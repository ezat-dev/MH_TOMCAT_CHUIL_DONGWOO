<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="ko">
<head>
<script src="/line/mock/mock-loader.js"></script>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>온도균일성 테스트</title>
    <%@include file="../include/pluginpage.jsp" %>
    <jsp:include page="../include/tabBar.jsp"/>
    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;600;700&family=JetBrains+Mono:wght@400;500&display=swap" rel="stylesheet">
    <link href="/vendor/tabulator/5.6.1/tabulator.min.css" rel="stylesheet">
    <script src="/vendor/tabulator/5.6.1/tabulator.min.js"></script>

    <style>
        /* ── Variables ── */
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
            --success-border:#a7f3d0;
            --danger:       #dc2626;
            --danger-bg:    #fff5f5;
            --danger-border:#fecaca;
            --warning:      #d97706;
            --radius-sm:    6px;
            --radius:       10px;
            --radius-lg:    14px;
            --shadow-sm:    0 1px 3px rgba(0,0,0,0.06), 0 1px 2px rgba(0,0,0,0.04);
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
            margin-bottom: 20px;
        }
        .header-icon {
            width: 40px; height: 40px;
            background: var(--accent);
            border-radius: var(--radius-sm);
            display: flex; align-items: center; justify-content: center;
            box-shadow: 0 2px 8px rgba(37,99,235,0.28);
            flex-shrink: 0;
            margin-right: 12px;
        }
        .header-icon svg {
            width: 20px; height: 20px;
            fill: none; stroke: #fff;
            stroke-width: 2; stroke-linecap: round; stroke-linejoin: round;
        }
        .page-title   { font-size: 18px; font-weight: 700; letter-spacing: -.3px; }
        .page-breadcrumb { font-size: 12px; color: var(--text-muted); margin-top: 2px; }

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

        .field-group   { display: flex; align-items: center; gap: 8px; }
        .field-label   {
            font-size: 13px; font-weight: 600;
            color: var(--text-secondary); white-space: nowrap;
        }
        .year-input {
            font-family: 'JetBrains Mono', monospace;
            font-size: 13px;
            background: var(--surface2);
            border: 1px solid var(--border);
            border-radius: var(--radius-sm);
            color: var(--text-primary);
            padding: 7px 12px;
            width: 110px;
            outline: none;
            text-align: center;
            transition: border-color .2s, box-shadow .2s;
        }
        .year-input:focus {
            border-color: var(--accent);
            box-shadow: 0 0 0 3px rgba(37,99,235,0.12);
        }
        .year-input::placeholder { color: var(--text-muted); }

        .toolbar-divider { width: 1px; height: 28px; background: var(--border); margin: 0 2px; }

        /* ── Buttons ── */
        .btn {
            display: inline-flex; align-items: center; gap: 6px;
            font-family: 'Noto Sans KR', sans-serif;
            font-size: 13px; font-weight: 500;
            padding: 7px 13px;
            border-radius: var(--radius-sm);
            border: 1px solid transparent;
            cursor: pointer;
            transition: all .18s ease;
            white-space: nowrap;
        }
        .btn svg { width: 14px; height: 14px; flex-shrink: 0; }

        .btn-primary {
            background: var(--accent); color: #fff; border-color: var(--accent);
            box-shadow: 0 1px 4px rgba(37,99,235,0.25);
        }
        .btn-primary:hover {
            background: var(--accent-hover); border-color: var(--accent-hover);
            transform: translateY(-1px); box-shadow: 0 3px 8px rgba(37,99,235,0.35);
        }
        .btn-outline {
            background: var(--surface); color: var(--text-secondary); border-color: var(--border);
        }
        .btn-outline:hover { border-color: var(--accent); color: var(--accent); background: var(--accent-light); }

        .btn-danger-outline {
            background: var(--surface); color: var(--danger); border-color: var(--danger-border);
        }
        .btn-danger-outline:hover { background: var(--danger-bg); border-color: var(--danger); }

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
        .tabulator .tabulator-header .tabulator-col:hover { background: #e8edf5 !important; }
        .tabulator-row {
            background: var(--surface) !important;
            border-bottom: 1px solid var(--border-light) !important;
            transition: background .12s !important;
        }
        .tabulator-row:nth-child(even) { background: #fafbfd !important; }
        .tabulator-row:hover           { background: var(--accent-light) !important; }
        .tabulator-row.row_select      {
            background: #dbeafe !important;
            border-left: 3px solid var(--accent) !important;
        }
        .tabulator-row .tabulator-cell {
            color: var(--text-primary) !important;
            border-right: 1px solid var(--border-light) !important;
            padding: 10px 12px !important;
        }
        .tabulator .tabulator-footer {
            background: var(--surface2) !important;
            border-top: 1px solid var(--border) !important;
        }

        /* 합격/불합격 배지 */
        .badge-pass {
            display: inline-block;
            padding: 2px 10px; border-radius: 20px; font-size: 11px; font-weight: 600;
            background: var(--success-bg); color: var(--success);
            border: 1px solid var(--success-border);
        }
        .badge-fail {
            display: inline-block;
            padding: 2px 10px; border-radius: 20px; font-size: 11px; font-weight: 600;
            background: var(--danger-bg); color: var(--danger);
            border: 1px solid var(--danger-border);
        }
        .file-link { color: var(--accent); font-size: 12px; text-decoration: none; }
        .file-link:hover { text-decoration: underline; }

        /* ── Modal ── */
        .modal {
            display: none;
            position: fixed; inset: 0;
            background: rgba(15,23,42,0.45);
            backdrop-filter: blur(3px);
            z-index: 9000;
            align-items: center; justify-content: center;
        }
        .modal.show { display: flex; }

        .modal-content {
            background: var(--surface);
            width: 440px; max-width: 95vw;
            max-height: 90vh; overflow-y: auto;
            border-radius: var(--radius-lg);
            box-shadow: var(--shadow-lg);
            padding: 28px 28px 22px;
            position: relative;
            animation: popIn .3s cubic-bezier(.34,1.56,.64,1) both;
        }
        .modal-header {
            display: flex; align-items: center; gap: 10px;
            margin-bottom: 22px;
        }
        .modal-header-icon {
            width: 34px; height: 34px;
            background: var(--accent-light); border-radius: 8px;
            display: flex; align-items: center; justify-content: center;
        }
        .modal-header-icon svg {
            width: 16px; height: 16px;
            stroke: var(--accent); fill: none;
            stroke-width: 2; stroke-linecap: round; stroke-linejoin: round;
        }
        .modal-title { font-size: 15px; font-weight: 700; }
        .modal-close {
            position: absolute; top: 16px; right: 18px;
            width: 28px; height: 28px; border-radius: 6px;
            border: none; background: var(--surface2);
            cursor: pointer; display: flex; align-items: center; justify-content: center;
            font-size: 15px; color: var(--text-muted);
            transition: background .15s, color .15s;
        }
        .modal-close:hover { background: var(--danger-bg); color: var(--danger); }

        /* Form elements inside modal */
        .form-group { margin-bottom: 14px; }
        .form-label {
            display: block; font-size: 12px; font-weight: 600;
            color: var(--text-secondary); margin-bottom: 5px; letter-spacing: .2px;
        }
        .form-input, .form-select {
            width: 100%;
            font-family: 'Noto Sans KR', sans-serif;
            font-size: 13px;
            padding: 8px 11px;
            border: 1px solid var(--border);
            border-radius: var(--radius-sm);
            outline: none; color: var(--text-primary);
            background: var(--surface2);
            transition: border-color .2s, box-shadow .2s;
        }
        .form-input:focus, .form-select:focus {
            border-color: var(--accent);
            box-shadow: 0 0 0 3px rgba(37,99,235,0.12);
            background: #fff;
        }
        .form-input::placeholder { color: var(--text-muted); }

        /* 파일 업로드 */
        .file-upload-wrap {
            position: relative;
            border: 1.5px dashed var(--border);
            border-radius: var(--radius-sm);
            padding: 14px 12px;
            text-align: center;
            cursor: pointer;
            transition: border-color .2s, background .2s;
            background: var(--surface2);
        }
        .file-upload-wrap:hover {
            border-color: var(--accent);
            background: var(--accent-light);
        }
        .file-upload-wrap input[type="file"] {
            position: absolute; inset: 0; opacity: 0; cursor: pointer; width: 100%;
        }
        .file-upload-label {
            font-size: 12px; color: var(--text-muted);
            pointer-events: none;
        }
        .file-upload-label svg {
            width: 18px; height: 18px; display: block; margin: 0 auto 4px;
            stroke: var(--text-muted); fill: none;
            stroke-width: 1.5; stroke-linecap: round; stroke-linejoin: round;
        }
        #fileNameDisplay {
            margin-top: 6px; font-size: 11px;
            color: var(--accent); font-weight: 500; word-break: break-all;
        }

        .modal-actions { display: flex; gap: 8px; margin-top: 18px; }
        .modal-actions .btn { flex: 1; justify-content: center; }

        /* ── Separator line in form ── */
        .form-divider {
            border: none; border-top: 1px solid var(--border-light);
            margin: 10px 0 14px;
        }

        /* ── Animations ── */
        @keyframes fadeIn   { from { opacity:0 } to { opacity:1 } }
        @keyframes slideDown {
            from { opacity:0; transform:translateY(-8px); }
            to   { opacity:1; transform:translateY(0); }
        }
        @keyframes popIn {
            from { opacity:0; transform:scale(.92); }
            to   { opacity:1; transform:scale(1); }
        }

        /* global select override */
        select { font-family: 'Noto Sans KR', sans-serif; }
    </style>
</head>
<body>
<main class="main">

    <!-- ── Page Header ── -->
    <div class="page-header">
        <div class="header-icon">
            <svg viewBox="0 0 24 24">
                <path d="M14 14.76V3.5a2.5 2.5 0 0 0-5 0v11.26a4.5 4.5 0 1 0 5 0z"/>
            </svg>
        </div>
        <div>
            <div class="page-title">온도균일성 테스트</div>
            <div class="page-breadcrumb">품질관리 · 온도 균일성 점검 이력</div>
        </div>
    </div>

    <!-- ── Toolbar ── -->
    <div class="toolbar-card">
        <div class="toolbar-left">
            <div class="field-group">
                <span class="field-label">검색 연도</span>
                <input type="text" id="t_year" class="year-input yearSet" placeholder="YYYY">
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
                추가
            </button>
            <button class="btn btn-danger-outline delete-button">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <polyline points="3 6 5 6 21 6"/>
                    <path d="M19 6l-1 14a2 2 0 0 1-2 2H8a2 2 0 0 1-2-2L5 6"/>
                    <path d="M10 11v6"/><path d="M14 11v6"/>
                </svg>
                삭제
            </button>
        </div>
    </div>

    <!-- ── Table ── -->
    <div class="table-wrap">
        <div id="dataList"></div>
    </div>
</main>


<!-- ── 등록/수정 모달 ── -->
<div id="modalContainer" class="modal">
    <div class="modal-content">
        <button class="modal-close close" type="button">✕</button>
        <div class="modal-header">
            <div class="modal-header-icon">
                <svg viewBox="0 0 24 24">
                    <path d="M14 14.76V3.5a2.5 2.5 0 0 0-5 0v11.26a4.5 4.5 0 1 0 5 0z"/>
                </svg>
            </div>
            <div class="modal-title">온도 균일성 테스트</div>
        </div>

        <form id="corrForm" autocomplete="off" enctype="multipart/form-data">
            <input type="hidden" name="id" id="hiddenId">

            <div class="form-group">
                <label class="form-label">발생 설비</label>
                <select name="mch_name" class="form-select">
                    <option value="소려로 소입로">소려로 소입로</option>
                </select>
            </div>

            <div style="display:grid; grid-template-columns:1fr 1fr 1fr; gap:10px;">
                <div class="form-group">
                    <label class="form-label">연도</label>
                    <input type="text" name="t_year" class="form-input yearSet" placeholder="YYYY">
                </div>
                <div class="form-group">
                    <label class="form-label">발생 월</label>
                    <input type="text" name="t_month" class="form-input monthSet" placeholder="MM">
                </div>
                <div class="form-group">
                    <label class="form-label">측정일</label>
                    <input type="text" name="t_day" class="form-input daySet" placeholder="DD">
                </div>
            </div>

            <div class="form-group">
                <label class="form-label">합격 / 불합격</label>
                <select name="t_gb" class="form-select">
                    <option value="합격">합격</option>
                    <option value="불합격">불합격</option>
                </select>
            </div>

            <hr class="form-divider">

            <div class="form-group">
                <label class="form-label">기준서 (PDF)</label>
                <div class="file-upload-wrap">
                    <input type="file" id="fileInput" name="uploadFile" accept="application/pdf">
                    <label class="file-upload-label" for="fileInput">
                        <svg viewBox="0 0 24 24"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="17 8 12 3 7 8"/><line x1="12" y1="3" x2="12" y2="15"/></svg>
                        클릭하여 PDF 파일 선택
                    </label>
                    <div id="fileNameDisplay"></div>
                </div>
            </div>

            <div class="form-group">
                <label class="form-label">파일 이름</label>
                <input type="text" name="t_url" id="fileName" class="form-input" placeholder="파일명 자동 입력">
            </div>

            <div class="form-group">
                <label class="form-label">비고</label>
                <input type="text" name="t_ok" class="form-input" placeholder="비고 입력">
            </div>

            <div class="modal-actions">
                <button type="submit" id="saveCorrStatus" class="btn btn-primary">저장</button>
                <button type="button" id="closeModal" class="btn btn-outline">닫기</button>
            </div>
        </form>
    </div>
</div>


<script>
let now_page_code = "e04";
let dataTable = null;
let selectedRow = null;

$(document).ready(function () {

    /* ── 연도 기본값 ── */
    const currentYear = new Date().getFullYear();
    $('#t_year').val(currentYear);

    /* ── 파일 선택 시 이름 표시 ── */
    document.getElementById("fileInput").addEventListener("change", function () {
        const file = this.files[0];
        const display = document.getElementById("fileNameDisplay");
        if (file) {
            document.getElementById("fileName").value = file.name;
            display.textContent = "📄 " + file.name;
        } else {
            document.getElementById("fileName").value = "";
            display.textContent = "";
        }
    });

    /* ── Tabulator 초기화 ── */
    getDataList();

    /* ── 행 추가 모달 ── */
    $(".insert-button").click(function () {
        $("#corrForm")[0].reset();
        $("#hiddenId").val("");
        $("#fileNameDisplay").text("");
        $("input[name='t_year']").val(currentYear);
        $("#modalContainer").addClass("show");
    });

    /* ── 모달 닫기 ── */
    $(".close, #closeModal").click(function () {
        $("#modalContainer").removeClass("show");
    });

    /* ── 조회 ── */
    $(".select-button").click(function () {
        const t_year = $("#t_year").val() || "";
        dataTable.setData("/line/quality/tusTest/list", { t_year });
    });

    /* ── 저장 ── */
    $("#saveCorrStatus").click(function (event) {
        event.preventDefault();
        const formElement = document.getElementById("corrForm");
        const formData = new FormData(formElement);
        if (!formData.get("id") || formData.get("id").trim() === "") formData.delete("id");

        $.ajax({
            url: "/line/quality/tusTest/insert",
            type: "POST",
            data: formData,
            dataType: "json",
            processData: false,
            contentType: false,
            success: function (response) {
                if (response.result === "success") {
                    alert("성공적으로 저장되었습니다!");
                    $("#modalContainer").removeClass("show");
                    getDataList();
                } else {
                    alert("저장 실패: " + (response.message || "알 수 없는 오류"));
                }
            },
            error: function () { alert("서버 오류 발생!"); }
        });
    });

    /* ── 삭제 ── */
    $(".delete-button").click(function (event) {
        event.preventDefault();
        if (!selectedRow)              { alert("삭제할 행을 선택하세요."); return; }
        const id = selectedRow.getData().id;
        if (!id)                       { alert("삭제할 항목이 없습니다."); return; }
        if (!confirm("정말 삭제하시겠습니까?")) return;

        $.ajax({
            url: "/line/quality/tusTest/del",
            type: "POST",
            contentType: "application/json",
            data: JSON.stringify({ id }),
            dataType: "json",
            success: function () {
                alert("삭제가 완료되었습니다.");
                selectedRow = null;
                dataTable.replaceData();
            },
            error: function (xhr, status, error) { alert("삭제 중 오류 발생: " + error); }
        });
    });

    /* ── 엑셀 ── */
    $(".excel-button").on("click", function () {
        const t_year = $("#t_year").val() || "";
        $.ajax({
            url: "/line/quality/tusTest/excel",
            type: "post",
            data: { t_year },
            dataType: "json",
            success: function (result) { alert("저장이 완료되었습니다."); },
            error: function ()         { alert("엑셀 다운로드 중 오류가 발생했습니다."); }
        });
    });
});

/* ── Tabulator 생성 ── */
function getDataList() {
    dataTable = new Tabulator("#dataList", {
        height: "700px",
        layout: "fitColumns",
        headerHozAlign: "center",
        columnHeaderVertAlign: "middle",
        rowVertAlign: "middle",
        ajaxConfig: "POST",
        ajaxLoader: false,
        ajaxURL: "/line/quality/tusTest/list",
        ajaxParams: { t_year: $("#t_year").val() || "" },
        placeholder: "조회된 데이터가 없습니다.",
        ajaxResponse: function (url, params, response) { return response; },

        columns: [
            { title: "id",    field: "id",      visible: false },
            { title: "No",    formatter: "rownum", hozAlign: "center", width: 65, headerSort: false },
            {
                title: "연도", field: "t_year", width: 100, hozAlign: "center",
                formatter: function (cell) {
                    return '<span style="font-family:\'JetBrains Mono\',monospace;font-size:12px;">' + (cell.getValue()||"") + '</span>';
                }
            },
            {
                title: "월", field: "t_month", width: 80, hozAlign: "center",
                formatter: function (cell) {
                    return '<span style="font-family:\'JetBrains Mono\',monospace;font-size:12px;">' + (cell.getValue()||"") + '</span>';
                }
            },
            {
                title: "측정일", field: "t_day", width: 90, hozAlign: "center",
                formatter: function (cell) {
                    return '<span style="font-family:\'JetBrains Mono\',monospace;font-size:12px;">' + (cell.getValue()||"") + '</span>';
                }
            },
            {
                title: "합부", field: "t_gb", width: 120, hozAlign: "center",
                formatter: function (cell) {
                    const v = cell.getValue();
                    if (!v) return "";
                    const cls = v === "합격" ? "badge-pass" : "badge-fail";
                    return '<span class="' + cls + '">' + v + '</span>';
                }
            },
            {
                title: "첨부 파일",
                field: "t_url",
                hozAlign: "center",
                widthGrow: 1,
                formatter: function (cell) {
                    const fileName = cell.getValue();
                    if (!fileName) return "";
                    return '<a class="file-link" href="/line/download_tusTest?filename=' + encodeURIComponent(fileName) + '" target="_blank">' + fileName + '</a>';
                }
            },
            { title: "비고", field: "t_ok", widthGrow: 1, hozAlign: "center" }
        ],

        rowClick: function (e, row) {
            $("#dataList .tabulator-row").removeClass("row_select");
            row.getElement().classList.add("row_select");
            selectedRow = row;
        },

        rowDblClick: function (e, row) {
            const d = row.getData();
            $("#corrForm")[0].reset();
            $("#fileNameDisplay").text("");
            $("input[name='t_year']").val(d.t_year);
            $("input[name='t_month']").val(d.t_month);
            $("input[name='t_day']").val(d.t_day);
            $("select[name='t_gb']").val(d.t_gb);
            $("input[name='t_ok']").val(d.t_ok);
            $("input[name='t_url']").val(d.t_url);
            if (d.t_url) { $("#fileNameDisplay").text("📄 " + d.t_url); }
            $("#hiddenId").val(d.id);
            $("input[name='id']").val(d.id);
            $("#modalContainer").addClass("show");
        }
    });
}
</script>
</body>
</html>
