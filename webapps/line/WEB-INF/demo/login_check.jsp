<%@ page contentType="application/json; charset=UTF-8" pageEncoding="UTF-8" import="java.util.*" trimDirectiveWhitespaces="true"%><%
    /* 데모 로그인: ID ez / PW ez (DB 없음) */
    request.setCharacterEncoding("UTF-8");
    String id = request.getParameter("user_id");
    String pw = request.getParameter("user_pw");
    if (id == null || id.trim().isEmpty()) { out.print("{\"data\":\"ID를 입력해주십시오!\"}"); return; }
    if (pw == null || pw.trim().isEmpty()) { out.print("{\"data\":\"PW를 입력해주십시오!\"}"); return; }
    if (!"ez".equals(id.trim()) || !"ez".equals(pw)) { out.print("{\"data\":\"등록되지 않은 사용자입니다.\"}"); return; }
    Map<String, Object> user = new HashMap<String, Object>();
    user.put("user_code", 1);
    user.put("user_id", "ez");
    user.put("user_name", "관리자");
    user.put("user_level", "관리자");
    session.setAttribute("loginUser", user);
    out.print("{\"data\":{\"user_code\":1,\"user_id\":\"ez\",\"user_name\":\"관리자\"}}");
%>
