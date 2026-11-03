<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<script src="/line/mock/mock-loader.js"></script>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <title>MES - 메인</title>
    
    <script src="/vendor/jquery/3.7.1/jquery.min.js"></script>
    
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            padding: 20px;
        }

        /* 헤더 */
        .header {
            text-align: center;
            padding: 20px 0 30px;
        }

        .logo {
            margin-bottom: -15px;
        }

        .logo img {
            max-width: 240px;
            height: auto;
            filter: brightness(0) invert(1);
        }

        .user-info {
            color: white;
            font-size: 14px;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 15px;
            margin-top: 10px;
        }

        .user-name {
            font-weight: 600;
            font-size: 16px;
        }

        .logout-btn {
            background: rgba(255, 255, 255, 0.2);
            border: 1px solid rgba(255, 255, 255, 0.3);
            color: white;
            padding: 6px 16px;
            border-radius: 20px;
            cursor: pointer;
            font-size: 13px;
            transition: all 0.3s;
        }

        .logout-btn:hover {
            background: rgba(255, 255, 255, 0.3);
        }

        /* 메인 컨테이너 */
        .main-container {
            max-width: 1200px;
            margin: 0 auto;
        }

        .page-title {
            text-align: center;
            color: white;
            font-size: 28px;
            font-weight: 700;
            margin-bottom: 30px;
            text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.2);
        }

        /* 메뉴 그리드 */
        .menu-grid {
            display: grid;
            grid-template-columns: repeat(1, 1fr);
            gap: 20px;
            padding: 0 10px;
        }

        /* 메뉴 카드 */
        .menu-card {
            background: white;
            border-radius: 20px;
            padding: 30px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.2);
            cursor: pointer;
            transition: all 0.3s;
            text-decoration: none;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            min-height: 180px;
            position: relative;
            overflow: hidden;
        }

        .menu-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: linear-gradient(135deg, rgba(102, 126, 234, 0.1) 0%, rgba(118, 75, 162, 0.1) 100%);
            opacity: 0;
            transition: opacity 0.3s;
        }

        .menu-card:hover::before {
            opacity: 1;
        }

        .menu-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 15px 40px rgba(0, 0, 0, 0.3);
        }

        .menu-card:active {
            transform: translateY(-2px);
        }

        /* 비활성 메뉴 */
        .menu-card.disabled {
            opacity: 0.5;
            cursor: not-allowed;
            background: #f5f5f5;
        }

        .menu-card.disabled:hover {
            transform: none;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.2);
        }

        .menu-card.disabled::after {
            content: '준비중';
            position: absolute;
            top: 10px;
            right: 15px;
            background: #ff9800;
            color: white;
            padding: 4px 12px;
            border-radius: 12px;
            font-size: 12px;
            font-weight: 600;
        }

        /* 아이콘 */
        .menu-icon {
            width: 80px;
            height: 80px;
            margin-bottom: 20px;
            background-size: contain;
            background-repeat: no-repeat;
            background-position: center;
            position: relative;
            z-index: 1;
        }

        .icon-overview {
            background-image: url('data:image/svg+xml,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="%23667eea"><path d="M3 13h8V3H3v10zm0 8h8v-6H3v6zm10 0h8V11h-8v10zm0-18v6h8V3h-8z"/></svg>');
        }

        .icon-lot {
            background-image: url('data:image/svg+xml,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="%23764ba2"><path d="M19 3H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm-5 14H7v-2h7v2zm3-4H7v-2h10v2zm0-4H7V7h10v2z"/></svg>');
        }

        .icon-monitoring {
            background-image: url('data:image/svg+xml,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="%234CAF50"><path d="M3.5 18.49l6-6.01 4 4L22 6.92l-1.41-1.41-7.09 7.97-4-4L2 16.99z"/></svg>');
        }

        .icon-report {
            background-image: url('data:image/svg+xml,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="%23FF9800"><path d="M19 3h-4.18C14.4 1.84 13.3 1 12 1c-1.3 0-2.4.84-2.82 2H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm-7 0c.55 0 1 .45 1 1s-.45 1-1 1-1-.45-1-1 .45-1 1-1zm2 14H7v-2h7v2zm3-4H7v-2h10v2zm0-4H7V7h10v2z"/></svg>');
        }

        .icon-settings {
            background-image: url('data:image/svg+xml,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="%23607D8B"><path d="M19.14 12.94c.04-.3.06-.61.06-.94 0-.32-.02-.64-.07-.94l2.03-1.58c.18-.14.23-.41.12-.61l-1.92-3.32c-.12-.22-.37-.29-.59-.22l-2.39.96c-.5-.38-1.03-.7-1.62-.94l-.36-2.54c-.04-.24-.24-.41-.48-.41h-3.84c-.24 0-.43.17-.47.41l-.36 2.54c-.59.24-1.13.57-1.62.94l-2.39-.96c-.22-.08-.47 0-.59.22L2.74 8.87c-.12.21-.08.47.12.61l2.03 1.58c-.05.3-.07.62-.07.94s.02.64.07.94l-2.03 1.58c-.18.14-.23.41-.12.61l1.92 3.32c.12.22.37.29.59.22l2.39-.96c.5.38 1.03.7 1.62.94l.36 2.54c.05.24.24.41.48.41h3.84c.24 0 .44-.17.47-.41l.36-2.54c.59-.24 1.13-.56 1.62-.94l2.39.96c.22.08.47 0 .59-.22l1.92-3.32c.12-.22.07-.47-.12-.61l-2.01-1.58zM12 15.6c-1.98 0-3.6-1.62-3.6-3.6s1.62-3.6 3.6-3.6 3.6 1.62 3.6 3.6-1.62 3.6-3.6 3.6z"/></svg>');
        }

        .icon-admin {
            background-image: url('data:image/svg+xml,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="%23F44336"><path d="M12 1L3 5v6c0 5.55 3.84 10.74 9 12 5.16-1.26 9-6.45 9-12V5l-9-4zm0 10.99h7c-.53 4.12-3.28 7.79-7 8.94V12H5V6.3l7-3.11v8.8z"/></svg>');
        }

        /* 텍스트 */
        .menu-title {
            font-size: 20px;
            font-weight: 700;
            color: #333;
            margin-bottom: 8px;
            position: relative;
            z-index: 1;
        }

        .menu-description {
            font-size: 14px;
            color: #666;
            text-align: center;
            position: relative;
            z-index: 1;
        }

        /* 태블릿 (600px 이상) */
        @media (min-width: 600px) {
            .menu-grid {
                grid-template-columns: repeat(2, 1fr);
                gap: 25px;
            }

            .menu-card {
                min-height: 200px;
            }

            .page-title {
                font-size: 32px;
                margin-bottom: 40px;
            }
        }

        /* PC (900px 이상) */
        @media (min-width: 900px) {
            body {
                padding: 40px;
            }

            .header {
                padding: 30px 0 40px;
            }

            .logo img {
                max-width: 250px;
            }

            .menu-grid {
                grid-template-columns: repeat(3, 1fr);
                gap: 30px;
            }

            .menu-card {
                min-height: 220px;
                padding: 40px;
            }

            .menu-icon {
                width: 90px;
                height: 90px;
            }

            .menu-title {
                font-size: 22px;
            }

            .menu-description {
                font-size: 15px;
            }

            .page-title {
                font-size: 36px;
                margin-bottom: 50px;
            }
        }
    </style>
