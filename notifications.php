<?php
// ════════════════════════════════════════════════════════
// notifications.php — صفحة إرسال الإشعارات
// متاحة للموظفين فقط (Admin, Supervisor, ProgramCoordinator...)
// ════════════════════════════════════════════════════════
// صفحة الاشعارات
session_start();
require_once 'db.php';

checkSessionTimeout();

if (!isset($_SESSION['user_id'])) { header('Location: login.php'); exit; }

$userId      = $_SESSION['user_id'];
$userName    = $_SESSION['user_name'];
$currentRole = $_SESSION['current_role'];
$roles       = $_SESSION['roles'] ?? [];

// الطلاب لا يدخلون هذه الصفحة
$allowedRoles = ['Admin','Supervisor','ProgramCoordinator','HeadOfSection','DeanOfFaculty','DeanOfGradStudies'];
if (!in_array($currentRole, $allowedRoles)) {
    header('Location: dashboard.php');
    exit;
}

$roleLabels = [
    'Student'            => 'طالب',
    'Admin'              => 'مشرف النظام',
    'Examiner'           => 'ممتحن',
    'Supervisor'         => 'مشرف',
    'ProgramCoordinator' => 'منسق البرنامج',
    'HeadOfSection'      => 'رئيس القسم',
    'DeanOfFaculty'      => 'عميد الكلية',
    'DeanOfGradStudies'  => 'عميد الدراسات العليا',
];
$roleLabel = $roleLabels[$currentRole] ?? $currentRole;

