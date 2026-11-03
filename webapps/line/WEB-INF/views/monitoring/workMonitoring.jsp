<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="ko">
<head>
<script src="/line/mock/mock-loader.js"></script>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>작업현황</title>
   <%@include file="../include/pluginpage.jsp" %>    
    <jsp:include page="../include/tabBar.jsp"/>
<link rel="stylesheet" href="/vendor/jquery-ui/1.13.2/themes/base/jquery-ui.css">
<script src="/vendor/jquery-ui/1.13.2/jquery-ui.js"></script>

<style>














    /* 기본 레이아웃 (테이블 높이/패딩 축소 적용) */
    body{ background:#fff; font-family:"Noto Sans KR", "맑은 고딕", sans-serif; color:#222; margin:0; padding:0; overflow: hidden; }
   .main {
    max-width:1800px;
    margin:18px auto;
    padding:6px;
    height: 100%;
    overflow: hidden; /* 내부 카드 스크롤만 허용 */
}

/* 카드 내부 테이블 래퍼 스크롤 */


.card.fixed-height #tableHeatWrapper {
    flex: 1; /* 남은 공간 모두 차지 */
    overflow-y: auto;

}
body, html {
    height: 100%;
    overflow: hidden; /* 화면 전체 스크롤 제거 */
}
    .header{ display:flex; justify-content:space-between; align-items:center; margin-bottom:14px; }
    .title{ font-size:20px; font-weight:700; }
    .subtitle{ font-size:13px; color:#6b7280; }

    .grid{ display:flex; gap:18px; margin-bottom:18px; }
    .card{
        background:#fff;
        border-radius:10px;
        padding:10px; /* 기존 12 -> 10 */
        box-shadow:0 6px 18px rgba(2,6,23,0.06);
        border:1px solid rgba(2,6,23,0.04);
        flex:1;
        min-width:330px;
    }
    .card .card-header{ display:flex; justify-content:space-between; align-items:center; margin-bottom:8px; }
    .card-title{ font-weight:700; font-size:14px; }
    .card-sub{ font-size:12px; color:#6b7280; }

    /* 테이블 공통: 패딩/행높이 축소 */
    table { width:100%; border-collapse:collapse; font-size:13px; }
    thead th {
        text-align:center;
        padding:6px 6px; /* 기존 10px -> 6px */
        background:#edeff1;
        border-bottom:1px solid #e6eefc;
        font-weight:700;
        height:27px; /* 헤더 높이 약간 축소 */
    }
    tbody td {
        padding:6px 6px; /* 기존 10px -> 6px */
        border-bottom:1px solid #f1f5f9;
        text-align:center;
        height:27px; /* 각 행 높이 고정 */
        line-height:18px;
        white-space:nowrap;
        overflow:hidden;
        text-overflow:ellipsis;
    }
    tbody tr:hover { background:#fbfdff; cursor:pointer; }
    tbody tr.selected { background: linear-gradient(90deg, rgba(11,99,206,0.06), rgba(11,99,206,0.02)); font-weight:700; }

    .kpi { display:flex; gap:8px; }
    .kpi .item{ flex:1; background:#edeff1; padding:6px; border-radius:8px; text-align:center; } /* padding 축소 */
    .kpi .label{ font-size:12px; color:#6b7280; }
    .kpi .value{ font-size:16px; font-weight:800; color:#111827; } /* 숫자 크기 약간 축소 */

    .btn{ display:inline-flex; align-items:center; gap:8px; padding:8px 12px; border-radius:8px; border:0; cursor:pointer; font-weight:700; }
    .btn.primary{ background:#0b63ce; color:#fff; }
    .btn.work{ background:#A566FF; color:#fff; }
    .btn.ghost{ background:#fff; color:#111; border:1px solid rgba(2,6,23,0.06); }



    .small-input{ padding:6px 8px; border-radius:6px; border:1px solid #e6eefc; }

    .muted {
    color: #6b7280;
    font-size: 14px;
    margin-right: 10px;
}

    /* 강조 셀 (온도, CP) */
    .temp { color:#e63946; font-weight:800; }
    .cp { color:#0b63ce; font-weight:800; }

    /* 개별 테이블 최대 높이 — 줄여서 스크롤 생기도록 설정 */
 
   #tableHeatWrapper { 
    height: 100px;  /* 기존 330px → 250px */
    overflow:auto; 
}

    #tableAlarm { } /* 테이블 element 자체는 사용 안함 */
    #tableAlarm tbody { } 
   #tableAlarmWrapper { 
    height: 340px;  
    overflow:auto; 
}

#tableAlarmWrapper th {
  font-size: 14px;
  font-weight: bold;
  text-align: center;
  padding: 8px 12px;
}

#tableAlarmWrapper td {
  font-size: 15px;
  font-weight: bold;
  text-align: center;
  padding: 8px 12px;
}



    /* 온도표는 한 줄이라 높이 조절 필요 없음 — 셀 패딩만 작게 */
    .temp-table thead th{ padding:6px 6px; font-size:14px; color:#6b7280; }
    .temp-table tbody td{ padding:8px 6px; font-size:14px; height:30px; }

    @media (max-width:1100px){
        .grid{ flex-direction:column; }
    }
    
/*바코드스캔 모달용 css*/
  #lotModal .form-section {
    margin-bottom: 15px;
    padding: 4px;
    border-radius: 10px;
    background: #f9fafb;
    box-shadow: 0 1px 4px rgba(0,0,0,0.05);
  }

  #lotModal .form-section h3 {
    margin-bottom: 8px;
    font-size: 14px;
    color: #333;
    border-left: 4px solid #007bff;
    padding-left: 6px;
  }

  #lotModal .grid {
    display: grid;
    gap: 8px;
  }

  #lotModal .grid-3 { grid-template-columns: repeat(3, 1fr); }
  #lotModal .grid-7 { grid-template-columns: repeat(7, 1fr); }
  #lotModal .grid-6 { grid-template-columns: repeat(6, 1fr); }

  #lotModal .form-group {
    display: flex;
    flex-direction: column;
  }

  #lotModal .form-group label {
    font-size: 12px;
    margin-bottom: 3px;
    color: #555;
  }

  #lotModal .form-group input {
    padding: 4px 6px;
    border: 1px solid #ccc;
    border-radius: 6px;
    outline: none;
    font-size: 12px;
  }

  #lotModal .form-group input:focus {
    border-color: #007bff;
    background: #f0f7ff;
  }

  #lotModal .modal-footer {
    display: flex;
    justify-content: flex-end;
    gap: 8px;
    margin-top: 10px;
  }

  #lotModal .btn {
    padding: 6px 12px;
    border: none;
    border-radius: 6px;
    cursor: pointer;
    font-size: 13px;
  }

  #lotModal .btn-primary {
    background-color: #007bff;
    color: white;
  }

  #lotModal .btn-secondary {
    background-color: #e0e0e0;
    color: #333;
  }
  .topBar {
    display: flex;
    align-items: center; /* 세로 가운데 정렬 */
    gap: 10px; /* 요소 사이 간격 */
}


