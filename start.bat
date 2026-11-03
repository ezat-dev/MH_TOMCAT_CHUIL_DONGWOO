@echo off
chcp 65001 >nul
rem ==========================================================
rem  영업 데모 서버 시작 (포트 5059)  -  http://localhost:5059/
rem  DB 없이 화면 + 예시 데이터(목업)만으로 동작합니다.
rem ==========================================================
set "CATALINA_HOME=D:\apache-tomcat-9.0.115"
set "CATALINA_BASE=%~dp0."
set "JAVA_HOME=C:\Program Files\Eclipse Adoptium\jdk-11.0.30.7-hotspot"
set "CATALINA_OPTS=-Dfile.encoding=UTF-8 -Xms256m -Xmx768m"
set "TITLE=DEMO-5059"
call "%CATALINA_HOME%\bin\catalina.bat" start
echo.
echo  데모 서버 기동: http://localhost:5059/   (ID: ez / PW: ez)
