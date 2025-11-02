buildscript {
    repositories {
        // Aliyun mirrors (helpful for network issues)
        maven { url = uri("https://maven.aliyun.com/repository/google") }
        maven { url = uri("https://maven.aliyun.com/repository/central") }
        maven { url = uri("https://maven.aliyun.com/repository/gradle-plugin") }
        maven { url = uri("https://maven.aliyun.com/repository/public") }
        google()
        mavenCentral()
        maven { url = uri("https://maven.google.com") }
        maven { url = uri("https://developer.huawei.com/repo/") }
    }
    
    dependencies {
        classpath("com.google.gms:google-services:4.3.4")
     
        classpath("cn.jiguang.sdk.plugin:xiaomi:5.6.0")
    }
}

allprojects {
    repositories {
        // Aliyun mirrors (helpful for network issues)
        maven { url = uri("https://maven.aliyun.com/repository/google") }
        maven { url = uri("https://maven.aliyun.com/repository/central") }
        maven { url = uri("https://maven.aliyun.com/repository/public") }
        // Flutter download repository
        maven { url = uri("https://storage.googleapis.com/download.flutter.io") }
        google()
        mavenCentral()
        maven { url = uri("https://maven.google.com") }
        maven { url = uri("https://developer.huawei.com/repo/") }
    }
}
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
    
    // Configure tasks immediately (this works before evaluation)
    tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
        kotlinOptions {
            jvmTarget = "17"
        }
    }
    
    // Configure Android options after evaluation
    afterEvaluate {
        if (project.hasProperty("android")) {
            extensions.findByType<com.android.build.gradle.BaseExtension>()?.let { android ->
                android.compileOptions {
                    sourceCompatibility = JavaVersion.VERSION_17
                    targetCompatibility = JavaVersion.VERSION_17
                }
            }
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
