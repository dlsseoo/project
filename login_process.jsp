<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    String empId = request.getParameter("emp_id");
    String password = request.getParameter("password");

    Connection conn = null;
    try {
        Class.forName("org.postgresql.Driver");
        conn = DriverManager.getConnection("jdbc:postgresql://localhost:5432/mydb", "inseo", "");

        // DB에서 사번과 비밀번호가 일치하는지 확인
        String sql = "SELECT emp_id, name FROM admins WHERE emp_id = ? AND password = ?";
        PreparedStatement pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, empId);
        pstmt.setString(2, password);
        ResultSet rs = pstmt.executeQuery();

        if (rs.next()) {
            // [핵심] 로그인 성공 시 세션에 사번 저장
            session.setAttribute("adminId", rs.getString("emp_id"));
            // 메인 페이지로 이동
            response.sendRedirect("dbtest.jsp");
        } else {
            // 로그인 실패 시 다시 로그인 페이지로 (에러 파라미터 포함)
            response.sendRedirect("login.jsp?error=1");
        }
    } catch (Exception e) {
        out.println("로그인 처리 중 오류 발생: " + e.getMessage());
    } finally {
        if (conn != null) conn.close();
    }
%>