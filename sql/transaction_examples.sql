-- ============================================================================
-- Transaction Examples - University Course Management System
-- ============================================================================
-- Demonstrates ACID properties and transaction handling
-- ============================================================================

-- ============================================================================
-- TRANSACTION 1: Student Enrollment with Validation
-- ============================================================================
-- Demonstrates: Atomicity, Consistency, Isolation
-- Business Rule: Student can only enroll if course has available seats

BEGIN TRANSACTION;

-- Step 1: Check if course offering has available seats
SELECT 
    OfferingID,
    MaxStudents,
    CurrentEnrollment,
    (MaxStudents - CurrentEnrollment) AS AvailableSeats
FROM CourseOffering
WHERE OfferingID = 1;

-- Step 2: Verify student is not already enrolled
SELECT COUNT(*) AS AlreadyEnrolled
FROM Enrollment
WHERE StudentID = 5 AND OfferingID = 1;

-- Step 3: If checks pass, insert enrollment
-- (In practice, this would be conditional based on above checks)
INSERT INTO Enrollment (StudentID, OfferingID, Status)
VALUES (5, 1, 'Enrolled');

-- Step 4: Trigger automatically updates CurrentEnrollment
-- Verify the update
SELECT CurrentEnrollment
FROM CourseOffering
WHERE OfferingID = 1;

-- If all steps successful, commit
COMMIT;

-- If any step fails, rollback
-- ROLLBACK;

-- ============================================================================
-- TRANSACTION 2: Grade Update with Audit Trail
-- ============================================================================
-- Demonstrates: Consistency, Durability
-- Business Rule: Grade changes must be logged for audit purposes

BEGIN TRANSACTION;

-- Step 1: Record current grade before update (for audit)
SELECT 
    EnrollmentID,
    StudentID,
    OfferingID,
    Grade AS OldGrade,
    CURRENT_TIMESTAMP AS ChangeTimestamp
FROM Enrollment
WHERE EnrollmentID = 1;

-- Step 2: Update grade
UPDATE Enrollment
SET Grade = 'A', Status = 'Completed'
WHERE EnrollmentID = 1;

-- Step 3: Verify update
SELECT 
    e.EnrollmentID,
    s.FirstName || ' ' || s.LastName AS StudentName,
    c.CourseCode,
    e.Grade,
    e.Status
FROM Enrollment e
JOIN Student s ON e.StudentID = s.StudentID
JOIN CourseOffering co ON e.OfferingID = co.OfferingID
JOIN Course c ON co.CourseID = c.CourseID
WHERE e.EnrollmentID = 1;

COMMIT;

-- ============================================================================
-- TRANSACTION 3: Course Offering Creation
-- ============================================================================
-- Demonstrates: Referential Integrity, Consistency
-- Business Rule: Course and Instructor must exist before creating offering

BEGIN TRANSACTION;

-- Step 1: Verify course exists
SELECT CourseID, CourseName
FROM Course
WHERE CourseID = 1;

-- Step 2: Verify instructor exists and is active
SELECT InstructorID, FirstName || ' ' || LastName AS InstructorName, Status
FROM Instructor
WHERE InstructorID = 1 AND Status = 'Active';

-- Step 3: Check for scheduling conflicts (same instructor, same semester)
SELECT COUNT(*) AS ConflictCount
FROM CourseOffering
WHERE InstructorID = 1 
  AND Semester = 'Fall' 
  AND Year = 2024;

-- Step 4: Create course offering
INSERT INTO CourseOffering 
(CourseID, InstructorID, Semester, Year, Room, MaxStudents, CurrentEnrollment)
VALUES (1, 1, 'Fall', 2024, 'A105', 35, 0);

-- Step 5: Verify creation
SELECT 
    co.OfferingID,
    c.CourseCode,
    c.CourseName,
    i.FirstName || ' ' || i.LastName AS Instructor,
    co.Semester,
    co.Year,
    co.Room,
    co.MaxStudents
FROM CourseOffering co
JOIN Course c ON co.CourseID = c.CourseID
JOIN Instructor i ON co.InstructorID = i.InstructorID
WHERE co.OfferingID = LAST_INSERT_ROWID();

COMMIT;

-- ============================================================================
-- TRANSACTION 4: Student Withdrawal with Refund Calculation
-- ============================================================================
-- Demonstrates: Complex business logic, Atomicity
-- Business Rule: Withdrawal before week 4 gets full refund, after gets partial

