package com.squiraldot.qippet_pets

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import es.antonborri.home_widget.HomeWidgetPlugin
import java.time.Clock

enum class PetAlarmStatus(val wireValue: String) {
    EXACT("exact"),
    INEXACT("inexact"),
    DISABLED("disabled"),
}

object PetAlarmScheduler {
    private const val REQUEST_CODE = 4101

    fun reschedule(context: Context): PetAlarmStatus {
        val appContext = context.applicationContext
        val alarmManager = appContext.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val baseIntent = Intent(appContext, PetScheduleAlarmReceiver::class.java).apply {
            action = PetScheduleAlarmReceiver.ACTION_TRANSITION
        }
        PendingIntent.getBroadcast(
            appContext,
            REQUEST_CODE,
            baseIntent,
            PendingIntent.FLAG_NO_CREATE or PendingIntent.FLAG_IMMUTABLE,
        )?.let { existing ->
            alarmManager.cancel(existing)
            existing.cancel()
        }

        val data = HomeWidgetPlugin.getData(appContext)
        val sleepTime = data.getString(
            PetWidgetProvider.KEY_SLEEP_TIME,
            PetWidgetProvider.DEFAULT_SLEEP_TIME,
        ) ?: PetWidgetProvider.DEFAULT_SLEEP_TIME
        val wakeTime = data.getString(
            PetWidgetProvider.KEY_WAKE_TIME,
            PetWidgetProvider.DEFAULT_WAKE_TIME,
        ) ?: PetWidgetProvider.DEFAULT_WAKE_TIME
        val trigger = PetAlarmTimeCalculator(Clock.systemDefaultZone())
            .nextTrigger(sleepTime, wakeTime)
            ?: return PetAlarmStatus.DISABLED

        val exactAllowed = Build.VERSION.SDK_INT < Build.VERSION_CODES.S ||
            alarmManager.canScheduleExactAlarms()
        val alarmIntent = Intent(appContext, PetScheduleAlarmReceiver::class.java).apply {
            action = PetScheduleAlarmReceiver.ACTION_TRANSITION
            putExtra(PetScheduleAlarmReceiver.EXTRA_TRANSITION, trigger.transition.name)
        }
        val alarmPendingIntent = PendingIntent.getBroadcast(
            appContext,
            REQUEST_CODE,
            alarmIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
        val triggerAtMillis = trigger.at.toInstant().toEpochMilli()

        return if (exactAllowed) {
            alarmManager.setExactAndAllowWhileIdle(
                AlarmManager.RTC_WAKEUP,
                triggerAtMillis,
                alarmPendingIntent,
            )
            PetAlarmStatus.EXACT
        } else {
            alarmManager.setAndAllowWhileIdle(
                AlarmManager.RTC_WAKEUP,
                triggerAtMillis,
                alarmPendingIntent,
            )
            PetAlarmStatus.INEXACT
        }
    }

    fun exactAlarmPermissionStatus(context: Context): PetAlarmStatus {
        val allowed = Build.VERSION.SDK_INT < Build.VERSION_CODES.S ||
            (context.getSystemService(Context.ALARM_SERVICE) as AlarmManager).canScheduleExactAlarms()
        return if (allowed) PetAlarmStatus.EXACT else PetAlarmStatus.INEXACT
    }

    fun openExactAlarmSettings(context: Context) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S) return
        val request = Intent(
            Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM,
            Uri.parse("package:${context.packageName}"),
        ).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        try {
            context.startActivity(request)
        } catch (_: Exception) {
            val fallback = Intent(
                Settings.ACTION_APPLICATION_DETAILS_SETTINGS,
                Uri.parse("package:${context.packageName}"),
            ).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            runCatching { context.startActivity(fallback) }
        }
    }
}
