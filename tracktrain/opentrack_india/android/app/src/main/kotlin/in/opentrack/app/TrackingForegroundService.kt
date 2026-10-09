package `in`.opentrack.app

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.IBinder
import android.os.PowerManager
import androidx.core.content.ContextCompat

/**
 * Location-typed foreground service that keeps the process alive while a
 * journey is being tracked, so the Dart-side geofence evaluation continues
 * with the screen off. Holds a partial wake lock for the session duration.
 */
class TrackingForegroundService : Service() {

    private var wakeLock: PowerManager.WakeLock? = null

    override fun onCreate() {
        super.onCreate()
        ensureChannel()
        try {
            val power = getSystemService(Context.POWER_SERVICE) as PowerManager
            wakeLock = power.newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, WAKE_TAG)
            wakeLock?.setReferenceCounted(false)
            wakeLock?.acquire()
        } catch (t: Throwable) {
            // Wake lock is an optimization; never crash over it.
        }
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        startForeground(NOTIFICATION_ID, buildNotification())
        return START_STICKY
    }

    override fun onDestroy() {
        try {
            wakeLock?.let { if (it.isHeld) it.release() }
        } catch (t: Throwable) {
            // Ignore release races.
        }
        wakeLock = null
        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? = null

    private fun ensureChannel() {
        if (Build.VERSION.SDK_INT < 26) return
        val manager = getSystemService(NotificationManager::class.java) ?: return
        if (manager.getNotificationChannel(CHANNEL_ID) != null) return
        val channel = NotificationChannel(
            CHANNEL_ID,
            "Journey tracking",
            NotificationManager.IMPORTANCE_LOW,
        ).apply {
            description = "Shown while OpenTrack India tracks your journey."
            setShowBadge(false)
        }
        manager.createNotificationChannel(channel)
    }

    private fun buildNotification(): Notification {
        val builder = if (Build.VERSION.SDK_INT >= 26) {
            Notification.Builder(this, CHANNEL_ID)
        } else {
            @Suppress("DEPRECATION")
            Notification.Builder(this)
        }
        return builder
            .setContentTitle("OpenTrack India")
            .setContentText("Tracking your journey — destination alarm armed.")
            .setSmallIcon(R.drawable.ic_notify)
            .setOngoing(true)
            .build()
    }

    companion object {
        private const val CHANNEL_ID = "tracking_foreground"
        private const val NOTIFICATION_ID = 5001
        private const val WAKE_TAG = "opentrack:tracking"

        fun start(context: Context) {
            val intent = Intent(context, TrackingForegroundService::class.java)
            ContextCompat.startForegroundService(context, intent)
        }

        fun stop(context: Context) {
            context.stopService(Intent(context, TrackingForegroundService::class.java))
        }
    }
}
