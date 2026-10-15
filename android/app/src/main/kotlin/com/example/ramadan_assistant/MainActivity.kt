package com.example.ramadan_assistant

import android.content.Intent
import android.content.pm.ShortcutInfo
import android.content.pm.ShortcutManager
import android.graphics.drawable.Icon
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private var features: MethodChannel? = null
    private var overlay: MethodChannel? = null
    private lateinit var calendar: NativeCalendarBridge
    private val shortcutIds = setOf("tasbih", "prayers", "worship", "planner", "library")
    private var pendingShortcut: String? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        pendingShortcut = readShortcut(intent)
        calendar = NativeCalendarBridge(this)
        val overlayBridge = ReaderOverlayBridge(this)
        overlay = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "app.tawabti/overlay")
        overlay!!.setMethodCallHandler { call, result -> overlayBridge.handle(call, result) }
        features = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "app.tawabti/features")
        features!!.setMethodCallHandler { call, result ->
            try {
                if (calendar.handle(call, result)) return@setMethodCallHandler
                val args = call.arguments as? Map<*, *> ?: emptyMap<String, Any>()
                when (call.method) {
                    "reader.apps" -> {
                        val query = Intent(Intent.ACTION_MAIN).addCategory(Intent.CATEGORY_LAUNCHER)
                        val apps = packageManager.queryIntentActivities(query, 0)
                            .filter { it.activityInfo.packageName != packageName }
                            .distinctBy { it.activityInfo.packageName }
                            .map { mapOf("packageName" to it.activityInfo.packageName,
                                "label" to it.loadLabel(packageManager).toString()) }
                            .sortedBy { it["label"]?.lowercase() }
                        result.success(apps)
                    }
                    "reader.open" -> {
                        val pkg = args["packageName"] as? String ?: error("Missing reader app")
                        val launch = packageManager.getLaunchIntentForPackage(pkg)
                        if (launch == null) result.success(false)
                        else { startActivity(launch); result.success(true) }
                    }
                    "shortcuts.initial" -> {
                        result.success(pendingShortcut)
                        pendingShortcut = null
                        intent?.removeExtra("tawabti_shortcut")
                    }
                    "shortcuts.supported" -> result.success(Build.VERSION.SDK_INT >= 26 &&
                        getSystemService(ShortcutManager::class.java)?.isRequestPinShortcutSupported == true)
                    "shortcuts.pin" -> {
                        if (Build.VERSION.SDK_INT < 26) result.success(false)
                        else {
                            val manager = getSystemService(ShortcutManager::class.java)
                            result.success(manager?.isRequestPinShortcutSupported == true &&
                                manager.requestPinShortcut(shortcut(args), null))
                        }
                    }
                    "shortcuts.dynamic" -> {
                        if (Build.VERSION.SDK_INT >= 25) {
                            val manager = getSystemService(ShortcutManager::class.java)
                            val items = args["items"] as? List<*> ?: emptyList<Any>()
                            val shortcuts = items.take(manager?.maxShortcutCountPerActivity ?: 4)
                                .map { shortcut(it as Map<*, *>) }
                            if (manager?.setDynamicShortcuts(shortcuts) == false) {
                                result.error("shortcut_rate_limit", "Try again later", null)
                                return@setMethodCallHandler
                            }
                        }
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            } catch (error: Exception) { result.error("feature_unavailable", error.message, null) }
        }
    }

    private fun readShortcut(value: Intent?): String? =
        value?.getStringExtra("tawabti_shortcut")?.takeIf { shortcutIds.contains(it) }

    private fun shortcut(args: Map<*, *>): ShortcutInfo {
        val id = args["id"] as? String ?: error("Missing shortcut")
        require(shortcutIds.contains(id)) { "Unsupported shortcut" }
        val label = (args["label"] as? String)?.trim()?.take(40)
        require(!label.isNullOrEmpty()) { "Missing shortcut label" }
        val destination = Intent(this, MainActivity::class.java)
            .setAction("app.tawabti.OPEN_SHORTCUT").putExtra("tawabti_shortcut", id)
            .addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP)
        return ShortcutInfo.Builder(this, id).setShortLabel(label)
            .setIcon(Icon.createWithResource(this, R.mipmap.launcher_icon)).setIntent(destination).build()
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        val destination = readShortcut(intent)
        pendingShortcut = destination
        if (destination != null) features?.invokeMethod("shortcut.open", destination)
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        if (::calendar.isInitialized && calendar.onRequestPermissionsResult(requestCode, grantResults)) return
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
    }

    override fun onDestroy() {
        if (::calendar.isInitialized) calendar.dispose()
        features?.setMethodCallHandler(null)
        features = null
        overlay?.setMethodCallHandler(null)
        overlay = null
        super.onDestroy()
    }
}
