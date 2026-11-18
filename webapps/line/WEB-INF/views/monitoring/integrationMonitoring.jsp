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
html, body { overflow: hidden; }  /* 데모: fit()으로 창에 맞추므로 스크롤 없음 */
</style>
<script>
/* 데모: 설비 화면(설계 폭 1880px)을 창 크기에 맞춰 축소/확대 → 스크롤 없음, 큰 화면에서도 꽉 차게
   (높이는 알람 2행까지 들어가는 최소 설계 높이 DESIGN_H 기준으로 제한) */
(function () {
  var DESIGN_W = 1880, DESIGN_H = 1000;
  function fit() {
    var z = Math.min((window.innerWidth || DESIGN_W) / DESIGN_W, (window.innerHeight || DESIGN_H) / DESIGN_H);
    document.documentElement.style.zoom = z;
  }
  fit();
  window.addEventListener('resize', fit);
})();
</script>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=IBM+Plex+Mono:wght@400;500&family=IBM+Plex+Sans+KR:wght@400;500;600&display=swap">
<style>
/* ===== 데모: 통합모니터링 재설계 — 고밀도 운영 대시보드 (설비 도면 제외) ===== */
:root {
  --imx-fg: oklch(24% 0.012 255); --imx-fg2: oklch(46% 0.012 255); --imx-fg3: oklch(64% 0.01 255);
  --imx-line: oklch(91.5% 0.006 255); --imx-line2: oklch(95.5% 0.004 255); --imx-hover: oklch(97.5% 0.003 255);
  --imx-accent: oklch(55% 0.13 255);
  --imx-ok: oklch(60% 0.12 150); --imx-warn: oklch(64% 0.13 75); --imx-bad: oklch(56% 0.15 25);
  --imx-sans: "IBM Plex Sans KR", "Pretendard", "Malgun Gothic", "맑은 고딕", sans-serif;
  --imx-mono: "IBM Plex Mono", Consolas, "Malgun Gothic", monospace;
}

