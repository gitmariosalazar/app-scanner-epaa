import java.util.Properties
import java.io.FileInputStream
import java.io.IOException

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.flutter_application"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlin {
        compilerOptions {
            jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
        }
    }

    signingConfigs {
        val keystoreProperties = Properties()
        val keystorePropertiesFile = rootProject.file("key.properties")
        
        if (keystorePropertiesFile.exists()) {
            keystoreProperties.load(FileInputStream(keystorePropertiesFile))
        }

        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String?
            keyPassword = keystoreProperties["keyPassword"] as String?
            storeFile = keystoreProperties["storeFile"]?.let { file(it as String) }
            storePassword = keystoreProperties["storePassword"] as String?
        }
    }

    defaultConfig {
        applicationId = "com.example.app_scanner_epaa"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // === FLAVORS ===
    flavorDimensions += "app"
    productFlavors {
        create("develop") {
            dimension = "app"
            applicationIdSuffix = ".develop"
            versionNameSuffix = "-develop"
            resValue("string", "app_name", "Readings App DEV")
            resValue("string", "google_maps_key", googleMapsApiKey("develop"))
        }
        create("prod") {
            dimension = "app"
            resValue("string", "app_name", "Readings App")
            resValue("string", "google_maps_key", googleMapsApiKey("prod"))
        }
    }

    // === BUILD TYPES ===
    buildTypes {
        getByName("debug") {
            applicationIdSuffix = ".debug"
            versionNameSuffix = "-debug"
            isDebuggable = true
        }
        getByName("release") {
            isMinifyEnabled = false
            isShrinkResources = false
            signingConfig = signingConfigs.getByName("release")
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

fun googleMapsApiKey(flavor: String): String {
    val fileName = if (flavor == "develop") ".env.dev" else ".env.production"
    val envFile = project.rootProject.file("../$fileName")

    if (!envFile.exists()) {
        println("❌ Warning: Archivo $fileName no encontrado en ${envFile.absolutePath}")
        return "MISSING_KEY"
    }

    return try {
        val props = Properties()
        envFile.inputStream().use { props.load(it) }
        val key = props.getProperty("GOOGLE_MAPS_API_KEY")
        if (key.isNullOrBlank()) {
            println("❌ Warning: GOOGLE_MAPS_API_KEY vacía o no encontrada en $fileName")
            "MISSING_KEY"
        } else {
            key.trim()
        }
    } catch (e: Exception) {
        println("❌ Error al leer $fileName: ${e.message}")
        "MISSING_KEY"
    }
}

flutter {
    source = "../.."
}