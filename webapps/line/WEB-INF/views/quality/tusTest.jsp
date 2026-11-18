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
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=IBM+Plex+Mono:wght@400;500&family=IBM+Plex+Sans+KR:wght@400;500;600&display=swap">
    <link href="/vendor/tabulator/5.6.1/tabulator.min.css" rel="stylesheet">
    <script src="/vendor/tabulator/5.6.1/tabulator.min.js"></script>
    <link rel="stylesheet" href="/line/css/opsList/ops-list.css">

    <style>
/* ===== 데모: 온도균일성 조사보고서 — 고밀도 운영 화면 (ops-list.css 공통 + 페이지 전용) ===== */
/* 화면 높이에 맞춤: 페이지는 스크롤 없이, 표 안에서만 스크롤 */
html, body.ops { height: 100%; }
body.ops { display: flex; flex-direction: column; overflow: hidden; min-height: 0; }
body.ops .ops-page { flex: 1; min-height: 0; }
.tus-card { flex: 1; min-height: 0; display: flex; flex-direction: column; }
.tus-card #dataList { flex: 1; min-height: 0; }

.ops-title small { margin-left: 8px; font-size: 12px; font-weight: 400; color: var(--ops-fg3); }
#t_year { width: 88px; min-width: 0; text-align: right; }

/* 지표: 최근 판정이 첫 시선 */
.tus-kpi { grid-template-columns: 1.4fr repeat(4, 1fr); }
.tus-kpi .kpi-value.ok { color: var(--ops-ok); }
.tus-kpi .kpi-value .st { font-family: var(--ops-sans); font-size: inherit; gap: 8px; }
.tus-kpi .kpi-value .st i { width: 8px; height: 8px; }

/* 표 셀 */
.ops-table .tabulator-col-title { text-align: left; }
.ops-table .tabulator-col.ta-r .tabulator-col-title { text-align: right; }
.ops-table .tabulator-col.ta-c .tabulator-col-title { text-align: center; }
.ops .file-link { display: inline-flex; align-items: center; gap: 6px; color: var(--ops-accent); font-family: var(--ops-mono); font-size: 12px; text-decoration: none; }
.ops .file-link:hover { text-decoration: underline; }
.ops .file-link b { font-family: var(--ops-sans); font-size: 11px; font-weight: 500; color: var(--ops-fg3); border: 1px solid var(--ops-line); border-radius: 4px; padding: 0 4px; line-height: 16px; }
.ops .c-note { color: var(--ops-fg2); }
.ops .c-note .mono { color: var(--ops-fg); }

