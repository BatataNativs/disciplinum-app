package com.disciplinum.app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import android.content.Intent
import android.provider.Settings
import android.text.TextUtils
import android.content.Context
import android.util.Log
import com.disciplinum.app.AccessibilityMonitorService
import com.disciplinum.app.TimerOverlayManager
import com.disciplinum.app_lock.AppLockService

class MainActivity : FlutterActivity() {
    private val ACCESSIBILITY_EVENT_CHANNEL = "com.disciplinum.app/accessibility"
    private val ACCESSIBILITY_METHOD_CHANNEL = "com.disciplinum.app/accessibility_methods"

    private lateinit var timerOverlayManager: TimerOverlayManager

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        timerOverlayManager = TimerOverlayManager(applicationContext)

        // Configura o MethodChannel do App Lock
        AppLockService.setupChannel(flutterEngine, this)
        AppLockService.getInstance().setCurrentActivity(this)

        // Event Channel para o stream de eventos
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, ACCESSIBILITY_EVENT_CHANNEL).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    AccessibilityMonitorService.setEventSink(events)
                }

                override fun onCancel(arguments: Any?) {
                    AccessibilityMonitorService.setEventSink(null)
                }
            }
        )

        // Method Channel para comandos administrativos
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, ACCESSIBILITY_METHOD_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "isAccessibilityServiceEnabled" -> {
                    result.success(isAccessibilityServiceEnabled())
                }
                "openAccessibilitySettings" -> {
                    openAccessibilitySettings()
                    result.success(null)
                }
                "hasOverlayPermission" -> {
                    result.success(Settings.canDrawOverlays(this))
                }
                "requestOverlayPermission" -> {
                    val intent = Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION)
                    intent.data = android.net.Uri.parse("package:$packageName")
                    startActivity(intent)
                    result.success(true)
                }
                "showTimerOverlay" -> {
                    val seconds = call.argument<Int>("seconds") ?: 30
                    val message = call.argument<String>("message")
                    timerOverlayManager.show(seconds, message)
                    result.success(true)
                }
                "hideTimerOverlay" -> {
                    timerOverlayManager.hide()
                    result.success(true)
                }
                "updateTimerOverlay" -> {
                    val seconds = call.argument<Int>("seconds") ?: 30
                    val message = call.argument<String>("message")
                    timerOverlayManager.update(seconds, message)
                    result.success(true)
                }
                "getForegroundApp" -> {
                    // Obtém o app em foreground via UsageStats
                    val foregroundApp = getForegroundAppFromUsageStats()
                    result.success(foregroundApp)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun getForegroundAppFromUsageStats(): String? {
        try {
            val usageStatsManager = getSystemService(Context.USAGE_STATS_SERVICE) as? android.app.usage.UsageStatsManager
                ?: return null
            
            val endTime = System.currentTimeMillis()
            val startTime = endTime - 1000 * 60 // Último minuto
            
            val usageStats = usageStatsManager.queryUsageStats(
                android.app.usage.UsageStatsManager.INTERVAL_DAILY,
                startTime,
                endTime
            )
            
            if (usageStats.isNullOrEmpty()) {
                return null
            }
            
            // Encontra o app mais recente
            var recentApp: android.app.usage.UsageStats? = null
            for (stats in usageStats) {
                if (recentApp == null || stats.lastTimeUsed > recentApp.lastTimeUsed) {
                    recentApp = stats
                }
            }
            
            return recentApp?.packageName
        } catch (e: Exception) {
            Log.e("DisciplinumA11y", "Erro ao obter foreground app: ${e.message}")
            return null
        }
    }

    private fun isAccessibilityServiceEnabled(): Boolean {
        val service = "${packageName}/${AccessibilityMonitorService::class.java.name}"
        val enabled = Settings.Secure.getInt(contentResolver, Settings.Secure.ACCESSIBILITY_ENABLED, 0)
        if (enabled == 1) {
            val settingValue = Settings.Secure.getString(contentResolver, Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES)
            if (settingValue != null) {
                val splitter = TextUtils.SimpleStringSplitter(':')
                splitter.setString(settingValue)
                while (splitter.hasNext()) {
                    if (splitter.next().equals(service, ignoreCase = true)) {
                        return true
                    }
                }
            }
        }
        return false
    }

    private fun openAccessibilitySettings() {
        val component = android.content.ComponentName(packageName, AccessibilityMonitorService::class.java.name)
        val componentFull = component.flattenToString()     // com.disciplinum.app/com.disciplinum.app.AccessibilityMonitorService
        val componentShort = component.flattenToShortString() // com.disciplinum.app/.AccessibilityMonitorService
        
        Log.d("DisciplinumA11y", "componentFull=$componentFull")
        Log.d("DisciplinumA11y", "componentShort=$componentShort")

        // 1. Android 12+ Direct Details
        // Funciona em apps instalados pela Play Store.
        // Em debug/sideloaded, o Android 14 bloqueia com OPEN_ACCESSIBILITY_DETAILS_SETTINGS.
        if (android.os.Build.VERSION.SDK_INT >= 31) {
            try {
                val intent = Intent("android.settings.ACCESSIBILITY_DETAILS_SETTINGS").apply {
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    putExtra(Intent.EXTRA_COMPONENT_NAME, componentFull)
                }
                startActivity(intent)
                Log.d("DisciplinumA11y", "Details screen opened successfully (Play Store install)")
                return
            } catch (e: Exception) {
                Log.d("DisciplinumA11y", "Details denied (normal for debug builds): ${e.message}")
            }
        }

        // 2. Fallback: Lista de Acessibilidade com highlight keys
        // Enviamos o componentName nos dois formatos usados por diferentes fabricantes
        val intent = Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS).apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            putExtra(":settings:fragment_args_key", componentFull)
            putExtra(":settings:show_fragment_args", android.os.Bundle().apply {
                putString(":settings:fragment_args_key", componentFull)
            })
        }

        try {
            startActivity(intent)
        } catch (e: Exception) {
            Log.e("DisciplinumA11y", "Fallback fail: ${e.message}")
            startActivity(Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK))
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        // Limpa a referência da activity no AppLockService
        AppLockService.getInstance().setCurrentActivity(null)
    }
}
