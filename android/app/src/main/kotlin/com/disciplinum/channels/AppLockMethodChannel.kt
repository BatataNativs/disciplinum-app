package com.disciplinum.channels

import android.content.Context
import io.flutter.plugin.common.MethodChannel
import io.flutter.embedding.engine.FlutterEngine
import com.disciplinum.app.AccessibilityMonitorService
import com.disciplinum.lock.LockDecisionEngine

/**
 * AppLockMethodChannel - Canal de comunicação entre Flutter e Android para App Lock
 * 
 * Este canal permite que o Flutter:
 * - Atualize a lista de apps monitorados
 * - Atualize o estado dos módulos ativos
 * - Configure o LockDecisionEngine
 * - Verifique se o AccessibilityService está ativo
 */
class AppLockMethodChannel(private val context: Context) {
    
    companion object {
        const val CHANNEL_NAME = "com.disciplinum.app/app_lock"
        const val METHOD_UPDATE_MONITORED_APPS = "updateMonitoredApps"
        const val METHOD_UPDATE_ACTIVE_MODULES = "updateActiveModules"
        const val METHOD_UPDATE_MODULE_CONFIGS = "updateModuleConfigs"
        const val METHOD_UPDATE_VIOLATION_COUNTS = "updateViolationCounts"
        const val METHOD_IS_ACCESSIBILITY_ENABLED = "isAccessibilityEnabled"
        const val METHOD_REQUEST_OVERLAY_PERMISSION = "requestOverlayPermission"
        const val METHOD_CHECK_OVERLAY_PERMISSION = "checkOverlayPermission"
        
        private var instance: AppLockMethodChannel? = null
        
        fun getInstance(): AppLockMethodChannel? = instance
    }
    
    private var methodChannel: MethodChannel? = null
    
    init {
        instance = this
    }
    