</head>

<body>
    <div class="header">
        <div class="logo">
            <img src="/line/css/login/logo2.png" alt="로고">
        </div>
        <div class="user-info">
            <span class="user-name" id="userName">사용자님</span>
            <button class="logout-btn" onclick="logout()">로그아웃</button>
        </div>
    </div>

    <div class="main-container">
        <h1 class="page-title">메뉴 선택</h1>

        <div class="menu-grid">
            <!-- ✅ 활성화된 메뉴 -->
            <a href="/line/hand" class="menu-card">
                <div class="menu-icon icon-overview"></div>
                <div class="menu-title">OVERVIEW</div>
                <div class="menu-description">설비 전체 현황 모니터링(가로 화면 권장)</div>
            </a>

            <a href="/line/monitoring/lotProcessorHand" class="menu-card">
                <div class="menu-icon icon-lot"></div>
                <div class="menu-title">LOT PROCESS</div>
                <div class="menu-description">LOT 처리 현황 추적</div>
            </a>


            <a href="/line/monitoring/handTrend" class="menu-card">
                <div class="menu-icon icon-monitoring"></div>
                <div class="menu-title">EQIOMENT TREND</div>
                <div class="menu-description">설비 실시간 데이터(가로 화면 권장)</div>
            </a>



            <div class="menu-card disabled">
                <div class="menu-icon icon-report"></div>
                <div class="menu-title">ALARM</div>
                <div class="menu-description">알람 리스트</div>
            </div>

            <div class="menu-card disabled">
                <div class="menu-icon icon-settings"></div>
                <div class="menu-title">설정</div>
                <div class="menu-description">시스템 환경 설정</div>
            </div>

            <div class="menu-card disabled">
                <div class="menu-icon icon-admin"></div>
                <div class="menu-title">관리자</div>
                <div class="menu-description">사용자 및 권한 관리</div>
            </div>
        </div>
    </div>

    <script>
    // 로그아웃
    function logout() {
        if (confirm('로그아웃 하시겠습니까?')) {
            $.ajax({
                url: '/line/user/logout',
                type: 'POST',
                success: function() {
                    location.href = '/line/monitoring/handLogin';
                },
                error: function() {
                    // 에러 발생 시에도 로그인 페이지로
                    location.href = '/line/monitoring/handLogin';
                }
            });
        }
    }

    // 사용자 정보 로드
    $(document).ready(function() {
        // 세션에서 사용자 정보 가져오기
        $.ajax({
            url: '/line/user/info',
            type: 'GET',
            dataType: 'json',
            success: function(result) {
                if (result.data && result.data.user_name) {
                    $('#userName').text(result.data.user_name + '님');
                }
            },
            error: function() {
                // 세션 없으면 로그인 페이지로
                // location.href = '/line/login';
            }
        });
    });
    </script>
</body>
</html>
