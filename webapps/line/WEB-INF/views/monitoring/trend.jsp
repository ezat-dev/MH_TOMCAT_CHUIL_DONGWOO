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
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@400;500;600;700;800&family=JetBrains+Mono:wght@400;600&display=swap" rel="stylesheet">

<style>
/* ===================== CSS 변수 (라이트 테마 기본) ===================== */
:root {
  --bg:           #f0f2f7;
  --surface:      #ffffff;
  --surface2:     #f7f8fc;
  --border:       #e2e6ef;
  --text-p:       #0f172a;
  --text-s:       #64748b;
  --text-m:       #94a3b8;
  --accent:       #3b82f6;
  --shadow-sm:    0 1px 3px rgba(0,0,0,.06);
  --shadow-md:    0 4px 16px rgba(0,0,0,.08);
  --radius:       12px;
  --topbar-h:     56px;
  --chart-bg:     #ffffff;
  --chart-grid:   #f0f2f7;
  --chart-text:   #374151;
}

[data-theme="dark"] {
  --bg:           #0d1117;
  --surface:      #161b22;
  --surface2:     #1c2230;
  --border:       #30363d;
  --text-p:       #e6edf3;
  --text-s:       #8b949e;
  --text-m:       #484f58;
  --accent:       #58a6ff;
  --shadow-sm:    0 1px 3px rgba(0,0,0,.3);
  --shadow-md:    0 4px 16px rgba(0,0,0,.4);
  --chart-bg:     #161b22;
  --chart-grid:   #21262d;
  --chart-text:   #8b949e;
}

* { box-sizing: border-box; margin: 0; padding: 0; }
body { font-family: 'Noto Sans KR', sans-serif; background: var(--bg); color: var(--text-p); transition: background .25s, color .25s; }

/* ===================== TOPBAR ===================== */
.topbar {
  position: sticky; top: 0; z-index: 200;
  background: var(--surface);
  border-bottom: 1px solid var(--border);
  box-shadow: var(--shadow-sm);
  backdrop-filter: blur(10px);
}
.topbar-inner {
  max-width: 1600px; margin: 0 auto;
  padding: 0 20px;
  height: var(--topbar-h);
  display: flex; align-items: center; gap: 10px; flex-wrap: wrap;
}
.topbar-title {
  font-size: 14px; font-weight: 800; color: var(--text-p);
  letter-spacing: -.3px; white-space: nowrap; margin-right: 6px;
}
.divider { width: 1px; height: 20px; background: var(--border); flex-shrink: 0; }
.label { font-size: 12px; font-weight: 700; color: var(--text-s); white-space: nowrap; }
.tilde { color: var(--text-m); font-weight: 800; padding: 0 4px; }
.ctrl {
  height: 32px; padding: 0 10px;
  border: 1px solid var(--border); border-radius: 8px;
  background: var(--surface2); color: var(--text-p);
  font-size: 13px; font-family: 'Noto Sans KR', sans-serif;
  outline: none; transition: border-color .15s, box-shadow .15s; min-width: 160px;
}
.ctrl:focus { border-color: var(--accent); box-shadow: 0 0 0 3px rgba(59,130,246,.15); }

/* 버튼 */
.btn {
  height: 32px; padding: 0 13px; border-radius: 8px;
  font-size: 12px; font-family: 'Noto Sans KR', sans-serif; font-weight: 700;
  display: inline-flex; align-items: center; gap: 5px;
  cursor: pointer; transition: filter .15s, transform .08s; white-space: nowrap;
  border: 1px solid transparent;
}
.btn:active { transform: translateY(1px); }
.btn svg { width: 13px; height: 13px; flex-shrink: 0; }

