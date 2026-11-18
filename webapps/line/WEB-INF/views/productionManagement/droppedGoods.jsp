<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="ko">
<head>
<script src="/line/mock/mock-loader.js"></script>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>낙하품관리</title>
<%@include file="../include/pluginpage.jsp" %>
<jsp:include page="../include/tabBar.jsp"/>
<link href="/vendor/tabulator/5.5.0/tabulator.min.css" rel="stylesheet">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=IBM+Plex+Mono:wght@400;500&family=IBM+Plex+Sans+KR:wght@400;500;600&display=swap">
<link rel="stylesheet" href="/line/css/opsList/ops-list.css">
<style>
/* 화면 높이에 맞춤: 페이지는 스크롤 없이, 목록 카드가 남은 높이를 채우고 표 안에서만 스크롤 */
html, body.ops { height: 100%; }
body.ops { display: flex; flex-direction: column; overflow: hidden; min-height: 0; }
body.ops > .ops-page { flex: 1; min-height: 0; }
body.ops > .ops-page > .ops-card { flex: 1; min-height: 0; display: flex; flex-direction: column; }
body.ops > .ops-page > .ops-card > #tab1 { flex: 1; min-height: 0; }
</style>
</head>
<body class="ops">

<!-- ===== 헤더 + 툴바 ===== -->
<header class="ops-head">
  <div class="ops-head-in">
    <h1 class="ops-title">낙하품 관리</h1>
    <span class="ops-label">작업일자</span>
    <input type="text" class="ops-input dayselect daySet" id="w_date" placeholder="YYYY-MM-DD" autocomplete="off"/>
    <button class="ops-btn primary select-button" onclick="getDroppedGoodsList();">
      <svg viewBox="0 0 24 24"><circle cx="11" cy="11" r="7"/><line x1="20" y1="20" x2="16" y2="16"/></svg>조회
    </button>
    <span class="ops-spacer"></span>
    <button class="ops-btn excel-button">
      <svg viewBox="0 0 24 24"><path d="M12 4v11"/><polyline points="7 10 12 15 17 10"/><line x1="5" y1="20" x2="19" y2="20"/></svg>엑셀 다운로드
    </button>
    <input type="file" id="fileInput" style="display:none;">
  </div>
</header>

<main class="ops-page">

  <!-- 지표: 낙하품 발생이 첫 시선 -->
  <section class="ops-kpi" aria-label="요약">
    <div class="hero">
      <span class="kpi-label">낙하품 발생</span>
      <span class="kpi-value" id="kpi-drop">0</span>
      <span class="kpi-sub">O 표기 LOT 수</span>
    </div>
    <div>
      <span class="kpi-label">전체 LOT</span>
      <span class="kpi-value" id="kpi-total">0</span>
      <span class="kpi-sub">조회된 총 건수</span>
    </div>
    <div>
      <span class="kpi-label">이상 없음</span>
      <span class="kpi-value" id="kpi-ok">0</span>
      <span class="kpi-sub">X 표기 LOT 수</span>
    </div>
    <div>
      <span class="kpi-label">미확인</span>
      <span class="kpi-value" id="kpi-warn">0</span>
      <span class="kpi-sub">미기재 LOT 수</span>
    </div>
    <div>
      <span class="kpi-label">거래처 수</span>
      <span class="kpi-value" id="kpi-cust">0</span>
      <span class="kpi-sub">고유 거래처</span>
    </div>
  </section>

  <!-- 이력 표 -->
  <section class="ops-card">
    <div class="ops-card-head">
      <h2>낙하품 확인 이력</h2>
      <span class="note"><span id="card-date-label">-</span> · O 낙하품 있음 · X 없음 · 셀을 눌러 입력</span>
    </div>

    <div id="tab1" class="ops-table"></div>

    <div class="ops-card-foot">
      <span id="footer-info">데이터를 조회하세요</span>
      <span>마지막 조회 <strong id="footer-time">-</strong></span>
    </div>
  </section>

</main>

<script>
let now_page_code = "e05";
let userTable = null;

/* ─── 날짜 유틸 ─── */
function pad2(n){ return String(n).padStart(2,'0'); }
function todayDate(){
  var d = new Date();
  return d.getFullYear()+'-'+pad2(d.getMonth()+1)+'-'+pad2(d.getDate());
}

/* ─── O/X 포매터 ─── */
function oxFormatter(cell){
  var v = (cell.getValue()||'').toString().trim().toUpperCase();
  // O = 낙하품 있음(이상), X = 없음
  if(v==='O') return '<span class="st bad"><i></i>O</span>';
  if(v==='X') return '<span class="st off"><i></i>X</span>';
  return '<span class="c-none">—</span>';
}

