<%@ page contentType="application/json; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true"%><%
    session.invalidate();
    out.print("{\"result\":\"success\"}");
%>
