-- ════════════════════════════════════════════════════════════════════════
-- MPA — ملف النماذج الموحّد النهائي v2
-- مكتوب يدوياً من الصفر — كل حقل في قسمه الصحيح
--
-- جدول الترقيم:
-- نموذج 700: Steps 1–5  | Sections  1–10 | Fields   1–54
-- نموذج 701: Steps 6–8  | Sections 11–17 | Fields  55–79
-- نموذج 704: Steps 9–14 | Sections 18–27 | Fields  80–121
-- نموذج 708: Steps15–18 | Sections 28–35 | Fields 122–152
-- نموذج 705: Steps19–22 | Sections 36–43 | Fields 153–193
-- نموذج 707: Steps23–25 | Sections 44–65 | Fields 194–302
-- نموذج 714: Steps26–30 | Sections 66–71 | Fields 303–324
-- نموذج 716: Steps31–34 | Sections 72–76 | Fields 325–346
-- نموذج 720: Steps35–38 | Sections 77–83 | Fields 347–379
-- نموذج 721: Steps39–42 | Sections 84–90 | Fields 380–413
--
-- الإجمالي: 42 خطوة | 90 قسم | 413 حقل
-- ════════════════════════════════════════════════════════════════════════

USE MPA2;

-- ════════════════════════════════════════════════════════════════════════
-- FormTypes
-- ════════════════════════════════════════════════════════════════════════
INSERT INTO FormTypes (FormTypeID,Code,Name,Description,DisplayOrder,IsStartingForm,Category) VALUES
(1,'700','طلب الالتحاق ببرنامج دراسات عليا','نموذج تقديم الطالب للالتحاق بأحد برامج الدراسات العليا',1,1,'Enrollment');
INSERT INTO FormTypes (FormTypeID,Code,Name,Description,DisplayOrder,IsStartingForm,Category) VALUES
(2,'701','استمارة تعيين مشرف وإقرار خطة أطروحة','تعيين المشرف الأكاديمي وإقرار خطة البحث الأولية',2,0,'Supervision');
INSERT INTO FormTypes (FormTypeID,Code,Name,Description,DisplayOrder,IsStartingForm,Category) VALUES
(3,'704','نموذج اعتماد مشروع خطة رسالة جامعية','اعتماد خطة الرسالة كاملةً بعد موافقة اللجنة',3,0,'Supervision');
INSERT INTO FormTypes (FormTypeID,Code,Name,Description,DisplayOrder,IsStartingForm,Category) VALUES
(4,'720','تقرير المتابعة الشهرية للمشرف','تقرير شهري دوري عن لقاءات المشرف بالطالب',4,0,'Monitoring');
INSERT INTO FormTypes (FormTypeID,Code,Name,Description,DisplayOrder,IsStartingForm,Category) VALUES
(5,'721','تقرير متابعة لطلاب الدراسات العليا','تقرير شامل يُقدَّم عند تسليم الرسالة للمناقشة',5,0,'Monitoring');
INSERT INTO FormTypes (FormTypeID,Code,Name,Description,DisplayOrder,IsStartingForm,Category) VALUES
(6,'708','نموذج تعيين موعد المناقشة','خطاب رسمي من منسق البرنامج يقترح موعد مناقشة الرسالة',6,0,'Defense');
INSERT INTO FormTypes (FormTypeID,Code,Name,Description,DisplayOrder,IsStartingForm,Category) VALUES
(7,'705','محضر اجتماع تعيين الممتحنين','محضر اللجنة لتعيين الممتحن الداخلي والخارجي',7,0,'Defense');
INSERT INTO FormTypes (FormTypeID,Code,Name,Description,DisplayOrder,IsStartingForm,Category) VALUES
(8,'706','استجابة الممتحن على طلب المراجعة','نموذج استقبال استجابة الممتحن على دعوة المراجعة (قبول/رفض)',8,0,'Defense');
INSERT INTO FormTypes (FormTypeID,Code,Name,Description,DisplayOrder,IsStartingForm,Category) VALUES
(9,'707','تقرير ممتحن للرسائل العلمية والأطروحات الجامعية','تقييم الممتحن الشامل للرسالة — يُرسَل لكل ممتحن مستقلاً',9,0,'Defense');
INSERT INTO FormTypes (FormTypeID,Code,Name,Description,DisplayOrder,IsStartingForm,Category) VALUES
(10,'714','إتمام التعديلات لأطروحة ماجستير','إقرار لجنة المناقشة بأن الطالب أجرى التعديلات المطلوبة',10,0,'Completion');
INSERT INTO FormTypes (FormTypeID,Code,Name,Description,DisplayOrder,IsStartingForm,Category) VALUES
(11,'716','إجازة رسالة جامعية','قرار إجازة الرسالة موقّعاً من لجنة المناقشة الكاملة',11,0,'Completion');

-- ════════════════════════════════════════════════════════════════════════
-- FormWorkflowSteps (StepID 1–42)
-- ════════════════════════════════════════════════════════════════════════
INSERT INTO FormWorkflowSteps (StepID,FormTypeID,StepName,StepOrder,AllowedRole,RequiresSpecificUser) VALUES
-- 700
(1,1,'تعبئة الطلب من الطالب',1,'Student',FALSE),
(2,1,'مراجعة منسق البرنامج',2,'ProgramCoordinator',FALSE),
(3,1,'اعتماد رئيس القسم',3,'HeadOfSection',FALSE),-- remove
(4,1,'اعتماد عميد الكلية',4,'DeanOfFaculty',FALSE), 
(5,1,'قرار عميد الدراسات العليا',5,'DeanOfGradStudies',FALSE);-- remove
-- 701
INSERT INTO FormWorkflowSteps (StepID,FormTypeID,StepName,StepOrder,AllowedRole,RequiresSpecificUser) VALUES
(6,2,'اقتراح منسق البرنامج',1,'ProgramCoordinator',FALSE),
(7,2,'اعتماد رئيس القسم',2,'HeadOfSection',FALSE),
(8,2,'اعتماد عميد الكلية',3,'DeanOfFaculty',FALSE);
-- 704
INSERT INTO FormWorkflowSteps (StepID,FormTypeID,StepName,StepOrder,AllowedRole,RequiresSpecificUser) VALUES
(9,3,'اختيار المشرف وعنوان الرسالة — الطالب',1,'Student',FALSE),
(10,3,'موافقة المشرف المقترح',2,'Supervisor',TRUE),
(11,3,'مراجعة منسق البرنامج',3,'ProgramCoordinator',FALSE),
(12,3,'اعتماد رئيس القسم',4,'HeadOfSection',FALSE),
(13,3,'تعبئة عناوين مشروع الخطة — الطالب',5,'Student',FALSE),
(14,3,'اعتماد المشرف النهائي للخطة',6,'Supervisor',TRUE);
-- 708
INSERT INTO FormWorkflowSteps (StepID,FormTypeID,StepName,StepOrder,AllowedRole,RequiresSpecificUser) VALUES
(15,6,'اقتراح منسق البرنامج',1,'ProgramCoordinator',FALSE),
(16,6,'مراجعة رئيس القسم',2,'HeadOfSection',FALSE),
(17,6,'اعتماد عميد الكلية',3,'DeanOfFaculty',FALSE),
(18,6,'قرار عميد الدراسات العليا',4,'DeanOfGradStudies',FALSE);
-- 705
INSERT INTO FormWorkflowSteps (StepID,FormTypeID,StepName,StepOrder,AllowedRole,RequiresSpecificUser) VALUES
(19,7,'تعبئة المحضر — منسق البرنامج',1,'ProgramCoordinator',FALSE),
(20,7,'مراجعة رئيس القسم',2,'HeadOfSection',FALSE),
(21,7,'اعتماد عميد الكلية',3,'DeanOfFaculty',FALSE),
(22,7,'مصادقة عميد الدراسات العليا',4,'DeanOfGradStudies',FALSE);
-- 707
INSERT INTO FormWorkflowSteps (StepID,FormTypeID,StepName,StepOrder,AllowedRole,RequiresSpecificUser) VALUES
(23,9,'تقرير الممتحن',1,'Examiner',TRUE),
(24,9,'اعتماد عميد الكلية',2,'DeanOfFaculty',FALSE),
(25,9,'قرار لجنة الدراسات العليا',3,'DeanOfGradStudies',FALSE);
-- 714
INSERT INTO FormWorkflowSteps (StepID,FormTypeID,StepName,StepOrder,AllowedRole,RequiresSpecificUser) VALUES
(26,10,'إقرار المشرف ولجنة المناقشة',1,'Supervisor',FALSE),
(27,10,'مراجعة منسق البرنامج',2,'ProgramCoordinator',FALSE),
(28,10,'مراجعة رئيس القسم',3,'HeadOfSection',FALSE),
(29,10,'مصادقة رئيس اللجنة في الكلية',4,'DeanOfFaculty',FALSE),
(30,10,'مصادقة عميد الدراسات العليا',5,'DeanOfGradStudies',FALSE);
-- 716
INSERT INTO FormWorkflowSteps (StepID,FormTypeID,StepName,StepOrder,AllowedRole,RequiresSpecificUser) VALUES
(31,11,'إعداد قرار الإجازة من العمادة',1,'DeanOfFaculty',FALSE),
(32,11,'توقيع الممتحن الداخلي',2,'Examiner',TRUE),
(33,11,'توقيع الممتحن الخارجي',3,'Examiner',TRUE),
(34,11,'مصادقة عميد الدراسات العليا',4,'DeanOfGradStudies',FALSE);
-- 720
INSERT INTO FormWorkflowSteps (StepID,FormTypeID,StepName,StepOrder,AllowedRole,RequiresSpecificUser) VALUES
(35,4,'تعبئة التقرير الشهري — المشرف',1,'Supervisor',FALSE),
(36,4,'مراجعة منسق البرنامج',2,'ProgramCoordinator',FALSE),
(37,4,'اعتماد رئيس القسم',3,'HeadOfSection',FALSE),
(38,4,'اعتماد عميد الكلية',4,'DeanOfFaculty',FALSE);
-- 721
INSERT INTO FormWorkflowSteps (StepID,FormTypeID,StepName,StepOrder,AllowedRole,RequiresSpecificUser) VALUES
(39,5,'تقرير المشرف الشامل',1,'Supervisor',FALSE),
(40,5,'مراجعة منسق البرنامج',2,'ProgramCoordinator',FALSE),
(41,5,'اعتماد رئيس القسم',3,'HeadOfSection',FALSE),
(42,5,'اعتماد عميد الكلية',4,'DeanOfFaculty',FALSE);

