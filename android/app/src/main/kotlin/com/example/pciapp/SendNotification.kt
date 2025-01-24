package com.uma.pciapp

import android.annotation.SuppressLint
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Intent
import android.os.Build
import android.os.IBinder
import android.util.Log
import androidx.annotation.RequiresApi
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat

class SendNotification: Service() {
    companion object {
        const val CHANNEL_ID = "pciapp_notification"
        const val CHANNEL_NAME = "PCI App Foreground Service"
        const val SENDING_NOTIFICATION_ID = 108
    }

    @RequiresApi(Build.VERSION_CODES.M)
    private lateinit var notificationManager: NotificationManager
    private lateinit var builder: NotificationCompat.Builder

    @RequiresApi(Build.VERSION_CODES.M)
    override fun onCreate() {
        notificationManager = getSystemService(NOTIFICATION_SERVICE) as NotificationManager
        super.onCreate()
    }

    @RequiresApi(Build.VERSION_CODES.O)
    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val notification = createSendingNotification()
        startForeground(SENDING_NOTIFICATION_ID, notification)
        return START_STICKY
    }

    @RequiresApi(Build.VERSION_CODES.M)
    override fun onDestroy() {
        stopSending()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            stopForeground(/* notificationBehavior = */ STOP_FOREGROUND_REMOVE)
        } else {
            @Suppress("DEPRECATION")
            stopForeground(true)
        }
        super.onDestroy()
    }

    // Required method for binding a service (not used in this foreground service)
    // Must be implemented even if not used
    override fun onBind(p0: Intent?): IBinder? {
        // TODO("Not yet implemented") indicates this method needs to be completed
        return null
    }

    // Create notification for sending message
    @SuppressLint("MissingPermission")
    @RequiresApi(Build.VERSION_CODES.O)
    fun createSendingNotification(): Notification {
        Log.d(/* tag = */ "sendNotification", /* msg = */ "sendNotification() function called")
        val sendNotificationChannel = NotificationChannel(
            CHANNEL_ID,
            CHANNEL_NAME,
            NotificationManager.IMPORTANCE_HIGH
        )

        notificationManager.createNotificationChannel(sendNotificationChannel)
        builder = NotificationCompat.Builder(
            this, NotificationService.CHANNEL_ID
        ).apply {
            setContentTitle("Sending Data")
            setContentText("Sending data to server")
            setSmallIcon(android.R.drawable.ic_menu_send)
            setPriority(NotificationCompat.PRIORITY_HIGH)
            setProgress(0, 0, true)
        }
        NotificationManagerCompat.from(this).notify(SENDING_NOTIFICATION_ID, builder.build())
        return builder.build()
    }

    @RequiresApi(Build.VERSION_CODES.M)
    fun stopSending() {
        val message = "Process completed"
        builder.setContentText(message).setProgress(0, 0, false)
    }
}