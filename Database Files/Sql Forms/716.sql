USE MPA2;
-- ------------------------------------------------------------
-- ------------------------------------------------------------
-- FORM 11-716 : إجازة رسالة جامعية
-- ------------------------------------------------------------
-- ------------------------------------------------------------
INSERT INTO FormTypes (FormTypeID,Code,Name,Description,DisplayOrder,IsStartingForm,Category) VALUES
(11,'716','إجازة رسالة جامعية','قرار إجازة الرسالة موقّعاً من لجنة المناقشة الكاملة',11,0,'Completion');

INSERT INTO FormWorkflowSteps (StepID,FormTypeID,StepName,StepOrder,AllowedRole,RequiresSpecificUser) VALUES
(31,11,'إعداد قرار الإجازة من العمادة',1,'DeanOfFaculty',FALSE),
(32,11,'توقيع الممتحن الداخلي',2,'Examiner',TRUE),
(33,11,'توقيع الممتحن الخارجي',3,'Examiner',TRUE),
(34,11,'مصادقة عميد الدراسات العليا',4,'DeanOfGradStudies',FALSE);

INSERT INTO FormSections (SectionID,StepID,SectionName,SectionOrder) VALUES
(72,31,'بيانات الطالب والرسالة',1),
(73,31,'توقيع المشرف رئيس اللجنة',2),
(74,32,'توقيع الممتحن الداخلي',1),
(75,33,'توقيع الممتحن الخارجي',1),
(76,34,'مصادقة عميد الدراسات العليا',1);

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