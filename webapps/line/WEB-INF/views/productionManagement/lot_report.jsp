<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="ko">
<head>
<script src="/line/mock/mock-loader.js"></script>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>LOT 보고서</title>
    <%@include file="../include/pluginpage.jsp" %>
    <jsp:include page="../include/tabBar.jsp"/>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=IBM+Plex+Mono:wght@400;500&family=IBM+Plex+Sans+KR:wght@400;500;600&display=swap">
    <link rel="stylesheet" href="/line/css/opsList/ops-list.css">
<style>
/* ===== LOT 보고서 — 화면 전용 (공통: ops-list.css) ===== */
html, body.ops { height: 100%; overflow: hidden; }
.lr-page { height: calc(100vh - 57px); /* .ops-head 56px + 아래 테두리 1px */ display: flex; flex-direction: column; gap: 16px; padding: 16px 24px 24px; }
.lr-page .ops-kpi { flex-shrink: 0; }
.lr-page .ops-kpi .kpi-sub b { font-family: var(--ops-mono); font-weight: 500; color: var(--ops-fg2); font-variant-numeric: tabular-nums; }
.lr-range { color: var(--ops-fg3); font-family: var(--ops-mono); }
.ops-input.dayselect { min-width: 120px; text-align: left; }

.lr-card { flex: 1; min-height: 0; display: flex; flex-direction: column; }
.lr-card .ops-card-head { align-items: center; }
.lr-card .note { display: inline-flex; align-items: center; gap: 16px; }
.lr-card .note .mono { color: var(--ops-fg2); }
.lr-count { display: inline-flex; align-items: center; gap: 6px; }
.lr-count i { width: 6px; height: 6px; border-radius: 50%; background: var(--ops-fg3); }
.lr-count.re i { background: var(--ops-bad); }
.lr-count b { font-family: var(--ops-mono); font-weight: 500; color: var(--ops-fg); font-variant-numeric: tabular-nums; }
.lr-body { flex: 1; min-height: 0; overflow: hidden; }

