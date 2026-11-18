<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="ko">
<head>
<script src="/line/mock/mock-loader.js"></script>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>부적합품</title>
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
    <h1 class="ops-title">부적합품 관리</h1>
    <span class="ops-label">작업월</span>
    <input type="text" class="ops-input dayselect daySet" placeholder="YYYY-MM" autocomplete="off"/>
    <button class="ops-btn select-button" onclick="getnoProductList();">
      <svg viewBox="0 0 24 24"><circle cx="11" cy="11" r="7"/><line x1="20" y1="20" x2="16" y2="16"/></svg>조회
    </button>
    <span class="ops-spacer"></span>
    <button class="ops-btn excel-button">
      <svg viewBox="0 0 24 24"><path d="M12 4v11"/><polyline points="7 10 12 15 17 10"/><line x1="5" y1="20" x2="19" y2="20"/></svg>엑셀 다운로드
    </button>
    <button class="ops-btn danger delete-button">
      <svg viewBox="0 0 24 24"><polyline points="4 7 20 7"/><path d="M18 7l-1 13H7L6 7"/><path d="M9 7V4h6v3"/></svg>삭제
    </button>
    <button class="ops-btn primary insert-button">
      <svg viewBox="0 0 24 24"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>부적합 등록
    </button>
    <input type="file" id="fileInput" style="display:none;">
  </div>
</header>

<main class="ops-page">

  <!-- 지표: 총 불량수량이 첫 시선 -->
  <section class="ops-kpi" aria-label="요약">
    <div class="hero">
      <span class="kpi-label">총 불량수량</span>
      <span class="kpi-value" id="kpi-cnt">0</span>
      <span class="kpi-sub">EA 합계</span>
    </div>
    <div>
      <span class="kpi-label">전체 건수</span>
      <span class="kpi-value" id="kpi-total">0</span>
      <span class="kpi-sub">조회된 총 건수</span>
    </div>
    <div>
      <span class="kpi-label">최다 불량유형</span>
      <span class="kpi-value text" id="kpi-defect">-</span>
      <span class="kpi-sub" id="kpi-defect-sub">유형별 1위</span>
    </div>
    <div>
      <span class="kpi-label">불량 유형 수</span>
      <span class="kpi-value" id="kpi-type">0</span>
      <span class="kpi-sub">고유 유형 수</span>
    </div>
    <div>
      <span class="kpi-label">조치 완료</span>
      <span class="kpi-value" id="kpi-ok">0</span>
      <span class="kpi-sub">대상·실시 모두 O</span>
    </div>
  </section>

  <!-- 현황 표 -->
  <section class="ops-card">
    <div class="ops-card-head">
      <h2>부적합품 현황</h2>
      <span class="note"><span id="card-date-label">-</span> · 행을 두 번 눌러 수정</span>
    </div>
    <div id="tab1" class="ops-table"></div>
    <div class="ops-card-foot">
      <span id="footer-info">데이터를 조회하세요</span>
      <span>마지막 조회 <strong id="footer-time">-</strong></span>
    </div>
  </section>

</main>

