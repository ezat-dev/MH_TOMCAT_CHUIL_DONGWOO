<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../common_style.jsp" %>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=IBM+Plex+Mono:wght@400;500&family=IBM+Plex+Sans+KR:wght@400;500;600&display=swap" rel="stylesheet">
<style>
/* ===== 데모: 알람 이력 — 고밀도 운영 화면 (무채색 + 파랑 1색, 빨강은 활성 알람에만) ===== */
:root {
  --al-fg: oklch(24% 0.012 255); --al-fg2: oklch(46% 0.012 255); --al-fg3: oklch(64% 0.01 255);
  --al-line: oklch(91.5% 0.006 255); --al-line2: oklch(95.5% 0.004 255); --al-hover: oklch(97.5% 0.003 255);
  --al-bg: oklch(98.6% 0.002 255);
  --al-accent: var(--primary); --al-accent-tint: oklch(58% 0.13 250 / 0.07);
  --al-bad: oklch(56% 0.15 25); --al-bad-tint: oklch(56% 0.15 25 / 0.04);
  --al-sans: "IBM Plex Sans KR", "Pretendard", "Malgun Gothic", "맑은 고딕", sans-serif;
  --al-mono: "IBM Plex Mono", Consolas, "Malgun Gothic", monospace;
}
html, body { background: var(--al-bg); color: var(--al-fg); font-family: var(--al-sans); font-size: 13px; }
.mono { font-family: var(--al-mono); font-variant-numeric: tabular-nums slashed-zero; }

.page-wrap { height: 100vh; overflow: hidden; padding: 0; display: flex; flex-direction: column; }