/* ─── 시간 포매터 ─── */
function timeFormatter(cell){
  var v = cell.getValue() || '';
  return v ? '<span class="c-time">'+v+'</span>' : '<span class="c-none">—</span>';
}

/* ─── KPI 업데이트 ─── */
function updateKpi(data){
  var total  = data.length;
  var dropCnt = 0, okCnt = 0, warnCnt = 0;
  var custSet = {};

  data.forEach(function(r){
    var vals = [r.d_in, r.d_qf, r.d_tf, r.d_out];
    var hasO = vals.some(function(v){ return (v||'').trim().toUpperCase()==='O'; });
    var hasX = vals.every(function(v){ return (v||'').trim().toUpperCase()==='X' || !(v||'').trim(); });
    var allFilled = vals.every(function(v){ return (v||'').trim(); });

    if(hasO) dropCnt++;
    else if(allFilled) okCnt++;
    else warnCnt++;

    if(r.cust_name) custSet[r.cust_name] = 1;
  });

  document.getElementById('kpi-total').textContent = total.toLocaleString();
  document.getElementById('kpi-drop').textContent  = dropCnt.toLocaleString();
  document.getElementById('kpi-drop').classList.toggle('bad', dropCnt > 0);
  document.getElementById('kpi-ok').textContent    = okCnt.toLocaleString();
  document.getElementById('kpi-warn').textContent  = warnCnt.toLocaleString();
  document.getElementById('kpi-cust').textContent  = Object.keys(custSet).length.toLocaleString();

  var dateVal = document.querySelector('.dayselect').value || '-';
  document.getElementById('card-date-label').textContent = dateVal + ' 기준';
  document.getElementById('footer-info').innerHTML = '총 <strong>'+total+'</strong>건';

  var now = new Date();
  document.getElementById('footer-time').textContent =
    pad2(now.getHours())+':'+pad2(now.getMinutes())+':'+pad2(now.getSeconds());
}

/* ─── 테이블 조회 ─── */
function getDroppedGoodsList() {
  userTable = new Tabulator("#tab1", {
    height: "100%",
    layout: "fitColumns",
    selectable: true,
    tooltips: true,
    selectableRangeMode: "click",
    reactiveData: true,
    headerHozAlign: "center",
    ajaxConfig: "POST",
    ajaxLoader: false,
    ajaxURL: "/line/productionManagement/droppedGoods/getDroppedGoodsList",
    ajaxParams: {
      "w_date": document.querySelector('.dayselect').value
    },
    ajaxResponse: function(url, params, response){
      var data = response.data || [];
      updateKpi(data);
      return data;
    },
    placeholder: "조회된 데이터가 없습니다.",
    columns: [
      { title:"작업 LOT",  field:"w_ci_lot",    hozAlign:"center", width:130, headerSort:true,
        formatter:function(cell){ return '<span class="c-lot">'+(cell.getValue()||'-')+'</span>'; }
      },
      { title:"투입시간",  field:"w_sdatetime", hozAlign:"center", width:160, headerSort:true, formatter:timeFormatter },
      { title:"거래처",    field:"cust_name",   hozAlign:"left", width:96, headerSort:false,
        formatter:function(cell){ return cell.getValue()||'<span class="c-none">—</span>'; }
      },
      { title:"품번",      field:"prod_code",   hozAlign:"left", width:120,  headerSort:false,
        formatter:function(cell){ var v=cell.getValue()||''; return v?'<span class="c-lot">'+v+'</span>':'<span class="c-none">—</span>'; }
      },
      { title:"품명",      field:"item_name",   hozAlign:"left",   width:160, headerSort:false },
      {
        title:"낙하품유무", hozAlign:"center", headerSort:false,
        columns:[
          { title:"투입",   field:"d_in",      hozAlign:"center", width:60,  headerSort:false, formatter:oxFormatter,   editor:"select", editorParams:{values:["O","X"]} },
          { title:"확인",   field:"d_in_time",  hozAlign:"center", width:80,  headerSort:false, formatter:timeFormatter },
          { title:"전세정기",   field:"d_qf",       hozAlign:"center", width:60,  headerSort:false, formatter:oxFormatter,   editor:"select", editorParams:{values:["O","X"]} },
          { title:"확인",   field:"d_qf_time",  hozAlign:"center", width:80,  headerSort:false, formatter:timeFormatter },
          { title:"소입유조", field:"d_tf",       hozAlign:"center", width:80,  headerSort:false, formatter:oxFormatter,   editor:"select", editorParams:{values:["O","X"]} },
          { title:"확인",   field:"d_tf_time",  hozAlign:"center", width:80,  headerSort:false, formatter:timeFormatter },
          { title:"중간세정기",   field:"d_out",      hozAlign:"center", width:80,  headerSort:false, formatter:oxFormatter,   editor:"select", editorParams:{values:["O","X"]} },
          { title:"확인",   field:"d_out_time", hozAlign:"center", width:80,  headerSort:false, formatter:timeFormatter },
          { title:"방청조",  field:"d_new",      hozAlign:"center", width:60,  headerSort:false, formatter:oxFormatter,   editor:"select", editorParams:{values:["O","X"]} },
          { title:"확인",   field:"d_new_time", hozAlign:"center", width:80,  headerSort:false, formatter:timeFormatter },
          { title:"확인자", field:"d_name",     hozAlign:"center", width:90,  headerSort:false, editor:"input" }
        ]
      },
      { title:"특이사항", field:"d_bigo", hozAlign:"left",  editor:"input", headerSort:false }
    ],
    rowFormatter: function(row){
      var data = row.getData();
      var vals = [data.d_in, data.d_qf, data.d_tf, data.d_out];
      var hasO = vals.some(function(v){ return (v||'').trim().toUpperCase()==='O'; });
      // 낙하품 발생 행: 왼쪽 2px 경고선 + 아주 옅은 배경 (레이아웃 밀림 없도록 inset 그림자)
      row.getElement().style.background = hasO ? 'var(--ops-bad-tint)' : '';
      row.getElement().style.boxShadow  = hasO ? 'inset 2px 0 0 var(--ops-bad)' : '';
    },
    rowClick: function(e, row){
      document.querySelectorAll('#tab1 .tabulator-row').forEach(function(el){ el.classList.remove('row_select'); });
      row.getElement().classList.add('row_select');
    },
    cellEdited: function(cell){
      var field    = cell.getField();
      var value    = cell.getValue();
      var rowData  = cell.getRow().getData();
      var w_ci_lot = rowData.w_ci_lot;

      console.log('✅ [수정 발생] LOT:', w_ci_lot, '| 컬럼:', field, '| 값:', value);

      $.ajax({
        url: "/line/productionManagement/droppedGoods/updateDroppedGoods",
        type: "POST",
        contentType: "application/json",
        data: JSON.stringify({ d_lot: w_ci_lot, column: field, value: value }),
        success: function(res){
          console.log('✅ [서버 응답]', res);
          if(res.result === 'success'){
            userTable.replaceData();
          } else {
            alert('저장 실패: ' + res.message);
          }
        },
        error: function(xhr, status, error){
          console.error('❌ [서버 통신 실패]', status, error);
          alert('서버 통신 실패');
        }
      });
    }
  });
}

