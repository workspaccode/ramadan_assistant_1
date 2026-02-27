-dontwarn androidx.window.**
-keep class androidx.window.** { *; }

-dontwarn androidx.window.extensions.**
-keep class androidx.window.extensions.** { *; }

-dontwarn androidx.window.sidecar.**
-keep class androidx.window.sidecar.** { *; }

# Flutter Wrapper and Plugins
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Permission Handler
-keep class com.baseflow.permissionhandler.** { *; }

# Geolocator
-keep class com.baseflow.geolocator.** { *; }

# General keep rules for Android classes used by plugins
-keep class androidx.core.app.ActivityCompat.** { *; }
-keep class androidx.core.content.ContextCompat.** { *; }

# WorkManager
-keep class be.tramckrijte.workmanager.** { *; }

# Awesome Notifications
-keep class me.carda.awesome_notifications.** { *; }

# Just Audio
-keep class com.ryanheise.just_audio.** { *; }

# AudioPlayers
-keep class xyz.luan.audioplayers.** { *; }

# Alarm
-keep class com.gdelataillade.alarm.** { *; }

# Flutter Foreground Task
-keep class com.pravera.flutter_foreground_task.** { *; }

# Firebase Core & Messaging
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-keep class com.google.common.** { *; }

# Prevent R8 missing class warnings for basic types
-dontwarn be.tramckrijte.workmanager.**
-dontwarn me.carda.awesome_notifications.**
-dontwarn com.ryanheise.just_audio.**
-dontwarn xyz.luan.audioplayers.**
-dontwarn com.gdelataillade.alarm.**
-dontwarn com.pravera.flutter_foreground_task.**
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**
-dontwarn com.google.android.play.core.**