/* 테이블 전체 스타일 */
.tableHeatTopWrapper table {
    width: 100%;
    border-collapse: collapse;
}

#tableHeatTopWrapper th {
  font-size: 16px;
  font-weight: bold;
  padding: 8px 12px;
  text-align: center;
}

#tableHeatTopWrapper td {
  font-size: 20px;
  font-weight: bold;
  padding: 8px 12px;
  text-align: center;
}


#tableAlarm td{
  font-weight: bold;
}
  #tableTempCurrent th {
    font-size: 16px;
  }

  #tableTempCurrent td {
    font-size: 23px;
  }
  
  .hidden-date {
    display: none;
}
  

/* ===== 온도별 현재 PV : 라인 × 구간 매트릭스 (페이지 카드와 동일한 흰 배경) ===== */
#pvCard{ min-width:0; padding:12px 14px 10px; }
#pvCard .pv-head{ margin-bottom:8px; }
#pvCard .pv-titlewrap{ display:flex; align-items:baseline; gap:12px; white-space:nowrap; }
#pvCard .pv-legend{ display:flex; gap:10px; font-size:12px; color:#94a3b8; }
#pvCard .pv-legend span{ display:inline-flex; align-items:center; gap:4px; }
#pvCard .pv-legend i, #pvCard .pv-sum i{ width:8px; height:8px; border-radius:50%; display:inline-block; }
#pvCard i.ok{ background:#16a34a; } #pvCard i.warn{ background:#f59e0b; } #pvCard i.bad{ background:#dc2626; }
#pvCard .pv-headr{ display:flex; align-items:center; gap:14px; white-space:nowrap; }
#pvCard .pv-sum{ display:flex; gap:12px; font-size:12.5px; color:#64748b; }
#pvCard .pv-sum span{ display:inline-flex; align-items:center; gap:5px; }
#pvCard .pv-sum b{ color:#0f172a; font-weight:700; font-variant-numeric:tabular-nums; }
#pvCard #btnToggleAuto{ font-size:12px; padding:4px 10px; }

#pvCard table.pvm{ width:100%; border-collapse:separate; border-spacing:0; table-layout:fixed; }
#pvCard .pvm col.h{ width:64px; }
#pvCard .pvm th{ font-size:12px; font-weight:600; color:#64748b; text-align:center; padding:0 2px 6px; white-space:nowrap; overflow:hidden; text-overflow:ellipsis; }
#pvCard .pvm th.grp{ color:#334155; }
#pvCard .pvm td{ border-top:1px solid #eef1f5; padding:7px 4px; text-align:center; vertical-align:middle; }
#pvCard .pvm td.rh{ text-align:left; font-size:13px; font-weight:700; color:#334155; white-space:nowrap; padding-left:2px; }
#pvCard .pvm td.rh small{ display:block; font-size:11px; font-weight:500; color:#94a3b8; margin-top:1px; }
#pvCard .pvm td.sep{ border-left:1px solid #e3e8ef; }
#pvCard .pv-tile{ transition:background .3s; border-radius:0; }
#pvCard .pv-tile.warn{ background:#fff7e8; }
#pvCard .pv-tile.bad{ background:#fdeeee; }
#pvCard .pv-val{ white-space:nowrap; line-height:1.15; }
#pvCard .pv-val b{ font-size:19px; font-weight:700; color:#0f172a; font-variant-numeric:tabular-nums; letter-spacing:-0.3px; }
#pvCard .pv-val i{ font-style:normal; font-size:11px; color:#94a3b8; margin-left:1px; }
#pvCard .pv-foot{ margin-top:3px; font-size:11.5px; color:#94a3b8; white-space:nowrap; font-variant-numeric:tabular-nums; }
#pvCard .pv-sv em{ font-style:normal; color:#64748b; }
#pvCard .pv-dev{ margin-left:5px; font-weight:700; color:#16a34a; }
#pvCard .pv-tile.warn .pv-dev{ color:#d97706; }
#pvCard .pv-tile.bad .pv-dev{ color:#dc2626; }
</style>

</head>
<body>
<main class="main">
    <div class="header">
        <div>
  

        </div>
        <div style="text-align:right;">
       
		
        </div>
    </div>

    <!-- 상단: 요약(왼) + 알람(오) (위치 변경: 알람을 상단 오른쪽에 배치) -->
    <div class="grid">
        <div class="card card" style="flex:0.75; fon">
            <div class="card-header">
                <div>
                    <div class="card-title">작업 진행</div>
                    <div class="card-sub"></div>
                </div>
               
            </div>

         
            

            
               <div id="tableHeatTopWrapper">
                <div id="tableHeatTop">
  <input type="text" class="daySet hidden-date" id="daySetStart" placeholder="시작일">