// جلب جميع المستخدمين للاختيار منهم
$users = [];
$stmt = $conn->prepare("
    SELECT UserID, FirstName, LastName, UserType,
           CONCAT(FirstName,' ',LastName) AS FullName
    FROM Users
    WHERE UserID != ?
    ORDER BY UserType, FirstName
");
$stmt->bind_param("i", $userId);
$stmt->execute();
$users = $stmt->get_result()->fetch_all(MYSQLI_ASSOC);

// جلب أدوار الموظفين لعرضها
$empRoles = [];
// نستخدم GROUP_CONCAT لجمع الأدوار المتعددة لكل موظف في صف واحد
$stmt2 = $conn->query("
    SELECT e.UserID, GROUP_CONCAT(er.Role SEPARATOR ',') AS Roles
    FROM Employees e
    JOIN Employee_Roles er ON er.EmployeeNumber = e.EmployeeNumber
    GROUP BY e.UserID
");
while ($r = $stmt2->fetch_assoc()) {
    $empRoles[$r['UserID']] = $r['Roles'];
}

// جلب آخر 20 إشعار أرسلها هذا المستخدم
$sentNotifs = [];
$stmt3 = $conn->prepare("
    SELECT n.NotificationID, n.Message, n.Type, n.CreatedAt,
           COUNT(nt.UserID) AS RecipientCount
    FROM Notifications n
    LEFT JOIN NotificationTo nt ON nt.NotificationID = n.NotificationID
    WHERE n.SenderID = ?
    GROUP BY n.NotificationID
    ORDER BY n.CreatedAt DESC
    LIMIT 20
");
$stmt3->bind_param("i", $userId);
$stmt3->execute();
$sentNotifs = $stmt3->get_result()->fetch_all(MYSQLI_ASSOC);

$typeLabels = [
    'General'       => ['label'=>'عام',      'cls'=>'b-prog'],
    'FormSubmitted' => ['label'=>'إرسال نموذج', 'cls'=>'b-ok'],
    'FormApproved'  => ['label'=>'موافقة',   'cls'=>'b-ok'],
    'FormRejected'  => ['label'=>'رفض',      'cls'=>'b-rej'],
    'FormReturned'  => ['label'=>'إرجاع',    'cls'=>'b-ret'],
];
?>
<!------------------------------------------------------------------------------------------------------------------------------------------------------------------>
<!------------------------------------------------------------------------------------------------------------------------------------------------------------------>
<!------------------------------------------------------------------------------------------------------------------------------------------------------------------>

<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
    <meta charset="UTF-8">
    <title>إرسال الإشعارات — كلية الدراسات العليا</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Cairo:wght@400;600;700;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="style.css">
    <link rel="stylesheet" href="notifications.css">
</head>
<body>

<!-- ══════════════════════════════════════
     الشريط الجانبي — fixed
     ══════════════════════════════════════ -->
<aside class="sidebar">

    <div class="logo-box">
        <?php if (file_exists('Logo.png')): ?>
            <img src="Logo.png" alt="شعار الجامعة">
        <?php else: ?>شعار الجامعة<?php endif; ?>
    </div>

    <div class="user-greet">مرحباً،</div>
    <div class="user-name"><?= htmlspecialchars($userName) ?></div>
    <div class="user-greet">أنت مسجل كـ</div>
    <div class="role-badge">
        <span><?= htmlspecialchars($roleLabel) ?></span>
        <span><?= $userId ?></span>
    </div>

    <hr class="sep">
    <div class="sec-title">الإجراءات</div>
    <a href="dashboard.php" class="side-btn">الرئيسية</a>
    <a href="notifications.php" class="side-btn active">إرسال إشعار</a>

    <hr class="sep">
    <a href="logout.php" class="btn-logout">تسجيل الخروج</a>

</aside>

<!-- ══════════════════════════════════════
     المحتوى الرئيسي
     ══════════════════════════════════════ -->
<div class="main-wrap">

    <!-- عنوان الصفحة -->
    <div class="page-title">
        <h2>إرسال الإشعارات</h2>
        <p>أرسل إشعاراً لمستخدم واحد أو مجموعة مستخدمين</p>
    </div>

    <div class="notif-layout">

        <!-- ════ عمود: نموذج الإرسال ════ -->
        <div class="notif-send-col">

            <div class="card">
                <div class="card-head">إنشاء إشعار جديد</div>
                <div class="card-body">

                    <!-- رسالة النتيجة -->
                    <div id="sendResult" class="send-result" style="display:none;"></div>

                    <!-- نص الإشعار -->
                    <div class="fg col-12" style="margin-bottom:12px;">
                        <label>نص الإشعار <span class="req">*</span></label>
                        <textarea id="notifMsg" rows="3"
                            placeholder="اكتب نص الإشعار هنا..."></textarea>
                        <span class="ferr" id="errMsg"></span>
                    </div>

                    <!-- نوع الإشعار -->
                    <div class="fg col-12" style="margin-bottom:12px;">
                        <label>نوع الإشعار</label>
                        <select id="notifType">
                            <option value="General">عام</option>
                            <option value="FormSubmitted">إرسال نموذج</option>
                            <option value="FormApproved">موافقة</option>
                            <option value="FormRejected">رفض</option>
                            <option value="FormReturned">إرجاع للتعديل</option>
                        </select>
                    </div>

                    <!-- البحث عن مستخدم -->
                    <div class="fg col-12" style="margin-bottom:8px;">
                        <label>البحث عن مستخدم</label>
                        <input type="text" id="userSearch"
                               placeholder="ابحث بالاسم أو الدور..."
                               oninput="filterUsers()">
                    </div>

                    <!-- خيارات التحديد السريع -->
                    <div class="quick-select">
                        <button type="button" class="btn btn-sm btn-gy"
                                onclick="selectByType('Student')">كل الطلاب</button>
                        <button type="button" class="btn btn-sm btn-gy"
                                onclick="selectByType('Employee')">كل الموظفين</button>
                        <button type="button" class="btn btn-sm btn-gy"
                                onclick="selectAll()">الكل</button>
                        <button type="button" class="btn btn-sm btn-gy"
                                onclick="clearAll()">إلغاء الكل</button>
                    </div>

                    <!-- قائمة المستخدمين -->
                    <div class="user-list" id="userList">
                        <?php foreach ($users as $u):
                            $role = $u['UserType'] === 'Student' ? 'طالب' :
                                    implode(' + ', array_map(function($r) use ($roleLabels) {
                                        return $roleLabels[$r] ?? $r;
                                    }, explode(',', $empRoles[$u['UserID']] ?? 'موظف')));
                        ?>

                        <label class="user-item" data-type="<?= $u['UserType'] ?>"
                               data-name="<?= htmlspecialchars(mb_strtolower($u['FullName'])) ?>"
                               data-role="<?= htmlspecialchars(mb_strtolower($role)) ?>">
                            <input type="checkbox"
                                   name="recipients[]"
                                   value="<?= $u['UserID'] ?>"
                                   class="recipient-cb">
                            <span class="user-item-info">
                                <span class="user-item-name"><?= htmlspecialchars($u['FullName']) ?></span>
                                <span class="user-item-role <?= $u['UserType'] === 'Student' ? 'role-student' : 'role-emp' ?>">
                                    <?= htmlspecialchars($role) ?>
                                </span>
                            </span>
                        </label>
                        <?php endforeach; ?>
                    </div>

                    <!-- عدد المحددين -->
                    <div class="selected-count">
                        المحددون: <strong id="selectedCount">0</strong> مستخدم
                    </div>

                    <!-- زر الإرسال -->
                    <button type="button" class="btn btn-g"
                            id="sendBtn"
                            style="width:100%;padding:10px;font-size:14px;margin-top:10px;"
                            onclick="sendNotification()">
                        إرسال الإشعار
                    </button>

                </div>
            </div>

        </div><!-- .notif-send-col -->

        <!-- ════ عمود: الإشعارات المُرسَلة ════ -->
        <div class="notif-sent-col">

            <div class="card">
                <div class="card-head">الإشعارات المُرسَلة مؤخراً</div>
                <div class="card-body" style="padding:0;" id="sentList">

                    <?php if (empty($sentNotifs)): ?>
                    <div style="text-align:center;padding:20px;color:#888;font-size:13px;">
                        لم ترسل أي إشعارات بعد
                    </div>
                    <?php else: ?>
                    <?php foreach ($sentNotifs as $n):
                        $tl = $typeLabels[$n['Type']] ?? ['label'=>$n['Type'],'cls'=>'b-prog'];
                    ?>
                    <div class="sent-item">
                        <div class="sent-item-top">
                            <span class="badge <?= $tl['cls'] ?>"><?= $tl['label'] ?></span>
                            <span class="sent-item-time">
                                <?= date('Y-m-d H:i', strtotime($n['CreatedAt'])) ?>
                            </span>
                        </div>
                        <div class="sent-item-msg"><?= htmlspecialchars($n['Message']) ?></div>
                        <div class="sent-item-recipients">
                            أُرسل إلى <?= $n['RecipientCount'] ?> مستخدم
                        </div>
                    </div>
                    <?php endforeach; ?>
                    <?php endif; ?>

                </div>
            </div>

        </div><!-- .notif-sent-col -->

    </div><!-- .notif-layout -->

</div><!-- .main-wrap -->

<!-- ══ التذييل ══ -->
<footer class="page-footer">
    <span>جميع الحقوق محفوظة <?= date('Y') ?></span>
    <div>
        الوقت: <strong><span class="clock-time"></span></strong>
        &nbsp;&nbsp;
        التاريخ: <strong><span class="clock-date"></span></strong>
    </div>
</footer>

<div id="sys-msg"></div>
<script src="app.js"></script>
<script src="notifications.js"></script>
</body>
</html>
