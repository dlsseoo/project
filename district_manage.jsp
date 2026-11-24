<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
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
        
        // [2. DBから実際の管理者名を取得]
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
    <title>管轄区域管理 - 水道管理システム</title>
    <style>
        * { box-sizing: border-box; }
        body { font-family: "Meiryo", "Hiragino Kaku Gothic ProN", sans-serif; margin: 0; background-color: #f8f9fa; color: #333; }
        .navbar { background-color: #2c3e50; color: white; height: 60px; display: flex; align-items: center; padding: 0 30px; position: sticky; top: 0; z-index: 1000; }
        .navbar-brand { font-size: 18px; font-weight: bold; color: #3498db; text-decoration: none; margin-right: 40px; }
        .nav-links { list-style: none; display: flex; gap: 25px; margin: 0; padding: 0; }
        .nav-links li a { color: #bdc3c7; text-decoration: none; font-size: 15px; font-weight: 500; }
        .nav-links li a.active { color: white; border-bottom: 3px solid #3498db; padding-bottom: 5px; }
        
        .admin-mini-bar { background: #fff; padding: 8px 30px; border-bottom: 1px solid #ddd; display: flex; justify-content: flex-end; font-size: 12px; color: #666; }
        .btn-logout { color: #e74c3c; text-decoration: none; margin-left: 15px; font-weight: bold; }

        .main-container { max-width: 1200px; margin: 30px auto; padding: 0 20px; }
        .content-card { background: white; border-radius: 12px; padding: 25px; box-shadow: 0 4px 12px rgba(0,0,0,0.05); }
        .section-title { font-size: 20px; font-weight: bold; color: #2c3e50; margin-bottom: 20px; border-left: 5px solid #3498db; padding-left: 10px; }
        
        .search-box { background: #f1f3f5; padding: 20px; border-radius: 8px; margin-bottom: 20px; display: flex; gap: 15px; align-items: flex-end; flex-wrap: wrap; }
        .search-group { display: flex; flex-direction: column; gap: 8px; }
        .search-group label { font-weight: bold; font-size: 13px; color: #495057; }
        
        select, input[type="text"], .btn-search { padding: 10px 15px; border-radius: 5px; border: 1px solid #ddd; font-size: 14px; height: 40px; }
        .btn-search { background: #3498db; color: white; cursor: pointer; font-weight: bold; border: none; transition: 0.2s; padding: 0 25px; }
        .btn-search:hover { background: #2980b9; }
        .btn-reset { text-decoration: none; font-size: 13px; color: #888; margin-left: 5px; line-height: 40px; }

        .table-wrapper { overflow-x: auto; width: 100%; }
        .data-table { width: 100%; border-collapse: collapse; min-width: 700px; }
        .data-table th { background: #f8f9fa; padding: 15px; text-align: center; border-bottom: 2px solid #eee; font-size: 14px; }
        .data-table td { padding: 15px; border-bottom: 1px solid #eee; text-align: center; font-size: 14px; }
        .status-dot { color: #2ecc71; margin-right: 5px; }
        code { background:#e9ecef; padding:3px 6px; border-radius:4px; font-family: 'Consolas', monospace; }

        @media (max-width: 768px) {
            .search-box { flex-direction: column; align-items: stretch; }
        }
    </style>
</head>
<body>
    <nav class="navbar">
        <a href="dbtest.jsp" class="navbar-brand">💧 SMART WATER JP</a>
        <ul class="nav-links">
            <li><a href="dbtest.jsp">ホーム</a></li>
            <li><a href="customer_list.jsp">顧客一覧</a></li>
            <li><a href="overdue_list.jsp">滞納者リスト</a></li>
            <li><a href="district_manage.jsp" class="active">管轄区域管理</a></li>
        </ul>
    </nav>

    <div class="admin-mini-bar">
        <span>ログイン管理者: <b><%= adminName %></b> 様 (社員番号: <%= sessionAdminId %>)</span>
        <a href="logout.jsp" class="btn-logout">ログアウト</a>
    </div>

    <div class="main-container">
        <div class="content-card">
            <div class="section-title">📍 区域・メーター別 詳細管理</div>
            
            <form class="search-box" method="get">
                <div class="search-group">
                    <label>管轄区域</label>
                    <select name="district">
                        <option value="">全ての区域</option>
                        <%-- 日本の地名の例に修正 --%>
                        <option value="渋谷区" <%= "渋谷区".equals(request.getParameter("district")) ? "selected" : "" %>>東京都 渋谷区</option>
                        <option value="新宿区" <%= "新宿区".equals(request.getParameter("district")) ? "selected" : "" %>>東京都 新宿区</option>
                        <option value="港区" <%= "港区".equals(request.getParameter("district")) ? "selected" : "" %>>東京都 港区</option>
                        <option value="中央区" <%= "中央区".equals(request.getParameter("district")) ? "selected" : "" %>>東京都 中央区</option>
                    </select>
                </div>

                <div class="search-group">
                    <label>メーター固有番号</label>
                    <select name="meter_id">
                        <option value="">全てのメーター</option>
                        <%
                            String sqlMeter = "SELECT DISTINCT meter_id FROM customers ORDER BY meter_id ASC";
                            Statement stmtMeter = conn.createStatement();
                            ResultSet rsMeter = stmtMeter.executeQuery(sqlMeter);
                            while(rsMeter.next()) {
                                String mId = rsMeter.getString("meter_id");
                                String selected = mId.equals(request.getParameter("meter_id")) ? "selected" : "";
                                out.println("<option value='" + mId + "' " + selected + ">" + mId + "</option>");
                            }
                        %>
                    </select>
                </div>

                <div class="search-group">
                    <label>顧客名 検索</label>
                    <input type="text" name="keyword" placeholder="お名前を入力" value="<%= request.getParameter("keyword") != null ? request.getParameter("keyword") : "" %>">
                </div>

                <button type="submit" class="btn-search">照会する</button>
                <a href="district_manage.jsp" class="btn-reset">リセット</a>
            </form>

            <div class="table-wrapper">
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>氏名</th>
                            <th>詳細住所</th>
                            <th>メーター固有番号</th>
                            <th>稼働状態</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            String district = request.getParameter("district");
                            String meter_id = request.getParameter("meter_id");
                            String keyword = request.getParameter("keyword");
                            
                            StringBuilder sql = new StringBuilder("SELECT * FROM customers WHERE 1=1");
                            
                            if(district != null && !district.isEmpty()) sql.append(" AND address LIKE ?");
                            if(meter_id != null && !meter_id.isEmpty()) sql.append(" AND meter_id = ?");
                            if(keyword != null && !keyword.isEmpty()) sql.append(" AND name LIKE ?");
                            
                            sql.append(" ORDER BY meter_id ASC, name ASC");
                            
                            PreparedStatement pstmt = conn.prepareStatement(sql.toString());
                            
                            int paramIndex = 1;
                            if(district != null && !district.isEmpty()) pstmt.setString(paramIndex++, "%" + district + "%");
                            if(meter_id != null && !meter_id.isEmpty()) pstmt.setString(paramIndex++, meter_id);
                            if(keyword != null && !keyword.isEmpty()) pstmt.setString(paramIndex++, "%" + keyword + "%");
                            
                            ResultSet rs = pstmt.executeQuery();
                            boolean hasData = false;
                            while(rs.next()) {
                                hasData = true;
                        %>
                        <tr>
                            <td><b><%= rs.getString("name") %> 様</b></td>
                            <td style="text-align: left;"><%= rs.getString("address") %></td>
                            <td><code><%= rs.getString("meter_id") %></code></td>
                            <td><span class="status-dot">●</span>正常稼働中</td>
                        </tr>
                        <% 
                                }
                                if(!hasData) {
                                    out.println("<tr><td colspan='4' style='padding:50px; color:#999;'>条件に一致するデータがありません。</td></tr>");
                                }
                        %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</body>
</html>
<%
    } catch (Exception e) {
        out.println("<div style='text-align:center; padding:20px; color:red;'>エラー発生: " + e.getMessage() + "</div>");
    } finally {
        if(conn != null) conn.close();
    }
%>