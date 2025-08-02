plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services") // sin versión aquí
}

android {
    namespace = "com.phone.alertmecel"
    compileSdk = 35

    defaultConfig {
        minSdk = 21
        targetSdk = 34
        versionCode = 1
        versionName = "1.0"
    }

    flavorDimensions += "device"

    productFlavors {
        create("phone") {
            dimension = "device"
            applicationId = "com.phone"
        }
        create("watch") {
            dimension = "device"
            applicationId = "com.watch"
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }
}

flutter {
    source = "../.."
}

// El apply ya no es necesario si está en plugins
// apply(plugin = "com.google.gms.google-services")

// Copiar el google-services.json correcto para cada flavor

