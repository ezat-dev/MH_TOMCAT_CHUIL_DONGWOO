<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<script src="/line/mock/mock-loader.js"></script>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>설비 가동률 분석</title>
<%@include file="../include/pluginpage.jsp"%>
<jsp:include page="../include/tabBar.jsp" />
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=IBM+Plex+Mono:wght@400;500&family=IBM+Plex+Sans+KR:wght@400;500;600&display=swap">
<link rel="stylesheet" href="/line/css/opsList/ops-list.css">
<style>
/* ===== 데모: 설비 가동률 분석 — 고밀도 운영 화면 (ops-list.css 공통 + 페이지 전용) ===== */
.er-kpi { grid-template-columns: 1.4fr repeat(3, 1fr); }
.er-kpi .kpi-unit, .er .u { font-family: var(--ops-sans); font-size: 13px; font-weight: 400; color: var(--ops-fg3); margin-left: 2px; }

.er-grid { display: grid; grid-template-columns: 1fr 400px; gap: 16px; align-items: stretch; }
.er-col > .ops-card:last-child { flex: 1; }
.er-col { display: flex; flex-direction: column; gap: 16px; min-width: 0; }
.er .card-body { padding: 12px 16px 16px; }

/* 상태 텍스트: 점 + 의미색 (배지 없음) — JS 가 badge-* 클래스를 붙임 */
.er .kpi-badge { display: inline-flex; align-items: center; gap: 6px; font-size: 12px; font-weight: 500; color: var(--ops-fg3); white-space: nowrap; }
.er .kpi-badge::before { content: ""; width: 6px; height: 6px; border-radius: 50%; background: var(--ops-line); }
.er .badge-good { color: var(--ops-ok); } .er .badge-good::before { background: var(--ops-ok); }
.er .badge-info { color: var(--ops-accent); } .er .badge-info::before { background: var(--ops-accent); }
.er .badge-warn { color: var(--ops-warn); } .er .badge-warn::before { background: var(--ops-warn); }
.er .badge-bad  { color: var(--ops-bad); }  .er .badge-bad::before  { background: var(--ops-bad); }
.er .kpi-badge.plain { color: var(--ops-fg3); } .er .kpi-badge.plain::before { display: none; }

/* 가동/비가동 막대 차트 */
#chart-container { height: 240px; }
.ops-card-head .mono { font-size: 12px; color: var(--ops-fg2); }

/* 가동률 게이지: 등급 경계 60 / 75 / 90% 눈금 */
.timeline-label-row { display: flex; justify-content: space-between; align-items: baseline; margin-bottom: 8px; font-family: var(--ops-mono); font-size: 12px; color: var(--ops-fg3); font-variant-numeric: tabular-nums; }
#bar-rate-label { font-size: 16px; font-weight: 500; color: var(--ops-fg); }
.timeline-bar { position: relative; height: 12px; border-radius: 2px; background: var(--ops-line2); }
.timeline-bar-fill { height: 100%; border-radius: 2px; background: var(--ops-ok); transition: width 300ms ease-out; }
.timeline-bar-fill span { display: none; }
.er-ticks { position: relative; height: 32px; margin-top: 4px; font-family: var(--ops-mono); font-size: 11px; color: var(--ops-fg3); }
.er-ticks i { position: absolute; top: -16px; width: 1px; height: 12px; background: var(--ops-fg3); }
.er-ticks span { position: absolute; top: 2px; transform: translateX(-50%); white-space: nowrap; }
.er-ticks span.g { top: 16px; font-family: var(--ops-sans); color: var(--ops-fg2); }
.er-legend { display: flex; gap: 24px; font-size: 12px; color: var(--ops-fg2); }
.er-legend .dot { display: inline-block; width: 6px; height: 6px; border-radius: 50%; margin-right: 6px; vertical-align: 1px; }
.er-legend strong { font-family: var(--ops-mono); font-weight: 500; color: var(--ops-fg); margin-left: 4px; font-variant-numeric: tabular-nums; }

