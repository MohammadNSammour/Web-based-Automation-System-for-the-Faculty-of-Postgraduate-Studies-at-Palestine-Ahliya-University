<?php
// ════════════════════════════════════════════════════════
// api/sendNotification.php — إرسال إشعار لمستخدمين محددين
// يستقبل: message, type, recipients (JSON array of UserIDs)
// يُرجع:  JSON { success, count, message }
// ════════════════════════════════════════════════════════
session_start();
require_once 'db.php';
header('Content-Type: application/json');

checkSessionTimeout();

//////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////
// حماية: يجب أن يكون مسجلاً
if (!isset($_SESSION['user_id'])) {
    echo json_encode(['success' => false, 'message' => 'غير مصرح']);
    exit;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////
// الطلاب لا يرسلون إشعارات
$allowedRoles = ['Admin','Supervisor','ProgramCoordinator','HeadOfSection','DeanOfFaculty','DeanOfGradStudies'];
if (!in_array($_SESSION['current_role'], $allowedRoles)) {
    echo json_encode(['success' => false, 'message' => 'غير مصرح لهذا الدور']);
    exit;
}

$senderId   = $_SESSION['user_id'];
$message    = trim($_POST['message']    ?? '');
$type       = trim($_POST['type']       ?? 'General');
$recipients = json_decode($_POST['recipients'] ?? '[]', true);
//////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////
// التحقق من البيانات
if (!$message) {
    echo json_encode(['success' => false, 'message' => 'نص الإشعار مطلوب']);
    exit;
}

if (empty($recipients) || !is_array($recipients)) {
    echo json_encode(['success' => false, 'message' => 'يجب تحديد مستخدم واحد على الأقل']);
    exit;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////
// التحقق من صحة النوع
$allowedTypes = ['General','FormSubmitted','FormApproved','FormRejected','FormReturned'];
if (!in_array($type, $allowedTypes)) {
    $type = 'General';
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////
// ── 1. إدراج الإشعار في جدول Notifications ──
$stmt = $conn->prepare("
    INSERT INTO Notifications (SenderID, Message, Type, CreatedAt)
    VALUES (?, ?, ?, NOW())
");
$stmt->bind_param("iss", $senderId, $message, $type);
$stmt->execute();
$notifId = $stmt->insert_id;

if (!$notifId) {
    echo json_encode(['success' => false, 'message' => 'فشل حفظ الإشعار']);
    exit;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////
// ── 2. إدراج المستقبلين في NotificationTo ──
// نستخدم INSERT IGNORE لتجنب التكرار في حال تم إرسال نفس الإشعار لنفس المستخدم أكثر من مرة
//يحدث ذلك عندما يختار المرسل مجموعة من المستخدمين تشمل نفس المستخدم أكثر من مرة، أو عند إعادة إرسال نفس الإشعار لنفس المجموعة
//فـ صحيح ان الايدي الخاص بالإشعار نفسه يتكرر، لكن تركيبة الايدي الخاص بالإشعار مع الايدي الخاص بالمستخدم لا تتكرر، وبالتالي لا يحدث تكرار في جدول NotificationTo
$stmt2 = $conn->prepare("
    INSERT IGNORE INTO NotificationTo (NotificationID, UserID, IsRead)
    VALUES (?, ?, 0)
");

$count = 0;
foreach ($recipients as $uid) {
    $uid = (int)$uid;
    if ($uid <= 0) 
        continue;

    // التحقق من وجود المستخدم
    $chk = $conn->prepare("SELECT UserID FROM Users WHERE UserID = ?");
    $chk->bind_param("i", $uid);
    $chk->execute();
    if (!$chk->get_result()->fetch_assoc()) continue;

    $stmt2->bind_param("ii", $notifId, $uid);
    $stmt2->execute();
    $count++;
}

if ($count === 0) {
    // لم يُضَف أحد — احذف الإشعار
    $del = $conn->prepare("DELETE FROM Notifications WHERE NotificationID = ?");
    $del->bind_param("i", $notifId);
    $del->execute();
    echo json_encode(['success' => false, 'message' => 'لم يُعثر على المستخدمين المحددين']);
    exit;
}

echo json_encode([
    'success' => true,
    'message' => 'تم الإرسال بنجاح',
    'count'   => $count,
    'notif_id'=> $notifId,
]);
