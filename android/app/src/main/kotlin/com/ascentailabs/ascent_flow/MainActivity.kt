package com.ascentailabs.ascent_flow

import android.app.ActivityManager
import android.app.AppOpsManager
import android.content.Context
import android.content.Intent
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
 * Focus lock bridge for Flutter (channel "ascentflow/focus"):
 * - app pinning (lock task mode) to keep the phone on AscentFlow during focus
 * - usage-access / overlay permission checks, used by app blocking
 * - the list of launchable apps for the blocker settings
 * - start/stop of [FocusGuardService], which sends you back here if you open
 *   a blocked app
 */
class MainActivity : FlutterActivity() {
    private var channel: MethodChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).also { ch ->
            ch.setMethodCallHandler { call, result ->
                when (call.method) {
                    "startLock" -> {
                        runCatching { startLockTask() }
                        result.success(null)
                    }
                    "stopLock" -> {
                        runCatching { if (isLocked()) stopLockTask() }
                        result.success(null)
                    }
                    "isLocked" -> result.success(isLocked())
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
                    "openPinningSettings" -> {
                        openSettings(Intent(Settings.ACTION_SECURITY_SETTINGS))
                        result.success(null)
                    }
                    "launchableApps" -> Thread {
                        val apps = runCatching { launchableApps() }.getOrDefault(emptyList())
                        runOnUiThread { result.success(apps) }
                    }.start()
                    "startBlocking" -> {
                        val packages = call.argument<List<String>>("packages") ?: emptyList()
                        FocusGuardService.start(this, ArrayList(packages))
                        result.success(null)
                    }
                    "stopBlocking" -> {
                        FocusGuardService.stop(this)
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
        }
        reportBlockedApp(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        reportBlockedApp(intent)
    }

    /** Tells Flutter which blocked app the guard just sent the user back from. */
    private fun reportBlockedApp(intent: Intent?) {
        val pkg = intent?.getStringExtra(FocusGuardService.EXTRA_BLOCKED) ?: return
        intent.removeExtra(FocusGuardService.EXTRA_BLOCKED)
        val label = runCatching {
            packageManager.getApplicationLabel(packageManager.getApplicationInfo(pkg, 0)).toString()
        }.getOrDefault(pkg)
        channel?.invokeMethod("blockedApp", mapOf("package" to pkg, "label" to label))
    }

    private fun isLocked(): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) return false
        val am = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        return am.lockTaskModeState != ActivityManager.LOCK_TASK_MODE_NONE
    }

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
