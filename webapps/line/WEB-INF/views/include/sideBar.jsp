<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
<script src="/line/mock/mock-loader.js"></script>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<link rel="stylesheet" href="/line/css/login/style.css">

	<script src="/vendor/ionicons/5.2.3/ionicons.js"></script>  
	<link rel="stylesheet" href="/line/css/sideBar/styles.css">
	<link rel="stylesheet" href="/line/css/login/style2.css">
	<link rel="stylesheet" href="/line/css/headerBar/headerBar.css">
<%@include file="../include/pluginpage.jsp" %>
  
<title>SMART MES</title>
</head>

<style>
	
	* {
	    font-weight: 600;
	    font-family: 'Pretendard', sans-serif;
	    box-sizing: border-box;
	}
	
	body {
	    background-color: #f4f6f9;
	}
	
	
	.row_select {
	    background-color: #9ABCEA !important;
	}
	
	
	.menuDiv {
	    display: flex;
	    align-items: center;
	    width: 92.7%;
	    height: 42px;
	    
	    margin-left: 131px;
	    padding: 8px 14px;
	    border-radius: 14px;
	    box-shadow: 0px 6px 12px rgba(0, 0, 0, 0.12);
	    overflow-x: auto;
	    white-space: nowrap;
	    gap: 8px;  /* 탭 간격 좁히기 */
	    scrollbar-width: none;
	    -ms-overflow-style: none;
	}
	
	.menuDiv::-webkit-scrollbar {
	    display: none;
	}
	
	
	.menuDivTab {
	    text-align: center;
	    cursor: pointer;
	    background: #dfe6ed;
	    border-radius: 10px;
	    padding: 12px 18px;
	    font-size: 14px;
	    font-weight: 700;
	    color: #333;
	    border: 1px solid #ddd;
	    transition: all 0.3s ease-in-out;
	    box-shadow: 0 3px 6px rgba(0, 0, 0, 0.1);
	    user-select: none;
	    display: flex;
	    align-items: center;
	    justify-content: center;
	    gap: 6px;
	    min-width: 100px;
	    height: 43px;
	    flex-shrink: 0;           /* 데모: 탭이 많아도 글자가 줄바꿈·압축되지 않게 */
	    white-space: nowrap;
	    max-width: 220px;
	}
	.menuDivTab .menuName {
	    overflow: hidden;
	    text-overflow: ellipsis;
	    white-space: nowrap;
	    cursor: pointer;
	}
	
	.menuDivTab:hover {
	    background: #f0f2f5;
	    transform: translateY(-2px);
	    box-shadow: 0 4px 8px rgba(0, 0, 0, 0.15);
	}
	/* 데모: 상단 탭 최대 6개 — 공간이 모자라면 탭이 같이 줄어들고 글자는 … 으로 생략 (줄바꿈·잘림 없음) */
