<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="ko">
<head>
<script src="/line/mock/mock-loader.js"></script>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>LOT트레킹</title>
    <%@include file="../include/pluginpage.jsp" %>
    <jsp:include page="../include/tabBar.jsp"/>
    <style>
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

        html, body {
            width: 100%;
            overflow-x: hidden;
            background: #f0f2f5;
            font-family: 'Noto Sans KR', '맑은 고딕', sans-serif;
            font-size: 13px;
        }

        /* ── 컨트롤 바 ── */
        #controlBar {
            width: 100%;
            background: #1a2236;
            display: flex;
            align-items: center;
            flex-wrap: wrap;
            gap: 8px;
            padding: 9px 16px;
            box-shadow: 0 3px 10px rgba(0,0,0,.35);
            position: sticky;
            top: 0;
            z-index: 600;
        }

        .bar-label { color: #8fa8cc; font-size: 12px; white-space: nowrap; }
        .bar-sep   { color: #fff; }

        .bar-input {
            height: 33px; padding: 0 10px;
            border: 1px solid #3a4a6a; border-radius: 5px;
            background: #253047; color: #e0e8f8;
            font-size: 13px; width: 120px; text-align: center;
        }
        .bar-input::placeholder { color: #4a6080; }
        .bar-input:focus { outline: none; border-color: #4e8ef7; background: #2a3a58; }

        .btn {
            height: 33px; padding: 0 14px; border: none; border-radius: 5px;
            cursor: pointer; font-size: 13px; font-weight: 600;
            display: inline-flex; align-items: center; gap: 5px;
            white-space: nowrap; transition: filter .15s;
        }
        .btn:hover { filter: brightness(1.15); }
        .btn img   { width: 14px; height: 14px; }
        .btn-blue  { background: #3d7ef5; color: #fff; }
        .btn-gray  { background: #374560; color: #c5d0e8; }
        .btn-green { background: #27a548; color: #fff; }
        .btn-amber { background: #d1a976; color: #fff; }

        .refresh-info {
            margin-left: auto; display: flex; align-items: center;
            gap: 6px; color: #6a8ab8; font-size: 11px; white-space: nowrap;
        }
        .pulse-dot {
            width: 7px; height: 7px; border-radius: 50%;
            background: #2ea84c; flex-shrink: 0;
            animation: blink 1.8s infinite;
        }
        @keyframes blink {
            0%,100% { opacity:1; transform:scale(1); }
            50%      { opacity:.3; transform:scale(.7); }
        }

        /* ══════════════════════════
           로트 지정 버튼 + 호버 툴팁
        ══════════════════════════ */
        .lot-btn-wrap {
            position: relative;
            display: inline-flex;
            align-items: center;
        }

        .lot-tooltip {
            display: none;
            position: absolute;
            top: calc(100% + 11px);
            left: 50%;
            transform: translateX(-50%);
            width: 298px;
            background: #0d1626;
            border: 1px solid #2b4268;
            border-radius: 9px;
            padding: 12px 13px 10px;
            box-shadow: 0 8px 28px rgba(0,0,0,.6);
            z-index: 900;
            pointer-events: none;
        }
        .lot-btn-wrap:hover .lot-tooltip {
            display: block;
            animation: tipIn .14s ease;
        }
        @keyframes tipIn {
            from { opacity:0; transform: translateX(-50%) translateY(-5px); }
            to   { opacity:1; transform: translateX(-50%) translateY(0); }
        }
        .lot-tooltip::before {
            content:''; position:absolute;
            top:-7px; left:50%; transform:translateX(-50%);
            border:7px solid transparent;
            border-top:none; border-bottom-color:#2b4268;
        }
        .lot-tooltip::after {
            content:''; position:absolute;
            top:-6px; left:50%; transform:translateX(-50%);
            border:6px solid transparent;
            border-top:none; border-bottom-color:#0d1626;
        }
        .tip-head {
            font-size:11px; font-weight:700; color:#d97706;
            margin-bottom:9px; padding-bottom:7px;
            border-bottom:1px solid #1e3050; letter-spacing:.3px;
        }
        .tip-row {
            display:flex; gap:8px; align-items:flex-start;
            margin-bottom:7px; line-height:1.55;
        }
        .tip-row:last-child { margin-bottom:0; }
        .tip-num {
            flex-shrink:0; width:17px; height:17px; border-radius:50%;
            font-size:10px; font-weight:700;
            display:flex; align-items:center; justify-content:center;
            margin-top:1px;
        }
        .tip-num.g { background:#14532d; color:#4ade80; }
        .tip-num.r { background:#7f1d1d; color:#fca5a5; }
        .tip-num.b { background:#1e3a5f; color:#93c5fd; }
        .tip-text  { font-size:11.5px; color:#8fa8c8; line-height:1.55; }
        .tip-text b { color:#c5d8f0; font-weight:600; }

        /* ── 테이블 ── */
        #tableWrap { width:100%; overflow-x:auto; }
        #dataList  { width:100%; border:none !important; }

        .tabulator { position:relative; background-color:#fff; font-size:14px; text-align:left; }

        #dataList .tabulator-header { background:#1e2d4a !important; border-bottom:2px solid #2e4070 !important; }
        #dataList .tabulator-col {
            background:#1e2d4a !important; color:#ededed !important;
            font-size:13px !important; font-weight:700 !important;
            border-right:1px solid #2e3f5e !important; padding:6px 4px !important;
        }
        #dataList .tabulator-col:hover { background:#263660 !important; }
        #dataList .tabulator-header-filter input {
            background:#253047 !important; border:1px solid #3a4a6a !important;
            color:#e0e8f8 !important; border-radius:3px; font-size:11px; padding:2px 5px;
        }

        #dataList .tabulator-row { border-bottom:1px solid #e4e9f2 !important; cursor:pointer; }
        #dataList .tabulator-row:hover { background:#e8f0ff !important; }
        #dataList .tabulator-row.tabulator-row-even { background:#f7f9fc; }
        #dataList .tabulator-cell { padding:5px 6px !important; border-right:1px solid #e8edf5 !important; }

        /* RI 강조 */
        .row-ri       { background-color:#ffe8e8 !important; }
        .row-ri:hover { background-color:#ffd5d5 !important; }
        .lot-ri       { color:#c80000; font-weight:700; font-size:11px; }

        /* 선택 행 강조 (amber) */
        .row-selected       { background-color:#fff3cd !important; box-shadow:inset 0 0 0 2px #c97000; }
        .row-selected:hover { background-color:#ffe8a0 !important; }

        .t-done  { color:#1a8a40; font-weight:600; }
        .t-empty { color:#bbb; }
        .qr-ok   { color:#1a8a40; font-weight:700; }

        /* ── 모달 공통 ── */
        .modal-overlay {
            display:none; position:fixed; inset:0;
            background:rgba(0,0,0,.55); z-index:700;
            align-items:center; justify-content:center;
        }
        .modal-overlay.open { display:flex; }
        .modal-box {
            background:#fff; width:96%; max-width:1500px;
            max-height:90vh; border-radius:10px; padding:18px;
            overflow-y:auto; box-shadow:0 10px 40px rgba(0,0,0,.45);
        }
        .modal-box h3 {
            font-size:15px; color:#1a2236;
            border-bottom:2px solid #e0e8f0;
            padding-bottom:10px; margin-bottom:14px;
        }
        .modal-footer {
            display:flex; align-items:center; gap:8px;
            justify-content:flex-end; margin-top:12px; flex-wrap:wrap;
        }
        .modal-input {
            height:34px; padding:0 10px;
            border:1px solid #c0cfe8; border-radius:5px;
            font-size:13px; width:180px;
        }

        /* ── 로트 지정 모달 ── */
        #lotAssignModal .modal-box { max-width:440px; }
        .assign-info {
            background:#f5f8ff; border:1px solid #c6d8f8;
            border-radius:6px; padding:10px 13px;
            font-size:12px; color:#334; line-height:1.7;
            margin-bottom:14px;
        }
        .assign-info b { color:#1a4a90; }
        .assign-row { display:flex; gap:8px; align-items:center; margin-bottom:10px; }
        .assign-row .modal-input { flex:1; width:auto; }
        #assignResult {
            min-height:22px; font-size:12px;
            padding:5px 8px; border-radius:4px; font-weight:600;
        }
        #assignResult.ok   { background:#d4edda; color:#155724; }
        #assignResult.err  { background:#f8d7da; color:#721c24; }
        #assignResult.info { background:#d1ecf1; color:#0c5460; }

        #editTable .tabulator-header { background:#f0f4fa !important; }
        #editTable .tabulator-col    { background:#f0f4fa !important; color:#334 !important; font-size:12px !important; }
        #editTable .tabulator-row    { font-size:13px; }

        /* ── 로딩바 ── */
        #loadingBar {
            position: fixed;
            top: 0; left: 0;
            width: 0%;
            height: 3px;
            background: linear-gradient(90deg, #3d7ef5, #4ee2a0);
            z-index: 9999;
            transition: width .3s ease, opacity .3s ease;
            opacity: 0;
        }
        #loadingBar.active {
            opacity: 1;
            animation: loadSlide 1.4s ease-in-out infinite;
        }
        @keyframes loadSlide {
            0%   { width:0%;   left:0; }
            50%  { width:70%;  left:0; }
            100% { width:100%; left:0; }
        }
        #loadingBar.done {
            width: 100%;
            opacity: 0;
            transition: opacity .4s ease .1s;
        }

        /* ── 초기 테이블 스피너 ── */
        #tableSpinner {
            display: none;
            position: absolute;
            inset: 0;
            background: rgba(240,242,245,.75);
            z-index: 100;
            align-items: center;
            justify-content: center;
            flex-direction: column;
            gap: 12px;
        }
        #tableSpinner.show { display: flex; }
        .spinner-ring {
            width: 44px; height: 44px;
            border: 4px solid #c5d5f0;
            border-top-color: #3d7ef5;
            border-radius: 50%;
            animation: spin .7s linear infinite;
        }
        @keyframes spin { to { transform: rotate(360deg); } }
        .spinner-txt { color: #4a6080; font-size: 13px; }

        @media (max-width:768px) {
            .bar-input { width:90px; font-size:12px; }
            .lot-tooltip { width:260px; }
        }
    </style>
</head>
<body>

<div id="loadingBar"></div>

<div id="controlBar">
    <span class="bar-label">조회기간</span>
    <input type="text" class="bar-input daySet" id="daySetStart" placeholder="시작일">
    <span class="bar-sep">~</span>
    <input type="text" class="bar-input daySet" id="daySetEnd" placeholder="종료일">

    <button class="btn btn-blue" id="btnSearch">
        <img src="/line/css/tabBar/search-icon.png" alt="">조회
    </button>

    <button class="btn btn-gray" id="btnEdit">✏️ 리스트 수정</button>

<!-- ══════ 로트 지정 버튼 + 툴팁 ══════ -->
<div class="lot-btn-wrap">
    <button class="btn btn-amber" id="btnLotAssign">📌 로트 지정</button>

    <div class="lot-tooltip">
        <div class="tip-head">
            📌 로트 지정 사용 안내<br>
            (행 선택 후 버튼 클릭)
        </div>
        
        <div class="tip-row">
            <span class="tip-num g">1</span>
            <span class="tip-text">
                <b>리스트 수정 후 시작 버튼이 동작하지 않을 때</b><br>
                예) 로트 스캔 완료 후 시작 버튼이 반응하지 않는 경우
            </span>
        </div>

        <div class="tip-row">
            <span class="tip-num r">2</span>
            <span class="tip-text">
                <b>로트를 건너뛰고 진행한 경우</b><br>
                예) 1번 로트는 정상 진행, 2번 로트는 시작/종료 미처리(리스트 수정 필요)<br>
                → 이후 3번 로트를 지정하여 정상 흐름으로 복구
            </span>
        </div>

        <div class="tip-row">
            <span class="tip-num b">3</span>
            <span class="tip-text">
                <b>기능 설명</b><br>
                로트 순서 꼬임 또는 수정 후 동작하지 않는 문제를<br>
                정상 상태로 복구하는 기능입니다.
            </span>
        </div>
    </div>
</div>
    <!-- ══════════════════════════════════ -->

    <button class="btn btn-green" id="btnExcel">
        <img src="/line/css/tabBar/excel-icon.png" alt="">Download
    </button>

    <div class="refresh-info">
        <span class="pulse-dot"></span>
        자동갱신 <span id="countdown">5</span>초
    </div>
</div>

<div id="tableWrap" style="position:relative;">
    <div id="tableSpinner">
        <div class="spinner-ring"></div>
        <span class="spinner-txt">데이터 조회 중...</span>
    </div>
    <div id="dataList"></div>
</div>

<!-- 리스트 수정 모달 -->
<div id="editModal" class="modal-overlay">
    <div class="modal-box">
        <h3>LOT 데이터 수정</h3>
        <div id="editTable"></div>
        <div class="modal-footer">
            <input type="text" class="modal-input" id="autoLotInput" placeholder="LOT 입력">
            <button class="btn btn-blue"                              id="btnAutoGenerate">15 자동생성</button>
            <button class="btn" style="background:#e8a020;color:#fff" id="btnAutoGenerate25">25 자동생성</button>
            <button class="btn btn-green"                             id="btnSave">💾 저장</button>
            <button class="btn btn-gray"                              id="btnClose">닫기</button>
        </div>
    </div>
</div>

<!-- 로트 지정 모달 -->
<div id="lotAssignModal" class="modal-overlay">
    <div class="modal-box">
        <h3>📌 로트 지정</h3>
        <div class="assign-info">
            테이블 행을 먼저 클릭하면 LOT가 자동으로 채워집니다.<br>
            직접 입력도 가능합니다. <b>전송</b>하면 서버에 즉시 반영됩니다.<br>
            반영 후 해당 행의 QR 확인란에 적용 시간과 적용 상태가 표시됩니다.
        </div>
        <div class="assign-row">
            <input type="text" class="modal-input" id="assignLotInput" placeholder="LOT 번호 (행 클릭 또는 직접 입력)">
            <button class="btn btn-amber" id="btnAssignSend">📤 전송</button>
        </div>
        <div id="assignResult"></div>
        <div class="modal-footer">
            <button class="btn btn-gray" id="btnAssignClose">닫기</button>
        </div>
    </div>
</div>

<script>
/* ══════════════════════════════════════════════
   전역 상태
══════════════════════════════════════════════ */
let dataTable, editTable;
let modifiedRows   = new Set();
let selectedLotRow = null;     // 메인 테이블에서 선택된 행 (한 행만)
let now_page_code  = "b06";

const REFRESH_SEC = 5;
let countdownVal  = REFRESH_SEC;
let countdownId   = null;
let isLoading     = false;

/* ── 날짜 유틸 ── */
function fmtDate(d) {
    return d.getFullYear() + "-" +
           String(d.getMonth() + 1).padStart(2, "0") + "-" +
           String(d.getDate()).padStart(2, "0");
}
function parseSafe(s) {
    if (!s) return null;
    const d = new Date(String(s).split(".")[0].replace(" ", "T"));
    return isNaN(d) ? null : d;
}
function fmtDT(d) {
    if (!(d instanceof Date) || isNaN(d)) return "";
    return fmtDate(d) + " " +
           [d.getHours(), d.getMinutes(), d.getSeconds()]
               .map(n => String(n).padStart(2, "0")).join(":");
}

/* ── 시간 포매터 ── */
function timeFmt(cell) {
    const v = cell.getValue();
    if (!v) return '<span class="t-empty">-</span>';
    const d = new Date(String(v).replace(" ", "T"));
    if (isNaN(d) || d > new Date()) return '<span class="t-empty">-</span>';
    return '<span class="t-done">' + String(v).split(" ")[1] + '</span>';
}

/* ── 로딩바 ── */
function showLoading(initial) {
    const bar = document.getElementById("loadingBar");
    bar.className = "active";
    if (initial) $("#tableSpinner").addClass("show");
}
function hideLoading() {
    const bar = document.getElementById("loadingBar");
    bar.className = "done";
    $("#tableSpinner").removeClass("show");
    setTimeout(function () { bar.className = ""; }, 500);
}

/* ── Ajax 파라미터 ── */
function getParams() {
    return { startDay: $("#daySetStart").val(), endDay: $("#daySetEnd").val() };
}

/* ══════════════════════════════════════════════
   행 선택 처리 (한 행만, amber 강조)
   - 같은 행 재클릭 → 선택 해제
   - 콘솔에 w_ci_lot 출력
   - 로트 지정 모달 입력창 자동 채움
══════════════════════════════════════════════ */
function applyRowClass(row, selected) {
    const el   = row.getElement();
    const data = row.getData();
    const isRI = data.w_ci_lot && data.w_ci_lot.indexOf("RI") !== -1;

    el.classList.toggle("row-selected", selected);
    /* RI 배경: 선택됐을 때는 amber가 우선, 해제되면 RI 배경 복원 */
    el.classList.toggle("row-ri", !selected && isRI);
}

function selectMainRow(row) {
    const lot = (row.getData() || {}).w_ci_lot;
    if (!lot) return;   // 빈 행 무시

    /* 이전 선택 행 해제 */
    if (selectedLotRow) {
        try { applyRowClass(selectedLotRow, false); } catch(e) {}
    }

    /* 같은 행 재클릭 → 토글 해제 */
    if (selectedLotRow === row) {
        selectedLotRow = null;
        console.log("%c[로트 지정] 선택 해제", "color:#888;");
        $("#assignLotInput").val("");
        return;
    }

    /* 새 행 선택 */
    selectedLotRow = row;
    applyRowClass(row, true);
    console.log("%c[로트 지정] ▶ w_ci_lot =", "color:#c97000;font-weight:bold;font-size:13px;", lot);
    $("#assignLotInput").val(lot);
}

/* ══════════════════════════════════════════════
   데이터 갱신 (스크롤 유지)
══════════════════════════════════════════════ */
function loadData(initial) {
    if (isLoading || !dataTable) return;
    isLoading = true;
    showLoading(initial);

    const holder = document.querySelector("#dataList .tabulator-tableholder");
    const st = holder ? holder.scrollTop  : 0;
    const sl = holder ? holder.scrollLeft : 0;

    $.ajax({
        url:  "/line/monitoring/lotProcessor/list",
        type: "POST",
        data: getParams(),
        success: function (res) {
            const rows    = (res && res.data) ? res.data : [];
            const newLots = new Set(rows.map(r => r.w_ci_lot));

            dataTable.getRows().forEach(function (r) {
                const lot = r.getData().w_ci_lot;
                if (lot && !newLots.has(lot)) {
                    if (selectedLotRow === r) { selectedLotRow = null; }
                    r.delete();
                }
            });

            dataTable.updateOrAddData(rows).then(function () {
                const allRows = dataTable.getRows();
                const last    = allRows[allRows.length - 1];
                if (!last || last.getData().w_ci_lot) dataTable.addRow({}, false);
                if (holder) { holder.scrollTop = st; holder.scrollLeft = sl; }
                hideLoading();
                isLoading = false;
            });
        },
        error: function () { hideLoading(); isLoading = false; }
    });
}

/* ── 카운트다운 ── */
function startCountdown() {
    clearInterval(countdownId);
    countdownVal = REFRESH_SEC;
    $("#countdown").text(countdownVal);
    countdownId = setInterval(function () {
        if (--countdownVal <= 0) { countdownVal = REFRESH_SEC; loadData(); }
        $("#countdown").text(countdownVal);
    }, 1000);
}

/* ══════════════════════════════════════════════
   메인 테이블
══════════════════════════════════════════════ */
function initTable() {
    dataTable = new Tabulator("#dataList", {
        height: "700px",
        ajaxConfig: "POST",
        ajaxURL: "/line/monitoring/lotProcessor/list",
        ajaxParams: getParams(),
        ajaxResponse: function (url, p, res) { return (res && res.data) ? res.data : []; },
        placeholder: "데이터가 없습니다.",
        selectable: false,   /* 내장 선택 off — 직접 관리 */
        index: "w_ci_lot",
        layout: "fitColumns",
        responsiveLayout: false,

        rowFormatter: function (row) {
            const d  = row.getData();
            const el = row.getElement();

            el.querySelectorAll(".tabulator-cell").forEach(function (cell) {
                const f = cell.getAttribute("tabulator-field");
                cell.style.display        = "inline-flex";
                cell.style.alignItems     = "center";
                cell.style.justifyContent = (f === "w_ci_lot") ? "flex-start" : "center";
            });

            /* 선택 상태 복원 (갱신 재렌더 후) */
            if (selectedLotRow && d.w_ci_lot) {
                try {
                    const selLot = selectedLotRow.getData().w_ci_lot;
                    if (selLot === d.w_ci_lot) {
                        el.classList.add("row-selected");
                        return;   /* amber 우선 — RI 배경 붙이지 않음 */
                    }
                } catch(e) {}
            }

            if (d.w_ci_lot && d.w_ci_lot.indexOf("RI") !== -1) {
                el.classList.add("row-ri");
            } else {
                el.classList.remove("row-ri");
            }
        },

        rowClick: function (e, row) { selectMainRow(row); },

        dataLoaded: function () { this.addRow({}, false); hideLoading(); },

        columns: [
            {
                title: "제품 정보", field: "w_ci_lot",
                frozen: true, minWidth: 180, widthGrow: 2,
                hozAlign: "left", headerHozAlign: "center",
                headerSort: false,
                headerFilter: "input", headerFilterPlaceholder: "LOT 검색", headerFilterFunc: "like",
                formatter: function (cell) {
                    const d = cell.getRow().getData();
                    let lot = String(d.w_ci_lot || "");
                    if (lot.indexOf("RI") !== -1 && lot.indexOf("(재처리)") === -1) {
                        lot += ' <span class="lot-ri">(재처리)</span>';
                    }
                    return '<div style="line-height:1.5;font-size:12px;white-space:normal;">' +
                           '<b style="font-size:13px">' + lot + '</b><br>' +
                           '<span style="color:#556">' + (d.cust_name || "") + '</span><br>' +
                           '<span style="color:#334">' + (d.item_name || "") + '</span><br>' +
                           '<span style="color:#889">' + (d.item_no   || "") + '</span>' +
                           '</div>';
                }
            },
            { title:"작업<br>등록",      field:"regtime",   minWidth:55, widthGrow:1, hozAlign:"center", headerHozAlign:"center", headerSort:false, formatter:timeFmt },
            {
                title:"QR<br>확인", field:"w_state",
                minWidth:55, maxWidth:70, widthGrow:1,
                hozAlign:"center", headerHozAlign:"center", headerSort:false,
                formatter: function (cell) {
                    const v = String(cell.getValue() || "");
                    return v.includes("스캔")
                        ? '<span class="qr-ok">✔ 스캔</span>'
                        : '<span class="t-empty">' + v + '</span>';
                }
            },
            { title:"투입<br>시작",      field:"d370",      minWidth:52, widthGrow:1, hozAlign:"center", headerHozAlign:"center", headerSort:false, formatter:timeFmt },
            { title:"투입<br>종료",      field:"x111",      minWidth:52, widthGrow:1, hozAlign:"center", headerHozAlign:"center", headerSort:false, formatter:timeFmt },
            { title:"전세정기<br>도착",  field:"f_wash_3",  minWidth:65, widthGrow:1, hozAlign:"center", headerHozAlign:"center", headerSort:false, formatter:timeFmt },
            { title:"소입로<br>도착",    field:"qf1_4",     minWidth:55, widthGrow:1, hozAlign:"center", headerHozAlign:"center", headerSort:false, formatter:timeFmt },
            { title:"유조<br>도착",      field:"oil_9",     minWidth:55, widthGrow:1, hozAlign:"center", headerHozAlign:"center", headerSort:false, formatter:timeFmt },
            { title:"중간세정기<br>도착",field:"m_wash_10", minWidth:70, widthGrow:1, hozAlign:"center", headerHozAlign:"center", headerSort:false, formatter:timeFmt },
            { title:"소려로<br>도착",    field:"tf1_11",    minWidth:55, widthGrow:1, hozAlign:"center", headerHozAlign:"center", headerSort:false, formatter:timeFmt },
            { title:"방청조<br>도착",    field:"bch_16",    minWidth:55, widthGrow:1, hozAlign:"center", headerHozAlign:"center", headerSort:false, formatter:timeFmt },
            { title:"출구콘베어<br>도착",field:"con_17",    minWidth:70, widthGrow:1, hozAlign:"center", headerHozAlign:"center", headerSort:false, formatter:timeFmt },
            { title:"로트<br>종료",      field:"l20",       minWidth:55, widthGrow:1, hozAlign:"center", headerHozAlign:"center", headerSort:false, formatter:timeFmt }
        ]
    });
}

/* ══════════════════════════════════════════════
   버튼 — 조회 / 엑셀
══════════════════════════════════════════════ */
$("#btnSearch").on("click", function () { startCountdown(); loadData(true); });

$("#btnExcel").on("click", function () {
    if (!dataTable) return;
    const fn = "LOT트레킹_" + $("#daySetStart").val() + "_" + $("#daySetEnd").val() + ".xlsx";
    dataTable.download("xlsx", fn, {
        sheetName: "LOT트레킹",
        documentProcessing: function (wb) {
            const ws = wb.Sheets["LOT트레킹"];
            if (ws) ws["!cols"] = [
                {wch:22},{wch:12},{wch:10},{wch:10},{wch:10},
                {wch:14},{wch:12},{wch:12},{wch:14},{wch:12},{wch:12},{wch:14},{wch:12}
            ];
            return wb;
        }
    });
});

/* ══════════════════════════════════════════════
   리스트 수정 모달
══════════════════════════════════════════════ */
$("#btnEdit").on("click", function () {
    modifiedRows.clear();
    $("#editModal").addClass("open");
    if (editTable) { editTable.destroy(); editTable = null; }

    editTable = new Tabulator("#editTable", {
        height: "420px",
        ajaxConfig: "POST",
        ajaxURL: "/line/monitoring/lotProcessor/list",
        ajaxParams: getParams(),
        ajaxResponse: function (url, p, res) { return (res && res.data) ? res.data : []; },
        layout: "fitDataStretch",
        columns: [
            { title:"LOT",        field:"w_ci_lot", frozen:true, width:170 },
            { title:"투입시작",   field:"d370",      editor:"input", width:145 },
            { title:"투입종료",   field:"x111",      editor:"input", width:145 },
            { title:"전세정기",   field:"f_wash_3",  editor:"input", width:145 },
            { title:"소입로",     field:"qf1_4",     editor:"input", width:145 },
            { title:"유조",       field:"oil_9",     editor:"input", width:145 },
            { title:"중간세정기", field:"m_wash_10", editor:"input", width:145 },
            { title:"소려로",     field:"tf1_11",    editor:"input", width:145 },
            { title:"방청조",     field:"bch_16",    editor:"input", width:145 },
            { title:"출구콘베어", field:"con_17",    editor:"input", width:145 },
            { title:"로트종료",   field:"l20",       editor:"input", width:145 }
        ],
        rowClick:   function (e, row) { $("#autoLotInput").val(row.getData().w_ci_lot || ""); },
        cellEdited: function (cell) {
            const r = cell.getRow();
            modifiedRows.add(r);
            r.getElement().style.backgroundColor = "#fff3cd";
        }
    });
});

$("#btnClose").on("click", function () { $("#editModal").removeClass("open"); });

function autoGenerate(steps, endMin) {
    const lot = $("#autoLotInput").val().trim();
    if (!lot) return alert("LOT를 입력하세요.");
    const row = editTable.getRows().find(r => r.getData().w_ci_lot === lot);
    if (!row) return alert("해당 LOT를 찾을 수 없습니다.");
    const data = row.getData();
    const base = parseSafe(data.d370);
    if (!base) return alert("투입시작 시간이 필요합니다.");

    data.x111 = fmtDT(new Date(base.getTime() + endMin * 60000));
    let cur = new Date(base);
    steps.forEach(function (s) {
        cur = new Date(cur.getTime() + s.minutes * 60000);
        data[s.field] = fmtDT(cur);
    });
    row.update(data);
    modifiedRows.add(row);
    row.getElement().style.backgroundColor = "#d4edda";
}

$("#btnAutoGenerate").on("click", function () {
    autoGenerate([
        {field:"f_wash_3",minutes:6.5},{field:"qf1_4",   minutes:1},
        {field:"oil_9",   minutes:84}, {field:"m_wash_10",minutes:7.3},
        {field:"tf1_11",  minutes:7.6},{field:"bch_16",   minutes:135},
        {field:"con_17",  minutes:13.5},{field:"l20",     minutes:15}
    ], 70);
});

$("#btnAutoGenerate25").on("click", function () {
    autoGenerate([
        {field:"f_wash_3",minutes:6.5},{field:"qf1_4",   minutes:1},
        {field:"oil_9",   minutes:50}, {field:"m_wash_10",minutes:7.3},
        {field:"tf1_11",  minutes:7.6},{field:"bch_16",   minutes:135},
        {field:"con_17",  minutes:13.5},{field:"l20",     minutes:15}
    ], 70);
});

$("#btnSave").on("click", function () {
    if (modifiedRows.size === 0) return alert("변경된 데이터가 없습니다.");
    const saveData = [];
    modifiedRows.forEach(r => saveData.push(r.getData()));

    $.ajax({
        url: "/line/monitoring/lotProcessor/bulkUpdate",
        type: "POST",
        contentType: "application/json",
        data: JSON.stringify(saveData),
        success: function () {
            alert("저장되었습니다.");
            modifiedRows.clear();
            editTable.replaceData();
            $("#editModal").removeClass("open");
            startCountdown();
            loadData();
        },
        error: function () { alert("저장에 실패했습니다."); }
    });
});

/* ══════════════════════════════════════════════
   로트 지정 모달
══════════════════════════════════════════════ */
$("#btnLotAssign").on("click", function () {
    /* 선택된 행 있으면 자동 채움 */
    if (selectedLotRow) {
        try {
            const lot = selectedLotRow.getData().w_ci_lot;
            if (lot) $("#assignLotInput").val(lot);
        } catch(e) {}
    }
    $("#assignResult").text("").removeClass("ok err info");
    $("#lotAssignModal").addClass("open");
});

$("#btnAssignClose").on("click", function () { $("#lotAssignModal").removeClass("open"); });

/* ── 전송 ── */
$("#btnAssignSend").on("click", function () {
    const lot = $("#assignLotInput").val().trim();
    if (!lot) {
        setResult("err", "⚠ LOT 번호를 입력하세요.");
        return;
    }

    console.log("%c[로트 지정] 전송 ▶ w_ci_lot =", "color:#c97000;font-weight:bold;font-size:13px;", lot);
    setResult("info", "⏳ 전송 중...");

    $.ajax({
        url:  "/line/lotProcessor/list/Fupdate",
        type: "POST",
        contentType: "application/json",
        data: JSON.stringify({ w_ci_lot: lot}),
        success: function (res) {
            console.log("%c[로트 지정] 서버 응답 ▶", "color:#22a455;font-weight:bold;", res);
            setResult("ok", "✔ 전송 완료 — " + lot);
            startCountdown();
            loadData();
        },
        error: function (xhr) {
            console.error("[로트 지정] 전송 실패", xhr.status, xhr.responseText);
            setResult("err", "✖ 전송 실패 (서버 오류). 다시 시도하세요.");
        }
    });
});

function setResult(type, msg) {
    $("#assignResult").removeClass("ok err info").addClass(type).text(msg);
}

/* ── 모달 바깥 클릭 닫기 ── */
$(".modal-overlay").on("click", function (e) {
    if ($(e.target).hasClass("modal-overlay")) $(this).removeClass("open");
});

/* ══════════════════════════════════════════════
   시작
══════════════════════════════════════════════ */
$(document).ready(function () {
    $("#daySetStart").val(fmtDate(new Date()));
    $("#daySetEnd").val(fmtDate(new Date()));
    showLoading(true);
    initTable();
    startCountdown();
});
</script>
</body>
</html>
