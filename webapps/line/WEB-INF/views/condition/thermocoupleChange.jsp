<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="ko">
<head>
<script src="/line/mock/mock-loader.js"></script>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>열전대교체이력</title>
    <%@include file="../include/pluginpage.jsp" %>
    <jsp:include page="../include/tabBar.jsp"/>
<style>
:root {
  --bg:#f3f5f8; --surface:#ffffff; --surface2:#f8fafc; --border:#e3e8ef; --line2:#eef1f5;
  --text-p:#0f172a; --text-2:#334155; --text-s:#64748b; --text-m:#94a3b8;
  --accent:#2563eb; --red:#dc2626; --amber:#d97706; --teal:#0d9488;
}
*{ box-sizing:border-box; margin:0; padding:0; }
body { font-family:"Pretendard","Malgun Gothic","맑은 고딕",sans-serif; background:var(--bg); color:var(--text-p); font-size:13px; min-height:100vh; }
.num { font-variant-numeric:tabular-nums; }

/* ===== 상단 바 ===== */
.topbar { background:var(--surface); border-bottom:1px solid var(--border); }
.topbar-inner { padding:0 20px; height:52px; display:flex; align-items:center; gap:10px; }
.tb-title { font-size:16px; font-weight:700; letter-spacing:-.3px; margin-right:12px; white-space:nowrap; color:var(--text-p); }
.tb-label { font-size:12.5px; color:var(--text-s); white-space:nowrap; }
.ctrl, .ctrl-select, .ctrl-input { height:32px; padding:0 10px; border:1px solid var(--border); border-radius:6px; background:#fff;
  color:var(--text-p); font-size:13px; font-family:inherit; outline:none; }
.ctrl-select { min-width:110px; cursor:pointer; }
.ctrl:focus, .ctrl-select:focus, .ctrl-input:focus { border-color:var(--accent); }
.tb-sp { flex:1; }
.btn { height:32px; padding:0 14px; border-radius:6px; font-size:13px; font-family:inherit; font-weight:600;
  cursor:pointer; white-space:nowrap; border:1px solid var(--border); background:#fff; color:var(--text-2);
  display:inline-flex; align-items:center; gap:5px; }
