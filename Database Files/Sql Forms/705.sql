USE MPA2;
-- ------------------------------------------------------------
-- ------------------------------------------------------------
-- FORM 7-705 : محضر اجتماع تعيين الممتحنين
-- ------------------------------------------------------------
-- ------------------------------------------------------------
INSERT INTO FormTypes (FormTypeID,Code,Name,Description,DisplayOrder,IsStartingForm,Category) VALUES
(7,'705','محضر اجتماع تعيين الممتحنين','محضر اللجنة لتعيين الممتحن الداخلي والخارجي',7,0,'Defense');

INSERT INTO FormWorkflowSteps (StepID,FormTypeID,StepName,StepOrder,AllowedRole,RequiresSpecificUser) VALUES
(19,7,'تعبئة المحضر — منسق البرنامج',1,'ProgramCoordinator',FALSE),
(20,7,'مراجعة رئيس القسم',2,'HeadOfSection',FALSE),
(21,7,'اعتماد عميد الكلية',3,'DeanOfFaculty',FALSE),
(22,7,'مصادقة عميد الدراسات العليا',4,'DeanOfGradStudies',FALSE);

INSERT INTO FormSections (SectionID,StepID,SectionName,SectionOrder) VALUES
(36,19,'اختيار الطالب',1),
(37,19,'بيانات الاجتماع',2),
(38,19,'بيانات الرسالة والطالب',3),
(39,19,'أعضاء اللجنة الحاضرون',4),
(40,19,'تعيين الممتحنين',5),
(41,20,'مراجعة رئيس القسم',1),
(42,21,'اعتماد عميد الكلية',1),
(43,22,'مصادقة عميد الدراسات العليا',1);

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
