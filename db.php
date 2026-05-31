<?php
// ════════════════════════════════════════════════════════
// db.php  —  الاتصال بقاعدة البيانات
// يُضمَّن في كل ملف PHP بـ: require_once 'db.php';
// أو من داخل مجلد api:  require_once '../db.php';
// ════════════════════════════════════════════════════════
//$host = 'localhost';
$host = 'localhost:3308';
$db   = 'MPA2';
$user = 'root';
$pass = '';

$conn = new mysqli($host, $user, $pass, $db);
$conn->set_charset('utf8mb4');

if ($conn->connect_error) {
    die("خطأ في الاتصال: " . $conn->connect_error);
}

function checkSessionTimeout() {
    $timeout = 3600; 
    
    if (isset($_SESSION['last_activity'])) {
        $elapsed = time() - $_SESSION['last_activity'];
        
        if ($elapsed > $timeout) {
            session_destroy();
            header('Location: login.php?timeout=1');
            exit;
        }
    }
    
    $_SESSION['last_activity'] = time();
}
