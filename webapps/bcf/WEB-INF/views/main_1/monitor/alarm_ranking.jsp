<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../common_style.jsp" %>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=IBM+Plex+Mono:wght@400;500&family=IBM+Plex+Sans+KR:wght@400;500;600&display=swap" rel="stylesheet">
<style>
/* ===== 데모: 알람 랭킹 — 고밀도 운영 화면 (무채색 + 파랑 1색, 상위 3위만 진하게) ===== */
:root {
  --al-fg: oklch(24% 0.012 255); --al-fg2: oklch(46% 0.012 255); --al-fg3: oklch(64% 0.01 255);
  --al-line: oklch(91.5% 0.006 255); --al-line2: oklch(95.5% 0.004 255); --al-hover: oklch(97.5% 0.003 255);
  --al-bg: oklch(98.6% 0.002 255);
  --al-accent: var(--primary); --al-accent-tint: oklch(58% 0.13 250 / 0.07);
  --al-sans: "IBM Plex Sans KR", "Pretendard", "Malgun Gothic", "맑은 고딕", sans-serif;
  --al-mono: "IBM Plex Mono", Consolas, "Malgun Gothic", monospace;
}
html, body { background: var(--al-bg); color: var(--al-fg); font-family: var(--al-sans); font-size: 13px; }
.mono { font-family: var(--al-mono); font-variant-numeric: tabular-nums slashed-zero; }

.page-wrap { height: 100vh; overflow: hidden; padding: 0; display: flex; flex-direction: column; }

