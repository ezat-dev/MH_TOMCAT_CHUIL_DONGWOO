<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<script src="/line/mock/mock-loader.js"></script>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>제품별작업관리</title>
<%@include file="../include/pluginpage.jsp"%>
<jsp:include page="../include/tabBar.jsp" />
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@400;500;600;700&display=swap" rel="stylesheet">
<style>
:root{
  --bg:#f3f5f8; --surface:#fff; --subtle:#f8fafc; --border:#e3e7ed; --border-strong:#cfd6df;
  --text:#1e293b; --text-2:#475569; --text-3:#8492a6;
  --accent:#2563eb; --accent-soft:#e8effd; --accent-muted:#93b4f5;
  --amber:#b45309; --amber-soft:#fef3e2; --red:#b91c1c; --red-soft:#fdecec;
  --green:#15803d; --green-soft:#e8f5ec;
  --radius:8px;
  --font:'Pretendard','Noto Sans KR','Malgun Gothic','맑은 고딕',sans-serif;
}
*{box-sizing:border-box;margin:0;padding:0;}
html,body{height:100%;}
body{font-family:var(--font);font-size:13px;color:var(--text);background:var(--bg);
  -webkit-font-smoothing:antialiased;overflow:hidden;display:flex;flex-direction:column;}
.num{font-variant-numeric:tabular-nums;}

/* ── 상단 필터바 ── */
.filterbar{position:sticky;top:0;z-index:50;background:var(--surface);border-bottom:1px solid var(--border);}
.filterbar-inner{height:52px;padding:0 20px;display:flex;align-items:center;gap:16px;}
.page-title{display:flex;align-items:baseline;gap:8px;white-space:nowrap;}
.page-title h1{font-size:15px;font-weight:700;letter-spacing:-.2px;}
.page-title span{font-size:12px;color:var(--text-3);}
.vsep{width:1px;height:20px;background:var(--border);}
.fgroup{display:flex;align-items:center;gap:6px;}
.fgroup label{font-size:12px;font-weight:600;color:var(--text-2);white-space:nowrap;}
.ctrl{height:30px;padding:0 9px;border:1px solid var(--border-strong);border-radius:6px;background:#fff;
  font:13px var(--font);color:var(--text);outline:none;width:140px;}
