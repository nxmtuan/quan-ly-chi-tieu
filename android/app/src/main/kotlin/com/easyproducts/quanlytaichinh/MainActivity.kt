package com.easyproducts.quanlytaichinh

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel

class MainActivity : FlutterFragmentActivity() {
    private val screenEventsChannel = "com.easyproducts.quanlytaichinh/screen_events"
    private var screenEventsSink: EventChannel.EventSink? = null
    private var screenReceiverRegistered = false

    private val screenReceiver =
        object : BroadcastReceiver() {
            override fun onReceive(context: Context?, intent: Intent?) {
                if (intent?.action == Intent.ACTION_SCREEN_OFF) {
                    screenEventsSink?.success("screenOff")
                }
            }
        }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        EventChannel(
                flutterEngine.dartExecutor.binaryMessenger,
                screenEventsChannel,
            )
            .setStreamHandler(
                object : EventChannel.StreamHandler {
                    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                        screenEventsSink = events
                        registerScreenReceiver()
                    }

                    override fun onCancel(arguments: Any?) {
                        unregisterScreenReceiver()
                        screenEventsSink = null
                    }
                },
            )
    }

    override fun onDestroy() {
        unregisterScreenReceiver()
        super.onDestroy()
    }

    private fun registerScreenReceiver() {
        if (screenReceiverRegistered) {
            return
        }

        registerReceiver(screenReceiver, IntentFilter(Intent.ACTION_SCREEN_OFF))
        screenReceiverRegistered = true
    }

    private fun unregisterScreenReceiver() {
        if (!screenReceiverRegistered) {
            return
        }

        unregisterReceiver(screenReceiver)
        screenReceiverRegistered = false
    }
}
