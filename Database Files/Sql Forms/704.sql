USE MPA2;
-- ------------------------------------------------------------
-- ------------------------------------------------------------
-- FORM 3-704 : نموذج اعتماد مشروع خطة رسالة جامعية
-- ------------------------------------------------------------
-- ------------------------------------------------------------
INSERT INTO FormTypes (FormTypeID,Code,Name,Description,DisplayOrder,IsStartingForm,Category) VALUES
(3,'704','نموذج اعتماد مشروع خطة رسالة جامعية','اعتماد خطة الرسالة كاملةً بعد موافقة اللجنة',3,0,'Supervision');

INSERT INTO FormWorkflowSteps (StepID,FormTypeID,StepName,StepOrder,AllowedRole,RequiresSpecificUser) VALUES
(9,3,'اختيار المشرف وعنوان الرسالة — الطالب',1,'Student',FALSE),
(10,3,'موافقة المشرف المقترح',2,'Supervisor',TRUE),
(11,3,'مراجعة منسق البرنامج',3,'ProgramCoordinator',FALSE),
(12,3,'اعتماد رئيس القسم',4,'HeadOfSection',FALSE),
(13,3,'تعبئة عناوين مشروع الخطة — الطالب',5,'Student',FALSE),
(14,3,'اعتماد المشرف النهائي للخطة',6,'Supervisor',TRUE);

INSERT INTO FormSections (SectionID,StepID,SectionName,SectionOrder) VALUES
(18,9,'اختيار المشرف وعنوان الرسالة',1),
(19,10,'موافقة المشرف',1),
(20,11,'مراجعة منسق البرنامج',1),
(21,12,'اعتماد رئيس القسم',1),
(22,13,'عناوين الخطة — أولاً: خلفية المشكلة',1),
(23,13,'عناوين الخطة — ثانياً: الإطار النظري',2),
(24,13,'عناوين الخطة — ثالثاً: المنهجية',3),
(25,13,'عناوين الخطة — رابعاً: النتائج',4),
(26,13,'عناوين الخطة — خامساً: الخاتمة والمراجع',5),
(27,14,'اعتماد المشرف النهائي',1);

