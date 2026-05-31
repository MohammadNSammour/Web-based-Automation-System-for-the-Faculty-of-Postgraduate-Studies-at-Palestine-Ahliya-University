<?php
// ════════════════════════════════════════════════════════
// api/getStep.php — يرجع الخطوة الصحيحة للمستخدم الحالي
// مع تطبيق التسلسل الصارم حتى عبر URL المباشر
// ════════════════════════════════════════════════════════
session_start();
require_once 'db.php';
header('Content-Type: application/json');

checkSessionTimeout();

if (!isset($_SESSION['user_id'])) {
    echo json_encode(['error' => 'غير مصرح']); exit;
}

$formId       = isset($_GET['form_id'])       ? (int)$_GET['form_id']       : 0;
$submissionId = isset($_GET['submission_id']) ? (int)$_GET['submission_id'] : 0;
$currentRole  = $_SESSION['current_role'];
$userId       = $_SESSION['user_id'];

// ══════════════════════════════════════════════════════
// الحالة 1: طلب موجود (submissionId > 0)
// ══════════════════════════════════════════════════════
if ($submissionId > 0) {
    //s66
    $stmt = $conn->prepare("
        SELECT fs.CurrentStepID, fs.StudentID, fws.AllowedRole
        FROM FormSubmissions fs
        JOIN FormWorkflowSteps fws ON fws.StepID = fs.CurrentStepID
        WHERE fs.SubmissionID = ?
    ");
    $stmt->bind_param("i", $submissionId);
    $stmt->execute();
    $sub = $stmt->get_result()->fetch_assoc();

    if (!$sub) {
        echo json_encode(['error' => 'الطلب غير موجود']); exit;
    }

    // التحقق من أن الدور الحالي مخوّل لهذه الخطوة
    if ($sub['AllowedRole'] !== $currentRole) {
        echo json_encode(['error' => 'ليس لديك صلاحية للوصول إلى هذا الطلب في هذه المرحلة.']); exit;
    }

    // إذا كان طالباً: تحقق أن الطلب يخصه
    if ($currentRole === 'Student') {
        //s67
        $stmtStu = $conn->prepare("SELECT StudentNumber FROM Students WHERE UserID = ?");
        if (!$stmtStu) { echo json_encode(['error'=>'خطأ في قاعدة البيانات: '.$conn->error]); exit; }
        $stmtStu->bind_param("i", $userId);
        $stmtStu->execute();
        $stu = $stmtStu->get_result()->fetch_assoc();
        if (!$stu || $stu['StudentNumber'] != $sub['StudentID']) {
            echo json_encode(['error' => 'هذا الطلب لا يخصك.']); exit;
        }
    }

    echo json_encode(['step_id' => $sub['CurrentStepID']]); exit;
}

// ══════════════════════════════════════════════════════
// الحالة 2: طلب جديد (submissionId = 0)
// ══════════════════════════════════════════════════════

// ── التحقق من التسلسل الصارم ──
// لا يجوز فتح أي نموذج ما لم يكن النموذج السابق في التسلسل مكتملاً (Approved)
//s68
$stmtDisplay = $conn->prepare("SELECT DisplayOrder FROM FormTypes WHERE FormTypeID = ?");
if (!$stmtDisplay) { echo json_encode(['error'=>'خطأ في قاعدة البيانات: '.$conn->error]); exit; }
$stmtDisplay->bind_param("i", $formId);
$stmtDisplay->execute();
$currForm = $stmtDisplay->get_result()->fetch_assoc();

if (!$currForm) {
    echo json_encode(['error' => 'النموذج غير موجود']); exit;
}

if ($currForm['DisplayOrder'] > 1) {
    // جلب النموذج السابق في التسلسل
    //s69
    $stmtPrev = $conn->prepare("
        SELECT FormTypeID FROM FormTypes
        WHERE DisplayOrder = ?
    ");
    $prevOrder = $currForm['DisplayOrder'] - 1;
    $stmtPrev->bind_param("i", $prevOrder);
    $stmtPrev->execute();
    $prevForm = $stmtPrev->get_result()->fetch_assoc();

    if ($prevForm) {

        if ($currentRole === 'Student') {
            //s70
            $stmtStu = $conn->prepare("SELECT StudentNumber FROM Students WHERE UserID = ?");
            if (!$stmtStu) { echo json_encode(['error'=>'خطأ في قاعدة البيانات: '.$conn->error]); exit; }
            $stmtStu->bind_param("i", $userId);
            $stmtStu->execute();
            $stu = $stmtStu->get_result()->fetch_assoc();

            if ($stu) {
                //s71
                $stmtDone = $conn->prepare("
                    SELECT SubmissionID FROM FormSubmissions
                    WHERE FormTypeID = ? AND StudentID = ? AND Status = 'Approved'
                    LIMIT 1
                ");
                $stmtDone->bind_param("ii", $prevForm['FormTypeID'], $stu['StudentNumber']);
                $stmtDone->execute();
                if (!$stmtDone->get_result()->fetch_assoc()) {
                    echo json_encode(['error' => 'لا يمكن فتح هذا النموذج قبل اكتمال النموذج السابق.']); exit;
                }
            }
        } else {
            // للموظف: النموذج السابق يجب أن يكون Approved لأي طالب
            //s72
            $stmtDone = $conn->prepare("
                SELECT SubmissionID FROM FormSubmissions
                WHERE FormTypeID = ? AND Status = 'Approved'
                LIMIT 1
            ");
            $stmtDone->bind_param("i", $prevForm['FormTypeID']);
            $stmtDone->execute();
            if (!$stmtDone->get_result()->fetch_assoc()) {
                echo json_encode(['error' => 'لا يمكن فتح هذا النموذج قبل اكتمال النموذج السابق في التسلسل.']); exit;
            }
        }
    }
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////
// ── للطالب: منع فتح طلب جديد إذا كان لديه طلب نشط ──
// سابقاً كان هذا التحقق يتم فقط في الواجهة الأمامية، لكن تم نقله إلى هنا لضمان تطبيقه حتى مع الوصول المباشر عبر URL
//هو ليس معناه ان هناك زر او رابط معين يمكن من خلال فتح النموذج بأي وقت,لكنه شيء للحماية من الوصول المباشر عبر URL, يعني حتى لو حاول الطالب يفتح النموذج عن طريق كتابة الرابط في المتصفح, هذا الكود راح يمنعه إذا كان لديه طلب نشط لهذا النموذج.
if ($currentRole === 'Student') {
    //s73
    $stmtStu = $conn->prepare("SELECT StudentNumber FROM Students WHERE UserID = ?");
    if (!$stmtStu) { echo json_encode(['error'=>'خطأ في قاعدة البيانات: '.$conn->error]); exit; }
    $stmtStu->bind_param("i", $userId);
    $stmtStu->execute();
    $stu = $stmtStu->get_result()->fetch_assoc();

    if ($stu) {
        //s74
        $stmtActive = $conn->prepare("
            SELECT SubmissionID FROM FormSubmissions
            WHERE FormTypeID = ? AND StudentID = ? AND Status IN ('InProgress','Returned')
            ORDER BY CreatedAt DESC LIMIT 1
        ");
        $stmtActive->bind_param("ii", $formId, $stu['StudentNumber']);
        $stmtActive->execute();
        $active = $stmtActive->get_result()->fetch_assoc();
        if ($active) {
            echo json_encode([
                'step_id'               => 0,
                'redirect_submission_id'=> $active['SubmissionID'],
                'message'               => 'يوجد طلب نشط لهذا النموذج. سيتم تحويلك إلى الطلب الحالي.'
            ]); exit;
        }
    }
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////
// ── التحقق من أن الدور مطلوب للخطوة الأولى في هذا النموذج ──
//s75
$stmt = $conn->prepare("
    SELECT StepID FROM FormWorkflowSteps
    WHERE FormTypeID = ? AND StepOrder = 1 AND AllowedRole = ?
    LIMIT 1
");
$stmt->bind_param("is", $formId, $currentRole);
$stmt->execute();
$step = $stmt->get_result()->fetch_assoc();

if (!$step) {
    echo json_encode(['error' => 'ليس لديك صلاحية لبدء هذا النموذج.']); exit;
}

echo json_encode(['step_id' => $step['StepID']]);
