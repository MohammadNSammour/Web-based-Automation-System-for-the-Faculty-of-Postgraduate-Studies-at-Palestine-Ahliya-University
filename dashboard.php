<?php
// ════════════════════════════════════════════════════════
// dashboard.php — لوحة التحكم الرئيسية
//
// المنطق الأساسي:
//   لا يُفتح أي نموذج إلا عبر طلب (submission) جاء بالتسلسل
//   الطالب غير المسجل → يُوجَّه لنموذج 700 مباشرة (الحالة الوحيدة التي تبدأ تلقائياً)
//   بعدها كل شيء يأتي عبر الطلبات فقط
// ════════════════════════════════════════════════════════
// الصفحة التي تظهر فيها الداشبورد بشكل فعلي
session_start();
require_once 'db.php';

checkSessionTimeout();

if (!isset($_SESSION['user_id'])) { header('Location: login.php'); exit; }

$userId      = $_SESSION['user_id'];
$userName    = $_SESSION['user_name'];
$roles       = $_SESSION['roles'] ?? [];
$currentRole = $_SESSION['current_role'];

// تبديل الدور
if (isset($_GET['role']) && in_array($_GET['role'], $roles)) {
    $_SESSION['current_role'] = $_GET['role'];
    header('Location: dashboard.php'); exit;
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

// ══════════════════════════════════════════════════════════
// بيانات الطالب
// ══════════════════════════════════════════════════════════
$studentInfo = null;
if ($currentRole === 'Student') {
    //s38
    $stmt = $conn->prepare("
        SELECT s.*, u.FirstName, u.LastName,
               u.College, u.Department, u.Program,
               CONCAT(su.FirstName,' ',su.LastName) AS SupName
        FROM Students s
        JOIN Users u       ON u.UserID         = s.UserID
        LEFT JOIN Employees e  ON e.EmployeeNumber = s.SupervisorID
        LEFT JOIN Users su     ON su.UserID        = e.UserID
        WHERE s.UserID = ?
    ");
    $stmt->bind_param("i", $userId);
    $stmt->execute();
    $studentInfo = $stmt->get_result()->fetch_assoc();
}

// ══════════════════════════════════════════════════════════
// الطالب غير المسجل → الحالة الوحيدة التي تبدأ تلقائياً
// يُوجَّه لنموذج 700 مباشرة لأنه لا يوجد طلب سابق يُحيله
// ══════════════════════════════════════════════════════════
if ($currentRole === 'Student' && $studentInfo) {
    $isRegistered = !empty($studentInfo['UniversityID'])
                 || !empty($studentInfo['EnrollmentSemester'])
                 || !empty($studentInfo['EnrollmentYear']);

    // إذا لم تكن البيانات محدّثة، نتحقق أيضاً من وجود طلب Approved لنموذج 700
    // لأن نموذج 700 قد يكتمل دون تحديث UniversityID تلقائياً
    //يمكنك إزالة هذا الشرط إذا كنت تضمن أن UniversityID يتم تحديثه فور الموافقة على نموذج 700، لكن وجود هذا الشرط يجعل النظام أكثر مرونة في حال تأخر تحديث بيانات الطالب بعد الموافقة.
    if (!$isRegistered) {
        //s39
        $stmtApproved700 = $conn->prepare("
            SELECT SubmissionID FROM FormSubmissions fs
            JOIN FormTypes ft ON ft.FormTypeID = fs.FormTypeID
            WHERE ft.Code = '700'
              AND fs.StudentID = ?
              AND fs.Status = 'Approved'
            LIMIT 1
        ");
        $stmtApproved700->bind_param("i", $studentInfo['StudentNumber']);
        $stmtApproved700->execute();
        if ($stmtApproved700->get_result()->fetch_assoc()) {
            $isRegistered = true;
        }
    }

    if (!$isRegistered) {
        $stmtForm700 = $conn->prepare("SELECT FormTypeID FROM FormTypes WHERE Code='700' LIMIT 1");
        $stmtForm700->execute();
        $form700 = $stmtForm700->get_result()->fetch_assoc();

        if ($form700) {
            // هل يوجد طلب نشط لنموذج 700؟
            //s40
            $stmtActive = $conn->prepare("
                SELECT SubmissionID FROM FormSubmissions
                WHERE FormTypeID = ? AND StudentID = ?
                AND Status IN ('InProgress','Returned')
                ORDER BY CreatedAt DESC LIMIT 1
            ");
            $stmtActive->bind_param("ii", $form700['FormTypeID'], $studentInfo['StudentNumber']);
            $stmtActive->execute();
            $active700 = $stmtActive->get_result()->fetch_assoc();

            if ($active700) {
                header('Location: form.php?form_id=' . $form700['FormTypeID'] . '&submission_id=' . $active700['SubmissionID']);
            } else {
                header('Location: form.php?form_id=' . $form700['FormTypeID']);
            }
            exit;
        }
    }
}

// ══════════════════════════════════════════════════════════
// طلبات الطالب — فقط ما جاء عبر التسلسل (submission موجود)
// ══════════════════════════════════════════════════════════
$studentSubmissions = []; // قائمة الطلبات الفعلية للطالب

if ($currentRole === 'Student' && $studentInfo) {
    //s41
    $stmtSubs = $conn->prepare("
        SELECT fs.SubmissionID, fs.FormTypeID, fs.Status, fs.CreatedAt,
               ft.Code AS FormCode, ft.Name AS FormName,
               fws.AllowedRole AS CurrentStepRole, fws.StepName,
               fws.StepOrder AS CurrentStepOrder,
               (SELECT COUNT(*) FROM FormWorkflowSteps WHERE FormTypeID = fs.FormTypeID) AS TotalSteps
        FROM FormSubmissions fs
        JOIN FormTypes ft          ON ft.FormTypeID  = fs.FormTypeID
        JOIN FormWorkflowSteps fws ON fws.StepID      = fs.CurrentStepID
        WHERE fs.StudentID = ?
        ORDER BY ft.DisplayOrder ASC, fs.CreatedAt DESC
    ");
    $stmtSubs->bind_param("i", $studentInfo['StudentNumber']);
    $stmtSubs->execute();
    $studentSubmissions = $stmtSubs->get_result()->fetch_all(MYSQLI_ASSOC);
}

// ══════════════════════════════════════════════════════════
// طلبات الموظف — قسم 1: هو يبدأ النموذج (StepOrder=1 له)
//                        وجاءه إشعار بذلك عبر التسلسل
// ══════════════════════════════════════════════════════════
$submissionsToStart = []; // طلبات بدأت من النموذج السابق وحان دوره ليبدأها

if ($currentRole !== 'Student' && $currentRole !== 'Admin') {
    // هذه الطلبات موجودة في FormSubmissions وCurrentStepID يشير لخطوة StepOrder=1 ودوره
    //s42
    $stmtStart = $conn->prepare("
        SELECT fs.SubmissionID, fs.FormTypeID, fs.Status, fs.CreatedAt,
               ft.Code AS FormCode, ft.Name AS FormName,
               fws.StepName, fws.StepOrder,
               CONCAT(u.FirstName,' ',u.LastName) AS StudentName,
               s.UniversityID
        FROM FormSubmissions fs
        JOIN FormTypes ft          ON ft.FormTypeID   = fs.FormTypeID
        JOIN FormWorkflowSteps fws ON fws.StepID       = fs.CurrentStepID
        LEFT JOIN Students s       ON s.StudentNumber   = fs.StudentID
        LEFT JOIN Users u          ON u.UserID           = s.UserID
        WHERE fws.AllowedRole = ?
          AND fws.StepOrder   = 1
          AND fs.Status IN ('InProgress','Returned')
        ORDER BY fs.CreatedAt ASC
    ");
    $stmtStart->bind_param("s", $currentRole);
    $stmtStart->execute();
    $submissionsToStart = $stmtStart->get_result()->fetch_all(MYSQLI_ASSOC);
}

// ══════════════════════════════════════════════════════════
// طلبات الموظف — قسم 2: هو مرحلة في نموذج جارٍ (StepOrder > 1)
// ══════════════════════════════════════════════════════════
$submissionsInProgress = [];

if ($currentRole === 'Admin') {
    //s43
    // في حالة المشرف العام، نُظهر كل الطلبات الجارية دون تصفية حسب الدور في الخطوة الحالية
    //لان المشرف العام دوره في النظام هو مراجعة كل الطلبات في كل الخطوات، لذلك لا نُقيّد العرض حسب AllowedRole في FormWorkflowSteps
    $stmtProg = $conn->prepare("
        SELECT fs.SubmissionID, fs.FormTypeID, fs.Status, fs.CreatedAt,
               ft.Code AS FormCode, ft.Name AS FormName,
               fws.StepName, fws.StepOrder,
               CONCAT(u.FirstName,' ',u.LastName) AS StudentName,
               s.UniversityID
        FROM FormSubmissions fs
        JOIN FormTypes ft          ON ft.FormTypeID  = fs.FormTypeID
        JOIN FormWorkflowSteps fws ON fws.StepID      = fs.CurrentStepID
        LEFT JOIN Students s       ON s.StudentNumber  = fs.StudentID
        LEFT JOIN Users u          ON u.UserID          = s.UserID
        WHERE fs.Status IN ('InProgress','Returned')
        ORDER BY fs.CreatedAt ASC
    ");
    $stmtProg->execute();
} else {
    //s44
    // في حالة الأدوار الأخرى، نُظهر الطلبات التي يكون دور المستخدم فيها هو دور الخطوة الحالية (StepOrder > 1)
    $stmtProg = $conn->prepare("
        SELECT fs.SubmissionID, fs.FormTypeID, fs.Status, fs.CreatedAt,
               ft.Code AS FormCode, ft.Name AS FormName,
               fws.StepName, fws.StepOrder,
               CONCAT(u.FirstName,' ',u.LastName) AS StudentName,
               s.UniversityID
        FROM FormSubmissions fs
        JOIN FormTypes ft          ON ft.FormTypeID  = fs.FormTypeID
        JOIN FormWorkflowSteps fws ON fws.StepID      = fs.CurrentStepID
        LEFT JOIN Students s       ON s.StudentNumber  = fs.StudentID
        LEFT JOIN Users u          ON u.UserID          = s.UserID
        WHERE fws.AllowedRole = ?
          AND fws.StepOrder   > 1
          AND fs.Status IN ('InProgress','Returned')
        ORDER BY fs.CreatedAt ASC
    ");
    $stmtProg->bind_param("s", $currentRole);
    $stmtProg->execute();
}
$submissionsInProgress = $stmtProg->get_result()->fetch_all(MYSQLI_ASSOC);

// ══════════════════════════════════════════════════════════
// بيانات الرسالة للطالب
// ══════════════════════════════════════════════════════════
$thesisInfo = null;
if ($currentRole === 'Student' && $studentInfo) {
    //s45
    $stmtThesis = $conn->prepare("
        SELECT t.ThesisTitle,
               CONCAT(su.FirstName,' ',su.LastName) AS MainSupervisorName
        FROM Thesis t
        LEFT JOIN Employees e ON e.EmployeeNumber = t.MainSupervisorID
        LEFT JOIN Users su    ON su.UserID         = e.UserID
        WHERE t.StudentNumber = ?
        ORDER BY t.ThesisID DESC LIMIT 1
    ");
    $stmtThesis->bind_param("i", $studentInfo['StudentNumber']);
    $stmtThesis->execute();
    $thesisInfo = $stmtThesis->get_result()->fetch_assoc();
}
?>
<!------------------------------------------------------------------------------------------------------------------------------------------------------------------>
<!------------------------------------------------------------------------------------------------------------------------------------------------------------------>

<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
    <meta charset="UTF-8">
    <title>الرئيسية</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Cairo:wght@400;600;700;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="style.css">
    <style>
        /* بطاقات الطلبات */
        .sub-card-start    { border-right:4px solid #f4a261; background:#fff8f0; }
        .sub-card-progress { border-right:4px solid #1d5c36; background:#f0f7f3; }
        .sub-card-done     { border-right:4px solid #adb5bd; background:#f8f9fa; }
        .sub-card-returned { border-right:4px solid #e63946; background:#fff0f1; }

        .badge-start    { background:#f4a261; color:#fff; font-size:11px; padding:2px 9px; border-radius:8px; white-space:nowrap; }
        .badge-progress { background:#1d5c36; color:#fff; font-size:11px; padding:2px 9px; border-radius:8px; white-space:nowrap; }
        .badge-done     { background:#adb5bd; color:#fff; font-size:11px; padding:2px 9px; border-radius:8px; white-space:nowrap; }
        .badge-returned { background:#e63946; color:#fff; font-size:11px; padding:2px 9px; border-radius:8px; white-space:nowrap; }

        .subs-grid { display:grid; grid-template-columns:repeat(auto-fill,minmax(290px,1fr)); gap:14px; }
        .sub-card  { border-radius:8px; padding:14px 16px; display:flex; flex-direction:column; gap:8px; }
        .sub-title { font-weight:700; font-size:14px; color:#222; }
        .sub-meta  { font-size:12px; color:#666; line-height:1.7; }

        /* شريط التقدم */
        .step-bar { display:flex; align-items:center; gap:0; margin:6px 0 2px; }
        .step-dot { width:10px; height:10px; border-radius:50%; background:#dee2e6; flex-shrink:0; }
        .step-dot.done   { background:#1d5c36; }
        .step-dot.active { background:#f4a261; }
        .step-line { flex:1; height:2px; background:#dee2e6; }
        .step-line.done { background:#1d5c36; }

        .empty-state { text-align:center; padding:40px; color:#aaa; font-size:13px; }
    </style>
</head>
<body>

<!-- ══ الشريط الجانبي ══ -->
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
        <!--اظهار خيارات التبديل بين الادوار بحال كان هناك اكثر من دور للمستخدم الواحد-->
    <?php if (count($roles) > 1): ?>
    <div class="role-switch-box">
        <div class="role-switch-label">تبديل الدور:</div>
        <select class="role-switch-select"
                onchange="if(this.value) window.location.href='dashboard.php?role='+this.value;">
            <option value="">-- اختر دور --</option>
            <?php foreach ($roles as $r): ?>
            <option value="<?= htmlspecialchars($r) ?>"
                    <?= $r === $currentRole ? 'selected' : '' ?>>
                <?= htmlspecialchars($roleLabels[$r] ?? $r) ?>
            </option>
            <?php endforeach; ?>
        </select>
    </div>
    <?php endif; ?>

    <hr class="sep">
    <div class="sec-title">الإجراءات</div>
    <!-- <a href="thesis.php"        class="side-btn">ملفات الرسائل</a> -->
    <?php if (in_array($currentRole, ['Admin','Supervisor','ProgramCoordinator','HeadOfSection','DeanOfFaculty','DeanOfGradStudies'])): ?>
    <a href="notifications.php" class="side-btn">إرسال إشعار</a>
    <?php endif; ?>
    <?php if ($currentRole === 'Admin'): ?>
    <a href="users.php" class="side-btn">إدارة المستخدمين والنماذج</a>
    <?php endif; ?>
    <hr class="sep">
    <a href="logout.php" class="btn-logout">تسجيل الخروج</a>
</aside>

<!-- ══ المحتوى الرئيسي ══ -->
<div class="main-wrap">

<div class="page-title">
    <h2>لوحة التحكم — <?= htmlspecialchars($roleLabel) ?></h2>
</div>
<!-- عرض مختلف حسب الدور الحالي -->
<!--الطالب-->
<?php if ($currentRole === 'Student' && $studentInfo): ?>
<!-- ══════════════════════════════════════════════════
     داشبورد الطالب
     ══════════════════════════════════════════════════ -->

    <!-- معلومات الطالب -->
    <?php if (!empty($studentInfo['UniversityID'])): ?>
    <div style="background:var(--green-lt);border:1px solid var(--green);border-radius:6px;
                padding:10px 14px;margin-bottom:12px;font-size:13px;font-weight:700;color:var(--green);">
        مرحبا بك,رقمك الجامعي هو: <span style="font-size:16px;"><?= htmlspecialchars($studentInfo['UniversityID']) ?></span>
    </div>
    <?php endif; ?>

    <div class="card">
        <div class="card-head">معلوماتي</div>
        <div class="card-body">
            <div class="d-row">
                <span class="d-lbl">الاسم</span>
                <span class="d-val"><?= htmlspecialchars($studentInfo['FirstName'].' '.$studentInfo['LastName']) ?></span>
            </div>
            <div class="d-row">
                <span class="d-lbl">الرقم الجامعي</span>
                <span class="d-val"><?= htmlspecialchars($studentInfo['UniversityID'] ?? '—') ?></span>
            </div>
            <div class="d-row">
                <span class="d-lbl">البرنامج</span>
                <span class="d-val"><?= htmlspecialchars($studentInfo['Program'] ?? '—') ?></span>
            </div>
            <div class="d-row">
                <span class="d-lbl">القسم</span>
                <span class="d-val"><?= htmlspecialchars($studentInfo['Department'] ?? '—') ?></span>
            </div>
            <div class="d-row">
                <span class="d-lbl">المعدل التراكمي</span>
                <span class="d-val"><?= $studentInfo['GPA'] ?? '—' ?></span>
            </div>
            <div class="d-row">
                <span class="d-lbl">الساعات المجتازة</span>
                <span class="d-val"><?= $studentInfo['TotalCompletedHours'] ?? '0' ?></span>
            </div>
            <div class="d-row">
                <span class="d-lbl">المشرف</span>
                <span class="d-val">
                    <?= $studentInfo['SupName']
                        ? htmlspecialchars($studentInfo['SupName'])
                        : 'لم يُعيَّن بعد' ?>
                </span>
            </div>
        </div>
    </div>
    <!---- معلومات الرسالة للطالب عندما تكون لديه واحدة-->
    <?php if ($thesisInfo): ?>
    <!-- رسالة الطالب -->
    <div class="card">
        <div class="card-head">رسالتي</div>
        <div class="card-body">
            <div class="d-row">
                <span class="d-lbl">عنوان الرسالة</span>
                <span class="d-val"><?= htmlspecialchars($thesisInfo['ThesisTitle']) ?></span>
            </div>
            <?php if ($thesisInfo['MainSupervisorName']): ?>
            <div class="d-row">
                <span class="d-lbl">المشرف الرئيسي</span>
                <span class="d-val"><?= htmlspecialchars($thesisInfo['MainSupervisorName']) ?></span>
            </div>
            <?php endif; ?>
        </div>
    </div>
    <?php endif; ?>

    <!-- الإشعارات -->
    <div class="card">
        <div class="card-head" style="display:flex;justify-content:space-between;align-items:center;">
            <span>الإشعارات <span id="unreadBadge" style="display:none;background:#e63946;color:#fff;
                border-radius:9px;padding:1px 8px;font-size:11px;font-weight:700;margin-right:6px;"></span></span>
            <button class="btn btn-sm btn-gy" onclick="markAllRead()">تعليم الكل كمقروء</button>
        </div>
        <div class="card-body" style="padding:0;" id="notifList">
            <div class="empty-state">جاري تحميل الإشعارات...</div>
        </div>
    </div>

    <!-- طلبات الطالب — فقط ما جاء عبر التسلسل -->
    <div class="card">
        <div class="card-head">طلباتي</div>
        <div class="card-body">
        <?php if (empty($studentSubmissions)): ?>
            <div class="empty-state">لا توجد طلبات حالياً</div>
        <?php else: ?>
            <div class="subs-grid">
            <?php foreach ($studentSubmissions as $sub):
                // تحديد لون البطاقة
                if ($sub['Status'] === 'Approved') {
                    $cls = 'sub-card-done';
                    $badgeCls = 'badge-done';
                    $badgeTxt = 'مكتمل ';
                } elseif ($sub['Status'] === 'Returned') {
                    $cls = 'sub-card-returned';
                    $badgeCls = 'badge-returned';
                    $badgeTxt = 'مرجع للتعديل';
                } elseif ($sub['CurrentStepRole'] === 'Student') {
                    // دور الطالب في الخطوة الحالية = هو من يعبئ
                    $cls = 'sub-card-start';
                    $badgeCls = 'badge-start';
                    $badgeTxt = 'بانتظارك';
                } else {
                    // خطوة الطالب انتهت وهو ينتظر الموافقات
                    $cls = 'sub-card-progress';
                    $badgeCls = 'badge-progress';
                    $badgeTxt = 'قيد المراجعة';
                }

                // شريط تقدم مبسط
                $doneSteps = $sub['CurrentStepOrder'] - 1;
                $totalSteps = $sub['TotalSteps'];
            ?>
                <div class="sub-card <?= $cls ?>">
                    <div style="display:flex;justify-content:space-between;align-items:flex-start;gap:8px;">
                        <span class="sub-title">نموذج <?= htmlspecialchars($sub['FormCode']) ?></span>
                        <span class="<?= $badgeCls ?>"><?= $badgeTxt ?></span>
                    </div>

                    <div class="sub-meta">
                        <?= htmlspecialchars($sub['FormName']) ?><br>
                        <?php if ($sub['Status'] !== 'Approved'): ?>
                        الخطوة الحالية: <?= htmlspecialchars($sub['StepName']) ?>
                        (<?= $sub['CurrentStepOrder'] ?>/<?= $totalSteps ?>)
                        <?php endif; ?>
                    </div>

                    <!-- شريط التقدم -->
                    <div class="step-bar">
                    <?php for ($i = 1; $i <= $totalSteps; $i++):
                        $dotCls = $i < $sub['CurrentStepOrder'] ? 'done'
                                : ($i == $sub['CurrentStepOrder'] ? 'active' : '');
                    ?>
                        <?php if ($i > 1): ?>
                            
                        <div class="step-line <?= $i <= $sub['CurrentStepOrder'] ? 'done' : '' ?>"></div>
                        <?php endif; ?>
                        <div class="step-dot <?= $dotCls ?>"></div>
                    <?php endfor; ?>
                    </div>
                    <!-- زر المتابعة أو تعديل وإعادة إرسال إذا كان مُرجَع -->
                    <?php if ($sub['Status'] !== 'Approved'
                              && ($sub['CurrentStepRole'] === 'Student'
                                  || $sub['Status'] === 'Returned')): ?>
                    <div>
                        <a href="form.php?form_id=<?= $sub['FormTypeID'] ?>&submission_id=<?= $sub['SubmissionID'] ?>"
                           class="btn btn-sm btn-g">
                            <?= $sub['Status'] === 'Returned' ? 'تعديل وإعادة إرسال' : 'متابعة' ?>
                        </a>
                    </div>
                    <?php endif; ?>

                </div>

            <?php endforeach; ?>
            </div>

        <?php endif; ?>
        </div>

    </div>
<!-- ══════════════════════════════════════════════════
     داشبورد الموظف
══════════════════════════════════════════════════ -->
<!--else ان كان موظفا-->
<?php else: ?>


    <!-- معلومات الموظف -->
    <div class="card">
        <div class="card-head">معلوماتي</div>
        <div class="card-body">
            <div class="d-row">
                <span class="d-lbl">الاسم</span>
                <span class="d-val"><?= htmlspecialchars($userName) ?></span>
            </div>
            <div class="d-row">
                <span class="d-lbl">الدور الحالي</span>
                <span class="d-val"><?= htmlspecialchars($roleLabel) ?></span>
            </div>
        </div>
    </div>

    <!-- الإشعارات -->
    <div class="card">
        <div class="card-head" style="display:flex;justify-content:space-between;align-items:center;">
            <span>الإشعارات <span id="unreadBadge" style="display:none;background:#e63946;color:#fff;
                border-radius:9px;padding:1px 8px;font-size:11px;font-weight:700;margin-right:6px;"></span></span>
            <button class="btn btn-sm btn-gy" onclick="markAllRead()">تعليم كمقروء</button>
        </div>
        <div class="card-body" style="padding:0;" id="notifList">
            <div class="empty-state">جاري تحميل الإشعارات...</div>
        </div>
    </div>
    <!--تظهر اقسام منفصلة للطلبات التي يجب ان يبدأها الموظف (هو الخطوة الاولى) والطلبات التي هو مرحلة منها (هو خطوة لاحقة)-->
    <?php if (!empty($submissionsToStart)): ?>
    <!-- قسم 1: طلبات يجب أن أبدأها (أنا الخطوة الأولى) — برتقالي -->
    <div class="card">
        <div class="card-head" style="border-right:4px solid #f4a261;padding-right:12px;">
            طلبات تحتاج منك البدء
            <span style="font-size:12px;font-weight:400;color:#888;margin-right:8px;">
                أنت الخطوة الأولى في هذه النماذج
            </span>
        </div>
        <div class="card-body">
            <div class="subs-grid">
            <?php foreach ($submissionsToStart as $sub): ?>
                <div class="sub-card sub-card-start">
                    <div style="display:flex;justify-content:space-between;align-items:flex-start;gap:8px;">
                        <span class="sub-title">نموذج <?= htmlspecialchars($sub['FormCode']) ?></span>
                        <span class="badge-start">ابدأ الآن</span>
                    </div>
                    <div class="sub-meta">
                        <?= htmlspecialchars($sub['FormName']) ?><br>
                        الطالب: <?= htmlspecialchars($sub['StudentName'] ?? '—') ?>
                        <?php if ($sub['UniversityID']): ?>
                        (<?= htmlspecialchars($sub['UniversityID']) ?>)
                        <?php endif; ?>
                    </div>
                    <div>
                        <a href="form.php?form_id=<?= $sub['FormTypeID'] ?>&submission_id=<?= $sub['SubmissionID'] ?>"
                           class="btn btn-sm btn-g">بدء النموذج</a>
                    </div>
                </div>
            <?php endforeach; ?>
            </div>
        </div>
    </div>
    <?php endif; ?>

    <!-- قسم 2: طلبات دوري حلّ فيها (أنا مرحلة منها) — أخضر -->
    <?php if (!empty($submissionsInProgress)): ?>
    <div class="card">
        <div class="card-head" style="border-right:4px solid #1d5c36;padding-right:12px;">
            طلبات تنتظر مراجعتك
            <span style="font-size:12px;font-weight:400;color:#888;margin-right:8px;">
                (<?= count($submissionsInProgress) ?>) طلب
            </span>
        </div>
        <div class="card-body">
            <div class="subs-grid">
    <!-- معالجة شكل ال
     الطلبات الجارية-->
            <?php foreach ($submissionsInProgress as $sub):
                $retCls = $sub['Status'] === 'Returned' ? 'sub-card-returned' : 'sub-card-progress';
                $retBadgeCls = $sub['Status'] === 'Returned' ? 'badge-returned' : 'badge-progress';
                $retBadgeTxt = $sub['Status'] === 'Returned' ? 'مُرجَع' : 'بانتظار مراجعتك';
            ?>
                <div class="sub-card <?= $retCls ?>">
                    <div style="display:flex;justify-content:space-between;align-items:flex-start;gap:8px;">
                        <span class="sub-title">نموذج <?= htmlspecialchars($sub['FormCode']) ?></span>
                        <span class="<?= $retBadgeCls ?>"><?= $retBadgeTxt ?></span>
                    </div>
                    <div class="sub-meta">
                        <?= htmlspecialchars($sub['FormName']) ?><br>
                        الطالب: <?= htmlspecialchars($sub['StudentName'] ?? '—') ?>
                        <?php if ($sub['UniversityID']): ?>
                        (<?= htmlspecialchars($sub['UniversityID']) ?>)
                        <?php endif; ?>
                        <br>الخطوة: <?= htmlspecialchars($sub['StepName']) ?>
                    </div>
                    <div>
                        <a href="form.php?form_id=<?= $sub['FormTypeID'] ?>&submission_id=<?= $sub['SubmissionID'] ?>"
                           class="btn btn-sm btn-g">مراجعة</a>
                    </div>
                </div>
            <?php endforeach; ?>
            </div>
        </div>
    </div>
    <?php endif; ?>

    <?php if (empty($submissionsToStart) && empty($submissionsInProgress)): ?>
    <div class="card">
        <div class="card-body">
            <div class="empty-state">
                <div style="font-size:32px;margin-bottom:10px;">قسم الطلبات قارغ</div>
                لا توجد طلبات تنتظرك حالياً
            </div>
        </div>
    </div>
    <?php endif; ?>

<?php endif; ?>

</div><!-- .main-wrap -->

<!-- ══ FOOTER ══ -->
<footer class="page-footer">
    <span>جميع الحقوق محفوظة <?= date('Y') ?></span>
    <div>
        الوقت: <strong><span class="clock-time"></span></strong>
        &nbsp;&nbsp;
        التاريخ: <strong><span class="clock-date"></span></strong>
    </div>
</footer>

<div id="sys-msg"></div>
<!------------------------------------------------------------------------------------------------------------------------------------------------------------------>
<!------------------------------------------------------------------------------------------------------------------------------------------------------------------>
<!------------------------------------------------------------------------------------------------------------------------------------------------------------------>
<script src="app.js"></script>

<script>
document.addEventListener('DOMContentLoaded', function() { 
    loadNotifications();
 });

// loadNotifications(): Fetch notifications for the current user via AJAX.
// Purpose: populate the notifications panel on the dashboard.
// Used in: called on DOMContentLoaded to load the latest notifications.
function loadNotifications() {
    fetch('getNotifications.php')
    .then(function(r){
        return r.json();
 })
    .then(function(d){
        if (!d.success) 
            return;
        renderNotifications(d.notifications, d.unread_count);
    })
    .catch(function(){
        document.getElementById('notifList').innerHTML =
            '<div class="empty-state">تعذّر تحميل الإشعارات</div>';
    });
}

// renderNotifications(list, unreadCount): Render notification items into the DOM.
// Purpose: format server response and show unread badge and list entries.
// Used in: `loadNotifications()` after receiving data from getNotifications.php.
function renderNotifications(list, unreadCount) {
    var badge = document.getElementById('unreadBadge');
    if (unreadCount > 0) {
        badge.textContent    = unreadCount;
        badge.style.display  = 'inline-block';
    } else {
        badge.style.display  = 'none';
    }
    var container = document.getElementById('notifList');
    if (!list || list.length === 0) {
        container.innerHTML = '<div class="empty-state">لا توجد إشعارات</div>';
        return;
    }
    var icons = {
        General:'📢', FormSubmitted:'📄',
        FormApproved:'✅', FormRejected:'❌', FormReturned:'↩️'
    };
    
    var html = '';
    list.forEach(function(n) {
        var icon   = icons[n.Type] || '📢';
        var unread = n.IsRead == 0 ? ' unread' : '';
        html += '<div class="notif-item' + unread + '" onclick="markRead(' + n.NotificationID + ',this)">'
              + icon + ' ' + esc(n.Message)
              + (n.SenderName
                  ? '<span style="font-size:11px;color:#888;display:block;">من: ' + esc(n.SenderName) + '</span>'
                  : '')
              + '<span class="notif-time">' + esc(n.TimeAgo) + '</span>'
              + '</div>';
    });
    container.innerHTML = html;
}

// markRead(notifId, el): Mark a single notification as read (optimistic UI).
// Purpose: call server to mark notification read and update unread badge locally.
// Used in: when user clicks a notification item in the list.
function markRead(notifId, el) {
    if (!el.classList.contains('unread')) return;
    el.classList.remove('unread');
    //FormData تُستخدم لإرسال بيانات POST إلى markNotifRead.php لتحديث حالة الإشعار في قاعدة البيانات. بعد ذلك، يتم تحديث عداد الإشعارات غير المقروءة في الواجهة الأمامية بشكل فوري (optimistic UI) دون الحاجة لإعادة تحميل الصفحة.
    //وهي عبارة عن واجهة برمجة تطبيقات JavaScript تتيح لك بناء مجموعة من أزواج المفتاح والقيمة تمثل بيانات النموذج، والتي يمكن إرسالها باستخدام fetch أو XMLHttpRequest. في هذا السياق، يتم استخدامها لإرسال معرف الإشعار الذي تم النقر عليه إلى الخادم ليتم تحديث حالته إلى "مقروء".
    var fd = new FormData();
    fd.append('notif_id', notifId);
    fetch('markNotifRead.php', { method:'POST', body:fd });
    var badge = document.getElementById('unreadBadge');
    var count = parseInt(badge.textContent || '0') - 1;
    badge.textContent   = count > 0 ? count : '';
    badge.style.display = count > 0 ? 'inline-block' : 'none';
}

// markAllRead(): Mark all notifications for the user as read.
// Purpose: bulk action used by the "تعليم كمقروء" button on dashboard.
// Used in: dashboard notifications panel.
function markAllRead() {
    var fd = new FormData(); fd.append('all', '1');
    fetch('markNotifRead.php', { method:'POST', body:fd }).then(function() {
        document.querySelectorAll('.notif-item.unread')
                .forEach(function(el){ el.classList.remove('unread'); });
        var badge = document.getElementById('unreadBadge');
        badge.style.display = 'none';
    });
}
</script>
</body>
</html>
