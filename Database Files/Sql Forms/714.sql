USE MPA2;
-- ------------------------------------------------------------
-- ------------------------------------------------------------
-- FORM 10-714 : إتمام التعديلات لأطروحة ماجستير
-- ------------------------------------------------------------
-- ------------------------------------------------------------
INSERT INTO FormTypes (FormTypeID,Code,Name,Description,DisplayOrder,IsStartingForm,Category) VALUES
(10,'714','إتمام التعديلات لأطروحة ماجستير','إقرار لجنة المناقشة بأن الطالب أجرى التعديلات المطلوبة',10,0,'Completion');

INSERT INTO FormWorkflowSteps (StepID,FormTypeID,StepName,StepOrder,AllowedRole,RequiresSpecificUser) VALUES
(26,10,'إقرار المشرف ولجنة المناقشة',1,'Supervisor',FALSE),
(27,10,'مراجعة منسق البرنامج',2,'ProgramCoordinator',FALSE),
(28,10,'مراجعة رئيس القسم',3,'HeadOfSection',FALSE),
(29,10,'مصادقة رئيس اللجنة في الكلية',4,'DeanOfFaculty',FALSE),
(30,10,'مصادقة عميد الدراسات العليا',5,'DeanOfGradStudies',FALSE);

INSERT INTO FormSections (SectionID,StepID,SectionName,SectionOrder) VALUES
(66,26,'بيانات الطالب والرسالة',1),
(67,26,'توقيعات لجنة المناقشة',2),
(68,27,'مراجعة منسق البرنامج',1),
(69,28,'مراجعة رئيس القسم',1),
(70,29,'مصادقة رئيس اللجنة في الكلية',1),
(71,30,'مصادقة عميد الدراسات العليا',1);

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