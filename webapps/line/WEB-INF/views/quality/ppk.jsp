<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="ko">
<head>
<script src="/line/mock/mock-loader.js"></script>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Ppk</title>
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
        .yearSet {
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
            z-index:19002;
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

/*유저모달*/
        .userModal {
            display: none;
            position: fixed;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0, 0, 0, 0.5);
            transition: opacity 0.3s ease-in-out;
            z-index:19002;
        }
	    .user-modal-content {
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
        .userModal.show {
            display: block;
            opacity: 1;
        }
        .userModal.show .user-modal-content {
            transform: scale(1);
            opacity: 1;
        }


        .user-modal-content button {
            background-color: #d3d3d3;
            color: black;
            padding: 10px;
            border: none;
            border-radius: 5px;
            margin-top: 10px;
            cursor: pointer;
            transition: background-color 0.3s ease;
        }
        .user-modal-content button:hover {
            background-color: #a9a9a9;
        }
        .user-modal-content form {
            display: flex;
            flex-direction: column;
        }
        .user-modal-content label {
            font-weight: bold;
            margin: 10px 0 5px;
        }
        .user-modal-content input, .user-modal-content textarea {
            width: 97%;
            padding: 8px;
            margin-bottom: 10px;
            border: 1px solid #ccc;
            border-radius: 5px;
        }

/*Ppk모달*/
        .ppkModal {
            display: none;
            position: fixed;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0, 0, 0, 0.5);
            transition: opacity 0.3s ease-in-out;
            z-index:19000;
        }
	    .ppk-modal-content {
	        background: white;
	        width: 100%;
	        max-width: 1600px;
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
        .ppkModal.show {
            display: block;
            opacity: 1;
        }
        .ppkModal.show .ppk-modal-content {
            transform: scale(1);
            opacity: 1;
        }


        .ppk-modal-content button {
            background-color: #d3d3d3;
            color: black;
            padding: 10px;
            border: none;
            border-radius: 5px;
            margin-top: 10px;
            cursor: pointer;
            transition: background-color 0.3s ease;
        }
        .ppk-modal-content button:hover {
            background-color: #a9a9a9;
        }
        .ppk-modal-content form {
            display: flex;
            flex-direction: column;
        }
        .ppk-modal-content label {
            font-weight: bold;
            margin: 10px 0 5px;
        }
        .ppk-modal-content input, .ppk-modal-content textarea {
            width: 97%;
            padding: 8px;
            margin-bottom: 10px;
            border: 1px solid #ccc;
            border-radius: 5px;
        }

/*Ppk그래프모달*/
        .ppkGraphModal {
            display: none;
            position: fixed;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0, 0, 0, 0.5);
            transition: opacity 0.3s ease-in-out;
            z-index:19008;
        }
	    .ppkGraph-modal-content {
	        background: white;
	        width: 100%;
	        max-width: 1600px;
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
        .ppkGraphModal.show {
            display: block;
            opacity: 1;
        }
        .ppkGraphModal.show .ppkGraph-modal-content {
            transform: scale(1);
            opacity: 1;
        }


        .ppkGraph-modal-content button {
            background-color: #d3d3d3;
            color: black;
            padding: 10px;
            border: none;
            border-radius: 5px;
            margin-top: 10px;
            cursor: pointer;
            transition: background-color 0.3s ease;
        }
        .ppkGraph-modal-content button:hover {
            background-color: #a9a9a9;
        }
        .ppkGraph-modal-content form {
            display: flex;
            flex-direction: column;
        }
        .ppkGraph-modal-content label {
            font-weight: bold;
            margin: 10px 0 5px;
        }
        .ppkGraph-modal-content input, .ppkGraph-modal-content textarea {
            width: 97%;
            padding: 8px;
            margin-bottom: 10px;
            border: 1px solid #ccc;
            border-radius: 5px;
        }

		.chartRow{
			display:flex;
		}

		.chartRow > div{
			margin-left:20px;
		}

    </style>

<body>
    <main class="main">
        <div class="tab">
        

            <div class="button-container">
            
               <div class="box1">
	
	            <label class="daylabel">조회일자 :</label>
	            <input type="text" id="s_p_year" class="dayselect yearSet"/>
			</div>
                <button class="select-button">
                    <img src="/line/css/tabBar/search-icon.png" alt="select" class="button-image">조회
                </button>
<!--                 <button class="insert-button">
                    <img src="/line/css/tabBar/add-outline.png" alt="insert" class="button-image">추가
                </button>
                <button class="delete-button">
				    <img src="/line/css/tabBar/xDel3.png" alt="delete" class="button-image"> 삭제
				</button>
                 -->
                
               <!--  <button class="excel-download-button">
                    <img src="/line/css/tabBar/excel-icon.png" alt="excel" class="button-image">엑셀다운로드
                </button> -->
                
                
            </div>
        </div>

        <div class="view">
        	<div id="ppkListTable"></div>
        </div>
    </main>
    

<div id="pumbunModal" class="pumbunModal">
  <div class="pumbun-modal-content">
    <span class="closePumbun">&times;</span>
    <!-- 추가, 수정 -->
    <h2>품번선택</h2>
    	<hr />
    	<div style="display:inline-block;">
			<label style="display:inline-block; width:40px;">품번</label>
			<input type="text" id="in_item_no" class="pumModalEnter" style="text-align:left; display:inline-block; width:200px;">    	
			<label style="display:inline-block; width:40px;">품명</label>
			<input type="text" id="in_item_name" class="pumModalEnter" style="text-align:left; display:inline-block; width:200px;">    	
			<label style="display:inline-block; width:50px;">회사명</label>
			<input type="text" id="in_cust_name" class="pumModalEnter" style="text-align:left; display:inline-block; width:200px;">
			<button type="button" onclick="getPumbunList();">조회</button>			    	
    	</div>
    	<hr />
    
    <div id="pumbunTabu"></div>
    <hr />
	<button type="button" class="closePumbunModal">닫기</button>
  </div>
</div>

<div id="userModal" class="userModal">
  <div class="user-modal-content">
    <span class="closeUser">&times;</span>
    <!-- 추가, 수정 -->
    <h2>사용자선택</h2>
<!--     
    	<hr />
    	<div style="display:inline-block;">
			<label style="display:inline-block; width:40px;">품번</label>
			<input type="text" id="s_pnum" class="pumModalEnter" style="text-align:left; display:inline-block; width:100px;">    	
			<label style="display:inline-block; width:40px;">강종</label>
			<input type="text" id="s_gang" class="pumModalEnter" style="text-align:left; display:inline-block; width:50px;">    	
			<label style="display:inline-block; width:40px;">T급</label>
			<input type="text" id="s_t_gb" class="pumModalEnter" style="text-align:left; display:inline-block; width:50px;">
			<button type="button" onclick="getPumbunList();">조회</button>			    	
    	</div>
 -->
    	<hr />
    
    <div id="userTabu"></div>
    <hr />
	<button type="button" class="closeUserModal">닫기</button>
  </div>
</div>

<div id="ppkModal" class="ppkModal">
  <div class="ppk-modal-content">
    <span class="closePpk">&times;</span>
    <!-- 추가, 수정 -->
    <h2>Ppk</h2>
    <hr />
    	<div id="ppkInfoTable"></div>
    <hr />
    
    	<div id="ppkValueTable"></div>
    <hr />
    
    	<div id="ppkCalcTable"></div>
    <hr />
	<button type="button" class="closePpkModal">닫기</button>
	<button type="button" class="savePpkModal">저장</button>
  </div>
</div>

<div id="ppkGraphModal" class="ppkGraphModal">
  <div class="ppkGraph-modal-content">
    <span class="closePpkGraph">&times;</span>
    <!-- 추가, 수정 -->
    <h2>Ppk 그래프</h2>
    <hr />
    	<div class="chartRow">
			<!-- 하이차트 - 1 -->
			<div id="runChart"></div>
			<!-- 하이차트 - 2 -->
			<div id="historyChart"></div>
		</div>			   
    <hr />
	<button type="button" class="closePpkGraphModal">닫기</button>
	<button type="button" class="savePpkGraphModal">저장</button>
  </div>
</div>




    
<script>
let now_page_code = "e02";

var cpkListTable;
var selectedRowData = null;
$(function() {
	
	
	
	$("#s_p_year").val(todayDate().substring(0,4));
	ppkTable();
	ppkData();	
//	session.setAttribute("userData",result);	
	
//	var sessionData = session.getAttribute("loginUser");
//	console.log(sessionData.user_code);
	
/*
	getStandardTable();	
	getCpkDataList();
	getCpkCalcList();
	getXbar();
	getRbar();
*/
});

//이벤트
  $('.select-button').click(function() {	  
	  ppkData();
  });
  

  $(".closePumbunModal, .closePumbun").click(function(){
	  $('#pumbunModal').removeClass('show').hide();
  });

  $(".closeUserModal, .closeUser").click(function(){
	  $('#userModal').removeClass('show').hide();
  });

  $(".closePpkModal, .closePpk").click(function(){
	  $('#ppkModal').removeClass('show').hide();
  });

  $(".closePpkGraphModal, .closePpkGraph").click(function(){
	  $('#ppkGraphModal').removeClass('show').hide();
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

 
$(".savePpkModal").on("click",function(){
	var infoData = ppkInfoTable.getData();
	var valueData = ppkValueTable.getData();
	
	var vdObj = {};
	var vIdx = 1;
	var set_p_cnt = 0;
	for(var vd in valueData){
//		console.log(valueData[vd]);
		for(var vd2 in valueData[vd]){
			if(vd2 === "p_cnt"){
				vdObj[vd2] = valueData[vd][vd2];
				set_p_cnt = valueData[vd][vd2];
			}
			if(vd2.indexOf("p_t_val") != -1){
				var keys = "p_val"+vIdx;
				
				var values = 0;
				if(valueData[vd][vd2] == ""){
					values = 0;					
				}else{
					values = valueData[vd][vd2];
				}
				
				vdObj[keys] = values;
//				console.log(keys, valueData[vd], vd2, valueData[vd][vd2]);
				vIdx++;
				
				
			}
		}
	}
	
	vdObj.p_pnum = infoData[0].p_pnum;
	vdObj.p_user_code = infoData[0].p_user_code;
//	console.log(infoData[0]);
	
//	return false;
	
/*	
	console.log(infoData);
	console.log(valueData);
*/
//	console.log(vdObj);
	
	$.ajax({
		url:"/line/quality/ppk/save",
		type:"post",
		contentType:"application/json",
		data: JSON.stringify(vdObj),
		success:function(result){
//			console.log(result);
			ppkData();
			ppkDetailData(set_p_cnt)
		}
	});
});
//함수

function ppkData(){
	
	$.ajax({
		url:"/line/quality/ppk/allList",
		type:"post",
		dataType:"json",
		data:{
			"p_year":$("#s_p_year").val()
		},
		success:function(result){
//			console.log(result);
			ppkListTable.setData(result.data);
		}
	})
}

var ppkListTable;
function ppkTable(){
	ppkListTable = new Tabulator('#ppkListTable', {
	    height: '600px',
	    layout: 'fitData',
	    headerSort: false,
	    reactiveData: true,
	    columnHeaderVertAlign: "middle",
	    headerHozAlign: 'center',
	    ajaxConfig: { method: 'POST' },
//	    ajaxURL: "/line/quality/cpk/standard/list",
	    ajaxProgressiveLoad:"scroll",    
	    ajaxResponse:function(url, params, response){
			$("#ppkListTable .tabulator-col.tabulator-sortable").css("height","55px");
	        return response; //return the response data to tabulator
	    },
	    placeholder: "조회된 데이터가 없습니다.",
	    columns: [
	      { title: "cnt", field: "p_cnt", visible: false }, 
	      { title: "일자",field: "p_ymon",width: 100, hozAlign: "center" },	
	      { title: "품명",field: "p_pname",width: 200 },	
	      { title: "품번",field: "p_pnum",width: 200 },	
	      { title: "회사명",field: "cust_name",width: 200 },		      
	      { title: "Ppk",field: "p_m_ppk",width: 120, hozAlign: "center" },
	      { title: "측정일자",field: "p_chkdate",width: 150, hozAlign: "center" },
	      { title: "측정자",field: "p_user_name",width: 120, hozAlign: "center" },
	      { title: "상한값",field: "p_upp",width: 100, hozAlign: "center" },
	      { title: "하한값",field: "p_low",width: 100, hozAlign: "center" },
/*	      { title: "",field: "h_t_gb",width: 200, hozAlign: "center" },
	      { title: "상한",field: "h_hard_up",width: 200, hozAlign: "center" },
	      { title: "하한",field: "h_hard_dw",width: 200, hozAlign: "center" },*/
	    ],

	    rowClick: function(e, row) {
	      $('#ppkListTable .tabulator-row').removeClass('row_select');
	      row.getElement().classList.add('row_select');
	      selectedRowData = row.getData();
	    },
	    rowDblClick: function(e, row){
	    	var data = row.getData();
	    	
	    	ppkDetailData(data.p_cnt);
	    	
	    }
	  });
	
}


function ppkDetailData(p_cnt){
	$.ajax({
		url:"/line/quality/ppk/detailList",
		type:"post",
		dataType:"json",
		data:{"p_cnt":p_cnt},
		success:function(result){
//			console.log(result.runChart);
//			console.log(result.historyChart);
			$("#ppkModal").show().addClass('show');
			ppkInfoFunc();
			ppkValueFunc();
			ppkCalcFunc();
			ppkInfoTable.setData(result.topData);
			ppkValueTable.setData(result.midData);
			ppkCalcTable.setData(result.btmData);
			
			//트렌드		
			//개별치 연속그래프
			var trendData1 = result.runChart;
			
			var run_upp_obj = new Object();
			var run_low_obj = new Object();
			var run_val_obj = new Object();
			var run_diff_obj = new Object();

			var run_upp_save = new Array();
			var run_low_save = new Array();
			var run_val_save = new Array();
			var run_diff_save = new Array();

			
			trendData1.forEach(function(data, i){
				var run_upp = new Array();
				var run_low = new Array();
				var run_val = new Array();
				var run_diff = new Array();
				
				
				run_upp.push(i);
				run_upp.push(eval(data.p_upp));
				
				run_low.push(i);
				run_low.push(eval(data.p_low));
				
				run_diff.push(i);
				run_diff.push(eval(data.p_diff));
				
				run_val.push(i);
				run_val.push(eval(data.p_val));
				
				run_upp_save.push(run_upp);
				run_low_save.push(run_low);
				run_diff_save.push(run_diff);
				run_val_save.push(run_val);
			});

			run_upp_obj = {"name":"UPP", "data":run_upp_save, "color":"red"};
			run_low_obj = {"name":"LOW", "data":run_low_save, "color":"red"};
			run_diff_obj = {"name":"DIF", "data":run_diff_save, "color":"red"};
			run_val_obj = {"name":"VAL", "data":run_val_save, "color":"blue"};
			
			
			seriesArray[0] = run_upp_obj;
			seriesArray[1] = run_low_obj;
			seriesArray[2] = run_diff_obj;
			seriesArray[3] = run_val_obj;

			//히스토그램
			var trendData2 = result.historyChart;
			
			var his_h_obj = new Object();
			var his_i_obj = new Object();
			var his_j_obj = new Object();
			var his_k_obj = new Object();
			var his_l_obj = new Object();

			var his_h_save = new Array();
			var his_i_save = new Array();
			var his_j_save = new Array();
			var his_k_save = new Array();
			var his_l_save = new Array();

			
			trendData2.forEach(function(data, i){
				var his_h = new Array();
				var his_i = new Array();
				var his_j = new Array();
				var his_k = new Array();
				var his_l = new Array();
				
				
				his_h.push(eval(data.p_xval2));
				his_h.push(eval(data.p_h_val));
				
				his_i.push(eval(data.p_xval2));
				his_i.push(eval(data.p_i_val));
				
				his_j.push(eval(data.p_xval2));
				his_j.push(eval(data.p_j_val));
				
				his_k.push(eval(data.p_xval2));
				his_k.push(eval(data.p_k_val));
				
				his_l.push(eval(data.p_xval2));
				his_l.push(eval(data.p_l_val));
				
				his_h_save.push(his_h);
				his_i_save.push(his_i);
				his_j_save.push(his_j);
				his_k_save.push(his_k);
				his_l_save.push(his_l);
			});

			his_h_obj = {"name":"H","data":his_h_save, "color":"blue"};
			his_i_obj = {"name":"I","data":his_i_save, "color":"red"};
			his_j_obj = {"name":"J","data":his_j_save, "color":"red"};
			his_k_obj = {"name":"K","data":his_k_save, "color":"blue"};
			his_l_obj = {"name":"L","data":his_l_save, "color":"blue"};
			
			seriesArray2[0] = his_h_obj;
			seriesArray2[1] = his_i_obj;
			seriesArray2[2] = his_j_obj;
			seriesArray2[3] = his_k_obj;
			seriesArray2[4] = his_l_obj;

			getRunChart();
			getHistoryChart();
		}
	})
}

var ppkInfoTable;
function ppkInfoFunc(){
	ppkInfoTable = new Tabulator('#ppkInfoTable', {
	    height: '65px',
	    layout: 'fitData',
	    headerSort: false,
	    reactiveData: true,
	    columnHeaderVertAlign: "middle",
	    headerHozAlign: 'center',
	    ajaxConfig: { method: 'POST' },
//	    ajaxURL: "/line/quality/cpk/standard/list",
	    ajaxProgressiveLoad:"scroll",    
	    ajaxResponse:function(url, params, response){
			$("#ppkInfoTable .tabulator-col.tabulator-sortable").css("height","55px");
	        return response; //return the response data to tabulator
	    },
	    placeholder: "조회된 데이터가 없습니다.",
	    columns: [
	      { title: "시험월",field: "p_ymon",width: 80, hozAlign: "center" },		      
	      { title: "측정항목",field: "p_pno",width: 100, hozAlign: "center" },
	      { title: "품명",field: "p_pname",width: 200, hozAlign: "center",
	    	  cellDblClick:function(e, column){
	    		  pumbunSelect();
//	    		  $("#pumbunModal").show().addClass('show');
	      }},
	      { title: "측정자",field: "p_user_name",width: 100, hozAlign: "center",
	    	  cellDblClick: function(e, column){
	    		  userSelect();
	    	  }
	      },
	      { title: "평가일자",field: "p_chkdate",width: 100, hozAlign: "center" },
	      { title: "샘플링수",field: "p_sampling",width: 80, hozAlign: "center" },
	      { title: "검사항목",field: "p_item",width: 100, hozAlign: "center" },
	      { title: "계측기명",field: "p_measure",width: 100, hozAlign: "center" },
	      { title: "측정단위",field: "p_unit",width: 80, hozAlign: "center" },
	      { title: "규격",field: "p_spec",width: 120, hozAlign: "center" },
	      { title: "규격상한",field: "p_upp",width: 80, hozAlign: "center" },
	      { title: "규격하한",field: "p_low",width: 80, hozAlign: "center" },
	      { title: "공차유형",field: "p_type",width: 100, hozAlign: "center" },
	      { title: "그래프",width: 100, hozAlign: "center",
	    	  formatter:graphIcon, cellClick:function(e, cell){
	    		  $("#ppkGraphModal").css("height","80vh");
	    		  $("#ppkGraphModal").show().addClass('show');
	    	  }
	      },
	      { title: "품번", field: "p_pnum", visible:false}
	    ],

	    rowClick: function(e, row) {
	      $('#ppkInfoTable .tabulator-row').removeClass('row_select');
	      row.getElement().classList.add('row_select');
	      selectedRowData = row.getData();
	    }
	  });
	
}

var graphIcon = function(cell, formatterParams){
	return "<img style='width:20px; heigt:20px;' src='/line/css/tabBar/bar-chart.png'></img>";
//    return "<i class='fa fa-chart-line'></i>";
};

var ppkValueTable;
function ppkValueFunc(){
	ppkValueTable = new Tabulator('#ppkValueTable', {
	    height: '340px',
	    layout: 'fitData',
	    headerSort: false,
	    reactiveData: true,
	    columnHeaderVertAlign: "middle",
	    headerHozAlign: 'center',
	    ajaxConfig: { method: 'POST' },
//	    ajaxURL: "/line/quality/cpk/standard/list",
	    ajaxProgressiveLoad:"scroll",    
	    ajaxResponse:function(url, params, response){
			$("#ppkValueTable .tabulator-col.tabulator-sortable").css("height","55px");
	        return response; //return the response data to tabulator
	    },
	    placeholder: "조회된 데이터가 없습니다.",
	    columns: [
	      { title: "cnt", field: "p_cnt", visible: false }, 
	      { title: "측정값",field: "p_t_gb",width: 80, hozAlign: "center", editor:true, },		      
	      { title: "1",field: "p_t_val01",width: 100, hozAlign: "center", editor:true },
	      { title: "2",field: "p_t_val02",width: 100, hozAlign: "center", editor:true },
	      { title: "3",field: "p_t_val03",width: 100, hozAlign: "center", editor:true },
	      { title: "4",field: "p_t_val04",width: 100, hozAlign: "center", editor:true },
	      { title: "5",field: "p_t_val05",width: 100, hozAlign: "center", editor:true },
	      { title: "6",field: "p_t_val06",width: 100, hozAlign: "center", editor:true },
	      { title: "7",field: "p_t_val07",width: 100, hozAlign: "center", editor:true },
	      { title: "8",field: "p_t_val08",width: 100, hozAlign: "center", editor:true },
	      { title: "9",field: "p_t_val09",width: 100, hozAlign: "center", editor:true },
	      { title: "10",field: "p_t_val10",width: 100, hozAlign: "center", editor:true },
	    ],

	    rowClick: function(e, row) {
	      $('#ppkValueTable .tabulator-row').removeClass('row_select');
	      row.getElement().classList.add('row_select');
	      selectedRowData = row.getData();
	    },
	    rowDblClick: function(e, row){
	    	var data = row.getData();
	    	
//	    	ppkDetailData(data.p_cnt);
	    	
	    }
	  });
	
}

var ppkCalcTable;
function ppkCalcFunc(){
	ppkCalcTable = new Tabulator('#ppkCalcTable', {
	    height: '60px',
	    layout: 'fitData',
	    headerSort: false,
	    reactiveData: true,
	    columnHeaderVertAlign: "middle",
	    headerHozAlign: 'center',
	    ajaxConfig: { method: 'POST' },
//	    ajaxURL: "/line/quality/cpk/standard/list",
	    ajaxProgressiveLoad:"scroll",    
	    ajaxResponse:function(url, params, response){
			$("#ppkCalcTable .tabulator-col.tabulator-sortable").css("height","55px");
	        return response; //return the response data to tabulator
	    },
	    placeholder: "조회된 데이터가 없습니다.",
	    columns: [
	      { title: "Min",field: "p_min",width: 80, hozAlign: "center"},		      
	      { title: "Max",field: "p_max",width: 100, hozAlign: "center"},
	      { title: "Aver",field: "p_avg",width: 100, hozAlign: "center"},
	      { title: "Dev",field: "p_dev",width: 100, hozAlign: "center"},
	      { title: "추정 불량율",field: "p_total_ppm",width: 100, hozAlign: "center"},
	      { title: "Pp",field: "p_pp",width: 100, hozAlign: "center"},
	      { title: "Ppu",field: "p_ppu",width: 100, hozAlign: "center"},
	      { title: "Ppl",field: "p_ppl",width: 100, hozAlign: "center"},
	      { title: "Ppk",field: "p_ppk",width: 100, hozAlign: "center"},
	    ],
	    rowClick: function(e, row) {
	      $('#ppkCalcTable .tabulator-row').removeClass('row_select');
	      row.getElement().classList.add('row_select');
	      selectedRowData = row.getData();
	    }
	  });
	
}

function pumbunSelect(){
//	alert("품번선택");
	$("#pumbunModal").show().addClass('show');
	getPumbunList();
}
var pumbunTabu;
function getPumbunList(){
	pumbunTabu = new Tabulator('#pumbunTabu', {
		    height: '300px',
		    layout: 'fitDataFill',
		    headerSort: false,
		    reactiveData: true,
		    columnHeaderVertAlign: "middle",
		    headerHozAlign: 'center',
		    ajaxConfig: { method: 'POST' },
		    ajaxURL: "/line/productionManagement/heatTreatment/pumbun/list",
		    ajaxProgressiveLoad:"scroll",
		    ajaxParams: { 
		    	"item_no": $("#in_item_no").val(),
		    	"item_name": $("#in_item_name").val(),		    	
		    	"cust_name": $("#in_cust_name").val()	    	
		    },		    
		    ajaxResponse:function(url, params, response){
				$("#pumbunTabu .tabulator-col.tabulator-sortable").css("height","55px");
		        return response; //return the response data to tabulator
		    },
		    placeholder: "조회된 데이터가 없습니다.",
		    columns: [
		        //{ title: "no", field: "no", visible: false }, 
		      { title: "품번",field: "item_no",width: 300, hozAlign: "center" },		      
		      { title: "품명",field: "item_name",width: 300, hozAlign: "center" },
		      { title: "거래처명",field: "cust_name",width: 200, hozAlign: "center" },
		      { title: "템퍼링 경도",field: "temp_spec",width: 200, hozAlign: "center" },
		      { title: "상한",field: "temper_high",width: 200, hozAlign: "center" },
		      { title: "하한",field: "temper_low",width: 200, hozAlign: "center" },
		    ],
		    rowClick: function(e, row) {
		      $('#pumbunTabu .tabulator-row').removeClass('row_select');
		      row.getElement().classList.add('row_select');
		      selectedRowData = row.getData();
		    },
		    //더블클릭 했을때 
		    rowDblClick: function(e, row) {
		  	  var d = row.getData();
//		  	  $("input[name='w_pnum']").val(d.w_pnum);
//		  		$('#pumbunModal').removeClass('show').hide();
//		  		console.log(ppkInfoTable.rowManager.rows[0].data.p_pname);
		  		
		  		ppkInfoTable.rowManager.rows[0].data.p_pname = d.item_name;
		  		ppkInfoTable.rowManager.rows[0].data.p_pnum = d.item_no;
		  		ppkInfoTable.rowManager.rows[0].data.p_spec = d.temp_spec;

		  		ppkInfoTable.rowManager.rows[0].data.p_upp = d.temper_high;
		  		ppkInfoTable.rowManager.rows[0].data.p_low = d.temper_low;
		  		$('#pumbunModal').removeClass('show').hide();
//		  		console.log(ppkInfoTable.rowManager.rows[0].data.p_pname);
//		  		console.log(ppkInfoTable.getRow());
//		  		console.log(ppkInfoTable.getCell(0,"p_pname"));
		  	}
		  });
}


function userSelect(){
//	alert("품번선택");
	$("#userModal").show().addClass('show');
	getUserList();
}

var userTabu;
function getUserList(){
	userTabu = new Tabulator('#userTabu', {
		    height: '300px',
		    layout: 'fitDataFill',
		    headerSort: false,
		    reactiveData: true,
		    columnHeaderVertAlign: "middle",
		    headerHozAlign: 'center',
		    ajaxConfig: { method: 'POST' },
		    ajaxURL: "/line/quality/ppk/userList",
		    ajaxProgressiveLoad:"scroll",
		    ajaxParams: {},		    
		    ajaxResponse:function(url, params, response){
				$("#userTabu .tabulator-col.tabulator-sortable").css("height","55px");
		        return response; //return the response data to tabulator
		    },
		    placeholder: "조회된 데이터가 없습니다.",
		    columns: [
		        //{ title: "no", field: "no", visible: false }, 
		      { title: "code", field: "user_code",width: 120, hozAlign: "center" },
		      { title: "아이디", field: "user_id",width: 150, hozAlign: "center" },
		      { title: "성명",field: "user_name",width: 80, hozAlign: "center" },
		      { title: "부서",field: "user_busu",width: 80, hozAlign: "center" },
		      { title: "직책",field: "user_jick",width: 110, hozAlign: "center" },
		    ],

		    rowClick: function(e, row) {
		      $('#userTabu .tabulator-row').removeClass('row_select');
		      row.getElement().classList.add('row_select');
		      selectedRowData = row.getData();
		    },
		    //더블클릭 했을때 
		    rowDblClick: function(e, row) {
		  	  var d = row.getData();
		  		ppkInfoTable.rowManager.rows[0].data.p_user_name = d.user_name;
		  		ppkInfoTable.rowManager.rows[0].data.p_user_code = d.user_code;
		  		$('#userModal').removeClass('show').hide();
		  	}
		  });
}

//하이차트 설정
var seriesArray = new Array();
function getRunChart(){	
    const chart = Highcharts.chart('runChart', {    	
    	chart: {    		
    		type:"line",        		
    		panning:true,
            panKey:"shift",
            zoomType:"x",
			styleMode: true,
			width:700,
			height:500
    	},
    	title: {
    		text:"개별치 연속그래프</br>(Run Chart)"
    	},
    	time:{
    		timezone: "Asia/Seoul",
    		useUTC: false
    	},
        yAxis: [{
//        	className: 'highcharts-color-0',
        	crosshair:{
        		width:3,
        		color:'#5D5D5D',
        		zIndex:5
        	},
            title: {
                text: '값'
            },
            labels:{
            	style:{
            		fontSize:"10pt"
            	}
            }
        }],
        xAxis: {
        	crosshair:{
        		width:3,
        		color:'#5D5D5D',
        		zIndex:5
        	},
//			tickAmount:11,
        	labels:{
        		style:{
        			fontSize:"11pt"
        		}
        	},
        	allowDecimals:false
//        	tickmarkPlacement:'on',
//        	max:datetimeJson[datetimeJson.length-1],
//        	startOnTick:false
        },
        legend: {
            layout: 'vertical',
            align: 'right',
            verticalAlign: 'middle'
        },
        plotOptions: {
            series: {
            	selected:true,
            	marker:{
                	radius:1
            	}
            }
        },

        series: seriesArray,
        responsive: {
            rules: [{
                condition: {
                    maxWidth: 1200
                },
                chartOptions: {
                    legend: {
                        layout: 'horizontal',
                        align: 'center',
                        verticalAlign: 'bottom'
                    }
                }
            }]
        },
        exporting:{
            menuItemDefinitions: {
                // Custom definition
                label: {
                    onclick: function () {
                        this.renderer.label(
                            'You just clicked a custom menu item',
                            100,
                            100
                        )
                            .attr({
                                fill: '#a4edba',
                                r: 5,
                                padding: 10,
                                zIndex: 10
                            })
                            .css({
                                fontSize: '1.5em'
                            })
                            .add();
                    },
                    text: 'Show label'
                }
            },
            buttons: {
                contextButton: {
                    menuItems: ['downloadPNG', 'downloadPDF', 'downloadXLS', 'separator']
                }
            }
        },
        legend:{
            itemStyle:{
                fontSize: "11pt"
            }
		}
    });
    
}

var seriesArray2 = new Array();
function getHistoryChart(){	
    const chart = Highcharts.chart('historyChart', {    	
    	chart: {    		
    		type:"line",        		
    		panning:true,
            panKey:"shift",
            zoomType:"x",
			styleMode: true,
			width:700,
			height:500
    	},
    	title: {
    		text:"히스토그램</br>(Histogram Chart)"
    	},
    	time:{
    		timezone: "Asia/Seoul",
    		useUTC: false
    	},
        yAxis: [{
//        	className: 'highcharts-color-0',
        	crosshair:{
        		width:3,
        		color:'#5D5D5D',
        		zIndex:5
        	},
            title: {
                text: '값'
            },
            labels:{
            	style:{
            		fontSize:"10pt"
            	}
            }
        }],
        xAxis: {
        	crosshair:{
        		width:3,
        		color:'#5D5D5D',
        		zIndex:5
        	},
//			tickAmount:11,
        	labels:{
        		style:{
        			fontSize:"11pt"
        		}
        	},
        	allowDecimals:false
//        	tickmarkPlacement:'on',
//        	max:datetimeJson[datetimeJson.length-1],
//        	startOnTick:false
        },
        legend: {
            layout: 'vertical',
            align: 'right',
            verticalAlign: 'middle'
        },
        plotOptions: {
            series: {
            	selected:true,
            	marker:{
                	radius:1
            	}
            }
        },
/*
        tooltip:{
        	split:true,
			formatter:function(){
				var tool;

				tool = '<span style=color:'+this.points[0].color+'><b>time :</b></span> <b>' + this.points[0].y + '</b></br>'+
	            '<span style=color:'+this.points[1].color+'><b>temper :</b></span> <b>' + this.points[1].y + '</b></br>'+
	            '<span style=color:'+this.points[2].color+'><b>temperToleCont :</b></span> <b>' + this.points[2].y + '</b></br>'+
	            '<span style=color:'+this.points[3].color+'><b>temperToleHold :</span> <b>' + this.points[3].y + '</b></br>'+
	            '<span style=color:'+this.points[4].color+'><b>holdbackTimeoutHeating :</span> <b>' + this.points[4].y + '</b></br>'+
	            '<span style=color:'+this.points[5].color+'><b>pressureSetValue :</span> <b>' + this.points[5].y + '</b></br>'+
	            '<span style=color:'+this.points[6].color+'><b>pressingCapacityF1 :</span> <b>' + this.points[6].y + '</b></br>'+
	            '<span style=color:'+this.points[7].color+'><b>pressingCapacityF2 :</span> <b>' + this.points[7].y + '</b></br>'+
	            '<span style=color:'+this.points[8].color+'><b>foreceTolerance :</span> <b>' + this.points[8].y + '</b></br>'+
	            '<span style=color:'+this.points[9].color+'><b>positionAbs :</span> <b>' + this.points[9].y + '</b></br>'+
	            '<span style=color:'+this.points[10].color+'><b>positionRelative :</span> <b>' + this.points[10].y + '</b></br>'+
	            '<span style=color:'+this.points[11].color+'><b>distanceTolerance :</span> <b>' + this.points[11].y + '</b></br>'+
	            '<span style=color:'+this.points[12].color+'><b>holdingTime1 :</span> <b>' + this.points[12].y + '</b></br>'+
	            '<span style=color:'+this.points[13].color+'><b>holdingTime2 :</span> <b>' + this.points[13].y + '</b></br>'+
	            '<span style=color:'+this.points[14].color+'><b>numberOfLoops :</span> <b>' + this.points[14].y + '</b></br>'+
	            '<span style=color:'+this.points[15].color+'><b>speedOfPlunger :</span> <b>' + this.points[15].y + '</b></br>'+
	            '<span style=color:'+this.points[16].color+'><b>gradientOfForce :</span> <b>' + this.points[16].y + '</b></br>'+
                'Segment : <b>' + this.x + '</b>';   						
				
	            return tool;
                                    
			},
	        shared: true,
//	        crosshairs:true,
    		style:{
    			fontSize:"14pt"
    		}
        },
*/
        series: seriesArray2,
        responsive: {
            rules: [{
                condition: {
                    maxWidth: 1200
                },
                chartOptions: {
                    legend: {
                        layout: 'horizontal',
                        align: 'center',
                        verticalAlign: 'bottom'
                    }
                }
            }]
        },
        exporting:{
            menuItemDefinitions: {
                // Custom definition
                label: {
                    onclick: function () {
                        this.renderer.label(
                            'You just clicked a custom menu item',
                            100,
                            100
                        )
                            .attr({
                                fill: '#a4edba',
                                r: 5,
                                padding: 10,
                                zIndex: 10
                            })
                            .css({
                                fontSize: '1.5em'
                            })
                            .add();
                    },
                    text: 'Show label'
                }
            },
            buttons: {
                contextButton: {
                    menuItems: ['downloadPNG', 'downloadPDF', 'downloadXLS', 'separator']
                }
            }
        },
        legend:{
            itemStyle:{
                fontSize: "11pt"
            }
		}
    });
    
}


</script>
</body>
</html>