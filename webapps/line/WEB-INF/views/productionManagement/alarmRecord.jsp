<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="ko">
<head>
<script src="/line/mock/mock-loader.js"></script>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>알람이력</title>
    <%@include file="../include/pluginpage.jsp" %>    
    <jsp:include page="../include/tabBar.jsp"/>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@400;500;600;700;800&family=JetBrains+Mono:wght@400;600&display=swap" rel="stylesheet">
<style>
:root {
  --bg:        #f0f2f7;
  --surface:   #ffffff;
  --surface2:  #f7f8fc;
  --border:    #e2e6ef;
  --text-p:    #0f172a;
  --text-s:    #64748b;
  --text-m:    #94a3b8;
  --red:       #dc2626;
  --red-light: #fee2e2;
  --red-mid:   #fca5a5;
  --yellow:    #d97706;
  --yel-light: #fef3c7;
  --green:     #16a34a;
  --grn-light: #dcfce7;
  --accent:    #2563eb;
  --shadow-sm: 0 1px 3px rgba(0,0,0,.06);
  --shadow-md: 0 4px 16px rgba(0,0,0,.08);
  --radius:    12px;
}

* { box-sizing: border-box; margin: 0; padding: 0; }

body {
  font-family: 'Noto Sans KR', sans-serif;
  background: var(--bg);
  color: var(--text-p);
  min-height: 100vh;
}

/* ===================== TOPBAR ===================== */
.topbar {
  position: sticky; top: 0; z-index: 100;
  background: rgba(255,255,255,.96);
  backdrop-filter: blur(12px);
  border-bottom: 1px solid var(--border);
  box-shadow: var(--shadow-sm);
}
.topbar-inner {
  max-width: 1600px; margin: 0 auto;
  padding: 0 24px;
  height: 54px;
  display: flex; align-items: center; gap: 10px;
}
.topbar-title {
  font-size: 14px; font-weight: 800;
  color: var(--text-p); letter-spacing: -.3px;
  white-space: nowrap; margin-right: 6px;
  display: flex; align-items: center; gap: 7px;
}
.topbar-title .blink-dot {
  width: 7px; height: 7px; border-radius: 50%;
  background: var(--red);
  animation: blink 1.4s ease-in-out infinite;
  flex-shrink: 0;
}
@keyframes blink {
  0%,100% { opacity: 1; box-shadow: 0 0 0 3px rgba(220,38,38,.15); }
  50%      { opacity: .4; box-shadow: none; }
}
.tb-divider { width: 1px; height: 20px; background: var(--border); flex-shrink: 0; }
.tb-label { font-size: 12px; font-weight: 700; color: var(--text-s); white-space: nowrap; }
.ctrl {
  height: 32px; padding: 0 10px;
  border: 1px solid var(--border); border-radius: 8px;
  background: var(--surface2); color: var(--text-p);
  font-size: 13px; font-family: 'Noto Sans KR', sans-serif;
  outline: none; transition: border-color .15s, box-shadow .15s;
  min-width: 155px; text-align: center;
}
.ctrl:focus { border-color: var(--accent); box-shadow: 0 0 0 3px rgba(37,99,235,.12); }
.tilde { color: var(--text-m); font-weight: 800; padding: 0 3px; font-size: 14px; }

