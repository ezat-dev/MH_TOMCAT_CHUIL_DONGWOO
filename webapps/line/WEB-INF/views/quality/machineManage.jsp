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
    <link href="/vendor/tabulator/5.6.1/tabulator.min.css" rel="stylesheet">
    <script src="/vendor/tabulator/5.6.1/tabulator.min.js"></script>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=IBM+Plex+Mono:wght@400;500&family=IBM+Plex+Sans+KR:wght@400;500;600&display=swap">
    <link rel="stylesheet" href="/line/css/opsList/ops-list.css">

    <style>
    /* ===== 데모: 설비 보전관리 — 고밀도 운영 화면 (공통: ops-list.css) ===== */
    html, body.ops { height: 100%; }
    body.ops { display: flex; flex-direction: column; min-height: 0; overflow: hidden; }
    .ops-page.mm { flex: 1; min-height: 0; }
    .mm .ops-kpi { grid-template-columns: 1.4fr repeat(3, 1fr); }
    .mm .ops-card { flex: 1; min-height: 0; display: flex; flex-direction: column; }
    .mm #dataTable { flex: 1; min-height: 0; }
    .ops-head .range-sep { color: var(--ops-fg3); }
    .ops-head .ops-input { width: 128px; min-width: 0; text-align: center; }

    /* 표: 한 줄 고정, 상세내용은 말줄임 + 툴팁 */
    .mm .tabulator-cell .c-desc { color: var(--ops-fg2); }
    .mm .tabulator-cell .c-title { font-weight: 500; }

    /* 모달 (기존 .modal / .show 토글 유지) */
    .modal { display: none; position: fixed; inset: 0; z-index: 9000; align-items: center; justify-content: center; background: oklch(20% 0.01 255 / 0.4); }
    .modal.show { display: flex; }
    .modal .modal-content {
      width: 640px; max-width: 95vw; max-height: 90vh; display: flex; flex-direction: column;
      background: #fff; border: 1px solid var(--ops-line); border-radius: 8px; box-shadow: 0 12px 32px oklch(20% 0.01 255 / 0.16);
      font-family: var(--ops-sans);
    }
    .modal #corrForm { display: flex; flex-direction: column; min-height: 0; flex: 1; }
    .modal .modal-body { overflow-y: auto; min-height: 0; }
    .modal .modal-close { border: 0; background: transparent; font-family: var(--ops-sans); }
    .modal .form-grid { grid-template-columns: 160px 1fr; }
    .modal .form-textarea {
      width: 100%; min-height: 200px; padding: 8px; resize: vertical; outline: none;
      border: 1px solid var(--ops-line); border-radius: 6px; background: #fff; color: var(--ops-fg);
      font-family: var(--ops-sans); font-size: 13px; line-height: 1.6;
    }
    .modal .form-textarea:focus { border-color: var(--ops-accent); box-shadow: 0 0 0 2px var(--ops-accent-tint); }
    .modal .form-input::placeholder, .modal .form-textarea::placeholder { color: var(--ops-fg3); }
    </style>
</head>
<body class="ops">

<!-- ===== 헤더 + 툴바 ===== -->
<header class="ops-head">
  <div class="ops-head-in">
    <h1 class="ops-title">설비 보전관리</h1>
    <span class="ops-label">등록일자</span>
    <input type="text" id="m_sdate" class="ops-input date-input" autocomplete="off">
    <span class="range-sep">~</span>
    <input type="text" id="m_edate" class="ops-input date-input" autocomplete="off">
    <button class="ops-btn primary select-button">
      <svg viewBox="0 0 24 24"><circle cx="11" cy="11" r="7"/><line x1="21" y1="21" x2="16.5" y2="16.5"/></svg>
      조회
    </button>
    <span class="ops-sep"></span>
    <button class="ops-btn insert-button">
      <svg viewBox="0 0 24 24"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
      추가
    </button>
    <button class="ops-btn danger delete-button">
      <svg viewBox="0 0 24 24"><polyline points="3 6 5 6 21 6"/><path d="M19 6l-1 14a2 2 0 0 1-2 2H8a2 2 0 0 1-2-2L5 6"/></svg>
      삭제
    </button>
    <span class="ops-spacer"></span>
    <button class="ops-btn excel-button">
      <svg viewBox="0 0 24 24"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/></svg>
      엑셀
    </button>
  </div>
</header>

