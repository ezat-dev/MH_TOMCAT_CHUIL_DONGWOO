<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="ko">
<head>
<script src="/line/mock/mock-loader.js"></script>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>알람발생 빈도</title>
    <%@include file="../include/pluginpage.jsp" %>
    <jsp:include page="../include/tabBar.jsp"/>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@400;500;600;700;800&family=JetBrains+Mono:wght@400;600;700&display=swap" rel="stylesheet">
<style>
:root {
  --bg:       #f0f2f7;
  --surface:  #ffffff;
  --surface2: #f7f8fc;
  --border:   #e2e6ef;
  --text-p:   #0f172a;
  --text-s:   #64748b;
  --text-m:   #94a3b8;
  --red:      #dc2626;
  --red-lt:   #fee2e2;
  --orange:   #ea580c;
  --org-lt:   #ffedd5;
  --yellow:   #d97706;
  --yel-lt:   #fef3c7;
  --green:    #16a34a;
  --grn-lt:   #dcfce7;
  --accent:   #2563eb;
  --acc-lt:   #dbeafe;
  --shadow:   0 1px 3px rgba(0,0,0,.06);
  --shadow-md:0 4px 16px rgba(0,0,0,.08);
  --radius:   12px;
}

*{ box-sizing:border-box; margin:0; padding:0; }

body {
  font-family:'Noto Sans KR', sans-serif;
  background: var(--bg);
  color: var(--text-p);
  min-height: 100vh;
}

