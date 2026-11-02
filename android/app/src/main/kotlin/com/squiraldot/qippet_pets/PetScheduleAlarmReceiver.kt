package com.squiraldot.qippet_pets

import android.appwidget.AppWidgetManager
import android.content.BroadcastReceiver
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.os.Handler
import android.os.Looper
import java.time.LocalTime

/**
 * Plays a transition sequence only when the alarm still matches the schedule-derived state.
 * The final RemoteViews update always resolves the current state, then schedules the next edge.
 */
class PetScheduleAlarmReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != ACTION_TRANSITION) return
        val pendingResult = goAsync()
        val appContext = context.applicationContext
        var resultFinished = false
        fun finishBroadcast() {
            if (!resultFinished) {
                resultFinished = true
                pendingResult.finish()
            }
        }

        try {
            val transition = intent.getStringExtra(EXTRA_TRANSITION)
            val data = es.antonborri.home_widget.HomeWidgetPlugin.getData(appContext)
            val petId = data.getString(
                PetWidgetProvider.KEY_SELECTED_PET_ID,
                PetWidgetProvider.DEFAULT_PET_ID,
            ) ?: PetWidgetProvider.DEFAULT_PET_ID
            val sleepTime = data.getString(
                PetWidgetProvider.KEY_SLEEP_TIME,
                PetWidgetProvider.DEFAULT_SLEEP_TIME,
            ) ?: PetWidgetProvider.DEFAULT_SLEEP_TIME
            val wakeTime = data.getString(
                PetWidgetProvider.KEY_WAKE_TIME,
                PetWidgetProvider.DEFAULT_WAKE_TIME,
            ) ?: PetWidgetProvider.DEFAULT_WAKE_TIME
            val state = PetStateResolver(LocalTime.now(), sleepTime, wakeTime).resolve()
            val animationName = when {
                transition == PetAlarmTransition.SLEEP.name && state == PetState.SLEEPING -> "sleep_start"
                transition == PetAlarmTransition.WAKE.name && state == PetState.AWAKE -> "wake_up"
                else -> null
            }

            val manager = AppWidgetManager.getInstance(appContext)
            val provider = ComponentName(appContext, PetWidgetProvider::class.java)
            val widgetIds = manager.getAppWidgetIds(provider)

            fun settleAndReschedule() {
                widgetIds.forEach { widgetId ->
                    runCatching { PetWidgetProvider.updateWidget(appContext, manager, widgetId) }
                }
                PetAlarmScheduler.reschedule(appContext)
            }

            if (animationName == null || widgetIds.isEmpty()) {
                try {
                    settleAndReschedule()
                } finally {
                    finishBroadcast()
                }
                return
            }

            val framePattern = Regex(
                "^pet_${Regex.escape(petId)}_${animationName}_(\\d{2})$",
            )
            val frameNames = R.drawable::class.java.fields
                .map { it.name }
                .mapNotNull { name ->
                    framePattern.matchEntire(name)?.let { it.groupValues[1].toInt() to name }
                }
                .sortedBy { it.first }
                .map { it.second }

            if (frameNames.isEmpty()) {
                try {
                    settleAndReschedule()
                } finally {
                    finishBroadcast()
                }
                return
            }

            val handler = Handler(Looper.getMainLooper())
            var index = 0
            var playbackFinished = false
            lateinit var playback: Runnable

            fun finishPlayback() {
                if (playbackFinished) return
                playbackFinished = true
                handler.removeCallbacks(playback)
                try {
                    settleAndReschedule()
                } finally {
                    finishBroadcast()
                }
            }

            playback = Runnable {
                try {
                    if (index >= frameNames.size) {
                        finishPlayback()
                    } else {
                        val resourceId = appContext.resources.getIdentifier(
                            frameNames[index],
                            "drawable",
                            appContext.packageName,
                        )
                        if (resourceId != 0) {
                            widgetIds.forEach { widgetId ->
                                PetWidgetProvider.renderFrame(appContext, manager, widgetId, resourceId)
                            }
                        }
                        index += 1
                        handler.postDelayed(
                            if (index >= frameNames.size) Runnable { finishPlayback() } else playback,
                            FRAME_DELAY_MS,
                        )
                    }
                } catch (_: Exception) {
                    finishPlayback()
                }
            }
            handler.post(playback)
        } catch (_: Exception) {
            try {
                PetAlarmScheduler.reschedule(appContext)
            } finally {
                finishBroadcast()
            }
        }
    }

    companion object {
        const val ACTION_TRANSITION = "com.squiraldot.qippet_pets.action.SCHEDULE_TRANSITION"
        const val EXTRA_TRANSITION = "transition"
        private const val FRAME_DELAY_MS = 125L
    }
}
