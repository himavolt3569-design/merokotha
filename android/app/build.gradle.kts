plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // Flutter Gradle plugin
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.merokotha.app" // Replace with your package if needed
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    defaultConfig {
        applicationId = "com.merokotha.app" // Replace with your package
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true // ✅ Required for flutter_local_notifications
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug") // For testing, replace for production
        }
    }
        signingConfigs {
        release {
            keyAlias 'merokotha'
            keyPassword 'your_password'
            storeFile file('merokotha.jks')
            storePassword 'your_password'
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Core library desugaring (required for some plugins)
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")

}
