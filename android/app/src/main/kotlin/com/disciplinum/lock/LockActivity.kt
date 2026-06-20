package com.disciplinum.lock

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.os.Bundle
import android.view.Gravity
import android.view.ViewGroup
import android.view.WindowManager
import android.widget.Button
import android.widget.LinearLayout
import android.widget.TextView

/**
 * LockActivity - Activity nativa de bloqueio que aparece sobre apps monitorados.
 *
 * IMPORTANTE: Herda de Activity (não FlutterActivity) para que possa ser exibida
 * sobre outros apps sem depender do engine Flutter estar ativo.
 *
 * Exibe uma tela de bloqueio simples com duas opções:
 * - Voltar: encerra o app monitorado e fica na tela de bloqueio (sem abrir Disciplinum)
 * - Abrir mesmo assim: fecha o bloqueio e permite que o app monitorado seja aberto
 */
class LockActivity : Activity() {

    companion object {
        const val EXTRA_PACKAGE_NAME = "package_name"
        const val EXTRA_MODULE_ID = "module_id"
        const val EXTRA_MODULE_NAME = "module_name"

        fun createIntent(
            context: Context,
            packageName: String,
            moduleId: String,
            moduleName: String
        ): Intent {
            return Intent(context, LockActivity::class.java).apply {
                putExtra(EXTRA_PACKAGE_NAME, packageName)
                putExtra(EXTRA_MODULE_ID, moduleId)
                putExtra(EXTRA_MODULE_NAME, moduleName)
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
            }
        }
    }

    private var blockedPackageName: String = ""

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Configura para aparecer sobre outras apps e na tela de bloqueio
        window.addFlags(
            WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
            WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD or
            WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON or
            WindowManager.LayoutParams.FLAG_FULLSCREEN or
            WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON
        )

        blockedPackageName = intent.getStringExtra(EXTRA_PACKAGE_NAME) ?: ""
        val moduleId = intent.getStringExtra(EXTRA_MODULE_ID) ?: ""
        val moduleName = intent.getStringExtra(EXTRA_MODULE_NAME) ?: moduleId

        buildLockUi(moduleName)
    }

    private fun buildLockUi(moduleName: String) {
        val root = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER
            setBackgroundColor(Color.parseColor("#0D0D0D"))
            layoutParams = ViewGroup.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.MATCH_PARENT
            )
            setPadding(80, 80, 80, 80)
        }

        // Ícone / emoji de cadeado
        val iconText = TextView(this).apply {
            text = "🔒"
            textSize = 64f
            gravity = Gravity.CENTER
        }

        // Título
        val title = TextView(this).apply {
            text = "App Bloqueado"
            textSize = 24f
            setTextColor(Color.WHITE)
            gravity = Gravity.CENTER
            setPadding(0, 32, 0, 0)
        }

        // Subtítulo com nome do módulo
        val subtitle = TextView(this).apply {
            text = "Este app está sendo monitorado\npelo módulo \"$moduleName\""
            textSize = 16f
            setTextColor(Color.parseColor("#AAAAAA"))
            gravity = Gravity.CENTER
            setPadding(0, 16, 0, 48)
        }

        // Botão Voltar (ação segura)
        val btnBack = Button(this).apply {
            text = "↩ Voltar"
            textSize = 16f
            setTextColor(Color.WHITE)
            setBackgroundColor(Color.parseColor("#1DB954"))
            setPadding(40, 24, 40, 24)
            layoutParams = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
            ).also { it.setMargins(0, 0, 0, 24) }
            setOnClickListener { goHome() }
        }

        // Botão Abrir mesmo assim (ação de risco)
        val btnOpen = Button(this).apply {
            text = "Abrir mesmo assim"
            textSize = 14f
            setTextColor(Color.parseColor("#FF6B6B"))
            setBackgroundColor(Color.parseColor("#222222"))
            setPadding(40, 24, 40, 24)
            layoutParams = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
            )
            setOnClickListener { openAnyway() }
        }

        root.addView(iconText)
        root.addView(title)
        root.addView(subtitle)
        root.addView(btnBack)
        root.addView(btnOpen)

        setContentView(root)
    }

    /** Volta para a tela inicial do Android (sem abrir o Disciplinum) */
    private fun goHome() {
        val homeIntent = Intent(Intent.ACTION_MAIN).apply {
            addCategory(Intent.CATEGORY_HOME)
            flags = Intent.FLAG_ACTIVITY_NEW_TASK
        }
        startActivity(homeIntent)
        finish()
    }

    /** Permite abrir o app e fecha o bloqueio */
    private fun openAnyway() {
        // Adiciona bypass temporário de 10 minutos + grace period de 10 segundos para evitar loop de bloqueio
        // Baseado em soluções profissionais como InstaGuard e Reels Blocker
        com.disciplinum.app.AccessibilityMonitorService.addBypassedApp(blockedPackageName)

        // Tenta lançar o app monitorado explicitamente
        try {
            val launchIntent = packageManager.getLaunchIntentForPackage(blockedPackageName)
            if (launchIntent != null) {
                launchIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                launchIntent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
                startActivity(launchIntent)
                android.util.Log.d("LockActivity", "App lançado: $blockedPackageName")
            } else {
                // Se não conseguir lançar, volta para home
                android.util.Log.w("LockActivity", "Não foi possível lançar intent para $blockedPackageName")
                goHome()
                return
            }
        } catch (e: Exception) {
            android.util.Log.e("LockActivity", "Erro ao lançar app", e)
            goHome()
            return
        }

        // Pequeno delay antes de fechar para garantir que o app seja lançado
        android.os.Handler(android.os.Looper.getMainLooper()).postDelayed({
            finish()
        }, 300)
    }

    override fun onBackPressed() {
        // Impede que o botão voltar feche a tela sem escolha
        goHome()
    }
}
