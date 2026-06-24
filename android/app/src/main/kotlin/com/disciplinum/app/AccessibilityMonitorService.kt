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

        /** Adiciona um app à lista de sessões autorizadas */
        fun addAuthorizedSession(packageName: String) {
            authorizedSessions[packageName] = AppSession(packageName, System.currentTimeMillis())
            android.util.Log.d("AccessMonitor", "Sessão autorizada para $packageName")
        }

        /** Verifica se o app possui uma sessão autorizada ativa */
        private fun isSessionAuthorized(packageName: String): Boolean {
            return authorizedSessions.containsKey(packageName)
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
        // Inicializa LockDecisionEngine
        lockDecisionEngine = LockDecisionEngine(this)
        lockDecisionEngine?.updateModuleConfigs(moduleConfigs)
        android.util.Log.d("AccessMonitor", "onServiceConnected: engine criado, ${moduleConfigs.size} configs carregadas")
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
                    // Remove a sessão do pacote anterior, pois ele não está mais em foreground
                    authorizedSessions.remove(currentPackage)
                    android.util.Log.d("AccessMonitor", "Sessão encerrada para $currentPackage (mudou para $packageName)")
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
                val intent = LockActivity.createIntent(
                    this,
                    packageName,
                    decision.moduleId,
                    decision.moduleId // Usar moduleId como nome por enquanto
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
