package com.squiraldot.qippet_pets

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
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
            updatePetWidget(context, appWidgetManager, appWidgetId)
        }
    }

    override fun onEnabled(context: Context) {
        super.onEnabled(context)
        val manager = AppWidgetManager.getInstance(context)
        val provider = ComponentName(context, PetWidgetProvider::class.java)
        onUpdate(context, manager, manager.getAppWidgetIds(provider))
    }

    private fun updatePetWidget(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int,
    ) {
        // Read the exact SharedPreferences store managed by home_widget.
        val widgetData = HomeWidgetPlugin.getData(context)
        val petId = widgetData.getString(KEY_SELECTED_PET_ID, DEFAULT_PET_ID)
            ?: DEFAULT_PET_ID
        val sleepTime = widgetData.getString(KEY_SLEEP_TIME, DEFAULT_SLEEP_TIME)
            ?: DEFAULT_SLEEP_TIME
        val wakeTime = widgetData.getString(KEY_WAKE_TIME, DEFAULT_WAKE_TIME)
            ?: DEFAULT_WAKE_TIME

        val state = PetStateResolver(LocalTime.now(), sleepTime, wakeTime).resolve()
        val imageResource = drawableFor(petId, state)
        val views = RemoteViews(context.packageName, R.layout.pet_widget).apply {
            setImageViewResource(R.id.pet_widget_image, imageResource)
        }
        appWidgetManager.updateAppWidget(appWidgetId, views)
    }

    private fun drawableFor(petId: String, state: PetState): Int {
        val sleeping = state == PetState.SLEEPING
        return when (petId) {
            "dog" -> if (sleeping) {
                R.drawable.pet_dog_sleeping_01
            } else {
                R.drawable.pet_dog_idle_01
            }
            "bunny" -> if (sleeping) {
                R.drawable.pet_bunny_sleeping_01
            } else {
                R.drawable.pet_bunny_idle_01
            }
            else -> if (sleeping) {
                R.drawable.pet_cat_sleeping_01
            } else {
                R.drawable.pet_cat_idle_01
            }
        }
    }

    private companion object {
        const val KEY_SELECTED_PET_ID = "selectedPetId"
        const val KEY_SLEEP_TIME = "sleepTime"
        const val KEY_WAKE_TIME = "wakeTime"
        const val DEFAULT_PET_ID = "cat"
        const val DEFAULT_SLEEP_TIME = "22:00"
        const val DEFAULT_WAKE_TIME = "07:00"
    }
}
