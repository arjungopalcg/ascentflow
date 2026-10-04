package com.ascentailabs.ascent_flow

import android.Manifest
import android.app.AppOpsManager
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.Drawable
import android.net.Uri
import android.os.Build
import android.os.PowerManager
import android.os.Process
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream

/**
 * Focus session bridge for Flutter (channel "ascentflow/focus"):
 * - start/stop of [FocusGuardService]: the lock-screen countdown and, when
 *   allowed, the full-screen lock over other apps
 * - usage-access / overlay / notification permission checks
 * - the list of launchable apps, so people can pick which ones stay usable
 * - "come back" alerts when someone leaves without the lock
 */
class MainActivity : FlutterActivity() {
    private var channel: MethodChannel? = null
    private var dartReady = false
    private val pendingCalls = mutableListOf<Pair<String, Any?>>()

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).also { ch ->
            ch.setMethodCallHandler { call, result ->
                when (call.method) {
                    "ready" -> {
                        dartReady = true
                        pendingCalls.forEach { (method, args) -> ch.invokeMethod(method, args) }
                        pendingCalls.clear()
                        result.success(null)
                    }
                    "startSession" -> {
                        FocusGuardService.start(
                            this,
                            endAt = call.argument<Number>("endAt")?.toLong() ?: 0L,
                            totalMs = call.argument<Number>("totalMs")?.toLong() ?: 0L,
                            guard = call.argument<Boolean>("guard") ?: false,
                            allowed = ArrayList(call.argument<List<String>>("allowed") ?: emptyList()),
                        )
                        result.success(null)
                    }
                    "stopSession" -> {
                        FocusGuardService.stop(this)
                        result.success(null)
                    }
                    "warnLeaving" -> {
                        FocusGuardService.postAlert(
                            this,
                            "Come back to your climb!",
                            "Return to AscentFlow within ${call.argument<Int>("seconds") ?: 10} seconds or Pip slips.",
                        )
                        result.success(null)
                    }
                    "clearWarning" -> {
                        FocusGuardService.cancelAlert(this)
                        result.success(null)
                    }
                    "isScreenOn" -> {
                        val power = getSystemService(Context.POWER_SERVICE) as PowerManager
                        result.success(power.isInteractive)
                    }
                    "hasUsageAccess" -> result.success(hasUsageAccess())
                    "openUsageAccessSettings" -> {
                        openSettings(Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS))
                        result.success(null)
                    }
                    "hasOverlayPermission" -> result.success(
                        Build.VERSION.SDK_INT < Build.VERSION_CODES.M || Settings.canDrawOverlays(this)
                    )
                    "openOverlaySettings" -> {
                        openSettings(
                            Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION, Uri.parse("package:$packageName"))
                        )
                        result.success(null)
                    }
                    "hasNotificationPermission" -> result.success(hasNotificationPermission())
                    "requestNotificationPermission" -> {
                        if (!hasNotificationPermission() && Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                            requestPermissions(arrayOf(Manifest.permission.POST_NOTIFICATIONS), 4203)
                        }
                        result.success(null)
                    }
                    "launchableApps" -> Thread {
                        val apps = runCatching { launchableApps() }.getOrDefault(emptyList())
                        runOnUiThread { result.success(apps) }
                    }.start()
                    else -> result.notImplemented()
                }
            }
        }
        handleGuardIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        handleGuardIntent(intent)
    }

    /** The guard sent the user back (from a locked app, or to give up). */
    private fun handleGuardIntent(intent: Intent?) {
        intent ?: return
        if (intent.getBooleanExtra(FocusGuardService.EXTRA_GIVE_UP, false)) {
            intent.removeExtra(FocusGuardService.EXTRA_GIVE_UP)
            toDart("giveUp", null)
        }
        val pkg = intent.getStringExtra(FocusGuardService.EXTRA_BLOCKED) ?: return
        intent.removeExtra(FocusGuardService.EXTRA_BLOCKED)
        val label = runCatching {
            packageManager.getApplicationLabel(packageManager.getApplicationInfo(pkg, 0)).toString()
        }.getOrDefault(pkg)
        toDart("blockedApp", mapOf("package" to pkg, "label" to label))
    }

    /** Calls Dart now, or once it has said it's listening (cold start). */
    private fun toDart(method: String, args: Any?) {
        val ch = channel
        if (dartReady && ch != null) ch.invokeMethod(method, args) else pendingCalls.add(method to args)
    }

    private fun hasNotificationPermission(): Boolean =
        Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU ||
            checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) == PackageManager.PERMISSION_GRANTED

    private fun hasUsageAccess(): Boolean {
        val ops = getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        val mode = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            ops.unsafeCheckOpNoThrow(AppOpsManager.OPSTR_GET_USAGE_STATS, Process.myUid(), packageName)
        } else {
            @Suppress("DEPRECATION")
            ops.checkOpNoThrow(AppOpsManager.OPSTR_GET_USAGE_STATS, Process.myUid(), packageName)
        }
        return mode == AppOpsManager.MODE_ALLOWED
    }

    private fun openSettings(intent: Intent) {
        runCatching { startActivity(intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)) }
            .onFailure { startActivity(Intent(Settings.ACTION_SETTINGS).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)) }
    }

    private fun launchableApps(): List<Map<String, Any>> {
        val pm = packageManager
        val launcher = Intent(Intent.ACTION_MAIN).addCategory(Intent.CATEGORY_LAUNCHER)
        @Suppress("DEPRECATION")
        val activities = pm.queryIntentActivities(launcher, 0)
        return activities
            .map { it.activityInfo.applicationInfo }
            .distinctBy { it.packageName }
            .filter { it.packageName != packageName }
            .map { info ->
                mapOf(
                    "package" to info.packageName,
                    "label" to pm.getApplicationLabel(info).toString(),
                    "icon" to iconBytes(pm.getApplicationIcon(info)),
                )
            }
            .sortedBy { (it["label"] as String).lowercase() }
    }

    private fun iconBytes(drawable: Drawable): ByteArray {
        val size = 96
        val bitmap = Bitmap.createBitmap(size, size, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)
        drawable.setBounds(0, 0, size, size)
        drawable.draw(canvas)
        val out = ByteArrayOutputStream()
        bitmap.compress(Bitmap.CompressFormat.PNG, 100, out)
        return out.toByteArray()
    }

    companion object {
        const val CHANNEL = "ascentflow/focus"
    }
}