/* 상단 LOT 바: 공정명 + LOT 번호(모노) */
.abs { top: 8px; left: 20px; width: 1820px; transform: none; font-family: var(--imx-sans); }
.process-wrapper { gap: 0; padding: 0; background: #fff; border: 1px solid var(--imx-line); border-radius: 8px; box-shadow: none; overflow: hidden; }
.process-wrapper::before, .process-wrapper::after { display: none; }
.process-step-wrapper { flex: 1 1 0; border-left: 1px solid var(--imx-line2); min-width: 0; }
.process-step-wrapper:first-child { border-left: 0; }
.process-step { padding: 12px 8px 4px; font-size: 12px; font-weight: 500; color: var(--imx-fg3); background: transparent;
  border-radius: 0; box-shadow: none; animation: none; }
.process-step.active-green { background: transparent; color: var(--imx-fg2) !important; box-shadow: none; animation: none; filter: none; }
.process-step.active-green::before { content: ""; display: inline-block; width: 6px; height: 6px; border-radius: 50%; background: var(--imx-accent); margin-right: 4px; vertical-align: 1px; }
.process-bottom-bar { margin: 0; height: 36px; border-radius: 0; background: transparent; box-shadow: none;
  color: var(--imx-fg); font-family: var(--imx-mono); font-size: 13px; font-weight: 500; font-variant-numeric: tabular-nums slashed-zero; }
.process-bottom-bar:empty::before { content: "—"; color: var(--imx-line); font-weight: 400; }
.process-step-wrapper:hover .process-step { transform: none; box-shadow: none; }
.process-step-wrapper:hover .process-bottom-bar { background: var(--imx-hover); }

/* 하단 패널 */
.imx { width: 1860px; padding: 0 20px 24px; box-sizing: border-box; font-family: var(--imx-sans); font-size: 13px; color: var(--imx-fg); }
.imx * { box-sizing: border-box; }
.imx .mono, .imx-mt td, .imx-inv b, .imx-inv .s, .imx .dv, #tableAlarm td.t { font-family: var(--imx-mono); font-variant-numeric: tabular-nums slashed-zero; }
.imx .u { font-family: var(--imx-sans); font-style: normal; font-size: 12px; font-weight: 400; color: var(--imx-fg3); margin-left: 2px; }

/* 상태 바: 이상 건수가 첫 시선 */
.imx-bar { display: flex; align-items: center; gap: 24px; height: 48px; padding: 0 4px; border-bottom: 1px solid var(--imx-line); }
.imx-live { display: flex; align-items: center; gap: 8px; color: var(--imx-fg2); white-space: nowrap; }
.imx-live i { width: 8px; height: 8px; border-radius: 50%; background: var(--imx-ok); }
.imx-live .mono { color: var(--imx-fg); }
.imx-kpi { display: flex; align-items: baseline; margin: 0; }
.imx-kpi > div { display: flex; align-items: baseline; gap: 8px; padding: 0 16px; border-left: 1px solid var(--imx-line); }
.imx-kpi dt { color: var(--imx-fg2); white-space: nowrap; }
.imx-kpi dd { margin: 0; font-family: var(--imx-mono); font-size: 16px; font-weight: 500; font-variant-numeric: tabular-nums; }
.imx-kpi dd small { font-size: 12px; color: var(--imx-fg3); }
.imx-kpi .hero dt { color: var(--imx-fg); font-weight: 600; }
.imx-kpi .hero dd { font-size: 24px; }
.imx-kpi dd.warn { color: var(--imx-warn); } .imx-kpi dd.bad { color: var(--imx-bad); }
.imx-legend { margin-left: auto; color: var(--imx-fg3); font-size: 12px; white-space: nowrap; }

.imx-row { display: grid; gap: 16px; margin-top: 16px; }
.imx-row.r1 { grid-template-columns: 1fr 1fr; }
.imx-row.r2 { grid-template-columns: 1fr 1fr; }
.imx-card { background: #fff; border: 1px solid var(--imx-line); border-radius: 8px; padding: 12px 16px 8px; min-width: 0; }
.imx-card header { display: flex; align-items: baseline; justify-content: space-between; gap: 12px; margin-bottom: 4px; }
.imx-card h3 { margin: 0; font-size: 14px; font-weight: 600; color: var(--imx-fg); }
.imx-note { font-size: 12px; color: var(--imx-fg3); white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
.imx-note b { color: var(--imx-fg); font-weight: 500; }

/* 온도 표: 숫자는 우측 정렬, 행 = PV / 3분 추이 / SP / 편차 */
table.imx-mt { width: 100%; border-collapse: collapse; table-layout: fixed; }
.imx-mt th { white-space: nowrap; font-weight: 500 !important; }
.imx-mt thead th { font-size: 12px !important; color: var(--imx-fg2) !important; padding: 4px 8px 8px !important; text-align: right !important; }
.imx-mt thead th:first-child { width: 48px; }
.imx-mt tbody th { font-size: 12px !important; color: var(--imx-fg3) !important; text-align: left !important; padding: 0 !important; }
.imx-mt td { text-align: right !important; padding: 0 8px !important; white-space: nowrap; color: var(--imx-fg) !important; }
.imx-mt tr.pv td { height: 44px; padding-top: 4px !important; font-size: 22px !important; font-weight: 500 !important; }
.imx-mt tr.sk td { height: 32px; }
.imx-mt tr.sp td { height: 28px; font-size: 13px !important; color: var(--imx-fg2) !important; }
.imx-mt tr.dv td { height: 24px; padding-bottom: 4px !important; vertical-align: top; }
.imx-mt tr.pv td.dev-warn, .imx-inv b.dev-warn { color: var(--imx-warn) !important; }
.imx-mt tr.pv td.dev-bad, .imx-inv b.dev-bad { color: var(--imx-bad) !important; }
.imx .dv { font-size: 12px !important; color: var(--imx-fg3) !important; }
.imx .dv.warn { color: var(--imx-warn) !important; } .imx .dv.bad { color: var(--imx-bad) !important; font-weight: 500 !important; }

/* 스파크라인: 회색 띠 = 허용범위(주의 기준), 점선 = SP */
.imx .sk svg { display: block; width: 100%; height: 24px; overflow: visible; }
.imx .sk .band { fill: var(--imx-line2); }
.imx .sk .ref { stroke: var(--imx-fg3); stroke-width: 1; stroke-dasharray: 2 2; vector-effect: non-scaling-stroke; }
.imx .sk .ln { fill: none; stroke: var(--imx-fg2); stroke-width: 1.5; stroke-linejoin: round; vector-effect: non-scaling-stroke; }
.imx .sk .ln.warn { stroke: var(--imx-warn); } .imx .sk .ln.bad { stroke: var(--imx-bad); }

/* 인버터 */
.imx-inv { display: grid; grid-template-columns: repeat(6, minmax(0, 1fr)); }
.imx-inv > div { padding: 4px 12px 8px; border-left: 1px solid var(--imx-line2); display: flex; flex-direction: column; gap: 4px; min-width: 0; }
.imx-inv > div:first-child { border-left: 0; padding-left: 0; }
.imx-inv .n { font-size: 12px; color: var(--imx-fg2); white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
.imx-inv b { font-size: 22px; font-weight: 500; color: var(--imx-fg); white-space: nowrap; }
.imx-inv .sk { display: block; height: 24px; }
.imx-inv .s { display: flex; justify-content: space-between; gap: 8px; font-size: 12px; color: var(--imx-fg3); white-space: nowrap; }
.imx-inv .s em { font-style: normal; color: var(--imx-fg2); }

/* 알람 */
#tableAlarmWrapper { max-height: none; overflow: visible; }
#tableAlarm { width: 100%; height: auto; border-collapse: collapse; table-layout: fixed; }
#tableAlarm th, #tableAlarm td { font-size: 13px !important; padding: 0 8px !important; text-align: left !important; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
#tableAlarm th { position: sticky; top: 0; z-index: 1; color: var(--imx-fg2) !important; font-weight: 500 !important; font-size: 12px !important; height: 28px; }
#tableAlarm th.t, #tableAlarm td.t { text-align: right !important; }
#tableAlarm td { height: 32px; color: var(--imx-fg2) !important; font-weight: 400 !important; }
#tableAlarm td.t { font-size: 12px !important; }
#tableAlarm tbody tr:hover td { background: var(--imx-hover) !important; transition: background-color 80ms; }
#tableAlarm tr.on td { color: var(--imx-fg) !important; }
#tableAlarm tr.on td.st { color: var(--imx-bad) !important; font-weight: 500 !important; }
#tableAlarm .dot { display: inline-block; width: 6px; height: 6px; border-radius: 50%; margin-right: 8px; background: var(--imx-line); vertical-align: 1px; }
#tableAlarm tr.on .dot { background: var(--imx-bad); }
#tableAlarm td.empty { color: var(--imx-fg3) !important; }

/* 원본 전역 table 스타일(파란 헤더·하늘색 셀·테두리) 무력화 */
.imx table, .imx th, .imx td { border: 0 !important; background: transparent !important; box-shadow: none !important; }
.imx .imx-mt thead th, .imx #tableAlarm th { border-bottom: 1px solid var(--imx-line) !important; background: #fff !important; }
.imx .imx-mt tr.sp > * { border-top: 1px solid var(--imx-line2) !important; }
.imx #tableAlarm td { border-bottom: 1px solid var(--imx-line2) !important; }
</style>
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
  
  
<!-- ===== 데모: 하단 패널 재설계 (설비 도면은 위 그대로) ===== -->
<div class="imx">
  <div class="imx-bar">
    <div class="imx-live"><i></i>실시간 <span class="mono" id="imxClock">—</span></div>
    <dl class="imx-kpi">
      <div class="hero"><dt>온도·CP 이상</dt><dd id="kBad">—</dd></div>
      <div><dt>주의</dt><dd id="kWarn">—</dd></div>
      <div><dt>정상</dt><dd id="kOk">—</dd></div>
      <div><dt>인버터 편차</dt><dd id="kInv">—</dd></div>
      <div><dt>발생중 알람</dt><dd id="kAlarm">—</dd></div>
      <div><dt>투입 공정</dt><dd><span id="kLot">—</span><small>/16</small></dd></div>
    </dl>
    <span class="imx-legend">편차 기준(주의/이상) · 온도 ±5/±10℃ · CP ±0.02/±0.04 · 인버터 ±1/±2 Hz</span>
  </div>

  <div class="imx-row r1">
    <section class="imx-card">
      <header><h3>소입 라인</h3><span class="imx-note">온도 ℃ · 추이 최근 3분</span></header>
      <table class="imx-mt">
        <thead><tr><th></th><th>전세정기</th><th>1존</th><th>2존</th><th>3존</th><th>4존</th><th>5존</th><th>유조</th><th>CP-A</th></tr></thead>
        <tbody>
          <tr class="pv"><th>PV</th>
            <td class="F_WASH_PV" data-sp="F_WASH_SP">—</td><td class="Q_PV_1" data-sp="Q_SP_1">—</td><td class="Q_PV_2" data-sp="Q_SP_2">—</td>
            <td class="Q_PV_3" data-sp="Q_SP_3">—</td><td class="Q_PV_4" data-sp="Q_SP_4">—</td><td class="Q_PV_5" data-sp="Q_SP_5">—</td>
            <td class="OIL_PV" data-sp="OIL_SP">—</td><td class="CP_PV_1" data-sp="CP_SP_1" data-cp="1">—</td></tr>
          <tr class="sk"><th>추이</th><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td></tr>
          <tr class="sp"><th>SP</th>
            <td class="F_WASH_SP">—</td><td class="Q_SP_1">—</td><td class="Q_SP_2">—</td><td class="Q_SP_3">—</td>
            <td class="Q_SP_4">—</td><td class="Q_SP_5">—</td><td class="OIL_SP">—</td><td class="CP_SP_1">—</td></tr>
          <tr class="dv"><th>편차</th><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td></tr>
        </tbody>
      </table>
    </section>
    <section class="imx-card">
      <header><h3>소려 라인</h3><span class="imx-note">온도 ℃ · 추이 최근 3분</span></header>
      <table class="imx-mt">
        <thead><tr><th></th><th>중간세정기</th><th>1존</th><th>2존</th><th>3존</th><th>4존</th><th>5존</th><th>방청</th><th>CP-B</th></tr></thead>
        <tbody>
          <tr class="pv"><th>PV</th>
            <td class="M_WASH_PV" data-sp="M_WASH_SP">—</td><td class="T_PV_1" data-sp="T_SP_1">—</td><td class="T_PV_2" data-sp="T_SP_2">—</td>
            <td class="T_PV_3" data-sp="T_SP_3">—</td><td class="T_PV_4" data-sp="T_SP_4">—</td><td class="T_PV_5" data-sp="T_SP_5">—</td>
            <td class="BC_PV" data-sp="BC_SP">—</td><td class="CP_PV_2" data-sp="CP_SP_2" data-cp="1">—</td></tr>
          <tr class="sk"><th>추이</th><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td></tr>
          <tr class="sp"><th>SP</th>
            <td class="M_WASH_SP">—</td><td class="T_SP_1">—</td><td class="T_SP_2">—</td><td class="T_SP_3">—</td>
            <td class="T_SP_4">—</td><td class="T_SP_5">—</td><td class="BC_SP">—</td><td class="CP_SP_2">—</td></tr>
          <tr class="dv"><th>편차</th><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td></tr>
        </tbody>
      </table>
    </section>
  </div>

  <div class="imx-row r2">
    <section class="imx-card">
      <header><h3>인버터 제어</h3><span class="imx-note">주파수 Hz · 추이 최근 3분</span></header>
      <div class="imx-inv">
        <div><span class="n">전세정기</span><b class="IN_WASH_PV" data-sp="IN_WASH_SP" data-hz="1">—</b><span class="sk"></span><span class="s"><span>SP <em class="IN_WASH_SP">—</em></span><span class="dv"></span></span></div>
        <div><span class="n">소입로</span><b class="IN_Q_PV" data-sp="IN_Q_SP" data-hz="1">—</b><span class="sk"></span><span class="s"><span>SP <em class="IN_Q_SP">—</em></span><span class="dv"></span></span></div>
        <div><span class="n">소입유조</span><b class="IN_OIL_PV" data-sp="IN_OIL_SP" data-hz="1">—</b><span class="sk"></span><span class="s"><span>SP <em class="IN_OIL_SP">—</em></span><span class="dv"></span></span></div>
        <div><span class="n">아지테이터 FAN</span><b class="IN_DATA_PV" data-sp="IN_DATA_SP" data-hz="1">—</b><span class="sk"></span><span class="s"><span>SP <em class="IN_DATA_SP">—</em></span><span class="dv"></span></span></div>
        <div><span class="n">중간세정기</span><b class="IN_M_WASH_PV" data-sp="IN_M_WASH_SP" data-hz="1">—</b><span class="sk"></span><span class="s"><span>SP <em class="IN_M_WASH_SP">—</em></span><span class="dv"></span></span></div>
        <div><span class="n">소려로</span><b class="IN_T_PV" data-sp="IN_T_SP" data-hz="1">—</b><span class="sk"></span><span class="s"><span>SP <em class="IN_T_SP">—</em></span><span class="dv"></span></span></div>
      </div>
    </section>
    <section class="imx-card">
      <header><h3>최근 알람</h3><span class="imx-note" id="imxAlarmCnt"></span></header>
      <div id="tableAlarmWrapper">
        <table id="tableAlarm">
          <colgroup><col style="width:88px"><col><col style="width:112px"><col style="width:64px"></colgroup>
          <thead><tr><th>상태</th><th>알람 내용</th><th class="t">발생</th><th class="t">해제</th></tr></thead>
          <tbody></tbody>
        </table>
      </div>
    </section>
  </div>
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
        if (el.closest(".imx")) { imxValue(el, key, val); return; }
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
// =====================
// 데모: PV 와 SP 를 비교해 편차 색상 표시 (온도 ±5/±10℃, CP ±0.02/±0.04, Hz ±1/±2)
//       + 최근 3분 추이 스파크라인, 상단 상태 바 집계
// =====================
var IMX_N = 180, imxHist = {}, imxAlarmOn = null;

// 하단 패널 값: 소수 자릿수 고정(자리 흔들림 방지), 단위는 PV 에만 작게
function imxValue(el, key, val) {
    var n = Number(val);
    if (val === "" || val == null || isNaN(n) || (key === "CP_SP_2" && n === 0)) { el.textContent = "—"; return; }
    var unit = key.indexOf("IN_") === 0 ? "Hz" : key.indexOf("CP_") === 0 ? "" : "℃";
    var dp = unit === "℃" ? (el.dataset.sp ? 1 : (n % 1 ? 1 : 0)) : 2;
    el.innerHTML = n.toFixed(dp) + (el.dataset.sp && unit ? '<i class="u">' + unit + "</i>" : "");
}

function imxNum(el) { var n = parseFloat(String(el ? el.textContent : "").replace(/[^0-9.\-]/g, "")); return isNaN(n) ? null : n; }

// PV 셀과 같은 열의 추이/편차 칸 (표는 같은 열, 인버터는 같은 블록)
function imxSlot(el, cls) {
    if (el.tagName === "TD") { var r = el.closest("table").querySelector("tr." + cls); return r ? r.cells[el.cellIndex] : null; }
    return el.parentNode.querySelector("." + cls);
}

function imxSpark(box, h, sp, l1, st) {
    if (!box || h.length < 2) return;
    var lo = Math.min.apply(null, h), hi = Math.max.apply(null, h);
    // 세로축은 최소 ±l1 폭 확보 (SP 가 없으면 평균 기준) → 미세 변동이 계단처럼 과장되지 않게
    var c = sp != null ? sp : (lo + hi) / 2;
    lo = Math.min(lo, c - l1); hi = Math.max(hi, c + l1);
    var pad = (hi - lo) * 0.1 || l1; lo -= pad; hi += pad;
    function y(v) { return (24 * (hi - v) / (hi - lo)).toFixed(2); }
    // 처음 1분은 수집분만으로 폭을 채우고, 이후 3분 창으로 고정
    var w = Math.max(h.length, 60), off = w - h.length;
    var pts = h.map(function (v, i) { return (100 * (off + i) / (w - 1)).toFixed(2) + "," + y(v); }).join(" ");
    var ref = sp == null ? "" :
        '<rect class="band" x="0" width="100" y="' + y(sp + l1) + '" height="' + (y(sp - l1) - y(sp + l1)).toFixed(2) + '"/>' +
        '<line class="ref" x1="0" x2="100" y1="' + y(sp) + '" y2="' + y(sp) + '"/>';
    box.innerHTML = '<svg viewBox="0 0 100 24" preserveAspectRatio="none" aria-hidden="true">' + ref +
        '<polyline class="ln ' + st + '" points="' + pts + '"/></svg>';
}

function imxDeviation() {
    var cnt = { ok: 0, warn: 0, bad: 0 }, inv = 0;
    document.querySelectorAll(".imx [data-sp]").forEach(function (el) {
        var sp = imxNum(document.querySelector(".imx ." + el.getAttribute("data-sp")));
        var pv = imxNum(el), dv = imxSlot(el, "dv"), st = "ok";
        var l1 = el.dataset.cp ? 0.02 : el.dataset.hz ? 1 : 5, dp = el.dataset.cp || el.dataset.hz ? 2 : 1;
        el.classList.remove("dev-warn", "dev-bad");
        if (dv) dv.className = "dv";
        if (pv == null) return;
        var h = imxHist[el.classList[0]] || (imxHist[el.classList[0]] = []);
        h.push(pv); if (h.length > IMX_N) h.shift();
        if (sp != null) {
            var d = pv - sp, ad = Math.abs(d);
            st = ad > l1 * 2 ? "bad" : ad > l1 ? "warn" : "ok";
            if (st !== "ok") el.classList.add("dev-" + st);
            if (dv) { dv.textContent = (d > 0 ? "+" : d < 0 ? "−" : "±") + ad.toFixed(dp); if (st !== "ok") dv.classList.add(st); }
            if (el.dataset.hz) { if (st !== "ok") inv++; } else cnt[st]++;
        } else if (dv) dv.textContent = "—";
        imxSpark(imxSlot(el, "sk"), h, sp, l1, st);
    });

    function kpi(id, n, st) { var e = document.getElementById(id); if (!e) return; e.textContent = n == null ? "—" : n; e.className = n > 0 && st ? st : ""; }
    if (cnt.ok + cnt.warn + cnt.bad > 0) { kpi("kBad", cnt.bad, "bad"); kpi("kWarn", cnt.warn, "warn"); kpi("kOk", cnt.ok); kpi("kInv", inv, "warn"); }
    kpi("kAlarm", imxAlarmOn, "bad");
    kpi("kLot", document.querySelectorAll(".process-step.active-green").length);
    var t = new Date(), p = function (n) { return String(n).padStart(2, "0"); };
    document.getElementById("imxClock").textContent = t.getFullYear() + "-" + p(t.getMonth() + 1) + "-" + p(t.getDate()) + " " + p(t.getHours()) + ":" + p(t.getMinutes()) + ":" + p(t.getSeconds());
}
setInterval(imxDeviation, 1000);

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

// 알람 표가 화면 아래 끝을 넘지 않는 행 수 (머리행 28 · 카드 아래 9 · 페이지 아래 24 · 행 32px)
function imxAlarmMax() {
    var top = 0, z = parseFloat(document.documentElement.style.zoom) || 1;
    for (var e = document.getElementById("tableAlarmWrapper"); e; e = e.offsetParent) top += e.offsetTop;
    return Math.max(2, Math.floor((window.innerHeight / z - top - 28 - 9 - 24) / 32));
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
                $tbody.append('<tr><td colspan="4" class="empty">최근 알람 없음</td></tr>');
                $("#imxAlarmCnt").text("");
                imxAlarmOn = 0;
                return;
            }

            var onCnt = 0, max = imxAlarmMax();
            arr.forEach(function(r) { if (!r.a_etime) onCnt++; });
            // 발생중 알람을 먼저, 화면 세로 스크롤이 생기지 않는 개수까지만
            arr = arr.filter(function(r) { return !r.a_etime; }).concat(arr.filter(function(r) { return r.a_etime; })).slice(0, max);
            arr.forEach(function(r, idx) {
                var on = !r.a_etime;
                var tr = $("<tr></tr>").toggleClass("on", on);
                tr.append("<td class='st'><i class='dot'></i>" + (on ? "발생중" : "해제") + "</td>");
                tr.append($("<td></td>").text(r.a_desc || "").attr("title", r.a_desc || ""));
                tr.append("<td class='t'>" + String(r.a_stime || "").substr(5, 11) + "</td>");
                tr.append("<td class='t'>" + (on ? "—" : String(r.a_etime).substr(11, 5)) + "</td>");
                tr.data("rowdata", r);
                $tbody.append(tr);
            });
            imxAlarmOn = onCnt;
            $("#imxAlarmCnt").html("최근 <b>" + arr.length + "</b>건");
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