.menuDiv { overflow: hidden !important; box-sizing: border-box; max-width: calc(100% - 141px); }
.menuDiv .menuDivTab {
    flex: 0 1 180px; min-width: 0; max-width: 200px;
    height: 36px; padding: 0 8px 0 14px; box-sizing: border-box;
    justify-content: space-between; font-size: 13.5px;
}
.menuDiv .menuDivTab .menuName { flex: 1 1 auto; min-width: 0; text-align: left; }
.menuDiv .menuDivTab .close-btn { flex-shrink: 0; margin-left: 4px; }
.tkLogo {
    width: 180px;
    height: 40px;
    min-width: 180px; max-width: 180px;   /* 데모: 로고 영역 180x40 고정 */
    min-height: 40px; max-height: 40px;
    flex-shrink: 0; overflow: hidden; box-sizing: border-box;
}
/* 데모: 상단 헤더 글자가 줄바꿈되지 않게 (원본은 margin-left:960px 고정) */
.header .headerP { white-space: nowrap; }
.header .loginName { margin-left: auto !important; margin-right: 16px; white-space: nowrap; }
.header .logout-button { white-space: nowrap; flex-shrink: 0; }
/* 데모: 중립 브랜드 로고 (회사 로고 대신) */
.demo-brand { display: flex; align-items: center; gap: 9px; text-decoration: none; padding: 0; }
.demo-brand-mark { width: 34px; height: 34px; flex-shrink: 0; }
.demo-brand-mark svg { width: 100%; height: 100%; display: block; }
.demo-brand-text { display: flex; flex-direction: column; line-height: 1.05; white-space: nowrap; }
.demo-brand-text b { color: #fff; font-size: 17px; font-weight: 800; letter-spacing: .4px; }
.demo-brand-text small { color: #9aa7bd; font-size: 9.5px; font-weight: 600; letter-spacing: 1.4px; margin-top: 3px; }
	.menuDivTab.active {
		background: white; /* 연한 회색 배경 */
	    color: #333; /* 글자색은 기본 유지 */
	    border: 1px solid #ccc;
	    box-shadow: 0 3px 6px rgba(0, 0, 0, 0.1);
	    transform: translateY(-2px);
	}
	
	
	.menuDivTab i {
	    font-size: 16px;
	    color: inherit;
	}
	
	
	.menuDivTab .close-btn {
	    font-size: 19px; 
	    background: none;
	    border: none;
	    color: #888; 
	    cursor: pointer;
	    padding: 0;
	    margin-left: 10px;
	    display: flex;
	    align-items: center; 
	    justify-content: center;
	    transition: color 0.2s ease-in-out;
	}

	
	.menuDivTab .close-btn:hover {
	    color: #ff3b30; 
	}
	
	
	.frameDiv {
	    display: flex;
	    width: 92.7%;
	    height: 90%;
	    background: white;
	    margin-left: 131px;
	    border-radius: 14px;
	    box-shadow: 0px 6px 12px rgba(0, 0, 0, 0.15);
	    overflow: hidden;
	}
	
	.frameDiv #pageFrame {
	    width: 100%;
	    height: 100%;
	    border: none;
	}
</style>

<body>

    <header class="header">
	    <p class="headerP" style="font-size:20px; margin-left:40px; color : white; font-weight:800;"></p>
	    <!-- 로그인정보 표현, 로그아웃 버튼 -->
	    <p class="loginName" style="font-size:20px; margin-left:960px; color : white; font-weight:800;"></p>
        <button class="logout-button">
            <img src="/line/css/headerBar/exit-outline.svg" alt="select" class="button-image">로그아웃	           
        </button>
    </header>

    <div class="hhhh"></div>
    <div class="l-navbar" id="navbar" style="overflow-y: auto;">
        <nav class="nav">
            <div>
			<div class="nav__brand">
			    <a href="#" class="nav__logo" onclick="openWorkMonitoring(); return false;">
			        <span class="demo-brand tkLogo">
			            <span class="demo-brand-mark">
			                <svg viewBox="0 0 40 40" aria-hidden="true">
			                    <defs><linearGradient id="dbg" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="#38bdf8"/><stop offset="1" stop-color="#4f46e5"/></linearGradient></defs>
			                    <rect width="40" height="40" rx="10" fill="url(#dbg)"/>
			                    <rect x="9" y="21" width="5" height="10" rx="1.5" fill="#fff" opacity=".75"/>
			                    <rect x="17.5" y="15" width="5" height="16" rx="1.5" fill="#fff" opacity=".9"/>
			                    <rect x="26" y="9" width="5" height="22" rx="1.5" fill="#fff"/>
			                </svg>
			            </span>
			            <span class="demo-brand-text"><b>SMART MES</b><small>HEAT TREATMENT</small></span>
			        </span>
			    </a>
			</div>
			<div class="nav__list">
<!--  a1 ~ a7 -->
			<div class="nav__link collapse">
				<ion-icon name="folder-outline" class="nav__icon"></ion-icon>
				<span class="nav_name">기준정보</span>
				<ion-icon name="chevron-down-outline" class="collapse__link"></ion-icon>
				<ul class="collapse__menu" id="aMenu"></ul>
			</div>
<!--  b1 ~ b7 -->
			<div class="nav__link collapse">
				<ion-icon name="folder-outline" class="nav__icon"></ion-icon>
				<span class="nav_name">모니터링</span>
				<ion-icon name="chevron-down-outline" class="collapse__link"></ion-icon>
				<ul class="collapse__menu" id="bMenu"></ul>
			</div>
<!--  c1 ~ c7 -->
			<div class="nav__link collapse">
				<ion-icon name="folder-outline" class="nav__icon"></ion-icon>
				<span class="nav_name">생산관리</span>
				<ion-icon name="chevron-down-outline" class="collapse__link"></ion-icon>
				<ul class="collapse__menu" id="cMenu"></ul>
			</div>
<!--  d1 ~ d7 -->
			<div class="nav__link collapse">
				<ion-icon name="desktop-outline"></ion-icon>
				<span class="nav_name">조건관리</span>
				<ion-icon name="chevron-down-outline" class="collapse__link"></ion-icon>
				<ul class="collapse__menu" id="dMenu"></ul>
			</div>
<!--  e1 ~ e7 -->
			<div class="nav__link collapse">
				<ion-icon name="folder-outline" class="nav__icon"></ion-icon>
				<span class="nav_name">품질관리</span>
				<ion-icon name="chevron-down-outline" class="collapse__link"></ion-icon>
				<ul class="collapse__menu" id="eMenu"></ul>
			</div>
			<div class="nav__link collapse">
				<ion-icon name="folder-outline" class="nav__icon"></ion-icon>
				<span class="nav_name">설비관리</span>
				<ion-icon name="chevron-down-outline" class="collapse__link"></ion-icon>
				<ul class="collapse__menu" id="fMenu"></ul>
			</div>

		
		</div>
	</div>
</nav>
    </div>
    
    <div class="menuDiv"></div>
    <div class="frameDiv">
		 <iframe id="pageFrame" src="/line/monitoring/workMonitoring" frameborder="0" width="100%" height="100%"></iframe>
    </div>
   <script>
     //로드
     
     
      
      $(document).on('click', '.menuDivTab', function () {
        // 기존 active 클래스 제거
        $('.menuDivTab').removeClass('active');

        // 현재 클릭된 탭에 active 클래스 추가
        $(this).addClass('active');
    });
     $(function(){
 		var loginInfo = "${loginUser.user_name}";


		$(".loginName").text(loginInfo+"님 로그인");
		loginUserMenuSetting();
		menuList();
		
     });
     
    //이벤트
   	$(".logout-button").on("click",function(){
   		$.ajax({
   			url:"/line/user/logout",
   			type:"get",
   			dataTypa:"json",
   			success:function(result){
   				location.href = "/line";
   			}
   		});
   	});    
     
     
    //함수
	function loginUserMenuSetting(){
		$.ajax({
			url:"/line/user/login/menuSetting",
			type:"post",
			dataType:"json",
			success:function(result){

				var data = result.data;
				var idx = 0;
				var user_code = 0;
				for(let key in data){
//					console.log(key);
					if(key == "user_code"){
						user_code = data[key];
					}
					
					

					if(key != "perm_code" && key != "user_code"){
						if(data[key] != null && data[key] != "N"){
							//console.log(data[key]);
							//console.log(pageObject(key));
							var _link = pageObject(key)[0];
							var _name = pageObject(key)[1];
							
							var _group = "";
							var _groupID = "";

							if(key.indexOf("a") != -1){
								_group = "기준정보";
								_groupID = "aMenu";
							}else if(key.indexOf("b") != -1){
								_group = "모니터링";
								_groupID = "bMenu";
							}else if(key.indexOf("c") != -1){
								_group = "생산관리";
								_groupID = "cMenu";
							}else if(key.indexOf("d") != -1){
								_group = "조건관리";
								_groupID = "dMenu";
							}else if(key.indexOf("e") != -1){
								_group = "품질관리";
								_groupID = "eMenu";
							}else if(key.indexOf("f") != -1){
								_group = "설비관리";
								_groupID = "fMenu";
							}/*else if(key.indexOf("g") != -1){
								_group = "취출 운전관리";
								_groupID = "gMenu";
							}else if(key.indexOf("h") != -1){
								_group = "설비관리";
								_groupID = "hMenu";
							}else if(key.indexOf("i") != -1){
								_group = "문서관리";
								_groupID = "iMenu";
							}else if(key.indexOf("j") != -1){
								_group = "AGV관리";
								_groupID = "jMenu";
							}else if(key.indexOf("k") != -1){
								_group = "세척관리";
								_groupID = "kMenu";
							} */
							
							if(key == "e03"){
								
							}
							
							_group_t = _group.replace(/\s/gi,"&nbsp;");
							_name_t = _name.replace(/\s/gi,"&nbsp;");
//							console.log(_group_t, _name_t);
							var _menu = "<li>";
							_menu += "<a class='collapse__sublink' onClick=updateHeaderAndNavigate(event,'"+_link+"','"+_name_t+"','"+_group_t+"');>"+_name+"</a>"
							_menu += "</li>";
							
							$("#"+_groupID).append(_menu);
							if(idx == 0){
//								iframeSrc(_link,(_group+"-"+_name));
							}
							idx++;
						}
					}
				}				
			}
		});
    }
    	function openWorkMonitoring() {
	    document.getElementById("pageFrame").src = "/line/monitoring/workMonitoring";
	}

   	function iframeSrc(url, menuGroupName){
   		$("#pageFrame").attr("src",url);
   		$(".headerP").text(menuGroupName);
   	}
    
        // 메뉴 클릭 시 헤더 업데이트
	function updateHeader(menuGroupName) {
//		document.getElementById('header-title').innerText = menuName;
	}


    // 메뉴 닫기 x
	function updateHeaderAndNavigate(event, url, menuGroupName) {
		  event.preventDefault(); 
		  event.stopPropagation();  // 이벤트 전파 차단 (부모로 클릭 이벤트 안 전달)
		  
		  iframeSrc(url, menuGroupName);
		  var loginCode = "${loginUser.user_code}";
		  var menuUrl = url;
		  var menuName = menuGroupName;

		  menuSave(loginCode, menuUrl, menuName);
		}
        
	function menuSave(loginCode, menuUrl, menuName){
		$.ajax({
			url:"/line/user/login/menuSave",
			type:"post",
			dataType:"json",
			data:{
				"user_code":loginCode,
				"menu_url":menuUrl,
				"menu_name":menuName
			},
			success:function(result){     			
				menuList();
			}
		});
	}
	
	function menuList(){
	    var loginCode = "${loginUser.user_code}";
	    
	    $.ajax({
	        url:"/line/user/login/menuList",
	        type:"post",
	        dataType:"json",
	        data:{
	            "user_code":loginCode
	        },
	        success:function(result){
	            // 데모: 탭은 최근 MAX_TABS 개만, 이름에 공백이 있어도 깨지지 않도록 DOM으로 생성
	            var MAX_TABS = 6;
	            var data = (result.data || []).slice(-MAX_TABS);
	            var current = $("#pageFrame").attr("src");
	            $(".menuDiv").empty();

	            data.forEach(function (m) {
	                var menuName = String(m.menu_name || "");
	                menuName = menuName.substring(menuName.indexOf("-") + 1).replace(/&nbsp;/g, " ");

	                var $tab = $("<div class='menuDivTab'></div>").attr("title", menuName)
	                    .toggleClass("active", m.menu_url === current)
	                    .on("click", function () { iframeSrc(m.menu_url, menuName); });
	                $("<label class='menuName'></label>").text(menuName).appendTo($tab);
	                $("<button class='close-btn'>×</button>")
	                    .on("click", function (e) { e.stopPropagation(); removeMenu(m.menu_url); })
	                    .appendTo($tab);
	                $(".menuDiv").append($tab);
	            });
	        }
	    });
	}



	
    // DOMContentLoaded 이벤트로 DOM이 준비된 후 스크립트 실행
  document.addEventListener('DOMContentLoaded', function () {
  const collapseItems = document.querySelectorAll('.nav__link.collapse');

  collapseItems.forEach(item => {
    item.addEventListener('click', function () {
      const collapseMenu = this.querySelector('.collapse__menu');
      const icon = this.querySelector('.collapse__link');

      // 펼침 상태 토글
      collapseMenu.classList.toggle('showCollapse');

      // 아이콘 회전
      icon.classList.toggle('rotate');
    });
  });
});




    
/*
    //상단 메뉴 삭제
function removeMenu2(button) {
    var loginCode = "${loginUser.user_code}";


    var label = $(button).siblings('.menuName');
    var onclickAttr = label.attr('onclick');
    var match = onclickAttr.match(/iframeSrc\('([^']+)'/);
    var menuUrl = match ? match[1] : null;

    console.log("user_code:", loginCode);
    console.log("menu_url:", menuUrl);

    if (!menuUrl) {
        console.error("삭제할 메뉴의 URL이 없습니다.");
        return;
    }

    $.ajax({
        url: "/geomet/user/login/menuRemove",
        type: "post",
        dataType: "json",
        data: {
            "user_code": loginCode,
            "menu_url": menuUrl
        },
        success: function(result) {
            menuList();
        }
    });

    var menuName = label.text().trim(); 
    console.log(menuName + " 메뉴 엑스.");

    $(button).parent().remove();
    }
*/



function removeMenu(url) {
	var loginCode = "${loginUser.user_code}";		   

	   
   $.ajax({
	  url:"/line/user/login/menuRemove",
	  type:"post",
	  dataType:"json",
	  data:{
		  "user_code":loginCode,
		  "menu_url":url},
	  success:function(result){
		  menuList();
	  }
   });
/*
   console.log(button);
   
   var menuName = $(button).siblings('.menuName').text(); 
   console.log(menuName + " 메뉴 엑스 .");

   $(button).parent().remove();
*/
}	



    
/*
    //상단 메뉴 삭제
function removeMenu2(button) {
    var loginCode = "${loginUser.user_code}";


    var label = $(button).siblings('.menuName');
    var onclickAttr = label.attr('onclick');
    var match = onclickAttr.match(/iframeSrc\('([^']+)'/);
    var menuUrl = match ? match[1] : null;

    console.log("user_code:", loginCode);
    console.log("menu_url:", menuUrl);

    if (!menuUrl) {
        console.error("삭제할 메뉴의 URL이 없습니다.");
        return;
    }

    $.ajax({
        url: "/line/user/login/menuRemove",
        type: "post",
        dataType: "json",
        data: {
            "user_code": loginCode,
            "menu_url": menuUrl
        },
        success: function(result) {
            menuList();
        }
    });

    var menuName = label.text().trim(); 
    console.log(menuName + " 메뉴 엑스.");

    $(button).parent().remove();
    }
*/



function removeMenu(url) {
	var loginCode = "${loginUser.user_code}";		   

	   
   $.ajax({
	  url:"/line/user/login/menuRemove",
	  type:"post",
	  dataType:"json",
	  data:{
		  "user_code":loginCode,
		  "menu_url":url},
	  success:function(result){
		  menuList();
	  }
   });
/*
   console.log(button);
   
   var menuName = $(button).siblings('.menuName').text(); 
   console.log(menuName + " 메뉴 엑스 .");

   $(button).parent().remove();
*/
}	

        
    </script>
    
    
</body>
</html>