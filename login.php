<?php
// ════════════════════════════════════════════════════════
// login.php  —  صفحة تسجيل الدخول
// الواجهة: HTML بالأسفل
// Backend: يستقبل POST ويرد JSON (يُستدعى من login.js بـ AJAX)
// ════════════════════════════════════════════════════════
// صفحة تسجيل الدخول الفعلية
session_start();
require_once 'db.php';

// ── Endpoint تحديث الكابشر ──
if (isset($_GET['get_captcha'])) {
    header('Content-Type: application/json');
    $_SESSION['captcha_result'] = rand(1000, 9999);
    echo json_encode(['captcha' => $_SESSION['captcha_result']]);
    exit;
}

// ── توليد كابشر أول مرة ──
if (!isset($_SESSION['captcha_result'])) {
    $_SESSION['captcha_result'] = rand(1000, 9999);
}

if (isset($_SESSION['user_id'])) {
    checkSessionTimeout();
}

// إذا كان المستخدم مسجلاً أرسله مباشرة للداشبورد
if (isset($_SESSION['user_id'])) {
    header('Location: dashboard.php');
    exit;
}

// ── معالجة طلب POST (AJAX من login.js) ──
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    header('Content-Type: application/json');

    $username = trim($_POST['username'] ?? '');
    $password = trim($_POST['password'] ?? '');
    $captcha  = trim($_POST['captcha']  ?? '');

    if (!$username || !$password) {
        $_SESSION['captcha_result'] = rand(1000, 9999);
        echo json_encode([
            'success'  => false,
            'message'  => 'يرجى إدخال اسم المستخدم وكلمة المرور.',
            'captcha'  => $_SESSION['captcha_result']
        ]);
        exit;
    }

    if (!$captcha || $captcha != $_SESSION['captcha_result']) {
    // ما نغير الرقم، نخليه نفسه
    echo json_encode([
        'success' => false,
        'message' => 'رمز التحقق غير صحيح، أدخل الرقم الظاهر أمامك.',
    ]);
    exit;
    }

    //s76
    $stmt = $conn->prepare("SELECT * FROM Users WHERE UserName = ?");
    $stmt->bind_param("s", $username);
    $stmt->execute();
    $user = $stmt->get_result()->fetch_assoc();

    if (!$user) {
        $_SESSION['captcha_result'] = rand(1000, 9999);
        echo json_encode([
            'success' => false,
            'message' => 'المستخدم غير موجود.',
            'captcha' => $_SESSION['captcha_result']
        ]);
        exit;
    }

    // Temporary plain text check (remove hash)
    if ($password !== $user['Password']) {
        $_SESSION['captcha_result'] = rand(1000, 9999);
        echo json_encode([
            'success' => false,
            'message' => 'اسم المستخدم أو كلمة المرور غير صحيحة.',
            'captcha' => $_SESSION['captcha_result']
        ]);
        exit;
    }

    // Success
    $_SESSION['user_id']       = $user['UserID'];
    $_SESSION['user_name']     = $user['FirstName'].' '.$user['LastName'];
    $_SESSION['user_type']     = $user['UserType'];
    $_SESSION['last_activity'] = time(); 

    if ($user['UserType'] === 'Employee') {
        //s77
        $stmt2 = $conn->prepare("
            SELECT er.Role FROM Employee_Roles er
            JOIN Employees e ON e.EmployeeNumber = er.EmployeeNumber
            WHERE e.UserID = ?
        ");
        $stmt2->bind_param("i", $user['UserID']);
        $stmt2->execute();
        $roles = [];
        $res   = $stmt2->get_result();
        while ($row = $res->fetch_assoc())
            $roles[] = $row['Role'];
        $_SESSION['roles']        = $roles;
        $_SESSION['current_role'] = $roles[0] ?? 'Employee';
    } else {
        $_SESSION['roles']        = ['Student'];
        $_SESSION['current_role'] = 'Student';
    }

    echo json_encode(['success'=>true]);
    exit;
}
?>
<!------------------------------------------------------------------------------------------------------------------------------------------------------------------>
<!------------------------------------------------------------------------------------------------------------------------------------------------------------------>
<!------------------------------------------------------------------------------------------------------------------------------------------------------------------>

<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
    <meta charset="UTF-8">
    <title>تسجيل الدخول — كلية الدراسات العليا</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Cairo:wght@400;600;700;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="style.css">
</head>
<body class="login-page">

<!-- ── الرأس الأخضر ── -->
<header class="login-header">
    <h1>جامعة فلسطين الأهلية <span class="en">| Palestine Ahliya University</span></h1>
    <h2>كلية الدراسات العليا <span class="en">| Faculty of Graduate Studies</span></h2>
</header>

<!-- ── المنتصف ── -->
<main class="login-main">

    <div class="login-logo-box">
        <?php if (file_exists('Logo.png')): ?>
            <img src="Logo.png" alt="شعار الجامعة">
        <?php else: ?>
            شعار الجامعة
        <?php endif; ?>
    </div>

    <div class="login-card">
        <div class="login-card-title">تسجيل الدخول</div>

        <div class="login-err" id="loginErr"></div>

        <div class="fg">
            <input type="text" id="username" placeholder="اسم المستخدم">
        </div>

        <div style="position:relative; display:flex; align-items:center;">
            <input type="password" id="password" placeholder="كلمة المرور" style="width:100%;">
            <span
                onmouseover="showPassword()"
                onmouseout="hidePassword()"
                style="position:absolute; left:10px; cursor:pointer; user-select:none; font-size:18px;">
                👁
            </span>
        </div>

        <!-- CAPTCHA -->
        <div class="fg" style="margin-top:10px; display:flex; gap:10px; align-items:center;">
            <div id="captchaDisplay" style="background:#f5f5f5;padding:10px 15px;border-radius:6px;font-weight:bold;letter-spacing:3px;border:1px solid #ddd;
                min-width:90px;text-align:center;font-size:18px;cursor:pointer;" onclick="refreshCaptcha()" title="انقر لتحديث الرمز">
                <?= $_SESSION['captcha_result'] ?>
            </div>
            <input type="text" id="captcha" placeholder="أدخل رمز التحقق" style="flex:1; min-width:0; width:100%;">
        </div>
        <small style="color:#888; font-size:11px; display:block; margin-top:3px;">
            يمكنك النقر على الرمز لتحديثه
        </small>

        <button class="btn btn-g login-submit" id="loginBtn"
                style="margin-top:12px;" onclick="doLogin()">
            الدخول
        </button>

        <div class="login-remember" style="margin-top:8px;">
            <label>
                <input type="checkbox" id="rememberMe"> تذكّرني في المرة القادمة
            </label>
        </div>

        <button class="btn btn-g login-forgot">نسيت كلمة المرور؟</button>
    </div>

</main>

<!-- ── التذييل ── -->
<footer class="login-footer">
    <span>الوقت:</span> <strong class="clock-time"></strong>
    <span style="margin:0 20px;">جميع الحقوق محفوظة <?= date('Y') ?></span>
    <span>التاريخ:</span> <strong class="clock-date"></strong>
</footer>

<div id="sys-msg"></div>
<script src="app.js"></script>  
<script src="login.js"></script>  
</body>
</html>