<input type="text" class="daySet hidden-date" id="daySetEnd" placeholder="종료일">

        <div id="dataList"></div>
                </div>
            </div>
            
            <div class="card card fixed-height" id="pvCard">
            <div class="card-header pv-head">
                <div class="pv-titlewrap">
                    <div class="card-title">온도별 현재 PV</div>
                    <div class="pv-legend">SV 대비 편차 · 정상 ±5℃ 이내 / 주의 ±10℃ 이내</div>
                </div>
                <div class="pv-headr">
                    <div class="pv-sum" id="pvSummary">
                        <span class="ok"><i class="ok"></i>정상 <b>-</b></span>
                        <span class="warn"><i class="warn"></i>주의 <b>-</b></span>
                        <span class="bad"><i class="bad"></i>이상 <b>-</b></span>
                    </div>
                    <button class="btn ghost" id="btnToggleAuto">자동(10s)</button>
                </div>
            </div>
            <div class="pvb" id="pvBoard"></div>
        </div>
        </div>

        <!-- 오른쪽 상단: 알람 카드로 변경 (위치 변경 적용) -->
        <div class="card card" style="flex:0.55;">
            <div class="card-header">
                <div>
                    <div class="card-title">최신 알람 이력</div>
                    <div class="card-sub"></div>
                </div>
                <div>
       <!--              <input type="date" id="s_sdate" class="small-input">
                    <input type="date" id="s_edate" class="small-input"> -->
                   <!--  <button class="btn ghost" id="btnLoadAlarm">조회</button> -->
                   
                   	<div class="topBar">
			    <div class="muted">최종 갱신: <span id="lastUpdated">--:--:--</span></div>
			    <button class="btn work" id="openModal">작업스캔</button>
			    <button class="btn primary" id="btnRefresh">즉시갱신</button>
			    <button class="btn ghost" id="btnRefreshAll">전체갱신</button>
			</div>
                </div>
            </div>

            <div id="tableAlarmWrapper"  overflow:auto;">
                <table id="tableAlarm">
                    <thead>
                        <tr>
                            <th>No</th>
                         <!--    <th>PLC주소</th> -->
                            <th>알람내용</th>
                            <th>발생시간</th>
                            <th>해제시간</th>
                            <th>상태</th>
                        </tr>
                    </thead>
                    <tbody></tbody>
                </table>
            </div>
        </div>
    </div>

    <!-- 하단: 최신 작업 목록 (전체 너비로 이동) -->
    <div class="grid">
        <div class="card" style="flex:1;">
            <div class="card-header">
                <div>
                    <div class="card-title">최신 작업 목록</div>
   
                </div>
                <div>
                
                </div>
            </div>

            <div id="tableHeatWrapper" style="height:260px; overflow:auto;">
                <table id="tableHeat">
                    <thead>
                        <tr>
                            <th>작업LOT</th>
                            <th>ERP</th>
                             <th>회사명</th>
                            <th>품번</th>
                            <th>품명</th>
                            <th>투입시작시간</th>
                            <th>투입종료시간</th>
                         <!-- <th>투입시간(분)</th>  -->  <th>중량(kg)</th>
                            <th>소입온도(℃)</th>
                            <th>소려온도(℃)</th>
                            <th>CP(%)</th>
                            <th>작업완료시간</th>
                        </tr>
                    </thead>
                    <tbody></tbody>
                </table>
            </div>
        </div>
    </div>

<!-- 스캔한 바코드의 정보 표현할 모달 -->
<div id="lotModal" title="작업 지시 확인" style="display:none;">

  <!-- 로트번호 -->
  <div class="form-section">
    <h3>바코드 스캔(키보드 언어 선택은 영문으로 선택해주세요)</h3>
    <div class="form-group">
      <input type="text" id="lotNumber">
    </div>
  </div>

  <!-- 기본 정보 -->
  <div class="form-section">
    <h3>기본 정보</h3>
    <div class="grid grid-3">
      <div class="form-group"><label>로트번호</label>
      <input type="text" name="w_ci_lot" class="w_ci_lot"></div>
      
      <div class="form-group"><label>업체명</label>
      <input type="text" name="cust_name" class="cust_name"></div>
      <div class="form-group"><label>품번</label>
      <input type="text" name="item_no" class="item_no"></div>
      <div class="form-group"><label>품명</label>
      <input type="text" name="item_name" class="item_name"></div>
      <div class="form-group"><label>규격</label>
      <input type="text" name="spec" class="spec"></div>
      <div class="form-group"><label>장입량</label>
      <input type="text" name="charge_weight" class="charge_weight"></div>
      <div class="form-group"><label>계획통수</label>
      <input type="text" name="w_plan_cnt" class="w_plan_cnt"></div>
      <div class="form-group"><label>투입통수</label>
      <input type="text" name="wd_in_cnt" class="wd_in_cnt"></div>
    </div>
  </div>

  <!-- 소입 존 -->
  <div class="form-section">
    <h3>소입 존</h3>
    <div class="grid grid-7">
      <div class="form-group"><label>소입1존</label>
      <input type="text" name="q1_zone" class="q1_zone"></div>
      <div class="form-group"><label>소입2존</label>
      <input type="text" name="q2_zone" class="q2_zone"></div>
      <div class="form-group"><label>소입3존</label>
      <input type="text" name="q3_zone" class="q3_zone"></div>
      <div class="form-group"><label>소입4존</label>
      <input type="text" class="q4_zone" readonly="readonly"></div>
      <div class="form-group"><label>소입5존</label>
      <input type="text" name="q5_zone" class="q5_zone"></div>
      <div class="form-group"><label>소입인버터</label>
      <input type="text" name="q_speed" class="q_speed"></div>
      <div class="form-group"><label>CP</label>
      <input type="text" name="cp" class="cp"></div>
    </div>
  </div>

  <!-- 소려 존 -->
  <div class="form-section">
    <h3>소려 존</h3>
    <div class="grid grid-6">
      <div class="form-group"><label>소려1존</label>
      <input type="text" name="t1_zone" class="t1_zone"></div>
      <div class="form-group"><label>소려2존</label>
      <input type="text" name="t2_zone" class="t2_zone"></div>
      <div class="form-group"><label>소려3존</label>
      <input type="text" class="t3_zone" readonly="readonly"></div>
      <div class="form-group"><label>소려4존</label>
      <input type="text" class="t4_zone" readonly="readonly"></div>
      <div class="form-group"><label>소려5존</label>
      <input type="text" class="t5_zone" readonly="readonly"></div>
      <div class="form-group"><label>소려인버터</label>
      <input type="text" name="t_speed" class="t_speed"></div>
    </div>
  </div>

  		<div class="view">
            <div id="dataTable"></div>
        </div>



  <!-- 버튼 -->
  <div class="modal-footer">
    <button type="button" id="applyBtn" class="btn btn-primary">작업지시 적용</button>
    <button type="button" id="cancelBtn" class="btn btn-secondary">닫기</button>
  </div>
