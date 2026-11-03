/*
 * 목업 로더 — index.html <head>에서 React 번들보다 먼저 동기 로드된다.
 * 공통 엔진(/mock-common/mock-core.js) → 기준데이터(master.js) → 화면별 라우트 순서.
 * 원래 API 서버(http://<host>:9090/api/...)로 가는 axios 요청을 경로로 매칭해 응답한다.
 */
(function () {
  if (window.MOCK_CONFIG) return;
  window.MOCK_CONFIG = { app: 'ym', ctx: '/smart', passthrough: [] };
  var files = [
    '/mock-common/mock-core.js',
    '/smart/mock/master.js',
    '/smart/mock/routes/y1-base-equip.js',
    '/smart/mock/routes/y2-monitoring-production.js',
    '/smart/mock/routes/y3-condition-quality.js'
  ];
  for (var i = 0; i < files.length; i++) document.write('<script src="' + files[i] + '"><\/script>');
})();
