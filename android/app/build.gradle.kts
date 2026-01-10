plugins {
    id 'com.android.application'
    id 'kotlin-android'
    // Flutter plugin must be applied after Android & Kotlin plugins
    id 'dev.flutter.flutter-gradle-plugin'
    id 'com.google.gms.google-services'  // Firebase services
}

android {
    namespace = "com.example.societyhub"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    defaultConfig {
        applicationId = "com.example.societyhub"
        minSdk = 19
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Firebase BOM (version manage karega)
    implementation platform('com.google.firebase:firebase-bom:34.7.0')

    // Firebase Authentication
    implementation 'com.google.firebase:firebase-auth'

    // Firebase Firestore (optional)
    implementation 'com.google.firebase:firebase-firestore'

    // Firebase Analytics (optional)
    implementation 'com.google.firebase:firebase-analytics'
}

// Apply Firebase plugin at the bottom
apply plugin: 'com.google.gms.google-services'
