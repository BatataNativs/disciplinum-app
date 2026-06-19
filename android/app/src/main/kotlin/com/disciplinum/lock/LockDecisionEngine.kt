package com.disciplinum.lock

import android.content.Context

/**
 * LockDecisionEngine - Engine que decide se deve bloquear um app
 * 
 * Esta engine contém a lógica de decisão de bloqueio baseada em:
 * - Estado do módulo (ativo/inativo)
 * - Horário atual (se o módulo tem horário restrito)
 * - Número de violações recentes
 * - Configurações do usuário
 */
class LockDecisionEngine(private val context: Context) {
    
    data class LockDecision(
        val shouldLock: Boolean,
        val reason: String,
        val moduleId: String
    )
    
    data class ModuleConfig(
        val id: String,
        val name: String,
        val isActive: Boolean,
        val monitoredPackages: Set<String> = emptySet(), // Lista de packages monitorados por este módulo
        val startTime: String? = null, // formato "HH:mm"
        val endTime: String? = null,   // formato "HH:mm"
        val maxViolationsPerDay: Int = Int.MAX_VALUE
    )
    
    private var moduleConfigs: Map<String, ModuleConfig> = emptyMap()
    private var violationCounts: Map<String, Int> = emptyMap()
    
    /**
     * Atualiza as configurações dos módulos
     */
    fun updateModuleConfigs(configs: Map<String, ModuleConfig>) {
        moduleConfigs = configs
    }
    
    /**
     * Atualiza os contadores de violações
     */
    fun updateViolationCounts(counts: Map<String, Int>) {
        violationCounts = counts
    }
    
    /**
     * Decide se deve bloquear o app baseado nas regras
     */
    fun shouldLockApp(packageName: String): LockDecision {
        val moduleId = getModuleIdForPackage(packageName) ?: return LockDecision(
            shouldLock = false,
            reason = "App não monitorado",
            moduleId = ""
        )
        
        val config = moduleConfigs[moduleId] ?: return LockDecision(
            shouldLock = false,
            reason = "Módulo não configurado",
            moduleId = moduleId
        )
        
        // Verifica se o módulo está ativo
        if (!config.isActive) {
            return LockDecision(
                shouldLock = false,
                reason = "Módulo inativo",
                moduleId = moduleId
            )
        }
        
        // Verifica horário restrito
        if (config.startTime != null && config.endTime != null) {
            if (!isWithinAllowedTime(config.startTime, config.endTime)) {
                return LockDecision(
                    shouldLock = false,
                    reason = "Fora do horário permitido",
                    moduleId = moduleId
                )
            }
        }
        
        // Verifica limite de violações
        val violations = violationCounts[moduleId] ?: 0
        if (violations >= config.maxViolationsPerDay) {
            return LockDecision(
                shouldLock = false,
                reason = "Limite de violações atingido",
                moduleId = moduleId
            )
        }
        
        // Deve bloquear
        return LockDecision(
            shouldLock = true,
            reason = "App monitorado e módulo ativo",
            moduleId = moduleId
        )
    }
    
    /**
     * Verifica se o horário atual está dentro do período permitido
     */
    private fun isWithinAllowedTime(startTime: String, endTime: String): Boolean {
        val now = java.time.LocalTime.now()
        val start = java.time.LocalTime.parse(startTime)
        val end = java.time.LocalTime.parse(endTime)
        
        return if (start.isBefore(end)) {
            now.isAfter(start) && now.isBefore(end)
        } else {
            // Período que atravessa meia-noite
            now.isAfter(start) || now.isBefore(end)
        }
    }
    
    /**
     * Mapeamento dinâmico de pacotes para módulos
     * Busca em todas as configurações de módulos para encontrar qual módulo monitora este package
     */
    private fun getModuleIdForPackage(packageName: String): String? {
        // Busca em todas as configs para encontrar o módulo que monitora este package
        for ((moduleId, config) in moduleConfigs) {
            if (config.monitoredPackages.contains(packageName)) {
                return moduleId
            }
        }
        return null
    }
}
