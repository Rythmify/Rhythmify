# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Dio
-keep class com.dio.** { *; }

# Riverpod
-keep class com.riverpod.** { *; }

# GoRouter
-keep class com.gorouter.** { *; }

# Google Sign-In
-keep class com.google.android.gms.auth.api.signin.** { *; }
-keep class com.google.android.gms.auth.api.signin.internal.** { *; }

# Firebase Auth
-keep class com.google.firebase.auth.** { *; }

# Preserve all model classes from obfuscation
-keep class **.data.models.** { *; }
-keep class **.domain.entities.** { *; }
-keep class **.models.** { *; }
-keep class **.entities.** { *; }

# Flutter Play Core / Deferred Components
-dontwarn com.google.android.play.core.**
-dontwarn io.flutter.embedding.engine.deferredcomponents.**