<!-- ===== 부적합품 등록/수정 모달 ===== -->
<div id="modalContainer" class="modal-overlay">
  <div class="modal-box" role="dialog" aria-labelledby="npModalTitle">
    <div class="modal-head">
      <h2 id="npModalTitle">부적합품 등록</h2>
      <span class="modal-close" id="mainClose" aria-label="닫기">✕</span>
    </div>
    <form id="corrForm" autocomplete="off">
      <input type="hidden" name="idx"/>
      <div class="modal-body form-grid">
        <div class="form-group">
          <label class="form-label">발생일</label>
          <input type="text" name="d_date" class="form-input mono" placeholder="YYYY-MM-DD"/>
        </div>
        <div class="form-group">
          <label class="form-label">종료시간</label>
          <input type="text" name="d_end_time" class="form-input mono" placeholder="HH:MM"/>
        </div>
        <div class="form-group full">
          <label class="form-label">작업 LOT</label>
          <div class="input-with-btn">
            <input type="text" name="d_lot" class="form-input mono" placeholder="작업 LOT 입력"/>
            <button type="button" class="ops-btn" id="btnPumbunOpen">
              <svg viewBox="0 0 24 24"><circle cx="11" cy="11" r="7"/><line x1="20" y1="20" x2="16" y2="16"/></svg>제품 검색
            </button>
          </div>
        </div>
        <div class="form-group">
          <label class="form-label">품번</label>
          <input type="text" name="d_pum_bun" class="form-input mono" placeholder="품번"/>
        </div>
        <div class="form-group">
          <label class="form-label">품명</label>
          <input type="text" name="d_pum_name" class="form-input" placeholder="품명"/>
        </div>
        <div class="form-group">
          <label class="form-label">불량유형</label>
          <select name="d_way" class="form-select">
            <option value="액고임">액고임</option>
            <option value="이종혼입">이종혼입</option>
            <option value="녹 발생">녹 발생</option>
            <option value="코팅 문제">코팅 문제</option>
            <option value="이물질">이물질</option>
            <option value="색상 이상">색상 이상</option>
            <option value="크랙">크랙</option>
            <option value="찍힘">찍힘</option>
            <option value="기타">기타</option>
          </select>
        </div>
        <div class="form-group">
          <label class="form-label">불량수량 (EA)</label>
          <input type="number" name="no_pro_cnt" class="form-input" placeholder="0"/>
        </div>
        <div class="form-group full">
          <label class="form-label">발생원인</label>
          <input type="text" name="d_cause" class="form-input" placeholder="발생원인 입력"/>
        </div>
        <div class="form-group full">
          <label class="form-label">조치내용</label>
          <input type="text" name="d_after" class="form-input" placeholder="조치내용 입력"/>
        </div>
        <div class="form-group">
          <label class="form-label">대상유무</label>
          <div class="radio-row">
            <label class="radio-item"><input type="radio" name="d_yn_1" value="O"> O</label>
            <label class="radio-item"><input type="radio" name="d_yn_1" value="X"> X</label>
          </div>
        </div>
        <div class="form-group">
          <label class="form-label">실시유무</label>
          <div class="radio-row">
            <label class="radio-item"><input type="radio" name="d_yn_2" value="O"> O</label>
            <label class="radio-item"><input type="radio" name="d_yn_2" value="X"> X</label>
          </div>
        </div>
        <div class="form-group">
          <label class="form-label">작성자</label>
          <input type="text" name="d_name" class="form-input" placeholder="작성자 입력"/>
        </div>
        <div class="form-group">
          <label class="form-label">특이사항</label>
          <input type="text" name="d_bigo" class="form-input" placeholder="특이사항 입력"/>
        </div>
      </div>
      <div class="modal-btn-row">
        <button type="button" id="closeModal" class="ops-btn">닫기</button>
        <button type="submit" id="saveCorrStatus" class="ops-btn primary">저장</button>
      </div>
    </form>
  </div>
</div>

<!-- ===== 품번 검색 모달 ===== -->
<div id="pumbunModal" class="pumbun-overlay">
  <div class="pumbun-box" role="dialog" aria-labelledby="npPumTitle">
    <div class="modal-head">
      <h2 id="npPumTitle">품번 검색</h2>
      <span class="modal-close" id="pumbunClose" aria-label="닫기">✕</span>
    </div>
    <div class="pumbun-search-row">
      <span class="ops-label">품번</span>
      <input type="text" id="s_pnum" class="form-input mono pumModalEnter" placeholder="품번 입력"/>
      <span class="ops-label">품명</span>
      <input type="text" id="s_gang" class="form-input pumModalEnter" placeholder="품명 입력"/>
      <button class="ops-btn primary" type="button" onclick="initPumbunTabu();">
        <svg viewBox="0 0 24 24"><circle cx="11" cy="11" r="7"/><line x1="20" y1="20" x2="16" y2="16"/></svg>조회
      </button>
    </div>
    <div id="pumbunTabu" class="ops-table"></div>
  </div>
</div>

<script>
let now_page_code = "e07";
let userTable   = null;
let pumbunTabu  = null;

/* ─── 날짜 유틸 ─── */
function pad2(n){ return String(n).padStart(2,'0'); }
function todayDate(){
  var d = new Date();
  return d.getFullYear()+'-'+pad2(d.getMonth()+1)+'-'+pad2(d.getDate());
}
function todayMonth(){
  var d = new Date();
  return d.getFullYear()+'-'+pad2(d.getMonth()+1);
}

