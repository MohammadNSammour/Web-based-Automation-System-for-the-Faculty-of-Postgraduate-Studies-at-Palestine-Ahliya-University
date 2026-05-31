USE MPA2;
-- ------------------------------------------------------------
-- ------------------------------------------------------------
-- FORM 5-721 : تقرير متابعة لطلاب الدراسات العليا
-- ------------------------------------------------------------
-- ------------------------------------------------------------
INSERT INTO FormTypes (FormTypeID,Code,Name,Description,DisplayOrder,IsStartingForm,Category) VALUES
(5,'721','تقرير متابعة لطلاب الدراسات العليا','تقرير شامل يُقدَّم عند تسليم الرسالة للمناقشة',5,0,'Monitoring');

INSERT INTO FormWorkflowSteps (StepID,FormTypeID,StepName,StepOrder,AllowedRole,RequiresSpecificUser) VALUES
(39,5,'تقرير المشرف الشامل',1,'Supervisor',FALSE),
(40,5,'مراجعة منسق البرنامج',2,'ProgramCoordinator',FALSE),
(41,5,'اعتماد رئيس القسم',3,'HeadOfSection',FALSE),
(42,5,'اعتماد عميد الكلية',4,'DeanOfFaculty',FALSE);

INSERT INTO FormSections (SectionID,StepID,SectionName,SectionOrder) VALUES
-- 721 → Steps 39–42
(84,39,'اختيار الطالب',1),
(85,39,'بيانات الطالب',2),
(86,39,'الفصول الدراسية المنجزة',3),
(87,39,'تقرير المشرف الشامل',4),
(88,40,'مراجعة منسق البرنامج',1),
(89,41,'اعتماد رئيس القسم',1),
(90,42,'اعتماد عميد الكلية',1);

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