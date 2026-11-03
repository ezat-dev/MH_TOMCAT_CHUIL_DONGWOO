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
    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@400;500;600;700;800&family=JetBrains+Mono:wght@400;600;700&display=swap" rel="stylesheet">
<style>
:root {
  --bg:      #f0f2f7;
  --surface: #ffffff;
  --surface2:#f7f8fc;
  --border:  #e2e6ef;
  --text-p:  #0f172a;
  --text-s:  #64748b;
  --text-m:  #94a3b8;
  --accent:  #2563eb;
  --acc-lt:  #dbeafe;
  --green:   #16a34a;
  --grn-lt:  #dcfce7;
  --red:     #dc2626;
  --red-lt:  #fee2e2;
  --teal:    #0d9488;
  --teal-lt: #ccfbf1;
  --yellow:  #d97706;
  --yel-lt:  #fef3c7;
  --shadow:  0 1px 3px rgba(0,0,0,.06);
  --radius:  12px;
}
*, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
html, body { height: 100%; font-family: 'Noto Sans KR', sans-serif; background: var(--bg); color: var(--text-p); overflow: hidden; }

/* TOPBAR */
.topbar { position:sticky; top:0; z-index:100; background:rgba(255,255,255,.97); backdrop-filter:blur(12px); border-bottom:1px solid var(--border); box-shadow:var(--shadow); }
.topbar-inner { max-width:1700px; margin:0 auto; padding:0 24px; height:54px; display:flex; align-items:center; gap:10px; flex-wrap:wrap; }
.tb-title { font-size:14px; font-weight:800; color:var(--text-p); letter-spacing:-.3px; white-space:nowrap; margin-right:6px; display:flex; align-items:center; gap:7px; }
.tb-title .icon { width:22px; height:22px; border-radius:7px; background:linear-gradient(135deg,#2563eb,#0d9488); display:flex; align-items:center; justify-content:center; }
.tb-title .icon svg { width:12px; height:12px; stroke:#fff; fill:none; stroke-width:2.5; stroke-linecap:round; stroke-linejoin:round; }
.tb-div { width:1px; height:20px; background:var(--border); flex-shrink:0; }
.tb-label { font-size:12px; font-weight:700; color:var(--text-s); white-space:nowrap; }
.tb-range { font-size:13px; color:var(--text-m); font-weight:600; }
.ctrl { height:32px; padding:0 10px; border:1px solid var(--border); border-radius:8px; background:var(--surface2); color:var(--text-p); font-size:12px; font-family:'JetBrains Mono',monospace; outline:none; transition:border-color .15s,box-shadow .15s; min-width:120px; text-align:center; }
.ctrl:focus { border-color:var(--accent); box-shadow:0 0 0 3px rgba(37,99,235,.12); }
.btn { height:32px; padding:0 13px; border-radius:8px; font-size:12px; font-family:'Noto Sans KR',sans-serif; font-weight:700; display:inline-flex; align-items:center; gap:5px; cursor:pointer; transition:filter .15s,transform .08s; white-space:nowrap; border:1px solid transparent; }
.btn:active { transform:translateY(1px); }
.btn svg { width:13px; height:13px; stroke:currentColor; fill:none; stroke-width:2.5; stroke-linecap:round; stroke-linejoin:round; flex-shrink:0; }
.btn-search { background:linear-gradient(135deg,#64748b,#475569); color:#fff; border-color:#475569; box-shadow:0 2px 6px rgba(71,85,105,.25); }
.btn:hover { filter:brightness(1.08); }
.tb-spacer { flex:1; }
.stat-chip { display:flex; align-items:center; gap:5px; padding:0 10px; height:28px; border:1px solid var(--border); border-radius:20px; background:var(--surface2); font-size:11px; }
.stat-chip .sc-dot { width:7px; height:7px; border-radius:50%; flex-shrink:0; }
.stat-chip .sc-label { color:var(--text-m); font-weight:700; letter-spacing:.3px; }
.stat-chip .sc-val { font-family:'JetBrains Mono',monospace; font-size:12px; font-weight:700; color:var(--text-p); min-width:20px; text-align:right; }

/* PAGE */
.page { height:calc(100vh - 54px); max-width:1700px; margin:0 auto; padding:16px 24px 20px; display:flex; flex-direction:column; gap:14px; overflow:hidden; }

/* KPI */
.kpi-row { display:grid; grid-template-columns:repeat(4,1fr); gap:12px; flex-shrink:0; }
.kpi-card { background:var(--surface); border:1px solid var(--border); border-radius:var(--radius); padding:14px 18px; box-shadow:var(--shadow); display:flex; align-items:center; gap:14px; position:relative; overflow:hidden; animation:fadeUp .3s ease both; }
.kpi-card::before { content:''; position:absolute; top:0; left:0; right:0; height:3px; border-radius:var(--radius) var(--radius) 0 0; }
.kpi-card:nth-child(1){ animation-delay:.04s; } .kpi-card:nth-child(1)::before{ background:linear-gradient(90deg,#2563eb,#60a5fa); }
.kpi-card:nth-child(2){ animation-delay:.08s; } .kpi-card:nth-child(2)::before{ background:linear-gradient(90deg,#16a34a,#4ade80); }
.kpi-card:nth-child(3){ animation-delay:.12s; } .kpi-card:nth-child(3)::before{ background:linear-gradient(90deg,#dc2626,#f87171); }
.kpi-card:nth-child(4){ animation-delay:.16s; } .kpi-card:nth-child(4)::before{ background:linear-gradient(90deg,#0d9488,#2dd4bf); }
@keyframes fadeUp { from{opacity:0;transform:translateY(10px);}to{opacity:1;transform:none;} }
.kpi-icon { width:38px; height:38px; border-radius:10px; display:flex; align-items:center; justify-content:center; flex-shrink:0; }
.kpi-icon svg { width:18px; height:18px; stroke:currentColor; fill:none; stroke-width:2; stroke-linecap:round; stroke-linejoin:round; }
.kpi-card:nth-child(1) .kpi-icon { background:var(--acc-lt); color:var(--accent); }
.kpi-card:nth-child(2) .kpi-icon { background:var(--grn-lt); color:var(--green); }
.kpi-card:nth-child(3) .kpi-icon { background:var(--red-lt); color:var(--red); }
.kpi-card:nth-child(4) .kpi-icon { background:var(--teal-lt); color:var(--teal); }
.kpi-info { display:flex; flex-direction:column; gap:2px; }
.kpi-lbl { font-size:11px; font-weight:700; color:var(--text-m); letter-spacing:.5px; text-transform:uppercase; }
.kpi-val { font-family:'JetBrains Mono',monospace; font-size:26px; font-weight:700; color:var(--text-p); letter-spacing:-1px; line-height:1; }
.kpi-sub { font-size:11px; color:var(--text-m); margin-top:2px; }

/* TABLE CARD */
.table-card { flex:1; min-height:0; background:var(--surface); border:1px solid var(--border); border-radius:var(--radius); box-shadow:var(--shadow); overflow:hidden; display:flex; flex-direction:column; animation:fadeUp .35s .2s ease both; }
.card-head { padding:12px 20px; border-bottom:1px solid var(--border); display:flex; align-items:center; justify-content:space-between; flex-shrink:0; }
.card-head-title { font-size:13px; font-weight:800; color:var(--text-p); }
.card-foot { padding:8px 16px; border-top:1px solid var(--border); flex-shrink:0; background:var(--surface2); display:flex; align-items:center; justify-content:space-between; font-size:11px; color:var(--text-m); font-family:'JetBrains Mono',monospace; }
.card-foot strong { color:var(--text-p); }

/* TABULATOR */
#tablelot_report .tabulator { border:none !important; font-family:'Noto Sans KR',sans-serif !important; font-size:13px !important; box-shadow:none !important; }
#tablelot_report .tabulator-header { background:var(--surface2) !important; border-bottom:2px solid var(--border) !important; }
#tablelot_report .tabulator-col { background:var(--surface2) !important; border-right:1px solid var(--border) !important; font-size:10px !important; font-weight:800 !important; color:var(--text-s) !important; text-transform:uppercase !important; letter-spacing:.5px !important; }
#tablelot_report .tabulator-col-title { padding:9px 8px !important; }
#tablelot_report .tabulator-row { background:var(--surface) !important; border-bottom:1px solid var(--border) !important; transition:background .1s !important; cursor:pointer; }
#tablelot_report .tabulator-row:hover { background:#f8faff !important; }
#tablelot_report .tabulator-row.row_select { background:#dbeafe !important; border-left:2px solid var(--accent) !important; }
#tablelot_report .tabulator-cell { padding:9px 10px !important; border-right:1px solid #f1f5f9 !important; color:var(--text-p) !important; }
#tablelot_report .tabulator-placeholder { color:var(--text-m) !important; font-size:13px !important; }
#tablelot_report .tabulator-header-filter input { height:24px !important; padding:0 6px !important; font-size:11px !important; border:1px solid var(--border) !important; border-radius:5px !important; background:var(--surface) !important; color:var(--text-p) !important; width:100% !important; }
#tablelot_report .tabulator-header-filter input:focus { border-color:var(--accent) !important; outline:none !important; }

/* 셀 배지 */
.lot-tag  { font-family:'JetBrains Mono',monospace; font-size:11px; font-weight:600; padding:2px 8px; border-radius:5px; background:var(--acc-lt); border:1px solid #bfdbfe; color:var(--accent); display:inline-block; }
.re-tag   { font-family:'JetBrains Mono',monospace; font-size:11px; font-weight:700; padding:2px 8px; border-radius:5px; background:var(--red-lt); border:1px solid #fca5a5; color:var(--red); display:inline-block; }
.erp-tag  { font-family:'JetBrains Mono',monospace; font-size:11px; color:var(--text-s); }
.date-tag { font-family:'JetBrains Mono',monospace; font-size:11px; color:var(--text-s); }
.time-tag { font-family:'JetBrains Mono',monospace; font-size:11px; color:var(--teal); font-weight:600; }
.cnt-tag  { font-family:'JetBrains Mono',monospace; font-size:12px; font-weight:700; color:var(--accent); }
.name-cell { font-size:12px; font-weight:600; color:var(--text-p); }
.cust-cell { font-size:12px; color:var(--text-s); }
.pdf-btn  { width:28px; height:24px; border-radius:6px; border:1px solid var(--border); background:var(--surface2); cursor:pointer; display:inline-flex; align-items:center; justify-content:center; font-size:14px; transition:background .15s,border-color .15s,transform .08s; }
.pdf-btn:hover { background:var(--yel-lt); border-color:#fcd34d; transform:scale(1.08); }
.pdf-btn:active { transform:scale(.96); }
</style>
</head>
<body>

<div class="topbar">
  <div class="topbar-inner">
    <div class="tb-title">
      <span class="icon">
        <svg viewBox="0 0 24 24"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/></svg>
      </span>
      LOT 보고서
    </div>
    <div class="tb-div"></div>
    <span class="tb-label">조회일자</span>
    <input type="text" id="s_sdate" class="ctrl dayselect daySet" autocomplete="off"/>
    <span class="tb-range">~</span>
    <input type="text" id="s_edate" class="ctrl dayselect daySet" autocomplete="off"/>
    <button class="btn btn-search select-button">
      <svg viewBox="0 0 24 24"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>조회
    </button>
    <div class="tb-spacer"></div>
    <div class="stat-chip">
      <span class="sc-dot" style="background:#2563eb;"></span>
      <span class="sc-label">전체</span>
      <span class="sc-val" id="st-total">0</span>
    </div>
    <div class="stat-chip">
      <span class="sc-dot" style="background:#16a34a;"></span>
      <span class="sc-label">일반</span>
      <span class="sc-val" id="st-normal">0</span>
    </div>
    <div class="stat-chip">
      <span class="sc-dot" style="background:#dc2626;"></span>
      <span class="sc-label">재처리</span>
      <span class="sc-val" id="st-re">0</span>
    </div>
  </div>
</div>

<div class="page">
  <div class="kpi-row">
    <div class="kpi-card">
      <div class="kpi-icon"><svg viewBox="0 0 24 24"><line x1="8" y1="6" x2="21" y2="6"/><line x1="8" y1="12" x2="21" y2="12"/><line x1="8" y1="18" x2="21" y2="18"/><line x1="3" y1="6" x2="3.01" y2="6"/><line x1="3" y1="12" x2="3.01" y2="12"/><line x1="3" y1="18" x2="3.01" y2="18"/></svg></div>
      <div class="kpi-info"><div class="kpi-lbl">총 LOT</div><div class="kpi-val" id="kpi-total">0</div><div class="kpi-sub">조회 기간 전체</div></div>
    </div>
    <div class="kpi-card">
      <div class="kpi-icon"><svg viewBox="0 0 24 24"><polyline points="20 6 9 17 4 12"/></svg></div>
      <div class="kpi-info"><div class="kpi-lbl">일반 작업</div><div class="kpi-val" id="kpi-normal">0</div><div class="kpi-sub">재처리 미포함</div></div>
    </div>
    <div class="kpi-card">
      <div class="kpi-icon"><svg viewBox="0 0 24 24"><polyline points="1 4 1 10 7 10"/><path d="M3.51 15a9 9 0 1 0 .49-3.57"/></svg></div>
      <div class="kpi-info"><div class="kpi-lbl">재처리 LOT</div><div class="kpi-val" id="kpi-re">0</div><div class="kpi-sub">재작업 발생 건</div></div>
    </div>
    <div class="kpi-card">
      <div class="kpi-icon"><svg viewBox="0 0 24 24"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg></div>
      <div class="kpi-info"><div class="kpi-lbl">거래처 수</div><div class="kpi-val" id="kpi-cust">0</div><div class="kpi-sub">고유 회사</div></div>
    </div>
  </div>

  <div class="table-card">
    <div class="card-head">
      <span class="card-head-title">📋 LOT 목록</span>
      <span style="font-size:11px; color:var(--text-m);" id="date-range-label">-</span>
    </div>
    <div style="flex:1; min-height:0; overflow:hidden;">
      <div id="tablelot_report" style="height:100%;"></div>
    </div>
    <div class="card-foot">
      <span id="footer-info">데이터를 조회하세요</span>
      <span>마지막 조회: <strong id="footer-time">-</strong></span>
    </div>
  </div>
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
  document.getElementById('footer-info').innerHTML  = '총 <strong>'+total+'</strong>건';

  var now = new Date();
  document.getElementById('footer-time').textContent = pad2(now.getHours())+':'+pad2(now.getMinutes())+':'+pad2(now.getSeconds());
  document.getElementById('date-range-label').textContent =
    document.getElementById('s_sdate').value + ' ~ ' + document.getElementById('s_edate').value;
}

function initTable(){
  tablelot_report = new Tabulator("#tablelot_report", {
    layout:"fitColumns", height:"100%", selectable:1,
    filterMode:"local", headerFilterLiveFilter:true,
    columns:[
      { title:"No", field:"idx", width:50, hozAlign:"center", headerHozAlign:"center", headerSort:false },
      { title:"작업일자", field:"w_date", width:110, hozAlign:"center", headerHozAlign:"center", headerSort:false,
        formatter:function(c){ return c.getValue()?'<span class="date-tag">'+c.getValue()+'</span>':''; } },
      { title:"LOT", field:"w_ci_lot", width:130, hozAlign:"center", headerHozAlign:"center", headerFilter:"input", headerSort:false,
        formatter:function(c){ return c.getValue()?'<span class="lot-tag">'+c.getValue()+'</span>':''; } },
      { title:"재처리", field:"w_old_lot", width:130, hozAlign:"center", headerHozAlign:"center", headerSort:false,
        formatter:function(c){ var v=c.getValue(); return v?'<span class="re-tag">↺ '+v+'</span>':''; } },
      { title:"ERP 작지번호", field:"erp_jack_no", width:130, hozAlign:"center", headerHozAlign:"center", headerFilter:"input", headerSort:false,
        formatter:function(c){ return c.getValue()?'<span class="erp-tag">'+c.getValue()+'</span>':''; } },
      { title:"거래처", field:"cust_name", width:130, hozAlign:"center", headerHozAlign:"center", headerFilter:"input", headerSort:false,
        formatter:function(c){ return c.getValue()?'<span class="cust-cell">'+c.getValue()+'</span>':''; } },
      { title:"품명", field:"item_name", width:170, hozAlign:"left", headerHozAlign:"center", headerFilter:"input", headerSort:false,
        formatter:function(c){ return c.getValue()?'<span class="name-cell">'+c.getValue()+'</span>':''; } },
      { title:"품번", field:"item_no", width:160, hozAlign:"left", headerHozAlign:"center", headerFilter:"input", headerSort:false,
        formatter:function(c){ return c.getValue()?'<span class="erp-tag">'+c.getValue()+'</span>':''; } },
      { title:"계획</br>통수", field:"w_plan_cnt", width:50, hozAlign:"center", headerHozAlign:"center", headerSort:false,
        formatter:function(c){ return c.getValue()?'<span class="cnt-tag">'+c.getValue()+'</span>':''; } },
      { title:"투입 시간", field:"d370", width:170, hozAlign:"center", headerHozAlign:"center", headerSort:false,
        formatter:function(c){ return c.getValue()?'<span class="time-tag">'+c.getValue()+'</span>':''; } },
      { title:"투입종료", field:"x111", width:170, hozAlign:"center", headerHozAlign:"center", headerSort:false,
        formatter:function(c){ return c.getValue()?'<span class="time-tag">'+c.getValue()+'</span>':''; } },
      { title:"작업완료", field:"l20", width:170, hozAlign:"center", headerHozAlign:"center", headerSort:false,
        formatter:function(c){ return c.getValue()?'<span class="time-tag">'+c.getValue()+'</span>':''; } },
      { title:"PDF", width:60, hozAlign:"center", headerHozAlign:"center", headerSort:false,
        formatter:function(){ return "<button class='pdf-btn' title='PDF 저장'>💾</button>"; },
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
