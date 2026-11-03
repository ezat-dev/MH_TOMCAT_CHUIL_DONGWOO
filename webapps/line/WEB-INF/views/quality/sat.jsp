<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="ko">
<head>
<script src="/line/mock/mock-loader.js"></script>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>열전대 비교검증</title>
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
	        width: 24%;
	        max-width: 500px;
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


    </style>

<body>
    <main class="main">
        <div class="tab">
        

            <div class="button-container">
            
               <div class="box1">
	
	            <label class="daylabel">등록일자 :</label>
	            <input type="text" id="s_smonth" class="dayselect daySet"/>
			</div>
                <button class="select-button">
                    <img src="/line/css/tabBar/search-icon.png" alt="select" class="button-image">조회
                </button>
                <button class="insert-button">
                    <img src="/line/css/tabBar/add-outline.png" alt="insert" class="button-image">추가
                </button>
                <button class="delete-button">
				    <img src="/line/css/tabBar/xDel3.png" alt="delete" class="button-image"> 삭제
				</button>
                
                
                <button class="excel-download-button">
                    <img src="/line/css/tabBar/excel-icon.png" alt="excel" class="button-image">엑셀다운로드
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
    <h2>설비 보전항목 등록</h2>
    <hr />
    <form id="corrForm" autocomplete="off">
      <label>등록일</label>
      <input type="text" name="m_date" class="daySet" style="text-align:left;">

      <label>보전항목</label>
      <input type="text" name="m_title">

      <label>상세내용</label>
      <textarea name="m_desc" rows="10" cols="30"></textarea>
      <input type="text" name="m_idx" value="0" style="display:none;" />
		<hr />
		
      <button type="submit" id="saveCorrStatus">저장</button>
      <button type="button" id="closeModal">닫기</button>
    </form>
  </div>
</div>



    
<script>
let now_page_code = "d07";

var dataTable;
var selectedRowData = null;

$(function() {
//	$(".dayselect").val(todayDate());
//	getHeatList();
	$("#s_smonth").val(todayDate().substring(0,7));
	getHeatList();
	getMachineManageList();
});

//이벤트
  $('.select-button').click(function() {
	  getMachineManageList();
//    dataTable.setData("/line/machine/spareStatus/list", { mch_name: sel });
  });

  $('.insert-button').click(function() {
    selectedRowData = null;
    $('#corrForm')[0].reset();
    $("input[name='m_date']").val(todayDate());
    $('#modalContainer').show().addClass('show');
  });

  $('.delete-button').click(function() {
    if (!selectedRowData) {
      alert('삭제할 행을 먼저 클릭해 주세요.');
      return;
    }
    if (!confirm('선택된 항목을 정말 삭제하시겠습니까?')) return;
  
    $.ajax({
      url: "/line/quality/sat/delete",
      type: "POST",
      dataType:"json",
      data: { "m_idx": selectedRowData.m_idx },
      success: function(res) {
        alert('삭제되었습니다.');
        
        getMachineManageList();
        selectedRowData = null;
      },
      error: function() {
        alert('삭제 중 오류가 발생했습니다.');
      }
    });

  });

  $('.close, #closeModal').click(function() {
	  $('#corrForm')[0].reset();
    $('#modalContainer').removeClass('show').hide();
  });
  
  $(".closePumbunModal, .closePumbun").click(function(){
	  $('#pumbunModal').removeClass('show').hide();
  });

  $('#saveCorrStatus').click(function(event) {
    event.preventDefault();
    var formData = new FormData($('#corrForm')[0]);
/*    if (selectedRowData && selectedRowData.no) {
      formData.append('no', selectedRowData.no);
    }*/
    $.ajax({
      url: "/line/quality/sat/save",
      type: "POST",
      data: formData,
      processData: false,
      contentType: false,
      success: function(result) {
      	 
      		 alert("저장되었습니다!");
               $('#modalContainer').hide();
               var currentFilter = $('.dayselect').val() || 'ALL';
               getMachineManageList();              
               selectedRowData = null;
      },
      error: function() {
        alert('저장 중 오류가 발생했습니다.');
      }
    });
  });

  

//엑셀 다운로드
 $('.excel-download-button').click(function() {
	    dataTable.download("xlsx", "스페어부품 관리.xlsx", {sheetName:"스페어부품 관리",
	    	 visibleColumnsOnly: false //숨겨진 데이터도 출력
	    	 });
	});

 $(".excel-upload-button").on("click", function () {
     $("#fileInput").click(); 
 });


//함수
function getMachineManageList(){
	$.ajax({
		url:"/line/quality/sat/list",
		type:"post",
		dataType:"json",
		data:{
			"s_smonth":$("#s_smonth").val()
		},
		success:function(result){
			console.log(result);
			dataTable.setData(result.data);
		}
	});
}

