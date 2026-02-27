allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)

    if (project.name != "app") {
        project.afterEvaluate {
            if (project.hasProperty("android")) {
                val android = project.extensions.findByName("android")
                try {
                    val getNamespace = android?.javaClass?.getMethod("getNamespace")
                    val namespace = getNamespace?.invoke(android)
                    if (namespace == null) {
                        val setNamespace = android?.javaClass?.getMethod("setNamespace", String::class.java)
                        val groupName = project.group.toString()
                        val fallbackNamespace = if (groupName.isNotEmpty()) groupName else "com.plugin.${project.name.replace("-", "_")}"
                        setNamespace?.invoke(android, fallbackNamespace)
                    }
                } catch (e: Exception) {
                    // Ignore if method not found or other issues
                }
            }
        }
        project.evaluationDependsOn(":app")
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