/* 효율 등급: 큰 글자 + 설명 (원/배경색 없음) */
.er-grade { display: flex; align-items: center; gap: 16px; }
.grade-circle { font-family: var(--ops-mono); font-size: 40px; font-weight: 500; line-height: 1; width: 48px; text-align: center; color: var(--ops-fg3); }
.grade-circle.grade-A { color: var(--ops-ok); } .grade-circle.grade-B { color: var(--ops-accent); }
.grade-circle.grade-C { color: var(--ops-warn); } .grade-circle.grade-D { color: var(--ops-bad); }
.er-grade > div { display: flex; flex-direction: column; gap: 4px; border-left: 1px solid var(--ops-line2); padding-left: 16px; }
.grade-label { font-size: 13px; font-weight: 600; color: var(--ops-fg); }
.grade-desc { font-size: 12px; color: var(--ops-fg3); line-height: 1.5; white-space: pre-line; }
.er-scale { display: flex; gap: 12px; margin-top: 12px; padding-top: 12px; border-top: 1px solid var(--ops-line2); font-size: 12px; color: var(--ops-fg3); }
.er-scale b { font-family: var(--ops-mono); font-weight: 500; color: var(--ops-fg2); margin-right: 4px; }

/* 키-값 행 */
.detail-table { width: 100%; border-collapse: collapse; }
.detail-table tr { border-bottom: 1px solid var(--ops-line2); }
.detail-table tr:last-child { border-bottom: 0; }
.detail-table td { height: 36px; padding: 0; font-size: 13px; }
.detail-table td:first-child { color: var(--ops-fg2); }
.detail-table td:last-child { text-align: right; font-family: var(--ops-mono); font-weight: 500; color: var(--ops-fg); font-variant-numeric: tabular-nums; }
.detail-table td:last-child .u { font-size: 12px; }
.detail-table .kpi-badge { justify-content: flex-end; }

/* 화면 높이 꽉 채움: 본문 그리드가 남은 높이를 쓰고, 왼쪽은 분포 차트 카드가 늘어남 (페이지 스크롤 없음) */
body.er { height: 100vh; min-height: 0; display: flex; flex-direction: column; overflow: hidden; }
.er .ops-page { flex: 1; min-height: 0; }
.er .er-grid { flex: 1; min-height: 0; }
.er-grid > .er-col:first-child > .ops-card:first-child { flex: 1; min-height: 0; display: flex; flex-direction: column; }
.er-grid > .er-col:first-child > .ops-card:last-child { flex: none; }
.er-grid > .er-col:first-child > .ops-card:first-child > .card-body { flex: 1; min-height: 0; }
.er-grid > .er-col:first-child #chart-container { height: 100%; min-height: 200px; }
</style>
</head>
<body class="ops er">

<!-- ======================== 헤더 + 조회조건 ======================== -->
<header class="ops-head">
  <div class="ops-head-in">
    <h1 class="ops-title">설비 가동률 분석</h1>
    <span class="ops-label">조회일자</span>
    <input type="text" id="s_sdate" class="ops-input ctrl datetimeSet" placeholder="시작일시" style="min-width:156px"/>
    <span class="muted">~</span>
    <input type="text" id="s_edate" class="ops-input ctrl datetimeSet" placeholder="종료일시" style="min-width:156px"/>
    <span class="ops-label">설비명</span>
    <select id="equipment_name" class="ops-input ctrl" style="font-family:var(--ops-sans)">
      <option value="">전체</option>
      <option value="열처리 연속로">열처리 연속로</option>
    </select>
    <button class="ops-btn primary btn-search" type="button" onclick="loadOperationData()">조회</button>
  </div>
</header>

