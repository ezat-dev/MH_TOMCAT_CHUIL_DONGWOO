<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="ko">
<head>
<script src="/line/mock/mock-loader.js"></script>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>트렌드</title>
   <%@include file="../include/pluginpage.jsp" %>    
    <jsp:include page="../include/tabBar.jsp"/>

    <style>
/* ==================================================
   모바일 전용 트렌드 페이지
   기본 = 세로(Portrait)
   ================================================== */

/* ---------- Reset ---------- */
* { box-sizing: border-box; }
html, body {
  margin: 0;
  padding: 0;
  width: 100%;
  font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", "Noto Sans KR", sans-serif;
  background: #f5f6f8;
  color: #111;
}

/* ==================================================
   📱 세로 모드 (기본)
   ================================================== */

.top-area {
    display: flex;
    justify-content: center;
    align-items: center;
    padding: px 0;
    background: #fff;
    border-bottom: 1px solid #e5e7eb;
}
.top-area .logo img {
    height: 124px;
    display: block;
}



/* ---------- 검색 영역 ---------- */
.button-container {
  background: #fff;
  margin: 12px;
  padding: 16px;
  border-radius: 16px;
  box-shadow: 0 6px 16px rgba(0,0,0,0.06);
}

/* 날짜 영역 */
.date_input {
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.datetimeSet {
  width: 100%;
  height: 42px;
  padding: 0 10px;
  font-size: 15px;
  text-align: left;
  border-radius: 8px;
  border: 1px solid #d1d5db;
  background: #fff;
}

/* ~ 숨김 (세로에서는 필요 없음) */
.date_input .mid {
  display: none;
}

.select-button {
  margin-top: 14px;
  width: 100%;
  height: 44px;
  border-radius: 10px;
  border: none;
  background: #d1d5db;     /* 지금 UI랑 톤 맞춤 */
  color: #555;
  font-size: 15px;
  font-weight: 600;

  display: flex;
  align-items: center;
  justify-content: center;
  gap: 6px;
}

.select-button img {
  width: 18px;
  height: 18px;
  opacity: 0.6;
}

/* ---------- 차트 ---------- */
#container {
  margin: 12px;
  width: calc(100% - 24px);
  height: calc(100vh - 360px); /* ✅ 세로 기준 */
  background: #fff;
  border-radius: 14px;
  box-shadow: 0 6px 18px rgba(0,0,0,0.06);
}

/* ---------- 불필요 버튼 제거 ---------- */
.insert-button,
.excel-button,
#printBtn {
  display: none !important;
}

/* ==================================================
   📱 가로 모드 (Landscape 전용)
   ================================================== */
@media (max-width: 900px) and (orientation: landscape) {

  /* 상단 축소 */
  .top-area {
    padding: 8px 12px;
  }

  .top-area .logo img {
    height: 108px;
  }

  .top-area .title {
    font-size: 17px;
  }

  /* 검색 영역: 한 줄 배치 */
  .button-container {
    margin: 8px 12px;
    padding: 10px 12px;
  }

  .button-container .daylabel {
    display: none; /* 가로에서는 라벨 제거 */
  }

  .date_input {
    flex-direction: row;
    align-items: center;
    gap: 6px;
  }

  .datetimeSet {
    flex: 1;
    height: 36px;
    font-size: 13px;
  }

  .date_input .mid {
    display: inline;
    font-size: 16px;
    font-weight: 700;
    color: #666;
  }

  .select-button {
    margin-top: 0;
    width: auto;
    height: 36px;
    padding: 0 12px;
    font-size: 13px;
    border-radius: 8px;
    white-space: nowrap;
  }

  /* 차트 크게 */
  #container {
    margin: 8px 12px;
    height: calc(100vh - 170px);
  }
}

    </style>
    </head>
<body>
<div class="top-area">
  <div class="logo"><img src="/line/css/login/logo2.png" alt="로고"></div>

</div>



     		<div class="button-container">
        		<!-- <label class="daylabel">검색 날짜 :</label> -->
