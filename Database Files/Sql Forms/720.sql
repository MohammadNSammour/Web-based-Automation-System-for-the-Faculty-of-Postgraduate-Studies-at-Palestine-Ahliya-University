USE MPA2;
-- ------------------------------------------------------------
-- ------------------------------------------------------------
-- FORM 4-720 : تقرير المتابعة الشهرية للمشرف
-- ------------------------------------------------------------
-- ------------------------------------------------------------
INSERT INTO FormTypes (FormTypeID,Code,Name,Description,DisplayOrder,IsStartingForm,Category,OpeningMessage) VALUES
(4,'720','تقرير المتابعة الشهرية للمشرف','تقرير شهري دوري عن لقاءات المشرف بالطالب',4,0,'Monitoring','يجب على الطالب ان يكون قد انهى 30 ساعة من الساعات المعتمدة بالاضافة الى الرسالة الاولى');

INSERT INTO FormWorkflowSteps (StepID,FormTypeID,StepName,StepOrder,AllowedRole,RequiresSpecificUser) VALUES
(35,4,'تعبئة التقرير الشهري — المشرف',1,'Supervisor',FALSE),
(36,4,'مراجعة منسق البرنامج',2,'ProgramCoordinator',FALSE),
(37,4,'اعتماد رئيس القسم',3,'HeadOfSection',FALSE),
(38,4,'اعتماد عميد الكلية',4,'DeanOfFaculty',FALSE);

INSERT INTO FormSections (SectionID,StepID,SectionName,SectionOrder) VALUES
(77,35,'اختيار الطالب',1),
(78,35,'بيانات الطالب',2),
(79,35,'تفاصيل اللقاء الشهري',3),
(80,35,'توقيعات الحضور',4),
(81,36,'مراجعة منسق البرنامج',1),
(82,37,'اعتماد رئيس القسم',1),
(83,38,'اعتماد عميد الكلية',1);

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