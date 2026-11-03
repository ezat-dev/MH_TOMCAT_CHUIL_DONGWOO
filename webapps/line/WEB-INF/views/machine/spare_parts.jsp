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
<link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@400;500;600;700;800&display=swap" rel="stylesheet">
<script src="/vendor/xlsx/0.18.5/xlsx.full.min.js"></script>
<style>
/* ═══════════════════════════════════════
   1. 기본 변수 & 리셋
═══════════════════════════════════════ */
:root {
  --primary:      #3B82F6;
  --primary-dark: #2563EB;
  --border:       #E5E7EB;
  --white:        #ffffff;
  --muted:        #6B7280;
  --shadow:       0 1px 3px rgba(0,0,0,.08);
  --shadow-md:    0 4px 16px rgba(0,0,0,.13);
  --bg:           #F3F4F6;
  --green:        #16A34A;
  --green-l:      #DCFCE7;
  --orange:       #EA580C;
  --red:          #DC2626;
  --red-l:        #FEE2E2;
}
*, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
body {
  font-family: 'Noto Sans KR', 'Apple SD Gothic Neo', '맑은 고딕', sans-serif;
  background: var(--bg);
  color: #111827;
  font-size: 13px;
  line-height: 1.5;
}

/* ═══════════════════════════════════════
   2. 레이아웃
═══════════════════════════════════════ */
.page-wrap {
  max-width: 1500px;
  margin: 0 auto;
  padding: 24px 20px;
}
.page-header {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  margin-bottom: 20px;
  gap: 12px;
  flex-wrap: wrap;
}
.page-title { font-size: 20px; font-weight: 800; color: #111827; }
.page-sub   { font-size: 12px; color: var(--muted); margin-top: 3px; }

/* ═══════════════════════════════════════
   3. 카드
═══════════════════════════════════════ */
.card {
  background: var(--white);
  border: 1px solid var(--border);
  border-radius: 14px;
  padding: 20px 22px;
  box-shadow: var(--shadow);
  margin-bottom: 16px;
}
.card-title { font-size: 13px; font-weight: 700; color: #111827; }

/* ═══════════════════════════════════════
   4. 버튼
═══════════════════════════════════════ */
.btn-primary {
  background: var(--primary);
  color: #fff;
  border: 1px solid var(--primary);
  padding: 8px 18px;
  border-radius: 8px;
  font-size: 13px;
  font-weight: 600;
  cursor: pointer;
  transition: background .14s, border-color .14s;
  font-family: inherit;
}
.btn-primary:hover { background: var(--primary-dark); border-color: var(--primary-dark); }
.btn-outline {
  background: #fff;
  color: #374151;
  border: 1px solid var(--border);
  padding: 8px 14px;
  border-radius: 8px;
  font-size: 13px;
  font-weight: 600;
  cursor: pointer;
  transition: border-color .14s;
  font-family: inherit;
}
.btn-outline:hover { border-color: #9CA3AF; background: #F9FAFB; }
.btn-sm { padding: 5px 12px; font-size: 12px; border-radius: 6px; }

/* ═══════════════════════════════════════
   5. 폼 요소
═══════════════════════════════════════ */
.form-field { display: flex; flex-direction: column; gap: 4px; }
.form-label { font-size: 11px; font-weight: 700; color: var(--muted); letter-spacing: .3px; }
.form-input {
  border: 1px solid var(--border);
  border-radius: 7px;
  padding: 7px 10px;
  font-size: 13px;
  font-family: inherit;
  outline: none;
  background: #fff;
  transition: border-color .14s, box-shadow .14s;
}
.form-input:focus {
  border-color: var(--primary);
  box-shadow: 0 0 0 3px rgba(59,130,246,.15);
}
.form-select {
  border: 1px solid var(--border);
  border-radius: 7px;
  padding: 7px 10px;
  font-size: 13px;
  font-family: inherit;
  outline: none;
  background: #fff;
  cursor: pointer;
  transition: border-color .14s;
}
.form-select:focus { border-color: var(--primary); }

/* ═══════════════════════════════════════
   6. 테이블
═══════════════════════════════════════ */
.table-wrap { overflow-x: auto; }
.data-table { width: 100%; border-collapse: collapse; font-size: 12px; }
.data-table th {
  background: #F9FAFB;
  border-top: 1px solid var(--border);
  border-bottom: 1px solid var(--border);
  padding: 9px 10px;
  font-size: 11px;
  font-weight: 700;
  color: var(--muted);
  text-align: left;
  white-space: nowrap;
  position: sticky;
  top: 0;
}
.data-table td {
  border-bottom: 1px solid #F3F4F6;
  padding: 8px 10px;
  vertical-align: middle;
}
.data-table tbody tr:hover { background: #F8FAFF; }

/* ═══════════════════════════════════════
   7. KPI 카드
═══════════════════════════════════════ */
.kpi-row {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 12px;
  margin-bottom: 12px;
}
@media(max-width:640px){ .kpi-row { grid-template-columns: repeat(2,1fr); } }
.kpi-card {
  background: var(--white);
  border: 1px solid var(--border);
  border-radius: 12px;
  padding: 14px 18px;
  box-shadow: var(--shadow);
  text-align: center;
}
.kpi-lbl { font-size: 11px; color: var(--muted); margin-bottom: 4px; font-weight: 600; }
.kpi-val { font-size: 28px; font-weight: 800; }

/* ═══════════════════════════════════════
   8. 색상 범례 바
═══════════════════════════════════════ */
.color-legend {
  display: flex;
  gap: 14px;
  align-items: center;
  flex-wrap: wrap;
  background: var(--white);
  border: 1px solid var(--border);
  border-radius: 10px;
  padding: 10px 18px;
  margin-bottom: 14px;
  box-shadow: var(--shadow);
}
.color-legend-item {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  font-size: 12px;
  font-weight: 600;
  cursor: pointer;
  padding: 3px 8px;
  border-radius: 6px;
  border: 1px solid transparent;
  transition: all .14s;
}
.color-legend-item:hover { background: var(--bg); }
.color-legend-item.active-filter { border-color: var(--primary); background: #EFF6FF; color: var(--primary); }
.color-dot { display: inline-block; width: 14px; height: 14px; border-radius: 50%; flex-shrink: 0; }
.dot-W { background: #fff;     border: 2px solid #aaa; }
.dot-Y { background: #FFF3CD; border: 2px solid #F5A623; }
.dot-G { background: #D4EDDA; border: 2px solid #28A745; }

/* ═══════════════════════════════════════
   9. 탭
═══════════════════════════════════════ */
.sp-tabs { display: flex; gap: 6px; margin-bottom: 16px; }
.sp-tab {
  padding: 7px 22px;
  border-radius: 8px;
  border: 1px solid var(--border);
  background: var(--white);
  font-size: 13px;
  font-weight: 600;
  cursor: pointer;
  transition: all .13s;
  color: var(--muted);
  font-family: inherit;
}
.sp-tab.active { background: var(--primary); color: #fff; border-color: var(--primary); }

/* ═══════════════════════════════════════
   10. 뱃지
═══════════════════════════════════════ */
.badge {
  display: inline-block;
  padding: 2px 9px;
  border-radius: 20px;
  font-size: 11px;
  font-weight: 700;
  white-space: nowrap;
}
.b-ok     { background: var(--green-l); color: var(--green);  border: 1px solid #86EFAC; }
.b-low    { background: #FFF7ED;        color: var(--orange); border: 1px solid #FED7AA; }
.b-none   { background: var(--red-l);   color: var(--red);    border: 1px solid #FCA5A5; }
.b-in     { background: #EFF6FF;        color: var(--primary);border: 1px solid #BFDBFE; }
.b-out    { background: var(--red-l);   color: var(--red);    border: 1px solid #FCA5A5; }
.b-muted  { background: var(--bg);     color: var(--muted);  border: 1px solid var(--border); }

/* ═══════════════════════════════════════
   11. 색상 셀 버튼
═══════════════════════════════════════ */
.color-btn {
  display: inline-flex;
  flex-direction: column;
  align-items: center;
  gap: 2px;
  cursor: pointer;
  background: none;
  border: none;
  padding: 3px 6px;
  border-radius: 6px;
  transition: background .14s;
  font-family: inherit;
}
.color-btn:hover { background: var(--bg); }
.color-btn .dot { width: 18px; height: 18px; border-radius: 50%; }
.color-btn .lbl { font-size: 9px; white-space: nowrap; font-weight: 700; }
.cb-W .dot { background: #fff;     border: 2px solid #aaa; }
.cb-W .lbl { color: #888; }
.cb-Y .dot { background: #FFF3CD; border: 2px solid #F5A623; }
.cb-Y .lbl { color: #856404; }
.cb-G .dot { background: #D4EDDA; border: 2px solid #28A745; }
.cb-G .lbl { color: #155724; }

/* ═══════════════════════════════════════
   12. 재고 바
═══════════════════════════════════════ */
.stock-bar-bg {
  display: inline-block;
  width: 60px;
  height: 6px;
  background: var(--bg);
  border-radius: 3px;
  overflow: hidden;
  vertical-align: middle;
}
.stock-bar-fill { height: 100%; border-radius: 3px; transition: width .3s; }

/* ═══════════════════════════════════════
   13. 모달
═══════════════════════════════════════ */
.modal-overlay {
  display: none;
  position: fixed;
  inset: 0;
  background: rgba(0,0,0,.45);
  z-index: 300;
  align-items: center;
  justify-content: center;
}
.modal-overlay.show { display: flex; }
.modal-box {
  background: var(--white);
  border-radius: 16px;
  padding: 28px 30px;
  width: 580px;
  max-width: 96vw;
  box-shadow: var(--shadow-md);
  max-height: 92vh;
  overflow-y: auto;
}
.modal-box.sm { width: 440px; }
.modal-title  { font-size: 15px; font-weight: 800; margin-bottom: 20px; color: #111827; }
.modal-grid   { display: grid; grid-template-columns: 1fr 1fr; gap: 12px 18px; }
.modal-grid .full { grid-column: 1 / -1; }
.modal-actions { display: flex; justify-content: flex-end; gap: 8px; margin-top: 22px; }
.modal-sep { border: none; border-top: 1px solid var(--border); margin: 16px 0; }

/* ═══════════════════════════════════════
   14. 액션 버튼 (테이블 내부)
═══════════════════════════════════════ */
.act-btns { display: flex; gap: 4px; flex-wrap: nowrap; }
.btn-xs {
  padding: 2px 8px;
  font-size: 11px;
  border-radius: 4px;
  border: 1px solid var(--border);
  background: none;
  cursor: pointer;
  font-family: inherit;
  white-space: nowrap;
  transition: all .12s;
}
.btn-xs-edit:hover { border-color: var(--primary); color: var(--primary); }
.btn-xs-del:hover  { border-color: var(--red); color: var(--red); background: var(--red-l); }
.btn-xs-in  { border-color: #BFDBFE; color: var(--primary); }
.btn-xs-in:hover  { background: #EFF6FF; }
.btn-xs-out { border-color: #FED7AA; color: var(--orange); }
.btn-xs-out:hover { background: #FFF7ED; }

/* ═══════════════════════════════════════
   15. 필터 바 / 기타
═══════════════════════════════════════ */
.ctrl-bar { display: flex; gap: 10px; flex-wrap: wrap; align-items: flex-end; margin-bottom: 14px; }
.btn-excel {
  background: #16A34A;
  color: #fff;
  border: 1px solid #15803D;
  padding: 8px 14px;
  border-radius: 8px;
  font-size: 13px;
  font-weight: 600;
  cursor: pointer;
  font-family: inherit;
  transition: background .14s;
}
.btn-excel:hover { background: #15803D; }
.btn-excel.btn-sm { padding: 5px 12px; font-size: 12px; border-radius: 6px; }

@media(max-width:640px){
  .modal-grid { grid-template-columns: 1fr; }
  .modal-grid .full { grid-column: 1; }
  .hide-m { display: none !important; }
}
</style>
</head>
<body>
<div class="page-wrap">

  <!-- 페이지 헤더 -->
  <div class="page-header">
    <div>
      <div class="page-title">스페어파트 관리</div>
      <div class="page-sub">부품 재고 · 색상 상태 · 입출고 이력 추적</div>
    </div>
    <div style="display:flex;gap:8px;flex-wrap:wrap">
      <button class="btn-outline" onclick="openInModal(null)">입고 등록</button>
      <button class="btn-outline" onclick="openOutModal(null)">사용 등록</button>
      <button class="btn-primary" onclick="openPartsModal(null)">+ 부품 등록</button>
    </div>
  </div>

  <!-- KPI 카드 -->
  <div class="kpi-row" style="grid-template-columns:repeat(5,1fr)">
    <div class="kpi-card">
      <div class="kpi-lbl">전체 품목</div>
      <div class="kpi-val" id="kTotal" style="color:var(--primary)">0</div>
    </div>
    <div class="kpi-card">
      <div class="kpi-lbl">재고없음</div>
      <div class="kpi-val" id="kNone" style="color:var(--red)">0</div>
    </div>
    <div class="kpi-card">
      <div class="kpi-lbl">재고 부족</div>
      <div class="kpi-val" id="kLow" style="color:var(--orange)">0</div>
    </div>
    <div class="kpi-card">
      <div class="kpi-lbl">정상</div>
      <div class="kpi-val" id="kOk" style="color:var(--green)">0</div>
    </div>
    <div class="kpi-card">
      <div class="kpi-lbl">총 재고금액 (원)</div>
      <div class="kpi-val" id="kValue" style="color:#7C3AED;font-size:18px">0</div>
    </div>
  </div>

  <!-- 색상 범례 / 필터 -->
  <div class="color-legend">
    <span style="font-size:11px;color:var(--muted);font-weight:700;flex-shrink:0">색상 상태</span>
    <span class="color-legend-item active-filter" id="fl-all" onclick="filterByColor('')">
      전체 <span id="cntAll" style="font-weight:400;color:var(--muted)"></span>
    </span>
    <span class="color-legend-item" id="fl-W" onclick="filterByColor('W')">
      <span class="color-dot dot-W"></span>
      W — 재고확보
      <span id="cntW" style="font-weight:400;color:#888"></span>
    </span>
    <span class="color-legend-item" id="fl-Y" onclick="filterByColor('Y')">
      <span class="color-dot dot-Y"></span>
      <span style="color:#856404">Y — Critical List</span>
      <span id="cntY" style="font-weight:400;color:#856404"></span>
    </span>
    <span class="color-legend-item" id="fl-G" onclick="filterByColor('G')">
      <span class="color-dot dot-G"></span>
      <span style="color:#155724">G — 구매진행중</span>
      <span id="cntG" style="font-weight:400;color:#155724"></span>
    </span>
    <span style="margin-left:auto;font-size:10px;color:var(--muted)">색상 셀 클릭 시 변경</span>
  </div>

  <!-- 탭 -->
  <div class="sp-tabs">
    <button class="sp-tab active" onclick="showTab('stock',this)">재고 현황</button>
    <button class="sp-tab"        onclick="showTab('history',this)">입출고 이력</button>
  </div>

  <!-- ══ 탭1: 재고 현황 ══ -->
  <div id="tab-stock">
    <div class="card">
      <div style="display:flex;align-items:center;gap:10px;margin-bottom:16px;flex-wrap:wrap">
        <div class="card-title">부품 목록</div>
        <div style="margin-left:auto;display:flex;gap:8px;flex-wrap:wrap">
          <select class="form-select" id="fCategory" style="width:120px" onchange="loadParts()">
            <option value="">전체 구분</option>
          </select>
          <input class="form-input" type="text" id="fKeyword" placeholder="품명·부품번호" style="width:160px"
                 onkeydown="if(event.key==='Enter') loadParts()">
          <button class="btn-primary btn-sm" onclick="loadParts()">조회</button>
          <button class="btn-excel btn-sm" onclick="exportParts()">엑셀 출력</button>
        </div>
      </div>
      <div class="table-wrap">
        <table class="data-table">
          <thead>
            <tr>
              <th style="width:36px;text-align:center">No</th>
              <th style="width:60px;text-align:center">색상</th>
              <th>부품번호</th>
              <th>품명</th>
              <th>구분</th>
              <th class="hide-m">적용 설비</th>
              <th style="text-align:center">현재재고</th>
              <th style="text-align:center" class="hide-m">최소재고</th>
              <th class="hide-m" style="width:80px">재고현황</th>
              <th style="text-align:center">총입고</th>
              <th style="text-align:center">총사용</th>
              <th style="text-align:center">상태</th>
              <th class="hide-m" style="text-align:right">단가(원)</th>
              <th class="hide-m" style="text-align:right">재고금액(원)</th>
              <th class="hide-m">단위</th>
              <th class="hide-m">교체주기</th>
              <th class="hide-m" style="text-align:center">민감도</th>
              <th class="hide-m" style="text-align:center">리드타임</th>
              <th class="hide-m" style="text-align:right">예상금액(원)</th>
              <th>관리</th>
            </tr>
          </thead>
          <tbody id="partsBody">
            <tr><td colspan="20" style="text-align:center;padding:48px;color:var(--muted)">로딩 중…</td></tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>

  <!-- ══ 탭2: 입출고 이력 ══ -->
  <div id="tab-history" style="display:none">
    <div class="card">
      <div class="ctrl-bar">
        <div class="form-field">
          <label class="form-label">구분</label>
          <select class="form-select" id="hType" style="width:90px">
            <option value="">전체</option>
            <option value="IN">입고</option>
            <option value="OUT">사용</option>
          </select>
        </div>
        <div class="form-field">
          <label class="form-label">시작일</label>
          <input class="form-input" type="date" id="hFrom" style="width:140px">
        </div>
        <div class="form-field">
          <label class="form-label">종료일</label>
          <input class="form-input" type="date" id="hTo" style="width:140px">
        </div>
        <button class="btn-primary btn-sm" style="margin-top:18px;height:34px" onclick="loadHistory()">조회</button>
        <button class="btn-excel btn-sm"  style="margin-top:18px;height:34px" onclick="exportHistory()">엑셀 출력</button>
        <span id="historyCount" style="margin-top:18px;font-size:11px;color:var(--muted)"></span>
      </div>
      <div class="table-wrap">
        <table class="data-table">
          <thead>
            <tr>
              <th style="text-align:center">No</th>
              <th>일시</th>
              <th style="text-align:center">구분</th>
              <th>부품번호</th>
              <th>품명</th>
              <th style="text-align:center">수량</th>
              <th class="hide-m">설비</th>
              <th>작업내용</th>
              <th class="hide-m">담당자</th>
              <th>관리</th>
            </tr>
          </thead>
          <tbody id="historyBody">
            <tr><td colspan="10" style="text-align:center;padding:48px;color:var(--muted)">조회 버튼을 눌러 이력을 확인하세요</td></tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>

</div><!-- /page-wrap -->

<!-- ══ 부품 마스터 등록/수정 모달 ══ -->
<div class="modal-overlay" id="partsModal">
  <div class="modal-box">
    <div class="modal-title">🔩 <span id="partsModalTitle">부품 등록</span></div>
    <div class="modal-grid">
      <div class="form-field">
        <label class="form-label">부품번호 *</label>
        <input class="form-input" type="text" id="mPartNo" placeholder="예) HT-001">
      </div>
      <div class="form-field">
        <label class="form-label">품명 *</label>
        <input class="form-input" type="text" id="mPartName" placeholder="예) 히터 엘리먼트 3kW">
      </div>
      <div class="form-field">
        <label class="form-label">구분</label>
        <input class="form-input" type="text" id="mCategory" placeholder="예) 히터, 열전대, 밸브" list="categoryDataList">
        <datalist id="categoryDataList"></datalist>
      </div>
      <div class="form-field">
        <label class="form-label">단위</label>
        <input class="form-input" type="text" id="mUnit" value="EA">
      </div>
      <div class="form-field full">
        <label class="form-label">적용 설비</label>
        <input class="form-input" type="text" id="mEquipment" placeholder="예) 열처리로 전계열">
      </div>
      <div class="form-field">
        <label class="form-label">최소재고 (EA)</label>
        <input class="form-input" type="number" id="mMinStock" value="1" min="0">
      </div>
      <div class="form-field">
        <label class="form-label">교체주기 (개월, 0=없음)</label>
        <input class="form-input" type="number" id="mReplaceCycle" value="0" min="0">
      </div>
      <div class="form-field">
        <label class="form-label">예상단가 (원/EA)</label>
        <input class="form-input" type="number" id="mPriceEa" value="0" min="0" placeholder="0">
      </div>
      <div class="form-field">
        <label class="form-label">제조사</label>
        <input class="form-input" type="text" id="mMaker">
      </div>
      <div class="form-field">
        <label class="form-label">민감도</label>
        <select class="form-select" id="mSensitivity">
          <option value="하">하</option>
          <option value="중">중</option>
          <option value="상">상</option>
        </select>
      </div>
      <div class="form-field">
        <label class="form-label">리드타임</label>
        <div style="display:flex;gap:6px">
          <input class="form-input" type="number" id="mLeadTimeVal" min="0" value="0" style="flex:1;min-width:0">
          <select class="form-select" id="mLeadTimeUnit" style="width:65px">
            <option value="일">일</option>
            <option value="주">주</option>
          </select>
        </div>
      </div>
      <div class="form-field">
        <label class="form-label">예상금액 (원)</label>
        <input class="form-input" type="number" id="mExpectedAmt" value="0" min="0" placeholder="0">
      </div>
      <div class="form-field">
        <label class="form-label">사양/모델</label>
        <input class="form-input" type="text" id="mSpecModel">
      </div>
      <div class="form-field">
        <label class="form-label">색상 상태</label>
        <select class="form-select" id="mColorStatus">
          <option value="W">W — 재고확보</option>
          <option value="Y">Y — Critical List</option>
          <option value="G">G — 구매진행중</option>
        </select>
      </div>
      <div class="form-field">
        <label class="form-label">고객제공</label>
        <select class="form-select" id="mCustomerYn">
          <option value="N">N</option>
          <option value="Y">Y</option>
        </select>
      </div>
      <div class="form-field full">
        <label class="form-label">비고</label>
        <input class="form-input" type="text" id="mRemark">
      </div>
    </div>
    <div class="modal-actions">
      <button class="btn-outline" onclick="closePartsModal()">취소</button>
      <button class="btn-primary" onclick="savePartsModal()">저장</button>
    </div>
  </div>
</div>

<!-- ══ 입고 모달 ══ -->
<div class="modal-overlay" id="inModal">
  <div class="modal-box sm">
    <div class="modal-title">📦 입고 등록</div>
    <div style="display:flex;flex-direction:column;gap:14px">
      <div class="form-field">
        <label class="form-label">부품 *</label>
        <select class="form-select" id="inPartNo" style="width:100%"></select>
      </div>
      <div class="form-field">
        <label class="form-label">입고 수량 *</label>
        <input class="form-input" type="number" id="inQty" min="1" value="1">
      </div>
      <div class="form-field">
        <label class="form-label">작업내용</label>
        <input class="form-input" type="text" id="inWorkDesc" placeholder="예) 신규 입고, 정기 발주">
      </div>
      <div class="form-field">
        <label class="form-label">담당자</label>
        <input class="form-input" type="text" id="inUserName" placeholder="성명">
      </div>
    </div>
    <div class="modal-actions">
      <button class="btn-outline" onclick="closeInModal()">취소</button>
      <button class="btn-primary" onclick="saveInModal()">저장</button>
    </div>
  </div>
</div>

<!-- ══ 사용(OUT) 모달 ══ -->
<div class="modal-overlay" id="outModal">
  <div class="modal-box sm">
    <div class="modal-title">🔧 사용 등록</div>
    <div style="display:flex;flex-direction:column;gap:14px">
      <div class="form-field">
        <label class="form-label">부품 *</label>
        <select class="form-select" id="outPartNo" style="width:100%"></select>
      </div>
      <div class="form-field">
        <label class="form-label">사용 수량 *</label>
        <input class="form-input" type="number" id="outQty" min="1" value="1">
      </div>
      <div class="form-field">
        <label class="form-label">사용 설비</label>
        <input class="form-input" type="text" id="outEquipment" placeholder="예) 열처리로 1호기">
      </div>
      <div class="form-field">
        <label class="form-label">작업내용</label>
        <input class="form-input" type="text" id="outWorkDesc" placeholder="예) 히터 교체, 정기 교환">
      </div>
      <div class="form-field">
        <label class="form-label">담당자</label>
        <input class="form-input" type="text" id="outUserName" placeholder="성명">
      </div>
    </div>
    <div class="modal-actions">
      <button class="btn-outline" onclick="closeOutModal()">취소</button>
      <button class="btn-primary" onclick="saveOutModal()"
              style="background:var(--orange);border-color:var(--orange)">사용 처리</button>
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

    var barColor, badgeCls;
    if      (st === '재고없음') { barColor='var(--red)';    badgeCls='b-none'; none++; }
    else if (st === '부족')     { barColor='var(--orange)'; badgeCls='b-low';  low++;  }
    else                        { barColor='var(--green)';  badgeCls='b-ok';   ok++;   }
    var sensCls = r.sensitivity === '상' ? 'b-none' : r.sensitivity === '중' ? 'b-low' : 'b-muted';
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
      + '<td style="text-align:center;color:var(--muted)">' + (i+1) + '</td>'
      + '<td style="text-align:center">' + colorCell + '</td>'
      + '<td style="font-family:monospace;font-size:12px">' + esc(r.partNo) + '</td>'
      + '<td style="font-weight:600">' + esc(r.partName) + '</td>'
      + '<td><span class="badge b-muted">' + esc(r.category||'—') + '</span></td>'
      + '<td class="hide-m" style="color:var(--muted)">' + esc(r.equipment||'—') + '</td>'
      + '<td style="text-align:center;font-weight:700;font-size:15px;color:' + barColor + '">' + cur + '</td>'
      + '<td style="text-align:center;color:var(--muted)" class="hide-m">' + r.minStock + '</td>'
      + '<td class="hide-m"><span class="stock-bar-bg">'
        + '<span class="stock-bar-fill" style="width:' + pct + '%;background:' + barColor + '"></span>'
        + '</span></td>'
      + '<td style="text-align:center;color:var(--primary)">' + r.totalIn + '</td>'
      + '<td style="text-align:center;color:var(--orange)">'  + r.totalOut + '</td>'
      + '<td style="text-align:center"><span class="badge ' + badgeCls + '">' + st + '</span></td>'
      + '<td class="hide-m" style="text-align:right;color:var(--muted)">'
        + (price > 0 ? comma(price) : '—') + '</td>'
      + '<td class="hide-m" style="text-align:right;font-weight:600;color:' + (stockVal > 0 ? '#7C3AED' : 'var(--muted)') + '">'
        + (stockVal > 0 ? comma(stockVal) : '—') + '</td>'
      + '<td class="hide-m" style="color:var(--muted)">' + esc(r.unit||'EA') + '</td>'
      + '<td class="hide-m" style="color:var(--muted)">' + cycle + '</td>'
      + '<td class="hide-m" style="text-align:center"><span class="badge ' + sensCls + '">' + esc(r.sensitivity||'하') + '</span></td>'
      + '<td class="hide-m" style="text-align:center;color:var(--muted)">' + ltStr + '</td>'
      + '<td class="hide-m" style="text-align:right;font-weight:600;color:' + (expAmt > 0 ? '#7C3AED' : 'var(--muted)') + '">' + (expAmt > 0 ? comma(expAmt) : '—') + '</td>'
      + '<td>' + actHtml + '</td>'
      + '</tr>';
  });

  document.getElementById('partsBody').innerHTML = html ||
    '<tr><td colspan="20" style="text-align:center;padding:48px;color:var(--muted)">'
    + '등록된 부품이 없습니다. 우상단 <strong>+ 부품 등록</strong>을 눌러 추가하세요.</td></tr>';

  document.getElementById('kTotal').textContent = list.length;
  document.getElementById('kNone').textContent  = none;
  document.getElementById('kLow').textContent   = low;
  document.getElementById('kOk').textContent    = ok;
  document.getElementById('kValue').textContent = comma(totalValue);
  document.getElementById('cntAll').textContent = '(' + list.length + ')';
  document.getElementById('cntW').textContent   = '(' + cW + ')';
  document.getElementById('cntY').textContent   = '(' + cY + ')';
  document.getElementById('cntG').textContent   = '(' + cG + ')';
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
      '<tr><td colspan="10" style="text-align:center;padding:48px;color:var(--muted)">이력이 없습니다.</td></tr>';
    return;
  }
  var html = '';
  list.forEach(function(r, i){
    var typeBadge = r.type === 'IN'
      ? '<span class="badge b-in">입고</span>'
      : '<span class="badge b-out">사용</span>';
    var qtyStr = r.type === 'IN'
      ? '<span style="color:var(--primary);font-weight:700">+' + r.qty + '</span>'
      : '<span style="color:var(--red);font-weight:700">-'     + r.qty + '</span>';
    html += '<tr>'
      + '<td style="text-align:center;color:var(--muted)">' + (i+1) + '</td>'
      + '<td style="font-size:12px">'           + esc(r.createdAt||'') + '</td>'
      + '<td style="text-align:center">'        + typeBadge             + '</td>'
      + '<td style="font-family:monospace;font-size:12px">' + esc(r.partNo||'')   + '</td>'
      + '<td style="font-weight:600">'          + esc(r.partName||'')  + '</td>'
      + '<td style="text-align:center">'        + qtyStr                + '</td>'
      + '<td class="hide-m">'                   + esc(r.equipment||'—')+ '</td>'
      + '<td>'                                  + esc(r.workDesc||'—') + '</td>'
      + '<td class="hide-m">'                   + esc(r.userName||'—') + '</td>'
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
