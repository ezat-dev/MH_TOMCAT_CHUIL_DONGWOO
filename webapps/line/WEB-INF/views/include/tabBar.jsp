<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
<script src="/line/mock/mock-loader.js"></script>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <link rel="stylesheet" href="/line/css/tabBar/tabBar.css">
  <title>SMART MES</title>
</head>

<style>	

</style>

<body>

	 

<script>

/* ── 버튼 비활성화 유틸 ── */
function selectButtonNone(){
	$(".select-button").css("pointer-events","none").css("opacity","0.5");
}
function insertButtonNone(){
	$(".insert-button").css("pointer-events","none").css("opacity","0.5");
}
function excelButtonNone(){
	$(".excel-button").css("pointer-events","none").css("opacity","0.5");
}
function printButtonNone(){
	$(".printer-button").css("pointer-events","none").css("opacity","0.5");
}

/* ── 페이지 접근 권한 체크 ── */
$(function () {
	/* now_page_code가 선언된 페이지에서만 동작 */
	if (typeof now_page_code === 'undefined' || !now_page_code) return;

	$.post('/line/user/info', {}, function (result) {
		var perm = result.loginUserPage;

		/* 세션 없음 → 로그인 페이지로 */
		if (!perm) {
			alert('로그인이 필요합니다.');
			location.href = '/line/';
			return;
		}

		var level = perm[now_page_code];

		/* 권한 없음(N) 또는 해당 코드 자체가 없으면 접근 차단 */
		if (!level || level === 'N') {
			document.body.innerHTML =
				'<div style="display:flex;align-items:center;justify-content:center;height:100vh;' +
				'font-family:sans-serif;flex-direction:column;gap:16px;background:#f0f2f7;">' +
				'<div style="font-size:48px;">🔒</div>' +
				'<div style="font-size:18px;font-weight:700;color:#1e293b;">접근 권한이 없습니다.</div>' +
				'<div style="font-size:13px;color:#64748b;">관리자에게 권한 부여를 요청하세요.</div>' +
				'<button onclick="history.back()" ' +
				'style="margin-top:8px;padding:8px 20px;border:none;border-radius:8px;' +
				'background:#2563eb;color:#fff;font-size:13px;font-weight:700;cursor:pointer;">돌아가기</button>' +
				'</div>';
		}
	}, 'json').fail(function () {
		/* 서버 오류 시에는 그냥 통과 (서버 다운 등 예외 상황) */
	});
});

</script>
    
</body>
</html>