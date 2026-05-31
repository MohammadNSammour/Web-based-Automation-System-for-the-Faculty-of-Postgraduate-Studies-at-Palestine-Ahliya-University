-- ════════════════════════════════════════════════════════════════════════
-- test_data.sql — بيانات اختبار كاملة
-- طالب جديد + جميع الأدوار المطلوبة في التسلسل
-- كلمة المرور لجميع المستخدمين: Test@1234
-- (password_hash of 'Test@1234' using PASSWORD_DEFAULT)
-- ════════════════════════════════════════════════════════════════════════

USE MPA2;

-- ════════════════════════════════════════════════════════════════════════
-- 1. المستخدمون — Users
-- ════════════════════════════════════════════════════════════════════════

INSERT INTO Users
    (UserID, FirstName, FatherName, LastName, UserName, Email, NationalID,
     Gender, College, Department, Program, UserType, Password)
VALUES
-- الطالب
(1, 'محمد', 'نافذ', 'سمور', 'student1', 'student1@test.com', '123456789',
 'Male', 'كلية الدراسات العليا', 'قسم إدارة الأعمال', 'ماجستير إدارة الأعمال',
 'Student', 'Test@1234'),

-- منسق البرنامج
(2, 'معتز', 'رسمي', 'ابو سارة', 'coordinator1', 'coord1@test.com', '223456789',
 'Male', 'كلية الدراسات العليا', 'قسم إدارة الأعمال', NULL,
 'Employee', 'Test@1234'),

-- رئيس القسم
(3, 'سامح', 'يوسف', 'طقاطقة', 'head1', 'head1@test.com', '323456789',
 'Male', 'كلية الدراسات العليا', 'قسم إدارة الأعمال', NULL,
 'Employee', 'Test@1234'),

-- عميد الكلية
(4, 'هيثم', 'وائل', 'حجازي', 'dean1', 'dean1@test.com', '423456789',
 'Male', 'كلية الدراسات العليا', NULL, NULL,
 'Employee', 'Test@1234'),

-- عميد الدراسات العليا
(5, 'فيصل', 'أحمد', 'الحمدان', 'graddean1', 'graddean1@test.com', '523456789',
 'Male', 'كلية الدراسات العليا', NULL, NULL,
 'Employee', 'Test@1234'),

-- المشرف
(6, 'أحمد', 'محمد', 'عطا الله', 'supervisor1', 'super1@test.com', '623456789',
 'Male', 'كلية الدراسات العليا', 'قسم إدارة الأعمال', NULL,
 'Employee', 'Test@1234'),

-- ممتحن داخلي
(7, 'وليد', 'سعيد', 'منصور', 'examiner_int', 'examint@test.com', '723456789',
 'Male', 'كلية الدراسات العليا', 'قسم إدارة الأعمال', NULL,
 'Employee', 'Test@1234'),

-- ممتحن خارجي
(8, 'ماجد', 'راشد', 'العتيبي', 'examiner_ext', 'examext@test.com', '823456789',
 'Male', 'جامعة خارجية', 'قسم الأعمال', NULL,
 'Employee', 'Test@1234'),

-- مشرف نظام (Admin)
(9, 'أدمن', 'النظام', 'الإداري', 'admin1', 'admin@test.com', '923456789',
 'Male', NULL, NULL, NULL,
 'Employee', 'Test@1234');

-- ════════════════════════════════════════════════════════════════════════
-- 2. الموظفون — Employees
-- ════════════════════════════════════════════════════════════════════════

INSERT INTO Employees
    (EmployeeNumber, UserID, AcademicRank, Specialization, IsSupervisor, IsAvailable)
VALUES
(101, 2, 'أستاذ مساعد', 'تكنولوجيا المعلومات',           0, 1), -- منسق
(102, 3, 'أستاذ مشارك', 'تكنولوجيا المعلومات',           0, 1), -- رئيس قسم
(103, 4, 'أستاذ',       NULL,                       0, 1), -- عميد كلية
(104, 5, 'أستاذ',       NULL,                       0, 1), -- عميد دراسات
(105, 6, 'أستاذ مشارك', 'تكنولوجيا المعلومات', 1, 1), -- مشرف
(106, 7, 'أستاذ مساعد', 'إدارة الأعمال',           0, 1), -- ممتحن داخلي
(107, 8, 'أستاذ',       'الإدارة الاستراتيجية',   0, 1), -- ممتحن خارجي
(108, 9, NULL,          NULL,                       0, 1); -- أدمن