</div><!-- 모달 열기 버튼 -->
<!--  <button id="openModal">모달 열기</button>-->


</main>


<script>

/*전역변수*/
var opcInterval;
var selectedRowData = null;
var tempAuto = true;
var tempTimer = null;
var dataTable;


$(document).ready(function () {
    const today = new Date();
    const yesterday = new Date(today);
    yesterday.setDate(today.getDate() - 1);

    function formatDate(date) {
        const yyyy = date.getFullYear();
        const mm = String(date.getMonth() + 1).padStart(2, '0');
        const dd = String(date.getDate()).padStart(2, '0');
        return yyyy + '-' + mm + '-' + dd;
    }

    $('#daySetStart').val(formatDate(today));
    $('#daySetEnd').val(formatDate(today));

    // Tabulator 최초 생성
    getDataList();

    // ⭐ 5초마다 데이터만 새로 조회
    setInterval(() => {
        if (dataTable) {
            dataTable.replaceData("/line/monitoring/lotProcessor/list", {
                startDay: $("#daySetStart").val(),
                endDay: $("#daySetEnd").val()
            });
        }
    }, 5000);
});


//공통 시간 formatter (미래 시간이면 공백)
function timeFormatter(cell) {
    const value = cell.getValue();
    if (!value) return "";

    const cellDate = new Date(value.replace(" ", "T"));
    const now = new Date();

    if (cellDate > now) return "";

    return value.split(" ")[1] || "";
}

// Tabulator 생성 함수
function getDataList() {

    const columns = [
        { title: "NO2", field: "idx", visible: false, frozen: true, width: 50, hozAlign: "center", headerHozAlign: "center", headerSort: false },
/*         {
            title: "제품 정보",
            field: "w_ci_lot",
            frozen: true,
            width: 165,
            hozAlign: "left",
            headerHozAlign: "center",
            headerSort: false,
            formatter: function(cell){
                const d = cell.getRow().getData();
                return String(d.w_ci_lot || "") +
                       "<br>" +
                       String(d.cust_name || "") +
                       "<br>" +
                       String(d.item_name || "");
            }
        }, */
        { title: "작업 LOT", field: "w_ci_lot", width: 150, hozAlign: "center", headerHozAlign: "center",  headerSort: false },
        { title: "업체명", field: "cust_name", width: 130, hozAlign: "center", headerHozAlign: "center", headerSort: false },
        { title: "품명", field: "item_name", width: 130, hozAlign: "center", headerHozAlign: "center", formatter: timeFormatter, headerSort: false },

        
        { title: "작업등록", field: "regtime", width: 100, hozAlign: "center", headerHozAlign: "center", formatter: timeFormatter, headerSort: false },
        { 
            title: "QR 확인", 
            field: "w_state", 
            width: 80, 
            hozAlign: "center", 
            headerHozAlign: "center",
             headerSort: false, 
            formatter: function(cell) {
                const value = cell.getValue() || "";  // 원래 값
                // "스캔"만 추출
                return value.includes("스캔") ? "스캔" : value;
            }
        },

        { title: "투입시작", field: "d370", width: 100, hozAlign: "center", headerHozAlign: "center", headerSort: false, formatter: timeFormatter },
        { title: "투입종료", field: "x111", width: 100, hozAlign: "center", headerHozAlign: "center", headerSort: false, formatter: timeFormatter },
     
        { title: "로트 종료", field: "l20", width: 120, hozAlign: "center", headerHozAlign: "center", headerSort: false, formatter: timeFormatter }
    ];

    dataTable = new Tabulator("#dataList", {
        height: "160px",
        movableColumns: true,
        resizableColumns: true,
        ajaxConfig: "POST",
        ajaxURL: "/line/monitoring/lotProcessor/list",
        ajaxParams: {
            startDay: $("#daySetStart").val(),
            endDay: $("#daySetEnd").val()
        },
        placeholder: "데이터가 없습니다.",
        columns: columns,
        selectable: 1,

        ajaxResponse: function (url, params, response) {
            const data = response.data || [];
            return data.filter(row => !row.l20); // 👈 핵심
        },

        virtualDom: true
    });

}






/*바코드스캔 모달*/
$(function() {

    // 초기 로드
    fetchHeatTop();
    fetchHeatTop2();
    fetchHeatList();
    fetchAlarm();
    fetchTempCurrent();

    // 자동 갱신 설정
    tempTimer = setInterval(function(){
        if(tempAuto) fetchTempCurrent();
    }, 10000); // 10s

    setInterval(fetchAlarm, 30000); // 알람 30s
    setInterval(fetchHeatList, 60000); // 작업목록 60s

    // 버튼 이벤트
    $("#btnRefresh").on("click", function(){ fetchHeatTop(); fetchTempCurrent(); updateLastUpdated(); });
    $("#btnRefreshAll").on("click", function(){ refreshAll(); });
    $("#btnLoadAlarm").on("click", function(){ fetchAlarm(); });
    $("#btnToggleAuto").on("click", function(){
        tempAuto = !tempAuto;
        $(this).text(tempAuto ? "자동(10s)" : "정지");
    });

    // 행 클릭 (테이블 바디에 이벤트 위임)
    $("#tableHeat tbody").on("click","tr", function(){
        $("#tableHeat tbody tr").removeClass("selected");
        $(this).addClass("selected");
        selectedRowData = $(this).data("rowdata");
    });
    $("#tableAlarm tbody").on("click","tr", function(){
        $("#tableAlarm tbody tr").removeClass("selected");
        $(this).addClass("selected");
        selectedRowData = $(this).data("rowdata");
    });
    $("#tableHeatTop tbody").on("click","tr", function(){
        $("#tableHeatTop tbody tr").removeClass("selected");
        $(this).addClass("selected");
        selectedRowData = $(this).data("rowdata");
    });
	
  $("#lotModal").dialog({
	    autoOpen: false,
	    modal: true,
	    width: 1300,  // 넓게 해서 스크롤 없음
	    height: 900,
	    resizable: false
  });
  
});

