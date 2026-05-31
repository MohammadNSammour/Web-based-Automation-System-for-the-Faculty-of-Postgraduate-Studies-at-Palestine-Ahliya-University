// ════════════════════════════════════════════════════════
// app.js  —  ملف JS المشترك لجميع الصفحات
// يحتوي فقط على: الساعة، القوائم المنسدلة، Toast، esc()
// كل منطق خاص بصفحة موجود في ملفها المستقل
// ════════════════════════════════════════════════════════
// ════════════════════════════════════════════════════════
//هذا الملف لا يحتوي على أي منطق خاص بصفحة معينة، بل هو مشترك لجميع الصفحات
//يحتوي فقط على: الساعة، القوائم المنسدلة، Toast، esc()
//كل منطق خاص بصفحة موجود في ملفها المستقل
// ════════════════════════════════════════════════════════
//READY

// ── 1. الساعة والتاريخ ──
// updateClock(): Update all `.clock-time` and `.clock-date` elements every second.
// Purpose: show current time/date in the header or widgets across pages.
// Used in: any page that includes the shared header with `.clock-time` / `.clock-date`.
function updateClock() {
    var now    = new Date();
    var h      = String(now.getHours()).padStart(2,'0');
    var m      = String(now.getMinutes()).padStart(2,'0');
    var s      = String(now.getSeconds()).padStart(2,'0');
    var days   = ['الأحد','الاثنين','الثلاثاء','الأربعاء','الخميس','الجمعة','السبت'];

    var months = ['يناير','فبراير','مارس','أبريل','مايو','يونيو',
                'يوليو','أغسطس','سبتمبر','أكتوبر','نوفمبر','ديسمبر'];

    var time = h+':'+m+':'+s;
    var date = days[now.getDay()]+' '+now.getDate()+' '+months[now.getMonth()]+' '+now.getFullYear();
    document.querySelectorAll('.clock-time').forEach(function(el){ el.textContent = time; });
    document.querySelectorAll('.clock-date').forEach(function(el){ el.textContent = date; });
}
setInterval(updateClock, 1000);
updateClock();


// ── 2. القوائم المنسدلة في الشريط الجانبي ──
// Sidebar dropdown toggles initialization.
// Purpose: enable opening/closing sidebar sub-menus when `.side-btn-drop` clicked.
// Used in: site-wide sidebar navigation.
document.addEventListener('DOMContentLoaded', function() {
    document.querySelectorAll('.side-btn-drop').forEach(function(btn) {
        btn.addEventListener('click', function() {
            var sub = document.getElementById(this.dataset.target);
            if (!sub) return;
            sub.classList.toggle('open');
        });
    });
});


// ── 3. Toast — رسالة النظام العائمة ──
// showMsg(text, type): Toast-style system message (success or error).
// Purpose: display a short system notification in `#sys-msg` element.
// Used across the app to provide lightweight feedback (ok / err).
function showMsg(text, type) {
    var el = document.getElementById('sys-msg');
    if (!el) return;
    el.textContent      = text;
    el.style.background = type === 'ok' ? '#eaf3ee' : '#fdecea';
    el.style.color      = type === 'ok' ? '#1d5c36' : '#e63946';
    el.style.border     = '1px solid ' + (type === 'ok' ? '#1d5c36' : '#e63946');
    el.style.display    = 'block';
    setTimeout(function(){
        el.style.display = 'none'; }, 3500);
}


// ── 4. Escape HTML — يمنع XSS ──
// esc(str): Escape HTML to prevent XSS when injecting user-controlled strings.
// Purpose: sanitize text before inserting into innerHTML or templates.
// Used in: many page-specific renderers (e.g., form.js, notifications.js).
function esc(str) {
    if (!str) return '';
    return String(str)
        .replace(/&/g,'&amp;').replace(/</g,'&lt;')
        .replace(/>/g,'&gt;').replace(/"/g,'&quot;');
}
