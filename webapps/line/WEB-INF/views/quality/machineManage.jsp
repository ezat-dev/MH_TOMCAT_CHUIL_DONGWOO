<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="ko">
<head>
<script src="/line/mock/mock-loader.js"></script>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>설비 보전관리</title>
    <%@include file="../include/pluginpage.jsp" %>
    <jsp:include page="../include/tabBar.jsp"/>
    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;600;700&family=JetBrains+Mono:wght@400;500&display=swap" rel="stylesheet">
    <link href="/vendor/tabulator/5.6.1/tabulator.min.css" rel="stylesheet">
    <script src="/vendor/tabulator/5.6.1/tabulator.min.js"></script>

    <style>
        /* ── Variables ── */
        :root {
            --bg:            #f8f9fb;
            --surface:       #ffffff;
            --surface2:      #f1f4f8;
            --border:        #e2e7ef;
            --border-light:  #edf0f5;
            --accent:        #2563eb;
            --accent-light:  #eff4ff;
            --accent-hover:  #1d4ed8;
            --text-primary:  #1a202c;
            --text-secondary:#4a5568;
            --text-muted:    #9aa5b4;
            --success:       #059669;
            --success-bg:    #ecfdf5;
            --success-border:#a7f3d0;
            --danger:        #dc2626;
            --danger-bg:     #fff5f5;
            --danger-border: #fecaca;
            --radius-sm:     6px;
            --radius:        10px;
            --radius-lg:     14px;
            --shadow-sm:     0 1px 3px rgba(0,0,0,0.06), 0 1px 2px rgba(0,0,0,0.04);
            --shadow-lg:     0 8px 30px rgba(0,0,0,0.14);
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
        .page-title       { font-size: 18px; font-weight: 700; letter-spacing: -.3px; }
        .page-breadcrumb  { font-size: 12px; color: var(--text-muted); margin-top: 2px; }

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
        .toolbar-left  { display: flex; align-items: center; gap: 10px; flex-wrap: wrap; }
        .toolbar-right { display: flex; align-items: center; gap: 8px; }

        .field-group  { display: flex; align-items: center; gap: 8px; }
        .field-label  {
            font-size: 13px; font-weight: 600;
            color: var(--text-secondary); white-space: nowrap;
        }
        .date-input {
            font-family: 'JetBrains Mono', monospace;
            font-size: 13px;
            background: var(--surface2);
            border: 1px solid var(--border);
            border-radius: var(--radius-sm);
            color: var(--text-primary);
            padding: 7px 11px;
            width: 128px;
            outline: none;
            text-align: center;
            transition: border-color .2s, box-shadow .2s;
        }
        .date-input:focus {
            border-color: var(--accent);
            box-shadow: 0 0 0 3px rgba(37,99,235,0.12);
        }
        .range-sep {
            font-size: 14px; color: var(--text-muted); font-weight: 500;
        }

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

        .btn-success-outline {
            background: var(--surface); color: var(--success); border-color: var(--success-border);
        }
        .btn-success-outline:hover { background: var(--success-bg); border-color: var(--success); }

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
            padding: 10px 14px !important;
        }
        .tabulator .tabulator-footer {
            background: var(--surface2) !important;
            border-top: 1px solid var(--border) !important;
        }

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
            width: 480px; max-width: 95vw;
            max-height: 90vh; overflow-y: auto;
            border-radius: var(--radius-lg);
            box-shadow: var(--shadow-lg);
            padding: 28px 28px 22px;
            position: relative;
            animation: popIn .3s cubic-bezier(.34,1.56,.64,1) both;
        }
        .modal-header {
            display: flex; align-items: center; gap: 10px;
            margin-bottom: 20px;
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

        .form-group { margin-bottom: 14px; }
        .form-label {
            display: block; font-size: 12px; font-weight: 600;
            color: var(--text-secondary); margin-bottom: 5px; letter-spacing: .2px;
        }
        .form-input, .form-textarea {
            width: 100%;
            font-family: 'Noto Sans KR', sans-serif;
            font-size: 13px;
            padding: 9px 11px;
            border: 1px solid var(--border);
            border-radius: var(--radius-sm);
            outline: none; color: var(--text-primary);
            background: var(--surface2);
            transition: border-color .2s, box-shadow .2s;
            resize: vertical;
        }
        .form-input:focus, .form-textarea:focus {
            border-color: var(--accent);
            box-shadow: 0 0 0 3px rgba(37,99,235,0.12);
            background: #fff;
        }
        .form-input::placeholder,
        .form-textarea::placeholder { color: var(--text-muted); }

        .form-divider { border: none; border-top: 1px solid var(--border-light); margin: 12px 0 16px; }

        .modal-actions { display: flex; gap: 8px; margin-top: 18px; }
        .modal-actions .btn { flex: 1; justify-content: center; }

        /* ── desc cell ── */
        .desc-cell {
            color: var(--text-secondary) !important;
            font-size: 12.5px !important;
            line-height: 1.5 !important;
        }

        /* ── Animations ── */
        @keyframes fadeIn    { from { opacity:0 } to { opacity:1 } }
        @keyframes slideDown {
            from { opacity:0; transform:translateY(-8px); }
            to   { opacity:1; transform:translateY(0); }
        }
        @keyframes popIn {
            from { opacity:0; transform:scale(.92); }
            to   { opacity:1; transform:scale(1); }
        }
    </style>
</head>
<body>
<main class="main">

    <!-- ── Page Header ── -->
    <div class="page-header">
        <div class="header-icon">
            <svg viewBox="0 0 24 24">
                <path d="M14.7 6.3a1 1 0 0 0 0 1.4l1.6 1.6a1 1 0 0 0 1.4 0l3.77-3.77a6 6 0 0 1-7.94 7.94l-6.91 6.91a2.12 2.12 0 0 1-3-3l6.91-6.91a6 6 0 0 1 7.94-7.94l-3.76 3.76z"/>
            </svg>
        </div>
        <div>
            <div class="page-title">설비 보전관리</div>
            <div class="page-breadcrumb">설비관리 · 보전항목 등록 및 이력 조회</div>
        </div>
    </div>

    <!-- ── Toolbar ── -->
    <div class="toolbar-card">
        <div class="toolbar-left">
            <div class="field-group">
                <span class="field-label">등록일자</span>
                <input type="text" id="m_sdate" class="date-input">
                <span class="range-sep">~</span>
                <input type="text" id="m_edate" class="date-input">
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
        <div class="toolbar-right">
            <button class="btn btn-success-outline excel-button">
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


<!-- ── 등록/수정 모달 ── -->
<div id="modalContainer" class="modal">
    <div class="modal-content">
        <button class="modal-close close" type="button">✕</button>
        <div class="modal-header">
            <div class="modal-header-icon">
                <svg viewBox="0 0 24 24">
                    <path d="M14.7 6.3a1 1 0 0 0 0 1.4l1.6 1.6a1 1 0 0 0 1.4 0l3.77-3.77a6 6 0 0 1-7.94 7.94l-6.91 6.91a2.12 2.12 0 0 1-3-3l6.91-6.91a6 6 0 0 1 7.94-7.94l-3.76 3.76z"/>
                </svg>
            </div>
            <div class="modal-title">설비 보전항목 등록</div>
        </div>

        <form id="corrForm" autocomplete="off">
            <input type="text" name="m_idx" value="0" style="display:none;">

            <div class="form-group">
                <label class="form-label">등록일</label>
                <input type="text" name="m_date" class="form-input daySet" placeholder="YYYY-MM-DD">
            </div>

            <div class="form-group">
                <label class="form-label">보전항목</label>
                <input type="text" name="m_title" class="form-input" placeholder="보전항목을 입력하세요">
            </div>

            <hr class="form-divider">

            <div class="form-group">
                <label class="form-label">상세내용</label>
                <textarea name="m_desc" class="form-textarea" rows="8" placeholder="상세 내용을 입력하세요…"></textarea>
            </div>

            <div class="modal-actions">
                <button type="submit" id="saveCorrStatus" class="btn btn-primary">저장</button>
                <button type="button" id="closeModal" class="btn btn-outline">닫기</button>
            </div>
        </form>
    </div>
</div>


<script>
let now_page_code = "f03";
var dataTable;
var selectedRowData = null;

/* ── 날짜 유틸 ── */
function todayDate() {
    const d = new Date();
    return d.getFullYear() + "-" +
        String(d.getMonth() + 1).padStart(2, '0') + "-" +
        String(d.getDate()).padStart(2, '0');
}
function twoYearsAgoDate() {
    const d = new Date();
    d.setFullYear(d.getFullYear() - 2);
    return d.getFullYear() + "-" +
        String(d.getMonth() + 1).padStart(2, '0') + "-" +
        String(d.getDate()).padStart(2, '0');
}

/* ── 초기화 ── */
document.addEventListener("DOMContentLoaded", function () {
    document.getElementById("m_sdate").value = twoYearsAgoDate();
    document.getElementById("m_edate").value = todayDate();
    getHeatList();
    getMachineManageList();
});

/* ── 조회 ── */
$('.select-button').click(function () {
    getMachineManageList();
});

/* ── 추가 버튼 ── */
$('.insert-button').click(function () {
    selectedRowData = null;
    $('#corrForm')[0].reset();
    $("input[name='m_idx']").val("0");
    $("input[name='m_date']").val(todayDate());
    $('#modalContainer').addClass('show');
});

/* ── 삭제 ── */
$('.delete-button').click(function () {
    if (!selectedRowData) { alert('삭제할 행을 먼저 클릭해 주세요.'); return; }
    if (!confirm('선택된 항목을 정말 삭제하시겠습니까?')) return;
    $.ajax({
        url: "/line/quality/machineManage/delete",
        type: "POST",
        dataType: "json",
        data: { "m_idx": selectedRowData.m_idx },
        success: function (res) {
            alert('삭제되었습니다.');
            getMachineManageList();
            selectedRowData = null;
        },
        error: function () { alert('삭제 중 오류가 발생했습니다.'); }
    });
});

/* ── 모달 닫기 ── */
$('.close, #closeModal').click(function () {
    $('#corrForm')[0].reset();
    $('#modalContainer').removeClass('show');
});

/* ── 저장 ── */
$('#saveCorrStatus').click(function (event) {
    event.preventDefault();
    var formData = new FormData($('#corrForm')[0]);
    $.ajax({
        url: "/line/quality/machineManage/save",
        type: "POST",
        data: formData,
        processData: false,
        contentType: false,
        success: function (result) {
            alert("저장되었습니다!");
            $('#modalContainer').removeClass('show');
            getMachineManageList();
            selectedRowData = null;
        },
        error: function () { alert('저장 중 오류가 발생했습니다.'); }
    });
});

/* ── 엑셀 다운로드 ── */
$('.excel-button').on('click', function () {
    if (!dataTable) return;
    const sdate = $("#m_sdate").val();
    const edate = $("#m_edate").val();
    dataTable.download("xlsx", "설비보전항목_" + sdate + "_" + edate + ".xlsx", {
        sheetName: "MachineManage",
        documentProcessing: function (wb) {
            const sheet = wb.Sheets["MachineManage"];
            sheet["!cols"] = [{ wch: 14 }, { wch: 40 }, { wch: 100 }];
            return wb;
        }
    });
});

/* ── 데이터 로드 ── */
function getMachineManageList() {
    $.ajax({
        url: "/line/quality/machineManage/list",
        type: "post",
        dataType: "json",
        data: { "m_sdate": $("#m_sdate").val(), "m_edate": $("#m_edate").val() },
        success: function (result) { dataTable.setData(result.data); }
    });
}

/* ── Tabulator 초기화 ── */
function getHeatList() {
    dataTable = new Tabulator('#dataTable', {
        height: '700px',
        layout: 'fitDataFill',
        headerSort: false,
        reactiveData: true,
        columnHeaderVertAlign: "middle",
        rowVertAlign: "middle",
        headerHozAlign: 'center',
        renderHorizontal: "virtual",
        placeholder: "조회된 데이터가 없습니다.",
        columns: [
            { title: "no", field: "m_idx", visible: false },
            {
                title: "등록일자", field: "m_date", width: 130, hozAlign: "center",
                formatter: function (cell) {
                    return '<span style="font-family:\'JetBrains Mono\',monospace;font-size:12px;">' + (cell.getValue() || "") + '</span>';
                }
            },
            { title: "보전항목", field: "m_title", width: 380, hozAlign: "left" },
            {
                title: "상세내용", field: "m_desc", widthGrow: 1, hozAlign: "left",
                formatter: function (cell) {
                    const v = cell.getValue() || "";
                    return '<span class="desc-cell">' + v + '</span>';
                }
            },
        ],
        rowClick: function (e, row) {
            $('#dataTable .tabulator-row').removeClass('row_select');
            row.getElement().classList.add('row_select');
            selectedRowData = row.getData();
        },
        rowDblClick: function (e, row) {
            var d = row.getData();
            selectedRowData = d;
            $('#corrForm')[0].reset();
            $('input[name="m_idx"]').val(d.m_idx);
            $('input[name="m_date"]').val(d.m_date);
            $('input[name="m_title"]').val(d.m_title);
            $('textarea[name="m_desc"]').val(d.m_desc);
            $('#modalContainer').addClass('show');
        }
    });
}
</script>
</body>
</html>
