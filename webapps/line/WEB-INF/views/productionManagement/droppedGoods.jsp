<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="ko">
<head>
<script src="/line/mock/mock-loader.js"></script>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>낙하품관리</title>
<%@include file="../include/pluginpage.jsp" %>
<jsp:include page="../include/tabBar.jsp"/>
<link href="/vendor/tabulator/5.5.0/tabulator.min.css" rel="stylesheet">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@400;500;600;700;800&family=JetBrains+Mono:wght@400;600;700&display=swap" rel="stylesheet">
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
  --red-lt:    #fee2e2;
  --orange:    #ea580c;
  --org-lt:    #ffedd5;
  --green:     #16a34a;
  --grn-lt:    #dcfce7;
  --accent:    #2563eb;
  --acc-lt:    #dbeafe;
  --yellow:    #d97706;
  --yel-lt:    #fef3c7;
  --purple:    #7c3aed;
  --pur-lt:    #ede9fe;
  --shadow:    0 1px 3px rgba(0,0,0,.06);
  --shadow-md: 0 4px 16px rgba(0,0,0,.08);
  --radius:    12px;
}

*{ box-sizing:border-box; margin:0; padding:0; }
body {
  font-family:'Noto Sans KR', sans-serif;
  background:var(--bg);
  color:var(--text-p);
  min-height:100vh;
}

/* ===== TOPBAR ===== */
.topbar {
  position:sticky; top:0; z-index:100;
  background:rgba(255,255,255,.96);
  backdrop-filter:blur(12px);
  border-bottom:1px solid var(--border);
  box-shadow:var(--shadow);
}
.topbar-inner {
  max-width:1700px; margin:0 auto;
  padding:0 24px; height:54px;
  display:flex; align-items:center; gap:10px; flex-wrap:wrap;
}
.tb-title {
  font-size:14px; font-weight:800; color:var(--text-p);
  letter-spacing:-.3px; white-space:nowrap; margin-right:6px;
  display:flex; align-items:center; gap:7px;
}
.tb-title .icon {
  width:22px; height:22px; border-radius:7px;
  background:linear-gradient(135deg,#dc2626,#ea580c);
  display:flex; align-items:center; justify-content:center; flex-shrink:0;
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
  min-width:148px; text-align:center;
}
.ctrl:focus { border-color:var(--accent); box-shadow:0 0 0 3px rgba(37,99,235,.12); }

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
  max-width:1700px; margin:0 auto;
  padding:16px 24px 28px;
  display:flex; flex-direction:column; gap:14px;
}

/* ===== KPI ===== */
.kpi-row {
  display:grid; grid-template-columns:repeat(5,1fr); gap:12px;
}
@media(max-width:1100px){ .kpi-row{ grid-template-columns:repeat(3,1fr); } }
@media(max-width:700px) { .kpi-row{ grid-template-columns:repeat(2,1fr); } }

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
.kpi-card:nth-child(5){ animation-delay:.20s; }

