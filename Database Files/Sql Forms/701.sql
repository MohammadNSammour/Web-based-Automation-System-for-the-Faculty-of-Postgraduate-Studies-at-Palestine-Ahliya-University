USE MPA2;
-- ------------------------------------------------------------
-- ------------------------------------------------------------
-- FORM 2-701 : استمارة تعيين مشرف وإقرار خطة أطروحة
-- ------------------------------------------------------------
-- ------------------------------------------------------------
-- يحتاج للتعديل بحيث ان الطالب هو من يختار المشرف ويرفع خطة الاطروحة الاولية ثم يوافق المشرف ثم منسق البرنامج ثم رئيس القسم ثم عميد الكلية
INSERT INTO FormTypes (FormTypeID,Code,Name,Description,DisplayOrder,IsStartingForm,Category,OpeningMessage) VALUES
(2,'701','استمارة تعيين مشرف وإقرار خطة أطروحة','تعيين المشرف الأكاديمي وإقرار خطة البحث الأولية',2,0,'Supervision','دخولك لهذا النموذج يعني انك قد اتمتت 18 ساعة من ساعات خطتك المعتمدة بالاضافة الى مادة مناهج البحث العلمي');

INSERT INTO FormWorkflowSteps (StepID,FormTypeID,StepName,StepOrder,AllowedRole,RequiresSpecificUser) VALUES
(6,2,'اقتراح منسق البرنامج',1,'ProgramCoordinator',FALSE),
(7,2,'اعتماد رئيس القسم',2,'HeadOfSection',FALSE),
(8,2,'اعتماد عميد الكلية',3,'DeanOfFaculty',FALSE);

INSERT INTO FormSections (SectionID,StepID,SectionName,SectionOrder) VALUES
(11,6,'بيانات التخصص والبرنامج',1),
(12,6,'بيانات الطالب',2),
(13,6,'بيانات الأطروحة والمشرف',3),
(14,6,'المستندات الداعمة',4),
(15,6,'توقيع منسق البرنامج',5),
(16,7,'اعتماد رئيس القسم',1),
(17,8,'اعتماد عميد الكلية',1);

INSERT INTO FormFields (FieldID,SectionID,FieldLabel,FieldName,FieldType,FieldOptions,IsRequired,IsReadOnly,IsAutoFill,IsRepeatable,MaxRepeat,DataSource,ConditionalOn,ConditionalValue,FieldOrder,CSSClass) VALUES
-- ── Sec 11: بيانات التخصص والبرنامج (تلقائية) ───────────────────────
(55,11,'اسم التخصص (البرنامج)','program_name','text',NULL,TRUE,TRUE,TRUE,FALSE,1,'Students.Programs.ProgramName',NULL,NULL,1,'col-6'),
(56,11,'القسم الأكاديمي','department_name','text',NULL,TRUE,TRUE,TRUE,FALSE,1,'Students.Programs.Sections.SectionName',NULL,NULL,2,'col-6'),
(57,11,'الكلية','faculty_name','text',NULL,TRUE,TRUE,TRUE,FALSE,1,'Students.Programs.Sections.Departments.DepartmentName',NULL,NULL,3,'col-6'),
-- ── Sec 12: بيانات الطالب (تلقائية من Students) ────────────────────
(58,12,'اسم الطالب الكامل','student_name','text',NULL,FALSE,TRUE,TRUE,FALSE,1,'Students.Users.full_name',NULL,NULL,1,'col-6'),
(59,12,'الرقم الجامعي','student_university_id','text',NULL,FALSE,TRUE,TRUE,FALSE,1,'Students.UniversityID',NULL,NULL,2,'col-6'),
(60,12,'تاريخ الالتحاق بالتخصص','enrollment_date','date',NULL,FALSE,TRUE,TRUE,FALSE,1,'Students.MajorJoinDate',NULL,NULL,3,'col-6'),
(61,12,'عدد الساعات المجتازة','completed_hours','number',NULL,FALSE,TRUE,TRUE,FALSE,1,'Students.TotalCompletedHours',NULL,NULL,4,'col-6'),
(62,12,'المعدل التراكمي','gpa','number',NULL,FALSE,TRUE,TRUE,FALSE,1,'Students.GPA',NULL,NULL,5,'col-6'),
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
(74,15,'توقيع منسق البرنامج (صورة)','coordinator_signature','file',NULL,FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,2,'col-6'),
(75,15,'تاريخ الاستمارة','coordinator_date','date',NULL,TRUE,TRUE,TRUE,FALSE,1,'CURRENT_DATE',NULL,NULL,3,'col-6'),
-- ── Sec 16: اعتماد رئيس القسم ───────────────────────────────────────
(76,16,'قرار رئيس القسم','head_decision','radio','موافقة,رفض,إرجاع للتعديل',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,1,'col-12'),
(77,16,'ملاحظات رئيس القسم','head_notes','textarea',NULL,FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,2,'col-12'),
(78,16,'توقيع رئيس القسم (صورة)','head_signature','file',NULL,FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,3,'col-6'),
(79,16,'تاريخ الاعتماد','head_date','date',NULL,TRUE,TRUE,TRUE,FALSE,1,'CURRENT_DATE',NULL,NULL,4,'col-6'),
-- ── Sec 17: اعتماد عميد الكلية ──────────────────────────────────────
(80,17,'قرار عميد الكلية','dean_decision','radio','موافقة,رفض,إرجاع للتعديل',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,1,'col-12'),
(81,17,'ملاحظات عميد الكلية','dean_notes','textarea',NULL,FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,2,'col-12'),
(82,17,'توقيع عميد الكلية (صورة)','dean_signature','file',NULL,FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,3,'col-6'),
(83,17,'تاريخ الاعتماد','dean_date','date',NULL,TRUE,TRUE,TRUE,FALSE,1,'CURRENT_DATE',NULL,NULL,4,'col-6');
