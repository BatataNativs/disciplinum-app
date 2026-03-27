package com.disciplinum

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.disciplinum.app_lock.AppLockService

class MainActivity: FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Configura o MethodChannel do App Lock
        AppLockService.setupChannel(flutterEngine, this)
        
        // Define a activity atual no serviço
        AppLockService.getInstance().setCurrentActivity(this)
    }
    
    override fun onDestroy() {
        super.onDestroy()
        // Limpa a referência da activity
        AppLockService.getInstance().setCurrentActivity(null)
    }
}
