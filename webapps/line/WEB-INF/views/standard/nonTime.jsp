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
  <style>
:root {
  --bg:         #f0f2f7;
  --surface:    #ffffff;
  --surface2:   #f7f8fc;
  --border:     #e2e6ef;
  --text-p:     #0f172a;
  --text-s:     #64748b;
  --text-m:     #94a3b8;
  --accent:     #2563eb;
  --indigo:     #4f46e5;
  --red:        #dc2626;
  --green:      #16a34a;
  --shadow-sm:  0 1px 3px rgba(0,0,0,.06);
  --shadow-md:  0 4px 16px rgba(0,0,0,.08);
  --radius:     12px;
}

body {
  font-family: 'Noto Sans KR', sans-serif;
  background: var(--bg);
  color: var(--text-p);
  margin: 0; padding: 0;
}

/* 상단 툴바 */
.topbar {
  position: sticky; top: 0; z-index: 100;
  background: rgba(255,255,255,.9);
  backdrop-filter: blur(10px);
  border-bottom: 1px solid var(--border);
  padding: 10px 24px;
}

.topbar-inner {
  max-width: 1600px; margin: 0 auto;
  display: flex; align-items: center; gap: 12px;
}

.topbar-title {
  font-size: 15px; font-weight: 800; display: flex; align-items: center; gap: 8px;
  margin-right: 15px;
}

.ctrl {
  height: 34px; padding: 0 12px; border: 1px solid var(--border);
  border-radius: 8px; font-size: 13px; outline: none;
}

/* KPI 카드 레이아웃 */
.page-wrap { max-width: 1600px; margin: 0 auto; padding: 20px; display: flex; flex-direction: column; gap: 20px; }

.kpi-row { display: grid; grid-template-columns: repeat(4, 1fr); gap: 15px; }

.kpi-card {
  background: var(--surface); border: 1px solid var(--border);
  border-radius: var(--radius); padding: 16px; box-shadow: var(--shadow-sm);
  display: flex; align-items: center; gap: 15px;
}

.kpi-icon { width: 42px; height: 42px; border-radius: 10px; display: flex; align-items: center; justify-content: center; background: var(--surface2); }

.kpi-value { font-size: 24px; font-weight: 800; font-family: 'JetBrains Mono'; }

/* 메인 컨텐츠 영역 (그리드) */
.content-grid {
  display: grid;
  grid-template-columns: 667px 1fr; /* 요약 350px, 리스트 나머지 */
  gap: 20px;
  align-items: start;
}

.main-card {
  background: var(--surface); border: 1px solid var(--border);
  border-radius: var(--radius); box-shadow: var(--shadow-sm); overflow: hidden;
}

.card-header {
  padding: 14px 20px; border-bottom: 1px solid var(--border);
  display: flex; align-items: center; justify-content: space-between;
}

.card-title { font-size: 14px; font-weight: 800; color: var(--text-p); }

/* 버튼 스타일 */
.btn {
  height: 34px; padding: 0 15px; border-radius: 8px; font-size: 13px; font-weight: 700;
  display: inline-flex; align-items: center; gap: 6px; cursor: pointer; border: none;
}

