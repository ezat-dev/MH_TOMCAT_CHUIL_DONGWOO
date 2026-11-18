<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<script src="/line/mock/mock-loader.js"></script>

<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>로그인 이력</title>
<%@include file="../include/pluginpage.jsp" %>
<%-- [demo] jQuery 중복 로드 제거 (pluginpage.jsp에서 이미 로드, 재로드 시 datepicker 플러그인 소실)
<script src="/vendor/jquery/3.7.1/jquery.min.js"></script> --%>

<!-- Tabulator -->
<link href="/vendor/tabulator/5.6.1/tabulator.min.css" rel="stylesheet">
<script src="/vendor/tabulator/5.6.1/tabulator.min.js"></script>

<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=IBM+Plex+Mono:wght@400;500&family=IBM+Plex+Sans+KR:wght@400;500;600&display=swap">
<link rel="stylesheet" href="/line/css/opsList/ops-list.css">
<link rel="stylesheet" href="/line/css/opsList/ops-user.css">

</head>

<body class="ops fit">

<header class="ops-head">
  <div class="ops-head-in">
    <h1 class="ops-title">로그인 이력</h1>
    <span class="ops-label">최신순 · 페이지당 20/50/100건</span>
  </div>
</header>

<main class="ops-page">

  <section class="ops-kpi k4" aria-label="요약">
    <div class="hero">
      <span class="kpi-label">오늘 로그인</span>
      <span class="kpi-value" id="kpi-today">-</span>
      <span class="kpi-sub" id="kpi-today-sub">&nbsp;</span>
    </div>
    <div>
      <span class="kpi-label">전체 이력</span>
      <span class="kpi-value" id="kpi-total">-</span>
      <span class="kpi-sub">누적 로그인 건수</span>
    </div>
    <div>
      <span class="kpi-label">오늘 접속 사용자</span>
      <span class="kpi-value" id="kpi-users">-</span>
      <span class="kpi-sub">고유 ID 수</span>
    </div>
    <div>
      <span class="kpi-label">최근 로그인</span>
      <span class="kpi-value" id="kpi-last">-</span>
      <span class="kpi-sub" id="kpi-last-sub">&nbsp;</span>
    </div>
  </section>

  <section class="ops-card grow">
    <div class="ops-card-head">
      <h2>로그인 기록</h2>
      <span class="note">열 머리를 눌러 정렬</span>
    </div>
    <div id="loginLogTable" class="ops-table"></div>
  </section>

</main>

<script>

let now_page_code = "a06";

// 데모: 상단 요약 (표시 전용)
function renderLoginSummary(rows) {
    rows = Array.isArray(rows) ? rows : [];
    var t = new Date(), p = function (n) { return String(n).padStart(2, "0"); };
    var today = t.getFullYear() + "-" + p(t.getMonth() + 1) + "-" + p(t.getDate());
    var todayRows = rows.filter(function (r) { return String(r.login_dt || "").indexOf(today) === 0; });
    var ids = {}, last = null;
    todayRows.forEach(function (r) { ids[r.user_id] = 1; });
    rows.forEach(function (r) { if (!last || String(r.login_dt) > String(last.login_dt)) last = r; });
    $("#kpi-today").text(todayRows.length);
    $("#kpi-today-sub").text(today);
    $("#kpi-total").text(rows.length);
    $("#kpi-users").text(Object.keys(ids).length);
    $("#kpi-last").text(last ? String(last.login_dt).substr(11, 5) : "-");
    $("#kpi-last-sub").text(last ? (last.user_name || "-") + " · " + String(last.login_dt).substr(0, 10) : " ");
}

$(function(){

    new Tabulator("#loginLogTable", {
        height: "100%",
        layout: "fitColumns",
        ajaxURL: "/line/user/login/log/list", // 컨트롤러 URL
        ajaxConfig: "POST",
        ajaxResponse:function(url, params, response){
            renderLoginSummary(response.data);
            return response.data; // { data : [...] } 구조 기준
        },
        pagination: "local",
        paginationSize: 20,
        paginationSizeSelector:[20,50,100],
        locale: "ko",
        langs: { ko: { pagination: { page_size: "페이지당", first: "처음", first_title: "처음", last: "끝", last_title: "끝", prev: "이전", prev_title: "이전", next: "다음", next_title: "다음" } } },
        initialSort:[
            {column:"login_dt", dir:"desc"}
        ],
        columns:[
            {title:"#", formatter:"rownum", width:70, headerSort:false, hozAlign:"right", headerHozAlign:"right", cssClass:"c-mono"},
            {
                title:"ID",
                field:"user_id",
                width:140,
                cssClass:"c-mono c-strong",
                formatter:function(cell, formatterParams, onRendered){
                    return cell.getValue() === "q" ? "EZ_ADMIN" : cell.getValue();
                }
            },
            {title:"이름", field:"user_name", width:120, cssClass:"c-strong"},
            {title:"부서", field:"user_busu", width:120},
            {title:"직급", field:"user_jick", width:120},
            {
                title:"로그인 시간",
                field:"login_dt",
                width:180,
                hozAlign:"left",
                cssClass:"c-mono"
            },
            {title:"메모", field:"memo", widthGrow:1}
        ],
    });

});
</script>

</body>
</html>