function getHeatList(){
	  dataTable = new Tabulator('#dataTable', {
		    height: '700px',
		    layout: 'fitDataFill',
		    headerSort: false,
		    reactiveData: true,
		    columnHeaderVertAlign: "middle",
		    rowVertAlign: "middle",
		    headerHozAlign: 'center',
		    ajaxConfig: { method: 'POST' },
		    renderHorizontal:"virtual",
//		    ajaxURL: "/line/productionManagement/heatTreatment/list",
		    ajaxProgressiveLoad:"scroll",
//		    ajaxParams: { w_date: $(".daySet").val() },		    
		    ajaxResponse:function(url, params, response){
				$("#dataTable .tabulator-col.tabulator-sortable").css("height","55px");
		        return response; //return the response data to tabulator
		    },
		    placeholder: "조회된 데이터가 없습니다.",
		    columns: [
		      { title: "no", field: "cnt", visible: false, frozen:true}, 
		      { title: "구분",field: "s_gb",width: 300, hozAlign: "left", frozen:true},
		      { title: "기준",field: "s_chk",width: 50, hozAlign: "center", frozen:true},		      
		      { title: "1",field: "s01",width: 50, hozAlign: "center", editor:true },
		      { title: "2",field: "s02",width: 50, hozAlign: "center", editor:true },
		      { title: "3",field: "s03",width: 50, hozAlign: "center", editor:true },
		      { title: "4",field: "s04",width: 50, hozAlign: "center", editor:true },
		      { title: "4",field: "s05",width: 50, hozAlign: "center", editor:true },
		      { title: "5",field: "s06",width: 50, hozAlign: "center", editor:true },
		      { title: "7",field: "s07",width: 50, hozAlign: "center", editor:true },
		      { title: "8",field: "s08",width: 50, hozAlign: "center", editor:true },
		      { title: "9",field: "s09",width: 50, hozAlign: "center", editor:true },
		      { title: "10",field: "s10",width: 50, hozAlign: "center", editor:true },
		      { title: "11",field: "s11",width: 50, hozAlign: "center", editor:true },
		      { title: "12",field: "s12",width: 50, hozAlign: "center", editor:true },
		      { title: "13",field: "s13",width: 50, hozAlign: "center", editor:true },
		      { title: "14",field: "s14",width: 50, hozAlign: "center", editor:true },
		      { title: "14",field: "s15",width: 50, hozAlign: "center", editor:true },
		      { title: "15",field: "s16",width: 50, hozAlign: "center", editor:true },
		      { title: "17",field: "s17",width: 50, hozAlign: "center", editor:true },
		      { title: "18",field: "s18",width: 50, hozAlign: "center", editor:true },
		      { title: "19",field: "s19",width: 50, hozAlign: "center", editor:true },
		      { title: "20",field: "s20",width: 50, hozAlign: "center", editor:true },
		      { title: "21",field: "s21",width: 50, hozAlign: "center", editor:true },
		      { title: "22",field: "s22",width: 50, hozAlign: "center", editor:true },
		      { title: "23",field: "s23",width: 50, hozAlign: "center", editor:true },
		      { title: "24",field: "s24",width: 50, hozAlign: "center", editor:true },
		      { title: "24",field: "s25",width: 50, hozAlign: "center", editor:true },
		      { title: "25",field: "s26",width: 50, hozAlign: "center", editor:true },
		      { title: "27",field: "s27",width: 50, hozAlign: "center", editor:true },
		      { title: "28",field: "s28",width: 50, hozAlign: "center", editor:true },
		      { title: "29",field: "s29",width: 50, hozAlign: "center", editor:true },
		      { title: "30",field: "s30",width: 50, hozAlign: "center", editor:true },
		      { title: "31",field: "s31",width: 50, hozAlign: "center", editor:true },
		    ],

		    rowClick: function(e, row) {
		      $('#dataTable .tabulator-row').removeClass('row_select');
		      row.getElement().classList.add('row_select');
		      selectedRowData = row.getData();
		    },
		    rowFormatter:function(row){
				var row = row;
		    },
			cellEdited: function(cell) {
			    var field = cell.getField(); 
			    var value = cell.getValue(); 
			    var rowData = cell.getRow().getData(); 
			    var cnt = rowData.cnt; 

			    console.log(field, value, cnt);
			    
			    $.ajax({
			        url: "/line/quality/sat/save",
			        type: "POST",
			        dataType:"json",			        
			        data: {
			        	"field":field,
			        	"value":value,
			        	"cnt":cnt
			        },
			        success: function(result) {
			        	
			        }
			    });
			},

		  });
}
</script>
</body>
</html>