<?php
// ════════════════════════════════════════════════════════
// users.php — لوحة إدارة المستخدمين + تعديل مسار النماذج
// متاحة للأدمن فقط
// ════════════════════════════════════════════════════════
session_start();
require_once 'db.php';

if (!isset($_SESSION['user_id']))          { header('Location: login.php');    exit; }
if ($_SESSION['current_role'] !== 'Admin') { header('Location: dashboard.php'); exit; }

$userId   = $_SESSION['user_id'];
$userName = $_SESSION['user_name'];

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

$allowedRoles = ['Student','Admin','Examiner','Supervisor',
                 'ProgramCoordinator','HeadOfSection','DeanOfFaculty','DeanOfGradStudies'];

// ══════════════════════════════════════════════════════════
// AJAX — حفظ ترتيب الخطوات الجديد
// ══════════════════════════════════════════════════════════
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['action'])) {
    header('Content-Type: application/json');

    // ── حفظ ترتيب جديد ──
    if ($_POST['action'] === 'save_workflow') {
        $formTypeId = (int)($_POST['form_type_id'] ?? 0);
        $steps      = json_decode($_POST['steps'] ?? '[]', true);

        if (!$formTypeId || empty($steps)) {
            echo json_encode(['success' => false, 'message' => 'بيانات ناقصة']);
            exit;
        }

        // تحقق إن النموذج موجود
        $chk = $conn->prepare("SELECT FormTypeID FROM FormTypes WHERE FormTypeID = ?");
        $chk->bind_param("i", $formTypeId);
        $chk->execute();
        if (!$chk->get_result()->fetch_assoc()) {
            echo json_encode(['success' => false, 'message' => 'النموذج غير موجود']);
            exit;
        }

        // حذف الخطوات القديمة وإدراج الجديدة
        $conn->begin_transaction();
        try {
            // أولاً احذف القيم المرتبطة بالخطوات القديمة
            $del = $conn->prepare("
                DELETE FROM FormWorkflowSteps WHERE FormTypeID = ?
            ");
            $del->bind_param("i", $formTypeId);
            $del->execute();

            // أدرج الخطوات الجديدة بالترتيب
            $ins = $conn->prepare("
                INSERT INTO FormWorkflowSteps (FormTypeID, StepName, StepOrder, AllowedRole, RequiresSpecificUser)
                VALUES (?, ?, ?, ?, 0)
            ");
            foreach ($steps as $i => $step) {
                $role     = $step['role'] ?? 'Student';
                $stepName = $step['name'] ?? ($roleLabels[$role] ?? $role);
                $order    = $i + 1;
                if (!in_array($role, $allowedRoles)) continue;
                $ins->bind_param("isis", $formTypeId, $stepName, $order, $role);
                $ins->execute();
            }

            $conn->commit();
            echo json_encode(['success' => true, 'message' => 'تم حفظ المسار بنجاح']);
        } catch (Exception $e) {
            $conn->rollback();
            echo json_encode(['success' => false, 'message' => 'خطأ: ' . $e->getMessage()]);
        }
        exit;
    }

    // ── جلب خطوات نموذج معين ──
    if ($_POST['action'] === 'get_steps') {
        $formTypeId = (int)($_POST['form_type_id'] ?? 0);
        $stmt = $conn->prepare("
            SELECT StepID, StepName, StepOrder, AllowedRole
            FROM   FormWorkflowSteps
            WHERE  FormTypeID = ?
            ORDER  BY StepOrder
        ");
        $stmt->bind_param("i", $formTypeId);
        $stmt->execute();
        $steps = $stmt->get_result()->fetch_all(MYSQLI_ASSOC);
        echo json_encode(['success' => true, 'steps' => $steps]);
        exit;
    }

    echo json_encode(['success' => false, 'message' => 'إجراء غير معروف']);
    exit;
}

// ══════════════════════════════════════════════════════════
// جلب النماذج
// ══════════════════════════════════════════════════════════
$forms = $conn->query("
    SELECT ft.FormTypeID, ft.Code, ft.Name,
           COUNT(ws.StepID) AS StepCount
    FROM   FormTypes ft
    LEFT JOIN FormWorkflowSteps ws ON ws.FormTypeID = ft.FormTypeID
    GROUP  BY ft.FormTypeID
    ORDER  BY ft.DisplayOrder, ft.FormTypeID
")->fetch_all(MYSQLI_ASSOC);

// ══════════════════════════════════════════════════════════
// جلب المستخدمين
// ══════════════════════════════════════════════════════════
$users = $conn->query("
    SELECT u.UserID,
           CONCAT(u.FirstName,' ',u.LastName) AS FullName,
           u.UserName, u.Email, u.UserType,
           GROUP_CONCAT(er.Role SEPARATOR ', ') AS Roles
    FROM   Users u
    LEFT JOIN Employees e  ON e.UserID = u.UserID
    LEFT JOIN Employee_Roles er ON er.EmployeeNumber = e.EmployeeNumber
    GROUP  BY u.UserID
    ORDER  BY u.UserType, u.FirstName
")->fetch_all(MYSQLI_ASSOC);
?>
<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
    <meta charset="UTF-8">
    <title>إدارة المستخدمين — كلية الدراسات العليا</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Cairo:wght@400;600;700;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="style.css">
    <style>
        /* ── تبويبات ── */
        .tabs { display:flex; gap:8px; margin-bottom:18px; }
        .tab-btn {
            padding:8px 22px; border:none; border-radius:6px 6px 0 0;
            background:#ddd; color:#555; font-family:inherit;
            font-size:14px; font-weight:700; cursor:pointer;
            transition:.2s;
        }
        .tab-btn.active { background:var(--green); color:#fff; }
        .tab-pane { display:none; }
        .tab-pane.active { display:block; }

        /* ── بطاقة النموذج ── */
        .form-card {
            background:#fff; border-radius:8px;
            margin-bottom:14px; overflow:hidden;
            box-shadow:0 1px 4px rgba(0,0,0,.08);
        }
        .form-card-head {
            background:var(--green); color:#fff;
            padding:10px 16px; display:flex;
            justify-content:space-between; align-items:center;
            cursor:pointer; user-select:none;
        }
        .form-card-head h3 { font-size:14px; margin:0; }
        .form-card-head .badge {
            background:rgba(255,255,255,.2);
            padding:2px 10px; border-radius:12px; font-size:12px;
        }
        .form-card-body { padding:16px; display:none; }
        .form-card-body.open { display:block; }

        /* ── قائمة الخطوات قابلة للسحب ── */
        .steps-list { list-style:none; margin:0 0 14px; padding:0; }
        .step-item {
            display:flex; align-items:center; gap:10px;
            background:#f8f9fa; border:1px solid #e0e0e0;
            border-radius:6px; padding:10px 14px;
            margin-bottom:8px; cursor:grab;
            transition:box-shadow .15s;
        }
        .step-item:active { cursor:grabbing; }
        .step-item.drag-over { box-shadow:0 0 0 2px var(--green); background:#eaf3ee; }
        .step-item.dragging  { opacity:.4; }
        .step-num {
            background:var(--green); color:#fff;
            width:26px; height:26px; border-radius:50%;
            display:flex; align-items:center; justify-content:center;
            font-size:12px; font-weight:700; flex-shrink:0;
        }
        .step-role-select {
            flex:1; padding:6px 10px; border:1px solid #ccc;
            border-radius:5px; font-family:inherit; font-size:13px;
            background:#fff;
        }
        .step-del {
            background:#fdecea; color:var(--red); border:none;
            border-radius:5px; padding:5px 10px; cursor:pointer;
            font-size:13px; font-weight:700;
        }
        .step-del:hover { background:var(--red); color:#fff; }
        .drag-handle {
            color:#bbb; font-size:18px; cursor:grab; flex-shrink:0;
        }

        /* ── أزرار ── */
        .btn-add-step {
            background:#eaf3ee; color:var(--green); border:1px dashed var(--green);
            border-radius:6px; padding:8px 16px; cursor:pointer;
            font-family:inherit; font-size:13px; font-weight:700;
            width:100%; margin-bottom:10px;
        }
        .btn-add-step:hover { background:var(--green); color:#fff; }
        .btn-save {
            background:var(--green); color:#fff; border:none;
            border-radius:6px; padding:9px 24px; cursor:pointer;
            font-family:inherit; font-size:14px; font-weight:700;
        }
        .btn-save:hover { opacity:.85; }
        .save-msg {
            display:inline-block; margin-right:10px;
            font-size:13px; font-weight:700;
        }
        .save-msg.ok  { color:var(--green); }
        .save-msg.err { color:var(--red); }

        /* ── جدول المستخدمين ── */
        .users-table { width:100%; border-collapse:collapse; background:#fff; border-radius:8px; overflow:hidden; }
        .users-table th {
            background:var(--green); color:#fff;
            padding:10px 12px; text-align:right; font-size:13px;
        }
        .users-table td { padding:9px 12px; border-bottom:1px solid #eee; font-size:13px; color:#333; }
        .users-table tr:hover td { background:#eaf3ee; }
        .badge-type {
            padding:3px 10px; border-radius:12px; font-size:11px; font-weight:700;
        }
        .badge-emp { background:#e8f0f8; color:#1565c0; }
        .badge-stu { background:#eaf3ee; color:var(--green); }

        /* ── تنبيه ── */
        .alert-warn {
            background:#fff8e1; border:1px solid #ffe082;
            border-radius:6px; padding:10px 14px;
            color:#795548; font-size:13px; margin-bottom:14px;
        }
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
    <div class="role-badge"><span>مشرف النظام</span><span><?= $userId ?></span></div>
    <hr class="sep">
    <div class="sec-title">الإجراءات</div>
    <a href="dashboard.php" class="side-btn">لوحة التحكم</a>
    <a href="users.php"     class="side-btn active">إدارة المستخدمين</a>
    <hr class="sep">
    <a href="logout.php" class="btn-logout">تسجيل الخروج</a>
</aside>

<!-- ══ المحتوى ══ -->
<div class="main-wrap">
<div style="padding:20px;">

    <h2 style="color:var(--green);margin-bottom:16px;">⚙️ إدارة المستخدمين والنماذج</h2>

    <!-- تبويبات -->
    <div class="tabs">
        <button class="tab-btn active" onclick="switchTab('workflow', this)">🔀 مسارات النماذج</button>
        <button class="tab-btn"        onclick="switchTab('users', this)">👥 المستخدمون</button>
    </div>

    <!-- ══ تبويب مسارات النماذج ══ -->
    <div id="tab-workflow" class="tab-pane active">

        <div class="alert-warn">
            ⚠️ تعديل مسار النموذج يؤثر على <strong>الطلبات المستقبلية فقط</strong>.
            الطلبات النشطة حالياً تكمل مسارها القديم.
        </div>

        <?php foreach ($forms as $form): ?>
        <div class="form-card" id="fc-<?= $form['FormTypeID'] ?>">
            <div class="form-card-head" onclick="toggleCard(<?= $form['FormTypeID'] ?>)">
                <h3>نموذج <?= htmlspecialchars($form['Code']) ?> — <?= htmlspecialchars($form['Name']) ?></h3>
                <span class="badge"><?= $form['StepCount'] ?> خطوات</span>
            </div>
            <div class="form-card-body" id="fb-<?= $form['FormTypeID'] ?>">
                <p style="color:#888;font-size:12px;margin-bottom:12px;">
                    اسحب الخطوات لإعادة الترتيب · اضغط ✕ لحذف خطوة · أضف خطوات جديدة
                </p>
                <ul class="steps-list" id="steps-<?= $form['FormTypeID'] ?>" data-form="<?= $form['FormTypeID'] ?>">
                    <!-- تُملأ بـ JS -->
                </ul>
                <button class="btn-add-step" onclick="addStep(<?= $form['FormTypeID'] ?>)">+ إضافة خطوة</button>
                <div>
                    <button class="btn-save" onclick="saveWorkflow(<?= $form['FormTypeID'] ?>)">💾 حفظ المسار</button>
                    <span class="save-msg" id="msg-<?= $form['FormTypeID'] ?>"></span>
                </div>
            </div>
        </div>
        <?php endforeach; ?>
    </div>

    <!-- ══ تبويب المستخدمين ══ -->
    <div id="tab-users" class="tab-pane">
        <table class="users-table">
            <thead>
                <tr>
                    <th>#</th>
                    <th>الاسم</th>
                    <th>اسم المستخدم</th>
                    <th>الإيميل</th>
                    <th>النوع</th>
                    <th>الأدوار</th>
                </tr>
            </thead>
            <tbody>
                <?php foreach ($users as $i => $u): ?>
                <tr>
                    <td><?= $i + 1 ?></td>
                    <td><?= htmlspecialchars($u['FullName']) ?></td>
                    <td><code><?= htmlspecialchars($u['UserName']) ?></code></td>
                    <td><?= htmlspecialchars($u['Email'] ?? '—') ?></td>
                    <td>
                        <span class="badge-type <?= $u['UserType'] === 'Employee' ? 'badge-emp' : 'badge-stu' ?>">
                            <?= $u['UserType'] === 'Employee' ? 'موظف' : 'طالب' ?>
                        </span>
                    </td>
                    <td><?= htmlspecialchars($u['Roles'] ?? ($u['UserType'] === 'Student' ? 'طالب' : '—')) ?></td>
                </tr>
                <?php endforeach; ?>
            </tbody>
        </table>
    </div>

</div>
</div>

<!-- تذييل -->
<footer class="page-footer">
    <span class="clock-time"></span>
    <span style="margin:0 20px;">جميع الحقوق محفوظة <?= date('Y') ?></span>
    <span class="clock-date"></span>
</footer>

<script src="app.js"></script>
<script>
// ══════════════════════════════════════
// بيانات الأدوار
// ══════════════════════════════════════
const ROLE_LABELS = <?= json_encode($roleLabels, JSON_UNESCAPED_UNICODE) ?>;
const ALLOWED_ROLES = <?= json_encode($allowedRoles, JSON_UNESCAPED_UNICODE) ?>;

// ══════════════════════════════════════
// تبديل التبويبات
// ══════════════════════════════════════
function switchTab(name, btn) {
    document.querySelectorAll('.tab-pane').forEach(p => p.classList.remove('active'));
    document.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('active'));
    document.getElementById('tab-' + name).classList.add('active');
    btn.classList.add('active');
}

// ══════════════════════════════════════
// فتح/إغلاق بطاقة النموذج + جلب خطواته
// ══════════════════════════════════════
function toggleCard(formId) {
    const body = document.getElementById('fb-' + formId);
    const isOpen = body.classList.toggle('open');
    if (isOpen) loadSteps(formId);
}

async function loadSteps(formId) {
    const list = document.getElementById('steps-' + formId);
    list.innerHTML = '<li style="color:#aaa;padding:8px;">جارٍ التحميل...</li>';

    const fd = new FormData();
    fd.append('action', 'get_steps');
    fd.append('form_type_id', formId);

    const res  = await fetch('users.php', { method: 'POST', body: fd });
    const data = await res.json();

    list.innerHTML = '';
    if (data.success && data.steps.length) {
        data.steps.forEach(step => appendStep(list, step.AllowedRole, step.StepName));
    } else {
        appendStep(list, 'Student');
    }
    initDrag(list);
}

// ══════════════════════════════════════
// إنشاء عنصر خطوة
// ══════════════════════════════════════
function appendStep(list, role, name) {
    const li = document.createElement('li');
    li.className = 'step-item';
    li.draggable = true;

    // خيارات الأدوار
    const options = ALLOWED_ROLES.map(r =>
        `<option value="${r}" ${r === role ? 'selected' : ''}>${ROLE_LABELS[r] || r}</option>`
    ).join('');

    li.innerHTML = `
        <span class="drag-handle">⠿</span>
        <span class="step-num">•</span>
        <select class="step-role-select">${options}</select>
        <button class="step-del" onclick="this.closest('li').remove(); renumber(this)">✕</button>
    `;
    list.appendChild(li);
    renumberList(list);
}

function addStep(formId) {
    const list = document.getElementById('steps-' + formId);
    appendStep(list, 'Student');
    initDrag(list);
}

// ══════════════════════════════════════
// إعادة ترقيم الخطوات
// ══════════════════════════════════════
function renumber(el) {
    const list = el.closest('ul');
    if (list) renumberList(list);
}
function renumberList(list) {
    list.querySelectorAll('.step-num').forEach((el, i) => el.textContent = i + 1);
}

// ══════════════════════════════════════
// Drag & Drop
// ══════════════════════════════════════
function initDrag(list) {
    let dragged = null;

    list.querySelectorAll('.step-item').forEach(item => {
        item.addEventListener('dragstart', () => {
            dragged = item;
            setTimeout(() => item.classList.add('dragging'), 0);
        });
        item.addEventListener('dragend', () => {
            item.classList.remove('dragging');
            list.querySelectorAll('.step-item').forEach(i => i.classList.remove('drag-over'));
            renumberList(list);
        });
        item.addEventListener('dragover', e => {
            e.preventDefault();
            list.querySelectorAll('.step-item').forEach(i => i.classList.remove('drag-over'));
            item.classList.add('drag-over');
        });
        item.addEventListener('drop', e => {
            e.preventDefault();
            if (dragged && dragged !== item) {
                const items = [...list.querySelectorAll('.step-item')];
                const fromIdx = items.indexOf(dragged);
                const toIdx   = items.indexOf(item);
                if (fromIdx < toIdx) item.after(dragged);
                else item.before(dragged);
                renumberList(list);
            }
        });
    });
}

// ══════════════════════════════════════
// حفظ المسار
// ══════════════════════════════════════
async function saveWorkflow(formId) {
    const list    = document.getElementById('steps-' + formId);
    const msgEl   = document.getElementById('msg-' + formId);
    const selects = list.querySelectorAll('.step-role-select');

    if (selects.length === 0) {
        msgEl.textContent = 'أضف خطوة واحدة على الأقل';
        msgEl.className   = 'save-msg err';
        return;
    }

    const steps = [...selects].map(s => ({
        role: s.value,
        name: ROLE_LABELS[s.value] || s.value
    }));

    const fd = new FormData();
    fd.append('action',       'save_workflow');
    fd.append('form_type_id', formId);
    fd.append('steps',        JSON.stringify(steps));

    msgEl.textContent = 'جارٍ الحفظ...';
    msgEl.className   = 'save-msg';

    const res  = await fetch('users.php', { method: 'POST', body: fd });
    const data = await res.json();

    msgEl.textContent = data.message;
    msgEl.className   = 'save-msg ' + (data.success ? 'ok' : 'err');
    setTimeout(() => msgEl.textContent = '', 3000);
}
</script>
</body>
</html>