-- ════════════════════════════════════════════════════════════════════════
-- FormSections (SectionID 1–90)
-- ════════════════════════════════════════════════════════════════════════
INSERT INTO FormSections (SectionID,StepID,SectionName,SectionOrder) VALUES
-- 700 → Steps 1–5
(1,1,'معلومات الالتحاق',1),
(2,1,'البيانات الشخصية',2),
(3,1,'المؤهلات العلمية',3),
(4,1,'نوع الدعم المالي',4),
(5,1,'المستندات المطلوبة',5),
(6,1,'إقرار الطالب',6),
(7,2,'مراجعة منسق البرنامج',1),
(8,3,'اعتماد رئيس القسم',1),
(9,4,'اعتماد عميد الكلية',1),
(10,5,'قرار عميد الدراسات العليا',1),
-- 701 → Steps 6–8
INSERT INTO FormSections (SectionID,StepID,SectionName,SectionOrder) VALUES
(11,6,'بيانات التخصص والبرنامج',1),
(12,6,'بيانات الطالب',2),
(13,6,'بيانات الأطروحة والمشرف',3),
(14,6,'المستندات الداعمة',4),
(15,6,'توقيع منسق البرنامج',5),
(16,7,'اعتماد رئيس القسم',1),
(17,8,'اعتماد عميد الكلية',1);
-- 704 → Steps 9–14
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
-- 708 → Steps 15–18
INSERT INTO FormSections (SectionID,StepID,SectionName,SectionOrder) VALUES
(28,15,'اختيار الطالب',1),
(29,15,'بيانات الطالب والرسالة',2),
(30,15,'الموعد المقترح للمناقشة',3),
(31,15,'الملفات الداعمة',4),
(32,15,'توقيع منسق البرنامج',5),
(33,16,'مراجعة رئيس القسم',1),
(34,17,'اعتماد عميد الكلية',1),
(35,18,'قرار عميد الدراسات العليا',1);
-- 705 → Steps 19–22
INSERT INTO FormSections (SectionID,StepID,SectionName,SectionOrder) VALUES
(36,19,'اختيار الطالب',1),
(37,19,'بيانات الاجتماع',2),
(38,19,'بيانات الرسالة والطالب',3),
(39,19,'أعضاء اللجنة الحاضرون',4),
(40,19,'تعيين الممتحنين',5),
(41,20,'مراجعة رئيس القسم',1),
(42,21,'اعتماد عميد الكلية',1),
(43,22,'مصادقة عميد الدراسات العليا',1);
-- 707 → Steps 23–25  (22 قسم للممتحن)
INSERT INTO FormSections (SectionID,StepID,SectionName,SectionOrder) VALUES
(44,23,'بيانات الطالب والرسالة',1),
(45,23,'بيانات الممتحن',2),
(46,23,'أولاً: ملخصات الرسالة',3),
(47,23,'ثانياً: مقدمة الرسالة',4),
(48,23,'ثالثاً: الإطار النظري والدراسات السابقة',5),
(49,23,'رابعاً: المنهجية',6),
(50,23,'خامساً: النتائج والمناقشة',7),
(51,23,'سادساً: الخاتمة والتوصيات',8),
(52,23,'سابعاً: المراجع والتوثيق',9),
(53,23,'ثامناً: الملاحق',10),
(54,23,'تاسعاً: الجدة والأصالة',11),
(55,23,'عاشراً: الالتزام بمناهج البحث',12),
(56,23,'حادي عشر: الموضوعية',13),
(57,23,'ثاني عشر: الأسلوب وشخصية الباحث',14),
(58,23,'ثالث عشر: التنظيم والترتيب',15),
(59,23,'رابع عشر: اللغة',16),
(60,23,'خامس عشر: التعامل مع التقنيات',17),
(61,23,'سادس عشر: التوثيق الداخلي للنص',18),
(62,23,'سابع عشر: نتائج البحث وتحليلها',19),
(63,23,'التوصية النهائية للممتحن',20),
(64,24,'للاستعمال الرسمي — اعتماد عميد الكلية',1),
(65,25,'قرار لجنة الدراسات العليا',1);
-- 714 → Steps 26–30
INSERT INTO FormSections (SectionID,StepID,SectionName,SectionOrder) VALUES
(66,26,'بيانات الطالب والرسالة',1),
(67,26,'توقيعات لجنة المناقشة',2),
(68,27,'مراجعة منسق البرنامج',1),
(69,28,'مراجعة رئيس القسم',1),
(70,29,'مصادقة رئيس اللجنة في الكلية',1),
(71,30,'مصادقة عميد الدراسات العليا',1);
-- 716 → Steps 31–34
INSERT INTO FormSections (SectionID,StepID,SectionName,SectionOrder) VALUES
(72,31,'بيانات الطالب والرسالة',1),
(73,31,'توقيع المشرف رئيس اللجنة',2),
(74,32,'توقيع الممتحن الداخلي',1),
(75,33,'توقيع الممتحن الخارجي',1),
(76,34,'مصادقة عميد الدراسات العليا',1);
-- 720 → Steps 35–38
INSERT INTO FormSections (SectionID,StepID,SectionName,SectionOrder) VALUES
(77,35,'اختيار الطالب',1),
(78,35,'بيانات الطالب',2),
(79,35,'تفاصيل اللقاء الشهري',3),
(80,35,'توقيعات الحضور',4),
(81,36,'مراجعة منسق البرنامج',1),
(82,37,'اعتماد رئيس القسم',1),
(83,38,'اعتماد عميد الكلية',1);
INSERT INTO FormSections (SectionID,StepID,SectionName,SectionOrder) VALUES
-- 721 → Steps 39–42
(84,39,'اختيار الطالب',1),
(85,39,'بيانات الطالب',2),
(86,39,'الفصول الدراسية المنجزة',3),
(87,39,'تقرير المشرف الشامل',4),
(88,40,'مراجعة منسق البرنامج',1),
(89,41,'اعتماد رئيس القسم',1),
(90,42,'اعتماد عميد الكلية',1);

-- ════════════════════════════════════════════════════════════════════════
-- FormFields — نموذج 700 (FieldID 1–54)
-- مرجع: النموذج الورقي طلب_الالتحاق_ببرنامج_دراسات_عليا__بعد_التعديل
-- ════════════════════════════════════════════════════════════════════════
-- FORMAT: (FieldID, SectionID, Label, Name, Type, Options,
--          IsRequired, IsReadOnly, IsAutoFill, IsRepeatable, MaxRepeat,
--          DataSource, ConditionalOn, ConditionalValue, FieldOrder, CSSClass)
INSERT INTO FormFields (FieldID,SectionID,FieldLabel,FieldName,FieldType,FieldOptions,IsRequired,IsReadOnly,IsAutoFill,IsRepeatable,MaxRepeat,DataSource,ConditionalOn,ConditionalValue,FieldOrder,CSSClass) VALUES
-- ── Sec 1: معلومات الالتحاق ──────────────────────────────────────────
(1,1,'مستوى الدراسة','degree_level','radio','ماجستير,دكتوراه',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,1,'col-6'),
(2,1,'الفصل الدراسي','semester','select','الفصل الأول,الفصل الثاني,الفصل الصيفي',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,2,'col-6'),
(3,1,'العام الدراسي','academic_year','text',NULL,TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,3,'col-6'),
(4,1,'البرنامج المطلوب','program','select','__dynamic:Programs.ProgramNumber:ProgramName',TRUE,FALSE,FALSE,FALSE,1,'Programs',NULL,NULL,4,'col-6'),
(5,1,'القسم','department','text',NULL,TRUE,TRUE,TRUE,FALSE,1,'Programs.Sections.SectionName',NULL,NULL,5,'col-6'),
(6,1,'الكلية','faculty','text',NULL,TRUE,TRUE,TRUE,FALSE,1,'Programs.Sections.Departments.DepartmentName',NULL,NULL,6,'col-6'),
-- ── Sec 2: البيانات الشخصية ──────────────────────────────────────────
(7,2,'الاسم الأول','first_name','text',NULL,TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,1,'col-6'),
(8,2,'اسم الأب','father_name','text',NULL,TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,2,'col-6'),
(9,2,'اسم الجد','grandfather_name','text',NULL,FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,3,'col-6'),
(10,2,'اسم العائلة','last_name','text',NULL,TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,4,'col-6'),
(11,2,'الجنس','gender','radio','ذكر,أنثى',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,5,'col-6'),
(12,2,'تاريخ الميلاد','birth_date','date',NULL,TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,6,'col-6'),
(13,2,'مكان الميلاد','birth_place','text',NULL,FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,7,'col-6'),
(14,2,'الجنسية','nationality','text',NULL,TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,8,'col-6'),
(15,2,'رقم الهوية أو جواز السفر','national_id','text',NULL,TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,9,'col-6'),
(16,2,'عنوان الإقامة','address','text',NULL,TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,10,'col-12'),
(17,2,'رقم الهاتف','phone','text',NULL,TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,11,'col-6'),
(18,2,'البريد الإلكتروني','email','email',NULL,TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,12,'col-6'),
(19,2,'مكان العمل الحالي','work_place','text',NULL,FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,13,'col-12'),
-- ── Sec 3: المؤهلات العلمية (قابلة للتكرار حتى 5 مرات) ──────────────
(20,3,'نوع الدرجة العلمية','degree_type','select','دبلوم,بكالوريوس,ماجستير',TRUE,FALSE,FALSE,TRUE,5,NULL,NULL,NULL,1,'col-4'),
(21,3,'اسم الجامعة أو الكلية','degree_university','text',NULL,TRUE,FALSE,FALSE,TRUE,5,NULL,NULL,NULL,2,'col-4'),
(22,3,'التخصص','degree_specialty','text',NULL,TRUE,FALSE,FALSE,TRUE,5,NULL,NULL,NULL,3,'col-4'),
(23,3,'المعدل التراكمي','degree_gpa','number',NULL,TRUE,FALSE,FALSE,TRUE,5,NULL,NULL,NULL,4,'col-4'),
(24,3,'التقدير','degree_appreciation','select','ممتاز,جيد جداً,جيد,مقبول',FALSE,FALSE,FALSE,TRUE,5,NULL,NULL,NULL,5,'col-4'),
(25,3,'سنة التخرج','degree_year','text',NULL,TRUE,FALSE,FALSE,TRUE,5,NULL,NULL,NULL,6,'col-4'),
-- ── Sec 4: نوع الدعم المالي ──────────────────────────────────────────
(26,4,'نوع الدعم المالي','funding_type','radio','ذاتي,منحة أو بعثة خارجية',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,1,'col-12'),
(27,4,'اسم الجهة المانحة','funding_body','text',NULL,FALSE,FALSE,FALSE,FALSE,1,NULL,'funding_type','منحة أو بعثة خارجية',2,'col-6'),
(28,4,'رقم كتاب الموافقة','funding_letter_no','text',NULL,FALSE,FALSE,FALSE,FALSE,1,NULL,'funding_type','منحة أو بعثة خارجية',3,'col-6'),
-- ── Sec 5: المستندات المطلوبة ────────────────────────────────────────
(29,5,'شهادة الدرجة العلمية السابقة (مصدّقة)','doc_degree','file',NULL,TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,1,'col-12'),
(30,5,'كشف العلامات للدرجة العلمية السابقة','doc_transcript','file',NULL,TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,2,'col-12'),
(31,5,'شهادة الميلاد','doc_birth','file',NULL,TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,3,'col-12'),
(32,5,'صورة عن الهوية الشخصية','doc_id','file',NULL,TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,4,'col-12'),
(33,5,'صورة شخصية حديثة','doc_photo','file',NULL,TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,5,'col-12'),
(34,5,'شهادة الثانوية العامة','doc_secondary','file',NULL,FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,6,'col-12'),
-- ── Sec 6: إقرار الطالب ──────────────────────────────────────────────
(35,6,'أقرّ بأن جميع المعلومات المُدخلة صحيحة وكاملة','declaration','checkbox','أوافق',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,1,'col-12'),
(36,6,'توقيع الطالب (صورة التوقيع)','student_signature','file',NULL,TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,2,'col-6'),
(37,6,'تاريخ تعبئة الطلب','submission_date','date',NULL,TRUE,TRUE,TRUE,FALSE,1,'CURRENT_DATE',NULL,NULL,3,'col-6'),
-- ── Sec 7: مراجعة منسق البرنامج ──────────────────────────────────────
(38,7,'قرار منسق البرنامج','coordinator_decision','radio','قبول,قبول مشروط,رفض,إرجاع للتعديل',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,1,'col-12'),
(39,7,'المادة الاستدراكية الأولى','makeup_course_1','select','لا يوجد,أساسيات البحث العلمي,الإحصاء التطبيقي,مبادئ الإدارة,غيرها',FALSE,FALSE,FALSE,FALSE,1,NULL,'coordinator_decision','قبول مشروط',2,'col-4'),
(40,7,'المادة الاستدراكية الثانية','makeup_course_2','select','لا يوجد,أساسيات البحث العلمي,الإحصاء التطبيقي,مبادئ الإدارة,غيرها',FALSE,FALSE,FALSE,FALSE,1,NULL,'coordinator_decision','قبول مشروط',3,'col-4'),
(41,7,'المادة الاستدراكية الثالثة','makeup_course_3','select','لا يوجد,أساسيات البحث العلمي,الإحصاء التطبيقي,مبادئ الإدارة,غيرها',FALSE,FALSE,FALSE,FALSE,1,NULL,'coordinator_decision','قبول مشروط',4,'col-4'),
(42,7,'ملاحظات منسق البرنامج','coordinator_notes','textarea',NULL,FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,5,'col-12'),
(43,7,'توقيع منسق البرنامج (صورة)','coordinator_signature','file',NULL,TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,6,'col-6'),
(44,7,'تاريخ المراجعة','coordinator_date','date',NULL,TRUE,TRUE,TRUE,FALSE,1,'CURRENT_DATE',NULL,NULL,7,'col-6'),
-- ── Sec 8: اعتماد رئيس القسم ─────────────────────────────────────────
(45,8,'قرار رئيس القسم','head_decision','radio','موافقة,رفض,إرجاع للتعديل',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,1,'col-12'),
(46,8,'ملاحظات رئيس القسم','head_notes','textarea',NULL,FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,2,'col-12'),
(47,8,'توقيع رئيس القسم (صورة)','head_signature','file',NULL,TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,3,'col-6'),
(48,8,'تاريخ الاعتماد','head_date','date',NULL,TRUE,TRUE,TRUE,FALSE,1,'CURRENT_DATE',NULL,NULL,4,'col-6'),
-- ── Sec 9: اعتماد عميد الكلية ────────────────────────────────────────
(49,9,'قرار عميد الكلية','dean_decision','radio','موافقة,رفض,إرجاع للتعديل',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,1,'col-12'),
(50,9,'ملاحظات عميد الكلية','dean_notes','textarea',NULL,FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,2,'col-12'),
(51,9,'توقيع عميد الكلية (صورة)','dean_signature','file',NULL,TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,3,'col-6'),
(52,9,'تاريخ الاعتماد','dean_date','date',NULL,TRUE,TRUE,TRUE,FALSE,1,'CURRENT_DATE',NULL,NULL,4,'col-6'),
-- ── Sec 10: قرار عميد الدراسات العليا ───────────────────────────────
(53,10,'القرار النهائي','grad_decision','radio','قبول,قبول مشروط,رفض,إرجاع للتعديل',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,1,'col-12'),
(54,10,'توقيع عميد الدراسات العليا (صورة)','grad_signature','file',NULL,TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,2,'col-6');

