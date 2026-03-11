package com.disciplinum.app

import android.accessibilityservice.AccessibilityService
import android.view.accessibility.AccessibilityEvent
import io.flutter.plugin.common.EventChannel

class AccessibilityMonitorService : AccessibilityService() {

    companion object {
        private var eventSink: EventChannel.EventSink? = null

        fun setEventSink(sink: EventChannel.EventSink?) {
            eventSink = sink
        }
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent) {
        if (event.eventType == AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) {
            val packageName = event.packageName?.toString()
            if (packageName != null) {
                // Envia o nome do pacote para o Flutter instantaneamente
                eventSink?.success(packageName)
            }
        }
    }

    override fun onInterrupt() {
        // Obrigatório, mas não precisamos fazer nada aqui
    }

    override fun onDestroy() {
        super.onDestroy()
        eventSink = null
    }
}
