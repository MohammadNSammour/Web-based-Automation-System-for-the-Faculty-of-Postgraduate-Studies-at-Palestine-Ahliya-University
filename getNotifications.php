<?php
// ════════════════════════════════════════════════════════
// api/getNotifications.php — جلب إشعارات المستخدم الحالي
// يُرجع: JSON { success, notifications[], unread_count }
// يُستدعى من dashboard.php بـ AJAX عند تحميل الصفحة
// ════════════════════════════════════════════════════════
session_start();
require_once 'db.php';
header('Content-Type: application/json');

checkSessionTimeout();

if (!isset($_SESSION['user_id'])) {
    echo json_encode(['success' => false, 'message' => 'غير مصرح']);
    exit;
}

$userId = $_SESSION['user_id'];

// ── جلب الإشعارات المرسلة لهذا المستخدم ──
//الاشعارات التي ارسلها المستخدم
//s64
$stmt = $conn->prepare("
    SELECT n.NotificationID, n.Message, n.Type, n.CreatedAt,
           nt.IsRead,
           CONCAT(u.FirstName,' ',u.LastName) AS SenderName
    FROM NotificationTo nt
    JOIN Notifications n ON n.NotificationID = nt.NotificationID
    LEFT JOIN Users u    ON u.UserID          = n.SenderID
    WHERE nt.UserID = ?
    ORDER BY n.CreatedAt DESC
    LIMIT 30
");
$stmt->bind_param("i", $userId);
$stmt->execute();
$rows = $stmt->get_result()->fetch_all(MYSQLI_ASSOC);

// ── عدد غير المقروءة ──
//s65
$stmt2 = $conn->prepare("
    SELECT COUNT(*) AS cnt
    FROM NotificationTo
    WHERE UserID = ? AND IsRead = 0
");
$stmt2->bind_param("i", $userId);
$stmt2->execute();
$unread = $stmt2->get_result()->fetch_assoc()['cnt'] ?? 0;

// ── تنسيق الوقت بشكل مقروء ──
foreach ($rows as &$r) {
    $ts = strtotime($r['CreatedAt']);
    $diff = time() - $ts;
    if ($diff < 60)    
        $r['TimeAgo'] = 'منذ لحظات';
    elseif ($diff < 3600)    
        $r['TimeAgo'] = 'منذ ' . floor($diff/60) . ' دقيقة';
    elseif ($diff < 86400)   
        $r['TimeAgo'] = 'منذ ' . floor($diff/3600) . ' ساعة';
    elseif ($diff < 604800)  
        $r['TimeAgo'] = 'منذ ' . floor($diff/86400) . ' يوم';
    else                     
        $r['TimeAgo'] = date('Y-m-d', $ts);
}
unset($r);

echo json_encode([
    'success'       => true,
    'notifications' => $rows,
    'unread_count'  => (int)$unread,
]);
