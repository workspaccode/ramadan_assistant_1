package com.example.ramadan_assistant

import android.app.AppOpsManager
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.app.usage.UsageEvents
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.graphics.Color
import android.graphics.PixelFormat
import android.graphics.drawable.GradientDrawable
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.provider.Settings
import android.view.Gravity
import android.view.MotionEvent
import android.view.View
import android.view.WindowManager
import android.widget.Button
import android.widget.LinearLayout
import android.widget.TextView

/** Process-wide hand-off between the overlay service and the Flutter activity. */
object OverlayState {
    @Volatile var pendingDone = false
}

/**
 * Foreground service that shows one small draggable bubble over the user's chosen reader app.
 * The bubble never records anything: "Done" only brings the app forward and asks for confirmation.
 */
class ReaderOverlayService : Service() {
    private val handler = Handler(Looper.getMainLooper())
    private var windowManager: WindowManager? = null
    private var panel: View? = null
    private var targetPackage: String = ""
    private var autoHide = false
    private var seenTarget = false
    private var lastForeground: String? = null
    private var lastPoll = 0L
    private val stopRunnable = Runnable { stopSelf() }
    private val pollRunnable = object : Runnable {
        override fun run() {
            if (pollForeground()) { stopSelf(); return }
            handler.postDelayed(this, 2000)
        }
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (intent?.action == ACTION_STOP) { stopSelf(); return START_NOT_STICKY }
        startAsForeground(intent?.getStringExtra("closeLabel") ?: "Close")
        if (intent == null || !Settings.canDrawOverlays(this)) { stopSelf(); return START_NOT_STICKY }
        removePanel()
        handler.removeCallbacksAndMessages(null)
        targetPackage = intent.getStringExtra("packageName") ?: ""
        autoHide = intent.getBooleanExtra("autoHide", false) && hasUsageAccess(this)
        seenTarget = false
        lastForeground = null
        lastPoll = System.currentTimeMillis()
        addPanel(
            intent.getStringExtra("title") ?: "",
            intent.getStringExtra("body") ?: "",
            intent.getStringExtra("doneLabel") ?: "Done",
            intent.getStringExtra("closeLabel") ?: "Close",
        )
        handler.postDelayed(stopRunnable, intent.getLongExtra("timeoutMs", 30 * 60 * 1000L))
        if (autoHide) handler.postDelayed(pollRunnable, 2000)
        return START_NOT_STICKY
    }

    private fun startAsForeground(closeLabel: String) {
        val manager = getSystemService(NotificationManager::class.java)
        if (Build.VERSION.SDK_INT >= 26) {
            manager.createNotificationChannel(
                NotificationChannel(CHANNEL, "Reading helper", NotificationManager.IMPORTANCE_LOW))
        }
        val stop = PendingIntent.getService(this, 1,
            Intent(this, ReaderOverlayService::class.java).setAction(ACTION_STOP),
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT)
        val builder = if (Build.VERSION.SDK_INT >= 26) Notification.Builder(this, CHANNEL)
        else @Suppress("DEPRECATION") Notification.Builder(this)
        val notification = builder.setSmallIcon(android.R.drawable.ic_dialog_info)
            .setContentTitle(applicationInfo.loadLabel(packageManager))
            .setOngoing(true)
            .addAction(Notification.Action.Builder(null, closeLabel, stop).build())
            .build()
        if (Build.VERSION.SDK_INT >= 34) {
            startForeground(NOTIFICATION_ID, notification, ServiceInfo.FOREGROUND_SERVICE_TYPE_SPECIAL_USE)
        } else startForeground(NOTIFICATION_ID, notification)
    }

    private fun dp(value: Int) = (value * resources.displayMetrics.density).toInt()

