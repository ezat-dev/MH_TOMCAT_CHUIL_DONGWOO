<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<script src="/line/mock/mock-loader.js"></script>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>수리이력관리</title>
<%@include file="../include/pluginpage.jsp"%>
<jsp:include page="../include/tabBar.jsp" />
<link href="/vendor/tabulator/5.5.0/tabulator.min.css" rel="stylesheet">
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
.tb-title { font-size:16px; font-weight:700; letter-spacing:-.3px; margin-right:12px; white-space:nowrap; }
.tb-label { font-size:12.5px; color:var(--text-s); white-space:nowrap; }
.ctrl, .ctrl-select { height:32px; padding:0 10px; border:1px solid var(--border); border-radius:6px; background:#fff;
  color:var(--text-p); font-size:13px; font-family:inherit; outline:none; }
.ctrl { width:80px; text-align:center; }
.ctrl-select { min-width:120px; cursor:pointer; }
.ctrl:focus, .ctrl-select:focus { border-color:var(--accent); }
.tb-sp { flex:1; }
.btn { height:32px; padding:0 14px; border-radius:6px; font-size:13px; font-family:inherit; font-weight:600;
  cursor:pointer; white-space:nowrap; border:1px solid var(--border); background:#fff; color:var(--text-2); }
.btn:hover { border-color:#cbd5e1; background:var(--surface2); }
.btn-search { background:var(--text-p); border-color:var(--text-p); color:#fff; }
.btn-search:hover { background:#1e293b; border-color:#1e293b; }
.btn-delete { color:var(--red); }
.tb-gap { width:6px; }

/* ===== 페이지 ===== */
.page { padding:14px 20px 18px; display:flex; flex-direction:column; gap:12px; }
.card { background:var(--surface); border:1px solid var(--border); border-radius:10px; }
.card-head { padding:12px 16px; display:flex; align-items:center; justify-content:space-between; border-bottom:1px solid var(--line2); }
.card-head-title { font-size:14px; font-weight:700; color:var(--text-2); }
.card-head small { font-size:12px; color:var(--text-m); }

/* 요약 지표 (한 줄) */
.summary { display:grid; grid-template-columns:repeat(5, minmax(0,1fr)); }
.summary > div { padding:14px 18px; border-left:1px solid var(--line2); min-width:0; }
.summary > div:first-child { border-left:0; }
.s-lb { font-size:12.5px; color:var(--text-s); }
.s-v { margin-top:4px; font-size:22px; font-weight:700; letter-spacing:-.4px; white-space:nowrap; overflow:hidden; text-overflow:ellipsis; }
.s-v u { text-decoration:none; font-size:13px; font-weight:500; color:var(--text-s); margin-left:2px; }
.s-v.txt { font-size:15px; font-weight:600; line-height:26px; }
.s-sub { margin-top:2px; font-size:12px; color:var(--text-m); white-space:nowrap; overflow:hidden; text-overflow:ellipsis; }

/* 본문 2열 */
.content-row { display:grid; grid-template-columns:300px minmax(0,1fr); gap:12px; align-items:stretch; }

/* 설비별 수리비용 */
.eq-list { padding:6px 16px 12px; }
.eq-it { padding:10px 0; border-bottom:1px solid var(--line2); }
.eq-it:last-child { border-bottom:0; }
.eq-top { display:flex; justify-content:space-between; align-items:baseline; gap:8px; margin-bottom:6px; }
.eq-nm { font-weight:600; color:var(--text-2); white-space:nowrap; overflow:hidden; text-overflow:ellipsis; }
.eq-nm small { font-weight:400; color:var(--text-m); margin-left:6px; font-size:12px; }
.eq-cost { font-weight:600; white-space:nowrap; }
.eq-tr { height:6px; background:var(--line2); border-radius:3px; overflow:hidden; }
.eq-tr i { display:block; height:100%; background:#94a3b8; border-radius:3px; }
.eq-it:first-child .eq-tr i { background:var(--text-2); }
.type-split { display:flex; gap:14px; padding:12px 16px 0; font-size:12.5px; color:var(--text-s); }
.type-split b { color:var(--text-p); font-weight:700; margin-left:4px; }
.dot { display:inline-block; width:7px; height:7px; border-radius:50%; margin-right:5px; vertical-align:1px; }
.d-plan { background:var(--accent); } .d-reg { background:var(--teal); } .d-sud { background:var(--red); } .d-etc { background:var(--text-m); }
.recent-empty { padding:30px; text-align:center; color:var(--text-m); }

/* 테이블 */
.main-card { display:flex; flex-direction:column; min-width:0; overflow:hidden; }
.card-foot { padding:8px 16px; border-top:1px solid var(--line2); display:flex; justify-content:space-between; font-size:12px; color:var(--text-m); }
.card-foot strong { color:var(--text-2); }
#dataTable.tabulator { border:0; background:#fff; font-family:inherit; font-size:13px; }
#dataTable .tabulator-header { background:#fff; border-bottom:1px solid var(--border); }
#dataTable .tabulator-header .tabulator-col { background:#fff; border-right:0; color:var(--text-s); font-size:12px; font-weight:600; }
#dataTable .tabulator-col .tabulator-col-content { padding:9px 10px; }
#dataTable .tabulator-tableholder { background:#fff; }
#dataTable .tabulator-row { background:#fff; border-bottom:1px solid var(--line2); min-height:40px; cursor:pointer; }
#dataTable .tabulator-row.tabulator-row-even { background:#fff; }
#dataTable .tabulator-row:hover { background:#f8fafc; }
#dataTable .tabulator-row.row_select { background:#eef4ff !important; }
#dataTable .tabulator-cell { border-right:0; padding:11px 10px; color:var(--text-2); }
#dataTable .tabulator-placeholder span { color:var(--text-m); font-size:13px; font-weight:400; }
.cost-cell { font-weight:600; color:var(--text-p); }
.date-cell { color:var(--text-s); }
.type-cell { font-size:12.5px; color:var(--text-2); white-space:nowrap; }
.photo-link { color:var(--accent); text-decoration:none; }
.photo-link:hover { text-decoration:underline; }

/* ===== 모달 ===== */
.modal-overlay { display:none; position:fixed; inset:0; background:rgba(15,23,42,.4); z-index:500;
  align-items:flex-start; justify-content:center; padding-top:24px; overflow-y:auto; }
.modal-overlay.show { display:flex; }
.modal-box { background:#fff; border-radius:10px; width:700px; max-width:96vw; box-shadow:0 16px 48px rgba(15,23,42,.18); margin-bottom:30px; }
.modal-head { padding:16px 22px; border-bottom:1px solid var(--border); display:flex; align-items:center; justify-content:space-between;
  position:sticky; top:0; background:#fff; border-radius:10px 10px 0 0; z-index:2; }
.modal-head h2 { font-size:16px; font-weight:700; }
.modal-close { cursor:pointer; color:var(--text-s); font-size:16px; padding:4px 6px; }
.modal-close:hover { color:var(--text-p); }
.modal-body { padding:16px 22px; }
.form-grid { display:grid; grid-template-columns:1fr 1fr; gap:12px; }
.form-grid.single { grid-template-columns:1fr; }
.form-group { display:flex; flex-direction:column; gap:5px; }
.form-label { font-size:12px; color:var(--text-s); }
.form-input, .form-textarea { width:100%; border:1px solid var(--border); border-radius:6px; background:#fff; color:var(--text-p);
  font-size:13px; font-family:inherit; outline:none; }
.form-input { height:34px; padding:0 10px; }
.form-textarea { padding:8px 10px; resize:vertical; min-height:80px; }
.form-input:focus, .form-textarea:focus { border-color:var(--accent); }
.form-input[readonly] { color:var(--text-m); background:var(--surface2); }
.section-label { font-size:13px; font-weight:700; color:var(--text-2); padding:10px 0 8px; margin-bottom:10px; border-bottom:1px solid var(--line2); }
.file-group { border:1px solid var(--border); border-radius:6px; padding:10px 12px; }
.file-group-label { font-size:12px; color:var(--text-s); margin-bottom:6px; }
.file-group-label span { display:none; }
.file-input { width:100%; font-size:12px; }
.file-name-input { margin-top:6px; }
.modal-foot { padding:12px 22px; border-top:1px solid var(--border); display:flex; gap:8px; justify-content:flex-end;
  position:sticky; bottom:0; background:#fff; border-radius:0 0 10px 10px; }
.modal-btn { height:34px; padding:0 18px; border-radius:6px; font-size:13px; font-weight:600; font-family:inherit; cursor:pointer; border:1px solid var(--border); }
.modal-btn-save { background:var(--text-p); border-color:var(--text-p); color:#fff; }
.modal-btn-cancel { background:#fff; color:var(--text-2); }
</style>
</head>
<body>

<div class="topbar">
  <div class="topbar-inner">
    <div class="tb-title">수리이력관리</div>
    <span class="tb-label">수리 연도</span>
    <input type="text" class="ctrl yearSet num" id="startDate" placeholder="연도" autocomplete="off"/>
    <span class="tb-label" style="margin-left:6px">수리 항목</span>
    <select id="endDate" class="ctrl-select">
      <option value="">전체</option>
      <option value="계획수리">계획수리</option>
      <option value="정기수리">정기수리</option>
      <option value="돌발고장">돌발고장</option>
      <option value="">기타</option>
    </select>
    <button class="btn btn-search select-button">조회</button>
    <div class="tb-sp"></div>
    <button class="btn insert-button">추가</button>
    <button class="btn btn-delete delete-button">삭제</button>
    <button class="btn excel-button">PDF 출력</button>
  </div>
</div>

<div class="page">

  <!-- 요약 지표 -->
  <div class="card summary">
    <div><div class="s-lb">수리 건수</div><div class="s-v num" id="kpi-total">0</div><div class="s-sub" id="kpi-total-sub">-</div></div>
    <div><div class="s-lb">총 수리비용</div><div class="s-v num" id="kpi-cost">0</div><div class="s-sub" id="kpi-cost-sub">-</div></div>
    <div><div class="s-lb">최다 수리유형</div><div class="s-v txt" id="kpi-type">-</div><div class="s-sub" id="kpi-type-sub">-</div></div>
    <div><div class="s-lb">수리 설비</div><div class="s-v num" id="kpi-equip">0</div><div class="s-sub">수리 이력이 있는 설비</div></div>
    <div><div class="s-lb">최근 수리</div><div class="s-v txt" id="kpi-recent">-</div><div class="s-sub num" id="kpi-recent-sub">-</div></div>
  </div>

  <div class="content-row">
    <div class="card">
      <div class="card-head"><span class="card-head-title">설비별 수리비용</span><small id="recent-subtitle"></small></div>
      <div class="type-split" id="typeSplit"></div>
      <div class="eq-list" id="recentList"><div class="recent-empty">조회된 데이터가 없습니다.</div></div>
    </div>

    <div class="card main-card">
      <div class="card-head"><span class="card-head-title">수리 이력 목록</span><small id="card-year-label">-</small></div>
      <div id="dataTable"></div>
      <div class="card-foot">
        <span id="footer-info">-</span>
        <span>행 더블클릭: 상세/수정 &nbsp;·&nbsp; 마지막 조회 <strong id="footer-time">-</strong></span>
      </div>
    </div>
  </div>
</div>

<!-- ===== 등록/수정 모달 ===== -->
<div id="modalContainer" class="modal-overlay">
  <div class="modal-box">
    <div class="modal-head">
      <h2>설비 수리내역 등록</h2>
      <span class="modal-close close">✕</span>
    </div>

    <form id="corrForm" enctype="multipart/form-data">
      <input type="hidden" name="idx"/>
      <div class="modal-body">

        <div class="section-label">설비 정보</div>
        <div class="form-grid" style="margin-bottom:14px;">
          <div class="form-group">
            <label class="form-label">설비공정</label>
            <input type="text" name="box_1" class="form-input" placeholder="설비공정 입력"/>
          </div>
          <div class="form-group">
            <label class="form-label">설비명</label>
            <input type="text" name="box_2" class="form-input" placeholder="설비명 입력"/>
          </div>
        </div>

        <div class="section-label">수리 의뢰</div>
        <div class="form-grid" style="margin-bottom:14px;">
          <div class="form-group">
            <label class="form-label">수리 담당업체</label>
            <input type="text" name="box_3" class="form-input" placeholder="담당업체 입력"/>
          </div>
          <div class="form-group">
            <label class="form-label">의뢰일</label>
            <input type="date" name="box_4" class="form-input"/>
          </div>
          <div class="form-group">
            <label class="form-label">의뢰자</label>
            <input type="text" name="box_5" class="form-input" placeholder="의뢰자 입력"/>
          </div>
        </div>

        <div class="section-label">수리 일정</div>
        <div class="form-grid" style="margin-bottom:14px;">
          <div class="form-group">
            <label class="form-label">수리 시작일</label>
            <input type="date" name="box_6" class="form-input"/>
          </div>
          <div class="form-group">
            <label class="form-label">수리 시작시간</label>
            <input type="time" name="box_7" class="form-input"/>
          </div>
          <div class="form-group">
            <label class="form-label">수리 완료일</label>
            <input type="date" name="box_8" class="form-input"/>
          </div>
          <div class="form-group">
            <label class="form-label">수리 완료시간</label>
            <input type="time" name="box_9" class="form-input"/>
          </div>
          <div class="form-group">
            <label class="form-label">회계처리일</label>
            <input type="date" name="box_10" class="form-input yearSet"/>
          </div>
        </div>

        <div class="section-label">수리 내용</div>
        <div class="form-grid" style="margin-bottom:14px;">
          <div class="form-group">
            <label class="form-label">수리제목</label>
            <input type="text" name="box_11" class="form-input"/>
          </div>
          <div class="form-group">
            <label class="form-label">수리부위</label>
            <input type="text" name="box_12" class="form-input"/>
          </div>
          <div class="form-group">
            <label class="form-label">수리비용 (원)</label>
            <input type="number" name="box_13" class="form-input" value="0"/>
          </div>
          <div class="form-group">
            <label class="form-label">수리 담당자</label>
            <input type="text" name="box_14" class="form-input"/>
          </div>
          <div class="form-group">
            <label class="form-label">연락처</label>
            <input type="text" name="box_15" class="form-input"/>
          </div>
        </div>
        <div class="form-grid single" style="margin-bottom:14px;">
          <div class="form-group">
            <label class="form-label">수리 상세내역</label>
            <textarea name="box_16" class="form-textarea" rows="4"></textarea>
          </div>
          <div class="form-group">
            <label class="form-label">메모</label>
            <textarea name="box_17" class="form-textarea" rows="3"></textarea>
          </div>
        </div>

        <div class="section-label">사진 첨부</div>
        <div class="form-grid" style="margin-bottom:6px;">
          <div class="file-group">
            <div class="file-group-label"><span class="lbl-before">전</span> 수리 전 사진</div>
            <input type="file" name="upload_file_1" class="file-input"/>
            <input type="text" name="file_name_1" class="form-input file-name-input" readonly placeholder="파일명 자동 입력"/>
          </div>
          <div class="file-group">
            <div class="file-group-label"><span class="lbl-after">후</span> 수리 후 사진</div>
            <input type="file" name="upload_file_2" class="file-input"/>
            <input type="text" name="file_name_2" class="form-input file-name-input" readonly placeholder="파일명 자동 입력"/>
          </div>
        </div>

      </div><!-- /modal-body -->

      <div class="modal-foot">
        <button type="button" id="closeModal" class="modal-btn modal-btn-cancel">닫기</button>
        <button type="submit" class="modal-btn modal-btn-save">저장</button>
      </div>
    </form>
  </div>
</div>

<script>
let now_page_code = "c04";
var dataTable;
var selectedRowData = null;
var allData = [];

/* ─── 날짜 유틸 ─── */
function pad2(n){ return String(n).padStart(2,'0'); }

/* ─── 수리유형 (제목의 [정기수리] 등에서 추출) ─── */
function typeOf(r){
  var t = (r && r.box_11) || '';
  if(t.includes('계획')) return '계획수리';
  if(t.includes('정기')) return '정기수리';
  if(t.includes('돌발') || t.includes('고장')) return '돌발고장';
  return '기타';
}
var TYPE_DOT = { '계획수리':'d-plan', '정기수리':'d-reg', '돌발고장':'d-sud', '기타':'d-etc' };
function won(v){ return Number(v||0).toLocaleString(); }

/* ─── 요약 지표 ─── */
function updateKpi(data){
  var total   = data.length;
  var costSum = data.reduce(function(a,r){ return a+(Number(r.box_13)||0); }, 0);
  var recent  = total ? data[0] : null;

  var typeMap = {};
  data.forEach(function(r){ var t = typeOf(r); typeMap[t] = (typeMap[t]||0)+1; });
  var topType='-', topCnt=0;
  Object.keys(typeMap).forEach(function(k){ if(typeMap[k]>topCnt){ topCnt=typeMap[k]; topType=k; } });

  var equipSet = {};
  data.forEach(function(r){ if(r.box_2) equipSet[r.box_2]=1; });

  document.getElementById('kpi-total').innerHTML = total.toLocaleString() + '<u>건</u>';
  document.getElementById('kpi-total-sub').textContent = '돌발고장 ' + (typeMap['돌발고장']||0) + '건 포함';
  document.getElementById('kpi-cost').innerHTML = won(costSum) + '<u>원</u>';
  document.getElementById('kpi-cost-sub').textContent = total ? '건당 평균 ' + won(Math.round(costSum/total)) + '원' : '-';
  document.getElementById('kpi-type').textContent = topType;
  document.getElementById('kpi-type-sub').textContent = total ? topCnt + '건 · ' + Math.round(topCnt/total*100) + '%' : '-';
  document.getElementById('kpi-equip').innerHTML = Object.keys(equipSet).length + '<u>대</u>';

  var recEl = document.getElementById('kpi-recent');
  var recentTitle = recent ? String(recent.box_11||'-').replace(/^\[[^\]]*\]\s*/, '') : '-';
  recEl.textContent = recentTitle; recEl.title = recentTitle;
  document.getElementById('kpi-recent-sub').textContent = recent ? (recent.box_6||recent.box_4||'') + ' · ' + (recent.box_2||'') : '-';

  var yr = document.getElementById('startDate').value || '-';
  document.getElementById('card-year-label').textContent = yr + '년';
  document.getElementById('footer-info').innerHTML = '총 <strong>' + total + '</strong>건';
  var now = new Date();
  document.getElementById('footer-time').textContent = pad2(now.getHours())+':'+pad2(now.getMinutes())+':'+pad2(now.getSeconds());

  document.getElementById('typeSplit').innerHTML = ['계획수리','정기수리','돌발고장'].map(function(t){
    return '<span><i class="dot ' + TYPE_DOT[t] + '"></i>' + t.replace('수리','').replace('고장','') + '<b class="num">' + (typeMap[t]||0) + '</b></span>';
  }).join('');
}

/* ─── 설비별 수리비용 ─── */
function renderRecent(data){
  var el = document.getElementById('recentList');
  if(!data || !data.length){ el.innerHTML = '<div class="recent-empty">조회된 데이터가 없습니다.</div>'; return; }
  var m = {};
  data.forEach(function(r){
    var k = r.box_2 || r.box_1 || '-';
    if(!m[k]) m[k] = { name:k, cnt:0, cost:0 };
    m[k].cnt++; m[k].cost += Number(r.box_13)||0;
  });
  var list = Object.keys(m).map(function(k){ return m[k]; }).sort(function(a,b){ return b.cost-a.cost; });
  var max = list[0].cost || 1;
  el.innerHTML = list.map(function(x){
    return '<div class="eq-it"><div class="eq-top"><span class="eq-nm">' + x.name + '<small>' + x.cnt + '건</small></span>' +
      '<span class="eq-cost num">' + won(x.cost) + '원</span></div>' +
      '<div class="eq-tr"><i style="width:' + Math.max(2, x.cost/max*100) + '%"></i></div></div>';
  }).join('');
  document.getElementById('recent-subtitle').textContent = '비용 순';
}

/* ─── 모달 show/hide ─── */
function showModal(){
  var ov = document.getElementById('modalContainer');
  ov.style.display = 'flex';
  setTimeout(function(){ ov.classList.add('show'); }, 10);
}
function hideModal(){
  var ov = document.getElementById('modalContainer');
  ov.classList.remove('show');
  setTimeout(function(){ ov.style.display = 'none'; }, 220);
}

/* ─── DOM Ready ─── */
document.addEventListener('DOMContentLoaded', function(){
  document.getElementById('startDate').value = new Date().getFullYear();

  /* 파일명 자동 세팅 */
  document.querySelector('input[name="upload_file_1"]').addEventListener('change', function(){
    document.querySelector('input[name="file_name_1"]').value = this.files[0]?.name || '';
  });
  document.querySelector('input[name="upload_file_2"]').addEventListener('change', function(){
    document.querySelector('input[name="file_name_2"]').value = this.files[0]?.name || '';
  });

  /* Tabulator 초기화 */
  dataTable = new Tabulator('#dataTable', {
    height: "calc(100vh - 260px)",
    layout: "fitColumns",
    headerHozAlign: "left",
    ajaxConfig: { method:'GET' },
    ajaxLoader: false,
    ajaxURL: "/line/productionManagement/repairHistory/select",
    ajaxParams: {
      startDate: document.getElementById('startDate').value,
      endDate:   document.getElementById('endDate').value
    },
    placeholder: "조회된 데이터가 없습니다.",
    ajaxResponse: function(url, params, response){
      allData = Array.isArray(response) ? response : (response.data||[]);
      updateKpi(allData);
      renderRecent(allData);
      return allData;
    },
    columns: [
      { title:"유형", width:96, headerSort:false,
        formatter:function(c){ var t=typeOf(c.getRow().getData()); return '<span class="type-cell"><i class="dot '+TYPE_DOT[t]+'"></i>'+t+'</span>'; } },
      { title:"수리제목", field:"box_11", minWidth:220, widthGrow:2, tooltip:true,
        formatter:function(c){ return String(c.getValue()||'').replace(/^\[[^\]]*\]\s*/, ''); } },
      { title:"설비", field:"box_2", width:120 },
      { title:"수리부위", field:"box_12", minWidth:120, tooltip:true },
      { title:"담당업체", field:"box_3", width:120 },
      { title:"수리 기간", field:"box_6", width:210,
        formatter:function(c){ var d=c.getRow().getData(); if(!d.box_6) return '';
          var e = d.box_8 ? (d.box_8===d.box_6 ? (d.box_9||'') : d.box_8.substr(5)+' '+(d.box_9||'')) : '진행중';
          return '<span class="date-cell num">'+d.box_6.substr(5)+' '+(d.box_7||'')+' ~ '+e+'</span>'; } },
      { title:"수리비용", field:"box_13", hozAlign:"right", headerHozAlign:"right", width:120, sorter:"number",
        formatter:function(c){ return '<span class="cost-cell num">'+won(c.getValue())+'원</span>'; } },
      { title:"담당자", field:"box_14", width:84 },
      { title:"회계처리", field:"box_10", width:100,
        formatter:function(c){ var v=c.getValue(); return v?'<span class="date-cell num">'+v+'</span>':'<span style="color:#d97706">미처리</span>'; } },
      { title:"사진", field:"file_name_1", width:64, hozAlign:"center", headerHozAlign:"center", headerSort:false,
        formatter:function(c){ var d=c.getRow().getData(), n=(d.file_name_1?1:0)+(d.file_name_2?1:0);
          return n ? '<a class="photo-link" href="/line/preview_repair?filename='+encodeURIComponent(d.file_name_1||d.file_name_2)+'" target="_blank" onclick="event.stopPropagation()">'+n+'장</a>' : '<span style="color:#cbd5e1">-</span>'; } }
    ],
    rowClick: function(e, row){
      document.querySelectorAll('#dataTable .tabulator-row').forEach(function(el){ el.classList.remove('row_select'); });
      row.getElement().classList.add('row_select');
      selectedRowData = row.getData();
    },
    rowDblClick: function(e, row){
      var d = row.getData();
      selectedRowData = d;
      document.getElementById('corrForm').reset();
      document.querySelector('input[name="idx"]').value = d.idx||'';

      var isReal = function(v){ if(v===null||v===undefined||v==='') return false; var s=String(v).trim(); return !(s.startsWith('box_')||s.startsWith('file_name_')); };
      for(var i=1;i<=17;i++){
        var key='box_'+i, val=d[key];
        if(!isReal(val)) continue;
        var el=document.querySelector('[name="'+key+'"]');
        if(el) el.value=val;
      }
      if(isReal(d.file_name_1)) document.querySelector('input[name="file_name_1"]').value=d.file_name_1;
      if(isReal(d.file_name_2)) document.querySelector('input[name="file_name_2"]').value=d.file_name_2;
      document.querySelector('input[name="upload_file_1"]').value='';
      document.querySelector('input[name="upload_file_2"]').value='';
      showModal();
    }
  });

  /* 조회 버튼 */
  document.querySelector('.select-button').addEventListener('click', function(){
    dataTable.setData("/line/productionManagement/repairHistory/select",{
      startDate: document.getElementById('startDate').value,
      endDate:   document.getElementById('endDate').value
    });
  });

  /* 추가 버튼 */
  document.querySelector('.insert-button').addEventListener('click', function(){
    selectedRowData = null;
    document.getElementById('corrForm').reset();
    document.querySelector('input[name="file_name_1"]').value='';
    document.querySelector('input[name="file_name_2"]').value='';
    showModal();
  });

  /* 삭제 버튼 */
  document.querySelector('.delete-button').addEventListener('click', function(){
    if(!selectedRowData){ alert('삭제할 행을 먼저 클릭해 주세요.'); return; }
    if(!confirm('선택된 항목을 정말 삭제하시겠습니까?')) return;
    fetch('/line/productionManagement/repairHistory/delete',{
      method:'POST', headers:{'Content-Type':'application/x-www-form-urlencoded'},
      body:'idx='+selectedRowData.idx
    }).then(function(r){ return r.json(); }).then(function(res){
      if(res.status==='success'){
        alert('삭제되었습니다.');
        dataTable.setData("/line/productionManagement/repairHistory/select",{});
        selectedRowData=null;
      } else { alert('삭제 실패: '+res.message); }
    }).catch(function(){ alert('삭제 중 오류가 발생했습니다.'); });
  });

  /* 모달 닫기 */
  document.querySelector('.close').addEventListener('click', hideModal);
  document.getElementById('closeModal').addEventListener('click', hideModal);
 

  /* 저장 */
  document.getElementById('corrForm').addEventListener('submit', function(e){
    e.preventDefault();
    var formData = new FormData(this);
    ['upload_file_1','upload_file_2'].forEach(function(n){
      var f=formData.get(n); if(f&&f.size===0) formData.delete(n);
    });
    var url = selectedRowData
      ? "/line/productionManagement/repairHistory/update"
      : "/line/productionManagement/repairHistory/insert";

    fetch(url,{ method:'POST', body:formData })
      .then(function(r){ return r.json(); })
      .then(function(res){
        if(res.status==='success'){
          alert('저장되었습니다!');
          hideModal();
          dataTable.setData("/line/productionManagement/repairHistory/select",{
            startDate: document.getElementById('startDate').value,
            endDate:   document.getElementById('endDate').value
          });
          selectedRowData=null;
        } else { alert('저장 실패: '+res.message); }
      })
      .catch(function(){ alert('저장 중 오류가 발생했습니다.'); });
  });

  /* PDF 다운로드 */
  document.querySelector('.excel-button').addEventListener('click', function(){ downloadExcel(); });
});

/* ─── PDF 다운로드 ─── */
function downloadExcel(){
  if(!selectedRowData){ alert("다운로드할 행을 선택해주세요."); return; }
  fetch("/line/productionManagement/repairHistory/jasperDownload",{
    method:"POST", headers:{"Content-Type":"application/json"},
    body: JSON.stringify([selectedRowData])
  }).then(function(res){
    if(!res.ok) throw new Error("다운로드 실패");
    return res.blob();
  }).then(function(blob){
    var url=window.URL.createObjectURL(blob);
    var a=document.createElement("a"); a.href=url; a.download="설비수리이력.pdf";
    document.body.appendChild(a); a.click(); a.remove();
    window.URL.revokeObjectURL(url);
  }).catch(function(err){ console.error(err); alert("리포트 다운로드 실패"); });
}
</script>
</body>
</html>
