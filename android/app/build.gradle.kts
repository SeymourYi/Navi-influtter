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

    signingConfigs {
        create("release") {
            storeFile = file("my-release-key.keystore")
            storePassword = "123456"
            keyAlias = "my-key-alias"
            keyPassword = "123456"
        }
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.Navi"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = 3
        versionName = "1.0.3"
        manifestPlaceholders["JPUSH_PKGNAME"] = "com.Navi"
        manifestPlaceholders["JPUSH_APPKEY"] = "8b8a7faafb8dbceffabf0bdb" // NOTE: JPush 上注册的包名对应的 Appkey.
        manifestPlaceholders["JPUSH_CHANNEL"] = "Navi" //暂时填写默认值即可.
        manifestPlaceholders["XIAOMI_APPID"] = "2882303761520401700" //暂时填写默认值即可.
        manifestPlaceholders["XIAOMI_APPKEY"] = "5482037264137" //暂时填写默认值即可.
    }

    buildTypes {
        release {
            // 使用我们定义的签名配置，而不是debug签名
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}
