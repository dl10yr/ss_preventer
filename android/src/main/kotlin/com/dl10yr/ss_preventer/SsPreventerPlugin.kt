package com.dl10yr.ss_preventer

import android.app.Activity
import android.os.Build
import android.view.WindowManager
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class SsPreventerPlugin :
    FlutterPlugin,
    MethodChannel.MethodCallHandler,
    ActivityAware,
    EventChannel.StreamHandler {
    private var activity: Activity? = null

    private lateinit var methodChannel: MethodChannel
    private lateinit var eventChannel: EventChannel

    private var isDetectionEnabled = false
    private var eventSink: EventChannel.EventSink? = null
    private var screenCaptureCallback: Activity.ScreenCaptureCallback? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel = MethodChannel(binding.binaryMessenger, "com.dl10yr.ss_preventer/methods")
        methodChannel.setMethodCallHandler(this)

        eventChannel = EventChannel(binding.binaryMessenger, "com.dl10yr.ss_preventer/events")
        eventChannel.setStreamHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "preventOn" -> {
                setSecureFlag(enabled = true)
                result.success(null)
            }

            "preventOff" -> {
                setSecureFlag(enabled = false)
                result.success(null)
            }

            "setDetectionEnabled" -> {
                val enabled = call.arguments as? Boolean ?: false
                isDetectionEnabled = enabled
                if (enabled) {
                    registerScreenCaptureCallbackIfNeeded()
                } else {
                    unregisterScreenCaptureCallbackIfNeeded()
                }
                result.success(null)
            }

            else -> result.notImplemented()
        }
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
        eventSink = events
        registerScreenCaptureCallbackIfNeeded()
    }

    override fun onCancel(arguments: Any?) {
        unregisterScreenCaptureCallbackIfNeeded()
        eventSink = null
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
        unregisterScreenCaptureCallbackIfNeeded()
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        registerScreenCaptureCallbackIfNeeded()
    }

    override fun onDetachedFromActivityForConfigChanges() {
        unregisterScreenCaptureCallbackIfNeeded()
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
        registerScreenCaptureCallbackIfNeeded()
    }

    override fun onDetachedFromActivity() {
        unregisterScreenCaptureCallbackIfNeeded()
        activity = null
    }

    private fun setSecureFlag(enabled: Boolean) {
        val currentActivity = activity ?: return
        if (enabled) {
            currentActivity.window.setFlags(
                WindowManager.LayoutParams.FLAG_SECURE,
                WindowManager.LayoutParams.FLAG_SECURE,
            )
        } else {
            currentActivity.window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
        }
    }

    private fun registerScreenCaptureCallbackIfNeeded() {
        if (!isDetectionEnabled) {
            return
        }
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            return
        }

        val currentActivity = activity ?: return
        if (eventSink == null || screenCaptureCallback != null) {
            return
        }

        val callback = object : Activity.ScreenCaptureCallback {
            override fun onScreenCaptured() {
                eventSink?.success(
                    mapOf(
                        "type" to "screenshot",
                        "detectedAt" to System.currentTimeMillis(),
                    ),
                )
            }
        }

        currentActivity.registerScreenCaptureCallback(currentActivity.mainExecutor, callback)
        screenCaptureCallback = callback
    }

    private fun unregisterScreenCaptureCallbackIfNeeded() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            return
        }

        val currentActivity = activity ?: return
        val callback = screenCaptureCallback ?: return

        currentActivity.unregisterScreenCaptureCallback(callback)
        screenCaptureCallback = null
    }
}
