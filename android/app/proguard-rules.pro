# YCT App — ProGuard Rules

# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Kotlin
-keep class kotlin.** { *; }
-keep class kotlinx.** { *; }

# Keep crash reporting stack traces readable via Crashlytics
-keepattributes SourceFile,LineNumberTable
-keep public class * extends java.lang.Exception
-keepattributes *Annotation*

# ── Fix R8 missing Play Core classes ────────────────────────────────────────
# Flutter uses Play Core for deferred components — we don't use them
# but R8 still tries to compile references. Tell R8 to ignore them.
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }
-dontwarn io.flutter.embedding.engine.deferredcomponents.**
-dontwarn io.flutter.app.FlutterPlayStoreSplitApplication
