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
        targetSdk = 33 // 降低targetSdk版本以解决小米推送兼容性问题
        versionCode = 3
        versionName = "1.0.3"
        
        ndk {
            // 选择要添加的对应cpu类型的.so库，移除不支持的armeabi
            abiFilters += listOf("armeabi-v7a", "arm64-v8a")
            // 还可以添加 'x86', 'x86_64'
        }
        
        manifestPlaceholders["JPUSH_PKGNAME"] = "com.Navi"
        manifestPlaceholders["JPUSH_APPKEY"] = "8b8a7faafb8dbceffabf0bdb" // NOTE: JPush 上注册的包名对应的 Appkey.
        manifestPlaceholders["JPUSH_CHANNEL"] = "Navi" //暂时填写默认值即可.
        manifestPlaceholders["XIAOMI_APPID"] = "2882303761520401700" //小米的APPID
        manifestPlaceholders["XIAOMI_APPKEY"] = "5482037264137" //小米的APPKEY
    }

    buildTypes {
        release {
            // 使用我们定义的签名配置，而不是debug签名
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

dependencies {
    // 极光推送核心SDK
    implementation("cn.jiguang.sdk:jpush:5.6.0")
    
    // 小米厂商通道
    implementation("cn.jiguang.sdk.plugin:xiaomi:5.6.0")
}

flutter {
    source = "../.."
}
