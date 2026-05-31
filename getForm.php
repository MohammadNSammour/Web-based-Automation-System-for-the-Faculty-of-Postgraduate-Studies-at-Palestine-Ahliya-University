<?php
// ════════════════════════════════════════════════════════
// api/getForm.php — جلب بيانات النموذج كاملاً
// متوافق مع Database_NEW.sql (بدون Programs/Sections/Departments)
// ════════════════════════════════════════════════════════
session_start();
require_once 'db.php';
header('Content-Type: application/json');

checkSessionTimeout();

if (!isset($_SESSION['user_id'])) {
    echo json_encode(['error'=>'غير مصرح']); exit;
}

$formId       = isset($_GET['formId'])       ? (int)$_GET['formId']       : 0;
$stepId       = isset($_GET['stepId'])       ? (int)$_GET['stepId']       : 0;
$submissionId = isset($_GET['submissionId']) ? (int)$_GET['submissionId'] : 0;
$userId       = $_SESSION['user_id'];
$currentRole  = $_SESSION['current_role'];
//////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////
// ── معلومات النموذج ──
//s50
$stmt = $conn->prepare("SELECT * FROM FormTypes WHERE FormTypeID = ?");
if (!$stmt) { echo json_encode(['error'=>'خطأ في قاعدة البيانات: '.$conn->error]); exit; }
$stmt->bind_param("i", $formId);
$stmt->execute();
$formInfo = $stmt->get_result()->fetch_assoc();
if (!$formInfo) { echo json_encode(['error'=>'النموذج غير موجود']); exit; }
//////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////
// ── الخطوة الحالية والتحقق من الصلاحية ──
//s51
$stmt = $conn->prepare("SELECT StepID, StepOrder, AllowedRole FROM FormWorkflowSteps WHERE StepID = ?");
if (!$stmt) { echo json_encode(['error'=>'خطأ في قاعدة البيانات: '.$conn->error]); exit; }
$stmt->bind_param("i", $stepId);
$stmt->execute();
$currentStepInfo = $stmt->get_result()->fetch_assoc();

if (!$currentStepInfo) { echo json_encode(['error'=>'الخطوة غير موجودة']); exit; }

