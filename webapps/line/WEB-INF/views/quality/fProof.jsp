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
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=IBM+Plex+Mono:wght@400;500&family=IBM+Plex+Sans+KR:wght@400;500;600&display=swap">
    <link href="/vendor/tabulator/5.6.1/tabulator.min.css" rel="stylesheet">
    <script src="/vendor/tabulator/5.6.1/tabulator.min.js"></script>
    <link rel="stylesheet" href="/line/css/opsList/ops-list.css">

    <style>
/* ===== 데모: F/PROOF — 월간 인터록 점검표 (고밀도 운영 화면) ===== */
.fp-page { height: calc(100vh - 57px); /* 헤더 56 + 아래 테두리 1 */ display: flex; flex-direction: column; gap: 16px; padding: 16px 24px 24px; }
.fp-page .ops-kpi { flex-shrink: 0; grid-template-columns: 1.4fr repeat(4, 1fr); }
.fp-page .ops-kpi .kpi-sub b { font-family: var(--ops-mono); font-weight: 500; color: var(--ops-fg2); font-variant-numeric: tabular-nums; }
.ops-head .ops-input.month-input { width: 112px; min-width: 0; text-align: left; }

.fp-card { flex: 1; min-height: 0; display: flex; flex-direction: column; }
.fp-card .ops-card-head { align-items: center; }
.fp-legend { display: flex; align-items: center; gap: 16px; font-size: 12px; color: var(--ops-fg3); }
.fp-body { flex: 1; min-height: 0; overflow: hidden; }
#dataList { height: 100%; }

/* 일자별 OK/NG: 글자만, NG 는 점 + 빨강, 오늘 열은 옅은 강조 */
.ops-table .tabulator-cell.fp-day { padding: 0 !important; text-align: center; font-family: var(--ops-mono); font-size: 12px; font-variant-numeric: tabular-nums; color: var(--ops-fg3); }
.ops-table .tabulator-col.fp-day .tabulator-col-content { padding: 6px 0 !important; }
.ops-table .tabulator-col.fp-day .tabulator-col-title { padding: 0 !important; text-align: center; font-family: var(--ops-mono); font-variant-numeric: tabular-nums; }
.ops-table .tabulator-cell.fp-day.cell-ok { color: var(--ops-ok) !important; font-weight: 500; }
.ops-table .tabulator-cell.fp-day.cell-ng { color: var(--ops-bad) !important; font-weight: 600; background: var(--ops-bad-tint); }
.ops-table .tabulator-col.fp-today { background: var(--ops-accent-tint) !important; color: var(--ops-accent) !important; box-shadow: inset 0 -2px 0 var(--ops-accent); }
.ops-table .tabulator-cell.fp-today { background: oklch(55% 0.13 255 / 0.035); }
.ops-table .tabulator-cell.fp-today.cell-ng { background: var(--ops-bad-tint); }
.ops-table .tabulator-cell.fp-text { color: var(--ops-fg2); }
.ops-table .tabulator-cell .c-lot { font-size: 12px; }

/* 행 안 업로드 버튼 / 점검방법 파일 링크 */
.img-upload-btn { height: 24px; padding: 0 8px; border: 1px solid var(--ops-line); border-radius: 4px; background: #fff; color: var(--ops-fg2);
  font-family: var(--ops-sans); font-size: 12px; cursor: pointer; transition: background-color 80ms, border-color 80ms; }
.img-upload-btn:hover { background: var(--ops-hover); border-color: oklch(86% 0.008 255); color: var(--ops-fg); }
.file-link { font-family: var(--ops-mono); font-size: 12px; color: var(--ops-accent); text-decoration: none; }
.file-link:hover { text-decoration: underline; }

/* 행 추가 모달 (#modalContainer.modal + .show 구조 유지) */
#modalContainer.modal { display: none; position: fixed; inset: 0; z-index: 9000; align-items: center; justify-content: center; background: oklch(20% 0.01 255 / 0.4); }
#modalContainer.modal.show { display: flex; }
#modalContainer .modal-content { position: relative; width: 400px; max-width: 95vw; padding: 0; background: #fff; border: 1px solid var(--ops-line); border-radius: 8px;
  box-shadow: 0 12px 32px oklch(20% 0.01 255 / 0.16); font-family: var(--ops-sans); }
#modalContainer .modal-head .modal-close { border: 0; background: transparent; }
#modalContainer .form-input { font-family: var(--ops-mono); }

