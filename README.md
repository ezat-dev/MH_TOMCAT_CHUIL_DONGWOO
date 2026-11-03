# MH_TOMCAT_CHUIL_DONGWOO
샘플 프로젝트 — 영업 시연용 MES 데모 (DB 없음, 프론트 + 브라우저 예시 데이터)

| 경로 | 화면 |
|---|---|
| `/line`  | 연속 열처리 라인 MES (JSP) |
| `/bcf`   | 침탄로 모니터링 포털 (JSP) |
| `/smart` | SMART MES (React 빌드본, 소스는 `src/ym-frontend`) |

## 다른 PC에서 실행
1. Tomcat 9 와 Java 11 설치
2. `start.bat`, `stop.bat`, `run-console.bat` 안의 경로를 그 PC에 맞게 수정
   - `CATALINA_HOME` (현재 `D:\apache-tomcat-9.0.115`)
   - `JAVA_HOME` (현재 `C:\Program Files\Eclipse Adoptium\jdk-11.0.30.7-hotspot`)
   - `CATALINA_BASE` = 이 폴더
3. `start.bat` 실행 → http://localhost:5059/

자세한 내용(예시 데이터 수정 방법, 다시 빌드하기 등)은 `README.txt` 참고.
