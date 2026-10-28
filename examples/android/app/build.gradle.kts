plugins { id("com.android.application"); id("org.jetbrains.kotlin.android") }
android {
    namespace = "ink.bop.demo"
    compileSdk = 35
    defaultConfig { applicationId = "ink.bop.demo"; minSdk = 23; targetSdk = 35; versionCode = 1; versionName = "0.1" }
    sourceSets["main"].java.srcDir("../../../packages/kotlin/src/main/kotlin")
    compileOptions { sourceCompatibility = JavaVersion.VERSION_1_8; targetCompatibility = JavaVersion.VERSION_1_8 }
    kotlinOptions { jvmTarget = "1.8" }
}
