<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="ko">
<head>
<script src="/line/mock/mock-loader.js"></script>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>오버뷰</title>
	<%@include file="../include/pluginpage.jsp" %>    
    <jsp:include page="../include/tabBar.jsp"/>
</head>
  <style>
  
  
  
  
  
  
  
    /* V 계열 (숨김/보임) */
    .hidden { display: none; }

    /* C 계열 (초록색 글씨) */
    .active-green { color: green !important; }

/* A 계열 (회전 애니메이션) */
@keyframes rotate {
  0%   { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}
.rotating {
  animation: rotate 5s linear infinite; /* 2s → 5s */
}

/* VS-text 계열 (깜빡임) */
@keyframes blink {
  0%, 50%, 100% { opacity: 1; }
  25%, 75%      { opacity: 0; }
}
.blinking {
  animation: blink 3s infinite; /* 1s → 3s */
}


    /* 버튼 스타일 */
    #toggleBtn {
      padding: 10px 20px;
      margin: 10px;
      background: #444;
      color: #fff;
      border: none;
      border-radius: 5px;
      cursor: pointer;
    }
    #toggleBtn.active {
      background: green;
    }
  
  
  
  
  
  
  .div1 table td, .div2 table td {
    font-weight: bold;
    padding: 10px;
    text-align: center;
}

  
   a,
   button,
   input,
   select,
   h1,
   h2,
   h3,
   h4,
   h5,
   * {
       box-sizing: border-box;
       margin: 0;
       padding: 0;
       border: none;
       text-decoration: none;
       background: none;
   
       -webkit-font-smoothing: antialiased;
   }
   
   menu, ol, ul {
       list-style-type: none;
       margin: 0;
       padding: 0;
   }
   
   .group-5,