-- ════════════════════════════════════════════════════════════════════════
-- FormFields — نموذج 701 (FieldID 55–79)
-- مرجع: 2_701_استمارة_تعيين_مشرف_وإقرار_خطة_أطروحة.docx
-- ════════════════════════════════════════════════════════════════════════
INSERT INTO FormFields (FieldID,SectionID,FieldLabel,FieldName,FieldType,FieldOptions,IsRequired,IsReadOnly,IsAutoFill,IsRepeatable,MaxRepeat,DataSource,ConditionalOn,ConditionalValue,FieldOrder,CSSClass) VALUES
-- ── Sec 11: بيانات التخصص والبرنامج (تلقائية) ───────────────────────
(55,11,'اسم التخصص (البرنامج)','program_name','text',NULL,TRUE,TRUE,TRUE,FALSE,1,'Students.Programs.ProgramName',NULL,NULL,1,'col-6'),
(56,11,'القسم الأكاديمي','department_name','text',NULL,TRUE,TRUE,TRUE,FALSE,1,'Students.Programs.Sections.SectionName',NULL,NULL,2,'col-6'),
(57,11,'الكلية','faculty_name','text',NULL,TRUE,TRUE,TRUE,FALSE,1,'Students.Programs.Sections.Departments.DepartmentName',NULL,NULL,3,'col-6'),
-- ── Sec 12: بيانات الطالب (تلقائية من Students) ────────────────────
(58,12,'اسم الطالب الكامل','student_name','text',NULL,TRUE,TRUE,TRUE,FALSE,1,'Students.Users.full_name',NULL,NULL,1,'col-6'),
(59,12,'الرقم الجامعي','student_university_id','text',NULL,TRUE,TRUE,TRUE,FALSE,1,'Students.UniversityID',NULL,NULL,2,'col-6'),
(60,12,'تاريخ الالتحاق بالتخصص','enrollment_date','date',NULL,TRUE,TRUE,TRUE,FALSE,1,'Students.MajorJoinDate',NULL,NULL,3,'col-6'),
(61,12,'عدد الساعات المجتازة','completed_hours','number',NULL,TRUE,TRUE,TRUE,FALSE,1,'Students.TotalCompletedHours',NULL,NULL,4,'col-6'),
(62,12,'المعدل التراكمي','gpa','number',NULL,TRUE,TRUE,TRUE,FALSE,1,'Students.GPA',NULL,NULL,5,'col-6'),
-- ── Sec 13: بيانات الأطروحة والمشرف ────────────────────────────────
(63,13,'عنوان الأطروحة المقترح','thesis_title','textarea',NULL,TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,1,'col-12'),
(64,13,'المشرف الرئيسي','supervisor_id','select','__dynamic:Supervisors.SupervisorID:full_name_rank',TRUE,FALSE,FALSE,FALSE,1,'Supervisors',NULL,NULL,2,'col-6'),
(65,13,'الرتبة الأكاديمية للمشرف','supervisor_rank','text',NULL,TRUE,TRUE,TRUE,FALSE,1,'Supervisors.AcademicRank',NULL,NULL,3,'col-6'),
(66,13,'هل يوجد مشرف مشارك؟','has_co_supervisor','radio','نعم,لا',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,4,'col-12'),
(67,13,'المشرف المشارك','co_supervisor_id','select','__dynamic:Supervisors.SupervisorID:full_name_rank',FALSE,FALSE,FALSE,FALSE,1,'Supervisors','has_co_supervisor','نعم',5,'col-6'),
(68,13,'الرتبة الأكاديمية للمشرف المشارك','co_supervisor_rank','text',NULL,FALSE,TRUE,TRUE,FALSE,1,'Supervisors.AcademicRank',NULL,NULL,6,'col-6'),
(69,13,'التاريخ المتوقع لإنهاء الأطروحة','expected_end_date','date',NULL,FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,7,'col-6'),
-- ── Sec 14: المستندات الداعمة ────────────────────────────────────────
(70,14,'خطة الأطروحة الأولية','doc_thesis_plan','file',NULL,TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,1,'col-12'),
(71,14,'كشف درجات الطالب','doc_transcript','file',NULL,TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,2,'col-12'),
(72,14,'قرار لجنة البرنامج (إن وجد)','doc_committee_decision','file',NULL,FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,3,'col-12'),
-- ── Sec 15: توقيع منسق البرنامج ─────────────────────────────────────
(73,15,'ملاحظات منسق البرنامج','coordinator_notes','textarea',NULL,FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,1,'col-12'),
(74,15,'توقيع منسق البرنامج (صورة)','coordinator_signature','file',NULL,TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,2,'col-6'),
(75,15,'تاريخ الاستمارة','coordinator_date','date',NULL,TRUE,TRUE,TRUE,FALSE,1,'CURRENT_DATE',NULL,NULL,3,'col-6'),
-- ── Sec 16: اعتماد رئيس القسم ───────────────────────────────────────
(76,16,'قرار رئيس القسم','head_decision','radio','موافقة,رفض,إرجاع للتعديل',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,1,'col-12'),
(77,16,'ملاحظات رئيس القسم','head_notes','textarea',NULL,FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,2,'col-12'),
(78,16,'توقيع رئيس القسم (صورة)','head_signature','file',NULL,TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,3,'col-6'),
(79,16,'تاريخ الاعتماد','head_date','date',NULL,TRUE,TRUE,TRUE,FALSE,1,'CURRENT_DATE',NULL,NULL,4,'col-6'),
-- ── Sec 17: اعتماد عميد الكلية ──────────────────────────────────────
(80,17,'قرار عميد الكلية','dean_decision','radio','موافقة,رفض,إرجاع للتعديل',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,1,'col-12'),
(81,17,'ملاحظات عميد الكلية','dean_notes','textarea',NULL,FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,2,'col-12'),
(82,17,'توقيع عميد الكلية (صورة)','dean_signature','file',NULL,TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,3,'col-6'),
(83,17,'تاريخ الاعتماد','dean_date','date',NULL,TRUE,TRUE,TRUE,FALSE,1,'CURRENT_DATE',NULL,NULL,4,'col-6');

-- ════════════════════════════════════════════════════════════════════════
-- FormFields — نموذج 704 (FieldID 84–121)
-- مرجع: 704نموذج_اعتماد_مشروع_خطة_رسالة_جامعية_3.docx
-- ════════════════════════════════════════════════════════════════════════
-- ── Sec 18: اختيار المشرف وعنوان الرسالة — الطالب ──────────────────
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

