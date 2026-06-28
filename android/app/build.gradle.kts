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
            signingConfig = signingConfigs.getByName("release")
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

// Configure Kotlin compiler options (required for Kotlin 2.3.x - replaces deprecated kotlinOptions DSL)
kotlin {
    compilerOptions {
        jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
    }
}

flutter {
    source = "../.."
}