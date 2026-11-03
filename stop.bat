@echo off
chcp 65001 >nul
rem 영업 데모 서버 종료 (포트 5059)
set "CATALINA_HOME=D:\apache-tomcat-9.0.115"
set "CATALINA_BASE=%~dp0."
set "JAVA_HOME=C:\Program Files\Eclipse Adoptium\jdk-11.0.30.7-hotspot"
call "%CATALINA_HOME%\bin\catalina.bat" stop
