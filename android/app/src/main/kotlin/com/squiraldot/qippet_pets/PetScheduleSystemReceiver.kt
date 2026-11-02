package com.squiraldot.qippet_pets

import android.appwidget.AppWidgetManager
import android.content.BroadcastReceiver
import android.content.ComponentName
import android.content.Context
import android.content.Intent

class PetScheduleSystemReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action !in SYSTEM_ACTIONS) return
        val appContext = context.applicationContext
        PetAlarmScheduler.reschedule(appContext)

        val manager = AppWidgetManager.getInstance(appContext)
        val provider = ComponentName(appContext, PetWidgetProvider::class.java)
        manager.getAppWidgetIds(provider).forEach { widgetId ->
            PetWidgetProvider.updateWidget(appContext, manager, widgetId)
        }
    }

    companion object {
        private val SYSTEM_ACTIONS = setOf(
            Intent.ACTION_BOOT_COMPLETED,
            Intent.ACTION_TIME_CHANGED,
            Intent.ACTION_TIMEZONE_CHANGED,
            Intent.ACTION_MY_PACKAGE_REPLACED,
            AlarmManagerPermissionAction.ACTION,
        )
    }
}

private object AlarmManagerPermissionAction {
    const val ACTION = "android.app.action.SCHEDULE_EXACT_ALARM_PERMISSION_STATE_CHANGED"
}
