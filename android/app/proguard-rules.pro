# -----------------------------------------------------------------------------
# ProGuard / R8 Rules for PulseTrack (Release Builds)
# -----------------------------------------------------------------------------

# --- R8 Full Mode Optimizations & Class Repackaging for Google Play ---
-repackageclasses ''
-allowaccessmodification

# --- Flutter engine / platform channels ---
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }
-keepclassmembers class * implements android.os.IInterface {
    public static ** DEFAULT;
}

# --- Play Store Split Install (deferred components) ---
-dontwarn com.google.android.play.core.**

# --- Firebase Crashlytics ---
# Retain line numbers and source file names for accurate stack trace de-obfuscation
-keepattributes SourceFile,LineNumberTable
-keep public class * extends java.lang.Exception
-keepclassmembers class * {
    @com.google.firebase.crashlytics.** *;
}

# --- Isar Community Database ---
# Isar uses JNI bindings to interact with native libisar binaries.
# Preventing stripping and obfuscation of dev.isar / io.isar classes avoids UnsatisfiedLinkError on release.
-keep class dev.isar.** { *; }
-dontwarn dev.isar.**
-keep class io.isar.** { *; }
-dontwarn io.isar.**

# --- Flutter Foreground Task ---
# Keeps foreground task service and notification components from being stripped by R8.
-keep class com.pravera.flutter_foreground_task.** { *; }

# --- Flutter Blue Plus ---
# Preserves Bluetooth Low Energy communication interfaces and channel callbacks.
-keep class com.boskokg.flutter_blue_plus.** { *; }

# --- Health Connect / AndroidX Health ---
-keep class androidx.health.** { *; }
-dontwarn androidx.health.**

# --- Flutter Local Notifications ---
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-keep class com.dexterous.flutterlocalnotifications.ActionBroadcastReceiver { *; }
-keep class com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver { *; }
-keep class com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver { *; }
-dontwarn com.dexterous.flutterlocalnotifications.**



