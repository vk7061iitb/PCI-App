package com.uma.pciapp

import android.content.Intent
import android.os.Build
import androidx.annotation.RequiresApi
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity(){
    private var channel = "pci_app/notification"
    @RequiresApi(Build.VERSION_CODES.M)
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
            if(call.method == "startSending"){
                startSending()
                result.success(null)
            }
            if(call.method == "stopSending"){
                stopSending()
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

    private fun startSending(){
        val serviceIntent = Intent(this, SendNotification::class.java)
        startService(serviceIntent)
    }

    private fun stopSending(){
        val serviceIntent = Intent(this, SendNotification::class.java)
        stopService(serviceIntent)
    }
}
