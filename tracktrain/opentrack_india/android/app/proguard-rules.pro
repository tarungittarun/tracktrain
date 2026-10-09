# Flutter engine internals.
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**

# flutter_local_notifications (Dexterous) uses reflection for scheduled
# notification payloads.
-keep class com.dexterous.** { *; }

# sqflite keeps native bindings.
-keep class com.tekartik.** { *; }

# geolocator plugin classes accessed via reflection.
-keep class com.baseflow.geolocator.** { *; }

# AndroidX lifecycle observers used by several plugins.
-keep class androidx.lifecycle.DefaultLifecycleObserver { *; }

# Keep the app's own platform-channel service referenced from the manifest.
-keep class in.opentrack.app.TrackingForegroundService { *; }