.group-5 * {
  box-sizing: border-box;
}
.group-5 {
  height: 518px;
  position: relative;
}
.c-text-6 {
  background: #ff4444;
  width: 11px;
  height: 19px;
  position: absolute;
  left: 71px;
  top: 201px;
}
.rectangle-3 {
  background: #ff4444;
  width: 11px;
  height: 19px;
  position: absolute;
  left: 116px;
  top: 201px;
}
.rectangle-2 {
  background: #ff4444;
  width: 11px;
  height: 19px;
  position: absolute;
  left: 94px;
  top: 201px;
}
.v-text-22 {
  background: #ff4444;
  width: 11px;
  height: 19px;
  position: absolute;
  left: 940px;
  top: 249px;
}
.v-text-222 {
  background: #ff4444;
  width: 11px;
  height: 19px;
  position: absolute;
  left: 981px;
  top: 249px;
}
.v-text-223 {
  background: #ff4444;
  width: 11px;
  height: 19px;
  position: absolute;
  left: 961px;
  top: 249px;
}
.v-heater-2 {
  background: #ff4444;
  width: 11px;
  height: 19px;
  position: absolute;
  left: 1615px;
  top: 285px;
}
.v-heater-22 {
  background: #ff4444;
  width: 11px;
  height: 19px;
  position: absolute;
  left: 1660px;
  top: 285px;
}
.v-heater-23 {
  background: #ff4444;
  width: 11px;
  height: 19px;
  position: absolute;
  left: 1638px;
  top: 285px;
}
.c-text {
  color: rgba(0, 0, 0, 0.47);
  text-align: left;
  font-family: "Inter-Bold", sans-serif;
  font-size: 14px;
  font-weight: 700;
  position: absolute;
  left: 66px;
  top: 313px;
  width: 99px;
  height: 26px;
}
.c-text-7 {
  color: rgba(0, 0, 0, 0.47);
  text-align: left;
  font-family: "Inter-Bold", sans-serif;
  font-size: 14px;
  font-weight: 700;
  position: absolute;
  left: 266px;
  top: 129px;
  width: 62px;
  height: 18px;
}
.c-text-8 {
  color: rgba(0, 0, 0, 0.47);
  text-align: left;
  font-family: "Inter-Bold", sans-serif;
  font-size: 14px;
  font-weight: 700;
  position: absolute;
  left: 382px;
  top: 295px;
  width: 62px;
  height: 18px;
}
.c-text-11 {
  color: rgba(0, 0, 0, 0.47);
  text-align: left;
  font-family: "Inter-Bold", sans-serif;
  font-size: 14px;
  font-weight: 700;
  position: absolute;
  left: 738px;
  top: 201px;
  width: 93px;
  height: 18px;
}
.input-text {
  color: #f70202;
  text-align: left;
  font-family: "Inter-Bold", sans-serif;
  font-size: 15px;
  font-weight: 700;
  position: absolute;
  left: 536px;
  top: 123px;
  width: 63px;
  height: 18px;
}
.input-text2 {
  color: #f70202;
  text-align: left;
  font-family: "Inter-Bold", sans-serif;
  font-size: 15px;
  font-weight: 700;
  position: absolute;
  left: 766px;
  top: 139px;
  width: 63px;
  height: 18px;
}
.input-text3 {
  color: #f70202;
  text-align: left;
  font-family: "Inter-Bold", sans-serif;
  font-size: 15px;
  font-weight: 700;
  position: absolute;
  left: 1365px;
  top: 130px;
  width: 51px;
  height: 18px;
}
.input-text4 {
  color: #f70202;
  text-align: left;
  font-family: "Inter-Bold", sans-serif;
  font-size: 15px;
  font-weight: 700;
  position: absolute;
  left: 1002px;
  top: 139px;
  width: 80px;
  height: 18px;
}
.v-text {
  color: #f70202;
  text-align: left;
  font-family: "Inter-Bold", sans-serif;
  font-size: 15px;
  font-weight: 700;
  position: absolute;
  left: 382px;
  top: 313px;
  width: 63px;
  height: 18px;
}
.c-text-15 {
  color: rgba(0, 0, 0, 0.47);
  text-align: left;
  font-family: "Inter-Bold", sans-serif;
  font-size: 14px;
  font-weight: 700;
  position: absolute;
  left: 952px;
  top: 174px;
  width: 62px;
  height: 18px;
}
.c-text-23 {
  color: rgba(0, 0, 0, 0.47);
  text-align: left;
  font-family: "Inter-Bold", sans-serif;
  font-size: 14px;
  font-weight: 700;
  position: absolute;
  left: 1113px;
  top: 178px;
  width: 62px;
  height: 18px;
}
.c-text-24 {
  color: rgba(0, 0, 0, 0.47);
  text-align: left;
  font-family: "Inter-Bold", sans-serif;
  font-size: 14px;
  font-weight: 700;
  position: absolute;
  left: 1550px;
  top: 341px;
  width: 62px;
  height: 18px;
}
.c-text-152 {
  color: rgba(0, 0, 0, 0.47);
  text-align: left;
  font-family: "Inter-Bold", sans-serif;
  font-size: 14px;
  font-weight: 700;
  position: absolute;
  left: 1722px;
  top: 196px;
  width: 62px;
  height: 18px;
}
.c-text-31 {
  color: #f70202;
  text-align: left;
  font-family: "Inter-Bold", sans-serif;
  font-size: 15px;
  font-weight: 700;
  position: absolute;
  left: 952px;
  top: 192px;
  width: 63px;
  height: 18px;
}
.v-text-3 {
  color: #f70202;
  text-align: left;
  font-family: "Inter-Bold", sans-serif;
  font-size: 15px;
  font-weight: 700;
  position: absolute;
  left: 1555px;
  top: 359px;
  width: 63px;
  height: 18px;
}
.v-text-32 {
  color: #f70202;
  text-align: left;
  font-family: "Inter-Bold", sans-serif;
  font-size: 15px;
  font-weight: 700;
  position: absolute;
  left: 1629px;
  top: 397px;
  width: 63px;
  height: 18px;
}
.v-text-33 {
  color: #f70202;
  text-align: left;
  font-family: "Inter-Bold", sans-serif;
  font-size: 15px;
  font-weight: 700;
  position: absolute;
  left: 1790px;
  top: 397px;
  width: 174px;
  height: 18px;
}
.c-text-1 {
  color: rgba(0, 0, 0, 0.47);
  text-align: left;
  font-family: "Inter-Bold", sans-serif;
  font-size: 14px;
  font-weight: 700;
  position: absolute;
  left: 66px;
  top: 336px;
  width: 99px;
  height: 26px;
}
.c-text-5 {
  color: rgba(0, 0, 0, 0.47);
  text-align: left;
  font-family: "Inter-Bold", sans-serif;
  font-size: 14px;
  font-weight: 700;
  position: absolute;
  left: 66px;
  top: 430px;
  width: 99px;
  height: 26px;
}
.c-text-12 {
  color: rgba(0, 0, 0, 0.47);
  text-align: left;
  font-family: "Inter-Bold", sans-serif;
  font-size: 14px;
  font-weight: 700;
  position: absolute;
  left: 873px;
  top: 350px;
  width: 69px;
  height: 26px;
}
.c-text-62 {
  color: rgba(0, 0, 0, 0.47);
  text-align: left;
  font-family: "Inter-Bold", sans-serif;
  font-size: 14px;
  font-weight: 700;
  position: absolute;
  left: 66px;
  top: 453px;
  width: 99px;
  height: 26px;
}
.c-text-4 {
  color: rgba(0, 0, 0, 0.47);
  text-align: left;
  font-family: "Inter-Bold", sans-serif;
  font-size: 14px;
  font-weight: 700;
  position: absolute;
  left: 66px;
  top: 406px;
  width: 132px;
  height: 26px;
}
.c-text-3 {
  color: rgba(0, 0, 0, 0.47);
  text-align: left;
  font-family: "Inter-Bold", sans-serif;
  font-size: 14px;
  font-weight: 700;
  position: absolute;
  left: 66px;
  top: 383px;
  width: 171px;
  height: 26px;
}
.c-text-13 {
  color: rgba(0, 0, 0, 0.47);
  text-align: left;
  font-family: "Inter-Bold", sans-serif;
  font-size: 14px;
  font-weight: 700;
  position: absolute;
  left: 873px;
  top: 389px;
  width: 99px;
  height: 26px;
}
.c-text-14 {
  color: rgba(0, 0, 0, 0.47);
  text-align: left;
  font-family: "Inter-Bold", sans-serif;
  font-size: 14px;
  font-weight: 700;
  position: absolute;
  left: 873px;
  top: 410px;
  width: 99px;
  height: 26px;
}
.c-text-2 {
  color: rgba(0, 0, 0, 0.47);
  text-align: left;
  font-family: "Inter-Bold", sans-serif;
  font-size: 14px;
  font-weight: 700;
  position: absolute;
  left: 66px;
  top: 360px;
  width: 99px;
  height: 26px;
}
.c-text-16 {
  color: rgba(0, 0, 0, 0.47);
  text-align: left;
  font-family: "Inter-Bold", sans-serif;
  font-size: 14px;
  font-weight: 700;
  position: absolute;
  left: 1073px;
  top: 350px;
  width: 99px;
  height: 26px;
}
.c-text-17 {
  color: rgba(0, 0, 0, 0.47);
  text-align: left;
  font-family: "Inter-Bold", sans-serif;
  font-size: 14px;
  font-weight: 700;
  position: absolute;
  left: 1073px;
  top: 367px;
  width: 99px;
  height: 26px;
}
.c-text-21 {
  color: rgba(0, 0, 0, 0.47);
  text-align: left;
  font-family: "Inter-Bold", sans-serif;
  font-size: 14px;
  font-weight: 700;
  position: absolute;
  left: 1073px;
  top: 439px;
  width: 99px;
  height: 26px;
}
.c-text-22 {
  color: rgba(0, 0, 0, 0.47);
  text-align: left;
  font-family: "Inter-Bold", sans-serif;
  font-size: 14px;
  font-weight: 700;
  position: absolute;
  left: 1073px;
  top: 458px;
  width: 99px;
  height: 26px;
}
.c-text-20 {
  color: rgba(0, 0, 0, 0.47);
  text-align: left;
  font-family: "Inter-Bold", sans-serif;
  font-size: 14px;
  font-weight: 700;
  position: absolute;
  left: 1073px;
  top: 420px;
  width: 117px;
  height: 26px;
}
.c-text-19 {
  color: rgba(0, 0, 0, 0.47);
  text-align: left;
  font-family: "Inter-Bold", sans-serif;
  font-size: 14px;
  font-weight: 700;
  position: absolute;
  left: 1073px;
  top: 403px;
  width: 150px;
  height: 26px;
}
.c-text-27 {
  color: rgba(0, 0, 0, 0.47);
  text-align: left;
  font-family: "Inter-Bold", sans-serif;
  font-size: 14px;
  font-weight: 700;
  position: absolute;
  left: 1602px;
  top: 443px;
  width: 99px;
  height: 22px;
}
.c-text-28 {
  color: rgba(0, 0, 0, 0.47);
  text-align: left;
  font-family: "Inter-Bold", sans-serif;
  font-size: 14px;
  font-weight: 700;
  position: absolute;
  left: 1602px;
  top: 459px;
  width: 99px;
  height: 23px;
}
.c-text-26 {
  color: rgba(0, 0, 0, 0.47);
  text-align: left;
  font-family: "Inter-Bold", sans-serif;
  font-size: 14px;
  font-weight: 700;
  position: absolute;
  left: 1602px;
  top: 428px;
  width: 117px;
  height: 23px;
}
.c-text-25 {
  color: rgba(0, 0, 0, 0.47);
  text-align: left;
  font-family: "Inter-Bold", sans-serif;
  font-size: 14px;
  font-weight: 700;
  position: absolute;
  left: 1602px;
  top: 411px;
  width: 140px;
  height: 23px;
}
.c-text-18 {
  color: rgba(0, 0, 0, 0.47);
  text-align: left;
  font-family: "Inter-Bold", sans-serif;
  font-size: 14px;
  font-weight: 700;
  position: absolute;
  left: 1073px;
  top: 385px;
  width: 99px;
  height: 26px;
}
.clean {
  color: #e70202;
  text-align: left;
  font-family: "Inter-Bold", sans-serif;
  font-size: 15px;
  font-weight: 700;
  position: absolute;
  left: 92px;
  top: 164px;
  width: 63px;
  height: 18px;
}
.a-pump {
  width: 39px;
  height: 39px;
  position: absolute;
  left: 186px;
  top: 132px;
  object-fit: cover;
  aspect-ratio: 1;
}
.a-text-11 {
  width: 39px;
  height: 39px;
  position: absolute;
  left: 718px;
  top: 162px;
  object-fit: cover;
  aspect-ratio: 1;
}
.a-pump-1 {
  width: 42px;
  height: 42px;
  position: absolute;
  left: 839px;
  top: 209px;
  object-fit: cover;
  aspect-ratio: 1;
}
.a-pump-2 {
  width: 36px;
  height: 36px;
  position: absolute;
  left: 1042px;
  top: 188px;
  object-fit: cover;
  aspect-ratio: 1;
}
.a-text-7 {
  width: 38px;
  height: 38px;
  position: absolute;
  left: 225px;
  top: 125px;
  object-fit: cover;
  aspect-ratio: 1;
}
.a-text-8 {
  width: 38px;
  height: 38px;
  position: absolute;
  left: 393px;
  top: 251px;
  object-fit: cover;
  aspect-ratio: 1;
}
.a-text-72 {
  width: 38px;
  height: 38px;
  position: absolute;
  left: 82px;
  top: 243px;
  object-fit: cover;
  aspect-ratio: 1;
}
.a-fan {
  width: 41px;
  height: 41px;
  position: absolute;
  left: 471px;
  top: 176px;
  object-fit: cover;
  aspect-ratio: 1;
}
.a-fan-3 {
  width: 41px;
  height: 41px;
  position: absolute;
  left: 664px;
  top: 176px;
  object-fit: cover;
  aspect-ratio: 1;
}
.a-fan-5 {
  width: 41px;
  height: 41px;
  position: absolute;
  left: 1257px;
  top: 207px;
  object-fit: cover;
  aspect-ratio: 1;
}
.a-fan-9 {
  width: 41px;
  height: 41px;
  position: absolute;
  left: 1476px;
  top: 207px;
  object-fit: cover;
  aspect-ratio: 1;
}
.a-fan-8 {
  width: 41px;
  height: 41px;
  position: absolute;
  left: 1422px;
  top: 207px;
  object-fit: cover;
  aspect-ratio: 1;
}
.a-fan-6 {
  width: 41px;
  height: 41px;
  position: absolute;
  left: 1314px;
  top: 207px;
  object-fit: cover;
  aspect-ratio: 1;
}
.a-fan-7 {
  width: 41px;
  height: 41px;
  position: absolute;
  left: 1371px;
  top: 207px;
  object-fit: cover;
  aspect-ratio: 1;
}
.a-fan-4 {
  width: 41px;
  height: 41px;
  position: absolute;
  left: 744px;
  top: 338px;
  object-fit: cover;
  aspect-ratio: 1;
}
.a-fan-2 {
  width: 41px;
  height: 41px;
  position: absolute;
  left: 599px;
  top: 176px;
  object-fit: cover;
  aspect-ratio: 1;
}
.a-fan-1 {
  width: 41px;
  height: 41px;
  position: absolute;
  left: 538px;
  top: 176px;
  object-fit: cover;
  aspect-ratio: 1;
}
.vs-text-12 {
  width: 46px;
  height: 13px;
  position: absolute;
  left: 688px;
  top: 327px;
  object-fit: cover;
  aspect-ratio: 46/13;
}
.vs-text-122 {
  width: 46px;
  height: 13px;
  position: absolute;
  left: 668px;
  top: 410px;
  object-fit: cover;
  aspect-ratio: 46/13;
}
.vs-text-123 {
  width: 46px;
  height: 13px;
  position: absolute;
  left: 668px;
  top: 400px;
  object-fit: cover;
  aspect-ratio: 46/13;
}
.vs-text-124 {
  width: 46px;
  height: 13px;
  position: absolute;
  left: 668px;
  top: 390px;
  object-fit: cover;
  aspect-ratio: 46/13;
}
.vs-text-125 {
  width: 46px;
  height: 13px;
  position: absolute;
  left: 668px;
  top: 382px;
  object-fit: cover;
  aspect-ratio: 46/13;
}
.v-heater {
  background: #ff4646;
  width: 4px;
  height: 98px;
  position: absolute;
  left: 792px;
  top: 314px;
}
.v-heater2 {
  background: #ff4646;
  width: 4px;
  height: 98px;
  position: absolute;
  left: 801px;
  top: 314px;
}
.v-heater3 {
  background: #ff4646;
  width: 4px;
  height: 98px;
  position: absolute;
  left: 828px;
  top: 314px;
}
.v-heater4 {
  background: #ff4646;
  width: 4px;
  height: 98px;
  position: absolute;
  left: 820px;
  top: 314px;
}
.rectangle-9 {
  background: #ff4646;
  width: 4px;
  height: 98px;
  position: absolute;
  left: 810px;
  top: 314px;
}
.a-text-15 {
  width: 38px;
  height: 38px;
  position: absolute;
  left: 658px;
  top: 428px;
  object-fit: cover;
  aspect-ratio: 1;
}
.a-text-17 {
  width: 36px;
  height: 36px;
  position: absolute;
  left: 950px;
  top: 286px;
  object-fit: cover;
  aspect-ratio: 1;
}
.a-text-23 {
  width: 36px;
  height: 36px;
  position: absolute;
  left: 1077px;
  top: 182px;
  object-fit: cover;
  aspect-ratio: 1;
}
.a-text-152 {
  width: 39px;
  height: 39px;
  position: absolute;
  left: 1770px;
  top: 209px;
  object-fit: cover;
  aspect-ratio: 1;
}
.a-text-24 {
  width: 40px;
  height: 40px;
  position: absolute;
  left: 1554px;
  top: 294px;
  object-fit: cover;
  aspect-ratio: 1;
}
.v-text-18 {
  width: 30px;
  height: 38px;
  position: absolute;
  left: 1021px;
  top: 246px;
  object-fit: cover;
  aspect-ratio: 30/38;
}
.rectangle-10 {
  background: #ff4444;
  width: 11px;
  height: 19px;
  position: absolute;
  left: 116px;
  top: 201px;
}
.rectangle-11 {
  background: #ff4444;
  width: 11px;
  height: 19px;
  position: absolute;
  left: 94px;
  top: 201px;
}
.header {
  background: #123478;
  width: 1918px;
  height: 46.68px;
  position: absolute;
  left: 0px;
  top: 0px;
}
.footer {
  background: #123478;
  width: 1918px;
  height: 72.43px;
  position: absolute;
  left: 0px;
  top: 805.57px;
}
.hamburger-icon-svg-1 {
  width: 33px;
  height: 26.56px;
  position: absolute;
  left: 13px;
  top: 36.21px;
  transform-origin: 0 0;
  transform: rotate(0deg) scale(1, -1);
  object-fit: cover;
}
.image-2 {
  width: 1918px;
  height: 426px;
  position: absolute;
  left: 0px;
  top: 47px;
  object-fit: cover;
  aspect-ratio: 1918/426;
}
.image-3 {
  width: 208px;
  height: 312px;
  position: absolute;
  left: 59px;
  top: 72px;
  object-fit: cover;
  aspect-ratio: 208/312;
}
.image-6 {
  width: 183px;
  height: 275px;
  position: absolute;
  left: 931px;
  top: 136px;
  object-fit: cover;
  aspect-ratio: 183/275;
}
.image-7 {
  width: 209px;
  height: 314px;
  position: absolute;
  left: 1603px;
  top: 156px;
  object-fit: cover;
  aspect-ratio: 209/314;
}
.image-9 {
  width: 67px;
  height: 67px;
  position: absolute;
  left: 1785px;
  top: 279px;
  object-fit: cover;
  aspect-ratio: 1;
}
.image-11 {
  width: 127px;
  height: 67px;
  position: absolute;
  left: 1791px;
  top: 414px;
  object-fit: cover;
  aspect-ratio: 127/67;
}
.image-photoroom-4-1 {
  width: 58.21px;
  height: 48.16px;
  position: absolute;
  left: 811px;
  top: 243.27px;
  transform-origin: 0 0;
  transform: rotate(-38.536deg) scale(1, 1);
  object-fit: cover;
  aspect-ratio: 58.21/48.16;
}
.coll-pump {
  color: rgba(0, 0, 0, 0.47);
  text-align: left;
  font-family: "Inter-Bold", sans-serif;
  font-size: 12px;
  font-weight: 700;
  position: absolute;
  left: 557px;
  top: 434px;
  width: 85px;
  height: 18px;
}
.c-text-9 {
  color: rgba(0, 0, 0, 0.47);
  text-align: left;
  font-family: "Inter-Bold", sans-serif;
  font-size: 12px;
  font-weight: 700;
  position: absolute;
  left: 557px;
  top: 448px;
  width: 85px;
  height: 18px;
}
.c-text-10 {
  color: rgba(0, 0, 0, 0.47);
  text-align: left;
  font-family: "Inter-Bold", sans-serif;
  font-size: 12px;
  font-weight: 700;
  position: absolute;
  left: 557px;
  top: 462px;
  width: 85px;
  height: 18px;
}
.coll-pump2 {
  color: #8e8e8e;
  text-align: left;
  font-family: "Inter-Bold", sans-serif;
  font-size: 12px;
  font-weight: 700;
  position: absolute;
  left: 557px;
  top: 434px;
  width: 85px;
  height: 18px;
}
.c-text-92 {
  color: #878787;
  text-align: left;
  font-family: "Inter-Bold", sans-serif;
  font-size: 12px;
  font-weight: 700;
  position: absolute;
  left: 557px;
  top: 448px;
  width: 85px;
  height: 18px;
}
.c-text-102 {
  color: #878787;
  text-align: left;
  font-family: "Inter-Bold", sans-serif;
  font-size: 12px;
  font-weight: 700;
  position: absolute;
  left: 557px;
  top: 462px;
  width: 85px;
  height: 18px;
}
.a-text-112 {
  width: 39px;
  height: 39px;
  position: absolute;
  left: 717px;
  top: 161px;
  object-fit: cover;
  aspect-ratio: 1;
}
.v-fan {
  background: #ff4646;
  width: 162px;
  height: 117px;
  position: absolute;
  left: 526px;
  top: 176px;
  transform-origin: 0 0;
  transform: rotate(0deg) scale(-1, 1);
  mix-blend-mode: color-burn;
}
.v-fan-1 {
  background: #ff4646;
  width: 67px;
  height: 117px;
  position: absolute;
  left: 593px;
  top: 176px;
  transform-origin: 0 0;
  transform: rotate(0deg) scale(-1, 1);
  mix-blend-mode: color-burn;
}
.v-fan-5 {
  background: #ff4646;
  width: 86px;
  height: 108px;
  position: absolute;
  left: 1301px;
  top: 197px;
  transform-origin: 0 0;
  transform: rotate(0deg) scale(-1, 1);
  mix-blend-mode: color-burn;
}
.v-fan-6 {
  background: #ff4646;
  width: 62px;
  height: 108px;
  position: absolute;
  left: 1363px;
  top: 197px;
  transform-origin: 0 0;
  transform: rotate(0deg) scale(-1, 1);
  mix-blend-mode: color-burn;
}
.v-fan-7 {
  background: #ff4646;
  width: 62px;
  height: 108px;
  position: absolute;
  left: 1425px;
  top: 197px;
  transform-origin: 0 0;
  transform: rotate(0deg) scale(-1, 1);
  mix-blend-mode: color-burn;
}
.v-fan-8 {
  background: #ff4646;
  width: 52px;
  height: 108px;
  position: absolute;
  left: 1477px;
  top: 197px;
  transform-origin: 0 0;
  transform: rotate(0deg) scale(-1, 1);
  mix-blend-mode: color-burn;
}
.v-fan-9 {
  background: #ff4646;
  width: 99px;
  height: 108px;
  position: absolute;
  left: 1576px;
  top: 197px;
  transform-origin: 0 0;
  transform: rotate(0deg) scale(-1, 1);
  mix-blend-mode: color-burn;
}
.v-fan-2 {
  background: #ff4646;
  width: 67px;
  height: 117px;
  position: absolute;
  left: 660px;
  top: 176px;
  transform-origin: 0 0;
  transform: rotate(0deg) scale(-1, 1);
  mix-blend-mode: color-burn;
}
.v-fan-3 {
  background: #ff4646;
  width: 62px;
  height: 117px;
  position: absolute;
  left: 722px;
  top: 176px;
  transform-origin: 0 0;
  transform: rotate(0deg) scale(-1, 1);
  mix-blend-mode: color-burn;
}
.xbox {
  background: #ffffff;
  width: 48px;
  height: 38px;
  position: absolute;
  left: 714px;
  top: 121px;
}
.v-fire {
  width: 94px;
  height: 52px;
  position: absolute;
  left: 781px;
  top: 107px;
  transform-origin: 0 0;
  transform: rotate(0deg) scale(-1, 1);
  object-fit: cover;
  aspect-ratio: 94/52;
}
.c-text-112 {
  color: #000000;
  text-align: left;
  font-family: "Inter-Bold", sans-serif;
  font-size: 14px;
  font-weight: 700;
  position: absolute;
  left: 738px;
  top: 195px;
  width: 93px;
  height: 18px;
}
.c-text-113 {
  color: #000000;
  text-align: left;
  font-family: "Inter-Bold", sans-serif;
  font-size: 14px;
  font-weight: 700;
  position: absolute;
  left: 263px;
  top: 116px;
  width: 56px;
  height: 18px;
}
.image-photoroom-6-2 {
  width: 279px;
  height: 263px;
  position: absolute;
  left: 666px;
  top: 200px;
  object-fit: cover;
  aspect-ratio: 279/263;
}
.v-heater5 {
  background: #ff0000;
  width: 3px;
  height: 97px;
  position: absolute;
  left: 829px;
  top: 315px;
  mix-blend-mode: hue;
}
.v-heater6 {
  background: #ff4646;
  width: 4px;
  height: 97px;
  position: absolute;
  left: 820px;
  top: 315px;
  mix-blend-mode: hue;
}
.rectangle-12 {
  background: #ff4646;
  width: 4px;
  height: 97px;
  position: absolute;
  left: 810px;
  top: 315px;
  mix-blend-mode: hue;
}
.v-heater7 {
  background: #ff4646;
  width: 4px;
  height: 97px;
  position: absolute;
  left: 801px;
  top: 315px;
  mix-blend-mode: hue;
}
.v-heater8 {
  background: #ff4646;
  width: 4px;
  height: 97px;
  position: absolute;
  left: 792px;
  top: 315px;
  mix-blend-mode: hue;
}
.vs-text-18 {
  width: 30px;
  height: 38px;
  position: absolute;
  left: 1021px;
  top: 246px;
  object-fit: cover;
  aspect-ratio: 30/38;
}
  


