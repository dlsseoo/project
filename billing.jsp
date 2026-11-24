<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>청구서 발행 - 상수도 관리 시스템</title>
    <style>
        /* 공통 네비게이션 스타일 */
        * { box-sizing: border-box; }
        body { font-family: 'Malgun Gothic', sans-serif; margin: 0; background-color: #f0f2f5; }
        .navbar { background-color: #2c3e50; color: white; min-height: 65px; display: flex; align-items: center; padding: 0 20px; flex-wrap: wrap; }
        .navbar-brand { font-size: 20px; font-weight: bold; color: #3498db; text-decoration: none; padding: 15px 0; margin-right: 30px; }
        .nav-links { list-style: none; display: flex; gap: 10px; margin: 0; padding: 0; flex-wrap: wrap; }
        .nav-links li a { color: #bdc3c7; text-decoration: none; font-size: 14px; padding: 10px 12px; display: inline-block; }
        .nav-links li a.active { color: white; border-bottom: 3px solid #3498db; }
        
        .main-container { padding: 40px 20px; display: flex; flex-direction: column; align-items: center; }

        /* [고지서 전용 스타일] */
        .bill-paper { 
            width: 100%; 
            max-width: 700px; 
            background: white; 
            padding: 50px; 
            border: 1px solid #ccc; 
            box-shadow: 0 0 20px rgba(0,0,0,0.1);
            position: relative;
        }
        .bill-header { text-align: center; border-bottom: 2px solid #333; padding-bottom: 20px; margin-bottom: 30px; }
        .bill-table { width: 100%; border-collapse: collapse; margin-bottom: 30px; }
        .bill-table th, .bill-table td { border: 1px solid #333; padding: 12px; text-align: left; }
        .bill-table th { background: #f8f9fa; width: 30%; }
        .total-amount { font-size: 24px; font-weight: bold; color: #e74c3c; text-align: right; margin-top: 20px; }
        
        .btn-print { 
            margin-top: 30px; 
            padding: 12px 30px; 
            background: #2c3e50; 
            color: white; 
            border: none; 
            border-radius: 5px; 
            cursor: pointer; 
            font-weight: bold;
        }

        /* 인쇄 시 네비게이션 숨기기 */
        @media print {
            .navbar, .btn-print { display: none; }
            body { background: white; }
            .main-container { padding: 0; }
            .bill-paper { border: none; box-shadow: none; width: 100%; }
        }
    </style>
</head>
<body>
    <nav class="navbar">
        <a href="dbtest.jsp" class="navbar-brand">💧 SMART WATER</a>
        <ul class="nav-links">
            <li><a href="dbtest.jsp">대시보드</a></li>
            <li><a href="#">고객 관리</a></li>
            <li><a href="overdue_list.jsp">연체/미납 관리</a></li>
            <li><a href="billing.jsp" class="active">청구서 발행</a></li>
        </ul>
    </nav>

    <div class="main-container">
        <%
            String id = request.getParameter("id");
            if(id == null) id = "1651841"; // 샘플 아이디

            Connection conn = DriverManager.getConnection("jdbc:postgresql://localhost:5432/mydb", "inseo", "");
            PreparedStatement pstmt = conn.prepareStatement("SELECT * FROM customers WHERE meter_id = ?");
            pstmt.setString(1, id);
            ResultSet rs = pstmt.executeQuery();

            if(rs.next()) {
                int total = rs.getInt("usage_amount") + rs.getInt("overdue_amount");
        %>
            <div class="bill-paper">
                <div class="bill-header">
                    <h1 style="margin:0;">상수도 요금 청구서</h1>
                    <p style="color:#666;">발행일: 2026년 1월 7일</p>
                </div>
                
                <table class="bill-table">
                    <tr><th>성함</th><td><%= rs.getString("name") %> 님</td></tr>
                    <tr><th>계량기 번호</th><td><%= rs.getString("meter_id") %></td></tr>
                    <tr><th>주소</th><td><%= rs.getString("address") %></td></tr>
                    <tr><th>당월 사용 요금</th><td><%= String.format("%,d", rs.getInt("usage_amount")) %>원</td></tr>
                    <tr><th>연체 미납액</th><td><%= String.format("%,d", rs.getInt("overdue_amount")) %>원</td></tr>
                </table>
                
                <div class="total-amount">
                    총 납부금액: <%= String.format("%,d", total) %>원
                </div>
                
                <div style="margin-top:40px; border-top: 1px dashed #ccc; padding-top:20px; font-size:14px; line-height:1.6;">
                    * 납부 기한: 2026년 1월 31일<br>
                    * 납부 계좌: 신한은행 110-123-456789 (서울특별시 수도국)<br>
                    * 문의 전화: 02-120 (다산콜센터)
                </div>
            </div>
            
            <button class="btn-print" onclick="window.print()">🖨️ 청구서 인쇄하기</button>
        <% 
            } else { 
                out.println("<h3>해당 고객 정보를 찾을 수 없습니다.</h3>");
            } 
            conn.close();
        %>
    </div>
</body>
</html>