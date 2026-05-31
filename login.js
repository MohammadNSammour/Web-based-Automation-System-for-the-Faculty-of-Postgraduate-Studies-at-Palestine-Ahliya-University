// ════════════════════════════════════════════════════════
// login.js  —  JS خاص بصفحة تسجيل الدخول فقط
// ════════════════════════════════════════════════════════

// doLogin(): Collects credentials and sends them to `login.php` via AJAX.
// Purpose: perform login flow (validate inputs, show errors, redirect on success).
// Used in: login page — called when user clicks login or presses Enter in inputs.
function doLogin() {
    var username = document.getElementById('username').value.trim();
    var password = document.getElementById('password').value.trim();
    var captcha  = document.getElementById('captcha').value.trim();
    var btn      = document.getElementById('loginBtn');
    var errBox   = document.getElementById('loginErr');

    // إخفاء أي خطأ سابق
    errBox.style.display = 'none';
    errBox.textContent   = '';

    if (!username || !password) {
        errBox.textContent   = 'يرجى إدخال اسم المستخدم وكلمة المرور.';
        errBox.style.display = 'block';
        return;
    }

    // تعطيل الزر أثناء الإرسال
    btn.disabled    = true;
    btn.textContent = 'جاري الدخول...';

    // AJAX POST
    var fd = new FormData();
    fd.append('username', username);
    fd.append('password', password);
    fd.append('captcha', captcha);

    fetch('login.php', { method:'POST', body:fd })
    .then(function(res){ return res.json(); })
    .then(function(data){
        if (data.success) {
            window.location.href = 'dashboard.php';
        } else {
            errBox.textContent   = data.message || 'بيانات غير صحيحة.';
            errBox.style.display = 'block';
            btn.disabled    = false;
            btn.textContent = 'الدخول';
        }
    })
    .catch(function(){
        errBox.textContent   = 'خطأ في الاتصال بالخادم.';
        errBox.style.display = 'block';
        btn.disabled    = false;
        btn.textContent = 'الدخول';
    });
}

function showPassword() {
    document.getElementById('password').type = 'text';
}

function hidePassword() {
    document.getElementById('password').type = 'password';
}

function refreshCaptcha() {
    fetch('login.php?get_captcha=1')
    .then(function(res){ return res.json(); })
    .then(function(data){
        document.getElementById('captchaDisplay').textContent = data.captcha;
        document.getElementById('captcha').value = '';
    })
    .catch(function(){
        console.error('خطأ في تحديث رمز التحقق');
    });
}

// إرسال بضغط Enter
// Attach Enter-key handler to username/password fields.
// Purpose: allow submitting the login form by pressing Enter.
// Used in: login page inputs (username, password).
document.addEventListener('DOMContentLoaded', function(){
    ['username','password'].forEach(function(id){
        document.getElementById(id).addEventListener('keypress', function(e){
            if (e.key === 'Enter') doLogin();
        });
    });
});
