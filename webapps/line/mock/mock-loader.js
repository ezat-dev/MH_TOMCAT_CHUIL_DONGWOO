/*
 * 목업 로더 — 모든 JSP의 <head> 맨 앞에서 동기 로드된다.
 * 공통 엔진(/mock-common/mock-core.js) → 기준데이터(master.js) → 화면별 라우트 순서.
 */
(function () {
  if (window.MOCK_CONFIG) return; // include 된 JSP에서 중복 로드 방지
  window.MOCK_CONFIG = {
    app: 'chunil',
    ctx: '/line',
    // 실제 서버(JSP)가 처리하는 URL — 데모 로그인/로그아웃(세션)만
    passthrough: ['/user/login/check', '/user/logout']
  };
  var files = [
    '/mock-common/mock-core.js',
    '/line/mock/master.js',
    '/line/mock/routes/c1-base-equip.js',
    '/line/mock/routes/c2-monitoring.js',
    '/line/mock/routes/c3-prod-cond.js',
    '/line/mock/routes/c4-quality.js',
    '/line/mock/routes/c5-extra.js',
  ];
  for (var i = 0; i < files.length; i++) document.write('<script src="' + files[i] + '"><\/script>');
})();
