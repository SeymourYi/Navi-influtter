# 保留BouncyCastle相关类
-keep class org.bouncycastle.** { *; }
-keepnames class org.bouncycastle.** { *; }
-dontwarn org.bouncycastle.**

# 特别指定需要保留的BouncyCastle类
-keep class org.bouncycastle.crypto.CipherParameters { *; }
-keep class org.bouncycastle.crypto.InvalidCipherTextException { *; }
-keep class org.bouncycastle.crypto.digests.SM3Digest { *; }
-keep class org.bouncycastle.crypto.engines.SM2Engine { *; }
-keep class org.bouncycastle.crypto.params.** { *; }
-keep class org.bouncycastle.jce.** { *; }
-keep class org.bouncycastle.math.ec.** { *; }

# 保留可能被引用的加密相关类
-keep class com.unicom.online.account.kernel.** { *; }
-keepnames class com.unicom.online.account.kernel.** { *; }
-dontwarn com.unicom.online.account.kernel.**

# Google Play Core相关
-keep class com.google.android.play.core.** { *; }
-keepnames class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**

# Flutter通用规则
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; } 