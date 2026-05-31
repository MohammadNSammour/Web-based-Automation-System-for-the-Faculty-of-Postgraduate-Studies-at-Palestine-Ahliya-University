USE MPA2;
-- ------------------------------------------------------------
-- ------------------------------------------------------------
-- FORM 6-708 : نموذج تعيين موعد المناقشة
-- ------------------------------------------------------------
-- ------------------------------------------------------------
INSERT INTO FormTypes (FormTypeID,Code,Name,Description,DisplayOrder,IsStartingForm,Category) VALUES
(6,'708','نموذج تعيين موعد المناقشة','خطاب رسمي من منسق البرنامج يقترح موعد مناقشة الرسالة',6,0,'Defense');

INSERT INTO FormWorkflowSteps (StepID,FormTypeID,StepName,StepOrder,AllowedRole,RequiresSpecificUser) VALUES
(15,6,'اقتراح منسق البرنامج',1,'ProgramCoordinator',FALSE),
(16,6,'مراجعة رئيس القسم',2,'HeadOfSection',FALSE),
(17,6,'اعتماد عميد الكلية',3,'DeanOfFaculty',FALSE),
(18,6,'قرار عميد الدراسات العليا',4,'DeanOfGradStudies',FALSE);

INSERT INTO FormSections (SectionID,StepID,SectionName,SectionOrder) VALUES
(28,15,'اختيار الطالب',1),
(29,15,'بيانات الطالب والرسالة',2),
(30,15,'الموعد المقترح للمناقشة',3),
(31,15,'الملفات الداعمة',4),
(32,15,'توقيع منسق البرنامج',5),
(33,16,'مراجعة رئيس القسم',1),
(34,17,'اعتماد عميد الكلية',1),
(35,18,'قرار عميد الدراسات العليا',1);

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