-- ════════════════════════════════════════════════════════════════════════
-- FormFields — نموذج 708 (FieldID 135–162)
-- مرجع: نموذج_708_معدل.docx
-- ════════════════════════════════════════════════════════════════════════
INSERT INTO FormFields (FieldID,SectionID,FieldLabel,FieldName,FieldType,FieldOptions,IsRequired,IsReadOnly,IsAutoFill,IsRepeatable,MaxRepeat,DataSource,ConditionalOn,ConditionalValue,FieldOrder,CSSClass) VALUES
-- ── Sec 28: اختيار الطالب ───────────────────────────────────────────
(135,28,'اختر الطالب/ة','student_select','select','__dynamic:Students.StudentNumber:full_name_id|filter:Thesis.CurrentStage=defense_scheduling',TRUE,FALSE,FALSE,FALSE,1,'Students',NULL,NULL,1,'col-12'),
(136,28,'تاريخ اجتماع اللجنة التي أوصت بالمناقشة','committee_meeting_date','date',NULL,TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,2,'col-6'),
-- ── Sec 29: بيانات الطالب والرسالة (تلقائية) ────────────────────────
(137,29,'اسم الطالب/ة الكامل','student_name','text',NULL,TRUE,TRUE,TRUE,FALSE,1,'Students.Users.full_name',NULL,NULL,1,'col-6'),
(138,29,'الرقم الجامعي','student_id','text',NULL,TRUE,TRUE,TRUE,FALSE,1,'Students.UniversityID',NULL,NULL,2,'col-6'),
(139,29,'مستوى الدراسة','degree_level','text',NULL,TRUE,TRUE,TRUE,FALSE,1,'Students.Programs.ProgramName',NULL,NULL,3,'col-6'),
(140,29,'القسم الأكاديمي','department','text',NULL,TRUE,TRUE,TRUE,FALSE,1,'Students.Programs.Sections.SectionName',NULL,NULL,4,'col-6'),
(141,29,'عنوان الرسالة بالعربية','thesis_title_ar','textarea',NULL,TRUE,TRUE,TRUE,FALSE,1,'Thesis.ThesisName',NULL,NULL,5,'col-12'),
(142,29,'عنوان الرسالة بالإنجليزية (اختياري)','thesis_title_en','textarea',NULL,FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,6,'col-12'),
-- ── Sec 30: الموعد المقترح للمناقشة ─────────────────────────────────
(143,30,'التاريخ المقترح للمناقشة','defense_date','date',NULL,TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,1,'col-6'),
(144,30,'اليوم','defense_day','select','الأحد,الاثنين,الثلاثاء,الأربعاء,الخميس',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,2,'col-6'),
(145,30,'وقت المناقشة','defense_time','text',NULL,TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,3,'col-6'),
(146,30,'مكان المناقشة (القاعة / المبنى)','defense_venue','text',NULL,TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,4,'col-6'),
-- ── Sec 31: الملفات الداعمة ──────────────────────────────────────────
(147,31,'ملف نتيجة الفحص الأولي للرسالة','initial_review_file','file',NULL,TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,1,'col-12'),
(148,31,'تقرير فحص الاقتباس (Plagiarism)','plagiarism_report_file','file',NULL,TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,2,'col-12'),
(149,31,'نسبة الاقتباس (%)','plagiarism_percentage','number',NULL,TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,3,'col-6'),
(150,31,'أية ملفات داعمة إضافية','extra_support_file','file',NULL,FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,4,'col-12'),
-- ── Sec 32: توقيع منسق البرنامج ──────────────────────────────────────
(151,32,'ملاحظات منسق البرنامج','coordinator_notes','textarea',NULL,FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,1,'col-12'),
(152,32,'توقيع منسق البرنامج (صورة)','coordinator_signature','file',NULL,TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,2,'col-6'),
(153,32,'تاريخ الخطاب','coordinator_date','date',NULL,TRUE,TRUE,TRUE,FALSE,1,'CURRENT_DATE',NULL,NULL,3,'col-6'),
-- ── Sec 33: مراجعة رئيس القسم ───────────────────────────────────────
(154,33,'قرار رئيس القسم','head_decision','radio','موافقة,رفض,إرجاع للتعديل',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,1,'col-12'),
(155,33,'ملاحظات رئيس القسم','head_notes','textarea',NULL,FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,2,'col-12'),
(156,33,'توقيع رئيس القسم (صورة)','head_signature','file',NULL,TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,3,'col-6'),
(157,33,'تاريخ المراجعة','head_date','date',NULL,TRUE,TRUE,TRUE,FALSE,1,'CURRENT_DATE',NULL,NULL,4,'col-6'),
-- ── Sec 34: اعتماد عميد الكلية ───────────────────────────────────────
(158,34,'قرار عميد الكلية','dean_decision','radio','موافقة,رفض,إرجاع للتعديل',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,1,'col-12'),
(159,34,'ملاحظات عميد الكلية','dean_notes','textarea',NULL,FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,2,'col-12'),
(160,34,'توقيع عميد الكلية (صورة)','dean_signature','file',NULL,TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,3,'col-6'),
(161,34,'تاريخ الاعتماد','dean_date','date',NULL,TRUE,TRUE,TRUE,FALSE,1,'CURRENT_DATE',NULL,NULL,4,'col-6'),
-- ── Sec 35: قرار عميد الدراسات العليا ───────────────────────────────
(162,35,'القرار النهائي','grad_dean_decision','radio','موافقة,رفض,إرجاع للتعديل',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,1,'col-12'),
(163,35,'ملاحظات عميد الدراسات العليا','grad_dean_notes','textarea',NULL,FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,2,'col-12'),
(164,35,'توقيع عميد الدراسات العليا (صورة)','grad_dean_signature','file',NULL,TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,3,'col-6'),
(165,35,'تاريخ القرار','grad_dean_date','date',NULL,TRUE,TRUE,TRUE,FALSE,1,'CURRENT_DATE',NULL,NULL,4,'col-6');

-- ════════════════════════════════════════════════════════════════════════
-- FormFields — نموذج 705 (FieldID 166–207)
-- مرجع: نموذج__تعيين_الممتحنين_6_5.docx
-- ════════════════════════════════════════════════════════════════════════
INSERT INTO FormFields (FieldID,SectionID,FieldLabel,FieldName,FieldType,FieldOptions,IsRequired,IsReadOnly,IsAutoFill,IsRepeatable,MaxRepeat,DataSource,ConditionalOn,ConditionalValue,FieldOrder,CSSClass) VALUES
-- ── Sec 36: اختيار الطالب ───────────────────────────────────────────
(166,36,'اختر الطالب/ة','student_select','select','__dynamic:Students.StudentNumber:full_name_id|filter:Thesis.CurrentStage=examiner_appointment',TRUE,FALSE,FALSE,FALSE,1,'Students',NULL,NULL,1,'col-12'),
-- ── Sec 37: بيانات الاجتماع ─────────────────────────────────────────
(167,37,'القسم (تلقائي)','department','text',NULL,TRUE,TRUE,TRUE,FALSE,1,'Students.Programs.Sections.SectionName',NULL,NULL,1,'col-6'),
(168,37,'التخصص (تلقائي)','specialty','text',NULL,TRUE,TRUE,TRUE,FALSE,1,'Students.Programs.ProgramName',NULL,NULL,2,'col-6'),
(169,37,'مكان الاجتماع','meeting_place','text',NULL,TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,3,'col-4'),
(170,37,'اليوم','meeting_day','select','الأحد,الاثنين,الثلاثاء,الأربعاء,الخميس',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,4,'col-4'),
(171,37,'تاريخ الاجتماع','meeting_date','date',NULL,TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,5,'col-4'),
-- ── Sec 38: بيانات الرسالة والطالب (تلقائية) ────────────────────────
(172,38,'اسم الطالب الكامل','student_name','text',NULL,TRUE,TRUE,TRUE,FALSE,1,'Students.Users.full_name',NULL,NULL,1,'col-6'),
(173,38,'الرقم الجامعي','student_id','text',NULL,TRUE,TRUE,TRUE,FALSE,1,'Students.UniversityID',NULL,NULL,2,'col-6'),
(174,38,'عنوان الأطروحة بالعربية','thesis_title_ar','textarea',NULL,TRUE,TRUE,TRUE,FALSE,1,'Thesis.ThesisName',NULL,NULL,3,'col-12'),
(175,38,'عنوان الأطروحة بالإنجليزية (اختياري)','thesis_title_en','textarea',NULL,FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,4,'col-12'),
-- ── Sec 39: أعضاء اللجنة الحاضرون ──────────────────────────────────
(176,39,'العضو الأول — الاسم','member1_name','text',NULL,TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,1,'col-6'),
(177,39,'العضو الأول — الحضور','member1_attendance','radio','حاضر,غائب',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,2,'col-3'),
(178,39,'العضو الأول — التوقيع (صورة)','member1_signature','file',NULL,FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,3,'col-3'),
(179,39,'العضو الثاني — الاسم','member2_name','text',NULL,FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,4,'col-6'),
(180,39,'العضو الثاني — الحضور','member2_attendance','radio','حاضر,غائب',FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,5,'col-3'),
(181,39,'العضو الثاني — التوقيع (صورة)','member2_signature','file',NULL,FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,6,'col-3'),
(182,39,'العضو الثالث — الاسم','member3_name','text',NULL,FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,7,'col-6'),
(183,39,'العضو الثالث — الحضور','member3_attendance','radio','حاضر,غائب',FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,8,'col-3'),
(184,39,'العضو الثالث — التوقيع (صورة)','member3_signature','file',NULL,FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,9,'col-3'),
-- ── Sec 40: تعيين الممتحنين ─────────────────────────────────────────
(185,40,'الممتحن الداخلي','internal_examiner_id','select','__dynamic:Employees.EmployeeNumber:full_name_rank|filter:Role=Examiner',TRUE,FALSE,FALSE,FALSE,1,'Employees',NULL,NULL,1,'col-6'),
(186,40,'الجامعة/المؤسسة — الداخلي (تلقائي)','internal_examiner_inst','text',NULL,TRUE,TRUE,TRUE,FALSE,1,'Employees.WorkPlace',NULL,NULL,2,'col-6'),
(187,40,'البريد الإلكتروني — الداخلي (تلقائي)','internal_examiner_email','email',NULL,TRUE,TRUE,TRUE,FALSE,1,'Employees.Users.Email',NULL,NULL,3,'col-6'),
(188,40,'الدرجة العلمية — الداخلي (تلقائية)','internal_examiner_rank','text',NULL,TRUE,TRUE,TRUE,FALSE,1,'Supervisors.AcademicRank',NULL,NULL,4,'col-6'),
(189,40,'اسم الممتحن الخارجي','external_examiner_name','text',NULL,TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,5,'col-6'),
(190,40,'الجامعة/المؤسسة — الخارجي','external_examiner_inst','text',NULL,TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,6,'col-6'),
(191,40,'البريد الإلكتروني — الخارجي','external_examiner_email','email',NULL,TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,7,'col-6'),
(192,40,'الدرجة العلمية — الخارجي','external_examiner_rank','text',NULL,TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,8,'col-6'),
(193,40,'توقيع منسق البرنامج (صورة)','coordinator_signature','file',NULL,TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,9,'col-6'),
(194,40,'تاريخ المحضر','coordinator_date','date',NULL,TRUE,TRUE,TRUE,FALSE,1,'CURRENT_DATE',NULL,NULL,10,'col-6'),
-- ── Sec 41: مراجعة رئيس القسم ───────────────────────────────────────
(195,41,'قرار رئيس القسم','head_decision','radio','موافقة,رفض,إرجاع للتعديل',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,1,'col-12'),
(196,41,'ملاحظات رئيس القسم','head_notes','textarea',NULL,FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,2,'col-12'),
(197,41,'توقيع رئيس القسم (صورة)','head_signature','file',NULL,TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,3,'col-6'),
(198,41,'تاريخ المراجعة','head_date','date',NULL,TRUE,TRUE,TRUE,FALSE,1,'CURRENT_DATE',NULL,NULL,4,'col-6'),
-- ── Sec 42: اعتماد عميد الكلية ───────────────────────────────────────
(199,42,'قرار عميد الكلية','dean_decision','radio','موافقة,رفض,إرجاع للتعديل',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,1,'col-12'),
(200,42,'ملاحظات عميد الكلية','dean_notes','textarea',NULL,FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,2,'col-12'),
(201,42,'توقيع عميد الكلية (صورة)','dean_signature','file',NULL,TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,3,'col-6'),
(202,42,'تاريخ الاعتماد','dean_date','date',NULL,TRUE,TRUE,TRUE,FALSE,1,'CURRENT_DATE',NULL,NULL,4,'col-6'),
-- ── Sec 43: مصادقة عميد الدراسات العليا ─────────────────────────────
(203,43,'قرار عميد الدراسات العليا','grad_dean_decision','radio','موافقة,رفض,إرجاع للتعديل',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,1,'col-12'),
(204,43,'ملاحظات عميد الدراسات','grad_dean_notes','textarea',NULL,FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,2,'col-12'),
(205,43,'توقيع عميد الدراسات (صورة)','grad_dean_signature','file',NULL,TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,3,'col-6'),
(206,43,'تاريخ المصادقة','grad_dean_date','date',NULL,TRUE,TRUE,TRUE,FALSE,1,'CURRENT_DATE',NULL,NULL,4,'col-6');