/* ─── O/X 포매터 ─── */
function oxFormatter(cell){
  var v = (cell.getValue()||'').toString().trim().toUpperCase();
  // 대상/실시 O = 조치됨, X = 미조치
  if(v==='O') return '<span class="st ok"><i></i>O</span>';
  if(v==='X') return '<span class="st off"><i></i>X</span>';
  return '<span class="c-none">—</span>';
}

/* ─── KPI 업데이트 ─── */
function updateKpi(data){
  var total  = data.length;
  var cntSum = data.reduce(function(a,r){ return a+(Number(r.no_pro_cnt)||0); }, 0);

  // 불량유형 집계
  var typeMap = {};
  data.forEach(function(r){ var t=r.d_way||'기타'; typeMap[t]=(typeMap[t]||0)+1; });
  var topType='-', topCnt=0;
  Object.keys(typeMap).forEach(function(k){ if(typeMap[k]>topCnt){ topCnt=typeMap[k]; topType=k; } });
  var typeCount = Object.keys(typeMap).length;

  // 조치완료 (d_yn_1, d_yn_2 모두 O)
  var okCnt = data.filter(function(r){ return (r.d_yn_1||'').toUpperCase()==='O' && (r.d_yn_2||'').toUpperCase()==='O'; }).length;

  document.getElementById('kpi-total').textContent  = total.toLocaleString();
  document.getElementById('kpi-cnt').textContent    = cntSum.toLocaleString();
  document.getElementById('kpi-type').textContent   = typeCount.toLocaleString();
  document.getElementById('kpi-ok').textContent     = okCnt.toLocaleString();

  var defEl = document.getElementById('kpi-defect');
  defEl.textContent = topType;
  defEl.title = topType;
  document.getElementById('kpi-defect-sub').textContent = topCnt + '건 발생';

  var dateVal = document.querySelector('.dayselect').value || '-';
  document.getElementById('card-date-label').textContent = dateVal + ' 기준';
  document.getElementById('footer-info').innerHTML = '총 <strong>'+total+'</strong>건';

  var now = new Date();
  document.getElementById('footer-time').textContent =
    pad2(now.getHours())+':'+pad2(now.getMinutes())+':'+pad2(now.getSeconds());
}