INSERT INTO FormFields (FieldID,SectionID,FieldLabel,FieldName,FieldType,FieldOptions,IsRequired,IsReadOnly,IsAutoFill,IsRepeatable,MaxRepeat,DataSource,ConditionalOn,ConditionalValue,FieldOrder,CSSClass) VALUES
(84,18,'القسم (تلقائي)','department','text',NULL,TRUE,TRUE,TRUE,FALSE,1,'Students.Programs.Sections.SectionName',NULL,NULL,1,'col-6'),
(85,18,'الكلية (تلقائية)','faculty','text',NULL,TRUE,TRUE,TRUE,FALSE,1,'Students.Programs.Sections.Departments.DepartmentName',NULL,NULL,2,'col-6'),
(86,18,'المشرف المقترح','supervisor_id','select','__dynamic:Supervisors.SupervisorID:full_name_rank',TRUE,FALSE,FALSE,FALSE,1,'Supervisors',NULL,NULL,3,'col-8'),
(87,18,'الرتبة الأكاديمية للمشرف','supervisor_rank','text',NULL,TRUE,TRUE,TRUE,FALSE,1,'Supervisors.AcademicRank',NULL,NULL,4,'col-4'),
(88,18,'عنوان الرسالة المقترح','thesis_title','textarea',NULL,TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,5,'col-12'),
-- ── Sec 19: موافقة المشرف ───────────────────────────────────────────
(89,19,'اسم الطالب (تلقائي)','student_name','text',NULL,TRUE,TRUE,TRUE,FALSE,1,'Students.Users.full_name',NULL,NULL,1,'col-6'),
(90,19,'الرقم الجامعي (تلقائي)','student_id','text',NULL,TRUE,TRUE,TRUE,FALSE,1,'Students.UniversityID',NULL,NULL,2,'col-6'),
(91,19,'التخصص (تلقائي)','specialty','text',NULL,TRUE,TRUE,TRUE,FALSE,1,'Students.Programs.ProgramName',NULL,NULL,3,'col-6'),
(92,19,'فصل الالتحاق (تلقائي)','semester','text',NULL,TRUE,TRUE,TRUE,FALSE,1,'Students.EnrollmentSemester',NULL,NULL,4,'col-6'),
(93,19,'العام الدراسي (تلقائي)','academic_year','text',NULL,TRUE,TRUE,TRUE,FALSE,1,'Students.EnrollmentYear',NULL,NULL,5,'col-6'),
(94,19,'عنوان الرسالة المقترح (تلقائي)','thesis_title_ro','textarea',NULL,TRUE,TRUE,TRUE,FALSE,1,'FormValues.form704.thesis_title',NULL,NULL,6,'col-12'),
(95,19,'رأي المشرف','supervisor_opinion','textarea',NULL,FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,7,'col-12'),
(96,19,'قرار المشرف','supervisor_decision','radio','أوافق على الإشراف,أرفض الإشراف',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,8,'col-12'),
(97,19,'توقيع المشرف (صورة)','supervisor_signature','file',NULL,TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,9,'col-6'),
(98,19,'تاريخ الموافقة','supervisor_date','date',NULL,TRUE,TRUE,TRUE,FALSE,1,'CURRENT_DATE',NULL,NULL,10,'col-6'),
-- ── Sec 20: مراجعة منسق البرنامج ────────────────────────────────────
(99,20,'توصية منسق البرنامج','coordinator_notes','textarea',NULL,FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,1,'col-12'),
(100,20,'قرار منسق البرنامج','coordinator_decision','radio','موافقة,رفض,إرجاع للتعديل',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,2,'col-12'),
(101,20,'توقيع منسق البرنامج (صورة)','coordinator_signature','file',NULL,TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,3,'col-6'),
(102,20,'تاريخ التوصية','coordinator_date','date',NULL,TRUE,TRUE,TRUE,FALSE,1,'CURRENT_DATE',NULL,NULL,4,'col-6'),
-- ── Sec 21: اعتماد رئيس القسم ───────────────────────────────────────
(103,21,'تنسيب لجنة الدراسات في القسم','head_notes','textarea',NULL,FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,1,'col-12'),
(104,21,'قرار رئيس القسم','head_decision','radio','موافقة,رفض,إرجاع للتعديل',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,2,'col-12'),
(105,21,'توقيع رئيس القسم (صورة)','head_signature','file',NULL,TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,3,'col-6'),
(106,21,'تاريخ التنسيب','head_date','date',NULL,TRUE,TRUE,TRUE,FALSE,1,'CURRENT_DATE',NULL,NULL,4,'col-6'),
-- ── Sec 22: عناوين الخطة — أولاً: خلفية المشكلة (9 عناصر) ─────────
(107,22,'المقدمة','outline_intro','checkbox','مُنجز',FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,1,'col-6'),
(108,22,'مشكلة البحث','outline_problem','checkbox','مُنجز',FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,2,'col-6'),
(109,22,'أسئلة الدراسة','outline_questions','checkbox','مُنجز',FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,3,'col-6'),
(110,22,'فرضيات البحث','outline_hypotheses','checkbox','مُنجز',FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,4,'col-6'),
(111,22,'أهداف البحث','outline_objectives','checkbox','مُنجز',FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,5,'col-6'),
(112,22,'أهمية البحث','outline_importance','checkbox','مُنجز',FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,6,'col-6'),
(113,22,'حدود الدراسة','outline_limits','checkbox','مُنجز',FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,7,'col-6'),
(114,22,'مصطلحات الدراسة','outline_terms','checkbox','مُنجز',FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,8,'col-6'),
(115,22,'مصادر الدراسة','outline_sources','checkbox','مُنجز',FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,9,'col-6'),
-- ── Sec 23: عناوين الخطة — ثانياً: الإطار النظري (3 عناصر) ────────
(116,23,'الإطار النظري','outline_theory','checkbox','مُنجز',FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,1,'col-6'),
(117,23,'الدراسات السابقة','outline_prev_studies','checkbox','مُنجز',FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,2,'col-6'),
(118,23,'التعقيب على الدراسات السابقة','outline_review','checkbox','مُنجز',FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,3,'col-6'),
-- ── Sec 24: عناوين الخطة — ثالثاً: المنهجية (7 عناصر) ─────────────
(119,24,'مجتمع الدراسة','outline_population','checkbox','مُنجز',FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,1,'col-6'),
(120,24,'عينة الدراسة','outline_sample','checkbox','مُنجز',FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,2,'col-6'),
(121,24,'أداة الدراسة','outline_tool','checkbox','مُنجز',FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,3,'col-6'),
(122,24,'صدق الأداة','outline_validity','checkbox','مُنجز',FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,4,'col-6'),
(123,24,'ثبات الأداة','outline_reliability','checkbox','مُنجز',FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,5,'col-6'),
(124,24,'إجراءات التطبيق','outline_procedures','checkbox','مُنجز',FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,6,'col-6'),
(125,24,'التحليل الإحصائي','outline_stats','checkbox','مُنجز',FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,7,'col-6'),
-- ── Sec 25: عناوين الخطة — رابعاً: النتائج (وصفي) ─────────────────
(126,25,'وصف محتوى النتائج المتوقعة','outline_results_desc','textarea',NULL,FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,1,'col-12'),
-- ── Sec 26: عناوين الخطة — خامساً: الخاتمة والمراجع ────────────────
(127,26,'المراجع','outline_references','checkbox','مُنجز',FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,1,'col-6'),
(128,26,'الملاحق','outline_appendices','checkbox','مُنجز',FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,2,'col-6'),
(129,26,'توقيع الطالب (صورة)','student_signature','file',NULL,TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,3,'col-6'),
(130,26,'تاريخ تعبئة الطالب','student_date','date',NULL,TRUE,TRUE,TRUE,FALSE,1,'CURRENT_DATE',NULL,NULL,4,'col-6'),
-- ── Sec 27: اعتماد المشرف النهائي ──────────────────────────────────
(131,27,'رأي المشرف على عناوين الخطة','supervisor_final_notes','textarea',NULL,FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,1,'col-12'),
(132,27,'القرار النهائي للمشرف','supervisor_final_decision','radio','اعتماد الخطة,إرجاع للتعديل',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,2,'col-12'),
(133,27,'توقيع المشرف (صورة)','supervisor_final_signature','file',NULL,TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,3,'col-6'),
(134,27,'تاريخ الاعتماد','supervisor_final_date','date',NULL,TRUE,TRUE,TRUE,FALSE,1,'CURRENT_DATE',NULL,NULL,4,'col-6');