-- ════════════════════════════════════════════════════════════════════════
-- FormFields — نموذج 707 (FieldID 207–302)
-- مرجع: 707تقرير_ممتحن_للرسائل_العلمية_والأطروحات_الجامعية_6.docx
-- ════════════════════════════════════════════════════════════════════════
INSERT INTO FormFields (FieldID,SectionID,FieldLabel,FieldName,FieldType,FieldOptions,IsRequired,IsReadOnly,IsAutoFill,IsRepeatable,MaxRepeat,DataSource,ConditionalOn,ConditionalValue,FieldOrder,CSSClass) VALUES
-- ── Sec 44: بيانات الطالب والرسالة (تلقائية) ────────────────────────
(207,44,'اسم الطالب/ة','student_name','text',NULL,TRUE,TRUE,TRUE,FALSE,1,'Students.Users.full_name',NULL,NULL,1,'col-6'),
(208,44,'الرقم الجامعي','student_id','text',NULL,TRUE,TRUE,TRUE,FALSE,1,'Students.UniversityID',NULL,NULL,2,'col-6'),
(209,44,'البرنامج','program','text',NULL,TRUE,TRUE,TRUE,FALSE,1,'Students.Programs.ProgramName',NULL,NULL,3,'col-6'),
(210,44,'منسق البرنامج','coordinator','text',NULL,FALSE,TRUE,TRUE,FALSE,1,'Programs.ProgramCoordinator.Users.full_name',NULL,NULL,4,'col-6'),
(211,44,'عنوان الرسالة','thesis_title','textarea',NULL,TRUE,TRUE,TRUE,FALSE,1,'Thesis.ThesisName',NULL,NULL,5,'col-12'),
-- ── Sec 45: بيانات الممتحن (تلقائية من سجل الدخول) ─────────────────
(212,45,'نوع الممتحن','examiner_type','radio','داخلي,خارجي',TRUE,TRUE,TRUE,FALSE,1,'FormSubmissionAssignees.ExaminerType',NULL,NULL,1,'col-6'),
(213,45,'اسم الممتحن','examiner_name','text',NULL,TRUE,TRUE,TRUE,FALSE,1,'Users.full_name',NULL,NULL,2,'col-6'),
(214,45,'التخصص الدقيق','examiner_specialty','text',NULL,TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,3,'col-6'),
(215,45,'الرتبة الأكاديمية','examiner_rank','text',NULL,TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,4,'col-6'),
(216,45,'الوظيفة','examiner_job','text',NULL,TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,5,'col-6'),
(217,45,'المؤسسة أو الجامعة','examiner_inst','text',NULL,TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,6,'col-6'),
(218,45,'العنوان','examiner_address','text',NULL,FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,7,'col-6'),
(219,45,'رقم الهاتف','examiner_phone','text',NULL,TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,8,'col-6'),
(220,45,'الفاكس','examiner_fax','text',NULL,FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,9,'col-6'),
(221,45,'البريد الإلكتروني','examiner_email','email',NULL,TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,10,'col-6'),
-- ── Sec 46: أولاً — ملخصات الرسالة ─────────────────────────────────
(222,46,'أ- الملخص (Abstract) بلغة الرسالة — 600 كلمة / 2-4 صفحات','abstract_ar','radio','ملائمة,بحاجة إلى تعديل,غير ملائمة',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,1,'col-12'),
(223,46,'ب- الملخص (Abstract) بلغة غير لغة الرسالة — 600 كلمة / 2-4 صفحات','abstract_other','radio','ملائمة,بحاجة إلى تعديل,غير ملائمة',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,2,'col-12'),
(224,46,'ملاحظات على الملخصات','abstract_notes','textarea',NULL,FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,3,'col-12'),
-- ── Sec 47: ثانياً — مقدمة الرسالة ─────────────────────────────────
(225,47,'أ- مشكلة الدراسة','intro_problem','radio','ملائمة,بحاجة إلى تعديل,غير ملائمة',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,1,'col-12'),
(226,47,'ب- أهمية الدراسة','intro_importance','radio','ملائمة,بحاجة إلى تعديل,غير ملائمة',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,2,'col-12'),
(227,47,'ج- أهداف الدراسة','intro_objectives','radio','ملائمة,بحاجة إلى تعديل,غير ملائمة',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,3,'col-12'),
(228,47,'د- أسئلة أو فرضيات الدراسة','intro_questions','radio','ملائمة,بحاجة إلى تعديل,غير ملائمة',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,4,'col-12'),
(229,47,'هـ- حدود الدراسة','intro_limits','radio','ملائمة,بحاجة إلى تعديل,غير ملائمة',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,5,'col-12'),
(230,47,'ملاحظات على المقدمة','intro_notes','textarea',NULL,FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,6,'col-12'),
-- ── Sec 48: ثالثاً — الإطار النظري والدراسات السابقة ───────────────
(231,48,'أ- شمولية الدراسات السابقة','theory_coverage','radio','ملائمة,بحاجة إلى تعديل,غير ملائمة',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,1,'col-12'),
(232,48,'ب- تحليل الدراسات السابقة','theory_analysis','radio','ملائمة,بحاجة إلى تعديل,غير ملائمة',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,2,'col-12'),
(233,48,'ج- الإسهام النظري الأصيل','theory_originality','radio','ملائمة,بحاجة إلى تعديل,غير ملائمة',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,3,'col-12'),
(234,48,'ملاحظات على الإطار النظري','theory_notes','textarea',NULL,FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,4,'col-12'),
-- ── Sec 49: رابعاً — المنهجية ───────────────────────────────────────
(235,49,'أ- مجتمع الدراسة وعينتها','method_sample','radio','ملائمة,بحاجة إلى تعديل,غير ملائمة',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,1,'col-12'),
(236,49,'ب- أداة الدراسة','method_tool','radio','ملائمة,بحاجة إلى تعديل,غير ملائمة',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,2,'col-12'),
(237,49,'ج- المعالجة الإحصائية','method_stats','radio','ملائمة,بحاجة إلى تعديل,غير ملائمة',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,3,'col-12'),
(238,49,'ملاحظات على المنهجية','method_notes','textarea',NULL,FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,4,'col-12'),
-- ── Sec 50: خامساً — النتائج والمناقشة ─────────────────────────────
(239,50,'أ- مناقشة النتائج','results_discussion','radio','ملائمة,بحاجة إلى تعديل,غير ملائمة',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,1,'col-12'),
(240,50,'ب- تفسير النتائج','results_interpretation','radio','ملائمة,بحاجة إلى تعديل,غير ملائمة',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,2,'col-12'),
(241,50,'ج- الجداول والأشكال','results_tables','radio','ملائمة,بحاجة إلى تعديل,غير ملائمة',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,3,'col-12'),
(242,50,'ملاحظات على النتائج والمناقشة','results_notes','textarea',NULL,FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,4,'col-12'),
-- ── Sec 51: سادساً — الخاتمة والتوصيات ─────────────────────────────
(243,51,'أ- استنتاجات البحث','conclusion_findings','radio','ملائمة,بحاجة إلى تعديل,غير ملائمة',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,1,'col-12'),
(244,51,'ب- التوصيات','conclusion_recommendations','radio','ملائمة,بحاجة إلى تعديل,غير ملائمة',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,2,'col-12'),
(245,51,'ملاحظات على الخاتمة','conclusion_notes','textarea',NULL,FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,3,'col-12'),
-- ── Sec 52: سابعاً — المراجع والتوثيق ──────────────────────────────
(246,52,'عدد المراجع المستخدمة','refs_count','radio','كافٍ,متوسط,قليل',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,1,'col-12'),
(247,52,'لغة المراجع المستخدمة','refs_language','radio','لغة واحدة,لغتان,أكثر من ذلك',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,2,'col-12'),
(248,52,'رد الباحث المعلومات إلى مصادرها الأصلية','refs_attribution','radio','غالباً,أحياناً,استند إلى باحثين آخرين',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,3,'col-12'),
(249,52,'مصادر البحث اشتملت على','refs_sources','checkbox','القرآن الكريم,كتب,مجلات ودوريات,موسوعات,مخطوطات,جرائد,تقارير,رسائل ماجستير ودكتوراه,الإنترنت,الإذاعة والتلفزيون,لقاء واتصال شخصي',FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,4,'col-12'),
(250,52,'ملاحظات على التوثيق','refs_notes','textarea',NULL,FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,5,'col-12'),
-- ── Sec 53: ثامناً — الملاحق ────────────────────────────────────────
(251,53,'الملاحق مرتبطة بموضوع الرسالة','appendix_relevance','radio','نعم,لا,لا توجد ملاحق',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,1,'col-12'),
(252,53,'ملاحظات على الملاحق','appendix_notes','textarea',NULL,FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,2,'col-12'),
-- ── Sec 54: تاسعاً — الجدة والأصالة (checkboxes نعم/لا) ────────────
(253,54,'الرسالة تحوي إنتاجاً علمياً لم يُسبق اكتشافه أو دراسته','originality_new','radio','نعم,لا',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,1,'col-12'),
(254,54,'الرسالة أتمت موضوعاً ناقصاً','originality_complete','radio','نعم,لا',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,2,'col-12'),
(255,54,'الرسالة شرحت موضوعاً مبهماً','originality_clarify','radio','نعم,لا',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,3,'col-12'),
(256,54,'الرسالة اختصرت موضوعاً طويلاً دون الإخلال بالمعنى','originality_shorten','radio','نعم,لا',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,4,'col-12'),
(257,54,'الرسالة جمعت موضوعاً متفرقاً أو رتبت موضوعاً مشتتاً','originality_organize','radio','نعم,لا',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,5,'col-12'),
(258,54,'ملاحظات على الجدة والأصالة','originality_notes','textarea',NULL,FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,6,'col-12'),
-- ── Sec 55: عاشراً — الالتزام بمناهج البحث ─────────────────────────
(259,55,'المنهج العلمي المستخدم','research_method','select','الوصفي,التاريخي,التحليلي,التجريبي,الوصفي الارتباطي,لم يلتزم بمنهج محدد',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,1,'col-12'),
(260,55,'ملاحظات على الالتزام بالمنهج','research_method_notes','textarea',NULL,FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,2,'col-12'),
-- ── Sec 56: حادي عشر — الموضوعية ───────────────────────────────────
(261,56,'طرح الباحث مشكلة البحث بموضوعية بدرجة','objectivity_problem','radio','كبيرة,متوسطة,معدومة',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,1,'col-12'),
(262,56,'مواقف وآراء الباحث جاءت بصورة','objectivity_stance','radio','متناسقة,متناقضة',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,2,'col-12'),
(263,56,'عرض الباحث نتائج البحث بصورة','objectivity_results','radio','موضوعية,متحيزة,لا رأي للباحث',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,3,'col-12'),
(264,56,'ملاحظات على الموضوعية','objectivity_notes','textarea',NULL,FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,4,'col-12'),
-- ── Sec 57: ثاني عشر — الأسلوب وشخصية الباحث ──────────────────────
(265,57,'برزت شخصية الباحث في','style_personality','radio','كافة الفصول,بعض الفصول,الخاتمة فقط,لم تبرز',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,1,'col-12'),
(266,57,'أسلوب عرض الرسالة','style_presentation','radio','خاص بالباحث (تقليدي),غير ذلك (مختلط)',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,2,'col-12'),
(267,57,'ملاحظات على الأسلوب','style_notes','textarea',NULL,FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,3,'col-12'),
-- ── Sec 58: ثالث عشر — التنظيم والترتيب ────────────────────────────
(268,58,'توزيع المعلومات في فصول الرسالة','organization_dist','radio','مناسب,غير مناسب',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,1,'col-12'),
(269,58,'التزم الباحث بتتابع منطقي للمعلومات بدرجة','organization_logic','radio','كبيرة,متوسطة,قليلة',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,2,'col-12'),
(270,58,'ملاحظات على التنظيم','organization_notes','textarea',NULL,FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,3,'col-12'),
-- ── Sec 59: رابع عشر — اللغة ────────────────────────────────────────
(271,59,'الرسالة تحتوي أخطاء لغوية','language_errors','radio','قليلة,متوسطة,كثيرة',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,1,'col-12'),
(272,59,'الرسالة تحتوي أخطاء مطبعية','typo_errors','radio','معدومة,قليلة,كثيرة',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,2,'col-12'),
(273,59,'لغة التخصص العلمية للرسالة','language_level','radio','سطحية,متوسطة,عميقة',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,3,'col-12'),
(274,59,'ملاحظات على اللغة','language_notes','textarea',NULL,FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,4,'col-12'),
-- ── Sec 60: خامس عشر — التعامل مع التقنيات ─────────────────────────
(275,60,'البيانات المستخدمة','tech_data','radio','من إعداد الباحث,استعان بها,لا ينطبق',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,1,'col-12'),
(276,60,'استخدم الباحث البرامج الحاسوبية','tech_software','radio','نعم,لا',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,2,'col-12'),
(277,60,'الطرق المستخدمة في البحث','tech_methods','radio','قابلة للإعادة,غير قابلة للإعادة وعشوائية',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,3,'col-12'),
(278,60,'ملاحظات على التقنيات','tech_notes','textarea',NULL,FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,4,'col-12'),
-- ── Sec 61: سادس عشر — التوثيق الداخلي للنص ───────────────────────
(279,61,'التوثيق داخل النص متسق مع قائمة المراجع','doc_consistency','radio','نعم دائماً,أحياناً,نادراً',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,1,'col-12'),
(280,61,'ملاحظات على التوثيق الداخلي','doc_notes','textarea',NULL,FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,2,'col-12'),
-- ── Sec 62: سابع عشر — نتائج البحث وتحليلها ────────────────────────
(281,62,'نتائج البحث أجابت على الفرضيات أو التساؤلات بدرجة','results_answered','radio','كبيرة,متوسطة,قليلة',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,1,'col-12'),
(282,62,'نتائج البحث حققت أهداف الدراسة بدرجة','results_achieved','radio','كبيرة,متوسطة,قليلة',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,2,'col-12'),
(283,62,'تحليل ومناقشة النتائج','results_analysis','radio','عميق,متوسط,غير مناسب',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,3,'col-12'),
(284,62,'أهمية نتائج البحث بالنسبة للتخصص','results_importance','radio','مفيدة جداً,مفيدة,غير مفيدة',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,4,'col-12'),
(285,62,'نتائج البحث وتوصياته في خدمة المجتمع','results_social','radio','قابلة للتطبيق,مهمة,نظرية بحتة,مكررة',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,5,'col-12'),
(286,62,'نتائج البحث','results_publishable','radio','قابلة للنشر,غير قابلة للنشر',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,6,'col-12'),
(287,62,'ملاحظات على النتائج والتحليل','results_final_notes','textarea',NULL,FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,7,'col-12'),
-- ── Sec 63: التوصية النهائية للممتحن ────────────────────────────────
(288,63,'الرسالة تحوي إسهاماً في عالم المعرفة','knowledge_contribution','radio','نعم,لا',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,1,'col-12'),
(289,63,'توصية الممتحن بخصوص الرسالة','final_recommendation','radio','الرسالة صالحة للمناقشة بصورتها الحالية (لا توجد تعديلات),الرسالة صالحة للمناقشة بعد تعديلات جانبية,الرسالة غير صالحة بصورتها الحالية (تعديلات أساسية مطلوبة),الرسالة مرفوضة وغير قابلة للمناقشة',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,2,'col-12'),
(290,63,'نوع التعديلات الجانبية','minor_revision_type','checkbox','الإطار النظري,توثيق,أخطاء مطبعية,أخطاء لغوية,غير ذلك',FALSE,FALSE,FALSE,FALSE,1,NULL,'final_recommendation','الرسالة صالحة للمناقشة بعد تعديلات جانبية',3,'col-12'),
(291,63,'تفاصيل التعديلات الجانبية','minor_revision_details','textarea',NULL,FALSE,FALSE,FALSE,FALSE,1,NULL,'final_recommendation','الرسالة صالحة للمناقشة بعد تعديلات جانبية',4,'col-12'),
(292,63,'نوع التعديلات الأساسية','major_revision_type','checkbox','المنهجية,أداة الدراسة,الأهداف,معالجة النتائج ومناقشتها,التوصيات,غير ذلك',FALSE,FALSE,FALSE,FALSE,1,NULL,'final_recommendation','الرسالة غير صالحة بصورتها الحالية (تعديلات أساسية مطلوبة)',5,'col-12'),
(293,63,'تفاصيل التعديلات الأساسية','major_revision_details','textarea',NULL,FALSE,FALSE,FALSE,FALSE,1,NULL,'final_recommendation','الرسالة غير صالحة بصورتها الحالية (تعديلات أساسية مطلوبة)',6,'col-12'),
(294,63,'سبب رفض الرسالة','rejection_reason','checkbox','لا تحوي إسهاماً في عالم المعرفة,مخالفة لقواعد الأمانة العلمية',FALSE,FALSE,FALSE,FALSE,1,NULL,'final_recommendation','الرسالة مرفوضة وغير قابلة للمناقشة',7,'col-12'),
(295,63,'ملاحظات عامة على الرسالة','general_notes','textarea',NULL,FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,8,'col-12'),
(296,63,'توقيع الممتحن (صورة)','examiner_signature','file',NULL,TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,9,'col-6'),
(297,63,'تاريخ التقرير','report_date','date',NULL,TRUE,TRUE,TRUE,FALSE,1,'CURRENT_DATE',NULL,NULL,10,'col-6'),
-- ── Sec 64: للاستعمال الرسمي — اعتماد عميد الكلية ──────────────────
(298,64,'رأي عميد الكلية','dean_opinion','textarea',NULL,FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,1,'col-12'),
(299,64,'قرار عميد الكلية','dean_decision','radio','يحول التقرير لمنسق البرنامج لمتابعة عقد المناقشة,يُعرض الأمر على لجنة الدراسات العليا لاختيار مقيّم ثالث,يُعرض الأمر على لجنة الدراسات العليا للبت في نتيجة الطالب',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,2,'col-12'),
(300,64,'توقيع عميد الكلية (صورة)','dean_signature','file',NULL,TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,3,'col-6'),
(301,64,'تاريخ المصادقة','dean_date','date',NULL,TRUE,TRUE,TRUE,FALSE,1,'CURRENT_DATE',NULL,NULL,4,'col-6'),
-- ── Sec 65: قرار لجنة الدراسات العليا ──────────────────────────────
(302,65,'رقم الجلسة','session_number','text',NULL,FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,1,'col-6'),
(303,65,'تاريخ الجلسة','session_date','date',NULL,FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,2,'col-6'),
(304,65,'قرار لجنة الدراسات العليا','committee_decision','radio','اعتماد التقارير ومتابعة عقد المناقشة,تعيين مقيّم ثالث مرجّح (تضارب التوصيات),قرار رسوب الطالب في رسالة الماجستير (مفصول من البرنامج)',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,3,'col-12'),
(305,65,'اسم المقيّم الثالث المقترح','third_examiner_name','text',NULL,FALSE,FALSE,FALSE,FALSE,1,NULL,'committee_decision','تعيين مقيّم ثالث مرجّح (تضارب التوصيات)',4,'col-12'),
(306,65,'ملاحظات اللجنة','committee_notes','textarea',NULL,FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,5,'col-12'),
(307,65,'توقيع عميد الدراسات العليا (صورة)','grad_dean_signature','file',NULL,TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,6,'col-6'),
(308,65,'تاريخ القرار','grad_dean_date','date',NULL,TRUE,TRUE,TRUE,FALSE,1,'CURRENT_DATE',NULL,NULL,7,'col-6');

