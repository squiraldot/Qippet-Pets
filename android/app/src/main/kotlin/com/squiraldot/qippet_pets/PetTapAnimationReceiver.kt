package com.squiraldot.qippet_pets

import android.appwidget.AppWidgetManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Handler
import android.os.Looper
import es.antonborri.home_widget.HomeWidgetPlugin
import java.time.LocalTime
import kotlin.random.Random

/**
 * Runs short RemoteViews frame bursts. goAsync() keeps the broadcast alive until the final
 * idle render, while the process-wide widget ID set prevents overlapping tap animations.
 */
class PetTapAnimationReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != ACTION_TAP) return

        val pendingResult = goAsync()
        val appWidgetId = intent.getIntExtra(
            AppWidgetManager.EXTRA_APPWIDGET_ID,
            AppWidgetManager.INVALID_APPWIDGET_ID,
        )
        if (appWidgetId == AppWidgetManager.INVALID_APPWIDGET_ID || !beginAnimation(appWidgetId)) {
            pendingResult.finish()
            return
        }

        val appContext = context.applicationContext
        try {
            val data = HomeWidgetPlugin.getData(appContext)
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

            // A sleeping pet is deliberately not awakened or visually replaced.
            if (PetStateResolver(LocalTime.now(), sleepTime, wakeTime).resolve() == PetState.SLEEPING) {
                endAnimation(appWidgetId)
                pendingResult.finish()
                return
            }

            val availableNames = R.drawable::class.java.fields.map { it.name }
            val animations = PetTapAnimationCatalog.forPet(petId, availableNames)
            val animation = PetTapAnimationCatalog.select(animations, Random.nextInt())
            val frames = animation?.let { PetTapAnimationCatalog.playbackFrames(it) }.orEmpty()
            if (animation == null || frames.isEmpty()) {
                endAnimation(appWidgetId)
                pendingResult.finish()
                return
            }

            val manager = AppWidgetManager.getInstance(appContext)
            val handler = Handler(Looper.getMainLooper())
            var frameIndex = 0
            var finished = false
            lateinit var playback: Runnable

            fun finishPlayback() {
                if (finished) return
                finished = true
                try {
                    handler.removeCallbacks(playback)
                    runCatching { PetWidgetProvider.updateWidget(appContext, manager, appWidgetId) }
                } finally {
                    endAnimation(appWidgetId)
                    pendingResult.finish()
                }
            }

            playback = Runnable {
                try {
                    if (frameIndex >= frames.size) {
                        finishPlayback()
                    } else {
                        val resourceId = appContext.resources.getIdentifier(
                            frames[frameIndex],
                            "drawable",
                            appContext.packageName,
                        )
                        if (resourceId != 0) {
                            PetWidgetProvider.renderFrame(appContext, manager, appWidgetId, resourceId)
                        }
                        frameIndex += 1
                        handler.postDelayed(
                            if (frameIndex >= frames.size) Runnable { finishPlayback() } else playback,
                            animation.frameDelayMs,
                        )
                    }
                } catch (_: Exception) {
                    finishPlayback()
                }
            }
            handler.post(playback)
        } catch (_: Exception) {
            endAnimation(appWidgetId)
            pendingResult.finish()
        }
    }

    private fun beginAnimation(widgetId: Int): Boolean = synchronized(runningWidgetIds) {
        runningWidgetIds.add(widgetId)
    }

    private fun endAnimation(widgetId: Int) {
        synchronized(runningWidgetIds) {
            runningWidgetIds.remove(widgetId)
        }
    }

    companion object {
        const val ACTION_TAP = "com.squiraldot.qippet_pets.action.PET_WIDGET_TAP"
        private val runningWidgetIds = mutableSetOf<Int>()
    }
}