/*바코드 스캔모달 이벤트*/
$("#openModal").click(function() {
  $("#lotModal").dialog("open");
  $("#lotNumber").focus();
  
});

$("#cancelBtn, #closeBtn").click(function() {
  $("#lotModal").dialog("close");
});

$("#applyBtn").click(function() {
    let allData = heatListTable.getData();
    let incomplete = allData.some(row => row.wd_state !== 1);
    let w_msg = ""; // 사용자가 입력한 메세지

    if (incomplete) {
        if (!confirm("스캔 완료되지 않은 항목이 있습니다. 계속 진행하시겠습니까?")) {
            return;
        }

        // ✅ 메세지 입력 받기
        w_msg = prompt("스캔 미완료 사유 또는 메모를 입력해주세요.", "");
        if (w_msg === null) {
            return;
        }
    }

    // wd_state == 0 또는 99 인 항목만 업데이트 대상
    let toUpdate = allData.filter(row => row.wd_state === 0 || row.wd_state === 99);

    // Ajax 요청
    let ajaxCalls = toUpdate.map(row => {
        return $.ajax({
            url: "/line/productionManagement/heatTreatment/barcodeScan",
            type: "post",
            dataType: "json",
            data: {
                w_ci_lot: row.w_ci_lot,
                tong_num: row.wd_tong_num,
                wd_state: 2,
                w_msg: w_msg   // ✅ 이 부분 이름 변경됨
            }
        });
    });

 // 모든 Ajax 완료 후 처리
    $.when.apply($, ajaxCalls).done(function() {
        alert("레시피 적용 로직 실행 및 대기중(2) 상태 업데이트 완료");
        heatListTable.replaceData(allData); 
        tongListInit();

        // ✅ 마지막 D500 호출 - w_ci_lot 배열 전송
        let w_ci_lots = toUpdate.map(row => row.w_ci_lot); // 배열로 만들기

     // 마지막 D500 호출
        $.ajax({
            url: "/line/productionManagement/heatTreatment/barcodeScanUpdate",
            type: "post",
            dataType: "json",
            data: {
                w_ci_lot: $(".w_ci_lot").val() // 여기서 입력값 가져오기
            },
            success: function(res) {
                console.log(res);
                fetchHeatTop();
            }
        });

    });

});




let heatListTable; 
let scanTimer;

// 🔹 테이블 초기화 (최초 1회만)

function tongListInit() {
  heatListTable = new Tabulator('#dataTable', {
    height: '160px',
    layout: 'fitColumns',
    headerSort: false,
    reactiveData: true,
    columnHeaderVertAlign: "middle",
    rowVertAlign: "middle",
    headerHozAlign: 'center',
    ajaxConfig: { method: 'POST' },
    renderHorizontal: "virtual",
    selectable: true,
    selectableRangeMode: "click",
    placeholder: "조회된 데이터가 없습니다.",
    rowFormatter: function(row) {
      let data = row.getData();
      if(data.wd_state === 0 || data.wd_state === 99){
        row.getElement().style.backgroundColor = "#fffacd"; // 연노랑
      } else if(data.wd_state === 1){
        row.getElement().style.backgroundColor = "#d4edda"; // 연초록
      } else {
        row.getElement().style.backgroundColor = "";
      }
    },
    columns: [
      { title: "No", formatter: "rownum", hozAlign: "center", width: 70 },
      { title: "통 번호", field: "wd_tong_num", width: 220, hozAlign: "center" },
      { 
        title: "상태", 
        field: "wd_state",
        hozAlign: "center",
        formatter: function(cell) {
          let value = cell.getValue();
          if (value === 0) return "스캔 대기";
          if (value === 1) return "스캔 완료";
          if (value === 2) return "미적용";
          return value;
        },
        // width 제거 → 남은 공간을 자동으로 채움
      },
    ],
  });
}


// 🔹 테이블 데이터 새로 불러오기 (w_ci_lot 포함)
function refreshTongList(w_ci_lot) {
  console.log("테이블 갱신 요청:", w_ci_lot);
  heatListTable.setData("/line/productionManagement/heatTreatment/tongList", { w_ci_lot: w_ci_lot });
}


//🔹 한글 자모 → qwerty 영타 변환 매핑
function korToEng(str) {
  const map = {
    ㄱ: "r", ㄲ: "R", ㄴ: "s", ㄷ: "e", ㄸ: "E", ㄹ: "f",
    ㅁ: "a", ㅂ: "q", ㅃ: "Q", ㅅ: "t", ㅆ: "T", ㅇ: "d",
    ㅈ: "w", ㅉ: "W", ㅊ: "c", ㅋ: "z", ㅌ: "x", ㅍ: "v", ㅎ: "g",
    ㅏ: "k", ㅐ: "o", ㅑ: "i", ㅒ: "O", ㅓ: "j", ㅔ: "p",
    ㅕ: "u", ㅖ: "P", ㅗ: "h", ㅘ: "hk", ㅙ: "ho", ㅚ: "hl",
    ㅛ: "y", ㅜ: "n", ㅝ: "nj", ㅞ: "np", ㅟ: "nl",
    ㅠ: "b", ㅡ: "m", ㅢ: "ml", ㅣ: "l"
  };

  return str.replace(/[ㄱ-ㅎㅏ-ㅣ]/g, m => map[m] || m);
}


