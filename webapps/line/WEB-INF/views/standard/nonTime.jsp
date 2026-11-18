<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="ko">
<head>
<script src="/line/mock/mock-loader.js"></script>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>비가동현황</title>
 <%@include file="../include/pluginpage.jsp" %>    
    <jsp:include page="../include/tabBar.jsp"/>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=IBM+Plex+Mono:wght@400;500&family=IBM+Plex+Sans+KR:wght@400;500;600&display=swap">
<link rel="stylesheet" href="/line/css/opsList/ops-list.css">
  <style>
/* ===== 데모: 설비비가동현황 — 고밀도 운영 화면 (ops-list.css 공통 + 페이지 전용) ===== */
html, body.ops { height: 100%; }
body.ops { display: flex; flex-direction: column; overflow: hidden; }
.ops-page { flex: 1; min-height: 0; }

.nt-kpi { grid-template-columns: 1.4fr repeat(3, 1fr); }
.nt-kpi .kpi-value .u { font-family: var(--ops-sans); font-size: 13px; color: var(--ops-fg3); margin-left: 2px; }

/* 원인별 요약 | 상세 이력: 남은 높이를 채우고 표 안에서만 스크롤 */
.nt-grid { flex: 1; min-height: 0; display: grid; grid-template-columns: 640px 1fr; gap: 16px; }
.nt-grid .ops-card { display: flex; flex-direction: column; min-height: 0; }
.nt-grid .ops-table { flex: 1; min-height: 0; }
.ops .c-mono { font-family: var(--ops-mono); font-size: 12px; font-variant-numeric: tabular-nums; color: var(--ops-fg2); }

/* 입력 모달 (#modalContainer 는 jQuery fadeIn/Out 으로 표시) */
.modal { display: none; position: fixed; z-index: 1000; inset: 0; background: oklch(20% 0.01 255 / 0.4); }
.modal-content { background: #fff; width: 440px; max-width: 95vw; margin: 8vh auto 0; border: 1px solid var(--ops-line); border-radius: 8px;
  box-shadow: 0 12px 32px oklch(20% 0.01 255 / 0.16); font-family: var(--ops-sans); }
.modal-content .modal-body { display: flex; flex-direction: column; gap: 12px; }
.modal-content .form-group label { font-size: 12px; font-weight: 500; color: var(--ops-fg2); }
.modal-content .form-group input, .modal-content .form-group select, .modal-content .form-group textarea {
  width: 100%; height: 32px; padding: 0 8px; border: 1px solid var(--ops-line); border-radius: 6px; background: #fff;
  color: var(--ops-fg); font-family: var(--ops-sans); font-size: 13px; outline: none; }
.modal-content .form-group textarea { height: auto; padding: 8px; resize: vertical; }
.modal-content .form-group input.datetimeSet { font-family: var(--ops-mono); font-variant-numeric: tabular-nums; }
.modal-content .form-group input[readonly] { background: var(--ops-bg); color: var(--ops-fg2); }
.modal-content .form-group input:focus, .modal-content .form-group select:focus, .modal-content .form-group textarea:focus {
  border-color: var(--ops-accent); box-shadow: 0 0 0 2px var(--ops-accent-tint); }
.modal-content .form-row { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; }
    </style>
</head>

<body class="ops">

<header class="ops-head">
  <div class="ops-head-in">
    <h1 class="ops-title">설비비가동현황</h1>
    <span class="ops-label">조회기간</span>
    <input type="text" id="startDate" class="ops-input ctrl daySet">
    <span class="muted">~</span>
    <input type="text" id="endDate" class="ops-input ctrl daySet">
    <span class="ops-label">설비</span>
    <select id="equipment_name" class="ops-input ctrl" style="font-family:var(--ops-sans)">
        <option value="열처리 연속로">열처리 연속로</option>
    </select>
    <button class="ops-btn primary btn select-button">조회</button>

    <span class="ops-spacer"></span>
    <button class="ops-btn btn insert-button">내역 추가</button>
    <button class="ops-btn danger btn delete-button">내역 삭제</button>
  </div>
