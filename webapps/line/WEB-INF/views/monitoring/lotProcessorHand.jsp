<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="ko">
<head>
<script src="/line/mock/mock-loader.js"></script>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <title>LOT트래킹</title>
    <%@include file="../include/pluginpage.jsp" %>    
    <jsp:include page="../include/tabBar.jsp"/> 
    
    <style>
* {
    box-sizing: border-box;
    margin: 0;
    padding: 0;
}

body {
    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Noto Sans KR", sans-serif;
    background: #f5f7fa;
    padding-bottom: 20px;
}

/* 로고 영역 */
.logo-container {
    background: white;
    padding: 15px;
    text-align: center;
    box-shadow: 0 2px 8px rgba(0,0,0,0.08);
}

.logo-container img {
    max-width: 180px;
    height: auto;
}

/* 검색 영역 */
.search-section {
    background: white;
    padding: 16px;
    margin: 12px;
    border-radius: 16px;
    box-shadow: 0 2px 12px rgba(0,0,0,0.06);
}

.date-selector {
    display: flex;
    align-items: center;
    gap: 8px;
    margin-bottom: 12px;
}

.date-selector label {
    font-size: 14px;
    font-weight: 600;
    color: #333;
    white-space: nowrap;
}

.date-selector input[type="date"] {
    flex: 1;
    padding: 10px 12px;
    border: 1px solid #e1e4e8;
    border-radius: 10px;
    font-size: 14px;
    background: #fafbfc;
}

.date-separator {
    color: #666;
    font-weight: 600;
}

.button-group {
    display: flex;
    gap: 8px;
}

.btn {
    flex: 1;
    padding: 12px;
    border: none;
    border-radius: 10px;
    font-size: 14px;
    font-weight: 600;
    cursor: pointer;
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 6px;
    transition: all 0.2s;
}

.btn-search {
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    color: white;
}

.btn-search:active {
    transform: scale(0.98);
}

.btn-edit {
    background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
    color: white;
}

.btn-edit:active {
    transform: scale(0.98);
}

.btn-icon {
    width: 18px;
    height: 18px;
}

/* 데이터 카드 리스트 */
.data-container {
    padding: 0 12px;
}

.data-card {
    background: white;
    border-radius: 16px;
    padding: 16px;
    margin-bottom: 12px;
    box-shadow: 0 2px 12px rgba(0,0,0,0.06);
    animation: slideIn 0.3s ease-out;
    cursor: pointer;
    transition: all 0.2s;
}

.data-card:active {
    transform: scale(0.98);
}

.data-card.selected {
    background: #e8eaf0;
    border: 2px solid #667eea;
    box-shadow: 0 4px 16px rgba(102, 126, 234, 0.2);
}

@keyframes slideIn {
    from {
        opacity: 0;
        transform: translateY(10px);
    }
    to {
        opacity: 1;
        transform: translateY(0);
    }
}

.card-header {
    border-bottom: 2px solid #f0f2f5;
    padding-bottom: 12px;
    margin-bottom: 12px;
}

.lot-number {
    font-size: 18px;
    font-weight: 700;
    color: #2c3e50;
    margin-bottom: 6px;
}

.card-info {
    display: flex;
    flex-direction: column;
    gap: 4px;
}

.info-row {
    display: flex;
    align-items: center;
    font-size: 13px;
    color: #5a6c7d;
}

.info-label {
    font-weight: 600;
    margin-right: 6px;
    color: #34495e;
}

.qr-badge {
    display: inline-block;
    padding: 3px 10px;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    color: white;
    border-radius: 12px;
    font-size: 11px;
    font-weight: 600;
    margin-left: 8px;
}

/* 프로세스 타임라인 */
.timeline {
    margin-top: 12px;
}

.timeline-item {
    display: flex;
    align-items: center;
    padding: 8px 0;
    border-bottom: 1px solid #f0f2f5;
}

.timeline-item:last-child {
    border-bottom: none;
}

