# Architecture decisions

## 2026-11-03 — Android-only Flutter foundation

- **Decision:** Use Flutter for the app UI and native Android/Kotlin integration for the home-screen widget.
- **Package:** `com.squiraldot.qippet_pets`; Flutter project name: `qippet_pets`.
- **Platform scope:** Android only, minimum SDK 24.
- **Release signing:** Use a configured release keystore only when all signing secrets are present; otherwise use debug signing for CI builds.
- **Release channel:** Maintain a rolling GitHub prerelease tagged `latest`, plus a per-run workflow artifact.

## 2026-11-03 — Pet catalog, animation, and persistence

- **Catalog:** Start with `cat`, `dog`, and `bunny`; stable IDs are persisted rather than display names.
- **Sprite source of truth:** Keep the six state sequences under `assets/pets/<petId>/`; Android `drawable-nodpi` files are generated copies. Flutter reads source assets directly.
- **Placeholder art:** Use deterministic Pillow geometry so the UI can be developed before commissioned artwork exists. Final artwork must preserve the exact 256 × 256 transparent PNG contract and filenames.
- **Frame contract:** Five frames per state; idle 6 FPS, tap-happy 10 FPS, tap-spin 12 FPS, sleep-start 8 FPS, sleeping 3 FPS, and wake-up 8 FPS.
- **Persistence:** Use `home_widget` data APIs for `selectedPetId`, `sleepTime`, and `wakeTime`, backed by Android SharedPreferences. Keep app state in a small `ChangeNotifier` controller rather than adding a state-management framework.
- **Schedule semantics:** Interpret schedule values in the device's local time zone. A sleep interval crossing midnight is supported; identical sleep and wake times mean the pet stays awake.
- **Widget scope:** The app button remains a clear placeholder until a native Android widget provider and launcher flow are implemented.
- **CI asset generation:** Pillow-generated source sprites and synchronized Android copies are committed by the main-branch CI job when generated files change. Pull-request runs generate and verify them without writing to the branch.

## 2026-11-03 — Kotlin and Java bytecode target alignment

- **Failure evidence:** GitHub Actions run `41525730979` failed in `:home_widget:compileReleaseKotlin`: its Java compile task targeted JVM 1.8 while Kotlin compilation targeted JVM 17.
- **Root cause:** Setting Kotlin's target for all subprojects did not change the Java compile options of Android library plugins pulled in through Flutter federated plugins.
- **Decision:** Configure every subproject's `JavaCompile` tasks to use Java 17 source and target compatibility, and configure Kotlin compile tasks with `JvmTarget.JVM_17`. This aligns the actual bytecode targets rather than disabling Gradle's compatibility validation.
- **Evidence:** Android Developers documents explicit Java `sourceCompatibility` and `targetCompatibility`; Kotlin documents that related Java/Kotlin tasks must have matching targets. The upstream `home_widget` Android build configuration also migrated to Java 17.
- **References:** https://developer.android.com/build/jdks, https://kotlinlang.org/docs/gradle-configure-project.html, https://github.com/ABausG/home_widget/pull/437

## 2026-11-03 — Android library compileOptions enforcement

- **Failure evidence:** Follow-up GitHub Actions run `41526726368` showed the previous task-level JavaCompile configuration was overridden by Android Gradle Plugin variant configuration: `:home_widget:compileReleaseJavaWithJavac` still targeted JVM 1.8 while Kotlin targeted JVM 17.
- **Root cause:** Android Gradle Plugin derives variant Java task targets from the Android DSL's `android.compileOptions`; setting generic JavaCompile task properties before AGP configures variants is not authoritative.
- **Decision:** For every subproject applying `com.android.library`, configure its `LibraryExtension.compileOptions` to Java 17 after the plugin is applied. Keep generic JavaCompile and KotlinCompile task defaults aligned as additional coverage. Do not disable Gradle's JVM target validation.
- **Validation:** A fresh release build is required; analyze/test passing alone does not verify this Android plugin compilation path.
- **References:** https://developer.android.com/build/jdks, https://docs.gradle.org/current/userguide/building_java_projects.html, https://kotlinlang.org/docs/gradle-compiler-options.html

## 2026-11-03 — Apply JVM targets after Android plugin evaluation