</header>

<div class="ops-page">
  <div class="ops-kpi nt-kpi">
    <div class="hero">
      <span class="kpi-label">총 비가동 시간</span>
      <span class="kpi-value" id="kpi-time">0h</span>
      <span class="kpi-sub">조회기간 합계 · 종료 시각이 있는 건만</span>
    </div>
    <div>
      <span class="kpi-label">전체 비가동</span>
      <span class="kpi-value" id="kpi-total">0</span>
      <span class="kpi-sub">조회기간 등록 건수</span>
    </div>
    <div>
      <span class="kpi-label">설비 고장</span>
      <span class="kpi-value" id="kpi-failure">0</span>
      <span class="kpi-sub">분류 = 설비고장</span>
    </div>
    <div>
      <span class="kpi-label">조치 완료</span>
      <span class="kpi-value" id="kpi-done">0</span>
      <span class="kpi-sub">종료 시각 입력 건</span>
    </div>
  </div>

  <div class="nt-grid">
    <section class="ops-card">
      <div class="ops-card-head">
        <h2>원인별 요약</h2><span class="note">비가동 시간 순 TOP 10</span>
      </div>
      <div id="dataView" class="ops-table"></div>
    </section>

    <section class="ops-card">
      <div class="ops-card-head">
        <h2>상세 비가동 이력</h2><span class="note">행 더블클릭으로 수정 · 선택 후 내역 삭제</span>
      </div>
      <div id="dataList" class="ops-table"></div>
    </section>
  </div>
</div>

<div id="modalContainer" class="modal">
    <div class="modal-content">
        <div class="modal-head"><h2>비가동 정보 입력</h2></div>
        <form id="corrForm">
          <div class="modal-body">
            <div class="form-group">
                <label>설비명</label>
                <input type="text" id="popup_equip" name="equipment_name" readonly>
            </div>
            <div class="form-group">
                <label>정보 LIST (분류)</label>
                <select name="info_list">
                    <option value="제품이상조치">제품이상조치</option>
                    <option value="설비고장">설비고장</option>
                    <option value="계획정지">계획정지</option>
                    <option value="기타">기타</option>
                </select>
            </div>
            <div class="form-row">
              <div class="form-group">
                  <label>비가동 시작</label>
                  <input type="text" class="datetimeSet" name="start_time">
              </div>
              <div class="form-group">
                  <label>비가동 종료</label>
                  <input type="text" class="datetimeSet" name="end_time">
              </div>
            </div>
            <div class="form-group">
                <label>비고 (상세 조치내역)</label>
                <textarea name="non_time_memo" rows="4"></textarea>
            </div>

            <input type="hidden" name="non_time_idx" />
            <input type="hidden" class="facility_standard_code" name="standard_code" value="">
          </div>

          <div class="modal-btn-row">
              <button type="button" id="closeModal" class="ops-btn btn">취소</button>
              <button type="submit" id="saveCorrStatus" class="ops-btn primary btn">데이터 저장</button>
          </div>
        </form>
    </div>
</div>


<script>
let now_page_code = "f01";
let dataListTable, dataViewTable;

$(document).ready(function() {
    // 1. 날짜 초기화 (현재월 1일 ~ 오늘)
    initDateRange();

    // 2. 테이블 초기화
    initTables();

    // 3. 이벤트 바인딩
    bindEvents();
});

/** * 날짜 초기화 함수
 */
function initDateRange() {
    const today = new Date();
    const firstDayOfMonth = new Date(today.getFullYear(), today.getMonth(), 1);

    function formatDate(date) {
        const year = date.getFullYear();
        const month = ("0" + (date.getMonth() + 1)).slice(-2);
        const day = ("0" + date.getDate()).slice(-2);
        return year + "-" + month + "-" + day;
    }

    $("#startDate").val(formatDate(firstDayOfMonth));
    $("#endDate").val(formatDate(today));
}

/** * 이벤트 바인딩
 */