<!-- ======================== 본문 ======================== -->
<div class="ops-page">

  <!-- 지표 스트립: 가동률이 첫 시선 -->
  <div class="ops-kpi er-kpi">
    <div class="hero">
      <span class="kpi-label">가동률</span>
      <span class="kpi-value"><span id="kpi_rate">--</span><span class="kpi-unit">%</span></span>
      <span class="kpi-badge badge-info" id="badge_rate">산출 중</span>
    </div>
    <div>
      <span class="kpi-label">가동 시간</span>
      <span class="kpi-value"><span id="kpi_run">--</span><span class="kpi-unit">h</span></span>
      <span class="kpi-badge plain" id="badge_run">정상 가동</span>
    </div>
    <div>
      <span class="kpi-label">비가동 시간</span>
      <span class="kpi-value"><span id="kpi_down">--</span><span class="kpi-unit">h</span></span>
      <span class="kpi-badge plain" id="badge_down">비가동 발생</span>
    </div>
    <div>
      <span class="kpi-label">기준 시간</span>
      <span class="kpi-value"><span id="kpi_standard">--</span><span class="kpi-unit">h</span></span>
      <span class="kpi-badge plain">조회 기간 총 시간</span>
    </div>
  </div>

  <div class="er-grid">

    <!-- 왼쪽: 분포 막대 + 게이지 -->
    <div class="er-col">
      <section class="ops-card">
        <div class="ops-card-head">
          <h2>가동 / 비가동 분포</h2>
          <span class="note">기준 시간 대비 · <span id="chart-period-badge" class="mono"></span></span>
        </div>
        <div class="card-body"><div id="chart-container"></div></div>
      </section>

      <section class="ops-card">
        <div class="ops-card-head">
          <h2>가동률 게이지</h2><span class="note">눈금 = 등급 경계</span>
        </div>
        <div class="card-body">
          <div class="timeline-label-row">
            <span>0%</span>
            <span id="bar-rate-label">-- %</span>
            <span>100%</span>
          </div>
          <div class="timeline-bar">
            <div class="timeline-bar-fill" id="gauge-bar" style="width:0%"><span id="gauge-bar-label"></span></div>
          </div>
          <div class="er-ticks">
            <i style="left:60%"></i><i style="left:75%"></i><i style="left:90%"></i>
            <span style="left:60%">60</span><span style="left:75%">75</span><span style="left:90%">90</span>
            <span class="g" style="left:30%">D</span><span class="g" style="left:67.5%">C</span><span class="g" style="left:82.5%">B</span><span class="g" style="left:95%">A</span>
          </div>
          <div class="er-legend">
            <span><span class="dot" style="background:var(--ops-ok)"></span>가동<strong id="legend-run">--h</strong></span>
            <span><span class="dot" style="background:var(--ops-bad)"></span>비가동<strong id="legend-down">--h</strong></span>
          </div>
        </div>
      </section>
    </div>

    <!-- 오른쪽: 등급 · 상세 수치 · 운영 현황 -->
    <div class="er-col">
      <section class="ops-card">
        <div class="ops-card-head"><h2>효율 등급</h2></div>
        <div class="card-body">
          <div class="er-grade">
            <span class="grade-circle grade-A" id="grade-circle">--</span>
            <div>
              <span class="grade-label" id="grade-label">데이터 없음</span>
              <span class="grade-desc" id="grade-desc">조회 후 등급이 표시됩니다.</span>
            </div>
          </div>
          <div class="er-scale">
            <span><b>A</b>90% 이상</span><span><b>B</b>75% 이상</span><span><b>C</b>60% 이상</span><span><b>D</b>60% 미만</span>
          </div>
        </div>
      </section>

      <section class="ops-card">
        <div class="ops-card-head"><h2>상세 수치</h2></div>
        <div class="card-body" style="padding-top:4px; padding-bottom:4px;">
          <table class="detail-table">
            <tr><td>기준 시간</td><td><span id="dt_standard">--</span><span class="u">h</span></td></tr>
            <tr><td>가동 시간</td><td><span id="dt_run">--</span><span class="u">h</span></td></tr>
            <tr><td>비가동 시간</td><td><span id="dt_down">--</span><span class="u">h</span></td></tr>
            <tr><td>가동률</td><td><span id="dt_rate">--</span><span class="u">%</span></td></tr>
            <tr><td>비가동률</td><td><span id="dt_down_rate">--</span><span class="u">%</span></td></tr>
          </table>
        </div>
      </section>

      <section class="ops-card">
        <div class="ops-card-head"><h2>운영 현황 요약</h2></div>
        <div class="card-body" style="padding-top:4px; padding-bottom:4px;">
          <table class="detail-table">
            <tr><td>설비명</td><td id="summary-equip" style="font-family:var(--ops-sans)">-</td></tr>
            <tr><td>조회 기간</td><td id="summary-period" style="font-size:12px">-</td></tr>
            <tr><td>운영 상태</td><td><span class="kpi-badge badge-good" id="summary-status">-</span></td></tr>
          </table>
        </div>
      </section>
    </div>
  </div>

