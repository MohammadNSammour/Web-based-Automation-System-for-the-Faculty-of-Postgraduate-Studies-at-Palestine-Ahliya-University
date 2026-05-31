USE MPA2;
-- ------------------------------------------------------------
-- ------------------------------------------------------------
-- FORM 8-706 : استجابة الممتحن على طلب المراجعة
-- ------------------------------------------------------------
-- ------------------------------------------------------------
INSERT INTO FormTypes (FormTypeID,Code,Name,Description,DisplayOrder,IsStartingForm,Category) VALUES
(8,'706','استجابة الممتحن على طلب المراجعة','نموذج استقبال استجابة الممتحن على دعوة المراجعة (قبول/رفض)',8,0,'Defense');

INSERT INTO FormWorkflowSteps (StepID, FormTypeID, StepName, StepOrder, AllowedRole, RequiresSpecificUser) VALUES
(43, 11, 'رد الممتحن على طلب المراجعة', 1, 'Examiner', TRUE),
(44, 11, 'توثيق الاستجابة من قبل منسق البرنامج', 2, 'ProgramCoordinator', FALSE)
ON DUPLICATE KEY UPDATE StepID = StepID;

INSERT INTO FormSections (SectionID, StepID, SectionName, SectionOrder) VALUES
(91, 43, 'بيانات الطالب والرسالة', 1),
(92, 43, 'استجابة الممتحن', 2),
(93, 44, 'توثيق الاستجابة', 1)
ON DUPLICATE KEY UPDATE SectionID = SectionID;

INSERT INTO FormFields (FieldID, SectionID, FieldName, FieldLabel, FieldType, IsRequired, Row, Col, IsReadOnly, IsAutoFill, DataSource) VALUES
(414, 91, 'StudentName', 'اسم الطالب', 'text', 1, 1, 1, 1, 1, 'Students.[FirstName] + " " + [LastName]'),
(415, 91, 'ThesisTitle', 'عنوان الرسالة', 'text', 1, 1, 2, 1, 1, 'Thesis.Title'),
(416, 91, 'ExaminerName', 'اسم الممتحن المقترح', 'text', 1, 2, 1, 1, 1, 'Users.[FirstName] + " " + [LastName]'),
(417, 91, 'ExaminerType', 'نوع الممتحن', 'select', 1, 2, 2, 1, 1, '__dynamic: ExaminerTypes'),
(418, 92, 'ExaminerResponse', 'استجابة الممتحن', 'radio', 1, 1, 1, 0, 0, 'قبول|acceptance,رفض|rejection'),
(419, 92, 'RejectionReason', 'إذا كانت الاستجابة برفض، يُرجى تحديد السبب', 'textarea', 0, 2, 1, 0, 0, NULL),
(420, 92, 'ExaminerSignature', 'التوقيع الرقمي', 'signature', 1, 3, 1, 0, 0, NULL),
(421, 93, 'ProcessingNotes', 'ملاحظات المعالجة', 'textarea', 0, 1, 1, 0, 0, NULL),
(422, 93, 'CoordinatorSignature', 'توقيع منسق البرنامج', 'signature', 1, 2, 1, 0, 0, NULL)
ON DUPLICATE KEY UPDATE FieldID = FieldID;