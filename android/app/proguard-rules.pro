# -----------------------------------------------------------------------------
# ProGuard / R8 Rules for PulseTrack (Release Builds)
# -----------------------------------------------------------------------------

# --- Firebase Crashlytics ---
# Retain line numbers and source file names for accurate stack trace de-obfuscation
-keepattributes SourceFile,LineNumberTable
-keep public class * extends java.lang.Exception
-keepclassmembers class * {
    @com.google.firebase.crashlytics.** *;
}

# --- Isar Community Database ---
# Isar uses JNI bindings to interact with native libisar binaries.
# Preventing stripping and obfuscation of dev.isar classes avoids UnsatisfiedLinkError on release.
-keep class dev.isar.** { *; }
-dontwarn dev.isar.**

# --- Flutter Foreground Task ---
# Keeps foreground task service and notification components from being stripped by R8.
-keep class com.pravera.flutter_foreground_task.** { *; }

# --- Flutter Blue Plus ---
# Preserves Bluetooth Low Energy communication interfaces and channel callbacks.
-keep class com.boskokg.flutter_blue_plus.** { *; }
