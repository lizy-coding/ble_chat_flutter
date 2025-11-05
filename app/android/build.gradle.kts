allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

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

// === HOTFIX_AGP8_NAMESPACE_isar_flutter_libs ===
// 动态为三方库模块注入 namespace（AGP 8+）。
// === HOTFIX_AGP8_NAMESPACE_isar_flutter_libs ===
// 为 isar_flutter_libs 子模块在 AGP 8+ 下动态注入 namespace（在库插件应用后立刻设置）
// === HOTFIX for isar_flutter_libs on AGP 8+ ===
// 目标：1) 注入 namespace；2) 移除库 Manifest 中的 package="..."。
subprojects {
    if (name == "isar_flutter_libs") {

        // ① 等库应用 Android 插件后，设置 namespace
        pluginManager.withPlugin("com.android.library") {
            val ext = extensions.findByName("android")
            val setter = ext?.javaClass?.methods
                ?.firstOrNull { it.name == "setNamespace" && it.parameterTypes.size == 1 }
            val getter = ext?.javaClass?.methods
                ?.firstOrNull { it.name == "getNamespace" && it.parameterTypes.isEmpty() }
            val hasNs = try { getter?.invoke(ext)?.toString().isNullOrBlank().not() } catch (_: Throwable) { false }
            if (!hasNs && setter != null) {
                setter.invoke(ext, "dev.isar.flutter.libs")
                println("[hotfix] set namespace for :$name -> dev.isar.flutter.libs")
            }
        }

        // ② 在处理清单前，把库的 AndroidManifest.xml 里的 package="..." 删除
        afterEvaluate {
            val manifestFile = file("src/main/AndroidManifest.xml")
            if (manifestFile.exists()) {
                val original = manifestFile.readText()
                // 去掉 manifest 根节点上的 package 属性（仅删除属性，不改其他内容）
                val patched = original.replace(Regex("""\s+package\s*=\s*"[^"]*""""), "")
                if (patched != original) {
                    manifestFile.writeText(patched)
                    println("[hotfix] stripped package attribute in :$name/src/main/AndroidManifest.xml")
                }
            }
        }
    }
}
// === END HOTFIX for isar_flutter_libs ===



