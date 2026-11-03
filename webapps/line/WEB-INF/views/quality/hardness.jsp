<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="ko">
<head>
<script src="/line/mock/mock-loader.js"></script>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>경도 관리</title>
	<%@include file="../include/pluginpage.jsp" %>    
    <jsp:include page="../include/tabBar.jsp"/>
</head>
    <style>
        .container {
            display: flex;
            justify-content: space-between;
            padding: 20px;
            margin-left: 1008px;
            margin-top: 200px;
        }
        .view {
            display: flex;
            justify-content: center;
            margin-top: 1%;
        }
        .tab {
            width: 95%;
            margin-bottom: 37px;
            margin-top: 5px;
            height: 45px;
            border-radius: 6px 6px 0px 0px;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }
        .modal {
            display: none;
            position: fixed;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0, 0, 0, 0.5);
            transition: opacity 0.3s ease-in-out;
        }
.modal-content {
    background: white;
    width: 100%;
    max-width: 1100px;
   height: 95vh;
    overflow-y: auto;
    margin: 0% auto 0;
    padding: 14px;
    border-radius: 10px;
    position: relative;
    box-shadow: 0px 4px 10px rgba(0, 0, 0, 0.3);
    transform: scale(0.8);
    transition: transform 0.3s 
ease-in-out, opacity 0.3s 
ease-in-out;
}
        .modal.show {
            display: block;
            opacity: 1;
        }
        .modal.show .modal-content {
            transform: scale(1);
            opacity: 1;
        }
        .close {
            background-color:white;
            position: absolute;
            right: 15px;
            top: 10px;
            font-size: 24px;
            font-weight: bold;
            cursor: pointer;
        }
        .closePumbun {
            background-color:white;
            position: absolute;
            right: 15px;
            top: 10px;
            font-size: 24px;
            font-weight: bold;
            cursor: pointer;
        }
        .modal-content form {
            display: flex;
            flex-direction: column;
        }
        .modal-content label {
            font-weight: bold;
            margin: 10px 0 5px;
        }
        .modal-content input, .modal-content textarea {
            width: 97%;
            padding: 8px;
            margin-bottom: 10px;
            border: 1px solid #ccc;
            border-radius: 5px;
        }
        select {
            width: 100%;
            padding: 8px;
            margin-bottom: 10px;
            border: 1px solid #ccc;
            border-radius: 5px;
        }
        .modal-content button {
            background-color: #d3d3d3;
            color: black;
            padding: 10px;
            border: none;
            border-radius: 5px;
            margin-top: 10px;
            cursor: pointer;
            transition: background-color 0.3s ease;
        }
        .modal-content button:hover {
            background-color: #a9a9a9;
        }
        
        .button-container {
    		display: flex;
		    gap: 10px;
		    margin-left: auto;
		    margin-right: 10px;
		    margin-top: 40px;
		}
		.box1 {
		    display: flex;
		    justify-content: right;
		    align-items: center;
		    width: 800px;
		    margin-right: 20px;
		    margin-top:4px;
		    gap:6px;
		}
        .dayselect {
            width: 20%;
            text-align: center;
            font-size: 15px;
        }
        .daySet {
        	width: 20%;
      		text-align: center;
            height: 16px;
            padding: 8px;
            margin-bottom: 10px;
            border: 1px solid #ccc;
            border-radius: 5px;
            font-size: 15px;
        }
        .daylabel {
            margin-right: 10px;
            margin-bottom: 13px;
            font-size: 18px;
            margin-left: 20px;
        }
        button-container.button{
        height: 16px;
        }
         .mid{
        margin-right: 9px;
	    font-size: 20px;
	    font-weight: bold;
	
	    height: 42px;
	    margin-left: 9px;
        }
        .row_select {
	    background-color: #ffeeba !important;
	    }
	    .excel-download-button,
		.excel-upload-button {
  		  height: 40px;
  		  background-color: white; 
   		 border: 1px solid black; 
   		 border-radius: 4px;
   		 padding: 4px 10px; 
   		 display: flex;
  		  align-items: center;
  		  gap: 5px;
  		  cursor: pointer;
}

.button-image {
    width: 16px; 
    height: 16px;
}