-- ════════════════════════════════════════════════════════════════════════
-- FormFields — نموذج 714 (FieldID 309–330)
-- مرجع: 7_714_إتمام_التعديلات_لأطروحة_ماجستير.docx
-- ════════════════════════════════════════════════════════════════════════
INSERT INTO FormFields (FieldID,SectionID,FieldLabel,FieldName,FieldType,FieldOptions,IsRequired,IsReadOnly,IsAutoFill,IsRepeatable,MaxRepeat,DataSource,ConditionalOn,ConditionalValue,FieldOrder,CSSClass) VALUES
-- ── Sec 66: بيانات الطالب والرسالة (تلقائية) ────────────────────────
(309,66,'اسم الطالب/ة','student_name','text',NULL,TRUE,TRUE,TRUE,FALSE,1,'Students.Users.full_name',NULL,NULL,1,'col-6'),
(310,66,'الرقم الجامعي','student_id','text',NULL,TRUE,TRUE,TRUE,FALSE,1,'Students.UniversityID',NULL,NULL,2,'col-6'),
(311,66,'التخصص','specialty','text',NULL,TRUE,TRUE,TRUE,FALSE,1,'Students.Programs.ProgramName',NULL,NULL,3,'col-6'),
(312,66,'تاريخ المناقشة','defense_date','date',NULL,TRUE,TRUE,TRUE,FALSE,1,'FormValues.form708.defense_date',NULL,NULL,4,'col-6'),
(313,66,'عنوان الرسالة','thesis_title','textarea',NULL,TRUE,TRUE,TRUE,FALSE,1,'Thesis.ThesisName',NULL,NULL,5,'col-12'),
-- ── Sec 67: توقيعات لجنة المناقشة ──────────────────────────────────
(314,67,'المشرف (رئيساً) — الاسم','supervisor_name','text',NULL,TRUE,TRUE,TRUE,FALSE,1,'Supervisors.Users.full_name',NULL,NULL,1,'col-6'),
(315,67,'توقيع المشرف (صورة)','supervisor_sig','file',NULL,TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,2,'col-3'),
(316,67,'تاريخ توقيع المشرف','supervisor_date','date',NULL,TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,3,'col-3'),
(317,67,'العضو الأول — الاسم (تلقائي)','member1_name','text',NULL,TRUE,TRUE,TRUE,FALSE,1,'FormValues.form705.internal_examiner_id.full_name',NULL,NULL,4,'col-6'),
(318,67,'توقيع العضو الأول (صورة)','member1_sig','file',NULL,TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,5,'col-3'),
(319,67,'تاريخ توقيع العضو الأول','member1_date','date',NULL,TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,6,'col-3'),
(320,67,'العضو الثاني — الاسم (تلقائي)','member2_name','text',NULL,FALSE,TRUE,TRUE,FALSE,1,'FormValues.form705.external_examiner_name',NULL,NULL,7,'col-6'),
(321,67,'توقيع العضو الثاني (صورة)','member2_sig','file',NULL,FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,8,'col-3'),
(322,67,'تاريخ توقيع العضو الثاني','member2_date','date',NULL,FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,9,'col-3'),
-- ── Sec 68: مراجعة منسق البرنامج ────────────────────────────────────
(323,68,'قرار منسق البرنامج','coordinator_decision','radio','موافقة,إرجاع للتعديل',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,1,'col-12'),
(324,68,'توقيع منسق البرنامج (صورة)','coordinator_sig','file',NULL,TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,2,'col-6'),
(325,68,'تاريخ المراجعة','coordinator_date','date',NULL,TRUE,TRUE,TRUE,FALSE,1,'CURRENT_DATE',NULL,NULL,3,'col-6'),
-- ── Sec 69: مراجعة رئيس القسم ───────────────────────────────────────
(326,69,'قرار رئيس القسم','head_decision','radio','موافقة,إرجاع للتعديل',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,1,'col-12'),
(327,69,'توقيع رئيس القسم (صورة)','head_sig','file',NULL,TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,2,'col-6'),
(328,69,'تاريخ المراجعة','head_date','date',NULL,TRUE,TRUE,TRUE,FALSE,1,'CURRENT_DATE',NULL,NULL,3,'col-6'),
-- ── Sec 70: مصادقة رئيس اللجنة في الكلية ───────────────────────────
(329,70,'الاسم (تلقائي)','chair_name','text',NULL,TRUE,TRUE,TRUE,FALSE,1,'DeanOfFaculty.Users.full_name',NULL,NULL,1,'col-6'),
(330,70,'توقيع رئيس اللجنة في الكلية (صورة)','chair_sig','file',NULL,TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,2,'col-3'),
(331,70,'تاريخ المصادقة','chair_date','date',NULL,TRUE,TRUE,TRUE,FALSE,1,'CURRENT_DATE',NULL,NULL,3,'col-3'),
-- ── Sec 71: مصادقة عميد الدراسات العليا ─────────────────────────────
(332,71,'الاسم (تلقائي)','grad_dean_name','text',NULL,TRUE,TRUE,TRUE,FALSE,1,'DeanOfGradStudies.Users.full_name',NULL,NULL,1,'col-6'),
(333,71,'توقيع عميد الدراسات العليا (صورة)','grad_dean_sig','file',NULL,TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,2,'col-3'),
(334,71,'تاريخ المصادقة','grad_dean_date','date',NULL,TRUE,TRUE,TRUE,FALSE,1,'CURRENT_DATE',NULL,NULL,3,'col-3');

