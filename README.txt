==========================================================================
 영업 시연용 MES 데모 서버 (DB 없음, 프론트 + 예시 데이터)
==========================================================================

접속      http://localhost:5059/        (다른 PC에서는 http://<이 서버 IP>:5059/)
로그인    없음 — 각 주소로 들어가면 관리자 계정으로 바로 메인 화면이 열립니다.

  /line     연속 열처리 라인 MES  (JSP)   - 소입로/소려로 연속 라인
  /bcf      침탄로 모니터링 포털  (JSP)   - BCF 침탄로 1~12호기
  /smart    SMART MES            (React) - 연속열처리로 MBF 1~6호기

  * 시연용이라 화면·URL에 회사명/로고가 나오지 않도록 일반 명칭과 중립 로고로 바꿔 두었습니다.

실행 / 종료
  start.bat         백그라운드로 기동 (Tomcat 창이 따로 뜸)
  stop.bat          종료
  run-console.bat   현재 창에서 로그 보면서 실행 (창 닫으면 종료)

  - Tomcat 본체는 D:\apache-tomcat-9.0.115 를 그대로 쓰고, 이 폴더를 CATALINA_BASE 로 사용합니다.
  - 포트: HTTP 5059, 종료 포트 5069 (conf\server.xml)
  - Java: C:\Program Files\Eclipse Adoptium\jdk-11.0.30.7-hotspot (bat 파일에서 지정)

예시 데이터
  - 모든 화면의 데이터는 브라우저에서 생성됩니다. 서버/DB 호출은 없습니다.
  - 날짜는 "접속한 날" 기준 그제·어제·오늘 3일치로 자동 생성되므로, 언제 시연해도 최신 데이터처럼 보입니다.
  - 같은 날에는 새로고침해도 같은 데이터가 나옵니다(실시간 값은 시간에 따라 조금씩 변함).
  - 등록/수정/삭제는 "성공"으로 처리되며, 일부 화면은 브라우저 탭을 닫기 전까지 변경 내용이 유지됩니다.
    (초기화하려면 브라우저 탭을 닫았다가 다시 열면 됩니다)

폴더 구성
  conf\                       Tomcat 설정 (server.xml = 포트 5059)
  webapps\ROOT\               첫 화면(프로젝트 선택) + 공통 목업 엔진 + 외부 라이브러리 로컬 사본
      mock-common\mock-core.js   ajax/fetch 를 가로채서 예시 데이터를 돌려주는 엔진
      vendor\                    tabulator, xlsx, chart.js, jquery-ui, ionicons (인터넷 없이도 동작)
  webapps\line\               연속 열처리 라인 화면 (원본 JSP) + mock\ (예시 데이터)
  webapps\bcf\                침탄로 포털 화면 (원본 JSP) + mock\ (예시 데이터)
  webapps\smart\              SMART MES 빌드 결과물 + mock\ (예시 데이터)
  src\ym-frontend\            SMART MES React 소스 (base=/smart 로 빌드하도록 수정본)

예시 데이터 수정 방법
  각 앱의 mock\master.js        거래처 / 품목 / 설비 / 작업자 / 3일치 LOT 흐름 (공통 기준)
  각 앱의 mock\routes\*.js      화면(메뉴 그룹)별 API 응답
  파일 저장 후 브라우저 새로고침(Ctrl+F5)만 하면 반영됩니다. 서버 재시작 불필요.

원본과 다른 점 (데모용 변경)
  - Spring 컨트롤러/DB 대신 web.xml 에서 URL -> JSP 를 직접 연결
  - 각 JSP <head> 에 /<앱>/mock/mock-loader.js 한 줄 추가
  - 로그인 화면 제거: WEB-INF\demo\autologin.jsp 가 관리자 세션을 만들고 메인으로 이동 (SMART MES 는 항상 관리자)
  - 외부 CDN 스크립트를 /vendor 로컬 사본으로 교체
  - 회사 로고/공장 사진 이미지를 같은 크기의 중립 이미지(SMART MES)로 교체, 회사명 문구 제거
  - SMART MES: vite base=/smart/, BrowserRouter basename=/smart, index.html 에 목업 로더 추가

SMART MES 다시 빌드하기 (소스 수정 시)
  cd src\ym-frontend
  npm ci
  npm run build
  -> dist\ 내용을 webapps\smart\ 에 덮어쓰기 (webapps\smart\mock, META-INF, WEB-INF 는 유지)
