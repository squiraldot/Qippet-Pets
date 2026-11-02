package com.squiraldot.qippet_pets

import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            SCHEDULE_CHANNEL,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "schedulePetAlarms" -> result.success(
                    PetAlarmScheduler.reschedule(this).wireValue,
                )
                "getPetAlarmStatus" -> result.success(
                    PetAlarmScheduler.exactAlarmPermissionStatus(this).wireValue,
                )
                "requestExactAlarmPermission" -> {
                    PetAlarmScheduler.openExactAlarmSettings(this)
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            PLATFORM_CHANNEL,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "requestPinWidget" -> {
                    val manager = AppWidgetManager.getInstance(this)
                    val supported = Build.VERSION.SDK_INT >= Build.VERSION_CODES.O &&
                        manager.isRequestPinAppWidgetSupported
                    val accepted = supported && manager.requestPinAppWidget(
                        ComponentName(this, PetWidgetProvider::class.java),
                        null,
                        null,
                    )
                    result.success(accepted)
                }
                "openMiuiAutostartSettings" -> result.success(openMiuiAutostartSettings())
                "openBatterySettings" -> result.success(openAppSettings())
                else -> result.notImplemented()
            }
        }
        PetAlarmScheduler.reschedule(this)
    }

    override fun onResume() {
        super.onResume()
        PetAlarmScheduler.reschedule(this)
    }

    private fun openMiuiAutostartSettings(): Boolean {
        val miuiIntent = Intent("miui.intent.action.OP_AUTO_START").apply {
            component = ComponentName(
                "com.miui.securitycenter",
                "com.miui.permcenter.autostart.AutoStartManagementActivity",
            )
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }
        return try {
            startActivity(miuiIntent)
            true
        } catch (_: Exception) {
            openAppSettings()
        }
    }

    private fun openAppSettings(): Boolean = try {
        startActivity(
            Intent(
                Settings.ACTION_APPLICATION_DETAILS_SETTINGS,
                Uri.parse("package:$packageName"),
            ).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK),
        )
        true
    } catch (_: Exception) {
        false
    }

    companion object {
        private const val SCHEDULE_CHANNEL = "com.squiraldot.qippet_pets/schedule"
        private const val PLATFORM_CHANNEL = "com.squiraldot.qippet_pets/platform"
    }
}
