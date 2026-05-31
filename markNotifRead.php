<?php
// ════════════════════════════════════════════════════════
// api/markNotifRead.php — تعليم الإشعارات كمقروءة
// POST: notif_id (رقم إشعار واحد) أو all=1 (كل الإشعارات)
// ════════════════════════════════════════════════════════
session_start();
require_once 'db.php';
header('Content-Type: application/json');

checkSessionTimeout();

if (!isset($_SESSION['user_id'])) {
    echo json_encode(['success' => false]);
    exit;
}

$userId  = $_SESSION['user_id'];
$notifId = (int)($_POST['notif_id'] ?? 0);
$all     = ($_POST['all'] ?? '') === '1';

if ($all) {
    // تعليم كل إشعارات هذا المستخدم كمقروءة+
    //s77
    $stmt = $conn->prepare("UPDATE NotificationTo SET IsRead = 1 WHERE UserID = ?");
    $stmt->bind_param("i", $userId);
    $stmt->execute();
} else {
    // تعليم إشعار محدد
    //s78
    $stmt = $conn->prepare("
        UPDATE NotificationTo SET IsRead = 1
        WHERE NotificationID = ? AND UserID = ?
    ");
    $stmt->bind_param("ii", $notifId, $userId);
    $stmt->execute();
}

echo json_encode(['success' => true]);
