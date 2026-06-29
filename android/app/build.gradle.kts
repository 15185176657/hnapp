plugins {
    id("com.android.application")
    // Flutter Gradle 插件必须在 Android 与 Kotlin 插件之后应用。
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.hnapp"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // 待办：打包发布前请替换为唯一的正式 applicationId。
        applicationId = "com.example.hnapp"
        // 可按应用需求调整下列 SDK 与版本配置。
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // 待办：正式发布前请配置 release 签名。
            // 当前暂用 debug 签名，便于演示版 release 运行。
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
