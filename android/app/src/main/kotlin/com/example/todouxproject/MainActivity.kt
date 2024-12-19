package com.example.todouxproject

import android.app.AlarmManager
import android.content.Context
import android.os.Build
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.todouxproject/exact_alarm"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Configurer le canal Flutter pour gérer les permissions d'alarmes précises
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "checkExactAlarmPermission" -> result.success(checkExactAlarmPermission())
                "requestExactAlarmPermission" -> {
                    requestExactAlarmPermission()
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }

    // Vérifie si l'autorisation d'alarmes précises est accordée
    private fun checkExactAlarmPermission(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val alarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager
            alarmManager.canScheduleExactAlarms()
        } else {
            true // Pas nécessaire pour les versions Android inférieures à 12
        }
    }

    // Demande l'autorisation d'alarmes précises
    private fun requestExactAlarmPermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val intent = android.provider.Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM
            startActivity(android.content.Intent(intent))
        }
    }
}

