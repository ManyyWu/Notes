# Clion

## 修改构建脚本后自动加载项目
  设置-构建、执行、部署-构建工具-勾选“在构建脚本发生任何改变后重新加载项目”
  文件-新项目设置-新项目的设置-构建、执行、部署-构建工具-勾选“在构建脚本发生任何改变后重新加载项目”

## 删除所有快捷键
  1. 修改一个快捷键
  2. %USERPROFILE%\AppData\Roaming\JetBrains\CLion2023.1\keymaps中的配置文件，把parent属性删掉，重启。

## 关闭格式化程序
  * 开: @formatter:on
  * 关: @formatter:off

## vm
  ```
  -Xms128m
  -Xmx20480m
  -XX:ReservedCodeCacheSize=512m
  -XX:+IgnoreUnrecognizedVMOptions
  -XX:+UseG1GC
  -XX:SoftRefLRUPolicyMSPerMB=50
  -XX:CICompilerCount=2
  -XX:+HeapDumpOnOutOfMemoryError
  -XX:-OmitStackTraceInFastThrow
  -ea
  -Dsun.io.useCanonCaches=false
  -Djdk.http.auth.tunneling.disabledSchemes=""
  -Djdk.attach.allowAttachSelf=true
  -Djdk.module.illegalAccess.silent=true
  -Dkotlinx.coroutines.debug=off
  -XX:ErrorFile=$USER_HOME/java_error_in_idea_%p.log
  -XX:HeapDumpPath=$USER_HOME/java_error_in_idea.hprof
  
  --add-opens=java.base/jdk.internal.org.objectweb.asm=ALL-UNNAMED
  --add-opens=java.base/jdk.internal.org.objectweb.asm.tree=ALL-UNNAMED
  
  -javaagent:C:\jetbra\ja-netfilter.jar=jetbrains
  ```
