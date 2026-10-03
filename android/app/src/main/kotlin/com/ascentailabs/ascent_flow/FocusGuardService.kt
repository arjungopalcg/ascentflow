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
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper

/**
 * Runs only while a focus session is active. Every ~0.8 s it checks which app
 * is in front (via usage access); if it's one the user chose to block, it
 * brings AscentFlow back to the front and tells Flutter which app it was.
 * Needs "Usage access" and "Display over other apps" (the latter lets us
 * return to the foreground from the background on Android 10+).
 */
class FocusGuardService : Service() {
    private val handler = Handler(Looper.getMainLooper())
    private var blocked: Set<String> = emptySet()
    private var lastForeground: String? = null

    private val tick = object : Runnable {
        override fun run() {
            checkForeground()
            handler.postDelayed(this, 800)
        }
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        intent?.getStringArrayListExtra(EXTRA_PACKAGES)?.let { blocked = it.toSet() }
        startInForeground()
        handler.removeCallbacks(tick)
        handler.post(tick)
        // If the system kills us, don't restart without a session.
        return START_NOT_STICKY
    }

    override fun onDestroy() {
        handler.removeCallbacks(tick)
        super.onDestroy()
    }

    private fun checkForeground() {
        val pkg = foregroundPackage() ?: return
        if (pkg in blocked) {
            val back = Intent(this, MainActivity::class.java)
                .addFlags(
                    Intent.FLAG_ACTIVITY_NEW_TASK or
                        Intent.FLAG_ACTIVITY_REORDER_TO_FRONT or
                        Intent.FLAG_ACTIVITY_SINGLE_TOP
                )
                .putExtra(EXTRA_BLOCKED, pkg)
            runCatching { startActivity(back) }
            // Assume we're in front again until a new event says otherwise.
            lastForeground = packageName
        }
    }

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

    private fun startInForeground() {
        val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            manager.createNotificationChannel(
                NotificationChannel(CHANNEL_ID, "Focus sessions", NotificationManager.IMPORTANCE_LOW)
            )
        }
        val open = PendingIntent.getActivity(
            this,
            0,
            Intent(this, MainActivity::class.java),
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
        )
        val builder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(this, CHANNEL_ID)
        } else {
            @Suppress("DEPRECATION")
            Notification.Builder(this)
        }
        val notification = builder
            .setContentTitle("Focus session in progress")
            .setContentText("Blocked apps will bring you back to AscentFlow.")
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentIntent(open)
            .setOngoing(true)
            .build()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            startForeground(NOTIFICATION_ID, notification, ServiceInfo.FOREGROUND_SERVICE_TYPE_SPECIAL_USE)
        } else {
            startForeground(NOTIFICATION_ID, notification)
        }
    }

    companion object {
        const val EXTRA_PACKAGES = "packages"
        const val EXTRA_BLOCKED = "blocked_package"
        private const val CHANNEL_ID = "focus_guard"
        private const val NOTIFICATION_ID = 4201

        fun start(context: Context, packages: ArrayList<String>) {
            val intent = Intent(context, FocusGuardService::class.java)
                .putStringArrayListExtra(EXTRA_PACKAGES, packages)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                context.startForegroundService(intent)
            } else {
                context.startService(intent)
            }
        }

        fun stop(context: Context) {
            context.stopService(Intent(context, FocusGuardService::class.java))
        }
    }
}
