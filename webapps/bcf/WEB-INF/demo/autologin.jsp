<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.util.*"%><%
    /* 데모: 로그인 화면 없이 관리자(ez)로 바로 입장 */
    Map<String, Object> emp = new HashMap<String, Object>();
    emp.put("id", "ez");
    emp.put("emp_name", "관리자");
    emp.put("user_code", 1);
    session.setAttribute("loginEmp", emp);
    response.sendRedirect(request.getContextPath() + "/main_1/main");
%>