$("#lotNumber").on("input", function () {

    // 🔕 한글 → 영타 변환 잠시 비활성화
    /*
    // 1️⃣ 한글 → 영타 자동 변환
    let converted = korToEng(this.value);

    // 2️⃣ 영어/숫자/하이픈(-) 외 문자 제거
    converted = converted.replace(/[^a-zA-Z0-9-]/g, "");

    // 3️⃣ 대문자로 변환
    converted = converted.toUpperCase();

    // 4️⃣ input 반영
    if (this.value !== converted) {
        this.value = converted;
    }
    */

    // 🔻 기존 스캔 타이머 로직 유지
    clearTimeout(scanTimer);
    let self = this;

    scanTimer = setTimeout(function () {

        if (self.value) {
            let lotValue = self.value.trim();

            $.ajax({
                url: "/line/productionManagement/heatTreatment/barcodeScan",
                type: "post",
                dataType: "json",
                data: {
                    w_ci_lot: lotValue,
                    tong_num: lotValue
                },
                success: function (result) {
                    if (result.gb == 1) {
                        var data = result.data;
                        for (var d in data) {
                            $("." + d).val(data[d]);
                        }
                        refreshTongList(lotValue);
                        $("#lotNumber").val("").focus();
                    } else {
                        alert(result.data);
                        $("#lotNumber").val("").focus();
                        refreshTongList(lotValue);
                    }
                },
                error: function (xhr, status, error) {
                    console.error("barcodeScan 요청 실패:", error);
                }
            });
        }

    }, 1000);
});


// 🔹 페이지 로드 시 테이블 초기화
$(document).ready(function () {
  tongListInit();
});






