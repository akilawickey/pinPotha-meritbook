import java.util.Properties

plugins {
    id("com.android.application")
    id("com.google.gms.google-services")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val signingProperties = Properties()
val signingFile = rootProject.file("key.properties")
if (signingFile.exists()) signingFile.inputStream().use { signingProperties.load(it) }

android {
    namespace = "asak.pro.pinPotha"
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
        // Preserve the identity declared by the native Android application.
        applicationId = "asak.pro.pinPotha"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (signingFile.exists()) {
            create("release") {
                keyAlias = signingProperties.getProperty("keyAlias")
                keyPassword = signingProperties.getProperty("keyPassword")
                storeFile = file(signingProperties.getProperty("storeFile"))
                storePassword = signingProperties.getProperty("storePassword")
            }
        }
    }
    buildTypes {
        release {
            // Release builds require the existing upload/signing configuration.
            signingConfig = if (signingFile.exists()) signingConfigs.getByName("release") else null
        }
    }
}

flutter {
    source = "../.."
}

// Never silently produce a debug-signed production bundle.
gradle.taskGraph.whenReady {
    if (!signingFile.exists() && providers.gradleProperty("allowUnsignedRelease").orNull != "true" && allTasks.any { it.name == "bundleRelease" || it.name == "assembleRelease" }) {
        throw GradleException("Release signing requires android/key.properties. Verify the existing Play signing identity first.")
    }
}
