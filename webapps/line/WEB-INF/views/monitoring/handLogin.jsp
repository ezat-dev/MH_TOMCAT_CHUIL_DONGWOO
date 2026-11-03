<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<script src="/line/mock/mock-loader.js"></script>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <title>MES - 로그인</title>
    
    <script src="/vendor/jquery/3.7.1/jquery.min.js"></script>

    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
            background: linear-gradient(135deg, #1e3c72 0%, #2a5298 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }

        #wrap_login {
            width: 100%;
            max-width: 420px;
        }

        .login_container {
            background: white;
            border-radius: 20px;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
            overflow: hidden;
        }

        /* 로고 영역 */
        .header {
            background: white;
            padding: 40px 30px 30px;
            text-align: center;
        }

        .logo {
            display: flex;
            align-items: center;
            justify-content: center;
            min-height: 180px;
        }

        .logo img {
            max-width: 100%;
            height: auto;
            width: auto;
            max-height: 180px;
            object-fit: contain;
            display: block;
        }

        /* 컨텐츠 */
        .content {
            padding: 30px;
        }

        .visual_box {
            display: none;
        }

        /* 로그인 폼 */
        .login_box {
            width: 100%;
        }

        .notice {
            margin-bottom: 25px;
            text-align: center;
        }

        .tit_bar {
            margin-bottom: 10px;
        }

        .tit {
            font-size: 20px;
            font-weight: 600;
            color: #333;
            margin: 0;
        }

        .bu_lst {
            list-style: none;
            padding: 0;
            margin: 0;
            font-size: 14px;
            color: #666;
        }

        .bu_lst li {
            padding: 5px 0;
        }

        /* 입력 필드 */
        .login_frm {
            width: 100%;
        }

        .ip_box {
            list-style: none;
            padding: 0;
            margin: 0 0 20px 0;
        }

        .ip_box li {
            margin-bottom: 15px;
        }

        .input_txt {
            display: block;
            position: relative;
        }

        .input_txt input {
            width: 100%;
            padding: 16px 50px 16px 20px;
            border: 2px solid #e0e0e0;
            border-radius: 12px;
            font-size: 16px;
            transition: all 0.3s;
            outline: none;
            background: #fafafa;
        }

        .input_txt input:focus {
            border-color: #2a5298;
            background: white;
            box-shadow: 0 0 0 4px rgba(42, 82, 152, 0.1);
        }

        .input_txt input::placeholder {
            color: #aaa;
        }

        /* 아이콘 */
        .input_txt .ico {
            position: absolute;
            right: 16px;
            top: 50%;
            transform: translateY(-50%);
            width: 22px;
            height: 22px;
            background-size: contain;
            background-repeat: no-repeat;
            opacity: 0.4;
        }

        .ico_login-id {
            background-image: url('data:image/svg+xml,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="%232a5298"><path d="M12 12c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm0 2c-2.67 0-8 1.34-8 4v2h16v-2c0-2.66-5.33-4-8-4z"/></svg>');
        }

        .ico_login-pw {
            background-image: url('data:image/svg+xml,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="%232a5298"><path d="M18 8h-1V6c0-2.76-2.24-5-5-5S7 3.24 7 6v2H6c-1.1 0-2 .9-2 2v10c0 1.1.9 2 2 2h12c1.1 0 2-.9 2-2V10c0-1.1-.9-2-2-2zm-6 9c-1.1 0-2-.9-2-2s.9-2 2-2 2 .9 2 2-.9 2-2 2zm3.1-9H8.9V6c0-1.71 1.39-3.1 3.1-3.1 1.71 0 3.1 1.39 3.1 3.1v2z"/></svg>');
        }

        /* 로그인 버튼 */
        .btn_login {
            margin-top: 20px;
        }

        #btnLogin {
            width: 100%;
            padding: 18px;
            background: linear-gradient(135deg, #1e3c72 0%, #2a5298 100%);
            border: none;
            border-radius: 12px;
            color: white;
            font-size: 18px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s;
            box-shadow: 0 4px 15px rgba(42, 82, 152, 0.4);
            letter-spacing: 2px;
        }

        #btnLogin:active {
            transform: translateY(2px);
            box-shadow: 0 2px 8px rgba(42, 82, 152, 0.3);
        }

        #btnLogin span {
            display: inline-block;
        }

        /* 로딩 상태 */
        #btnLogin.loading {
            pointer-events: none;
            opacity: 0.7;
            position: relative;
        }

        #btnLogin.loading span {
            visibility: hidden;
        }

        #btnLogin.loading::after {
            content: "";
            position: absolute;
            width: 20px;
            height: 20px;
            top: 50%;
            left: 50%;
            margin: -10px 0 0 -10px;
            border: 3px solid rgba(255, 255, 255, 0.3);
            border-top-color: white;
            border-radius: 50%;
            animation: spin 0.6s linear infinite;
        }

        @keyframes spin {
            to { transform: rotate(360deg); }
        }

        /* 에러 메시지 */
        .error-message {
            display: none;
            padding: 14px;
            margin-bottom: 15px;
            background: #fee;
            border: 1px solid #fcc;
            border-radius: 10px;
            color: #c33;
            font-size: 14px;
            text-align: center;
            font-weight: 500;
        }

        .error-message.show {
            display: block;
            animation: slideDown 0.3s ease-out;
        }

        @keyframes slideDown {
            from {
                opacity: 0;
                transform: translateY(-10px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        /* 숨김 요소 */
        .hide {
            position: absolute;
            width: 1px;
            height: 1px;
            overflow: hidden;
            clip: rect(0, 0, 0, 0);
        }

        /* 태블릿 (600px 이상) */
        @media (min-width: 600px) {
            body {
                padding: 40px;
            }

            #wrap_login {
                max-width: 480px;
            }

            .header {
                padding: 50px 40px 40px;
            }

            .logo {
                min-height: 240px;
            }

            .logo img {
                max-height: 240px;
            }

            .content {
                padding: 40px;
            }

            .tit {
                font-size: 22px;
            }

            .input_txt input {
                padding: 18px 55px 18px 22px;
                font-size: 17px;
            }

            #btnLogin {
                padding: 20px;
                font-size: 19px;
            }
        }

        /* PC (900px 이상) */
        @media (min-width: 900px) {
            #wrap_login {
                max-width: 500px;
            }

            .header {
                padding: 60px 50px 50px;
            }

            .logo {
                min-height: 250px;
            }

            .logo img {
                max-height: 250px;
            }

            .content {
                padding: 50px;
            }

            .notice {
                margin-bottom: 30px;
            }

            .tit {
                font-size: 24px;
            }
        }

        /* 가로 모드 (모바일) */
        @media (max-height: 600px) and (orientation: landscape) {
            body {
                padding: 10px;
            }

            .header {
                padding: 20px 30px 15px;
            }

            .logo {
                min-height: 150px;
            }

            .logo img {
                max-height: 150px;
            }

            .content {
                padding: 20px 30px;
            }

            .notice {
                margin-bottom: 15px;
            }

            .tit {
                font-size: 16px;
            }

            .input_txt input {
                padding: 12px 45px 12px 16px;
                font-size: 15px;
            }

            .ip_box li {
                margin-bottom: 10px;
            }

            #btnLogin {
                padding: 14px;
                font-size: 16px;
            }
        }
    </style>
