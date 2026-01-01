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
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    defaultConfig {
        applicationId = "com.example.flutter_application"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // === FLAVORS ===
    flavorDimensions += "app"
    productFlavors {
        create("dev") {
            dimension = "app"
            applicationIdSuffix = ".dev"
            versionNameSuffix = "-dev"
            resValue("string", "app_name", "Readings App DEV")
            resValue("string", "google_maps_key", googleMapsApiKey("dev"))
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
            signingConfig = signingConfigs.getByName("debug")
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

// === LEE .env DESDE LA RAÍZ DEL PROYECTO FLUTTER ===
fun googleMapsApiKey(flavor: String): String {
    val fileName = if (flavor == "dev") ".env.dev" else ".env"
    val rootProjectDir = project.rootProject.projectDir.parentFile
    val envFile = rootProjectDir.resolve(fileName)

    if (!envFile.exists()) {
        println("Warning: Archivo $fileName no encontrado en $rootProjectDir. Usando clave por defecto.")
        return "MISSING_KEY"
    }

    return try {
        val props = Properties()
        FileInputStream(envFile).use { input ->
            props.load(input)
        }
        val key = props.getProperty("GOOGLE_MAPS_API_KEY")
        if (key.isNullOrBlank()) {
            println("Warning: GOOGLE_MAPS_API_KEY vacía en $fileName.")
            "MISSING_KEY"
        } else {
            key.trim()
        }
    } catch (e: IOException) {
        println("Error al leer $fileName: ${e.message}")
        "MISSING_KEY"
    } catch (e: Exception) {
        println("Error inesperado: ${e.message}")
        "MISSING_KEY"
    }
}

flutter {
    source = "../.."
}