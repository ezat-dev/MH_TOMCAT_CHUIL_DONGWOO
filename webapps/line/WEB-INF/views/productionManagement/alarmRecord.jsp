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
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=IBM+Plex+Mono:wght@400;500&family=IBM+Plex+Sans+KR:wght@400;500;600&display=swap">
    <link rel="stylesheet" href="/line/css/opsList/ops-list.css">
<style>
/* 데모: 한 화면 고정 — 페이지 스크롤 없이 표만 스크롤 */
html, body.ops { height: 100%; }
body.ops { display: flex; flex-direction: column; overflow: hidden; min-height: 0; }
.ops-head { flex: 0 0 auto; }
.ops-page { flex: 1 1 auto; min-height: 0; }
.ops-card { flex: 1 1 auto; min-height: 0; display: flex; flex-direction: column; }
#tableAlarmTab { flex: 1 1 auto; min-height: 0; }

.ops-input { text-align: center; min-width: 156px; }
.tilde { color: var(--ops-fg3); }

/* 지표: 진행 중(핵심) / 전체 / 해제 / 기간 */
.ops-kpi.k4 { grid-template-columns: 1.4fr repeat(3, 1fr); }

/* 상태 필터 — 아웃라인 칩 */
.ops-card-head { align-items: center; padding: 8px 16px; }
.head-right { display: flex; align-items: center; gap: 8px; }
.filter-chip {
  height: 28px; padding: 0 8px 0 12px; display: inline-flex; align-items: center; gap: 8px;
  border: 1px solid var(--ops-line); border-radius: 6px; background: #fff; color: var(--ops-fg2);
  font-family: var(--ops-sans); font-size: 12px; font-weight: 500; cursor: pointer; white-space: nowrap;
  transition: background-color 80ms, border-color 80ms;
}
.filter-chip:hover { background: var(--ops-hover); }
.filter-chip.active-all, .filter-chip.active-alarm, .filter-chip.active-clear {
  border-color: var(--ops-accent); background: var(--ops-accent-tint); color: var(--ops-accent);
}
.count-badge { font-family: var(--ops-mono); font-size: 12px; font-variant-numeric: tabular-nums; color: var(--ops-fg3); min-width: 16px; text-align: right; }
.filter-chip[class*="active-"] .count-badge { color: var(--ops-accent); }
#chip-alarm .count-badge { color: var(--ops-bad); }

.search-input {
  height: 28px; width: 200px; padding: 0 8px 0 28px;
  border: 1px solid var(--ops-line); border-radius: 6px; background: #fff; color: var(--ops-fg);
  font-family: var(--ops-sans); font-size: 12px; outline: none;
  background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='14' height='14' viewBox='0 0 24 24' fill='none' stroke='%239aa1ad' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3E%3Ccircle cx='11' cy='11' r='8'/%3E%3Cline x1='21' y1='21' x2='16.65' y2='16.65'/%3E%3C/svg%3E");
  background-repeat: no-repeat; background-position: 8px center;
}
.search-input:focus { border-color: var(--ops-accent); box-shadow: 0 0 0 2px var(--ops-accent-tint); }

/* 표 */
#tableAlarmTab .tabulator-header-filter input {
  height: 24px; border: 1px solid var(--ops-line) !important; border-radius: 4px !important;
  font-family: var(--ops-sans); font-size: 12px !important; padding: 0 6px !important; background: #fff !important; outline: none;
}
#tableAlarmTab .tabulator-row.row-active { background: var(--ops-bad-tint) !important; box-shadow: inset 2px 0 0 var(--ops-bad); }
#tableAlarmTab .tabulator-row.row-active:hover { background: oklch(56% 0.15 25 / 0.07) !important; }

.cell-no   { font-family: var(--ops-mono); font-size: 12px; color: var(--ops-fg3); font-variant-numeric: tabular-nums; }
.cell-time { font-family: var(--ops-mono); font-size: 12px; color: var(--ops-fg2); font-variant-numeric: tabular-nums; }
.cell-addr { font-family: var(--ops-mono); font-size: 12px; color: var(--ops-fg); font-variant-numeric: tabular-nums slashed-zero; }
.cell-desc { color: var(--ops-fg); }
.cell-desc.active { font-weight: 500; }
.cell-open { font-size: 12px; color: var(--ops-fg3); }
.ops #tableAlarmTab .st { font-family: var(--ops-sans); }
</style>
</head>
<body class="ops">

