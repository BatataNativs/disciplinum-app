package com.disciplinum.lock

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity

/**
 * LockActivity - Activity de bloqueio que aparece sobre apps monitorados
 * 
 * Esta Activity é iniciada pelo AccessibilityService quando um app monitorado é aberto.
 * Ela exibe uma tela de bloqueio sobre o app alvo, permitindo que o usuário decida
 * se deseja continuar ou voltar ao app Disciplinum.
 */
class LockActivity : FlutterActivity() {
    
    companion object {
        const val EXTRA_PACKAGE_NAME = "package_name"
        const val EXTRA_MODULE_ID = "module_id"
        const val EXTRA_MODULE_NAME = "module_name"
        
        fun createIntent(
            activity: Activity,
            packageName: String,
            moduleId: String,
            moduleName: String
        ): Intent {
            return Intent(activity, LockActivity::class.java).apply {
                putExtra(EXTRA_PACKAGE_NAME, packageName)
                putExtra(EXTRA_MODULE_ID, moduleId)
                putExtra(EXTRA_MODULE_NAME, moduleName)
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
            }
        }
    }
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Configura a Activity para aparecer sobre outras apps
        window.addFlags(
            WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
            WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD or
            WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON or
            WindowManager.LayoutParams.FLAG_FULLSCREEN
        )
        
        // Inicia o Flutter engine com a rota de bloqueio
        val packageName = intent.getStringExtra(EXTRA_PACKAGE_NAME) ?: ""
        val moduleId = intent.getStringExtra(EXTRA_MODULE_ID) ?: ""
        val moduleName = intent.getStringExtra(EXTRA_MODULE_NAME) ?: ""
        
        // Passa os parâmetros para o Flutter via initial route
        val initialRoute = "/lock?package=$packageName&module=$moduleId&name=$moduleName"
        intent.putExtra("initial_route", initialRoute)
    }
    
    override fun onDestroy() {
        super.onDestroy()
        // Limpeza se necessário
    }
}
