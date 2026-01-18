package com.aarshjulet.app

import android.app.Application
import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache

/**
 * Custom Application klasse til at initialisere notification channels tidligt.
 * Dette sikrer at FCM-beskeder kan vises korrekt selv når appen ikke kører.
 */
class MainApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
    }

    /**
     * Opretter notification channel for FCM-beskeder.
     * Skal matche channel ID'et sendt fra serveren ("aarshjulet_notifications").
     */
    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channelId = "aarshjulet_notifications"
            val channelName = "Årshjulet Notifikationer"
            val channelDescription = "Påmindelser om opgaver og invitationer"
            val importance = NotificationManager.IMPORTANCE_HIGH

            val channel = NotificationChannel(channelId, channelName, importance).apply {
                description = channelDescription
                enableVibration(true)
                enableLights(true)
            }

            val notificationManager = getSystemService(NotificationManager::class.java)
            notificationManager.createNotificationChannel(channel)
        }
    }
}
