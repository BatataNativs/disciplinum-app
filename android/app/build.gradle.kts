import java.util.Base64
import org.gradle.api.file.RelativePath

val dartEnvironmentVariables = mutableMapOf<String, String>()
if (project.hasProperty("dart-defines")) {
    val dartDefines = project.property("dart-defines") as String
    if (dartDefines.isNotEmpty()) {
        dartDefines.split(",").forEach { entry ->
            try {
                val decoded = String(Base64.getDecoder().decode(entry), Charsets.UTF_8)
                val pair = decoded.split("=")
                if (pair.size == 2) {
                    dartEnvironmentVariables[pair[0]] = pair[1]
                }
            } catch (e: Exception) {
                // Ignore
            }
        }
    }
}

plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
    id("com.google.firebase.crashlytics")
}

android {
    namespace = "com.disciplinum.app"

    compileSdk = 36 // android sdk version
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    configurations.all {
        resolutionStrategy {
            // Força versões estáveis que funcionam com AGP 8.7.x
            force("androidx.browser:browser:1.8.0")
            force("androidx.activity:activity:1.9.3")
            force("androidx.activity:activity-ktx:1.9.3")
            force("androidx.core:core:1.15.0")
            force("androidx.core:core-ktx:1.15.0")
        }
    }

    defaultConfig {
        applicationId = "com.disciplinum.app"
        // Atualizado para 23 para melhor compatibilidade com libs modernas
        minSdk = flutter.minSdkVersion 
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
        
        val admobAppId = dartEnvironmentVariables["ADMOB_APP_ID"] ?: "ca-app-pub-3940256099942544~3347358543"
        manifestPlaceholders["ADMOB_APP_ID"] = admobAppId
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = false // Mantenha false até configurar ProGuard corretamente
            isShrinkResources = false
        }
        debug {
            isMinifyEnabled = false
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
    implementation("androidx.multidex:multidex:2.0.1")
    implementation("androidx.appcompat:appcompat:1.6.1")
}

// Workaround for Flutter AGP 8.x APK location issue
// See: https://github.com/flutter/flutter/issues/174620
// Flutter expects APKs at <project_root>/build/app/outputs/flutter-apk/
// but AGP 8.x generates them at android/app/build/outputs/apk/
val flutterOutDir = layout.buildDirectory.dir("outputs/apk").get().asFile
val cliOutDir = file("${project.projectDir.parentFile.parentFile}/build/app/outputs/flutter-apk")

tasks.register<Copy>("syncFlutterApks") {
    group = "flutter"
    description = "Syncs APKs to Flutter's expected location"

    from(flutterOutDir) {
        include("**/*.apk")
    }
    into(cliOutDir)

    // Flatten directory structure - copy APKs directly to target dir
    eachFile {
        val segments = relativePath.segments
        if (segments.size > 1) {
            relativePath = RelativePath(true, segments.last())
        }
    }
    includeEmptyDirs = false

    doFirst {
        cliOutDir.mkdirs()
        logger.lifecycle("[patch] syncFlutterApks: from=$flutterOutDir -> to=$cliOutDir")
    }
    doLast {
        logger.lifecycle("[patch] syncFlutterApks: done")
    }
}

// Hook sync task to all assemble tasks
afterEvaluate {
    tasks.named("assembleDebug").configure {
        finalizedBy("syncFlutterApks")
    }
    tasks.named("assembleRelease").configure {
        finalizedBy("syncFlutterApks")
    }
    tasks.named("assembleProfile").configure {
        finalizedBy("syncFlutterApks")
    }
}
