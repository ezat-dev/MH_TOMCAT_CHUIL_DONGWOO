<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="ko">
<head>
<script src="/line/mock/mock-loader.js"></script>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>F/PROOF</title>
    <%@include file="../include/pluginpage.jsp" %>
    <jsp:include page="../include/tabBar.jsp"/>
    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;600;700&family=JetBrains+Mono:wght@400;500&display=swap" rel="stylesheet">
    <link href="/vendor/tabulator/5.6.1/tabulator.min.css" rel="stylesheet">
    <script src="/vendor/tabulator/5.6.1/tabulator.min.js"></script>

    <style>
        /* ── Reset & Variables ── */
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
            --success-bg:   #ecfdf5;
            --danger:       #dc2626;
            --danger-bg:    #fff5f5;
            --warning:      #d97706;
            --radius-sm:    6px;
            --radius:       10px;
            --radius-lg:    14px;
            --shadow-sm:    0 1px 3px rgba(0,0,0,0.06), 0 1px 2px rgba(0,0,0,0.04);
            --shadow:       0 4px 12px rgba(0,0,0,0.08);
            --shadow-lg:    0 8px 30px rgba(0,0,0,0.14);
        }

        * { box-sizing: border-box; margin: 0; padding: 0; }

        body {
            font-family: 'Noto Sans KR', sans-serif;
            background: var(--bg);
            color: var(--text-primary);
            min-height: 100vh;
        }

        /* ── Main ── */
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
            box-shadow: 0 2px 8px rgba(37,99,235,0.28);
            flex-shrink: 0;
        }
        .header-icon svg {
            width: 20px; height: 20px;
            fill: none; stroke: #fff;
            stroke-width: 2; stroke-linecap: round; stroke-linejoin: round;
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
        .toolbar-left  { display: flex; align-items: center; gap: 10px; }
        .toolbar-right { display: flex; align-items: center; gap: 8px; }

        /* ── Field Group ── */
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
        .month-input::placeholder { color: var(--text-muted); }

        /* ── Divider ── */
        .toolbar-divider {
            width: 1px; height: 28px;
            background: var(--border);
            margin: 0 2px;
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
        .btn svg { width: 14px; height: 14px; flex-shrink: 0; }

        .btn-primary {
            background: var(--accent);
            color: #fff;
            border-color: var(--accent);
            box-shadow: 0 1px 4px rgba(37,99,235,0.25);
        }
        .btn-primary:hover {
            background: var(--accent-hover);
            border-color: var(--accent-hover);
            transform: translateY(-1px);
            box-shadow: 0 3px 8px rgba(37,99,235,0.35);
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
            background: var(--danger-bg);
            border-color: var(--danger);
        }
        .btn-success-outline {
            background: var(--surface);
            color: var(--success);
            border-color: #a7f3d0;
        }
        .btn-success-outline:hover {
            background: var(--success-bg);
            border-color: var(--success);
        }

        /* ── Table Wrap ── */
        .table-wrap {
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: var(--radius);
            overflow: hidden;
            box-shadow: var(--shadow-sm);
            animation: slideDown .4s .1s ease both;
        }

        /* ── Tabulator Overrides ── */
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
        .tabulator-row.tabulator-selected,
        .tabulator-row.row_select {
            background: #dbeafe !important;
            border-left: 3px solid var(--accent) !important;
        }
        .tabulator-row .tabulator-cell {
            color: var(--text-primary) !important;
            border-right: 1px solid var(--border-light) !important;
            padding: 9px 10px !important;
        }
        .tabulator .tabulator-footer {
            background: var(--surface2) !important;
            border-top: 1px solid var(--border) !important;
            color: var(--text-muted) !important;
        }
        /* OK/NG 셀 색상 */
        .cell-ok  { color: var(--success) !important; font-weight: 600 !important; }
        .cell-ng  { color: var(--danger)  !important; font-weight: 600 !important; }

        /* 업로드 버튼 in cell */
        .img-upload-btn {
            font-family: 'Noto Sans KR', sans-serif;
            font-size: 11px;
            font-weight: 500;
            padding: 3px 9px;
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
        .file-link {
            color: var(--accent);
            font-size: 12px;
            text-decoration: none;
        }
        .file-link:hover { text-decoration: underline; }

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
            font-size: 15px;
            color: var(--text-muted);
            transition: background .15s, color .15s;
        }
        .modal-close:hover { background: #fecaca; color: var(--danger); }

        .form-group { margin-bottom: 16px; }
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
        .form-input::placeholder { color: var(--text-muted); }

        .modal-actions {
            display: flex;
            gap: 8px;
            margin-top: 8px;
        }
        .modal-actions .btn { flex: 1; justify-content: center; }

        /* ── PDF Viewer ── */
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
            font-size: 15px;
            color: var(--text-secondary);
            display: flex; align-items: center; justify-content: center;
            transition: background .15s, color .15s;
        }
        .pdf-close-btn:hover { background: #fecaca; color: var(--danger); }

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

        select { font-family: 'Noto Sans KR', sans-serif; }
    </style>
</head>
<body>
<main class="main">

    <!-- ── Page Header ── -->
    <div class="page-header">
        <div class="page-header-left">
            <div class="header-icon">
                <svg viewBox="0 0 24 24">
                    <path d="M14 14.76V3.5a2.5 2.5 0 0 0-5 0v11.26a4.5 4.5 0 1 0 5 0z"/>
                </svg>
            </div>
            <div>
                <div class="page-title">F/PROOF</div>
                <div class="page-breadcrumb">품질관리 · F/Proof 점검</div>
            </div>
        </div>
    </div>

    <!-- ── Toolbar ── -->
    <div class="toolbar-card">
        <div class="toolbar-left">
            <div class="field-group">
                <span class="field-label">검색 월</span>
                <input type="text" id="y_m" class="month-input monthSet month-search" placeholder="YYYY-MM">
            </div>
            <div class="toolbar-divider"></div>
            <button class="btn btn-primary select-button">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/>
                </svg>
                조회
            </button>
            <button class="btn btn-outline insert-button">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/>
                </svg>
                행 추가
            </button>
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
        <div id="dataList"></div>
    </div>
</main>


<!-- ── 행 추가 모달 ── -->
<div id="modalContainer" class="modal">
    <div class="modal-content">
        <button class="modal-close close" type="button">✕</button>
        <div class="modal-header">
            <div class="modal-header-icon">
                <svg viewBox="0 0 24 24">
                    <line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/>
                </svg>
            </div>
            <div class="modal-title">F/Proof 행 추가</div>
        </div>
        <form id="corrForm" autocomplete="off" enctype="multipart/form-data">
            <input type="hidden" name="id" id="modalId">
            <input type="hidden" name="year" id="modalYear">
            <div class="form-group">
                <label class="form-label">년 / 월</label>
                <input type="text" class="form-input monthSet month-modal" name="y_month" placeholder="예: 2025-07">
            </div>
            <div class="modal-actions">
                <button type="submit" id="saveCorrStatus" class="btn btn-primary">저장</button>
                <button type="button" id="closeModal" class="btn btn-outline">닫기</button>
            </div>
        </form>
    </div>
</div>


<!-- ── PDF Viewer ── -->
<div id="pdfViewerModal">
    <div class="pdf-modal-inner">
        <button class="pdf-close-btn" onclick="document.getElementById('pdfViewerModal').style.display='none';">✕</button>
        <iframe id="pdfFrame" style="width:1000px;height:800px;border:none;display:block;margin-top:8px;"></iframe>
    </div>
</div>


<script>
let now_page_code = "e03";
let dataTable = null;

$(document).ready(function () {

    /* 현재 년-월 세팅 */
    const now = new Date();
    const ym  = now.getFullYear() + "-" + String(now.getMonth() + 1).padStart(2, "0");
    $("#y_m").val(ym);
    $("input[name='y_month']").val(ym);

    /* Tabulator 생성 */
    getDataList();

    /* 행 추가 모달 열기 */
    $(".insert-button").click(function () {
        $("#corrForm")[0].reset();
        $("input[name='y_month']").val($("#y_m").val());
        $("#modalContainer").addClass("show");
    });

    /* 모달 닫기 */
    $(".close, #closeModal").click(function () {
        $("#modalContainer").removeClass("show");
    });

    /* 조회 */
    $(".select-button").click(function () {
        if (!dataTable) return;
        dataTable.setData("/line/quality/fProof/list", { y_m: $("#y_m").val() });
    });

    /* 엑셀 다운로드 */
    $("#btnExcel").click(function (event) {
        event.preventDefault();
        const y_m = $("#y_m").val();
        if (!y_m) { alert("년/월을 선택하세요."); return; }
        window.location.href = "/line/quality/fProof/excel?y_m=" + encodeURIComponent(y_m);
    });

    /* 저장 (행 추가) */
    $("#saveCorrStatus").click(function (event) {
        event.preventDefault();
        const y_m = $("input[name='y_month']").val();
        if (!y_m) { alert("년/월을 선택하세요."); return; }
        $.ajax({
            url: "/line/quality/fProof/insert",
            type: "POST",
            data: { y_m: y_m },
            dataType: "json",
            success: function (res) {
                if (res.result === "success") {
                    alert("행이 성공적으로 추가되었습니다.");
                    $("#modalContainer").removeClass("show");
                    dataTable.replaceData();
                } else {
                    alert("저장 실패: " + (res.message || ""));
                }
            },
            error: function () { alert("서버 오류 발생"); }
        });
    });

    /* 삭제 */
    $(".delete-button").click(function (event) {
        event.preventDefault();
        if (!dataTable) { alert("테이블이 준비되지 않았습니다."); return; }
        const rows = dataTable.getSelectedRows();
        if (!rows.length) { alert("삭제할 행을 선택하세요."); return; }
        const id = rows[0].getData().id;
        if (!confirm("정말 삭제하시겠습니까?")) return;
        $.ajax({
            url: "/line/quality/fProof/del",
            type: "POST",
            contentType: "application/json",
            data: JSON.stringify({ id: id }),
            success: function () {
                alert("삭제 완료");
                dataTable.replaceData();
            },
            error: function () { alert("삭제 중 오류 발생"); }
        });
    });
});

/* ── Tabulator 생성 ── */
function getDataList() {
    const dayColumns = [];
    for (let i = 1; i <= 31; i++) {
        dayColumns.push({
            title: i + "일",
            field: "m_" + i,
            hozAlign: "center",
            width: 70,
            editor: "select",
            editorParams: { values: ["OK", "NG"] },
            headerSort: false,
            formatter: function (cell) {
                const v = cell.getValue();
                if (v === "OK") cell.getElement().classList.add("cell-ok");
                else if (v === "NG") cell.getElement().classList.add("cell-ng");
                return v || "";
            }
        });
    }

    const columns = [
        { title: "ID",      field: "id",       visible: false, frozen: true },
        { title: "No",      formatter: "rownum", width: 55, hozAlign: "center", frozen: true },
        { title: "년/월",   field: "y_m", visible: false,      width: 110, hozAlign: "center", frozen: true,
          formatter: function(cell){ return `<span style="font-family:'JetBrains Mono',monospace;font-size:12px;">${cell.getValue()||""}</span>`; }
        },
        { title: "설비",    field: "mch_name", width: 110, frozen: true, editor: "input" },
        { title: "규격",    field: "standard", width: 120, frozen: true, editor: "input" },
        { title: "점검항목",field: "up_down",  width: 120, frozen: true, editor: "input" },
        {
            title: "이미지",
            width: 90,
            hozAlign: "center",
            formatter: function (cell) { return `<button class="img-upload-btn">업로드</button>`; },
            cellClick: function (e, cell) {
                const id = cell.getRow().getData().id;
                const input = document.createElement("input");
                input.type = "file";
                input.accept = "image/*,application/pdf";
                input.onchange = function (event) {
                    const file = event.target.files[0];
                    if (!file) return;
                    const formData = new FormData();
                    formData.append("cnt", id);
                    formData.append("file", file);
                    $.ajax({
                        url: "/line/quality/fProof/uploadImage",
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
            title: "점검방법",
            field: "img_url",
            hozAlign: "left",
            width: 220,
            formatter: function (cell) {
                const fn = cell.getValue();
                if (!fn) return "";
                return '<a class="file-link" href="javascript:void(0);" onclick="openPdf(\'' + encodeURIComponent(fn) + '\')">' + fn + '</a>';
            }
        },
        { title: "이상시 조치내용",field: "memo_f",  width: 220,  editor: "input" },
       
        ...dayColumns
    ];

    dataTable = new Tabulator("#dataList", {
        height: "700px",
        layout: "fitColumns",
        headerHozAlign: "center",
        columnHeaderVertAlign: "middle",
        rowVertAlign: "middle",
        selectable: 1,
        ajaxConfig: "POST",
        ajaxURL: "/line/quality/fProof/list",
        ajaxParams: { y_m: $("#y_m").val() },
        placeholder: "데이터가 없습니다.",
        columns: columns,
        cellEdited: function (cell) {
            const rowData = cell.getRow().getData();
            const payload = {
                id:     rowData.id,
                column: cell.getField(),
                value:  cell.getValue()
            };
            $.ajax({
                url: "/line/quality/fProof/save",
                type: "POST",
                contentType: "application/json",
                data: JSON.stringify(payload),
                success: function (res) {
                    if (res.result !== "success") cell.restoreOldValue();
                },
                error: function () { cell.restoreOldValue(); }
            });
        }
    });
}

/* ── PDF 뷰어 ── */
function openPdf(encodedName) {
    if (!encodedName) { alert("파일명이 없습니다!"); return; }
    document.getElementById('pdfFrame').src = '/line/quality/fProof/viewImage?fileName=' + encodedName;
    document.getElementById('pdfViewerModal').style.display = 'flex';
}
</script>
</body>
</html>
