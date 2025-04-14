import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

val dotenv = Properties()
file("../../.env").inputStream().use { dotenv.load(it) }

val googleClientId = dotenv.getProperty("GOOGLE_CLIENT_ID") ?: ""
val googleRedirectScheme = dotenv.getProperty("GOOGLE_REDIRECT_SCHEME") ?: ""

android {
    namespace = "com.example.reverie"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973" 

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.reverie"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        resValue("string", "google_client_id", googleClientId)

        manifestPlaceholders["appAuthRedirectScheme"] = googleRedirectScheme
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
