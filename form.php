<?php
// ════════════════════════════════════════════════════════
// form.php  —  صفحة النماذج الموحدة (صفحة واحدة لكل النماذج)
// هيكل: sidebar fixed + main-wrap + footer fixed
// النموذج نفسه يُحمَّل ديناميكياً بـ AJAX من api/getForm.php
// ════════════════════════════════════════════════════════
//1
//صفحة الفورمس الرئيسية
session_start();
require_once 'db.php';

checkSessionTimeout();

if (!isset($_SESSION['user_id'])) { header('Location: login.php'); exit; }

$userId      = $_SESSION['user_id'];
$userName    = $_SESSION['user_name'];
$currentRole = $_SESSION['current_role'];
//it brings them from the card that either represent a form to be filled or a submission to be reviewed and they are sent as query parameters in the url like form.php?form_id=1&submission_id=2
$formId      = isset($_GET['form_id'])       ? (int)$_GET['form_id']       : 0;
$subId       = isset($_GET['submission_id']) ? (int)$_GET['submission_id'] : 0;

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

// معلومات النموذج
$formInfo = null;
if ($formId) {
    //s46
    $stmt = $conn->prepare("SELECT * FROM FormTypes WHERE FormTypeID = ?");
    $stmt->bind_param("i", $formId);
    $stmt->execute();
    $formInfo = $stmt->get_result()->fetch_assoc();
}

// خطوات الـ workflow لعرض المسار في الشريط الجانبي
$wfSteps = [];
if ($formId) {
    //s47
    $stmt = $conn->prepare("SELECT * FROM FormWorkflowSteps WHERE FormTypeID = ? ORDER BY StepOrder");
    $stmt->bind_param("i", $formId);
    $stmt->execute();
    $wfSteps = $stmt->get_result()->fetch_all(MYSQLI_ASSOC);
}

// الخطوة الحالية وحالة الطلب
$currentStepId    = 0;
$currentStepOrder = 1;
$subStatus        = '';
$returnNotes      = '';

if ($subId) {
    //s48
    $stmt = $conn->prepare("SELECT * FROM FormSubmissions WHERE SubmissionID = ?");
    $stmt->bind_param("i", $subId);
    $stmt->execute();
    $sub = $stmt->get_result()->fetch_assoc();
    if ($sub) {
        $currentStepId = $sub['CurrentStepID'];
        $subStatus     = $sub['Status'];
        foreach ($wfSteps as $ws) {
            if ($ws['StepID'] == $currentStepId) { 
                $currentStepOrder = $ws['StepOrder'];
                break;
            }
        }
        // ملاحظات آخر إرجاع
        //s49
        $stmt2 = $conn->prepare("
            SELECT Notes FROM FormWorkflowHistory
            WHERE SubmissionID = ? AND Action = 'Returned'
            ORDER BY ActionDate DESC LIMIT 1
        ");
        $stmt2->bind_param("i", $subId);
        $stmt2->execute();
        $hist        = $stmt2->get_result()->fetch_assoc();
        $returnNotes = $hist['Notes'] ?? '';
    }
}
?>
<!------------------------------------------------------------------------------------------------------------------------------------------------------------------>
<!------------------------------------------------------------------------------------------------------------------------------------------------------------------>
<!------------------------------------------------------------------------------------------------------------------------------------------------------------------>

<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
    <meta charset="UTF-8">
    <title><?= $formInfo ? 'نموذج '.$formInfo['Code'] : 'النماذج' ?> — كلية الدراسات العليا</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Cairo:wght@400;600;700;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="style.css">
</head>
<body>

<!-- ══════════════════════════════════════--
     الشريط الجانبي الثابت
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
    <a href="dashboard.php" class="side-btn">العودة للرئيسية</a>

    <!-- مسار النموذج -->
    <?php if (!empty($wfSteps)): ?>
    <hr class="sep">
    <div class="sec-title">مسار النموذج</div>
    
    <?php foreach ($wfSteps as $i => $step):
        $cls = '';
        if ($step['StepID'] == $currentStepId)          $cls = 'current';
        elseif ($step['StepOrder'] < $currentStepOrder)  $cls = 'done';
    ?>
        <div class="wf-step <?= $cls ?>">
            <?= htmlspecialchars($roleLabels[$step['AllowedRole']] ?? $step['AllowedRole']) ?>
        </div>
        <?php if ($i < count($wfSteps)-1): ?>
        <div class="wf-arrow">↓</div>
        <?php endif; ?>
    <?php endforeach; ?>
    <?php endif; ?>

    <hr class="sep">
    <a href="logout.php" class="btn-logout">تسجيل الخروج</a>

</aside>

<!-- ══════════════════════════════════════
     المحتوى الرئيسي
     ══════════════════════════════════════ -->
<div class="main-wrap">

    <!-- تنبيه الإرجاع -->
    <?php if ($subStatus === 'Returned' && $returnNotes): ?>
    <div style="background:#fff4e6;border:1px solid #f4a261;border-radius:5px;
                padding:9px 14px;margin-bottom:12px;font-size:13px;color:#92400e;font-weight:600;">
        تم الإرجاع للتعديل — <?= htmlspecialchars($returnNotes) ?>
    </div>
    <?php endif; ?>

    <?php if ($formId && $formInfo): ?>

    <div id="form-area">
        <div style="text-align:center;padding:30px;color:#888;">جاري التحميل...</div>
    </div>
    
    <?php else: ?>
    <div style="text-align:center;padding:40px;color:#888;">
        <p style="font-size:14px;font-weight:700;">لم يتم تحديد نموذج</p>
        <a href="dashboard.php" class="btn btn-g" style="margin-top:12px;display:inline-block;">رجوع</a>
    </div>
    <?php endif; ?>

</div><!-- .main-wrap -->

<!-- ══ التذييل — fixed ══ -->
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

<?php if ($formId && $formInfo): ?>
<script>
    var PAGE_FORM_ID = <?= $formId ?>;
    var PAGE_SUB_ID  = <?= $subId ?>;
</script>
<script src="form.js"></script>
<?php endif; ?>

</body>
</html>
<!------------------------------------------------------------------------------------------------------------------------------------------------------------------>
<!------------------------------------------------------------------------------------------------------------------------------------------------------------------>
<!------------------------------------------------------------------------------------------------------------------------------------------------------------------>