/* 버튼 */
.btn {
  height: 32px; padding: 0 13px; border-radius: 8px;
  font-size: 12px; font-family: 'Noto Sans KR', sans-serif; font-weight: 700;
  display: inline-flex; align-items: center; gap: 5px;
  cursor: pointer; transition: filter .15s, transform .08s;
  white-space: nowrap; border: 1px solid transparent;
}
.btn:active { transform: translateY(1px); }
.btn svg { width: 13px; height: 13px; flex-shrink: 0; }
.btn-search { background: linear-gradient(135deg,#64748b,#475569); color:#fff; border-color:#475569; box-shadow:0 2px 6px rgba(71,85,105,.3); }
.btn-excel  { background: linear-gradient(135deg,#16a34a,#15803d); color:#fff; border-color:#15803d; }
.btn:hover  { filter: brightness(1.08); }

/* ===================== 페이지 ===================== */
.page-wrap {
  max-width: 1600px; margin: 0 auto;
  padding: 16px 24px 28px;
  display: flex; flex-direction: column; gap: 14px;
}

/* ===================== KPI 배너 ===================== */
.kpi-row {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 12px;
}
@media (max-width: 900px) { .kpi-row { grid-template-columns: repeat(2,1fr); } }

.kpi-card {
  background: var(--surface);
  border: 1px solid var(--border);
  border-radius: var(--radius);
  padding: 14px 18px;
  box-shadow: var(--shadow-sm);
  display: flex; align-items: center; gap: 14px;
  position: relative; overflow: hidden;
  animation: fadeUp .3s ease both;
}
.kpi-card::before {
  content: ''; position: absolute;
  top: 0; left: 0; right: 0; height: 3px;
  border-radius: var(--radius) var(--radius) 0 0;
}
.kpi-card.kpi-total::before  { background: linear-gradient(90deg,#64748b,#94a3b8); }
.kpi-card.kpi-active::before { background: linear-gradient(90deg,#dc2626,#f87171); }
.kpi-card.kpi-clear::before  { background: linear-gradient(90deg,#16a34a,#4ade80); }
.kpi-card.kpi-today::before  { background: linear-gradient(90deg,#2563eb,#60a5fa); }

.kpi-card:nth-child(1) { animation-delay:.04s; }
.kpi-card:nth-child(2) { animation-delay:.08s; }
.kpi-card:nth-child(3) { animation-delay:.12s; }
.kpi-card:nth-child(4) { animation-delay:.16s; }

@keyframes fadeUp {
  from { opacity:0; transform:translateY(10px); }
  to   { opacity:1; transform:none; }
}

.kpi-icon {
  width: 38px; height: 38px; border-radius: 10px;
  display: flex; align-items: center; justify-content: center;
  flex-shrink: 0;
}
.kpi-icon svg { width: 18px; height: 18px; }
.kpi-card.kpi-total  .kpi-icon { background:#f1f5f9; color:#64748b; }
.kpi-card.kpi-active .kpi-icon { background:var(--red-light); color:var(--red); }
.kpi-card.kpi-clear  .kpi-icon { background:var(--grn-light); color:var(--green); }
.kpi-card.kpi-today  .kpi-icon { background:#dbeafe; color:var(--accent); }

.kpi-info { display: flex; flex-direction: column; gap: 2px; }
.kpi-label { font-size: 11px; font-weight: 700; color: var(--text-m); text-transform: uppercase; letter-spacing: .5px; }
.kpi-value { font-size: 26px; font-weight: 800; font-family: 'JetBrains Mono', monospace; color: var(--text-p); line-height: 1; letter-spacing: -1px; }
.kpi-sub   { font-size: 11px; color: var(--text-m); margin-top: 2px; }

/* ===================== 메인 카드 ===================== */
.main-card {
  background: var(--surface);
  border: 1px solid var(--border);
  border-radius: var(--radius);
  box-shadow: var(--shadow-sm);
  overflow: hidden;
  animation: fadeUp .35s .2s ease both;
}
.main-card-header {
  padding: 14px 20px;
  border-bottom: 1px solid var(--border);
  display: flex; align-items: center; justify-content: space-between; gap: 12px;
  flex-wrap: wrap;
}
.main-card-title {
  font-size: 13px; font-weight: 800; color: var(--text-p); letter-spacing: -.2px;
}
.header-right {
  display: flex; align-items: center; gap: 8px;
}

/* 검색 인풋 */
.search-input {
  height: 30px; padding: 0 10px 0 30px;
  border: 1px solid var(--border); border-radius: 8px;
  background: var(--surface2); color: var(--text-p);
  font-size: 12px; font-family: 'Noto Sans KR', sans-serif;
  outline: none; transition: border-color .15s, box-shadow .15s;
  width: 180px;
  background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='14' height='14' viewBox='0 0 24 24' fill='none' stroke='%2394a3b8' stroke-width='2.5' stroke-linecap='round' stroke-linejoin='round'%3E%3Ccircle cx='11' cy='11' r='8'/%3E%3Cline x1='21' y1='21' x2='16.65' y2='16.65'/%3E%3C/svg%3E");
  background-repeat: no-repeat;
  background-position: 9px center;
}
.search-input:focus { border-color: var(--accent); box-shadow: 0 0 0 3px rgba(37,99,235,.12); }

/* 상태 필터 칩 */
.filter-chip {
  height: 26px; padding: 0 11px; border-radius: 20px;
  font-size: 11px; font-weight: 700; border: 1.5px solid var(--border);
  background: var(--surface); color: var(--text-s);
  cursor: pointer; transition: all .15s; white-space: nowrap;
}
.filter-chip.active-all    { background:#475569; border-color:#475569; color:#fff; }
.filter-chip.active-alarm  { background:var(--red); border-color:var(--red); color:#fff; }
.filter-chip.active-clear  { background:var(--green); border-color:var(--green); color:#fff; }

/* count badge */
.count-badge {
  display: inline-flex; align-items: center; justify-content: center;
  min-width: 18px; height: 18px; padding: 0 5px;
  border-radius: 9px; font-size: 10px; font-weight: 700;
  margin-left: 4px;
}

/* ===================== TABULATOR 커스텀 ===================== */
.main-card #tableAlarmTab {
  font-family: 'Noto Sans KR', sans-serif !important;
}

/* Tabulator 전체 오버라이드 */
#tableAlarmTab .tabulator {
  border: none !important;
  background: transparent !important;
  font-size: 13px !important;
}
#tableAlarmTab .tabulator-header {
  background: var(--surface2) !important;
  border-bottom: 1px solid var(--border) !important;
}
#tableAlarmTab .tabulator-col {
  background: var(--surface2) !important;
  border-right: 1px solid var(--border) !important;
  font-size: 12px !important;
  font-weight: 700 !important;
  color: var(--text-s) !important;
  letter-spacing: .3px;
}
#tableAlarmTab .tabulator-col:last-child { border-right: none !important; }
#tableAlarmTab .tabulator-col-title { padding: 8px 10px !important; }
#tableAlarmTab .tabulator-row {
  border-bottom: 1px solid var(--border) !important;
  transition: background .1s !important;
}
#tableAlarmTab .tabulator-row:hover { background: #f8faff !important; }
#tableAlarmTab .tabulator-cell {
  border-right: 1px solid #f1f5f9 !important;
  padding: 8px 10px !important;
  font-size: 13px !important;
  color: var(--text-p) !important;
}
#tableAlarmTab .tabulator-cell:last-child { border-right: none !important; }

/* 진행중 행 강조 */
#tableAlarmTab .tabulator-row.row-active {
  background: linear-gradient(90deg, rgba(220,38,38,.06) 0%, rgba(255,255,255,0) 60%) !important;
}
#tableAlarmTab .tabulator-row.row-active .tabulator-cell {
  color: #b91c1c !important;
  font-weight: 600 !important;
}

/* 헤더필터 인풋 */
#tableAlarmTab .tabulator-header-filter input {
  border: 1px solid var(--border) !important;
  border-radius: 6px !important;
  font-size: 11px !important;
  padding: 3px 7px !important;
  background: var(--surface) !important;
  color: var(--text-p) !important;
  outline: none !important;
  width: 100% !important;
}

/* 상태 뱃지 */
.badge {
  display: inline-flex; align-items: center; gap: 4px;
  padding: 2px 9px; border-radius: 20px;
  font-size: 11px; font-weight: 700;
}
.badge-active {
  background: var(--red-light); color: var(--red);
}
.badge-active::before {
  content: ''; display: inline-block;
  width: 5px; height: 5px; border-radius: 50%;
  background: var(--red);
  animation: blink 1.4s ease-in-out infinite;
}
.badge-clear {
  background: var(--grn-light); color: var(--green);
}
.badge-clear::before {
  content: ''; display: inline-block;
  width: 5px; height: 5px; border-radius: 50%;
  background: var(--green);
}

/* No 컬럼 */
.cell-no {
  font-family: 'JetBrains Mono', monospace;
  font-size: 11px; color: var(--text-m); font-weight: 600;
}

/* 시간 컬럼 */
.cell-time {
  font-family: 'JetBrains Mono', monospace;
  font-size: 12px; color: var(--text-s);
}

/* PLC 주소 */
.cell-addr {
  font-family: 'JetBrains Mono', monospace;
  font-size: 12px; font-weight: 600;
  background: var(--surface2);
  padding: 2px 8px; border-radius: 5px;
  border: 1px solid var(--border);
  display: inline-block;
}

/* 알람내용 */
.cell-desc { font-weight: 500; text-align: left; }
.cell-desc.active { color: #b91c1c; font-weight: 700; }

/* 하단 카운트 바 */
.footer-bar {
  padding: 8px 16px;
  border-top: 1px solid var(--border);
  background: var(--surface2);
  display: flex; align-items: center; justify-content: space-between;
  font-size: 12px; color: var(--text-m);
}
.footer-bar strong { color: var(--text-p); font-family: 'JetBrains Mono', monospace; }
</style>
</head>
<body>

<!-- ===================== TOPBAR ===================== -->
<div class="topbar">
  <div class="topbar-inner">
    <div class="topbar-title">
      <span class="blink-dot"></span>알람 이력
    </div>
    <div class="tb-divider"></div>
    <span class="tb-label">조회일자</span>
    <input type="text" id="s_sdate" class="ctrl dayselect daySet" placeholder="시작일"/>
    <span class="tilde">~</span>
    <input type="text" id="s_edate" class="ctrl dayselect daySet" placeholder="종료일"/>
    <div class="tb-divider"></div>
    <button class="btn btn-search select-button">
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
        <circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/>
      </svg>조회
    </button>
    <button class="btn btn-excel" id="btnExcel">
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
        <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/>
        <line x1="12" y1="12" x2="12" y2="18"/><line x1="9" y1="15" x2="15" y2="15"/>
      </svg>Download
    </button>
  </div>
</div>

<!-- ===================== PAGE ===================== -->
<div class="page-wrap">

  <!-- KPI 카드 -->
  <div class="kpi-row">
    <div class="kpi-card kpi-total">
      <div class="kpi-icon">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/>
        </svg>
      </div>
      <div class="kpi-info">
        <div class="kpi-label">전체 건수</div>
        <div class="kpi-value" id="kpi-total">0</div>
        <div class="kpi-sub">조회 기간 합계</div>
      </div>
    </div>
    <div class="kpi-card kpi-active">
      <div class="kpi-icon">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/>
        </svg>
      </div>
      <div class="kpi-info">
        <div class="kpi-label">진행 중</div>
        <div class="kpi-value" id="kpi-active">0</div>
        <div class="kpi-sub">미해제 알람</div>
      </div>
    </div>
    <div class="kpi-card kpi-clear">
      <div class="kpi-icon">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/>
        </svg>
      </div>
      <div class="kpi-info">
        <div class="kpi-label">해제 완료</div>
        <div class="kpi-value" id="kpi-clear">0</div>
        <div class="kpi-sub">정상 해제</div>
      </div>
    </div>
    <div class="kpi-card kpi-today">
      <div class="kpi-icon">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/>
        </svg>
      </div>
      <div class="kpi-info">
        <div class="kpi-label">조회 기간</div>
        <div class="kpi-value" style="font-size:15px; margin-top:2px;" id="kpi-period">-</div>
        <div class="kpi-sub" id="kpi-period-sub">-</div>
      </div>
    </div>
  </div>

  <!-- 테이블 카드 -->
  <div class="main-card">
    <div class="main-card-header">
      <div class="main-card-title">알람 목록</div>
      <div class="header-right">
        <button class="filter-chip active-all"   id="chip-all"   onclick="setFilter('all')">전체<span class="count-badge" id="cnt-all"  style="background:#64748b;color:#fff;">0</span></button>
        <button class="filter-chip"              id="chip-alarm" onclick="setFilter('alarm')">진행 중<span class="count-badge" id="cnt-alarm" style="background:var(--red-light);color:var(--red);">0</span></button>
        <button class="filter-chip"              id="chip-clear" onclick="setFilter('clear')">해제 완료<span class="count-badge" id="cnt-clear" style="background:var(--grn-light);color:var(--green);">0</span></button>
        <div class="tb-divider" style="height:18px;"></div>
        <input type="text" class="search-input" id="tableSearch" placeholder="내용 검색...">
      </div>
    </div>

    <div id="tableAlarmTab"></div>

    <div class="footer-bar">
      <span id="footer-info">데이터를 조회하세요</span>
      <span>마지막 조회: <strong id="footer-time">-</strong></span>
    </div>
  </div>

</div>

<script>
let now_page_code = "b02";
let alarmTable = null;
let allData = [];
var currentFilter = 'all';

$(function () {
  $("#s_sdate").val(yesterDate());
  $("#s_edate").val(todayDate());

  alarmTable = new Tabulator("#tableAlarmTab", {
    layout: "fitColumns",
    height: "560px",
    placeholder: '<div style="padding:40px;color:#94a3b8;font-size:13px;">조회된 데이터가 없습니다.</div>',
    reactiveData: true,
    selectable: 1,
    columns: [
      {
        title: "No", field: "idx", width: 70, hozAlign: "center",
        headerFilter: "input",
        formatter: function(cell){
          return '<span class="cell-no">' + (cell.getValue()||'') + '</span>';
        }
      },
      {
        title: "PLC주소", field: "a_addr", width: 130, hozAlign: "center",
        headerFilter: "input",
        formatter: function(cell){
          var v = cell.getValue() || '';
          return v ? '<span class="cell-addr">' + v + '</span>' : '-';
        }
      },
      {
        title: "알람내용", field: "a_desc", minWidth: 280, hozAlign: "left",
        headerFilter: "input",
        formatter: function(cell){
          var row = cell.getRow().getData();
          var active = !row.a_etime || row.a_etime === '';
          var v = cell.getValue() || '';
          return '<span class="cell-desc' + (active?' active':'') + '">' + v + '</span>';
        }
      },
      {
        title: "발생시간", field: "a_stime", width: 170, hozAlign: "center",
        headerFilter: "input",
        formatter: function(cell){
          var v = cell.getValue() || '';
          return v ? '<span class="cell-time">' + v + '</span>' : '-';
        }
      },
      {
        title: "해제시간", field: "a_etime", width: 170, hozAlign: "center",
        headerFilter: "input",
        formatter: function(cell){
          var v = cell.getValue() || '';
          return v ? '<span class="cell-time">' + v + '</span>'
                   : '<span style="color:var(--text-m);font-size:12px;">미해제</span>';
        }
      },
      {
        title: "상태", field: "status", width: 110, hozAlign: "center",
        headerFilter: "input",
        formatter: function(cell){
          var v = cell.getValue() || '';
          if(v === '진행 중'){
            return '<span class="badge badge-active">진행 중</span>';
          } else {
            return '<span class="badge badge-clear">해제</span>';
          }
        }
      }
    ],
    rowFormatter: function(row){
      var d = row.getData();
      if(!d.a_etime || d.a_etime === ''){
        row.getElement().classList.add('row-active');
      } else {
        row.getElement().classList.remove('row-active');
      }
    }
  });

  // 검색
  $("#tableSearch").on("keyup", function(){
    var kw = $(this).val();
    if(!kw){ alarmTable.clearFilter(true); }
    else {
      alarmTable.setFilter([
        [
          { field:"a_addr", type:"like", value:kw },
          { field:"a_desc", type:"like", value:kw },
          { field:"a_stime", type:"like", value:kw },
          { field:"a_etime", type:"like", value:kw }
        ]
      ]);
    }
  });

  fetchAlarm();
});

$(".select-button").click(function(){ fetchAlarm(); });

$("#btnExcel").click(function(){
  var s = $("#s_sdate").val();
  var e = $("#s_edate").val();
  window.location.href = "/line/productionManagement/alarmRecordListAll/excel"
    + "?s_sdate=" + encodeURIComponent(s)
    + "&s_edate=" + encodeURIComponent(e);
});

function fetchAlarm(){
  $.ajax({
    url: "/line/productionManagement/alarmRecordListAll/list",
    method: "POST",
    data: { s_sdate: $("#s_sdate").val(), s_edate: $("#s_edate").val() },
    dataType: "json",
    success: function(resp){
      var arr = Array.isArray(resp) ? resp : (resp.data || resp.rows || (resp ? [resp] : []));
      allData = (arr || []).map(function(r){
        return Object.assign({}, r, {
          status: (!r.a_etime || r.a_etime === "") ? "진행 중" : "-"
        });
      });

      applyFilter(currentFilter);
      updateKpi();
      updateFooter();
    },
    error: function(xhr){
      console.error("fetchAlarm error", xhr);
      alarmTable.replaceData([]);
    }
  });
}

function applyFilter(f){
  currentFilter = f;
  var filtered;
  if(f === 'alarm')      filtered = allData.filter(function(r){ return r.status === '진행 중'; });
  else if(f === 'clear') filtered = allData.filter(function(r){ return r.status !== '진행 중'; });
  else                   filtered = allData.slice();

  alarmTable.setData(filtered);

  // 칩 상태
  document.getElementById('chip-all').className   = 'filter-chip' + (f==='all'   ? ' active-all':'');
  document.getElementById('chip-alarm').className = 'filter-chip' + (f==='alarm' ? ' active-alarm':'');
  document.getElementById('chip-clear').className = 'filter-chip' + (f==='clear' ? ' active-clear':'');

  // 푸터
  document.getElementById('footer-info').innerHTML =
    '총 <strong>' + filtered.length + '</strong>건 표시 중';
}

function setFilter(f){ applyFilter(f); }

function updateKpi(){
  var total  = allData.length;
  var active = allData.filter(function(r){ return r.status === '진행 중'; }).length;
  var clear  = total - active;

  document.getElementById('kpi-total').textContent  = total.toLocaleString();
  document.getElementById('kpi-active').textContent = active.toLocaleString();
  document.getElementById('kpi-clear').textContent  = clear.toLocaleString();

  var s = $("#s_sdate").val() || '-';
  var e = $("#s_edate").val() || '-';
  document.getElementById('kpi-period').textContent     = s.substring(0,10);
  document.getElementById('kpi-period-sub').textContent = '~ ' + e.substring(0,10);

  // 배지 카운트
  document.getElementById('cnt-all').textContent   = total;
  document.getElementById('cnt-alarm').textContent = active;
  document.getElementById('cnt-clear').textContent = clear;
}

function updateFooter(){
  var now = new Date();
  var h = String(now.getHours()).padStart(2,'0');
  var m = String(now.getMinutes()).padStart(2,'0');
  var s = String(now.getSeconds()).padStart(2,'0');
  document.getElementById('footer-time').textContent = h+':'+m+':'+s;
  document.getElementById('footer-info').innerHTML =
    '총 <strong>' + allData.length + '</strong>건';
}
</script>
</body>
</html>
