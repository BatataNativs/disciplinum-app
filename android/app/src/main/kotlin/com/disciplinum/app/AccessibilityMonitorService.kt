package com.disciplinum.app

import android.accessibilityservice.AccessibilityService
import android.view.accessibility.AccessibilityEvent
import android.content.Intent
import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.EventChannel
import com.disciplinum.lock.LockDecisionEngine
import com.disciplinum.lock.LockActivity

class AccessibilityMonitorService : AccessibilityService() {

    companion object {
        private var eventSink: EventChannel.EventSink? = null
        private var lockDecisionEngine: LockDecisionEngine? = null
        private var monitoredApps: Set<String> = emptySet()
        private var moduleConfigs: Map<String, LockDecisionEngine.ModuleConfig> = emptyMap()
        data class AppSession(
            val packageName: String,
            val authorizedAt: Long
        )
        private val authorizedSessions: MutableMap<String, AppSession> = mutableMapOf()

        fun setEventSink(sink: EventChannel.EventSink?) {
            eventSink = sink
        }

        fun updateMonitoredApps(apps: Set<String>) {
            monitoredApps = apps
        }

        fun updateModuleConfigs(configs: Map<String, LockDecisionEngine.ModuleConfig>) {
            moduleConfigs = configs
            android.util.Log.d("AccessMonitor", "updateModuleConfigs: ${configs.size} módulos, engine=${ if (lockDecisionEngine != null) "OK" else "NULL" }")
            lockDecisionEngine?.updateModuleConfigs(configs)
        }

        fun updateViolationCounts(counts: Map<String, Int>) {
            lockDecisionEngine?.updateViolationCounts(counts)
        }

        private const val SESSION_DURATION_MS = 5 * 60 * 1000L // 5 minutos

        /** Adiciona um app à lista de sessões autorizadas */
        fun addAuthorizedSession(packageName: String) {
            authorizedSessions[packageName] = AppSession(packageName, System.currentTimeMillis())
            android.util.Log.d("AccessMonitor", "Sessão autorizada para $packageName")
        }

        /** Verifica se o app possui uma sessão autorizada ativa */
        private fun isSessionAuthorized(packageName: String): Boolean {
            val session = authorizedSessions[packageName] ?: return false
            val currentTime = System.currentTimeMillis()
            if (currentTime - session.authorizedAt < SESSION_DURATION_MS) {
                return true
            }
            authorizedSessions.remove(packageName)
            return false
        }

        /** Notifica o Flutter de que uma regra foi violada */
        fun notifyRuleViolated(moduleId: String, packageName: String) {
            Handler(Looper.getMainLooper()).post {
                try {
                    eventSink?.success(mapOf<String, Any>(
                        "type" to "rule_violated",
                        "moduleId" to moduleId,
                        "packageName" to packageName
                    ))
                    android.util.Log.d("AccessMonitor", "Evento rule_violated enviado: módulo $moduleId, pacote $packageName")
                } catch (e: Exception) {
                    android.util.Log.e("AccessMonitor", "Erro ao enviar rule_violated para o Flutter", e)
                }
            }
        }

        fun getMonitoredApps(): Set<String> = monitoredApps

        fun getLockDecisionEngine(): LockDecisionEngine? = lockDecisionEngine
    }

    private var currentPackage: String? = null
    private var lastEventTime = 0L
    private val eventHandler = Handler(Looper.getMainLooper())
    
    // Debounce de 50ms para evitar múltiplas chamadas para o mesmo app
    private val debounceDelay = 50L

