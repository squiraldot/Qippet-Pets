package com.squiraldot.qippet_pets

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin
import java.time.LocalTime

class PetWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
    ) {
        appWidgetIds.forEach { appWidgetId ->
            updateWidget(context, appWidgetManager, appWidgetId)
        }
    }

    override fun onEnabled(context: Context) {
        super.onEnabled(context)
        val manager = AppWidgetManager.getInstance(context)
        val provider = android.content.ComponentName(context, PetWidgetProvider::class.java)
        onUpdate(context, manager, manager.getAppWidgetIds(provider))
    }

    companion object {
        internal const val KEY_SELECTED_PET_ID = "selectedPetId"
        internal const val KEY_SLEEP_TIME = "sleepTime"
        internal const val KEY_WAKE_TIME = "wakeTime"
        internal const val DEFAULT_PET_ID = "cat"
        internal const val DEFAULT_SLEEP_TIME = "22:00"
        internal const val DEFAULT_WAKE_TIME = "07:00"

        internal fun updateWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int,
        ) {
            val widgetData = HomeWidgetPlugin.getData(context)
            val petId = widgetData.getString(KEY_SELECTED_PET_ID, DEFAULT_PET_ID) ?: DEFAULT_PET_ID
            val sleepTime = widgetData.getString(KEY_SLEEP_TIME, DEFAULT_SLEEP_TIME) ?: DEFAULT_SLEEP_TIME
            val wakeTime = widgetData.getString(KEY_WAKE_TIME, DEFAULT_WAKE_TIME) ?: DEFAULT_WAKE_TIME
            val state = PetStateResolver(LocalTime.now(), sleepTime, wakeTime).resolve()
            renderFrame(context, appWidgetManager, appWidgetId, drawableFor(petId, state))
        }

        internal fun renderFrame(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int,
            imageResource: Int,
        ) {
            val tapIntent = Intent(context, PetTapAnimationReceiver::class.java).apply {
                action = PetTapAnimationReceiver.ACTION_TAP
                putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
            }
            val pendingIntent = PendingIntent.getBroadcast(
                context,
                appWidgetId,
                tapIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
            )
            val views = RemoteViews(context.packageName, R.layout.pet_widget).apply {
                setImageViewResource(R.id.pet_widget_image, imageResource)
                setOnClickPendingIntent(R.id.pet_widget_root, pendingIntent)
            }
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }

        private fun drawableFor(petId: String, state: PetState): Int {
            val sleeping = state == PetState.SLEEPING
            return when (petId) {
                "dog" -> if (sleeping) R.drawable.pet_dog_sleeping_01 else R.drawable.pet_dog_idle_01
                "bunny" -> if (sleeping) R.drawable.pet_bunny_sleeping_01 else R.drawable.pet_bunny_idle_01
                else -> if (sleeping) R.drawable.pet_cat_sleeping_01 else R.drawable.pet_cat_idle_01
            }
        }
    }
}