    fun setupMethodChannel(flutterEngine: FlutterEngine) {
        methodChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL_NAME
        )
        setupMethodCallHandler()
    }
    
    private fun setupMethodCallHandler() {
        methodChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                METHOD_UPDATE_MONITORED_APPS -> {
                    try {
                        val apps = call.argument<List<String>>("apps") ?: emptyList()
                        updateMonitoredApps(apps.toSet())
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("ERROR", e.message, null)
                    }
                }
                
                METHOD_UPDATE_ACTIVE_MODULES -> {
                    try {
                        val modules = call.argument<Map<String, Boolean>>("modules") ?: emptyMap()
                        updateActiveModules(modules)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("ERROR", e.message, null)
                    }
                }
                
                METHOD_UPDATE_MODULE_CONFIGS -> {
                    try {
                        val configs = call.argument<List<Map<String, Any>>>("configs") ?: emptyList()
                        updateModuleConfigs(configs)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("ERROR", e.message, null)
                    }
                }
                
                METHOD_UPDATE_VIOLATION_COUNTS -> {
                    try {
                        val counts = call.argument<Map<String, Int>>("counts") ?: emptyMap()
                        updateViolationCounts(counts)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("ERROR", e.message, null)
                    }
                }
                
                METHOD_IS_ACCESSIBILITY_ENABLED -> {
                    try {
                        val isEnabled = isAccessibilityEnabled()
                        result.success(isEnabled)
                    } catch (e: Exception) {
                        result.error("ERROR", e.message, null)
                    }
                }
                
                METHOD_REQUEST_OVERLAY_PERMISSION -> {
                    try {
                        requestOverlayPermission()
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("ERROR", e.message, null)
                    }
                }
                
                METHOD_CHECK_OVERLAY_PERMISSION -> {
                    try {
                        val hasPermission = checkOverlayPermission()
                        result.success(hasPermission)
                    } catch (e: Exception) {
                        result.error("ERROR", e.message, null)
                    }
                }
                
                else -> result.notImplemented()
            }
        }
    }
    
    private fun updateMonitoredApps(apps: Set<String>) {
        // Atualiza o AccessibilityService com a lista de apps monitorados
        AccessibilityMonitorService.updateMonitoredApps(apps)
    }

    private fun updateActiveModules(modules: Map<String, Boolean>) {
        // Atualiza o LockDecisionEngine com os módulos ativos
        // Converte o Map<String, Boolean> para ModuleConfigs
        val moduleConfigs = modules.map { (moduleId, isActive) ->
            mapOf<String, Any>(
                "id" to moduleId,
                "name" to moduleId, // Usar moduleId como nome por enquanto
                "isActive" to isActive,
                "maxViolationsPerDay" to Int.MAX_VALUE
            )
        }
        updateModuleConfigs(moduleConfigs)
    }
    
    private fun updateModuleConfigs(configs: List<Map<String, Any>>) {
        val moduleConfigs = configs.associate { config ->
            val id = config["id"] as String
            val name = config["name"] as String
            val isActive = config["isActive"] as Boolean
            val monitoredPackagesRaw = config["monitoredPackages"]
            val monitoredPackages = if (monitoredPackagesRaw is List<*>) {
                monitoredPackagesRaw.map { it.toString() }.toSet()
            } else {
                emptySet()
            }
            val startTime = config["startTime"] as? String
            val endTime = config["endTime"] as? String
            val maxViolationsPerDay = config["maxViolationsPerDay"] as? Int ?: Int.MAX_VALUE
            
            android.util.Log.d("AppLockMethodChannel", "Config parsed: id=$id, isActive=$isActive, pkgs=$monitoredPackages, start=$startTime, end=$endTime")

            id to LockDecisionEngine.ModuleConfig(
                id = id,
                name = name,
                isActive = isActive,
                monitoredPackages = monitoredPackages,
                startTime = startTime,
                endTime = endTime,
                maxViolationsPerDay = maxViolationsPerDay
            )
        }
        android.util.Log.d("AppLockMethodChannel", "Updating AccessibilityMonitorService configs: ${moduleConfigs.keys}")
        AccessibilityMonitorService.updateModuleConfigs(moduleConfigs)
        
        // Salva as configurações de forma persistente no Android (para sobrevivência ao reboot)
        try {
            val jsonArray = org.json.JSONArray()
            for (config in configs) {
                val jsonObject = org.json.JSONObject()
                jsonObject.put("id", config["id"])
                jsonObject.put("name", config["name"])
                jsonObject.put("isActive", config["isActive"])
                
                val pkgsArray = org.json.JSONArray()
                val monitoredPackagesRaw = config["monitoredPackages"]
                if (monitoredPackagesRaw is List<*>) {
                    monitoredPackagesRaw.forEach { pkgsArray.put(it.toString()) }
                }
                jsonObject.put("monitoredPackages", pkgsArray)
                
                jsonObject.put("startTime", config["startTime"])
                jsonObject.put("endTime", config["endTime"])
                jsonObject.put("maxViolationsPerDay", config["maxViolationsPerDay"] ?: Int.MAX_VALUE)
                
                jsonArray.put(jsonObject)
            }
            
            val prefs = context.getSharedPreferences("DisciplinumAppLockPrefs", Context.MODE_PRIVATE)
            prefs.edit().putString("module_configs", jsonArray.toString()).apply()
            android.util.Log.d("AppLockMethodChannel", "Saved configs to SharedPreferences")
        } catch (e: Exception) {
            android.util.Log.e("AppLockMethodChannel", "Erro ao salvar configs no SharedPreferences", e)
        }
    }
    
    private fun updateViolationCounts(counts: Map<String, Int>) {
        AccessibilityMonitorService.updateViolationCounts(counts)
    }
    
    private fun isAccessibilityEnabled(): Boolean {
        val serviceName = "${context.packageName}/.AccessibilityMonitorService"
        val enabledServices = android.provider.Settings.Secure.getString(
            context.contentResolver,
            "enabled_accessibility_services"
        )
        return enabledServices?.contains(serviceName) == true
    }
    
    private fun requestOverlayPermission() {
        val intent = android.content.Intent(
            android.provider.Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
            android.net.Uri.parse("package:${context.packageName}")
        )
        intent.addFlags(android.content.Intent.FLAG_ACTIVITY_NEW_TASK)
        context.startActivity(intent)
    }
    
    private fun checkOverlayPermission(): Boolean {
        return android.provider.Settings.canDrawOverlays(context)
    }
    
    fun dispose() {
        methodChannel?.setMethodCallHandler(null)
        methodChannel = null
        instance = null
    }
}
