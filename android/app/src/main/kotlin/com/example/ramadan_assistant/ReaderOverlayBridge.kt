package com.example.ramadan_assistant

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/** Channel `app.tawabti/overlay`: permission state, settings hand-off and the bubble service. */
class ReaderOverlayBridge(private val activity: Activity) {
    fun handle(call: MethodCall, result: MethodChannel.Result) {
        try {
            val args = call.arguments as? Map<*, *> ?: emptyMap<String, Any>()
            when (call.method) {
                "overlay.status" -> result.success(mapOf(
                    "canDraw" to Settings.canDrawOverlays(activity),
                    "usageAccess" to ReaderOverlayService.hasUsageAccess(activity)))
                "overlay.openSettings" -> {
                    activity.startActivity(Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                        Uri.parse("package:" + activity.packageName)))
                    result.success(true)
                }
                "overlay.openUsageSettings" -> {
                    activity.startActivity(Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS))
                    result.success(true)
                }
                "overlay.show" -> {
                    if (!Settings.canDrawOverlays(activity)) { result.success(false); return }
                    val intent = Intent(activity, ReaderOverlayService::class.java)
                    for ((key, value) in args) {
                        when (value) {
                            is String -> intent.putExtra(key as String, value)
                            is Boolean -> intent.putExtra(key as String, value)
                            is Int -> intent.putExtra(key as String, value.toLong())
                            is Long -> intent.putExtra(key as String, value)
                        }
                    }
                    if (Build.VERSION.SDK_INT >= 26) activity.startForegroundService(intent)
                    else activity.startService(intent)
                    result.success(true)
                }
                "overlay.hide" -> {
                    activity.stopService(Intent(activity, ReaderOverlayService::class.java))
                    result.success(null)
                }
                "overlay.takePendingDone" -> {
                    val pending = OverlayState.pendingDone
                    OverlayState.pendingDone = false
                    result.success(pending)
                }
                else -> result.notImplemented()
            }
        } catch (error: Exception) { result.error("overlay_unavailable", error.message, null) }
    }
}
