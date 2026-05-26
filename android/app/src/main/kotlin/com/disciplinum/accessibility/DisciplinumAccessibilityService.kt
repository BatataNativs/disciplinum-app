package com.disciplinum.accessibility

import android.accessibilityservice.AccessibilityService
import android.content.Intent
import android.view.accessibility.AccessibilityEvent
import android.content.Context
import io.flutter.plugin.common.MethodChannel

/**
 * DisciplinumAccessibilityService - Service de acessibilidade para detectar apps em foreground
 * 
 * Este service monitora quando apps são abertos e inicia o LockActivity se o app
 * estiver na lista de apps monitorados e o módulo correspondente estiver ativo.
 */
class DisciplinumAccessibilityService : AccessibilityService() {
    
    private var currentPackage: String? = null
    private var monitoredApps: Set<String> = emptySet()
    private var activeModules: Map<String, Boolean> = emptyMap()
    
    companion object {
        private const val TAG = "DisciplinumAccessibility"
        private const val CHANNEL = "com.disciplinum.app/accessibility"
    }
    
    override fun onServiceConnected() {
        super.onServiceConnected()
        // Service conectado, pronto para monitorar apps
    }
    
    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        event ?: return
        
        when (event.eventType) {
            AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED -> {
                val packageName = event.packageName?.toString()
                if (packageName != null && packageName != currentPackage) {
                    currentPackage = packageName
                    handleAppSwitch(packageName)
                }
            }
        }
    }
    
    override fun onInterrupt() {
        // Service interrompido
    }
    
    private fun handleAppSwitch(packageName: String) {
        // Verifica se o app está na lista de monitoramento
        if (packageName in monitoredApps) {
            // Verifica se o módulo correspondente está ativo
            val moduleId = getModuleIdForPackage(packageName)
            if (moduleId != null && activeModules[moduleId] == true) {
                // Inicia LockActivity
                val moduleName = getModuleNameForModuleId(moduleId) ?: "Módulo"
                val intent = LockActivity.createIntent(
                    this,
                    packageName,
                    moduleId,
                    moduleName
                )
                startActivity(intent)
            }
        }
    }
    
    private fun getModuleIdForPackage(packageName: String): String? {
        // Mapeamento de pacotes para módulos
        // Isso deve ser configurado via MethodChannel do Flutter
        return when (packageName) {
            "com.instagram.android" -> "instagram"
            "com.facebook.katana" -> "facebook"
            "com.twitter.android" -> "twitter"
            "com.tiktok.android" -> "tiktok"
            "com.youtube.android" -> "youtube"
            else -> null
        }
    }
    
    private fun getModuleNameForModuleId(moduleId: String): String? {
        return when (moduleId) {
            "instagram" -> "Instagram"
            "facebook" -> "Facebook"
            "twitter" -> "Twitter"
            "tiktok" -> "TikTok"
            "youtube" -> "YouTube"
            else -> null
        }
    }
    
    /**
     * Atualiza a lista de apps monitorados
     * Chamado via MethodChannel do Flutter
     */
    fun updateMonitoredApps(apps: Set<String>) {
        monitoredApps = apps
    }
    
    /**
     * Atualiza o estado dos módulos ativos
     * Chamado via MethodChannel do Flutter
     */
    fun updateActiveModules(modules: Map<String, Boolean>) {
        activeModules = modules
    }
}
