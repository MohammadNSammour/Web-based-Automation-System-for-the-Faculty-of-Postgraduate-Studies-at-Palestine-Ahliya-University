USE MPA2;
-- ------------------------------------------------------------
-- ------------------------------------------------------------
-- FORM 1-700 : طلب الالتحاق ببرنامج دراسات عليا
-- ------------------------------------------------------------
-- ------------------------------------------------------------
INSERT INTO FormTypes (FormTypeID,Code,Name,Description,DisplayOrder,IsStartingForm,Category) VALUES
(1,'700','طلب الالتحاق ببرنامج دراسات عليا','نموذج تقديم الطالب للالتحاق بأحد برامج الدراسات العليا',1,1,'Enrollment');

INSERT INTO FormWorkflowSteps (StepID,FormTypeID,StepName,StepOrder,AllowedRole,RequiresSpecificUser) VALUES
-- 700
(1,1,'تعبئة الطلب من الطالب',1,'Student',FALSE),
(2,1,'مراجعة منسق البرنامج',2,'ProgramCoordinator',FALSE),
(3,1,'اعتماد رئيس القسم',3,'HeadOfSection',FALSE),-- remove
(4,1,'اعتماد عميد الكلية',4,'DeanOfFaculty',FALSE), 
(5,1,'قرار عميد الدراسات العليا',5,'DeanOfGradStudies',FALSE);-- remove

INSERT INTO FormSections (SectionID,StepID,SectionName,SectionOrder) VALUES
-- 700 → Steps 1–5
(1,1,'معلومات الالتحاق',1),
(2,1,'البيانات الشخصية',2),
(3,1,'-المؤهلات العلمية -حال توفرها',3),
(4,1,'نوع الدعم المالي',4),
(5,1,'المستندات المطلوبة',5),
(6,1,'إقرار الطالب',6),
(7,2,'مراجعة منسق البرنامج',1),
(8,3,'اعتماد رئيس القسم',1),
(9,4,'اعتماد عميد الكلية',1),
(10,5,'قرار عميد الدراسات العليا',1);

