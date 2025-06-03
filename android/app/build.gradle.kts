// android/app/build.gradle.kts

import java.util.Properties
import java.io.FileInputStream
import java.io.File

plugins {
    id("com.android.application")
    kotlin("android")
    id("dev.flutter.flutter-gradle-plugin")
}

println(">>> Applying app/build.gradle.kts...")

// --- key.properties 읽는 부분 수정 (절대 경로 사용 및 즉시 확인) ---
println(">>> Reading key properties using absolute path logic...")
// 1. key.properties 파일의 예상 절대 경로를 구성합니다.
// rootProject.projectDir은 보통 'android' 폴더를 가리킵니다.
val expectedKeyPropertiesPath = File(rootProject.projectDir, "key.properties").canonicalPath
println(">>> Constructed absolute path for key.properties: ${expectedKeyPropertiesPath}")
// 2. 절대 경로를 사용하여 File 객체를 생성합니다.
val keyPropertiesFile = File(expectedKeyPropertiesPath)
// 3. File 객체 생성 직후 존재 여부를 로그로 출력합니다!
println(">>> Does keyPropertiesFile object exist based on absolute path? ${keyPropertiesFile.exists()}")
// --- 수정 끝 ---


val keyProperties = Properties()
var storeFilePath: String? = null
var loadedStoreFile: File? = null
var loadedKeyAlias: String? = null
var loadedKeyPassword: String? = null
var loadedStorePassword: String? = null
var propertiesLoaded = false

// 파일 존재 여부를 다시 확인하고 로드 시도
if (keyPropertiesFile.exists()) { // 파일 존재 여부 재확인
    try {
        keyProperties.load(FileInputStream(keyPropertiesFile))
        propertiesLoaded = true
        println(">>> key.properties loaded successfully.")

        storeFilePath = keyProperties.getProperty("storeFile")
        loadedKeyAlias = keyProperties.getProperty("keyAlias")
        loadedKeyPassword = keyProperties.getProperty("keyPassword")
        loadedStorePassword = keyProperties.getProperty("storePassword")

        println(">>> storeFile from properties: ${storeFilePath ?: "null or missing"}")
        println(">>> keyAlias from properties: ${loadedKeyAlias ?: "null or missing"}")

        if (storeFilePath != null) {
            loadedStoreFile = rootProject.file(storeFilePath) // storeFile 경로는 이전처럼 rootProject 기준으로 해석
            println(">>> Resolved storeFile path: ${loadedStoreFile?.absolutePath ?: "null"}")
            if (loadedStoreFile?.exists() != true) {
                println(">>> ERROR: Keystore file specified in storeFile DOES NOT EXIST at: ${loadedStoreFile?.absolutePath}")
                loadedStoreFile = null
            } else {
                println(">>> Keystore file FOUND at: ${loadedStoreFile?.absolutePath}")
            }
        } else {
            println(">>> ERROR: 'storeFile' property is missing in key.properties.")
        }

        if (loadedKeyAlias.isNullOrEmpty()) println(">>> ERROR: 'keyAlias' property is missing or empty.")
        if (loadedKeyPassword.isNullOrEmpty()) println(">>> ERROR: 'keyPassword' property is missing or empty.")
        if (loadedStorePassword.isNullOrEmpty()) println(">>> ERROR: 'storePassword' property is missing or empty.")

    } catch (e: Exception) {
        println(">>> CRITICAL ERROR loading key.properties: ${e.message}")
        propertiesLoaded = false
    }
} else {
    // 이 로그는 위에서 절대 경로로 생성한 File 객체가 존재하지 않을 때만 출력됩니다.
    println(">>> CRITICAL ERROR: key.properties file object check failed for path: ${expectedKeyPropertiesPath}")
    propertiesLoaded = false
}

// --- 모든 필수 서명 정보가 유효한지 최종 확인 ---
val signingPropertiesValid = propertiesLoaded &&
                             loadedStoreFile != null &&
                             loadedStoreFile?.exists() == true &&
                             !loadedKeyAlias.isNullOrEmpty() &&
                             !loadedKeyPassword.isNullOrEmpty() &&
                             !loadedStorePassword.isNullOrEmpty()

if (signingPropertiesValid) {
    println(">>> Conclusion: All required signing properties seem VALID and loaded.")
} else {
    println(">>> Conclusion: Required signing properties are MISSING or INVALID. Release signing cannot be configured.")
    // 필수 정보가 유효하지 않으면 여기서 빌드 중단
    throw org.gradle.api.GradleException("Stopped build because required signing properties are missing or invalid. Check key.properties content and keystore file path/existence.")
}
// --- 확인 끝 ---


android {
    namespace = "com.hikari.goh_calculator"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    sourceSets {
        getByName("main").java.srcDirs("src/main/kotlin")
    }

    defaultConfig {
        applicationId = "com.hikari.goh_calculator"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        println(">>> Configuring signingConfigs...")
        // signingPropertiesValid 가 true 임이 위에서 확인되었으므로, 생성 시도
        create("release") {
            println(">>> Creating 'release' signingConfig with validated properties...")
            keyAlias = loadedKeyAlias!!
            keyPassword = loadedKeyPassword!!
            storeFile = loadedStoreFile!!
            storePassword = loadedStorePassword!!
            println(">>> 'release' signingConfig block executed.")
        }
    }

    buildTypes {
        release {
            println(">>> Configuring release buildType...")
            println(">>> Attempting to apply 'release' signingConfig...")
            signingConfig = signingConfigs.getByName("release")
            println(">>> Successfully applied 'release' signingConfig.")

            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation(kotlin("stdlib-jdk8"))
    // 기타 의존성
}