/*작업현황 그 외 함수*/




        function updateLastUpdated(){
            var d = new Date();
            var hh = String(d.getHours()).padStart(2,'0');
            var mm = String(d.getMinutes()).padStart(2,'0');
            var ss = String(d.getSeconds()).padStart(2,'0');
            $("#lastUpdated").text(hh+":"+mm+":"+ss);
        }

        function refreshAll(){
            fetchHeatTop();
            fetchHeatList();
            fetchAlarm();
            fetchTempCurrent();
            updateLastUpdated();
        }

        /* ---------- getHeatList_1 (요약) ---------- */
        function fetchHeatTop(){
        	   // 오늘 날짜 yyyy-MM-dd 형식
            var today = new Date();
            var yyyy = today.getFullYear();
            var mm = String(today.getMonth() + 1).padStart(2, '0'); // 월은 0~11이므로 +1
            var dd = String(today.getDate()).padStart(2, '0');
            var todayStr = yyyy + '-' + mm + '-' + dd;
            $.ajax({
                url: "/line/productionManagement/heatTreatment/list_1",
                method: "POST",
                data: { w_date: todayStr },
                dataType: "json",
                success: function(resp){
                    updateLastUpdated();
                    // resp가 배열인지 객체인지 유연하게 처리
                    var arr = Array.isArray(resp) ? resp : (resp.data || resp.rows || (resp ? [resp] : []));
                    var $tbody = $("#tableHeatTop tbody").empty();
                    if(!arr || arr.length===0){
                        $tbody.append('<tr><td colspan="5">조회된 데이터가 없습니다.</td></tr>');
                        $("#kpi_lot").text("-");
                        $("#kpi_qf").text("-");
                        $("#tong_count").text("-");
                        return;
                    }
                    arr.forEach(function(r, idx){
                        var tr = $("<tr></tr>");
                        tr.append("<td>"+(r.w_sdatetime || "")+"</td>");
                        tr.append("<td>"+(r.item_name || "")+"</td>");
                        tr.append("<td>"+(r.item_no || "")+"</td>");
                        tr.append("<td class='temp'>"+(r.q1_zone != null ? r.q1_zone : "")+"</td>");
                        tr.append("<td class='cp'>"+(r.cp != null ? r.cp : "")+"</td>");
                        tr.data("rowdata", r);
                        $tbody.append(tr);
                    });
                    // KPI에는 첫 행 표시
                 // KPI 표시
                    var first = arr[0];
                    $("#kpi_lot").text(first.w_ci_lot || "-");
                    $("#kpi_qf").text(first.q1_zone != null ? first.q1_zone : "-");
                    $("#kpi_cp").text(first.cp != null ? first.cp : "-");
                    $("#tong_count").text(first.tong_count != null ? first.tong_count : "-");

                    // 실시간 KPI 시간 시작
                    startKpiTimer(first.w_sdatetime);


                    
                },
                error: function(xhr){
                    console.error("getHeatList_1 error", xhr);
                }
            });
        }







        /* ---------- getHeatList_2 (다음 작업) ---------- */
        function fetchHeatTop2(){
            // 오늘 날짜 yyyy-MM-dd 형식
            var today = new Date();
            var yyyy = today.getFullYear();
            var mm = String(today.getMonth() + 1).padStart(2, '0');
            var dd = String(today.getDate()).padStart(2, '0');
            var todayStr = yyyy + '-' + mm + '-' + dd;

            $.ajax({
                url: "/line/productionManagement/heatTreatment/list_next",
                method: "POST",
                data: { w_date: todayStr },
                dataType: "json",
                success: function(resp){
                    updateLastUpdated();
                    var arr = Array.isArray(resp) ? resp : (resp.data || resp.rows || (resp ? [resp] : []));
                    var $tbody = $("#tableHeatTop2 tbody").empty();

                    if(!arr || arr.length === 0){
                        $tbody.append('<tr><td colspan="5">조회된 데이터가 없습니다.</td></tr>');
                        return;
                    }

                    arr.forEach(function(r){
                        var tr = $("<tr></tr>");
                        tr.append("<td>"+(r.w_sdatetime || "")+"</td>");
                        tr.append("<td>"+(r.item_name || "")+"</td>");
                        tr.append("<td>"+(r.item_no || "")+"</td>");
                        tr.append("<td class='temp'>"+(r.q1_zone != null ? r.q1_zone : "")+"</td>");
                        tr.append("<td class='cp'>"+(r.cp != null ? r.cp : "")+"</td>");
                        tr.data("rowdata", r);
                        $tbody.append(tr);
                    });
                },
                error: function(xhr){
                    console.error("getHeatList_2 (list_next) error", xhr);
                }
            });
        }












        


        var startTime = null; // 진행 중 작업 시작 시간

        function startKpiTimer(w_sdatetime){
            if(!w_sdatetime){
                $("#kpi_time").text("-");
                return;
            }

            // 문자열 → Date 객체
            startTime = new Date(w_sdatetime.replace(/-/g, '/'));

            // 기존 타이머가 있으면 제거
            if(window.kpiTimer) clearInterval(window.kpiTimer);

            // 1초마다 업데이트
            window.kpiTimer = setInterval(function(){
                var now = new Date();
                var diffMs = now - startTime;

                var diffH = Math.floor(diffMs / 1000 / 60 / 60);
                var diffM = Math.floor(diffMs / 1000 / 60) % 60;
                var diffS = Math.floor(diffMs / 1000) % 60;

                var timeStr = diffH.toString().padStart(2,'0') + ":" +
                              diffM.toString().padStart(2,'0') + ":" +
                              diffS.toString().padStart(2,'0');
                $("#kpi_time").text(timeStr);
            }, 1000);
        }









        

        /* ---------- getHeatList (상세 목록) ---------- */
        function fetchHeatList(){
            // 오늘 날짜 yyyy-MM-dd 형식
            var today = new Date();
            var yyyy = today.getFullYear();
            var mm = String(today.getMonth() + 1).padStart(2, '0'); // 월은 0~11이므로 +1
            var dd = String(today.getDate()).padStart(2, '0');
            var todayStr = yyyy + '-' + mm + '-' + dd;

            $.ajax({
                url: "/line/productionManagement/heatTreatment/list_10",
                method: "POST",
                data: { w_date: todayStr },
                dataType: "json",
                success: function(resp){
                   // console.log("fetchHeatList resp:", resp);

                    updateLastUpdated();
                    var arr = Array.isArray(resp) ? resp : (resp.data || resp.rows || (resp ? [resp] : []));
                    var $tbody = $("#tableHeat tbody").empty();
                    if(!arr || arr.length===0){
                        $tbody.append('<tr><td colspan="12">조회된 데이터가 없습니다.</td></tr>');
                        return;
                    }
                    arr.forEach(function(r){
                        var tr = $("<tr></tr>");
                        tr.append("<td>"+(r.w_ci_lot || "")+"</td>");
                        tr.append("<td>"+(r.erp_jack_no  || "")+"</td>");
                        tr.append("<td>"+(r.cust_name || "")+"</td>");
                        tr.append("<td>"+(r.item_no || "")+"</td>");
                        tr.append("<td>"+(r.item_name || "")+"</td>");
                        tr.append("<td>"+(r.d370  || "")+"</td>");
                        tr.append("<td>"+(r.x111 || "")+"</td>");
                      /*   tr.append("<td>"+(r.w_intime!=null?r.w_intime:"")+"</td>");  투입 시간이였음*/
                      tr.append("<td>&nbsp;</td>"); 
                        tr.append("<td class='temp'>"+(r.q1_zone != null ? r.q1_zone : "")+"</td>");
                        tr.append("<td class='temp'>"+(r.t1_zone != null ? r.t1_zone : "")+"</td>");
                        tr.append("<td class='cp'>"+(r.cp != null ? r.cp : "")+"</td>");

                        tr.append("<td>"+(r.l20 || "")+"</td>");
                        tr.data("rowdata", r);
                        $tbody.append(tr);
                    });
                },
                error: function(xhr){
                    console.error("getHeatList error", xhr);
                }
            });
        }


        /* ---------- Alarm ---------- */
        function fetchAlarm(){
            $.ajax({
                url: "/line/productionManagement/alarmRecord/list",
                method: "POST",
                dataType: "json",
                success: function(resp){
                    updateLastUpdated();
                    var arr = Array.isArray(resp) ? resp : (resp.data || resp.rows || (resp ? [resp] : []));
                    var $tbody = $("#tableAlarm tbody").empty();
                    if(!arr || arr.length === 0){
                        $tbody.append('<tr><td colspan="5">조회된 데이터가 없습니다.</td></tr>');
                        return;
                    }

                    arr.forEach(function(r, idx){
                        var tr = $("<tr></tr>");
                        tr.append("<td>"+(r.idx!=null?r.idx:"")+"</td>");
                      /*   tr.append("<td>"+(r.a_addr || "")+"</td>"); */
                        tr.append("<td>"+(r.a_desc || "")+"</td>");
                     
                        tr.append("<td>"+(r.a_stime || "")+"</td>");
                        tr.append("<td>"+(r.a_etime || "")+"</td>");
                        tr.data("rowdata", r);

   /*                      // ✅ 진행 중인 알람 시각적 강조
                        if(!r.a_etime || r.a_etime === ""){
                            tr.css({
                                "background": "linear-gradient(90deg, rgba(255,230,0,0.2), rgba(255,255,255,0))",
                                "font-weight": "bold",
                                "color": "#b30000"  // 빨간색 글씨
                            });
                            tr.append("<td style='color:#b30000; font-weight:bold;'>진행 중</td>");
                        } else {
                            tr.append("<td>-</td>");
                        } */

                        $tbody.append(tr);
                    });
                },
                error: function(xhr){
                    console.error("fetchAlarm error", xhr);
                }
            });
        }








        /* ---------- Temp Current (getLatestTrend → 라인 흐름 PV 보드) ---------- */