$currentStepOrder = $currentStepInfo['StepOrder'];
if ($currentStepInfo['AllowedRole'] !== $currentRole) {
    echo json_encode(['error'=>'ليس لديك صلاحية للوصول إلى هذه الخطوة.']); exit;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////
// ── التحقق من ملكية الطلب للطالب ──
if ($submissionId && $currentRole === 'Student') {
    //s52
    $stmtCheck = $conn->prepare("SELECT StudentID FROM FormSubmissions WHERE SubmissionID = ?");
    if (!$stmtCheck) { echo json_encode(['error'=>'خطأ في قاعدة البيانات: '.$conn->error]); exit; }
    $stmtCheck->bind_param("i", $submissionId);
    $stmtCheck->execute();
    $subMatch = $stmtCheck->get_result()->fetch_assoc();
    if (!$subMatch) { echo json_encode(['error'=>'الطلب غير موجود']); exit; }

    $stmtStu = $conn->prepare("SELECT StudentNumber FROM Students WHERE UserID = ?");
    if (!$stmtStu) { echo json_encode(['error'=>'خطأ في قاعدة البيانات: '.$conn->error]); exit; }
    $stmtStu->bind_param("i", $userId);
    $stmtStu->execute();
    $studentRow = $stmtStu->get_result()->fetch_assoc();
    if (!$studentRow || $studentRow['StudentNumber'] != $subMatch['StudentID']) {
        echo json_encode(['error'=>'غير مسموح بالوصول لهذا الطلب']); exit;
    }
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////
// ── حقول الخطوة الحالية (قابلة للتحرير) ──
//s53
$stmt = $conn->prepare("
    SELECT ff.*, fs.SectionName, fs.SectionOrder,
           fws.AllowedRole, fws.StepOrder, fws.StepID
    FROM FormFields ff
    JOIN FormSections fs       ON fs.SectionID = ff.SectionID
    JOIN FormWorkflowSteps fws ON fws.StepID   = fs.StepID
    WHERE fws.StepID = ?
    ORDER BY fs.SectionOrder, ff.FieldOrder
");
$stmt->bind_param("i", $stepId);
$stmt->execute();
$currentFields = $stmt->get_result()->fetch_all(MYSQLI_ASSOC);
//////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////
// ── حقول الخطوات السابقة (للقراءة فقط) ──
$previousFields = [];
if ($submissionId && $currentStepOrder > 1) {
    //s54
    $stmt = $conn->prepare("
        SELECT ff.*, fs.SectionName, fs.SectionOrder,
               fws.AllowedRole, fws.StepOrder, fws.StepID
        FROM FormFields ff
        JOIN FormSections fs       ON fs.SectionID = ff.SectionID
        JOIN FormWorkflowSteps fws ON fws.StepID   = fs.StepID
        WHERE fws.FormTypeID = ? AND fws.StepOrder < ? AND fws.StepID != ?
        ORDER BY fws.StepOrder, fs.SectionOrder, ff.FieldOrder
    ");
    $stmt->bind_param("iii", $formId, $currentStepOrder, $stepId);
    $stmt->execute();
    $previousFields = $stmt->get_result()->fetch_all(MYSQLI_ASSOC);
    foreach ($previousFields as &$f) {
        $f['is_from_previous_step'] = true;
    }
    unset($f);
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////
// ── القيم المحفوظة ──
$saved         = [];
$previousSaved = [];
if ($submissionId) {
    //s55
    $stmt2 = $conn->prepare("SELECT FieldID, FieldValue FROM FormValues WHERE SubmissionID = ? AND StepID = ?");
    if (!$stmt2) { echo json_encode(['error'=>'خطأ في قاعدة البيانات: '.$conn->error]); exit; }
    $stmt2->bind_param("ii", $submissionId, $stepId);
    $stmt2->execute();
    $res = $stmt2->get_result();
    while ($row = $res->fetch_assoc()) {
        $saved[$row['FieldID']] = $row['FieldValue'];
    }

    if (!empty($previousFields)) {
        //s56
        $stmt2b = $conn->prepare("SELECT FieldID, FieldValue FROM FormValues WHERE SubmissionID = ? AND StepID != ?");
        if (!$stmt2b) { echo json_encode(['error'=>'خطأ في قاعدة البيانات: '.$conn->error]); exit; }
        $stmt2b->bind_param("ii", $submissionId, $stepId);
        $stmt2b->execute();
        $res = $stmt2b->get_result();
        while ($row = $res->fetch_assoc()) {
            $previousSaved[$row['FieldID']] = $row['FieldValue'];
        }
    }
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////
// ── بيانات الطالب للتعبئة التلقائية ──
// [MOD] متوافق مع Database_NEW: College/Department/Program في Users مباشرة
$studentData = [];
if ($submissionId) {
    //s57
    $stmt4 = $conn->prepare("
        SELECT s.StudentNumber, s.UniversityID, s.GPA,
               s.TotalCompletedHours, s.MajorJoinDate,
               s.EnrollmentSemester, s.EnrollmentYear,
               CONCAT(u.FirstName,' ',u.LastName) AS full_name,
               u.College, u.Department, u.Program,
               CONCAT(su.FirstName,' ',su.LastName) AS supervisor_name,
               t.ThesisTitle
        FROM FormSubmissions fs
        LEFT JOIN Students s   ON s.StudentNumber = fs.StudentID
        LEFT JOIN Users u      ON u.UserID         = s.UserID
        LEFT JOIN Employees e  ON e.EmployeeNumber = s.SupervisorID
        LEFT JOIN Users su     ON su.UserID        = e.UserID
        LEFT JOIN Thesis t     ON t.StudentNumber  = s.StudentNumber
        WHERE fs.SubmissionID = ?
        ORDER BY t.ThesisID DESC LIMIT 1
    ");
    $stmt4->bind_param("i", $submissionId);
    $stmt4->execute();
    $studentData = $stmt4->get_result()->fetch_assoc() ?? [];

} elseif ($currentRole === 'Student') {
    //s58
    $stmt4 = $conn->prepare("
        SELECT s.StudentNumber, s.UniversityID, s.GPA,
               s.TotalCompletedHours, s.MajorJoinDate,
               s.EnrollmentSemester, s.EnrollmentYear,
               CONCAT(u.FirstName,' ',u.LastName) AS full_name,
               u.College, u.Department, u.Program
        FROM Students s
        JOIN Users u ON u.UserID = s.UserID
        WHERE s.UserID = ?
    ");
    $stmt4->bind_param("i", $userId);
    $stmt4->execute();
    $studentData = $stmt4->get_result()->fetch_assoc() ?? [];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////
// ── القوائم الديناميكية — متوافقة مع Database_NEW ──
// fetchDynamicOptions($conn, $optStr): Parse a `__dynamic:` option string and
// return an array of {id,label} options pulled from the appropriate table.
// Purpose: support fields with dynamic option lists (Programs, Sections, etc.).
// Used in: when rendering fields in `getForm.php` server response for `form.js`.
function fetchDynamicOptions($conn, $optStr) {
    //from where this '__dynamic:' convention came? it's a simple way to indicate in the FieldOptions that the options should be fetched dynamically from the server, and the part after '__dynamic:' tells us which set of options to fetch. This allows us to have a flexible system where we can define dynamic option sources without hardcoding them in the frontend.
    //this itself '__dynamic:TableName|OtherInfo' where it is defined and from where it comes? it is defined in the database in the FormFields table, in the FieldOptions column for fields that require dynamic options. When we fetch the form structure in getForm.php, we check if FieldOptions starts with '__dynamic:', and if so, we call this fetchDynamicOptions function to get the actual options from the server before sending the form data to the frontend.
    //__dynamic:Programs.ProgramNumber:ProgramName for example would indicate that we want to fetch options for programs, where the id should be ProgramNumber and the label should be ProgramName. In our implementation, since we don't have a separate Programs table, we interpret 'Programs' as a request to fetch distinct program names from the Users table.
    $clean = str_replace('__dynamic:', '', explode('|', $optStr)[0]);
    $parts = explode(':', $clean);
    if (count($parts) < 2) return [];
    $table   = explode('.', $parts[0])[0];
    $options = [];

    switch ($table) {
        case 'Programs':
            //s59
            $res = $conn->query("
                SELECT DISTINCT u.Program AS id, u.Program AS label
                FROM Users u WHERE u.Program IS NOT NULL AND u.Program != ''
                ORDER BY u.Program
            ");
            break;


        case 'Sections':
            //s60
            $res = $conn->query("
                SELECT DISTINCT u.Department AS id, u.Department AS label
                FROM Users u WHERE u.Department IS NOT NULL AND u.Department != ''
                ORDER BY u.Department
            ");
            break;


        case 'Supervisors':
                        //s61
            $res = $conn->query("
                SELECT e.EmployeeNumber AS id,
                       CONCAT(u.FirstName,' ',u.LastName,' — ',COALESCE(e.AcademicRank,'')) AS label
                FROM Employees e
                JOIN Users u ON u.UserID = e.UserID
                WHERE e.IsSupervisor = 1 AND e.IsAvailable = 1
                ORDER BY u.FirstName
            ");

            break;

        case 'Employees':
            //s62
            $res = $conn->query("
                SELECT e.EmployeeNumber AS id,
                       CONCAT(u.FirstName,' ',u.LastName) AS label
                FROM Employees e
                JOIN Users u ON u.UserID = e.UserID
                JOIN Employee_Roles er ON er.EmployeeNumber = e.EmployeeNumber
                WHERE er.Role = 'Examiner'
                ORDER BY u.FirstName
            ");
            break;

        case 'Students':
            //s63
            $res = $conn->query("
                SELECT s.StudentNumber AS id,
                       CONCAT(u.FirstName,' ',u.LastName,' (',s.UniversityID,')') AS label
                FROM Students s
                JOIN Users u ON u.UserID = s.UserID
                ORDER BY u.FirstName
            ");
            break;

        default:
            return [];
    }

    if (!$res) return [];
    while ($row = $res->fetch_assoc()) { $options[] = $row; }
    return $options;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////
// ── التعبئة التلقائية  
// resolveAutoFill($dataSource, $studentData): Map a data-source key to a value.
// Purpose: provide automatic default values for fields (e.g., CURRENT_DATE, student info).
// Used in: `getForm.php` to populate `display_value` for fields before sending JSON.
//
function resolveAutoFill($dataSource, $studentData) {
    if (!$dataSource) return '';
    if ($dataSource === 'CURRENT_DATE') return date('Y-m-d');
            //map between the possible DataSource values(that come from the database like labels for this map) and the corresponding keys in the $studentData array. This allows us to easily fetch the correct value for a given DataSource when auto-filling fields.
            $map = [
        'Students.Users.full_name'                              => 'full_name',
        'Students.UniversityID'                                 => 'UniversityID',
        'Students.GPA'                                          => 'GPA',
        'Students.TotalCompletedHours'                          => 'TotalCompletedHours',
        'Students.MajorJoinDate'                                => 'MajorJoinDate',
        'Students.EnrollmentSemester'                           => 'EnrollmentSemester',
        'Students.EnrollmentYear'                               => 'EnrollmentYear',
        'Students.Programs.ProgramName'                         => 'Program',
        'Users.Program'                                         => 'Program',
        'Students.Programs.Sections.SectionName'                => 'Department',
        'Users.Department'                                      => 'Department',
        'Students.Programs.Sections.Departments.DepartmentName' => 'College',
        'Users.College'                                         => 'College',
        'Thesis.ThesisName'                                     => 'ThesisTitle',
        'Thesis.ThesisTitle'                                    => 'ThesisTitle',
        'Supervisors.Users.full_name'                           => 'supervisor_name',
        'Users.full_name'                                       => 'full_name',
    ];

    return $studentData[$map[$dataSource] ?? ''] ?? '';
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////
// ── معالجة حقول الخطوة الحالية ──
foreach ($currentFields as &$f) {
    $fid  = $f['FieldID'];
    $opts = $f['FieldOptions'] ?? '';
    $f['is_from_previous_step'] = false;

    if ($opts && strpos($opts, '__dynamic:') === 0) {
        $f['dynamic_options'] = fetchDynamicOptions($conn, $opts);
        $f['FieldOptions']    = '';
    } else {
        $f['dynamic_options'] = [];
    }

    $autoVal = '';
    if ($f['IsAutoFill'] && $f['DataSource'] && !isset($saved[$fid])) {
        $autoVal = resolveAutoFill($f['DataSource'], $studentData);
    }

    $f['display_value'] = $saved[$fid] ?? $autoVal;
    $f['IsRepeatable']  = (bool)$f['IsRepeatable'];
    $f['MaxRepeat']     = (int)($f['MaxRepeat'] ?? 1);
}
unset($f);// مهم: نستخدم unset($f) بعد الحلقة لإلغاء المرجعية إلى العنصر الأخير في $currentFields، مما يمنع التعديلات غير المقصودة على هذا العنصر لاحقًا في الكود.
//some of mistakes that can happen when we use a reference in a foreach loop (like &$f) is that if we forget to unset the reference after the loop, $f will still reference the last element of the array. This means that if we later assign something to $f, it will actually modify the last element of $currentFields, which can lead to bugs that are hard to track down. By calling unset($f) after the loop, we break this reference and prevent accidental modifications to the last element of the array.
//////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////
// ── معالجة حقول الخطوات السابقة ──
foreach ($previousFields as &$f) {
    $fid  = $f['FieldID'];
    $opts = $f['FieldOptions'] ?? '';
    $f['is_from_previous_step'] = true;
    $f['IsReadOnly']            = 1;

    if ($opts && strpos($opts, '__dynamic:') === 0) {
        $f['dynamic_options'] = fetchDynamicOptions($conn, $opts);
        $f['FieldOptions']    = '';
    } else {
        $f['dynamic_options'] = [];
    }

    $autoVal = '';
    if ($f['IsAutoFill'] && $f['DataSource'] && !isset($previousSaved[$fid])) {
        $autoVal = resolveAutoFill($f['DataSource'], $studentData);
    }

    $f['display_value'] = $previousSaved[$fid] ?? $autoVal;
    $f['IsRepeatable']  = (bool)$f['IsRepeatable'];
    $f['MaxRepeat']     = (int)($f['MaxRepeat'] ?? 1);
}
unset($f);// مهم: نستخدم unset($f) بعد الحلقة لإلغاء المرجعية إلى العنصر الأخير في $previousFields، مما يمنع التعديلات غير المقصودة على هذا العنصر لاحقًا في الكود.
//some of mistakes that can happen when we use a reference in a foreach loop (like &$f) is that if we forget to unset the reference after the loop, $f will still reference the last element of the array. This means that if we later assign something to $f, it will actually modify the last element of $previousFields, which can lead to bugs that are hard to track down. By calling unset($f) after the loop, we break this reference and prevent accidental modifications to the last element of the array.

$allFields = array_merge($previousFields, $currentFields);
$canAct    = $submissionId > 0 && $currentStepOrder > 1;
//what's we return from this api is a JSON object that contains all the necessary information for the frontend to render the form correctly.

echo json_encode([
    'success'            => true,// this indicates that the API call was successful and the frontend can proceed to use the data.
    'form_id'            => $formId,// the ID of the form type being accessed, useful for the frontend to know which form structure it is working with.
    'form_code'          => $formInfo['Code'],// a code or identifier for the form, which can be used in the frontend for display or logic purposes.
    'form_name'          => $formInfo['Name'],// the name of the form, which is important for displaying to the user and for context.
    'current_step_order' => $currentStepOrder,// the order of the current step in the workflow, which can be used to determine which fields to show and which actions are available.
    'current_role'       => $currentRole,// the role of the current user, which is crucial for enforcing permissions and determining what the user can see and do.
    'fields'             => $allFields,// an array of field definitions for both the current step and previous steps, including their values and options, which the frontend will use to render the form fields.
    'previous_fields'    => !empty($previousFields),// a boolean indicating whether there are fields from previous steps, which can be used to decide whether to show a "previous steps" section in the UI.
    'saved'              => $saved,// an associative array of saved field values for the current step, keyed by FieldID, which the frontend can use to populate the form fields with existing data.
    'can_act'            => $canAct,// a boolean indicating whether the user can take actions (like submit, approve, etc.) on this form, which is typically true if it's an existing submission and not the first step.
    'submission_id'      => $submissionId,// the ID of the current submission, which is important for the frontend to know when making API calls to save or update the submission.
]);
