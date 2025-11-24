allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    project.layout.buildDirectory.value(rootProject.layout.buildDirectory.dir(project.name))
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
// --- TAMBAHAN WAJIB UNTUK FIREBASE ---
// Baris ini sudah dipindahkan ke android/settings.gradle.kts
// id("com.google.gms.google-services") version "4.4.2" apply false
// --- TAMBAHAN WAJIB UNTUK FIREBASE ---