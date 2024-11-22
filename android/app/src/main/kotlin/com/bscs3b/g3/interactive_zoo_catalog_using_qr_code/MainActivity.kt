package com.bscs3b.g3.interactive_zoo_catalog_using_qr_code

import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "flutter/android"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
                call, result ->
            if (call.method == "getSdkInt") {
                val sdkInt = Build.VERSION.SDK_INT
                result.success(sdkInt)
            } else {
                result.notImplemented()
            }
        }
    }
}
