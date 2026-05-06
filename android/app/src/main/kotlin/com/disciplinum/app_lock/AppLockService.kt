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
        private const val METHOD_CLOSE_APP = "closeBlockedApp"

        private var instance: AppLockService? = null

        fun getInstance(): AppLockService {
            if (instance == null) {
                instance = AppLockService()
            }
            return instance!!
        }

        fun setupChannel(flutterEngine: FlutterEngine, context: Context) {
            val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_NAME)
            channel.setMethodCallHandler(getInstance())
        }
    }

    private var currentActivity: FlutterActivity? = null

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
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
            else -> {
                result.notImplemented()
            }
        }
    }

    /// Fecha o app bloqueado via sistema (volta para home e mata processo)
    private fun closeBlockedApp(packageName: String) {
        try {
            val activityManager = currentActivity?.getSystemService(Context.ACTIVITY_SERVICE) as? ActivityManager

            // Volta para home
            val intent = Intent(Intent.ACTION_MAIN).apply {
                addCategory(Intent.CATEGORY_HOME)
                flags = Intent.FLAG_ACTIVITY_NEW_TASK
            }
            currentActivity?.startActivity(intent)

            // Tenta matar o processo do app bloqueado
            activityManager?.killBackgroundProcesses(packageName)

            android.util.Log.d("AppLock", "App bloqueado fechado: $packageName")
        } catch (e: Exception) {
            android.util.Log.e("AppLock", "Erro ao fechar app: $packageName", e)
        }
    }

    /// Define a activity atual (chamado pelo MainActivity)
    fun setCurrentActivity(activity: FlutterActivity?) {
        currentActivity = activity
    }
}
