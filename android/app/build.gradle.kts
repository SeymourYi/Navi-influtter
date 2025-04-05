plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.Navi"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.Navi"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
  manifestPlaceholders["JPUSH_PKGNAME"] = "com.Navi"
        manifestPlaceholders["JPUSH_APPKEY"] = "37bb58f488aa4f8dd7e43516" // NOTE: JPush 上注册的包名对应的 Appkey.
        manifestPlaceholders["JPUSH_CHANNEL"] = "Navi" //暂时填写默认值即可.
  manifestPlaceholders["XIAOMI_APPID"] = "2882303761520401700" //暂时填写默认值即可.
  manifestPlaceholders["XIAOMI_APPKEY"] = "5912040133700" //暂时填写默认值即可.

    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
