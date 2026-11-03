<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<script src="/line/mock/mock-loader.js"></script>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>설비 가동률 분석</title>
<%@include file="../include/pluginpage.jsp"%>
<jsp:include page="../include/tabBar.jsp" />
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@400;500;600;700;800&family=JetBrains+Mono:wght@400;600&display=swap" rel="stylesheet">
<style>
:root {
  --bg: #f0f2f7;
  --surface: #ffffff;
  --surface2: #f8f9fc;
  --border: #e2e6ef;
  --text-primary: #0f172a;
  --text-secondary: #64748b;
  --text-muted: #94a3b8;
  --accent-run: #16a34a;
  --accent-run-light: #dcfce7;
  --accent-down: #dc2626;
  --accent-down-light: #fee2e2;
  --accent-neutral: #2563eb;
  --accent-yellow: #d97706;
  --accent-yellow-light: #fef3c7;
  --shadow-sm: 0 1px 3px rgba(0,0,0,.06), 0 1px 2px rgba(0,0,0,.04);
  --shadow-md: 0 4px 16px rgba(0,0,0,.07), 0 2px 6px rgba(0,0,0,.04);
  --shadow-lg: 0 12px 32px rgba(0,0,0,.09), 0 4px 12px rgba(0,0,0,.05);
  --radius: 14px;
}

* { box-sizing: border-box; margin: 0; padding: 0; }

body {
  font-family: 'Noto Sans KR', sans-serif;
  background: var(--bg);
  color: var(--text-primary);
}

/* =====================
   TOPBAR
===================== */
.topbar {
  position: sticky;
  top: 0;
  z-index: 100;
  background: rgba(255,255,255,0.96);
  backdrop-filter: blur(12px);
  border-bottom: 1px solid var(--border);
  box-shadow: var(--shadow-sm);
}

.topbar-inner {
  max-width: 1400px;
  margin: 0 auto;
  padding: 12px 24px;
  display: flex;
  align-items: center;
  gap: 12px;
  flex-wrap: wrap;
}

.topbar-title {
  font-size: 15px;
  font-weight: 800;
  color: var(--text-primary);
  letter-spacing: -0.3px;
  margin-right: 8px;
  white-space: nowrap;
}

.topbar-divider {
  width: 1px;
  height: 22px;
  background: var(--border);
  margin: 0 4px;
}

.filter-group {
  display: flex;
  align-items: center;
  gap: 8px;
  flex-wrap: wrap;
  flex: 1;
}

.field {
  display: flex;
  align-items: center;
  gap: 7px;
}

.label {
  font-size: 13px;
  font-weight: 700;
  color: var(--text-secondary);
  white-space: nowrap;
}

.tilde {
  color: var(--text-muted);
  font-weight: 700;
  font-size: 15px;
  padding: 0 2px;
}

.ctrl {
  height: 34px;
  padding: 0 11px;
  border: 1px solid var(--border);
  border-radius: 9px;
  background: var(--surface2);
  font-size: 13px;
  font-family: 'Noto Sans KR', sans-serif;
  color: var(--text-primary);
  outline: none;
  transition: border-color .15s, box-shadow .15s;
  min-width: 180px;
}

.ctrl:focus {
  border-color: #94a3b8;
  box-shadow: 0 0 0 3px rgba(100,116,139,.12);
}

select.ctrl {
  min-width: 150px;
  cursor: pointer;
}

/* 조회 버튼 - 회색 계열 */
.btn-search {
  height: 34px;
  padding: 0 16px;
  border-radius: 9px;
  border: 1px solid #94a3b8;
  background: linear-gradient(135deg, #64748b 0%, #475569 100%);
  color: #fff;
  font-size: 13px;
  font-family: 'Noto Sans KR', sans-serif;
  font-weight: 700;
  display: inline-flex;
  align-items: center;
  gap: 6px;
  cursor: pointer;
  transition: filter .15s, transform .08s;
  white-space: nowrap;
  box-shadow: 0 2px 6px rgba(71,85,105,.3);
}

.btn-search:hover { filter: brightness(1.08); }
.btn-search:active { transform: translateY(1px); }

.btn-search svg { width: 14px; height: 14px; }

/* =====================
   PAGE LAYOUT
===================== */
.page-wrap {
  max-width: 1400px;
  margin: 20px auto;
  padding: 0 24px 32px;
  display: flex;
  flex-direction: column;
  gap: 16px;
}

/* =====================
   KPI CARDS (상단 4개)
===================== */
.kpi-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 14px;
}

