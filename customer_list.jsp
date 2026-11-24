<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.DecimalFormat" %>
<%
    // [1. セキュリティ及びセッションチェック]
    String sessionAdminId = (String) session.getAttribute("adminId");
    if (sessionAdminId == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String adminName = "";
    Connection conn = null;
    DecimalFormat df = new DecimalFormat("¥###,###");

    try {
        Class.forName("org.postgresql.Driver");
        conn = DriverManager.getConnection("jdbc:postgresql://localhost:5432/mydb", "inseo", "");

        // 管理者名取得
        String sqlAdmin = "SELECT name FROM admins WHERE emp_id = ?";
        PreparedStatement pstmtAdmin = conn.prepareStatement(sqlAdmin);
        pstmtAdmin.setString(1, sessionAdminId);
        ResultSet rsAdmin = pstmtAdmin.executeQuery();
        if(rsAdmin.next()) { adminName = rsAdmin.getString("name"); }
%>
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>顧客一覧 - SMART WATER JP</title>
    <style>
        * { box-sizing: border-box; }
        body { font-family: "Meiryo", sans-serif; margin: 0; background-color: #f8f9fa; }
        .navbar { background-color: #2c3e50; color: white; height: 60px; display: flex; align-items: center; padding: 0 30px; }
        .navbar-brand { font-size: 18px; font-weight: bold; color: #3498db; text-decoration: none; margin-right: 40px; }
        .nav-links { list-style: none; display: flex; gap: 25px; margin: 0; padding: 0; }
        .nav-links li a { color: #bdc3c7; text-decoration: none; font-size: 14px; font-weight: 500; }
        .nav-links li a.active { color: white; border-bottom: 2px solid #3498db; padding-bottom: 5px; }
        .admin-mini-bar { background: #fff; padding: 8px 30px; border-bottom: 1px solid #ddd; display: flex; justify-content: flex-end; font-size: 12px; color: #666; }
        .btn-logout { color: #e74c3c; text-decoration: none; margin-left: 15px; font-weight: bold; }
        .main-container { max-width: 1200px; margin: 30px auto; padding: 0 20px; }
        .content-card { background: white; border-radius: 10px; padding: 25px; box-shadow: 0 2px 10px rgba(0,0,0,0.05); }
        .list-table { width: 100%; border-collapse: collapse; margin-top: 20px; }
        .list-table th { background: #f1f3f5; padding: 12px; text-align: left; border-bottom: 2px solid #dee2e6; color: #495057; }
        .list-table td { padding: 12px; border-bottom: 1px solid #eee; font-size: 14px; }
        .name-link { color: #3498db; text-decoration: none; font-weight: bold; border-bottom: 1px solid transparent; }
        .name-link:hover { border-bottom: 1px solid #3498db; }
        .usage-badge { background: #e8f4fd; color: #2980b9; padding: 4px 8px; border-radius: 4px; font-size: 12px; }
    </style>
</head>
<body>
    <nav class="navbar">
        <a href="dbtest.jsp" class="navbar-brand">💧 SMART WATER JP</a>
        <ul class="nav-links">
            <li><a href="dbtest.jsp">ホーム</a></li>
            <li><a href="customer_list.jsp" class="active">顧客一覧</a></li>
            <li><a href="overdue_list.jsp">滞納者リスト</a></li>
            <li><a href="district_manage.jsp">管轄区域管理</a></li>
        </ul>
    </nav>
    <div class="admin-mini-bar">
        <span>ログイン管理者: <b><%= adminName %></b> 様 (社員番号: <%= sessionAdminId %>)</span>
        <a href="logout.jsp" class="btn-logout">ログアウト</a>
    </div>

    <div class="main-container">
        <div class="content-card">
            <h2 style="font-size: 20px;">👥 顧客管理名簿</h2>
            <p style="color: #666; font-size: 13px;">※ お名前をクリックすると詳細な検針データが表示されます。</p>
            
            <table class="list-table">
                <thead>
                    <tr>
                        <th>氏名</th>
                        <th>メーター固有番号</th>
                        <th>詳細住所</th>
                        <th>今月使用量</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        String sqlCust = "SELECT * FROM customers ORDER BY name ASC";
                        Statement stmt = conn.createStatement();
                        ResultSet rs = stmt.executeQuery(sqlCust);
                        
                        while(rs.next()) {
                    %>
                    <tr>
                        <td>
                            <a href="customer_detail.jsp?meter_id=<%= rs.getString("meter_id") %>" class="name-link">
                                <%= rs.getString("name") %> 様
                            </a>
                        </td>
                        <td><code><%= rs.getString("meter_id") %></code></td>
                        <td><%= rs.getString("address") %></td>
                        <td><span class="usage-badge"><%= String.format("%,d", rs.getInt("usage_amount")) %> m³</span></td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
        </div>
    </div>
</body>
</html>
<%
    } catch (Exception e) { out.println("Error: " + e.getMessage()); } finally { if(conn != null) conn.close(); }
%>