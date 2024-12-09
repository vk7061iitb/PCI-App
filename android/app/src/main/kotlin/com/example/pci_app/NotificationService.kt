package com.example.pci_app

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

// This is a Service class in Android, which allows you to perform long-running operations
// in the background, even when the user is not directly interacting with the app
class NotificationService: Service(){

    // Companion object is similar to static members in Java
    // It holds constants and methods that are shared across all instances of the class
    companion object{
        // Unique identifier for the notification channel
        // Used to create and identify a specific type of notification
        const val CHANNEL_ID = "pci_app_notification"

        // Human-readable name for the notification channel
        // Visible to users in system settings
        const val CHANNEL_NAME = "PCI App Foreground Service"

        // Unique ID for the notification
        // Helps in managing and updating the notification later
        const val NOTIFICATION_ID = 107
    }

    // Called when the service is first created
    // Used for one-time setup that doesn't need to be repeated each time the service starts
    override fun onCreate() {
        super.onCreate()
        // You can add initialization code here if needed
    }

    // Called every time startService() is called
    // This is where you define what happens when the service starts
    @RequiresApi(Build.VERSION_CODES.O)
    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        // Create a foreground notification (required for long-running background tasks)
        val notification = createNotification()

        // Start the service in the foreground
        // This prevents the system from killing the service to reclaim resources
        startForeground(NOTIFICATION_ID, notification)

        // START_STICKY tells the system to recreate the service if it's killed
        // and no pending start commands remain
        return START_STICKY
    }

    // Creates and configures the notification for the foreground service
    @RequiresApi(Build.VERSION_CODES.O)
    fun createNotification():Notification{
        Log.d("createNotification", "function called")
        // Create a NotificationChannel (required for Android Oreo and above)
        // Allows you to group and configure different types of notifications
        val notChannel = NotificationChannel(
            /* id = */ CHANNEL_ID,
            /* name = */ CHANNEL_NAME,
            /* importance = */ NotificationManager.IMPORTANCE_HIGH // Determines how intrusive the notification is
        )

        // Get the system's NotificationManager to create the channel
        val notificationManager = getSystemService(NotificationManager::class.java)
        notificationManager.createNotificationChannel(notChannel)

        // Build the actual notification
        return NotificationCompat.Builder(
            /* context = */ this, /* channelId = */ CHANNEL_ID
        )
            .setContentTitle(/* title = */ "PCI App is running")
            .setContentText(/* text = */ "PCI App is collecting location data...")
            .setSmallIcon(/* icon = */ android.R.drawable.ic_menu_mylocation) // Small icon shown in the status bar
            .setPriority(/* pri = */ NotificationCompat.PRIORITY_HIGH) // High priority ensures visibility
            .build()
    }

    // Required method for binding a service (not used in this foreground service)
    // Must be implemented even if not used
    override fun onBind(p0: Intent?): IBinder? {
        // TODO("Not yet implemented") indicates this method needs to be completed
        return null
    }

    // Called when the service is about to be destroyed
    @RequiresApi(Build.VERSION_CODES.N)
    override fun onDestroy() {
        // Handles removing the foreground notification when service stops
        // Different approaches for newer and older Android versions
        if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.N){
            // Modern method to stop foreground service and remove notification
            stopForeground(/* notificationBehavior = */ STOP_FOREGROUND_REMOVE)
        }else{
            // Deprecated method for older Android versions
            // @Suppress("DEPRECATION") tells the compiler to ignore deprecation warnings
            @Suppress("DEPRECATION")
            stopForeground(/* removeNotification = */ true)
        }
        super.onDestroy()
    }
}