.kpi-card.k-total::before  { background:linear-gradient(90deg,#64748b,#94a3b8); }
.kpi-card.k-drop::before   { background:linear-gradient(90deg,#dc2626,#f87171); }
.kpi-card.k-ok::before     { background:linear-gradient(90deg,#16a34a,#4ade80); }
.kpi-card.k-warn::before   { background:linear-gradient(90deg,#d97706,#fbbf24); }
.kpi-card.k-cust::before   { background:linear-gradient(90deg,#7c3aed,#a78bfa); }

@keyframes fadeUp {
  from{ opacity:0; transform:translateY(10px); }
  to  { opacity:1; transform:none; }
}

.kpi-icon {
  width:38px; height:38px; border-radius:10px;
  display:flex; align-items:center; justify-content:center; flex-shrink:0;
}
.kpi-icon svg { width:18px; height:18px; }
.k-total .kpi-icon { background:#f1f5f9; color:#64748b; }
.k-drop  .kpi-icon { background:var(--red-lt); color:var(--red); }
.k-ok    .kpi-icon { background:var(--grn-lt); color:var(--green); }
.k-warn  .kpi-icon { background:var(--yel-lt); color:var(--yellow); }
.k-cust  .kpi-icon { background:var(--pur-lt); color:var(--purple); }

.kpi-info  { display:flex; flex-direction:column; gap:2px; }
.kpi-label { font-size:11px; font-weight:700; color:var(--text-m); text-transform:uppercase; letter-spacing:.5px; }
.kpi-value { font-size:26px; font-weight:800; font-family:'JetBrains Mono',monospace; color:var(--text-p); line-height:1; letter-spacing:-1px; }
.kpi-sub   { font-size:11px; color:var(--text-m); margin-top:2px; }

/* ===== MAIN CARD ===== */
.main-card {
  background:var(--surface); border:1px solid var(--border);
  border-radius:var(--radius); box-shadow:var(--shadow);
  overflow:hidden;
  animation:fadeUp .35s .2s ease both;
}
.card-head {
  padding:14px 20px; border-bottom:1px solid var(--border);
  display:flex; align-items:center; justify-content:space-between; gap:12px; flex-wrap:wrap;
}
.card-head-title { font-size:13px; font-weight:800; color:var(--text-p); }
.card-foot {
  padding:8px 16px; border-top:1px solid var(--border);
  background:var(--surface2);
  display:flex; align-items:center; justify-content:space-between;
  font-size:12px; color:var(--text-m);
}
.card-foot strong { color:var(--text-p); font-family:'JetBrains Mono',monospace; }

/* ===== TABULATOR OVERRIDES ===== */
#tab1 .tabulator {
  border:none !important;
  border-radius:0 !important;
  font-family:'Noto Sans KR',sans-serif !important;
  font-size:13px !important;
  box-shadow:none !important;
}
#tab1 .tabulator-header {
  background:var(--surface2) !important;
  border-bottom:2px solid var(--border) !important;
}
#tab1 .tabulator-col {
  background:var(--surface2) !important;
  border-right:1px solid var(--border) !important;
  font-size:11px !important; font-weight:800 !important;
  color:var(--text-s) !important; text-transform:uppercase !important; letter-spacing:.3px !important;
}
#tab1 .tabulator-col-title { padding:8px 6px !important; }
#tab1 .tabulator-col-group-cols .tabulator-col {
  background:#eef2fb !important;
}

/* 낙하품유무 그룹 헤더 강조 */
#tab1 .tabulator-col.tabulator-col-group {
  background:linear-gradient(180deg,#fee2e2,#fecaca) !important;
  color:#991b1b !important;
  font-weight:800 !important;
}

#tab1 .tabulator-row {
  border-bottom:1px solid var(--border) !important;
  transition:background .1s !important;
}
#tab1 .tabulator-row:hover { background:#f8faff !important; }
#tab1 .tabulator-row.row_select { background:#dbeafe !important; }
#tab1 .tabulator-cell {
  padding:7px 10px !important;
  border-right:1px solid #f1f5f9 !important;
}
#tab1 .tabulator-placeholder {
  color:var(--text-m) !important; font-size:13px !important;
}

/* O/X 셀 강조 */
.cell-o {
  display:inline-flex; align-items:center; justify-content:center;
  width:24px; height:24px; border-radius:50%;
  background:var(--grn-lt); color:var(--green);
  font-size:13px; font-weight:800; border:1.5px solid #86efac;
}
.cell-x {
  display:inline-flex; align-items:center; justify-content:center;
  width:24px; height:24px; border-radius:50%;
  background:var(--red-lt); color:var(--red);
  font-size:12px; font-weight:800; border:1.5px solid #fca5a5;
}
.cell-empty {
  display:inline-flex; align-items:center; justify-content:center;
  width:24px; height:24px; border-radius:50%;
  background:var(--surface2); color:var(--text-m);
  font-size:11px; border:1px solid var(--border);
}

/* 시간 태그 */
.time-tag {
  font-family:'JetBrains Mono',monospace; font-size:11px;
  color:var(--text-s); font-weight:600;
}
.lot-tag {
  font-family:'JetBrains Mono',monospace; font-size:12px;
  font-weight:700; color:var(--accent);
}
.cust-tag {
  display:inline-block; padding:2px 8px; border-radius:12px;
  background:var(--pur-lt); border:1px solid #ddd6fe;
  font-size:11px; font-weight:700; color:var(--purple);
}
</style>
</head>
<body>

<!-- ===== TOPBAR ===== -->
<div class="topbar">
  <div class="topbar-inner">
    <div class="tb-title">
      <span class="icon">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
          <path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/>
          <line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/>
        </svg>
      </span>
      낙하품 관리
    </div>
    <div class="tb-div"></div>
    <span class="tb-label">작업일자</span>
    <input type="text" class="ctrl dayselect daySet" id="w_date" placeholder="날짜 선택" autocomplete="off"/>
    <div class="tb-div"></div>
    <button class="btn btn-search select-button" onclick="getDroppedGoodsList();">
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
    <input type="file" id="fileInput" style="display:none;">
  </div>
</div>

<!-- ===== PAGE ===== -->
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
        <div class="kpi-label">전체 LOT</div>
        <div class="kpi-value" id="kpi-total">0</div>
        <div class="kpi-sub">조회된 총 건수</div>
      </div>
    </div>
    <div class="kpi-card k-drop">
      <div class="kpi-icon">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/>
          <line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/>
        </svg>
      </div>
      <div class="kpi-info">
        <div class="kpi-label">낙하품 발생</div>
        <div class="kpi-value" id="kpi-drop">0</div>
        <div class="kpi-sub">O 표기 LOT 수</div>
      </div>
    </div>
    <div class="kpi-card k-ok">
      <div class="kpi-icon">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <polyline points="20 6 9 17 4 12"/>
        </svg>
      </div>
      <div class="kpi-info">
        <div class="kpi-label">이상 없음</div>
        <div class="kpi-value" id="kpi-ok">0</div>
        <div class="kpi-sub">X 표기 LOT 수</div>
      </div>
    </div>
    <div class="kpi-card k-warn">
      <div class="kpi-icon">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <circle cx="12" cy="12" r="10"/>
          <line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/>
        </svg>
      </div>
      <div class="kpi-info">
        <div class="kpi-label">미확인</div>
        <div class="kpi-value" id="kpi-warn">0</div>
        <div class="kpi-sub">미기재 LOT 수</div>
      </div>
    </div>
    <div class="kpi-card k-cust">
      <div class="kpi-icon">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/>
          <circle cx="9" cy="7" r="4"/>
          <path d="M23 21v-2a4 4 0 0 0-3-3.87"/>
          <path d="M16 3.13a4 4 0 0 1 0 7.75"/>
        </svg>
      </div>
      <div class="kpi-info">
        <div class="kpi-label">거래처 수</div>
        <div class="kpi-value" id="kpi-cust">0</div>
        <div class="kpi-sub">고유 거래처</div>
      </div>
    </div>
  </div>

  <!-- 메인 테이블 카드 -->
  <div class="main-card">
    <div class="card-head">
      <span class="card-head-title">⚠️ 낙하품 관리 이력</span>
      <span style="font-size:11px; color:var(--text-m);" id="card-date-label">-</span>
    </div>

    <div id="tab1"></div>

    <div class="card-foot">
      <span id="footer-info">데이터를 조회하세요</span>
      <span>마지막 조회: <strong id="footer-time">-</strong></span>
    </div>
  </div>

</div>

<script>
let now_page_code = "e05";
let userTable = null;

/* ─── 날짜 유틸 ─── */
function pad2(n){ return String(n).padStart(2,'0'); }
function todayDate(){
  var d = new Date();
  return d.getFullYear()+'-'+pad2(d.getMonth()+1)+'-'+pad2(d.getDate());
}

/* ─── O/X 포매터 ─── */
function oxFormatter(cell){
  var v = (cell.getValue()||'').toString().trim().toUpperCase();
  if(v==='O') return '<div style="display:flex;justify-content:center;"><span class="cell-o">O</span></div>';
  if(v==='X') return '<div style="display:flex;justify-content:center;"><span class="cell-x">✕</span></div>';
  return '<div style="display:flex;justify-content:center;"><span class="cell-empty">-</span></div>';
}

/* ─── 시간 포매터 ─── */
function timeFormatter(cell){
  var v = cell.getValue() || '';
  return v ? '<span class="time-tag">'+v+'</span>' : '<span style="color:var(--text-m);font-size:11px;">-</span>';
}

/* ─── KPI 업데이트 ─── */
function updateKpi(data){
  var total  = data.length;
  var dropCnt = 0, okCnt = 0, warnCnt = 0;
  var custSet = {};

  data.forEach(function(r){
    var vals = [r.d_in, r.d_qf, r.d_tf, r.d_out];
    var hasO = vals.some(function(v){ return (v||'').trim().toUpperCase()==='O'; });
    var hasX = vals.every(function(v){ return (v||'').trim().toUpperCase()==='X' || !(v||'').trim(); });
    var allFilled = vals.every(function(v){ return (v||'').trim(); });

    if(hasO) dropCnt++;
    else if(allFilled) okCnt++;
    else warnCnt++;

    if(r.cust_name) custSet[r.cust_name] = 1;
  });

  document.getElementById('kpi-total').textContent = total.toLocaleString();
  document.getElementById('kpi-drop').textContent  = dropCnt.toLocaleString();
  document.getElementById('kpi-ok').textContent    = okCnt.toLocaleString();
  document.getElementById('kpi-warn').textContent  = warnCnt.toLocaleString();
  document.getElementById('kpi-cust').textContent  = Object.keys(custSet).length.toLocaleString();

  var dateVal = document.querySelector('.dayselect').value || '-';
  document.getElementById('card-date-label').textContent = dateVal + ' 기준';
  document.getElementById('footer-info').innerHTML = '총 <strong>'+total+'</strong>건';

  var now = new Date();
  document.getElementById('footer-time').textContent =
    pad2(now.getHours())+':'+pad2(now.getMinutes())+':'+pad2(now.getSeconds());
}

/* ─── 테이블 조회 ─── */
function getDroppedGoodsList() {
  userTable = new Tabulator("#tab1", {
    height: "600px",
    layout: "fitColumns",
    selectable: true,
    tooltips: true,
    selectableRangeMode: "click",
    reactiveData: true,
    headerHozAlign: "center",
    ajaxConfig: "POST",
    ajaxLoader: false,
    ajaxURL: "/line/productionManagement/droppedGoods/getDroppedGoodsList",
    ajaxParams: {
      "w_date": document.querySelector('.dayselect').value
    },
    ajaxResponse: function(url, params, response){
      var data = response.data || [];
      updateKpi(data);
      return data;
    },
    placeholder: "조회된 데이터가 없습니다.",
    columns: [
      { title:"작업 LOT",  field:"w_ci_lot",    hozAlign:"center", width:130, headerSort:true,
        formatter:function(cell){ return '<span class="lot-tag">'+(cell.getValue()||'-')+'</span>'; }
      },
      { title:"투입시간",  field:"w_sdatetime", hozAlign:"center", width:160, headerSort:true, formatter:timeFormatter },
      { title:"거래처",    field:"cust_name",   hozAlign:"center", width:80, headerSort:false,
        formatter:function(cell){ var v=cell.getValue()||''; return v?'<span class="cust-tag">'+v+'</span>':'-'; }
      },
      { title:"품번",      field:"prod_code",   hozAlign:"center", width:90,  headerSort:false },
      { title:"품명",      field:"item_name",   hozAlign:"left",   width:160, headerSort:false },
      {
        title:"낙하품유무", hozAlign:"center", headerSort:false,
        columns:[
          { title:"투입",   field:"d_in",      hozAlign:"center", width:60,  headerSort:false, formatter:oxFormatter,   editor:"select", editorParams:{values:["O","X"]} },
          { title:"확인",   field:"d_in_time",  hozAlign:"center", width:80,  headerSort:false, formatter:timeFormatter },
          { title:"전세정기",   field:"d_qf",       hozAlign:"center", width:60,  headerSort:false, formatter:oxFormatter,   editor:"select", editorParams:{values:["O","X"]} },
          { title:"확인",   field:"d_qf_time",  hozAlign:"center", width:80,  headerSort:false, formatter:timeFormatter },
          { title:"소입유조", field:"d_tf",       hozAlign:"center", width:80,  headerSort:false, formatter:oxFormatter,   editor:"select", editorParams:{values:["O","X"]} },
          { title:"확인",   field:"d_tf_time",  hozAlign:"center", width:80,  headerSort:false, formatter:timeFormatter },
          { title:"중간세정기",   field:"d_out",      hozAlign:"center", width:80,  headerSort:false, formatter:oxFormatter,   editor:"select", editorParams:{values:["O","X"]} },
          { title:"확인",   field:"d_out_time", hozAlign:"center", width:80,  headerSort:false, formatter:timeFormatter },
          { title:"방청조",  field:"d_new",      hozAlign:"center", width:60,  headerSort:false, formatter:oxFormatter,   editor:"select", editorParams:{values:["O","X"]} },
          { title:"확인",   field:"d_new_time", hozAlign:"center", width:80,  headerSort:false, formatter:timeFormatter },
          { title:"확인자", field:"d_name",     hozAlign:"center", width:90,  headerSort:false, editor:"input" }
        ]
      },
      { title:"특이사항", field:"d_bigo", hozAlign:"left",  editor:"input", headerSort:false }
    ],
    rowFormatter: function(row){
      var data = row.getData();
      var vals = [data.d_in, data.d_qf, data.d_tf, data.d_out];
      var hasO = vals.some(function(v){ return (v||'').trim().toUpperCase()==='O'; });
      if(hasO){
        row.getElement().style.background = '#fff7f7';
        row.getElement().style.borderLeft = '3px solid #dc2626';
      } else {
        row.getElement().style.background = '#ffffff';
        row.getElement().style.borderLeft = 'none';
      }
    },
    rowClick: function(e, row){
      document.querySelectorAll('#tab1 .tabulator-row').forEach(function(el){ el.classList.remove('row_select'); });
      row.getElement().classList.add('row_select');
    },
    cellEdited: function(cell){
      var field    = cell.getField();
      var value    = cell.getValue();
      var rowData  = cell.getRow().getData();
      var w_ci_lot = rowData.w_ci_lot;

      console.log('✅ [수정 발생] LOT:', w_ci_lot, '| 컬럼:', field, '| 값:', value);

      $.ajax({
        url: "/line/productionManagement/droppedGoods/updateDroppedGoods",
        type: "POST",
        contentType: "application/json",
        data: JSON.stringify({ d_lot: w_ci_lot, column: field, value: value }),
        success: function(res){
          console.log('✅ [서버 응답]', res);
          if(res.result === 'success'){
            userTable.replaceData();
          } else {
            alert('저장 실패: ' + res.message);
          }
        },
        error: function(xhr, status, error){
          console.error('❌ [서버 통신 실패]', status, error);
          alert('서버 통신 실패');
        }
      });
    }
  });
}

/* ─── 엑셀 다운로드 ─── */
function downloadDroppedGoodsExcel(){
  if(!userTable){ return; }
  var tableData = userTable.getData();
  if(!tableData || tableData.length === 0){ alert('다운로드할 데이터가 없습니다.'); return; }

  var excelData = tableData.map(function(row, index){
    return {
      "NO": index+1,
      "작업LOT": row.w_ci_lot||"",
      "투입시간": row.w_sdatetime||"",
      "거래처": row.cust_name||"",
      "품번": row.prod_code||"",
      "품명": row.item_name||"",
      "투입": row.d_in||"",
      "투입</br>확인시간": row.d_in_time||"",
      "전세정기": row.d_qf||"",
      "전세정기</br> 확인시간": row.d_qf_time||"",
      "소입유조": row.d_tf||"",
      "소입유조</br> 확인시간": row.d_tf_time||"",
      "중간 새정기": row.d_out||"",
      "중간 세정기</br>확인시간": row.d_out_time||"",
      "방청조": row.d_new||"",
      "방청조</br>확인시간": row.d_new_time||"",
      "확인자": row.d_name||"",
      "특이사항": row.d_bigo||""
    };
  });

  var ws = XLSX.utils.json_to_sheet(excelData);
  ws['!cols'] = [
    {wch:5},{wch:15},{wch:18},{wch:15},{wch:12},{wch:20},
    {wch:6},{wch:18},{wch:6},{wch:18},{wch:8},{wch:18},
    {wch:6},{wch:18},{wch:10},{wch:20}
  ];

  var wb = XLSX.utils.book_new();
  XLSX.utils.book_append_sheet(wb, ws, "낙하품 관리 이력");

  var workDate = document.querySelector('.dayselect').value || '전체';
  var now = new Date();
  var timeStr = pad2(now.getHours()) + pad2(now.getMinutes());
  XLSX.writeFile(wb, '낙하품관리_'+workDate+'_'+timeStr+'.xlsx');
}

/* ─── DOM Ready ─── */
$(function(){
  document.querySelector('.dayselect').value = todayDate();
  getDroppedGoodsList();
  $('.excel-button').on('click', downloadDroppedGoodsExcel);
});
</script>

</body>
</html>
