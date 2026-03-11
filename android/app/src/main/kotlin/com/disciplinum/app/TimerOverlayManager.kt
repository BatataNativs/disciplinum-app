package com.disciplinum.app

import android.content.Context
import android.graphics.PixelFormat
import android.os.Build
import android.view.Gravity
import android.view.View
import android.view.WindowManager
import android.widget.LinearLayout
import android.widget.TextView
import android.graphics.Color
import android.graphics.Typeface
import android.graphics.drawable.GradientDrawable
import android.util.TypedValue

class TimerOverlayManager(private val context: Context) {
    private val windowManager = context.getSystemService(Context.WINDOW_SERVICE) as WindowManager
    private var overlayView: View? = null

    fun show(secondsRemaining: Int, message: String?) {
        if (overlayView != null) {
            update(secondsRemaining, message)
            return
        }

        val params = WindowManager.LayoutParams(
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.WRAP_CONTENT,
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
                WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
            else
                WindowManager.LayoutParams.TYPE_PHONE,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL or WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN,
            PixelFormat.TRANSLUCENT
        ).apply {
            gravity = Gravity.TOP
            y = 130 // Descer mais para não bater no entalhe/barra de status
        }

        val container = LinearLayout(context).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(40, 40, 40, 40)
            gravity = Gravity.CENTER
            background = GradientDrawable().apply {
                setColor(Color.parseColor("#FF222222")) // Cinza quase preto opaco
                cornerRadius = 40f
            }
        }

        val textView = TextView(context).apply {
            id = View.generateViewId()
            text = message ?: "Atenção!"
            setTextColor(Color.WHITE)
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 16f)
            typeface = Typeface.DEFAULT_BOLD
            gravity = Gravity.CENTER
            setPadding(0, 0, 0, 20)
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
            )
        }
        container.addView(textView)

        val barContainer = LinearLayout(context).apply {
            id = View.generateViewId()
            orientation = LinearLayout.HORIZONTAL
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                35
            )
            gravity = Gravity.CENTER
        }

        for (i in 1..30) {
            val segment = View(context).apply {
                layoutParams = LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.MATCH_PARENT, 1f).apply {
                    setMargins(2, 0, 2, 0)
                }
                tag = "seg_$i"
            }
            barContainer.addView(segment)
        }

        container.addView(barContainer)
        overlayView = container
        
        try {
            windowManager.addView(overlayView, params)
            update(secondsRemaining, message)
        } catch (e: Exception) {
            overlayView = null
        }
    }

    fun update(secondsRemaining: Int, message: String?) {
        val container = overlayView as? LinearLayout ?: return
        val textView = container.getChildAt(0) as? TextView
        val barContainer = container.getChildAt(1) as? LinearLayout ?: return

        if (message != null && message.isNotEmpty()) {
            textView?.text = message
        }

        val elapsed = 30 - secondsRemaining

        for (i in 0 until 30) {
            val segment = barContainer.getChildAt(i) ?: continue
            val segmentPosition = i + 1
            
            if (segmentPosition > elapsed) {
                val color = when {
                    segmentPosition <= 10 -> "#4CAF50"
                    segmentPosition <= 20 -> "#FFEB3B"
                    else -> "#F44336"
                }
                segment.setBackgroundColor(Color.parseColor(color))
                segment.alpha = 1.0f
            } else {
                segment.setBackgroundColor(Color.TRANSPARENT)
                segment.alpha = 0.0f
            }
        }
    }


    fun hide() {
        overlayView?.let {
            try {
                windowManager.removeView(it)
            } catch (e: Exception) {}
            overlayView = null
        }
    }
}
