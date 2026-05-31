<?php
// ════════════════════════════════════════════════════════
// api/saveForm.php — حفظ بيانات النموذج وتقديمه للخطوة التالية
// يدعم: التسلسل الصارم + التكرار (720) + مسار الممتحنين (706,707)
// ════════════════════════════════════════════════════════
session_start();
require_once 'db.php';
header('Content-Type: application/json');

checkSessionTimeout();

if (!isset($_SESSION['user_id'])) {
    echo json_encode(['success'=>false,'message'=>'غير مصرح']); exit;
}

$userId       = $_SESSION['user_id'];
$currentRole  = $_SESSION['current_role'];
$formId       = isset($_POST['formId'])       ? (int)$_POST['formId']       : 0;
$stepId       = isset($_POST['stepId'])       ? (int)$_POST['stepId']       : 0;
$submissionId = isset($_POST['submissionId']) ? (int)$_POST['submissionId'] : 0;
//////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////
// إصلاح: حماية من JSON فاسد أو قيمة null
$values = json_decode($_POST['values'] ?? '[]', true);
if (!is_array($values)) $values = [];

if (!$formId || !$stepId) {
    echo json_encode(['success'=>false,'message'=>'بيانات ناقصة']); exit;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////
// ── التحقق من الخطوة والدور ──
$stmt = $conn->prepare("
    SELECT FormTypeID, AllowedRole, StepOrder, MaxRepeats
    FROM FormWorkflowSteps WHERE StepID=?
");
if (!$stmt) { echo json_encode(['success'=>false,'message'=>'خطأ في قاعدة البيانات: '.$conn->error]); exit; }
$stmt->bind_param("i", $stepId);
$stmt->execute();
$stepInfo = $stmt->get_result()->fetch_assoc();

if (!$stepInfo || $stepInfo['FormTypeID'] != $formId) {
    echo json_encode(['success'=>false,'message'=>'الخطوة غير صحيحة.']); exit;
}
if ($stepInfo['AllowedRole'] !== $currentRole) {
    echo json_encode(['success'=>false,'message'=>'ليس لديك صلاحية.']); exit;
}

$currentOrder = $stepInfo['StepOrder'];
$maxRepeats   = $stepInfo['MaxRepeats'];
//////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////
// ── جلب معلومات النموذج ──
$stmtFT = $conn->prepare("
    SELECT Code, AllowMultipleSubmissions FROM FormTypes WHERE FormTypeID=?
");
if (!$stmtFT) { echo json_encode(['success'=>false,'message'=>'خطأ في قاعدة البيانات: '.$conn->error]); exit; }
$stmtFT->bind_param("i", $formId);
$stmtFT->execute();
$formInfo      = $stmtFT->get_result()->fetch_assoc();
$formCode      = $formInfo['Code'] ?? '';
$allowMultiple = (bool)($formInfo['AllowMultipleSubmissions'] ?? false);
//////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////
// ── جلب أو إنشاء الـ Submission ──
$studentId          = null;
$thesisId           = null;
$repeatNumber       = 1;
$examinerType       = null;
$examinerEmployeeId = null;

if ($submissionId > 0) {
    $stmt0 = $conn->prepare("SELECT * FROM FormSubmissions WHERE SubmissionID=?");
    if (!$stmt0) { echo json_encode(['success'=>false,'message'=>'خطأ في قاعدة البيانات: '.$conn->error]); exit; }
    $stmt0->bind_param("i", $submissionId);
    $stmt0->execute();
    $sub = $stmt0->get_result()->fetch_assoc();

    if (!$sub) { echo json_encode(['success'=>false,'message'=>'الطلب غير موجود']); exit; }
    if ($sub['CurrentStepID'] != $stepId) {
        echo json_encode(['success'=>false,'message'=>'الطلب لا يتطابق مع هذه الخطوة.']); exit;
    }
    if (in_array($sub['Status'], ['Approved','Rejected'])) {
        echo json_encode(['success'=>false,'message'=>'هذا الطلب مغلق.']); exit;
    }

    $studentId          = $sub['StudentID'];
    $thesisId           = $sub['ThesisID'];
    $repeatNumber       = $sub['RepeatNumber'];
    $examinerType       = $sub['ExaminerType'];
    $examinerEmployeeId = $sub['ExaminerEmployeeID'];

    if ($currentRole === 'Student') {
        $stmtStu = $conn->prepare("SELECT StudentNumber FROM Students WHERE UserID=?");
        if (!$stmtStu) { echo json_encode(['success'=>false,'message'=>'خطأ في قاعدة البيانات: '.$conn->error]); exit; }
        $stmtStu->bind_param("i", $userId);
        $stmtStu->execute();
        $stu = $stmtStu->get_result()->fetch_assoc();
        if (!$stu || $studentId != $stu['StudentNumber']) {
            echo json_encode(['success'=>false,'message'=>'لا يمكنك تعديل هذا الطلب.']); exit;
        }
    }
} else {
    if ($currentRole === 'Student') {
        $stmtStu = $conn->prepare("SELECT StudentNumber FROM Students WHERE UserID=?");
        if (!$stmtStu) { echo json_encode(['success'=>false,'message'=>'خطأ في قاعدة البيانات: '.$conn->error]); exit; }
        $stmtStu->bind_param("i", $userId);
        $stmtStu->execute();
        $stu = $stmtStu->get_result()->fetch_assoc();
        if (!$stu) { echo json_encode(['success'=>false,'message'=>'الطالب غير موجود']); exit; }
        $studentId = $stu['StudentNumber'];

        if (!$allowMultiple) {
            $stmtDup = $conn->prepare("
                SELECT SubmissionID FROM FormSubmissions
                WHERE FormTypeID=? AND StudentID=? AND Status IN ('InProgress','Returned')
                ORDER BY CreatedAt DESC LIMIT 1
            ");
            if (!$stmtDup) { echo json_encode(['success'=>false,'message'=>'خطأ في قاعدة البيانات: '.$conn->error]); exit; }
            $stmtDup->bind_param("ii", $formId, $studentId);
            $stmtDup->execute();
            $dup = $stmtDup->get_result()->fetch_assoc();
            if ($dup) {
                echo json_encode([
                    'success'=>false,
                    'message'=>'يوجد طلب نشط بالفعل.',
                    'existing_submission_id'=>$dup['SubmissionID']
                ]); exit;
            }
        }
    } else {
        $studentId          = isset($_POST['studentId'])          ? (int)$_POST['studentId']          : null;
        $thesisId           = isset($_POST['thesisId'])           ? (int)$_POST['thesisId']           : null;
        $examinerType       = $_POST['examinerType']              ?? null;
        $examinerEmployeeId = isset($_POST['examinerEmployeeId']) ? (int)$_POST['examinerEmployeeId']  : null;

        if ($allowMultiple && $studentId) {
            $stmtRepeat = $conn->prepare("
                SELECT MAX(RepeatNumber) AS maxRep FROM FormSubmissions
                WHERE FormTypeID=? AND StudentID=? AND ExaminerType=?
            ");
            if (!$stmtRepeat) { echo json_encode(['success'=>false,'message'=>'خطأ في قاعدة البيانات: '.$conn->error]); exit; }
            $stmtRepeat->bind_param("iis", $formId, $studentId, $examinerType);
            $stmtRepeat->execute();
            $repRow       = $stmtRepeat->get_result()->fetch_assoc();
            $repeatNumber = ($repRow['maxRep'] ?? 0) + 1;
        }
    }
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////
// ── تحديد الخطوة التالية ──
$nextStepId = $stepId;  // الافتراضي: نبقى في نفس الخطوة
$isFormDone = false;
$newStatus  = 'InProgress';

if ($maxRepeats > 1) {
    if ($repeatNumber < $maxRepeats) {
        $newStatus  = 'Approved';
        $isFormDone = false;
    } else {
        [$nextStepId, $isFormDone, $newStatus] = _getNextStep($conn, $formId, $currentOrder, $stepId);
    }
} else {
    [$nextStepId, $isFormDone, $newStatus] = _getNextStep($conn, $formId, $currentOrder, $stepId);
}

// ── جلب أسماء حقول الـ file/signature من قاعدة البيانات ──
// نجلبها مرة واحدة ونخزنها في map: fieldId => fieldName
$fieldNamesMap = [];
if (!empty($values)) {
    $fieldIds = array_map(fn($f) => (int)($f['fieldId'] ?? 0), $values);
    $fieldIds = array_filter($fieldIds);
    if ($fieldIds) {
        $placeholders = implode(',', array_fill(0, count($fieldIds), '?'));
        $types        = str_repeat('i', count($fieldIds));
        $stmtFN = $conn->prepare("SELECT FieldID, FieldName FROM FormFields WHERE FieldID IN ($placeholders)");
        if ($stmtFN) {
            $stmtFN->bind_param($types, ...$fieldIds);
            $stmtFN->execute();
            $fnRows = $stmtFN->get_result()->fetch_all(MYSQLI_ASSOC);
            foreach ($fnRows as $fnRow) {
                $fieldNamesMap[$fnRow['FieldID']] = $fnRow['FieldName'];
            }
        }
    }
}

// ── مسار الملفات ──
// الهيكل الموحد: uploads/forms/{formId}/{submissionId}/filename
// نكتشف جذر المشروع تلقائياً:
//   إذا كان saveForm.php في MPA/api/ → __DIR__ = .../MPA/api → dirname = .../MPA
//   إذا كان في MPA/ مباشرة → __DIR__ = .../MPA → نستخدمه كما هو
$_selfDir    = __DIR__;
$_parentDir  = dirname($_selfDir);
// نتحقق: هل uploads/ موجودة في المجلد الأب؟ إذا نعم استخدمه، وإلا استخدم المجلد الحالي
$projectRoot = is_dir($_parentDir . '/uploads') ? $_parentDir : $_selfDir;
$uploadDir   = ''; // سيُحدَّد بعد معرفة submissionId

// ══════════════════════════════════════
// بداية Transaction لضمان تكامل البيانات
// ══════════════════════════════════════
$conn->begin_transaction();

try {

    // ── إنشاء أو تحديث الـ Submission ──
    if ($submissionId == 0) {
        $stmt3 = $conn->prepare("
            INSERT INTO FormSubmissions
                (FormTypeID,CurrentStepID,CreatedBy,StudentID,ThesisID,
                 Status,RepeatNumber,ExaminerType,ExaminerEmployeeID)
            VALUES (?,?,?,?,?,?,?,?,?)
        ");
        if (!$stmt3) throw new Exception('خطأ في إعداد الاستعلام: '.$conn->error);
        $stmt3->bind_param("iiiiisisi",
            $formId, $nextStepId, $userId, $studentId, $thesisId,
            $newStatus, $repeatNumber, $examinerType, $examinerEmployeeId);
        $stmt3->execute();
        $submissionId = $stmt3->insert_id;
//////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////
        // الآن نعرف submissionId — أنشئ المجلد الكامل
        $uploadDir = $projectRoot . '/uploads/forms/' . $formId . '/' . $submissionId . '/';
        if (!is_dir($uploadDir)) {
            if (!mkdir($uploadDir, 0755, true)) {
                throw new Exception('تعذّر إنشاء مجلد الرفع.');
            }
        }
    } else {
        $stmt3 = $conn->prepare("
            UPDATE FormSubmissions SET CurrentStepID=?,Status=? WHERE SubmissionID=?
        ");
        if (!$stmt3) throw new Exception('خطأ في إعداد الاستعلام: '.$conn->error);
        $stmt3->bind_param("isi", $nextStepId, $newStatus, $submissionId);
        $stmt3->execute();

        // للطلبات الموجودة: submissionId معروف مسبقًا
        $uploadDir = $projectRoot . '/uploads/forms/' . $formId . '/' . $submissionId . '/';
        if (!is_dir($uploadDir)) {
            if (!mkdir($uploadDir, 0755, true)) {
                throw new Exception('تعذّر إنشاء مجلد الرفع.');
            }
        }
    }
//////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////
    // ── حفظ قيم الحقول ──
    foreach ($values as $field) {
        $fieldId = (int)($field['fieldId'] ?? 0);
        if (!$fieldId) continue;
        $value   = $field['value'] ?? '';
//////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////
        // نبحث عن الملف القديم في قاعدة البيانات قبل الحذف
        $stmtOld = $conn->prepare("SELECT FieldValue FROM FormValues WHERE SubmissionID=? AND FieldID=? AND StepID=?");
        if (!$stmtOld) throw new Exception('خطأ في إعداد الاستعلام: '.$conn->error);
        $stmtOld->bind_param("iii", $submissionId, $fieldId, $stepId);
        $stmtOld->execute();
        $oldRow = $stmtOld->get_result()->fetch_assoc();
//////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////
        // رفع الملف الجديد
        if (isset($_FILES[$fieldId]) && $_FILES[$fieldId]['error'] === 0) {
            // صيغة الاسم: {fieldName}_{formCode}_{submissionId}_{stepId}.{ext}
            $originalName = basename($_FILES[$fieldId]['name']);
            $ext          = strtolower(pathinfo($originalName, PATHINFO_EXTENSION));
            $fieldName    = $fieldNamesMap[$fieldId] ?? ('field_' . $fieldId);
            // تنظيف fieldName من أي حرف غير آمن
            $fieldName    = preg_replace('/[^a-zA-Z0-9_\-]/', '_', $fieldName);
            $fileName     = $fieldName . '_' . $formCode . '_' . $submissionId . '_' . $stepId . '.' . $ext;

            if (!move_uploaded_file($_FILES[$fieldId]['tmp_name'], $uploadDir . $fileName)) {
                throw new Exception('فشل رفع الملف للحقل ' . $fieldId);
            }
            // حذف الملف القديم من الخادم إذا كان موجوداً
            if ($oldRow && $oldRow['FieldValue'] && $oldRow['FieldValue'] !== 'FILE_UPLOADED') {
                $oldFilePath = $uploadDir . $oldRow['FieldValue'];
                if (is_file($oldFilePath)) {
                    unlink($oldFilePath);
                }
            }
            $value = $fileName;
        }

        $stmtDel = $conn->prepare("DELETE FROM FormValues WHERE SubmissionID=? AND FieldID=? AND StepID=?");
        if (!$stmtDel) throw new Exception('خطأ في إعداد الاستعلام: '.$conn->error);
        $stmtDel->bind_param("iii", $submissionId, $fieldId, $stepId);
        $stmtDel->execute();

        $stmtIns = $conn->prepare("INSERT INTO FormValues (SubmissionID,FieldID,StepID,FieldValue) VALUES(?,?,?,?)");
        if (!$stmtIns) throw new Exception('خطأ في إعداد الاستعلام: '.$conn->error);
        $stmtIns->bind_param("iiis", $submissionId, $fieldId, $stepId, $value);
        $stmtIns->execute();
    }
//////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////
    // ── سجل التاريخ ──
    $stmtHist = $conn->prepare("
        INSERT INTO FormWorkflowHistory (SubmissionID,StepID,Action,ActedBy)
        VALUES (?,?,'Submitted',?)
    ");
    if (!$stmtHist) throw new Exception('خطأ في إعداد الاستعلام: '.$conn->error);
    $stmtHist->bind_param("iii", $submissionId, $stepId, $userId);
    $stmtHist->execute();
//////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////
    // ── نموذج 720: إنشاء submission للتكرار التالي ──
    if ($maxRepeats > 1 && !$isFormDone && $repeatNumber < $maxRepeats && $studentId) {
        $nextRepeat = $repeatNumber + 1;
        $stmtFS = $conn->prepare("
            SELECT StepID FROM FormWorkflowSteps WHERE FormTypeID=? AND StepOrder=1 LIMIT 1
        ");
        if (!$stmtFS) throw new Exception('خطأ في إعداد الاستعلام: '.$conn->error);
        $stmtFS->bind_param("i", $formId);
        $stmtFS->execute();
        $firstStep = $stmtFS->get_result()->fetch_assoc();
        if ($firstStep) {
            $stmtNS = $conn->prepare("
                INSERT INTO FormSubmissions
                    (FormTypeID,CurrentStepID,CreatedBy,StudentID,ThesisID,Status,RepeatNumber)
                VALUES (?,?,?,?,?,'InProgress',?)
            ");
            if (!$stmtNS) throw new Exception('خطأ في إعداد الاستعلام: '.$conn->error);
            $stmtNS->bind_param("iiiiii",
                $formId, $firstStep['StepID'], $userId, $studentId, $thesisId, $nextRepeat);
            $stmtNS->execute();
        }
        _recordProgress($conn, $studentId, $formId, $submissionId, $thesisId, $repeatNumber);
        _sendNotification($conn, $userId,
            'يمكنك الآن تعبئة اللقاء رقم ' . $nextRepeat . ' من نموذج ' . $formCode,
            'FormApproved', $submissionId, $stepInfo['AllowedRole'], $studentId);
    }
//////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////
    // ── اكتمال النموذج ──
    if ($isFormDone && $studentId) {
        _recordProgress($conn, $studentId, $formId, $submissionId, $thesisId, $repeatNumber);
        _notifyNextForm($conn, $userId, $formId, $formCode, $submissionId,
                        $studentId, $thesisId, $examinerType, $examinerEmployeeId);
    }

    $conn->commit();

} catch (Exception $e) {
    $conn->rollback();
    echo json_encode(['success'=>false,'message'=>'حدث خطأ أثناء الحفظ: '.$e->getMessage()]); exit;
}

$msg = $isFormDone
     ? 'تم اعتماد النموذج بنجاح!'
     : ($maxRepeats > 1 && $repeatNumber < $maxRepeats
        ? 'تم حفظ اللقاء رقم ' . $repeatNumber . '، في انتظار اللقاء التالي.'
        : 'تم الإرسال بنجاح، في انتظار المراجعة.');

echo json_encode(['success'=>true,
'message'=>$msg,
'submission_id'=>$submissionId
]);


















/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// ════════════════════════════════════════════════════════
// دوال مساعدة
// ════════════════════════════════════════════════════════
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// إصلاح: استخدام متغير مؤقت بدل expression في bind_param
// لما لا توجد خطوة تالية نبقي CurrentStepID على الخطوة الحالية بدل 0
// _getNextStep($conn, $formId, $currentOrder, $currentStepId)
// Purpose: determine the next workflow step for a form or mark the form as done.
// Returns: [nextStepId, isFormDone(bool), newStatus]
// Used in: main save flow above to advance submission to the next step.
function _getNextStep($conn, $formId, $currentOrder, $currentStepId = 0) {
    $nextOrder = $currentOrder + 1;
    $stmt = $conn->prepare("
        SELECT StepID FROM FormWorkflowSteps WHERE FormTypeID=? AND StepOrder=?
    ");
    if (!$stmt) return [$currentStepId, true, 'Approved'];
    $stmt->bind_param("ii", $formId, $nextOrder);
    $stmt->execute();
    $next = $stmt->get_result()->fetch_assoc();
    if ($next) return [$next['StepID'], false, 'InProgress'];
    // آخر خطوة: نبقي نفس الـ StepID الحالي
    return [$currentStepId, true, 'Approved'];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////
// _recordProgress(...): Record/update student progress for completed forms.
// Purpose: keep StudentProgress table up-to-date when a form/meeting is done.
// Used in: after finishing a repeat sequence or completing a form (see main flow).
function _recordProgress($conn, $studentId, $formId, $submissionId, $thesisId, $repeatNumber) {
    $stmt = $conn->prepare("
        INSERT INTO StudentProgress
            (StudentNumber,FormTypeID,SubmissionID,ThesisID,RepeatNumber)
        VALUES (?,?,?,?,?)
        ON DUPLICATE KEY UPDATE
            SubmissionID=VALUES(SubmissionID),
            ThesisID=VALUES(ThesisID),
            CompletedAt=CURRENT_TIMESTAMP
    ");
    if (!$stmt) return;
    $stmt->bind_param("iiiii", $studentId, $formId, $submissionId, $thesisId, $repeatNumber);
    $stmt->execute();
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////
// _notifyNextForm(...): When a form is completed, prepare and optionally create
// the next form in the sequence and send notifications to relevant users.
// Purpose: chain workflows and notify the next responsible role.
// Used in: after a form is fully approved and `isFormDone` is true.
function _notifyNextForm($conn, $userId, $formId, $formCode, $submissionId,
                         $studentId, $thesisId, $examinerType, $examinerEmployeeId) {
    $stmtD = $conn->prepare("SELECT DisplayOrder FROM FormTypes WHERE FormTypeID=?");
    if (!$stmtD) return;
    $stmtD->bind_param("i", $formId);
    $stmtD->execute();
    $disp = $stmtD->get_result()->fetch_assoc();
    if (!$disp) return;

    $stmtNF = $conn->prepare("
        SELECT FormTypeID,Code,Name FROM FormTypes
        WHERE DisplayOrder>? ORDER BY DisplayOrder ASC LIMIT 1
    ");
    if (!$stmtNF) return;
    $stmtNF->bind_param("i", $disp['DisplayOrder']);
    $stmtNF->execute();
    $nextForm = $stmtNF->get_result()->fetch_assoc();
    if (!$nextForm) return;

    $stmtFS = $conn->prepare("
        SELECT StepID,AllowedRole FROM FormWorkflowSteps
        WHERE FormTypeID=? AND StepOrder=1 LIMIT 1
    ");
    if (!$stmtFS) return;
    $stmtFS->bind_param("i", $nextForm['FormTypeID']);
    $stmtFS->execute();
    $firstStep = $stmtFS->get_result()->fetch_assoc();
    if (!$firstStep) return;

    if ($firstStep['AllowedRole'] !== 'Student' && $studentId) {
        $stmtNS = $conn->prepare("
            INSERT INTO FormSubmissions
                (FormTypeID,CurrentStepID,CreatedBy,StudentID,ThesisID,
                 Status,RepeatNumber,ExaminerType,ExaminerEmployeeID)
            VALUES (?,?,?,?,?,'InProgress',1,?,?)
        ");
        if (!$stmtNS) return;
        $stmtNS->bind_param("iiiiisi",
            $nextForm['FormTypeID'], $firstStep['StepID'],
            $userId, $studentId, $thesisId,
            $examinerType, $examinerEmployeeId);
        $stmtNS->execute();
    }

    $notifMsg = 'تم اعتماد نموذج ' . $formCode . '، يمكنك الآن البدء في نموذج '
              . $nextForm['Code'] . ' — ' . $nextForm['Name'];

    _sendNotification($conn, $userId, $notifMsg, 'FormApproved',
                      $submissionId, $firstStep['AllowedRole'], $studentId);
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////
// _sendNotification(...): Insert a notification and attach it to target users.
// Purpose: create Notifications + NotificationTo rows for a message and role/student.
// Used in: multiple places (saveForm, actionForm, etc.) to inform users of changes.
function _sendNotification($conn, $senderId, $msg, $type, $submissionId, $role, $studentId) {
    $stmtN = $conn->prepare("
        INSERT INTO Notifications (SenderID,Message,Type,RelatedSubmissionID) VALUES(?,?,?,?)
    ");
    if (!$stmtN) return;
    $stmtN->bind_param("issi", $senderId, $msg, $type, $submissionId);
    $stmtN->execute();
    $notifId = $stmtN->insert_id;

    if ($role === 'Student' && $studentId) {
        $stmtU = $conn->prepare("SELECT UserID FROM Students WHERE StudentNumber=?");
        if (!$stmtU) return;
        $stmtU->bind_param("i", $studentId);
        $stmtU->execute();
        $u = $stmtU->get_result()->fetch_assoc();
        if ($u) {
            $stmtNT = $conn->prepare("INSERT INTO NotificationTo (NotificationID,UserID) VALUES(?,?)");
            if (!$stmtNT) return;
            $stmtNT->bind_param("ii", $notifId, $u['UserID']);
            $stmtNT->execute();
        }
    } else {
        $stmtR = $conn->prepare("
            SELECT e.UserID FROM Employees e
            JOIN Employee_Roles er ON er.EmployeeNumber=e.EmployeeNumber WHERE er.Role=?
        ");
        if (!$stmtR) return;
        $stmtR->bind_param("s", $role);
        $stmtR->execute();
        $users = $stmtR->get_result()->fetch_all(MYSQLI_ASSOC);
        foreach ($users as $u) {
            $stmtNT = $conn->prepare("INSERT INTO NotificationTo (NotificationID,UserID) VALUES(?,?)");
            if (!$stmtNT) continue;
            $stmtNT->bind_param("ii", $notifId, $u['UserID']);
            $stmtNT->execute();
        }
    }
}