<main class="ops-page mm">

  <!-- 요약: 조회 기간 보전 이력 건수가 첫 시선 -->
  <section class="ops-kpi" aria-label="요약">
    <div class="hero">
      <span class="kpi-label">보전 이력</span>
      <span class="kpi-value" id="mmTotal">—</span>
      <span class="kpi-sub" id="mmRange">조회 기간</span>
    </div>
    <div>
      <span class="kpi-label">최근 30일</span>
      <span class="kpi-value" id="mm30">—</span>
      <span class="kpi-sub">건</span>
    </div>
    <div>
      <span class="kpi-label">이번 달</span>
      <span class="kpi-value" id="mmMonth">—</span>
      <span class="kpi-sub">건</span>
    </div>
    <div>
      <span class="kpi-label">최근 보전</span>
      <span class="kpi-value" id="mmLast">—</span>
      <span class="kpi-sub" id="mmLastSub">&nbsp;</span>
    </div>
  </section>

  <section class="ops-card">
    <div class="ops-card-head">
      <h2>보전 이력</h2>
      <span class="note">행 클릭 → 선택 · 더블클릭 → 수정</span>
    </div>
    <div id="dataTable" class="ops-table"></div>
  </section>
</main>


<!-- ── 등록/수정 모달 ── -->
<div id="modalContainer" class="modal">
  <div class="modal-content" role="dialog" aria-labelledby="mmModalTitle">
    <div class="modal-head">
      <h2 id="mmModalTitle">설비 보전항목 등록</h2>
      <button class="modal-close close" type="button" aria-label="닫기">✕</button>
    </div>

    <form id="corrForm" autocomplete="off">
      <input type="text" name="m_idx" value="0" style="display:none;">
      <div class="modal-body">
        <div class="form-grid">
          <div class="form-group">
            <label class="form-label">등록일</label>
            <input type="text" name="m_date" class="form-input mono daySet" placeholder="YYYY-MM-DD">
          </div>
          <div class="form-group">
            <label class="form-label">보전항목</label>
            <input type="text" name="m_title" class="form-input" placeholder="보전항목을 입력하세요">
          </div>
          <div class="form-group full">
            <label class="form-label">상세내용</label>
            <textarea name="m_desc" class="form-textarea" rows="10" placeholder="상세 내용을 입력하세요"></textarea>
          </div>
        </div>
      </div>
      <div class="modal-btn-row">
        <button type="button" id="closeModal" class="ops-btn">닫기</button>
        <button type="submit" id="saveCorrStatus" class="ops-btn primary">저장</button>
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
        height: '100%',
        layout: 'fitColumns',
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
                    return '<span class="c-time">' + (cell.getValue() || "") + '</span>';
                }
            },
            {
                title: "보전항목", field: "m_title", width: 380, hozAlign: "left",
                formatter: function (cell) {
                    cell.getElement().title = cell.getValue() || "";
                    return '<span class="c-title">' + (cell.getValue() || "") + '</span>';
                }
            },
            {
                title: "상세내용", field: "m_desc", widthGrow: 1, hozAlign: "left",
                formatter: function (cell) {
                    const v = cell.getValue() || "";
                    cell.getElement().title = v;
                    return '<span class="c-desc">' + v + '</span>';
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
    dataTable.on("dataLoaded", mmSummary);
}

/* ── 요약 스트립 (표시 전용) ── */
function mmSummary(rows) {
    rows = rows || [];
    var today = todayDate(), month = today.slice(0, 7);
    var d30 = new Date(); d30.setDate(d30.getDate() - 30);
    var from30 = d30.getFullYear() + "-" + String(d30.getMonth() + 1).padStart(2, '0') + "-" + String(d30.getDate()).padStart(2, '0');
    var n30 = 0, nMonth = 0, last = "";
    rows.forEach(function (r) {
        var d = String(r.m_date || "").slice(0, 10);
        if (d >= from30 && d <= today) n30++;
        if (d.slice(0, 7) === month) nMonth++;
        if (d > last) last = d;
    });
    $("#mmTotal").text(rows.length);
    $("#mmRange").text($("#m_sdate").val() + " ~ " + $("#m_edate").val());
    $("#mm30").text(n30);
    $("#mmMonth").text(nMonth);
    $("#mmLast").text(last || "—");
    var days = last ? Math.round((new Date(today) - new Date(last)) / 86400000) : null;
    $("#mmLastSub").text(days == null ? "" : days === 0 ? "오늘" : days + "일 전");
}
</script>
</body>
</html>
