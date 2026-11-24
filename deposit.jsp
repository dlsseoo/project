<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>입금 테스트 페이지</title>
    <style>
        body { font-family: sans-serif; padding: 20px; }
        .container { border: 1px solid #ccc; padding: 20px; border-radius: 10px; width: 300px; }
        input { margin-bottom: 10px; width: 100%; padding: 5px; }
        button { width: 100%; padding: 10px; background-color: #007bff; color: white; border: none; cursor: pointer; }
    </style>
</head>
<body>

<div class="container">
    <h2>💰 입금 서비스</h2>
    <form method="post">
        <label for="amount">입금 금액:</label>
        <input type="number" id="amount" name="amount" placeholder="금액을 입력하세요" required>
        <button type="submit">입금하기</button>
    </form>

    <hr>

    <% 
        // POST 방식으로 데이터가 전송되었을 때 처리
        String amountStr = request.getParameter("amount");
        if (amountStr != null && !amountStr.isEmpty()) {
            try {
                int amount = Integer.parseInt(amountStr);
    %>
                <div style="color: blue; font-weight: bold;">
                    ✅ 결과: <%= amount %>원이 정상적으로 입금되었습니다!
                </div>
    <% 
            } catch (NumberFormatException e) {
    %>
                <div style="color: red;">숫자만 입력 가능합니다.</div>
    <% 
            }
        } 
    %>
</div>

</body>
</html>