// 각 존: pv/sv 필드, 단위, 편차 임계값(주의/이상). CP 는 ‰ 단위 원값 → % 로 환산
var PV_LINES = [
    { cls:"q", lane:"소입로", cells:[
        { stage:"전처리 세정", name:"전세정기", pv:"f_wash_pv", sv:"f_wash_sp", unit:"℃", svDef:60 },
        { stage:"소입로 1~5존", grp:[1,2,3,4,5].map(function(n){ return { name:n+"존", pv:"q_pv_"+n, sv:"q_sp_"+n, unit:"℃" }; }) },
        { stage:"냉각", name:"소입유조", pv:"oil_pv", sv:"oil_sp", unit:"℃", svDef:80 },
        { stage:"분위기", name:"CP-A", pv:"cp_pv_1", sv:"cp_sp_1", unit:"%", cp:true }
    ]},
    { cls:"t", lane:"소려로", cells:[
        { stage:"중간 세정", name:"중간세정기", pv:"m_wash_pv", sv:"m_wash_sp", unit:"℃", svDef:55 },
        { stage:"소려로 1~5존", grp:[1,2,3,4,5].map(function(n){ return { name:n+"존", pv:"t_pv_"+n, sv:"t_sp_"+n, unit:"℃" }; }) },
        { stage:"방청", name:"방청조", pv:"bc_pv", sv:"bc_sp", unit:"℃", svDef:40 },
        { stage:"분위기", name:"CP-B", pv:"cp_pv_2", sv:"cp_sp_2", unit:"%", cp:true }
    ]}
];

function pvTileHtml(z, sep){
    return '<td class="pv-tile' + (sep ? ' sep' : '') + '" data-pv="' + z.pv + '" title="' + z.name + '">' +
        '<div class="pv-val"><b>-</b><i>' + z.unit + '</i></div>' +
        '<div class="pv-foot"><span class="pv-sv">SV <em>-</em></span><span class="pv-dev"></span></div>' +
        '</td>';
}

// 라인(행) × 구간(열) 매트릭스: 세정 | 1~5존 | 유조·방청 | CP
function ensurePvBoard(){
    var $b = $("#pvBoard");
    if(!$b.length || $b.children().length) return;
    var h = '<table class="pvm"><colgroup><col class="h">' + new Array(9).join('<col>') + '</colgroup>' +
        '<thead><tr><th></th><th>세정</th><th class="grp">1존</th><th class="grp">2존</th><th class="grp">3존</th>' +
        '<th class="grp">4존</th><th class="grp">5존</th><th>유조·방청</th><th>CP</th></tr></thead><tbody>';
    PV_LINES.forEach(function(line){
        h += '<tr><td class="rh">' + line.lane + '</td>';
        line.cells.forEach(function(c, i){
            if(c.grp) h += c.grp.map(function(z, j){ return pvTileHtml(z, j === 0); }).join("");
            else h += pvTileHtml(c, i > 0);
        });
        h += '</tr>';
    });
    $b.html(h + '</tbody></table>');
}
$(ensurePvBoard);
$(document).on("click", "#btnToggleAuto", function(){ $(this).toggleClass("is-paused", !tempAuto); });

function pvNum(v){ var n = parseFloat(v); return isNaN(n) ? null : n; }

function renderPvBoard(obj){
    ensurePvBoard();
    var cnt = { ok:0, warn:0, bad:0 };
    PV_LINES.forEach(function(line){
        line.cells.forEach(function(c){
            (c.grp || [c]).forEach(function(z){
                var $t = $('#pvBoard .pv-tile[data-pv="' + z.pv + '"]');
                var pv = obj ? pvNum(obj[z.pv]) : null;
                var sv = obj ? pvNum(obj[z.sv]) : null;
                $t.removeClass("ok warn bad");
                if(pv == null){
                    $t.find(".pv-val b").text("-"); $t.find(".pv-sv em").text("-"); $t.find(".pv-dev").text("-");
                    $t.find(".pv-meter s").css("left", "50%");
                    return;
                }
                var dec, lim1, lim2;
                if(z.cp){
                    pv = pv / 1000; sv = sv != null ? sv / 1000 : Math.round(pv * 100) / 100;
                    dec = 2; lim1 = 0.02; lim2 = 0.04;
                } else {
                    if(sv == null) sv = z.svDef != null ? z.svDef : Math.round(pv / 10) * 10;
                    dec = 1; lim1 = 5; lim2 = 10;
                }
                var d = pv - sv, ad = Math.abs(d);
                var st = ad <= lim1 ? "ok" : (ad <= lim2 ? "warn" : "bad");
                cnt[st]++;
                $t.addClass(st);
                $t.find(".pv-val b").text(z.cp ? pv.toFixed(2) : (Math.round(pv * 10) / 10).toFixed(1));
                $t.find(".pv-sv em").text(z.cp ? sv.toFixed(2) : String(Math.round(sv * 10) / 10));
                $t.find(".pv-dev").text((d >= 0 ? "+" : "−") + Math.abs(d).toFixed(dec));
                var pos = 50 + Math.max(-1, Math.min(1, d / (lim2 * 1.5))) * 50;
                $t.find(".pv-meter s").css("left", pos.toFixed(1) + "%");
            });
        });
    });
    var $s = $("#pvSummary");
    $s.find(".ok b").text(obj ? cnt.ok : "-");
    $s.find(".warn b").text(obj ? cnt.warn : "-");
    $s.find(".bad b").text(obj ? cnt.bad : "-");
}

      function fetchTempCurrent(){
    var today = new Date();
    var yyyy = today.getFullYear();
    var mm = String(today.getMonth() + 1).padStart(2,'0');
    var dd = String(today.getDate()).padStart(2,'0');
    var todayStr = yyyy + '-' + mm + '-' + dd;

    $.ajax({
        url: "/line/monitoring/trend/getLatestTrend",
        method: "POST",
        data: { w_date: todayStr },
        dataType: "json",
        success: function(resp){
            updateLastUpdated();
            var obj = Array.isArray(resp) ? (resp[0] || null) : resp || null;
            renderPvBoard(obj);
        },
        error: function(xhr){
            console.error("fetchTempCurrent error", xhr);
        }
    });
}


</script>
</body>
</html>
