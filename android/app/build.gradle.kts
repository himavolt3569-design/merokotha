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
    namespace = "com.example.merokotha" // Replace with your package if needed
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    defaultConfig {
        applicationId = "com.example.merokotha" // Replace with your package
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
}

flutter {
    source = "../.."
}

dependencies {
    // Core library desugaring (required for some plugins)
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")

    // Firebase / FlutterFire dependencies
     implementation("com.google.firebase:firebase-analytics-ktx:21.3.0")
    implementation("com.google.firebase:firebase-auth-ktx:22.1.0")
    implementation("com.google.firebase:firebase-firestore-ktx:24.6.0") // ✅ Correct version
    implementation("com.google.firebase:firebase-messaging-ktx:23.2.0")

}