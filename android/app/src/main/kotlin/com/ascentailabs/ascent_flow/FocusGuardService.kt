package com.ascentailabs.ascent_flow

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
import android.graphics.Typeface
import android.graphics.drawable.GradientDrawable
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.provider.Settings
import android.telecom.TelecomManager
import android.text.format.DateFormat
import android.util.TypedValue
import android.view.Gravity
import android.view.View
import android.view.WindowManager
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.TextView
import java.util.Date

/**
 * Runs for the length of a focus session, like Forest:
 *
 * - An ongoing notification counts down on the lock screen and in the shade.
 * - When the lock is on (needs "Usage access" + "Display over other apps"),
 *   any app that isn't allowed gets covered by a full-screen lock and the
 *   user is sent back to AscentFlow. Calls and the user's allowed apps get
 *   through.
 * - Closing AscentFlow from Recents mid-session counts as giving up: Pip
 *   slips, and the app applies it the next time it opens.
 * - When the time is up, the countdown turns into a "Focus complete" alert.
 */
class FocusGuardService : Service() {
    private val handler = Handler(Looper.getMainLooper())
    private var endAt = 0L
    private var totalMs = 0L
    private var guard = false
    private var allowed: Set<String> = emptySet()
    private var active = false
    private var lastForeground: String? = null
    private var lastLaunchAt = 0L
    private var lastNotifiedMinute = -1L

    private var overlay: View? = null
    private var overlayTimer: TextView? = null
    private var giveUpArmed = false

    private val tick = object : Runnable {
        override fun run() {
            onTick()
            if (active) handler.postDelayed(this, 500)
        }
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (intent == null) {
            stopSelf()
            return START_NOT_STICKY
        }
        endAt = intent.getLongExtra(EXTRA_END_AT, 0L)
        totalMs = intent.getLongExtra(EXTRA_TOTAL_MS, 0L)
        guard = intent.getBooleanExtra(EXTRA_GUARD, false)
        allowed = intent.getStringArrayListExtra(EXTRA_ALLOWED)?.toSet() ?: emptySet()
        active = true
        lastNotifiedMinute = -1L
        startInForeground()
        handler.removeCallbacks(tick)
        handler.post(tick)
        return START_NOT_STICKY
    }

    override fun onDestroy() {
        active = false
        handler.removeCallbacks(tick)
        hideOverlay()
        super.onDestroy()
    }

    /** Swiping AscentFlow away from Recents mid-session is giving up. */
    override fun onTaskRemoved(rootIntent: Intent?) {
        if (active && System.currentTimeMillis() < endAt) {
            getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
                .edit()
                .putBoolean("flutter.$PREF_PENDING_SLIP", true)
                .commit()
            postAlert(
                this,
                "Pip slipped down the mountain",
                "You closed AscentFlow during focus. Open it to keep climbing.",
            )
            finishSession(complete = false)
        }
        super.onTaskRemoved(rootIntent)
    }

    // ── Every half second ───────────────────────────────────────────────
    private fun onTick() {
        val now = System.currentTimeMillis()
        if (now >= endAt) {
            finishSession(complete = true)
            return
        }
        val remaining = endAt - now
        overlayTimer?.text = formatClock(remaining)

        // Refresh the progress bar once a minute.
        val minute = remaining / 60_000
        if (minute != lastNotifiedMinute) {
            lastNotifiedMinute = minute
            notificationManager().notify(NOTIFICATION_ID, buildNotification())
        }

        if (!guard) return
        val pkg = foregroundPackage() ?: return
        if (isAllowed(pkg)) {
            hideOverlay()
        } else {
            showOverlay()
            // Send them back; at most every 2 s so we never fight in a loop.
            if (now - lastLaunchAt > 2_000) {
                lastLaunchAt = now
                openApp(blocked = pkg)
            }
        }
    }