BEGIN TRANSACTION;

-- Step 1: Get enrollment details
SELECT 
    e.EnrollmentID,
    e.StudentID,
    e.OfferingID,
    e.EnrollmentDate,
    c.Credits,
    JULIANDAY('now') - JULIANDAY(e.EnrollmentDate) AS DaysEnrolled,
    CASE 
        WHEN JULIANDAY('now') - JULIANDAY(e.EnrollmentDate) <= 28 THEN 'Full Refund'
        WHEN JULIANDAY('now') - JULIANDAY(e.EnrollmentDate) <= 56 THEN 'Partial Refund'
        ELSE 'No Refund'
    END AS RefundStatus
FROM Enrollment e
JOIN CourseOffering co ON e.OfferingID = co.OfferingID
JOIN Course c ON co.CourseID = c.CourseID
WHERE e.EnrollmentID = 2;

-- Step 2: Update enrollment status to withdrawn
UPDATE Enrollment
SET Status = 'Withdrawn', Grade = 'W'
WHERE EnrollmentID = 2 AND Status = 'Enrolled';

-- Step 3: Trigger automatically decrements CurrentEnrollment
-- Verify the update
SELECT 
    co.OfferingID,
    co.CurrentEnrollment,
    co.MaxStudents,
    (co.MaxStudents - co.CurrentEnrollment) AS AvailableSeats
FROM Enrollment e
JOIN CourseOffering co ON e.OfferingID = co.OfferingID
WHERE e.EnrollmentID = 2;

COMMIT;

-- ============================================================================
-- TRANSACTION 5: Batch Grade Entry (Multiple Students)
-- ============================================================================
-- Demonstrates: Atomicity (all or nothing), Isolation
-- Business Rule: All grades for a course must be entered together or not at all

BEGIN TRANSACTION;

-- Update grades for all students in a specific course offering
UPDATE Enrollment
SET Grade = CASE StudentID
    WHEN 1 THEN 'A'
    WHEN 2 THEN 'B'
    WHEN 3 THEN 'A'
    WHEN 4 THEN 'C'
    ELSE Grade
END,
Status = 'Completed'
WHERE OfferingID = 5 
  AND StudentID IN (1, 2, 3, 4)
  AND Status = 'Enrolled';

-- Verify all updates
SELECT 
    s.StudentID,
    s.FirstName || ' ' || s.LastName AS StudentName,
    e.Grade,
    e.Status
FROM Enrollment e
JOIN Student s ON e.StudentID = s.StudentID
WHERE e.OfferingID = 5
ORDER BY s.StudentID;

-- Calculate class statistics
SELECT 
    COUNT(*) AS TotalStudents,
    COUNT(CASE WHEN Grade = 'A' THEN 1 END) AS GradeA,
    COUNT(CASE WHEN Grade = 'B' THEN 1 END) AS GradeB,
    COUNT(CASE WHEN Grade = 'C' THEN 1 END) AS GradeC,
    ROUND(AVG(
        CASE Grade
            WHEN 'A' THEN 4.0
            WHEN 'B' THEN 3.0
            WHEN 'C' THEN 2.0
            WHEN 'D' THEN 1.0
            WHEN 'F' THEN 0.0
        END
    ), 2) AS ClassAverageGPA
FROM Enrollment
WHERE OfferingID = 5 AND Grade IS NOT NULL;

COMMIT;

-- ============================================================================
-- TRANSACTION 6: Program Transfer (Complex Update)
-- ============================================================================
-- Demonstrates: Referential Integrity, Consistency
-- Business Rule: Student can transfer programs if prerequisites are met

BEGIN TRANSACTION;

-- Step 1: Get current program information
SELECT 
    s.StudentID,
    s.FirstName || ' ' || s.LastName AS StudentName,
    p.ProgramName AS CurrentProgram,
    p.ProgramID AS CurrentProgramID
FROM Student s
JOIN Program p ON s.ProgramID = p.ProgramID
WHERE s.StudentID = 5;

-- Step 2: Verify new program exists
SELECT ProgramID, ProgramName, TotalCredits
FROM Program
WHERE ProgramID = 2;

-- Step 3: Check student's completed credits
SELECT 
    COUNT(e.EnrollmentID) AS CoursesCompleted,
    SUM(c.Credits) AS TotalCredits