/* ===== TOPBAR ===== */
.topbar {
  position: sticky; top:0; z-index:100;
  background: rgba(255,255,255,.96);
  backdrop-filter: blur(12px);
  border-bottom: 1px solid var(--border);
  box-shadow: var(--shadow);
}
.topbar-inner {
  max-width:1600px; margin:0 auto;
  padding:0 24px; height:54px;
  display:flex; align-items:center; gap:10px;
}
.tb-title {
  font-size:14px; font-weight:800; color:var(--text-p);
  letter-spacing:-.3px; white-space:nowrap; margin-right:6px;
  display:flex; align-items:center; gap:7px;
}
.tb-title .icon {
  width:22px; height:22px; border-radius:7px;
  background: linear-gradient(135deg,#f97316,#dc2626);
  display:flex; align-items:center; justify-content:center;
  flex-shrink:0;
}
.tb-title .icon svg { width:12px; height:12px; stroke:#fff; }
.tb-div { width:1px; height:20px; background:var(--border); flex-shrink:0; }
.tb-label { font-size:12px; font-weight:700; color:var(--text-s); white-space:nowrap; }
.ctrl {
  height:32px; padding:0 10px;
  border:1px solid var(--border); border-radius:8px;
  background:var(--surface2); color:var(--text-p);
  font-size:13px; font-family:'Noto Sans KR',sans-serif;
  outline:none; transition:border-color .15s, box-shadow .15s;
  min-width:150px; text-align:center;
}
.ctrl:focus { border-color:var(--accent); box-shadow:0 0 0 3px rgba(37,99,235,.12); }
.tilde { color:var(--text-m); font-weight:800; font-size:14px; padding:0 2px; }
.btn {
  height:32px; padding:0 13px; border-radius:8px;
  font-size:12px; font-family:'Noto Sans KR',sans-serif; font-weight:700;
  display:inline-flex; align-items:center; gap:5px;
  cursor:pointer; transition:filter .15s, transform .08s;
  white-space:nowrap; border:1px solid transparent;
}
.btn:active { transform:translateY(1px); }
.btn svg { width:13px; height:13px; flex-shrink:0; }
.btn-search { background:linear-gradient(135deg,#64748b,#475569); color:#fff; border-color:#475569; box-shadow:0 2px 6px rgba(71,85,105,.3); }
.btn-excel  { background:linear-gradient(135deg,#16a34a,#15803d); color:#fff; border-color:#15803d; }
.btn:hover  { filter:brightness(1.08); }

/* ===== PAGE ===== */
.page {
  max-width:1600px; margin:0 auto;
  padding:16px 24px 28px;
  display:flex; flex-direction:column; gap:14px;
}

/* ===== KPI ===== */
.kpi-row {
  display:grid; grid-template-columns:repeat(4,1fr); gap:12px;
}
@media(max-width:900px){ .kpi-row{ grid-template-columns:repeat(2,1fr); } }

.kpi-card {
  background:var(--surface); border:1px solid var(--border);
  border-radius:var(--radius); padding:14px 18px;
  box-shadow:var(--shadow); display:flex; align-items:center; gap:14px;
  position:relative; overflow:hidden;
  animation:fadeUp .3s ease both;
}
.kpi-card::before {
  content:''; position:absolute; top:0; left:0; right:0; height:3px;
  border-radius:var(--radius) var(--radius) 0 0;
}
.kpi-card:nth-child(1){ animation-delay:.04s; }
.kpi-card:nth-child(2){ animation-delay:.08s; }
.kpi-card:nth-child(3){ animation-delay:.12s; }
.kpi-card:nth-child(4){ animation-delay:.16s; }
.kpi-card.k-total::before  { background:linear-gradient(90deg,#64748b,#94a3b8); }
.kpi-card.k-top::before    { background:linear-gradient(90deg,#dc2626,#f87171); }
.kpi-card.k-avg::before    { background:linear-gradient(90deg,#ea580c,#fb923c); }
.kpi-card.k-period::before { background:linear-gradient(90deg,#2563eb,#60a5fa); }

@keyframes fadeUp {
  from{ opacity:0; transform:translateY(10px); }
  to  { opacity:1; transform:none; }
}

.kpi-icon {
  width:38px; height:38px; border-radius:10px;
  display:flex; align-items:center; justify-content:center; flex-shrink:0;
}
.kpi-icon svg { width:18px; height:18px; }
.k-total  .kpi-icon { background:#f1f5f9; color:#64748b; }
.k-top    .kpi-icon { background:var(--red-lt); color:var(--red); }
.k-avg    .kpi-icon { background:var(--org-lt); color:var(--orange); }
.k-period .kpi-icon { background:var(--acc-lt); color:var(--accent); }
.kpi-info { display:flex; flex-direction:column; gap:2px; }
.kpi-label{ font-size:11px; font-weight:700; color:var(--text-m); text-transform:uppercase; letter-spacing:.5px; }
.kpi-value{ font-size:26px; font-weight:800; font-family:'JetBrains Mono',monospace; color:var(--text-p); line-height:1; letter-spacing:-1px; }
.kpi-sub  { font-size:11px; color:var(--text-m); margin-top:2px; }

/* ===== MAIN CARD ===== */
.main-card {
  background:var(--surface); border:1px solid var(--border);
  border-radius:var(--radius); box-shadow:var(--shadow);
  overflow:hidden;
  animation:fadeUp .35s .2s ease both;
  display:flex; flex-direction:column;
}
.card-head {
  padding:14px 20px; border-bottom:1px solid var(--border);
  display:flex; align-items:center; justify-content:space-between; gap:12px; flex-wrap:wrap;
}
.card-head-title { font-size:13px; font-weight:800; color:var(--text-p); }
.head-right { display:flex; align-items:center; gap:8px; }
.search-input {
  height:30px; padding:0 10px 0 30px;
  border:1px solid var(--border); border-radius:8px;
  background:var(--surface2); color:var(--text-p);
  font-size:12px; font-family:'Noto Sans KR',sans-serif;
  outline:none; transition:border-color .15s, box-shadow .15s; width:180px;
  background-image:url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='14' height='14' viewBox='0 0 24 24' fill='none' stroke='%2394a3b8' stroke-width='2.5' stroke-linecap='round' stroke-linejoin='round'%3E%3Ccircle cx='11' cy='11' r='8'/%3E%3Cline x1='21' y1='21' x2='16.65' y2='16.65'/%3E%3C/svg%3E");
  background-repeat:no-repeat; background-position:9px center;
}
.search-input:focus { border-color:var(--accent); box-shadow:0 0 0 3px rgba(37,99,235,.12); }

/* ===== TABLE ===== */
.table-wrap { overflow-y:auto; max-height:580px; }

table { width:100%; border-collapse:collapse; font-size:13px; }
thead tr { position:sticky; top:0; z-index:2; }
thead th {
  text-align:center; padding:10px 12px;
  background:var(--surface2); border-bottom:2px solid var(--border);
  font-size:11px; font-weight:800; color:var(--text-s);
  letter-spacing:.4px; text-transform:uppercase; white-space:nowrap;
  user-select:none;
}
thead th.th-left { text-align:left; padding-left:16px; }

tbody tr {
  border-bottom:1px solid var(--border);
  transition:background .1s;
  animation:rowIn .25s ease both;
}
tbody tr:hover { background:#f8faff; cursor:pointer; }

@keyframes rowIn {
  from{ opacity:0; transform:translateX(-6px); }
  to  { opacity:1; transform:none; }
}

tbody td { padding:10px 12px; color:var(--text-p); vertical-align:middle; }
tbody td.td-center { text-align:center; }
tbody td.td-left   { text-align:left; }

/* 순위 뱃지 */
.rank-badge {
  display:inline-flex; align-items:center; justify-content:center;
  width:26px; height:26px; border-radius:50%;
  font-size:12px; font-weight:800; font-family:'JetBrains Mono',monospace;
}
.rank-1 { background:linear-gradient(135deg,#fbbf24,#f59e0b); color:#fff; box-shadow:0 2px 6px rgba(245,158,11,.4); }
.rank-2 { background:linear-gradient(135deg,#94a3b8,#64748b); color:#fff; }
.rank-3 { background:linear-gradient(135deg,#fb923c,#ea580c); color:#fff; }
.rank-n { background:var(--surface2); color:var(--text-m); border:1px solid var(--border); }

/* PLC 주소 */
.addr-tag {
  display:inline-block; padding:2px 8px; border-radius:5px;
  background:var(--surface2); border:1px solid var(--border);
  font-family:'JetBrains Mono',monospace; font-size:11px; font-weight:600; color:var(--text-s);
}

/* 알람 내용 */
.desc-text { font-size:13px; font-weight:500; color:var(--text-p); }

/* 발생 수 셀 */
.cnt-cell { display:flex; align-items:center; gap:10px; justify-content:flex-end; padding-right:20px; }
.cnt-bar-wrap { flex:1; max-width:160px; height:6px; background:var(--border); border-radius:3px; overflow:hidden; }
.cnt-bar { height:100%; border-radius:3px; transition:width .6s cubic-bezier(.4,0,.2,1); }
.cnt-val {
  font-family:'JetBrains Mono',monospace; font-size:14px; font-weight:800;
  min-width:36px; text-align:right;
}

/* 발생 수 색상 (상위→하위) */
.bar-1 { background:linear-gradient(90deg,#dc2626,#f87171); }
.bar-2 { background:linear-gradient(90deg,#ea580c,#fb923c); }
.bar-3 { background:linear-gradient(90deg,#d97706,#fbbf24); }
.bar-n { background:linear-gradient(90deg,#2563eb,#60a5fa); }
.val-1 { color:var(--red); }
.val-2 { color:var(--orange); }
.val-3 { color:var(--yellow); }
.val-n { color:var(--accent); }

/* 푸터 */
.card-foot {
  padding:8px 16px; border-top:1px solid var(--border);
  background:var(--surface2);
  display:flex; align-items:center; justify-content:space-between;
  font-size:12px; color:var(--text-m);
}
.card-foot strong { color:var(--text-p); font-family:'JetBrains Mono',monospace; }

/* 빈 데이터 */
.empty-row td {
  padding:40px; text-align:center;
  color:var(--text-m); font-size:13px;
}
</style>
</head>
<body>

<!-- TOPBAR -->
<div class="topbar">
  <div class="topbar-inner">
    <div class="tb-title">
      <span class="icon">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
          <path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/>
          <line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/>
        </svg>
      </span>
      알람 발생 빈도
    </div>
    <div class="tb-div"></div>
    <span class="tb-label">조회일자</span>
    <input type="text" id="s_sdate" class="ctrl dayselect daySet" placeholder="시작일"/>
    <span class="tilde">~</span>
    <input type="text" id="s_edate" class="ctrl dayselect daySet" placeholder="종료일"/>
    <div class="tb-div"></div>
    <button class="btn btn-search select-button">
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
        <circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/>
      </svg>조회
    </button>
    <button class="btn btn-excel excel-button">
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
        <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/>
        <line x1="12" y1="12" x2="12" y2="18"/><line x1="9" y1="15" x2="15" y2="15"/>
      </svg>Download
    </button>
  </div>
</div>

<!-- PAGE -->
<div class="page">

  <!-- KPI 카드 -->
  <div class="kpi-row">
    <div class="kpi-card k-total">
      <div class="kpi-icon">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <line x1="8" y1="6" x2="21" y2="6"/><line x1="8" y1="12" x2="21" y2="12"/><line x1="8" y1="18" x2="21" y2="18"/>
          <line x1="3" y1="6" x2="3.01" y2="6"/><line x1="3" y1="12" x2="3.01" y2="12"/><line x1="3" y1="18" x2="3.01" y2="18"/>
        </svg>
      </div>
      <div class="kpi-info">
        <div class="kpi-label">알람 종류</div>
        <div class="kpi-value" id="kpi-total">0</div>
        <div class="kpi-sub">고유 알람 수</div>
      </div>
    </div>
    <div class="kpi-card k-top">
      <div class="kpi-icon">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/>
        </svg>
      </div>
      <div class="kpi-info">
        <div class="kpi-label">최다 발생</div>
        <div class="kpi-value" id="kpi-top">0</div>
        <div class="kpi-sub" id="kpi-top-sub">1위 발생 횟수</div>
      </div>
    </div>
    <div class="kpi-card k-avg">
      <div class="kpi-icon">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <line x1="18" y1="20" x2="18" y2="10"/><line x1="12" y1="20" x2="12" y2="4"/>
          <line x1="6" y1="20" x2="6" y2="14"/><line x1="2" y1="20" x2="22" y2="20"/>
        </svg>
      </div>
      <div class="kpi-info">
        <div class="kpi-label">총 발생 수</div>
        <div class="kpi-value" id="kpi-sum">0</div>
        <div class="kpi-sub">전체 알람 합계</div>
      </div>
    </div>
    <div class="kpi-card k-period">
      <div class="kpi-icon">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <rect x="3" y="4" width="18" height="18" rx="2" ry="2"/>
          <line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/>
        </svg>
      </div>
      <div class="kpi-info">
        <div class="kpi-label">조회 기간</div>
        <div class="kpi-value" style="font-size:14px; margin-top:3px;" id="kpi-period">-</div>
        <div class="kpi-sub" id="kpi-period-sub">-</div>
      </div>
    </div>
  </div>

  <!-- 메인 테이블 카드 -->
  <div class="main-card">
    <div class="card-head">
      <span class="card-head-title">알람 발생 랭킹</span>
      <div class="head-right">
        <input type="text" class="search-input" id="tableSearch" placeholder="알람 내용 검색...">
      </div>
    </div>

    <div class="table-wrap">
      <table id="tableAlarm">
        <thead>
          <tr>
            <th style="width:60px;">순위</th>
            <th style="width:130px;">PLC 주소</th>
            <th class="th-left">알람 내용</th>
            <th style="width:260px; text-align:right; padding-right:20px;">발생 횟수</th>
          </tr>
        </thead>
        <tbody id="alarmTbody">
          <tr class="empty-row"><td colspan="4">조회 버튼을 눌러 데이터를 불러오세요</td></tr>
        </tbody>
      </table>
    </div>

    <div class="card-foot">
      <span id="footer-info">데이터를 조회하세요</span>
      <span>마지막 조회: <strong id="footer-time">-</strong></span>
    </div>
  </div>

</div>

<!-- 엑셀 로딩 오버레이 -->
<div id="excelOverlay" style="display:none;position:fixed;inset:0;background:rgba(0,0,0,.5);z-index:9998;"></div>
<div id="excelLoading" style="display:none;position:fixed;top:50%;left:50%;transform:translate(-50%,-50%);background:#fff;padding:30px 50px;border-radius:12px;box-shadow:0 8px 30px rgba(0,0,0,.2);z-index:9999;font-size:15px;font-weight:700;text-align:center;">엑셀 생성 중...</div>

<script>
let now_page_code = "b03";
var allData = [];

document.addEventListener("DOMContentLoaded", function () {
  // ✅ 올해 1/1 08:00 ~ 현재로 기본 세팅
  const now = new Date();
  const start = new Date(now.getFullYear(), 0, 1, 8, 0, 0, 0);
  const end = now;

  const sEl = document.getElementById("s_sdate");
  const eEl = document.getElementById("s_edate");
  if (sEl) sEl.value = formatDateTime(start);
  if (eEl) eEl.value = formatDateTime(end);

  // 버튼 이벤트 (jQuery 없이)
  const btnSelect = document.querySelector(".select-button");
  const btnExcel  = document.querySelector(".excel-button");
  if (btnSelect) btnSelect.addEventListener("click", fetchAlarm);
  if (btnExcel)  btnExcel.addEventListener("click", downloadExcel);

  // 실시간 검색 (jQuery 없이)
  const searchEl = document.getElementById("tableSearch");
  if (searchEl) {
    searchEl.addEventListener("keyup", function () {
      const kw = (searchEl.value || "").toLowerCase().trim();
      if (!kw) {
        renderTable(allData);
        updateFooter();
        return;
      }
      const filtered = (allData || []).filter(function (r) {
        const desc = (r.a_desc || "").toLowerCase();
        const addr = (r.a_addr || "").toLowerCase();
        return desc.indexOf(kw) > -1 || addr.indexOf(kw) > -1;
      });
      renderTable(filtered);
      const footerInfo = document.getElementById("footer-info");
      if (footerInfo) footerInfo.innerHTML = '총 <strong>' + filtered.length + "</strong>건 표시 중";
    });
  }

  fetchAlarm();
});

function pad2(n) { return String(n).padStart(2, "0"); }

// YYYY-MM-DD HH:mm
function formatDateTime(date) {
  const y  = date.getFullYear();
  const m  = pad2(date.getMonth() + 1);
  const d  = pad2(date.getDate());
  const h  = pad2(date.getHours());
  const mi = pad2(date.getMinutes());
  return y + "-" + m + "-" + d + " " + h + ":" + mi;
}

function fetchAlarm() {
  const sVal = document.getElementById("s_sdate")?.value || "";
  const eVal = document.getElementById("s_edate")?.value || "";

  // ✅ 기존과 동일하게 POST 폼 방식으로 전송 (Content-Type 자동)
  $.ajax({
    url: "/line/productionManagement/alarmRanking/list",
    method: "POST",
    dataType: "json",
    data: { s_sdate: sVal, s_edate: eVal },
    success: function (resp) {
      var arr = Array.isArray(resp) ? resp : (resp.data || resp.rows || (resp ? [resp] : []));
      allData = arr || [];
      renderTable(allData);
      updateKpi();
      updateFooter();
    },
    error: function (xhr) {
      console.error("fetchAlarm error", xhr);
    }
  });
}

function getRankClass(idx) {
  if (idx === 0) return "rank-1";
  if (idx === 1) return "rank-2";
  if (idx === 2) return "rank-3";
  return "rank-n";
}
function getBarClass(idx) {
  if (idx === 0) return "bar-1";
  if (idx === 1) return "bar-2";
  if (idx === 2) return "bar-3";
  return "bar-n";
}
function getValClass(idx) {
  if (idx === 0) return "val-1";
  if (idx === 1) return "val-2";
  if (idx === 2) return "val-3";
  return "val-n";
}

function renderTable(data) {
  var tbody = document.getElementById("alarmTbody");
  if (!tbody) return;
  tbody.innerHTML = "";

  if (!data || data.length === 0) {
    tbody.innerHTML = '<tr class="empty-row"><td colspan="4">조회된 데이터가 없습니다.</td></tr>';
    return;
  }

  // 최대값 (바 너비 계산용)
  var maxCnt = 0;
  for (var i = 0; i < data.length; i++) {
    var c = Number(data[i].cnt) || 0;
    if (c > maxCnt) maxCnt = c;
  }

  data.forEach(function (r, i) {
    var cnt = Number(r.cnt) || 0;
    var barWidth = maxCnt > 0 ? Math.round((cnt / maxCnt) * 100) : 0;

    var rankCls = getRankClass(i);
    var barCls  = getBarClass(i);
    var valCls  = getValClass(i);
    var animDelay = Math.min(i * 0.03, 0.5);

    var tr = document.createElement("tr");
    tr.style.animationDelay = animDelay + "s";

    // td 1
    var td1 = document.createElement("td");
    td1.className = "td-center";
    td1.innerHTML = '<span class="rank-badge ' + rankCls + '">' + (i + 1) + "</span>";
    tr.appendChild(td1);

    // td 2
    var td2 = document.createElement("td");
    td2.className = "td-center";
    td2.innerHTML = '<span class="addr-tag">' + (r.a_addr || "-") + "</span>";
    tr.appendChild(td2);

    // td 3
    var td3 = document.createElement("td");
    td3.className = "td-left";
    td3.innerHTML = '<span class="desc-text">' + (r.a_desc || "") + "</span>";
    tr.appendChild(td3);

    // td 4
    var td4 = document.createElement("td");
    td4.innerHTML =
      '<div class="cnt-cell">' +
        '<div class="cnt-bar-wrap">' +
          '<div class="cnt-bar ' + barCls + '" style="width:0%" data-w="' + barWidth + '%"></div>' +
        "</div>" +
        '<span class="cnt-val ' + valCls + '">' + cnt.toLocaleString() + "</span>" +
      "</div>";
    tr.appendChild(td4);

    tbody.appendChild(tr);
  });

  // 바 애니메이션 (렌더 후 width 적용) - jQuery 없이
  setTimeout(function () {
    var bars = tbody.querySelectorAll(".cnt-bar");
    bars.forEach(function (el) {
      el.style.width = el.getAttribute("data-w") || "0%";
    });
  }, 60);
}

function updateKpi() {
  var total = (allData || []).length;
  var sum = (allData || []).reduce(function (acc, r) {
    return acc + (Number(r.cnt) || 0);
  }, 0);

  var top = total ? (Number(allData[0].cnt) || 0) : 0;
  var topAddr = total ? (allData[0].a_addr || "-") : "-";

  var elTotal = document.getElementById("kpi-total");
  var elTop   = document.getElementById("kpi-top");
  var elTopS  = document.getElementById("kpi-top-sub");
  var elSum   = document.getElementById("kpi-sum");

  if (elTotal) elTotal.textContent = total.toLocaleString();
  if (elTop)   elTop.textContent   = top.toLocaleString();
  if (elTopS)  elTopS.textContent  = "1위: " + topAddr;
  if (elSum)   elSum.textContent   = sum.toLocaleString();

  var s = document.getElementById("s_sdate")?.value || "-";
  var e = document.getElementById("s_edate")?.value || "-";

  var elP  = document.getElementById("kpi-period");
  var elPS = document.getElementById("kpi-period-sub");
  if (elP)  elP.textContent  = s.substring(0, 10);
  if (elPS) elPS.textContent = "~ " + e.substring(0, 10);
}

function updateFooter() {
  var now = new Date();
  var hh = pad2(now.getHours());
  var mm = pad2(now.getMinutes());
  var ss = pad2(now.getSeconds());

  var ft = document.getElementById("footer-time");
  var fi = document.getElementById("footer-info");
  if (ft) ft.textContent = hh + ":" + mm + ":" + ss;
  if (fi) fi.innerHTML = '총 <strong>' + (allData ? allData.length : 0) + "</strong>건";
}

function downloadExcel() {
  if (!allData || allData.length === 0) {
    alert("다운로드할 데이터가 없습니다.");
    return;
  }

  $("#excelOverlay").show();
  $("#excelLoading").show();

  try {
    var excelData = allData.map(function (r, i) {
      return {
        "순위": i + 1,
        "No": r.idx || "",
        "PLC주소": r.a_addr || "",
        "알람내용": r.a_desc || "",
        "발생 수": r.cnt || ""
      };
    });

    var ws = XLSX.utils.json_to_sheet(excelData);
    ws["!cols"] = [{ wch: 6 }, { wch: 8 }, { wch: 15 }, { wch: 50 }, { wch: 12 }];

    var wb = XLSX.utils.book_new();
    XLSX.utils.book_append_sheet(wb, ws, "알람랭킹");

    var sdate = (document.getElementById("s_sdate")?.value || "").replace(/-/g, "");
    var edate = (document.getElementById("s_edate")?.value || "").replace(/-/g, "");

    XLSX.writeFile(wb, "알람랭킹_" + sdate + "_" + edate + ".xlsx");
    setTimeout(function () {
      $("#excelOverlay").hide();
      $("#excelLoading").hide();
    }, 500);
  } catch (e) {
    console.error(e);
    alert("엑셀 다운로드에 실패했습니다.");
    $("#excelOverlay").hide();
    $("#excelLoading").hide();
  }
}
</script>
</body>
</html>
