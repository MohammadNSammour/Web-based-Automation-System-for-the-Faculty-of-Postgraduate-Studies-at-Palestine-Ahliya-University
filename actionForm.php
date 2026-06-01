<?php
// ════════════════════════════════════════════════════════
// api/actionForm.php — الموافقة / الرفض / الإرجاع
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
$action       = $_POST['action']       ?? '';
$submissionId = (int)($_POST['submissionId'] ?? 0);
$stepId       = (int)($_POST['stepId']       ?? 0);
$notes        = trim($_POST['notes']         ?? '');
# يتحقق من ان الاجراء موجود وصحيح
if (!$submissionId || !$stepId || !in_array($action, ['approve','reject','return'])) {
    echo json_encode(['success'=>false,'message'=>'بيانات ناقصة']); exit;
}
//---------------------------
// ── التحقق من الخطوة والدور ──
//s1
$stmtStep = $conn->prepare("SELECT FormTypeID, AllowedRole, StepOrder, MaxRepeats FROM FormWorkflowSteps WHERE StepID=?");
if (!$stmtStep) { 
    echo json_encode(['success'=>false,'message'=>'خطأ في قاعدة البيانات: '.$conn->error]);
    exit;
} 
$stmtStep->bind_param("i", $stepId);
$stmtStep->execute();
$stepInfo = $stmtStep->get_result()->fetch_assoc();
if (!$stepInfo || $stepInfo['AllowedRole'] !== $currentRole) {
    echo json_encode(['success'=>false,'message'=>'ليس لديك صلاحية لتنفيذ هذا الإجراء.']); 
    exit;
}
$formId       = $stepInfo['FormTypeID'];
$currentOrder = $stepInfo['StepOrder'];
$maxRepeats   = $stepInfo['MaxRepeats'];
//---------------------------
// ── جلب الطلب ──
//s2
$stmt = $conn->prepare("SELECT * FROM FormSubmissions WHERE SubmissionID=?");
if (!$stmt) { 
    echo json_encode(['success'=>false,'message'=>'خطأ في قاعدة البيانات: '.$conn->error]);
    exit; }
$stmt->bind_param("i", $submissionId);
$stmt->execute();
$sub = $stmt->get_result()->fetch_assoc();

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
$returnedToStep     = null;
//---------------------------
// ── جلب كود النموذج ──
//s3
$stmtCode = $conn->prepare("SELECT Code, AllowMultipleSubmissions FROM FormTypes WHERE FormTypeID=?");
if (!$stmtCode) { 
    echo json_encode(['success'=>false,'message'=>'خطأ في قاعدة البيانات: '.$conn->error]);
    exit;
    }
$stmtCode->bind_param("i", $formId);
$stmtCode->execute();
$formInfo = $stmtCode->get_result()->fetch_assoc();
$formCode = $formInfo['Code'] ?? '';