<div class="date_input" style="text-align:center; width:100%;">

    <input type="text"
           autocomplete="off"
           class="datetimeSet"
           id="startDate"
           style="
             font-size:16px;
             margin:5px;
             border-radius:6px;
             border:1px solid #ccc;
             text-align:center;
             height:36px;
             width:100%;
             max-width:360px;
           ">

    <span class="mid"
          style="
            display:block;
            font-size:18px;
            font-weight:bold;
            margin:6px 0;
          ">  </span>

    <input type="text"
           autocomplete="off"
           class="datetimeSet"
           id="endDate"
           style="
             font-size:16px;
             margin:5px;
             border-radius:6px;
             border:1px solid #ccc;
             text-align:center;
             height:36px;
             width:100%;
             max-width:360px;
           ">

    <button class="select-button"
            style="
         
              width:100%;
              max-width:360px;
              height:36px;
              border-radius:8px;
            ">
        <img src="/line/css/tabBar/search-icon.png"
             alt="select"
             class="button-image">
        조회
    </button>

</div>

				
           <button class="insert-button">
				<img src="/line/css/tabBar/add-outline.png" alt="insert"
					class="button-image">추가
			</button>
				
				
				<button id="printBtn" 
				        style="margin-left:0px; background-color:#ffffff; border:1px solid #000000; border-radius:4px; padding:5px 10px; cursor:pointer; width:72px; height:40px;">
				    🖨️ 인쇄
				</button>


               <button class="excel-button">
                    <img src="/line/css/tabBar/excel-icon.png" alt="excel" class="button-image" >Download
                </button>

                
			</div>
			<div id="container" style="width: 100%; height: 600px; margin-top:10px;"></div>

<script>
let now_page_code = "b04";

let categories;

let q_pv_1,q_pv_2,q_pv_3,q_pv_4,q_pv_5;
let t_pv_1,t_pv_2,t_pv_3,t_pv_4,t_pv_5;
let cp_pv_1,cp_pv_2,f_wash_pv,m_wash_pv,oil_pv,bc_pv;
let tc_val_pv,tc_val_label;
let tc_val_series;
let memoSeries = []; // ✅ 메모 시리즈용 전역 변수
var trendInterval;
var chart;

document.getElementById('printBtn').addEventListener('click', function() {
    const style = document.createElement('style');
    style.innerHTML = `
        @page {
            size: A4 landscape;
            margin: 10mm;
        }
        @media print {
            body { zoom: 67%; }
            #container { width: 1700px !important; max-width: 1700px !important; height: 660px !important; }
        }
    `;
    document.head.appendChild(style);
    if(chart){ chart.reflow(); }
    window.print();
    setTimeout(() => { document.head.removeChild(style); }, 1000);
});


$(".excel-button").click(function () {
    downloadExcel();
});