.timeline-dot {
    width: 10px;
    height: 10px;
    background: #e1e4e8;
    border-radius: 50%;
    margin-right: 12px;
    flex-shrink: 0;
}

.timeline-dot.completed {
    background: linear-gradient(135deg, #11998e 0%, #38ef7d 100%);
    box-shadow: 0 0 0 3px rgba(56, 239, 125, 0.2);
}

.timeline-content {
    flex: 1;
    display: flex;
    justify-content: space-between;
    align-items: center;
}

.timeline-label {
    font-size: 15px;
    font-weight: 600;
    color: #34495e;
}

.timeline-time {
    font-size: 15px;
    color: #7f8c8d;
    font-family: 'Courier New', monospace;
    font-weight: 600;
}

.timeline-time.completed {
    color: #27ae60;
    font-weight: 700;
}

/* 빈 상태 */
.empty-state {
    text-align: center;
    padding: 60px 20px;
    color: #95a5a6;
}

.empty-state-icon {
    font-size: 64px;
    margin-bottom: 16px;
}

.empty-state-text {
    font-size: 16px;
    font-weight: 500;
}

/* 로딩 */
.loading {
    text-align: center;
    padding: 40px;
    color: #95a5a6;
}

.spinner {
    border: 3px solid #f3f3f3;
    border-top: 3px solid #667eea;
    border-radius: 50%;
    width: 40px;
    height: 40px;
    animation: spin 1s linear infinite;
    margin: 0 auto 12px;
}

@keyframes spin {
    0% { transform: rotate(0deg); }
    100% { transform: rotate(360deg); }
}

/* 모달 */
.modal {
    display: none;
    position: fixed;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background: rgba(0,0,0,0.5);
    z-index: 1000;
    overflow-y: auto;
    animation: fadeIn 0.2s;
}

@keyframes fadeIn {
    from { opacity: 0; }
    to { opacity: 1; }
}

.modal-content {
    background: white;
    margin: 20px;
    border-radius: 20px;
    padding: 20px;
    max-width: 500px;
    margin: 20px auto;
}

.modal-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 16px;
    padding-bottom: 12px;
    border-bottom: 2px solid #f0f2f5;
}

.modal-title {
    font-size: 20px;
    font-weight: 700;
    color: #2c3e50;
}

.modal-close {
    background: none;
    border: none;
    font-size: 28px;
    color: #95a5a6;
    cursor: pointer;
    width: 32px;
    height: 32px;
    display: flex;
    align-items: center;
    justify-content: center;
}

.edit-card {
    background: #fafbfc;
    border-radius: 12px;
    padding: 16px;
    margin-bottom: 12px;
}

.edit-lot-name {
    font-size: 16px;
    font-weight: 700;
    color: #2c3e50;
    margin-bottom: 12px;
}

.edit-field {
    margin-bottom: 12px;
}

.edit-field:last-child {
    margin-bottom: 0;
}

.edit-field label {
    display: block;
    font-size: 12px;
    font-weight: 600;
    color: #5a6c7d;
    margin-bottom: 4px;
}

.edit-field input {
    width: 100%;
    padding: 10px 12px;
    border: 1px solid #e1e4e8;
    border-radius: 8px;
    font-size: 14px;
    background: white;
}

.edit-field input:focus {
    outline: none;
    border-color: #667eea;
    box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
}

.auto-generate-section {
    margin: 16px 0;
    padding: 16px;
    background: #f8f9fa;
    border-radius: 12px;
}

.auto-input {
    width: 100%;
    padding: 12px;
    border: 1px solid #e1e4e8;
    border-radius: 8px;
    font-size: 14px;
    margin-bottom: 12px;
}

.auto-buttons {
    display: flex;
    gap: 8px;
    margin-bottom: 12px;
}

.btn-auto {
    flex: 1;
    padding: 10px;
    border: none;
    border-radius: 8px;
    font-size: 13px;
    font-weight: 600;
    color: white;
    cursor: pointer;
}