.ctrl.date{width:110px;font-variant-numeric:tabular-nums;}
.ctrl:focus{border-color:var(--accent);box-shadow:0 0 0 3px rgba(37,99,235,.12);}
.ctrl::placeholder{color:#a8b3c2;}
.tilde{color:var(--text-3);}
.fspacer{flex:1;}
.btn{height:30px;padding:0 14px;border-radius:6px;font:600 13px var(--font);cursor:pointer;
  display:inline-flex;align-items:center;gap:6px;border:1px solid var(--border-strong);background:#fff;color:var(--text-2);white-space:nowrap;}
.btn:hover{background:var(--subtle);}
.btn svg{width:14px;height:14px;}
.btn-primary{background:var(--accent);border-color:var(--accent);color:#fff;}
.btn-primary:hover{background:#1d4ed8;}

/* ── 페이지 레이아웃 ── */
.page{flex:1;min-height:0;padding:14px 20px;display:flex;flex-direction:column;gap:12px;}
.card{background:var(--surface);border:1px solid var(--border);border-radius:var(--radius);}
.card-head{height:42px;padding:0 16px;display:flex;align-items:center;gap:10px;border-bottom:1px solid var(--border);flex-shrink:0;}
.card-title{font-size:13px;font-weight:700;}
.card-meta{font-size:12px;color:var(--text-3);}
.card-head .right{margin-left:auto;display:flex;align-items:center;gap:8px;}

/* KPI */
.kpi-row{display:grid;grid-template-columns:repeat(5,minmax(0,1fr));gap:12px;flex-shrink:0;}
.kpi{padding:12px 16px;display:flex;flex-direction:column;gap:6px;min-width:0;}
.kpi-label{font-size:12px;font-weight:600;color:var(--text-2);}
.kpi-value{font-size:22px;font-weight:700;line-height:1.1;letter-spacing:-.3px;font-variant-numeric:tabular-nums;
  white-space:nowrap;overflow:hidden;text-overflow:ellipsis;}
.kpi-value small{font-size:13px;font-weight:500;color:var(--text-3);margin-left:3px;}
.kpi-value.text{font-size:17px;padding-top:3px;}
.kpi-sub{font-size:12px;color:var(--text-3);white-space:nowrap;overflow:hidden;text-overflow:ellipsis;font-variant-numeric:tabular-nums;}
.kpi-sub b{font-weight:600;color:var(--text-2);}
.meter{height:4px;background:#edf0f4;border-radius:2px;overflow:hidden;margin-top:2px;}
.meter i{display:block;height:100%;background:var(--accent);width:0;transition:width .4s;}
.meter.warn i{background:#d97706;}
.dot{display:inline-block;width:6px;height:6px;border-radius:50%;margin:0 4px 1px 8px;vertical-align:middle;}
.dot:first-child{margin-left:0;}

/* 본문 그리드 */
.main{flex:1;min-height:0;display:grid;grid-template-columns:minmax(0,1fr) 320px;gap:12px;}
.col{display:flex;flex-direction:column;gap:12px;min-height:0;min-width:0;}
.chart-card{height:232px;flex-shrink:0;display:flex;flex-direction:column;}
#dailyChart{flex:1;min-height:0;padding:4px 8px 0;}
.legend{display:flex;gap:14px;font-size:12px;color:var(--text-2);}
.legend span{display:inline-flex;align-items:center;gap:6px;}
.legend i{width:10px;height:10px;border-radius:2px;display:inline-block;}

.table-card{flex:1;min-height:0;display:flex;flex-direction:column;overflow:hidden;}
#tableWrap{flex:1;min-height:0;position:relative;}
#tableWrap > #tableproduct_report{position:absolute;inset:0;}
.card-foot{height:34px;padding:0 16px;border-top:1px solid var(--border);display:flex;align-items:center;justify-content:space-between;
  font-size:12px;color:var(--text-3);flex-shrink:0;background:var(--subtle);font-variant-numeric:tabular-nums;}
.card-foot b{color:var(--text);font-weight:600;}
.search{height:28px;width:200px;padding:0 9px 0 28px;border:1px solid var(--border-strong);border-radius:6px;font:12px var(--font);outline:none;
  background:#fff url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='13' height='13' viewBox='0 0 24 24' fill='none' stroke='%238492a6' stroke-width='2' stroke-linecap='round'%3E%3Ccircle cx='11' cy='11' r='7'/%3E%3Cline x1='20' y1='20' x2='16.5' y2='16.5'/%3E%3C/svg%3E") no-repeat 9px center;}
.search:focus{border-color:var(--accent);box-shadow:0 0 0 3px rgba(37,99,235,.12);}
.chip{display:none;align-items:center;gap:6px;height:24px;padding:0 6px 0 10px;border-radius:12px;background:var(--accent-soft);
  color:var(--accent);font-size:12px;font-weight:600;}
.chip.on{display:inline-flex;}
.chip button{border:0;background:transparent;color:var(--accent);cursor:pointer;font-size:14px;line-height:1;padding:0 2px;}

/* 랭킹 */
.rank-card{display:flex;flex-direction:column;min-height:0;}
.rank-list{flex:1;min-height:0;overflow-y:auto;padding:6px 0;}
.rank-item{display:grid;grid-template-columns:22px minmax(0,1fr) auto;column-gap:10px;row-gap:5px;align-items:center;
  padding:8px 16px;cursor:pointer;border-left:2px solid transparent;}
.rank-item:hover{background:var(--subtle);}
.rank-item.active{background:var(--accent-soft);border-left-color:var(--accent);}
.rank-no{font-size:12px;font-weight:700;color:var(--text-3);text-align:center;font-variant-numeric:tabular-nums;}
.rank-item.top .rank-no{color:var(--text);}
.rank-name{font-size:13px;font-weight:600;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;}
.rank-name em{font-style:normal;font-weight:400;font-size:12px;color:var(--text-3);margin-left:6px;}
.rank-val{font-size:13px;font-weight:600;text-align:right;font-variant-numeric:tabular-nums;}
.rank-val small{font-size:11px;font-weight:400;color:var(--text-3);margin-left:4px;}
.rank-bar{grid-column:2 / 4;height:4px;background:#edf0f4;border-radius:2px;overflow:hidden;}
.rank-bar i{display:block;height:100%;background:var(--accent-muted);width:0;transition:width .4s;}
.rank-item.top .rank-bar i{background:var(--accent);}
.empty{padding:40px 16px;text-align:center;color:var(--text-3);font-size:13px;}

/* 상태 배지 */
.badge{display:inline-block;min-width:44px;padding:1px 8px;border-radius:4px;font-size:12px;font-weight:600;text-align:center;line-height:18px;}
.badge.done{background:var(--green-soft);color:var(--green);}
.badge.run{background:var(--accent-soft);color:var(--accent);}
.badge.wait{background:#eef1f5;color:var(--text-2);}
.re-lot{color:var(--amber);font-weight:600;}

/* Tabulator */
#tableproduct_report.tabulator{border:0;background:#fff;font-family:var(--font);font-size:13px;}
#tableproduct_report .tabulator-header{background:var(--subtle);border-bottom:1px solid var(--border);color:var(--text-2);}
#tableproduct_report .tabulator-header .tabulator-col{background:var(--subtle);border-right:1px solid #edf0f4;}
#tableproduct_report .tabulator-header .tabulator-col .tabulator-col-content{padding:7px 8px 6px;}
#tableproduct_report .tabulator-col-title{font-size:12px;font-weight:600;}
#tableproduct_report .tabulator-header-filter{margin-top:5px;}
#tableproduct_report .tabulator-header-filter input{height:24px;padding:0 6px;font:12px var(--font);border:1px solid var(--border);
  border-radius:4px;background:#fff;width:100%;outline:none;}
#tableproduct_report .tabulator-header-filter input:focus{border-color:var(--accent);}
#tableproduct_report .tabulator-row{border-bottom:1px solid #eef1f4;min-height:34px;}
#tableproduct_report .tabulator-row.tabulator-row-even{background:#fff;}
#tableproduct_report .tabulator-row:hover{background:#f5f8fd;}
#tableproduct_report .tabulator-row.tabulator-selected{background:var(--accent-soft);}
#tableproduct_report .tabulator-cell{padding:8px 8px;border-right:0;font-variant-numeric:tabular-nums;}
#tableproduct_report .tabulator-placeholder span{color:var(--text-3);font-size:13px;font-weight:400;}
#tableproduct_report .tabulator-tableholder::-webkit-scrollbar{width:8px;height:8px;}
#tableproduct_report .tabulator-tableholder::-webkit-scrollbar-thumb{background:#d4dae2;border-radius:4px;}
.muted{color:var(--text-3);}
</style>
</head>
<body>

<!-- 필터바 -->
<div class="filterbar">
  <div class="filterbar-inner">
    <div class="page-title"><h1>제품별 작업관리</h1><span>생산관리</span></div>
    <div class="vsep"></div>
    <div class="fgroup">
      <label for="s_sdate">작업일자</label>
      <input type="text" id="s_sdate" class="ctrl date daySet" autocomplete="off" readonly/>
      <span class="tilde">~</span>
      <input type="text" id="s_edate" class="ctrl date daySet" autocomplete="off" readonly/>
    </div>
    <div class="fgroup">
      <label for="item_name">제품명</label>
      <input type="text" id="item_name" class="ctrl" placeholder="전체"/>
    </div>
    <div class="fgroup">
      <label for="item_no">품번</label>
      <input type="text" id="item_no" class="ctrl" placeholder="전체"/>
    </div>
    <button class="btn btn-primary select-button" type="button">
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round"><circle cx="11" cy="11" r="7"/><line x1="20" y1="20" x2="16.5" y2="16.5"/></svg>조회
    </button>
    <div class="fspacer"></div>
    <button class="btn excel-button" type="button">
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 4v11"/><polyline points="7 10 12 15 17 10"/><path d="M5 19h14"/></svg>엑셀 다운로드
    </button>
  </div>
</div>

<div class="page">

  <!-- KPI -->
  <div class="kpi-row">
    <div class="card kpi">
      <div class="kpi-label">작업 건수</div>
      <div class="kpi-value"><span id="kpi-total">0</span><small>건</small></div>
      <div class="kpi-sub" id="kpi-status">-</div>
    </div>
    <div class="card kpi">
      <div class="kpi-label">계획 통수</div>
      <div class="kpi-value"><span id="kpi-plan">0</span><small>통</small></div>
      <div class="kpi-sub" id="kpi-plan-sub">일평균 -</div>
    </div>
    <div class="card kpi">
      <div class="kpi-label">투입 통수</div>
      <div class="kpi-value"><span id="kpi-input">0</span><small>통</small></div>
      <div class="kpi-sub" id="kpi-input-sub">잔여 -</div>
    </div>
    <div class="card kpi">
      <div class="kpi-label">투입률</div>
      <div class="kpi-value"><span id="kpi-rate">0.0</span><small>%</small></div>
      <div class="meter" id="kpi-meter"><i></i></div>
    </div>
    <div class="card kpi">
      <div class="kpi-label">최다 투입 품목</div>
      <div class="kpi-value text" id="kpi-top">-</div>
      <div class="kpi-sub" id="kpi-top-sub">-</div>
    </div>
  </div>

  <div class="main">
    <div class="col">
      <!-- 일자별 차트 -->
      <div class="card chart-card">
        <div class="card-head">
          <span class="card-title">일자별 계획 대비 투입</span>
          <span class="card-meta" id="chart-meta">-</span>
          <div class="right legend">
            <span><i style="background:#cbd5e1"></i>계획 통수</span>
            <span><i style="background:#2563eb"></i>투입 통수</span>
          </div>
        </div>
        <div id="dailyChart"></div>
      </div>

      <!-- 작업 목록 -->
      <div class="card table-card">
        <div class="card-head">
          <span class="card-title">작업 목록</span>
          <span class="card-meta" id="table-meta"></span>
          <div class="right">
            <span class="chip" id="rankChip"><span id="rankChipText"></span><button type="button" id="rankChipClear" title="필터 해제">&times;</button></span>
            <input type="text" class="search" id="tableSearch" placeholder="품명 / 품번 / 회사명">
          </div>
        </div>
        <div id="tableWrap"><div id="tableproduct_report"></div></div>
        <div class="card-foot">
          <span id="footer-info">-</span>
          <span>최종 조회 <b id="footer-time">-</b></span>
        </div>
      </div>
    </div>

    <!-- 제품 랭킹 -->
    <div class="card rank-card">
      <div class="card-head">
        <span class="card-title">제품별 투입 순위</span>
        <span class="card-meta" id="rank-subtitle">투입 통수 기준</span>
      </div>
      <div class="rank-list" id="rankList"><div class="empty">데이터를 조회하세요.</div></div>
      <div class="card-foot"><span id="rank-foot">-</span><span>클릭 시 목록 필터</span></div>
    </div>
  </div>
</div>

<script>
let now_page_code = "c04";
let productTable = null;
let allData = [];
let dailyChart = null;
let rankFilter = null;

function pad2(n){ return String(n).padStart(2,'0'); }
function formatDate(d){ return d.getFullYear()+'-'+pad2(d.getMonth()+1)+'-'+pad2(d.getDate()); }
function fmt(n){ return (Number(n)||0).toLocaleString(); }
function esc(s){ return String(s==null?'':s).replace(/[&<>"]/g,function(c){return {'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;'}[c];}); }

/* 초기 날짜: 7일 전 ~ 오늘 */
(function(){
  var t = new Date(), w = new Date(); w.setDate(t.getDate()-2); /* 데모: 기본 조회 = 최근 3일 */
  document.getElementById('s_sdate').value = formatDate(w);
  document.getElementById('s_edate').value = formatDate(t);
})();

function getSearchParams(){
  return {
    s_sdate:   document.getElementById('s_sdate').value,
    s_edate:   document.getElementById('s_edate').value,
    item_name: document.getElementById('item_name').value,
    item_no:   document.getElementById('item_no').value
  };
}

function dayList(){
  var s = document.getElementById('s_sdate').value, e = document.getElementById('s_edate').value, out = [];
  if(!s || !e) return out;
  var d = new Date(s+'T00:00:00'), end = new Date(e+'T00:00:00');
  while(d <= end && out.length < 62){ out.push(formatDate(d)); d.setDate(d.getDate()+1); }
  return out;
}

/* KPI */
function updateKpi(data){
  var plan = 0, input = 0, st = {'완료':0,'진행중':0,'대기':0}, itemMap = {};
  data.forEach(function(r){
    plan += Number(r.w_plan_cnt)||0; input += Number(r.play_cnt)||0;
    if(st[r.status] != null) st[r.status]++;
    var k = r.item_name || '-'; itemMap[k] = (itemMap[k]||0) + (Number(r.play_cnt)||0);
  });
  var days = Math.max(1, dayList().length);
  var rate = plan ? input/plan*100 : 0;

  document.getElementById('kpi-total').textContent = fmt(data.length);
  document.getElementById('kpi-status').innerHTML =
    '<span class="dot" style="background:#15803d"></span>완료 <b>'+st['완료']+'</b>'+
    '<span class="dot" style="background:#2563eb"></span>진행 <b>'+st['진행중']+'</b>'+
    '<span class="dot" style="background:#94a3b8"></span>대기 <b>'+st['대기']+'</b>';
  document.getElementById('kpi-plan').textContent = fmt(plan);
  document.getElementById('kpi-plan-sub').innerHTML = '일평균 <b>'+(plan/days).toFixed(1)+'</b>통 · '+days+'일';
  document.getElementById('kpi-input').textContent = fmt(input);
  document.getElementById('kpi-input-sub').innerHTML = '잔여 <b>'+fmt(Math.max(0,plan-input))+'</b>통';
  document.getElementById('kpi-rate').textContent = rate.toFixed(1);
  var meter = document.getElementById('kpi-meter');
  meter.classList.toggle('warn', plan > 0 && rate < 80);
  meter.querySelector('i').style.width = Math.min(100, rate) + '%';

  var top = '-', topCnt = 0;
  Object.keys(itemMap).forEach(function(k){ if(itemMap[k] > topCnt){ topCnt = itemMap[k]; top = k; } });
  var el = document.getElementById('kpi-top'); el.textContent = top; el.title = top;
  document.getElementById('kpi-top-sub').innerHTML = topCnt
    ? '투입 <b>'+fmt(topCnt)+'</b>통 · 비중 '+(input ? (topCnt/input*100).toFixed(1) : '0.0')+'%' : '-';
}

/* 랭킹 */
function renderRanking(data){
  var rankEl = document.getElementById('rankList'), map = {}, total = 0;
  data.forEach(function(r){
    var k = (r.item_name || '(없음)').trim();
    if(!map[k]) map[k] = { name:k, no:r.item_no||'', cnt:0, plan:0 };
    map[k].cnt += Number(r.play_cnt)||0; map[k].plan += Number(r.w_plan_cnt)||0;
    total += Number(r.play_cnt)||0;
  });
  var sorted = Object.values(map).sort(function(a,b){ return b.cnt - a.cnt || b.plan - a.plan; });
  if(!sorted.length){ rankEl.innerHTML = '<div class="empty">조회된 데이터가 없습니다.</div>'; document.getElementById('rank-subtitle').textContent='투입 통수 기준'; return; }
  var max = sorted[0].cnt || 1, top = sorted.slice(0, 12), html = '';
  top.forEach(function(it, i){
    html += '<div class="rank-item'+(i<3?' top':'')+(rankFilter===it.name?' active':'')+'" data-name="'+esc(it.name)+'" title="클릭하여 목록 필터">'+
      '<span class="rank-no">'+(i+1)+'</span>'+
      '<span class="rank-name">'+esc(it.name)+'<em>'+esc(it.no)+'</em></span>'+
      '<span class="rank-val">'+fmt(it.cnt)+'<small>'+(total ? (it.cnt/total*100).toFixed(1) : '0.0')+'%</small></span>'+
      '<span class="rank-bar"><i data-w="'+Math.round(it.cnt/max*100)+'%"></i></span>'+
    '</div>';
  });
  rankEl.innerHTML = html;
  requestAnimationFrame(function(){ rankEl.querySelectorAll('.rank-bar i').forEach(function(b){ b.style.width = b.getAttribute('data-w'); }); });
  document.getElementById('rank-subtitle').textContent = '투입 통수 기준 · 상위 ' + top.length + '개';
  var top3 = sorted.slice(0,3).reduce(function(a,x){ return a + x.cnt; }, 0);
  document.getElementById('rank-foot').innerHTML = '품목 <b>'+sorted.length+'</b>개 · 상위 3개 비중 <b>'+(total ? (top3/total*100).toFixed(1) : '0.0')+'%</b>';
}

/* 차트 */
function renderChart(data){
  var days = dayList(), plan = {}, input = {};
  days.forEach(function(d){ plan[d] = 0; input[d] = 0; });
  data.forEach(function(r){
    var d = (r.w_date||'').substring(0,10);
    if(plan[d] == null) return;
    plan[d] += Number(r.w_plan_cnt)||0; input[d] += Number(r.play_cnt)||0;
  });
  var cats = days.map(function(d){ return d.substring(5).replace('-','/'); });
  var p = days.map(function(d){ return plan[d]; }), q = days.map(function(d){ return input[d]; });
  document.getElementById('chart-meta').textContent = days.length ? days[0] + ' ~ ' + days[days.length-1] : '-';

  if(dailyChart){
    dailyChart.xAxis[0].setCategories(cats, false);
    dailyChart.series[0].setData(p, false);
    dailyChart.series[1].setData(q, false);
    dailyChart.redraw();
    return;
  }
  dailyChart = Highcharts.chart('dailyChart', {
    chart:{ type:'column', backgroundColor:'transparent', spacing:[12,8,8,4], style:{ fontFamily:"'Pretendard','Noto Sans KR','Malgun Gothic',sans-serif" }, animation:false },
    title:{ text:null }, credits:{ enabled:false }, legend:{ enabled:false }, exporting:{ enabled:false },
    xAxis:{ categories:cats, lineColor:'#cfd6df', tickLength:0, labels:{ style:{ color:'#64748b', fontSize:'12px' } } },
    yAxis:{ title:{ text:null }, gridLineColor:'#eef1f4', allowDecimals:false, labels:{ style:{ color:'#8492a6', fontSize:'11px' } } },
    tooltip:{ shared:true, backgroundColor:'#fff', borderColor:'#cfd6df', borderRadius:6, shadow:false,
      style:{ fontSize:'12px', color:'#1e293b' },
      formatter:function(){
        var s = '<b>'+this.x+'</b>', pl = this.points[0] ? this.points[0].y : 0, inp = this.points[1] ? this.points[1].y : 0;
        this.points.forEach(function(pt){ s += '<br/><span style="color:'+pt.color+'">■</span> '+pt.series.name+': <b>'+pt.y+'</b>통'; });
        if(pl) s += '<br/>투입률: <b>'+(inp/pl*100).toFixed(1)+'%</b>';
        return s;
      } },
    plotOptions:{ column:{ grouping:true, groupPadding:0.18, pointPadding:0.04, borderWidth:0, borderRadius:2, maxPointWidth:28, animation:false } },
    series:[
      { name:'계획 통수', data:p, color:'#cbd5e1' },
      { name:'투입 통수', data:q, color:'#2563eb' }
    ]
  });
}

function updateFooter(){
  var now = new Date();
  document.getElementById('footer-time').textContent = pad2(now.getHours())+':'+pad2(now.getMinutes())+':'+pad2(now.getSeconds());
  updateCount();
}
function updateCount(){
  if(!productTable) return;
  var shown = productTable.getDataCount('active');
  document.getElementById('footer-info').innerHTML = '전체 <b>'+fmt(allData.length)+'</b>건' + (shown !== allData.length ? ' · 표시 <b>'+fmt(shown)+'</b>건' : '');
  document.getElementById('table-meta').textContent = allData.length ? fmt(shown)+'건' : '';
}

/* 테이블 */
function numFmt(cell){ var v = cell.getValue(); return (v===''||v==null) ? '' : fmt(v); }
function initProductTable(){
  productTable = new Tabulator("#tableproduct_report", {
    height: '100%',
    layout: "fitColumns",
    ajaxURL: "/line/productionManagement/product_report/list",
    ajaxConfig: "POST",
    ajaxContentType: "form",
    ajaxParams: getSearchParams(),
    ajaxResponse: function(url, params, res){
      var arr = Array.isArray(res) ? res : (res.data || res.rows || []);
      allData = arr || [];
      if(rankFilter && !allData.some(function(r){ return (r.item_name||'').trim() === rankFilter; })) rankFilter = null;
      updateKpi(allData);
      renderRanking(allData);
      renderChart(allData);
      setTimeout(function(){ applyFilters(); updateFooter(); }, 0);
      return arr;
    },
    dataFiltered: function(){ setTimeout(updateCount, 0); },
    placeholder: "조회된 데이터가 없습니다.",
    selectable: 1,
    columns: [
      { title:"No",        field:"idx",        width:62,  hozAlign:"center", headerHozAlign:"center", headerFilter:"input", headerFilterPlaceholder:" ", formatter:function(c){ return '<span class="muted">'+c.getValue()+'</span>'; } },
      { title:"작업일자",  field:"w_date",     width:104, hozAlign:"center", headerHozAlign:"center", headerFilter:"input", headerFilterPlaceholder:" " },
      { title:"상태",      field:"status",     width:76,  hozAlign:"center", headerHozAlign:"center", headerFilter:"input", headerFilterPlaceholder:" ",
        formatter:function(c){ var v = c.getValue()||''; var cls = v==='완료'?'done':(v==='대기'?'wait':'run'); return v ? '<span class="badge '+cls+'">'+v+'</span>' : ''; } },
      { title:"재처리 LOT",field:"w_old_lot",  width:124, hozAlign:"center", headerHozAlign:"center", headerFilter:"input", headerFilterPlaceholder:" ",
        formatter:function(c){ var v = c.getValue(); return v ? '<span class="re-lot">'+esc(v)+'</span>' : '<span class="muted">-</span>'; } },
      { title:"회사명",    field:"cust_name",  minWidth:96,  widthGrow:1,   headerHozAlign:"center", headerFilter:"input", headerFilterPlaceholder:" " },
      { title:"품명",      field:"item_name",  minWidth:130, widthGrow:1.6, headerHozAlign:"center", headerFilter:"input", headerFilterPlaceholder:" ", formatter:function(c){ return '<b style="font-weight:600">'+esc(c.getValue())+'</b>'; } },
      { title:"품번",      field:"item_no",    minWidth:110, widthGrow:1.2, headerHozAlign:"center", headerFilter:"input", headerFilterPlaceholder:" " },
      { title:"계획 통수", field:"w_plan_cnt", width:94,  hozAlign:"right", headerHozAlign:"center", headerFilter:"input", headerFilterPlaceholder:" ", formatter:numFmt },
      { title:"투입 통수", field:"play_cnt",   width:94,  hozAlign:"right", headerHozAlign:"center", headerFilter:"input", headerFilterPlaceholder:" ",
        formatter:function(c){ var v = Number(c.getValue())||0, p = Number(c.getRow().getData().w_plan_cnt)||0;
          var color = v===0 ? 'var(--text-3)' : (v>=p ? 'var(--text)' : 'var(--accent)');
          return '<span style="font-weight:600;color:'+color+'">'+fmt(v)+'</span>'; } },
      { title:"규격",      field:"spec",       minWidth:120, widthGrow:1.4, headerHozAlign:"center", headerFilter:"input", headerFilterPlaceholder:" " },
      { title:"중량(g)",   field:"weight",     width:88,  hozAlign:"right", headerHozAlign:"center", headerFilter:"input", headerFilterPlaceholder:" ", formatter:numFmt },
      { title:"장입량(EA)",field:"material",   width:104,  hozAlign:"right", headerHozAlign:"center", headerFilter:"input", headerFilterPlaceholder:" ", formatter:numFmt }
    ]
  });
}

/* 검색어 + 랭킹 필터 */
function applyFilters(){
  if(!productTable) return;
  var kw = (document.getElementById('tableSearch').value||'').trim().toLowerCase();
  if(!kw && !rankFilter){ productTable.clearFilter(); }
  else productTable.setFilter(function(d){
    if(rankFilter && (d.item_name||'').trim() !== rankFilter) return false;
    if(kw && ((d.item_name||'')+' '+(d.item_no||'')+' '+(d.cust_name||'')).toLowerCase().indexOf(kw) < 0) return false;
    return true;
  });
  var chip = document.getElementById('rankChip');
  chip.classList.toggle('on', !!rankFilter);
  document.getElementById('rankChipText').textContent = rankFilter ? '품목: ' + rankFilter : '';
  document.querySelectorAll('#rankList .rank-item').forEach(function(el){ el.classList.toggle('active', el.getAttribute('data-name') === rankFilter); });
  updateCount();
}

function reloadData(){
  if(!productTable) return;
  allData = [];
  productTable.setData("/line/productionManagement/product_report/list", getSearchParams());
}

document.addEventListener('DOMContentLoaded', function(){
  document.getElementById('tableSearch').addEventListener('input', applyFilters);
  document.getElementById('rankList').addEventListener('click', function(e){
    var it = e.target.closest('.rank-item'); if(!it) return;
    var n = it.getAttribute('data-name');
    rankFilter = (rankFilter === n) ? null : n;
    applyFilters();
  });
  document.getElementById('rankChipClear').addEventListener('click', function(){ rankFilter = null; applyFilters(); });
  ['item_name','item_no'].forEach(function(id){
    document.getElementById(id).addEventListener('keydown', function(e){ if(e.key === 'Enter') reloadData(); });
  });
  document.querySelector('.select-button').addEventListener('click', reloadData);
  document.querySelector('.excel-button').addEventListener('click', downloadExcel);

  initProductTable();

  var rt;
  window.addEventListener('resize', function(){
    clearTimeout(rt);
    rt = setTimeout(function(){
      if(productTable) productTable.redraw();
      if(dailyChart) dailyChart.reflow();
    }, 120);
  });
});

/* 엑셀 다운로드 */
function downloadExcel(){
  if(!productTable) return;
  if(!productTable.getDataCount('active')){ alert('다운로드할 데이터가 없습니다.'); return; }
  document.getElementById('excelOverlay').style.display = 'block';
  document.getElementById('excelLoading').style.display = 'block';
  var sdate = (document.getElementById('s_sdate').value||'').replace(/-/g,'');
  var edate = (document.getElementById('s_edate').value||'').replace(/-/g,'');
  var now = new Date();
  var fileName = '제품별작업관리_' + sdate + '_' + edate + '_' + pad2(now.getHours()) + pad2(now.getMinutes()) + '.xlsx';
  productTable.download('xlsx', fileName, {
    sheetName: '제품별작업관리',
    documentProcessing: function(wb){
      var ws = wb.Sheets['제품별작업관리'] || wb.Sheets[wb.SheetNames[0]];
      if(ws) ws['!cols'] = [{wch:6},{wch:12},{wch:8},{wch:16},{wch:20},{wch:30},{wch:20},{wch:10},{wch:10},{wch:22},{wch:10},{wch:12}];
      return wb;
    }
  });
  setTimeout(function(){
    document.getElementById('excelOverlay').style.display = 'none';
    document.getElementById('excelLoading').style.display = 'none';
  }, 800);
}
</script>
</body>
</html>