/* ─── 부적합 리스트 조회 ─── */
function getnoProductList(){
  userTable = new Tabulator("#tab1", {
    height: "100%",
    layout: "fitColumns",
    selectable: true,
    reactiveData: true,
    headerHozAlign: "center",
    ajaxConfig: "POST",
    ajaxLoader: false,
    ajaxURL: "/line/productionManagement/noProduct/getNoProductList",
    ajaxParams: { w_date: document.querySelector('.dayselect').value },
    ajaxResponse: function(url, params, response){
      var data = response.data || [];
      updateKpi(data);
      return data;
    },
    placeholder: "조회된 데이터가 없습니다.",
    columns: [
      { title:"IDX",       field:"idx",        visible:false },
      { title:"발생일",    field:"d_date",     hozAlign:"center", width:112,
        formatter:function(c){ return c.getValue()?'<span class="c-time">'+c.getValue()+'</span>':'<span class="c-none">—</span>'; }
      },
      { title:"작업 LOT",  field:"d_lot",      hozAlign:"center", width:128,
        formatter:function(c){ return c.getValue()?'<span class="c-lot">'+c.getValue()+'</span>':'<span class="c-none">—</span>'; }
      },
      { title:"품번",      field:"d_pum_bun",  hozAlign:"left",   width:120,
        formatter:function(c){ return c.getValue()?'<span class="c-lot">'+c.getValue()+'</span>':'<span class="c-none">—</span>'; }
      },
      { title:"품명",      field:"d_pum_name", hozAlign:"left",   width:150 },
      { title:"불량유형",  field:"d_way",      hozAlign:"left",   width:100 },
      { title:"종료시간",  field:"d_end_time", hozAlign:"center", width:88,
        formatter:function(c){ return c.getValue()?'<span class="c-time">'+c.getValue()+'</span>':'<span class="c-none">—</span>'; }
      },
      { title:"불량수량",  field:"no_pro_cnt", hozAlign:"right",  width:88,
        formatter:function(c){ return c.getValue()?'<span class="c-num">'+Number(c.getValue()).toLocaleString()+'</span>':'<span class="c-none">—</span>'; }
      },
      { title:"발생원인",  field:"d_cause",    hozAlign:"left",   width:220 },
      { title:"조치내용",  field:"d_after",    hozAlign:"left",   width:220 },
      { title:"대상유무",  field:"d_yn_1",     hozAlign:"center", width:90,  formatter:oxFormatter },
      { title:"실시유무",  field:"d_yn_2",     hozAlign:"center", width:90,  formatter:oxFormatter },
      { title:"작성자",    field:"d_name",     hozAlign:"center", width:90 },
      { title:"특이사항",  field:"d_bigo",     hozAlign:"left",   width:180 }
    ],
    rowFormatter: function(row){
      var d = row.getData();
      var hasDefect = (d.d_yn_1||'').toUpperCase()==='O' || (d.d_yn_2||'').toUpperCase()==='O';
      // 대상/실시 표기 행: 왼쪽 2px 경고선만 (배경 대신, 레이아웃 밀림 없음)
      row.getElement().style.boxShadow = hasDefect ? 'inset 2px 0 0 var(--ops-bad)' : '';
    },
    rowClick: function(e, row){
      document.querySelectorAll('#tab1 .tabulator-row').forEach(function(el){ el.classList.remove('row_select'); });
      row.getElement().classList.add('row_select');
    },
    rowDblClick: function(e, row){
      var d = row.getData();
      document.getElementById('corrForm').reset();
      $("input[name='idx']").val(d.idx);
      $("input[name='d_date']").val(d.d_date);
      $("input[name='d_lot']").val(d.d_lot);
      $("input[name='d_pum_bun']").val(d.d_pum_bun);
      $("input[name='d_pum_name']").val(d.d_pum_name);
      $("select[name='d_way']").val(d.d_way);
      $("input[name='d_end_time']").val(d.d_end_time);
      $("input[name='no_pro_cnt']").val(d.no_pro_cnt);
      $("input[name='d_cause']").val(d.d_cause);
      $("input[name='d_after']").val(d.d_after);
      $("input[name='d_yn_1'][value='"+d.d_yn_1+"']").prop('checked',true);
      $("input[name='d_yn_2'][value='"+d.d_yn_2+"']").prop('checked',true);
      $("input[name='d_name']").val(d.d_name);
      $("input[name='d_bigo']").val(d.d_bigo);
      showModal('modalContainer');
    }
  });
}

/* ─── 품번 Tabulator 초기화 ─── */
function initPumbunTabu(){
  pumbunTabu = new Tabulator("#pumbunTabu", {
    height: "520px",
    layout: "fitDataFill",
    headerSort: false,
    reactiveData: true,
    headerHozAlign: "center",
    ajaxConfig: { method:"POST" },
    ajaxURL: "/line/productionManagement/heatTreatment/pumbun/list",
    ajaxProgressiveLoad: "scroll",
    ajaxParams: {
      item_no:   document.getElementById('s_pnum').value,
      item_name: document.getElementById('s_gang').value,
      cust_name: ""
    },
    ajaxResponse: function(url, params, res){ return res; },
    placeholder: "조회된 데이터가 없습니다.",
    columns: [
      { title:"품번", field:"item_no",   width:260 },
      { title:"품명", field:"item_name", width:300 }
    ],
    rowClick: function(e, row){
      document.querySelectorAll('#pumbunTabu .tabulator-row').forEach(function(el){ el.classList.remove('row_select'); });
      row.getElement().classList.add('row_select');
    },
    rowDblClick: function(e, row){
      var d = row.getData();
      $("input[name='d_pum_bun']").val(d.item_no);
      $("input[name='d_pum_name']").val(d.item_name);
      hideModal('pumbunModal');
    }
  });
}

/* ─── 모달 show/hide ─── */
function showModal(id){
  var ov = document.getElementById(id);
  ov.style.display = 'flex';
  setTimeout(function(){ ov.classList.add('show'); }, 10);
}
function hideModal(id){
  var ov = document.getElementById(id);
  ov.classList.remove('show');
  setTimeout(function(){ ov.style.display = 'none'; }, 220);
}

