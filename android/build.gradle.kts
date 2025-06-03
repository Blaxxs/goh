// android/build.gradle.kts

// buildscript { ... } // 이 부분은 삭제된 상태 유지

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// 수정: 문자열 대신 file() 함수를 사용하여 File 객체 할당
rootProject.buildDir = file("../build") // "../build" 문자열을 File 객체로 변환
subprojects {
    // 수정: rootProject.buildDir (File 객체) 에 project.name (String)을 resolve하여 하위 경로 File 객체 생성
    project.buildDir = rootProject.buildDir.resolve(project.name)
}
// 아래 블록은 보통 최신 프로젝트에는 필요 없을 수 있으나, 일단 유지합니다.
subprojects {
     project.evaluationDependsOn(":app")
}

tasks.register("clean", Delete::class) {
    delete(rootProject.buildDir)
}