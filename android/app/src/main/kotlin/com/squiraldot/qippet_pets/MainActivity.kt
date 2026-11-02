package com.squiraldot.qippet_pets

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
                    PetAlarmScheduler.reschedule(this).wireValue,
                )
                "requestExactAlarmPermission" -> {
                    PetAlarmScheduler.requestExactAlarmPermission(this)
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
        PetAlarmScheduler.reschedule(this)
    }

    override fun onResume() {
        super.onResume()
        PetAlarmScheduler.reschedule(this)
    }

    companion object {
        private const val SCHEDULE_CHANNEL = "com.squiraldot.qippet_pets/schedule"
    }
}
