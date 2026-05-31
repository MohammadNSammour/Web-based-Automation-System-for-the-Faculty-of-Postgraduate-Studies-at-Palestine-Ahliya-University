// ════════════════════════════════════════════════════════
// notifications.js — JS خاص بصفحة إرسال الإشعارات
// ════════════════════════════════════════════════════════


// ── تحديث عداد المحددين عند كل تغيير ──
// Initialize recipient checkboxes listener on DOM ready.
// Purpose: keep the selected count updated when checkboxes change.
// Used in: notifications page list of recipients.
document.addEventListener('DOMContentLoaded', function() {
    document.querySelectorAll('.recipient-cb').forEach(function(cb) {
        cb.addEventListener('change', updateCount);
    });
});

// updateCount(): Update the counter of selected recipients.
// Purpose: display how many recipients are currently checked.
// Used in: page header/status on notifications page.
function updateCount() {
    var count = document.querySelectorAll('.recipient-cb:checked').length;
    document.getElementById('selectedCount').textContent = count;
}


// ── البحث في قائمة المستخدمين ──
// filterUsers(): Filter displayed users by name or role using search input.
// Purpose: help the sender find recipients quickly in the list.
// Used in: search box on notifications page (on input events).
function filterUsers() {
    var q = document.getElementById('userSearch').value.trim().toLowerCase();
    document.querySelectorAll('.user-item').forEach(function(item) {
        var name = item.getAttribute('data-name') || '';
        var role = item.getAttribute('data-role') || '';
        if (!q || name.includes(q) || role.includes(q)) {
            item.classList.remove('hidden');
        } else {
            item.classList.add('hidden');
        }
    });
}


// ── تحديد بالنوع (طالب / موظف) ──
// selectByType(type): Check recipients by their `data-type` (e.g., student/staff).
// Purpose: quickly select groups of users by category.
// Used in: filter buttons on notifications page.
function selectByType(type) {
    document.querySelectorAll('.user-item').forEach(function(item) {
        if (item.getAttribute('data-type') === type) {
            var cb = item.querySelector('.recipient-cb');
            if (cb) cb.checked = true;
        }
    });
    updateCount();
}

// selectAll(): Check all recipient checkboxes.
// Purpose: convenience to target all users in the current list.
// Used in: "Select All" control on notifications page.
function selectAll() {
    document.querySelectorAll('.recipient-cb').forEach(function(cb) {
        cb.checked = true;
    });
    updateCount();
}

// clearAll(): Uncheck all recipient checkboxes.
// Purpose: convenience to clear selection.
// Used in: "Clear All" control on notifications page.
function clearAll() {
    document.querySelectorAll('.recipient-cb').forEach(function(cb) {
        cb.checked = false;
    });
    updateCount();
}


// ── إرسال الإشعار بـ AJAX ──
// sendNotification(): Collect message, recipients and POST to `sendNotification.php`.
// Purpose: send the notification via AJAX and update UI on success/failure.
// Used in: notifications page when user clicks the send button.
function sendNotification() {
    var msg  = document.getElementById('notifMsg').value.trim();
    var type = document.getElementById('notifType').value;
    var btn  = document.getElementById('sendBtn');
    var res  = document.getElementById('sendResult');
    var errMsg = document.getElementById('errMsg');

    // تنظيف الأخطاء
    errMsg.textContent = '';
    errMsg.classList.remove('show');
    res.style.display  = 'none';

    // التحقق من النص
    if (!msg) {
        errMsg.textContent = 'يرجى كتابة نص الإشعار.';
        errMsg.classList.add('show');
        document.getElementById('notifMsg').focus();
        return;
    }

    // جمع المستخدمين المحددين
    var recipients = [];
    document.querySelectorAll('.recipient-cb:checked').forEach(function(cb) {
        recipients.push(cb.value);
    });

    if (recipients.length === 0) {
        showResult('يرجى تحديد مستخدم واحد على الأقل.', 'err');
        return;
    }

    // تعطيل الزر
    btn.disabled    = true;
    btn.textContent = 'جاري الإرسال...';

    // AJAX POST
    var fd = new FormData();
    fd.append('message',    msg);
    fd.append('type',       type);
    fd.append('recipients', JSON.stringify(recipients));

    fetch('sendNotification.php', { method: 'POST', body: fd })
    .then(function(r) { return r.json(); })
    .then(function(data) {
        if (data.success) {
            showResult('✓ تم إرسال الإشعار إلى ' + data.count + ' مستخدم بنجاح.', 'ok');
            // تنظيف النموذج
            document.getElementById('notifMsg').value = '';
            clearAll();
            // إضافة الإشعار الجديد لقائمة المُرسَلة
            addToSentList(msg, type, data.count);
        } else {
            showResult(data.message || 'حدث خطأ أثناء الإرسال.', 'err');
        }
    })
    .catch(function() {
        showResult('خطأ في الاتصال بالخادم.', 'err');
    })
    .finally(function() {
        btn.disabled    = false;
        btn.textContent = 'إرسال الإشعار';
    });
}

// عرض رسالة النتيجة
// showResult(msg, type): Display a temporary result message (ok/err).
// Purpose: give user feedback after attempting to send a notification.
// Used in: `sendNotification()` to show success/error messages.
function showResult(msg, type) {
    var el = document.getElementById('sendResult');
    el.textContent  = msg;
    el.className    = 'send-result ' + type;
    el.style.display = 'block';
    // hide after 5 seconds
    setTimeout(function() { el.style.display = 'none'; }, 5000);
}

// إضافة الإشعار الجديد لقائمة المُرسَلة دون إعادة تحميل الصفحة
// addToSentList(msg, type, count): Insert a new sent-item into the sent list DOM.
// Purpose: update the sent notifications list instantly without page reload.
// Used in: `sendNotification()` after a successful send.
function addToSentList(msg, type, count) {
    var typeMap = {
        'General':       ['عام',         'b-prog'],
        'FormSubmitted': ['إرسال نموذج', 'b-ok'],
        'FormApproved':  ['موافقة',      'b-ok'],
        'FormRejected':  ['رفض',         'b-rej'],
        'FormReturned':  ['إرجاع',       'b-ret'],
    };
    var tl  = typeMap[type] || ['عام', 'b-prog'];
    var now = new Date();
    var timeStr = now.getFullYear() + '-'
        + String(now.getMonth()+1).padStart(2,'0') + '-'
        + String(now.getDate()).padStart(2,'0') + ' '
        + String(now.getHours()).padStart(2,'0') + ':'
        + String(now.getMinutes()).padStart(2,'0');

    var div = document.createElement('div');
    div.className = 'sent-item';
    div.innerHTML =
        '<div class="sent-item-top">' +
            '<span class="badge ' + tl[1] + '">' + tl[0] + '</span>' +
            '<span class="sent-item-time">' + timeStr + '</span>' +
        '</div>' +
        '<div class="sent-item-msg">' + esc(msg) + '</div>' +
        '<div class="sent-item-recipients">أُرسل إلى ' + count + ' مستخدم</div>';

    var list = document.getElementById('sentList');
    // إزالة رسالة "لم ترسل أي إشعارات" إن وُجدت
    var empty = list.querySelector('[style*="text-align"]');
    if (empty) empty.remove();

    list.insertBefore(div, list.firstChild);
}