/* ─── 엑셀 다운로드 ─── */
function downloadDroppedGoodsExcel(){
  if(!userTable){ return; }
  var tableData = userTable.getData();
  if(!tableData || tableData.length === 0){ alert('다운로드할 데이터가 없습니다.'); return; }

  var excelData = tableData.map(function(row, index){
    return {
      "NO": index+1,
      "작업LOT": row.w_ci_lot||"",
      "투입시간": row.w_sdatetime||"",
      "거래처": row.cust_name||"",
      "품번": row.prod_code||"",
      "품명": row.item_name||"",
      "투입": row.d_in||"",
      "투입</br>확인시간": row.d_in_time||"",
      "전세정기": row.d_qf||"",
      "전세정기</br> 확인시간": row.d_qf_time||"",
      "소입유조": row.d_tf||"",
      "소입유조</br> 확인시간": row.d_tf_time||"",
      "중간 새정기": row.d_out||"",
      "중간 세정기</br>확인시간": row.d_out_time||"",
      "방청조": row.d_new||"",
      "방청조</br>확인시간": row.d_new_time||"",
      "확인자": row.d_name||"",
      "특이사항": row.d_bigo||""
    };
  });

  var ws = XLSX.utils.json_to_sheet(excelData);
  ws['!cols'] = [
    {wch:5},{wch:15},{wch:18},{wch:15},{wch:12},{wch:20},
    {wch:6},{wch:18},{wch:6},{wch:18},{wch:8},{wch:18},
    {wch:6},{wch:18},{wch:10},{wch:20}
  ];

  var wb = XLSX.utils.book_new();
  XLSX.utils.book_append_sheet(wb, ws, "낙하품 관리 이력");

  var workDate = document.querySelector('.dayselect').value || '전체';
  var now = new Date();
  var timeStr = pad2(now.getHours()) + pad2(now.getMinutes());
  XLSX.writeFile(wb, '낙하품관리_'+workDate+'_'+timeStr+'.xlsx');
}

/* ─── DOM Ready ─── */
$(function(){
  document.querySelector('.dayselect').value = todayDate();
  getDroppedGoodsList();
  $('.excel-button').on('click', downloadDroppedGoodsExcel);
});
</script>

</body>
</html>