/*품번모달*/
        .pumbunModal {
            display: none;
            position: fixed;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0, 0, 0, 0.5);
            transition: opacity 0.3s ease-in-out;
        }
	    .pumbun-modal-content {
	        background: white;
	        width: 60%;
	        max-width: 1200px;
	        height: 80vh; 
	        overflow-y: auto; 
	        margin: 6% auto 0;
	        padding: 20px;
	        border-radius: 10px;
	        position: relative;
	        box-shadow: 0px 4px 10px rgba(0, 0, 0, 0.3);
	        transform: scale(0.8);
	        transition: transform 0.3s ease-in-out, opacity 0.3s ease-in-out;
	        opacity: 0;
	    }
        .pumbunModal.show {
            display: block;
            opacity: 1;
        }
        .pumbunModal.show .pumbun-modal-content {
            transform: scale(1);
            opacity: 1;
        }


        .pumbun-modal-content button {
            background-color: #d3d3d3;
            color: black;
            padding: 10px;
            border: none;
            border-radius: 5px;
            margin-top: 10px;
            cursor: pointer;
            transition: background-color 0.3s ease;
        }
        .pumbun-modal-content button:hover {
            background-color: #a9a9a9;
        }
        .pumbun-modal-content form {
            display: flex;
            flex-direction: column;
        }
        .pumbun-modal-content label {
            font-weight: bold;
            margin: 10px 0 5px;
        }
        .pumbun-modal-content input, .pumbun-modal-content textarea {
            width: 97%;
            padding: 8px;
            margin-bottom: 10px;
            border: 1px solid #ccc;
            border-radius: 5px;
        }

		.barcode-button {
		    height: 40px;
		    padding: 0 11px;
		    border: 1px solid rgb(53, 53, 53);
		    border-radius: 4px;
		    background-color: #ffffff;
		    cursor: pointer;
		    display: flex;
		    align-items: center;
		}
		
		.form-grid {
	    display: grid;
		    grid-template-columns: repeat(5, 1fr);  /* 👉 5개씩 한 줄 */
		    gap: 18px 20px;                         /* 👉 세로 18px, 가로 20px 간격 */
		    margin-top: 15px;
		}
		
		.form-grid-4 {
		    display: grid;
		    grid-template-columns: repeat(4, 1fr);
		    gap: 1px 10px;
		    /* margin-top: 15px; */
		}
		
		.grid-item {
		    display: flex;
		    flex-direction: column;
		}
		
		.grid-item label {
		    font-size: 13px;
		    margin-bottom: 4px;                     /* 👉 라벨과 input 간격 */
		}
		
		.grid-item input {
		    width: 95%;                             /* 👉 입력칸 너비 넓힘 */
		    padding: 6px 8px;
		    font-size: 14px;
		    box-sizing: border-box;
		    height: 35px;
		}
		
		
		/* 경도 입력 전용 스크롤 */
.scroll-area {
 /*  max-height: 420px;          /* ★ 여기서 길이 조절 */ */
  overflow-y: auto;
  padding-right: 6px;
}

/* 스크롤바 살짝 정리 (선택) */
.scroll-area::-webkit-scrollbar {
  width: 8px;
}
.scroll-area::-webkit-scrollbar-thumb {
  background: rgba(0,0,0,0.25);
  border-radius: 4px;
}

/* 나머지는 기존 CSS 그대로 */
		.form-grid.vertical {
  display: flex;
  flex-direction: column;
  gap: 14px;
}

/* 구역 공통 */
.zone-box {
  border-radius: 10px;
  padding: 10px;
  box-shadow: 0 2px 6px rgba(0,0,0,0.08);
}

.zone-box h1 {
  margin-bottom: 10px;
  font-size: 16px;
  font-weight: 800;
}

