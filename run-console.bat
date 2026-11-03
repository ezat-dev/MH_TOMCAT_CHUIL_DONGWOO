@echo off
chcp 65001 >nul
rem 콘솔 창에서 로그를 보면서 실행 (창을 닫으면 종료)
set "CATALINA_HOME=D:\apache-tomcat-9.0.115"
set "CATALINA_BASE=%~dp0."
set "JAVA_HOME=C:\Program Files\Eclipse Adoptium\jdk-11.0.30.7-hotspot"
set "CATALINA_OPTS=-Dfile.encoding=UTF-8 -Xms256m -Xmx768m"
call "%CATALINA_HOME%\bin\catalina.bat" run
