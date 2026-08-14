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
        val maxViolationsPerDay: Int = Int.MAX_VALUE,
        
        // Campos otimizados pré-processados
        val parsedStartTime: java.time.LocalTime? = null,
        val parsedEndTime: java.time.LocalTime? = null
    )
    
    private var moduleConfigs: Map<String, ModuleConfig> = emptyMap()
    private var violationCounts: Map<String, Int> = emptyMap()
    
    // Mapa O(1) de pacote para moduleId
    private var packageToModuleMap: Map<String, String> = emptyMap()
    
    /**
     * Atualiza as configurações dos módulos e pré-computa os mapas de decisão
     */
    fun updateModuleConfigs(configs: Map<String, ModuleConfig>) {
        val optimizedConfigs = mutableMapOf<String, ModuleConfig>()
        val newPackageMap = mutableMapOf<String, String>()
        
        for ((moduleId, config) in configs) {
            // Pré-processa as datas
            var pStart: java.time.LocalTime? = null
            var pEnd: java.time.LocalTime? = null
            
            try {
                if (config.startTime != null) pStart = java.time.LocalTime.parse(config.startTime)
                if (config.endTime != null) pEnd = java.time.LocalTime.parse(config.endTime)
            } catch (e: Exception) {
                android.util.Log.e("LockDecisionEngine", "Erro ao fazer parse de data para o módulo $moduleId: ${config.startTime} - ${config.endTime}")
            }
            
            val optimizedConfig = config.copy(
                parsedStartTime = pStart,
                parsedEndTime = pEnd
            )
            
            optimizedConfigs[moduleId] = optimizedConfig
            
            // Popula o mapa reverso O(1)
            for (pkg in config.monitoredPackages) {
                newPackageMap[pkg] = moduleId
            }
        }
        
        moduleConfigs = optimizedConfigs
        packageToModuleMap = newPackageMap
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
        
        // Verifica horário restrito de forma otimizada
        if (config.parsedStartTime != null && config.parsedEndTime != null) {
            if (!isWithinAllowedTime(config.parsedStartTime, config.parsedEndTime)) {
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
     * Verifica se o horário atual está dentro do período permitido usando os objetos cacheados
     */
    private fun isWithinAllowedTime(start: java.time.LocalTime, end: java.time.LocalTime): Boolean {
        val now = java.time.LocalTime.now()
        
        return if (start.isBefore(end)) {
            now.isAfter(start) && now.isBefore(end)
        } else {
            // Período que atravessa meia-noite
            now.isAfter(start) || now.isBefore(end)
        }
    }
    
    /**
     * Mapeamento dinâmico de pacotes para módulos - Agora com busca O(1)
     */
    private fun getModuleIdForPackage(packageName: String): String? {
        return packageToModuleMap[packageName]
    }
}
