<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="ko">
<head>
<script src="/line/mock/mock-loader.js"></script>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>설비 효율현황</title>
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
                
                
  <!--               <button class="excel-download-button">
                    <img src="/line/css/tabBar/excel-icon.png" alt="excel" class="button-image">엑셀다운로드
                </button>
                 -->
                
            </div>
        </div>

        <div class="view">
            <div id="efficWeightChart"></div>
            <div id="efficTimeChart"></div>
        </div>
    </main>
    
<script>
let now_page_code = "c03";

var dataTable;
var selectedRowData = null;

var weightTitle = "0 %";
var timeTitle = "0 %";

$(function() {
	getList();

});

//이벤트
  $('.select-button').click(function() {
	  getList();
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
function getList(){
	$.ajax({
		url:"/line/productionManagement/machineEfficiency/list",
		type:"post",
		dataType:"json",
		data:{},
		success:function(result){

			var weight_val = 0;
			var time_val = 0;

			if(result.data.length > 0){
				weight_val = result.data[0].m_weight_percent;
				time_val = result.data[0].m_time_percent;
				
				weightTitle = weight_val+" %";
				timeTitle = time_val+" %";
			}
			
			
			var weight_obj = new Object();
			var time_obj = new Object();
			
			var weight_save = new Array();
			var weight = new Array();
			
			var time_save = new Array();
			var time = new Array();
	
			var wObj = new Object();
			wObj.name = "장입량 준수율(%)";
			wObj.y = weight_val;
			wObj.color = "green";
			
			weight.push(wObj);
			
			weight_save.push(wObj);

			wObj = new Object();
			wObj.name = "";
			wObj.y = (100 - weight_val);
			wObj.color = "lightGray";
			
			weight.push(wObj);
			
			weight_save.push(wObj);

			
			weight_obj = {"data":weight_save, "innerSize":"75%", "colorByPoint":true};
			
			seriesArrayWeight[0] = weight_obj;
	
			var tObj = new Object();
			tObj.name = "생산 효율(%)";
			tObj.y = time_val;
			tObj.color = "orange";
			
			time.push(tObj);
			
			time_save.push(tObj);

			tObj = new Object();
			tObj.name = "";
			tObj.y = (100 - time_val);
			tObj.color = "lightGray";
			
			time.push(tObj);
			
			time_save.push(tObj);
			
			time_obj = {"data":time_save, "innerSize":"75%", "colorByPoint":true};
			
			seriesArrayTime[0] = time_obj;
			
			getEfficWeightChart();
			getEfficTimeChart();
		}
	})
}

var seriesArrayWeight = new Array();
function getEfficWeightChart(){	
    const chart = Highcharts.chart('efficWeightChart', {    	
    	chart: {    		
    		type:"pie",
			styleMode: true,
			width:700,
			height:500
    	},
    	title: {
    		text:"장입량 준수율(%)</br>"+weightTitle
    	},
        legend: {
            enabled: false
        },
        accessibility: {
            point: {
                valueSuffix: '%'
            }
        },
        plotOptions: {
            series: {
                allowPointSelect: true,
                cursor: 'pointer',
                borderRadius: 8,
                dataLabels: [{
                    enabled: true,
                    distance: 20,
                    format: '{point.name}'
                }, {
                    enabled: true,
                    distance: -15,
                    format: '{point.percentage:.0f}%',
                    style: {
                        fontSize: '0.9em'
                    }
                }],
                showInLegend: true
            }
        },        
        series: seriesArrayWeight,
        tooltip: {
            pointFormat: '{series.name}: <b>{point.percentage:.0f}%</b>'
        }
    });
    
}

var seriesArrayTime = new Array();
function getEfficTimeChart(){	
    const chart = Highcharts.chart('efficTimeChart', {    	
    	chart: {    		
    		type:"pie",        		
    		panning:true,
            panKey:"shift",
            zoomType:"x",
			styleMode: true,
			width:700,
			height:500
    	},
    	title: {
    		text:"생산 효율(%)</br>"+timeTitle
    	},
        legend: {
            enabled: false
        },
        accessibility: {
            point: {
                valueSuffix: '%'
            }
        },
        plotOptions: {
            series: {
                allowPointSelect: true,
                cursor: 'pointer',
                borderRadius: 8,
                dataLabels: [{
                    enabled: true,
                    distance: 20,
                    format: '{point.name}'
                }, {
                    enabled: true,
                    distance: -15,
                    format: '{point.percentage:.0f}%',
                    style: {
                        fontSize: '0.9em'
                    }
                }],
                showInLegend: true
            }
        },        
        series: seriesArrayTime,
        tooltip: {
            pointFormat: '{series.name}: <b>{point.percentage:.0f}%</b>'
        }
    });
    
}

</script>

</body>
</html>