#tableAlarm {
    height: 40px;
  
}

#tableAlarm th, 
#tableAlarm td {
    text-align: center !important;  
    vertical-align: middle !important;
    font-size: 18px;
    padding: 8px;

}


#tableAlarm th, 
#tableAlarm td {
    text-align: center;   /* 가로 가운데 */
    vertical-align: middle; /* 세로 가운데 */
    font-size: 16px;      /* 폰트 크기 */
    padding: 8px;
}
  
  
  
  
  
  
 .right-pane{
 
 width: 770px; /* 컨테이너 폭 */
 } 
 
 
  
  
  
  .div1{
margin-left: 20px;
width: 1900px; /* 컨테이너 폭 */
gap: 20px;
display: flex;
}
.div2 {
    width: 1660px;
    gap: 20px;
    display: flex
;
    margin-top: 20px;
}
.div1 table,
.div2 table {
    width: 90%;
    border-collapse: collapse; /* 테이블 선 겹침 제거 */
          /* 글씨 크기 조금 키움 */
    font-weight: bold;         /* 글씨 두껍게 */
    height: 60px;              /* 행 높이 증가 */
}

.div1 table:first-child { 
    width: 860px; 
}

.div1 table:last-child { 
    width: 740px; 
}
.div2 table:last-child { 
    width: 740px; 
}