/* 헤더 + 필터 툴바 */
.al-head { display: flex; align-items: center; gap: 8px; height: 56px; padding: 0 24px; background: #fff; border-bottom: 1px solid var(--al-line); flex-shrink: 0; flex-wrap: wrap; }
.al-title { font-size: 18px; font-weight: 600; margin-right: 16px; white-space: nowrap; }
.al-sep { width: 1px; height: 20px; background: var(--al-line); margin: 0 4px; }
.al-label { font-size: 12px; color: var(--al-fg2); white-space: nowrap; }
.al-spacer { flex: 1; }
.al-upd { font-size: 12px; color: var(--al-fg3); font-family: var(--al-mono); font-variant-numeric: tabular-nums; white-space: nowrap; }
.form-input, .form-select {
  height: 32px; padding: 0 8px; border: 1px solid var(--al-line); border-radius: 6px; background: #fff;
  color: var(--al-fg); font-family: var(--al-mono); font-size: 13px; font-variant-numeric: tabular-nums;
}
.form-select { font-family: var(--al-sans); }
.form-input:focus, .form-select:focus { border-color: var(--al-accent); box-shadow: 0 0 0 2px var(--al-accent-tint); outline: none; }
.btn-outline, .btn-primary {
  height: 32px; padding: 0 12px; display: inline-flex; align-items: center; gap: 8px; border-radius: 6px;
  font-family: var(--al-sans); font-size: 13px; font-weight: 500; white-space: nowrap; cursor: pointer;
  transition: background-color 80ms, border-color 80ms;
}
.btn-outline { border: 1px solid var(--al-line); background: #fff; color: var(--al-fg); }
.btn-outline:hover { background: var(--al-hover); border-color: oklch(86% 0.008 255); color: var(--al-fg); }
.btn-primary { border: 1px solid var(--al-accent); background: var(--al-accent); color: #fff; }
.btn-primary:hover { background: var(--primary-d); }
.btn-outline svg, .btn-primary svg { width: 14px; height: 14px; fill: none; stroke: currentColor; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }

/* 본문 */
.al-body { flex: 1; min-height: 0; padding: 16px 24px 24px; display: flex; flex-direction: column; gap: 16px; }

/* 지표 띠: 첫 칸이 핵심 지표 */
.al-kpi { display: grid; grid-template-columns: 1.4fr repeat(3, 1fr); background: #fff; border: 1px solid var(--al-line); border-radius: 8px; flex-shrink: 0; }
.al-kpi > div { padding: 12px 16px; border-left: 1px solid var(--al-line2); display: flex; flex-direction: column; gap: 4px; min-width: 0; }
.al-kpi > div:first-child { border-left: 0; }
.kpi-lbl { font-size: 12px; font-weight: 500; color: var(--al-fg2); }
.kpi-val { font-family: var(--al-mono); font-size: 22px; font-weight: 500; line-height: 1.2; font-variant-numeric: tabular-nums; color: var(--al-fg); }
.kpi-sub { font-size: 12px; color: var(--al-fg3); }
.al-kpi .hero .kpi-lbl { color: var(--al-fg); font-weight: 600; }
.al-kpi .hero .kpi-val { font-size: 28px; }
.al-kpi .hero .kpi-val.bad { color: var(--al-bad); }

/* 패널 */
.panel { background: #fff; border: 1px solid var(--al-line); border-radius: 8px; display: flex; flex-direction: column; min-width: 0; min-height: 0; }
.panel-head { display: flex; align-items: center; gap: 8px; height: 40px; padding: 0 16px; border-bottom: 1px solid var(--al-line2); flex-shrink: 0; }
.panel-title { font-size: 14px; font-weight: 600; }
.panel-meta { margin-left: auto; font-size: 12px; color: var(--al-fg3); }
.chart-row { display: grid; grid-template-columns: 1fr 1.2fr 2.4fr; gap: 16px; flex-shrink: 0; }
.chart-body { position: relative; height: 168px; padding: 8px 12px 8px 8px; }
.chart-body canvas { position: absolute; inset: 8px 12px 8px 8px; width: calc(100% - 20px) !important; height: calc(100% - 16px) !important; }

/* 상태 분포: 수평 비율 막대 */
.st-list { padding: 16px; display: flex; flex-direction: column; gap: 12px; }

/* 표 */
.tbl-panel { flex: 1; }
.tbl-scroll { flex: 1; min-height: 0; overflow: auto; }
.data-table { width: 100%; border-collapse: collapse; font-size: 13px; }
.data-table th {
  position: sticky; top: 0; z-index: 1; background: #fff; color: var(--al-fg2);
  font-size: 12px; font-weight: 500; text-align: left; padding: 8px 12px; height: 36px;
  border-bottom: 1px solid var(--al-line); white-space: nowrap;
}
.data-table td { padding: 0 12px; height: 32px; border-bottom: 1px solid var(--al-line2); color: var(--al-fg); white-space: nowrap; }
.data-table tbody tr { transition: background-color 80ms; }
.data-table tbody tr:hover { background: var(--al-hover); }
.data-table td.num, .data-table th.num { text-align: right; }
.alarm-row-active { background: var(--al-bad-tint) !important; }
.alarm-row-active td:first-child { box-shadow: inset 2px 0 0 var(--al-bad); }
.th-sort { cursor: pointer; user-select: none; }
.th-sort:hover { color: var(--al-fg); }
.th-sort::after { content: ' ↕'; font-size: 11px; color: var(--al-fg3); }
.th-sort.asc::after  { content: ' ↑'; color: var(--al-accent); }
.th-sort.desc::after { content: ' ↓'; color: var(--al-accent); }
.st { display: inline-flex; align-items: center; gap: 6px; font-size: 12px; color: var(--al-fg2); }
.st::before { content: ''; width: 6px; height: 6px; border-radius: 50%; background: var(--al-fg3); opacity: .6; }
.st.on { color: var(--al-bad); font-weight: 500; }
.st.on::before { background: var(--al-bad); opacity: 1; }

.tbl-foot { display: flex; align-items: center; gap: 8px; height: 40px; padding: 0 16px; border-top: 1px solid var(--al-line2); flex-shrink: 0; }
.total-count { font-size: 12px; color: var(--al-fg2); font-variant-numeric: tabular-nums; }
.pagination { display: flex; align-items: center; gap: 4px; margin-left: auto; }
.page-btn {
  min-width: 28px; height: 28px; padding: 0 6px; border-radius: 6px; border: 1px solid transparent; background: transparent;
  cursor: pointer; font-family: var(--al-mono); font-size: 12px; color: var(--al-fg2); font-variant-numeric: tabular-nums;
}
.page-btn:hover { background: var(--al-hover); border-color: var(--al-line); }
.page-btn.active { border-color: var(--al-accent); color: var(--al-accent); background: var(--al-accent-tint); font-weight: 500; }
</style>
<body>
<div class="page-wrap">
  <!-- 헤더 + 필터 -->
  <div class="al-head">
    <div class="al-title">알람 이력</div>
    <span class="al-label">시작일</span>
    <input class="form-input" type="date" id="dateFrom" style="width:140px">
    <span class="al-label">~</span>
    <input class="form-input" type="date" id="dateTo" style="width:140px">
    <span class="al-label" style="margin-left:8px">PLC</span>
    <select class="form-select" id="selPlc" style="width:110px">
      <option value="">전체</option>
    </select>
    <span class="al-label" style="margin-left:8px">상태</span>
    <select class="form-select" id="selState" style="width:96px">
      <option value="">전체</option>
      <option value="active">활성</option>
      <option value="cleared">해제됨</option>
    </select>
    <button class="btn-primary" onclick="applyFilter()"><svg viewBox="0 0 24 24"><circle cx="11" cy="11" r="7"/><path d="m20 20-3.5-3.5"/></svg>조회</button>
    <div class="al-spacer"></div>
    <span class="al-upd" id="lastUpdate"></span>
    <div class="al-sep"></div>
    <button class="btn-outline" onclick="loadAll()"><svg viewBox="0 0 24 24"><path d="M21 12a9 9 0 1 1-2.6-6.4"/><path d="M21 4v5h-5"/></svg>새로고침</button>
    <button class="btn-outline" onclick="downloadExcel()"><svg viewBox="0 0 24 24"><path d="M12 4v11"/><path d="m7 10 5 5 5-5"/><path d="M5 20h14"/></svg>엑셀</button>
  </div>

  <div class="al-body">
    <!-- 지표 띠 -->
    <div class="al-kpi">
      <div class="hero">
        <span class="kpi-lbl">현재 활성 알람</span>
        <span class="kpi-val" id="kpiActive">-</span>
        <span class="kpi-sub">해제되지 않은 알람</span>
      </div>
      <div>
        <span class="kpi-lbl">오늘 발생</span>
        <span class="kpi-val" id="kpiToday">-</span>
        <span class="kpi-sub">00:00 이후</span>
      </div>
      <div>
        <span class="kpi-lbl">미인지 알람</span>
        <span class="kpi-val" id="kpiUnack">-</span>
        <span class="kpi-sub">활성 중 확인 안 됨</span>
      </div>
      <div>
        <span class="kpi-lbl">해제 완료</span>
        <span class="kpi-val" id="kpiCleared">-</span>
        <span class="kpi-sub">이력 기준</span>
      </div>
    </div>

    <!-- 차트 행 -->
    <div class="chart-row">
      <div class="panel">
        <div class="panel-head"><span class="panel-title">상태별 분포</span><span class="panel-meta">건수</span></div>
        <div class="chart-body"><canvas id="chartState"></canvas></div>
      </div>
      <div class="panel">
        <div class="panel-head"><span class="panel-title">PLC별 알람 수</span><span class="panel-meta">상위 8</span></div>
        <div class="chart-body"><canvas id="chartPlc"></canvas></div>
      </div>
      <div class="panel">
        <div class="panel-head"><span class="panel-title">시간대별 발생 추이</span><span class="panel-meta">최근 24시간 · 1시간 단위</span></div>
        <div class="chart-body"><canvas id="chartTrend"></canvas></div>
      </div>
    </div>

    <!-- 테이블 -->
    <div class="panel tbl-panel">
      <div class="panel-head"><span class="panel-title">알람 목록</span><span class="panel-meta">활성 알람은 왼쪽 빨간 선</span></div>
      <div class="tbl-scroll">
        <table class="data-table">
          <thead>
            <tr>
              <th class="num" style="width:56px">No</th>
              <th class="th-sort desc" id="thOccur" onclick="toggleSort('occurTime')">발생시각</th>
              <th>PLC</th><th>태그명</th><th>내용</th><th class="num">발생값</th>
              <th class="th-sort" id="thClear" onclick="toggleSort('clearTime')">해제시각</th>
              <th>상태</th>
            </tr>
          </thead>
          <tbody id="alarmBody"></tbody>
        </table>
      </div>
      <div class="tbl-foot">
        <span class="total-count" id="totalCount">총 0건</span>
        <div class="pagination" id="pagination"></div>
      </div>
    </div>
  </div>
</div>

<script src="/bcf/mock/mock-loader.js"></script>
<script src="/vendor/chartjs/4.4.0/chart.umd.min.js"></script>
<script src="/vendor/xlsx/0.18.5/xlsx.full.min.js"></script>
<script>
var base = '${pageContext.request.contextPath}';
var allHistory = [];  // history/list 결과
var allActive  = [];  // active/list 결과
var filtered   = [];
var PAGE_SIZE  = 20;
var curPage    = 1;
var curSortCol = 'occurTime';
var curSortDir = 'desc';

var chartState, chartPlc, chartTrend;

/* ── 데이터 로드 ── */
function loadAll(){
  document.getElementById('lastUpdate').textContent = '로딩 중…';
  var p1 = fetch(base + '/alarm/active/list?limit=200').then(function(r){ return r.json(); }).catch(function(){ return []; });
  var p2 = fetch(base + '/alarm/history/list?limit=500').then(function(r){ return r.json(); }).catch(function(){ return []; });
  Promise.all([p1, p2]).then(function(res){
    allActive  = Array.isArray(res[0]) ? res[0] : [];
    allHistory = Array.isArray(res[1]) ? res[1] : [];
    updateKpi();
    buildCharts();
    populatePlcFilter();
    applyFilter();
    var now = new Date();
    document.getElementById('lastUpdate').textContent = '갱신: '
      + String(now.getHours()).padStart(2,'0') + ':' + String(now.getMinutes()).padStart(2,'0') + ':' + String(now.getSeconds()).padStart(2,'0');
    window.scrollTo(0,0);
  });
}

/* ── KPI ── */
function updateKpi(){
  var todayStr = new Date().toISOString().slice(0,10);
  var combined = allHistory.slice();
  allActive.forEach(function(a){
    var dup = combined.some(function(h){ return h.tagName===a.tagName && h.occurTime===a.occurTime; });
    if(!dup) combined.push(a);
  });
  document.getElementById('kpiActive').textContent  = allActive.length;
  document.getElementById('kpiActive').classList.toggle('bad', allActive.length > 0);
  document.getElementById('kpiToday').textContent   = combined.filter(function(r){ return (r.occurTime||'').slice(0,10) === todayStr; }).length;
  document.getElementById('kpiUnack').textContent   = allActive.filter(function(r){ return !r.ackTime; }).length;
  document.getElementById('kpiCleared').textContent = allHistory.filter(function(r){ return r.clearTime; }).length;
}

/* ── PLC ID → 설비명 치환 ── */
function plcLabel(plcId) {
  if (!plcId) return '-';
  var m = String(plcId).match(/(\d+)$/);
  if (m) return parseInt(m[1], 10) + '호기';
  return plcId;
}

/* ── PLC 필터 드롭다운 ── */
function populatePlcFilter(){
  var ids = {};
  allHistory.forEach(function(r){ if(r.plcId) ids[r.plcId]=1; });
  var sel = document.getElementById('selPlc');
  sel.innerHTML = '<option value="">전체</option>';
  Object.keys(ids).sort().forEach(function(id){
    sel.innerHTML += '<option value="'+id+'">'+plcLabel(id)+'</option>';
  });
}

/* ── 차트 (데모: 무채색 + 파랑 1색, 빨강은 활성에만) ── */
var CH_ACCENT = '#3182CE', CH_MUTED = '#CBD5E0', CH_BAD = '#C53030';
var CH_GRID = '#EEF1F5', CH_TICK = '#718096';
var CH_FONT = { family:'"IBM Plex Mono", Consolas, monospace', size:11 };
function buildCharts(){
  /* 상태별 분포 — 가로 막대 (활성/해제) */
  var activeCnt  = allActive.length;
  var clearedCnt = allHistory.filter(function(r){ return r.clearTime; }).length;

  if(chartState){ chartState.destroy(); }
  chartState = new Chart(document.getElementById('chartState'), {
    type:'bar',
    data:{
      labels:['활성','해제'],
      datasets:[{
        data:[activeCnt, clearedCnt],
        backgroundColor:[CH_BAD, CH_MUTED],
        borderRadius:2, barThickness:18
      }]
    },
    options:{
      responsive:true, maintainAspectRatio:false, animation:false, indexAxis:'y',
      plugins:{ legend:{display:false} },
      scales:{
        x:{ beginAtZero:true, grid:{color:CH_GRID}, border:{display:false}, ticks:{font:CH_FONT, color:CH_TICK} },
        y:{ grid:{display:false}, border:{display:false}, ticks:{font:{size:12}, color:'#4A5568'} }
      }
    }
  });

  /* PLC별 바 */
  var plcCnt = {};
  allHistory.forEach(function(r){ var p=r.plcId||'unknown'; plcCnt[p]=(plcCnt[p]||0)+1; });
  var plcKeys = Object.keys(plcCnt).sort(function(a,b){ return plcCnt[b]-plcCnt[a]; }).slice(0,8);

  if(chartPlc){ chartPlc.destroy(); }
  chartPlc = new Chart(document.getElementById('chartPlc'), {
    type:'bar',
    data:{
      labels:plcKeys.map(plcLabel),
      datasets:[{
        label:'알람 수',
        data:plcKeys.map(function(k){ return plcCnt[k]; }),
        backgroundColor:plcKeys.map(function(_,i){ return i < 3 ? CH_ACCENT : 'rgba(49,130,206,.35)'; }),
        borderRadius:2, maxBarThickness:12
      }]
    },
    options:{
      responsive:true, maintainAspectRatio:false, animation:false, indexAxis:'y',
      plugins:{ legend:{display:false} },
      scales:{
        x:{ beginAtZero:true, grid:{color:CH_GRID}, border:{display:false}, ticks:{font:CH_FONT, color:CH_TICK} },
        y:{ grid:{display:false}, border:{display:false}, ticks:{font:{size:11}, color:'#4A5568', autoSkip:false} }
      }
    }
  });

  /* 시간대별 추이 — 최근 24h, 1시간 단위 */
  var now = new Date();
  var bucketStart = new Date(now.getTime() - 23*3600000);
  bucketStart.setMinutes(0,0,0);
  var buckets = [];
  for(var h=0;h<24;h++){
    var t = new Date(bucketStart.getTime() + h*3600000);
    buckets.push({ label: String(t.getHours()).padStart(2,'0')+'시', ts: t.getTime(), cnt:0 });
  }
  var cutoff = bucketStart.getTime();
  allHistory.forEach(function(r){
    var raw = r.occurTime || '';
    var ts  = new Date(raw.replace(' ','T')).getTime();
    if(!ts || isNaN(ts) || ts < cutoff) return;
    for(var i=buckets.length-1;i>=0;i--){
      if(ts >= buckets[i].ts){ buckets[i].cnt++; break; }
    }
  });

  if(chartTrend){ chartTrend.destroy(); }
  chartTrend = new Chart(document.getElementById('chartTrend'), {
    type:'line',
    data:{
      labels:buckets.map(function(b){ return b.label; }),
      datasets:[{
        label:'알람 발생 수',
        data:buckets.map(function(b){ return b.cnt; }),
        borderColor:CH_ACCENT,
        backgroundColor:function(ctx){
          var a = ctx.chart.chartArea; if(!a) return 'rgba(49,130,206,.15)';
          var g = ctx.chart.ctx.createLinearGradient(0, a.top, 0, a.bottom);
          g.addColorStop(0, 'rgba(49,130,206,.15)'); g.addColorStop(1, 'rgba(49,130,206,0)');
          return g;
        },
        borderWidth:1.5, pointRadius:0, pointHoverRadius:3, fill:true, tension:.25, cubicInterpolationMode:'monotone'
      }]
    },
    options:{
      responsive:true, maintainAspectRatio:false, animation:false,
      interaction:{ mode:'index', intersect:false },
      plugins:{ legend:{display:false} },
      scales:{
        x:{ grid:{display:false}, border:{color:CH_GRID}, ticks:{font:CH_FONT, color:CH_TICK, maxTicksLimit:12} },
        y:{ beginAtZero:true, grid:{color:CH_GRID}, border:{display:false}, ticks:{font:CH_FONT, color:CH_TICK, stepSize:1} }
      }
    }
  });
}

/* ── 필터 적용 ── */
function applyFilter(){
  curPage = 1;
  var from  = document.getElementById('dateFrom').value;
  var to    = document.getElementById('dateTo').value + 'T23:59:59';
  var plcF  = document.getElementById('selPlc').value;
  var stF   = document.getElementById('selState').value;

  // active + history 합본 (active는 clearTime이 없음)
  var combined = allHistory.slice();
  allActive.forEach(function(a){
    var dup = combined.some(function(h){ return h.tagName===a.tagName && h.occurTime===a.occurTime; });
    if(!dup){ combined.push(a); }
  });

  filtered = combined.filter(function(r){
    if(from && (r.occurTime||'') < from) return false;
    if(to   && (r.occurTime||'') > to  ) return false;
    if(plcF && r.plcId !== plcF        ) return false;
    if(stF === 'active'  && r.clearTime) return false;
    if(stF === 'cleared' && !r.clearTime) return false;
    return true;
  });

  applySortFiltered();

  document.getElementById('totalCount').textContent = '총 '+filtered.length+'건';
  renderPage(1);
}

/* ── 정렬 ── */
function applySortFiltered() {
  var col = curSortCol, dir = curSortDir;
  filtered.sort(function(a, b) {
    var av = a[col] || '', bv = b[col] || '';
    if (av === bv) return 0;
    var cmp = av < bv ? -1 : 1;
    return dir === 'asc' ? cmp : -cmp;
  });
  // 헤더 아이콘 갱신
  ['thOccur','thClear'].forEach(function(id) {
    var el = document.getElementById(id);
    if (!el) return;
    el.classList.remove('asc','desc');
  });
  var activeId = col === 'occurTime' ? 'thOccur' : 'thClear';
  var el = document.getElementById(activeId);
  if (el) el.classList.add(dir);
}

function toggleSort(col) {
  if (curSortCol === col) {
    curSortDir = curSortDir === 'desc' ? 'asc' : 'desc';
  } else {
    curSortCol = col;
    curSortDir = 'desc';
  }
  applySortFiltered();
  renderPage(1);
}

/* ── 테이블 렌더 ── */
function renderPage(page){
  curPage = page;
  var start = (page-1)*PAGE_SIZE;
  var rows  = filtered.slice(start, start+PAGE_SIZE);
  var html  = '';
  rows.forEach(function(r, i){
    var isActive = !r.clearTime;
    html += '<tr'+(isActive?' class="alarm-row-active"':'')+'>'
          + '<td class="num mono" style="color:var(--al-fg3)">'+(start+i+1)+'</td>'
          + '<td class="mono">'+(r.occurTime||'-')+'</td>'
          + '<td>'+esc(plcLabel(r.plcId))+'</td>'
          + '<td class="mono" style="color:var(--al-fg2)">'+esc(r.tagName||'-')+'</td>'
          + '<td'+(isActive?' style="font-weight:500"':'')+'>'+esc(r.alarmMsg||'-')+'</td>'
          + '<td class="num mono">'+(r.valueAtOccur!=null?r.valueAtOccur:'-')+'</td>'
          + '<td class="mono" style="color:var(--al-fg3)">'+(r.clearTime||'—')+'</td>'
          + '<td><span class="st'+(isActive?' on':'')+'">'+(isActive?'활성':'해제')+'</span></td>'
          + '</tr>';
  });
  document.getElementById('alarmBody').innerHTML = html || '<tr><td colspan="8" style="text-align:center;color:var(--al-fg3);height:64px">조회 조건에 맞는 알람이 없습니다</td></tr>';
  var sc = document.querySelector('.tbl-scroll'); if(sc) sc.scrollTop = 0;
  renderPaging();
}

function renderPaging(){
  var total = Math.ceil(filtered.length / PAGE_SIZE);
  var html  = '';
  if(total <= 1){ document.getElementById('pagination').innerHTML=''; return; }
  if(curPage>1)  html += '<button class="page-btn" onclick="renderPage('+(curPage-1)+')">‹</button>';
  var s=Math.max(1,curPage-3), e=Math.min(total,curPage+3);
  for(var p=s;p<=e;p++){
    html += '<button class="page-btn'+(p===curPage?' active':'')+'" onclick="renderPage('+p+')">'+p+'</button>';
  }
  if(curPage<total) html += '<button class="page-btn" onclick="renderPage('+(curPage+1)+')">›</button>';
  document.getElementById('pagination').innerHTML = html;
}

/* ── 엑셀 다운로드 ── */
var BCF_MACHINES = [
  {plcId:'bcf_01', label:'BCF_01'},
  {plcId:'bcf_02', label:'BCF_02'},
  {plcId:'bcf_03', label:'BCF_03'},
  {plcId:'bcf_04', label:'BCF_04'},
  {plcId:'bcf_05', label:'BCF_05'},
  {plcId:'bcf_06', label:'BCF_06'},
  {plcId:'bcf_07', label:'BCF_07'},
  {plcId:'bcf_08', label:'BCF_08'},
  {plcId:'bcf_09', label:'BCF_09'},
  {plcId:'bcf_10', label:'BCF_10'},
  {plcId:'bcf_11', label:'BCF_11'},
  {plcId:'bcf_12', label:'BCF_12'}
];
function downloadExcel(){
  if(typeof XLSX === 'undefined'){ alert('라이브러리 로드 중입니다. 잠시 후 다시 시도해주세요.'); return; }

  var from  = document.getElementById('dateFrom').value;
  var to    = document.getElementById('dateTo').value;
  var toEnd = to + 'T23:59:59';

  // active + history 합본 (중복 제거)
  var combined = allHistory.slice();
  allActive.forEach(function(a){
    var dup = combined.some(function(h){ return h.tagName===a.tagName && h.occurTime===a.occurTime; });
    if(!dup) combined.push(a);
  });

  // 날짜 범위 필터
  var data = combined.filter(function(r){
    if(from && (r.occurTime||'') < from) return false;
    if(to   && (r.occurTime||'') > toEnd) return false;
    return true;
  });

  var wb = XLSX.utils.book_new();
  var HEADER = ['No','발생시각','설비','태그명','알람내용','발생값','해제시각','상태'];

  BCF_MACHINES.forEach(function(m){
    var rows = data.filter(function(r){ return r.plcId === m.plcId; });
    rows.sort(function(a,b){ return (a.occurTime||'') < (b.occurTime||'') ? -1 : 1; });

    var wsData = [HEADER];
    rows.forEach(function(r, i){
      wsData.push([
        i+1,
        r.occurTime  || '-',
        m.label,
        r.tagName    || '-',
        r.alarmMsg   || '-',
        r.valueAtOccur != null ? r.valueAtOccur : '-',
        r.clearTime  || '',
        r.clearTime  ? '해제' : '활성'
      ]);
    });

    var ws = XLSX.utils.aoa_to_sheet(wsData);
    ws['!cols'] = [
      {wch:5},{wch:22},{wch:10},{wch:28},{wch:45},{wch:12},{wch:22},{wch:8}
    ];
    XLSX.utils.book_append_sheet(wb, ws, m.label);
  });

  var fileName = '알람이력_' + from + '_' + to + '.xlsx';
  XLSX.writeFile(wb, fileName);
}

/* ── 유틸 ── */
function esc(s){ return String(s||'').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;'); }

/* ── 초기화 ── */
function toLocalDate(d){
  return d.getFullYear() + '-' + String(d.getMonth()+1).padStart(2,'0') + '-' + String(d.getDate()).padStart(2,'0');
}
var today = new Date();
document.getElementById('dateTo').value   = toLocalDate(today);
var m1 = new Date(today); m1.setDate(m1.getDate() - 7);
document.getElementById('dateFrom').value = toLocalDate(m1);

loadAll();
setInterval(loadAll, 300000); // 5분 주기 자동 갱신
</script>
</body>
</html>