.btn:hover { border-color:#cbd5e1; background:var(--surface2); }
.btn-search { background:var(--text-p); border-color:var(--text-p); color:#fff; }
.btn-search:hover { background:#1e293b; border-color:#1e293b; }
.btn-delete { color:var(--red); }

/* ===== 페이지 ===== */
.page { padding:14px 20px 18px; display:flex; flex-direction:column; gap:12px; }
/* 큰 화면 대응: 페이지를 창 높이에 맞추고 목록 카드가 남은 높이를 채움 (페이지 스크롤 없음) */
html, body { height:100%; overflow:hidden; }
body { display:flex; flex-direction:column; min-height:0; }
body > .page { flex:1; min-height:0; }
.page > .main-card, .page > .table-card { flex:1; min-height:0; display:flex; flex-direction:column; }
.page > .main-card > .flat-tab, .page > .table-card > .flat-tab { flex:1; min-height:0; }
.page > .main-card > .table-wrap { flex:1; min-height:0; max-height:none; }
.card { background:var(--surface); border:1px solid var(--border); border-radius:10px; }
.card-head { padding:12px 16px; display:flex; align-items:center; justify-content:space-between; gap:12px; border-bottom:1px solid var(--line2); }
.card-head-title { font-size:14px; font-weight:700; color:var(--text-2); }
.card-head small, .card-head .hint { font-size:12px; color:var(--text-m); }
.card-foot { padding:8px 16px; border-top:1px solid var(--line2); display:flex; justify-content:space-between; font-size:12px; color:var(--text-m); }
.card-foot strong { color:var(--text-2); font-variant-numeric:tabular-nums; }
.main-card { background:var(--surface); border:1px solid var(--border); border-radius:10px; overflow:hidden; display:flex; flex-direction:column; min-width:0; }

/* 요약 지표 */
.summary { display:grid; grid-template-columns:repeat(4, minmax(0,1fr)); }
.summary > div { padding:14px 18px; border-left:1px solid var(--line2); min-width:0; }
.summary > div:first-child { border-left:0; }
.s-lb { font-size:12.5px; color:var(--text-s); }
.s-v { margin-top:4px; font-size:22px; font-weight:700; letter-spacing:-.4px; color:var(--text-p); font-variant-numeric:tabular-nums; white-space:nowrap; overflow:hidden; text-overflow:ellipsis; }
.s-v u { text-decoration:none; font-size:13px; font-weight:500; color:var(--text-s); margin-left:2px; }
.s-sub { margin-top:2px; font-size:12px; color:var(--text-m); white-space:nowrap; overflow:hidden; text-overflow:ellipsis; }

/* ===== Tabulator ===== */
.flat-tab.tabulator { border:0; background:#fff; font-family:inherit; font-size:13px; }
.flat-tab .tabulator-header { background:#fff; border-bottom:1px solid var(--border); }
.flat-tab .tabulator-header .tabulator-col { background:#fff; border-right:0; color:var(--text-s); font-size:12px; font-weight:600; }
.flat-tab .tabulator-col .tabulator-col-content { padding:9px 10px; }
.flat-tab .tabulator-tableholder { background:#fff; }
.flat-tab .tabulator-row { background:#fff; border-bottom:1px solid var(--line2); min-height:40px; cursor:pointer; }
.flat-tab .tabulator-row.tabulator-row-even { background:#fff; }
.flat-tab .tabulator-row:hover { background:#f8fafc; }
.flat-tab .tabulator-row.row_select, .flat-tab .tabulator-row.tabulator-selected { background:#eef4ff !important; }
.flat-tab .tabulator-cell { border-right:0; padding:11px 10px; color:var(--text-2); }
.flat-tab .tabulator-placeholder span { color:var(--text-m); font-size:13px; font-weight:400; }
.flat-tab .tabulator-footer { background:#fff; border-top:1px solid var(--line2); }
.date-cell { color:var(--text-s); font-variant-numeric:tabular-nums; }
.st-ok { color:var(--teal); } .st-warn { color:var(--amber); } .st-over { color:var(--red); font-weight:600; }
.file-link { color:var(--accent); text-decoration:none; cursor:pointer; display:inline-block; max-width:100%; overflow:hidden; text-overflow:ellipsis; white-space:nowrap; vertical-align:middle; }
.file-link:hover { text-decoration:underline; }
.muted { color:var(--text-m); }

/* ===== 모달 ===== */
.modal-overlay { display:none; position:fixed; inset:0; background:rgba(15,23,42,.4); z-index:500; align-items:center; justify-content:center; }
.modal-overlay.show { display:flex; }
.modal-box { background:#fff; border-radius:10px; width:460px; max-width:95vw; max-height:90vh; overflow-y:auto; box-shadow:0 16px 48px rgba(15,23,42,.18); padding:20px 22px; position:relative; }
.modal-head { display:flex; align-items:center; justify-content:space-between; margin:-20px -22px 16px; padding:16px 22px; border-bottom:1px solid var(--border); }
.modal-head h2 { font-size:16px; font-weight:700; color:var(--text-p); }
.modal-close { cursor:pointer; color:var(--text-s); font-size:16px; padding:4px 6px; background:none; border:0; }
.modal-close:hover { color:var(--text-p); }
.form-group { margin-bottom:12px; }
.form-label { font-size:12px; color:var(--text-s); margin-bottom:5px; display:block; }
.form-input, .form-textarea, .form-select { width:100%; border:1px solid var(--border); border-radius:6px; background:#fff; color:var(--text-p); font-size:13px; font-family:inherit; outline:none; }
.form-input, .form-select { height:34px; padding:0 10px; }
.form-textarea { padding:8px 10px; resize:vertical; min-height:80px; }
.form-input:focus, .form-textarea:focus, .form-select:focus { border-color:var(--accent); }
.form-input[readonly] { color:var(--text-m); background:var(--surface2); cursor:default; }
.modal-btn-row { display:flex; gap:8px; justify-content:flex-end; margin:18px -22px -20px; padding:12px 22px; border-top:1px solid var(--border); }
.modal-btn { height:34px; padding:0 18px; border-radius:6px; font-size:13px; font-weight:600; font-family:inherit; cursor:pointer; border:1px solid var(--border); background:#fff; color:var(--text-2); }
.modal-btn-save { background:var(--text-p); border-color:var(--text-p); color:#fff; }
.modal-btn-cancel { background:#fff; color:var(--text-2); }

/* 엑셀 로딩 */
#excelOverlay { display:none; position:fixed; inset:0; background:rgba(15,23,42,.4); z-index:9998; }
#excelLoading { display:none; position:fixed; top:50%; left:50%; transform:translate(-50%,-50%); background:#fff; padding:22px 40px; border-radius:10px; border:1px solid var(--border); z-index:9999; font-size:14px; font-weight:600; text-align:center; }
</style>
</head>
<body>

<div class="topbar">
  <div class="topbar-inner">
    <div class="tb-title">열전대 교체이력</div>
    <span class="tb-label">연도</span>
    <select id="sdate" class="ctrl-select">
      <option value="2024">2024</option>
      <option value="2025">2025</option>
      <option value="2026">2026</option>
      <option value="2027">2027</option>
    </select>
    <button class="btn btn-search select-button" onclick="getThermocoupleList();">조회</button>
    <div class="tb-sp"></div>
    <button class="btn btn-excel excel-button">엑셀 다운로드</button>
    <input type="file" id="fileInput" style="display:none;">
  </div>
</div>

<div class="page">

  <div class="card summary">
    <div><div class="s-lb">전체 열전대</div><div class="s-v" id="kpi-total">0</div><div class="s-sub">조회된 총 건수</div></div>
    <div><div class="s-lb">교체 임박</div><div class="s-v" id="kpi-soon">0</div><div class="s-sub">30일 이내 또는 경과</div></div>
    <div><div class="s-lb">교체 완료</div><div class="s-v" id="kpi-done">0</div><div class="s-sub">교체일자 입력 건수</div></div>
    <div><div class="s-lb">조회 연도</div><div class="s-v" id="kpi-year">-</div><div class="s-sub">기준 연도</div></div>
  </div>

  <div class="main-card">
    <div class="card-head">
      <span class="card-head-title">열전대 교체 이력 목록</span>
      <small>더블클릭 시 수정</small>
    </div>
    <div id="tab1" class="flat-tab"></div>
    <div class="card-foot">
      <span id="footer-info">데이터를 조회하세요</span>
      <span>마지막 조회 <strong id="footer-time">-</strong></span>
    </div>
  </div>

</div>

<div id="modalContainer" class="modal-overlay">
  <div class="modal-box">
    <div class="modal-head">
      <h2>교체 이력 수정</h2>
      <span class="modal-close close">✕</span>
    </div>
    <form id="corrForm" autocomplete="off">
      <input type="hidden" name="cnt" id="cnt"/>
      <div class="form-group">
        <label class="form-label">설비명</label>
        <input type="text" name="seolbi" class="form-input" value="연속열처리로" readonly/>
      </div>
      <div class="form-group">
        <label class="form-label">존 구분</label>
        <input type="text" name="zone" class="form-input" readonly/>
      </div>
      <div class="form-group">
        <label class="form-label">교체일자</label>
        <input type="date" name="change_date" class="form-input"/>
      </div>
      <div class="form-group">
        <label class="form-label">차기교체일자</label>
        <input type="date" name="change_ndate" class="form-input"/>
      </div>
      <div class="form-group">
        <label class="form-label">비고</label>
        <textarea name="bigo" class="form-textarea" rows="4"></textarea>
      </div>
      <div class="modal-btn-row">
        <button type="button" id="closeModal" class="modal-btn modal-btn-cancel">닫기</button>
        <button type="submit" id="saveCorrStatus" class="modal-btn modal-btn-save">저장</button>
      </div>
    </form>
  </div>
</div>

<div id="excelOverlay"></div>
<div id="excelLoading">엑셀 생성 중...</div>

<script>
let now_page_code = "d01";
var userTable;
var selectedRowData = null;

/* ─── 날짜 유틸 ─── */
function pad2(n){ return String(n).padStart(2,'0'); }
function todayDate(){
  var d=new Date();
  return d.getFullYear()+'-'+pad2(d.getMonth()+1)+'-'+pad2(d.getDate());
}
function oneYearAfterDate(){
  var d=new Date(); d.setFullYear(d.getFullYear()+1);
  return d.getFullYear()+'-'+pad2(d.getMonth()+1)+'-'+pad2(d.getDate());
}
function oneYearBeforeDate(){
  var d=new Date(); d.setFullYear(d.getFullYear()-1);
  return d.getFullYear()+'-'+pad2(d.getMonth()+1)+'-'+pad2(d.getDate());
}
function paddingZero(n){ return String(n).padStart(2,'0'); }

/* ─── 차기교체일 상태 판단 ─── */
function getDateStatus(ndate){
  if(!ndate) return 'none';
  var today = new Date(); today.setHours(0,0,0,0);
  var nd    = new Date(ndate); nd.setHours(0,0,0,0);
  var diff  = Math.floor((nd - today) / (1000*60*60*24));
  if(diff < 0)  return 'over';
  if(diff <= 30) return 'warn';
  return 'ok';
}

/* ─── KPI 업데이트 ─── */
function updateKpi(data){
  var total = data.length;
  var done  = data.filter(function(r){ return r.change_date; }).length;
  var soon  = data.filter(function(r){
    var s = getDateStatus(r.change_ndate);
    return s==='over' || s==='warn';
  }).length;

  document.getElementById('kpi-total').textContent = total.toLocaleString();
  document.getElementById('kpi-done').textContent  = done.toLocaleString();
  document.getElementById('kpi-soon').textContent  = soon.toLocaleString();
  document.getElementById('kpi-year').textContent  = document.getElementById('sdate').value || '-';

  document.getElementById('footer-info').innerHTML = '총 <strong>'+total+'</strong>건';
  var now = new Date();
  document.getElementById('footer-time').textContent =
    pad2(now.getHours())+':'+pad2(now.getMinutes())+':'+pad2(now.getSeconds());
}

/* ─── 테이블 조회 ─── */
function getThermocoupleList(){
  userTable = new Tabulator("#tab1", {
    height: "100%",
    layout: "fitColumns",
    selectable: true,
    reactiveData: true,
    headerHozAlign: "center",
    ajaxConfig: "POST",
    ajaxLoader: false,
    ajaxURL: "/line/condition/thermocoupleChange/getThermocoupleList",
    ajaxParams: { year: document.getElementById('sdate').value },
    ajaxResponse: function(url, params, response){
      var data = response.data || [];
      updateKpi(data);
      return data;
    },
    placeholder: "조회된 데이터가 없습니다.",
    columns: [
      { title:"No.", formatter:"rownum", width:70, hozAlign:"center", headerSort:false },
      { title:"No.", field:"cnt", visible:false },
      { title:"설비명",  field:"hogi",        width:160, hozAlign:"center" },
      { title:"존 구분", field:"zone",         width:160, hozAlign:"center",
        formatter:function(c){ return c.getValue() || '-'; }
      },
      { title:"이전교체일자", field:"change_bdate", width:170, hozAlign:"center",
        formatter:function(c){ return c.getValue()?'<span class="date-cell">'+c.getValue()+'</span>':'-'; }
      },
      { title:"교체일자",    field:"change_date",  width:150, hozAlign:"center",
        formatter:function(c){ return c.getValue()?'<span class="date-cell">'+c.getValue()+'</span>':'-'; }
      },
      { title:"차기교체일자", field:"change_ndate", width:200, hozAlign:"center",
        formatter:function(c){
          var v = c.getValue();
          if(!v) return '-';
          var s = getDateStatus(v);
          if(s==='over') return '<span class="date-cell st-over">'+v+' · 경과</span>';
          if(s==='warn') return '<span class="date-cell st-warn">'+v+' · 임박</span>';
          return '<span class="date-cell">'+v+'</span>';
        }
      },
      { title:"비고", field:"bigo", hozAlign:"left" }
    ],
    rowClick: function(e, row){
      document.querySelectorAll('#tab1 .tabulator-row').forEach(function(el){ el.classList.remove('row_select'); });
      row.getElement().classList.add('row_select');
    },
    rowDblClick: function(e, row){
      var data = row.getData();
      selectedRowData = data;
      document.getElementById('corrForm').reset();
      document.getElementById('cnt').value = data.cnt || '';
      document.querySelector('input[name="seolbi"]').value = data.hogi || '연속열처리로';
      document.querySelector('input[name="zone"]').value   = data.zone || '';
      document.querySelector('input[name="change_date"]').value  = data.change_date  || todayDate();
      document.querySelector('input[name="change_ndate"]').value = data.change_ndate || oneYearAfterDate();
      document.querySelector('textarea[name="bigo"]').value      = data.bigo || '';
      showModal();
    }
  });
}

/* ─── 교체일 변경 시 차기교체일 자동 계산 ─── */
document.addEventListener('DOMContentLoaded', function(){
  document.querySelector('input[name="change_date"]').addEventListener('change', function(){
    var d = new Date(this.value);
    d.setFullYear(d.getFullYear()+1);
    document.querySelector('input[name="change_ndate"]').value =
      d.getFullYear()+'-'+pad2(d.getMonth()+1)+'-'+pad2(d.getDate());
  });
});

/* ─── 저장 ─── */
function save(){
  var formData = new FormData(document.getElementById('corrForm'));
  $.ajax({
    url:'/line/condition/thermocoupleChange/thermocoupleSave',
    type:'POST', data:formData, contentType:false, processData:false, dataType:'json',
    success:function(res){
      if(res.status==='success'){ alert('수정되었습니다.'); hideModal(); getThermocoupleList(); }
      else { alert('수정 실패: '+res.message); }
    },
    error:function(){ alert('수정 중 오류가 발생했습니다.'); }
  });
}

/* ─── 모달 show/hide ─── */
function showModal(){
  var ov = document.getElementById('modalContainer');
  ov.style.display='flex';
  setTimeout(function(){ ov.classList.add('show'); },10);
}
function hideModal(){
  var ov = document.getElementById('modalContainer');
  ov.classList.remove('show');
  setTimeout(function(){ ov.style.display='none'; },220);
}

/* ─── 이벤트 ─── */
document.querySelector('.close').addEventListener('click', hideModal);
document.getElementById('closeModal').addEventListener('click', hideModal);
document.getElementById('modalContainer').addEventListener('click', function(e){ if(e.target===this) hideModal(); });

document.getElementById('saveCorrStatus').addEventListener('click', function(e){
  e.preventDefault(); save();
});

/* ─── 엑셀 다운로드 ─── */
document.querySelector('.excel-button').addEventListener('click', function(){ downloadExcel(); });

function downloadExcel(){
  if(!userTable) return;
  var tableData = userTable.getData();
  if(!tableData||tableData.length===0){ alert('다운로드할 데이터가 없습니다.'); return; }

  document.getElementById('excelOverlay').style.display='block';
  document.getElementById('excelLoading').style.display='block';

  try {
    var excelData = tableData.map(function(row,i){
      return {
        "NO": i+1,
        "설비명": row.hogi||"",
        "존구분": row.zone||"",
        "이전교체일자": row.change_bdate||"",
        "교체일자": row.change_date||"",
        "차기교체일자": row.change_ndate||"",
        "비고": row.bigo||""
      };
    });
    var ws = XLSX.utils.json_to_sheet(excelData);
    ws['!cols'] = [{wch:5},{wch:20},{wch:20},{wch:18},{wch:18},{wch:18},{wch:40}];
    var wb = XLSX.utils.book_new();
    XLSX.utils.book_append_sheet(wb, ws, "열전대교체이력");
    var yr  = document.getElementById('sdate').value || new Date().getFullYear();
    var now = new Date();
    var ts  = pad2(now.getHours())+pad2(now.getMinutes());
    XLSX.writeFile(wb, '열전대교체이력_'+yr+'_'+ts+'.xlsx');
    setTimeout(function(){
      document.getElementById('excelOverlay').style.display='none';
      document.getElementById('excelLoading').style.display='none';
    }, 500);
  } catch(e){
    console.error(e); alert('엑셀 다운로드에 실패했습니다.');
    document.getElementById('excelOverlay').style.display='none';
    document.getElementById('excelLoading').style.display='none';
  }
}

/* ─── 초기 로드 ─── */
$(function(){
  $(".headerP").text("조건관리 - 열전대교체이력");
  // 현재 연도 선택
  var yr = String(new Date().getFullYear());
  var opt = document.querySelector('#sdate option[value="'+yr+'"]');
  if(opt) opt.selected = true;
  getThermocoupleList();
});
</script>

</body>
</html>
