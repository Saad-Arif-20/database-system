-- ============================================================================
-- University Course Management System - Database Schema
-- ============================================================================
-- Author: SAAD ARIF
-- Purpose: Demonstrate database design, normalization, and SQL proficiency
-- Database: SQLite (portable, no server required)
-- ============================================================================

-- Drop existing tables if they exist (for clean recreation)
DROP TABLE IF EXISTS Enrollment;
DROP TABLE IF EXISTS CourseOffering;
DROP TABLE IF EXISTS Course;
DROP TABLE IF EXISTS Instructor;
DROP TABLE IF EXISTS Student;
DROP TABLE IF EXISTS Program;
DROP TABLE IF EXISTS Department;

-- ============================================================================
-- DEPARTMENT TABLE
-- ============================================================================
-- Represents academic departments within the university
-- ============================================================================

CREATE TABLE Department (
    DepartmentID INTEGER PRIMARY KEY AUTOINCREMENT,
    DepartmentName VARCHAR(100) NOT NULL UNIQUE,
    Building VARCHAR(50),
    HeadOfDepartment VARCHAR(100),
    CreatedDate DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- PROGRAM TABLE
-- ============================================================================
-- Represents degree programs (e.g., BSc Computer Science, MSc Data Science)
-- ============================================================================

CREATE TABLE Program (
    ProgramID INTEGER PRIMARY KEY AUTOINCREMENT,
    ProgramName VARCHAR(150) NOT NULL,
    ProgramCode VARCHAR(20) NOT NULL UNIQUE,
    DepartmentID INTEGER NOT NULL,
    DurationYears INTEGER NOT NULL CHECK (DurationYears > 0),
    TotalCredits INTEGER NOT NULL CHECK (TotalCredits > 0),
    Level INTEGER NOT NULL CHECK (Level IN (4, 5, 6, 7)), -- 4-7 for undergrad/postgrad
    CreatedDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (DepartmentID) REFERENCES Department(DepartmentID)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

-- ============================================================================
-- STUDENT TABLE
-- ============================================================================
-- Represents students enrolled in the university
-- ============================================================================

CREATE TABLE Student (
    StudentID INTEGER PRIMARY KEY AUTOINCREMENT,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Email VARCHAR(100) NOT NULL UNIQUE,
    DateOfBirth DATE NOT NULL,
    EnrollmentDate DATE NOT NULL DEFAULT CURRENT_DATE,
    ProgramID INTEGER NOT NULL,
    Status VARCHAR(20) DEFAULT 'Active' CHECK (Status IN ('Active', 'Suspended', 'Graduated', 'Withdrawn')),
    CreatedDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (ProgramID) REFERENCES Program(ProgramID)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    
    CHECK (EnrollmentDate >= DateOfBirth)
);

-- ============================================================================
-- COURSE TABLE
-- ============================================================================
-- Represents courses offered by the university
-- ============================================================================

CREATE TABLE Course (
    CourseID INTEGER PRIMARY KEY AUTOINCREMENT,
    CourseName VARCHAR(150) NOT NULL,
    CourseCode VARCHAR(20) NOT NULL UNIQUE,
    Credits INTEGER NOT NULL CHECK (Credits > 0),
    Level INTEGER NOT NULL CHECK (Level IN (4, 5, 6, 7)),
    DepartmentID INTEGER NOT NULL,
    Description TEXT,
    Prerequisites TEXT, -- Comma-separated course codes
    CreatedDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (DepartmentID) REFERENCES Department(DepartmentID)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

-- ============================================================================
-- INSTRUCTOR TABLE
-- ============================================================================
-- Represents faculty members who teach courses
-- ============================================================================

CREATE TABLE Instructor (
    InstructorID INTEGER PRIMARY KEY AUTOINCREMENT,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Email VARCHAR(100) NOT NULL UNIQUE,
    DepartmentID INTEGER NOT NULL,
    HireDate DATE NOT NULL,
    Title VARCHAR(50) DEFAULT 'Lecturer' CHECK (Title IN ('Lecturer', 'Senior Lecturer', 'Professor', 'Associate Professor')),
    Status VARCHAR(20) DEFAULT 'Active' CHECK (Status IN ('Active', 'On Leave', 'Retired')),
    CreatedDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (DepartmentID) REFERENCES Department(DepartmentID)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

-- ============================================================================
-- COURSE OFFERING TABLE
-- ============================================================================
-- Represents specific instances of courses offered in particular semesters
-- ============================================================================

CREATE TABLE CourseOffering (
    OfferingID INTEGER PRIMARY KEY AUTOINCREMENT,
    CourseID INTEGER NOT NULL,
    InstructorID INTEGER NOT NULL,
    Semester VARCHAR(20) NOT NULL CHECK (Semester IN ('Fall', 'Spring', 'Summer')),
    Year INTEGER NOT NULL CHECK (Year >= 2020 AND Year <= 2030),
    Room VARCHAR(20),
    MaxStudents INTEGER NOT NULL DEFAULT 30 CHECK (MaxStudents > 0),
    CurrentEnrollment INTEGER DEFAULT 0 CHECK (CurrentEnrollment >= 0),
    CreatedDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (CourseID) REFERENCES Course(CourseID)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    FOREIGN KEY (InstructorID) REFERENCES Instructor(InstructorID)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    
    -- Ensure a course is not offered multiple times in same semester/year by same instructor
    UNIQUE (CourseID, Semester, Year, InstructorID),
    
    -- Ensure current enrollment doesn't exceed max
    CHECK (CurrentEnrollment <= MaxStudents)
);

-- ============================================================================
-- ENROLLMENT TABLE
-- ============================================================================
-- Represents student enrollments in specific course offerings
-- ============================================================================

CREATE TABLE Enrollment (
    EnrollmentID INTEGER PRIMARY KEY AUTOINCREMENT,
    StudentID INTEGER NOT NULL,
    OfferingID INTEGER NOT NULL,
    EnrollmentDate DATE NOT NULL DEFAULT CURRENT_DATE,
    Grade VARCHAR(2) CHECK (Grade IN ('A', 'B', 'C', 'D', 'F', 'P', 'W', NULL)),
    Status VARCHAR(20) DEFAULT 'Enrolled' CHECK (Status IN ('Enrolled', 'Completed', 'Withdrawn', 'Failed')),
    CreatedDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (StudentID) REFERENCES Student(StudentID)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (OfferingID) REFERENCES CourseOffering(OfferingID)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    
    -- A student can only enroll once in a specific course offering
    UNIQUE (StudentID, OfferingID)
);

-- ============================================================================
-- INDEXES FOR PERFORMANCE OPTIMIZATION
-- ============================================================================

-- Email lookups (frequently used for login/search)
CREATE INDEX idx_student_email ON Student(Email);
CREATE INDEX idx_instructor_email ON Instructor(Email);

-- Department-based queries
CREATE INDEX idx_program_department ON Program(DepartmentID);
CREATE INDEX idx_course_department ON Course(DepartmentID);
CREATE INDEX idx_instructor_department ON Instructor(DepartmentID);

-- Course code lookups
CREATE INDEX idx_course_code ON Course(CourseCode);
CREATE INDEX idx_program_code ON Program(ProgramCode);

-- Semester/year filtering for course offerings
CREATE INDEX idx_offering_semester_year ON CourseOffering(Semester, Year);
CREATE INDEX idx_offering_course ON CourseOffering(CourseID);
CREATE INDEX idx_offering_instructor ON CourseOffering(InstructorID);

-- Enrollment queries
CREATE INDEX idx_enrollment_student ON Enrollment(StudentID);
CREATE INDEX idx_enrollment_offering ON Enrollment(OfferingID);
CREATE INDEX idx_enrollment_grade ON Enrollment(Grade);

-- Composite indexes for common query patterns
CREATE INDEX idx_offering_course_semester ON CourseOffering(CourseID, Semester, Year);
CREATE INDEX idx_enrollment_student_status ON Enrollment(StudentID, Status);

-- ============================================================================
-- VIEWS FOR COMMON QUERIES
-- ============================================================================

-- View: Student enrollment with course details
CREATE VIEW StudentEnrollmentView AS
SELECT 
    s.StudentID,
    s.FirstName || ' ' || s.LastName AS StudentName,
    s.Email AS StudentEmail,
    p.ProgramName,
    c.CourseCode,
    c.CourseName,
    c.Credits,
    co.Semester,
    co.Year,
    i.FirstName || ' ' || i.LastName AS InstructorName,
    e.Grade,
    e.Status AS EnrollmentStatus
FROM Enrollment e
JOIN Student s ON e.StudentID = s.StudentID
JOIN CourseOffering co ON e.OfferingID = co.OfferingID
JOIN Course c ON co.CourseID = c.CourseID
JOIN Instructor i ON co.InstructorID = i.InstructorID
JOIN Program p ON s.ProgramID = p.ProgramID;

-- View: Course offerings with availability
CREATE VIEW CourseOfferingAvailability AS
SELECT 
    co.OfferingID,
    c.CourseCode,
    c.CourseName,
    c.Credits,
    co.Semester,
    co.Year,
    i.FirstName || ' ' || i.LastName AS InstructorName,
    co.Room,
    co.MaxStudents,
    co.CurrentEnrollment,
    (co.MaxStudents - co.CurrentEnrollment) AS AvailableSeats,
    CASE 
        WHEN co.CurrentEnrollment >= co.MaxStudents THEN 'Full'
        WHEN co.CurrentEnrollment >= co.MaxStudents * 0.9 THEN 'Almost Full'
        ELSE 'Available'
    END AS Status
FROM CourseOffering co
JOIN Course c ON co.CourseID = c.CourseID
JOIN Instructor i ON co.InstructorID = i.InstructorID;

-- View: Student GPA calculation
CREATE VIEW StudentGPA AS
SELECT 
    s.StudentID,
    s.FirstName || ' ' || s.LastName AS StudentName,
    COUNT(e.EnrollmentID) AS CoursesCompleted,
    SUM(c.Credits) AS TotalCredits,
    ROUND(AVG(
        CASE e.Grade
            WHEN 'A' THEN 4.0
            WHEN 'B' THEN 3.0
            WHEN 'C' THEN 2.0
            WHEN 'D' THEN 1.0
            WHEN 'F' THEN 0.0
            ELSE NULL
        END
    ), 2) AS GPA
FROM Student s
LEFT JOIN Enrollment e ON s.StudentID = e.StudentID AND e.Grade IS NOT NULL
LEFT JOIN CourseOffering co ON e.OfferingID = co.OfferingID
LEFT JOIN Course c ON co.CourseID = c.CourseID
GROUP BY s.StudentID, s.FirstName, s.LastName;

-- View: Department statistics
CREATE VIEW DepartmentStatistics AS
SELECT 
    d.DepartmentID,
    d.DepartmentName,
    COUNT(DISTINCT p.ProgramID) AS TotalPrograms,
    COUNT(DISTINCT c.CourseID) AS TotalCourses,
    COUNT(DISTINCT i.InstructorID) AS TotalInstructors,
    COUNT(DISTINCT s.StudentID) AS TotalStudents
FROM Department d
LEFT JOIN Program p ON d.DepartmentID = p.DepartmentID
LEFT JOIN Course c ON d.DepartmentID = c.DepartmentID
LEFT JOIN Instructor i ON d.DepartmentID = i.DepartmentID
LEFT JOIN Student s ON p.ProgramID = s.ProgramID
GROUP BY d.DepartmentID, d.DepartmentName;

-- ============================================================================
-- TRIGGERS FOR DATA INTEGRITY
-- ============================================================================

-- Trigger: Update current enrollment when student enrolls
CREATE TRIGGER trg_enrollment_insert
AFTER INSERT ON Enrollment
BEGIN
    UPDATE CourseOffering
    SET CurrentEnrollment = CurrentEnrollment + 1
    WHERE OfferingID = NEW.OfferingID;
END;

-- Trigger: Update current enrollment when enrollment is deleted
CREATE TRIGGER trg_enrollment_delete
AFTER DELETE ON Enrollment
BEGIN
    UPDATE CourseOffering
    SET CurrentEnrollment = CurrentEnrollment - 1
    WHERE OfferingID = OLD.OfferingID;
END;

-- Trigger: Prevent enrollment if course is full
CREATE TRIGGER trg_check_enrollment_capacity
BEFORE INSERT ON Enrollment
BEGIN
    SELECT RAISE(ABORT, 'Course offering is full')
    WHERE (
        SELECT CurrentEnrollment >= MaxStudents
        FROM CourseOffering
        WHERE OfferingID = NEW.OfferingID
    );
END;

-- Trigger: Prevent grade change after course completion
CREATE TRIGGER trg_prevent_grade_change
BEFORE UPDATE OF Grade ON Enrollment
WHEN OLD.Grade IS NOT NULL AND OLD.Status = 'Completed'
BEGIN
    SELECT RAISE(ABORT, 'Cannot change grade for completed course')
    WHERE NEW.Grade != OLD.Grade;
END;

-- ============================================================================
-- END OF SCHEMA
-- ============================================================================