</head>

<body id="login_body">
    <div id="wrap_login" class="login_gw7">
        <div class="login_container">
            <div class="header">
                <div class="logo">
                    <img id="login_img_logo" src="/line/css/login/logo2.png" alt="로고">
                </div>
            </div>
            
            <hr class="hide">
            
            <div class="content" id="login_layout_content">
                <div id="login_imgbox" class="visual_box">
                    <img id="login_img_loginBanner" src="/line/css/login/vt2.jpg" alt="">
                </div>
                
                <div class="login_box">
                    <div class="notice">
                        <div class="tit_bar">
                            <!-- <h3 class="tit">공지사항</h3> -->
                        </div>
                        <ul id="login_noticeCont_ul" class="bu_lst">
                            <!-- 공지사항 내용 -->
                        </ul>
                    </div>
                    
                    <div class="login">
                        <div id="error-container" class="error-message"></div>
                        
                        <form id="userForm" class="omb_loginForm" role="form" 
                              action="login_ok.jsp" method="post">
                            <div class="login_frm">
                                <div id="login_loginBox">
                                    <ul id="loginIdType1" class="ip_box">
                                        <li class="info id">
                                            <label class="input_txt">
                                                <input id="userId" name="user_id" class="input_id" 
                                                       type="text" autocomplete="off" 
                                                       placeholder="아이디" required>
                                                <i class="ico ico_login-id"></i>
                                            </label>
                                        </li>
                                        <li class="info pw">
                                            <label class="input_txt">
                                                <input id="password" name="user_pw" type="password" 
                                                       autocomplete="new-password" class="input_pw" 
                                                       placeholder="비밀번호" required>
                                                <i class="ico ico_login-pw"></i>
                                            </label>
                                        </li>
                                    </ul>
                                </div>
                                
                                <div class="btn_login">
                                    <button id="btnLogin" type="submit">
                                        <span>L</span><span>O</span><span>G</span><span>I</span><span>N</span>
                                    </button>
                                </div>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script>
    // 에러 메시지 표시
    function showError(message) {
        const errorDiv = $("#error-container");
        errorDiv.text(message).addClass("show");
        
        setTimeout(() => {
            errorDiv.removeClass("show");
        }, 3000);
    }

    // 폼 제출
    $("#userForm").on("submit", function (e) {
        e.preventDefault();
        login();
    });

    // 로그인 처리
    function login() {
        const userId = $("#userId").val().trim();
        const userPw = $("#password").val().trim();

        // 유효성 검사
        if (!userId) {
            showError("아이디를 입력해주세요");
            $("#userId").focus();
            return;
        }

        if (!userPw) {
            showError("비밀번호를 입력해주세요");
            $("#password").focus();
            return;
        }

        // 로딩 상태
        const btn = $("#btnLogin");
        btn.addClass("loading").prop("disabled", true);

        var userData = new FormData($("#userForm")[0]);

        $.ajax({
            url: "/line/user/login/check",
            type: "post",
            contentType: false,
            processData: false,
            dataType: "json",
            data: userData,
            success: function(result) {
                if (result.data && result.data.user_code) {
                    // 로그인 성공
                    saveLoginLog(result.data.user_code);
                    location.href = "/line/monitoring/handMain";
                } else {
                    btn.removeClass("loading").prop("disabled", false);
                    showError("아이디 또는 비밀번호를 확인해주세요");
                    $("#password").val("").focus();
                }
            },
            error: function(xhr) {
                btn.removeClass("loading").prop("disabled", false);
                
                if (xhr.status === 401) {
                    showError("아이디 또는 비밀번호를 확인해주세요");
                } else {
                    showError("서버 오류가 발생했습니다");
                }
                
                $("#password").val("").focus();
            }
        });
    }

    // 로그인 로그 저장
    function saveLoginLog(userCode) {
        $.ajax({
            url: "/line/user/login/log",
            type: "post",
            data: {
                user_code: userCode,
                memo: "로그인 성공"
            }
        });
    }

    // 페이지 로드 시 포커스
    $(document).ready(function() {
        $("#userId").focus();
    });
    </script>
</body>
</html>