<!-- ===== 헤더 + 툴바 ===== -->
<header class="ops-head">
  <div class="ops-head-in">
    <h1 class="ops-title">알람 이력</h1>
    <span class="ops-label">조회일자</span>
    <input type="text" id="s_sdate" class="ops-input dayselect daySet" placeholder="시작일"/>
    <span class="tilde">~</span>
    <input type="text" id="s_edate" class="ops-input dayselect daySet" placeholder="종료일"/>
    <button class="ops-btn primary select-button">
      <svg viewBox="0 0 24 24"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>조회
    </button>
    <span class="ops-spacer"></span>
    <button class="ops-btn" id="btnExcel">
      <svg viewBox="0 0 24 24"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/></svg>엑셀
    </button>
  </div>
</header>

<!-- ===== 본문 ===== -->
<main class="ops-page">

  <!-- 지표 띠: 첫 칸이 핵심 -->
  <section class="ops-kpi k4">
    <div class="hero">
      <span class="kpi-label">진행 중 알람</span>
      <span class="kpi-value" id="kpi-active">0</span>
      <span class="kpi-sub">미해제 · 조치 필요</span>
    </div>
    <div>
      <span class="kpi-label">전체 건수</span>
      <span class="kpi-value" id="kpi-total">0</span>
      <span class="kpi-sub">조회 기간 합계</span>
    </div>
    <div>
      <span class="kpi-label">해제 완료</span>
      <span class="kpi-value" id="kpi-clear">0</span>
      <span class="kpi-sub">정상 해제</span>
    </div>
    <div>
      <span class="kpi-label">조회 기간</span>
      <span class="kpi-value" style="font-size:16px;" id="kpi-period">-</span>
      <span class="kpi-sub mono" id="kpi-period-sub">-</span>
    </div>
  </section>

  <!-- 표 카드 -->
  <section class="ops-card">
    <div class="ops-card-head">
      <h2>알람 목록</h2>
      <div class="head-right">
        <button class="filter-chip active-all" id="chip-all"   onclick="setFilter('all')">전체<span class="count-badge" id="cnt-all">0</span></button>
        <button class="filter-chip"            id="chip-alarm" onclick="setFilter('alarm')">진행 중<span class="count-badge" id="cnt-alarm">0</span></button>
        <button class="filter-chip"            id="chip-clear" onclick="setFilter('clear')">해제 완료<span class="count-badge" id="cnt-clear">0</span></button>
        <span class="ops-sep"></span>
        <input type="text" class="search-input" id="tableSearch" placeholder="주소 · 내용 · 시간 검색">
      </div>
    </div>

    <div id="tableAlarmTab" class="ops-table"></div>

    <div class="ops-card-foot">
      <span id="footer-info">데이터를 조회하세요</span>
      <span>마지막 조회 <strong id="footer-time">-</strong></span>
    </div>
  </section>

</main>

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
    height: "100%",
    placeholder: '<span>조회된 데이터가 없습니다.</span>',
    reactiveData: true,
    selectable: 1,
    columns: [
      {
        title: "No", field: "idx", width: 84, hozAlign: "right",
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
        title: "발생시간", field: "a_stime", width: 180, hozAlign: "center",
        headerFilter: "input",
        formatter: function(cell){
          var v = cell.getValue() || '';
          return v ? '<span class="cell-time">' + v + '</span>' : '-';
        }
      },
      {
        title: "해제시간", field: "a_etime", width: 180, hozAlign: "center",
        headerFilter: "input",
        formatter: function(cell){
          var v = cell.getValue() || '';
          return v ? '<span class="cell-time">' + v + '</span>'
                   : '<span class="cell-open">—</span>';
        }
      },
      {
        title: "상태", field: "status", width: 110, hozAlign: "left",
        headerFilter: "input",
        formatter: function(cell){
          var v = cell.getValue() || '';
          if(v === '진행 중'){
            return '<span class="st bad"><i></i>진행 중</span>';
          } else {
            return '<span class="st off"><i></i>해제</span>';
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

  // 창 크기 변경 시 표 높이 다시 맞춤
  var rT = null;
  $(window).on("resize", function(){ clearTimeout(rT); rT = setTimeout(function(){ alarmTable.redraw(true); }, 120); });

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
  document.getElementById('kpi-active').classList.toggle('bad', active > 0);
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