.btn-blue { background: var(--accent); color: #fff; }
.btn-green { background: var(--green); color: #fff; }
.btn-red { background: var(--red); color: #fff; }

/* 모달 스타일 커스텀 */
.modal {
  display: none; position: fixed; z-index: 1000; left: 0; top: 0;
  width: 100%; height: 100%; background: rgba(15, 23, 42, 0.5);
  backdrop-filter: blur(4px);
}

.modal-content {
  background: white; width: 420px; margin: 5vh auto; padding: 25px;
  border-radius: 20px; box-shadow: var(--shadow-md);
}

.form-group { margin-bottom: 15px; }
.form-group label { display: block; font-size: 12px; font-weight: 700; color: var(--text-s); margin-bottom: 5px; }
.form-group input, .form-group select, .form-group textarea {
  width: 100%; padding: 10px; border: 1px solid var(--border); border-radius: 8px; font-size: 14px;
}
	
    </style>
</head>

<body>

<div class="topbar">
  <div class="topbar-inner">
    <div class="topbar-title">📋 비가동 현황</div>
    <div style="width:1px; height:20px; background:var(--border);"></div>
    
    <span style="font-size:12px; font-weight:700; color:var(--text-s);">조회기간</span>
    <input type="text" id="startDate" class="ctrl daySet">
    <span style="color:var(--text-m);">~</span>
    <input type="text" id="endDate" class="ctrl daySet">
    
    <select id="equipment_name" class="ctrl">
        <option value="열처리 연속로">열처리 연속로</option>
    </select>

    <button class="btn btn-blue select-button">조회</button>
    
    <div style="margin-left:auto; display:flex; gap:8px;">
        <button class="btn btn-green insert-button">내역 추가</button>
        <button class="btn btn-red delete-button">내역 삭제</button>
    </div>
  </div>
</div>

<div class="page-wrap">
  <div class="kpi-row">
    <div class="kpi-card">
        <div class="kpi-icon" style="color:var(--indigo); background:#eef2ff;">📊</div>
        <div>
            <div style="font-size:11px; font-weight:700; color:var(--text-m);">전체 비가동</div>
            <div class="kpi-value" id="kpi-total">0</div>
        </div>
    </div>
    <div class="kpi-card">
        <div class="kpi-icon" style="color:var(--red); background:#fef2f2;">⚠️</div>
        <div>
            <div style="font-size:11px; font-weight:700; color:var(--text-m);">설비 고장</div>
            <div class="kpi-value" id="kpi-failure">0</div>
        </div>
    </div>
    <div class="kpi-card">
        <div class="kpi-icon" style="color:var(--accent); background:#eff6ff;">⏱️</div>
        <div>
            <div style="font-size:11px; font-weight:700; color:var(--text-m);">총 비가동 시간</div>
            <div class="kpi-value" id="kpi-time">0h</div>
        </div>
    </div>
    <div class="kpi-card">
        <div class="kpi-icon" style="color:var(--green); background:#f0fdf4;">✅</div>
        <div>
            <div style="font-size:11px; font-weight:700; color:var(--text-m);">조치 완료</div>
            <div class="kpi-value" id="kpi-done">0</div>
        </div>
    </div>
  </div>

  <div class="content-grid">
    <div class="main-card">
      <div class="card-header">
        <span class="card-title">원인별 요약 (TOP 10)</span>
      </div>
      <div id="dataView"></div>
    </div>

    <div class="main-card">
      <div class="card-header">
        <span class="card-title">상세 비가동 이력</span>
      </div>
      <div id="dataList"></div>
    </div>
  </div>
</div>

<div id="modalContainer" class="modal">
    <div class="modal-content">
        <h2 style="margin:0 0 20px 0; font-size:18px;">비가동 정보 입력</h2>
        <form id="corrForm">
            <div class="form-group">
                <label>설비명</label>
                <input type="text" id="popup_equip" name="equipment_name" readonly style="background:#f8fafc;">
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
            <div class="form-group">
                <label>비가동 시작</label>
                <input type="text" class="datetimeSet" name="start_time">
            </div>
            <div class="form-group">
                <label>비가동 종료</label>
                <input type="text" class="datetimeSet" name="end_time">
            </div>
            <div class="form-group">
                <label>비고 (상세 조치내역)</label>
                <textarea name="non_time_memo" rows="4"></textarea>
            </div>
            
            <input type="hidden" name="non_time_idx" />
            <input type="hidden" class="facility_standard_code" name="standard_code" value="">

            <div style="display:flex; gap:10px; margin-top:20px;">
                <button type="submit" id="saveCorrStatus" class="btn btn-blue" style="flex:2; justify-content:center;">데이터 저장</button>
                <button type="button" id="closeModal" class="btn" style="flex:1; justify-content:center; background:#e2e8f0;">취소</button>
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
        height: "560px",
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
            {title: "비가동 시작", field: "start_time", width: 180, hozAlign: "center"},
            {title: "비가동 종료", field: "end_time", width: 180, hozAlign: "center"},
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
        height: "560px",
        layout: "fitColumns",
        placeholder: "데이터 없음",
        ajaxConfig: "POST",
        ajaxURL: "/line/standard/nonTime/view",
        ajaxParams: getSearchParams(),
        ajaxResponse: function(url, params, response) {
            return response.status === "success" ? response.data : [];
        },
        columns: [
            {title: "순위", field: "rank", width: 60, hozAlign: "center", formatter:"rownum"},
            {title: "설비", field: "v_equipment_name", width: 100, hozAlign: "center"},
            {title: "비가동 내역", field: "info_list_v", hozAlign: "center"},
            {title: "시간", field: "sum_time_ch", width: 120, hozAlign: "right"},
            {title: "건수(일/월)", field: "day_count", width: 100, hozAlign: "center", 
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