/* PDF 뷰어 */
#pdfViewerModal { display: none; position: fixed; inset: 0; z-index: 9500; justify-content: center; align-items: center; background: oklch(20% 0.01 255 / 0.55); }
#pdfViewerModal .pdf-modal-inner { position: relative; display: flex; flex-direction: column; background: #fff; border: 1px solid var(--ops-line); border-radius: 8px; overflow: hidden;
  box-shadow: 0 12px 32px oklch(20% 0.01 255 / 0.2); }
#pdfViewerModal .pdf-head { display: flex; align-items: center; justify-content: space-between; height: 44px; padding: 0 8px 0 16px; border-bottom: 1px solid var(--ops-line); }
#pdfViewerModal .pdf-head h2 { margin: 0; font-size: 14px; font-weight: 600; color: var(--ops-fg); }
#pdfViewerModal .pdf-close-btn { width: 28px; height: 28px; border: 0; border-radius: 6px; background: transparent; color: var(--ops-fg2); font-size: 13px; cursor: pointer; }
#pdfViewerModal .pdf-close-btn:hover { background: var(--ops-hover); }
#pdfFrame { width: 1000px; max-width: 92vw; height: 800px; max-height: calc(92vh - 44px); border: 0; display: block; }
    </style>
</head>
<body class="ops">

<!-- ── 헤더 + 툴바 ── -->
<header class="ops-head">
  <div class="ops-head-in">
    <h1 class="ops-title">F/PROOF</h1>
    <span class="ops-label">검색 월</span>
    <input type="text" id="y_m" class="ops-input month-input monthSet month-search" placeholder="YYYY-MM">
    <button class="ops-btn primary select-button">
      <svg viewBox="0 0 24 24"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>조회
    </button>
    <span class="ops-spacer"></span>
    <button class="ops-btn" id="btnExcel">
      <svg viewBox="0 0 24 24"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/></svg>엑셀
    </button>
    <span class="ops-sep"></span>
    <button class="ops-btn danger delete-button">행 삭제</button>
    <button class="ops-btn insert-button">
      <svg viewBox="0 0 24 24"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>행 추가
    </button>
  </div>
</header>

<main class="fp-page">
  <!-- 요약 띠: 조회 결과로 계산 (표시 전용) -->
  <div class="ops-kpi">
    <div class="hero"><span class="kpi-label">NG 판정</span><span class="kpi-value" id="fpNg">—</span><span class="kpi-sub" id="fpNgSub">이번 달 점검 기록 중</span></div>
    <div><span class="kpi-label">점검 항목</span><span class="kpi-value" id="fpRows">—</span><span class="kpi-sub" id="fpRowsSub">설비 —</span></div>
    <div><span class="kpi-label">점검 일수</span><span class="kpi-value" id="fpDays">—</span><span class="kpi-sub" id="fpDaysSub">기록이 있는 날</span></div>
    <div><span class="kpi-label">OK 비율</span><span class="kpi-value" id="fpRate">—</span><span class="kpi-sub" id="fpRateSub">기록 —</span></div>
    <div><span class="kpi-label">점검방법 미등록</span><span class="kpi-value" id="fpNoDoc">—</span><span class="kpi-sub">첨부 파일 없는 항목</span></div>
  </div>

  <section class="ops-card fp-card">
    <div class="ops-card-head">
      <h2>인터록 점검표</h2>
      <div class="fp-legend">
        <span class="st ok"><i></i>OK</span>
        <span class="st bad"><i></i>NG</span>
        <span>일자 칸을 눌러 OK / NG 입력 · 저장은 즉시</span>
      </div>
    </div>
    <div class="fp-body"><div id="dataList" class="ops-table"></div></div>
  </section>
</main>


<!-- ── 행 추가 모달 ── -->
<div id="modalContainer" class="modal">
    <div class="modal-content">
        <div class="modal-head">
            <h2 class="modal-title">F/Proof 행 추가</h2>
            <button class="modal-close close" type="button" aria-label="닫기">✕</button>
        </div>
        <form id="corrForm" autocomplete="off" enctype="multipart/form-data">
            <input type="hidden" name="id" id="modalId">
            <input type="hidden" name="year" id="modalYear">
            <div class="modal-body">
                <div class="form-group">
                    <label class="form-label">년 / 월</label>
                    <input type="text" class="form-input monthSet month-modal" name="y_month" placeholder="예: 2025-07">
                </div>
            </div>
            <div class="modal-btn-row">
                <button type="button" id="closeModal" class="ops-btn">닫기</button>
                <button type="submit" id="saveCorrStatus" class="ops-btn primary">저장</button>
            </div>
        </form>
    </div>
