import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

// Load keystore properties
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {

    namespace = "com.geographygeyser.simon"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    testOptions {
        unitTests {
            isReturnDefaultValues = true
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    // 🔐 Signing config
    signingConfigs {
        create("release") {
            val keyAliasStr = keystoreProperties["keyAlias"] as? String
            val keyPasswordStr = keystoreProperties["keyPassword"] as? String
            val storeFileStr = keystoreProperties["storeFile"] as? String
            val storePasswordStr = keystoreProperties["storePassword"] as? String

            if (keyAliasStr != null && keyPasswordStr != null && storeFileStr != null && storePasswordStr != null) {
                keyAlias = keyAliasStr
                keyPassword = keyPasswordStr
                storeFile = file(storeFileStr)
                storePassword = storePasswordStr
            }
        }
    }

    defaultConfig {
        applicationId = "com.geographygeyser.simon"
        minSdk = flutter.minSdkVersion
        targetSdk = 36
        versionCode = 4
        versionName = "2.0.1"
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
        }
        getByName("debug") {
            // debug build normally unsigned
        }
    }
}

flutter {
    source = "../.."
}
