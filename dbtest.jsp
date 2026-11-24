<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    // [1. セキュリティ及びセッションチェック] ログイン状態の確認
    String sessionAdminId = (String) session.getAttribute("adminId");
    if (sessionAdminId == null) {
        response.sendRedirect("login.jsp"); 
        return;
    }

    String adminName = "";
    Connection conn = null;
    try {
        Class.forName("org.postgresql.Driver");
        conn = DriverManager.getConnection("jdbc:postgresql://localhost:5432/mydb", "inseo", "");
        
        // [2. DBから実際の管理者名を取得] セッションの社員番号(sessionAdminId)基準
        String sqlAdmin = "SELECT name FROM admins WHERE emp_id = ?";
        PreparedStatement pstmtAdmin = conn.prepareStatement(sqlAdmin);
        pstmtAdmin.setString(1, sessionAdminId);
        ResultSet rsAdmin = pstmtAdmin.executeQuery();
        
        if(rsAdmin.next()) {
            adminName = rsAdmin.getString("name");
        }
%>
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>水道管理システム - メイン</title>
    <style>
        * { box-sizing: border-box; }
        /* 日本語表示に最適化されたフォント設定 */
        body { font-family: "Meiryo", "Hiragino Kaku Gothic ProN", sans-serif; margin: 0; background-color: #f8f9fa; }
        
        /* ナビゲーションスタイル */
        .navbar { background-color: #2c3e50; color: white; height: 60px; display: flex; align-items: center; padding: 0 30px; }
        .navbar-brand { font-size: 18px; font-weight: bold; color: #3498db; text-decoration: none; margin-right: 40px; }
        .nav-links { list-style: none; display: flex; gap: 25px; margin: 0; padding: 0; }
        .nav-links li a { color: #bdc3c7; text-decoration: none; font-size: 15px; font-weight: 500; }
        .nav-links li a.active { color: white; border-bottom: 2px solid #3498db; padding-bottom: 5px; }
        
        .admin-mini-bar { background: #fff; padding: 8px 30px; border-bottom: 1px solid #ddd; display: flex; justify-content: flex-end; font-size: 12px; color: #666; }
        .btn-logout { color: #e74c3c; text-decoration: none; margin-left: 15px; font-weight: bold; }

        .main-container { max-width: 1200px; margin: 20px auto; padding: 0 20px; }
        
        /* バナー領域 */
        .image-banner { width: 100%; height: 350px; background: #ccc; border-radius: 10px; margin-bottom: 30px; overflow: hidden; position: relative; }
        .image-banner img { width: 100%; height: 100%; object-fit: cover; }
        .banner-text { position: absolute; bottom: 30px; left: 30px; color: white; font-size: 28px; font-weight: bold; text-shadow: 2px 2px 8px rgba(0,0,0,0.7); }
    </style>
</head>
<body>
    <nav class="navbar">
        <a href="dbtest.jsp" class="navbar-brand">💧 SMART WATER JP</a>
        <ul class="nav-links">
            <li><a href="dbtest.jsp" class="active">ホーム</a></li>
            <li><a href="customer_list.jsp">顧客一覧</a></li>
            <li><a href="overdue_list.jsp">滞納者リスト</a></li>
            <li><a href="district_manage.jsp">管轄区域管理</a></li>
        </ul>
    </nav>
    <div class="admin-mini-bar">
        <span>ログイン管理者: <b><%= adminName %></b> 様 (社員番号: <%= sessionAdminId %>)</span>
        <a href="logout.jsp" class="btn-logout">ログアウト</a>
    </div>

    <div class="main-container">
        <div class="image-banner">
            <img src="company_photo.jpg" onerror="this.src='https://via.placeholder.com/1200x350?text=水道局+管理システム'">
            <div class="banner-text">安全な水の管理、市民の幸せのために</div>
        </div>
        
        <div style="display: flex; gap: 20px;">
            <div style="flex: 1; background: white; padding: 25px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.05);">
                <h3>📊 本日の要約</h3>
                <%
                    // [3. 統計データのリアルタイム照会]
                    Statement stmt = conn.createStatement();
                    ResultSet rsTotal = stmt.executeQuery("SELECT COUNT(*) FROM customers");
                    int totalCount = 0; if(rsTotal.next()) totalCount = rsTotal.getInt(1);

                    ResultSet rsOverdue = stmt.executeQuery("SELECT COUNT(*) FROM customers WHERE overdue_amount > 0");
                    int overdueCount = 0; if(rsOverdue.next()) overdueCount = rsOverdue.getInt(1);
                %>
                <p>総顧客数: <%= String.format("%,d", totalCount) %> 名 | 滞納顧客数: <%= String.format("%,d", overdueCount) %> 名</p>
                <button onclick="location.href='overdue_list.jsp'" style="background: #3498db; color: white; border: none; padding: 10px 20px; border-radius: 5px; cursor: pointer;">滞納内訳を詳しく見る</button>
            </div>
        </div>
    </div>
</body>
</html>
<%
    } catch (Exception e) {
        out.println("エラーが発生しました: " + e.getMessage());
    } finally {
        if(conn != null) conn.close();
    }
%>