function bindEvents() {
    // 조회 버튼
    $(".select-button").on("click", function() {
        refreshData();
    });

    // 추가 버튼
    $(".insert-button").on("click", function() {
        openModal("add");
    });

    // 삭제 버튼
    $(".delete-button").on("click", function() {
        deleteCorrStatus();
    });

    // 모달 닫기
    $(".close, #closeModal").on("click", function() {
        closeModal();
    });
}

/** * 테이블 초기화 (Tabulator)
 */
function initTables() {
    // 상세 리스트 테이블
    dataListTable = new Tabulator("#dataList", {
        height: "100%",
        layout: "fitColumns",
        selectable: 1,
        placeholder: "조회된 데이터가 없습니다.",
        ajaxConfig: "POST",
        ajaxURL: "/line/standard/nonTime/list",
        ajaxParams: getSearchParams(),
        ajaxResponse: function(url, params, response) {
            if (response.status === "success") {
                updateKpi(response.data); // KPI 수치 업데이트 연동
                return response.data;
            }
            return [];
        },
        columns: [
            {title: "설비", field: "equipment_name", width: 150, hozAlign: "center"},
            {title: "정보LIST", field: "info_list", width: 150, hozAlign: "center"},
            {title: "비가동 시작", field: "start_time", width: 160, hozAlign: "center", cssClass: "c-mono"},
            {title: "비가동 종료", field: "end_time", width: 160, hozAlign: "center", cssClass: "c-mono"},
            {title: "비고", field: "non_time_memo", minWidth: 200, hozAlign: "left"},
            {title: "idx", field: "non_time_idx", visible: false},
            {title: "code", field: "standard_code", visible: false},
        ],
        rowDblClick: function(e, row) {
            openModal("edit", row.getData());
        }
    });

    // 원인별 요약 테이블
    dataViewTable = new Tabulator("#dataView", {
        height: "100%",
        layout: "fitColumns",
        placeholder: "데이터 없음",
        ajaxConfig: "POST",
        ajaxURL: "/line/standard/nonTime/view",
        ajaxParams: getSearchParams(),
        ajaxResponse: function(url, params, response) {
            return response.status === "success" ? response.data : [];
        },
        columns: [
            {title: "순위", field: "rank", width: 56, hozAlign: "right", cssClass: "c-mono", formatter:"rownum"},
            {title: "설비", field: "v_equipment_name", width: 100, hozAlign: "center"},
            {title: "비가동 내역", field: "info_list_v", hozAlign: "center"},
            {title: "시간", field: "sum_time_ch", width: 120, hozAlign: "right", cssClass: "c-mono"},
            {title: "건수(일/월)", field: "day_count", width: 100, hozAlign: "right", cssClass: "c-mono", 
             formatter:function(cell){
                const d = cell.getRow().getData();
                return d.day_count + " / " + d.month_count;
             }}
        ]
    });
}

/**
 * 공통 검색 파라미터 추출
 */
function getSearchParams() {
    return {
        equipment_name: $("#equipment_name").val() || "",
        startDate: $("#startDate").val() || "",
        endDate: $("#endDate").val() || ""
    };
}

/**
 * KPI 카드 수치 업데이트 (UI 연동)
 */
 /**
  * KPI 카드 수치 업데이트 (시간 계산 로직 포함)
  */
 function updateKpi(data) {
     if(!data || data.length === 0) {
         $(".kpi-value").text("0");
         return;
     }

     const totalCount = data.length;
     const failureCount = data.filter(r => r.info_list === '설비고장').length;
     const doneCount = data.filter(r => r.end_time && r.end_time !== '').length;

     // --- 비가동 시간 계산 로직 ---
     let totalMinutes = 0;

     data.forEach(row => {
         if (row.start_time && row.end_time) {
             const start = new Date(row.start_time);
             const end = new Date(row.end_time);

             // 유효한 날짜인지 확인 후 차이 계산 (밀리초 -> 분)
             if (!isNaN(start) && !isNaN(end)) {
                 const diffMs = end - start;
                 if (diffMs > 0) {
                     totalMinutes += Math.floor(diffMs / (1000 * 60));
                 }
             }
         }
     });

     // 시간과 분으로 변환 (예: 125분 -> 2h 5m)
     const hours = Math.floor(totalMinutes / 60);
     const mins = totalMinutes % 60;
     const timeStr = hours > 0 ? hours + "h " + mins + "m" : mins + "m";

     // UI 반영
     $("#kpi-total").text(totalCount.toLocaleString());
     $("#kpi-failure").text(failureCount.toLocaleString());
     $("#kpi-done").text(doneCount.toLocaleString());
     $("#kpi-time").text(timeStr); // 계산된 시간 표시
 }