-- ════════════════════════════════════════════════════════════════════════
-- FormFields — نموذج 716 (FieldID 335–358)
-- مرجع: إجازة_رسالة_جامعية_8_716_.docx
-- ════════════════════════════════════════════════════════════════════════
INSERT INTO FormFields (FieldID,SectionID,FieldLabel,FieldName,FieldType,FieldOptions,IsRequired,IsReadOnly,IsAutoFill,IsRepeatable,MaxRepeat,DataSource,ConditionalOn,ConditionalValue,FieldOrder,CSSClass) VALUES
-- ── Sec 72: بيانات الطالب والرسالة (تلقائية) ────────────────────────
(335,72,'اسم الطالب/ة','student_name','text',NULL,TRUE,TRUE,TRUE,FALSE,1,'Students.Users.full_name',NULL,NULL,1,'col-6'),
(336,72,'الرقم الجامعي','student_id','text',NULL,TRUE,TRUE,TRUE,FALSE,1,'Students.UniversityID',NULL,NULL,2,'col-6'),
(337,72,'عنوان الرسالة','thesis_title','textarea',NULL,TRUE,TRUE,TRUE,FALSE,1,'Thesis.ThesisName',NULL,NULL,3,'col-12'),
(338,72,'درجة الدراسة','degree','text',NULL,TRUE,TRUE,TRUE,FALSE,1,'Students.Programs.ProgramName',NULL,NULL,4,'col-4'),
(339,72,'التخصص','specialty','text',NULL,TRUE,TRUE,TRUE,FALSE,1,'Students.Programs.ProgramName',NULL,NULL,5,'col-4'),
(340,72,'القسم','department','text',NULL,TRUE,TRUE,TRUE,FALSE,1,'Students.Programs.Sections.SectionName',NULL,NULL,6,'col-4'),
(341,72,'الكلية','faculty','text',NULL,TRUE,TRUE,TRUE,FALSE,1,'Students.Programs.Sections.Departments.DepartmentName',NULL,NULL,7,'col-6'),
(342,72,'تاريخ المناقشة','defense_date','date',NULL,TRUE,TRUE,TRUE,FALSE,1,'FormValues.form708.defense_date',NULL,NULL,8,'col-6'),
-- ── Sec 73: توقيع المشرف رئيس اللجنة ───────────────────────────────
(343,73,'اسم المشرف (مشرفاً ورئيساً) — تلقائي','chair_name','text',NULL,TRUE,TRUE,TRUE,FALSE,1,'Supervisors.Users.full_name',NULL,NULL,1,'col-6'),
(344,73,'الصفة','chair_role','text','مشرفاً ورئيساً',TRUE,TRUE,TRUE,FALSE,1,'CONST:مشرفاً ورئيساً',NULL,NULL,2,'col-3'),
(345,73,'توقيع المشرف (صورة)','chair_sig','file',NULL,TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,3,'col-3'),
-- ── Sec 74: توقيع الممتحن الداخلي ──────────────────────────────────
(346,74,'اسم الممتحن الداخلي (تلقائي)','internal_name','text',NULL,TRUE,TRUE,TRUE,FALSE,1,'FormValues.form705.internal_examiner_id.full_name',NULL,NULL,1,'col-6'),
(347,74,'الصفة','internal_role','text','ممتحناً داخلياً',TRUE,TRUE,TRUE,FALSE,1,'CONST:ممتحناً داخلياً',NULL,NULL,2,'col-3'),
(348,74,'توقيع الممتحن الداخلي (صورة)','internal_sig','file',NULL,TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,3,'col-3'),
-- ── Sec 75: توقيع الممتحن الخارجي ──────────────────────────────────
(349,75,'اسم الممتحن الخارجي (تلقائي)','external_name','text',NULL,TRUE,TRUE,TRUE,FALSE,1,'FormValues.form705.external_examiner_name',NULL,NULL,1,'col-6'),
(350,75,'الصفة','external_role','text','ممتحناً خارجياً',TRUE,TRUE,TRUE,FALSE,1,'CONST:ممتحناً خارجياً',NULL,NULL,2,'col-3'),
(351,75,'توقيع الممتحن الخارجي (صورة)','external_sig','file',NULL,TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,3,'col-3'),
(352,75,'اسم الممتحن الخارجي الثاني إن وجد (مقيّم ثالث)','external2_name','text',NULL,FALSE,TRUE,TRUE,FALSE,1,'FormValues.form707.third_examiner_name',NULL,NULL,4,'col-6'),
(353,75,'الصفة','external2_role','text','ممتحناً خارجياً',FALSE,TRUE,TRUE,FALSE,1,'CONST:ممتحناً خارجياً',NULL,NULL,5,'col-3'),
(354,75,'توقيع الممتحن الخارجي الثاني (صورة)','external2_sig','file',NULL,FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,6,'col-3'),
-- ── Sec 76: مصادقة عميد الدراسات العليا ─────────────────────────────
(355,76,'توقيع عميد الدراسات العليا (صورة)','grad_dean_sig','file',NULL,TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,1,'col-6'),
(356,76,'تاريخ الإجازة','approval_date','date',NULL,TRUE,TRUE,TRUE,FALSE,1,'CURRENT_DATE',NULL,NULL,2,'col-6');