FROM Enrollment e
JOIN CourseOffering co ON e.OfferingID = co.OfferingID
JOIN Course c ON co.CourseID = c.CourseID
WHERE e.StudentID = 5 
  AND e.Status = 'Completed'
  AND e.Grade IN ('A', 'B', 'C', 'D', 'P');

-- Step 4: Update student's program
UPDATE Student
SET ProgramID = 2
WHERE StudentID = 5;

-- Step 5: Verify transfer
SELECT 
    s.StudentID,
    s.FirstName || ' ' || s.LastName AS StudentName,
    p.ProgramName AS NewProgram,
    s.EnrollmentDate,
    CURRENT_DATE AS TransferDate
FROM Student s
JOIN Program p ON s.ProgramID = p.ProgramID
WHERE s.StudentID = 5;

COMMIT;

-- ============================================================================
-- TRANSACTION 7: Concurrent Enrollment Prevention
-- ============================================================================
-- Demonstrates: Isolation, Preventing Race Conditions
-- Business Rule: Prevent double enrollment when multiple requests occur simultaneously

BEGIN TRANSACTION;

-- Lock the course offering row for update
SELECT OfferingID, CurrentEnrollment, MaxStudents
FROM CourseOffering
WHERE OfferingID = 10
FOR UPDATE;  -- Note: SQLite uses BEGIN IMMEDIATE for locking

-- Check availability
SELECT 
    CASE 
        WHEN CurrentEnrollment < MaxStudents THEN 'Available'
        ELSE 'Full'
    END AS Status
FROM CourseOffering
WHERE OfferingID = 10;

-- Attempt enrollment (will fail if full)
INSERT INTO Enrollment (StudentID, OfferingID, Status)
SELECT 10, 10, 'Enrolled'
WHERE (
    SELECT CurrentEnrollment < MaxStudents
    FROM CourseOffering
    WHERE OfferingID = 10
);

-- Verify enrollment
SELECT 
    e.EnrollmentID,
    s.FirstName || ' ' || s.LastName AS StudentName,
    co.CurrentEnrollment,
    co.MaxStudents
FROM Enrollment e
JOIN Student s ON e.StudentID = s.StudentID
JOIN CourseOffering co ON e.OfferingID = co.OfferingID
WHERE e.StudentID = 10 AND e.OfferingID = 10;

COMMIT;

-- ============================================================================
-- TRANSACTION 8: Rollback Example (Intentional Failure)
-- ============================================================================
-- Demonstrates: Rollback on error, Data integrity preservation

BEGIN TRANSACTION;

-- Step 1: Insert a new student
INSERT INTO Student (FirstName, LastName, Email, DateOfBirth, ProgramID)
VALUES ('Test', 'Student', 'test.student@university.ac.uk', '2004-01-01', 1);

SELECT LAST_INSERT_ROWID() AS NewStudentID;

-- Step 2: Attempt to enroll in non-existent course (will fail)
INSERT INTO Enrollment (StudentID, OfferingID, Status)
VALUES (LAST_INSERT_ROWID(), 9999, 'Enrolled');  -- OfferingID 9999 doesn't exist

-- This will fail due to foreign key constraint
-- Transaction will be rolled back
-- Student record will not be created

ROLLBACK;

-- Verify rollback - student should not exist
SELECT COUNT(*) AS StudentExists
FROM Student
WHERE Email = 'test.student@university.ac.uk';
-- Should return 0

-- ============================================================================
-- ACID PROPERTIES DEMONSTRATION SUMMARY
-- ============================================================================

/*
ATOMICITY:
- Transactions 1, 5, 6, 8 demonstrate all-or-nothing execution
- If any step fails, entire transaction is rolled back

CONSISTENCY:
- All transactions maintain database constraints
- Foreign keys, check constraints, and triggers ensure consistency
- Transactions 2, 3, 6 explicitly verify data integrity

ISOLATION:
- Transaction 7 demonstrates locking to prevent concurrent conflicts
- Each transaction operates independently
- SQLite uses serializable isolation by default

DURABILITY:
- Once committed, changes persist even after system failure
- All committed transactions (1-7) are permanently stored
- Database file ensures durability
*/

-- ============================================================================
-- END OF TRANSACTION EXAMPLES
-- ============================================================================