</div><!-- /ops-page -->

<script>
let now_page_code = "f04";

$(function() {
    let startDate = new Date();
    startDate.setHours(8, 0, 0, 0);
    let endDate = new Date();
    $("#s_sdate").val(formatDateTime(startDate));
    $("#s_edate").val(formatDateTime(endDate));
    loadOperationData();
});

function formatDateTime(date) {
    let y = date.getFullYear();
    let m = String(date.getMonth()+1).padStart(2,'0');
    let d = String(date.getDate()).padStart(2,'0');
    let h = String(date.getHours()).padStart(2,'0');
    let mi = String(date.getMinutes()).padStart(2,'0');
    return y+'-'+m+'-'+d+' '+h+':'+mi;
}

function loadOperationData() {
    let startDate = $("#s_sdate").val();
    let endDate   = $("#s_edate").val();
    let equipName = $("#equipment_name").val();

    if(!startDate || !endDate) {
        alert("조회 기간을 입력하세요.");
        return;
    }

    $.ajax({
        url: "/line/standard/operation/rate",
        type: "POST",
        dataType: "json",
        data: { startDate, endDate, equipment_name: equipName },
        success: function(result) {
            let standardHours = result.standardHours || 0;
            let downHours     = result.downHours || 0;
            let runHours      = Math.max(0, standardHours - downHours);
            let runRate       = standardHours > 0 ? (runHours / standardHours * 100) : 0;
            let downRate      = 100 - runRate;

            updateUI(standardHours, runHours, downHours, runRate, downRate, startDate, endDate, equipName);
            drawDonutChart(runHours, downHours, runRate);
        },
        error: function(xhr, status, error) {
            console.error("데이터 로드 실패:", error);
            alert("데이터를 불러오는데 실패했습니다.");
        }
    });
}

