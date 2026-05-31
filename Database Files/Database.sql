
CREATE DATABASE IF NOT EXISTS MPA2
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE MPA2;

-- ════════════════════════════════════════════════════════════════════════
-- Part 1: المستخدمون والأدوار
-- ════════════════════════════════════════════════════════════════════════
-- first model
CREATE TABLE Users (
    UserID              INT AUTO_INCREMENT PRIMARY KEY,
    FirstName           VARCHAR(50)  NOT NULL,
    FatherName          VARCHAR(50)  NOT NULL,
    GrandfatherName     VARCHAR(50),
    LastName            VARCHAR(50)  NOT NULL,
    UserName            VARCHAR(50)  NOT NULL UNIQUE,
    Email               VARCHAR(100) NOT NULL UNIQUE,
    NationalID          VARCHAR(20)  NOT NULL UNIQUE,
    Gender              ENUM('Male','Female') NOT NULL,
    BirthDate           DATE,
    BirthPlace          VARCHAR(100),
    PhoneNumber         VARCHAR(20),
    Address             VARCHAR(255),
    WorkPlace           VARCHAR(100),
    National            VARCHAR(50),
    UniversityEnterDate DATE,
    College             VARCHAR(150),
    Department          VARCHAR(150),
    Program             VARCHAR(150)
        COMMENT 'البرنامج الدراسي — للطلاب فقط',
    Signature           VARCHAR(255)
        COMMENT 'مسار صورة التوقيع',
    UserType            ENUM('Student','Employee') NOT NULL,
    Password            VARCHAR(255) NOT NULL,
    CreatedAt           TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Employees (
    EmployeeNumber   INT PRIMARY KEY,
    UserID           INT NOT NULL UNIQUE,
    AcademicRank     VARCHAR(100),
    Specialization   VARCHAR(200),
    IsSupervisor     TINYINT(1) NOT NULL DEFAULT 0,
    IsAvailable      TINYINT(1) NOT NULL DEFAULT 1,
    MaxStudents      TINYINT UNSIGNED DEFAULT 5,
    FOREIGN KEY (UserID) REFERENCES Users(UserID) ON DELETE CASCADE
);

CREATE TABLE Employee_Roles (
    EmployeeNumber INT NOT NULL,
    Role ENUM(
        'Admin','Examiner','Supervisor','ProgramCoordinator',
        'HeadOfSection','DeanOfFaculty','DeanOfGradStudies'
    ) NOT NULL,
    PRIMARY KEY (EmployeeNumber, Role),
    FOREIGN KEY (EmployeeNumber)
        REFERENCES Employees(EmployeeNumber) ON DELETE CASCADE
);

CREATE TABLE Students (
    StudentNumber       INT PRIMARY KEY,
    UserID              INT NOT NULL UNIQUE,
    UniversityID        VARCHAR(20) UNIQUE,
    GPA                 DECIMAL(3,2),
    TotalCompletedHours INT DEFAULT 0,
    MajorJoinDate       DATE,
    EnrollmentSemester  VARCHAR(20),
    EnrollmentYear      VARCHAR(10),
    SupervisorID        INT
        COMMENT 'يُحدَّث عند اعتماد نموذج 701',
    FOREIGN KEY (UserID) REFERENCES Users(UserID) ON DELETE CASCADE,
    FOREIGN KEY (SupervisorID)
        REFERENCES Employees(EmployeeNumber) ON DELETE SET NULL
);

-- ════════════════════════════════════════════════════════════════════════
-- Part 2: الملفات
-- ════════════════════════════════════════════════════════════════════════

CREATE TABLE Files (
    FileNumber   INT AUTO_INCREMENT PRIMARY KEY,
    FileName     VARCHAR(255) NOT NULL,
    FilePath     VARCHAR(500) NOT NULL,
    FileType     VARCHAR(50),
    UploadedBy   INT,
    UploadDate   DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (UploadedBy) REFERENCES Users(UserID) ON DELETE SET NULL
);

-- ════════════════════════════════════════════════════════════════════════
-- Part 3: الرسالة
-- ════════════════════════════════════════════════════════════════════════
-- second model student +employee+employee rule + file+thesis
CREATE TABLE Thesis (
    ThesisID              INT AUTO_INCREMENT PRIMARY KEY,
    ThesisTitle           VARCHAR(300) NOT NULL,
    StudentNumber         INT NOT NULL,
    MainSupervisorID      INT NULL COMMENT 'يُملأ عند اعتماد 701',
    CoSupervisorID        INT NULL COMMENT 'يُملأ عند اعتماد 701 (اختياري)',
    InternalExaminerID    INT NULL COMMENT 'يُملأ عند اعتماد 705',
    ExternalExaminerID    INT NULL COMMENT 'يُملأ عند اعتماد 705',
    ThirdExaminerID       INT NULL COMMENT 'يُملأ عند تعيين ممتحن ثالث من لجنة الدراسات',
    ThesisFileID          INT NULL COMMENT 'ملف الرسالة النهائي',
    CreatedAt             DATETIME DEFAULT CURRENT_TIMESTAMP,
    CreatedBySubmissionID INT NULL COMMENT 'SubmissionID لنموذج 700',
    FOREIGN KEY (StudentNumber)
        REFERENCES Students(StudentNumber) ON DELETE CASCADE,
    FOREIGN KEY (MainSupervisorID)
        REFERENCES Employees(EmployeeNumber) ON DELETE SET NULL,
    FOREIGN KEY (CoSupervisorID)
        REFERENCES Employees(EmployeeNumber) ON DELETE SET NULL,
    FOREIGN KEY (InternalExaminerID)
        REFERENCES Employees(EmployeeNumber) ON DELETE SET NULL,
    FOREIGN KEY (ExternalExaminerID)
        REFERENCES Employees(EmployeeNumber) ON DELETE SET NULL,
    FOREIGN KEY (ThirdExaminerID)
        REFERENCES Employees(EmployeeNumber) ON DELETE SET NULL,
    FOREIGN KEY (ThesisFileID)
        REFERENCES Files(FileNumber) ON DELETE SET NULL
);

-- ════════════════════════════════════════════════════════════════════════
-- Part 4: محرك النماذج الديناميكي
-- ════════════════════════════════════════════════════════════════════════
-- model3 forms
CREATE TABLE FormTypes (
    FormTypeID               INT AUTO_INCREMENT PRIMARY KEY,
    Code                     VARCHAR(10)  NOT NULL UNIQUE,
    Name                     VARCHAR(200) NOT NULL,
    Description              TEXT,
    Category                 ENUM(
                                 'Enrollment',
                                 'Supervision',
                                 'Monitoring',
                                 'Defense',
                                 'Completion'
                             ) NOT NULL DEFAULT 'Enrollment',
    IsStartingForm           TINYINT(1) NOT NULL DEFAULT 0
        COMMENT '1 = نموذج 700 فقط',
    DisplayOrder             INT NOT NULL DEFAULT 1
        COMMENT 'ترتيب النموذج في التسلسل',

    -- [NEW-v6-1] السماح بأكثر من submission للطالب في نفس النموذج
    -- FALSE = النموذج العادي (submission واحد فقط) — الحالة الافتراضية
    -- TRUE  = نماذج الممتحنين 705,706,707 (submission لكل ممتحن)
    AllowMultipleSubmissions TINYINT(1) NOT NULL DEFAULT 0
        COMMENT '1 = يسمح بـ submissions متعددة (705,706,707)',

    -- [NEW-v6-2] رسالة تنبيه تظهر عند فتح النموذج لأول مرة
    -- مثال نموذج 701: "يُشترط اجتياز 18 ساعة ومناهج البحث"
    OpeningMessage           TEXT NULL
        COMMENT 'رسالة تنبيه عند فتح النموذج — NULL = لا رسالة'
);
ALTER TABLE FormTypes
    ADD COLUMN IF NOT EXISTS Category ENUM(
        'Enrollment','Supervision','Monitoring','Defense','Completion'
    ) NOT NULL DEFAULT 'Enrollment' AFTER Description,

    ADD COLUMN IF NOT EXISTS IsStartingForm TINYINT(1) NOT NULL DEFAULT 0
        COMMENT '1 = نموذج يبدأه المستخدم مباشرة من لوحة التحكم' AFTER Category,

    ADD COLUMN IF NOT EXISTS DisplayOrder INT NOT NULL DEFAULT 1
        COMMENT 'ترتيب النموذج في التسلسل الصارم' AFTER IsStartingForm;


CREATE TABLE FormWorkflowSteps (
    StepID               INT AUTO_INCREMENT PRIMARY KEY,
    FormTypeID           INT          NOT NULL,
    StepName             VARCHAR(100) NOT NULL,
    StepOrder            INT          NOT NULL,
    AllowedRole ENUM(
        'Student','Admin','Examiner','Supervisor',
        'ProgramCoordinator','HeadOfSection',
        'DeanOfFaculty','DeanOfGradStudies'
    ) NOT NULL,
    RequiresSpecificUser BOOLEAN DEFAULT FALSE
        COMMENT 'TRUE = يجب تعيين مستخدم بعينه',
    MaxRepeats           TINYINT NOT NULL DEFAULT 1
        COMMENT 'نموذج 720: 4 تكرارات',
    FOREIGN KEY (FormTypeID)
        REFERENCES FormTypes(FormTypeID) ON DELETE CASCADE,
    UNIQUE KEY uq_form_step (FormTypeID, StepOrder)
);

CREATE TABLE FormSections (
    SectionID    INT AUTO_INCREMENT PRIMARY KEY,
    StepID       INT          NOT NULL,
    SectionName  VARCHAR(150) NOT NULL,
    SectionOrder INT          NOT NULL DEFAULT 1,
    FOREIGN KEY (StepID)
        REFERENCES FormWorkflowSteps(StepID) ON DELETE CASCADE
);

CREATE TABLE FormFields (
    FieldID          INT AUTO_INCREMENT PRIMARY KEY,
    SectionID        INT          NOT NULL,
    FieldLabel       VARCHAR(200) NOT NULL,
    FieldName        VARCHAR(100) NOT NULL,
    FieldType        ENUM(
                         'text','number','email','textarea',
                         'select','radio','checkbox','checkbox_group',
                         'file','date','signature'
                     ) NOT NULL,
    FieldOptions     TEXT,
    IsRequired       BOOLEAN DEFAULT FALSE,
    IsReadOnly       BOOLEAN DEFAULT FALSE,
    IsAutoFill       TINYINT(1) NOT NULL DEFAULT 0,
    IsRepeatable     TINYINT(1) NOT NULL DEFAULT 0,
    MaxRepeat        TINYINT NOT NULL DEFAULT 1,
    DataSource       VARCHAR(255) NULL,
    ConditionalOn    VARCHAR(100) NULL,
    ConditionalValue VARCHAR(100) NULL,-- مثال: "coordinator_decision:قبول مشروط" ,any field contains this value will show the conditional field
    FieldOrder       INT NOT NULL DEFAULT 1,
    FieldValidation  JSON NULL,
    Placeholder      VARCHAR(200),
    CSSClass         VARCHAR(100) DEFAULT 'col-12',
    FOREIGN KEY (SectionID)
        REFERENCES FormSections(SectionID) ON DELETE CASCADE
);

-- ════════════════════════════════════════════════════════════════════════
-- Part 5: الطلبات وسير العمل
-- ════════════════════════════════════════════════════════════════════════

CREATE TABLE FormSubmissions (
    SubmissionID       INT AUTO_INCREMENT PRIMARY KEY,
    FormTypeID         INT NOT NULL,
    CurrentStepID      INT NOT NULL,
    CreatedBy          INT,
    StudentID          INT,
    ThesisID           INT NULL,
    Status             ENUM('InProgress','Approved','Rejected','Returned')
                       DEFAULT 'InProgress',

    -- [NEW-v5] رقم التكرار — نموذج 720
    RepeatNumber       TINYINT NOT NULL DEFAULT 1
        COMMENT 'نموذج 720: 1-4 | بقية النماذج: دائماً 1',

    -- [NEW-v6-3] نوع الممتحن — نماذج 706 و707
    ExaminerType       ENUM('Internal','External','Third') NULL
        COMMENT 'نوع الممتحن في نماذج 706/707',

    -- [NEW-v6-4] الممتحن المحدد لهذا الـ submission
    ExaminerEmployeeID INT NULL
        COMMENT 'EmployeeNumber للممتحن المحدد',

    CreatedAt          DATETIME DEFAULT CURRENT_TIMESTAMP,
    LastUpdated        DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (FormTypeID)
        REFERENCES FormTypes(FormTypeID) ON DELETE RESTRICT,
    FOREIGN KEY (CurrentStepID)
        REFERENCES FormWorkflowSteps(StepID) ON DELETE RESTRICT,
    FOREIGN KEY (CreatedBy)
        REFERENCES Users(UserID) ON DELETE SET NULL,
    FOREIGN KEY (StudentID)
        REFERENCES Students(StudentNumber) ON DELETE SET NULL,
    FOREIGN KEY (ThesisID)
        REFERENCES Thesis(ThesisID) ON DELETE SET NULL,
    FOREIGN KEY (ExaminerEmployeeID)
        REFERENCES Employees(EmployeeNumber) ON DELETE SET NULL
);

CREATE TABLE StudentProgress (
    ProgressID    INT AUTO_INCREMENT PRIMARY KEY,
    StudentNumber INT NOT NULL,
    FormTypeID    INT NOT NULL,
    SubmissionID  INT NOT NULL,
    ThesisID      INT NULL,
    RepeatNumber  TINYINT NOT NULL DEFAULT 1
        COMMENT 'نموذج 720: سجل لكل تكرار',
    CompletedAt   DATETIME DEFAULT CURRENT_TIMESTAMP,
    ExaminerType ENUM('Internal','External','Third') NULL
    COMMENT 'لنماذج 706/707 فقط',

    -- يسمح بتكرار نفس النموذج (705,706,707) لكل ممتحن
    -- RepeatNumber يميز بين التكرارات في 720
    UNIQUE KEY uq_student_form_repeat (StudentNumber, FormTypeID, RepeatNumber,ExaminerType),

    FOREIGN KEY (StudentNumber)
        REFERENCES Students(StudentNumber) ON DELETE CASCADE,
    FOREIGN KEY (FormTypeID)
        REFERENCES FormTypes(FormTypeID) ON DELETE RESTRICT,
    FOREIGN KEY (SubmissionID)
        REFERENCES FormSubmissions(SubmissionID) ON DELETE RESTRICT,
    FOREIGN KEY (ThesisID)
        REFERENCES Thesis(ThesisID) ON DELETE SET NULL
);

CREATE TABLE FormValues (
    SubmissionID INT  NOT NULL,
    FieldID      INT  NOT NULL,
    StepID       INT  NOT NULL,
    FieldValue   TEXT,
    EnteredAt    DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (SubmissionID, FieldID, StepID),
    FOREIGN KEY (SubmissionID)
        REFERENCES FormSubmissions(SubmissionID) ON DELETE CASCADE,
    FOREIGN KEY (FieldID)
        REFERENCES FormFields(FieldID) ON DELETE RESTRICT,
    FOREIGN KEY (StepID)
        REFERENCES FormWorkflowSteps(StepID) ON DELETE RESTRICT
);
    -- يسمح بتكرار نفس النموذج (705,706,707) لكل ممتحن، لذلك نحتاج لتخزين القيم لكل تكرار بشكل مستقل
CREATE TABLE FormSubmissionAssignees (
    SubmissionID INT NOT NULL,
    StepID       INT NOT NULL,
    UserID       INT NOT NULL,
    AssignedAt   DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (SubmissionID, StepID, UserID),
    FOREIGN KEY (SubmissionID)
        REFERENCES FormSubmissions(SubmissionID) ON DELETE CASCADE,
    FOREIGN KEY (StepID)
        REFERENCES FormWorkflowSteps(StepID) ON DELETE RESTRICT,
    FOREIGN KEY (UserID)
        REFERENCES Users(UserID) ON DELETE RESTRICT
);

CREATE TABLE FormWorkflowHistory (
    HistoryID        INT AUTO_INCREMENT PRIMARY KEY,
    SubmissionID     INT  NOT NULL,
    StepID           INT  NOT NULL,
    Action           ENUM('Submitted','Approved','Rejected','Returned') NOT NULL,
    Notes            TEXT,
    ActedBy          INT,
    ReturnedToStepID INT NULL,
    ActionDate       DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (SubmissionID)
        REFERENCES FormSubmissions(SubmissionID) ON DELETE CASCADE,
    FOREIGN KEY (StepID)
        REFERENCES FormWorkflowSteps(StepID) ON DELETE RESTRICT,
    FOREIGN KEY (ActedBy)
        REFERENCES Users(UserID) ON DELETE SET NULL,
    FOREIGN KEY (ReturnedToStepID)
        REFERENCES FormWorkflowSteps(StepID) ON DELETE RESTRICT
);
-- model 4 progress + forms
-- ════════════════════════════════════════════════════════════════════════
-- Part 6: الإشعارات
-- ════════════════════════════════════════════════════════════════════════
-- model 5 nofifications + users+forms
CREATE TABLE Notifications (
    NotificationID      INT AUTO_INCREMENT PRIMARY KEY,
    SenderID            INT,
    Message             TEXT NOT NULL,
    Type                ENUM(
                            'FormSubmitted','FormApproved',
                            'FormRejected','FormReturned','General'
                        ) DEFAULT 'General',
    RelatedSubmissionID INT,
    CreatedAt           DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (SenderID)
        REFERENCES Users(UserID) ON DELETE SET NULL,
    FOREIGN KEY (RelatedSubmissionID)
        REFERENCES FormSubmissions(SubmissionID) ON DELETE SET NULL
);

CREATE TABLE NotificationTo (
    NotificationID INT     NOT NULL,
    UserID         INT     NOT NULL,
    IsRead         BOOLEAN DEFAULT FALSE,
    PRIMARY KEY (NotificationID, UserID),
    FOREIGN KEY (NotificationID)
        REFERENCES Notifications(NotificationID) ON DELETE CASCADE,
    FOREIGN KEY (UserID)
        REFERENCES Users(UserID) ON DELETE CASCADE
);

-- ════════════════════════════════════════════════════════════════════════
-- Part 7: FKs المؤجلة
-- ════════════════════════════════════════════════════════════════════════

ALTER TABLE Thesis
    ADD CONSTRAINT fk_thesis_submission
    FOREIGN KEY (CreatedBySubmissionID)
        REFERENCES FormSubmissions(SubmissionID) ON DELETE SET NULL;

-- ════════════════════════════════════════════════════════════════════════
-- Part 8: الفهارس
-- ════════════════════════════════════════════════════════════════════════

CREATE INDEX idx_submissions_status       ON FormSubmissions(Status);
CREATE INDEX idx_submissions_step         ON FormSubmissions(CurrentStepID);
CREATE INDEX idx_submissions_thesis       ON FormSubmissions(ThesisID);
CREATE INDEX idx_submissions_student      ON FormSubmissions(StudentID);
CREATE INDEX idx_submissions_examiner     ON FormSubmissions(ExaminerEmployeeID, ExaminerType);
CREATE INDEX idx_form_student_repeat      ON FormSubmissions(FormTypeID, StudentID, RepeatNumber, Status);
CREATE INDEX idx_progress_student         ON StudentProgress(StudentNumber);
CREATE INDEX idx_progress_form_repeat     ON StudentProgress(StudentNumber, FormTypeID, RepeatNumber);
CREATE INDEX idx_thesis_student           ON Thesis(StudentNumber);
CREATE INDEX idx_thesis_supervisors       ON Thesis(MainSupervisorID);
CREATE INDEX idx_thesis_examiners         ON Thesis(InternalExaminerID, ExternalExaminerID, ThirdExaminerID);
CREATE INDEX idx_employees_supervisor     ON Employees(IsSupervisor, IsAvailable);
CREATE INDEX idx_fields_section           ON FormFields(SectionID);
CREATE INDEX idx_values_submission        ON FormValues(SubmissionID);
CREATE INDEX idx_assignees_submission     ON FormSubmissionAssignees(SubmissionID);
CREATE INDEX idx_notif_user_read          ON NotificationTo(UserID, IsRead);
CREATE INDEX idx_history_submission       ON FormWorkflowHistory(SubmissionID);
ALTER TABLE StudentProgress
DROP INDEX uq_student_form_repeat;