.btn-search  { background: linear-gradient(135deg,#64748b,#475569); color:#fff; border-color:#475569; box-shadow:0 2px 6px rgba(71,85,105,.3); }
.btn-insert  { background: linear-gradient(135deg,#2563eb,#1d4ed8); color:#fff; border-color:#1d4ed8; }
.btn-excel   { background: linear-gradient(135deg,#16a34a,#15803d); color:#fff; border-color:#15803d; }
.btn-print   { background: var(--surface2); color: var(--text-p); border-color: var(--border); }
.btn-theme   { background: var(--surface2); color: var(--text-p); border-color: var(--border); min-width:32px; padding:0 8px; }
.btn:hover   { filter: brightness(1.08); }

/* ===================== 페이지 레이아웃 ===================== */
.page-wrap {
  max-width: 1600px; margin: 0 auto;
  padding: 16px 20px 24px;
  display: flex; flex-direction: column; gap: 12px;
}

/* ===================== 컨트롤 패널 (그룹 토글 + 차트 타입) ===================== */
.control-panel {
  background: var(--surface);
  border: 1px solid var(--border);
  border-radius: var(--radius);
  padding: 12px 16px;
  display: flex; align-items: center; gap: 14px; flex-wrap: wrap;
  box-shadow: var(--shadow-sm);
}
.ctrl-section { display: flex; align-items: center; gap: 8px; }
.ctrl-section-label {
  font-size: 11px; font-weight: 700; color: var(--text-m);
  text-transform: uppercase; letter-spacing: .6px; white-space: nowrap;
}
.ctrl-divider { width: 1px; height: 22px; background: var(--border); }

/* 그룹 토글 칩 */
.group-chip {
  height: 26px; padding: 0 11px; border-radius: 20px;
  font-size: 11px; font-weight: 700;
  border: 1.5px solid; cursor: pointer;
  transition: all .15s; display: inline-flex; align-items: center; gap: 4px;
  user-select: none;
}
.group-chip.active  { color: #fff; }
.group-chip.inactive { background: transparent !important; opacity: .5; }

.chip-quench  { border-color: #f59e0b; color: #f59e0b; }
.chip-quench.active  { background: #f59e0b; color: #fff; }
.chip-temper  { border-color: #ef4444; color: #ef4444; }
.chip-temper.active  { background: #ef4444; color: #fff; }
.chip-cp      { border-color: #8b5cf6; color: #8b5cf6; }
.chip-cp.active      { background: #8b5cf6; color: #fff; }
.chip-wash    { border-color: #06b6d4; color: #06b6d4; }
.chip-wash.active    { background: #06b6d4; color: #fff; }
.chip-all     { border-color: #64748b; color: #64748b; }
.chip-all.active     { background: #64748b; color: #fff; }

/* 차트 타입 버튼 */
.type-btn {
  height: 26px; width: 32px;
  border-radius: 7px; border: 1.5px solid var(--border);
  background: var(--surface2); color: var(--text-s);
  cursor: pointer; display: inline-flex; align-items: center; justify-content: center;
  font-size: 14px; transition: all .15s;
}
.type-btn.active, .type-btn:hover { border-color: var(--accent); color: var(--accent); background: rgba(59,130,246,.1); }


/* ===================== 통계 바 ===================== */
.stats-bar {
  background: var(--surface);
  border: 1px solid var(--border);
  border-radius: var(--radius);
  padding: 10px 16px;
  display: flex; align-items: center; gap: 6px; flex-wrap: wrap;
  box-shadow: var(--shadow-sm);
}
.stats-item {
  display: flex; align-items: center; gap: 6px;
  padding: 4px 10px; border-radius: 8px;
  background: var(--surface2); border: 1px solid var(--border);
  font-size: 12px;
}
.stats-item .s-label { color: var(--text-s); font-weight: 600; }
.stats-item .s-val   { font-family: 'JetBrains Mono', monospace; font-weight: 700; color: var(--text-p); }
.stats-dot { width: 7px; height: 7px; border-radius: 50%; flex-shrink: 0; }
.stats-bar-title { font-size: 11px; font-weight: 800; color: var(--text-m); text-transform: uppercase; letter-spacing: .5px; }

/* ===================== 메인 차트 영역 ===================== */
.chart-wrap {
  background: var(--surface);
  border: 1px solid var(--border);
  border-radius: var(--radius);
  box-shadow: var(--shadow-sm);
  overflow: hidden;
}

.chart-toolbar {
  padding: 12px 16px 0;
  display: flex; align-items: center; justify-content: space-between; gap: 10px;
}
.chart-title {
  font-size: 14px; font-weight: 800; color: var(--text-p); letter-spacing: -.2px;
}
.chart-meta { font-size: 12px; color: var(--text-m); font-family: 'JetBrains Mono', monospace; }

#container { width: 100%; height: calc(100vh - 250px); min-height: 520px; }

/* ===================== 구간 통계 팝업 ===================== */
.range-popup {
  display: none;
  position: fixed; z-index: 9999;
  background: var(--surface);
  border: 1px solid var(--border);
  border-radius: 12px;
  padding: 14px 16px;
  box-shadow: var(--shadow-md);
  min-width: 260px;
  pointer-events: none;
}
.range-popup.show { display: block; }
.range-popup-title {
  font-size: 12px; font-weight: 800; color: var(--text-p);
  margin-bottom: 8px; padding-bottom: 6px;
  border-bottom: 1px solid var(--border);
}
.range-stat-row {
  display: flex; justify-content: space-between;
  font-size: 12px; padding: 3px 0;
}
.range-stat-row .rk { color: var(--text-s); font-weight: 600; }
.range-stat-row .rv {
  font-family: 'JetBrains Mono', monospace;
  font-weight: 700; color: var(--text-p);
}

/* ===================== 현재값 사이드 패널 ===================== */
.live-panel {
  background: var(--surface);
  border: 1px solid var(--border);
  border-radius: var(--radius);
  box-shadow: var(--shadow-sm);
  overflow: hidden;
}
.live-panel-header {
  padding: 10px 14px;
  border-bottom: 1px solid var(--border);
  font-size: 12px; font-weight: 800; color: var(--text-p);
  display: flex; align-items: center; justify-content: space-between;
}
.live-time {
  font-size: 11px; font-family: 'JetBrains Mono', monospace;
  color: var(--text-m); font-weight: 400;
}
.live-grid {
  display: grid; grid-template-columns: 1fr 1fr;
  gap: 1px; background: var(--border);
  max-height: 320px; overflow-y: auto;
}
.live-item {
  background: var(--surface);
  padding: 8px 12px;
  display: flex; align-items: center; justify-content: space-between; gap: 8px;
}
.live-item-name {
  font-size: 11px; font-weight: 600; color: var(--text-s); white-space: nowrap;
  display: flex; align-items: center; gap: 5px;
}
.live-item-val {
  font-size: 13px; font-weight: 800;
  font-family: 'JetBrains Mono', monospace;
  color: var(--text-p); text-align: right;
}
.live-item-val.warn  { color: #f59e0b; }
.live-item-val.alarm { color: #ef4444; }

/* ===================== MODAL ===================== */
.modal {
  display: none; position: fixed; inset: 0;
  background: rgba(0,0,0,.45); z-index: 20010;
  backdrop-filter: blur(4px);
  align-items: center; justify-content: center;
}
.modal.show { display: flex; }
.modal-content {
  background: var(--surface);
  width: 520px; max-width: 95vw; max-height: 90vh;
  border-radius: 16px; overflow-y: auto;
  padding: 24px; position: relative;
  box-shadow: 0 20px 60px rgba(0,0,0,.25);
  border: 1px solid var(--border);
  animation: modalIn .2s ease;
}
@keyframes modalIn { from{opacity:0;transform:scale(.95) translateY(10px)} to{opacity:1;transform:none} }
.modal-title { font-size: 16px; font-weight: 800; color: var(--text-p); margin-bottom: 14px; }
.modal-content hr { border: none; border-top: 1px solid var(--border); margin: 12px 0; }
.close-btn {
  position: absolute; right: 16px; top: 16px;
  width: 28px; height: 28px; border-radius: 8px;
  background: var(--surface2); border: 1px solid var(--border);
  cursor: pointer; display: flex; align-items: center; justify-content: center;
  font-size: 16px; color: var(--text-s); transition: background .15s;
}
.close-btn:hover { background: var(--border); }
.form-group { margin-bottom: 12px; }
.form-label { font-size: 12px; font-weight: 700; color: var(--text-s); margin-bottom: 5px; display: block; }
.form-input {
  width: 100%; height: 34px; padding: 0 10px;
  border: 1px solid var(--border); border-radius: 8px;
  background: var(--surface2); color: var(--text-p);
  font-size: 13px; font-family: 'Noto Sans KR', sans-serif; outline: none;
  transition: border-color .15s;
}
.form-input:focus { border-color: var(--accent); }
.btn-save { background: linear-gradient(135deg,#2563eb,#1d4ed8); color:#fff; border-color:#1d4ed8; }
.btn-close-modal { background: var(--surface2); color: var(--text-p); border-color: var(--border); }

/* ===================== 엑셀 로딩 ===================== */
#excelOverlay { display:none; position:fixed; inset:0; background:rgba(0,0,0,.5); z-index:9998; }
#excelLoading {
  display:none; position:fixed; top:50%; left:50%; transform:translate(-50%,-50%);
  background:var(--surface); padding:24px 40px; border-radius:12px;
  box-shadow:var(--shadow-md); z-index:9999; font-size:14px; font-weight:700; text-align:center;
  border:1px solid var(--border);
}

/* ===================== 스크롤바 ===================== */
::-webkit-scrollbar { width: 5px; height: 5px; }
::-webkit-scrollbar-track { background: transparent; }
::-webkit-scrollbar-thumb { background: var(--border); border-radius: 3px; }

/* ===================== 반응형 ===================== */
@media (max-width: 1200px) {
  .main-grid { grid-template-columns: 1fr !important; }
  .live-panel { display: none; }
}
</style>
</head>
<body>

<!-- ===================== 로딩 오버레이 ===================== -->
<div id="excelOverlay"></div>
<div id="excelLoading">📊 엑셀 생성 중...</div>

<!-- ===================== 구간 통계 팝업 ===================== -->
<div class="range-popup" id="rangePopup">
  <div class="range-popup-title" id="rangeTitle">선택 구간 통계</div>
  <div id="rangeStats"></div>
</div>

<!-- ===================== 등록 모달 ===================== -->
<div id="modalContainer" class="modal">
  <div class="modal-content">
    <button class="close-btn" id="closeModalBtn">&times;</button>
    <div class="modal-title">트렌드 데이터 등록</div>
    <hr/>
    <div id="signDataTable"></div>
    <hr/>
    <form id="corrForm" autocomplete="off">
      <input type="hidden" name="tc_cnt" value="0">
      <input type="hidden" name="tc_user_code">
      <div class="form-group">
        <label class="form-label">작업자</label>
        <input type="text" name="tc_user_name" class="form-input" readonly>
      </div>
      <div class="form-group">
        <label class="form-label">등록시간</label>
        <input type="text" name="tc_regtime" class="form-input">
      </div>
      <div class="form-group">
        <label class="form-label">등록내용</label>
        <input type="text" name="tc_name" class="form-input">
      </div>
      <div class="form-group">
        <label class="form-label">비고</label>
        <input type="text" name="tc_desc" class="form-input">
      </div>
      <hr/>
      <div style="display:flex; gap:8px; margin-top:4px;">
        <button type="submit" id="saveCorrStatus" class="btn btn-save" style="flex:1; height:36px; border-radius:8px; font-size:13px; font-family:'Noto Sans KR',sans-serif;">저장</button>
        <button type="button" id="closeModal" class="btn btn-close-modal" style="flex:1; height:36px; border-radius:8px; font-size:13px; font-family:'Noto Sans KR',sans-serif;">닫기</button>
      </div>
    </form>
  </div>
</div>

<!-- ===================== TOPBAR ===================== -->
<div class="topbar">
  <div class="topbar-inner">
    <span class="topbar-title">📈 온도 트렌드 분석</span>
    <div class="divider"></div>
    <span class="label">검색 날짜</span>
    <input type="text" autocomplete="off" class="datetimeSet ctrl" id="startDate">
    <span class="tilde">~</span>
    <input type="text" autocomplete="off" class="datetimeSet ctrl" id="endDate">
    <div class="divider"></div>
    <button class="btn btn-search select-button">
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>조회
    </button>
    <button class="btn btn-insert insert-button">
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>추가
    </button>
    <button class="btn btn-print" id="printBtn">
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 6 2 18 2 18 9"/><path d="M6 18H4a2 2 0 0 1-2-2v-5a2 2 0 0 1 2-2h16a2 2 0 0 1 2 2v5a2 2 0 0 1-2 2h-2"/><rect x="6" y="14" width="12" height="8"/></svg>인쇄
    </button>
    <button class="btn btn-excel excel-button">
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/></svg>Download
    </button>
    <div class="divider"></div>
    <button class="btn btn-theme" id="themeToggle" title="테마 전환"></button>
  </div>
</div>

<!-- ===================== PAGE ===================== -->
<div class="page-wrap">

  <!-- 컨트롤 패널 -->
  <div class="control-panel">
    <div class="ctrl-section">
      <span class="ctrl-section-label">그룹</span>
      <button class="group-chip chip-all active"    id="chip-all"    onclick="toggleGroup('all')">전체</button>
      <button class="group-chip chip-quench active" id="chip-quench" onclick="toggleGroup('quench')">소입로</button>
      <button class="group-chip chip-temper active" id="chip-temper" onclick="toggleGroup('temper')">소려로</button>
      <button class="group-chip chip-cp active"     id="chip-cp"     onclick="toggleGroup('cp')">CP</button>
      <button class="group-chip chip-wash active"   id="chip-wash"   onclick="toggleGroup('wash')">세정/기타</button>
    </div>
    <div class="ctrl-divider"></div>
    <div class="ctrl-section">
      <span class="ctrl-section-label">타입</span>
      <button class="type-btn active" data-type="line"   onclick="setChartType('line')"   title="라인">〜</button>
      <button class="type-btn"        data-type="spline" onclick="setChartType('spline')" title="스플라인">∿</button>
      <button class="type-btn"        data-type="area"   onclick="setChartType('area')"   title="영역">▲</button>
    </div>
    <div class="ctrl-divider"></div>
    <div class="ctrl-section" style="gap:12px; flex-wrap:wrap;">
      <span class="ctrl-section-label">조작</span>
      <button class="group-chip chip-all active" style="font-size:10px;" onclick="chart && chart.zoomOut()">🔍 전체 보기</button>
      <div style="display:flex; gap:14px; flex-wrap:wrap; align-items:center;">
        <span style="font-size:11px; color:var(--text-s); display:flex; align-items:center; gap:4px;">
          <span style="background:#e2e6ef; border-radius:4px; padding:1px 6px; font-size:10px; font-weight:700; color:var(--text-p); font-family:'JetBrains Mono',monospace;">드래그</span>
          구간 줌
        </span>
        <span style="font-size:11px; color:var(--text-s); display:flex; align-items:center; gap:4px;">
          <span style="background:#e2e6ef; border-radius:4px; padding:1px 6px; font-size:10px; font-weight:700; color:var(--text-p); font-family:'JetBrains Mono',monospace;">Shift + 드래그</span>
          좌우 이동
        </span>
        <span style="font-size:11px; color:var(--text-s); display:flex; align-items:center; gap:4px;">
          <span style="background:#e2e6ef; border-radius:4px; padding:1px 6px; font-size:10px; font-weight:700; color:var(--text-p); font-family:'JetBrains Mono',monospace;">Alt + 드래그</span>
          구간 통계
        </span>
      </div>
    </div>
  </div>

  <!-- 통계 바 -->
  <div class="stats-bar" id="statsBar">
    <span class="stats-bar-title">커서 통계</span>
    <div class="stats-item"><div class="stats-dot" style="background:#f59e0b"></div><span class="s-label">소입로 평균</span><span class="s-val" id="stat-quench">--</span></div>
    <div class="stats-item"><div class="stats-dot" style="background:#ef4444"></div><span class="s-label">소려로 평균</span><span class="s-val" id="stat-temper">--</span></div>
    <div class="stats-item"><div class="stats-dot" style="background:#06b6d4"></div><span class="s-label">세정 평균</span><span class="s-val" id="stat-wash">--</span></div>
    <div class="stats-item"><div class="stats-dot" style="background:#8b5cf6"></div><span class="s-label">CP-A</span><span class="s-val" id="stat-cp-a">--</span></div>
    <div class="stats-item"><div class="stats-dot" style="background:#a855f7"></div><span class="s-label">CP-B</span><span class="s-val" id="stat-cp-b">--</span></div>
    <div style="margin-left:auto; display:flex; align-items:center; gap:6px;">
      <div class="stats-item" style="border-color:#3b82f6;">
        <span class="s-label">데이터 포인트</span>
        <span class="s-val" id="stat-count">--</span>
      </div>
      <div class="stats-item">
        <span class="s-label">범위</span>
        <span class="s-val" id="stat-range">--</span>
      </div>
    </div>
  </div>

  <!-- 메인 그리드: 차트 + 사이드 -->
  <div class="main-grid" style="display:grid; grid-template-columns:1fr; gap:12px; align-items:start;">

    <!-- 차트 카드 -->
    <div class="chart-wrap">
      <div class="chart-toolbar">
        <div>
          <div class="chart-title">열처리 연속로 온도 트렌드</div>
        </div>
        <div class="chart-meta" id="chartMeta">-</div>
      </div>
      <div id="container"></div>
    </div>

    <!-- 현재값 사이드 패널 -->
    <div class="live-panel" style="display:none">
      <div class="live-panel-header">
        📡 실시간 커서 값
        <span class="live-time" id="liveTime">-</span>
      </div>
      <div id="liveGrid" style="overflow-y:auto; max-height:560px;">
        <div style="padding:24px 16px; text-align:center; color:var(--text-m); font-size:12px;">차트에서 포인트를 선택하세요</div>
      </div>
    </div>

  </div>
</div>

<!-- ===================== 구간 통계 모달 ===================== -->
<div id="rangeStatsModal" style="display:none; position:fixed; inset:0; background:rgba(0,0,0,.45); z-index:20020; align-items:center; justify-content:center; backdrop-filter:blur(4px);">
  <div style="background:var(--surface); border:1px solid var(--border); border-radius:16px; padding:24px; min-width:380px; max-width:95vw; max-height:80vh; overflow-y:auto; box-shadow:0 20px 60px rgba(0,0,0,.25); animation:modalIn .2s ease;">
    <div style="display:flex; align-items:center; justify-content:space-between; margin-bottom:14px;">
      <span style="font-size:15px; font-weight:800; color:var(--text-p);">📊 선택 구간 통계</span>
      <button onclick="document.getElementById('rangeStatsModal').style.display='none'" class="close-btn" style="position:static;">&times;</button>
    </div>
    <div id="rangeStatsContent"></div>
  </div>
</div>


<script>
let now_page_code = "b04";

let categories;
let q_pv_1,q_pv_2,q_pv_3,q_pv_4,q_pv_5;
let t_pv_1,t_pv_2,t_pv_3,t_pv_4,t_pv_5;
let cp_pv_1,cp_pv_2,f_wash_pv,m_wash_pv,oil_pv,bc_pv;
let memoSeries = [];
var trendInterval;
var chart;
var currentChartType = 'line';
var selectedRowData = null;

// Alt키 추적 (구간통계용)
window._altPressed = false;
document.addEventListener('keydown', function(e){ if(e.key==='Alt') window._altPressed=true; });
document.addEventListener('keyup',   function(e){ if(e.key==='Alt') window._altPressed=false; });

// 시리즈 그룹 매핑 (인덱스 기준, 마지막 메모 시리즈 제외)
const GROUP_MAP = {
  wash:   [0, 7, 8],   // 전세정기, 중간세정기, 방청조
  quench: [1,2,3,4,5,6], // 소입로 1~5존, 소입유조
  temper: [9,10,11,12,13], // 소려로 1~5존
  cp:     [14,15]
};

const SERIES_COLORS = [
  '#06b6d4','#f59e0b','#fb923c','#fbbf24','#84cc16','#22c55e',
  '#ef4444','#06b6d4','#64748b',
  '#f87171','#fca5a5','#fcd34d','#86efac','#a5f3fc',
  '#8b5cf6','#a855f7','#94a3b8'
];

// ===================== 테마 =====================
let isDark = false;
document.getElementById('themeToggle').addEventListener('click', function(){
  isDark = !isDark;
  document.documentElement.setAttribute('data-theme', isDark ? 'dark' : '');
  this.textContent = isDark ? '☀️' : '🌙';
  if(chart) { applyChartTheme(); chart.redraw(); }
});

function applyChartTheme(){
  const bg    = getComputedStyle(document.documentElement).getPropertyValue('--chart-bg').trim();
  const grid  = getComputedStyle(document.documentElement).getPropertyValue('--chart-grid').trim();
  const text  = getComputedStyle(document.documentElement).getPropertyValue('--chart-text').trim();
  chart.update({
    chart:  { backgroundColor: bg },
    xAxis:  { gridLineColor: grid, lineColor: grid, tickColor: grid, labels:{ style:{color:text} }, title:{style:{color:text}} },
    yAxis:  [{ gridLineColor: grid, labels:{style:{color:text}}, title:{style:{color:text}} },
             { gridLineColor: grid, labels:{style:{color:text}}, title:{style:{color:text}} }],
    legend: { itemStyle:{color:text}, itemHoverStyle:{color:text} }
  }, false);
}

// ===================== 차트 타입 =====================
function setChartType(type){
  currentChartType = type;
  document.querySelectorAll('.type-btn').forEach(b => b.classList.toggle('active', b.dataset.type===type));
  if(!chart) return;
  const memoIdx = chart.series.length - 1;
  chart.series.forEach((s, i) => {
    if(i === memoIdx) return;
    if(type === 'area'){
      s.update({ type:'area', fillOpacity:.08 }, false);
    } else {
      s.update({ type }, false);
    }
  });
  chart.redraw();
}

// ===================== 그룹 토글 =====================
function toggleGroup(group){
  var groupIds = ['quench','temper','cp','wash'];

  if(group === 'all'){
    var chips = groupIds.map(function(g){ return document.getElementById('chip-'+g); }).filter(Boolean);
    var allActive = chips.every(function(c){ return c.classList.contains('active'); });
    var newState = !allActive;
    chips.forEach(function(c){
      var g = c.id.replace('chip-','');
      c.classList.toggle('active',   newState);
      c.classList.toggle('inactive', !newState);
      applyGroupVisibility(g, newState);
    });
    var allChip = document.getElementById('chip-all');
    if(allChip){
      allChip.classList.toggle('active',   newState);
      allChip.classList.toggle('inactive', !newState);
    }
    return;
  }

  var chip = document.getElementById('chip-'+group);
  if(!chip) return;
  var isActive = chip.classList.contains('active');
  chip.classList.toggle('active',   !isActive);
  chip.classList.toggle('inactive',  isActive);
  applyGroupVisibility(group, !isActive);

  // 전체 칩 상태 동기화
  var chips2 = groupIds.map(function(g){ return document.getElementById('chip-'+g); }).filter(Boolean);
  var anyActive = chips2.some(function(c){ return c.classList.contains('active'); });
  var allActive2 = chips2.every(function(c){ return c.classList.contains('active'); });
  var allChip2 = document.getElementById('chip-all');
  if(allChip2){
    allChip2.classList.toggle('active',   allActive2);
    allChip2.classList.toggle('inactive', !allActive2);
  }
}

function applyGroupVisibility(group, visible){
  if(!chart) return;
  const indices = GROUP_MAP[group] || [];
  indices.forEach(i => {
    if(chart.series[i]) {
      if(visible) chart.series[i].show();
      else chart.series[i].hide();
    }
  });
}

// ===================== 유틸 =====================
function escapeHtml(str){ if(!str) return ""; return String(str).replace(/&/g,"&amp;").replace(/</g,"&lt;").replace(/>/g,"&gt;"); }
function safeNum(v){ return (v===null||v===undefined||v==="")?null:(isNaN(Number(v))?null:Number(v)); }
function paddingZero(v){ return v<10?"0"+v:v; }
function dataLabelFormat(val){
  var d = new Date(val);
  if(isNaN(d.getTime())) return val;
  return paddingZero(d.getMonth()+1)+"-"+paddingZero(d.getDate())+"<br/>"+
         paddingZero(d.getHours())+":"+paddingZero(d.getMinutes());
}
function avg(arr){ const v=arr.filter(x=>x!==null&&x!==undefined); return v.length?v.reduce((a,b)=>a+b,0)/v.length:null; }
function calcStats(arr){
  const v=arr.filter(x=>x!==null&&x!==undefined);
  if(!v.length) return null;
  return { min:Math.min(...v), max:Math.max(...v), avg:(v.reduce((a,b)=>a+b,0)/v.length).toFixed(1) };
}

// ===================== 초기화 =====================
$(document).ready(function(){
  $(".datetimeSet").datepicker({ language:'ko', timepicker:true, dateFormat:'yyyy-mm-dd', timeFormat:'hh:ii', autoClose:true });
  $("#startDate").val(trendStime());
  $("#endDate").val(trendEtime());
  fetchData();
  trendInterval = setInterval(function(){ $("#startDate").val(trendStime()); $("#endDate").val(trendEtime()); fetchData(); }, 1000*60*5);
});

$(".select-button").on("click", fetchData);

$(".insert-button").on("click", function(){
  $("input[name='tc_user_code']").val("${loginUser.user_code}");
  $("input[name='tc_user_name']").val("${loginUser.user_name}");
  $("input[name='tc_regtime']").val(trendEtime());
  $('#modalContainer').addClass('show');
  getSignDataList();
  signData();
});

$('.close-btn, #closeModal, #closeModalBtn').click(function(){
  $('#corrForm')[0].reset();
  $('#modalContainer').removeClass('show');
});

$('#saveCorrStatus').click(function(e){
  e.preventDefault();
  var formData = new FormData($('#corrForm')[0]);
  $.ajax({ url:"/line/monitoring/trend/sign/save", type:"POST", data:formData, processData:false, contentType:false,
    success:function(){ alert("저장되었습니다!"); signData(); getTrend(); selectedRowData=null; },
    error:function(){ alert('저장 중 오류가 발생했습니다.'); }
  });
});

$(".excel-button").click(function(){ downloadExcel(); });

document.getElementById('printBtn').addEventListener('click', function(){
  const style = document.createElement('style');
  style.innerHTML = `@page{size:A4 landscape;margin:10mm}@media print{body{zoom:67%}#container{width:1700px!important;max-width:1700px!important;height:660px!important}}`;
  document.head.appendChild(style);
  if(chart) chart.reflow();
  window.print();
  setTimeout(() => document.head.removeChild(style), 1000);
});

// ===================== signData =====================
var signDataTable;
function signData(){
  $.ajax({ url:"/line/monitoring/trend/sign/list", type:"post", dataType:"json", data:{},
    success:function(result){ if(signDataTable) signDataTable.setData(result.data); }
  });
}

function getSignDataList(){
  if($("#signDataSearch").length===0){
    $("#signDataTable").before(`<div style="margin-bottom:8px;display:flex;justify-content:flex-end;">
      <input type="text" id="signDataSearch" placeholder="검색어 입력..." class="form-input" style="width:200px;">
    </div>`);
  }
  signDataTable = new Tabulator('#signDataTable',{
    height:'200px', layout:'fitColumns', reactiveData:true,
    columnHeaderVertAlign:"middle", headerHozAlign:'center', renderHorizontal:"virtual",
    placeholder:"조회된 데이터가 없습니다.",
    columns:[
      {title:"tc_cnt",field:"tc_cnt",visible:false},
      {title:"작업자",field:"tc_user_name",hozAlign:"center"},
      {title:"작업내용",field:"tc_name",hozAlign:"center"},
      {title:"작업시간",field:"tc_regtime",hozAlign:"center"},
      {title:"비고",field:"tc_desc",hozAlign:"center",headerSort:false}
    ],
    rowClick:function(e,row){
      $('#signDataTable .tabulator-row').removeClass('row_select');
      row.getElement().classList.add('row_select');
      selectedRowData=row.getData();
    }
  });
  $("#signDataSearch").on("keyup", function(){
    const kw=$(this).val();
    if(!kw) signDataTable.clearFilter();
    else signDataTable.setFilter([[
      {field:"tc_user_name",type:"like",value:kw},
      {field:"tc_name",type:"like",value:kw},
      {field:"tc_regtime",type:"like",value:kw},
      {field:"tc_desc",type:"like",value:kw}
    ]]);
  });
}

// ===================== fetchData =====================
var signListObj = {};
function fetchData(){
  const startDate=$("#startDate").val(), endDate=$("#endDate").val();
  $.ajax({
    type:"POST", url:"/line/monitoring/trend/list",
    data:{ startDate, endDate },
    success:function(result){
      if(!result||result.length===0){ alert("데이터가 없습니다."); return; }

      const grouped={}, uniqueOrder=[];
      result.forEach(r=>{
        const key=r.regtime;
        if(!grouped.hasOwnProperty(key)){ grouped[key]=r; uniqueOrder.push(key); }
      });
      categories=uniqueOrder.slice();

      signListObj = {};
      memoSeries = [];

      uniqueOrder.forEach(rt => {
        const r = grouped[rt];
        if (r.tc_name || r.tc_desc || r.item_name || r.cust_name || r.lot_name || r.tc_val !== null) {
          // 데모: 차트 위 메모는 한 줄로 짧게 (LOT 시작 = LOT 번호, 일반 메모 = 내용만)
          const parts = [];
          if (r.lot_name && r.lot_name.trim() !== "") parts.push(escapeHtml(r.lot_name));
          else if (r.tc_name && r.tc_name.trim() !== "") parts.push(escapeHtml(r.tc_name));

          memoSeries.push({
            x: uniqueOrder.indexOf(rt),
            y: 950,
            desc: parts.join("")
          });
        }
      });

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

      // 통계 바 업데이트
      const qArr=[...q_pv_1,...q_pv_2,...q_pv_3,...q_pv_4,...q_pv_5];
      const tArr=[...t_pv_1,...t_pv_2,...t_pv_3,...t_pv_4,...t_pv_5];
      const wArr=[...f_wash_pv,...m_wash_pv,...bc_pv];
      const qAvg=avg(qArr), tAvg=avg(tArr), wAvg=avg(wArr);
      const cpAArr=cp_pv_1.filter(x=>x!==null), cpBArr=cp_pv_2.filter(x=>x!==null);
      $("#stat-quench").text(qAvg!==null ? qAvg.toFixed(1)+"°C" : "--");
      $("#stat-temper").text(tAvg!==null ? tAvg.toFixed(1)+"°C" : "--");
      $("#stat-wash").text(wAvg!==null ? wAvg.toFixed(1)+"°C" : "--");
      $("#stat-cp-a").text(cpAArr.length ? (cpAArr.reduce((a,b)=>a+b,0)/cpAArr.length).toFixed(3) : "--");
      $("#stat-cp-b").text(cpBArr.length ? (cpBArr.reduce((a,b)=>a+b,0)/cpBArr.length).toFixed(3) : "--");
      $("#stat-count").text(uniqueOrder.length.toLocaleString()+" pt");
      $("#stat-range").text(startDate.substring(5,16)+" ~ "+endDate.substring(5,16));
      $("#chartMeta").text(uniqueOrder.length.toLocaleString()+" points | "+startDate.substring(0,16)+" ~ "+endDate.substring(0,16));

      const newData=[f_wash_pv,q_pv_1,q_pv_2,q_pv_3,q_pv_4,q_pv_5,oil_pv,m_wash_pv,bc_pv,t_pv_1,t_pv_2,t_pv_3,t_pv_4,t_pv_5,cp_pv_1,cp_pv_2];

      if(!chart){ getTrend(); }
      else{
        chart.xAxis[0].setCategories(categories,false);
        chart.series.forEach((s,i)=>{
          if(i===chart.series.length-1) s.setData(memoSeries,false);
          else if(newData[i]) s.setData(newData[i],false);
        });
        chart.redraw();
      }
    },
    error:function(xhr,status,error){ console.error("❌",error); alert("데이터 조회 중 오류가 발생했습니다."); }
  });
}

// ===================== getTrend (차트 생성) =====================
function getTrend(){
  const bg    = isDark ? '#161b22' : '#ffffff';
  const grid  = isDark ? '#21262d' : '#f0f2f7';
  const textC = isDark ? '#8b949e' : '#374151';

  chart = Highcharts.chart('container',{
    chart:{
      type: currentChartType,
      backgroundColor: bg,
      zoomType:'x',
      panning:true, panKey:'shift',
      animation:{ duration:600 },
      resetZoomButton:{
        position:{ align:'right', verticalAlign:'top', x:-10, y:10 },
        theme:{
          fill: '#475569', stroke:'#475569', r:8,
          style:{ color:'#fff', fontSize:'11px', fontWeight:'700' },
          states:{ hover:{ fill:'#334155' } }
        },
        relativeTo:'chart'
      },
      events:{
    	  selection: function (e) {
    		  const oe = e.originalEvent || {};
    		  const alt = !!oe.altKey;   // ✅ 드래그 이벤트 당시 Alt 상태

    		  if (e.xAxis && alt) {
    		    const xMin = Math.round(e.xAxis[0].min);
    		    const xMax = Math.round(e.xAxis[0].max);
    		    setTimeout(() => showRangeStats(xMin, xMax), 100);
    		  }
    		}
      }
    },
    title:{ text:null },
    credits:{ enabled:false },
    xAxis:{
      categories:categories,
      title:{ text:null },
      labels:{
        formatter:function(){ return dataLabelFormat(this.value); },
        step:40, style:{ color:textC, fontSize:'11px' }, useHTML:true
      },
      lineColor:grid, tickColor:grid, gridLineColor:grid,
      crosshair:{ width:1.5, color:'rgba(100,116,139,.4)', dashStyle:'Solid' }
    },
    yAxis:[
      {
        title:{ text:'온도 (°C)', style:{color:textC,fontSize:'11px'}, rotation:0, margin:16 },
        labels:{ align:'right', x:-8, style:{color:textC,fontSize:'11px'},
          formatter:function(){ return this.value+'°'; } },
        min:0, max:1000,
        gridLineColor:grid, gridLineDashStyle:'Solid',
        plotBands:[{ from:800, to:920, color:'rgba(59,130,246,.03)' }]
      },
      {
        opposite:true,
        title:{ text:'CP', style:{color:textC,fontSize:'11px'}, rotation:0, margin:16 },
        labels:{ align:'left', x:8, style:{color:textC,fontSize:'11px'},
          formatter:function(){ return this.value.toFixed(2); } },
        min:0, max:2,
        gridLineColor:'transparent'
      }
    ],
    legend:{
      enabled:true, layout:'horizontal', align:'center', verticalAlign:'bottom',
      borderWidth:0, backgroundColor:'transparent',
      itemStyle:{ fontSize:'11px', fontWeight:'600', color:textC },
      itemHoverStyle:{ color:textC },
      itemHiddenStyle:{ color:isDark?'#484f58':'#d1d5db' },
      symbolRadius:3, symbolHeight:8
    },
    tooltip:{
      shared:true, crosshairs:true,
      backgroundColor: isDark?'rgba(22,27,34,.95)':'rgba(255,255,255,.97)',
      borderColor: grid, borderRadius:10, borderWidth:1,
      shadow:{ color:'rgba(0,0,0,.15)', offsetX:2, offsetY:4, opacity:.4, width:6 },
      useHTML:true,
      formatter:function(){
        if(!this.points || !this.points.length) return '';

        var s = '<b>' + (this.x || '') + '</b><br/>';

        this.points.forEach(function(pt){
          if(!pt || !pt.series || pt.series.name==='메모') return;
          var color = (typeof pt.series.color === 'object') ? '#aaa' : pt.series.color;
          var isCP = pt.series.options.yAxis === 1;
          var val = (pt.y===null||pt.y===undefined) ? '<span style="color:#94a3b8">-</span>'
                  : (isCP ? pt.y.toFixed(3) : pt.y.toFixed(1));
          var unit = isCP ? '' : ' °C';
          var valStyle='font-weight:700;';
          if(pt.y!==null && pt.y!==undefined && !isCP){
            if(pt.y>=960) valStyle+='color:#ef4444;';
            else if(pt.y>=920||pt.y<=800) valStyle+='color:#f59e0b;';
          }
          s+='<div style="display:flex;align-items:center;gap:8px;padding:2px 0;">'
            +'<span style="display:inline-block;width:8px;height:8px;border-radius:50%;background:'+color+';flex-shrink:0;"></span>'
            +'<span style="font-size:11px;flex:1;">'+pt.series.name+'</span>'
            +'<span style="font-family:\'JetBrains Mono\',monospace;font-size:12px;'+valStyle+'">'+val+unit+'</span>'
            +'</div>';
        });

        // 메모 — 원본 코드와 완전히 동일
        var regtime = categories[this.points[0].point.x];
        var labelHtml = signListObj[regtime] || "";
        if(labelHtml) s += '<hr/>' + labelHtml;

        return s;
      }
    },
    plotOptions:{
      line:{ lineWidth:1.5, marker:{enabled:false,radius:2}, states:{hover:{lineWidth:2.5}} },
      spline:{ lineWidth:1.5, marker:{enabled:false,radius:2}, states:{hover:{lineWidth:2.5}} },
      area:{ lineWidth:1.5, fillOpacity:.08, marker:{enabled:false,radius:2}, states:{hover:{lineWidth:2.5}} },
      scatter:{ marker:{symbol:'diamond',radius:6,fillColor:'#fbbf24',lineColor:'#f59e0b',lineWidth:1.5} },
      series:{
        animation:{ duration:600 },
        events:{
          mouseOver:function(){
            // 사이드 패널 강조 (추후 확장 가능)
          }
        },
        point:{
          events:{
            mouseOver:function(){
              updateLivePanel(this.x);
            }
          }
        }
      }
    },
    navigator:{ enabled:true, height:40,
      xAxis:{ labels:{style:{color:textC,fontSize:'10px'}} },
      series:{ lineWidth:1, color:'#3b82f6', fillOpacity:.1 }
    },
    scrollbar:{ enabled:false },
    rangeSelector:{ enabled:false },
    series:[
      { name:'전세정기',  data:f_wash_pv, yAxis:0, color:SERIES_COLORS[0] },
      { name:'소입로1존', data:q_pv_1,    yAxis:0, color:SERIES_COLORS[1] },
      { name:'소입로2존', data:q_pv_2,    yAxis:0, color:SERIES_COLORS[2] },
      { name:'소입로3존', data:q_pv_3,    yAxis:0, color:SERIES_COLORS[3] },
      { name:'소입로4존', data:q_pv_4,    yAxis:0, color:SERIES_COLORS[4] },
      { name:'소입로5존', data:q_pv_5,    yAxis:0, color:SERIES_COLORS[5] },
      { name:'소입유조',  data:oil_pv,    yAxis:0, color:SERIES_COLORS[6] },
      { name:'중간세정기',data:m_wash_pv, yAxis:0, color:SERIES_COLORS[7] },
      { name:'방청조',    data:bc_pv,     yAxis:0, color:SERIES_COLORS[8] },
      { name:'소려로1존', data:t_pv_1,    yAxis:0, color:SERIES_COLORS[9] },
      { name:'소려로2존', data:t_pv_2,    yAxis:0, color:SERIES_COLORS[10] },
      { name:'소려로3존', data:t_pv_3,    yAxis:0, color:SERIES_COLORS[11] },
      { name:'소려로4존', data:t_pv_4,    yAxis:0, color:SERIES_COLORS[12] },
      { name:'소려로5존', data:t_pv_5,    yAxis:0, color:SERIES_COLORS[13] },
      { name:'CP-A',      data:cp_pv_1,  yAxis:1, color:SERIES_COLORS[14], lineWidth:2, dashStyle:'Solid' },
      { name:'CP-B',      data:cp_pv_2,  yAxis:1, color:SERIES_COLORS[15], lineWidth:2, dashStyle:'Solid' },
      {
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
            pointFormatter:function(){ return this.desc ? ('<span style="color:blue">'+this.desc+'</span>') : ""; }
          }
        }
      ]
    });

    // 임계값 플롯라인 초기 추가
    if(showThreshold) addPlotLines();
  }  // ← 함수 닫기

// ===================== 사이드 패널 업데이트 =====================
function updateLivePanel(xIndex){
  if(xIndex===undefined||xIndex===null) return;
  var time = categories && categories[xIndex] ? categories[xIndex] : '-';
  document.getElementById('liveTime').textContent = time.length>16 ? time.substring(5,16) : time;

  var groups = [
    { label:'소입로', color:'#f59e0b', items:[
      {name:'소입로1존',color:SERIES_COLORS[1],data:q_pv_1},
      {name:'소입로2존',color:SERIES_COLORS[2],data:q_pv_2},
      {name:'소입로3존',color:SERIES_COLORS[3],data:q_pv_3},
      {name:'소입로4존',color:SERIES_COLORS[4],data:q_pv_4},
      {name:'소입로5존',color:SERIES_COLORS[5],data:q_pv_5},
      {name:'소입유조', color:SERIES_COLORS[6],data:oil_pv}
    ]},
    { label:'소려로', color:'#ef4444', items:[
      {name:'소려로1존',color:SERIES_COLORS[9], data:t_pv_1},
      {name:'소려로2존',color:SERIES_COLORS[10],data:t_pv_2},
      {name:'소려로3존',color:SERIES_COLORS[11],data:t_pv_3},
      {name:'소려로4존',color:SERIES_COLORS[12],data:t_pv_4},
      {name:'소려로5존',color:SERIES_COLORS[13],data:t_pv_5}
    ]},
    { label:'세정 / 기타', color:'#06b6d4', items:[
      {name:'전세정기', color:SERIES_COLORS[0],data:f_wash_pv},
      {name:'중간세정기',color:SERIES_COLORS[7],data:m_wash_pv},
      {name:'방청조',   color:SERIES_COLORS[8],data:bc_pv}
    ]},
    { label:'CP', color:'#8b5cf6', items:[
      {name:'CP-A',color:SERIES_COLORS[14],data:cp_pv_1,isCP:true},
      {name:'CP-B',color:SERIES_COLORS[15],data:cp_pv_2,isCP:true}
    ]}
  ];

  var html = '';
  groups.forEach(function(grp){
    html += '<div style="padding:6px 12px 3px;font-size:10px;font-weight:800;letter-spacing:.5px;text-transform:uppercase;'
          + 'color:'+grp.color+';border-bottom:1px solid var(--border);background:var(--surface2);">'+grp.label+'</div>';
    grp.items.forEach(function(s){
      var val = s.data ? s.data[xIndex] : null;
      var dispVal, cls='';
      if(val===null||val===undefined){
        dispVal='--';
      } else {
        dispVal = s.isCP ? val.toFixed(3) : val.toFixed(1);
        if(!s.isCP){
          if(val>=960) cls='alarm';
          else if(val>=920||val<=800) cls='warn';
        }
      }
      var unit = (val!==null&&val!==undefined&&!s.isCP) ? ' °C' : '';
      var valColor = cls==='alarm'?'#ef4444':(cls==='warn'?'#f59e0b':'var(--text-p)');
      html += '<div style="display:flex;align-items:center;justify-content:space-between;'
            + 'padding:7px 12px;border-bottom:1px solid var(--border);">'
            + '<div style="display:flex;align-items:center;gap:7px;">'
            + '<span style="display:inline-block;width:7px;height:7px;border-radius:50%;background:'+s.color+';flex-shrink:0;"></span>'
            + '<span style="font-size:12px;font-weight:600;color:var(--text-s);">'+s.name+'</span>'
            + '</div>'
            + '<span style="font-size:13px;font-weight:800;font-family:\'JetBrains Mono\',monospace;color:'+valColor+';">'+dispVal+unit+'</span>'
            + '</div>';
    });
  });

  // 메모가 있으면 하단에 표시 (signListObj 기준)
  var regtime = categories && categories[xIndex] ? categories[xIndex] : null;
  var memoHtml = regtime ? (signListObj[regtime] || '') : '';
  if(memoHtml){
    html += '<div style="padding:10px 12px;background:#fefce8;border-top:2px solid #f59e0b;">'
          + '<div style="font-size:10px;font-weight:800;color:#b45309;margin-bottom:4px;">📌 메모</div>'
          + '<div style="font-size:12px;color:#374151;line-height:1.6;">'+memoHtml+'</div>'
          + '</div>';
  }

  document.getElementById('liveGrid').innerHTML = html;
}

// ===================== 구간 통계 =====================
function showRangeStats(xMin, xMax){
  if(!categories) return;
  const from = Math.max(0, xMin), to = Math.min(categories.length-1, xMax);
  const cnt = to - from + 1;

  const seriesList = [
    { name:'전세정기',  data:f_wash_pv, unit:'°C' },
    { name:'소입로1~5존', data:[...q_pv_1,...q_pv_2,...q_pv_3,...q_pv_4,...q_pv_5].slice(from*(5)-from, to*(5)-from), unit:'°C' },
    { name:'소입로1존', data:q_pv_1, unit:'°C' },
    { name:'소입로2존', data:q_pv_2, unit:'°C' },
    { name:'소입로3존', data:q_pv_3, unit:'°C' },
    { name:'소려로1존', data:t_pv_1, unit:'°C' },
    { name:'소려로2존', data:t_pv_2, unit:'°C' },
    { name:'소려로3존', data:t_pv_3, unit:'°C' },
    { name:'CP-A',      data:cp_pv_1, unit:'' },
    { name:'CP-B',      data:cp_pv_2, unit:'' },
  ];

  let html = '<div style="font-size:12px;color:var(--text-s);margin-bottom:12px;">'
           + '구간: <strong style="color:var(--text-p)">'+categories[from]+'</strong> ~ <strong style="color:var(--text-p)">'+categories[to]+'</strong>'
           + '<span style="margin-left:8px;background:var(--surface2);padding:2px 8px;border-radius:6px;font-family:\'JetBrains Mono\',monospace;">'+cnt+'pt</span>'
           + '</div>';

  html += '<table style="width:100%;border-collapse:collapse;font-size:12px;">'
        + '<thead><tr style="border-bottom:2px solid var(--border);">'
        + '<th style="text-align:left;padding:6px 8px;color:var(--text-s);font-weight:700;">시리즈</th>'
        + '<th style="text-align:right;padding:6px 8px;color:var(--text-s);font-weight:700;">최소</th>'
        + '<th style="text-align:right;padding:6px 8px;color:var(--text-s);font-weight:700;">최대</th>'
        + '<th style="text-align:right;padding:6px 8px;color:var(--text-s);font-weight:700;">평균</th>'
        + '</tr></thead><tbody>';

  const allSeriesForStats = [
    {name:'전세정기',data:f_wash_pv,unit:'°C'},
    {name:'소입로1존',data:q_pv_1,unit:'°C'},{name:'소입로2존',data:q_pv_2,unit:'°C'},
    {name:'소입로3존',data:q_pv_3,unit:'°C'},{name:'소입로4존',data:q_pv_4,unit:'°C'},
    {name:'소입로5존',data:q_pv_5,unit:'°C'},{name:'소입유조',data:oil_pv,unit:'°C'},
    {name:'중간세정기',data:m_wash_pv,unit:'°C'},{name:'방청조',data:bc_pv,unit:'°C'},
    {name:'소려로1존',data:t_pv_1,unit:'°C'},{name:'소려로2존',data:t_pv_2,unit:'°C'},
    {name:'소려로3존',data:t_pv_3,unit:'°C'},{name:'소려로4존',data:t_pv_4,unit:'°C'},
    {name:'소려로5존',data:t_pv_5,unit:'°C'},
    {name:'CP-A',data:cp_pv_1,unit:''},{name:'CP-B',data:cp_pv_2,unit:''},
  ];

  allSeriesForStats.forEach((s,i) => {
    if(!s.data) return;
    const slice = s.data.slice(from, to+1);
    const st = calcStats(slice);
    if(!st) return;
    const rowBg = i%2===0?'background:var(--surface2);':'';
    const dec = s.unit ? 1 : 3;
    html += '<tr style="'+rowBg+'">'
          + '<td style="padding:5px 8px;font-weight:600;color:var(--text-p);">'
          + '<span style="display:inline-block;width:6px;height:6px;border-radius:50%;background:'+SERIES_COLORS[i]+';margin-right:5px;"></span>'+s.name
          + '</td>'
          + '<td style="padding:5px 8px;text-align:right;font-family:\'JetBrains Mono\',monospace;color:#3b82f6;">'+st.min.toFixed(dec)+s.unit+'</td>'
          + '<td style="padding:5px 8px;text-align:right;font-family:\'JetBrains Mono\',monospace;color:#ef4444;">'+st.max.toFixed(dec)+s.unit+'</td>'
          + '<td style="padding:5px 8px;text-align:right;font-family:\'JetBrains Mono\',monospace;font-weight:700;color:var(--text-p);">'+st.avg+s.unit+'</td>'
          + '</tr>';
  });

  html += '</tbody></table>';

  document.getElementById('rangeStatsContent').innerHTML = html;
  const modal = document.getElementById('rangeStatsModal');
  modal.style.display = 'flex';
}

// ===================== Excel 다운로드 =====================
function downloadExcel(){
  if(!chart||!categories||!categories.length){ alert("다운로드할 데이터가 없습니다."); return; }
  $("#excelOverlay").show(); $("#excelLoading").show();
  try{
    const excelData = categories.map((time,idx)=>({
      "시간": time||"",
      "전세정기":  f_wash_pv[idx]!==null?f_wash_pv[idx]:"",
      "소입로1존": q_pv_1[idx]!==null?q_pv_1[idx]:"",
      "소입로2존": q_pv_2[idx]!==null?q_pv_2[idx]:"",
      "소입로3존": q_pv_3[idx]!==null?q_pv_3[idx]:"",
      "소입로4존": q_pv_4[idx]!==null?q_pv_4[idx]:"",
      "소입로5존": q_pv_5[idx]!==null?q_pv_5[idx]:"",
      "소입유조":  oil_pv[idx]!==null?oil_pv[idx]:"",
      "중간세정기":m_wash_pv[idx]!==null?m_wash_pv[idx]:"",
      "방청조":    bc_pv[idx]!==null?bc_pv[idx]:"",
      "소려로1존": t_pv_1[idx]!==null?t_pv_1[idx]:"",
      "소려로2존": t_pv_2[idx]!==null?t_pv_2[idx]:"",
      "소려로3존": t_pv_3[idx]!==null?t_pv_3[idx]:"",
      "소려로4존": t_pv_4[idx]!==null?t_pv_4[idx]:"",
      "소려로5존": t_pv_5[idx]!==null?t_pv_5[idx]:"",
      "CP-A":      cp_pv_1[idx]!==null?cp_pv_1[idx]:"",
      "CP-B":      cp_pv_2[idx]!==null?cp_pv_2[idx]:"",
      "메모":      (memoSeries.find(m=>m.x===idx)||{desc:""}).desc.replace(/<br\/>/g," | ")
    }));
    const ws=XLSX.utils.json_to_sheet(excelData);
    ws['!cols']=[{wch:20},...Array(16).fill({wch:12}),{wch:50}];
    const wb=XLSX.utils.book_new();
    XLSX.utils.book_append_sheet(wb,ws,"온도트렌드");
    const fn="온도트렌드_"+$("#startDate").val().replace(/[-:\s]/g,'').substring(0,12)+"_"+$("#endDate").val().replace(/[-:\s]/g,'').substring(0,12)+".xlsx";
    XLSX.writeFile(wb,fn);
    setTimeout(()=>{ $("#excelOverlay").hide(); $("#excelLoading").hide(); },500);
  } catch(e){
    console.error(e); alert("엑셀 다운로드에 실패했습니다.");
    $("#excelOverlay").hide(); $("#excelLoading").hide();
  }
}
</script>

</body>
</html>