-- ════════════════════════════════════════════════════════════════════════
-- 3. أدوار الموظفين — Employee_Roles
-- ════════════════════════════════════════════════════════════════════════

INSERT INTO Employee_Roles (EmployeeNumber, Role) VALUES
(101, 'ProgramCoordinator'),
(102, 'HeadOfSection'),
(103, 'DeanOfFaculty'),
(104, 'DeanOfGradStudies'),
(105, 'Supervisor'),
(106, 'Examiner'),
(107, 'Examiner'),
(108, 'Admin');

-- ════════════════════════════════════════════════════════════════════════
-- 4. الطالب — Students
-- ════════════════════════════════════════════════════════════════════════

INSERT INTO Students
    (StudentNumber, UserID, UniversityID, GPA, TotalCompletedHours,
     EnrollmentSemester, EnrollmentYear)
VALUES
-- لاحظ: UniversityID فارغ → يعني غير مسجل → dashboard سيوجهه لـ 700
(1001, 1, NULL, NULL, 0, NULL, NULL);

-- ════════════════════════════════════════════════════════════════════════
-- 5. Session بيانات — للمرجع فقط
-- ════════════════════════════════════════════════════════════════════════
/*
بيانات تسجيل الدخول لكل مستخدم (كلمة المرور: Test@1234):

الطالب:
    UserName: student1
    Password: Test@1234
    current_role: Student

منسق البرنامج:
    UserName: coordinator1
    Password: Test@1234
    current_role: ProgramCoordinator

رئيس القسم:
    UserName: head1
    Password: Test@1234
    current_role: HeadOfSection

عميد الكلية:
    UserName: dean1
    Password: Test@1234
    current_role: DeanOfFaculty

عميد الدراسات العليا:
    UserName: graddean1
    Password: Test@1234
    current_role: DeanOfGradStudies

المشرف:
    UserName: supervisor1
    Password: Test@1234
    current_role: Supervisor

الممتحن الداخلي:
    UserName: examiner_int
    Password: Test@1234
    current_role: Examiner

الممتحن الخارجي:
    UserName: examiner_ext
    Password: Test@1234
    current_role: Examiner

الأدمن:
    UserName: admin1
    Password: Test@1234
    current_role: Admin
*/

-- ════════════════════════════════════════════════════════════════════════
-- 6. التحقق — تأكد من إدخال البيانات بشكل صحيح
-- ════════════════════════════════════════════════════════════════════════

SELECT 'Users' AS tbl, COUNT(*) AS cnt FROM Users
UNION ALL
SELECT 'Employees', COUNT(*) FROM Employees
UNION ALL
SELECT 'Employee_Roles', COUNT(*) FROM Employee_Roles
UNION ALL
SELECT 'Students', COUNT(*) FROM Students;

-- طالب اخر جديد
INSERT INTO Users
    (UserID, FirstName, FatherName, LastName, UserName, Email, NationalID,
     Gender, College, Department, Program, UserType, Password)
VALUES
-- الطالب
(12, 'حنا', 'داود', 'غنيم', 'student2', 'student2@test.com', '133456789',
 'Male', 'كلية الدراسات العليا', 'قسم إدارة الأعمال', 'ماجستير إدارة الأعمال',
 'Student', 'Test@1234');
 INSERT INTO Students
    (StudentNumber, UserID, UniversityID, GPA, TotalCompletedHours,
     EnrollmentSemester, EnrollmentYear)
VALUES
-- لاحظ: UniversityID فارغ → يعني غير مسجل → dashboard سيوجهه لـ 700
(1002, 12, NULL, NULL, 0, NULL, NULL);
-- طالب اخر جديد
INSERT INTO Users
    (UserID, FirstName, FatherName, LastName, UserName, Email, NationalID,
     Gender, College, Department, Program, UserType, Password)
VALUES
-- الطالب
(13, 'روجيه', 'جاك', 'طبش', 'student3', 'student3@test.com', '193456789',
 'Male', 'كلية الدراسات العليا', 'قسم إدارة الأعمال', 'ماجستير إدارة الأعمال',
 'Student', 'Test@1234');
 INSERT INTO Students
    (StudentNumber, UserID, UniversityID, GPA, TotalCompletedHours,
     EnrollmentSemester, EnrollmentYear)
VALUES
-- لاحظ: UniversityID فارغ → يعني غير مسجل → dashboard سيوجهه لـ 700
(1003, 13, NULL, NULL, 0, NULL, NULL);
