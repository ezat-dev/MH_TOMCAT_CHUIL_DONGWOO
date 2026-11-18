<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<script src="/line/mock/mock-loader.js"></script>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>스페어파트 관리</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=IBM+Plex+Mono:wght@400;500&family=IBM+Plex+Sans+KR:wght@400;500;600&display=swap">
<link rel="stylesheet" href="/line/css/opsList/ops-list.css">
<script src="/vendor/xlsx/0.18.5/xlsx.full.min.js"></script>
<style>
/* ===== 데모: 스페어파트 관리 — 고밀도 운영 화면 (공통: ops-list.css) ===== */
html, body.ops { height: 100%; }
body.ops { display: flex; flex-direction: column; overflow: hidden; line-height: 1.4; }
.ops-page.sp { flex: 1; min-height: 0; }
.ops-sub { font-size: 12px; color: var(--ops-fg3); white-space: nowrap; }

/* 요약 스트립: 재고없음이 첫 시선 */
.sp .ops-kpi .kpi-value.warn { color: var(--ops-warn); }

/* 탭 + 색상 필터 (한 줄) */
.sp-bar { display: flex; align-items: center; gap: 16px; flex-wrap: wrap; }
.sp-tabs { display: inline-flex; border: 1px solid var(--ops-line); border-radius: 6px; background: #fff; overflow: hidden; }
.sp-tab {
  height: 32px; padding: 0 16px; border: 0; border-left: 1px solid var(--ops-line); background: #fff; cursor: pointer;
  font-family: var(--ops-sans); font-size: 13px; font-weight: 500; color: var(--ops-fg2); transition: background-color 80ms;
}
.sp-tab:first-child { border-left: 0; }
.sp-tab:hover { background: var(--ops-hover); }
.sp-tab.active { background: var(--ops-accent-tint); color: var(--ops-accent); }
.color-legend { display: flex; align-items: center; gap: 8px; flex-wrap: wrap; }
.color-legend .lg-title { font-size: 12px; color: var(--ops-fg2); margin-right: 4px; }
.color-legend-item {
  display: inline-flex; align-items: center; gap: 8px; height: 28px; padding: 0 10px; cursor: pointer;
  border: 1px solid var(--ops-line); border-radius: 6px; background: #fff; font-size: 12px; color: var(--ops-fg);
  transition: background-color 80ms, border-color 80ms;
}
.color-legend-item:hover { background: var(--ops-hover); }
.color-legend-item.active-filter { border-color: var(--ops-accent); background: var(--ops-accent-tint); color: var(--ops-accent); }
.color-legend-item .cnt { font-family: var(--ops-mono); font-variant-numeric: tabular-nums; color: var(--ops-fg3); }
.color-legend .lg-hint { margin-left: auto; font-size: 12px; color: var(--ops-fg3); }

/* 색상 상태 점: W 빈 원 · Y 주의 · G 정상(구매진행) */
.color-dot { display: inline-block; width: 8px; height: 8px; border-radius: 50%; flex-shrink: 0; }
.dot-W { background: #fff; box-shadow: inset 0 0 0 1.5px var(--ops-fg3); }
.dot-Y { background: var(--ops-warn); }
.dot-G { background: var(--ops-ok); }
.color-btn {
  display: inline-flex; align-items: center; gap: 6px; height: 24px; padding: 0 8px; cursor: pointer;
  border: 1px solid transparent; border-radius: 6px; background: none; font-family: var(--ops-mono); font-size: 12px; font-weight: 500;
  transition: background-color 80ms, border-color 80ms;
}
.color-btn:hover { background: var(--ops-hover); border-color: var(--ops-line); }
.color-btn .dot { width: 8px; height: 8px; border-radius: 50%; }
.cb-W .dot { background: #fff; box-shadow: inset 0 0 0 1.5px var(--ops-fg3); } .cb-W .lbl { color: var(--ops-fg3); }
.cb-Y .dot { background: var(--ops-warn); } .cb-Y .lbl { color: var(--ops-warn); }
.cb-G .dot { background: var(--ops-ok); } .cb-G .lbl { color: var(--ops-ok); }

/* 표 카드: 남은 높이를 채우고 표 안에서만 스크롤 */
.sp-tabpane { flex: 1; min-height: 0; display: flex; flex-direction: column; }
.sp-tabpane[style*="none"] { display: none !important; }
.sp-tabpane .ops-card { flex: 1; min-height: 0; display: flex; flex-direction: column; }
.ops-card-head .tools { display: flex; align-items: center; gap: 8px; }
.ops-card-head { align-items: center; padding: 8px 16px; }
.table-wrap { flex: 1; min-height: 0; overflow: auto; scrollbar-gutter: stable; }
.data-table { width: 100%; border-collapse: collapse; font-size: 13px; }
.data-table th {
  position: sticky; top: 0; z-index: 1; height: 32px; padding: 0 8px; background: #fff; text-align: left; white-space: nowrap;
  font-size: 12px; font-weight: 500; color: var(--ops-fg2); border-bottom: 1px solid var(--ops-line);
}
.data-table td { height: 36px; padding: 0 8px; border-bottom: 1px solid var(--ops-line2); white-space: nowrap; vertical-align: middle; color: var(--ops-fg); }
.data-table tbody tr { transition: background-color 80ms; }
.data-table tbody tr:hover { background: var(--ops-hover); }
.data-table .r { text-align: right !important; }
.data-table .c { text-align: center !important; }
.data-table .num { font-family: var(--ops-mono); font-variant-numeric: tabular-nums; }
.data-table .id { font-family: var(--ops-mono); font-size: 12px; font-variant-numeric: tabular-nums slashed-zero; }
.data-table .m { color: var(--ops-fg3); }
.data-table .s { color: var(--ops-fg2); }
.data-table .name { font-weight: 500; max-width: 220px; overflow: hidden; text-overflow: ellipsis; }
.data-table .ellip { max-width: 160px; overflow: hidden; text-overflow: ellipsis; }
.data-table .t-bad { color: var(--ops-bad); } .data-table .t-warn { color: var(--ops-warn); }
.data-table td.empty { height: auto; padding: 48px 8px; text-align: center; color: var(--ops-fg3); white-space: normal; }
.ops .st.warn { color: var(--ops-warn); } .ops .st.in { color: var(--ops-accent); }

/* 재고 막대 (최소재고 2배 = 100%) */
.stock-bar-bg { display: inline-block; width: 64px; height: 4px; border-radius: 2px; background: var(--ops-line2); overflow: hidden; vertical-align: middle; }
.stock-bar-fill { display: block; height: 100%; border-radius: 2px; }

/* 행 액션: 테두리 없는 작은 버튼 */
.act-btns { display: flex; gap: 4px; }
.btn-xs {
  height: 24px; padding: 0 8px; border: 1px solid var(--ops-line); border-radius: 4px; background: #fff; cursor: pointer;
  font-family: var(--ops-sans); font-size: 12px; color: var(--ops-fg2); white-space: nowrap; transition: background-color 80ms, color 80ms, border-color 80ms;
}
.btn-xs:hover { background: var(--ops-hover); color: var(--ops-fg); }
.btn-xs-del:hover { color: var(--ops-bad); border-color: var(--ops-bad); }

/* 이력 탭 필터 */
.ctrl-bar { display: flex; align-items: center; gap: 8px; flex-wrap: wrap; }
.ctrl-bar .ops-input { min-width: 0; }
.ctrl-bar select.ops-input { font-family: var(--ops-sans); }
#historyCount { font-family: var(--ops-mono); font-size: 12px; color: var(--ops-fg3); }

/* 모달: 머리·버튼줄 고정, 본문만 스크롤 (열기/닫기는 기존 .show 토글) */
.modal-overlay .modal-box { display: flex; flex-direction: column; overflow: hidden; }
.modal-box.sm { width: 440px; }
.modal-box .modal-body { overflow-y: auto; min-height: 0; }
.modal-box .modal-close { border: 0; background: transparent; font-family: var(--ops-sans); }
.modal-box .form-group.lead .row { display: flex; gap: 8px; }
.modal-box .form-group.lead .form-input { flex: 1; min-width: 0; }
.modal-box .form-group.lead .form-select { width: 72px; }
.modal-box .form-input[readonly] { background: var(--ops-bg); color: var(--ops-fg2); }

@media(max-width:640px){ .hide-m { display: none !important; } .form-grid { grid-template-columns: 1fr; } }
</style>
</head>
<body class="ops">

<!-- ===== 헤더 ===== -->
<header class="ops-head">
  <div class="ops-head-in">
    <h1 class="ops-title">스페어파트 관리</h1>
    <span class="ops-sub">부품 재고 · 색상 상태 · 입출고 이력</span>
    <span class="ops-spacer"></span>
    <button class="ops-btn" onclick="openInModal(null)">입고 등록</button>
    <button class="ops-btn" onclick="openOutModal(null)">사용 등록</button>
    <button class="ops-btn primary" onclick="openPartsModal(null)">
      <svg viewBox="0 0 24 24"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
      부품 등록
    </button>
  </div>
</header>

<main class="ops-page sp">

  <!-- 요약: 재고없음 → 부족 → 정상 → 전체 → 금액 -->
  <section class="ops-kpi" aria-label="요약">
    <div class="hero">
      <span class="kpi-label">재고 없음</span>
      <span class="kpi-value" id="kNone">0</span>
      <span class="kpi-sub">즉시 발주 필요 품목</span>
    </div>
    <div>
      <span class="kpi-label">재고 부족</span>
      <span class="kpi-value" id="kLow">0</span>
      <span class="kpi-sub">최소재고 미만</span>
    </div>
    <div>
      <span class="kpi-label">정상</span>
      <span class="kpi-value" id="kOk">0</span>
      <span class="kpi-sub">품목</span>
    </div>
    <div>
      <span class="kpi-label">전체 품목</span>
      <span class="kpi-value" id="kTotal">0</span>
      <span class="kpi-sub">조회 조건 기준</span>
    </div>
    <div>
      <span class="kpi-label">총 재고금액</span>
      <span class="kpi-value" id="kValue">0</span>
      <span class="kpi-sub">원 · 현재재고 × 단가</span>
    </div>
  </section>

  <!-- 탭 + 색상 필터 -->
  <div class="sp-bar">
    <div class="sp-tabs" role="tablist">
      <button class="sp-tab active" onclick="showTab('stock',this)">재고 현황</button>
      <button class="sp-tab"        onclick="showTab('history',this)">입출고 이력</button>
    </div>
    <div class="color-legend">
      <span class="lg-title">색상 상태</span>
      <span class="color-legend-item active-filter" id="fl-all" onclick="filterByColor('')">
        전체 <span class="cnt" id="cntAll"></span>
      </span>
      <span class="color-legend-item" id="fl-W" onclick="filterByColor('W')">
        <span class="color-dot dot-W"></span>W 재고확보 <span class="cnt" id="cntW"></span>
      </span>
      <span class="color-legend-item" id="fl-Y" onclick="filterByColor('Y')">
        <span class="color-dot dot-Y"></span>Y Critical List <span class="cnt" id="cntY"></span>
      </span>
      <span class="color-legend-item" id="fl-G" onclick="filterByColor('G')">
        <span class="color-dot dot-G"></span>G 구매진행중 <span class="cnt" id="cntG"></span>
      </span>
    </div>
    <span class="lg-hint ops-sub" style="margin-left:auto">색상 셀 클릭 → 다음 상태로 변경</span>
  </div>

  <!-- ══ 탭1: 재고 현황 ══ -->
  <div id="tab-stock" class="sp-tabpane">
    <section class="ops-card">
      <div class="ops-card-head">
        <h2>부품 목록</h2>
        <div class="tools">
          <select class="ops-input" id="fCategory" style="width:128px;font-family:var(--ops-sans)" onchange="loadParts()">
            <option value="">전체 구분</option>
          </select>
          <input class="ops-input" type="text" id="fKeyword" placeholder="품명·부품번호" style="width:176px;font-family:var(--ops-sans)"
                 onkeydown="if(event.key==='Enter') loadParts()">
          <button class="ops-btn primary" onclick="loadParts()">조회</button>
          <button class="ops-btn" onclick="exportParts()">엑셀</button>
        </div>
      </div>
      <div class="table-wrap">
        <table class="data-table">
          <thead>
            <tr>
              <th class="r" style="width:40px">No</th>
              <th style="width:56px">색상</th>
              <th>부품번호</th>
              <th>품명</th>
              <th>구분</th>
              <th class="hide-m">적용 설비</th>
              <th class="r">현재재고</th>
              <th class="r hide-m">최소재고</th>
              <th class="hide-m" style="width:80px">재고현황</th>
              <th class="r">총입고</th>
              <th class="r">총사용</th>
              <th>상태</th>
              <th class="r hide-m">단가(원)</th>
              <th class="r hide-m">재고금액(원)</th>
              <th class="hide-m">단위</th>
              <th class="r hide-m">교체주기</th>
              <th class="hide-m">민감도</th>
              <th class="r hide-m">리드타임</th>
              <th class="r hide-m">예상금액(원)</th>
              <th>관리</th>
            </tr>
          </thead>
          <tbody id="partsBody">
            <tr><td colspan="20" class="empty">로딩 중…</td></tr>
          </tbody>
        </table>
      </div>
    </section>
  </div>

  <!-- ══ 탭2: 입출고 이력 ══ -->
  <div id="tab-history" class="sp-tabpane" style="display:none">
    <section class="ops-card">
      <div class="ops-card-head">
        <h2>입출고 이력</h2>
        <div class="ctrl-bar">
          <span class="ops-label">구분</span>
          <select class="ops-input" id="hType" style="width:88px">
            <option value="">전체</option>
            <option value="IN">입고</option>
            <option value="OUT">사용</option>
          </select>
          <span class="ops-label">기간</span>
          <input class="ops-input" type="date" id="hFrom" style="width:144px">
          <span class="ops-sub">~</span>
          <input class="ops-input" type="date" id="hTo" style="width:144px">
          <button class="ops-btn primary" onclick="loadHistory()">조회</button>
          <button class="ops-btn" onclick="exportHistory()">엑셀</button>
          <span id="historyCount"></span>
        </div>
      </div>
      <div class="table-wrap">
        <table class="data-table">
          <thead>
            <tr>
              <th class="r" style="width:40px">No</th>
              <th>일시</th>
              <th>구분</th>
              <th>부품번호</th>
              <th>품명</th>
              <th class="r">수량</th>
              <th class="hide-m">설비</th>
              <th>작업내용</th>
              <th class="hide-m">담당자</th>
              <th>관리</th>
            </tr>
          </thead>
          <tbody id="historyBody">
            <tr><td colspan="10" class="empty">조회 버튼을 눌러 이력을 확인하세요</td></tr>
          </tbody>
        </table>
      </div>
    </section>
  </div>

</main>

<!-- ══ 부품 마스터 등록/수정 모달 ══ -->
<div class="modal-overlay" id="partsModal">
  <div class="modal-box" role="dialog" aria-labelledby="partsModalTitle">
    <div class="modal-head">
      <h2 id="partsModalTitle">부품 등록</h2>
      <button class="modal-close" type="button" onclick="closePartsModal()" aria-label="닫기">✕</button>
    </div>
    <div class="modal-body">
      <div class="form-grid">
        <div class="form-group">
          <label class="form-label">부품번호 *</label>
          <input class="form-input mono" type="text" id="mPartNo" placeholder="예) HT-001">
        </div>
        <div class="form-group">
          <label class="form-label">품명 *</label>
          <input class="form-input" type="text" id="mPartName" placeholder="예) 히터 엘리먼트 3kW">
        </div>
        <div class="form-group">
          <label class="form-label">구분</label>
          <input class="form-input" type="text" id="mCategory" placeholder="예) 히터, 열전대, 밸브" list="categoryDataList">
          <datalist id="categoryDataList"></datalist>
        </div>
        <div class="form-group">
          <label class="form-label">단위</label>
          <input class="form-input" type="text" id="mUnit" value="EA">
        </div>
        <div class="form-group full">
          <label class="form-label">적용 설비</label>
          <input class="form-input" type="text" id="mEquipment" placeholder="예) 열처리로 전계열">
        </div>
        <div class="form-group">
          <label class="form-label">최소재고 (EA)</label>
          <input class="form-input" type="number" id="mMinStock" value="1" min="0">
        </div>
        <div class="form-group">
          <label class="form-label">교체주기 (개월, 0=없음)</label>
          <input class="form-input" type="number" id="mReplaceCycle" value="0" min="0">
        </div>
        <div class="form-group">
          <label class="form-label">예상단가 (원/EA)</label>
          <input class="form-input" type="number" id="mPriceEa" value="0" min="0" placeholder="0">
        </div>
        <div class="form-group">
          <label class="form-label">제조사</label>
          <input class="form-input" type="text" id="mMaker">
        </div>
        <div class="form-group">
          <label class="form-label">민감도</label>
          <select class="form-select" id="mSensitivity">
            <option value="하">하</option>
            <option value="중">중</option>
            <option value="상">상</option>
          </select>
        </div>
        <div class="form-group lead">
          <label class="form-label">리드타임</label>
          <div class="row">
            <input class="form-input" type="number" id="mLeadTimeVal" min="0" value="0">
            <select class="form-select" id="mLeadTimeUnit">
              <option value="일">일</option>
              <option value="주">주</option>
            </select>
          </div>
        </div>
        <div class="form-group">
          <label class="form-label">예상금액 (원)</label>
          <input class="form-input" type="number" id="mExpectedAmt" value="0" min="0" placeholder="0">
        </div>
        <div class="form-group">
          <label class="form-label">사양/모델</label>
          <input class="form-input" type="text" id="mSpecModel">
        </div>
        <div class="form-group">
          <label class="form-label">색상 상태</label>
          <select class="form-select" id="mColorStatus">
            <option value="W">W — 재고확보</option>
            <option value="Y">Y — Critical List</option>
            <option value="G">G — 구매진행중</option>
          </select>
        </div>
        <div class="form-group">
          <label class="form-label">고객제공</label>
          <select class="form-select" id="mCustomerYn">
            <option value="N">N</option>
            <option value="Y">Y</option>
          </select>
        </div>
        <div class="form-group full">
          <label class="form-label">비고</label>
          <input class="form-input" type="text" id="mRemark">
        </div>
      </div>
    </div>
    <div class="modal-btn-row">
      <button class="ops-btn" onclick="closePartsModal()">취소</button>
      <button class="ops-btn primary" onclick="savePartsModal()">저장</button>
    </div>
  </div>
</div>

<!-- ══ 입고 모달 ══ -->
<div class="modal-overlay" id="inModal">
  <div class="modal-box sm" role="dialog" aria-labelledby="inModalTitle">
    <div class="modal-head">
      <h2 id="inModalTitle">입고 등록</h2>
      <button class="modal-close" type="button" onclick="closeInModal()" aria-label="닫기">✕</button>
    </div>
    <div class="modal-body">
      <div class="form-grid">
        <div class="form-group full">
          <label class="form-label">부품 *</label>
          <select class="form-select" id="inPartNo"></select>
        </div>
        <div class="form-group">
          <label class="form-label">입고 수량 *</label>
          <input class="form-input" type="number" id="inQty" min="1" value="1">
        </div>
        <div class="form-group">
          <label class="form-label">담당자</label>
          <input class="form-input" type="text" id="inUserName" placeholder="성명">
        </div>
        <div class="form-group full">
          <label class="form-label">작업내용</label>
          <input class="form-input" type="text" id="inWorkDesc" placeholder="예) 신규 입고, 정기 발주">
        </div>
      </div>
    </div>
    <div class="modal-btn-row">
      <button class="ops-btn" onclick="closeInModal()">취소</button>
      <button class="ops-btn primary" onclick="saveInModal()">저장</button>
    </div>
  </div>
</div>

<!-- ══ 사용(OUT) 모달 ══ -->
<div class="modal-overlay" id="outModal">
  <div class="modal-box sm" role="dialog" aria-labelledby="outModalTitle">
    <div class="modal-head">
      <h2 id="outModalTitle">사용 등록</h2>
      <button class="modal-close" type="button" onclick="closeOutModal()" aria-label="닫기">✕</button>
    </div>
    <div class="modal-body">
      <div class="form-grid">
        <div class="form-group full">
          <label class="form-label">부품 *</label>
          <select class="form-select" id="outPartNo"></select>
        </div>
        <div class="form-group">
          <label class="form-label">사용 수량 *</label>
          <input class="form-input" type="number" id="outQty" min="1" value="1">
        </div>
        <div class="form-group">
          <label class="form-label">담당자</label>
          <input class="form-input" type="text" id="outUserName" placeholder="성명">
        </div>
        <div class="form-group full">
          <label class="form-label">사용 설비</label>
          <input class="form-input" type="text" id="outEquipment" placeholder="예) 열처리로 1호기">
        </div>
        <div class="form-group full">
          <label class="form-label">작업내용</label>
          <input class="form-input" type="text" id="outWorkDesc" placeholder="예) 히터 교체, 정기 교환">
        </div>
      </div>
    </div>
    <div class="modal-btn-row">
      <button class="ops-btn" onclick="closeOutModal()">취소</button>
      <button class="ops-btn primary" onclick="saveOutModal()">사용 처리</button>
    </div>
  </div>
</div>

<script>
var base              = '${pageContext.request.contextPath}';
var partsCache        = [];
var historyCache      = [];
var activeColorFilter = '';

/* ── 초기화 ── */
(function(){
  var t = new Date();
  var y = t.getFullYear(), m = String(t.getMonth()+1).padStart(2,'0');
  document.getElementById('hFrom').value = y + '-' + m + '-01';
  document.getElementById('hTo').value   = t.toISOString().slice(0,10);
  loadCategoryOptions();
  loadParts();
  document.getElementById('fl-all').classList.add('active-filter');
})();

/* ── 구분 드롭다운 동적 로드 ── */
function loadCategoryOptions() {
  fetch(base + '/parts/category/list')
    .then(function(r){ return r.json(); })
    .then(function(list){
      var sel = document.getElementById('fCategory');
      var dl  = document.getElementById('categoryDataList');
      sel.innerHTML = '<option value="">전체 구분</option>';
      dl.innerHTML  = '';
      list.forEach(function(v){
        var o = document.createElement('option');
        o.value = v; o.textContent = v; sel.appendChild(o);
        var d = document.createElement('option');
        d.value = v; dl.appendChild(d);
      });
    }).catch(function(){});
}

/* ══════════════════════════════════════════
   재고 현황
══════════════════════════════════════════ */
function loadParts() {
  var cat   = document.getElementById('fCategory').value;
  var kw    = document.getElementById('fKeyword').value.trim();
  var qs    = '?category='    + encodeURIComponent(cat)
            + '&keyword='     + encodeURIComponent(kw)
            + '&colorStatus=' + encodeURIComponent(activeColorFilter);

  fetch(base + '/parts/list' + qs)
    .then(function(r){ return r.json(); })
    .then(function(d){
      if (!d.success) { alert(d.error || '조회 실패'); return; }
      partsCache = d.data || [];
      renderParts(partsCache);
      updatePartsSelect();
    })
    .catch(function(){ alert('부품 목록 로드 실패'); });
}

function comma(n) {
  return Number(n || 0).toLocaleString('ko-KR');
}

function renderParts(list) {
  var none=0, low=0, ok=0, cW=0, cY=0, cG=0, totalValue=0;
  var html = '';

  list.forEach(function(r, i){
    var cur   = r.currentStock;
    var st    = r.stockStatus;
    var cs    = r.colorStatus || 'W';
    var price = r.priceEa || 0;
    var stockVal = cur * price;
    totalValue += stockVal;

    var barColor, badgeCls, curCls;
    if      (st === '재고없음') { barColor='var(--ops-bad)';  badgeCls='bad';  curCls='t-bad';  none++; }
    else if (st === '부족')     { barColor='var(--ops-warn)'; badgeCls='warn'; curCls='t-warn'; low++;  }
    else                        { barColor='var(--ops-ok)';   badgeCls='ok';   curCls='';       ok++;   }
    var sensCls = r.sensitivity === '상' ? 't-bad' : r.sensitivity === '중' ? 't-warn' : 'm';
    var ltVal  = r.leadTimeVal  || 0;
    var ltUnit = r.leadTimeUnit || '일';
    var ltStr  = ltVal > 0 ? ltVal + ltUnit : '—';
    var expAmt = r.expectedAmt || 0;
    if      (cs === 'Y') cY++;
    else if (cs === 'G') cG++;
    else                 cW++;

    var pct = r.minStock > 0
      ? Math.min(100, Math.round(cur / (r.minStock * 2) * 100))
      : (cur > 0 ? 100 : 0);
    var cycle = r.replaceCycle > 0 ? r.replaceCycle + '개월' : '—';

    var colorCell = '<button class="color-btn cb-' + cs
      + '" onclick="cycleColor(\'' + esc(r.partNo) + '\',\'' + cs + '\')" title="클릭 → 색상 변경">'
      + '<span class="dot"></span>'
      + '<span class="lbl">' + cs + '</span>'
      + '</button>';

    var actHtml = '<div class="act-btns">'
      + '<button class="btn-xs btn-xs-in"   onclick="openInModal(\''  + esc(r.partNo) + '\')">입고</button>'
      + '<button class="btn-xs btn-xs-out"  onclick="openOutModal(\'' + esc(r.partNo) + '\')">사용</button>'
      + '<button class="btn-xs btn-xs-edit" onclick="openPartsModal(\'' + esc(r.partNo) + '\')">수정</button>'
      + '<button class="btn-xs btn-xs-del"  onclick="deleteParts(\''  + esc(r.partNo) + '\')">삭제</button>'
      + '</div>';

    html += '<tr>'
      + '<td class="r num m">' + (i+1) + '</td>'
      + '<td>' + colorCell + '</td>'
      + '<td class="id">' + esc(r.partNo) + '</td>'
      + '<td class="name" title="' + esc(r.partName) + '">' + esc(r.partName) + '</td>'
      + '<td class="s">' + esc(r.category||'—') + '</td>'
      + '<td class="hide-m s ellip" title="' + esc(r.equipment||'') + '">' + esc(r.equipment||'—') + '</td>'
      + '<td class="r num ' + curCls + '" style="font-weight:500">' + cur + '</td>'
      + '<td class="r num m hide-m">' + r.minStock + '</td>'
      + '<td class="hide-m"><span class="stock-bar-bg">'
        + '<span class="stock-bar-fill" style="width:' + pct + '%;background:' + barColor + '"></span>'
        + '</span></td>'
      + '<td class="r num s">' + r.totalIn + '</td>'
      + '<td class="r num s">' + r.totalOut + '</td>'
      + '<td><span class="st ' + badgeCls + '"><i></i>' + st + '</span></td>'
      + '<td class="hide-m r num s">' + (price > 0 ? comma(price) : '—') + '</td>'
      + '<td class="hide-m r num' + (stockVal > 0 ? '' : ' m') + '">' + (stockVal > 0 ? comma(stockVal) : '—') + '</td>'
      + '<td class="hide-m m">' + esc(r.unit||'EA') + '</td>'
      + '<td class="hide-m r num m">' + cycle + '</td>'
      + '<td class="hide-m ' + sensCls + '">' + esc(r.sensitivity||'하') + '</td>'
      + '<td class="hide-m r num m">' + ltStr + '</td>'
      + '<td class="hide-m r num' + (expAmt > 0 ? '' : ' m') + '">' + (expAmt > 0 ? comma(expAmt) : '—') + '</td>'
      + '<td>' + actHtml + '</td>'
      + '</tr>';
  });

  document.getElementById('partsBody').innerHTML = html ||
    '<tr><td colspan="20" class="empty">'
    + '등록된 부품이 없습니다. 오른쪽 위 <strong>부품 등록</strong>으로 추가하세요.</td></tr>';

  document.getElementById('kTotal').textContent = list.length;
  document.getElementById('kNone').textContent  = none;
  document.getElementById('kLow').textContent   = low;
  document.getElementById('kOk').textContent    = ok;
  document.getElementById('kValue').textContent = comma(totalValue);
  document.getElementById('kNone').classList.toggle('bad', none > 0);
  document.getElementById('kLow').classList.toggle('warn', low > 0);
  document.getElementById('cntAll').textContent = list.length;
  document.getElementById('cntW').textContent   = cW;
  document.getElementById('cntY').textContent   = cY;
  document.getElementById('cntG').textContent   = cG;
}

function filterByColor(color) {
  activeColorFilter = color;
  ['fl-all','fl-W','fl-Y','fl-G'].forEach(function(id){
    document.getElementById(id).classList.remove('active-filter');
  });
  document.getElementById(color === '' ? 'fl-all' : ('fl-' + color)).classList.add('active-filter');
  loadParts();
}

function cycleColor(partNo, cur) {
  var order = ['W','Y','G'];
  var next  = order[(order.indexOf(cur) + 1) % 3];
  fetch(base + '/parts/color', {
    method: 'POST',
    headers: {'Content-Type':'application/json'},
    body: JSON.stringify({partNo: partNo, colorStatus: next})
  }).then(function(r){ return r.json(); })
    .then(function(d){ if (d.success) loadParts(); else alert(d.error || '색상 변경 실패'); });
}

/* ══════════════════════════════════════════
   입출고 이력
══════════════════════════════════════════ */
function loadHistory() {
  var qs = '?type='   + encodeURIComponent(document.getElementById('hType').value)
         + '&fromDt=' + encodeURIComponent(document.getElementById('hFrom').value)
         + '&toDt='   + encodeURIComponent(document.getElementById('hTo').value);
  fetch(base + '/parts/history/list' + qs)
    .then(function(r){ return r.json(); })
    .then(function(d){
      if (!d.success) { alert(d.error || '조회 실패'); return; }
      renderHistory(d.data || []);
    });
}

function renderHistory(list) {
  historyCache = list;
  document.getElementById('historyCount').textContent = '총 ' + list.length + '건';
  if (!list.length) {
    document.getElementById('historyBody').innerHTML =
      '<tr><td colspan="10" class="empty">이력이 없습니다.</td></tr>';
    return;
  }
  var html = '';
  list.forEach(function(r, i){
    var typeBadge = r.type === 'IN'
      ? '<span class="st in"><i></i>입고</span>'
      : '<span class="st warn"><i></i>사용</span>';
    var qtyStr = r.type === 'IN' ? '+' + r.qty : '−' + r.qty;
    html += '<tr>'
      + '<td class="r num m">' + (i+1) + '</td>'
      + '<td class="id s">'    + esc(r.createdAt||'') + '</td>'
      + '<td>'                 + typeBadge             + '</td>'
      + '<td class="id">'      + esc(r.partNo||'')   + '</td>'
      + '<td class="name">'    + esc(r.partName||'')  + '</td>'
      + '<td class="r num" style="font-weight:500">' + qtyStr + '</td>'
      + '<td class="hide-m s">' + esc(r.equipment||'—')+ '</td>'
      + '<td>'                  + esc(r.workDesc||'—') + '</td>'
      + '<td class="hide-m s">' + esc(r.userName||'—') + '</td>'
      + '<td><button class="btn-xs btn-xs-del" onclick="deleteHistory(' + r.id + ')">삭제</button></td>'
      + '</tr>';
  });
  document.getElementById('historyBody').innerHTML = html;
}

/* ══════════════════════════════════════════
   부품 마스터 모달
══════════════════════════════════════════ */
var editingPartNo = null;

function openPartsModal(partNo) {
  editingPartNo = partNo || null;
  document.getElementById('partsModalTitle').textContent = partNo ? '부품 수정' : '부품 등록';
  if (partNo) {
    var r = partsCache.find(function(p){ return p.partNo === partNo; });
    if (r) {
      document.getElementById('mPartNo').value       = r.partNo;
      document.getElementById('mPartNo').readOnly    = true;
      document.getElementById('mPartName').value     = r.partName;
      document.getElementById('mCategory').value     = r.category || '';
      document.getElementById('mEquipment').value    = r.equipment || '';
      document.getElementById('mUnit').value         = r.unit || 'EA';
      document.getElementById('mMinStock').value     = r.minStock;
      document.getElementById('mReplaceCycle').value = r.replaceCycle;
      document.getElementById('mMaker').value        = r.maker || '';
      document.getElementById('mSpecModel').value    = r.specModel || '';
      document.getElementById('mColorStatus').value  = r.colorStatus || 'W';
      document.getElementById('mCustomerYn').value   = r.customerYn || 'N';
      document.getElementById('mSensitivity').value  = r.sensitivity || '하';
      document.getElementById('mLeadTimeVal').value  = r.leadTimeVal || 0;
      document.getElementById('mLeadTimeUnit').value = r.leadTimeUnit || '일';
      document.getElementById('mExpectedAmt').value  = r.expectedAmt || 0;
      document.getElementById('mRemark').value       = r.remark || '';
    }
  } else {
    ['mPartNo','mPartName','mCategory','mEquipment','mMaker','mSpecModel','mRemark'].forEach(function(id){
      document.getElementById(id).value = '';
    });
    document.getElementById('mPartNo').readOnly    = false;
    document.getElementById('mUnit').value         = 'EA';
    document.getElementById('mMinStock').value     = '1';
    document.getElementById('mReplaceCycle').value = '0';
    document.getElementById('mColorStatus').value  = 'W';
    document.getElementById('mCustomerYn').value   = 'N';
    document.getElementById('mSensitivity').value  = '하';
    document.getElementById('mLeadTimeVal').value  = '0';
    document.getElementById('mLeadTimeUnit').value = '일';
    document.getElementById('mExpectedAmt').value  = '0';
  }
  document.getElementById('partsModal').classList.add('show');
}
function closePartsModal() { document.getElementById('partsModal').classList.remove('show'); }

function savePartsModal() {
  var partNo   = document.getElementById('mPartNo').value.trim();
  var partName = document.getElementById('mPartName').value.trim();
  if (!partNo || !partName) { alert('부품번호와 품명은 필수입니다.'); return; }
  fetch(base + '/parts/save', {
    method: 'POST',
    headers: {'Content-Type':'application/json'},
    body: JSON.stringify({
      partNo:       partNo,
      partName:     partName,
      category:     document.getElementById('mCategory').value.trim(),
      equipment:    document.getElementById('mEquipment').value.trim(),
      unit:         document.getElementById('mUnit').value.trim() || 'EA',
      minStock:     parseInt(document.getElementById('mMinStock').value)     || 0,
      replaceCycle: parseInt(document.getElementById('mReplaceCycle').value) || 0,
      maker:        document.getElementById('mMaker').value.trim(),
      specModel:    document.getElementById('mSpecModel').value.trim(),
      colorStatus:  document.getElementById('mColorStatus').value,
      customerYn:   document.getElementById('mCustomerYn').value,
      sensitivity:  document.getElementById('mSensitivity').value,
      leadTimeVal:  parseInt(document.getElementById('mLeadTimeVal').value)  || 0,
      leadTimeUnit: document.getElementById('mLeadTimeUnit').value,
      expectedAmt:  parseInt(document.getElementById('mExpectedAmt').value)  || 0,
      remark:       document.getElementById('mRemark').value.trim()
    })
  }).then(function(r){ return r.json(); })
    .then(function(d){
      if (!d.success) { alert(d.error || '저장 실패'); return; }
      closePartsModal();
      loadParts();
      loadCategoryOptions();
    });
}

function deleteParts(partNo) {
  if (!confirm('[' + partNo + '] 부품을 삭제하시겠습니까?\n관련 이력도 함께 삭제됩니다.')) return;
  fetch(base + '/parts/delete', {
    method: 'POST', headers: {'Content-Type':'application/json'},
    body: JSON.stringify({partNo: partNo})
  }).then(function(r){ return r.json(); })
    .then(function(d){ if (d.success) loadParts(); else alert(d.error || '삭제 실패'); });
}

/* ══════════════════════════════════════════
   입고 모달
══════════════════════════════════════════ */
function updatePartsSelect() {
  var opts = partsCache.length
    ? partsCache.map(function(p){
        return '<option value="' + esc(p.partNo) + '">' + esc(p.partNo) + ' — ' + esc(p.partName) + '</option>';
      }).join('')
    : '<option value="">부품 없음</option>';
  document.getElementById('inPartNo').innerHTML  = opts;
  document.getElementById('outPartNo').innerHTML = opts;
}

function openInModal(partNo) {
  if (!partsCache.length) { alert('먼저 부품을 등록하세요.'); return; }
  document.getElementById('inQty').value      = '1';
  document.getElementById('inWorkDesc').value = '신규 입고';
  document.getElementById('inUserName').value = '';
  if (partNo) document.getElementById('inPartNo').value = partNo;
  document.getElementById('inModal').classList.add('show');
}
function closeInModal() { document.getElementById('inModal').classList.remove('show'); }

function saveInModal() {
  var qty = parseInt(document.getElementById('inQty').value);
  if (qty < 1) { alert('수량을 1 이상 입력하세요.'); return; }
  fetch(base + '/parts/history/save', {
    method: 'POST', headers: {'Content-Type':'application/json'},
    body: JSON.stringify({
      partNo:   document.getElementById('inPartNo').value,
      type:     'IN',
      qty:      qty,
      workDesc: document.getElementById('inWorkDesc').value.trim(),
      userName: document.getElementById('inUserName').value.trim()
    })
  }).then(function(r){ return r.json(); })
    .then(function(d){ if (!d.success) { alert(d.error || '저장 실패'); return; } closeInModal(); loadParts(); });
}

/* ══════════════════════════════════════════
   사용 모달
══════════════════════════════════════════ */
function openOutModal(partNo) {
  if (!partsCache.length) { alert('먼저 부품을 등록하세요.'); return; }
  document.getElementById('outQty').value       = '1';
  document.getElementById('outEquipment').value = '';
  document.getElementById('outWorkDesc').value  = '';
  document.getElementById('outUserName').value  = '';
  if (partNo) document.getElementById('outPartNo').value = partNo;
  document.getElementById('outModal').classList.add('show');
}
function closeOutModal() { document.getElementById('outModal').classList.remove('show'); }

function saveOutModal() {
  var qty    = parseInt(document.getElementById('outQty').value);
  var partNo = document.getElementById('outPartNo').value;
  if (qty < 1) { alert('수량을 1 이상 입력하세요.'); return; }
  var part = partsCache.find(function(p){ return p.partNo === partNo; });
  if (part && part.currentStock < qty) {
    if (!confirm('현재 재고(' + part.currentStock + ')보다 많은 수량입니다. 계속하시겠습니까?')) return;
  }
  fetch(base + '/parts/history/save', {
    method: 'POST', headers: {'Content-Type':'application/json'},
    body: JSON.stringify({
      partNo:    partNo,
      type:      'OUT',
      qty:       qty,
      equipment: document.getElementById('outEquipment').value.trim(),
      workDesc:  document.getElementById('outWorkDesc').value.trim(),
      userName:  document.getElementById('outUserName').value.trim()
    })
  }).then(function(r){ return r.json(); })
    .then(function(d){ if (!d.success) { alert(d.error || '저장 실패'); return; } closeOutModal(); loadParts(); });
}

/* ══════════════════════════════════════════
   이력 삭제
══════════════════════════════════════════ */
function deleteHistory(id) {
  if (!confirm('이 이력을 삭제하시겠습니까?')) return;
  fetch(base + '/parts/history/delete', {
    method: 'POST', headers: {'Content-Type':'application/json'},
    body: JSON.stringify({id: id})
  }).then(function(r){ return r.json(); })
    .then(function(d){
      if (d.success) { loadHistory(); loadParts(); }
      else alert(d.error || '삭제 실패');
    });
}

/* ══════════════════════════════════════════
   탭 전환
══════════════════════════════════════════ */
function showTab(id, btn) {
  document.getElementById('tab-stock').style.display   = id === 'stock'   ? '' : 'none';
  document.getElementById('tab-history').style.display = id === 'history' ? '' : 'none';
  document.querySelectorAll('.sp-tab').forEach(function(b){ b.classList.remove('active'); });
  if (btn) btn.classList.add('active');
  if (id === 'history') loadHistory();
}

/* ══════════════════════════════════════════
   엑셀 출력
══════════════════════════════════════════ */
function getToday() {
  return new Date().toISOString().slice(0, 10).replace(/-/g, '');
}

function exportParts() {
  if (!partsCache.length) { alert('출력할 데이터가 없습니다.'); return; }
  var header = ['No','색상','부품번호','품명','구분','적용설비',
                '현재재고','최소재고','총입고','총사용','상태',
                '단가(원)','재고금액(원)','단위','교체주기',
                '민감도','리드타임','예상금액(원)'];
  var rows = [header];
  partsCache.forEach(function(r, i) {
    var ltStr    = r.leadTimeVal > 0 ? r.leadTimeVal + (r.leadTimeUnit || '일') : '';
    var stockVal = (r.currentStock || 0) * (r.priceEa || 0);
    rows.push([
      i + 1,
      r.colorStatus || 'W',
      r.partNo,
      r.partName,
      r.category    || '',
      r.equipment   || '',
      r.currentStock,
      r.minStock,
      r.totalIn,
      r.totalOut,
      r.stockStatus,
      r.priceEa     || 0,
      stockVal,
      r.unit        || 'EA',
      r.replaceCycle > 0 ? r.replaceCycle + '개월' : '',
      r.sensitivity || '하',
      ltStr,
      r.expectedAmt || 0
    ]);
  });
  var ws = XLSX.utils.aoa_to_sheet(rows);
  var wb = XLSX.utils.book_new();
  XLSX.utils.book_append_sheet(wb, ws, '재고현황');
  XLSX.writeFile(wb, '스페어파트_재고현황_' + getToday() + '.xlsx');
}

function exportHistory() {
  if (!historyCache.length) { alert('먼저 조회 버튼을 눌러 이력을 불러오세요.'); return; }
  var header = ['No','일시','구분','부품번호','품명','수량','설비','작업내용','담당자'];
  var rows = [header];
  historyCache.forEach(function(r, i) {
    rows.push([
      i + 1,
      r.createdAt   || '',
      r.type === 'IN' ? '입고' : '사용',
      r.partNo      || '',
      r.partName    || '',
      r.type === 'IN' ? r.qty : -r.qty,
      r.equipment   || '',
      r.workDesc    || '',
      r.userName    || ''
    ]);
  });
  var ws = XLSX.utils.aoa_to_sheet(rows);
  var wb = XLSX.utils.book_new();
  XLSX.utils.book_append_sheet(wb, ws, '입출고이력');
  XLSX.writeFile(wb, '스페어파트_입출고이력_' + getToday() + '.xlsx');
}

function esc(s){
  return String(s||'')
    .replace(/&/g,'&amp;').replace(/</g,'&lt;')
    .replace(/>/g,'&gt;').replace(/"/g,'&quot;');
}
</script>
</body>
</html>
