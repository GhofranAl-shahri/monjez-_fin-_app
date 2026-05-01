allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// 1. تعريف مجلد البناء الرئيسي داخل المشروع (المسار الافتراضي)
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()

// 2. تعيين القيمة للمشروع الرئيسي
rootProject.layout.buildDirectory.value(newBuildDir)

// 3. تعيين مجلدات البناء للمشاريع الفرعية (مثل app و libraries)
subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