    override fun onServiceConnected() {
        super.onServiceConnected()
        
        // Tenta carregar as configs salvas nativamente no SharedPreferences
        try {
            val prefs = getSharedPreferences("DisciplinumAppLockPrefs", android.content.Context.MODE_PRIVATE)
            val configsJson = prefs.getString("module_configs", null)
            if (configsJson != null) {
                val jsonArray = org.json.JSONArray(configsJson)
                val loadedConfigs = mutableMapOf<String, LockDecisionEngine.ModuleConfig>()
                
                for (i in 0 until jsonArray.length()) {
                    val obj = jsonArray.getJSONObject(i)
                    val id = obj.getString("id")
                    
                    val pkgsArray = obj.getJSONArray("monitoredPackages")
                    val pkgs = mutableSetOf<String>()
                    for (j in 0 until pkgsArray.length()) {
                        pkgs.add(pkgsArray.getString(j))
                    }
                    
                    val config = LockDecisionEngine.ModuleConfig(
                        id = id,
                        name = obj.getString("name"),
                        isActive = obj.getBoolean("isActive"),
                        monitoredPackages = pkgs,
                        startTime = if (obj.isNull("startTime")) null else obj.getString("startTime"),
                        endTime = if (obj.isNull("endTime")) null else obj.getString("endTime"),
                        maxViolationsPerDay = if (obj.has("maxViolationsPerDay")) obj.getInt("maxViolationsPerDay") else Int.MAX_VALUE
                    )
                    loadedConfigs[id] = config
                }
                moduleConfigs = loadedConfigs
                android.util.Log.d("AccessMonitor", "Configs carregadas do SharedPreferences com sucesso!")
            }
        } catch (e: Exception) {
            android.util.Log.e("AccessMonitor", "Erro ao carregar configs do SharedPreferences", e)
        }

        // Inicializa LockDecisionEngine
        lockDecisionEngine = LockDecisionEngine(this)
        lockDecisionEngine?.updateModuleConfigs(moduleConfigs)
        android.util.Log.d("AccessMonitor", "onServiceConnected: engine criado, ${moduleConfigs.size} configs ativas")
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent) {
        if (event.eventType == AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) {
            val packageName = event.packageName?.toString()
            val currentTime = System.currentTimeMillis()
            
            if (packageName != null && packageName != currentPackage) {
                // Ignorar eventos de teclado, systemui ou permissões para não limpar a sessão 
                // indevidamente quando eles aparecem sobrepostos
                if (packageName == "com.android.systemui" || 
                    packageName == "com.google.android.permissioncontroller" ||
                    packageName.contains("inputmethod")) {
                    return
                }

                if (currentPackage != null) {
                    val session = authorizedSessions[currentPackage]
                    if (session != null && (currentTime - session.authorizedAt < 2000)) {
                        // Grace period: não remove a sessão se foi autorizada há menos de 2 segundos.
                        // Isso previne que transições de tela rápidas/instáveis matem a autorização.
                        android.util.Log.d("AccessMonitor", "Sessão mantida (grace period) para $currentPackage")
                    } else {
                        // Remove a sessão do pacote anterior, pois ele não está mais em foreground
                        authorizedSessions.remove(currentPackage)
                        android.util.Log.d("AccessMonitor", "Sessão encerrada para $currentPackage (mudou para $packageName)")
                    }
                }
                
                // Debounce: ignora eventos muito próximos (menos de 50ms)
                if (currentTime - lastEventTime < debounceDelay) {
                    return
                }
                
                currentPackage = packageName
                lastEventTime = currentTime
                
                // Processa de forma assíncrona para não bloquear o thread de acessibilidade
                eventHandler.post {
                    processAppEvent(packageName)
                }
            }
        }
    }
    
    private fun processAppEvent(packageName: String) {
        try {
            // Verifica sessão autorizada (usuário escolheu "abrir mesmo assim" anteriormente nesta sessão)
            if (isSessionAuthorized(packageName)) {
                android.util.Log.d("AccessMonitor", "$packageName tem sessão autorizada, ignorando")
                eventSink?.success(mapOf<String, Any>(
                    "type" to "app_opened",
                    "packageName" to packageName,
                    "reason" to "Sessão em andamento"
                ))
                return
            }

            android.util.Log.d("AccessMonitor", "processAppEvent: pkg=$packageName engine=${ if (lockDecisionEngine != null) "OK" else "NULL" } configs=${moduleConfigs.keys}")
            
            // Se o engine existe mas os configs ainda não foram aplicados (race condition),
            // re-aplica agora antes de decidir
            val engine = lockDecisionEngine
            if (engine != null && moduleConfigs.isNotEmpty()) {
                engine.updateModuleConfigs(moduleConfigs)
            }
            
            // Decide se deve bloquear nativamente
            val decision = lockDecisionEngine?.shouldLockApp(packageName)
            
            if (decision?.shouldLock == true) {
                // Bloqueia nativamente - inicia LockActivity
                val friendlyName = getFriendlyModuleName(decision.moduleId)
                val intent = LockActivity.createIntent(
                    this,
                    packageName,
                    decision.moduleId,
                    friendlyName
                )
                startActivity(intent)

                // Envia evento para Flutter para gamificação (após bloqueio)
                eventSink?.success(mapOf<String, Any>(
                    "type" to "app_blocked",
                    "packageName" to packageName,
                    "moduleId" to decision.moduleId,
                    "reason" to decision.reason
                ))
            } else {
                // Não bloqueia - envia evento apenas para monitoramento
                eventSink?.success(mapOf<String, Any>(
                    "type" to "app_opened",
                    "packageName" to packageName,
                    "reason" to (decision?.reason ?: "Not monitored")
                ))
            }
        } catch (e: Exception) {
            android.util.Log.e("AccessibilityMonitor", "Erro ao processar evento", e)
        }
    }

    private fun getFriendlyModuleName(moduleId: String): String {
        return when (moduleId) {
            "focus" -> "Foco e Produtividade"
            "spending" -> "Controle de Gastos"
            "smoking" -> "Controle do Fumo"
            "diet" -> "Compulsão Alimentar"
            "binge_eating" -> "Compulsão Alimentar"
            "adult_content" -> "Jejum 18+"
            "digital_detox" -> "Jejum Digital"
            else -> "Módulo Desconhecido"
        }
    }


    override fun onInterrupt() {
        // Obrigatório, mas não precisamos fazer nada aqui
    }

    override fun onDestroy() {
        super.onDestroy()
        eventSink = null
        lockDecisionEngine = null
        eventHandler.removeCallbacksAndMessages(null)
    }
}