-- ════════════════════════════════════════════════════════════════════════
-- FormFields — نموذج 720 (FieldID 357–389)
-- تقرير المتابعة الشهرية للمشرف — نموذج جديد
-- ════════════════════════════════════════════════════════════════════════
INSERT INTO FormFields (FieldID,SectionID,FieldLabel,FieldName,FieldType,FieldOptions,IsRequired,IsReadOnly,IsAutoFill,IsRepeatable,MaxRepeat,DataSource,ConditionalOn,ConditionalValue,FieldOrder,CSSClass) VALUES
-- ── Sec 77: اختيار الطالب ───────────────────────────────────────────
(357,77,'اختر الطالب','student_select','select','__dynamic:Students.StudentNumber:full_name_id|filter:SupervisorID=current_user',TRUE,FALSE,FALSE,FALSE,1,'Students',NULL,NULL,1,'col-12'),
(358,77,'شهر التقرير','report_month','select','يناير,فبراير,مارس,أبريل,مايو,يونيو,يوليو,أغسطس,سبتمبر,أكتوبر,نوفمبر,ديسمبر',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,2,'col-6'),
(359,77,'سنة التقرير','report_year','text',NULL,TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,3,'col-6'),
-- ── Sec 78: بيانات الطالب (تلقائية) ────────────────────────────────
(360,78,'اسم الطالب الكامل','student_name','text',NULL,TRUE,TRUE,TRUE,FALSE,1,'Students.Users.full_name',NULL,NULL,1,'col-6'),
(361,78,'الرقم الجامعي','student_id','text',NULL,TRUE,TRUE,TRUE,FALSE,1,'Students.UniversityID',NULL,NULL,2,'col-6'),
(362,78,'القسم','department','text',NULL,TRUE,TRUE,TRUE,FALSE,1,'Students.Programs.Sections.SectionName',NULL,NULL,3,'col-6'),
(363,78,'البرنامج','program','text',NULL,TRUE,TRUE,TRUE,FALSE,1,'Students.Programs.ProgramName',NULL,NULL,4,'col-6'),
(364,78,'عنوان الرسالة','thesis_title','text',NULL,FALSE,TRUE,TRUE,FALSE,1,'Thesis.ThesisName',NULL,NULL,5,'col-12'),
(365,78,'تاريخ تسجيل الرسالة','thesis_reg_date','date',NULL,FALSE,TRUE,TRUE,FALSE,1,'Thesis.CreatedAt',NULL,NULL,6,'col-6'),
-- ── Sec 79: تفاصيل اللقاء الشهري ───────────────────────────────────
(366,79,'تاريخ اللقاء','meeting_date','date',NULL,TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,1,'col-6'),
(367,79,'مدة اللقاء (بالدقائق)','meeting_duration','number',NULL,FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,2,'col-6'),
(368,79,'مكان اللقاء','meeting_location','text',NULL,FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,3,'col-6'),
(369,79,'طريقة اللقاء','meeting_type','radio','حضوري,عن بُعد (أونلاين)',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,4,'col-6'),
(370,79,'محتوى اللقاء وما تم مناقشته','meeting_content','textarea',NULL,TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,5,'col-12'),
(371,79,'المهام المطلوبة من الطالب للشهر القادم','next_month_tasks','textarea',NULL,FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,6,'col-12'),
(372,79,'مستوى تقدم الطالب هذا الشهر','monthly_progress','radio','ممتاز,جيد جداً,جيد,مقبول,ضعيف',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,7,'col-12'),
(373,79,'ملاحظات إضافية','extra_notes','textarea',NULL,FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,8,'col-12'),
-- ── Sec 80: توقيعات الحضور ──────────────────────────────────────────
(374,80,'توقيع المشرف (صورة)','supervisor_signature','file',NULL,TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,1,'col-6'),
(375,80,'تاريخ توقيع المشرف','supervisor_sign_date','date',NULL,TRUE,TRUE,TRUE,FALSE,1,'CURRENT_DATE',NULL,NULL,2,'col-6'),
(376,80,'توقيع الطالب (صورة) — دليل الحضور','student_signature','file',NULL,TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,3,'col-6'),
(377,80,'تاريخ توقيع الطالب','student_sign_date','date',NULL,FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,4,'col-6'),
-- ── Sec 81: مراجعة منسق البرنامج ────────────────────────────────────
(378,81,'قرار منسق البرنامج','coordinator_decision','radio','معتمد,مرفوض,إرجاع للمشرف',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,1,'col-12'),
(379,81,'ملاحظات منسق البرنامج','coordinator_notes','textarea',NULL,FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,2,'col-12'),
(380,81,'توقيع منسق البرنامج (صورة)','coordinator_signature','file',NULL,TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,3,'col-6'),
(381,81,'تاريخ المراجعة','coordinator_date','date',NULL,TRUE,TRUE,TRUE,FALSE,1,'CURRENT_DATE',NULL,NULL,4,'col-6'),
-- ── Sec 82: اعتماد رئيس القسم ───────────────────────────────────────
(382,82,'قرار رئيس القسم','head_decision','radio','معتمد,مرفوض',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,1,'col-12'),
(383,82,'ملاحظات رئيس القسم','head_notes','textarea',NULL,FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,2,'col-12'),
(384,82,'توقيع رئيس القسم (صورة)','head_signature','file',NULL,TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,3,'col-6'),
(385,82,'تاريخ الاعتماد','head_date','date',NULL,TRUE,TRUE,TRUE,FALSE,1,'CURRENT_DATE',NULL,NULL,4,'col-6'),
-- ── Sec 83: اعتماد عميد الكلية ───────────────────────────────────────
(386,83,'قرار عميد الكلية','dean_decision','radio','معتمد,مرفوض',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,1,'col-12'),
(387,83,'ملاحظات عميد الكلية','dean_notes','textarea',NULL,FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,2,'col-12'),
(388,83,'توقيع عميد الكلية (صورة)','dean_signature','file',NULL,TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,3,'col-6'),
(389,83,'تاريخ الاعتماد','dean_date','date',NULL,TRUE,TRUE,TRUE,FALSE,1,'CURRENT_DATE',NULL,NULL,4,'col-6');

-- ════════════════════════════════════════════════════════════════════════
-- FormFields — نموذج 721 (FieldID 390–413)
-- مرجع: 4_نموذج_721_تقرير_متابعة_لطلاب_الدراسات_العليا.docx
-- ════════════════════════════════════════════════════════════════════════
INSERT INTO FormFields (FieldID,SectionID,FieldLabel,FieldName,FieldType,FieldOptions,IsRequired,IsReadOnly,IsAutoFill,IsRepeatable,MaxRepeat,DataSource,ConditionalOn,ConditionalValue,FieldOrder,CSSClass) VALUES
-- ── Sec 84: اختيار الطالب ───────────────────────────────────────────
(390,84,'اختر الطالب','student_select','select','__dynamic:Students.StudentNumber:full_name_id|filter:SupervisorID=current_user',TRUE,FALSE,FALSE,FALSE,1,'Students',NULL,NULL,1,'col-12'),
-- ── Sec 85: بيانات الطالب (تلقائية) ────────────────────────────────
(391,85,'اسم الطالب الكامل','student_name','text',NULL,TRUE,TRUE,TRUE,FALSE,1,'Students.Users.full_name',NULL,NULL,1,'col-6'),
(392,85,'الرقم الجامعي','student_id','text',NULL,TRUE,TRUE,TRUE,FALSE,1,'Students.UniversityID',NULL,NULL,2,'col-6'),
(393,85,'القسم','department','text',NULL,TRUE,TRUE,TRUE,FALSE,1,'Students.Programs.Sections.SectionName',NULL,NULL,3,'col-6'),
(394,85,'البرنامج','program','text',NULL,TRUE,TRUE,TRUE,FALSE,1,'Students.Programs.ProgramName',NULL,NULL,4,'col-6'),
(395,85,'الفصل الدراسي الحالي','current_semester','text',NULL,TRUE,TRUE,TRUE,FALSE,1,'Students.EnrollmentSemester',NULL,NULL,5,'col-6'),
(396,85,'العام الدراسي الحالي','academic_year','text',NULL,TRUE,TRUE,TRUE,FALSE,1,'Students.EnrollmentYear',NULL,NULL,6,'col-6'),
(397,85,'الساعات المجتازة بنجاح','passed_hours','number',NULL,TRUE,TRUE,TRUE,FALSE,1,'Students.TotalCompletedHours',NULL,NULL,7,'col-6'),
(398,85,'الساعات المتبقية','remaining_hours','number',NULL,TRUE,TRUE,TRUE,FALSE,1,'computed:ProgramTotalHours-Students.TotalCompletedHours',NULL,NULL,8,'col-6'),
(399,85,'المشرف على الرسالة','supervisor_name','text',NULL,FALSE,TRUE,TRUE,FALSE,1,'Supervisors.Users.full_name',NULL,NULL,9,'col-6'),
(400,85,'تاريخ تسجيل الرسالة','thesis_reg_date','date',NULL,FALSE,TRUE,TRUE,FALSE,1,'Thesis.CreatedAt',NULL,NULL,10,'col-6'),
-- ── Sec 86: الفصول الدراسية المنجزة ─────────────────────────────────
(401,86,'مخطط الدراسة','chapter_plan','radio','أنجز,قيد الإنجاز,لم ينجز',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,1,'col-12'),
(402,86,'الفصل الأول في الرسالة','chapter_1','radio','أنجز,قيد الإنجاز,لم ينجز',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,2,'col-12'),
(403,86,'الفصل الثاني في الرسالة','chapter_2','radio','أنجز,قيد الإنجاز,لم ينجز',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,3,'col-12'),
(404,86,'الفصل الثالث في الرسالة','chapter_3','radio','أنجز,قيد الإنجاز,لم ينجز',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,4,'col-12'),
(405,86,'الفصل الرابع في الرسالة','chapter_4','radio','أنجز,قيد الإنجاز,لم ينجز',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,5,'col-12'),
-- ── Sec 87: تقرير المشرف الشامل ─────────────────────────────────────
(406,87,'مستوى تقدم الطالب في الرسالة','progress_level','radio','ممتاز,جيد جداً,جيد,مقبول,ضعيف',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,1,'col-12'),
(407,87,'ملاحظات عن أداء الطالب','performance_notes','textarea',NULL,TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,2,'col-12'),
(408,87,'المدة المتوقعة لإنهاء الرسالة','expected_duration','text',NULL,TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,3,'col-6'),
(409,87,'حالة تسليم الرسالة','thesis_submission_status','radio','تم تسليم الرسالة للمناقشة,لم تُسلَّم بعد',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,4,'col-12'),
(410,87,'توقيع المشرف (صورة)','supervisor_signature','file',NULL,TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,5,'col-6'),
(411,87,'تاريخ التقرير','supervisor_date','date',NULL,TRUE,TRUE,TRUE,FALSE,1,'CURRENT_DATE',NULL,NULL,6,'col-6'),
-- ── Sec 88: مراجعة منسق البرنامج ────────────────────────────────────
(412,88,'قرار منسق البرنامج','coordinator_decision','radio','معتمد,مرفوض,إرجاع للمشرف',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,1,'col-12'),
(413,88,'رأي منسق البرنامج','coordinator_opinion','textarea',NULL,FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,2,'col-12'),
(414,88,'توقيع منسق البرنامج (صورة)','coordinator_signature','file',NULL,TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,3,'col-6'),
(415,88,'تاريخ المراجعة','coordinator_date','date',NULL,TRUE,TRUE,TRUE,FALSE,1,'CURRENT_DATE',NULL,NULL,4,'col-6'),
-- ── Sec 89: اعتماد رئيس القسم ───────────────────────────────────────
(416,89,'قرار رئيس القسم','head_decision','radio','معتمد,مرفوض',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,1,'col-12'),
(417,89,'ملاحظات رئيس القسم','head_notes','textarea',NULL,FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,2,'col-12'),
(418,89,'توقيع رئيس القسم (صورة)','head_signature','file',NULL,TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,3,'col-6'),
(419,89,'تاريخ الاعتماد','head_date','date',NULL,TRUE,TRUE,TRUE,FALSE,1,'CURRENT_DATE',NULL,NULL,4,'col-6'),
-- ── Sec 90: اعتماد عميد الكلية ───────────────────────────────────────
(420,90,'قرار عميد الكلية','dean_decision','radio','معتمد,مرفوض',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,1,'col-12'),
(421,90,'ملاحظات عميد الكلية','dean_notes','textarea',NULL,FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,2,'col-12'),
(422,90,'توقيع عميد الكلية (صورة)','dean_signature','file',NULL,TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,3,'col-6'),
(423,90,'تاريخ الاعتماد','dean_date','date',NULL,TRUE,TRUE,TRUE,FALSE,1,'CURRENT_DATE',NULL,NULL,4,'col-6');