/* ─── 저장 ─── */
$('#corrForm').on('submit', function(e){
  e.preventDefault();
  var formData = {
    idx:       $("input[name='idx']").val(),
    d_date:    $("input[name='d_date']").val(),
    d_lot:     $("input[name='d_lot']").val(),
    d_pum_bun: $("input[name='d_pum_bun']").val(),
    d_pum_name:$("input[name='d_pum_name']").val(),
    d_way:     $("select[name='d_way']").val(),
    d_end_time:$("input[name='d_end_time']").val(),
    no_pro_cnt:$("input[name='no_pro_cnt']").val(),
    d_cause:   $("input[name='d_cause']").val(),
    d_after:   $("input[name='d_after']").val(),
    d_yn_1:    $("input[name='d_yn_1']:checked").val(),
    d_yn_2:    $("input[name='d_yn_2']:checked").val(),
    d_name:    $("input[name='d_name']").val(),
    d_bigo:    $("input[name='d_bigo']").val()
  };
  var url = formData.idx
    ? '/line/productionManagement/noProduct/updateNoProduct'
    : '/line/productionManagement/noProduct/insertNoProduct';

  $.ajax({
    url: url, type:'POST', contentType:'application/json',
    data: JSON.stringify(formData),
    success: function(res){
      if(res.result==='success'){ alert('저장 완료되었습니다.'); userTable.replaceData(); hideModal('modalContainer'); }
      else { alert('저장 실패: '+res.message); }
    },
    error: function(){ alert('서버 통신 오류 발생'); }
  });
});

/* ─── 삭제 ─── */
document.querySelector('.delete-button').addEventListener('click', function(){
  var selectedRows = userTable.getSelectedData();
  if(!selectedRows.length){ alert('삭제할 항목을 선택하세요.'); return; }
  if(!confirm('정말 삭제하시겠습니까?')) return;
  var idxList = selectedRows.map(function(r){ return r.idx; });
  $.ajax({
    url:'/line/productionManagement/noProduct/deleteNoProduct',
    type:'POST', contentType:'application/json',
    data: JSON.stringify({idx:idxList}),
    success: function(res){
      if(res.result==='success'){ alert('삭제 완료되었습니다.'); userTable.replaceData(); }
      else { alert('삭제 실패: '+res.message); }
    },
    error: function(){ alert('서버 통신 오류 발생'); }
  });
});

/* ─── 엑셀 ─── */
$('.excel-button').on('click', function(){
  if(!userTable) return;
  userTable.download('xlsx','부적합품_현황.xlsx',{
    sheetName:'NoProduct',
    documentProcessing: function(wb){
      var sheet = wb.Sheets['NoProduct'];
      sheet['!cols'] = [
        {wch:14},{wch:18},{wch:20},{wch:28},{wch:18},{wch:14},{wch:14},
        {wch:35},{wch:35},{wch:12},{wch:12},{wch:14},{wch:30}
      ];
      return wb;
    }
  });
});

/* ─── 이벤트 바인딩 ─── */
$(function(){
  document.querySelector('.dayselect').value = todayMonth();
  getnoProductList();
  initPumbunTabu();

  // 추가 버튼
  document.querySelector('.insert-button').addEventListener('click', function(){
    document.getElementById('corrForm').reset();
    $("input[name='idx']").val('');
    $("input[name='d_date']").val(todayDate());
    showModal('modalContainer');
  });

  // 모달 닫기
  document.getElementById('mainClose').addEventListener('click', function(){ hideModal('modalContainer'); });
  document.getElementById('closeModal').addEventListener('click', function(){ hideModal('modalContainer'); });
  document.getElementById('modalContainer').addEventListener('click', function(e){ if(e.target===this) hideModal('modalContainer'); });

  // 품번 모달
  document.getElementById('btnPumbunOpen').addEventListener('click', function(){
    showModal('pumbunModal');
    if(pumbunTabu) pumbunTabu.replaceData();
  });
  document.getElementById('pumbunClose').addEventListener('click', function(){ hideModal('pumbunModal'); });
  document.getElementById('pumbunModal').addEventListener('click', function(e){ if(e.target===this) hideModal('pumbunModal'); });
});
</script>

</body>
</html>
