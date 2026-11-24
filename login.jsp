<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <title>管理者ログイン - SMART WATER JP</title>
    <style>
        /* 日本語表示に最適化されたフォント設定 */
        body { 
            font-family: "Meiryo", "Hiragino Kaku Gothic ProN", sans-serif; 
            background: #2c3e50; 
            display: flex; 
            justify-content: center; 
            align-items: center; 
            height: 100vh; 
            margin: 0; 
        }
        .login-card { 
            background: white; 
            padding: 40px; 
            border-radius: 12px; 
            box-shadow: 0 10px 25px rgba(0,0,0,0.3); 
            width: 350px; 
            text-align: center; 
        }
        .login-card h2 { color: #2c3e50; margin-bottom: 30px; font-size: 22px; }
        .input-group { margin-bottom: 20px; text-align: left; }
        .input-group label { display: block; font-size: 13px; color: #7f8c8d; margin-bottom: 5px; font-weight: bold; }
        .input-group input { width: 100%; padding: 12px; border: 1px solid #ddd; border-radius: 5px; box-sizing: border-box; }
        .btn-login { 
            width: 100%; 
            padding: 15px; 
            background: #3498db; 
            color: white; 
            border: none; 
            border-radius: 5px; 
            font-weight: bold; 
            cursor: pointer; 
            transition: 0.3s; 
            font-size: 16px;
        }
        .btn-login:hover { background: #2980b9; }
        .error-msg { color: #e74c3c; font-size: 12px; margin-bottom: 15px; background: #fdf2f2; padding: 10px; border-radius: 5px; }
    </style>
</head>
<body>
    <div class="login-card">
        <h2>💧 SMART WATER JP</h2>
        <form action="login_process.jsp" method="post">
            <div class="input-group">
                <label>社員番号 (ID)</label>
                <input type="text" name="emp_id" placeholder="社員番号を入力してください" required>
            </div>
            <div class="input-group">
                <label>パスワード</label>
                <input type="password" name="password" placeholder="パスワードを入力してください" required>
            </div>
            
            <%-- ログイン失敗時のエラーメッセージ --%>
            <% if(request.getParameter("error") != null) { %>
                <div class="error-msg">
                    社員番号またはパスワードが<br>正しくありません。
                </div>
            <% } %>
            
            <button type="submit" class="btn-login">ログイン</button>
        </form>
    </div>
</body>
</html>