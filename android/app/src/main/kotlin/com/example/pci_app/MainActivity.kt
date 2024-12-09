package com.example.pci_app

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity(){
    private var channel = "pci_app/notification"
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channel).setMethodCallHandler{
            call, result ->
            if(call.method == "startNotification"){
                startService()
                result.success(null)
            }
            if(call.method == "stopNotification"){
                stopService()
                result.success(null)
            }
    }
}

    private fun startService() {
        val serviceIntent = Intent(this, NotificationService::class.java)
        startService(serviceIntent)
    }

    private fun stopService(){
        val serviceIntent = Intent(this, NotificationService::class.java)
        stopService(serviceIntent)
    }
}