function updateUI(std, run, down, runRate, downRate, startDate, endDate, equipName) {
    let rStr = runRate.toFixed(1);
    let dStr = downRate.toFixed(1);

    // KPI
    $("#kpi_standard").text(std.toFixed(1));
    $("#kpi_run").text(run.toFixed(1));
    $("#kpi_down").text(down.toFixed(1));
    $("#kpi_rate").text(rStr);

    // 상세
    $("#dt_standard").text(std.toFixed(1));
    $("#dt_run").text(run.toFixed(1));
    $("#dt_down").text(down.toFixed(1));
    $("#dt_rate").text(rStr);
    $("#dt_down_rate").text(dStr);

    // 게이지 바
    $("#gauge-bar").css("width", rStr + "%");
    $("#gauge-bar-label").text(rStr + "%");
    $("#bar-rate-label").text(rStr + "%");
    $("#legend-run").text(run.toFixed(1) + "h");
    $("#legend-down").text(down.toFixed(1) + "h");

    // 기간 뱃지
    let s = startDate.substring(5,16);
    let e = endDate.substring(5,16);
    $("#chart-period-badge").text(s + " ~ " + e);

    // 요약
    $("#summary-equip").text(equipName || "전체");
    $("#summary-period").text(s + "~" + e);

    // 효율 등급
    let grade, gradeClass, gradeLabel, gradeDesc, badgeClass, statusText, statusClass;
    if(runRate >= 90) {
        grade = "A"; gradeClass = "grade-A";
        gradeLabel = "최우수 (A등급)";
        gradeDesc = "설비 가동률이 매우 우수합니다.\n정기 점검을 유지하세요.";
        badgeClass = "badge-good"; statusText = "최우수";
    } else if(runRate >= 75) {
        grade = "B"; gradeClass = "grade-B";
        gradeLabel = "양호 (B등급)";
        gradeDesc = "가동률이 양호한 수준입니다.\n소폭 개선이 가능합니다.";
        badgeClass = "badge-info"; statusText = "양호";
    } else if(runRate >= 60) {
        grade = "C"; gradeClass = "grade-C";
        gradeLabel = "주의 (C등급)";
        gradeDesc = "비가동 시간이 증가하고 있습니다.\n원인 분석이 필요합니다.";
        badgeClass = "badge-warn"; statusText = "주의";
    } else {
        grade = "D"; gradeClass = "grade-D";
        gradeLabel = "불량 (D등급)";
        gradeDesc = "가동률이 낮습니다.\n즉각적인 점검이 필요합니다.";
        badgeClass = "badge-bad"; statusText = "불량";
    }

    $("#grade-circle").text(grade)
      .removeClass("grade-A grade-B grade-C grade-D")
      .addClass(gradeClass);
    $("#grade-label").text(gradeLabel);
    $("#grade-desc").text(gradeDesc);

    // 뱃지 업데이트
    $("#badge_run").text("가동 " + run.toFixed(1) + "h");
    $("#badge_down").text("비가동 " + down.toFixed(1) + "h");
    $("#badge_rate").text("가동률 " + rStr + "%")
      .removeClass("badge-good badge-info badge-warn badge-bad")
      .addClass(badgeClass);

    $("#summary-status")
      .text(statusText)
      .removeClass("badge-good badge-info badge-warn badge-bad")
      .addClass(badgeClass);
}

// 데모: 도넛 → 가로 막대 (같은 데이터: 가동/비가동 시간과 기준 시간 대비 비율)
function drawDonutChart(run, down, runRate) {
    var total = run + down;
    Highcharts.chart('chart-container', {
        chart: {
            type: 'bar',
            height: null,
            spacing: [4, 8, 4, 0],
            style: { fontFamily: "'IBM Plex Sans KR', 'Malgun Gothic', sans-serif" },
            backgroundColor: 'transparent',
            animation: { duration: 150 }
        },
        title: { text: null },
        subtitle: { text: null },
        credits: { enabled: false },
        exporting: { enabled: false },
        legend: { enabled: false },
        xAxis: {
            categories: ['가동', '비가동'],
            lineColor: '#e3e7ee',
            tickLength: 0,
            labels: { style: { fontSize: '12px', color: '#4b5563' } }
        },
        yAxis: {
            min: 0,
            max: total > 0 ? total : 1,
            title: { text: null },
            gridLineColor: "#f0f2f5",
            tickPixelInterval: 160,
            labels: { format: '{value}h', style: { fontSize: '11px', color: '#9aa1ad', fontFamily: "'IBM Plex Mono', Consolas, monospace" } }
        },
        tooltip: {
            headerFormat: '',
            pointFormat: '<b>{point.category}</b><br>{point.y:.1f}시간 | {point.pct:.1f}%',
            backgroundColor: '#fff',
            borderColor: '#e3e7ee',
            borderRadius: 6,
            shadow: false,
            style: { fontSize: '12px' }
        },
        plotOptions: {
            bar: {
                borderWidth: 0,
                borderRadius: 2,
                pointWidth: 32,
                dataLabels: {
                    enabled: true,
                    format: '{point.y:.1f}h · {point.pct:.1f}%',
                    style: { fontSize: '12px', fontWeight: '500', color: '#374151', textOutline: 'none', fontFamily: "'IBM Plex Mono', Consolas, monospace" }
                }
            }
        },
        series: [{
            name: '시간',
            data: [
                { y: run,  pct: runRate,       color: '#4a9a63' },
                { y: down, pct: 100 - runRate, color: '#c4483f' }
            ]
        }]
    });
}
</script>

</body>
</html>