/* 필요하면 각 td 높이도 조절 가능 */
.div1 table td,
.div2 table td {
    font-weight: bold; 
    padding: 10px; /* 높이 확보 */
}

.table-title1{


}
.table-title1{
font-size: 1.2em;
}
.span1 {
  margin-left: 30px;       /* 왼쪽에서 조금 띄우기 */
}

.span2 {
  margin-left: 720px;      /* 왼쪽에서 많이 띄우기 (원하는 수치로 조절) */
}
table th{
background-color: #326fd5; 
font-size: 1.2em;
    color: #fff4df;
    border: 1px solid #000;
}
table td{
font-size: 1.2em;
background-color: #c8ebff; 
border: 1px solid #000;
}
 .tabulator .tabulator-header {
    background-color: #F3F6FB; /* 연한 하늘색 */
}
/* 실제 제목 셀이 들어 있는 부분 */
#dataList .tabulator-col {
  background-color: #F3F6FB; /* 컬럼 헤더 셀 배경 */
  color: #222;               /* 글자색 */
  font-weight: bold;         /* 글자 굵게 */
  border-right: 1px solid #ddd; /* 구분선 */
}

/* 헤더와 본문 사이 구분선 */
#dataList .tabulator-header {
  border-bottom: 1px solid #000;
  border-top: 1px solid #000;
  border-right: 1px solid #000;
  border-left: 1px solid #000;
}

/* 테이블 자체 외곽 (헤더+본문 감싸는 박스) */
#dataList .tabulator {
  border: 1px solid #000;
  border-radius: 0;
} */
/* 각 헤더 셀 */
#dataList .tabulator-col {
  border-left: 1px solid #000;
  border-right: 1px solid #000;
  border-bottom: 1px solid #000;
}

/* 각 데이터 셀 */
#dataList .tabulator-cell {
  border-left: 1px solid #000;
  border-bottom: 1px solid #000;
}
.alarm{
  display: inline-block;      /* 내용만큼만 박스 */
  background: #cfcdcd;        
  color: #fff;                /* 글자 흰색 */
  font-weight: 700;
  padding: 6px 12px;          /* 안쪽 여백 */
  margin-bottom: 1px;         /* 아래 테이블과 간격 */
} 

#pageFrame {
    width: 90vw;
    height: 90vh;
    border: none;
    display: block;
    margin: 0 auto;
    overflow: hidden;

    /* 내부 내용 축소 */
    transform: scale(0.9);  /* 90% 크기로 축소 */
    transform-origin: top left; /* 축소 기준점 */
}

/* PV 행 (진한 블루) */
.temp-table tbody tr:first-child td:not(:first-child) {
  color: #0055ff; /* 진한 파랑 */
  font-weight: 700;
}

/* SP 행 (진한 레드) */
.temp-table tbody tr:last-child td:not(:first-child) {
  color: #d60000; /* 진한 빨강 */
  font-weight: 700;
}










