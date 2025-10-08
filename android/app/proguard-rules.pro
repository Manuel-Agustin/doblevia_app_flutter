#Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-keep class com.redsys.tpvvinapplibrary.**  { *; }

# Mantener clases Flutter deferred components (aunque no los uses)
-keep class io.flutter.embedding.android.** { *; }
-keep class com.google.android.play.core.** { *; }

-keep class com.google.android.play.** { *; }
-dontwarn com.google.android.play.core.**
-dontnote com.google.android.play.core.**
-dontwarn io.flutter.embedding.engine.deferredcomponents.**