/** * 모달 열기/닫기
 */
function openModal(mode, rowData) {
    const $form = $("#corrForm");
    $form[0].reset();

    if (mode === "edit") {
        $("#saveCorrStatus").text("수정");
        // 필드 매핑
        $form.find("input[name='equipment_name']").val(rowData.equipment_name);
        $form.find("select[name='info_list']").val(rowData.info_list);
        $form.find("input[name='start_time']").val(rowData.start_time);
        $form.find("input[name='end_time']").val(rowData.end_time);
        $form.find("textarea[name='non_time_memo']").val(rowData.non_time_memo);
        $form.find("input[name='non_time_idx']").val(rowData.non_time_idx);
        $form.find("input[name='standard_code']").val(rowData.standard_code);
    } else {
        $("#saveCorrStatus").text("추가");
        // 현재 선택된 설비 정보를 기본값으로 세팅
        const currentEquip = $("#equipment_name option:selected").text();
        const currentCode = $("#equipment_name").val();
        $form.find("input[name='equipment_name']").val(currentEquip);
        $form.find("input[name='standard_code']").val(currentCode);
    }

    $("#modalContainer").fadeIn(200).addClass("show");

    // 저장 이벤트 바인딩 (기존 바인딩 제거 후 재등록)
    $("#saveCorrStatus").off("click").on("click", function(e) {
        e.preventDefault();
        mode === "edit" ? updateCorrStatus() : saveCorrStatus();
    });
}

function closeModal() {
    $("#modalContainer").fadeOut(200).removeClass("show");
}

/** * 데이터 저장/수정/삭제/조회 Ajax
 */
function refreshData() {
    const params = getSearchParams();
    dataListTable.setData("/line/standard/nonTime/list", params);
    dataViewTable.setData("/line/standard/nonTime/view", params);
}

function saveCorrStatus() {
    const formData = new FormData($("#corrForm")[0]);
    $.ajax({
        url: "/line/standard/nonTime/insert",
        type: "POST",
        data: formData,
        processData: false,
        contentType: false,
        success: function(res) {
            if (res.result === "success") {
                alert("저장되었습니다.");
                closeModal();
                refreshData();
            } else {
                alert("저장 실패: " + res.message);
            }
        }
    });
}

function updateCorrStatus() {
    const formData = new FormData($("#corrForm")[0]);
    $.ajax({
        url: "/line/standard/nonTime/update",
        type: "POST",
        data: formData,
        processData: false,
        contentType: false,
        success: function(res) {
            if (res.result === "success") {
                alert("수정되었습니다.");
                closeModal();
                refreshData();
            }
        }
    });
}

function deleteCorrStatus() {
    const selectedRows = dataListTable.getSelectedData();
    if (selectedRows.length === 0) return alert("삭제할 항목을 선택하세요.");
    if (!confirm("정말 삭제하시겠습니까?")) return;

    $.ajax({
        url: "/line/standard/nonTime/delete",
        type: "POST",
        contentType: "application/json",
        data: JSON.stringify({ non_time_idx: selectedRows[0].non_time_idx }),
        success: function(res) {
            if (res.result === "success") {
                alert("삭제되었습니다.");
                refreshData();
            }
        }
    });
}
</script>


</body>
</html>