</div>


<!-- ── PDF Viewer ── -->
<div id="pdfViewerModal">
    <div class="pdf-modal-inner">
        <div class="pdf-head">
            <h2>점검방법</h2>
            <button class="pdf-close-btn" aria-label="닫기" onclick="document.getElementById('pdfViewerModal').style.display='none';">✕</button>
        </div>
        <iframe id="pdfFrame"></iframe>
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
    const today = fpTodayCol();
    for (let i = 1; i <= 31; i++) {
        dayColumns.push({
            title: String(i),
            field: "m_" + i,
            hozAlign: "center",
            width: 32,
            minWidth: 28,
            cssClass: "fp-day" + (i === today ? " fp-today" : ""),
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
        { title: "#",       formatter: "rownum", width: 44, hozAlign: "right", frozen: true, cssClass: "c-time" },
        { title: "년/월",   field: "y_m", visible: false,      width: 110, hozAlign: "center", frozen: true,
          formatter: function(cell){ return `<span class="c-time">${cell.getValue()||""}</span>`; }
        },
        { title: "설비",    field: "mch_name", width: 96, frozen: true, editor: "input" },
        { title: "규격",    field: "standard", width: 112, frozen: true, editor: "input", cssClass: "c-time", tooltip: true },
        { title: "점검항목",field: "up_down",  width: 140, frozen: true, editor: "input", tooltip: true },
        {
            title: "이미지",
            width: 72,
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
            width: 180,
            tooltip: true,
            formatter: function (cell) {
                const fn = cell.getValue();
                if (!fn) return '<span class="c-none">—</span>';
                return '<a class="file-link" href="javascript:void(0);" onclick="openPdf(\'' + encodeURIComponent(fn) + '\')">' + fn + '</a>';
            }
        },
        { title: "이상 시 조치내용",field: "memo_f",  width: 180,  editor: "input", tooltip: true, cssClass: "fp-text" },
       
        ...dayColumns
    ];

    dataTable = new Tabulator("#dataList", {
        height: "100%",
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

    // 데모: 요약 띠 갱신 (표시 전용) + 창 크기 변경 시 표 높이 다시 맞춤
    dataTable.on("dataProcessed", fpKpi);
    dataTable.on("dataChanged", fpKpi);
    window.addEventListener("resize", function () { dataTable.redraw(); });
}

/* ── 데모: 오늘 열 (조회 월이 이번 달일 때만) ── */
function fpTodayCol() {
    const now = new Date();
    const ym = now.getFullYear() + "-" + String(now.getMonth() + 1).padStart(2, "0");
    return $("#y_m").val() === ym ? now.getDate() : 0;
}

/* ── 데모: 요약 띠 — NG / 점검 항목 / 점검 일수 / OK 비율 / 점검방법 미등록 ── */
function fpKpi() {
    const rows = dataTable ? dataTable.getData() : [];
    let ok = 0, ng = 0, ngRows = 0, noDoc = 0;
    const days = new Set(), mch = new Set();
    rows.forEach(function (r) {
        let rowNg = false;
        for (let i = 1; i <= 31; i++) {
            const v = r["m_" + i];
            if (v === "OK") { ok++; days.add(i); }
            else if (v === "NG") { ng++; rowNg = true; days.add(i); }
        }
        if (rowNg) ngRows++;
        if (!r.img_url) noDoc++;
        if (r.mch_name) mch.add(r.mch_name);
    });
    const ym = ($("#y_m").val() || "").split("-");
    const last = ym.length === 2 ? new Date(+ym[0], +ym[1], 0).getDate() : 31;
    const total = ok + ng;

    $("#fpNg").text(ng).toggleClass("bad", ng > 0);
    $("#fpNgSub").html(ng > 0 ? "NG 항목 <b>" + ngRows + "</b>개" : "이번 달 NG 없음");
    $("#fpRows").text(rows.length);
    $("#fpRowsSub").html("설비 <b>" + mch.size + "</b>종");
    $("#fpDays").html(days.size + '<span class="muted" style="font-size:14px">/' + last + "</span>");
    $("#fpRate").text(total ? (ok / total * 100).toFixed(1) + "%" : "—");
    $("#fpRateSub").html("기록 <b>" + total + "</b>칸");
    $("#fpNoDoc").text(noDoc).toggleClass("bad", noDoc > 0);
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