/* 표 셀 */
#tablelot_report .tabulator-header-filter input { height: 24px !important; padding: 0 6px !important; font-size: 12px !important; border: 1px solid var(--ops-line) !important; border-radius: 4px !important; background: #fff !important; color: var(--ops-fg) !important; width: 100% !important; }
#tablelot_report .tabulator-header-filter input:focus { border-color: var(--ops-accent) !important; outline: none !important; }
#tablelot_report .tabulator-header-filter input::placeholder { color: var(--ops-fg3); }
#tablelot_report .tabulator-row { cursor: pointer; }
#tablelot_report .tabulator-cell.c-r { text-align: right; }
.ops .c-name { font-weight: 500; color: var(--ops-fg); }
.ops .c-sub { color: var(--ops-fg2); }
.ops .c-re { display: inline-flex; align-items: center; gap: 6px; font-family: var(--ops-mono); font-size: 12px; font-weight: 500; color: var(--ops-bad); font-variant-numeric: tabular-nums slashed-zero; }
.ops .c-re i { width: 6px; height: 6px; border-radius: 50%; background: currentColor; }
.ops .st.run { color: var(--ops-accent); }
#tablelot_report .st { font-family: var(--ops-sans); }
.pdf-btn { height: 24px; padding: 0 8px; display: inline-flex; align-items: center; gap: 4px; border: 1px solid var(--ops-line); border-radius: 4px; background: #fff; color: var(--ops-fg2); font-family: var(--ops-mono); font-size: 12px; line-height: 1; cursor: pointer; transition: background-color 80ms, border-color 80ms; }
.pdf-btn svg { width: 12px; height: 12px; stroke: currentColor; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
.pdf-btn:hover { background: var(--ops-hover); border-color: oklch(86% 0.008 255); color: var(--ops-fg); }
</style>
</head>
<body class="ops">

<header class="ops-head">
  <div class="ops-head-in">
    <h1 class="ops-title">LOT 보고서</h1>
    <span class="ops-label">조회일자</span>
    <input type="text" id="s_sdate" class="ops-input dayselect daySet" autocomplete="off"/>
    <span class="lr-range">~</span>
    <input type="text" id="s_edate" class="ops-input dayselect daySet" autocomplete="off"/>
    <button class="ops-btn primary select-button">
      <svg viewBox="0 0 24 24"><circle cx="11" cy="11" r="7"/><line x1="20" y1="20" x2="16.2" y2="16.2"/></svg>조회
    </button>
    <div class="ops-spacer"></div>
    <span class="ops-label">보고서 열의 PDF 버튼으로 LOT별 보고서를 저장합니다</span>
  </div>
</header>

<div class="lr-page">
  <!-- 요약: 첫 칸이 핵심 지표 -->
  <div class="ops-kpi">
    <div class="hero"><span class="kpi-label">총 LOT</span><span class="kpi-value" id="kpi-total">0</span><span class="kpi-sub">조회 기간 전체</span></div>
    <div><span class="kpi-label">작업 완료</span><span class="kpi-value" id="kpi-done">0</span><span class="kpi-sub">진행중 <b id="kpi-run">0</b> · 투입 전 <b id="kpi-wait">0</b></span></div>
    <div><span class="kpi-label">일반 작업</span><span class="kpi-value" id="kpi-normal">0</span><span class="kpi-sub">재처리 미포함</span></div>
    <div><span class="kpi-label">재처리 LOT</span><span class="kpi-value" id="kpi-re">0</span><span class="kpi-sub">재작업 발생 건</span></div>
    <div><span class="kpi-label">거래처</span><span class="kpi-value" id="kpi-cust">0</span><span class="kpi-sub">고유 회사 수</span></div>
  </div>

  <section class="ops-card lr-card">
    <div class="ops-card-head">
      <h2>LOT 목록</h2>
      <span class="note">
        <span class="lr-count">전체 <b id="st-total">0</b></span>
        <span class="lr-count">일반 <b id="st-normal">0</b></span>
        <span class="lr-count re"><i></i>재처리 <b id="st-re">0</b></span>
        <span class="mono" id="date-range-label">-</span>
      </span>
    </div>
    <div class="lr-body">
      <div id="tablelot_report" class="ops-table" style="height:100%;"></div>
    </div>
    <div class="ops-card-foot">
      <span id="footer-info">데이터를 조회하세요</span>
      <span>마지막 조회 <strong id="footer-time">-</strong></span>
    </div>
  </section>
</div>

<script>
let now_page_code = "b02";
let tablelot_report = null;
let selectedRowData = null;

function pad2(n){ return String(n).padStart(2,'0'); }

function updateStats(data){
  var total  = data.length;
  var re     = data.filter(function(r){ return r.w_old_lot; }).length;
  var normal = total - re;
  var custs  = {};
  data.forEach(function(r){ if(r.cust_name) custs[r.cust_name]=1; });

  document.getElementById('st-total').textContent  = total;
  document.getElementById('st-normal').textContent = normal;
  document.getElementById('st-re').textContent     = re;
  document.getElementById('kpi-total').textContent  = total;
  document.getElementById('kpi-normal').textContent = normal;
  document.getElementById('kpi-re').textContent     = re;
  document.getElementById('kpi-cust').textContent   = Object.keys(custs).length;
  // 진행 단계 (표시 전용): 작업완료 시각 → 완료, 투입 시각만 → 진행중, 그 외 → 투입 전
  var done = data.filter(function(r){ return r.l20; }).length;
  var run  = data.filter(function(r){ return !r.l20 && r.d370; }).length;
  document.getElementById('kpi-done').textContent = done;
  document.getElementById('kpi-run').textContent  = run;
  document.getElementById('kpi-wait').textContent = total - done - run;
  document.getElementById('kpi-re').classList.toggle('bad', re > 0);
  document.getElementById('footer-info').innerHTML  = '총 <strong>'+total+'</strong>건';

  var now = new Date();
  document.getElementById('footer-time').textContent = pad2(now.getHours())+':'+pad2(now.getMinutes())+':'+pad2(now.getSeconds());
  document.getElementById('date-range-label').textContent =
    document.getElementById('s_sdate').value + ' ~ ' + document.getElementById('s_edate').value;
}

// 셀 표시: 값이 없으면 흐린 대시
function lrTxt(cls){ return function(c){ var v=c.getValue(); return v||v===0 ? '<span class="'+cls+'">'+v+'</span>' : '<span class="c-none">—</span>'; }; }
// 일시: 같은 해는 "MM-DD HH:mm" 로 줄이고 전체 값은 툴팁
function lrTime(c){
  var v=c.getValue(); if(!v) return '<span class="c-none">—</span>';
  var s=String(v), m=s.match(/^\d{4}-(\d{2}-\d{2})[ T](\d{2}:\d{2})/);
  return '<span class="c-time" title="'+s+'">'+(m ? m[1]+' '+m[2] : s)+'</span>';
}
// 진행 단계 (표시 전용)
function lrStage(c){
  var d=c.getRow().getData();
  if(d.l20)  return '<span class="st ok"><i></i>완료</span>';
  if(d.d370) return '<span class="st run"><i></i>진행중</span>';
  return '<span class="st off"><i></i>투입 전</span>';
}

function initTable(){
  tablelot_report = new Tabulator("#tablelot_report", {
    layout:"fitColumns", height:"100%", selectable:1,
    filterMode:"local", headerFilterLiveFilter:true,
    columns:[
      { title:"#", field:"idx", width:48, hozAlign:"right", headerHozAlign:"right", headerSort:false, formatter:lrTxt("c-time") },
      { title:"작업일자", field:"w_date", width:104, headerSort:false, formatter:lrTxt("c-time") },
      { title:"LOT", field:"w_ci_lot", width:136, headerFilter:"input", headerFilterPlaceholder:"필터", headerSort:false, formatter:lrTxt("c-lot") },
      { title:"재처리 원LOT", field:"w_old_lot", width:150, headerSort:false,
        formatter:function(c){ var v=c.getValue(); return v?'<span class="c-re" title="재처리 · 원 LOT '+v+'"><i></i>'+v+'</span>':'<span class="c-none">—</span>'; } },
      { title:"ERP 작지번호", field:"erp_jack_no", width:136, headerFilter:"input", headerFilterPlaceholder:"필터", headerSort:false, formatter:lrTxt("c-time") },
      { title:"거래처", field:"cust_name", width:120, headerFilter:"input", headerFilterPlaceholder:"필터", headerSort:false, formatter:lrTxt("c-sub") },
      { title:"품명", field:"item_name", minWidth:160, headerFilter:"input", headerFilterPlaceholder:"필터", headerSort:false, formatter:lrTxt("c-name") },
      { title:"품번", field:"item_no", width:136, headerFilter:"input", headerFilterPlaceholder:"필터", headerSort:false, formatter:lrTxt("c-time") },
      { title:"계획 통수", field:"w_plan_cnt", width:84, hozAlign:"right", headerHozAlign:"right", headerSort:false, formatter:lrTxt("c-num") },
      { title:"상태", width:88, headerSort:false, formatter:lrStage },
      { title:"투입 시간", field:"d370", width:112, headerSort:false, formatter:lrTime },
      { title:"투입 종료", field:"x111", width:112, headerSort:false, formatter:lrTime },
      { title:"작업 완료", field:"l20", width:112, headerSort:false, formatter:lrTime },
      { title:"보고서", width:84, hozAlign:"center", headerHozAlign:"center", headerSort:false,
        formatter:function(){ return "<button class='pdf-btn' title='PDF 저장'><svg viewBox='0 0 24 24'><path d='M12 4v11'/><polyline points='7 10 12 15 17 10'/><line x1='5' y1='20' x2='19' y2='20'/></svg>PDF</button>"; },
        cellClick:function(e,cell){ var d=cell.getRow().getData(); selectedRowData=d; lotPdfDownload(d.w_ci_lot); } }
    ],
    rowClick:function(e,row){
      document.querySelectorAll('#tablelot_report .tabulator-row').forEach(function(el){ el.classList.remove('row_select'); });
      row.getElement().classList.add('row_select');
      selectedRowData = row.getData();
    }
  });
}

function fetchlot_report(){
  $.ajax({
    url:"/line/productionManagement/lot_report/list", type:"POST", dataType:"json",
    data:{ s_sdate:document.getElementById('s_sdate').value, s_edate:document.getElementById('s_edate').value },
    success:function(resp){
      var data = Array.isArray(resp)?resp:(resp.data||resp.rows||[]);
      tablelot_report.setData(data);
      updateStats(data);
    },
    error:function(xhr){ console.error("fetchlot_report error",xhr); }
  });
}

function lotPdfDownload(w_ci_lot){
  if(!w_ci_lot) return;
  $.ajax({
    url:"/line/productionManagement/lot_report/lotPrint", type:"POST", contentType:"application/json",
    data:JSON.stringify({w_ci_lot:w_ci_lot}), xhrFields:{responseType:"blob"},
    success:function(blob){
      var link=document.createElement("a"); link.href=URL.createObjectURL(blob); link.download=w_ci_lot+".pdf";
      document.body.appendChild(link); link.click(); document.body.removeChild(link); URL.revokeObjectURL(link.href);
    },
    error:function(err){ console.error("PDF 생성 실패",err); }
  });
}

$(function(){
  $("#s_sdate").val(todayDate());
  $("#s_edate").val(todayDate());
  initTable();
  fetchlot_report();
});

$('.select-button').click(function(){ fetchlot_report(); });
</script>
</body>
</html>
