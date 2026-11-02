@echo off
set DIRNAME=%~dp0
set APP_HOME=%DIRNAME%
set CLASSPATH=%APP_HOME%gradle\wrapper\gradle-wrapper.jar
if not exist "%CLASSPATH%" (
  echo Gradle wrapper JAR is missing. Bootstrap it from a Flutter SDK.
  exit /b 1
)
java -classpath "%CLASSPATH%" org.gradle.wrapper.GradleWrapperMain %*
