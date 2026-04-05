import org.gradle.api.tasks.Delete
import org.gradle.api.file.Directory

plugins {
    // Não forçar versões aqui; o Flutter controla via flutter.gradle
    id("com.android.application") apply false
    id("org.jetbrains.kotlin.android") apply false
}

buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.google.gms:google-services:4.4.1")
        classpath("com.google.firebase:firebase-crashlytics-gradle:3.0.2")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Redireciona o diretório de build para ../../build
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
    
    // Correção para plugins sem namespace (Isar, etc.) - AGP 8.x requer namespace
    afterEvaluate {
        if (plugins.hasPlugin("com.android.library")) {
            try {
                val androidExtension = extensions.findByType(com.android.build.gradle.LibraryExtension::class.java)
                androidExtension?.let { ext ->
                    if (ext.namespace == null || ext.namespace?.isEmpty() == true) {
                        ext.namespace = "fix.${project.name}"
                        println("Fixed namespace for ${project.name}: ${ext.namespace}")
                    }
                }
            } catch (e: Exception) {
                println("Could not fix namespace for ${project.name}: ${e.message}")
            }
        }
    }
    
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}