.btn-auto-15 {
    background: linear-gradient(135deg, #4CAF50 0%, #45a049 100%);
}

.btn-auto-25 {
    background: linear-gradient(135deg, #43a047 0%, #2e7d32 100%);
}

.modal-buttons {
    display: flex;
    gap: 8px;
    margin-top: 16px;
}

.btn-save {
    flex: 1;
    padding: 14px;
    background: linear-gradient(135deg, #2196F3 0%, #1976D2 100%);
    color: white;
    border: none;
    border-radius: 10px;
    font-size: 15px;
    font-weight: 600;
    cursor: pointer;
}

.btn-cancel {
    flex: 1;
    padding: 14px;
    background: #e0e0e0;
    color: #333;
    border: none;
    border-radius: 10px;
    font-size: 15px;
    font-weight: 600;
    cursor: pointer;
}

/* 반응형 */
@media (min-width: 768px) {
    .search-section {
        max-width: 800px;
        margin: 20px auto;
    }
    
    .data-container {
        max-width: 800px;
        margin: 0 auto;
    }
}
    </style>
</head>

<body>
    <!-- 로고 -->
    <div class="logo-container">
        <img src="/line/css/login/logo2.png" alt="로고">
    </div>

    <!-- 검색 영역 -->
    <div class="search-section">
        <div class="date-selector">
         <!--    <label>조회기간</label> -->
            <input type="date" id="daySetStart">
            <span class="date-separator">~</span>
            <input type="date" id="daySetEnd">
        </div>
        
        <div class="button-group">
            <button class="btn btn-search" onclick="searchData()">
                <img src="/line/css/tabBar/search-icon.png" alt="조회" class="btn-icon">
                <span>조회</span>
            </button>
            <button class="btn btn-edit" onclick="openEditModal()">
                <span>수정</span>
            </button>
        </div>
    </div>

    <!-- 데이터 리스트 -->
    <div class="data-container" id="dataContainer">
        <div class="loading">
            <div class="spinner"></div>
            <div>데이터를 불러오는 중...</div>
        </div>
    </div>

    <!-- 수정 모달 -->
    <div class="modal" id="editModal">
        <div class="modal-content">
            <div class="modal-header">
                <h2 class="modal-title">LOT 데이터 수정</h2>
                <button class="modal-close" onclick="closeEditModal()">&times;</button>
            </div>
            
            <div class="auto-generate-section">
                <input type="text" class="auto-input" id="autoLotInput" placeholder="LOT 번호를 입력하세요">
                <div class="auto-buttons">
                    <button class="btn-auto btn-auto-15" onclick="autoGenerate(15)">15분 자동생성</button>
                    <button class="btn-auto btn-auto-25" onclick="autoGenerate(25)">25분 자동생성</button>
                </div>
            </div>
            
            <div id="editDataContainer"></div>
            
            <div class="modal-buttons">
                <button class="btn-save" onclick="saveData()">저장</button>
                <button class="btn-cancel" onclick="closeEditModal()">취소</button>
            </div>
        </div>
    </div>

<script>
let currentData = [];
let modifiedData = {};
let selectedLot = null;

// 날짜 포맷팅
function formatDate(date) {
    return [
        date.getFullYear(),
        String(date.getMonth() + 1).padStart(2, '0'),
        String(date.getDate()).padStart(2, '0')
    ].join("-");
}

function formatDateTime(d) {
    if (!(d instanceof Date)) return "";
    return [
        d.getFullYear(),
        String(d.getMonth() + 1).padStart(2, '0'),
        String(d.getDate()).padStart(2, '0')
    ].join("-") + " " +
    [
        String(d.getHours()).padStart(2, '0'),
        String(d.getMinutes()).padStart(2, '0'),
        String(d.getSeconds()).padStart(2, '0')
    ].join(":");
}

function parseDateSafe(dateStr) {
    if (!dateStr) return null;
    dateStr = dateStr.split(".")[0];
    const d = new Date(dateStr.replace(" ", "T"));
    return isNaN(d) ? null : d;
}

// 시간만 추출
function getTimeOnly(dateTimeStr) {
    if (!dateTimeStr) return '';
    const parts = dateTimeStr.split(' ');
    return parts.length > 1 ? parts[1] : '';
}

// 초기화
$(document).ready(function() {
    const today = new Date();
    $('#daySetStart').val(formatDate(today));
    $('#daySetEnd').val(formatDate(today));
    
    searchData();
    
    // 5초마다 자동 새로고침 (모바일에서는 옵션)
    // setInterval(searchData, 5000);
});

// 데이터 조회
function searchData() {
    const startDay = $('#daySetStart').val();
    const endDay = $('#daySetEnd').val();
    
    $.ajax({
        url: '/line/monitoring/lotProcessor/list',
        type: 'POST',
        data: { startDay, endDay },
        success: function(response) {
            currentData = response.data || [];
            renderDataCards();
        },
        error: function() {
            $('#dataContainer').html(
                '<div class="empty-state">' +
                    '<div class="empty-state-icon">⚠️</div>' +
                    '<div class="empty-state-text">데이터를 불러오는데 실패했습니다</div>' +
                '</div>'
            );
        }
    });
}

// LOT 선택
function selectLot(lotNumber) {
    if (selectedLot === lotNumber) {
        selectedLot = null;
    } else {
        selectedLot = lotNumber;
    }
    renderDataCards();
}

// 데이터 카드 렌더링
function renderDataCards() {
    const container = $('#dataContainer');
    
    if (currentData.length === 0) {
        container.html(
            '<div class="empty-state">' +
                '<div class="empty-state-icon">📦</div>' +
                '<div class="empty-state-text">조회된 데이터가 없습니다</div>' +
            '</div>'
        );
        return;
    }
    
    let html = '';
    currentData.forEach(function(item, index) {
        const processes = [
            { label: '작업등록', value: item.regtime },
            { label: 'QR확인', value: item.w_state },
            { label: '투입시작', value: item.d370 },
            { label: '투입종료', value: item.x111 },
            { label: '전세정기', value: item.f_wash_3 },
            { label: '소입로', value: item.qf1_4 },
            { label: '유조', value: item.oil_9 },
            { label: '중간세정기', value: item.m_wash_10 },
            { label: '소려로', value: item.tf1_11 },
            { label: '방청조', value: item.bch_16 },
            { label: '출구콘베어', value: item.con_17 },
            { label: '로트종료', value: item.l20 }
        ];
        
        const isSelected = selectedLot === item.w_ci_lot;
        
        html += '<div class="data-card' + (isSelected ? ' selected' : '') + '" onclick="selectLot(\'' + item.w_ci_lot + '\')">' +
                '<div class="card-header">' +
                    '<div class="lot-number">' + (item.w_ci_lot || '-') + '</div>' +
                    '<div class="card-info">' +
                        '<div class="info-row">' +
                            '<span class="info-label">고객사:</span>' +
                            '<span>' + (item.cust_name || '-') + '</span>' +
                        '</div>' +
                        '<div class="info-row">' +
                            '<span class="info-label">품목:</span>' +
                            '<span>' + (item.item_name || '-') + '</span>' +
                        '</div>' +
                    '</div>' +
                '</div>' +
                '<div class="timeline">';
        
        processes.forEach(function(p) {
            const isCompleted = p.value && p.value.trim() !== '';
            let displayValue = '-';
            
            if (p.label === 'QR확인') {
                if (p.value && p.value.includes('스캔')) {
                    displayValue = '스캔완료';
                } else if (p.value) {
                    displayValue = p.value;
                }
            } else {
                displayValue = getTimeOnly(p.value) || '-';
            }
            
            html += '<div class="timeline-item">' +
                        '<div class="timeline-dot ' + (isCompleted ? 'completed' : '') + '"></div>' +
                        '<div class="timeline-content">' +
                            '<span class="timeline-label">' + p.label + '</span>' +
                            '<span class="timeline-time ' + (isCompleted ? 'completed' : '') + '">' + displayValue + '</span>' +
                        '</div>' +
                    '</div>';
        });
        
        html += '</div></div>';
    });
    
    container.html(html);
}

// 수정 모달 열기
function openEditModal() {
    if (currentData.length === 0) {
        alert('수정할 데이터가 없습니다.');
        return;
    }
    
    modifiedData = {};
    renderEditCards();
    
    // 선택된 LOT가 있으면 자동 입력
    if (selectedLot) {
        $('#autoLotInput').val(selectedLot);
    }
    
    $('#editModal').show();
}

// 수정 카드 렌더링
function renderEditCards() {
    const container = $('#editDataContainer');
    let html = '';
    
    currentData.forEach(function(item, index) {
        html += '<div class="edit-card">' +
                '<div class="edit-lot-name">' + (item.w_ci_lot || '-') + '</div>' +
                
                '<div class="edit-field">' +
                    '<label>투입시작</label>' +
                    '<input type="text" data-index="' + index + '" data-field="d370" value="' + (item.d370 || '') + '" ' +
                           'placeholder="YYYY-MM-DD HH:MM:SS" onchange="markAsModified(this)">' +
                '</div>' +
                
                '<div class="edit-field">' +
                    '<label>투입종료</label>' +
                    '<input type="text" data-index="' + index + '" data-field="x111" value="' + (item.x111 || '') + '" ' +
                           'placeholder="YYYY-MM-DD HH:MM:SS" onchange="markAsModified(this)">' +
                '</div>' +
                
                '<div class="edit-field">' +
                    '<label>전세정기</label>' +
                    '<input type="text" data-index="' + index + '" data-field="f_wash_3" value="' + (item.f_wash_3 || '') + '" ' +
                           'placeholder="YYYY-MM-DD HH:MM:SS" onchange="markAsModified(this)">' +
                '</div>' +
                
                '<div class="edit-field">' +
                    '<label>소입로</label>' +
                    '<input type="text" data-index="' + index + '" data-field="qf1_4" value="' + (item.qf1_4 || '') + '" ' +
                           'placeholder="YYYY-MM-DD HH:MM:SS" onchange="markAsModified(this)">' +
                '</div>' +
                
                '<div class="edit-field">' +
                    '<label>유조</label>' +
                    '<input type="text" data-index="' + index + '" data-field="oil_9" value="' + (item.oil_9 || '') + '" ' +
                           'placeholder="YYYY-MM-DD HH:MM:SS" onchange="markAsModified(this)">' +
                '</div>' +
                
                '<div class="edit-field">' +
                    '<label>중간세정기</label>' +
                    '<input type="text" data-index="' + index + '" data-field="m_wash_10" value="' + (item.m_wash_10 || '') + '" ' +
                           'placeholder="YYYY-MM-DD HH:MM:SS" onchange="markAsModified(this)">' +
                '</div>' +
                
                '<div class="edit-field">' +
                    '<label>소려로</label>' +
                    '<input type="text" data-index="' + index + '" data-field="tf1_11" value="' + (item.tf1_11 || '') + '" ' +
                           'placeholder="YYYY-MM-DD HH:MM:SS" onchange="markAsModified(this)">' +
                '</div>' +
                
                '<div class="edit-field">' +
                    '<label>방청조</label>' +
                    '<input type="text" data-index="' + index + '" data-field="bch_16" value="' + (item.bch_16 || '') + '" ' +
                           'placeholder="YYYY-MM-DD HH:MM:SS" onchange="markAsModified(this)">' +
                '</div>' +
                
                '<div class="edit-field">' +
                    '<label>출구콘베어</label>' +
                    '<input type="text" data-index="' + index + '" data-field="con_17" value="' + (item.con_17 || '') + '" ' +
                           'placeholder="YYYY-MM-DD HH:MM:SS" onchange="markAsModified(this)">' +
                '</div>' +
                
                '<div class="edit-field">' +
                    '<label>로트종료</label>' +
                    '<input type="text" data-index="' + index + '" data-field="l20" value="' + (item.l20 || '') + '" ' +
                           'placeholder="YYYY-MM-DD HH:MM:SS" onchange="markAsModified(this)">' +
                '</div>' +
                
            '</div>';
    });
    
    container.html(html);
}

// 수정 표시
function markAsModified(input) {
    const index = $(input).data('index');
    const field = $(input).data('field');
    const value = $(input).val();
    
    if (!modifiedData[index]) {
        modifiedData[index] = Object.assign({}, currentData[index]);
    }
    modifiedData[index][field] = value;
    
    $(input).closest('.edit-card').css('background', '#fff3cd');
}

// 자동 생성
function autoGenerate(type) {
    const lot = $('#autoLotInput').val().trim();
    if (!lot) {
        alert('LOT 번호를 입력하세요');
        return;
    }
    
    let index = -1;
    for (let i = 0; i < currentData.length; i++) {
        if (currentData[i].w_ci_lot === lot) {
            index = i;
            break;
        }
    }
    
    if (index === -1) {
        alert('해당 LOT를 찾을 수 없습니다');
        return;
    }
    
    const item = currentData[index];
    const base = parseDateSafe(item.d370);
    if (!base) {
        alert('투입시작 시간이 필요합니다');
        return;
    }
    
    const endMinutes = 70;
    const oilMinutes = type === 15 ? 84 : 50;
    
    const steps = [
        { field: 'x111', minutes: endMinutes },
        { field: 'f_wash_3', minutes: endMinutes + 6.5 },
        { field: 'qf1_4', minutes: endMinutes + 7.5 },
        { field: 'oil_9', minutes: endMinutes + 7.5 + oilMinutes },
        { field: 'm_wash_10', minutes: endMinutes + 7.5 + oilMinutes + 7.3 },
        { field: 'tf1_11', minutes: endMinutes + 7.5 + oilMinutes + 14.9 },
        { field: 'bch_16', minutes: endMinutes + 7.5 + oilMinutes + 14.9 + 135 },
        { field: 'con_17', minutes: endMinutes + 7.5 + oilMinutes + 14.9 + 148.5 },
        { field: 'l20', minutes: endMinutes + 7.5 + oilMinutes + 14.9 + 163.5 }
    ];
    
    if (!modifiedData[index]) {
        modifiedData[index] = Object.assign({}, item);
    }
    
    steps.forEach(function(step) {
        const newTime = new Date(base.getTime() + step.minutes * 60000);
        modifiedData[index][step.field] = formatDateTime(newTime);
        
        const input = $('input[data-index="' + index + '"][data-field="' + step.field + '"]');
        input.val(formatDateTime(newTime));
    });
    
    $('input[data-index="' + index + '"]').closest('.edit-card').css('background', '#d4edda');
}

// 저장
function saveData() {
    const modifiedKeys = Object.keys(modifiedData);
    if (modifiedKeys.length === 0) {
        alert('변경된 데이터가 없습니다.');
        return;
    }
    
    const saveArray = modifiedKeys.map(function(key) {
        return modifiedData[key];
    });
    
    $.ajax({
        url: '/line/monitoring/lotProcessor/bulkUpdate',
        type: 'POST',
        contentType: 'application/json',
        data: JSON.stringify(saveArray),
        success: function() {
            alert('저장되었습니다.');
            closeEditModal();
            searchData();
        },
        error: function() {
            alert('저장에 실패했습니다.');
        }
    });
}

// 모달 닫기
function closeEditModal() {
    $('#editModal').hide();
    $('#autoLotInput').val('');
    modifiedData = {};
}
</script>

</body>
</html>