    private fun addPanel(title: String, body: String, doneLabel: String, closeLabel: String) {
        val background = GradientDrawable().apply {
            setColor(Color.parseColor("#F2102A27"))
            cornerRadius = dp(16).toFloat()
        }
        val titleView = TextView(this).apply {
            text = title; setTextColor(Color.WHITE); textSize = 14f
            setPadding(0, 0, 0, dp(2))
        }
        val bodyView = TextView(this).apply {
            text = body; setTextColor(Color.parseColor("#D8E6E3")); textSize = 13f
        }
        val done = Button(this).apply {
            text = doneLabel; isAllCaps = false; minHeight = dp(40); minimumHeight = dp(40)
            setOnClickListener { requestConfirm() }
        }
        val close = Button(this).apply {
            text = closeLabel; isAllCaps = false; minHeight = dp(40); minimumHeight = dp(40)
            setOnClickListener { stopSelf() }
        }
        val buttons = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            val cell = { LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.WRAP_CONTENT, 1f) }
            addView(done, cell().apply { marginEnd = dp(4) })
            addView(close, cell().apply { marginStart = dp(4) })
        }
        val view = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            this.background = background
            setPadding(dp(14), dp(10), dp(14), dp(10))
            addView(titleView); addView(bodyView)
            addView(buttons, LinearLayout.LayoutParams(-1, -2).apply { topMargin = dp(8) })
        }
        val type = if (Build.VERSION.SDK_INT >= 26) WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
        else @Suppress("DEPRECATION") WindowManager.LayoutParams.TYPE_PHONE
        val params = WindowManager.LayoutParams(
            dp(260), WindowManager.LayoutParams.WRAP_CONTENT, type,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS,
            PixelFormat.TRANSLUCENT,
        ).apply { gravity = Gravity.TOP or Gravity.START; x = dp(16); y = dp(96) }
        // Drag by the text area so buttons keep normal tap handling.
        var startX = 0; var startY = 0; var touchX = 0f; var touchY = 0f
        val drag = View.OnTouchListener { _, event ->
            when (event.action) {
                MotionEvent.ACTION_DOWN -> { startX = params.x; startY = params.y; touchX = event.rawX; touchY = event.rawY }
                MotionEvent.ACTION_MOVE -> {
                    params.x = startX + (event.rawX - touchX).toInt()
                    params.y = startY + (event.rawY - touchY).toInt()
                    windowManager?.updateViewLayout(view, params)
                }
            }
            true
        }
        titleView.setOnTouchListener(drag); bodyView.setOnTouchListener(drag)
        windowManager = getSystemService(Context.WINDOW_SERVICE) as WindowManager
        windowManager!!.addView(view, params)
        panel = view
    }

    private fun requestConfirm() {
        OverlayState.pendingDone = true
        startActivity(Intent(this, MainActivity::class.java)
            .setAction("app.tawabti.OPEN_SHORTCUT")
            .putExtra("tawabti_shortcut", "worship")
            .putExtra("tawabti_wird_done", true)
            .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP))
        stopSelf()
    }

    /** Returns true when the selected app was visible and the user has since left it. */
    private fun pollForeground(): Boolean {
        val stats = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val now = System.currentTimeMillis()
        val events = stats.queryEvents(lastPoll, now)
        lastPoll = now
        val event = UsageEvents.Event()
        while (events.hasNextEvent()) {
            events.getNextEvent(event)
            @Suppress("DEPRECATION")
            if (event.eventType == UsageEvents.Event.MOVE_TO_FOREGROUND) lastForeground = event.packageName
        }
        val current = lastForeground ?: return false
        if (current == targetPackage) { seenTarget = true; return false }
        return seenTarget
    }

    private fun removePanel() {
        panel?.let { runCatching { windowManager?.removeView(it) } }
        panel = null
    }

    override fun onDestroy() {
        handler.removeCallbacksAndMessages(null)
        removePanel()
        super.onDestroy()
    }

    companion object {
        const val ACTION_STOP = "app.tawabti.overlay.STOP"
        private const val CHANNEL = "reader_overlay"
        private const val NOTIFICATION_ID = 2000100

        fun hasUsageAccess(context: Context): Boolean {
            val ops = context.getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
            @Suppress("DEPRECATION")
            val mode = ops.checkOpNoThrow(AppOpsManager.OPSTR_GET_USAGE_STATS,
                android.os.Process.myUid(), context.packageName)
            return mode == AppOpsManager.MODE_ALLOWED
        }
    }
}
