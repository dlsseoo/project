<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.DecimalFormat" %>
<%
    /**
     * [관리자용 고객 상세 정보 페이지]
     * 작성 목적: 특정 고객의 계량기 정보, 주소, 사용량, 납부 상태 상세 조회
     * 타겟 사용자: 일본 수도국 관리자
     */

    // 1. 세션 체크 (보안)
    String sessionAdminId = (String) session.getAttribute("adminId");
    if (sessionAdminId == null) {
        response.sendRedirect("login.jsp"); // 로그인 안 되어 있으면 튕김
        return;
    }

    // 2. 리스트 페이지에서 넘어온 meter_id 파라미터 수신
    String meterId = request.getParameter("meter_id");
    
    Connection conn = null;
    String adminName = "";
    DecimalFormat df = new DecimalFormat("¥###,###"); // 일본 엔화 콤마 형식

    try {
        Class.forName("org.postgresql.Driver");
        conn = DriverManager.getConnection("jdbc:postgresql://localhost:5432/mydb", "inseo", "");

        // 3. 접속 중인 관리자 정보 조회 (상단 바 표시용)
        String sqlAdmin = "SELECT name FROM admins WHERE emp_id = ?";
        PreparedStatement pstmtAdmin = conn.prepareStatement(sqlAdmin);
        pstmtAdmin.setString(1, sessionAdminId);
        ResultSet rsAdmin = pstmtAdmin.executeQuery();
        if(rsAdmin.next()) {
            adminName = rsAdmin.getString("name");
        }

        // 4. 해당 meter_id를 가진 고객의 모든 정보 조회
        String sqlCust = "SELECT * FROM customers WHERE meter_id = ?";
        PreparedStatement pstmtCust = conn.prepareStatement(sqlCust);
        pstmtCust.setString(1, meterId);
        ResultSet rs = pstmtCust.executeQuery();

        if (rs.next()) {
            // 조회 결과가 있을 때만 아래 HTML을 렌더링
%>
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= rs.getString("name") %> 様の検針詳細 - SMART WATER JP</title>
    <style>
        /* 기본 폰트: 일본어 환경에서 가장 가독성이 좋은 Meiryo 적용 */
        body { font-family: "Meiryo", "Hiragino Kaku Gothic ProN", sans-serif; margin: 0; background-color: #f4f7f6; color: #333; }
        
        /* 네비게이션 및 바 */
        .navbar { background-color: #2c3e50; color: white; height: 60px; display: flex; align-items: center; padding: 0 30px; }
        .navbar-brand { font-size: 18px; font-weight: bold; color: #3498db; text-decoration: none; }
        .admin-bar { background: #fff; padding: 10px 30px; border-bottom: 1px solid #ddd; text-align: right; font-size: 12px; color: #666; }
        
        /* 메인 컨테이너 */
        .main-container { max-width: 850px; margin: 40px auto; background: white; padding: 40px; border-radius: 12px; box-shadow: 0 4px 20px rgba(0,0,0,0.1); }
        .detail-header { border-bottom: 2px solid #3498db; padding-bottom: 15px; margin-bottom: 30px; display: flex; justify-content: space-between; align-items: flex-end; }
        .detail-header h2 { margin: 0; color: #2c3e50; font-size: 24px; }
        
        /* 정보 레이아웃 (그리드) */
        .info-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; }
        .info-item { padding: 18px; background: #fafafa; border: 1px solid #eee; border-radius: 8px; }
        .info-label { font-size: 13px; color: #7f8c8d; margin-bottom: 8px; font-weight: bold; }
        .info-value { font-size: 19px; font-weight: bold; color: #2c3e50; }
        
        /* 상태 배지 스타일 */
        .status-badge { padding: 6px 15px; border-radius: 50px; font-size: 13px; font-weight: bold; }
        .status-ok { background: #e8faf0; color: #2ecc71; border: 1px solid #2ecc71; }
        .status-warning { background: #fff5f5; color: #e74c3c; border: 1px solid #e74c3c; }
        
        /* 하단 버튼 */
        .btn-group { margin-top: 40px; display: flex; gap: 15px; }
        .btn-back { padding: 12px 25px; background: #95a5a6; color: white; text-decoration: none; border-radius: 6px; font-size: 14px; transition: 0.2s; }
        .btn-back:hover { background: #7f8c8d; }
        
        code { background: #e9ecef; padding: 2px 6px; border-radius: 4px; font-family: 'Consolas', monospace; color: #e83e8c; }
    </style>
</head>
<body>
    <nav class="navbar">
        <a href="dbtest.jsp" class="navbar-brand">💧 SMART WATER JP</a>
    </nav>
    <div class="admin-bar">
        ログイン中: <b><%= adminName %></b> 様 (社員番号: <%= sessionAdminId %>)
    </div>

    <div class="main-container">
        <div class="detail-header">
            <h2>顧客詳細情報</h2>
            <%-- 연체 금액 존재 여부에 따른 배지 분기 처리 --%>
            <span class="status-badge <%= rs.getInt("overdue_amount") > 0 ? "status-warning" : "status-ok" %>">
                <%= rs.getInt("overdue_amount") > 0 ? "⚠️ 滞納あり" : "✅ 正常稼働中" %>
            </span>
        </div>

        <div class="info-grid">
            <div class="info-item">
                <div class="info-label">氏名 (お名前)</div>
                <div class="info-value"><%= rs.getString("name") %> 様</div>
            </div>
            <div class="info-item">
                <div class="info-label">メーター固有番号</div>
                <div class="info-value"><code><%= rs.getString("meter_id") %></code></div>
            </div>
            <div class="info-item" style="grid-column: span 2;">
                <div class="info-label">設置住所</div>
                <div class="info-value"><%= rs.getString("address") %></div>
            </div>
            <div class="info-item">
                <div class="info-label">当月使用量</div>
                <div class="info-value"><%= String.format("%,d", rs.getInt("usage_amount")) %> m³</div>
            </div>
            <div class="info-item">
                <div class="info-label">未納金額 (税込)</div>
                <div class="info-value" style="color: <%= rs.getInt("overdue_amount") > 0 ? "#e74c3c" : "#2c3e50" %>">
                    <%= df.format(rs.getInt("overdue_amount")) %>
                </div>
            </div>
            
            <%-- 체납 개월 수가 0보다 클 때만 섹션 노출 --%>
            <% if(rs.getInt("overdue_months") > 0) { %>
            <div class="info-item" style="grid-column: span 2; border-left: 5px solid #e74c3c; background-color: #fff9f9;">
                <div class="info-label">滞납期間</div>
                <div class="info-value"><%= rs.getInt("overdue_months") %> ヶ月</div>
            </div>
            <% } %>
        </div>

        <div class="btn-group">
            <a href="customer_list.jsp" class="btn-back">← 顧客一覧に戻る</a>
        </div>
    </div>
</body>
</html>
<%
        } else {
            // DB에 데이터가 없는 경우 (잘못된 meter_id 접근)
            out.println("<script>alert('該当する顧客データが見つかりません。'); history.back();</script>");
        }
    } catch (Exception e) {
        // DB 연결 실패 등 예외 처리
        out.println("<div style='text-align:center; padding:50px; color:red;'>システムエラー: " + e.getMessage() + "</div>");
    } finally {
        if(conn != null) conn.close();
    }
%>