// دالة مساعدة: جلب قيمة حقل من FormValues
// getFieldValue($conn, $submissionId, $fieldName): Retrieve latest value for a named field.
// Purpose: helper to lookup a field's most recent saved value by FieldName.
// Used in: special-case logic in approval flows (e.g., committee decisions).
function getFieldValue($conn, $submissionId, $fieldName) {
    //s4
    $stmt = $conn->prepare("
        SELECT fv.FieldValue FROM FormValues fv
        JOIN FormFields ff ON ff.FieldID = fv.FieldID
        WHERE fv.SubmissionID=? AND ff.FieldName=?
        ORDER BY fv.EnteredAt DESC LIMIT 1
    ");
    if (!$stmt)
        return null;
    $stmt->bind_param("is", $submissionId, $fieldName);
    $stmt->execute();
    $row = $stmt->get_result()->fetch_assoc();
    return $row['FieldValue'] ?? null;
}

// ══════════════════════════════════════
// بداية Transaction لضمان تكامل البيانات
// ══════════════════════════════════════
$conn->begin_transaction();
$msg = '';

try {

// ════════════════════════════════════════════════════════
// APPROVE خيار الموافقة
// ════════════════════════════════════════════════════════
if ($action === 'approve') {
    // المتغيرات الافتراضية لكل الحالات
    $isFormDone = false;
    $nextStepId = $stepId;
    $newStatus  = 'InProgress';
    ///////////////////////////////////////////////
    ///////////////////////////////////////////////
    // الحالات الخاصة
    // ── تكرار (720) ──
    if ($maxRepeats > 1) {
        if ($repeatNumber < $maxRepeats) {
            $newStatus  = 'Approved';
            $isFormDone = false;
        } else {
            [$nextStepId, $isFormDone, $newStatus] = _getNextStep($conn, $formId, $currentOrder, $stepId);
        }
    //---------------------------------
    // ── نموذج 707: قرار عميد الكلية ──
    } elseif ($formCode === '707' && $currentOrder === 2) {
        [$nextStepId, $isFormDone, $newStatus] = _getNextStep($conn, $formId, $currentOrder, $stepId);
    //-------------------------------------
    // ── نموذج 707: قرار لجنة الدراسات العليا ──
    } elseif ($formCode === '707' && $currentOrder === 3) {
        $committeeDecision = getFieldValue($conn, $submissionId, 'committee_decision');

        if ($committeeDecision === 'اعتماد التقارير ومتابعة عقد المناقشة') {
            $newStatus  = 'Approved';
            $isFormDone = true;
        }
        
        elseif ($committeeDecision === 'تعيين مقيّم ثالث مرجّح (تضارب التوصيات)') {
            $newStatus  = 'Approved';
            $isFormDone = false;
            //s5
            $stmt705 = $conn->prepare("
                SELECT ft.FormTypeID, fws.StepID
                FROM FormTypes ft
                JOIN FormWorkflowSteps fws ON fws.FormTypeID=ft.FormTypeID AND fws.StepOrder=1
                WHERE ft.Code='705' LIMIT 1
            ");
            if (!$stmt705) 
                throw new Exception('خطأ في إعداد الاستعلام: '.$conn->error);
            $stmt705->execute();
            $form705 = $stmt705->get_result()->fetch_assoc();
            // إذا وجدنا نموذج 705 و لدينا رقم الطالب، ننشئ 
            //submission جديد للتكرار التالي من 705
            if ($form705 && $studentId) {
                //s6
                $stmtRepeat = $conn->prepare("
                    SELECT MAX(RepeatNumber) AS maxRep FROM FormSubmissions
                    WHERE FormTypeID=? AND StudentID=?
                ");
                if (!$stmtRepeat) 
                    throw new Exception('خطأ في إعداد الاستعلام: '.$conn->error);
                
                $stmtRepeat->bind_param("ii", $form705['FormTypeID'], $studentId);
                $stmtRepeat->execute();
                $repRow     = $stmtRepeat->get_result()->fetch_assoc();
                $nextRepeat = ($repRow['maxRep'] ?? 0) + 1;// رقم التكرار التالي لنموذج 705 لهذا الطالب,ان لم يوجد نبدأ من 1
                //s7
                $stmtNewSub = $conn->prepare("
                    INSERT INTO FormSubmissions
                        (FormTypeID,CurrentStepID,CreatedBy,StudentID,ThesisID,Status,RepeatNumber)
                    VALUES (?,?,?,?,?,'InProgress',?)
                ");
                if (!$stmtNewSub) 
                    throw new Exception('خطأ في إعداد الاستعلام: '.$conn->error);
                $stmtNewSub->bind_param("iiiiii",$form705['FormTypeID'], $form705['StepID'],$userId, $studentId, $thesisId, $nextRepeat);
                $stmtNewSub->execute();
                _sendNotification($conn, $userId,
                    'قررت لجنة الدراسات العليا تعيين مقيّم ثالث — يرجى اختيار الممتحن البديل في نموذج 705.',
                    'FormApproved', $submissionId, 'ProgramCoordinator', $studentId);
            }
        } 
        
        elseif ($committeeDecision === 'قرار رسوب الطالب في رسالة الماجستير (مفصول من البرنامج)') {
            $newStatus  = 'Rejected';
            $isFormDone = false;
            if ($studentId) {
                //s8
                $stmtDelProg = $conn->prepare("DELETE FROM StudentProgress WHERE StudentNumber=?");
                if (!$stmtDelProg) 
                    throw new Exception('خطأ في إعداد الاستعلام: '.$conn->error);
                $stmtDelProg->bind_param("i", $studentId);
                $stmtDelProg->execute();
                _sendNotification($conn, $userId,
                    'نأسف لإبلاغك بأن لجنة الدراسات العليا قررت رسوبك في رسالة الماجستير وفصلك من البرنامج.',
                    'FormRejected', $submissionId, 'Student', $studentId);
            }
        }
        // غير ذلك (مثل "تأجيل القرار" أو "طلب معلومات إضافية") نعتبر النموذج مكتمل لكن مع حالة خاصة، ولا نتقدم للخطوة التالية
        else {
            [$nextStepId, $isFormDone, $newStatus] = _getNextStep($conn, $formId, $currentOrder, $stepId);
        }
    // الحالات الخاصة من التسلسل نهاية، نستخدم المنطق العادي لتحديد الخطوة التالية أو اكتمال النموذج
    ///////////////////////////////////////////////
    ///////////////////////////////////////////////
    // ── الحالة العادية ──
    } else {
        [$nextStepId, $isFormDone, $newStatus] = _getNextStep($conn, $formId, $currentOrder, $stepId);
    }

    // تحديث الطلب
    // إذا لم يكن الرفض الخاص بلجنة الدراسات العليا، نحدث الحالة والخطوة التالية
    if ($newStatus !== 'Rejected') {
        //s9
        $stmtUpd = $conn->prepare("UPDATE FormSubmissions SET CurrentStepID=?,Status=? WHERE SubmissionID=?");
        if (!$stmtUpd) 
            throw new Exception('خطأ في إعداد الاستعلام: '.$conn->error);
        $stmtUpd->bind_param("isi", $nextStepId, $newStatus, $submissionId);
        $stmtUpd->execute();
    } else {
        //s10
        $stmtUpd = $conn->prepare("UPDATE FormSubmissions SET Status='Rejected' WHERE SubmissionID=?");
        if (!$stmtUpd) throw new Exception('خطأ في إعداد الاستعلام: '.$conn->error);
        $stmtUpd->bind_param("i", $submissionId);
        $stmtUpd->execute();
    }

    // ── نموذج 720: إنشاء submission للتكرار التالي ──
    //تكملة للحالة الخاصة بالتكرار، إذا لم نصل للحد الأقصى للتكرار بعد، ننشئ 
    //submission جديد للتكرار التالي بنفس الخطوة الأولى من النموذج
    if ($maxRepeats > 1 && !$isFormDone && $repeatNumber < $maxRepeats && $studentId) {
        $nextRepeat = $repeatNumber + 1;
        //s11
        $stmtFS    = $conn->prepare("
            SELECT StepID FROM FormWorkflowSteps WHERE FormTypeID=? AND StepOrder=1 LIMIT 1
        ");
        if (!$stmtFS) 
            throw new Exception('خطأ في إعداد الاستعلام: '.$conn->error);
        $stmtFS->bind_param("i", $formId);
        $stmtFS->execute();
        $firstStep = $stmtFS->get_result()->fetch_assoc();
        if ($firstStep) {
            //s12
            $stmtNS = $conn->prepare("
                INSERT INTO FormSubmissions
                    (FormTypeID,CurrentStepID,CreatedBy,StudentID,ThesisID,Status,RepeatNumber)
                VALUES (?,?,?,?,?,'InProgress',?)
            ");
            if (!$stmtNS) 
                throw new Exception('خطأ في إعداد الاستعلام: '.$conn->error);
            $stmtNS->bind_param("iiiiii",
                $formId, $firstStep['StepID'], $userId, $studentId, $thesisId, $nextRepeat);
            $stmtNS->execute();
        }
        // نسجل التقدم في StudentProgress لكل تكرار يتم إنشاؤه
        _recordProgress($conn, $studentId, $formId, $submissionId, $thesisId, $repeatNumber);
        _sendNotification($conn, $userId,
            'يمكنك الآن تعبئة اللقاء رقم ' . $nextRepeat . ' من نموذج ' . $formCode,
            'FormApproved', $submissionId, $stepInfo['AllowedRole'], $studentId);
    }

    // ── اكتمال النموذج ──
    if ($isFormDone && $studentId) {
        _recordProgress($conn, $studentId, $formId, $submissionId, $thesisId, $repeatNumber);
        _notifyNextForm($conn, $userId, $formId, $formCode, $submissionId,
                        $studentId, $thesisId, $examinerType, $examinerEmployeeId);
        //بحال كنا نعبئ بنموذج 700 (اعتماد نهائي)، نولد رقم جامعي تلقائياً إذا لم يكن موجود
        // ── نموذج 700: توليد الرقم الجامعي تلقائياً عند الاعتماد النهائي ──
        if ($formCode === '700') {
            // نتحقق أن الطالب لا يملك رقماً جامعياً بعد
            //s13
            $stmtCheck = $conn->prepare("SELECT UniversityID FROM Students WHERE StudentNumber=?");
            if (!$stmtCheck) 
                throw new Exception('خطأ: '.$conn->error);
            $stmtCheck->bind_param("i", $studentId);
            $stmtCheck->execute();
            $checkRow = $stmtCheck->get_result()->fetch_assoc();
            // إذا لم يكن لديه رقم جامعي، نولده
            if (empty($checkRow['UniversityID'])) {
                // نجلب أعلى رقم جامعي موجود ونزيد عليه 1
                // إذا لم يوجد أحد نبدأ من 1001
                //s14
                $stmtMax = $conn->prepare("
                    SELECT MAX(CAST(UniversityID AS UNSIGNED)) AS maxID
                    FROM Students
                    WHERE UniversityID IS NOT NULL AND UniversityID != ''
                ");
                if (!$stmtMax) 
                    throw new Exception('خطأ: '.$conn->error);
                $stmtMax->execute();
                $maxRow      = $stmtMax->get_result()->fetch_assoc();
                $newUID      = max(1001, ($maxRow['maxID'] ?? 1000) + 1);
                $newUIDStr   = (string)$newUID;
                //s15
                $stmtUID = $conn->prepare("UPDATE Students SET UniversityID=? WHERE StudentNumber=?");
                if (!$stmtUID) 
                    throw new Exception('خطأ: '.$conn->error);
                $stmtUID->bind_param("si", $newUIDStr, $studentId);
                $stmtUID->execute();
                // إشعار الطالب برقمه الجامعي الجديد
                _sendNotification($conn, $userId,
                    'تهانينا! تم قبولك في البرنامج. رقمك الجامعي هو: ' . $newUIDStr,
                    'FormApproved', $submissionId, 'Student', $studentId);
            }
        }
    }
    // رسالة عامة للنجاح، يمكن تخصيصها حسب الحاجة
    // إذا كان النموذج اكتمل، نخبر المستخدم أن الطلب تم الموافقة النهائية عليه، وإلا نخبره أنه تمت الموافقة وينتقل للخطوة التالية
    $msg = $isFormDone
         ? 'تمت الموافقة النهائية على الطلب.'
         : 'تمت الموافقة، انتقل للخطوة التالية.';

// ════════════════════════════════════════════════════════════════════════════════════════════════════════════════
// REJECT خيار الرفض
// ════════════════════════════════════════════════════════════════════════════════════════════════════════════════
} elseif ($action === 'reject') {
    // الحالات الخاصة
    // نموذج 706: ممتحن رفض الامتحان → يعود لـ 705 لتعيين بديل
    if ($formCode === '706' && $examinerType && $studentId) {
        //s16
        $stmtUpd = $conn->prepare("UPDATE FormSubmissions SET Status='Rejected' WHERE SubmissionID=?");
        if (!$stmtUpd) throw new Exception('خطأ في إعداد الاستعلام: '.$conn->error);
        $stmtUpd->bind_param("i", $submissionId);
        $stmtUpd->execute();
        //s17
        // جلب بيانات نموذج 705 (تعيين ممتحن بديل) للخطوة الأولى
        $stmt705 = $conn->prepare("
            SELECT ft.FormTypeID, fws.StepID FROM FormTypes ft
            JOIN FormWorkflowSteps fws ON fws.FormTypeID=ft.FormTypeID AND fws.StepOrder=1
            WHERE ft.Code='705' LIMIT 1
        ");
        if (!$stmt705) 
            throw new Exception('خطأ في إعداد الاستعلام: '.$conn->error);
        $stmt705->execute();
        $form705 = $stmt705->get_result()->fetch_assoc();
        // إذا وجدنا نموذج 705، ننشئ 
        //submission جديد للتكرار التالي من 705 لتعيين ممتحن بديل
        if ($form705) {
            //s18
            $stmtRepeat = $conn->prepare("
                SELECT MAX(RepeatNumber) AS maxRep FROM FormSubmissions
                WHERE FormTypeID=? AND StudentID=?
            ");
            
            if (!$stmtRepeat) 
                throw new Exception('خطأ في إعداد الاستعلام: '.$conn->error);
            $stmtRepeat->bind_param("ii", $form705['FormTypeID'], $studentId);
            $stmtRepeat->execute();
            $repRow     = $stmtRepeat->get_result()->fetch_assoc();
            $nextRepeat = ($repRow['maxRep'] ?? 0) + 1;
            //s19
            $stmtNS = $conn->prepare("
                INSERT INTO FormSubmissions
                    (FormTypeID,CurrentStepID,CreatedBy,StudentID,ThesisID,Status,RepeatNumber)
                VALUES (?,?,?,?,?,'InProgress',?)
            ");
            if (!$stmtNS)
                throw new Exception('خطأ في إعداد الاستعلام: '.$conn->error);
            $stmtNS->bind_param("iiiiii",$form705['FormTypeID'], $form705['StepID'],$userId, $studentId, $thesisId, $nextRepeat);
            $stmtNS->execute();

            _sendNotification($conn, $userId, 
            'رفض الممتحن ' . ($examinerType === 'Internal' ? 'الداخلي' : 'الخارجي') .' المشاركة في الامتحان — يرجى تعيين ممتحن بديل في نموذج 705.',
                'FormReturned', $submissionId, 'ProgramCoordinator', $studentId);
        }
        $msg = 'تم تسجيل رفض الممتحن وإعادة فتح نموذج 705 لتعيين بديل.';
    
    } else {
        // رفض عادي
        //s20
        $stmtUpd = $conn->prepare("UPDATE FormSubmissions SET Status='Rejected' WHERE SubmissionID=?");
        if (!$stmtUpd) throw new Exception('خطأ في إعداد الاستعلام: '.$conn->error);
        $stmtUpd->bind_param("i", $submissionId);
        $stmtUpd->execute();

        if ($studentId) {
            _sendNotification($conn, $userId,
                'تم رفض طلبك في نموذج ' . $formCode . ($notes ? ' — ' . $notes : ''),
                'FormRejected', $submissionId, 'Student', $studentId);
        }
        $msg = 'تم رفض الطلب.';
    }

// ═════════════════════════════════════════════════════════════════════════════════════════════════════════════════
// RETURN — خطوة واحدة للخلف فقط
// ═════════════════════════════════════════════════════════════════════════════════════════════════════════════════
} elseif ($action === 'return') {

    $prevOrder = max(1, $currentOrder - 1);
    //s21
    $stmtPrev  = $conn->prepare("
        SELECT StepID, AllowedRole FROM FormWorkflowSteps
        WHERE FormTypeID=? AND StepOrder=? LIMIT 1
    ");
    if (!$stmtPrev)
        throw new Exception('خطأ في إعداد الاستعلام: '.$conn->error);
    $stmtPrev->bind_param("ii", $formId, $prevOrder);
    $stmtPrev->execute();
    $prev = $stmtPrev->get_result()->fetch_assoc();

    $prevStepId     = $prev['StepID']      ?? $stepId;
    $prevRole       = $prev['AllowedRole'] ?? '';
    $returnedToStep = $prevStepId;
    // تحديث الطلب ليعود للخطوة السابقة مع حالة "Returned"
    //s22
    $stmtUpd = $conn->prepare("
        UPDATE FormSubmissions SET CurrentStepID=?,Status='Returned' WHERE SubmissionID=?
    ");
    if (!$stmtUpd)
        throw new Exception('خطأ في إعداد الاستعلام: '.$conn->error);
    $stmtUpd->bind_param("ii", $prevStepId, $submissionId);
    $stmtUpd->execute();

    if ($studentId) {
        _sendNotification($conn, $userId,
            'تم إرجاع طلبك في نموذج ' . $formCode .
            ' للتعديل.' . ($notes ? ' ملاحظة: ' . $notes : ''),
            'FormReturned', $submissionId, $prevRole, $studentId);
    }
    $msg = 'تم إرجاع الطلب للتعديل.';
}

// ── حفظ قيم الحقول الخاصة بهذه الخطوة ──
// نتوقع أن القيم تأتي كـ JSON في حقل 
//"values" في POST، وهي مصفوفة من الكائنات التي تحتوي على fieldId و value
$values = json_decode($_POST['values'] ?? '[]', true);
if (!is_array($values)) 
    $values = [];

if (!empty($values)) {
    // جلب أسماء حقول الملفات لبناء اسم الملف المنظم
    // نحاول جلب أسماء الحقول دفعة واحدة لتقليل الاستعلامات داخل اللوب
    // نحضر قائمة بالـ fieldIds من القيم المرسلة، ثم نستخدم IN في الاستعلام لجلب أسماء هذه الحقول مرة واحدة
    $fieldNamesMap = [];
    $fieldIds = array_filter(array_map(fn($f) => (int)($f['fieldId'] ?? 0), $values));
    if ($fieldIds) {
        // بناء جملة placeholders و types للدوال المحضرة
        //implode تستخدم لإنشاء سلسلة من علامات الاستفهام مفصولة بفواصل بناءً على عدد الحقول، وstr_repeat
        // لإنشاء سلسلة من 'i' بنفس الطول لتمثل نوع كل معلمة في bind_param
        $placeholders = implode(',', array_fill(0, count($fieldIds), '?'));
        $types        = str_repeat('i', count($fieldIds));
        //s23
        $stmtFN = $conn->prepare("SELECT FieldID, FieldName FROM FormFields WHERE FieldID IN ($placeholders)");
        if ($stmtFN) {
            //... تستخدم لتفكيك مصفوفة fieldIds إلى معلمات منفصلة لbind_param
            //وهي ميزة في PHP 5.6
            //وما بعدها تسمح بتمرير مصفوفة كوسيطات منفصلة إلى دوال مثل bind_param
            $stmtFN->bind_param($types, ...$fieldIds);
            $stmtFN->execute();
            foreach ($stmtFN->get_result()->fetch_all(MYSQLI_ASSOC) as $fnRow) {

                $fieldNamesMap[$fnRow['FieldID']] = $fnRow['FieldName'];
            }
        }
    }

    // مسار رفع الملفات
    //DIR هو مسار ثابت يشير إلى مجلد المشروع الحالي، نستخدمه لبناء مسار منظم لرفع الملفات داخل مجلد uploads
    $selfDir     = __DIR__;
    $parentDir   = dirname($selfDir);
    $projectRoot = is_dir($parentDir . '/uploads') ? $parentDir : $selfDir;
    $uploadDir   = $projectRoot . '/uploads/forms/' . $formId . '/' . $submissionId . '/';
    if (!is_dir($uploadDir)) mkdir($uploadDir, 0755, true);
    // معالجة كل حقل من الحقول المرسلة
    foreach ($values as $field) {
        $fieldId = (int)($field['fieldId'] ?? 0);
        if (!$fieldId) 
            continue;
        $value = $field['value'] ?? '';
        // جلب الملف القديم لحذفه عند الاستبدال
        //s24
        // نحضر استعلاماً محضراً خارج اللوب لجلب القيمة القديمة لأي حقل من نوع ملف، لتقليل الاستعلامات داخل اللوب
        //كيف سيعرف ان الحقل من نوع ملف؟
        // نفترض أن الحقول من نوع ملف لها أسماء معينة أو يمكننا جلب نوع الحقل من قاعدة البيانات إذا كان ذلك ضرورياً
        // في هذا المثال، سنفترض أن الحقول من نوع ملف تحتوي على 
        //"file" في اسمها، ونستخدم fieldNamesMap للتحقق من ذلك
        $stmtOld = $conn->prepare("SELECT FieldValue FROM FormValues WHERE SubmissionID=? AND FieldID=? AND StepID=?");
        // إذا كان الحقل من نوع ملف، نحتاج لجلب القيمة القديمة (اسم الملف) لحذفه بعد رفع الملف الجديد
        if ($stmtOld) {
            $stmtOld->bind_param("iii", $submissionId, $fieldId, $stepId);
            $stmtOld->execute();
            $oldRow = $stmtOld->get_result()->fetch_assoc();
        } else {
            $oldRow = null;
        }
        // رفع الملف الجديد إن وجد
        //ان وجد ان الملف تم رفعه مرة أخرى في هذا الحقل الذي عنوانه $_FILES[$fieldId]
        //، نرفع الملف الجديد ونحذف القديم
        if (isset($_FILES[$fieldId]) && $_FILES[$fieldId]['error'] === 0) {
            $originalName = basename($_FILES[$fieldId]['name']);
            $ext          = strtolower(pathinfo($originalName, PATHINFO_EXTENSION));
            $fieldName    = preg_replace('/[^a-zA-Z0-9_\-]/',
            '_', 
            $fieldNamesMap[$fieldId] ?? ('field_'.$fieldId));
            $fileName     = $fieldName . '_' . $formCode . '_' . $submissionId . '_' . $stepId . '.' . $ext;
            if (move_uploaded_file($_FILES[$fieldId]['tmp_name'], $uploadDir . $fileName)) {
                // حذف الملف القديم
                if ($oldRow && $oldRow['FieldValue'] && is_file($uploadDir . $oldRow['FieldValue'])) {
                    unlink($uploadDir . $oldRow['FieldValue']);
                }
                $value = $fileName;
            }
        }

        // حفظ القيمة في FormValues
        //s25
        $stmtDel = $conn->prepare("DELETE FROM FormValues WHERE SubmissionID=? AND FieldID=? AND StepID=?");
        if (!$stmtDel) 
            throw new Exception('خطأ في إعداد الاستعلام: '.$conn->error);
        $stmtDel->bind_param("iii", $submissionId, $fieldId, $stepId);
        $stmtDel->execute();
        //s26
        $stmtIns = $conn->prepare("INSERT INTO FormValues (SubmissionID,FieldID,StepID,FieldValue) VALUES(?,?,?,?)");
        if (!$stmtIns) 
            throw new Exception('خطأ في إعداد الاستعلام: '.$conn->error);
        $stmtIns->bind_param("iiis", $submissionId, $fieldId, $stepId, $value);
        $stmtIns->execute();
        //وهكذا لجميع الحقول بكل انواعها,بغض النظر ان كانت العملية ادخال بيانات جديدة او تعديل بيانات موجودة او رفع ملف جديد واستبدال ملف قديم,كلها ستعالج في هذا الجزء من الكود بشكل متكامل.
    }
}

// ── تسجيل في التاريخ ──
$actionMap = ['approve'=>'Approved','reject'=>'Rejected','return'=>'Returned'];
//s27
$stmtHist  = $conn->prepare("
    INSERT INTO FormWorkflowHistory
        (SubmissionID,StepID,Action,Notes,ActedBy,ReturnedToStepID)
    VALUES (?,?,?,?,?,?)
");
if (!$stmtHist) 
    throw new Exception('خطأ في إعداد الاستعلام: '.$conn->error);
$stmtHist->bind_param("iissii",
    $submissionId, $stepId, $actionMap[$action], $notes, $userId, $returnedToStep);
$stmtHist->execute();

$conn->commit();// إذا وصلنا هنا بدون استثناء، نثبت التغييرات
//--------------------------------------------------
// في حال حدوث أي استثناء، نلغي كل التغييرات التي تمت في هذا الإجراء ونرسل رسالة الخطأ
} catch (Exception $e) {
    $conn->rollback();
    echo json_encode(['success'=>false,'message'=>'حدث خطأ: '.$e->getMessage()]); exit;
}
// في النهاية، نرسل رسالة النجاح إلى الواجهة الأمامية
echo json_encode(['success'=>true,'message'=>$msg]);

// ════════════════════════════════════════════════════════
// دوال مساعدة
// ════════════════════════════════════════════════════════

// _getNextStep(...): Determine the next workflow step or mark the form as done.
// Returns: [nextStepId, isFormDone(bool), newStatus]
// Used in: approval/rejection/return flows to advance submissions.
function _getNextStep($conn, $formId, $currentOrder, $currentStepId = 0) {
    $nextOrder = $currentOrder + 1;
    //s28
    $stmt = $conn->prepare("
        SELECT StepID FROM FormWorkflowSteps
        WHERE FormTypeID=? AND StepOrder=?
    ");
    //اذا لم نجد خطوة تالية، نعتبر النموذج مكتمل ونبقي نفس الـ StepID الحالي (لأغراض السجلات والتاريخ) مع تغيير الحالة إلى Approved
    if (!$stmt) 
        return [$currentStepId, true, 'Approved'];

    $stmt->bind_param("ii", $formId, $nextOrder);
    $stmt->execute();
    $next = $stmt->get_result()->fetch_assoc();
    if ($next) 
        return [$next['StepID'], false, 'InProgress'];
    // آخر خطوة: نبقي نفس الـ 
    //StepID الحالي بدل 0
    return [$currentStepId, true, 'Approved'];
}

// _recordProgress(...): Insert or update StudentProgress when relevant events occur.
// Purpose: track completed forms/meetings per student.
// Used in: after creating next repeat or on final approval.
function _recordProgress($conn, $studentId, $formId, $submissionId, $thesisId, $repeatNumber) {
    //s29
    $stmt = $conn->prepare("
        INSERT INTO StudentProgress
            (StudentNumber,FormTypeID,SubmissionID,ThesisID,RepeatNumber)
        VALUES (?,?,?,?,?)
        ON DUPLICATE KEY UPDATE
            SubmissionID=VALUES(SubmissionID),
            ThesisID=VALUES(ThesisID),
            CompletedAt=CURRENT_TIMESTAMP
    ");
    if (!$stmt) 
        return;
    $stmt->bind_param("iiiii", $studentId, $formId, $submissionId, $thesisId, $repeatNumber);
    $stmt->execute();
}

// _notifyNextForm(...): Create the next submission (if needed) and notify responsible users.
// Purpose: chain workflows and send notifications when a form completes.
// Used in: when a workflow reaches a state that should trigger the next form.
function _notifyNextForm($conn, $userId, $formId, $formCode, $submissionId,
                         $studentId, $thesisId, $examinerType, $examinerEmployeeId) {
    $stmtD = $conn->prepare("SELECT DisplayOrder FROM FormTypes WHERE FormTypeID=?");
    // إذا لم نجد النموذج الحالي، لا نكمل العملية
    // هذا تحقق أمان إضافي، لأنه من المفترض أن النموذج موجود أصلاً في بداية العملية، لكننا نتحقق مرة أخرى قبل محاولة جلب النموذج التالي
    //وكيف يتم هذا قبل تنفيذ الامر ؟
    //باختصار في حالة وجود خطأ في قاعدة البيانات أو تم حذف النموذج من قاعدة البيانات بعد بدء العملية، هذا التحقق يمنع حدوث أخطاء لاحقة في الكود الذي يعتمد على وجود النموذج الحالي.
    //يعني هو تحقق اضافي ويمكن ازالته اذا كنا واثقين من سلامة البيانات، لكن وجوده لا يضر ويضيف طبقة حماية ضد الحالات غير المتوقعة.
    if (!$stmtD)
        return;
    $stmtD->bind_param("i", $formId);
    $stmtD->execute();
    $disp = $stmtD->get_result()->fetch_assoc();
    // إذا لم نجد ترتيب العرض للنموذج الحالي، لا نكمل العملية
    if (!$disp)
        return;
    //s30
    $stmtNF = $conn->prepare("
        SELECT FormTypeID,Code,Name FROM FormTypes
        WHERE DisplayOrder>? ORDER BY DisplayOrder ASC LIMIT 1
    ");
    // إذا لم نجد نموذج تالي، لا نكمل العملية   
    if (!$stmtNF)
        return;
    $stmtNF->bind_param("i", $disp['DisplayOrder']);
    $stmtNF->execute();
    $nextForm = $stmtNF->get_result()->fetch_assoc();
    // إذا لم نجد النموذج التالي، لا نكمل العملية
    if (!$nextForm)
        return;
    //s31
    $stmtFS = $conn->prepare("
        SELECT StepID,AllowedRole FROM FormWorkflowSteps
        WHERE FormTypeID=? AND StepOrder=1 LIMIT 1
    ");
    if (!$stmtFS)
        return;
    $stmtFS->bind_param("i", $nextForm['FormTypeID']);
    $stmtFS->execute();
    $firstStep = $stmtFS->get_result()->fetch_assoc();
    if (!$firstStep)
        return;
    //بعد ان يرجع ويتاكد من وجود كل المعلومات اللازمة مثل النموذج وتريبه والى اخره
    //يقوم بإنشاء submission جديد للنموذج التالي إذا كان النموذج التالي لا يستهدف الطلاب فقط (مثل نموذج إداري) أو إذا كان يستهدف الطلاب ولدينا رقم الطالب، لأننا نحتاج لربط submission بالطالب في هذه الحالة
    if ($firstStep['AllowedRole'] !== 'Student' && $studentId) {
            //s32
        $stmtNewSub = $conn->prepare("
            INSERT INTO FormSubmissions
                (FormTypeID,CurrentStepID,CreatedBy,StudentID,ThesisID,
                 Status,RepeatNumber,ExaminerType,ExaminerEmployeeID)
            VALUES (?,?,?,?,?,'InProgress',1,?,?)
        ");
        //ويقوم بعدها في الحالات الخاصة بتعيين ممتحنين 
        //حالات خاصة مثل نموذج 705 و706 و 707
        if (!$stmtNewSub) 
            return;
        $stmtNewSub->bind_param("iiiiisi",
            $nextForm['FormTypeID'], $firstStep['StepID'],
            $userId, $studentId, $thesisId,
            $examinerType, $examinerEmployeeId);
        $stmtNewSub->execute();
    }

    $notifMsg = 'تم اعتماد نموذج ' . $formCode . '، يمكنك الآن البدء في نموذج '
              . $nextForm['Code'] . ' — ' . $nextForm['Name'];

    _sendNotification($conn, $userId, $notifMsg, 'FormApproved',
                      $submissionId, $firstStep['AllowedRole'], $studentId);
}

// _sendNotification(...): Insert a notification row and attach it to users.
// Purpose: generic notifier for student/role-based messages used across the app.
// Used in: many places (saveForm, actionForm, notify flows) to inform users.
function _sendNotification($conn, $senderId, $msg, $type, $submissionId, $role, $studentId) {
        //s33
    $stmtN = $conn->prepare("
        INSERT INTO Notifications (SenderID,Message,Type,RelatedSubmissionID) VALUES(?,?,?,?)
    ");
    if (!$stmtN) 
        return;
    $stmtN->bind_param("issi", $senderId, $msg, $type, $submissionId);
    $stmtN->execute();
    $notifId = $stmtN->insert_id;
// إذا كان الإشعار موجه لطلاب ولدينا رقم الطالب، نرسل الإشعار للطالب فقط
    if ($role === 'Student' && $studentId) {
        //s34
        $stmtU = $conn->prepare("SELECT UserID FROM Students WHERE StudentNumber=?");
        if (!$stmtU) return;
        $stmtU->bind_param("i", $studentId);
        $stmtU->execute();
        $u = $stmtU->get_result()->fetch_assoc();
        if ($u) {
            //s35
            $stmtNT = $conn->prepare("INSERT INTO NotificationTo (NotificationID,UserID) VALUES(?,?)");
            if (!$stmtNT) return;
            $stmtNT->bind_param("ii", $notifId, $u['UserID']);
            $stmtNT->execute();
        }
    } 
// أما إذا كان الإشعار موجه لدور معين (مثل "ProgramCoordinator" أو "Examiner")، نرسل الإشعار لكل المستخدمين الذين لديهم هذا الدور
    else {
        //s36
        $stmtR = $conn->prepare("
            SELECT e.UserID FROM Employees e
            JOIN Employee_Roles er ON er.EmployeeNumber=e.EmployeeNumber
            WHERE er.Role=?
        ");
        if (!$stmtR) return;
        $stmtR->bind_param("s", $role);
        $stmtR->execute();
        $users = $stmtR->get_result()->fetch_all(MYSQLI_ASSOC);
        foreach ($users as $u) {
            //s37
            $stmtNT = $conn->prepare("INSERT INTO NotificationTo (NotificationID,UserID) VALUES(?,?)");
            if (!$stmtNT)
                continue;
            $stmtNT->bind_param("ii", $notifId, $u['UserID']);
            $stmtNT->execute();
        }
    }
}