- **Failure evidence:** Run `41527777543` still failed at `:home_widget:compileReleaseKotlin` with Java `compileReleaseJavaWithJavac` at JVM 1.8 and Kotlin at JVM 17, despite configuring the Android library DSL from the root project.
- **Root cause:** The `home_widget` module's own Gradle script applies its Java 8 defaults after the root project's early task/extension configuration. Earlier configuration actions therefore did not win for the generated release variant.
- **Decision:** Move the JavaCompile and KotlinCompile target configuration into Gradle's `projectsEvaluated` lifecycle callback. The callback is registered from the root build and configures plugin tasks only after subproject build scripts have completed, so the common JVM 17 policy is applied last. Keep Gradle's compatibility validation enabled.
- **Validation:** The next release APK workflow must confirm the actual `:home_widget:compileReleaseJavaWithJavac` and `:home_widget:compileReleaseKotlin` pair succeeds.

## 2026-11-03 — Native Android pet home-screen widget

- **Decision:** Implement a classic XML AppWidgetProvider named PetWidgetProvider, using home_widget's HomeWidgetPlugin.getData(context) accessor so Kotlin reads the same SharedPreferences instance and keys written by Flutter.
- **Widget appearance:** Use one ImageView inside a transparent, rounded FrameLayout. The default footprint is 2 × 2 cells, it can resize horizontally and vertically, and periodic updates are disabled; Flutter explicitly requests immediate updates after pet or schedule changes.
- **State resolution:** Resolve local wall-clock LocalTime values in a pure Kotlin PetStateResolver. The sleep interval includes its start and excludes its wake boundary; overnight intervals are supported, and equal or malformed times resolve to AWAKE.
- **Artwork:** Select pre-generated drawable-nodpi resource IDs for each supported pet and state. Widget rendering uses RemoteViews.setImageViewResource, never bitmaps.
- **Testing:** Add JVM unit tests for overnight and same-day windows, exact boundary minutes, and equal-time schedules. Run them in CI with ./gradlew testDebugUnitTest; CI bootstraps the wrapper JAR because this repository intentionally does not check in the generated binary.

## 2026-11-03 — Native widget tap animations

- **Decision:** Give the widget root an explicit immutable broadcast PendingIntent targeting a non-exported PetTapAnimationReceiver. Keep the widget ID in the intent so each widget instance has an independent in-flight guard.
- **Playback:** Use goAsync() and a main-thread Handler to send one RemoteViews frame every 120 ms, then restore the schedule-derived idle/sleeping frame. The sequence is capped at 2 seconds. Repeated taps for the same widget are ignored until completion.
- **Sleep behavior:** Resolve the same local sleep/wake schedule before playback; a sleeping pet receives no tap animation and remains on its sleeping frame.
- **Animation data:** Discover tap animation groups from drawable resource names matching pet_<petId>_tap_<animation>_<NN>. Each group is an ordered frame-name list plus a frame delay, so adding a correctly named animation's assets automatically makes it selectable.
- **Testing:** Cover deterministic selection, resource-name discovery, frame ordering, invalid delays, and the two-second sequence cap with JVM unit tests.

## 2026-11-03 — Automatic sleep/wake alarms

- **Scheduling model:** Keep one pending transition alarm at a time. The pure Kotlin calculator chooses the next state boundary (sleep or wake) from the current local schedule; after a transition, the receiver schedules the following boundary.
- **Exact alarm access:** Declare `SCHEDULE_EXACT_ALARM` only. On Android 12+, check `AlarmManager.canScheduleExactAlarms()`; use `setExactAndAllowWhileIdle` when allowed and `setAndAllowWhileIdle` otherwise. Report exact, inexact, or disabled status through a Flutter MethodChannel and offer the system access settings shortcut.
- **Transition playback:** A schedule alarm plays the matching `sleep_start` or `wake_up` drawable sequence, then re-resolves the current wall-clock state and updates every widget. Stale alarms never force a state inconsistent with the configured schedule.
- **Rescheduling:** Recompute after app launch/resume, Flutter sleep/wake preference changes, boot, system time changes, timezone changes, package replacement, and exact-alarm permission changes.
- **DST policy:** Resolve local wall-clock times using `LocalDateTime.atZone(zone)`. Nonexistent times during a spring-forward gap move forward by the DST gap; ambiguous fall-back times use java.time's earlier valid offset. The calculator accepts an injected `Clock` for deterministic tests.
- **Self-healing:** Every widget render continues to derive its frame from `PetStateResolver(LocalTime.now(), ...)`, so a delayed or missed alarm cannot leave the widget displaying a stale sleep state.
