// ════════════════════════════════════════════════════════
// form.js  —  JS خاص بصفحة النماذج
// يعتمد على المتغيرات: PAGE_FORM_ID و PAGE_SUB_ID (من form.php)
// ════════════════════════════════════════════════════════

var currentStepId = 0;
// ── 0. عند تحميل الصفحة ──
document.addEventListener('DOMContentLoaded', function() {
    getCorrectStep();
});
//////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////
// ── 1. جلب الخطوة الصحيحة للمستخدم الحالي ──
//اولا نجلب الفورم  بخطوته الصحيحة للمستخدم الحالي，
//  بناءً على 
// form_id و submission_id 
// (إن وجدت) في URL
// getCorrectStep(): Ask server which step the current user should see.
// Purpose: determine `currentStepId` or redirect to an existing submission.
// Used in: `form.php` on page load to decide which step to render.
function getCorrectStep() {
    fetch('getStep.php?form_id=' + PAGE_FORM_ID + '&submission_id=' + PAGE_SUB_ID)
    .then(function(res){ return res.json(); })
    .then(function(data){
        // إذا أعاد السيرفر redirect_submission_id، نعيد التوجيه إلى form.php مع submission_id الجديد
        //الاسماء الموجودة هان هي اسماء المتغيرات الي برجعها السيرفر من خلال الجيسون، اذا كان في redirect_submission_id معناها انو في submission موجود لهذا المستخدم وبدنا نوجهه عليه مباشرة
        //ليش !PAGE_SUB_ID
        // لأننا نريد فقط إعادة التوجيه إذا لم يكن هناك submission_id في URL أصلاً، أي هذه هي الزيارة الأولى للمستخدم. إذا كان PAGE_SUB_ID موجود، فهذا يعني أن المستخدم بالفعل على صفحة submission معينة، حتى لو كانت غير صحيحة، فلا نريد إعادة التوجيه مرة أخرى لتجنب الحلقات.
        if (data.redirect_submission_id && !PAGE_SUB_ID) {
            window.location.href = 'form.php?form_id=' + PAGE_FORM_ID + '&submission_id=' + data.redirect_submission_id;
            return;
        }
        if (!data.step_id) {
            //form-area هو div في form.php نعرض فيه النموذج، إذا ما في step_id معناها ما في صلاحية او في خطأ، بنعرض الرسالة اللي جايه من السيرفر او رسالة افتراضية
            document.getElementById('form-area').innerHTML =
                '<p style="color:#e63946;text-align:center;padding:20px;">' + esc(data.message || data.error || 'لا توجد صلاحية لهذا النموذج.') + '</p>';
            return;
        }
        currentStepId = data.step_id;
        loadForm();
    })
    .catch(function(){
        document.getElementById('form-area').innerHTML =
            '<p style="color:#e63946;text-align:center;padding:20px;">خطأ في الاتصال.</p>';
    });
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////
// ── 2. جلب بيانات النموذج (الحقول + القيم المحفوظة) ──
//ثانيا نستخدم الخطوة لجلب بيانات النموذج (الحقول + القيم المحفوظة) ورسمه على الشاشة
// بناءً على form_id و step_id و submission_id
// loadForm(): Fetch fields & saved values for the current step from `getForm.php`.
// Purpose: retrieve JSON describing fields and then call `renderForm()`.
// Used in: after determining `currentStepId` (getCorrectStep) and when navigating steps.
function loadForm() {
    var url = 'getForm.php?formId='    + PAGE_FORM_ID
            + '&stepId='               + currentStepId//currentStepId تم تحديده في getCorrectStep بناءً على form_id و submission_id
            + '&submissionId='         + PAGE_SUB_ID;

    fetch(url)
    .then(function(res){ return res.json(); })
    .then(function(data){
        if (data.error) {
            document.getElementById('form-area').innerHTML =
                '<p style="color:#e63946;text-align:center;padding:20px;">' + esc(data.error) + '</p>';
            return;
        }
        //نمرر بيانات النموذج إلى الدالة المسؤولة عن رسمه
        renderForm(data);
    })
    .catch(function(){
        document.getElementById('form-area').innerHTML =
            '<p style="color:#e63946;text-align:center;padding:20px;">تعذّر تحميل النموذج.</p>';
    });
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////
// ── خريطة FieldName → FieldID (مشتركة بين كل الدوال) ──
// تستخدم لتحويل أسماء الحقول الشرطية (ConditionalOn) إلى معرفات الحقول الفعلية في HTML عند تقييم الشروط في checkConditionals().
var fieldNameToId = {};

// ── 3. رسم النموذج على الشاشة ──
// renderForm(data): Build the HTML for the form from server data.
// Purpose: render sections, fields, repeatable groups and action buttons.
// Used in: `form.php` after `loadForm()` receives data.
function renderForm(data) {
    var fields = data.fields  || [];
    var canAct = data.can_act || false;
    var hasPreviousFields = data.previous_fields || false;
    var html   = '';

    // بناء الخريطة: FieldName → FieldID
    // تُستخدم في checkConditionals لتحويل اسم الحقل إلى name الفعلي في HTML
    fieldNameToId = {};
    fields.forEach(function(f) {
        if (f.FieldName)
            fieldNameToId[f.FieldName] = f.FieldID;
    });

    // عنوان النموذج
    html += '<div class="page-title">';
    html += '<h2>صفحة النماذج — نموذج ' + esc(data.form_code) + '</h2>';
    html += '<p>' + esc(data.form_name) + '</p>';

    // إذا كانت هناك مراحل سابقة
    /*if (hasPreviousFields && PAGE_SUB_ID > 0) {
        html += '<div style="background:#f0f0f0;border:1px solid #ccc;border-radius:4px;padding:8px 12px;margin-top:10px;font-size:12px;color:#666;">'
              + '📋 يوجد بيانات من مراحل سابقة (للقراءة فقط)'
              + '</div>';
    }*/

    html += '</div>';
// بدء النموذج
    html += '<form id="dynamicForm">';

    // تجميع الحقول في أقسام حسب SectionName + معلومات المرحلة السابقة
    var sections    = {};
    var sectionList = [];
    //هنا بنجمع الحقول حسب اسم القسم (SectionName) في كائن sections، وبنحتفظ بقائمة sectionList لترتيب الأقسام عند الرسم. إذا الحقل ما عنده SectionName، بنحطه في قسم افتراضي اسمه "بيانات". كمان بنحدد إذا كانت الحقول من مرحلة سابقة (is_from_previous_step) عشان نرسمها بشكل مختلف (قراءة فقط مع إشارة).
    fields.forEach(function(f) {
        var s = f.SectionName || 'بيانات';// إذا لم يكن هناك اسم قسم، نضعه في قسم افتراضي اسمه "بيانات"
        if (!sections[s]) {
            sections[s] = [];
            sectionList.push(s);
        }
        sections[s].push(f);
    });

    // رسم كل قسم
    sectionList.forEach(function(secName, idx) {
        var secFields  = sections[secName];
        var isFromPreviousFlag = secFields[0] && secFields[0].is_from_previous_step;// نفترض أن جميع الحقول في نفس القسم تنتمي إلى نفس المرحلة (سواء كانت سابقة أم لا)، لذلك نأخذ is_from_previous_step من أول حقل في القسم. إذا كان true، فهذا يعني أن هذا القسم يحتوي على بيانات من مرحلة سابقة ويجب رسمه كقراءة فقط مع إشارة مناسبة.
        var isPreviousStageReadOnly = isFromPreviousFlag && PAGE_SUB_ID > 0;

        html += '<div class="f-section' + (isPreviousStageReadOnly ? ' f-section-readonly' : '') + '">';

        // رأس القسم - مع إشارة إذا كان من مرحلة سابقة
        var headClass = isPreviousStageReadOnly ? 'f-sec-head-prev' : 'f-sec-head';
        var headLabel = secName;
        if (isPreviousStageReadOnly) {
            headLabel = ' (للقراءة فقط) ' + secName;
        }
        html += '<div class="' + headClass + '">';
        //idx+1 لأن idx يبدأ من 0، لكننا نريد أن نعرض "القسم 1" بدلاً من "القسم 0"
        html += 'القسم ' + (idx+1) + ': ' + esc(headLabel) + '</div>';
        html += '<div class="f-sec-body">';

        // فصل الحقول: عادية VS قابلة للتكرار
        var normalFields  = [];
        var repeatFields  = [];
        var maxRepeat     = 1;

        secFields.forEach(function(f) {
            if (f.IsRepeatable) {
                repeatFields.push(f);
                // نحدد الحد الأقصى للتكرار بناءً على الحقل الذي لديه أعلى قيمة MaxRepeat، أو 1 إذا لم يكن محددًا
                maxRepeat = Math.max(maxRepeat, f.MaxRepeat || 1);
            } else {
                normalFields.push(f);
            }
        });

        // الحقول العادية
        normalFields.forEach(function(field) {
            // إذا كان الحقل من مرحلة سابقة، نستخدم display_value للعرض بدلاً من القيمة المحفوظة، ونرسمه كقراءة فقط
            // إذا لم يكن من مرحلة سابقة، نستخدم القيمة المحفوظة (إذا وجدت) أو display_value كقيمة افتراضية، ونرسمه حسب صلاحياته (قد يكون قابل للتعديل أو للقراءة فقط بناءً على IsReadOnly)
            html += renderField(field, field.display_value || '', isPreviousStageReadOnly, '');
        });

        // الحقول القابلة للتكرار
        if (repeatFields.length > 0) {
            var baseId = repeatFields[0].FieldID;
            html += '<div class="repeat-wrapper" id="rw_' + baseId + '">';
            // نرسم صف تكرار واحد كافٍ في البداية، حتى لو كان maxRepeat > 1، لأن المستخدم قد لا يحتاج إلى تكرار إضافي. إذا احتاج، يمكنه الضغط على زر "إضافة مؤهل آخر" لإضافة صفوف تكرار جديدة حتى الحد الأقصى.
            html += renderRepeatRow(repeatFields, isPreviousStageReadOnly, 1);
            
            if (!isPreviousStageReadOnly) {
                html += '<button type="button" class="repeat-add-btn" '
                      + 'onclick="addRepeatRow(' + baseId + ',' + maxRepeat + ')">'
                      + '+ إضافة مؤهل آخر</button>';
            }
            html += '</div>';
        }

        html += '</div></div>';

        if (repeatFields.length > 0) {
            // نحتفظ بمعلومات الحقول القابلة للتكرار في المتغيرات العالمية لاستخدامها عند إضافة صفوف تكرار جديدة
            //rf_ تعني "repeat fields" و rro_ تعني "is read only" و rc_ تعني "repeat count"
            // نستخدم FieldID كجزء من المفتاح لضمان التمييز بين مجموعات الحقول القابلة للتكرار المختلفة في النموذج، خاصة إذا كان هناك أكثر من مجموعة واحدة.
            //لما اسندنا هذه القيم بالتحديد,
            var baseId2 = repeatFields[0].FieldID;// نستخدم FieldID كجزء من المفتاح لضمان التمييز بين مجموعات الحقول القابلة للتكرار المختلفة في النموذج، خاصة إذا كان هناك أكثر من مجموعة واحدة.
            window['rf_'  + baseId2] = repeatFields;// نحتفظ بمصفوفة الحقول القابلة للتكرار في المتغير العالمي rf_ مع FieldID كجزء من المفتاح
            window['rro_' + baseId2] = isPreviousStageReadOnly;// نحتفظ بقيمة "isPreviousStageReadOnly" في المتغير العالمي rro_ مع FieldID كجزء من المفتاح
            window['rc_'  + baseId2] = 1;// نحتفظ بقيمة "repeat count" في المتغير العالمي rc_ مع FieldID كجزء من المفتاح
            //لما نحتفظ بكل هذه المعلومات في المتغير العالمي
            // نكون قادرين على الوصول إليها بسهولة عند الحاجة لإضافة صف تكرار جديد (addRepeatRow) أو عند رسم صف تكرار (renderRepeatRow) لمعرفة الحقول التي يجب تضمينها، وما إذا كانت للقراءة فقط، وعدد الصفوف الحالية. هذا التنظيم يجعل من السهل إدارة الحقول القابلة للتكرار في النموذج دون الحاجة إلى إعادة جلب البيانات من السيرفر أو تمرير الكثير من المعلومات بين الدوال.
            //هي مثل الـmetadata الخاصة بكل مجموعة من الحقول القابلة للتكرار، بتساعدنا نديرهم بشكل ديناميكي في الواجهة الأمامية.
        }
    });

    // أزرار الإجراءات
    html += '<div class="f-actions">';
    if (canAct && PAGE_SUB_ID) {
        html += '<button type="button" class="btn btn-o" onclick="sendAction(\'return\')">إرجاع</button>';
        html += '<button type="button" class="btn btn-r" onclick="sendAction(\'reject\')">رفض</button>';
        html += '<button type="button" class="btn btn-g" onclick="sendAction(\'approve\')">إرسال</button>';
    } else {
        html += '<button type="button" class="btn btn-g" onclick="submitForm()">إرسال</button>';
    }
    html += '</div></form>';

    document.getElementById('form-area').innerHTML = html;
    // بعد رسم النموذج، نفحص الحقول الشرطية لإظهار أو إخفاء الحقول بناءً على القيم الحالية. ثم نضيف مستمع حدث `change` على النموذج لإعادة فحص الحقول الشرطية كلما تغيرت أي قيمة في النموذج.
    checkConditionals();
    document.getElementById('dynamicForm').addEventListener('change', checkConditionals);
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////
// ── 4. رسم حقل واحد ──
// renderField(field, savedVal, readOnly, prefix): Render a single field's HTML.
// Purpose: support multiple input types (text, select, radio, file, etc.)
// Used in: `renderForm()` and `renderRepeatRow()` to build each field element.
//هنا يتم رندرة حقل واحد في وقت واحد، بناءً على نوعه (FieldType) وخياراته (FieldOptions) وقيمته المحفوظة (savedVal) وما إذا كان للقراءة فقط (readOnly). يتم دعم أنواع متعددة من الحقول مثل النصوص، القوائم المنسدلة، الأزرار الراديوية، المربعات الاختيارية، والملفات. يتم بناء HTML مناسب لكل نوع حقل مع مراعاة الشروط مثل الحقول المطلوبة أو الحقول الشرطية التي تظهر أو تختفي بناءً على قيم حقول أخرى.
function renderField(field, savedVal, readOnly, prefix) {
    var id      = 'f_' + prefix + field.FieldID;
    var name    = prefix ? (field.FieldID + '_' + prefix) : String(field.FieldID);
    var type    = field.FieldType;
    var opts    = field.FieldOptions || '';
    var dynOpts = field.dynamic_options || [];
    var req     = field.IsRequired == 1 && !readOnly;
    var ro      = readOnly || field.IsReadOnly == 1;
    var cssCol  = field.CSSClass || 'col-6';
    var condOn  = field.ConditionalOn    || '';
    var condVal = field.ConditionalValue || '';
    // إذا كان الحقل له شرط عرض (ConditionalOn)، نضيف data-show-if إلى div الحاوي ونخفيه افتراضيًا. ستقوم checkConditionals لاحقًا بإظهار الحقل إذا تحقق الشرط.
    var showIf  = condOn ? ' data-show-if="' + condOn + ':' + condVal + '" style="display:none"' : '';
    var val     = savedVal || field.display_value || '';

    var html = '<div class="fg ' + cssCol + '"' + showIf + '>';
    html += '<label for="' + id + '">';
    if (req) html += '<span class="req">* </span>';
    html += esc(field.FieldLabel) + '</label>';
    // بناء السلاسل الخاصة بالسمات المطلوبة (required) والقراءة فقط (readonly) والتعطيل (disabled) بناءً على خصائص الحقل وحالة القراءة فقط. هذه السلاسل ستُضاف إلى عناصر الإدخال لتفعيل السلوك المناسب.
    //هذه موجودة بنفس اسمائها الطبيعية في input tag
    var reqA = req ? ' required' : '';
    var roA  = ro  ? ' readonly' : '';
    var disA = ro && type === 'select' ? ' disabled' : '';

    if (type === 'text' || type === 'number' || type === 'email' || type === 'date') {
        html += '<input type="' + type + '" id="' + id + '" name="' + name
              + '" value="' + esc(val) + '"' + reqA + roA + '>';

    } else if (type === 'textarea') {
        html += '<textarea id="' + id + '" name="' + name + '"' + reqA + roA + '>'
              + esc(val) + '</textarea>';

    } else if (type === 'select') {
        html += '<select id="' + id + '" name="' + name + '"' + reqA + disA + '>';
        html += '<option value="">-- اختر --</option>';
        // إذا كانت هناك خيارات ديناميكية (dynOpts) تأتي من السيرفر، نستخدمها بدلاً من FieldOptions الثابتة. هذا يسمح بتوليد خيارات تعتمد على بيانات أخرى أو قواعد معينة في السيرفر.
        if (dynOpts.length > 0) {
            dynOpts.forEach(function(opt) {
                var sel = (String(opt.id) === String(val)) ? ' selected' : '';
                html += '<option value="' + esc(opt.id) + '"' + sel + '>' + esc(opt.label) + '</option>';
            });
        } else if (opts) {
            opts.split(',').forEach(function(o) {
                o = o.trim();
                html += '<option value="' + esc(o) + '"' + (o === val ? ' selected' : '') + '>'
                      + esc(o) + '</option>';
            });
        }
        html += '</select>';

    } else if (type === 'radio') {
        html += '<div class="opts">';
        opts.split(',').forEach(function(o) {
            o = o.trim();
            var dis = ro ? ' disabled' : '';
            html += '<label><input type="radio" name="' + name + '" value="' + esc(o) + '"'
                  + (o === val ? ' checked' : '') + dis + reqA + '> ' + esc(o) + '</label>';
        });
        html += '</div>';

    } else if (type === 'checkbox' || type === 'checkbox_group') {
        var checked = val ? val.split(',') : [];
        html += '<div class="opts">';
        opts.split(',').forEach(function(o) {
            o = o.trim();
            var dis = ro ? ' disabled' : '';
            html += '<label><input type="checkbox" name="' + name + '[]" value="' + esc(o) + '"'
                  + (checked.indexOf(o) !== -1 ? ' checked' : '') + dis + '> ' + esc(o) + '</label>';
        });
        html += '</div>';

    } else if (type === 'file' || type === 'signature') {
        // الهيكل الموحد: uploads/forms/{formId}/{submissionId}/filename
        var subId = PAGE_SUB_ID || 0;
        if (ro && val) {
            var fileUrl = 'uploads/forms/' + PAGE_FORM_ID + '/' + subId + '/' + esc(val);
            html += '<a href="' + fileUrl + '" target="_blank" style="color:#1d5c36;text-decoration:underline;"> ' + esc(val) + '</a>';
        }
        else if (ro) {
            html += '<span style="font-size:12px;color:#666;">لا يوجد ملف مرفوع</span>';
        }
        else {
            html += '<input type="file" id="' + id + '" name="' + name + '"' + reqA + '>';
            if (val) {
                var fileUrl2 = 'uploads/forms/' + PAGE_FORM_ID + '/' + subId + '/' + esc(val);
                html += '<small><a href="' + fileUrl2 + '" target="_blank" style="color:#666;">الملف الحالي: ' + esc(val) + '</a></small>';
            }
        }
    }

    html += '<span class="ferr" id="err_' + id + '"></span>';
    html += '</div>';
    // يتم إرجاع HTML الخاص بالحقل ليتم تضمينه في بناء النموذج الكامل في `renderForm()` أو `renderRepeatRow()`.
    return html;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////
// ── 5. صف التكرار ──
// renderRepeatRow(fields, readOnly, rowNum): Render one repeated group instance.
// Purpose: create a grouped set of fields for repeatable sections with remove button.
// Used in: `renderForm()` and `addRepeatRow()` when inserting new repeat instances.
function renderRepeatRow(fields, readOnly, rowNum) {
    var html = '<div class="repeat-group" id="rg_' + fields[0].FieldID + '_' + rowNum + '">';
    html += '<div class="repeat-index">المؤهل رقم ' + rowNum + '</div>';
    if (!readOnly && rowNum > 1) {
        html += '<button type="button" class="repeat-remove-btn" '
              + 'onclick="removeRepeatRow(' + fields[0].FieldID + ',' + rowNum + ')">حذف</button>';
    }
    fields.forEach(function(field) {
        //سيقوم برندرة الحقول التي عدد تكرارها أكبر من 1 بإضافة زر "حذف" لكل صف تكرار (باستثناء الصف الأول الذي لا يحتوي على زر حذف). عند الضغط على زر الحذف، سيتم استدعاء الدالة removeRepeatRow مع معرف الحقل الأساسي ورقم الصف لإزالة هذا الصف من DOM.
        html += renderField(field, '', readOnly, 'r' + rowNum + '_');
    });
    html += '</div>';
    return html;
}

// addRepeatRow(baseId, maxRepeat): Insert a new repeat row into the DOM.
// Purpose: allow user to add another repeated entry (up to `maxRepeat`).
// Used in: repeat-section "+ إضافة مؤهل آخر" button click.
function addRepeatRow(baseId, maxRepeat) {
    var wrapper = document.getElementById('rw_' + baseId);
    if (!wrapper) return;
    var current = wrapper.querySelectorAll('.repeat-group').length;
    if (current >= maxRepeat) { 
        showMsg('الحد الأقصى ' + maxRepeat + ' مؤهلات.', 'err');
        return;
    }
    var newNum  = current + 1;
    var fields  = window['rf_' + baseId];
    var readOnly = window['rro_' + baseId];
    if (!fields) return;
    var div = document.createElement('div');
    div.innerHTML = renderRepeatRow(fields, readOnly, newNum);
    var addBtn = wrapper.querySelector('.repeat-add-btn');
    wrapper.insertBefore(div.firstChild, addBtn);
    window['rc_' + baseId] = newNum;
}

// removeRepeatRow(baseId, rowNum): Remove a repeated row by DOM id.
// Purpose: let user delete a specific repeated entry.
// Used in: the remove button rendered by `renderRepeatRow()`.
function removeRepeatRow(baseId, rowNum) {
    var row = document.getElementById('rg_' + baseId + '_' + rowNum);
    if (row) row.remove();
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////
// ── 6. الحقول الشرطية ──
// ConditionalOn يحتوي على FieldName (مثل 'coordinator_decision')
// لكن عناصر HTML تستخدم FieldID كـ name (مثل '38')
// نحوّل FieldName → FieldID عبر fieldNameToId
// checkConditionals(): Show/hide fields based on conditional rules.
// Purpose: evaluate `data-show-if` attributes and toggle visibility accordingly.
// Used in: after rendering the form and on `change` events of the form.
//الفكرة بكل اختصار هو انه قاعدة البيانات لديها القدرة على تحديد أن حقل معين يظهر فقط إذا كان حقل آخر يساوي قيمة معينة. في الواجهة الأمامية، نستخدم خاصية data-show-if لتخزين هذه القاعدة على العنصر الذي يجب إظهاره أو إخفاؤه. عندما يتم تحميل النموذج أو عندما يتغير أي حقل في النموذج، نقوم بفحص جميع العناصر التي تحتوي على data-show-if، ونقيم الشرط المحدد فيها. إذا تحقق الشرط (أي أن الحقل المشار إليه يساوي القيمة المتوقعة)، نظهر العنصر؛ وإلا، نخفيه. هذا يسمح بإنشاء نماذج ديناميكية تتكيف مع إدخالات المستخدم بشكل فوري دون الحاجة إلى إعادة تحميل الصفحة.
function checkConditionals() {//هناك حقول شرطية في النموذج تظهر أو تختفي بناءً على قيمة حقل آخر.
    document.querySelectorAll('[data-show-if]').forEach(function(el) {
        //gettAttribute is a method that retrieves the value of an attribute from an HTML element. In this case, it gets the value of the "data-show-if" attribute, which contains a condition in the format "FieldName:ExpectedValue". We then split this string by the colon to separate the FieldName and the ExpectedValue.
        var parts     = el.getAttribute('data-show-if').split(':');
        var fieldName = parts[0];                            // coordinator_decision
        var fval      = parts.slice(1).join(':');            // قبول مشروط,slice here is used to handle cases where the expected value itself might contain colons. By slicing from index 1 to the end and joining with a colon, we ensure that we get the full expected value even if it contains colons.
        var curVal    = '';

        // نحوّل FieldName → FieldID → name الفعلي في HTML
        var fieldId   = fieldNameToId[fieldName];            // 38
        var htmlName  = fieldId ? String(fieldId) : fieldName; // '38'

        // نبحث عن radio مختار
        // لأن الحقول الشرطية قد تعتمد على أنواع مختلفة من الحقول (نصوص، قوائم، راديو، إلخ)، نحتاج إلى طريقة مرنة لاستخراج القيمة الحالية. أولاً، نحاول العثور على زر راديو مختار بنفس الاسم (لأن الحقول الشرطية غالبًا ما تعتمد على خيارات الراديو). إذا وجدنا واحدًا، نستخدم قيمته. إذا لم نجد زر راديو مختار، نحاول العثور على عنصر آخر (مثل select أو input أو textarea) بنفس الاسم ونستخدم قيمته. 
        var radioChecked = document.querySelector('input[type="radio"][name="'+htmlName+'"]:checked');
        if (radioChecked) {
            curVal = radioChecked.value;
        } else {
            var ctrl = document.querySelector(
                'select[name="'+htmlName+'"], ' +
                'input[name="'+htmlName+'"], ' +
                'textarea[name="'+htmlName+'"]'
            );
            if (ctrl) curVal = ctrl.value;
        }
        // أخيرًا، نقارن القيمة الحالية بالقيمة المتوقعة (fval) ونقرر ما إذا كنا سنظهر العنصر الشرطي أم لا. إذا كانت القيم متساوية، نظهر العنصر (display: '' يعني استخدام العرض الافتراضي). إذا لم تكن متساوية، نخفي العنصر (display: 'none').
        //العرض الافتراضي قيمته الافتراضية هي اظهار العنصر حسب نوعه (block, inline, inline-block, etc.)، وعندما نضع display: 'none'، نخفي العنصر تمامًا من الصفحة. هذا يسمح لنا بالتحكم في ظهور الحقول الشرطية بشكل ديناميكي بناءً على إدخالات المستخدم.
        el.style.display = (curVal === fval) ? '' : 'none';
    });
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////
// ── 7. التحقق من صحة الحقول ──
// validateForm(): Client-side validation of visible form inputs.
// Purpose: check required fields, types (email, number, date), and file presence.
// Used in: before submitting (`submitForm()`) to prevent invalid submissions.
function validateForm() {
    var form  = document.getElementById('dynamicForm');
    var valid = true;
    var done  = {};

    // إصلاح: تنظيف .ferr (وليس .err) لأن span رسائل الخطأ اسمه ferr
    form.querySelectorAll('.err').forEach(function(e){
        e.classList.remove('err');
    });
    form.querySelectorAll('.ferr').forEach(function(e){
        e.classList.remove('show');
        e.textContent = ''; });

    form.querySelectorAll('input,select,textarea').forEach(function(f) {
        if (f.disabled || f.readOnly || f.type === 'hidden') return;

        var parentDiv = f.closest('[data-show-if]');
        if (parentDiv && parentDiv.style.display === 'none') 
            return;

        var name = f.name;
        if (!name) return;

        if (f.type === 'radio') {
            if (done[name]) return;
            done[name] = true;
            if (f.required && !form.querySelector('[name="'+name+'"]:checked')) {
                markErr(f, 'يرجى اختيار أحد الخيارات.'); valid = false;
            }
            return;
        }

        if (f.type === 'checkbox') return;

        if (f.type === 'file') {
            if (f.required && (!f.files || !f.files.length)) {
                markErr(f, 'يرجى رفع الملف.'); valid = false;
            }
            return;
        }

        if (f.required && f.value.trim() === '') {
            markErr(f, 'هذا الحقل مطلوب.'); valid = false; return;
        }

        if (f.value.trim() !== '') {
            if (f.type === 'email' && !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(f.value)) {
                markErr(f, 'بريد إلكتروني غير صحيح.'); valid = false;
            } 
            else if (f.type === 'number' && isNaN(parseFloat(f.value))) {
                markErr(f, 'يرجى إدخال رقم صحيح.'); valid = false;
            } 
            else if (f.type === 'date' && !/^\d{4}-\d{2}-\d{2}$/.test(f.value)) {
                markErr(f, 'تاريخ غير صحيح (يجب أن يكون YYYY-MM-DD).'); valid = false;
            }
        }
    });

    if (!valid) {
        var first = form.querySelector('.err');
        if (first) { first.scrollIntoView({behavior:'smooth',block:'center'}); first.focus(); }
    }
    return valid;
}

// markErr(input, msg): Mark a single input as having an error and show message.
// Purpose: add `.err` class and populate the corresponding `.ferr` span.
// Used in: `validateForm()` and other validation paths.
function markErr(input, msg) {
    //classList is a property of DOM elements that provides methods to manipulate the list of classes on that element. In this case, we use classList.add('err') to add the 'err' class to the input element, which can be styled with CSS to indicate that there is a validation error (e.g., by changing the border color to red).
    input.classList.add('err');
    var errEl = document.getElementById('err_' + input.id);
    if (errEl) { errEl.textContent = msg; errEl.classList.add('show'); }
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////
// ── 8. إرسال النموذج ──
// submitForm(): Gather form values/files and POST them to `saveForm.php`.
// Purpose: prepare FormData payload including files and values JSON then send.
// Used in: user action when pressing the primary submit button (or programmatic calls).
function submitForm() {
    if (!validateForm()) 
        return;

    var form     = document.getElementById('dynamicForm');
    var formData = new FormData();
    formData.append('formId',       PAGE_FORM_ID);
    formData.append('stepId',       currentStepId);
    formData.append('submissionId', PAGE_SUB_ID);

    var values = [];
    var done   = {};// نستخدم done لتتبع الحقول التي تم معالجتها بالفعل، خاصة بالنسبة لحقول الراديو والمربعات الاختيارية التي قد يكون لها نفس الاسم لعدة خيارات. هذا يمنعنا من معالجة نفس الحقل عدة مرات.
    // نجمع قيم الحقول من النموذج. نتجاهل الحقول المعطلة أو للقراءة فقط أو المخفية (بسبب الشروط). بالنسبة لحقول الراديو، نأخذ القيمة المختارة فقط. بالنسبة لحقول المربعات الاختيارية، نجمع كل القيم المختارة وننضمها بفواصل. بالنسبة لحقول الملفات، نضيف الملف إلى FormData ونضع قيمة "FILE_UPLOADED" في JSON للإشارة إلى وجود ملف مرفوع لهذا الحقل.
    form.querySelectorAll('input,select,textarea').forEach(function(input) {
        var name = input.name;
        if (!name || input.disabled || input.readOnly || done[name]) return;

        var rawFieldId = name.split('_')[0];
        var fieldId    = parseInt(rawFieldId, 10);
        if (!fieldId) return;

        if (input.type === 'radio') {
            done[name] = true;
            var ch = form.querySelector('[name="'+name+'"]:checked');
            values.push({ fieldId: fieldId, value: ch ? ch.value : '' });

        } else if (input.type === 'checkbox') {
            done[name] = true;
            var vals = [];
            form.querySelectorAll('[name="'+name+'"]:checked').forEach(function(c){ vals.push(c.value); });
            values.push({ fieldId: fieldId, value: vals.join(',') });

        } 
        else if (input.type === 'file') {
            done[name] = true;
            if (input.files && input.files.length) {

                formData.append(String(fieldId), input.files[0]);
                values.push({ fieldId: fieldId, value: 'FILE_UPLOADED' });
            }

        } else if (input.type !== 'hidden') {
            done[name] = true;
            values.push({ fieldId: fieldId, value: input.value });
        }
    });

    formData.append('values', JSON.stringify(values));

    fetch('saveForm.php', { method: 'POST', body: formData })
    .then(function(res){ 
        return res.json();
    })
    .then(function(data){
        showMsg(data.message, data.success ? 'ok' : 'err');
        if (data.success) 
            setTimeout(function(){ window.location.href = 'dashboard.php'; }, 1500);
    })
    .catch(function(){ 
        showMsg('خطأ في الإرسال.', 'err');
     });
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////
// ── 9. إجراءات المراجع ──
// sendAction(action): Handler for reviewer actions (approve/reject/return).
// Purpose: collect current-step values, optional notes, files and send to `actionForm.php`.
// Used in: approval workflow buttons rendered by `renderForm()` when user can act.
function sendAction(action) {
    var labels = { approve: 'الموافقة', reject: 'الرفض', return: 'الإرجاع' };
    if (!confirm('هل أنت متأكد من قرار ' + labels[action] + '؟')) return;

    var notes = '';
    if (action === 'return') { notes = prompt('ملاحظات عن سبب الارجاع/الرفض:') || ''; }

    // ── جمع قيم الحقول الخاصة بهذه الخطوة لحفظها ──
    var form   = document.getElementById('dynamicForm');
    var values = [];
    var done   = {};

    if (form) {
        form.querySelectorAll('input,select,textarea').forEach(function(input) {
            var name = input.name;
            if (!name || input.disabled || input.readOnly || done[name]) return;

            // تجاهل الحقول من خطوات سابقة (readonly)
            var parentSection = input.closest('.f-section-readonly');
            if (parentSection) return;

            var rawFieldId = name.split('_')[0];
            var fieldId    = parseInt(rawFieldId, 10);
            if (!fieldId) return;

            if (input.type === 'radio') {
                done[name] = true;
                var ch = form.querySelector('[name="'+name+'"]:checked');
                values.push({ fieldId: fieldId, value: ch ? ch.value : '' });

            } else if (input.type === 'checkbox') {
                done[name] = true;
                var vals = [];
                form.querySelectorAll('[name="'+name+'"]:checked')
                    .forEach(function(c){ vals.push(c.value); });
                values.push({ fieldId: fieldId, value: vals.join(',') });

            } else if (input.type === 'file') {

            } else if (input.type !== 'hidden') {
                done[name] = true;
                values.push({ fieldId: fieldId, value: input.value });
            }
        });
    }

    var fd = new FormData();
    fd.append('action',       action);
    fd.append('notes',        notes);
    fd.append('formId',       PAGE_FORM_ID);
    fd.append('stepId',       currentStepId);
    fd.append('submissionId', PAGE_SUB_ID);
    fd.append('values',       JSON.stringify(values));

    // إرفاق ملفات الخطوة الحالية إن وجدت
    if (form) {
        form.querySelectorAll('input[type="file"]').forEach(function(input) {
            if (input.files && input.files.length) {
                var rawId  = input.name.split('_')[0];
                var fid    = parseInt(rawId, 10);
                if (fid) fd.append(String(fid), input.files[0]);
            }
        });
    }

    fetch('actionForm.php', { method: 'POST', body: fd })
    .then(function(res){ return res.json(); })
    .then(function(data){
        showMsg(data.message, data.success ? 'ok' : 'err');
        if (data.success) setTimeout(function(){ window.location.href = 'dashboard.php'; }, 1500);
    })
    .catch(function(){ showMsg('خطأ.', 'err'); });
}