/* 전체 컨테이너 */
.abs {
    position: absolute;
    top: 10px;
    left: 50%;
    transform: translateX(-50%);
    z-index: 9999;
    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
}

.process-wrapper {
    display: flex;
    gap: 14px;
    background: #f0f6fb;
    padding: 15px 10px;
    border-radius: 20px;
    box-shadow: 0 8px 20px rgba(0, 0, 0, 0.08), inset 0 0 0 1px rgba(200, 200, 220, 0.3);
    position: relative;
}

/* 상단/하단 배경 강조 */
.process-wrapper::before,
.process-wrapper::after {
    content: "";
    position: absolute;
    left: 0;
    width: 100%;
    height: 10px;
    background: linear-gradient(to right, #dce6f2, #ffffff);
    border-radius: 5px;
}

.process-wrapper::before { top: 0; }
.process-wrapper::after { bottom: 0; }

/* 각 단계 묶음 */
.process-step-wrapper {
    display: flex;
    flex-direction: column;
    align-items: center;
    flex: 1;
    position: relative;
}

/* 상단 공정 박스 */
.process-step {
    padding: 12px 22px;
    font-size: 14px;
    font-weight: 600;
    border-radius: 18px;
    background: linear-gradient(145deg, #ffffff, #dce6f2);
    color: #2a3b50;
    white-space: nowrap;
    display: flex;
    justify-content: center;
    align-items: center;
    width: 100%;
    box-sizing: border-box;
    transition: all 0.3s ease;
    text-align: center;
    cursor: default;
    box-shadow: 0 2px 6px rgba(0,0,0,0.1), inset 0 1px 2px rgba(255,255,255,0.6);
}



/* 공정 활성화 애니메이션 */
.process-step.active-green {
    background: linear-gradient(145deg, #a0d4ff, #61b8ff);
    color: #1b2a3b !important;
    box-shadow: 0 4px 12px rgba(0,0,0,0.15), inset 0 1px 2px rgba(255,255,255,0.4);

    /* 깜빡임 대신 은은한 밝기 변화 */
    animation: pulseLight 2.5s ease-in-out infinite;
}

@keyframes pulseLight {
    0% { filter: brightness(1); }
    50% { filter: brightness(1.12); } /* 밝기 살짝 증가 */
    100% { filter: brightness(1); }
}

/* 하단 바 */
.process-bottom-bar {
    margin-top: 8px;
    width: 100%;
    height: 27px;
    border-radius: 6px;
    background: #d0d8e4;
    transition: all 0.35s ease;
    box-shadow: inset 0 1px 2px rgba(255,255,255,0.3);

    /* 글씨 가운데 정렬 */
    display: flex;
    justify-content: center; /* 가로 중앙 */
    align-items: center;     /* 세로 중앙 */
    font-weight: 600;        /* 글씨 굵기 선택 */
    color: #2a3b50;          /* 글씨 색상 */
    font-size: 14px;         /* 글씨 크기 */
}

/* 하단 바 활성화 */
.process-bottom-bar.active {
    background: linear-gradient(135deg, #61b8ff, #3a9eff);
    box-shadow: inset 0 1px 2px rgba(255,255,255,0.4);
}

/* hover 효과 */
.process-step-wrapper:hover .process-step {
    transform: translateY(-2px);
    box-shadow: 0 6px 14px rgba(0,0,0,0.12), inset 0 1px 2px rgba(255,255,255,0.5);
}

.process-step-wrapper:hover .process-bottom-bar {
    background: #82c4ff;
}


   </style>
  <title>Document</title>
<style>
/* 데모: 상단 LOT 바는 항상 한 줄 */
.process-wrapper { gap: 8px; padding: 12px 10px; }
.process-step { padding: 10px 8px; font-size: 13.5px; }
.process-bottom-bar { white-space: nowrap; overflow: hidden; text-overflow: ellipsis; font-size: 13px; padding: 0 4px; box-sizing: border-box; font-variant-numeric: tabular-nums; }
html, body { overflow-x: hidden; }
</style>
<script>
/* 데모: 설비 화면(설계 폭 1880px)을 창 너비에 맞춰 축소 → 가로 스크롤 없음 */
(function () {
  var DESIGN_W = 1880;
  function fit() {
    var z = Math.min(1, (window.innerWidth || DESIGN_W) / DESIGN_W);
    document.documentElement.style.zoom = z;
  }
  fit();
  window.addEventListener('resize', fit);
})();
</script>
</head>
<body>



<div class="abs">
  <div class="process-wrapper">

    <div class="process-step-wrapper">
      <div class="process-step L002">입구호퍼</div>
      <div class="process-bottom-bar start_hoper_2"></div>
    </div>

    <div class="process-step-wrapper">
      <div class="process-step L003">전세정기</div>
      <div class="process-bottom-bar f_wash_3"></div>
    </div>

    <div class="process-step-wrapper">
      <div class="process-step L004">소입_1</div>
      <div class="process-bottom-bar qf1_4"></div>
    </div>

    <div class="process-step-wrapper">
      <div class="process-step L005">소입_2</div>
      <div class="process-bottom-bar qf2_5"></div>
    </div>

    <div class="process-step-wrapper">
      <div class="process-step L006">소입_3</div>
      <div class="process-bottom-bar qf3_6"></div>
    </div>

    <div class="process-step-wrapper">
      <div class="process-step L007">소입_4</div>
      <div class="process-bottom-bar qf4_7"></div>
    </div>

    <div class="process-step-wrapper">
      <div class="process-step L008">소입_5</div>
      <div class="process-bottom-bar qf5_8"></div>
    </div>

    <div class="process-step-wrapper">
      <div class="process-step L009">유조</div>
      <div class="process-bottom-bar oil_9"></div>
    </div>

    <div class="process-step-wrapper">
      <div class="process-step L010">중간세정기</div>
      <div class="process-bottom-bar m_wash_10"></div>
    </div>

    <div class="process-step-wrapper">
      <div class="process-step L011">소려_1</div>
      <div class="process-bottom-bar tf1_11"></div>
    </div>

    <div class="process-step-wrapper">
      <div class="process-step L012">소려_2</div>
      <div class="process-bottom-bar tf2_12"></div>
    </div>

    <div class="process-step-wrapper">
      <div class="process-step L013">소려_3</div>
      <div class="process-bottom-bar tf3_13"></div>
    </div>

    <div class="process-step-wrapper">
      <div class="process-step L014">소려_4</div>
      <div class="process-bottom-bar tf4_14"></div>
    </div>

    <div class="process-step-wrapper">
      <div class="process-step L015">소려_5</div>
      <div class="process-bottom-bar tf5_15"></div>
    </div>

    <div class="process-step-wrapper">
      <div class="process-step L016">방청조</div>
      <div class="process-bottom-bar bch_16"></div>
    </div>

    <div class="process-step-wrapper">
      <div class="process-step L017">출구콘베어</div>
      <div class="process-bottom-bar con_17"></div>
    </div>

  </div>
</div>






<!-- <div class="abs2">
    <div class="process-flow2">

        <div class="process-step2 from_pc_1"></div>
        <div class="process-step2 start_hoper_2"></div>
        <div class="process-step2 f_wash_3"></div>
        <div class="process-step2 qf1_4"></div>
        <div class="process-step2 qf2_5"></div>
        <div class="process-step2 qf3_6"></div>
        <div class="process-step2 qf4_7"></div>
        <div class="process-step2 qf5_8"></div>
        <div class="process-step2 oil_9"></div>
        <div class="process-step2 m_wash_10"></div>
        <div class="process-step2 tf1_11"></div>
        <div class="process-step2 tf2_12"></div>
        <div class="process-step2 tf3_13"></div>
        <div class="process-step2 tf4_14"></div>
        <div class="process-step2 tf5_15"></div>
        <div class="process-step2 bch_16"></div>
        <div class="process-step2 con_17"></div>
        <div class="process-step ex_18"></div>
        <div class="process-step ex_19"></div>
        <div class="process-step ex_20"></div>

    </div>
</div> -->



  <div class="group-5">
    <div class="c-text-6"></div>
    <div class="rectangle-3"></div>
    <div class="rectangle-2"></div>
    <div class="v-text-22"></div>
    <div class="v-text-222"></div>
    <div class="v-text-223"></div>
    <div class="v-heater-2"></div>
    <div class="v-heater-22"></div>
    <div class="v-heater-23"></div>
    <div class="c-text">자동급수운전중</div>
<!--     <div class="c-text-7">구동모터</div>
    <div class="c-text-8">구동모터</div> -->
<!--     <div class="c-text-11">Exhaust FAN</div> -->
    <div class="input-text">소입로</div>
    <div class="input-text2">소입유조</div>
    <div class="input-text3">소려로</div>
    <div class="input-text4">중간세정기</div>
    <div class="v-text">역방향</div>
<!--     <div class="c-text-15">구동모터</div>
    <div class="c-text-23">구동모터</div>
    <div class="c-text-24">구동모터</div>
    <div class="c-text-152">구동모터</div> -->
<!--     <div class="c-text-31">역방향</div> -->
<!--     <div class="v-text-3">역방향</div> -->
    <div class="v-text-32">냉각조</div>
    <div class="v-text-33">추출콘베어</div>
    <div class="c-text-1">급수펌프</div>
    <div class="c-text-5">자동가열운전중</div>
    <div class="c-text-12">
      제트펌프
      <br />
      (커튼펌프)
    </div>
    <div class="c-text-62">히터 ON</div>
    <div class="c-text-4">오일스키머 운전중</div>
    <div class="c-text-3">오일스키머 자동운전중</div>
    <div class="c-text-13">자동가열운전중</div>
    <div class="c-text-14">자동냉각운전중</div>
    <div class="c-text-2">스프레이펌프</div>
    <div class="c-text-16">자동급수운전중</div>
    <div class="c-text-17">급수펌프</div>
    <div class="c-text-21">자동가열운전중</div>
    <div class="c-text-22">히터 ON</div>
    <div class="c-text-20">오일스키머 운전중</div>
    <div class="c-text-19">오일스키머 자동운전중</div>
    <div class="c-text-27">CT. Pump</div>
    <div class="c-text-28">CT. Elevate</div>
    <div class="c-text-26">자동냉각운전중</div>
    <div class="c-text-25">자동가열운전중</div>
    <div class="c-text-18">스트레이펌프</div>
    <div class="clean">전세정기</div>
    <img class="a-pump" src="/line/image/overview/a-pump0.png" />
    <img class="a-text-11" src="/line/image/overview/a-text-110.png" />
    <img class="a-pump-1" src="/line/image/overview/a-pump-10.png" />
    <img class="a-pump-2" src="/line/image/overview/a-pump-20.png" />
    <img class="a-text-7" src="/line/image/overview/a-text-70.png" />
    <img class="a-text-8" src="/line/image/overview/a-text-80.png" />
    <img class="a-text-72" src="/line/image/overview/a-text-71.png" />
    <img class="a-fan" src="/line/image/overview/a-fan0.png" />
    <img class="a-fan-3" src="/line/image/overview/a-fan-30.png" />
    <img class="a-fan-5" src="/line/image/overview/a-fan-50.png" />
    <img class="a-fan-9" src="/line/image/overview/a-fan-90.png" />
    <img class="a-fan-8" src="/line/image/overview/a-fan-80.png" />
    <img class="a-fan-6" src="/line/image/overview/a-fan-60.png" />
    <img class="a-fan-7" src="/line/image/overview/a-fan-70.png" />
    <img class="a-fan-4" src="/line/image/overview/a-fan-40.png" />
    <img class="a-fan-2" src="/line/image/overview/a-fan-20.png" />
    <img class="a-fan-1" src="/line/image/overview/a-fan-10.png" />
    <img class="vs-text-12" src="/line/image/overview/vs-text-120.png" />
    <img class="vs-text-122" src="/line/image/overview/vs-text-121.png" />
    <img class="vs-text-123" src="/line/image/overview/vs-text-122.png" />
    <img class="vs-text-124" src="/line/image/overview/vs-text-123.png" />
    <img class="vs-text-125" src="/line/image/overview/vs-text-124.png" />
    <div class="v-heater"></div>
    <div class="v-heater2"></div>
    <div class="v-heater3"></div>
    <div class="v-heater4"></div>
    <div class="rectangle-9"></div>
    <img class="a-text-15" src="/line/image/overview/a-text-150.png" />
    <img class="a-text-17" src="/line/image/overview/a-text-170.png" />
    <img class="a-text-23" src="/line/image/overview/a-text-230.png" />
    <img class="a-text-152" src="/line/image/overview/a-text-151.png" />
    <img class="a-text-24" src="/line/image/overview/a-text-240.png" />
    <img class="v-text-18" src="/line/image/overview/v-text-180.png" />
    <div class="c-text-6"></div>
    <div class="rectangle-10"></div>
    <div class="rectangle-11"></div>
    <div class="v-text-22"></div>
    <div class="v-text-222"></div>
    <div class="v-text-223"></div>
    <div class="v-heater-2"></div>
    <div class="v-heater-22"></div>
    <div class="v-heater-23"></div>
    <div class="c-text">자동급수운전중</div>
<!--     <div class="c-text-7">구동모터</div>
    <div class="c-text-8">구동모터</div> -->
 

    <img class="image-2" src="/line/image/overview/image-20.png" />
    <img class="image-3" src="/line/image/overview/image-30.png" />
    <img class="image-6" src="/line/image/overview/image-60.png" />
    <img class="image-7" src="/line/image/overview/image-70.png" />
    <img class="image-9" src="/line/image/overview/image-90.png" />
    <img class="image-11" src="/line/image/overview/image-110.png" />
    <img class="image-photoroom-4-1" src="/line/image/overview/image-photoroom-4-10.png" />
    <div class="coll-pump">유조냉각 펌프</div>
    <div class="c-text-9">NO.1 냉각펌프</div>
    <div class="c-text-10">NO.2 냉각펌프</div>
    <div class="coll-pump2">유조냉각 펌프</div>
    <div class="c-text-92">NO.1 냉각펌프</div>
    <div class="c-text-102">NO.2 냉각펌프</div>
    <img class="a-text-112" src="/line/image/overview/a-text-111.png" />
    <div class="v-fan"></div>
    <div class="v-fan-1"></div>
    <div class="v-fan-5"></div>
    <div class="v-fan-6"></div>
    <div class="v-fan-7"></div>
    <div class="v-fan-8"></div>
    <div class="v-fan-9"></div>
    <div class="v-fan-2"></div>
    <div class="v-fan-3"></div>
    <div class="xbox"></div>
    <img class="v-fire" src="/line/image/overview/v-fire0.png" />
<!--     <div class="c-text-112">Exhaust FAN</div> -->
<!--     <div class="c-text-113">구동모터</div> -->
    <img class="image-photoroom-6-2" src="/line/image/overview/image-photoroom-6-20.png" />
    <div class="v-heater5"></div>
    <div class="v-heater6"></div>
    <div class="rectangle-12"></div>
    <div class="v-heater7"></div>
    <div class="v-heater8"></div>
    <div class="input-text">소입로</div>
    <div class="input-text2">소입유조</div>
    <div class="input-text3">소려로</div>
    <div class="input-text4">중간세정기</div>
<!--     <div class="v-text">역방향</div>
    <div class="c-text-15">구동모터</div>
    <div class="c-text-23">구동모터</div>
    <div class="c-text-24">구동모터</div>
    <div class="c-text-152">구동모터</div>
    <div class="c-text-31">역방향</div>
    <div class="v-text-3">역방향</div> -->
    <div class="v-text-32">냉각조</div>
    <div class="v-text-33">추출콘베어</div>
    <div class="c-text-1">급수펌프</div>
    <div class="c-text-5">자동가열운전중</div>
    <div class="c-text-12">
      제트펌프
      <br />
      (커튼펌프)
    </div>
    <div class="c-text-62">히터 ON</div>
    <div class="c-text-4">오일스키머 운전중</div>
    <div class="c-text-3">오일스키머 자동운전중</div>
    <div class="c-text-13">자동가열운전중</div>
    <div class="c-text-14">자동냉각운전중</div>
    <div class="c-text-2">스프레이펌프</div>
    <div class="c-text-16">자동급수운전중</div>
    <div class="c-text-17">급수펌프</div>
    <div class="c-text-21">자동가열운전중</div>
    <div class="c-text-22">히터 ON</div>
    <div class="c-text-20">오일스키머 운전중</div>
    <div class="c-text-19">오일스키머 자동운전중</div>
    <div class="c-text-27">CT. Pump</div>
    <div class="c-text-28">CT. Elevate</div>
    <div class="c-text-26">자동냉각운전중</div>
    <div class="c-text-25">자동가열운전중</div>
    <div class="c-text-18">스트레이펌프</div>
    <div class="clean">전세정기</div>
    <img class="a-pump" src="/line/image/overview/a-pump1.png" />
    <img class="a-pump-1" src="/line/image/overview/a-pump-11.png" />
    <img class="a-pump-2" src="/line/image/overview/a-pump-21.png" />
    <img class="a-text-7" src="/line/image/overview/a-text-72.png" />
    <img class="a-text-8" src="/line/image/overview/a-text-81.png" />
    <img class="a-text-72" src="/line/image/overview/a-text-73.png" />
    <img class="a-fan" src="/line/image/overview/a-fan1.png" />
    <img class="a-fan-3" src="/line/image/overview/a-fan-31.png" />
    <img class="a-fan-5" src="/line/image/overview/a-fan-51.png" />
    <img class="a-fan-9" src="/line/image/overview/a-fan-91.png" />
    <img class="a-fan-8" src="/line/image/overview/a-fan-81.png" />
    <img class="a-fan-6" src="/line/image/overview/a-fan-61.png" />
    <img class="a-fan-7" src="/line/image/overview/a-fan-71.png" />
    <img class="a-fan-4" src="/line/image/overview/a-fan-41.png" />
    <img class="a-fan-2" src="/line/image/overview/a-fan-21.png" />
    <img class="a-fan-1" src="/line/image/overview/a-fan-11.png" />
    <img class="vs-text-12" src="/line/image/overview/vs-text-125.png" />
    <img class="vs-text-122" src="/line/image/overview/vs-text-126.png" />
    <img class="vs-text-123" src="/line/image/overview/vs-text-127.png" />
    <img class="vs-text-124" src="/line/image/overview/vs-text-128.png" />
    <img class="vs-text-125" src="/line/image/overview/vs-text-129.png" />
    <img class="a-text-15" src="/line/image/overview/a-text-152.png" />
    <img class="a-text-17" src="/line/image/overview/a-text-171.png" />
    <img class="a-text-23" src="/line/image/overview/a-text-231.png" />
    <img class="a-text-152" src="/line/image/overview/a-text-153.png" />
    <img class="a-text-24" src="/line/image/overview/a-text-241.png" />
    <img class="vs-text-18" src="/line/image/overview/vs-text-180.png" />
  </div>
  
  
  <div class="table-title1">
<!-- <span class="span1">소입(온도 유조 냉각 CP)</span>
<span class="span2">인버터 제어</span> -->
</div>

<div class="div1">
<table border="1" cellspacing="0" cellpadding="5" class="temp-table">
  <thead>
    <tr>
      <th></th>
      <th>전세정기</th>
      <th> 1존</th>
      <th> 2존</th>
      <th> 3존</th>
      <th> 4존</th>
      <th> 5존</th>
      <th> 유조</th>
   
      <th>&nbsp&nbspCP_A&nbsp&nbsp</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>PV</td>
      <td class="F_WASH_PV">##.#</td>
      <td class="Q_PV_1">##.#</td>
      <td class="Q_PV_2">##.#</td>
      <td class="Q_PV_3">##.#</td>
      <td class="Q_PV_4">##.#</td>
      <td class="Q_PV_5">##.#</td>
      <td class="OIL_PV">##.#</td>

      <td class="CP_PV_1">##.#</td>
    </tr>
    <tr>
      <td>SP</td>
      <td class="F_WASH_SP">##.#</td>
      <td class="Q_SP_1">##.#</td>
      <td class="Q_SP_2">##.#</td>
      <td class="Q_SP_3">##.#</td>
      <td class="Q_SP_4">##.#</td>
      <td class="Q_SP_5">##.#</td>
      <td class="OIL_SP">##.#</td>

      <td class="CP_SP_1">##.#</td>
    </tr>
  </tbody>
</table>

<table border="1" cellspacing="0" cellpadding="5" class="temp-table">
  <thead>
    <tr>
      <th></th>
      <th>전세정기 </th>
      <th>소입로 </th>
      <th>소입유조 </th>
      <th>아지테이터 FAN</th>
      <th>중간세정기 </th>
      <th>소려로 </th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>PV</td>
      <td class="IN_WASH_PV">##.#</td>
      <td class="IN_Q_PV">##.#</td>
      <td class="IN_OIL_PV">##.#</td>
      <td class="IN_DATA_PV">##.#</td>
      <td class="IN_M_WASH_PV">##.#</td>
      <td class="IN_T_PV">##.#</td>
    </tr>
    <tr>
      <td>SP</td>
      <td class="IN_WASH_SP">##.#</td>
      <td class="IN_Q_SP">##.#</td>
      <td class="IN_OIL_SP">##.#</td>
      <td class="IN_DATA_SP">##.#</td>
      <td class="IN_M_WASH_SP">##.#</td>
      <td class="IN_T_SP">##.#</td>
    </tr>
  </tbody>
</table>
</div>

<br>

<div class="div2">
  <div class="table-title1">

</div>
<table border="1" cellspacing="0" cellpadding="5" class="temp-table">

  <thead>
    <tr>
      <th></th>
      <th>중간세정기</th>
      <th> 1존</th>
      <th> 2존</th>
      <th> 3존</th>
      <th> 4존</th>
      <th> 5존</th>
      <th>방청</th>
 
      <th>CP_B</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>PV</td>
      <td class="M_WASH_PV">##.#</td>
      <td class="T_PV_1">##.#</td>
      <td class="T_PV_2">##.#</td>
      <td class="T_PV_3">##.#</td>
      <td class="T_PV_4">##.#</td>
      <td class="T_PV_5">##.#</td>
      <td class="BC_PV">##.#</td>
  
      <td class="CP_PV_2">##.#</td>
    </tr>
    <tr>
      <td>SP</td>
      <td class="M_WASH_SP">##.#</td>
      <td class="T_SP_1">##.#</td>
      <td class="T_SP_2">##.#</td>
      <td class="T_SP_3">##.#</td>
      <td class="T_SP_4">##.#</td>
      <td class="T_SP_5">##.#</td>
      <td class="BC_SP">##.#</td>

      <td class="CP_SP_2">##.#</td>
    </tr>
  </tbody>
</table>
  <div class="right-pane">
<!--       <div class="alarm">경보요약</div> -->
      
       <div id="tableAlarmWrapper" style="max-height:127px; overflow:auto;">
                <table id="tableAlarm">
                    <thead>
                        <tr>
                            <!-- <th>No</th>                                 
                            <th>PLC주소</th> -->
                            <th>알람내용</th>
                            <th>발생시간</th>
                        <!--     <th>해제시간</th> -->
                          
                        </tr>
                    </thead>
                    <tbody></tbody>
                </table>
            </div>       
 </div>



<!-- <div id="currentTime" style="
    position: fixed;
    top: 12px;
    right: 20px;
    padding: 6px 14px;
    background: #f5f5f5;  /* 밝은 회색 배경 */
    color: #333;           /* 진한 회색 글씨 */
    font-size: 28px;
    font-weight: 600;
    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
    border-radius: 6px;
    box-shadow: 0 2px 6px rgba(0,0,0,0.1); /* 은은한 그림자 */
    letter-spacing: 1px;
    z-index: 99999;
"></div> -->


       
</div>
  
  

 <script>
let overviewInterval;
let userTable;
let now_page_code = "b01";

// =====================
// 숫자 표시 포맷
// 50.00 -> 50
// 25.50 -> 25.5
// 25.55 -> 25.55
// =====================
function formatNumberSmart(val) {
    if (val === null || val === undefined || val === "") return val;

    const num = Number(val);
    if (isNaN(num)) return val;

    return num.toString();
}

// =====================
// 📦 LOT 품목명 맵 (DB 요청 0회)
// =====================
const lotItemMap = new Map(); // LOT 번호 → 품목명 전체 맵
let isLotDataLoaded = false;

// =====================
// 🚀 페이지 로드 시 전체 LOT 목록 가져오기
// =====================
function loadAllLotItems() {
    $.ajax({
        url: "/line/monitoring/allLotItems",
        type: "POST",
        dataType: "json",
        success: function(result) {
            const items = result.data || result.items || result;

            if (Array.isArray(items)) {
                lotItemMap.clear();
                items.forEach(item => {
                    if (item.w_ci_lot && item.v_item_name) {
                        lotItemMap.set(item.w_ci_lot, item.v_item_name);
                    }
                });
                console.log(`✅ LOT 품목명 ${lotItemMap.size}개 로드 완료`);
                isLotDataLoaded = true;
            }
        },
        error: function(err) {
            console.error("❌ LOT 목록 로드 실패:", err);
            isLotDataLoaded = false;
        }
    });
}

// =====================
// 📦 LOT 품목명 조회 (로컬 맵에서)
// =====================
function getItemNameFromMap(lotNumber) {
    return lotItemMap.get(lotNumber) || null;
}

// =====================
// 각 계열 처리 함수
// =====================
function v(key, value) {
    const els = document.getElementsByClassName(key);
    if (!els || els.length === 0) return;

    Array.from(els).forEach(el => {
        if (value === true) {
            el.classList.remove("hidden");
        } else {
            el.classList.add("hidden");
            el.style.backgroundColor = "";
        }
    });
}

function c(key, value) {
    const els = document.getElementsByClassName(key);
    if (!els || els.length === 0) return;
    Array.from(els).forEach(el => el.classList.toggle("active-green", !!value));
}

function a(key, value) {
    const els = document.getElementsByClassName(key);
    if (!els || els.length === 0) return;
    Array.from(els).forEach(el => el.classList.toggle("rotating", !!value));
}

function vs(key, value) {
    const els = document.getElementsByClassName(key);
    if (!els || els.length === 0) return;
    Array.from(els).forEach(el => el.classList.toggle("blinking", !!value));
}

function LLL(key, value) {
    const els = document.getElementsByClassName(key);
    if (!els || els.length === 0) return;

    const isActive = value === true || value === 1 || value === "1";
    Array.from(els).forEach(el => {
        el.classList.toggle("active-green", isActive);
    });
}

// =====================
// 🎯 valueDisplay (로컬 맵 사용 - DB 요청 없음)
// =====================
function valueDisplay(key, val) {
    const els = document.getElementsByClassName(key);
    if (!els || els.length === 0) return;

    const lotClassList = [
        "from_pc_1", "start_hoper_2", "f_wash_3",
        "qf1_4", "qf2_5", "qf3_6", "qf4_7", "qf5_8",
        "oil_9", "m_wash_10",
        "tf1_11", "tf2_12", "tf3_13", "tf4_14", "tf5_15",
        "bch_16", "con_17"
    ];

    // =====================
    // 📦 LOT 전용 처리
    // =====================
    if (lotClassList.includes(key) && val) {
        const ciIdx = val.indexOf("CI");

        if (ciIdx !== -1) {
            const originalVal = val;
            const displayVal = val.substring(ciIdx);
            const itemName = getItemNameFromMap(originalVal);

            Array.from(els).forEach(el => {
                let displayText;

                if (itemName) {
                    displayText = itemName.length > 9
                        ? itemName.substring(0, 9) + "..."
                        : itemName;
                    el.style.fontSize = "10px";
                    el.title = itemName;
                } else {
                    displayText = displayVal;
                    el.style.fontSize = "";
                    el.title = "";
                }

                el.innerText = displayText;
            });
            return;
        }
        // 데모: 일반 LOT 번호(CH261103-006)는 앞의 접두어·연도를 빼고 한 줄로 (전체 번호는 툴팁)
        Array.from(els).forEach(el => {
            el.innerText = String(val).replace(/^[A-Za-z]+\d{2}(?=\d{4}-)/, "");
            el.title = val;
        });
        return;
    }

    // =====================
    // 🔥 일반 값 표시 + 단위 처리
    // =====================
    Array.from(els).forEach(el => {
        let displayValue = val;

        if (!isNaN(val) && val !== "" && val !== null) {
            const formatted = formatNumberSmart(val);

            // IN_ 계열 → Hz
            if (key.includes("IN_")) {
                displayValue = formatted + " Hz";
            }
            // PV / SP → ℃ (CP 제외)
            else if ((key.includes("PV") || key.includes("SP")) && !key.includes("CP_")) {
                displayValue = formatted + " ℃";
            }
            // 그 외 숫자
            else {
                displayValue = formatted;
            }
        }

        el.innerText = displayValue;
        el.style.fontSize = "";
        el.title = "";
    });
}

// =====================
// OPC 값 조회
// =====================
function overviewListView() {
    $.ajax({
        url: "/line/monitoring/view",
        type: "post",
        dataType: "json",
        success: function(result) {
            const data = result.multiValues;

            for (const item of data) {
                for (const [tagName, tagData] of Object.entries(item)) {
                    if (!tagName) continue;
                    const { action, value } = tagData;

                    switch (action) {
                        case "LLL":
                            LLL(tagName, value);
                            break;
                        case "v":
                            v(tagName, value);
                            break;
                        case "c":
                            c(tagName, value);
                            break;
                        case "a":
                            a(tagName, value);
                            break;
                        case "vs":
                            vs(tagName, value);
                            break;
                        case "value":
                            valueDisplay(tagName, value);
                            break;
                    }
                }
            }
        },
        error: function(err) {
            console.error("❌ Ajax 요청 실패:", err);
        }
    });
}

function overviewListViewString() {
    $.ajax({
        url: "/line/monitoring/view/string",
        type: "post",
        dataType: "json",
        success: function(result) {
            const data = result.multiValues;

            for (const item of data) {
                for (const [tagName, tagData] of Object.entries(item)) {
                    if (!tagName) continue;

                    let { action, value } = tagData;

                    // IN_ 태그 처리
                    if (tagName.includes("IN_") && /^\d+$/.test(value)) {
                        value = (Number(value) / 100).toFixed(2);
                    }

                    // CP_ 태그 처리
                    if (tagName.includes("CP_") && /^\d+$/.test(value)) {
                        value = (Number(value) / 1000).toFixed(2);
                    }

                    if (tagName === "CP_SP_2") {
                        value = 0;
                    }

                    switch (action) {
                        case "value":
                            valueDisplay(tagName, value);
                            break;
                    }
                }
            }
        },
        error: function(err) {
            console.error("❌ Ajax 요청 실패:", err);
        }
    });
}

function fetchAlarm() {
    $.ajax({
        url: "/line/productionManagement/alarmRecord/list",
        method: "POST",
        dataType: "json",
        success: function(resp) {
            var arr = Array.isArray(resp) ? resp : (resp.data || resp.rows || (resp ? [resp] : []));
            var $tbody = $("#tableAlarm tbody").empty();

            if (!arr || arr.length === 0) {
                $tbody.append('<tr><td colspan="6" style="font-weight:900;">조회된 데이터가 없습니다.</td></tr>');
                return;
            }

            arr.forEach(function(r, idx) {
                var tr = $("<tr></tr>");
                tr.append("<td style='text-align:left;padding-left:12px;font-weight:900;'>" + (r.a_desc || "") + "</td>");
                tr.append("<td style='font-weight:900;'>" + (r.a_stime || "") + "</td>");
                tr.data("rowdata", r);

                if (!r.a_etime || r.a_etime === "") {
                    tr.css({
                        "background": "linear-gradient(90deg, rgba(255,230,0,0.25), rgba(255,255,255,0))",
                        "font-weight": "900",
                        "color": "#a80000"
                    });
                } else {
                    tr.append("<td style='font-weight:900;'>-</td>");
                }

                $tbody.append(tr);
            });
        }
    });
}

// =====================
// 🔄 주기적으로 LOT 목록 갱신 (5분마다)
// =====================
function startLotRefreshInterval() {
    setInterval(() => {
        loadAllLotItems();
        console.log("🔄 LOT 목록 갱신 완료");
    }, 300000);
}

// =====================
// DOM Ready 시 실행
// =====================
$(function() {
    // 1. LOT 목록 전체 로드
    loadAllLotItems();

    // 2. 데이터 조회 시작
    overviewListView();
    overviewListViewString();
    fetchAlarm();

    // 3. 1초마다 데이터 갱신
    overviewInterval = setInterval(() => {
        overviewListView();
        overviewListViewString();
        fetchAlarm();
    }, 1000);

    // 4. 5분마다 LOT 목록 갱신
    startLotRefreshInterval();
});
</script>

</body>
</html>