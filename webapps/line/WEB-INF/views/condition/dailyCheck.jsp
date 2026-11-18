<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="ko">
<head>
<script src="/line/mock/mock-loader.js"></script>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>일상점검일지</title>
    <%@include file="../include/pluginpage.jsp" %>
    <jsp:include page="../include/tabBar.jsp"/>
    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;600;700&family=JetBrains+Mono:wght@400;500&display=swap" rel="stylesheet">
    <link href="/vendor/tabulator/5.6.1/tabulator.min.css" rel="stylesheet">
    <script src="/vendor/tabulator/5.6.1/tabulator.min.js"></script>

    <style>
        /* ── Reset & Base ── */
        :root {
            --bg:           #f8f9fb;
            --surface:      #ffffff;
            --surface2:     #f1f4f8;
            --border:       #e2e7ef;
            --border-light: #edf0f5;
            --accent:       #2563eb;
            --accent-light: #eff4ff;
            --accent-hover: #1d4ed8;
            --text-primary: #1a202c;
            --text-secondary:#4a5568;
            --text-muted:   #9aa5b4;
            --success:      #059669;
            --warning:      #d97706;
            --danger:       #dc2626;
            --radius-sm:    6px;
            --radius:       10px;
            --radius-lg:    14px;
            --shadow-sm:    0 1px 3px rgba(0,0,0,0.06), 0 1px 2px rgba(0,0,0,0.04);
            --shadow:       0 4px 12px rgba(0,0,0,0.08);
            --shadow-lg:    0 8px 30px rgba(0,0,0,0.12);
        }

        * { box-sizing: border-box; margin: 0; padding: 0; }

        body {
            font-family: 'Noto Sans KR', sans-serif;
            background: var(--bg);
            color: var(--text-primary);
            min-height: 100vh;
        }

        /* ── Main layout ── */
        .main {
            padding: 24px 28px;
            animation: fadeIn .35s ease both;
        }

        /* ── Page Header ── */
        .page-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 20px;
        }
        .page-header-left {
            display: flex;
            align-items: center;
            gap: 12px;
        }
        .header-icon {
            width: 40px; height: 40px;
            background: var(--accent);
            border-radius: var(--radius-sm);
            display: flex; align-items: center; justify-content: center;
            box-shadow: 0 2px 8px rgba(37,99,235,0.3);
            flex-shrink: 0;
        }
        .header-icon svg {
            width: 20px; height: 20px;
            fill: none; stroke: #fff; stroke-width: 2;
            stroke-linecap: round; stroke-linejoin: round;
        }
        .page-title {
            font-size: 18px;
            font-weight: 700;
            color: var(--text-primary);
            letter-spacing: -.3px;
        }
        .page-breadcrumb {
            font-size: 12px;
            color: var(--text-muted);
            margin-top: 2px;
            font-weight: 400;
        }

        /* ── Toolbar Card ── */
        .toolbar-card {
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: var(--radius);
            padding: 14px 18px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 16px;
            box-shadow: var(--shadow-sm);
            animation: slideDown .4s .05s ease both;
        }
        .toolbar-left {
            display: flex;
            align-items: center;
            gap: 10px;
        }
        .toolbar-right {
            display: flex;
            align-items: center;
            gap: 8px;
        }

        /* ── Label + Input group ── */
        .field-group {
            display: flex;
            align-items: center;
            gap: 8px;
        }
        .field-label {
            font-size: 13px;
            font-weight: 600;
            color: var(--text-secondary);
            white-space: nowrap;
        }
        .month-input {
            font-family: 'JetBrains Mono', monospace;
            font-size: 13px;
            background: var(--surface2);
            border: 1px solid var(--border);
            border-radius: var(--radius-sm);
            color: var(--text-primary);
            padding: 7px 12px;
            width: 130px;
            outline: none;
            transition: border-color .2s, box-shadow .2s;
            text-align: center;
        }
        .month-input:focus {
            border-color: var(--accent);
            box-shadow: 0 0 0 3px rgba(37,99,235,0.12);
        }

        /* ── Divider ── */
        .toolbar-divider {
            width: 1px;
            height: 28px;
            background: var(--border);
            margin: 0 4px;
        }

        /* ── Buttons ── */
        .btn {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            font-family: 'Noto Sans KR', sans-serif;
            font-size: 13px;
            font-weight: 500;
            padding: 7px 13px;
            border-radius: var(--radius-sm);
            border: 1px solid transparent;
            cursor: pointer;
            transition: all .18s ease;
            white-space: nowrap;
        }
        .btn svg {
            width: 14px; height: 14px;
            flex-shrink: 0;
        }
        .btn-primary {
            background: var(--accent);
            color: #fff;
            border-color: var(--accent);
            box-shadow: 0 1px 4px rgba(37,99,235,0.25);
        }
        .btn-primary:hover {
            background: var(--accent-hover);
            border-color: var(--accent-hover);
            box-shadow: 0 2px 8px rgba(37,99,235,0.35);
            transform: translateY(-1px);
        }
        .btn-outline {
            background: var(--surface);
            color: var(--text-secondary);
            border-color: var(--border);
        }
        .btn-outline:hover {
            border-color: var(--accent);
            color: var(--accent);
            background: var(--accent-light);
        }
        .btn-danger-outline {
            background: var(--surface);
            color: var(--danger);
            border-color: #fecaca;
        }
        .btn-danger-outline:hover {
            background: #fff5f5;
            border-color: var(--danger);
        }
        .btn-success-outline {
            background: var(--surface);
            color: var(--success);
            border-color: #a7f3d0;
        }
        .btn-success-outline:hover {
            background: #f0fdf4;
            border-color: var(--success);
        }

        /* ── Table Wrapper ── */
        .table-wrap {
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: var(--radius);
            overflow: hidden;
            box-shadow: var(--shadow-sm);
            animation: slideDown .4s .1s ease both;
        }

        /* 큰 화면 대응: 창 높이에 맞추고 표가 남은 높이를 채움 (페이지 스크롤 없음) */
        html, body { height: 100%; overflow: hidden; }
        body > .main { height: 100%; display: flex; flex-direction: column; }
        .main > .table-wrap { flex: 1; min-height: 0; display: flex; flex-direction: column; }
        .main > .table-wrap > #dataTable { flex: 1; min-height: 0; }

        /* ── Tabulator overrides (light) ── */
        .tabulator {
            background: var(--surface) !important;
            border: none !important;
            font-family: 'Noto Sans KR', sans-serif !important;
            font-size: 13px !important;
        }
        .tabulator .tabulator-header {
            background: var(--surface2) !important;
            border-bottom: 1px solid var(--border) !important;
        }
        .tabulator .tabulator-header .tabulator-col {
            background: transparent !important;
            border-right: 1px solid var(--border-light) !important;
            color: var(--text-secondary) !important;
            font-size: 11.5px !important;
            font-weight: 600 !important;
            letter-spacing: .3px !important;
        }
        .tabulator .tabulator-header .tabulator-col:hover {
            background: #e8edf5 !important;
        }
        .tabulator-row {
            background: var(--surface) !important;
            border-bottom: 1px solid var(--border-light) !important;
            transition: background .12s !important;
        }
        .tabulator-row:nth-child(even) {
            background: #fafbfd !important;
        }
        .tabulator-row:hover {
            background: var(--accent-light) !important;
        }
        .tabulator-row .tabulator-cell {
            color: var(--text-primary) !important;
            border-right: 1px solid var(--border-light) !important;
            padding: 9px 12px !important;
        }
        .tabulator-row.row_select {
            background: #dbeafe !important;
            border-left: 3px solid var(--accent) !important;
        }
        .tabulator-row.row_select .tabulator-cell {
            color: #1e3a8a !important;
        }
        /* pagination */
        .tabulator .tabulator-footer {
            background: var(--surface2) !important;
            border-top: 1px solid var(--border) !important;
            color: var(--text-muted) !important;
        }
        .tabulator .tabulator-footer .tabulator-page {
            background: var(--surface) !important;
            border: 1px solid var(--border) !important;
            color: var(--text-secondary) !important;
            border-radius: 5px !important;
        }
        .tabulator .tabulator-footer .tabulator-page.active {
            background: var(--accent) !important;
            border-color: var(--accent) !important;
            color: #fff !important;
        }
        .tabulator .tabulator-footer .tabulator-page:hover:not(.active) {
            background: var(--accent-light) !important;
            border-color: var(--accent) !important;
            color: var(--accent) !important;
        }
        /* frozen column shadow */
        .tabulator .tabulator-frozen.tabulator-frozen-right {
            border-left: 2px solid var(--border) !important;
        }

        /* ── Upload Button in cell ── */
        .img-upload-btn {
            font-family: 'Noto Sans KR', sans-serif;
            font-size: 11px;
            font-weight: 500;
            padding: 4px 10px;
            background: var(--surface2);
            border: 1px solid var(--border);
            border-radius: 4px;
            cursor: pointer;
            color: var(--text-secondary);
            transition: all .15s;
        }
        .img-upload-btn:hover {
            background: var(--accent-light);
            border-color: var(--accent);
            color: var(--accent);
        }

        /* ── Modal ── */
        .modal {
            display: none;
            position: fixed;
            inset: 0;
            background: rgba(15,23,42,0.45);
            backdrop-filter: blur(3px);
            z-index: 9000;
            align-items: center;
            justify-content: center;
            transition: opacity .25s;
        }
        .modal.show { display: flex; }

        .modal-content {
            background: var(--surface);
            width: 380px;
            max-width: 95vw;
            border-radius: var(--radius-lg);
            box-shadow: var(--shadow-lg);
            padding: 28px 28px 22px;
            position: relative;
            animation: popIn .3s cubic-bezier(.34,1.56,.64,1) both;
        }
        .modal-header {
            display: flex;
            align-items: center;
            gap: 10px;
            margin-bottom: 22px;
        }
        .modal-header-icon {
            width: 34px; height: 34px;
            background: var(--accent-light);
            border-radius: 8px;
            display: flex; align-items: center; justify-content: center;
        }
        .modal-header-icon svg {
            width: 16px; height: 16px;
            stroke: var(--accent); fill: none;
            stroke-width: 2; stroke-linecap: round; stroke-linejoin: round;
        }
        .modal-title {
            font-size: 15px;
            font-weight: 700;
            color: var(--text-primary);
        }
        .modal-close {
            position: absolute;
            top: 16px; right: 18px;
            width: 28px; height: 28px;
            border-radius: 6px;
            border: none;
            background: var(--surface2);
            cursor: pointer;
            display: flex; align-items: center; justify-content: center;
            font-size: 16px;
            color: var(--text-muted);
            transition: background .15s, color .15s;
            line-height: 1;
        }
        .modal-close:hover { background: #fecaca; color: var(--danger); }

        .form-group {
            margin-bottom: 16px;
        }
        .form-label {
            display: block;
            font-size: 12px;
            font-weight: 600;
            color: var(--text-secondary);
            margin-bottom: 6px;
            letter-spacing: .2px;
        }
        .form-input {
            width: 100%;
            font-family: 'JetBrains Mono', monospace;
            font-size: 13px;
            padding: 9px 12px;
            border: 1px solid var(--border);
            border-radius: var(--radius-sm);
            outline: none;
            color: var(--text-primary);
            background: var(--surface2);
            transition: border-color .2s, box-shadow .2s;
        }
        .form-input:focus {
            border-color: var(--accent);
            box-shadow: 0 0 0 3px rgba(37,99,235,0.12);
            background: #fff;
        }
        .modal-actions {
            display: flex;
            gap: 8px;
            margin-top: 8px;
        }
        .modal-actions .btn { flex: 1; justify-content: center; }

        /* ── PDF Viewer Modal ── */
        #pdfViewerModal {
            display: none;
            position: fixed;
            inset: 0;
            background: rgba(15,23,42,0.65);
            backdrop-filter: blur(4px);
            justify-content: center;
            align-items: center;
            z-index: 9500;
        }
        .pdf-modal-inner {
            position: relative;
            background: var(--surface);
            border-radius: var(--radius-lg);
            padding: 16px;
            box-shadow: var(--shadow-lg);
            animation: popIn .3s ease both;
        }
        .pdf-close-btn {
            position: absolute;
            top: 12px; right: 14px;
            width: 30px; height: 30px;
            border-radius: 6px;
            border: none;
            background: var(--surface2);
            cursor: pointer;
            font-size: 16px;
            color: var(--text-secondary);
            display: flex; align-items: center; justify-content: center;
            transition: background .15s, color .15s;
        }
        .pdf-close-btn:hover { background: #fecaca; color: var(--danger); }

        /* ── File link ── */
        .file-link {
            color: var(--accent);
            font-size: 12px;
            text-decoration: none;
        }
        .file-link:hover { text-decoration: underline; }

        /* ── Animations ── */
        @keyframes fadeIn {
            from { opacity: 0; } to { opacity: 1; }
        }
        @keyframes slideDown {
            from { opacity: 0; transform: translateY(-8px); }
            to   { opacity: 1; transform: translateY(0); }
        }
        @keyframes popIn {
            from { opacity: 0; transform: scale(.92); }
            to   { opacity: 1; transform: scale(1); }
        }

        /* ── select override ── */
        select {
            font-family: 'Noto Sans KR', sans-serif;
        }
        /* flat 정렬: 아이콘 박스 제거, 조회 버튼 다크 */
        .header-icon { display:none !important; }
        .btn-primary { background:#0f172a !important; border-color:#0f172a !important; box-shadow:none !important; }
        .btn-primary:hover { background:#1e293b !important; border-color:#1e293b !important; box-shadow:none !important; transform:none !important; }
    </style>
</head>
<body>
<main class="main">

    <!-- ── Page Header ── -->
    <div class="page-header">
        <div class="page-header-left">
            <div class="header-icon">
                <svg viewBox="0 0 24 24">
                    <path d="M9 5H7a2 2 0 0 0-2 2v12a2 2 0 0 0 2 2h10a2 2 0 0 0 2-2V7a2 2 0 0 0-2-2h-2"/>
                    <rect x="9" y="3" width="6" height="4" rx="1"/>
                    <line x1="9" y1="12" x2="15" y2="12"/>
                    <line x1="9" y1="16" x2="13" y2="16"/>
                </svg>
            </div>
            <div>
                <div class="page-title">일상점검일지</div>
                <div class="page-breadcrumb">설비관리 · 일상점검</div>
            </div>
        </div>
    </div>

    <!-- ── Toolbar ── -->
    <div class="toolbar-card">
        <div class="toolbar-left">
            <div class="field-group">
                <span class="field-label">검색 월</span>
                <input type="text" id="s_sdate" class="month-input monthSet" placeholder="YYYY-MM">
            </div>
            <div class="toolbar-divider"></div>
            <!-- 조회 -->
            <button class="btn btn-primary select-button">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/>
                </svg>
                조회
            </button>
            <!-- 행 추가 -->
            <button class="btn btn-outline insert-button">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/>
                </svg>
                행 추가
            </button>
            <!-- 행 삭제 -->
            <button class="btn btn-danger-outline delete-button">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <polyline points="3 6 5 6 21 6"/>
                    <path d="M19 6l-1 14a2 2 0 0 1-2 2H8a2 2 0 0 1-2-2L5 6"/>
                    <path d="M10 11v6"/><path d="M14 11v6"/>
                </svg>
                행 삭제
            </button>
        </div>
        <div class="toolbar-right">
            <!-- 엑셀 다운로드 -->
            <button class="btn btn-success-outline" id="btnExcel">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/>
                    <polyline points="7 10 12 15 17 10"/>
                    <line x1="12" y1="15" x2="12" y2="3"/>
                </svg>
                Download
            </button>
        </div>
    </div>

    <!-- ── Table ── -->
    <div class="table-wrap">
        <div id="dataTable"></div>
    </div>
</main>


<!-- ── 행 추가 모달 ── -->
<div id="modalContainer" class="modal">
    <div class="modal-content">
        <button class="modal-close close" id="closeModal" type="button">✕</button>
        <div class="modal-header">
            <div class="modal-header-icon">
                <svg viewBox="0 0 24 24">
                    <line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/>
                </svg>
            </div>
            <div class="modal-title">일상점검일지 행 추가</div>
        </div>
        <form id="corrForm" autocomplete="off" enctype="multipart/form-data">
            <input type="hidden" name="id" id="id">
            <input type="hidden" name="year" id="year">
            <div class="form-group">
                <label class="form-label">년 / 월</label>
                <input type="text" class="month-input monthSet month-search" name="y_month" placeholder="예) 2025-07">
            </div>
            <div class="modal-actions">
                <button type="submit" id="saveCorrStatus" class="btn btn-primary">저장</button>
                <button type="button" id="closeModalBtn" class="btn btn-outline">닫기</button>
            </div>
        </form>
    </div>
</div>


<!-- ── PDF Viewer Modal ── -->
<div id="pdfViewerModal">
    <div class="pdf-modal-inner">
        <button class="pdf-close-btn" onclick="document.getElementById('pdfViewerModal').style.display='none';">✕</button>
        <iframe id="pdfFrame" style="width:1000px;height:800px;border:none;display:block;margin-top:8px;"></iframe>
    </div>
</div>


<script>
let now_page_code = "d04";

var dataTable;
var selectedRowData = null;
let tdate2 = "";

/* ── 모달 열기/닫기 ── */
$(".insert-button").click(function () {
    $("#corrForm")[0].reset();
    $("#id").val("");
    $(".monthSet").val(tdate2);
    $("#modalContainer").addClass("show");
});

$(".close, #closeModal, #closeModalBtn").click(function () {
    $("#modalContainer").removeClass("show");
});

/* ── 초기화 ── */
$(function () {
    var tdate = todayDate();
    tdate2 = tdate.substr(0, 7);
    $("#s_sdate").val(tdate2);
    getDailyCheck();
    getDailyCheckData();
});

/* ── 조회 버튼 ── */
$('.select-button').click(function () {
    getDailyCheckData();
});

/* ── 엑셀 다운로드 (서버) ── */
$("#btnExcel").click(function () {
    $.ajax({
        url: "/line/condition/dailyCheck/excelDownload",
        type: "POST",
        xhrFields: { responseType: 'blob' },
        data: { "d_sdate": $("#s_sdate").val() },
        success: function (blob) {
            const link = document.createElement('a');
            const url  = window.URL.createObjectURL(blob);
            link.href  = url;
            link.download = "일상점검일지.xlsx";
            link.click();
            window.URL.revokeObjectURL(url);
        }
    });
});

/* ── 데이터 로드 ── */
function getDailyCheckData() {
    $.ajax({
        url: "/line/condition/dailyCheck/list",
        type: "post",
        dataType: "json",
        data: { "d_sdate": $("#s_sdate").val() },
        success: function (result) {
            dataTable.setData(result.data);
        }
    });
}

/* ── Tabulator 초기화 ── */
function getDailyCheck() {
    dataTable = new Tabulator('#dataTable', {
        height: '100%',
        layout: 'fitDataFill',
        headerSort: false,
        reactiveData: true,
        columnHeaderVertAlign: "middle",
        rowVertAlign: "middle",
        headerHozAlign: 'center',
        placeholder: "조회된 데이터가 없습니다.",
        columns: [
            { title: "년-월",    field: "d_ym",    width: 80,  hozAlign: "center", frozen: true },
            { title: "점검항목", field: "d_title", width: 250, hozAlign: "left",   frozen: true, editor: "input" },
            { title: "점검내용", field: "d_desc",  width: 450, hozAlign: "left",   frozen: true, editor: "input" },
            {
                title: "이미지",
                width: 100,
                hozAlign: "center",
                formatter: function (cell) {
                    return `<button class="img-upload-btn">업로드</button>`;
                },
                cellClick: function (e, cell) {
                    const rowData = cell.getRow().getData();
                    const cnt = rowData.cnt;
                    const input = document.createElement("input");
                    input.type = "file";
                    input.accept = "image/*,application/pdf";
                    input.onchange = function (event) {
                        const file = event.target.files[0];
                        if (!file) return;
                        const formData = new FormData();
                        formData.append("cnt", cnt);
                        formData.append("file", file);
                        $.ajax({
                            url: "/line/condition/dailycheck/uploadImage",
                            type: "POST",
                            data: formData,
                            processData: false,
                            contentType: false,
                            success: function (res) {
                                if (res && res.result === 'success') {
                                    cell.getRow().update({ img_url: res.fileName });
                                    alert("이미지 업로드 완료");
                                } else {
                                    alert("업로드 실패: " + (res && res.message ? res.message : 'unknown'));
                                }
                            },
                            error: function (xhr) { alert("업로드 실패: " + xhr.statusText); }
                        });
                    };
                    input.click();
                }
            },
            {
                title: "파일 링크",
                field: "img_url",
                hozAlign: "left",
                width: 250,
                formatter: function (cell) {
                    const fn = cell.getValue();
                    if (!fn) return "";
                    return '<a class="file-link" href="javascript:void(0);" onclick="openPdf(\'' + encodeURIComponent(fn) + '\')">' + fn + '</a>';
                }
            },
            { title: "1일",  field: "d01", width: 70, hozAlign: "center", editor: "input" },
            { title: "2일",  field: "d02", width: 70, hozAlign: "center", editor: "input" },
            { title: "3일",  field: "d03", width: 70, hozAlign: "center", editor: "input" },
            { title: "4일",  field: "d04", width: 70, hozAlign: "center", editor: "input" },
            { title: "5일",  field: "d05", width: 70, hozAlign: "center", editor: "input" },
            { title: "6일",  field: "d06", width: 70, hozAlign: "center", editor: "input" },
            { title: "7일",  field: "d07", width: 70, hozAlign: "center", editor: "input" },
            { title: "8일",  field: "d08", width: 70, hozAlign: "center", editor: "input" },
            { title: "9일",  field: "d09", width: 70, hozAlign: "center", editor: "input" },
            { title: "10일", field: "d10", width: 70, hozAlign: "center", editor: "input" },
            { title: "11일", field: "d11", width: 70, hozAlign: "center", editor: "input" },
            { title: "12일", field: "d12", width: 70, hozAlign: "center", editor: "input" },
            { title: "13일", field: "d13", width: 70, hozAlign: "center", editor: "input" },
            { title: "14일", field: "d14", width: 70, hozAlign: "center", editor: "input" },
            { title: "15일", field: "d15", width: 70, hozAlign: "center", editor: "input" },
            { title: "16일", field: "d16", width: 70, hozAlign: "center", editor: "input" },
            { title: "17일", field: "d17", width: 70, hozAlign: "center", editor: "input" },
            { title: "18일", field: "d18", width: 70, hozAlign: "center", editor: "input" },
            { title: "19일", field: "d19", width: 70, hozAlign: "center", editor: "input" },
            { title: "20일", field: "d20", width: 70, hozAlign: "center", editor: "input" },
            { title: "21일", field: "d21", width: 70, hozAlign: "center", editor: "input" },
            { title: "22일", field: "d22", width: 70, hozAlign: "center", editor: "input" },
            { title: "23일", field: "d23", width: 70, hozAlign: "center", editor: "input" },
            { title: "24일", field: "d24", width: 70, hozAlign: "center", editor: "input" },
            { title: "25일", field: "d25", width: 70, hozAlign: "center", editor: "input" },
            { title: "26일", field: "d26", width: 70, hozAlign: "center", editor: "input" },
            { title: "27일", field: "d27", width: 70, hozAlign: "center", editor: "input" },
            { title: "28일", field: "d28", width: 70, hozAlign: "center", editor: "input" },
            { title: "29일", field: "d29", width: 70, hozAlign: "center", editor: "input" },
            { title: "30일", field: "d30", width: 70, hozAlign: "center", editor: "input" },
            { title: "31일", field: "d31", width: 70, hozAlign: "center", editor: "input" },
            { title: "비고", field: "d_bigo", width: 200, hozAlign: "center", editor: "input" },
            { field: "cnt", visible: false },
        ],
        rowClick: function (e, row) {
            $('#dataTable .tabulator-row').removeClass('row_select');
            row.getElement().classList.add('row_select');
            selectedRowData = row.getData();
        },
        cellEdited: function (cell) {
            var field   = cell.getField();
            var value   = cell.getValue();
            var rowData = cell.getRow().getData();
            var cnt     = rowData.cnt;
            $.ajax({
                url: "/line/condition/dailycheck/update",
                type: "POST",
                dataType: "json",
                data: { "d_field": field, "d_value": value, "cnt": cnt },
                success: function (result) {}
            });
        },
    });
}

/* ── PDF 뷰어 ── */
function openPdf(encodedName) {
    if (!encodedName) { alert("파일명이 없습니다!"); return; }
    document.getElementById('pdfFrame').src =
        '/line/condition/dailycheck/viewImage?fileName=' + encodedName;
    document.getElementById('pdfViewerModal').style.display = 'flex';
}

/* ── 저장 ── */
$("#saveCorrStatus").click(function (event) {
    event.preventDefault();
    const y_m = $(".monthSet").val() || "";
    if (!y_m) { alert("년/월을 선택하세요."); return; }
    $.ajax({
        url: "/line/condition/dailycheck/insert",
        type: "POST",
        data: { y_m: y_m },
        dataType: "json",
        success: function (response) {
            if (response.result === "success") {
                alert("행이 성공적으로 추가되었습니다!");
                $("#modalContainer").removeClass("show");
                getDailyCheckData();
            } else {
                alert("저장 실패: " + (response.message || "알 수 없는 오류"));
            }
        },
        error: function (xhr, status, error) {
            console.error(xhr.responseText);
            alert("서버 오류 발생! " + error);
        }
    });
});

/* ── 삭제 ── */
$(".delete-button").click(function (event) {
    event.preventDefault();
    if (!dataTable) { alert("테이블이 준비되지 않았습니다."); return; }
    if (!selectedRowData) { alert("삭제할 행을 선택하세요."); return; }
    const cnt = selectedRowData.cnt;
    if (!confirm("정말 삭제하시겠습니까?")) return;
    $.ajax({
        url: "/line/condition/dailycheck/del",
        type: "POST",
        contentType: "application/json",
        data: JSON.stringify({ cnt: cnt }),
        dataType: "json",
        success: function (res) {
            alert("삭제가 완료되었습니다.");
            selectedRowData = null;
            getDailyCheckData();
        },
        error: function (xhr, status, error) {
            alert("삭제 중 오류 발생: " + error);
        }
    });
});
</script>
</body>
</html>
