<%@ page contentType="application/json; charset=UTF-8" pageEncoding="UTF-8" import="java.util.*" trimDirectiveWhitespaces="true"%><%
    /* 데모 로그인: ID ez / PW ez (DB 없음) */
    request.setCharacterEncoding("UTF-8");
    String id = request.getParameter("user_id");
    String pw = request.getParameter("user_pw");
    if (id == null || id.trim().isEmpty()) { out.print("{\"success\":false,\"message\":\"아이디를 입력하세요.\"}"); return; }
    if (pw == null || pw.trim().isEmpty()) { out.print("{\"success\":false,\"message\":\"비밀번호를 입력하세요.\"}"); return; }
    if (!"ez".equals(id.trim()) || !"ez".equals(pw)) { out.print("{\"success\":false,\"message\":\"아이디 또는 비밀번호가 올바르지 않습니다.\"}"); return; }
    Map<String, Object> emp = new HashMap<String, Object>();
    emp.put("id", "ez");
    emp.put("emp_name", "관리자");
    emp.put("user_code", 1);
    session.setAttribute("loginEmp", emp);
    out.print("{\"success\":true}");
%>
