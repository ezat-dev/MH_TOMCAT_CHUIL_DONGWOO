/* ===== 데모: Cpk / Ppk 화면 공통 표시 보조 (조회·저장 로직은 각 화면 원본 그대로) ===== */
var CPX = (function () {
    var C = {
        fg: "#2a2f38", fg2: "#5b616c", fg3: "#8b919b", line: "#e3e6eb", line2: "#eef0f3",
        accent: "#2f6fb8", ok: "#3f9a63", warn: "#c08a1e", bad: "#c4473c"
    };

    function num(v) { var n = parseFloat(v); return isNaN(n) ? null : n; }
    function fmt(v, dp) { var n = num(v); return n == null ? "—" : n.toFixed(dp == null ? 2 : dp); }

    // 공정능력 판정: 1.67 이상 우수 / 1.33 이상 양호 / 1.00 이상 개선 필요 / 미만 부족
    function judge(v) {
        var n = num(v);
        if (n == null) return { cls: "", key: "none", text: "데이터 없음" };
        if (n >= 1.67) return { cls: "is-ok", key: "best", text: "우수" };
        if (n >= 1.33) return { cls: "is-good", key: "good", text: "양호" };
        if (n >= 1.00) return { cls: "is-warn", key: "warn", text: "개선 필요" };
        return { cls: "is-bad", key: "bad", text: "부족" };
    }

    // 0 ~ 2.0 눈금 위에 현재 지수 위치 표시
    function scale(el, v) {
        if (!el) return;
        if (!el.firstChild) {
            el.innerHTML = '<div class="track"></div>' + [1.00, 1.33, 1.67].map(function (t) {
                return '<div class="tick" style="left:' + (t / 2 * 100) + '%"><span>' + t.toFixed(2) + '</span></div>';
            }).join("") + '<div class="mark" hidden></div>';
        }
        var m = el.querySelector(".mark"), n = num(v);
        m.hidden = n == null;
        if (n != null) m.style.left = Math.max(0, Math.min(100, n / 2 * 100)) + "%";
    }

    function hero(valEl, judgeEl, scaleEl, v) {
        var j = judge(v);
        valEl.textContent = fmt(v);
        valEl.className = j.cls;
        judgeEl.textContent = j.text;
        judgeEl.className = "cpx-judge " + j.cls;
        scale(scaleEl, v);
        return j;
    }

    // 지수 열 셀에 판정 색 (Tabulator 가 행을 다시 그려도 유지되도록 관찰)
    function tagCells(root, field) {
        if (!root) return;
        function run() {
            root.querySelectorAll('.tabulator-cell[tabulator-field="' + field + '"]').forEach(function (c) {
                var j = judge(c.textContent);
                c.classList.remove("is-ok", "is-good", "is-warn", "is-bad");
                c.classList.add("cpx-num");
                if (j.cls) c.classList.add(j.cls);
            });
        }
        new MutationObserver(run).observe(root, { childList: true, subtree: true });
        run();
    }

    function findChart(id) {
        return (window.Highcharts && Highcharts.charts || []).filter(function (c) { return c && c.renderTo && c.renderTo.id === id; }).pop();
    }

    // 시리즈 이름별 선 스타일 (색만 정리, 데이터·시리즈 구성은 그대로)
    function styleSeries(id, map) {
        var ch = findChart(id);
        if (!ch) return;
        ch.series.forEach(function (s) {
            var st = map[s.name];
            if (st) s.update(st, false);
        });
        ch.redraw(false);
    }

    if (window.Highcharts) {
        Highcharts.setOptions({
            chart: { style: { fontFamily: '"IBM Plex Sans KR","Pretendard","Malgun Gothic",sans-serif' }, spacing: [8, 8, 8, 0],
                     events: { load: function () { var c = this; setTimeout(function () { c.reflow(); }, 0); } } },
            credits: { enabled: false },
            xAxis: { lineColor: C.line, tickColor: C.line, labels: { style: { color: C.fg3, fontSize: "11px" } } },
            yAxis: { gridLineColor: C.line2, labels: { style: { color: C.fg3, fontSize: "11px" } }, title: { style: { color: C.fg3, fontSize: "11px" } } },
            legend: { itemStyle: { color: C.fg2, fontWeight: "500" } },
            tooltip: { backgroundColor: "#fff", borderColor: C.line, shadow: false, style: { fontSize: "12px" } }
        });
    }

    // 차트 칸 크기가 바뀌면(레이아웃 확정·창 크기 변경) 차트를 칸에 다시 맞춤
    if (window.ResizeObserver) {
        $(function () {
            var ro = new ResizeObserver(function (es) {
                es.forEach(function (e) { var ch = findChart(e.target.id); if (ch) ch.reflow(); });
            });
            document.querySelectorAll(".cpx-chart").forEach(function (el) { ro.observe(el); });
        });
    }

    return { C: C, num: num, fmt: fmt, judge: judge, scale: scale, hero: hero, tagCells: tagCells, styleSeries: styleSeries };
})();
