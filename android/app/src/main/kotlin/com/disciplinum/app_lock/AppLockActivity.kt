package com.disciplinum.app_lock

import android.content.Intent
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.view.WindowManager
import android.widget.Button
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import com.disciplinum.app.R

/**
 * Activity que mostra a tela de bloqueio quando um app monitorado é aberto.
 * Esta Activity é iniciada pelo AppLockService quando detecta um app bloqueado.
 */
class AppLockActivity : AppCompatActivity() {
    
    companion object {
        const val EXTRA_APP_NAME = "appName"
        const val EXTRA_PACKAGE_NAME = "packageName"
        const val EXTRA_NICHE_ID = "nicheId"
    }
    
    private var appName: String = ""
    private var packageName: String = ""
    private var nicheId: String = ""
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Configurações para manter a tela sempre visível e bloquear interações
        window.addFlags(
            WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON or
            WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
            WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON
        )
        
        // Obtém os dados do intent
        appName = intent.getStringExtra(EXTRA_APP_NAME) ?: ""
        packageName = intent.getStringExtra(EXTRA_PACKAGE_NAME) ?: ""
        nicheId = intent.getStringExtra(EXTRA_NICHE_ID) ?: ""
        
        setContentView(R.layout.activity_app_lock)
        
        setupUI()
    }
    
    private fun setupUI() {
        // Configura o título com o nome do app
        val titleText = findViewById<TextView>(R.id.lockTitle)
        titleText.text = "📱 $appName está bloqueado"
        
        // Configura a mensagem
        val messageText = findViewById<TextView>(R.id.lockMessage)
        messageText.text = "Este aplicativo está sendo monitorado pelo Disciplinum. Escolha uma opção:"
        
        // Botão para sair do app (voltar para home)
        val exitButton = findViewById<Button>(R.id.exitButton)
        exitButton.setOnClickListener {
            AppLockService.getInstance().processUserChoice("exit")
            finish()
        }
        
        // Botão para abrir o app (com reset de gamificação)
        val openButton = findViewById<Button>(R.id.openButton)
        openButton.setOnClickListener {
            AppLockService.getInstance().processUserChoice("open")
            finish()
        }
    }
    
    override fun onBackPressed() {
        // Bloqueia o botão de voltar - usuário deve escolher uma opção
        // Não chama super.onBackPressed()
    }
    
    override fun onPause() {
        super.onPause()
        // Garante que a activity fique no topo
        Handler(Looper.getMainLooper()).postDelayed({
            val intent = packageManager.getLaunchIntentForPackage(packageName)
            if (intent != null) {
                // Se o usuário tentou sair, mantém nossa tela visível
                val lockIntent = Intent(this, AppLockActivity::class.java).apply {
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                    putExtra(EXTRA_APP_NAME, appName)
                    putExtra(EXTRA_PACKAGE_NAME, packageName)
                    putExtra(EXTRA_NICHE_ID, nicheId)
                }
                startActivity(lockIntent)
            }
        }, 100)
    }
    
    override fun onDestroy() {
        super.onDestroy()
        // Limpa a referência da activity no serviço
        AppLockService.getInstance().setCurrentActivity(null)
    }
}
