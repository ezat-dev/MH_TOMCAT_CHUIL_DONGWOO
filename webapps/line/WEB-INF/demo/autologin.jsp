<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.util.*"%><%
    /* 데모: 로그인 화면 없이 관리자(ez)로 바로 입장 */
    Map<String, Object> user = new HashMap<String, Object>();
    user.put("user_code", 1);
    user.put("user_id", "ez");
    user.put("user_name", "관리자");
    user.put("user_level", "관리자");
    session.setAttribute("loginUser", user);
    response.sendRedirect(request.getContextPath() + "/main");
%>