    private fun finishSession(complete: Boolean) {
        active = false
        handler.removeCallbacks(tick)
        hideOverlay()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            stopForeground(STOP_FOREGROUND_REMOVE)
        } else {
            @Suppress("DEPRECATION")
            stopForeground(true)
        }
        if (complete) {
            postAlert(this, "Focus complete!", "Pip reached the next ledge. Open AscentFlow to bank your metres.")
        }
        stopSelf()
    }

    // ── Which app is in front ───────────────────────────────────────────
    private fun foregroundPackage(): String? {
        val usage = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val now = System.currentTimeMillis()
        val events = usage.queryEvents(now - 10_000, now)
        val event = UsageEvents.Event()
        while (events.hasNextEvent()) {
            events.getNextEvent(event)
            @Suppress("DEPRECATION")
            if (event.eventType == UsageEvents.Event.MOVE_TO_FOREGROUND) {
                lastForeground = event.packageName
            }
        }
        return lastForeground
    }

    private fun isAllowed(pkg: String): Boolean {
        if (pkg == packageName || pkg in allowed || pkg in ALWAYS_ALLOWED) return true
        // Calls, permission prompts and installers always get through.
        if (pkg.contains("incallui") || pkg.contains("telecom") || pkg.contains("dialer") ||
            pkg.contains("permissioncontroller") || pkg.contains("packageinstaller")
        ) return true
        val dialer = runCatching {
            (getSystemService(Context.TELECOM_SERVICE) as TelecomManager).defaultDialerPackage
        }.getOrNull()
        return pkg == dialer
    }

    private fun openApp(blocked: String? = null, giveUp: Boolean = false) {
        val intent = Intent(this, MainActivity::class.java)
            .addFlags(
                Intent.FLAG_ACTIVITY_NEW_TASK or
                    Intent.FLAG_ACTIVITY_REORDER_TO_FRONT or
                    Intent.FLAG_ACTIVITY_SINGLE_TOP
            )
        if (blocked != null) intent.putExtra(EXTRA_BLOCKED, blocked)
        if (giveUp) intent.putExtra(EXTRA_GIVE_UP, true)
        runCatching { startActivity(intent) }
    }

    // ── Full-screen lock drawn over other apps ──────────────────────────
    private fun canDrawOverlay() =
        Build.VERSION.SDK_INT < Build.VERSION_CODES.M || Settings.canDrawOverlays(this)

    private fun showOverlay() {
        if (overlay != null || !canDrawOverlay()) return
        val wm = getSystemService(Context.WINDOW_SERVICE) as WindowManager
        val type = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
        } else {
            @Suppress("DEPRECATION")
            WindowManager.LayoutParams.TYPE_PHONE
        }
        val params = WindowManager.LayoutParams(
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.MATCH_PARENT,
            type,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN,
            PixelFormat.TRANSLUCENT,
        )
        val view = buildOverlay()
        runCatching { wm.addView(view, params) }.onSuccess { overlay = view }
    }

    private fun hideOverlay() {
        val view = overlay ?: return
        overlay = null
        overlayTimer = null
        giveUpArmed = false
        runCatching { (getSystemService(Context.WINDOW_SERVICE) as WindowManager).removeView(view) }
    }

    private fun dp(v: Int) = TypedValue.applyDimension(
        TypedValue.COMPLEX_UNIT_DIP, v.toFloat(), resources.displayMetrics,
    ).toInt()

    private fun buildOverlay(): View {
        val root = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER
            setPadding(dp(32), dp(48), dp(32), dp(48))
            background = GradientDrawable(
                GradientDrawable.Orientation.TOP_BOTTOM,
                intArrayOf(Color.parseColor("#1C4466"), Color.parseColor("#0E2236")),
            )
            isClickable = true // swallow touches meant for the app underneath
        }
        root.addView(ImageView(this).apply {
            setImageResource(R.mipmap.ic_launcher)
        }, LinearLayout.LayoutParams(dp(88), dp(88)).apply { bottomMargin = dp(20) })

        root.addView(text("Pip is still climbing", 26f, Color.WHITE, bold = true))
        val timer = text(formatClock(endAt - System.currentTimeMillis()), 64f, Color.WHITE, bold = true).apply {
            fontFeatureSettings = "tnum"
        }
        overlayTimer = timer
        root.addView(timer, wrap().apply { topMargin = dp(8); bottomMargin = dp(8) })
        root.addView(
            text("Everything except your allowed apps is locked until your focus session ends.", 16f, Color.parseColor("#CFE3F5")),
            wrap().apply { bottomMargin = dp(32) },
        )

        val back = text("Back to my climb", 18f, Color.WHITE, bold = true).apply {
            setPadding(dp(32), dp(16), dp(32), dp(16))
            background = GradientDrawable().apply {
                cornerRadius = dp(999).toFloat()
                setColor(Color.parseColor("#22A058"))
            }
            setOnClickListener { openApp() }
        }
        root.addView(back, wrap())

        val giveUp = text("Give up (Pip slips $FALL_METRES m)", 15f, Color.parseColor("#FF86A6"), bold = true).apply {
            setPadding(dp(16), dp(20), dp(16), dp(12))
            setOnClickListener {
                if (!giveUpArmed) {
                    giveUpArmed = true
                    text = "Tap again to give up"
                } else {
                    hideOverlay()
                    openApp(giveUp = true)
                }
            }
        }
        root.addView(giveUp, wrap())
        return root
    }

    private fun wrap() = LinearLayout.LayoutParams(
        LinearLayout.LayoutParams.WRAP_CONTENT,
        LinearLayout.LayoutParams.WRAP_CONTENT,
    )

    private fun text(value: String, sp: Float, color: Int, bold: Boolean = false) = TextView(this).apply {
        text = value
        textSize = sp
        setTextColor(color)
        gravity = Gravity.CENTER
        if (bold) typeface = Typeface.DEFAULT_BOLD
    }

    // ── The countdown notification (shown on the lock screen) ──────────
    private fun notificationManager() =
        getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

    private fun startInForeground() {
        ensureChannels(this)
        val notification = buildNotification()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            startForeground(NOTIFICATION_ID, notification, ServiceInfo.FOREGROUND_SERVICE_TYPE_SPECIAL_USE)
        } else {
            startForeground(NOTIFICATION_ID, notification)
        }
    }

    private fun buildNotification(): Notification {
        val now = System.currentTimeMillis()
        val ends = DateFormat.getTimeFormat(this).format(Date(endAt))
        val done = if (totalMs > 0) (((totalMs - (endAt - now)) * 100) / totalMs).toInt().coerceIn(0, 100) else 0
        val builder = newBuilder(this, CHANNEL_TIMER)
            .setSmallIcon(R.drawable.ic_stat_focus)
            .setContentTitle("Focusing · Pip is climbing")
            .setContentText(
                if (guard) "Ends at $ends. Other apps are locked until then."
                else "Ends at $ends. Leaving early makes Pip slip $FALL_METRES m."
            )
            .setContentIntent(openIntent(this))
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .setShowWhen(true)
            .setWhen(endAt)
            .setUsesChronometer(true)
            .setProgress(100, done, false)
            .setCategory(Notification.CATEGORY_PROGRESS)
            .setVisibility(Notification.VISIBILITY_PUBLIC)
            .setColor(Color.parseColor("#22A058"))
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) builder.setChronometerCountDown(true)
        // Android 16 "Live Update": keep it pinned at the top of the lock screen.
        builder.extras.putBoolean("android.requestPromotedOngoing", true)
        return builder.build()
    }

    companion object {
        const val EXTRA_END_AT = "end_at"
        const val EXTRA_TOTAL_MS = "total_ms"
        const val EXTRA_GUARD = "guard"
        const val EXTRA_ALLOWED = "allowed"
        const val EXTRA_BLOCKED = "blocked_package"
        const val EXTRA_GIVE_UP = "give_up"
        const val PREF_PENDING_SLIP = "focus.pendingSlip"
        private const val FALL_METRES = 50
        private const val CHANNEL_TIMER = "focus_timer"
        private const val CHANNEL_ALERTS = "focus_alerts"
        private const val NOTIFICATION_ID = 4201
        private const val ALERT_ID = 4202

        private val ALWAYS_ALLOWED = setOf(
            "android",
            "com.android.systemui",
            "com.android.phone",
            "com.android.emergency",
            "com.google.android.apps.safetyhub",
        )

        fun start(context: Context, endAt: Long, totalMs: Long, guard: Boolean, allowed: ArrayList<String>) {
            cancelAlert(context)
            val intent = Intent(context, FocusGuardService::class.java)
                .putExtra(EXTRA_END_AT, endAt)
                .putExtra(EXTRA_TOTAL_MS, totalMs)
                .putExtra(EXTRA_GUARD, guard)
                .putStringArrayListExtra(EXTRA_ALLOWED, allowed)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                context.startForegroundService(intent)
            } else {
                context.startService(intent)
            }
        }

        fun stop(context: Context) {
            context.stopService(Intent(context, FocusGuardService::class.java))
            cancelAlert(context)
        }

        /** Heads-up alert, e.g. "come back or Pip slips". */
        fun postAlert(context: Context, title: String, body: String) {
            ensureChannels(context)
            val notification = newBuilder(context, CHANNEL_ALERTS)
                .setSmallIcon(R.drawable.ic_stat_focus)
                .setContentTitle(title)
                .setContentText(body)
                .setStyle(Notification.BigTextStyle().bigText(body))
                .setContentIntent(openIntent(context))
                .setAutoCancel(true)
                .setVisibility(Notification.VISIBILITY_PUBLIC)
                .setColor(Color.parseColor("#22A058"))
                .build()
            runCatching {
                (context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager)
                    .notify(ALERT_ID, notification)
            }
        }

        fun cancelAlert(context: Context) {
            (context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager).cancel(ALERT_ID)
        }

        private fun ensureChannels(context: Context) {
            if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
            val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            // Default importance (silent) so the countdown shows on the lock
            // screen; silent "low" notifications are hidden there.
            manager.createNotificationChannel(
                NotificationChannel(CHANNEL_TIMER, "Focus timer", NotificationManager.IMPORTANCE_DEFAULT).apply {
                    description = "The running focus countdown"
                    setSound(null, null)
                    enableVibration(false)
                    setShowBadge(false)
                    lockscreenVisibility = Notification.VISIBILITY_PUBLIC
                }
            )
            manager.createNotificationChannel(
                NotificationChannel(CHANNEL_ALERTS, "Focus alerts", NotificationManager.IMPORTANCE_HIGH).apply {
                    description = "Session complete, and come-back warnings"
                    lockscreenVisibility = Notification.VISIBILITY_PUBLIC
                }
            )
            // Channel from earlier builds.
            manager.deleteNotificationChannel("focus_guard")
        }

        private fun newBuilder(context: Context, channel: String): Notification.Builder =
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                Notification.Builder(context, channel)
            } else {
                @Suppress("DEPRECATION")
                Notification.Builder(context)
            }

        private fun openIntent(context: Context): PendingIntent = PendingIntent.getActivity(
            context,
            0,
            Intent(context, MainActivity::class.java).addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP),
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
        )

        fun formatClock(ms: Long): String {
            val total = (ms.coerceAtLeast(0) + 999) / 1000
            val h = total / 3600
            val m = (total % 3600) / 60
            val s = total % 60
            return if (h > 0) "%d:%02d:%02d".format(h, m, s) else "%02d:%02d".format(m, s)
        }
    }
}