@media (max-width: 1100px) { .kpi-grid { grid-template-columns: repeat(2, 1fr); } }
@media (max-width: 600px)  { .kpi-grid { grid-template-columns: 1fr; } }

.kpi-card {
  background: var(--surface);
  border: 1px solid var(--border);
  border-radius: var(--radius);
  padding: 18px 20px;
  box-shadow: var(--shadow-sm);
  display: flex;
  flex-direction: column;
  gap: 6px;
  position: relative;
  overflow: hidden;
  transition: box-shadow .2s;
}

.kpi-card:hover { box-shadow: var(--shadow-md); }

.kpi-card::before {
  content: '';
  position: absolute;
  top: 0; left: 0; right: 0;
  height: 3px;
  border-radius: var(--radius) var(--radius) 0 0;
}

.kpi-card.kpi-run::before   { background: linear-gradient(90deg, #16a34a, #4ade80); }
.kpi-card.kpi-down::before  { background: linear-gradient(90deg, #dc2626, #f87171); }
.kpi-card.kpi-rate::before  { background: linear-gradient(90deg, #2563eb, #60a5fa); }
.kpi-card.kpi-base::before  { background: linear-gradient(90deg, #d97706, #fcd34d); }

.kpi-icon {
  width: 36px;
  height: 36px;
  border-radius: 9px;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 4px;
}

.kpi-icon svg { width: 18px; height: 18px; }

.kpi-card.kpi-run  .kpi-icon { background: var(--accent-run-light);  color: var(--accent-run); }
.kpi-card.kpi-down .kpi-icon { background: var(--accent-down-light); color: var(--accent-down); }
.kpi-card.kpi-rate .kpi-icon { background: #dbeafe; color: #2563eb; }
.kpi-card.kpi-base .kpi-icon { background: var(--accent-yellow-light); color: var(--accent-yellow); }

.kpi-label {
  font-size: 12px;
  font-weight: 600;
  color: var(--text-muted);
  letter-spacing: 0.4px;
  text-transform: uppercase;
}

.kpi-value {
  font-size: 28px;
  font-weight: 800;
  font-family: 'JetBrains Mono', monospace;
  color: var(--text-primary);
  letter-spacing: -1px;
  line-height: 1;
}

.kpi-unit {
  font-size: 13px;
  font-weight: 500;
  color: var(--text-secondary);
  margin-left: 3px;
}

.kpi-badge {
  display: inline-flex;
  align-items: center;
  gap: 4px;
  font-size: 11px;
  font-weight: 700;
  padding: 2px 8px;
  border-radius: 20px;
  margin-top: 4px;
  width: fit-content;
}

.badge-good  { background: var(--accent-run-light);    color: var(--accent-run); }
.badge-warn  { background: var(--accent-yellow-light);  color: var(--accent-yellow); }
.badge-bad   { background: var(--accent-down-light);   color: var(--accent-down); }
.badge-info  { background: #dbeafe; color: #2563eb; }

/* =====================
   메인 콘텐츠 영역 (차트 + 사이드)
===================== */
.content-grid {
  display: grid;
  grid-template-columns: 1fr 360px;
  gap: 14px;
  align-items: start;
}

@media (max-width: 1100px) { .content-grid { grid-template-columns: 1fr; } }

/* 카드 공통 */
.card {
  background: var(--surface);
  border: 1px solid var(--border);
  border-radius: var(--radius);
  box-shadow: var(--shadow-sm);
  overflow: hidden;
}

.card-header {
  padding: 16px 20px 12px;
  border-bottom: 1px solid var(--border);
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.card-title {
  font-size: 14px;
  font-weight: 800;
  color: var(--text-primary);
  letter-spacing: -0.2px;
}

.card-subtitle {
  font-size: 12px;
  color: var(--text-muted);
  margin-top: 2px;
}

.card-body {
  padding: 16px 20px;
}

/* =====================
   도넛 차트
===================== */
#chart-container {
  min-height: 420px;
}

/* =====================
   가동 시간 바
===================== */
.timeline-bar-wrap {
  margin: 4px 0 16px;
}

.timeline-label-row {
  display: flex;
  justify-content: space-between;
  font-size: 12px;
  color: var(--text-muted);
  margin-bottom: 6px;
  font-family: 'JetBrains Mono', monospace;
}

.timeline-bar {
  height: 20px;
  border-radius: 10px;
  background: var(--accent-down-light);
  overflow: hidden;
  position: relative;
}

.timeline-bar-fill {
  height: 100%;
  border-radius: 10px;
  background: linear-gradient(90deg, #16a34a, #4ade80);
  transition: width .8s cubic-bezier(.4,0,.2,1);
  display: flex;
  align-items: center;
  justify-content: flex-end;
  padding-right: 8px;
}

.timeline-bar-fill span {
  font-size: 11px;
  font-weight: 700;
  color: #fff;
  font-family: 'JetBrains Mono', monospace;
  white-space: nowrap;
}

/* =====================
   사이드 패널
===================== */
.side-panel {
  display: flex;
  flex-direction: column;
  gap: 14px;
}

/* 효율 등급 카드 */
.grade-card .card-body {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 12px;
  padding: 24px 20px;
}

.grade-circle {
  width: 96px;
  height: 96px;
  border-radius: 50%;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  font-size: 36px;
  font-weight: 900;
  position: relative;
}

.grade-circle.grade-A { background: #dcfce7; color: #15803d; border: 3px solid #16a34a; }
.grade-circle.grade-B { background: #dbeafe; color: #1d4ed8; border: 3px solid #2563eb; }
.grade-circle.grade-C { background: #fef3c7; color: #b45309; border: 3px solid #d97706; }
.grade-circle.grade-D { background: #fee2e2; color: #b91c1c; border: 3px solid #dc2626; }

.grade-label {
  font-size: 13px;
  font-weight: 700;
  color: var(--text-secondary);
}

.grade-desc {
  font-size: 12px;
  color: var(--text-muted);
  text-align: center;
  line-height: 1.5;
}

/* 상세 수치 테이블 */
.detail-table {
  width: 100%;
  border-collapse: collapse;
}

.detail-table tr {
  border-bottom: 1px solid var(--border);
}

.detail-table tr:last-child {
  border-bottom: none;
}

.detail-table td {
  padding: 10px 0;
  font-size: 13px;
}

.detail-table td:first-child {
  color: var(--text-secondary);
  font-weight: 600;
  width: 50%;
}

.detail-table td:last-child {
  text-align: right;
  font-family: 'JetBrains Mono', monospace;
  font-weight: 700;
  color: var(--text-primary);
}

.dot {
  display: inline-block;
  width: 7px; height: 7px;
  border-radius: 50%;
  margin-right: 6px;
  vertical-align: middle;
}

/* =====================
   하단 바 차트 (시간별)
===================== */
#bar-chart-container {
  min-height: 240px;
}

/* =====================
   애니메이션
===================== */
@keyframes fadeUp {
  from { opacity: 0; transform: translateY(12px); }
  to   { opacity: 1; transform: translateY(0); }
}

.kpi-card, .card {
  animation: fadeUp .35s ease both;
}

.kpi-card:nth-child(1) { animation-delay: .04s; }
.kpi-card:nth-child(2) { animation-delay: .08s; }
.kpi-card:nth-child(3) { animation-delay: .12s; }
.kpi-card:nth-child(4) { animation-delay: .16s; }

.status-dot {
  display: inline-block;
  width: 8px; height: 8px;
  border-radius: 50%;
  margin-right: 5px;
  vertical-align: middle;
}

.status-dot.running {
  background: #16a34a;
  box-shadow: 0 0 0 3px #dcfce7;
  animation: pulse 2s infinite;
}

@keyframes pulse {
  0%, 100% { box-shadow: 0 0 0 3px #dcfce7; }
  50%       { box-shadow: 0 0 0 6px rgba(22,163,74,.15); }
}
</style>
</head>
<body>

<!-- ======================== TOPBAR ======================== -->
<div class="topbar">
  <div class="topbar-inner">

    <span class="topbar-title">
      <span class="status-dot running"></span>설비 가동률 분석
    </span>
    <div class="topbar-divider"></div>

    <div class="filter-group">
      <div class="field">
        <span class="label">조회일자</span>
        <input type="text" id="s_sdate" class="ctrl datetimeSet" placeholder="시작일시"/>
      </div>

      <span class="tilde">~</span>

      <div class="field">
        <input type="text" id="s_edate" class="ctrl datetimeSet" placeholder="종료일시"/>
      </div>

      <div class="field" style="margin-left:8px;">
        <span class="label">설비명</span>
        <select id="equipment_name" class="ctrl">
          <option value="">전체</option>
          <option value="열처리 연속로">열처리 연속로</option>
        </select>
      </div>
    </div>

    <button class="btn-search" type="button" onclick="loadOperationData()">
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
        <circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/>
      </svg>
      조회
    </button>

  </div>
</div>

<!-- ======================== PAGE CONTENT ======================== -->
<div class="page-wrap">

  <!-- KPI 카드 4개 -->
  <div class="kpi-grid">
    <div class="kpi-card kpi-base">
      <div class="kpi-icon">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/>
        </svg>
      </div>
      <div class="kpi-label">기준 시간</div>
      <div class="kpi-value"><span id="kpi_standard">--</span><span class="kpi-unit">h</span></div>
      <div class="kpi-badge badge-info">조회 기간 총 시간</div>
    </div>

    <div class="kpi-card kpi-run">
      <div class="kpi-icon">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/>
        </svg>
      </div>
      <div class="kpi-label">가동 시간</div>
      <div class="kpi-value"><span id="kpi_run">--</span><span class="kpi-unit">h</span></div>
      <div class="kpi-badge badge-good" id="badge_run">정상 가동</div>
    </div>

    <div class="kpi-card kpi-down">
      <div class="kpi-icon">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/>
        </svg>
      </div>
      <div class="kpi-label">비가동 시간</div>
      <div class="kpi-value"><span id="kpi_down">--</span><span class="kpi-unit">h</span></div>
      <div class="kpi-badge badge-bad" id="badge_down">비가동 발생</div>
    </div>

    <div class="kpi-card kpi-rate">
      <div class="kpi-icon">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <line x1="18" y1="20" x2="18" y2="10"/><line x1="12" y1="20" x2="12" y2="4"/><line x1="6" y1="20" x2="6" y2="14"/>
        </svg>
      </div>
      <div class="kpi-label">가동률</div>
      <div class="kpi-value"><span id="kpi_rate">--</span><span class="kpi-unit">%</span></div>
      <div class="kpi-badge badge-info" id="badge_rate">산출 중</div>
    </div>
  </div>

  <!-- 메인 콘텐츠 -->
  <div class="content-grid">

    <!-- 왼쪽: 도넛 차트 + 가동 바 -->
    <div style="display:flex; flex-direction:column; gap:14px;">

      <!-- 도넛 차트 -->
      <div class="card">
        <div class="card-header">
          <div>
            <div class="card-title">가동 / 비가동 분포</div>
            <div class="card-subtitle">전체 기준 시간 대비 비율</div>
          </div>
          <div id="chart-period-badge" class="kpi-badge badge-info" style="font-size:12px;"></div>
        </div>
        <div id="chart-container"></div>
      </div>

      <!-- 가동률 타임라인 바 -->
      <div class="card">
        <div class="card-header">
          <div class="card-title">가동률 게이지</div>
        </div>
        <div class="card-body">
          <div class="timeline-bar-wrap">
            <div class="timeline-label-row">
              <span>0%</span>
              <span id="bar-rate-label" style="font-weight:700; color:var(--text-primary);">-- %</span>
              <span>100%</span>
            </div>
            <div class="timeline-bar">
              <div class="timeline-bar-fill" id="gauge-bar" style="width:0%">
                <span id="gauge-bar-label"></span>
              </div>
            </div>
            <div style="display:flex; justify-content:space-between; margin-top:8px; font-size:12px; color:var(--text-muted);">
              <span>
                <span class="dot" style="background:#4ade80;"></span>가동
                <strong id="legend-run" style="color:var(--text-primary); margin-left:2px;">--h</strong>
              </span>
              <span>
                <span class="dot" style="background:#f87171;"></span>비가동
                <strong id="legend-down" style="color:var(--text-primary); margin-left:2px;">--h</strong>
              </span>
            </div>
          </div>

          <!-- 등급 기준 안내 -->
          <div style="margin-top:14px; padding:12px; background:var(--surface2); border-radius:10px; border:1px solid var(--border);">
            <div style="font-size:12px; font-weight:700; color:var(--text-secondary); margin-bottom:8px;">가동률 등급 기준</div>
            <div style="display:flex; gap:6px; flex-wrap:wrap;">
              <span class="kpi-badge badge-good">A등급: 90% 이상</span>
              <span class="kpi-badge badge-info">B등급: 75% 이상</span>
              <span class="kpi-badge badge-warn">C등급: 60% 이상</span>
              <span class="kpi-badge badge-bad">D등급: 60% 미만</span>
            </div>
          </div>
        </div>
      </div>

    </div>

    <!-- 오른쪽: 사이드 패널 -->
    <div class="side-panel">

      <!-- 효율 등급 -->
      <div class="card grade-card">
        <div class="card-header">
          <div class="card-title">효율 등급</div>
        </div>
        <div class="card-body">
          <div class="grade-circle grade-A" id="grade-circle">--</div>
          <div class="grade-label" id="grade-label">데이터 없음</div>
          <div class="grade-desc" id="grade-desc">조회 후 등급이 표시됩니다.</div>
        </div>
      </div>

      <!-- 상세 수치 -->
      <div class="card">
        <div class="card-header">
          <div class="card-title">상세 수치</div>
        </div>
        <div class="card-body" style="padding-top:8px; padding-bottom:8px;">
          <table class="detail-table">
            <tr>
              <td><span class="dot" style="background:#fcd34d;"></span>기준 시간</td>
              <td><span id="dt_standard">--</span> h</td>
            </tr>
            <tr>
              <td><span class="dot" style="background:#4ade80;"></span>가동 시간</td>
              <td><span id="dt_run">--</span> h</td>
            </tr>
            <tr>
              <td><span class="dot" style="background:#f87171;"></span>비가동 시간</td>
              <td><span id="dt_down">--</span> h</td>
            </tr>
            <tr>
              <td><span class="dot" style="background:#60a5fa;"></span>가동률</td>
              <td><span id="dt_rate">--</span> %</td>
            </tr>
            <tr>
              <td><span class="dot" style="background:#c084fc;"></span>비가동률</td>
              <td><span id="dt_down_rate">--</span> %</td>
            </tr>
          </table>
        </div>
      </div>

      <!-- 상태 요약 -->
      <div class="card">
        <div class="card-header">
          <div class="card-title">운영 현황 요약</div>
        </div>
        <div class="card-body" style="display:flex; flex-direction:column; gap:10px;">
          <div style="display:flex; align-items:center; justify-content:space-between; padding:10px 12px; background:var(--surface2); border-radius:9px; border:1px solid var(--border);">
            <span style="font-size:13px; font-weight:600; color:var(--text-secondary);">설비명</span>
            <span style="font-size:13px; font-weight:800;" id="summary-equip">-</span>
          </div>
          <div style="display:flex; align-items:center; justify-content:space-between; padding:10px 12px; background:var(--surface2); border-radius:9px; border:1px solid var(--border);">
            <span style="font-size:13px; font-weight:600; color:var(--text-secondary);">조회 기간</span>
            <span style="font-size:12px; font-weight:700; font-family:'JetBrains Mono',monospace;" id="summary-period">-</span>
          </div>
          <div style="display:flex; align-items:center; justify-content:space-between; padding:10px 12px; background:var(--surface2); border-radius:9px; border:1px solid var(--border);">
            <span style="font-size:13px; font-weight:600; color:var(--text-secondary);">운영 상태</span>
            <span class="kpi-badge badge-good" id="summary-status">-</span>
          </div>
        </div>
      </div>

    </div>
  </div>

</div><!-- /page-wrap -->

<script>
let now_page_code = "f04";

$(function() {
    let startDate = new Date();
    startDate.setHours(8, 0, 0, 0);
    let endDate = new Date();
    $("#s_sdate").val(formatDateTime(startDate));
    $("#s_edate").val(formatDateTime(endDate));
    loadOperationData();
});

function formatDateTime(date) {
    let y = date.getFullYear();
    let m = String(date.getMonth()+1).padStart(2,'0');
    let d = String(date.getDate()).padStart(2,'0');
    let h = String(date.getHours()).padStart(2,'0');
    let mi = String(date.getMinutes()).padStart(2,'0');
    return y+'-'+m+'-'+d+' '+h+':'+mi;
}

function loadOperationData() {
    let startDate = $("#s_sdate").val();
    let endDate   = $("#s_edate").val();
    let equipName = $("#equipment_name").val();

    if(!startDate || !endDate) {
        alert("조회 기간을 입력하세요.");
        return;
    }

    $.ajax({
        url: "/line/standard/operation/rate",
        type: "POST",
        dataType: "json",
        data: { startDate, endDate, equipment_name: equipName },
        success: function(result) {
            let standardHours = result.standardHours || 0;
            let downHours     = result.downHours || 0;
            let runHours      = Math.max(0, standardHours - downHours);
            let runRate       = standardHours > 0 ? (runHours / standardHours * 100) : 0;
            let downRate      = 100 - runRate;

            updateUI(standardHours, runHours, downHours, runRate, downRate, startDate, endDate, equipName);
            drawDonutChart(runHours, downHours, runRate);
        },
        error: function(xhr, status, error) {
            console.error("데이터 로드 실패:", error);
            alert("데이터를 불러오는데 실패했습니다.");
        }
    });
}

function updateUI(std, run, down, runRate, downRate, startDate, endDate, equipName) {
    let rStr = runRate.toFixed(1);
    let dStr = downRate.toFixed(1);

    // KPI
    $("#kpi_standard").text(std.toFixed(1));
    $("#kpi_run").text(run.toFixed(1));
    $("#kpi_down").text(down.toFixed(1));
    $("#kpi_rate").text(rStr);

    // 상세
    $("#dt_standard").text(std.toFixed(1));
    $("#dt_run").text(run.toFixed(1));
    $("#dt_down").text(down.toFixed(1));
    $("#dt_rate").text(rStr);
    $("#dt_down_rate").text(dStr);

    // 게이지 바
    $("#gauge-bar").css("width", rStr + "%");
    $("#gauge-bar-label").text(rStr + "%");
    $("#bar-rate-label").text(rStr + "%");
    $("#legend-run").text(run.toFixed(1) + "h");
    $("#legend-down").text(down.toFixed(1) + "h");

    // 기간 뱃지
    let s = startDate.substring(5,16);
    let e = endDate.substring(5,16);
    $("#chart-period-badge").text(s + " ~ " + e);

    // 요약
    $("#summary-equip").text(equipName || "전체");
    $("#summary-period").text(s + "~" + e);

    // 효율 등급
    let grade, gradeClass, gradeLabel, gradeDesc, badgeClass, statusText, statusClass;
    if(runRate >= 90) {
        grade = "A"; gradeClass = "grade-A";
        gradeLabel = "최우수 (A등급)";
        gradeDesc = "설비 가동률이 매우 우수합니다.\n정기 점검을 유지하세요.";
        badgeClass = "badge-good"; statusText = "최우수";
    } else if(runRate >= 75) {
        grade = "B"; gradeClass = "grade-B";
        gradeLabel = "양호 (B등급)";
        gradeDesc = "가동률이 양호한 수준입니다.\n소폭 개선이 가능합니다.";
        badgeClass = "badge-info"; statusText = "양호";
    } else if(runRate >= 60) {
        grade = "C"; gradeClass = "grade-C";
        gradeLabel = "주의 (C등급)";
        gradeDesc = "비가동 시간이 증가하고 있습니다.\n원인 분석이 필요합니다.";
        badgeClass = "badge-warn"; statusText = "주의";
    } else {
        grade = "D"; gradeClass = "grade-D";
        gradeLabel = "불량 (D등급)";
        gradeDesc = "가동률이 낮습니다.\n즉각적인 점검이 필요합니다.";
        badgeClass = "badge-bad"; statusText = "불량";
    }

    $("#grade-circle").text(grade)
      .removeClass("grade-A grade-B grade-C grade-D")
      .addClass(gradeClass);
    $("#grade-label").text(gradeLabel);
    $("#grade-desc").text(gradeDesc);

    // 뱃지 업데이트
    $("#badge_run").text("가동 " + run.toFixed(1) + "h");
    $("#badge_down").text("비가동 " + down.toFixed(1) + "h");
    $("#badge_rate").text("가동률 " + rStr + "%")
      .removeClass("badge-good badge-info badge-warn badge-bad")
      .addClass(badgeClass);

    $("#summary-status")
      .text(statusText)
      .removeClass("badge-good badge-info badge-warn badge-bad")
      .addClass(badgeClass);
}

function drawDonutChart(run, down, runRate) {
    Highcharts.chart('chart-container', {
        chart: {
            type: 'pie',
            height: 420,
            style: { fontFamily: "'Noto Sans KR', sans-serif" },
            backgroundColor: 'transparent',
            animation: { duration: 800, easing: 'easeOutBounce' }
        },
        title: {
            text: '<b style="font-size:22px;">' + runRate.toFixed(1) + '%</b><br><span style="font-size:13px;color:#64748b;">가동률</span>',
            align: 'center',
            verticalAlign: 'middle',
            y: 8,
            useHTML: true
        },
        subtitle: { text: '' },
        credits: { enabled: false },
        legend: {
            enabled: true,
            align: 'center',
            verticalAlign: 'bottom',
            itemStyle: { fontSize: '13px', fontWeight: '700', color: '#374151' },
            symbolRadius: 4
        },
        tooltip: {
            useHTML: true,
            headerFormat: '',
            pointFormat: '<div style="font-size:13px;"><b>{point.name}</b><br>{point.y:.1f}시간 &nbsp;|&nbsp; {point.percentage:.1f}%</div>',
            backgroundColor: '#fff',
            borderColor: '#e2e6ef',
            borderRadius: 10,
            shadow: true
        },
        plotOptions: {
            pie: {
                innerSize: '62%',
                borderWidth: 3,
                borderColor: '#fff',
                dataLabels: {
                    enabled: true,
                    distance: 20,
                    format: '<b style="font-size:12px;">{point.name}</b><br><span style="color:#64748b;">{point.y:.1f}h ({point.percentage:.1f}%)</span>',
                    connectorShape: 'crookedLine',
                    crookDistance: '70%'
                },
                showInLegend: true
            }
        },
        series: [{
            name: '시간',
            colorByPoint: true,
            data: [
                { name: '가동',   y: run,  color: { linearGradient:{x1:0,y1:0,x2:1,y2:1}, stops:[[0,'#16a34a'],[1,'#4ade80']] } },
                { name: '비가동', y: down, color: { linearGradient:{x1:0,y1:0,x2:1,y2:1}, stops:[[0,'#dc2626'],[1,'#f87171']] } }
            ]
        }]
    });
}
</script>

</body>
</html>
