package com.example.rythmify

import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.pm.PackageManager
import android.os.Build
import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : AudioServiceActivity() {

    private val CHANNEL = "flutter_dynamic_icon"
    private val MAIN_ACTIVITY = ".MainActivity"
    private val DEFAULT_ALIAS = ".MainActivity.default"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            val pkg = packageName
            val pm = packageManager
            when (call.method) {
                "mSupportsAlternateIcons" -> result.success(true)
                "mSetAlternateIconName" -> {
                    try {
                        setIcon(pm, pkg, call.argument<String>("iconName"))
                        result.success(null)
                    } catch (e: Exception) {
                        result.error("ERROR", e.message, null)
                    }
                }
                "mGetAlternateIconName" -> {
                    try {
                        result.success(getCurrentIcon(pm, pkg))
                    } catch (e: Exception) {
                        result.error("ERROR", e.message, null)
                    }
                }
                "mGetAvailableIcons" -> {
                    try {
                        result.success(getAvailableIcons(pm, pkg))
                    } catch (e: Exception) {
                        result.error("ERROR", e.message, null)
                    }
                }
                "pinWidget" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        val manager = AppWidgetManager.getInstance(this)
                        if (manager.isRequestPinAppWidgetSupported) {
                            val component = ComponentName(this, PlayerWidget::class.java)
                            manager.requestPinAppWidget(component, null, null)
                            result.success(true)
                        } else {
                            result.success(false)
                        }
                    } else {
                        result.success(false)
                    }
                }
                "pinLikesWidget" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        val manager = AppWidgetManager.getInstance(this)
                        if (manager.isRequestPinAppWidgetSupported) {
                            val component = ComponentName(this, LikesWidget::class.java)
                            manager.requestPinAppWidget(component, null, null)
                            result.success(true)
                        } else {
                            result.success(false)
                        }
                    } else {
                        result.success(false)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun getAvailableIcons(pm: PackageManager, pkg: String): List<String> {
        val intent = android.content.Intent(android.content.Intent.ACTION_MAIN).apply {
            addCategory(android.content.Intent.CATEGORY_LAUNCHER)
            setPackage(pkg)
        }
        val prefix = "$pkg$MAIN_ACTIVITY."
        return pm.queryIntentActivities(intent, PackageManager.GET_DISABLED_COMPONENTS)
            .map { it.activityInfo.name }
            .filter { it.startsWith(prefix) }
            .map { it.removePrefix(prefix) }
            .filter { it != "default" }
    }

    private fun getCurrentIcon(pm: PackageManager, pkg: String): String? {
        val defaultAlias = ComponentName(pkg, "$pkg$DEFAULT_ALIAS")
        try {
            if (pm.getComponentEnabledSetting(defaultAlias) == PackageManager.COMPONENT_ENABLED_STATE_ENABLED)
                return null
        } catch (_: Exception) {}
        getAvailableIcons(pm, pkg).forEach { name ->
            val c = ComponentName(pkg, "$pkg$MAIN_ACTIVITY.$name")
            if (pm.getComponentEnabledSetting(c) == PackageManager.COMPONENT_ENABLED_STATE_ENABLED)
                return name
        }
        return null
    }

    private fun setIcon(pm: PackageManager, pkg: String, iconName: String?) {
        val mainActivity = ComponentName(pkg, "$pkg$MAIN_ACTIVITY")
        val defaultAlias = ComponentName(pkg, "$pkg$DEFAULT_ALIAS")
        val available = getAvailableIcons(pm, pkg)

        pm.setComponentEnabledSetting(mainActivity, PackageManager.COMPONENT_ENABLED_STATE_DISABLED, PackageManager.DONT_KILL_APP)
        pm.setComponentEnabledSetting(defaultAlias, PackageManager.COMPONENT_ENABLED_STATE_DISABLED, PackageManager.DONT_KILL_APP)
        available.forEach { name ->
            pm.setComponentEnabledSetting(
                ComponentName(pkg, "$pkg$MAIN_ACTIVITY.$name"),
                PackageManager.COMPONENT_ENABLED_STATE_DISABLED,
                PackageManager.DONT_KILL_APP
            )
        }

        if (iconName.isNullOrEmpty()) {
            pm.setComponentEnabledSetting(defaultAlias, PackageManager.COMPONENT_ENABLED_STATE_ENABLED, PackageManager.DONT_KILL_APP)
        } else {
            if (!available.contains(iconName))
                throw IllegalArgumentException("Icon '$iconName' not found")
            pm.setComponentEnabledSetting(
                ComponentName(pkg, "$pkg$MAIN_ACTIVITY.$iconName"),
                PackageManager.COMPONENT_ENABLED_STATE_ENABLED,
                PackageManager.DONT_KILL_APP
            )
        }
    }
}
