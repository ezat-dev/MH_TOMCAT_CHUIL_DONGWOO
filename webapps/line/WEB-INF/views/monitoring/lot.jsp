<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<script src="/line/mock/mock-loader.js"></script>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>LOT현황</title>
<%@include file="../include/pluginpage.jsp"%>
<jsp:include page="../include/tabBar.jsp" />

<link href="/vendor/tabulator/5.5.1/tabulator.min.css" rel="stylesheet">

<style>
    :root {
        --bg: #f4f6fa;
        --card: #ffffff;
        --line: #e4e8f0;
        --text: #1f2633;
        --muted: #6b7486;
        --blue: #2563eb;
        --wait: #d97706;   --wait-bg: #fff7e6;
        --run: #059669;    --run-bg: #e8f8f1;
        --done: #4b5563;   --done-bg: #eef1f5;
    }
    * { box-sizing: border-box; }
    body { background: var(--bg); font-family: "Pretendard", "Noto Sans KR", "맑은 고딕", sans-serif; color: var(--text); margin: 0; }
    .main { padding: 18px 22px 24px; }

    .page-head { display: flex; align-items: flex-end; justify-content: space-between; margin-bottom: 14px; }
    .page-title { font-size: 21px; font-weight: 800; }
    .page-sub { font-size: 13px; color: var(--muted); margin-top: 4px; }
    .live { display: inline-flex; align-items: center; gap: 8px; font-size: 13px; color: var(--muted);
            background: var(--card); border: 1px solid var(--line); border-radius: 20px; padding: 6px 14px; }
    .live-dot { width: 8px; height: 8px; border-radius: 50%; background: var(--run); animation: pulse 1.6s ease-in-out infinite; }
    @keyframes pulse { 0%, 100% { opacity: 1; } 50% { opacity: .3; } }

    /* KPI */
    .kpis { display: grid; grid-template-columns: repeat(4, 1fr); gap: 12px; margin-bottom: 14px; }
    .kpi { background: var(--card); border: 1px solid var(--line); border-radius: 12px; padding: 14px 18px; position: relative; overflow: hidden; }
    .kpi::before { content: ''; position: absolute; left: 0; top: 0; bottom: 0; width: 4px; background: var(--c, var(--blue)); }
    .kpi-label { font-size: 13px; color: var(--muted); font-weight: 600; }
    .kpi-value { font-size: 30px; font-weight: 800; margin-top: 4px; font-variant-numeric: tabular-nums; }
    .kpi-value small { font-size: 14px; font-weight: 600; color: var(--muted); margin-left: 4px; }
    .kpi.total { --c: var(--blue); } .kpi.wait { --c: var(--wait); } .kpi.run { --c: var(--run); } .kpi.done { --c: var(--done); }

    /* 라인 위 LOT 카드 */
    .section { background: var(--card); border: 1px solid var(--line); border-radius: 12px; padding: 16px 18px; margin-bottom: 14px; }
    .section-head { display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px; }
    .section-title { font-size: 15px; font-weight: 800; }
    .section-note { font-size: 12px; color: var(--muted); }
    .run-list { display: grid; grid-template-columns: repeat(auto-fill, minmax(420px, 1fr)); gap: 12px; }
    .run-card { border: 1px solid var(--line); border-radius: 10px; padding: 14px 16px; background: #fbfcfe; }
    .run-top { display: flex; justify-content: space-between; align-items: baseline; gap: 10px; }
    .run-lot { font-size: 17px; font-weight: 800; letter-spacing: .3px; }
    .run-meta { font-size: 13px; color: var(--muted); margin-top: 3px; }
    .run-stage { font-size: 13px; font-weight: 700; color: var(--run); background: var(--run-bg); border-radius: 6px; padding: 3px 9px; white-space: nowrap; }
    .run-stage.wait { color: var(--wait); background: var(--wait-bg); }
    .steps { display: grid; grid-template-columns: repeat(9, 1fr); gap: 4px; margin-top: 12px; }
    .step { height: 8px; border-radius: 4px; background: #e6eaf1; }
    .step.on { background: var(--run); }
    .step.now { background: var(--run); box-shadow: 0 0 0 3px rgba(5, 150, 105, .18); animation: pulse 1.6s ease-in-out infinite; }
    .step-labels { display: grid; grid-template-columns: repeat(9, 1fr); gap: 4px; margin-top: 5px; font-size: 11px; color: var(--muted); text-align: center; }
    .run-foot { display: flex; justify-content: space-between; font-size: 12.5px; color: var(--muted); margin-top: 10px; }
    .run-foot b { color: var(--text); font-weight: 700; }
    .empty { padding: 26px; text-align: center; color: var(--muted); font-size: 14px; }

    /* 목록 테이블 */
    #dataList { border: none; font-size: 14px; background: transparent; }
    #dataList .tabulator-header { background: #f6f8fb; border-bottom: 1px solid var(--line); color: #4a5468; font-weight: 700; }
    #dataList .tabulator-header .tabulator-col { background: transparent; border-right: none; }
    #dataList .tabulator-row { min-height: 42px; border-bottom: 1px solid #eef1f5; background: #fff; }
    #dataList .tabulator-row .tabulator-cell { padding: 11px 10px; border-right: none; }
    #dataList .tabulator-row.tabulator-selected { background: #eaf1ff; }
    .badge { display: inline-block; font-size: 12.5px; font-weight: 700; padding: 3px 10px; border-radius: 12px; }
    .badge.wait { color: var(--wait); background: var(--wait-bg); }
    .badge.run  { color: var(--run);  background: var(--run-bg); }
    .badge.done { color: var(--done); background: var(--done-bg); }
    .mono { font-family: Consolas, "JetBrains Mono", monospace; }
    .hidden-date { display: none; }

    /* 화면 높이 꽉 채움: 마지막 섹션(오늘 작업 목록)이 남은 높이 사용, 페이지 스크롤 없음 */
    html, body { height: 100%; overflow: hidden; }
    .main { height: 100vh; display: flex; flex-direction: column; }
    .main > .page-head, .main > .kpis, .main > .section { flex: none; }
    .main > .section:last-child { flex: 1; min-height: 0; margin-bottom: 0; display: flex; flex-direction: column; }
    .main > .section:last-child #dataList { flex: 1; min-height: 0; }
</style>
</head>
<body>

<main class="main">
    <div class="page-head">
        <div>
            <div class="page-title">LOT 현황</div>
            <div class="page-sub">열처리 연속 라인 투입 LOT의 공정 위치와 진행 상태 · <span id="todayText"></span></div>
        </div>
        <div class="live"><span class="live-dot"></span>실시간 · 5초 갱신 <span id="lastUpdate" class="mono"></span></div>
    </div>

    <div class="kpis">
        <div class="kpi total"><div class="kpi-label">오늘 등록 LOT</div><div class="kpi-value"><span id="kTotal">-</span><small>건</small></div></div>
        <div class="kpi wait"><div class="kpi-label">투입 대기 (QR 확인)</div><div class="kpi-value"><span id="kWait">-</span><small>건</small></div></div>
        <div class="kpi run"><div class="kpi-label">라인 진행 중</div><div class="kpi-value"><span id="kRun">-</span><small>건</small></div></div>
        <div class="kpi done"><div class="kpi-label">작업 완료</div><div class="kpi-value"><span id="kDone">-</span><small>건</small></div></div>
    </div>

    <div class="section">
        <div class="section-head">
            <div class="section-title">라인 위 LOT</div>
            <div class="section-note">투입 → 전세정 → 소입로 → 소입유조 → 중간세정 → 소려로 → 방청 → 냉각 → 종료</div>
        </div>
        <div id="runList" class="run-list"></div>
    </div>

    <div class="section">
        <div class="section-head">
            <div class="section-title">오늘 작업 목록</div>
            <div class="section-note">행 색상 대신 상태 배지로 구분</div>
        </div>
        <input type="text" class="daySet hidden-date" id="daySetStart">
        <input type="text" class="daySet hidden-date" id="daySetEnd">
        <div id="dataList"></div>
    </div>
</main>

<script>
let now_page_code = "b05";

// 공정 단계 (각 LOT 행의 도착 시각 필드)
const STAGES = [
    { name: '투입',     fields: ['d370', 'start_hoper_2'] },
    { name: '전세정',   fields: ['f_wash_3'] },
    { name: '소입로',   fields: ['qf1_4', 'qf2_5', 'qf3_6', 'qf4_7', 'qf5_8'] },
    { name: '소입유조', fields: ['oil_9'] },
    { name: '중간세정', fields: ['m_wash_10'] },
    { name: '소려로',   fields: ['tf1_11', 'tf2_12', 'tf3_13', 'tf4_14', 'tf5_15'] },
    { name: '방청',     fields: ['bch_16'] },
    { name: '냉각',     fields: ['con_17'] },
    { name: '종료',     fields: ['l20'] }
];

function toDate(v) { return v ? new Date(String(v).replace(' ', 'T')) : null; }
function passed(v, now) { const d = toDate(v); return d && d <= now; }
function hhmm(v) { const d = toDate(v); return d && d <= new Date() ? String(v).split(' ')[1].slice(0, 5) : ''; }
function fmtDate(d) { return d.getFullYear() + '-' + String(d.getMonth() + 1).padStart(2, '0') + '-' + String(d.getDate()).padStart(2, '0'); }
function esc(s) { return String(s == null ? '' : s).replace(/[&<>"]/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c])); }

// 현재 공정 단계 index (-1 = 아직 투입 전)
function stageIndex(r, now) {
    let idx = -1;
    STAGES.forEach((s, i) => { if (s.fields.some((f) => passed(r[f], now))) idx = i; });
    return idx;
}
function statusOf(r, now) {
    if (passed(r.l20, now)) return 'done';
    if (stageIndex(r, now) >= 0) return 'run';
    return 'wait';
}
const STATUS_LABEL = { wait: '투입 대기', run: '진행 중', done: '완료' };

function minutesSince(v, now) { const d = toDate(v); return d ? Math.max(0, Math.round((now - d) / 60000)) : 0; }
function durText(min) { return min >= 60 ? Math.floor(min / 60) + '시간 ' + (min % 60) + '분' : min + '분'; }

function renderCards(rows, now) {
    const active = rows.filter((r) => statusOf(r, now) !== 'done');
    if (!active.length) { $('#runList').html('<div class="empty">현재 라인에 진행 중인 LOT가 없습니다.</div>'); return; }
    const html = active.map((r) => {
        const st = statusOf(r, now);
        const si = stageIndex(r, now);
        const steps = STAGES.map((s, i) => '<div class="step' + (i < si ? ' on' : i === si ? ' now' : '') + '"></div>').join('');
        const labels = STAGES.map((s) => '<div>' + s.name + '</div>').join('');
        const stageText = st === 'wait' ? '투입 대기' : STAGES[si].name + ' 통과 중';
        const startAt = r.d370 && passed(r.d370, now) ? r.d370 : null;
        return '<div class="run-card">' +
            '<div class="run-top"><div><div class="run-lot mono">' + esc(r.w_ci_lot) + '</div>' +
            '<div class="run-meta">' + esc(r.cust_name) + ' · ' + esc(r.item_name) + (r.item_no ? ' (' + esc(r.item_no) + ')' : '') + '</div></div>' +
            '<span class="run-stage' + (st === 'wait' ? ' wait' : '') + '">' + stageText + '</span></div>' +
            '<div class="steps">' + steps + '</div><div class="step-labels">' + labels + '</div>' +
            '<div class="run-foot"><span>ERP <b class="mono">' + esc(r.erp_jack_no) + '</b></span>' +
            (startAt ? '<span>투입 <b class="mono">' + hhmm(startAt) + '</b> · 경과 <b>' + durText(minutesSince(startAt, now)) + '</b></span>'
                     : '<span>등록 <b class="mono">' + hhmm(r.regtime) + '</b> · QR 확인 완료</span>') +
            '</div></div>';
    }).join('');
    $('#runList').html(html);
}

function renderKpis(rows, now) {
    const c = { wait: 0, run: 0, done: 0 };
    rows.forEach((r) => { c[statusOf(r, now)]++; });
    $('#kTotal').text(rows.length); $('#kWait').text(c.wait); $('#kRun').text(c.run); $('#kDone').text(c.done);
}

let dataTable = null;
function buildTable() {
    dataTable = new Tabulator('#dataList', {
        layout: 'fitColumns',
        height: '100%',
        selectable: 1,
        placeholder: '오늘 등록된 LOT가 없습니다.',
        columns: [
            { title: 'NO', width: 60, hozAlign: 'center', headerHozAlign: 'center', headerSort: false, formatter: (cell) => cell.getRow().getPosition(true) + 1 },
            { title: '상태', field: '_status', width: 100, hozAlign: 'center', headerHozAlign: 'center', headerSort: false,
              formatter: (cell) => { const s = cell.getValue(); return '<span class="badge ' + s + '">' + STATUS_LABEL[s] + '</span>'; } },
            { title: '작업 LOT', field: 'w_ci_lot', minWidth: 140, hozAlign: 'center', headerHozAlign: 'center', headerSort: false, cssClass: 'mono' },
            { title: 'ERP 작지번호', field: 'erp_jack_no', minWidth: 140, hozAlign: 'center', headerHozAlign: 'center', headerSort: false, cssClass: 'mono' },
            { title: '업체명', field: 'cust_name', minWidth: 110, headerHozAlign: 'center', headerSort: false },
            { title: '품명', field: 'item_name', minWidth: 140, headerHozAlign: 'center', headerSort: false },
            { title: '현재 공정', field: '_stage', minWidth: 100, hozAlign: 'center', headerHozAlign: 'center', headerSort: false },
            { title: '작업등록', field: 'regtime', width: 95, hozAlign: 'center', headerHozAlign: 'center', headerSort: false, formatter: (c) => hhmm(c.getValue()) },
            { title: '투입시작', field: 'd370', width: 95, hozAlign: 'center', headerHozAlign: 'center', headerSort: false, formatter: (c) => hhmm(c.getValue()) },
            { title: '투입종료', field: 'x111', width: 95, hozAlign: 'center', headerHozAlign: 'center', headerSort: false, formatter: (c) => hhmm(c.getValue()) },
            { title: '로트 종료', field: 'l20', width: 95, hozAlign: 'center', headerHozAlign: 'center', headerSort: false, formatter: (c) => hhmm(c.getValue()) }
        ]
    });
}

function loadData() {
    $.ajax({
        url: '/line/monitoring/lotProcessor/list',
        type: 'POST',
        dataType: 'json',
        data: { startDay: $('#daySetStart').val(), endDay: $('#daySetEnd').val() },
        success: function (res) {
            const now = new Date();
            const rows = (res && res.data) || res || [];
            rows.forEach((r) => {
                r._status = statusOf(r, now);
                const si = stageIndex(r, now);
                r._stage = r._status === 'done' ? '종료' : si >= 0 ? STAGES[si].name : '-';
            });
            renderKpis(rows, now);
            renderCards(rows, now);
            if (dataTable) dataTable.replaceData(rows);
            $('#lastUpdate').text(String(now.getHours()).padStart(2, '0') + ':' + String(now.getMinutes()).padStart(2, '0') + ':' + String(now.getSeconds()).padStart(2, '0'));
        }
    });
}

$(function () {
    const today = fmtDate(new Date());
    $('#daySetStart').val(today);
    $('#daySetEnd').val(today);
    $('#todayText').text(today);
    buildTable();
    loadData();
    setInterval(loadData, 5000);
    $(window).on('resize', function () { if (dataTable) dataTable.redraw(); });
});
</script>

</body>
</html>