/* 헤더 + 기간 칩 */
.al-head { display: flex; align-items: center; gap: 8px; min-height: 56px; padding: 8px 24px; background: #fff; border-bottom: 1px solid var(--al-line); flex-shrink: 0; flex-wrap: wrap; }
.al-title { font-size: 18px; font-weight: 600; margin-right: 16px; white-space: nowrap; }
.al-sep { width: 1px; height: 20px; background: var(--al-line); margin: 0 4px; }
.al-spacer { flex: 1; }
.al-upd { font-size: 12px; color: var(--al-fg3); font-family: var(--al-mono); font-variant-numeric: tabular-nums; white-space: nowrap; }
.period-tab { display: flex; gap: 4px; }
.tab-btn {
  height: 28px; padding: 0 12px; border-radius: 6px; border: 1px solid var(--al-line); background: #fff;
  font-family: var(--al-sans); font-size: 12px; font-weight: 500; color: var(--al-fg2); cursor: pointer;
  transition: background-color 80ms, border-color 80ms;
}
.tab-btn:hover { background: var(--al-hover); color: var(--al-fg); }
.tab-btn.active { border-color: var(--al-accent); color: var(--al-accent); background: var(--al-accent-tint); }
.range-box { display: none; align-items: center; gap: 8px; }
.range-box.show { display: flex; }
.range-input {
  height: 28px; padding: 0 8px; border: 1px solid var(--al-line); border-radius: 6px; background: #fff;
  font-family: var(--al-mono); font-size: 12px; color: var(--al-fg); font-variant-numeric: tabular-nums; outline: none;
}
.range-input:focus { border-color: var(--al-accent); box-shadow: 0 0 0 2px var(--al-accent-tint); }
.btn-outline, .btn-primary {
  height: 32px; padding: 0 12px; display: inline-flex; align-items: center; gap: 8px; border-radius: 6px;
  font-family: var(--al-sans); font-size: 13px; font-weight: 500; white-space: nowrap; cursor: pointer;
  transition: background-color 80ms, border-color 80ms;
}
.btn-outline { border: 1px solid var(--al-line); background: #fff; color: var(--al-fg); }
.btn-outline:hover { background: var(--al-hover); border-color: oklch(86% 0.008 255); color: var(--al-fg); }
.btn-primary { border: 1px solid var(--al-accent); background: var(--al-accent); color: #fff; }
.btn-primary:hover { background: var(--primary-d); }
.range-box .btn-primary { height: 28px; font-size: 12px; }
.btn-outline svg { width: 14px; height: 14px; fill: none; stroke: currentColor; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }

/* 본문 */
.al-body { flex: 1; min-height: 0; padding: 16px 24px 24px; display: flex; flex-direction: column; gap: 16px; }

/* 지표 띠: 첫 칸이 핵심 지표 */
.kpi-mini-row { display: grid; grid-template-columns: 1fr 1.6fr 1.2fr; background: #fff; border: 1px solid var(--al-line); border-radius: 8px; flex-shrink: 0; }
.kpi-mini { padding: 12px 16px; border-left: 1px solid var(--al-line2); display: flex; flex-direction: column-reverse; justify-content: flex-end; gap: 4px; min-width: 0; }
.kpi-mini:first-child { border-left: 0; }
.kpi-mini-lbl { font-size: 12px; font-weight: 500; color: var(--al-fg2); }
.kpi-mini-val { font-family: var(--al-mono); font-size: 22px; font-weight: 500; line-height: 1.25; font-variant-numeric: tabular-nums; color: var(--al-fg); white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
.kpi-mini-val.text { font-family: var(--al-sans); font-size: 18px; }
.kpi-mini:first-child .kpi-mini-lbl { color: var(--al-fg); font-weight: 600; }
.kpi-mini:first-child .kpi-mini-val { font-size: 28px; }

/* 패널 */
.panel { background: #fff; border: 1px solid var(--al-line); border-radius: 8px; display: flex; flex-direction: column; min-width: 0; min-height: 0; }
.panel-head { display: flex; align-items: center; gap: 8px; height: 40px; padding: 0 16px; border-bottom: 1px solid var(--al-line2); flex-shrink: 0; }
.panel-title { font-size: 14px; font-weight: 600; }
.panel-meta { margin-left: auto; font-size: 12px; color: var(--al-fg3); }
.chart-body { position: relative; flex: 1; min-height: 0; }
.chart-body canvas { position: absolute; inset: 8px 16px 8px 8px; width: calc(100% - 24px) !important; height: calc(100% - 16px) !important; }

.grid-main { flex: 1; min-height: 0; display: grid; grid-template-columns: 1fr 1fr 0.8fr; grid-template-rows: 1fr 1fr; gap: 16px; }

/* 랭킹 표 */
.rank-list { flex: 1; min-height: 0; overflow: auto; }
.rank-item {
  display: grid; grid-template-columns: 40px minmax(0, 1fr) minmax(64px, 30%) 48px; align-items: center; gap: 12px;
  height: 30px; padding: 0 16px; border-bottom: 1px solid var(--al-line2); transition: background-color 80ms;
}
.rank-item:last-child { border-bottom: 0; }
.rank-item:hover { background: var(--al-hover); }
.rank-no { font-family: var(--al-mono); font-variant-numeric: tabular-nums; font-size: 12px; color: var(--al-fg3); text-align: right; }
.rank-no.top { color: var(--al-fg); font-weight: 500; }
.rank-name { font-size: 13px; color: var(--al-fg); overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.rank-bar-bg { height: 6px; background: var(--al-line2); border-radius: 1px; overflow: hidden; }
.rank-bar-fill { height: 100%; border-radius: 1px; }
.rank-cnt { font-family: var(--al-mono); font-variant-numeric: tabular-nums; font-size: 12px; color: var(--al-fg); text-align: right; }

/* 등급 */
.lv-stack { padding: 12px 16px 0; flex-shrink: 0; }
.lv-stack-body { position: relative; height: 56px; }
.lv-stack-body canvas { position: absolute; inset: 0; width: 100% !important; height: 100% !important; }
.lv-stack-body { height: 24px; }
.lv-legend { flex: 1; min-height: 0; overflow: auto; padding: 8px 0 0; }
.lv-row { display: grid; grid-template-columns: 1fr 64px 64px; align-items: center; height: 32px; padding: 0 16px; border-bottom: 1px solid var(--al-line2); font-size: 13px; }
.lv-row:last-child { border-bottom: 0; }
.lv-row i { display: inline-block; width: 8px; height: 8px; border-radius: 2px; margin-right: 8px; }
.lv-row .mono { text-align: right; }

.loading-msg { padding: 24px 16px; color: var(--al-fg3); font-size: 12px; }
</style>
<body>
<div class="page-wrap">
  <!-- 헤더 + 기간 -->
  <div class="al-head">
    <div class="al-title">알람 랭킹</div>
    <div class="period-tab">
      <button class="tab-btn" onclick="setPeriod('day',this)">오늘</button>
      <button class="tab-btn" onclick="setPeriod('week',this)">이번 주</button>
      <button class="tab-btn active" onclick="setPeriod('month',this)">이번 달</button>
      <button class="tab-btn" onclick="setPeriod('all',this)">전체</button>
      <button class="tab-btn" onclick="setPeriod('range',this)">기간 지정</button>
    </div>
    <div class="range-box" id="rangeBox">
      <input type="date" class="range-input" id="fromDate">
      <span style="color:var(--al-fg3)">~</span>
      <input type="date" class="range-input" id="toDate">
      <button class="btn-primary" onclick="loadDataRange()">조회</button>
    </div>
    <div class="al-spacer"></div>
    <span class="al-upd" id="lastUpdate"></span>
    <div class="al-sep"></div>
    <button class="btn-outline" onclick="curPeriod==='range'?loadDataRange():loadData()"><svg viewBox="0 0 24 24"><path d="M21 12a9 9 0 1 1-2.6-6.4"/><path d="M21 4v5h-5"/></svg>새로고침</button>
  </div>

  <div class="al-body">
    <!-- 지표 띠 -->
    <div class="kpi-mini-row">
      <div class="kpi-mini">
        <div class="kpi-mini-val" id="kpiTotal">-</div>
        <div class="kpi-mini-lbl">기간 내 전체 알람</div>
      </div>
      <div class="kpi-mini" id="kpiTopItem">
        <div class="kpi-mini-val">-</div>
        <div class="kpi-mini-lbl">최다 발생 항목</div>
      </div>
      <div class="kpi-mini" id="kpiTopPlc">
        <div class="kpi-mini-val">-</div>
        <div class="kpi-mini-lbl">최다 발생 PLC</div>
      </div>
    </div>

    <div class="grid-main">
      <!-- 차트 -->
      <div class="panel">
        <div class="panel-head"><span class="panel-title">알람 항목 TOP 10</span><span class="panel-meta">건수</span></div>
        <div class="chart-body"><canvas id="chartItem"></canvas></div>
      </div>
      <div class="panel">
        <div class="panel-head"><span class="panel-title">PLC별 알람 TOP 10</span><span class="panel-meta">건수</span></div>
        <div class="chart-body"><canvas id="chartPlc"></canvas></div>
      </div>

      <!-- 등급 -->
      <div class="panel">
        <div class="panel-head"><span class="panel-title">등급별 알람 발생 비율</span><span class="panel-meta">기간 내</span></div>
        <div class="lv-stack"><div class="lv-stack-body"><canvas id="chartLvDist"></canvas></div></div>
        <div class="lv-legend" id="lvLegend"></div>
      </div>

      <!-- 랭킹 리스트 -->
      <div class="panel">
        <div class="panel-head"><span class="panel-title">알람 항목 순위</span><span class="panel-meta">호기_알람 내용</span></div>
        <div class="rank-list" id="itemRanking">
          <div class="loading-msg">불러오는 중…</div>
        </div>
      </div>
      <div class="panel">
        <div class="panel-head"><span class="panel-title">PLC별 순위</span><span class="panel-meta">상위 3위 강조</span></div>
        <div class="rank-list" id="plcRanking">
          <div class="loading-msg">불러오는 중…</div>
        </div>
      </div>
      <div class="panel">
        <div class="panel-head"><span class="panel-title">등급별 건수</span><span class="panel-meta">건수</span></div>
        <div class="chart-body"><canvas id="chartLvBar"></canvas></div>
      </div>
    </div>
  </div>
</div>

<script src="/bcf/mock/mock-loader.js"></script>
<script src="/vendor/chartjs/4.4.0/chart.umd.min.js"></script>
<script>
var base    = '${pageContext.request.contextPath}';
var rawData = [];       // history API 전체
var curPeriod = 'month';
var charts  = {};

var LV_LABEL = {1:'위험',2:'경고',3:'주의',4:'정보'};
/* 데모: 등급은 의미색을 채도 낮춰 사용, 랭킹은 파랑 1색(상위 3위만 진하게) */
var LV_COLOR = ['#C0473B','#4A5568','#A0AEC0','#E2E8F0'];
var RANK_TOP = '#3182CE', RANK_REST = 'rgba(49,130,206,.35)';
var RANK_COLORS = [RANK_TOP,RANK_TOP,RANK_TOP,RANK_REST,RANK_REST,RANK_REST,RANK_REST,RANK_REST,RANK_REST,RANK_REST];
var CH_GRID = '#EEF1F5', CH_TICK = '#718096';
var CH_FONT = { family:'"IBM Plex Mono", Consolas, monospace', size:11 };

/* ── 날짜 필터 기준 ── */
function periodStart(p){
  var d = new Date();
  if(p==='day'){   d.setHours(0,0,0,0); }
  else if(p==='week'){  var day=d.getDay(); d.setDate(d.getDate()-day); d.setHours(0,0,0,0); }
  else if(p==='month'){ d.setDate(1); d.setHours(0,0,0,0); }
  else return null; // 'all', 'range'
  return d;
}

function filterByPeriod(data, p){
  if(p==='range') return data; // 서버에서 이미 필터링
  var start = periodStart(p);
  if(!start) return data;
  return data.filter(function(r){
    return new Date(r.occurTime||r.occurrTime||0) >= start;
  });
}

/* ── 집계 ── */
function countBy(data, key){
  var map = {};
  data.forEach(function(r){ var k=r[key]||'unknown'; map[k]=(map[k]||0)+1; });
  return Object.entries(map).sort(function(a,b){ return b[1]-a[1]; });
}

/* bcf_04 → BCF4 */
function plcLabel(id){
  var m = (id||'').match(/(\d+)$/);
  return m ? 'BCF' + parseInt(m[1]) : (id||'?');
}

/* 호기_경보내용 복합키 집계 */
function countByItem(data){
  var map = {};
  data.forEach(function(r){
    var k = plcLabel(r.plcId) + '_' + (r.alarmMsg || 'unknown');
    map[k] = (map[k]||0) + 1;
  });
  return Object.entries(map).sort(function(a,b){ return b[1]-a[1]; });
}

/* ── 데이터 로드 ── */
function loadData(){
  document.getElementById('lastUpdate').textContent = '로딩 중…';
  fetch(base + '/alarm/history/list?limit=1000')
    .then(function(r){ return r.json(); })
    .then(function(d){
      rawData = Array.isArray(d) ? d : [];
      renderAll();
      var now = new Date();
      document.getElementById('lastUpdate').textContent = '갱신: '
        + String(now.getHours()).padStart(2,'0') + ':' + String(now.getMinutes()).padStart(2,'0') + ':' + String(now.getSeconds()).padStart(2,'0');
    })
    .catch(function(){
      rawData = [];
      renderAll();
      document.getElementById('lastUpdate').textContent = 'API 연결 실패';
    });
}

function setPeriod(p, btn){
  curPeriod = p;
  document.querySelectorAll('.tab-btn').forEach(function(b){ b.classList.remove('active'); });
  if(btn) btn.classList.add('active');
  var rb = document.getElementById('rangeBox');
  if(p === 'range'){
    rb.classList.add('show');
    /* 기간 탭은 조회 버튼을 눌러야 로드 */
  } else {
    rb.classList.remove('show');
    renderAll();
  }
}

function loadDataRange(){
  var from = document.getElementById('fromDate').value;
  var to   = document.getElementById('toDate').value;
  if(!from || !to){ alert('날짜를 선택하세요'); return; }
  document.getElementById('lastUpdate').textContent = '로딩 중…';
  fetch(base + '/alarm/history/range?from=' + encodeURIComponent(from) + '&to=' + encodeURIComponent(to))
    .then(function(r){ return r.json(); })
    .then(function(d){
      rawData = Array.isArray(d) ? d : [];
      renderAll();
      var now = new Date();
      document.getElementById('lastUpdate').textContent =
        from + ' ~ ' + to + ' (' + rawData.length + '건)';
    })
    .catch(function(){
      rawData = [];
      renderAll();
      document.getElementById('lastUpdate').textContent = '조회 실패';
    });
}

function renderAll(){
  var data = filterByPeriod(rawData, curPeriod);
  renderKpi(data);
  renderRankLists(data);
  renderCharts(data);
  window.scrollTo(0,0);
}

/* ── KPI ── */
function renderKpi(data){
  document.getElementById('kpiTotal').textContent = data.length;

  var byItem = countByItem(data);
  var topItemEl = document.getElementById('kpiTopItem');
  if(byItem.length > 0){
    topItemEl.innerHTML = '<div class="kpi-mini-val text">'+esc(byItem[0][0])+' <span class="mono" style="font-size:13px;color:var(--al-fg3)">'+byItem[0][1]+'건</span></div>'
      + '<div class="kpi-mini-lbl">최다 발생 항목</div>';
  } else {
    topItemEl.innerHTML = '<div class="kpi-mini-val">—</div><div class="kpi-mini-lbl">최다 발생 항목</div>';
  }

  var byPlc = countBy(data, 'plcId');
  var topPlcEl = document.getElementById('kpiTopPlc');
  if(byPlc.length > 0){
    topPlcEl.innerHTML = '<div class="kpi-mini-val">'+esc(byPlc[0][0])+' <span style="font-size:13px;color:var(--al-fg3)">'+byPlc[0][1]+'건</span></div>'
      + '<div class="kpi-mini-lbl">최다 발생 PLC</div>';
  } else {
    topPlcEl.innerHTML = '<div class="kpi-mini-val">—</div><div class="kpi-mini-lbl">최다 발생 PLC</div>';
  }
}

/* ── 랭킹 리스트 ── */
function renderRankLists(data){
  var byItem = countByItem(data).slice(0,10);
  var byPlc  = countBy(data, 'plcId').slice(0,10);
  document.getElementById('itemRanking').innerHTML = buildRankHtml(byItem);
  document.getElementById('plcRanking').innerHTML  = buildRankHtml(byPlc);
}

function buildRankHtml(entries){
  if(!entries.length) return '<div class="loading-msg">선택한 기간에 발생한 알람이 없습니다</div>';
  var max = entries[0][1];
  return entries.map(function(e,i){
    var pct = Math.round(e[1]/max*100);
    var barColor = i < 3 ? RANK_TOP : RANK_REST;
    return '<div class="rank-item">'
      + '<div class="rank-no'+(i<3?' top':'')+'">'+(i+1)+'</div>'
      + '<div class="rank-name"'+(i<3?' style="font-weight:500"':'')+'>'+esc(e[0])+'</div>'
      + '<div class="rank-bar-bg"><div class="rank-bar-fill" style="width:'+pct+'%;background:'+barColor+'"></div></div>'
      + '<div class="rank-cnt">'+e[1]+'</div>'
      + '</div>';
  }).join('');
}

/* ── 차트 ── */
function destroyChart(key){
  if(charts[key]){ charts[key].destroy(); charts[key]=null; }
}

function rankBarOpts(){
  return {
    responsive:true, maintainAspectRatio:false, animation:false, indexAxis:'y',
    plugins:{ legend:{display:false} },
    scales:{
      x:{ beginAtZero:true, grid:{color:CH_GRID}, border:{display:false}, ticks:{font:CH_FONT, color:CH_TICK, precision:0} },
      y:{ grid:{display:false}, border:{display:false}, ticks:{font:{size:11}, color:'#4A5568', autoSkip:false} }
    }
  };
}

function renderCharts(data){
  var byItem = countByItem(data).slice(0,10);
  var byPlc  = countBy(data, 'plcId').slice(0,10);

  /* 항목 가로 바 */
  destroyChart('item');
  charts['item'] = new Chart(document.getElementById('chartItem'), {
    type:'bar',
    data:{
      labels: byItem.map(function(e){ return e[0]; }),
      datasets:[{
        label:'알람 건수',
        data: byItem.map(function(e){ return e[1]; }),
        backgroundColor: byItem.map(function(_,i){ return RANK_COLORS[i%RANK_COLORS.length]; }),
        borderRadius:2, maxBarThickness:14
      }]
    },
    options: rankBarOpts()
  });

  /* PLC 가로 바 */
  destroyChart('plc');
  charts['plc'] = new Chart(document.getElementById('chartPlc'), {
    type:'bar',
    data:{
      labels: byPlc.map(function(e){ return e[0]; }),
      datasets:[{
        label:'알람 건수',
        data: byPlc.map(function(e){ return e[1]; }),
        backgroundColor: byPlc.map(function(_,i){ return RANK_COLORS[i%RANK_COLORS.length]; }),
        borderRadius:2, maxBarThickness:14
      }]
    },
    options: rankBarOpts()
  });

  /* 등급 비율 — 100% 누적 가로 막대 (도넛 대체) */
  var lvCnt = {1:0,2:0,3:0,4:0};
  data.forEach(function(r){ var l=parseInt(r.level)||0; if(lvCnt[l]!==undefined) lvCnt[l]++; });
  var LV_NAMES = ['위험(Lv1)','경고(Lv2)','주의(Lv3)','정보(Lv4)'];
  var lvTotal = lvCnt[1]+lvCnt[2]+lvCnt[3]+lvCnt[4];
  destroyChart('lvDist');
  charts['lvDist'] = new Chart(document.getElementById('chartLvDist'), {
    type:'bar',
    data:{
      labels:['비율'],
      datasets: LV_NAMES.map(function(n, i){
        return { label:n, data:[lvTotal ? lvCnt[i+1]/lvTotal*100 : 0], backgroundColor:LV_COLOR[i], borderWidth:0, barPercentage:1, categoryPercentage:1 };
      })
    },
    options:{
      responsive:true, maintainAspectRatio:false, animation:false, indexAxis:'y',
      plugins:{ legend:{display:false}, tooltip:{ callbacks:{ label:function(c){ return c.dataset.label+' '+c.raw.toFixed(1)+'%'; } } } },
      scales:{
        x:{ stacked:true, min:0, max:100, display:false },
        y:{ stacked:true, display:false }
      }
    }
  });
  var lg = document.getElementById('lvLegend');
  if(lg) lg.innerHTML = LV_NAMES.map(function(n, i){
    var pct = lvTotal ? (lvCnt[i+1]/lvTotal*100).toFixed(1) : '0.0';
    return '<div class="lv-row"><span><i style="background:'+LV_COLOR[i]+'"></i>'+n+'</span>'
      + '<span class="mono">'+lvCnt[i+1]+'</span><span class="mono" style="color:var(--al-fg3)">'+pct+'%</span></div>';
  }).join('');

  /* 등급 건수 — 가로 바 */
  destroyChart('lvBar');
  charts['lvBar'] = new Chart(document.getElementById('chartLvBar'), {
    type:'bar',
    data:{
      labels:LV_NAMES,
      datasets:[{
        label:'건수',
        data:[lvCnt[1],lvCnt[2],lvCnt[3],lvCnt[4]],
        backgroundColor:LV_COLOR,
        borderRadius:2, maxBarThickness:18
      }]
    },
    options: rankBarOpts()
  });
}

function esc(s){ return String(s||'').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;'); }

loadData();
</script>
</body>
</html>
