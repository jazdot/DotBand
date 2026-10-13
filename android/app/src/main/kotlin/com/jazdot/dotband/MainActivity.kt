package com.jazdot.dotband

import android.os.Bundle
import com.jazdot.dotband.bridge.WifiScannerBridge
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private companion object {
        const val METHOD_CHANNEL_NAME = "com.jazdot.dotband/control"
        const val EVENT_CHANNEL_NAME = "com.jazdot.dotband/telemetry"
    }

    private var scannerBridge: WifiScannerBridge? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        scannerBridge = WifiScannerBridge(this)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, METHOD_CHANNEL_NAME)
            .setMethodCallHandler(scannerBridge)

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENT_CHANNEL_NAME)
            .setStreamHandler(scannerBridge)
    }
}
