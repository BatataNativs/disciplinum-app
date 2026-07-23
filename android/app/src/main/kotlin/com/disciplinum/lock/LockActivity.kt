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

    private fun dp(value: Int): Int {
        return (value * resources.displayMetrics.density).toInt()
    }

    private fun buildLockUi(moduleName: String) {
        // Fundo principal com gradiente escuro
        val root = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER
            background = android.graphics.drawable.GradientDrawable(
                android.graphics.drawable.GradientDrawable.Orientation.TL_BR,
                intArrayOf(Color.parseColor("#0F0F0F"), Color.parseColor("#1A1A1A"))
            )
            layoutParams = ViewGroup.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.MATCH_PARENT
            )
        }

        // Card central
        val card = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER
            background = android.graphics.drawable.GradientDrawable().apply {
                setColor(Color.parseColor("#222222"))
                cornerRadius = dp(32).toFloat()
                setStroke(dp(1), Color.parseColor("#333333"))
            }
            elevation = dp(16).toFloat()
            setPadding(dp(24), dp(40), dp(24), dp(40))
            layoutParams = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
            ).apply {
                setMargins(dp(32), 0, dp(32), 0)
            }
        }

        // Ícone / emoji de cadeado com fundo circular
        val iconText = TextView(this).apply {
            text = "🔒"
            textSize = 52f
            gravity = Gravity.CENTER
            background = android.graphics.drawable.GradientDrawable().apply {
                shape = android.graphics.drawable.GradientDrawable.OVAL
                setColor(Color.parseColor("#2D2D2D"))
                setStroke(dp(1), Color.parseColor("#444444"))
            }
            layoutParams = LinearLayout.LayoutParams(dp(100), dp(100)).apply {
                setMargins(0, 0, 0, dp(24))
            }
        }

        // Título
        val title = TextView(this).apply {
            text = "App Bloqueado"
            textSize = 22f
            setTextColor(Color.WHITE)
            typeface = android.graphics.Typeface.DEFAULT_BOLD
            gravity = Gravity.CENTER
            layoutParams = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.WRAP_CONTENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
            ).apply {
                setMargins(0, 0, 0, dp(8))
            }
        }

        // Subtítulo com nome do módulo
        val subtitle = TextView(this).apply {
            text = "Este app está sendo monitorado\npelo módulo \"$moduleName\""
            textSize = 15f
            setTextColor(Color.parseColor("#BBBBBB"))
            gravity = Gravity.CENTER
            setLineSpacing(dp(4).toFloat(), 1f)
            layoutParams = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.WRAP_CONTENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
            ).apply {
                setMargins(0, 0, 0, dp(32))
            }
        }

        // Botão Voltar (ação segura)
        val btnBack = android.widget.Button(this).apply {
            text = "↩ Voltar"
            textSize = 16f
            isAllCaps = false
            typeface = android.graphics.Typeface.DEFAULT_BOLD
            setTextColor(Color.WHITE)
            background = android.graphics.drawable.GradientDrawable().apply {
                colors = intArrayOf(Color.parseColor("#1DB954"), Color.parseColor("#1AA34A"))
                cornerRadius = dp(100).toFloat()
            }
            stateListAnimator = null // Remove sombra padrão do botão
            layoutParams = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                dp(56)
            ).apply {
                setMargins(0, 0, 0, dp(16))
            }
            setOnClickListener { goHome() }
        }

        // Botão Abrir mesmo assim (ação de risco)
        val btnOpen = android.widget.Button(this).apply {
            text = "Abrir mesmo assim"
            textSize = 14f
            isAllCaps = false
            typeface = android.graphics.Typeface.DEFAULT_BOLD
            setTextColor(Color.parseColor("#FF6B6B"))
            background = android.graphics.drawable.GradientDrawable().apply {
                setColor(Color.parseColor("#2D2D2D"))
                setStroke(dp(1), Color.parseColor("#444444"))
                cornerRadius = dp(100).toFloat()
            }
            stateListAnimator = null
            layoutParams = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                dp(52)
            )
            setOnClickListener { openAnyway() }
        }

        card.addView(iconText)
        card.addView(title)
        card.addView(subtitle)
        card.addView(btnBack)
        card.addView(btnOpen)

        root.addView(card)

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
        // Cria uma sessão autorizada para o app (válida enquanto ele estiver em foreground)
        com.disciplinum.app.AccessibilityMonitorService.addAuthorizedSession(blockedPackageName)

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
