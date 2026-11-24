<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.DecimalFormat" %>
<%
    String sessionAdminId = (String) session.getAttribute("adminId");
    if (sessionAdminId == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    Connection conn = null;
    String adminName = "";
    DecimalFormat df = new DecimalFormat("¥###,###");

    try {
        Class.forName("org.postgresql.Driver");
        conn = DriverManager.getConnection("jdbc:postgresql://localhost:5432/mydb", "inseo", "");

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
    <title>滞納者リスト - SMART WATER JP</title>
    <style>
        body { font-family: "Meiryo", sans-serif; margin: 0; background: #fff5f5; }
        .navbar { background: #2c3e50; color: white; padding: 0 30px; display: flex; justify-content: space-between; align-items: center; height: 60px; }
        .admin-bar { background: #fff; padding: 10px 30px; border-bottom: 1px solid #ddd; text-align: right; font-size: 12px; color: #666; }
        .main-container { max-width: 1100px; margin: 30px auto; background: white; padding: 25px; border-radius: 12px; box-shadow: 0 4px 12px rgba(0,0,0,0.1); }
        .btn-logout { color: #e74c3c; text-decoration: none; margin-left: 15px; font-weight: bold; }
        table { width: 100%; border-collapse: collapse; margin-top: 20px; }
        th, td { padding: 15px; border-bottom: 1px solid #eee; text-align: left; font-size: 14px; }
        th { background: #fff5f5; color: #c0392b; border-top: 2px solid #e74c3c; }
        .name-link { color: #e74c3c; text-decoration: none; font-weight: bold; }
        .price-text { color: #c0392b; font-weight: bold; font-family: 'Consolas', monospace; }
        .badge-warning { background: #fee2e2; color: #ef4444; padding: 3px 8px; border-radius: 4px; font-size: 12px; border: 1px solid #fecaca; }
    </style>
</head>
<body>
    <nav class="navbar">
        <div style="font-size:18px; font-weight:bold; color:#3498db;">⚠️ 滞納管理システム</div>
        <div style="display:flex; gap:20px;">
            <a href="customer_list.jsp" style="color:#bdc3c7; text-decoration:none;">顧客一覧</a>
            <a href="overdue_list.jsp" style="color:white; text-decoration:none; border-bottom:2px solid #e74c3c;">滞納者リスト</a>
        </div>
    </nav>

    <div class="admin-bar">
        ログイン管理者: <b><%= adminName %></b> 様 (社員番号: <%= sessionAdminId %>)
        <a href="logout.jsp" class="btn-logout">ログアウト</a>
    </div>

    <div class="main-container">
        <h2 style="color:#c0392b; font-size:22px;">⚠️ 料金未納者一覧</h2>
        <p style="font-size: 13px; color: #888;">※ 未納金額の高い順に表示されています。督促状の送付対象を確認してください。</p>
        
        <table>
            <thead>
                <tr>
                    <th>顧客名</th>
                    <th>未納金額 (税込)</th>
                    <th>滞納期間</th>
                    <th>メーター番号</th>
                </tr>
            </thead>
            <tbody>
                <%
                    String sqlOverdue = "SELECT * FROM customers WHERE overdue_amount > 0 ORDER BY overdue_amount DESC";
                    Statement stmt = conn.createStatement();
                    ResultSet rs = stmt.executeQuery(sqlOverdue);
                    while(rs.next()) {
                %>
                <tr>
                    <td><a href="customer_detail.jsp?meter_id=<%= rs.getString("meter_id") %>" class="name-link"><%= rs.getString("name") %> 様</a></td>
                    <td class="price-text"><%= df.format(rs.getInt("overdue_amount")) %></td>
                    <td><span class="badge-warning"><%= rs.getInt("overdue_months") %>ヶ月</span></td>
                    <td><code><%= rs.getString("meter_id") %></code></td>
                </tr>
                <% } %>
            </tbody>
        </table>
    </div>
</body>
</html>
<%
    } catch (Exception e) { out.println("Error: " + e.getMessage()); } finally { if(conn != null) conn.close(); }
%>