function escapeHtml(str) {
    if (!str) return "";
    return String(str).replace(/&/g,"&amp;").replace(/</g,"&lt;").replace(/>/g,"&gt;").replace(/"/g,"&quot;").replace(/'/g,"&#039;");
}

function safeNum(v){ return (v===null||v===undefined||v==="")?null:(isNaN(Number(v))?null:Number(v)); }

function dataLabelFormat(val){
    var d = new Date(val);
    return paddingZero(d.getMonth()+1) + "-" + paddingZero(d.getDate()) + "<br/>" +
           paddingZero(d.getHours()) + ":" + paddingZero(d.getMinutes());
}

function paddingZero(v){ return v<10?"0"+v:v; }

$(document).ready(function () {
    $(".datetimeSet").datepicker({ language:'ko', timepicker:true, dateFormat:'yyyy-mm-dd', timeFormat:'hh:ii', autoClose:true });
    $("#startDate").val(trendStime());
    $("#endDate").val(trendEtime());
    fetchData();
    trendInterval = setInterval(trendIntervalFunc, 1000*60*5);
});

$(".select-button").on("click", fetchData);

$(".insert-button").on("click", function(){
    $("input[name='tc_user_code']").val("${loginUser.user_code}");
    $("input[name='tc_user_name']").val("${loginUser.user_name}");
    $("input[name='tc_regtime']").val(trendEtime());
    $('#modalContainer').show().addClass('show');
    getSignDataList();
    signData();
});

$('.close, #closeModal').click(function() { $('#corrForm')[0].reset(); $('#modalContainer').removeClass('show').hide(); });

$('#saveCorrStatus').click(function(event){
    event.preventDefault();
    var formData = new FormData($('#corrForm')[0]);
    $.ajax({
      url:"/line/monitoring/trend/sign/save",
      type:"POST",
      data: formData,
      processData: false,
      contentType: false,
      success:function(result){ alert("저장되었습니다!"); signData(); getTrend(); selectedRowData=null; },
      error:function(){ alert('저장 중 오류가 발생했습니다.'); }
    });
});

function trendIntervalFunc(){ $("#startDate").val(trendStime()); $("#endDate").val(trendEtime()); fetchData(); }

function signData(){
    $.ajax({
        url:"/line/monitoring/trend/sign/list",
        type:"post",
        dataType:"json",
        data:{},
        success:function(result){ signDataTable.setData(result.data); }
    })
}

var signDataTable;
function getSignDataList() {
    if($("#signDataSearch").length===0){
        $("#signDataTable").before(`<div style="margin-bottom:8px;display:flex;justify-content:flex-end;">
            <input type="text" id="signDataSearch" placeholder="검색어 입력..." style="width:200px;padding:4px;border:1px solid #ccc;border-radius:4px;">
        </div>`);
    }
    signDataTable = new Tabulator('#signDataTable', {
        height:'200px', layout:'fitColumns', reactiveData:true, columnHeaderVertAlign:"middle", headerHozAlign:'center', renderHorizontal:"virtual", placeholder:"조회된 데이터가 없습니다.",
        ajaxResponse: function(url,params,response){ $("#signDataTable .tabulator-col.tabulator-sortable").css("height","55px"); return response; },
        columns:[
            { title:"tc_cnt", field:"tc_cnt", visible:false },
            { title:"작업자", field:"tc_user_name", hozAlign:"center", headerSort:true },
            { title:"작업내용", field:"tc_name", hozAlign:"center", headerSort:true },
            { title:"작업시간", field:"tc_regtime", hozAlign:"center", headerSort:true },
            { title:"비고", field:"tc_desc", hozAlign:"center", headerSort:false }
        ],
        rowClick:function(e,row){ $('#signDataTable .tabulator-row').removeClass('row_select'); row.getElement().classList.add('row_select'); selectedRowData=row.getData(); }
    });

    $("#signDataSearch").on("keyup", function(){
        const keyword = $(this).val();
        if(keyword==="") signDataTable.clearFilter();
        else signDataTable.setFilter([
            [
              { field:"tc_user_name", type:"like", value:keyword },
              { field:"tc_name", type:"like", value:keyword },
              { field:"tc_regtime", type:"like", value:keyword },
              { field:"tc_desc", type:"like", value:keyword }
            ]
        ]);
    });
}

var signListObj = {};
function fetchData() {
    const startDate=$("#startDate").val(), endDate=$("#endDate").val();
    $.ajax({
        type:"POST",
        url:"/line/monitoring/trend/list",
        data:{ startDate, endDate },
        success:function(result){
            if(!result || result.length===0){ alert("데이터가 없습니다."); return; }

            // 그룹화 + 중복 제거
            const grouped={}, uniqueOrder=[];
            result.forEach(r=>{
                const key = r.regtime;
                if(!grouped.hasOwnProperty(key)){
                    grouped[key] = r; // 최초 데이터만
                    uniqueOrder.push(key);
                }
            });
            categories = uniqueOrder.slice();

            // signListObj
            signListObj = {};
            memoSeries = []; // ✅ 메모용 시리즈 초기화

            uniqueOrder.forEach(rt => {
                const r = grouped[rt];
                if (r.tc_name || r.tc_desc || r.item_name|| r.cust_name || r.lot_name || r.tc_val !== null) {
                    const parts = [];
                    if (r.tc_name && r.tc_name.trim() !== "") parts.push("이름: " + escapeHtml(r.tc_name));
                    if (r.tc_desc && r.tc_desc.trim() !== "") parts.push("설명: " + escapeHtml(r.tc_desc));
                    if (r.lot_name && r.lot_name.trim() !== "") parts.push("LOT: " + escapeHtml(r.lot_name));
                    if (r.item_name && r.cust_name.trim() !== "") parts.push("회사명: " + escapeHtml(r.cust_name));
                    if (r.item_name && r.item_name.trim() !== "") parts.push("제품명: " + escapeHtml(r.item_name));

                    memoSeries.push({
                        x: uniqueOrder.indexOf(rt),
                        y: 950,
                        desc: parts.join("<br/>") // 비어있으면 그냥 빈 문자열
                    });
                }
            });


            // 시리즈 데이터 구성
            q_pv_1=uniqueOrder.map(rt=>safeNum(grouped[rt].q_pv_1));
            q_pv_2=uniqueOrder.map(rt=>safeNum(grouped[rt].q_pv_2));
            q_pv_3=uniqueOrder.map(rt=>safeNum(grouped[rt].q_pv_3));
            q_pv_4=uniqueOrder.map(rt=>safeNum(grouped[rt].q_pv_4));
            q_pv_5=uniqueOrder.map(rt=>safeNum(grouped[rt].q_pv_5));

            t_pv_1=uniqueOrder.map(rt=>safeNum(grouped[rt].t_pv_1));
            t_pv_2=uniqueOrder.map(rt=>safeNum(grouped[rt].t_pv_2));
            t_pv_3=uniqueOrder.map(rt=>safeNum(grouped[rt].t_pv_3));
            t_pv_4=uniqueOrder.map(rt=>safeNum(grouped[rt].t_pv_4));
            t_pv_5=uniqueOrder.map(rt=>safeNum(grouped[rt].t_pv_5));

            f_wash_pv=uniqueOrder.map(rt=>safeNum(grouped[rt].f_wash_pv));
            m_wash_pv=uniqueOrder.map(rt=>safeNum(grouped[rt].m_wash_pv));
            oil_pv=uniqueOrder.map(rt=>safeNum(grouped[rt].oil_pv));
            bc_pv=uniqueOrder.map(rt=>safeNum(grouped[rt].bc_pv));

            cp_pv_1=uniqueOrder.map(rt=>grouped[rt].cp_pv_1?Number(grouped[rt].cp_pv_1)/1000:null);
            cp_pv_2=uniqueOrder.map(rt=>grouped[rt].cp_pv_2?Number(grouped[rt].cp_pv_2)/1000:null);

            const newSeriesData=[ f_wash_pv, q_pv_1,q_pv_2,q_pv_3,q_pv_4,q_pv_5, oil_pv, m_wash_pv, bc_pv, t_pv_1,t_pv_2,t_pv_3,t_pv_4,t_pv_5, cp_pv_1, cp_pv_2 ];

            if(!chart) getTrend();
            else{
                chart.xAxis[0].setCategories(categories,false);
                chart.series.forEach((s,i)=>s.setData(newSeriesData[i]||[],false));
                // ✅ 메모 시리즈 갱신
                const memoIdx = chart.series.length - 1;
                chart.series[memoIdx].setData(memoSeries,false);
                chart.redraw();
            }
        },
        error:function(xhr,status,error){ console.error("❌ 에러:",error); alert("데이터 조회 중 오류가 발생했습니다."); }
    });
}

function getTrend(){
    chart = Highcharts.chart('container',{
        chart:{ type:'line' },
        title:{ text:'온도 트렌드' },
        xAxis:{
            categories:categories,
            title:{ text:'시간' },
            labels: {
                formatter: function() { return dataLabelFormat(this.value); },
                step: 2
            },
            tickInterval:40
        },
        yAxis:[
            { title:{ text:"온도", rotation:0 }, labels:{ align:"right", x:-10 }, min:0, max:1000 },
            { opposite:true, title:{ text:"CP", rotation:0 }, labels:{ align:"left", x:10 }, min:0, max:2 }
        ],
        tooltip:{
            shared:true,
            crosshairs:true,
            formatter:function(){
                var s='<b>'+(this.x||'')+'</b><br/>';
                this.points.forEach(pt=>{ s+=pt.series.name+': '+(pt.y===null?'-':pt.y)+'<br/>'; });
                var regtime=categories[this.points[0].point.x];
                var labelHtml=signListObj[regtime]||"";
                if(labelHtml) s+='<hr/>'+labelHtml;
                return s;
            }
        },
        series:[
            { name:'전세정기', data:f_wash_pv, yAxis:0 },
            { name:'소입로1존', data:q_pv_1, yAxis:0 },
            { name:'소입로2존', data:q_pv_2, yAxis:0 },
            { name:'소입로3존', data:q_pv_3, yAxis:0 },
            { name:'소입로4존', data:q_pv_4, yAxis:0 },
            { name:'소입로5존', data:q_pv_5, yAxis:0 },
            { name:'소입유조', data:oil_pv, yAxis:0 },
            { name:'중간세정기', data:m_wash_pv, yAxis:0 },
            { name:'방청조', data:bc_pv, yAxis:0 },
            { name:'소려로1존', data:t_pv_1, yAxis:0 },
            { name:'소려로2존', data:t_pv_2, yAxis:0 },
            { name:'소려로3존', data:t_pv_3, yAxis:0 },
            { name:'소려로4존', data:t_pv_4, yAxis:0 },
            { name:'소려로5존', data:t_pv_5, yAxis:0 },
            { name:'CP-A', data:cp_pv_1, yAxis:1 },
            { name:'CP-B', data:cp_pv_2, yAxis:1 },
            {   // ✅ 메모 시리즈 추가
                name:'메모',
                type:'scatter',
                data:memoSeries,
                yAxis:0,
                marker:{ symbol:'circle', radius:4 },
                dataLabels:{
                    enabled:true,
                    useHTML:true,
                    formatter:function(){ return this.point.desc || ""; }
                },
                tooltip:{
                    pointFormatter:function(){ return this.desc ? `<span style="color:blue">${point.desc}</span>` : ""; }
                }
            }
        ]
    });
}


function downloadExcel() {
    if (!chart || !categories || categories.length === 0) {
        alert("다운로드할 데이터가 없습니다.");
        return;
    }

    $("#excelOverlay").show();
    $("#excelLoading").show();

    try {
        // 엑셀 데이터 배열 생성
        const excelData = categories.map((time, idx) => {
            const row = {
                "시간": time || "",
                "전세정기": f_wash_pv[idx] !== null ? f_wash_pv[idx] : "",
                "소입로1존": q_pv_1[idx] !== null ? q_pv_1[idx] : "",
                "소입로2존": q_pv_2[idx] !== null ? q_pv_2[idx] : "",
                "소입로3존": q_pv_3[idx] !== null ? q_pv_3[idx] : "",
                "소입로4존": q_pv_4[idx] !== null ? q_pv_4[idx] : "",
                "소입로5존": q_pv_5[idx] !== null ? q_pv_5[idx] : "",
                "소입유조": oil_pv[idx] !== null ? oil_pv[idx] : "",
                "중간세정기": m_wash_pv[idx] !== null ? m_wash_pv[idx] : "",
                "방청조": bc_pv[idx] !== null ? bc_pv[idx] : "",
                "소려로1존": t_pv_1[idx] !== null ? t_pv_1[idx] : "",
                "소려로2존": t_pv_2[idx] !== null ? t_pv_2[idx] : "",
                "소려로3존": t_pv_3[idx] !== null ? t_pv_3[idx] : "",
                "소려로4존": t_pv_4[idx] !== null ? t_pv_4[idx] : "",
                "소려로5존": t_pv_5[idx] !== null ? t_pv_5[idx] : "",
                "CP-A": cp_pv_1[idx] !== null ? cp_pv_1[idx] : "",
                "CP-B": cp_pv_2[idx] !== null ? cp_pv_2[idx] : ""
            };

            // 메모 데이터 추가
            const memo = memoSeries.find(m => m.x === idx);
            if (memo) {
                row["메모"] = memo.desc.replace(/<br\/>/g, " | ");
            } else {
                row["메모"] = "";
            }

            return row;
        });

        // 워크시트 생성
        const ws = XLSX.utils.json_to_sheet(excelData);
        
        // 컬럼 너비 설정
        ws['!cols'] = [
            {wch: 20},  // 시간
            {wch: 12},  // 전세정기
            {wch: 12},  // 소입로1존
            {wch: 12},  // 소입로2존
            {wch: 12},  // 소입로3존
            {wch: 12},  // 소입로4존
            {wch: 12},  // 소입로5존
            {wch: 12},  // 소입유조
            {wch: 12},  // 중간세정기
            {wch: 12},  // 방청조
            {wch: 12},  // 소려로1존
            {wch: 12},  // 소려로2존
            {wch: 12},  // 소려로3존
            {wch: 12},  // 소려로4존
            {wch: 12},  // 소려로5존
            {wch: 12},  // CP-A
            {wch: 12},  // CP-B
            {wch: 50}   // 메모
        ];

        // 워크북 생성
        const wb = XLSX.utils.book_new();
        XLSX.utils.book_append_sheet(wb, ws, "온도트렌드");

        // 파일명 생성 (조회 기간 포함)
        const startDate = $("#startDate").val().replace(/[-:\s]/g, '').substring(0, 12);
        const endDate = $("#endDate").val().replace(/[-:\s]/g, '').substring(0, 12);
        const fileName = "온도트렌드_" + startDate + "_" + endDate + ".xlsx";

        // 다운로드
        XLSX.writeFile(wb, fileName);

        setTimeout(function() {
            $("#excelOverlay").hide();
            $("#excelLoading").hide();
        }, 500);

    } catch (error) {
        console.error("엑셀 다운로드 실패:", error);
        alert("엑셀 다운로드에 실패했습니다.");
        $("#excelOverlay").hide();
        $("#excelLoading").hide();
    }
}
</script>

</body>
</html>