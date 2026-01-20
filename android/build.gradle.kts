


allprojects {
//    repositories {
//        // 修正为https协议
//        aven { url = uri("https://maven.aliyun.com/repository/google") }m
//        maven { url = uri("https://maven.aliyun.com/repository/jcenter") }
//        maven { url = uri("https://maven.aliyun.com/nexus/content/groups/public") }
//    }
    repositories {
        maven { url = uri("https://maven.aliyun.com/repository/public/") }
        mavenCentral()
        google()
        // 其他仓库
    }

    configurations.all {
        resolutionStrategy {
            cacheDynamicVersionsFor(10, "minutes")
            cacheChangingModulesFor(10, "minutes")
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
    }

    subprojects {
        project.evaluationDependsOn(":app")
    }

// 保留原有clean任务配置（无需修改）
//    tasks.register<Delete>("clean") {
//        delete(rootProject.layout.buildDirectory)
//    }
}

