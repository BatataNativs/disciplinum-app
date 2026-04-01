package com.disciplinum.app_lock

import android.app.ActivityManager
import android.content.Context
import android.content.Intent
import android.os.Handler
import android.os.Looper
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class AppLockService : MethodCallHandler {
    companion object {
        private const val CHANNEL_NAME = "disciplinum/app_lock"
        private const val METHOD_SHOW_LOCK = "showAppLockScreen"
        private const val METHOD_CLOSE_APP = "closeBlockedApp"
        private const val METHOD_IS_AVAILABLE = "isAvailable"
        
        private var instance: AppLockService? = null
        private var flutterEngineRef: FlutterEngine? = null
        
        fun getInstance(): AppLockService {
            if (instance == null) {
                instance = AppLockService()
            }
            return instance!!
        }
        
        fun setupChannel(flutterEngine: FlutterEngine, context: Context) {
            flutterEngineRef = flutterEngine
            val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_NAME)
            channel.setMethodCallHandler(getInstance())
        }
    }
    
    private var currentActivity: FlutterActivity? = null
    private var currentLockEvent: Map<String, Any>? = null
    
    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            METHOD_SHOW_LOCK -> {
                try {
                    val arguments = call.arguments as? Map<String, Any> ?: emptyMap()
                    showAppLockScreen(arguments)
                    result.success(true)
                } catch (e: Exception) {
                    result.error("ERROR", e.message, null)
                }
            }
            METHOD_CLOSE_APP -> {
                try {
                    val packageName = call.argument<String>("packageName")
                    if (packageName != null) {
                        closeBlockedApp(packageName)
                        result.success(true)
                    } else {
                        result.error("ERROR", "Package name não fornecido", null)
                    }
                } catch (e: Exception) {
                    result.error("ERROR", e.message, null)
                }
            }
            METHOD_IS_AVAILABLE -> {
                result.success(true)
            }
            else -> {
                result.notImplemented()
            }
        }
    }
    
    /// Mostra a tela de bloqueio do Flutter
    private fun showAppLockScreen(eventData: Map<String, Any>) {
        currentLockEvent = eventData
        
        // Inicia a Activity de bloqueio
        currentActivity?.let { activity ->
            val intent = Intent(activity, AppLockActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                putExtra("appName", eventData["appName"] as? String ?: "")
                putExtra("packageName", eventData["packageName"] as? String ?: "")
                putExtra("nicheId", eventData["nicheId"] as? String ?: "")
            }
            activity.startActivity(intent)
        }
        
        android.util.Log.d("AppLock", "Tela de bloqueio iniciada para: ${eventData["appName"]}")
    }
    
    /// Fecha o app bloqueado via sistema
    private fun closeBlockedApp(packageName: String) {
        try {
            val activityManager = currentActivity?.getSystemService(Context.ACTIVITY_SERVICE) as? ActivityManager
            
            // Força o fechamento do app
            val intent = Intent(Intent.ACTION_MAIN).apply {
                addCategory(Intent.CATEGORY_HOME)
                flags = Intent.FLAG_ACTIVITY_NEW_TASK
            }
            
            currentActivity?.startActivity(intent)
            
            // Tenta fechar o app específico
            activityManager?.killBackgroundProcesses(packageName)
            
            android.util.Log.d("AppLock", "App bloqueado e fechado: $packageName")
        } catch (e: Exception) {
            android.util.Log.e("AppLock", "Erro ao fechar app: $packageName", e)
        }
    }
    
    /// Define a activity atual (chamado pelo FlutterActivity)
    fun setCurrentActivity(activity: FlutterActivity?) {
        currentActivity = activity
    }
    
    /// Processa a escolha do usuário na tela de bloqueio
    fun processUserChoice(choice: String) {
        when (choice) {
            "exit" -> {
                // Usuário escolheu sair do app
                currentLockEvent?.let { event ->
                    closeBlockedApp(event["packageName"] as String)
                }
            }
            "open" -> {
                // Usuário escolheu abrir o app (com reset de gamificação)
                android.util.Log.d("AppLock", "Usuário escolheu abrir app - reset de gamificação")
                
                // Envia evento de reset de gamificação via MethodChannel
                flutterEngineRef?.let { engine ->
                    val channel = MethodChannel(engine.dartExecutor.binaryMessenger, CHANNEL_NAME)
                    currentLockEvent?.let { event ->
                        val nicheId = event["nicheId"] as? String ?: ""
                        channel.invokeMethod("resetGamification", mapOf("nicheId" to nicheId))
                        android.util.Log.d("AppLock", "Reset de gamificação enviado para nicheId: $nicheId")
                    }
                }
            }
        }
        
        currentLockEvent = null
    }
}