/* 모달: 제목줄·버튼줄 고정, 본문만 스크롤 */
#modalContainer.modal { display: none; position: fixed; inset: 0; z-index: 9000; align-items: center; justify-content: center; background: oklch(20% 0.01 255 / 0.4); }
#modalContainer.modal.show { display: flex; }
#modalContainer .modal-content {
  width: 560px; max-width: 95vw; max-height: 90vh; display: flex; flex-direction: column; overflow: hidden;
  background: #fff; border: 1px solid var(--ops-line); border-radius: 8px; box-shadow: 0 12px 32px oklch(20% 0.01 255 / 0.16); font-family: var(--ops-sans);
}
#modalContainer .modal-close { border: 0; background: transparent; }
#corrForm { flex: 1; min-height: 0; display: flex; flex-direction: column; }
#corrForm .modal-body { flex: 1; min-height: 0; overflow-y: auto; }
.tus-date { display: grid; grid-template-columns: 1.4fr 1fr 1fr; gap: 8px; }
.tus-date .form-input { font-family: var(--ops-mono); text-align: right; }
.file-upload-wrap { position: relative; display: flex; align-items: center; gap: 8px; height: 32px; padding: 0 8px; border: 1px dashed var(--ops-line); border-radius: 6px; background: #fff; cursor: pointer; }
.file-upload-wrap:hover { border-color: var(--ops-accent); background: var(--ops-hover); }
.file-upload-wrap input[type="file"] { position: absolute; inset: 0; opacity: 0; cursor: pointer; width: 100%; }
.file-upload-label { font-size: 12px; color: var(--ops-fg2); pointer-events: none; white-space: nowrap; }
#fileNameDisplay { pointer-events: none; font-family: var(--ops-mono); font-size: 12px; color: var(--ops-fg); white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
.form-hint { font-size: 12px; color: var(--ops-fg3); }
    </style>
</head>
<body class="ops">

<!-- ── 헤더 + 툴바 ── -->
<header class="ops-head">
  <div class="ops-head-in">
    <h1 class="ops-title">온도균일성 조사보고서<small>품질관리 · TUS 이력</small></h1>
    <span class="ops-label">검색 연도</span>
    <input type="text" id="t_year" class="ops-input yearSet" placeholder="YYYY">
    <button class="ops-btn select-button">
      <svg viewBox="0 0 24 24"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
      조회
    </button>
    <span class="ops-spacer"></span>
    <button class="ops-btn danger delete-button">삭제</button>
    <button class="ops-btn primary insert-button">
      <svg viewBox="0 0 24 24"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
      조사 등록
    </button>
  </div>
</header>

<main class="ops-page">

  <!-- ── 지표: 조회 결과로 계산해 표시만 ── -->
  <section class="ops-kpi tus-kpi" aria-label="조사 요약">
    <div class="hero">
      <span class="kpi-label">최근 조사 판정</span>
      <span class="kpi-value" id="kLast">—</span>
      <span class="kpi-sub mono" id="kLastSub">—</span>
    </div>
    <div>
      <span class="kpi-label">조사 건수</span>
      <span class="kpi-value" id="kCnt">—</span>
      <span class="kpi-sub" id="kCntSub">검색 연도 기준</span>
    </div>
    <div>
      <span class="kpi-label">불합격</span>
      <span class="kpi-value" id="kFail">—</span>
      <span class="kpi-sub" id="kFailSub">—</span>
    </div>
    <div>
      <span class="kpi-label">최대 편차</span>
      <span class="kpi-value" id="kDev">—</span>
      <span class="kpi-sub">비고 기재값 기준</span>
    </div>
    <div>
      <span class="kpi-label">첨부 누락</span>
      <span class="kpi-value" id="kNoFile">—</span>
      <span class="kpi-sub">보고서 PDF 미등록</span>
    </div>
  </section>

  <!-- ── 표 ── -->
  <section class="ops-card tus-card">
    <div class="ops-card-head">
      <h2>조사 이력</h2>
      <span class="note">행 클릭 = 선택 · 더블클릭 = 수정 · 파일명 클릭 = 보고서 열기</span>
    </div>
    <div id="dataList" class="ops-table"></div>
  </section>
</main>


<!-- ── 등록/수정 모달 ── -->
<div id="modalContainer" class="modal">
    <div class="modal-content" role="dialog" aria-modal="true" aria-labelledby="tusModalTitle">
        <div class="modal-head">
            <h2 id="tusModalTitle">온도균일성 조사 등록</h2>
            <button class="modal-close close" type="button" aria-label="닫기">✕</button>
        </div>

        <form id="corrForm" autocomplete="off" enctype="multipart/form-data">
            <input type="hidden" name="id" id="hiddenId">

            <div class="modal-body">
              <div class="form-grid">
                <div class="form-group">
                    <label class="form-label">발생 설비</label>
                    <select name="mch_name" class="form-select">
                        <option value="소려로 소입로">소려로 소입로</option>
                    </select>
                </div>

                <div class="form-group">
                    <label class="form-label">합격 / 불합격</label>
                    <select name="t_gb" class="form-select">
                        <option value="합격">합격</option>
                        <option value="불합격">불합격</option>
                    </select>
                </div>

                <div class="form-group full">
                    <label class="form-label">측정일 (연도 · 월 · 일)</label>
                    <div class="tus-date">
                        <input type="text" name="t_year" class="form-input yearSet" placeholder="YYYY" aria-label="연도">
                        <input type="text" name="t_month" class="form-input monthSet" placeholder="MM" aria-label="발생 월">
                        <input type="text" name="t_day" class="form-input daySet" placeholder="DD" aria-label="측정일">
                    </div>
                </div>

                <div class="form-group full">
                    <label class="form-label">기준서 (PDF)</label>
                    <div class="file-upload-wrap">
                        <input type="file" id="fileInput" name="uploadFile" accept="application/pdf">
                        <label class="file-upload-label" for="fileInput">PDF 선택</label>
                        <div id="fileNameDisplay"></div>
                    </div>
                </div>

                <div class="form-group">
                    <label class="form-label">파일 이름</label>
                    <input type="text" name="t_url" id="fileName" class="form-input mono" placeholder="파일 선택 시 자동 입력">
                </div>

                <div class="form-group">
                    <label class="form-label">비고</label>
                    <input type="text" name="t_ok" class="form-input" placeholder="예: 소입로 860℃ · 9점 · 최대편차 +4.0 / -1.7℃">
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
            display.textContent = file.name;
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

/* ── 데모: 조회 결과로 상단 지표 계산 (표시 전용) ── */
function tusSummary(rows) {
    rows = Array.isArray(rows) ? rows : [];
    var fail = rows.filter(function (r) { return r.t_gb && r.t_gb !== "합격"; });
    var noFile = rows.filter(function (r) { return !r.t_url; }).length;
    var last = rows.slice().sort(function (a, b) {
        return String(b.t_year + b.t_month + b.t_day).localeCompare(String(a.t_year + a.t_month + a.t_day));
    })[0];
    // 비고의 "최대편차 +4.0 / -1.7" 에서 절댓값이 가장 큰 값
    var dev = null, devRow = null;
    rows.forEach(function (r) {
        var m = /최대\s*편차\s*([+\-−]?\d+(?:\.\d+)?)\s*\/\s*([+\-−]?\d+(?:\.\d+)?)/.exec(r.t_ok || "");
        if (!m) return;
        [m[1], m[2]].forEach(function (s) {
            var v = parseFloat(s.replace("−", "-"));
            if (!isNaN(v) && (dev == null || Math.abs(v) > Math.abs(dev))) { dev = v; devRow = r; }
        });
    });

    if (last) {
        var ok = last.t_gb === "합격";
        $("#kLast").html('<span class="st ' + (ok ? "ok" : "bad") + '"><i></i>' + (last.t_gb || "—") + "</span>");
        $("#kLastSub").text(last.t_year + "-" + last.t_month + "-" + last.t_day);
    } else {
        $("#kLast").text("—"); $("#kLastSub").text("조사 이력 없음");
    }
    $("#kCnt").text(rows.length);
    $("#kCntSub").text(($("#t_year").val() || "전체") + "년 · 합격 " + (rows.length - fail.length));
    $("#kFail").text(fail.length).toggleClass("bad", fail.length > 0);
    $("#kFailSub").text(fail.length ? "최근 " + fail[0].t_year + "-" + fail[0].t_month + "-" + fail[0].t_day : "없음");
    $("#kDev").html(dev == null ? "—" : (dev > 0 ? "+" : dev < 0 ? "−" : "") + Math.abs(dev).toFixed(1) + '<small class="muted" style="font-size:13px"> ℃</small>')
        .toggleClass("bad", !!devRow && devRow.t_gb !== "합격");
    $("#kNoFile").text(noFile).toggleClass("bad", noFile > 0);
}

/* ── Tabulator 생성 ── */
function getDataList() {
    dataTable = new Tabulator("#dataList", {
        height: "100%",
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
            { title: "#",     formatter: "rownum", hozAlign: "right", cssClass: "ta-r", width: 56, headerSort: false },
            {
                title: "연도", field: "t_year", width: 88, hozAlign: "right", cssClass: "ta-r",
                formatter: function (cell) { return '<span class="c-num">' + (cell.getValue()||"") + '</span>'; }
            },
            {
                title: "월", field: "t_month", width: 64, hozAlign: "right", cssClass: "ta-r",
                formatter: function (cell) { return '<span class="c-num">' + (cell.getValue()||"") + '</span>'; }
            },
            {
                title: "측정일", field: "t_day", width: 76, hozAlign: "right", cssClass: "ta-r",
                formatter: function (cell) { return '<span class="c-num">' + (cell.getValue()||"") + '</span>'; }
            },
            {
                title: "합부", field: "t_gb", width: 104, hozAlign: "left",
                formatter: function (cell) {
                    const v = cell.getValue();
                    if (!v) return '<span class="c-none">—</span>';
                    return '<span class="st ' + (v === "합격" ? "ok" : "bad") + '" style="font-family:var(--ops-sans)"><i></i>' + v + '</span>';
                }
            },
            {
                title: "보고서 파일",
                field: "t_url",
                hozAlign: "left",
                width: 360,
                formatter: function (cell) {
                    const fileName = cell.getValue();
                    if (!fileName) return '<span class="c-none">—</span>';
                    cell.getElement().title = fileName;
                    return '<a class="file-link" href="/line/download_tusTest?filename=' + encodeURIComponent(fileName) + '" target="_blank"><b>PDF</b>' + fileName + '</a>';
                }
            },
            {
                title: "비고", field: "t_ok", widthGrow: 1, hozAlign: "left",
                formatter: function (cell) {
                    const v = cell.getValue() || "";
                    cell.getElement().title = v;
                    if (!v) return '<span class="c-none">—</span>';
                    // 숫자(온도·편차)만 고정폭으로
                    const esc = $("<div>").text(v).html();
                    return '<span class="c-note">' + esc.replace(/([+\-−±]?\d+(?:\.\d+)?)/g, '<span class="mono">$1</span>') + '</span>';
                }
            }
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
            if (d.t_url) { $("#fileNameDisplay").text(d.t_url); }
            $("#hiddenId").val(d.id);
            $("input[name='id']").val(d.id);
            $("#modalContainer").addClass("show");
        }
    });
    dataTable.on("dataLoaded", tusSummary);
}

// 데모: 표가 화면 남은 높이를 채우므로 창 크기 변경 시 다시 그림
$(window).on("resize", function () { if (dataTable) dataTable.redraw(); });</script>
</body>
</html>