INSERT INTO FormFields (FieldID,SectionID,FieldLabel,FieldName,FieldType,FieldOptions,IsRequired,IsReadOnly,IsAutoFill,IsRepeatable,MaxRepeat,DataSource,ConditionalOn,ConditionalValue,FieldOrder,CSSClass) VALUES
-- ── Sec 1: معلومات الالتحاق ──────────────────────────────────────────
(1,1,'مستوى الدراسة','degree_level','radio','ماجستير,دكتوراه',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,1,'col-6'),
(2,1,'الفصل الدراسي','semester','select','الفصل الأول,الفصل الثاني,الفصل الصيفي',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,2,'col-6'),
(3,1,'العام الدراسي','academic_year','text',NULL,TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,3,'col-6'),
(4,1,'البرنامج المطلوب','program','select','__dynamic:Programs.ProgramNumber:ProgramName',TRUE,FALSE,FALSE,FALSE,1,'Programs',NULL,NULL,4,'col-6'),
(5,1,'القسم','department','text',NULL,TRUE,FALSE,FALSE,FALSE,1,'Programs.Sections.SectionName',NULL,NULL,5,'col-6'),
(6,1,'الكلية','faculty','text',NULL,TRUE,FALSE,FALSE,FALSE,1,'Programs.Sections.Departments.DepartmentName',NULL,NULL,6,'col-6'),
-- ── Sec 2: البيانات الشخصية ──────────────────────────────────────────
(7,2,'الاسم الأول','first_name','text',NULL,TRUE,TRUE,TRUE,FALSE,1,NULL,NULL,NULL,1,'col-6'),
(8,2,'اسم الأب','father_name','text',NULL,TRUE,TRUE,TRUE,FALSE,1,NULL,NULL,NULL,2,'col-6'),
(9,2,'اسم الجد','grandfather_name','text',NULL,TRUE,TRUE,TRUE,FALSE,1,NULL,NULL,NULL,3,'col-6'),
(10,2,'اسم العائلة','last_name','text',NULL,TRUE,TRUE,TRUE,FALSE,1,NULL,NULL,NULL,4,'col-6'),
(11,2,'الجنس','gender','radio','ذكر,أنثى',TRUE,TRUE,TRUE,FALSE,1,NULL,NULL,NULL,5,'col-6'),
(12,2,'تاريخ الميلاد','birth_date','date',NULL,TRUE,TRUE,TRUE,FALSE,1,NULL,NULL,NULL,6,'col-6'),
(13,2,'مكان الميلاد','birth_place','text',NULL,TRUE,TRUE,TRUE,FALSE,1,NULL,NULL,NULL,7,'col-6'),
(14,2,'الجنسية','nationality','text',NULL,TRUE,TRUE,TRUE,FALSE,1,NULL,NULL,NULL,8,'col-6'),
(15,2,'رقم الهوية أو جواز السفر','national_id','text',NULL,FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,9,'col-6'),
(16,2,'عنوان الإقامة','address','text',NULL,TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,10,'col-12'),
(17,2,'رقم الهاتف','phone','text',NULL,TRUE,TRUE,TRUE,FALSE,1,NULL,NULL,NULL,11,'col-6'),
(18,2,'البريد الإلكتروني','email','email',NULL,TRUE,TRUE,TRUE,FALSE,1,NULL,NULL,NULL,12,'col-6'),
(19,2,'مكان العمل الحالي','work_place','text',NULL,FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,13,'col-12'),
-- ── Sec 3: المؤهلات العلمية (قابلة للتكرار حتى 5 مرات) ──────────────
(20,3,'نوع الدرجة العلمية','degree_type','select','دبلوم,بكالوريوس,ماجستير',FALSE,FALSE,FALSE,TRUE,5,NULL,NULL,NULL,1,'col-4'),
(21,3,'اسم الجامعة أو الكلية','degree_university','text',NULL,FALSE,FALSE,FALSE,TRUE,5,NULL,NULL,NULL,2,'col-4'),
(22,3,'التخصص','degree_specialty','text',NULL,FALSE,FALSE,FALSE,TRUE,5,NULL,NULL,NULL,3,'col-4'),
(23,3,'المعدل التراكمي','degree_gpa','number',NULL,FALSE,FALSE,FALSE,TRUE,5,NULL,NULL,NULL,4,'col-4'),
(24,3,'التقدير','degree_appreciation','select','ممتاز,جيد جداً,جيد,مقبول',FALSE,FALSE,FALSE,TRUE,5,NULL,NULL,NULL,5,'col-4'),
(25,3,'سنة التخرج','degree_year','text',NULL,FALSE,FALSE,FALSE,TRUE,5,NULL,NULL,NULL,6,'col-4'),
-- ── Sec 4: نوع الدعم المالي ──────────────────────────────────────────
(26,4,'نوع الدعم المالي','funding_type','radio','ذاتي,منحة أو بعثة خارجية',FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,1,'col-12'),
(27,4,'اسم الجهة المانحة','funding_body','text',NULL,FALSE,FALSE,FALSE,FALSE,1,NULL,'funding_type','منحة أو بعثة خارجية',2,'col-6'),
(28,4,'رقم كتاب الموافقة','funding_letter_no','text',NULL,FALSE,FALSE,FALSE,FALSE,1,NULL,'funding_type','منحة أو بعثة خارجية',3,'col-6'),
-- ── Sec 5: المستندات المطلوبة ────────────────────────────────────────
(29,5,'شهادة الدرجة العلمية السابقة (مصدّقة)','doc_degree','file',NULL,TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,1,'col-12'),
(30,5,'كشف العلامات للدرجة العلمية السابقة','doc_transcript','file',NULL,TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,2,'col-12'),
(31,5,'شهادة الميلاد','doc_birth','file',NULL,TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,3,'col-12'),
(32,5,'صورة عن الهوية الشخصية','doc_id','file',NULL,TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,4,'col-12'),
(33,5,'صورة شخصية حديثة','doc_photo','file',NULL,TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,5,'col-12'),
(34,5,'شهادة الثانوية العامة','doc_secondary','file',NULL,TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,6,'col-12'),
-- ── Sec 6: إقرار الطالب ──────────────────────────────────────────────
(35,6,'أقرّ بأن جميع المعلومات المُدخلة صحيحة وكاملة','declaration','checkbox','أوافق',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,1,'col-12'),
(36,6,'توقيع الطالب (صورة التوقيع)','student_signature','file',NULL,FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,2,'col-6'),
(37,6,'تاريخ تعبئة الطلب','submission_date','date',NULL,TRUE,TRUE,TRUE,FALSE,1,'CURRENT_DATE',NULL,NULL,3,'col-6'),
-- ── Sec 7: مراجعة منسق البرنامج ──────────────────────────────────────
(38,7,'قرار منسق البرنامج','coordinator_decision','radio','قبول,قبول مشروط,رفض,إرجاع للتعديل',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,1,'col-12'),
(39,7,'المادة الاستدراكية الأولى','makeup_course_1','select','لا يوجد,أساسيات البحث العلمي,الإحصاء التطبيقي,مبادئ الإدارة,غيرها',FALSE,FALSE,FALSE,FALSE,1,NULL,'coordinator_decision','قبول مشروط',2,'col-4'),
(40,7,'المادة الاستدراكية الثانية','makeup_course_2','select','لا يوجد,أساسيات البحث العلمي,الإحصاء التطبيقي,مبادئ الإدارة,غيرها',FALSE,FALSE,FALSE,FALSE,1,NULL,'coordinator_decision','قبول مشروط',3,'col-4'),
(41,7,'المادة الاستدراكية الثالثة','makeup_course_3','select','لا يوجد,أساسيات البحث العلمي,الإحصاء التطبيقي,مبادئ الإدارة,غيرها',FALSE,FALSE,FALSE,FALSE,1,NULL,'coordinator_decision','قبول مشروط',4,'col-4'),
(42,7,'ملاحظات منسق البرنامج','coordinator_notes','textarea',NULL,FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,5,'col-12'),
(43,7,'توقيع منسق البرنامج (صورة)','coordinator_signature','file',NULL,FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,6,'col-6'),
(44,7,'تاريخ المراجعة','coordinator_date','date',NULL,TRUE,TRUE,TRUE,FALSE,1,'CURRENT_DATE',NULL,NULL,7,'col-6'),
-- ── Sec 8: اعتماد رئيس القسم ─────────────────────────────────────────
(45,8,'قرار رئيس القسم','head_decision','radio','موافقة,رفض,إرجاع للتعديل',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,1,'col-12'),
(46,8,'ملاحظات رئيس القسم','head_notes','textarea',NULL,FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,2,'col-12'),
(47,8,'توقيع رئيس القسم (صورة)','head_signature','file',NULL,FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,3,'col-6'),
(48,8,'تاريخ الاعتماد','head_date','date',NULL,TRUE,TRUE,TRUE,FALSE,1,'CURRENT_DATE',NULL,NULL,4,'col-6'),
-- ── Sec 9: اعتماد عميد الكلية ────────────────────────────────────────
(49,9,'قرار عميد الكلية','dean_decision','radio','موافقة,رفض,إرجاع للتعديل',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,1,'col-12'),
(50,9,'ملاحظات عميد الكلية','dean_notes','textarea',NULL,FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,2,'col-12'),
(51,9,'توقيع عميد الكلية (صورة)','dean_signature','file',NULL,FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,3,'col-6'),
(52,9,'تاريخ الاعتماد','dean_date','date',NULL,TRUE,TRUE,TRUE,FALSE,1,'CURRENT_DATE',NULL,NULL,4,'col-6'),
-- ── Sec 10: قرار عميد الدراسات العليا ───────────────────────────────
(53,10,'القرار النهائي','grad_decision','radio','قبول,قبول مشروط,رفض,إرجاع للتعديل',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,1,'col-12'),
(54,10,'توقيع عميد الدراسات العليا (صورة)','grad_signature','file',NULL,FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,2,'col-6');
