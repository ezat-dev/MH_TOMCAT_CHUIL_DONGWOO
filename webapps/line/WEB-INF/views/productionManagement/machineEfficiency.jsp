<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="ko">
<head>
<script src="/line/mock/mock-loader.js"></script>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>설비 효율현황</title>
	<%@include file="../include/pluginpage.jsp" %>
    <jsp:include page="../include/tabBar.jsp"/>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=IBM+Plex+Mono:wght@400;500&family=IBM+Plex+Sans+KR:wght@400;500;600&display=swap">
<style>
    :root {
        --bg: #f8f9fb; --card: #ffffff; --line: #e1e5ea; --line2: #eef0f3;
        --ink: #1b222c; --ink2: #333c48; --mute: #5b6470; --mute2: #8d949e;
        --blue: #3b6fc4; --teal: #3e9a5c; --amber: #b8862a; --red: #c2453d;
        --sans: "IBM Plex Sans KR", "Pretendard", "Malgun Gothic", "맑은 고딕", sans-serif;
        --mono: "IBM Plex Mono", Consolas, "Malgun Gothic", monospace;
    }
    html, body { background: var(--bg); }
    body { margin: 0; color: var(--ink); font-size: 13px; font-family: var(--sans); }
    .oee { box-sizing: border-box; height: 100vh; min-height: 720px; padding: 16px 16px 16px;
        display: grid; grid-template-rows: auto minmax(320px, 1fr) minmax(0, max-content);  /* 하단 표는 내용 높이만, 남는 높이는 차트로 */ gap: 12px; }
    .oee *, .oee *::before, .oee *::after { box-sizing: border-box; }
    .num { font-family: var(--mono); font-variant-numeric: tabular-nums slashed-zero; }

    /* 헤더 */
    .hd { display: flex; align-items: center; gap: 12px; }
    .hd h1 { margin: 0; font-size: 18px; font-weight: 700; letter-spacing: -0.3px; }
    .hd .sub { color: var(--mute); font-size: 13px; }
    .hd .sp { flex: 1; }
    .seg { display: inline-flex; background: #fff; border: 1px solid var(--line); border-radius: 8px; padding: 3px; }
    .seg button { border: 0; background: transparent; padding: 6px 16px; font-size: 13px; color: var(--ink2);
        border-radius: 6px; cursor: pointer; font-family: inherit; }
    .seg button.on { background: var(--ink); color: #fff; font-weight: 600; }
    .upd { color: var(--mute2); font-size: 12px; }

    /* 카드 */
    .row { display: grid; gap: 12px; min-height: 0; }
    .row.r1 { grid-template-columns: 400px minmax(0, 1fr); }
    .row.r2 { grid-template-columns: minmax(0, 1fr) 400px; }
    .card { background: var(--card); border: 1px solid var(--line); border-radius: 8px; padding: 12px 16px;
        display: flex; flex-direction: column; min-height: 0; min-width: 0; }
    .card h3 { margin: 0 0 8px; font-size: 14px; font-weight: 600; color: var(--ink);
        display: flex; align-items: center; justify-content: space-between; }
    .card h3 small { font-size: 12px; font-weight: 400; color: var(--mute2); }
    .chart { flex: 1; min-height: 0; }

    /* OEE 요약: 히어로 수치 + 손실 분해(계획시간 100% → 가동 → 성능 → 품질 = OEE) */
    .sum { flex: 1; display: flex; flex-direction: column; gap: 16px; min-height: 0; }
    .hero { display: flex; align-items: flex-end; justify-content: space-between; gap: 16px; padding-bottom: 12px; border-bottom: 1px solid var(--line2); }
    .hero .v { font-family: var(--mono); font-size: 44px; font-weight: 500; letter-spacing: -1px; line-height: 1; }
    .hero .v u { text-decoration: none; font-family: var(--sans); font-size: 16px; font-weight: 400; color: var(--mute2); margin-left: 4px; }
    .hero .meta { display: grid; grid-template-columns: auto auto; gap: 4px 12px; font-size: 12px; color: var(--mute); text-align: right; white-space: nowrap; }
    .hero .meta b { font-family: var(--mono); font-weight: 500; color: var(--ink); }
    .fac { flex: 1; display: flex; flex-direction: column; justify-content: space-evenly; gap: 12px; min-height: 0; }
    .fac .lb { display: flex; align-items: baseline; gap: 8px; font-size: 12px; color: var(--mute); margin-bottom: 4px; }
    .fac .lb .nm { color: var(--ink2); font-weight: 500; font-size: 13px; }
    .fac .lb .op { width: 12px; color: var(--mute2); font-family: var(--mono); }
    .fac .lb .sp { flex: 1; }
    .fac .lb b { font-family: var(--mono); font-weight: 500; color: var(--ink); font-size: 14px; }
    .fac .lb .ls { font-family: var(--mono); font-size: 12px; color: var(--mute2); width: 64px; text-align: right; }
    .fac .tr { position: relative; height: 12px; background: var(--line2); border-radius: 2px; }
    .fac .tr i { position: absolute; top: 0; bottom: 0; left: 0; border-radius: 2px 0 0 2px; background: #9aa3ae; }
    .fac .tr s { position: absolute; top: 0; bottom: 0; background: repeating-linear-gradient(135deg, #e7c9c6 0 3px, #f6e7e5 3px 6px); }
    .fac .tr em { position: absolute; top: -2px; width: 2px; height: 16px; background: var(--ink2); }
    .fac .res .tr i { background: var(--blue); }
    .fac .res .lb .nm { color: var(--ink); font-weight: 600; }
    .fac .bad b { color: var(--red); } .fac .warn b { color: var(--amber); }
    .fac-note { margin-top: auto; font-size: 12px; color: var(--mute2); display: flex; gap: 12px; align-items: center; }
    .fac-note i { display: inline-block; width: 12px; height: 8px; margin-right: 4px; vertical-align: 0; }

    /* 설비 테이블 */
    .tbl-wrap { flex: 1; min-height: 0; overflow: auto; }
    table.eq { width: 100%; border-collapse: collapse; font-size: 13px; }
    table.eq th { position: sticky; top: 0; background: #fff; color: var(--mute); font-weight: 600; font-size: 12px;
        text-align: right; padding: 0 10px 8px; border-bottom: 1px solid var(--line); white-space: nowrap; }
    table.eq td { padding: 0 10px; height: 38px; border-bottom: 1px solid var(--line2); white-space: nowrap; text-align: right; }
    table.eq th:first-child, table.eq td:first-child, table.eq th:nth-child(2), table.eq td:nth-child(2) { text-align: left; }
    table.eq tr:last-child td { border-bottom: 0; }
    table.eq th, table.eq .en, table.eq .st { font-family: var(--sans); }
    table.eq tbody tr:hover td { background: #f6f7f9; }
    .en { font-weight: 500; }
    .st { font-size: 12px; font-weight: 600; }
    .st::before { content: ""; display: inline-block; width: 7px; height: 7px; border-radius: 50%; background: currentColor; margin-right: 6px; vertical-align: 0; }
    .st.run { color: var(--teal); } .st.stop { color: var(--red); } .st.wait { color: var(--amber); }
    .oe { font-weight: 700; }

    /* 비가동 TOP */
    .top { flex: 1; display: flex; flex-direction: column; gap: 20px; padding-top: 6px; min-height: 0; overflow: auto; }
    .top .it .lb { display: flex; justify-content: space-between; font-size: 13px; margin-bottom: 5px; }
    .top .it .lb span { color: var(--ink2); }
    .top .it .lb b { font-weight: 600; } .top .it .lb small { color: var(--mute2); font-weight: 400; margin-left: 6px; }
    .top .it .tr { height: 8px; background: var(--line2); border-radius: 4px; overflow: hidden; }
    .top .it .tr i { display: block; height: 100%; border-radius: 4px; background: #94a3b8; }
    .top .it:first-child .tr i { background: var(--red); }
    .empty { color: var(--mute2); text-align: center; margin: auto; }
</style>
</head>
<body>
<div class="oee">
    <div class="hd">
        <h1>설비효율현황</h1>
        <span class="sub" id="rangeLbl"></span>
        <div class="sp"></div>
        <span class="upd num" id="upd"></span>
        <div class="seg" id="seg">
            <button data-p="today" class="on">오늘</button>
            <button data-p="yesterday">어제</button>
            <button data-p="3d">최근 3일</button>
        </div>
    </div>

    <div class="row r1">
        <div class="card">
            <h3>종합 설비효율 (OEE) <small id="gTag"></small></h3>
            <div class="sum">
                <div class="hero">
                    <div class="v" id="oeeV">-</div>
                    <div class="meta" id="oeeS"></div>
                </div>
                <div class="fac" id="fac"></div>
                <div class="fac-note">
                    <span><i style="background:#9aa3ae"></i>남은 시간</span>
                    <span><i style="background:repeating-linear-gradient(135deg,#e7c9c6 0 3px,#f6e7e5 3px 6px)"></i>단계별 손실</span>
                    <span><i style="background:#333c48;width:2px"></i>목표</span>
                </div>
            </div>
        </div>
        <div class="card">
            <h3>시간대별 OEE · 생산량 <small>막대: 생산량(kg) &nbsp;·&nbsp; 선: OEE(%)</small></h3>
            <div class="chart" id="cTrend"></div>
        </div>
    </div>

    <div class="row r2">
        <div class="card">
            <h3>설비별 효율 <small id="eqTag"></small></h3>
            <div class="tbl-wrap">
                <table class="eq num">
                    <thead><tr>
                        <th>설비</th><th>상태</th><th>시간가동률</th><th>성능가동률</th><th>양품률</th><th>가동시간</th><th>비가동</th><th>OEE</th>
                    </tr></thead>
                    <tbody id="eqBody"></tbody>
                </table>
            </div>
        </div>
        <div class="card">
            <h3>비가동 원인 TOP 5 <small id="parTag"></small></h3>
            <div class="top" id="top"></div>
        </div>
    </div>
</div>

<script>
let now_page_code = "c03";

var C = { blue: '#3b6fc4', blueL: '#dbe3f1', teal: '#3e9a5c', amber: '#b8862a', red: '#c2453d', mute: '#5b6470', ink2: '#333c48', grid: '#eef0f3' };
var period = 'today', charts = {};

Highcharts.setOptions({
    lang: { thousandsSep: ',', numericSymbols: null },
    chart: { style: { fontFamily: '"IBM Plex Sans KR","Pretendard","Malgun Gothic","맑은 고딕",sans-serif' }, animation: { duration: 400 } },
    title: { text: null }, credits: { enabled: false }, exporting: { enabled: false }, legend: { enabled: false },
    tooltip: { backgroundColor: 'rgba(15,23,42,0.92)', borderWidth: 0, borderRadius: 6, shadow: false,
               style: { color: '#fff', fontSize: '12px' }, shared: true, useHTML: true }
});

function f0(v) { return Highcharts.numberFormat(v, 0); }
function f1(v) { return Highcharts.numberFormat(v, 1); }
function lvlColor(v, t) { var band = t >= 99 ? 0.5 : 5; return v >= t ? C.teal : (v >= t - band ? C.amber : C.red); }

function load(p) {
    period = p || period;
    $('#seg button').removeClass('on').filter('[data-p="' + period + '"]').addClass('on');
    $.ajax({ url: '/line/productionManagement/machineEfficiency/data', type: 'POST', data: { period: period }, dataType: 'json',
        success: render });
}

function render(d) {
    $('#rangeLbl').text(d.line + ' · ' + d.label + (d.period === 'today' ? ' 00:00 ~ ' + d.updated.substr(11, 5) : ''));
    $('#upd').text('갱신 ' + d.updated.substr(11, 8));
    $('#eqTag').text(d.period === '3d' ? '최근 3일 누적' : (d.period === 'today' ? '오늘 누적' : '어제'));
    renderSummary(d);
    renderTrend(d);
    renderEquip(d);
    renderTop(d);
}

function renderSummary(d) {
    var k = d.kpi, T = d.target, p = d.prev;
    $('#gTag').text('목표 ' + T.oee + '%');
    $('#oeeV').html(f1(k.oee) + '<u>%</u>').css('color', lvlColor(k.oee, T.oee));
    var gap = k.oee - T.oee;
    var s = '<span>목표 대비</span><b style="color:' + (gap >= 0 ? C.teal : C.red) + '">' + (gap >= 0 ? '+' : '−') + f1(Math.abs(gap)) + '%p</b>';
    if (p) { var dd = k.oee - p.oee; s += '<span>전일 대비</span><b>' + (dd >= 0 ? '+' : '−') + f1(Math.abs(dd)) + '%p</b>'; }
    s += '<span>생산</span><b>' + f0(k.kg) + ' kg</b><span>비가동</span><b>' + f0(k.down_min) + ' 분</b>';
    $('#oeeS').html(s);

    // 계획 가동시간(100%)에서 단계별로 곱해 내려가며 손실 구간을 빗금으로 표시
    var cum = 100, rows = [['시간가동률', k.a, T.a, 1], ['성능가동률', k.p, T.p, 1], ['양품률', k.q, T.q, 2]].map(function (x, i) {
        var before = cum; cum = cum * x[1] / 100;
        var st = x[1] >= x[2] ? '' : (x[1] >= x[2] - (x[2] >= 99 ? 0.5 : 5) ? 'warn' : 'bad');
        return '<div class="' + st + '"><div class="lb"><span class="op">' + (i ? '×' : '') + '</span><span class="nm">' + x[0] + '</span>' +
            '<span>목표 ' + x[2] + '%</span><span class="sp"></span><b>' + Highcharts.numberFormat(x[1], x[3]) + '%</b>' +
            '<span class="ls">−' + f1(before - cum) + '%p</span></div>' +
            '<div class="tr"><i style="width:' + cum + '%"></i><s style="left:' + cum + '%;width:' + (before - cum) + '%"></s>' +
            '<em style="left:' + (before * x[2] / 100) + '%"></em></div></div>';
    });
    rows.push('<div class="res"><div class="lb"><span class="op">=</span><span class="nm">종합 설비효율</span><span>목표 ' + T.oee + '%</span>' +
        '<span class="sp"></span><b>' + f1(k.oee) + '%</b><span class="ls">−' + f1(100 - k.oee) + '%p</span></div>' +
        '<div class="tr"><i style="width:' + k.oee + '%"></i><em style="left:' + T.oee + '%"></em></div></div>');
    $('#fac').html(rows.join(''));
}

function renderTrend(d) {
    var hs = d.hourly, multi = hs.length > 30;
    var cats = hs.map(function (h) { return multi ? (h.hh === '00' ? h.t.substr(0, 5).replace('-', '/') : h.hh) : h.hh + '시'; });
    var lines = [];
    hs.forEach(function (h, i) { if (h.hh === '00' && i > 0) lines.push({ value: i - 0.5, color: '#cbd5e1', width: 1, dashStyle: 'Dash' }); });
    var maxKg = Math.max.apply(null, hs.map(function (h) { return h.kg; }).concat([100]));
    var step = Math.ceil(maxKg * 1.15 / 4 / 50) * 50;
    var opt = {
        chart: { backgroundColor: 'transparent', spacing: [6, 2, 2, 2] },
        xAxis: { categories: cats, plotLines: lines, lineColor: '#e3e8ef', tickLength: 0,
            labels: { style: { color: C.mute, fontSize: '11px' }, step: multi ? 3 : 1, rotation: 0 } },
        yAxis: [
            { title: { text: null }, min: 0, max: 100, tickPositions: [0, 25, 50, 75, 100], gridLineColor: C.grid,
              labels: { format: '{value}%', style: { color: C.mute, fontSize: '11px' } },
              plotLines: [{ value: d.target.oee, color: C.amber, width: 1, dashStyle: 'ShortDash', zIndex: 4,
                  label: { text: '목표 ' + d.target.oee + '%', align: 'right', x: -4, y: -5, style: { color: C.amber, fontSize: '11px' } } }] },
            { title: { text: null }, tickPositions: [0, step, 2 * step, 3 * step, 4 * step], opposite: true, gridLineWidth: 0,
              labels: { formatter: function () { return f0(this.value); }, style: { color: C.mute, fontSize: '11px' } } }
        ],
        tooltip: { formatter: function () {
            var h = hs[this.points[0].point.index];
            return '<b>' + h.t + '</b><br/>OEE <b>' + f1(h.oee) + '%</b><br/>생산량 ' + f0(h.kg) + 'kg' +
                (h.down ? '<br/><span style="color:#fca5a5">비가동 ' + h.down + '분</span>' : '');
        } },
        plotOptions: { series: { animation: { duration: 400 } },
            column: { borderWidth: 0, borderRadius: 2, pointPadding: 0.08, groupPadding: 0.06 },
            spline: { lineWidth: 2.2, marker: { enabled: false } } },
        series: [
            { type: 'column', name: '생산량', yAxis: 1, color: C.blueL, data: hs.map(function (h) { return h.kg; }) },
            { type: 'spline', name: 'OEE', color: C.blue, data: hs.map(function (h) { return h.oee; }) }
        ]
    };
    if (charts.trend) charts.trend.destroy();
    charts.trend = Highcharts.chart('cTrend', opt);
}

function renderEquip(d) {
    var T = d.target;
    $('#eqBody').html(d.equipments.map(function (e) {
        var st = e.status === '가동' ? 'run' : e.status === '정지' ? 'stop' : 'wait';
        return '<tr><td class="en">' + e.name + '</td>' +
            '<td><span class="st ' + st + '">' + e.status + '</span></td>' +
            '<td>' + f1(e.a) + '%</td><td>' + f1(e.p) + '%</td><td>' + Highcharts.numberFormat(e.q, 2) + '%</td>' +
            '<td>' + f1(e.run_min / 60) + 'h</td>' +
            '<td style="color:' + (e.down_min ? C.ink2 : C.mute) + '">' + f0(e.down_min) + '분</td>' +
            '<td class="oe" style="color:' + lvlColor(e.oee, T.oee) + '">' + f1(e.oee) + '%</td></tr>';
    }).join(''));
}

function renderTop(d) {
    var ps = d.pareto, tot = ps.reduce(function (a, x) { return a + x.min; }, 0);
    $('#parTag').text('총 ' + f0(tot) + '분 · ' + d.events.length + '건');
    var top = ps.slice(0, 5), max = top.length ? top[0].min : 1;
    $('#top').html(top.length ? top.map(function (x) {
        return '<div class="it"><div class="lb"><span>' + x.reason + '</span><b class="num">' + f0(x.min) + '분<small>' + x.count + '건</small></b></div>' +
            '<div class="tr"><i style="width:' + Math.max(2, x.min / max * 100) + '%"></i></div></div>';
    }).join('') : '<div class="empty">비가동 이력 없음</div>');
}

$(function () {
    $('#seg').on('click', 'button', function () { load($(this).data('p')); });
    var qp = (location.search.match(/period=(today|yesterday|3d)/) || [])[1];
    load(qp || 'today');
    var rt; $(window).on('resize', function () { clearTimeout(rt); rt = setTimeout(function () { for (var k in charts) charts[k].reflow(); }, 150); });
    /* 하단 표가 채워지며 차트 칸 높이가 바뀌어도 차트를 칸에 맞춤 */
    if (window.ResizeObserver) new ResizeObserver(function () { clearTimeout(rt); rt = setTimeout(function () { for (var k in charts) charts[k].reflow(); }, 50); }).observe(document.getElementById("cTrend"));
});
</script>
</body>
</html>
