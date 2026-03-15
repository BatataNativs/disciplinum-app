package com.disciplinum.app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import android.content.Intent
import android.provider.Settings
import android.text.TextUtils
import android.content.Context
import com.disciplinum.app.AccessibilityMonitorService
import com.disciplinum.app.TimerOverlayManager

class MainActivity : FlutterActivity() {
    private val ACCESSIBILITY_EVENT_CHANNEL = "com.disciplinum.app/accessibility"
    private val ACCESSIBILITY_METHOD_CHANNEL = "com.disciplinum.app/accessibility_methods"

    private lateinit var timerOverlayManager: TimerOverlayManager

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        timerOverlayManager = TimerOverlayManager(this)

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
                    result.success(true)
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
                "showAccessibilityHint" -> {
                    val target = call.argument<String>("target") ?: "installed_apps"
                    val message = call.argument<String>("message") ?: "Toque aqui"
                    val duration = call.argument<Int>("duration") ?: 3000
                    showAccessibilityHint(target, message, duration)
                    result.success(true)
                }
                else -> {
                    result.notImplemented()
                }
            }
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
        val intent = Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS)
        val serviceName = "${packageName}/${AccessibilityMonitorService::class.java.name}"
        
        // Parâmetros para fazer o Android destacar (blink) o item na lista, se suportado
        intent.putExtra(":settings:fragment_args_key", serviceName)
        val bundle = android.os.Bundle()
        bundle.putString(":settings:fragment_args_key", serviceName)
        intent.putExtra(":settings:show_fragment_args", bundle)
        
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        startActivity(intent)
    }

    private fun showAccessibilityHint(target: String, message: String, duration: Int) {
        when (target) {
            "installed_apps" -> {
                // Usar o TimerOverlayManager para mostrar hint sobre "Aplicativos instalados"
                timerOverlayManager.showHint(
                    title = "Aplicativos instalados",
                    message = message,
                    duration = duration,
                    position = "top"
                )
            }
            "disciplinum_item" -> {
                // Usar o TimerOverlayManager para mostrar hint sobre "Disciplinum"
                timerOverlayManager.showHint(
                    title = "Disciplinum",
                    message = message,
                    duration = duration,
                    position = "center"
                )
            }
        }
    }
}