/* 색상 */
.zone-cho  { background:#eef6ff; border-left:6px solid #4a90e2; }
.zone-jung { background:#f0f9f0; border-left:6px solid #2ecc71; }
.zone-jong { background:#fff6e8; border-left:6px solid #f5a623; }
.zone-test { background:#f8f0ff; border-left:6px solid #9b59b6; }
.zone-surface { background:#e8fbfa; border-left:6px solid #16a085; }
.zone-twist   { background:#fdf1ee; border-left:6px solid #d35400; }

/* 5칸 고정 */
.zone-grid {
  display: grid;
  grid-template-columns: repeat(5, 1fr);
  gap: 8px;
}

.grid-item label {
  font-size: 12px;
  font-weight: 600;
}

.grid-item input {
  height: 30px;
  text-align: right;
}

.zone-grid select {
  height: 30px;
  margin-bottom: 0;
  text-align: center;
}
.row-lot-0 {
  background-color: #f7f9fc;
}
.row-lot-1 {
  background-color: #e9f1ff;
}

.q-red {
    color: #e53935; /* Quenching */
    font-weight: 600;
}

.q-blue {
    color: #1e88e5; /* Tempering */
    font-weight: 600;
}

		
		.h-out {
    color: #e53935;
    font-weight: 600;
}

.h-in {
    color: #000;
}
		
		
		
		.image-preview-area {
    display: flex;
    gap: 105px;
    margin: 15px 0 10px 0;
    justify-content: center;
}

.image-box {
    display: flex;
    flex-direction: column;
    align-items: center;
}

.img-title {
    font-size: 13px;
    font-weight: 600;
    margin-bottom: 6px;
}

.preview-img {
    width: 280px;
    height: 250px;
    object-fit: cover;
    border-radius: 8px;
    border: 1px solid #ddd;
    cursor: pointer;
    transition: 0.2s;
    display: none; /* 기본 숨김 */
}

.preview-img:hover {
    transform: scale(1.05);
}
    </style>

<body>
    <main class="main">
        <div class="tab">
        

            <div class="button-container">
            
               <div class="box1">
	
	            <label class="daylabel">등록일자 :</label>
	            <input type="text" id="m_sdate" class="dayselect daySet"/>
	            <div style="margin-bottom:10px;">
				 ~
				</div>

	            <input type="text" id="m_edate" class="dayselect daySet"/>
			</div>
                <button class="select-button">
                    <img src="/line/css/tabBar/search-icon.png" alt="select" class="button-image">조회
                </button>
                    <button class="barcode-button">
			        <img src="/line/css/tabBar/barcode-icon.png" alt="barcode" class="button-image">스캔
			    </button>
               <!--  <button class="insert-button">
                    <img src="/line/css/tabBar/add-outline.png" alt="insert" class="button-image">추가
                </button>
                <button class="delete-button">
				    <img src="/line/css/tabBar/xDel3.png" alt="delete" class="button-image"> 삭제
				</button>
                
                
                <button class="excel-download-button">
                    <img src="/line/css/tabBar/excel-icon.png" alt="excel" class="button-image">엑셀다운로드
                </button>
                 -->
                 <button class="excel-button">
                    <img src="/line/css/tabBar/excel-icon.png" alt="excel" class="button-image" >Download
                </button>
            </div>
        </div>

        <div class="view">
            <div id="dataTable"></div>
        </div>
    </main>
    
<div id="modalContainer" class="modal">
  <div class="modal-content">
    <span class="close">&times;</span>
    <!-- 추가, 수정 -->
<h2 id="hardnessTitle" style="font-size: 18px;">
    <span id="hardnessType"></span> 경도 측정값 등록
</h2>



<hr />

<form id="corrForm" autocomplete="off">

<!--   <label>LOT 번호</label>
  <input type="text" name="w_ci_lot">

  <label>등록시간</label>
  <input type="text" name="regtime" class="daySet" style="text-align:left;">

 -->

<div class="form-grid-4">





  <div class="grid-item">
    <label>LOT 번호</label>
    <input type="text" name="w_ci_lot" style="text-align:left;"readonly>
  </div>

  <div class="grid-item">
    <label>등록시간</label>
    <input type="text" name="regtime" style="text-align:left;"readonly>
  </div>

  <div class="grid-item">
    <label>거래처</label>
    <input type="text" name="cust_name"   style="text-align:left;"readonly>
  </div>

  <div class="grid-item">
    <label>품명</label>
    <input type="text" name="item_name"  style="text-align:left;"readonly>
  </div>

  <div class="grid-item">
    <label>품번</label>
    <input type="text" name="item_no"  style="text-align:left;"readonly>
  </div>

  <div class="grid-item">
    <label>규격</label>
    <input type="text" name="spec"  style="text-align:left;"readonly>
  </div>

  <div class="grid-item">
    <label>재질</label>
    <input type="text" name="texture"  style="text-align:left;"readonly>
  </div>

  <div class="grid-item">
    <label>계획수량</label>
    <input type="text" name="w_plan_cnt"  style="text-align:left;"readonly>
  </div>

  <div class="grid-item">
    <label>퀜칭 하한</label>
    <input type="number" name="quench_low"  style="text-align:left;"readonly>
  </div>

  <div class="grid-item">
    <label>퀜칭 상한</label>
    <input type="number" name="quench_high"  style="text-align:left;"readonly>
  </div>

  <div class="grid-item">
    <label>템퍼 하한</label>
    <input type="number" name="temper_low"  style="text-align:left;"readonly>
  </div>

  <div class="grid-item">
    <label>템퍼 상한</label>
    <input type="number" name="temper_high"  style="text-align:left;"readonly>
  </div>
</div>


<div class="image-preview-area">
    <div class="image-box">
        <div class="img-title">검사품 사진3</div>
        <img id="preview_img_3" class="preview-img" />
    </div>

    <div class="image-box">
        <div class="img-title">검사품 사진4</div>
        <img id="preview_img_4" class="preview-img" />
    </div>

    <div class="image-box">
        <div class="img-title">검사품 사진5</div>
        <img id="preview_img_5" class="preview-img" />
    </div>
</div>





<!-- 경도 스크롤 영역 -->
<div class="scroll-area">

  <div class="form-grid vertical">

    <!-- 초몰 -->
    <div class="zone-box zone-cho">
      <!-- <h1>초몰</h1> -->
    <div style="font-size: 15px; font-weight: bold;">초몰</div>


      <div class="zone-grid">
        <div class="grid-item"><label>경도1</label><input type="number" step="0.01" name="h_val1"></div>
        <div class="grid-item"><label>경도2</label><input type="number" step="0.01" name="h_val2"></div>
        <div class="grid-item"><label>경도3</label><input type="number" step="0.01" name="h_val3"></div>
        <div class="grid-item"><label>경도4</label><input type="number" step="0.01" name="h_val4"></div>
        <div class="grid-item"><label>경도5</label><input type="number" step="0.01" name="h_val5"></div>
      </div>
    </div>

  
    <div class="zone-box zone-jung">
      <div style="font-size: 15px; font-weight: bold;">중몰</div>
     <!--  <h1>중몰</h1> -->
      <div class="zone-grid">
        <div class="grid-item"><label>경도6</label><input type="number" step="0.01" name="h_val6"></div>
        <div class="grid-item"><label>경도7</label><input type="number" step="0.01" name="h_val7"></div>
        <div class="grid-item"><label>경도8</label><input type="number" step="0.01" name="h_val8"></div>
        <div class="grid-item"><label>경도9</label><input type="number" step="0.01" name="h_val9"></div>
        <div class="grid-item"><label>경도10</label><input type="number" step="0.01" name="h_val10"></div>
      </div>
    </div>

  
    <div class="zone-box zone-jong">
      <div style="font-size: 15px; font-weight: bold;">종몰</div>
      <!-- <h1>종몰</h1> -->
      <div class="zone-grid">
        <div class="grid-item"><label>경도11</label><input type="number" step="0.01" name="h_val11"></div>
        <div class="grid-item"><label>경도12</label><input type="number" step="0.01" name="h_val12"></div>
        <div class="grid-item"><label>경도13</label><input type="number" step="0.01" name="h_val13"></div>
        <div class="grid-item"><label>경도14</label><input type="number" step="0.01" name="h_val14"></div>
        <div class="grid-item"><label>경도15</label><input type="number" step="0.01" name="h_val15"></div>
      </div>
    </div>


    <div class="zone-box zone-test">
          <div style="font-size: 15px; font-weight: bold;">검사실</div>
      <div class="zone-grid">
        <div class="grid-item"><label>경도16</label><input type="number" step="0.01" name="h_val16"></div>
        <div class="grid-item"><label>경도17</label><input type="number" step="0.01" name="h_val17"></div>
        <div class="grid-item"><label>경도18</label><input type="number" step="0.01" name="h_val18"></div>
        <div class="grid-item"><label>경도19</label><input type="number" step="0.01" name="h_val19"></div>
        <div class="grid-item"><label>경도20</label><input type="number" step="0.01" name="h_val20"></div>
      </div>
    </div>

    <!-- Tempering 전용: 표면경도 / 비틀림 시험 -->
    <div class="zone-box zone-surface" id="zoneSurface" style="display:none;">
      <div style="font-size: 15px; font-weight: bold;">표면경도 (HRC 40~46, 측정위치: 깊이 0.05)</div>
      <div class="zone-grid">
        <div class="grid-item"><label>표면경도1</label><input type="number" step="0.01" name="h_val21"></div>
        <div class="grid-item"><label>표면경도2</label><input type="number" step="0.01" name="h_val22"></div>
        <div class="grid-item"><label>표면경도3</label><input type="number" step="0.01" name="h_val23"></div>
        <div class="grid-item"><label>표면경도4</label><input type="number" step="0.01" name="h_val24"></div>
        <div class="grid-item"><label>표면경도5</label><input type="number" step="0.01" name="h_val25"></div>
      </div>
    </div>

    <div class="zone-box zone-twist" id="zoneTwist" style="display:none;">
      <div style="font-size: 15px; font-weight: bold;">비틀림 시험 (90&deg; 미만에서 파단 않을 것)</div>
      <div class="zone-grid">
        <div class="grid-item"><label>비틀림1</label>
          <select name="h_val26_s"><option value="">선택</option><option value="OK">OK</option><option value="NG">NG</option></select>
        </div>
        <div class="grid-item"><label>비틀림2</label>
          <select name="h_val27_s"><option value="">선택</option><option value="OK">OK</option><option value="NG">NG</option></select>
        </div>
        <div class="grid-item"><label>비틀림3</label>
          <select name="h_val28_s"><option value="">선택</option><option value="OK">OK</option><option value="NG">NG</option></select>
        </div>
        <div class="grid-item"><label>비틀림4</label>
          <select name="h_val29_s"><option value="">선택</option><option value="OK">OK</option><option value="NG">NG</option></select>
        </div>
        <div class="grid-item"><label>비틀림5</label>
          <select name="h_val30_s"><option value="">선택</option><option value="OK">OK</option><option value="NG">NG</option></select>
        </div>
      </div>
    </div>

  </div>
</div>


  <input type="hidden" name="idx" value="0" />
  <hr />
  <button type="submit" id="saveCorrStatus">저장</button>
  <button type="button" id="closeModal">닫기</button>
</form>


  </div>
</div>



  <script>
let now_page_code = "e06";

var dataTable;
var selectedRowData = null;

$(function() {
    // 기본 날짜 세팅
    $("#m_sdate").val(todayDate()); // 어제
    $("#m_edate").val(todayDate());   // 오늘

    // Tabulator 초기화
    initDataTable();

    // 초기 데이터 로드
    gethardnessList();
});


$(document).on('input change', 'input[name^="h_val"], select[name^="h_val"]', function () {
    validateHardnessRange();
});


$(document).on('keydown', '#corrForm input', function (e) {
    if (e.key === 'Enter') {
        e.preventDefault(); // submit 차단

        const inputs = $('#corrForm')
            .find('input:visible:not([readonly]):not([disabled])');

        const idx = inputs.index(this);

        if (idx > -1 && idx < inputs.length - 1) {
            inputs.eq(idx + 1).focus();
        }
    }
});



// =====================
// 이벤트 바인딩
// =====================
$('.select-button').click(function() {
    gethardnessList();
});

$('.insert-button').click(function() {
    selectedRowData = null;
    $('#corrForm')[0].reset();
    $("input[name='m_date']").val(todayDate());
    $('#modalContainer').show().addClass('show');
});

$('.close, #closeModal').click(function() {
    $('#corrForm')[0].reset();
    $('#modalContainer').removeClass('show').hide();
});

$('#saveCorrStatus').click(function(event) {
    event.preventDefault();
    var formData = new FormData($('#corrForm')[0]);

    $.ajax({
        url: "/line/quality/hardness/update",
        type: "POST",
        data: formData,
        processData: false,
        contentType: false,
        success: function(result) {
            if(result.status === "success"){
                alert("저장되었습니다!");
                $('#modalContainer').hide();
                gethardnessList();
                selectedRowData = null;
            } else {
                alert("저장 실패: " + result.message);
            }
        },
        error: function() {
            alert('저장 중 오류가 발생했습니다.');
        }
    });
});

// =====================
// 함수 정의
// =====================
     let lastLot = null;
        let colorToggle = 0;
// Tabulator 초기화
function initDataTable(){
    dataTable = new Tabulator('#dataTable', {
        height: '700px',
        layout: 'fitDataFill',
        headerSort: false,
        reactiveData: true,
        columnHeaderVertAlign: "middle",
        rowVertAlign: "middle",
        headerHozAlign: 'center',
        placeholder: "조회된 데이터가 없습니다.",
        columns: [
/*             { 
                title: "No", 
                field: "no", 
                hozAlign: "center", 
                headerHozAlign: "center",
                formatter: "rownum", 
                width: 100
            }, */
            { 
                title: "idx", 
                field: "idx", 
                visible: false,      // 화면에는 안 보임
                headerSort: true     // 정렬 기능은 활성화
            },
            { 
                title: "LOT 번호",
                field: "w_ci_lot",
                width: 180,
                hozAlign: "center",
                headerHozAlign: "center",
                headerFilter: "input",
                headerFilterPlaceholder: "검색..."
            },
            { 
                title: "고객명",
                field: "cust_name",
                width: 120,
                hozAlign: "left",
                headerHozAlign: "center",
                headerFilter: "input",
                headerFilterPlaceholder: "검색..."
            },
            { 
                title: "품명",
                field: "item_name",
                width: 250,
                hozAlign: "left",
                headerHozAlign: "center",
                headerFilter: "input",
                headerFilterPlaceholder: "검색..."
            },
            { 
                title: "품번",
                field: "item_no",
                width: 120,
                hozAlign: "left",
                headerHozAlign: "center",
                headerFilter: "input",
                headerFilterPlaceholder: "검색..."
            },
            { 
                title: "구분",
                field: "q_or_tp",
                width: 140,
                hozAlign: "center",
                headerHozAlign: "center",
                headerFilter: "select",
                headerFilterParams: {
                    values: {
                        "": "전체",
                        "Quenching 경도": "Quenching 경도",
                        "Tempering 경도": "Tempering 경도"
                    }
                }
            },

            { title: "퀜칭 하한", field: "quench_low", width: 90, hozAlign: "right" },
            { title: "퀜칭 상한", field: "quench_high", width: 90, hozAlign: "right" },
            { title: "템퍼 하한", field: "temper_low", width: 90, hozAlign: "right" },
            { title: "템퍼 상한", field: "temper_high", width: 90, hozAlign: "right" },
            {
                title: "초몰",
                headerHozAlign: "center",
                columns: [
                  { title: "경도1", field: "h_val1", width: 90, hozAlign: "center" },
                  { title: "경도2", field: "h_val2", width: 90, hozAlign: "center" },
                  { title: "경도3", field: "h_val3", width: 90, hozAlign: "center" },
                  { title: "경도4", field: "h_val4", width: 90, hozAlign: "center" },
                  { title: "경도5", field: "h_val5", width: 90, hozAlign: "center" }
                ]
              },

              {
                title: "중몰",
                headerHozAlign: "center",
                columns: [
                  { title: "경도6", field: "h_val6", width: 90, hozAlign: "center" },
                  { title: "경도7", field: "h_val7", width: 90, hozAlign: "center" },
                  { title: "경도8", field: "h_val8", width: 90, hozAlign: "center" },
                  { title: "경도9", field: "h_val9", width: 90, hozAlign: "center" },
                  { title: "경도10", field: "h_val10", width: 90, hozAlign: "center" }
                ]
              },

              {
                title: "종몰",
                headerHozAlign: "center",
                columns: [
                  { title: "경도11", field: "h_val11", width: 90, hozAlign: "center" },
                  { title: "경도12", field: "h_val12", width: 90, hozAlign: "center" },
                  { title: "경도13", field: "h_val13", width: 90, hozAlign: "center" },
                  { title: "경도14", field: "h_val14", width: 90, hozAlign: "center" },
                  { title: "경도15", field: "h_val15", width: 90, hozAlign: "center" }
                ]
              },

              {
                title: "검사실",
                headerHozAlign: "center",
                columns: [
                  { title: "경도16", field: "h_val16", width: 90, hozAlign: "center" },
                  { title: "경도17", field: "h_val17", width: 90, hozAlign: "center" },
                  { title: "경도18", field: "h_val18", width: 90, hozAlign: "center" },
                  { title: "경도19", field: "h_val19", width: 90, hozAlign: "center" },
                  { title: "경도20", field: "h_val20", width: 90, hozAlign: "center" }
                ]
              },
/*               { title: "거래처", field: "cust_name", width: 90, hozAlign: "center" },
              { title: "품명", field: "item_name", width: 120, hozAlign: "center" },
              { title: "품번", field: "item_no", width: 120, hozAlign: "center" },
              { title: "규격", field: "spec", width: 120, hozAlign: "center" },
              { title: "재질", field: "texture", width: 80, hozAlign: "center" }, */
              { title: "경도_이미지3", field: "img_url_3", width: 90, hozAlign: "right" },
              { title: "경도_이미지4", field: "img_url_4", width: 90, hozAlign: "right" },
              { title: "경도_이미지5", field: "img_url_5", width: 90, hozAlign: "right" },

            
        ],
   

        rowFormatter: function(row) {
            const data = row.getData();
            const el = row.getElement();

            // 재렌더 대비 초기화
            el.classList.remove("row-lot-0", "row-lot-1");

            // LOT가 바뀌는 시점에만 색 전환
            if (data.w_ci_lot !== lastLot) {
                colorToggle = (colorToggle + 1) % 2;
                lastLot = data.w_ci_lot;
            }

            el.classList.add("row-lot-" + colorToggle);
        },


        rowClick: function(e, row) {
            $('#dataTable .tabulator-row').removeClass('row_select');
            row.getElement().classList.add('row_select');
            selectedRowData = row.getData();
        },
        rowDblClick: function(e, row) {
            const d = row.getData();
            selectedRowData = d;

            const $type = $('#hardnessType');

            if (d.q_or_tp === 'Quenching 경도') {
                $type
                    .text('Quenching')
                    .removeClass('q-blue')
                    .addClass('q-red');
                $('#zoneSurface, #zoneTwist').hide();
            } else if (d.q_or_tp === 'Tempering 경도') {
                $type
                    .text('Tempering')
                    .removeClass('q-red')
                    .addClass('q-blue');
                $('#zoneSurface, #zoneTwist').show();
            } else {
                // 예외 대비
                $type.text(d.q_or_tp).removeClass('q-red q-blue');
                $('#zoneSurface, #zoneTwist').hide();
            }






            
            $('#corrForm')[0].reset();

            $('input[name="idx"]').val(d.idx);
            $('input[name="w_ci_lot"]').val(d.w_ci_lot);
            $('input[name="regtime"]').val(d.regtime);
            $('input[name="cust_name"]').val(d.cust_name);
            $('input[name="item_name"]').val(d.item_name);
            $('input[name="item_no"]').val(d.item_no);
            $('input[name="spec"]').val(d.spec);
            $('input[name="texture"]').val(d.texture);
            $('input[name="w_plan_cnt"]').val(d.w_plan_cnt);
            $('input[name="quench_low"]').val(d.quench_low);
            $('input[name="quench_high"]').val(d.quench_high);
            $('input[name="temper_low"]').val(d.temper_low);
            $('input[name="temper_high"]').val(d.temper_high);

            setPreviewImage("preview_img_3", d.img_url_3);
            setPreviewImage("preview_img_4", d.img_url_4);
            setPreviewImage("preview_img_5", d.img_url_5);
            // 경도 자동 매핑
            for (let i = 1; i <= 25; i++) {
                $('input[name="h_val' + i + '"]').val(d['h_val' + i]);
            }
            for (let i = 26; i <= 30; i++) {
                $('select[name="h_val' + i + '_s"]').val(d['h_val' + i + '_s'] || '');
            }

            $('#modalContainer').show().addClass('show');
            validateHardnessRange();

        }

    });
}

// Hardness 조회
function gethardnessList(){
    if(!dataTable) return;

    $.ajax({
        url: "/line/quality/hardness/list",
        type: "POST",
        dataType: "json",
        data:{
            "m_sdate": $("#m_sdate").val(),
            "m_edate": $("#m_edate").val()
        },
        success:function(result){
            if(result.status === "success"){
                dataTable.setData(result.data || []);
            } else {
                alert("조회 실패: " + result.message);
            }
        },
        error:function(xhr, status, error){
            console.error(xhr.responseText);
            alert("조회 중 오류 발생");
        }
    });
}

// 날짜 관련 함수
function todayDate() {
    var d = new Date();
    return d.getFullYear() + "-" + pad(d.getMonth()+1) + "-" + pad(d.getDate());
}

function yesterDate() {
    var d = new Date();
    d.setDate(d.getDate()-1);
    return d.getFullYear() + "-" + pad(d.getMonth()+1) + "-" + pad(d.getDate());
}

function pad(n){ return n<10 ? "0"+n : n; }




$('.barcode-button').click(function() {
    var lotNo = prompt("스캔된 LOT 번호를 입력하세요:");
    if(!lotNo) return;

    $.ajax({
        url: "/line/quality/hardness/list", // 기존 조회 컨트롤러 재사용
        type: "POST",
        dataType: "json",
        data: {
            "m_sdate": "",   // 전체 조회 가능
            "m_edate": "",
            "w_ci_lot": lotNo // Lot 번호 기준 필터
        },
        success:function(result){
            if(result.status === "success"){
                dataTable.setData(result.data || []);
                if(result.data && result.data.length > 0){
                    var d = result.data[0];
                    selectedRowData = d;

                    $('#corrForm')[0].reset();

                    var $type = $('#hardnessType');
                    if (d.q_or_tp === 'Quenching 경도') {
                        $type.text('Quenching').removeClass('q-blue').addClass('q-red');
                        $('#zoneSurface, #zoneTwist').hide();
                    } else if (d.q_or_tp === 'Tempering 경도') {
                        $type.text('Tempering').removeClass('q-red').addClass('q-blue');
                        $('#zoneSurface, #zoneTwist').show();
                    } else {
                        $type.text(d.q_or_tp).removeClass('q-red q-blue');
                        $('#zoneSurface, #zoneTwist').hide();
                    }

                    $('input[name="idx"]').val(d.idx);
                    $('input[name="w_ci_lot"]').val(d.w_ci_lot);
                    $('input[name="regtime"]').val(d.regtime);

                    $('input[name="cust_name"]').val(d.cust_name);
                    $('input[name="item_name"]').val(d.item_name);
                    $('input[name="item_no"]').val(d.item_no);
                    $('input[name="spec"]').val(d.spec);
                    $('input[name="texture"]').val(d.texture);
                    $('input[name="w_plan_cnt"]').val(d.w_plan_cnt);
                    $('input[name="quench_low"]').val(d.quench_low);
                    $('input[name="quench_high"]').val(d.quench_high);
                    $('input[name="temper_low"]').val(d.temper_low);
                    $('input[name="temper_high"]').val(d.temper_high);

                    for (let i = 1; i <= 25; i++) {
                        $('input[name="h_val' + i + '"]').val(d['h_val' + i]);
                    }
                    for (let i = 26; i <= 30; i++) {
                        $('select[name="h_val' + i + '_s"]').val(d['h_val' + i + '_s'] || '');
                    }

                    setPreviewImage("preview_img_3", d.img_url_3);
                    setPreviewImage("preview_img_4", d.img_url_4);
                    setPreviewImage("preview_img_5", d.img_url_5);

                    $('#modalContainer').show().addClass('show');
                    validateHardnessRange();
                } else {
                    alert("해당 LOT 번호 데이터가 없습니다.");
                }
            } else {
                alert("조회 실패: " + result.message);
            }
        },

        error:function(xhr, status, error){
            console.error(xhr.responseText);
            alert("조회 중 오류 발생");
        }
    });
});


//=====================
//경도 합격/불합격 판정
//=====================
function validateHardnessRange() {

 const type = $('#hardnessType').text(); // Quenching / Tempering
 let low, high;

 if (type === 'Quenching') {
     low  = Number($('input[name="quench_low"]').val());
     high = Number($('input[name="quench_high"]').val());
 } else if (type === 'Tempering') {
     low  = Number($('input[name="temper_low"]').val());
     high = Number($('input[name="temper_high"]').val());
 } else {
     return;
 }

 let isPass = true;

 for (let i = 1; i <= 20; i++) {
     const $input = $('input[name="h_val' + i + '"]');
     const val = Number($input.val());

     if (isNaN(val)) {
         $input.removeClass('h-out');
         continue;
     }

     if (val < low || val > high) {
         $input.addClass('h-out');
         isPass = false;
     } else {
         $input.removeClass('h-out');
     }
 }

 // 표면경도 (HRC 40~46, 깊이 0.05) - Tempering 전용, 고정 판정범위
 const SURFACE_LOW = 40, SURFACE_HIGH = 46;
 for (let i = 21; i <= 25; i++) {
     const $input = $('input[name="h_val' + i + '"]');
     const raw = $input.val();
     const val = Number(raw);

     if (raw === '' || isNaN(val)) {
         $input.removeClass('h-out');
         continue;
     }

     if (val < SURFACE_LOW || val > SURFACE_HIGH) {
         $input.addClass('h-out');
         isPass = false;
     } else {
         $input.removeClass('h-out');
     }
 }

 // 비틀림 시험 (90° 미만 파단 없을 것) - NG면 불합격
 for (let i = 26; i <= 30; i++) {
     const $select = $('select[name="h_val' + i + '_s"]');

     if ($select.val() === 'NG') {
         $select.addClass('h-out');
         isPass = false;
     } else {
         $select.removeClass('h-out');
     }
 }

 // 결과 저장
 $('input[name="pass_yn"]').val(isPass ? 'Y' : 'N');
}


$('.excel-button').on('click', function () {
    if (!dataTable) return;

    dataTable.download("xlsx", "경도측정결과.xlsx", {
        sheetName: "Hardness",

        documentProcessing: function (workbook) {
            const sheet = workbook.Sheets["Hardness"];

            sheet["!cols"] = [
                { wch: 14 }, // LOT
                { wch: 14 }, // 고객명
                { wch: 14 }, // 품명
                { wch: 14 }, // 품번
                { wch: 14 }, // 구분

                // 경도 1~20
                { wch: 6 }, { wch: 6 }, { wch: 6 }, { wch: 6 }, { wch: 6 },
                { wch: 6 }, { wch: 6 }, { wch: 6 }, { wch: 6 }, { wch: 6 },
                { wch: 6 }, { wch: 6 }, { wch: 6 }, { wch: 6 }, { wch: 6 },
                { wch: 6 }, { wch: 6 }, { wch: 6 }, { wch: 6 }, { wch: 6 },

                { wch: 9 }, // 퀜칭 하한
                { wch: 9 }, // 퀜칭 상한
                { wch: 9 }, // 템퍼 하한
                { wch: 9 }, // 템퍼 상한
            ];

            return workbook;
        }
    });
});

function setPreviewImage(imgId, fileName) {

    const img = document.getElementById(imgId);

    let finalFileName = fileName;

    // 🔥 파일이 없으면 기본 이미지 사용
    if (!fileName || fileName.trim() === "") {
        finalFileName = "null_img.png";
    }

    const encoded = encodeURIComponent(finalFileName);
    const imgUrl = "/line/standard/product/image?filename=" + encoded;

    img.src = imgUrl;
    img.style.display = "block";

    img.onclick = function () {
        window.open(imgUrl, "_blank");
    };
}
</script>

</body>
</html>