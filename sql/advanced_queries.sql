-- ============================================================================
-- Advanced SQL Queries - University Course Management System
-- ============================================================================
-- Demonstrates complex queries, joins, subqueries, aggregations, and analytics
-- ============================================================================

-- ============================================================================
-- SECTION 1: BASIC QUERIES WITH JOINS
-- ============================================================================

-- Query 1: List all students with their program and department information
SELECT 
    s.StudentID,
    s.FirstName || ' ' || s.LastName AS StudentName,
    s.Email,
    p.ProgramName,
    d.DepartmentName,
    s.EnrollmentDate,
    s.Status
FROM Student s
JOIN Program p ON s.ProgramID = p.ProgramID
JOIN Department d ON p.DepartmentID = d.DepartmentID
ORDER BY d.DepartmentName, p.ProgramName, s.LastName;

-- Query 2: List all course offerings with instructor and course details
SELECT 
    co.OfferingID,
    c.CourseCode,
    c.CourseName,
    c.Credits,
    i.FirstName || ' ' || i.LastName AS InstructorName,
    co.Semester,
    co.Year,
    co.Room,
    co.CurrentEnrollment || '/' || co.MaxStudents AS Enrollment
FROM CourseOffering co
JOIN Course c ON co.CourseID = c.CourseID
JOIN Instructor i ON co.InstructorID = i.InstructorID
ORDER BY co.Year DESC, co.Semester, c.CourseCode;

-- Query 3: Student enrollment history with grades
SELECT 
    s.FirstName || ' ' || s.LastName AS StudentName,
    c.CourseCode,
    c.CourseName,
    co.Semester || ' ' || co.Year AS Term,
    i.FirstName || ' ' || i.LastName AS Instructor,
    e.Grade,
    e.Status
FROM Enrollment e
JOIN Student s ON e.StudentID = s.StudentID
JOIN CourseOffering co ON e.OfferingID = co.OfferingID
JOIN Course c ON co.CourseID = c.CourseID
JOIN Instructor i ON co.InstructorID = i.InstructorID
WHERE s.StudentID = 1
ORDER BY co.Year DESC, co.Semester, c.CourseCode;

-- ============================================================================
-- SECTION 2: AGGREGATION QUERIES
-- ============================================================================

-- Query 4: Count students per program
SELECT 
    p.ProgramName,
    d.DepartmentName,
    COUNT(s.StudentID) AS TotalStudents,
    COUNT(CASE WHEN s.Status = 'Active' THEN 1 END) AS ActiveStudents
FROM Program p
JOIN Department d ON p.DepartmentID = d.DepartmentID
LEFT JOIN Student s ON p.ProgramID = s.ProgramID
GROUP BY p.ProgramID, p.ProgramName, d.DepartmentName
ORDER BY TotalStudents DESC;

-- Query 5: Course enrollment statistics
SELECT 
    c.CourseCode,
    c.CourseName,
    co.Semester || ' ' || co.Year AS Term,
    co.MaxStudents,
    co.CurrentEnrollment,
    ROUND(CAST(co.CurrentEnrollment AS FLOAT) / co.MaxStudents * 100, 2) AS FillRate,
    (co.MaxStudents - co.CurrentEnrollment) AS AvailableSeats
FROM CourseOffering co
JOIN Course c ON co.CourseID = c.CourseID
ORDER BY FillRate DESC;

-- Query 6: Instructor workload (number of courses and students)
SELECT 
    i.FirstName || ' ' || i.LastName AS InstructorName,
    d.DepartmentName,
    COUNT(DISTINCT co.OfferingID) AS CoursesTeaching,
    SUM(co.CurrentEnrollment) AS TotalStudents,
    ROUND(AVG(co.CurrentEnrollment), 1) AS AvgClassSize
FROM Instructor i
JOIN Department d ON i.DepartmentID = d.DepartmentID
LEFT JOIN CourseOffering co ON i.InstructorID = co.InstructorID
WHERE co.Year = 2024 OR co.Year IS NULL
GROUP BY i.InstructorID, InstructorName, d.DepartmentName
ORDER BY CoursesTeaching DESC, TotalStudents DESC;

-- ============================================================================
-- SECTION 3: SUBQUERIES
-- ============================================================================

-- Query 7: Find students with GPA above department average
SELECT 
    s.FirstName || ' ' || s.LastName AS StudentName,
    p.ProgramName,
    ROUND(AVG(
        CASE e.Grade
            WHEN 'A' THEN 4.0
            WHEN 'B' THEN 3.0
            WHEN 'C' THEN 2.0
            WHEN 'D' THEN 1.0
            WHEN 'F' THEN 0.0
        END
    ), 2) AS GPA
FROM Student s
JOIN Program p ON s.ProgramID = p.ProgramID
JOIN Enrollment e ON s.StudentID = e.StudentID
WHERE e.Grade IS NOT NULL
GROUP BY s.StudentID, StudentName, p.ProgramName
HAVING AVG(
    CASE e.Grade
        WHEN 'A' THEN 4.0
        WHEN 'B' THEN 3.0
        WHEN 'C' THEN 2.0
        WHEN 'D' THEN 1.0
        WHEN 'F' THEN 0.0
    END
) > (
    SELECT AVG(
        CASE e2.Grade
            WHEN 'A' THEN 4.0
            WHEN 'B' THEN 3.0
            WHEN 'C' THEN 2.0
            WHEN 'D' THEN 1.0
            WHEN 'F' THEN 0.0
        END
    )
    FROM Enrollment e2
    JOIN Student s2 ON e2.StudentID = s2.StudentID
    JOIN Program p2 ON s2.ProgramID = p2.ProgramID
    WHERE p2.DepartmentID = p.DepartmentID
    AND e2.Grade IS NOT NULL
)
ORDER BY GPA DESC;

-- Query 8: Find courses with no enrollments
SELECT 
    c.CourseCode,
    c.CourseName,
    c.Level,
    d.DepartmentName
FROM Course c
JOIN Department d ON c.DepartmentID = d.DepartmentID
WHERE NOT EXISTS (
    SELECT 1
    FROM CourseOffering co
    WHERE co.CourseID = c.CourseID
)
ORDER BY d.DepartmentName, c.CourseCode;

-- Query 9: Find students who haven't enrolled in any courses this semester
SELECT 
    s.FirstName || ' ' || s.LastName AS StudentName,
    s.Email,
    p.ProgramName,
    s.Status
FROM Student s
JOIN Program p ON s.ProgramID = p.ProgramID
WHERE s.Status = 'Active'
AND s.StudentID NOT IN (
    SELECT DISTINCT e.StudentID
    FROM Enrollment e
    JOIN CourseOffering co ON e.OfferingID = co.OfferingID
    WHERE co.Semester = 'Spring' AND co.Year = 2024
)
ORDER BY p.ProgramName, s.LastName;

-- ============================================================================
-- SECTION 4: ADVANCED ANALYTICS
-- ============================================================================

-- Query 10: Grade distribution by course
SELECT 
    c.CourseCode,
    c.CourseName,
    COUNT(e.EnrollmentID) AS TotalEnrollments,
    COUNT(CASE WHEN e.Grade = 'A' THEN 1 END) AS GradeA,
    COUNT(CASE WHEN e.Grade = 'B' THEN 1 END) AS GradeB,
    COUNT(CASE WHEN e.Grade = 'C' THEN 1 END) AS GradeC,
    COUNT(CASE WHEN e.Grade = 'D' THEN 1 END) AS GradeD,
    COUNT(CASE WHEN e.Grade = 'F' THEN 1 END) AS GradeF,
    ROUND(AVG(
        CASE e.Grade
            WHEN 'A' THEN 4.0
            WHEN 'B' THEN 3.0
            WHEN 'C' THEN 2.0
            WHEN 'D' THEN 1.0
            WHEN 'F' THEN 0.0
        END
    ), 2) AS AverageGPA
FROM Course c
JOIN CourseOffering co ON c.CourseID = co.CourseID
JOIN Enrollment e ON co.OfferingID = e.OfferingID
WHERE e.Grade IS NOT NULL
GROUP BY c.CourseID, c.CourseCode, c.CourseName
ORDER BY AverageGPA DESC;

-- Query 11: Student performance ranking within their program
WITH StudentGPAs AS (
    SELECT 
        s.StudentID,
        s.FirstName || ' ' || s.LastName AS StudentName,
        s.ProgramID,
        p.ProgramName,
        COUNT(e.EnrollmentID) AS CoursesCompleted,
        ROUND(AVG(
            CASE e.Grade
                WHEN 'A' THEN 4.0
                WHEN 'B' THEN 3.0
                WHEN 'C' THEN 2.0
                WHEN 'D' THEN 1.0
                WHEN 'F' THEN 0.0
            END
        ), 2) AS GPA
    FROM Student s
    JOIN Program p ON s.ProgramID = p.ProgramID
    LEFT JOIN Enrollment e ON s.StudentID = e.StudentID AND e.Grade IS NOT NULL
    GROUP BY s.StudentID, StudentName, s.ProgramID, p.ProgramName
)
SELECT 
    StudentName,
    ProgramName,
    CoursesCompleted,
    GPA,
    RANK() OVER (PARTITION BY ProgramID ORDER BY GPA DESC) AS ProgramRank
FROM StudentGPAs
WHERE GPA IS NOT NULL
ORDER BY ProgramName, ProgramRank;

-- Query 12: Course popularity trend (enrollment over time)
SELECT 
    c.CourseCode,
    c.CourseName,
    co.Year,
    co.Semester,
    co.CurrentEnrollment,
    co.MaxStudents,
    ROUND(CAST(co.CurrentEnrollment AS FLOAT) / co.MaxStudents * 100, 1) AS FillRate
FROM Course c
JOIN CourseOffering co ON c.CourseID = co.CourseID
WHERE c.CourseCode IN ('CS101', 'CS201', 'CS202')
ORDER BY c.CourseCode, co.Year, 
    CASE co.Semester
        WHEN 'Spring' THEN 1
        WHEN 'Summer' THEN 2
        WHEN 'Fall' THEN 3
    END;

-- Query 13: Department performance comparison
SELECT 
    d.DepartmentName,
    COUNT(DISTINCT s.StudentID) AS TotalStudents,
    COUNT(DISTINCT i.InstructorID) AS TotalInstructors,
    COUNT(DISTINCT c.CourseID) AS TotalCourses,
    COUNT(DISTINCT co.OfferingID) AS CourseOfferings,
    ROUND(AVG(
        CASE e.Grade
            WHEN 'A' THEN 4.0
            WHEN 'B' THEN 3.0
            WHEN 'C' THEN 2.0
            WHEN 'D' THEN 1.0
            WHEN 'F' THEN 0.0
        END
    ), 2) AS AverageDepartmentGPA
FROM Department d
LEFT JOIN Program p ON d.DepartmentID = p.DepartmentID
LEFT JOIN Student s ON p.ProgramID = s.ProgramID
LEFT JOIN Instructor i ON d.DepartmentID = i.DepartmentID
LEFT JOIN Course c ON d.DepartmentID = c.DepartmentID
LEFT JOIN CourseOffering co ON c.CourseID = co.CourseID
LEFT JOIN Enrollment e ON co.OfferingID = e.OfferingID AND e.Grade IS NOT NULL
GROUP BY d.DepartmentID, d.DepartmentName
ORDER BY AverageDepartmentGPA DESC;

-- ============================================================================
-- SECTION 5: COMPLEX BUSINESS QUERIES
-- ============================================================================

-- Query 14: Find prerequisite violations (students enrolled without completing prerequisites)
SELECT 
    s.FirstName || ' ' || s.LastName AS StudentName,
    c.CourseCode AS EnrolledCourse,
    c.Prerequisites AS RequiredPrerequisites,
    co.Semester || ' ' || co.Year AS Term
FROM Enrollment e
JOIN Student s ON e.StudentID = s.StudentID
JOIN CourseOffering co ON e.OfferingID = co.OfferingID
JOIN Course c ON co.CourseID = c.CourseID
WHERE c.Prerequisites IS NOT NULL
AND e.StudentID NOT IN (
    SELECT DISTINCT e2.StudentID
    FROM Enrollment e2
    JOIN CourseOffering co2 ON e2.OfferingID = co2.OfferingID
    JOIN Course c2 ON co2.CourseID = c2.CourseID
    WHERE c2.CourseCode = c.Prerequisites
    AND e2.Grade IN ('A', 'B', 'C', 'D', 'P')
    AND e2.Status = 'Completed'
)
ORDER BY StudentName, EnrolledCourse;

-- Query 15: Calculate student progress towards degree completion
SELECT 
    s.FirstName || ' ' || s.LastName AS StudentName,
    p.ProgramName,
    p.TotalCredits AS RequiredCredits,
    COALESCE(SUM(c.Credits), 0) AS EarnedCredits,
    p.TotalCredits - COALESCE(SUM(c.Credits), 0) AS RemainingCredits,
    ROUND(CAST(COALESCE(SUM(c.Credits), 0) AS FLOAT) / p.TotalCredits * 100, 1) AS PercentComplete
FROM Student s
JOIN Program p ON s.ProgramID = p.ProgramID
LEFT JOIN Enrollment e ON s.StudentID = e.StudentID 
    AND e.Status = 'Completed' 
    AND e.Grade IN ('A', 'B', 'C', 'D', 'P')
LEFT JOIN CourseOffering co ON e.OfferingID = co.OfferingID
LEFT JOIN Course c ON co.CourseID = c.CourseID
WHERE s.Status = 'Active'
GROUP BY s.StudentID, StudentName, p.ProgramName, p.TotalCredits, RequiredCredits
ORDER BY PercentComplete DESC;

-- Query 16: Find courses that are consistently full (high demand)
SELECT 
    c.CourseCode,
    c.CourseName,
    COUNT(co.OfferingID) AS TimesOffered,
    AVG(CAST(co.CurrentEnrollment AS FLOAT) / co.MaxStudents * 100) AS AvgFillRate,
    SUM(co.CurrentEnrollment) AS TotalEnrollments
FROM Course c
JOIN CourseOffering co ON c.CourseID = co.CourseID
GROUP BY c.CourseID, c.CourseCode, c.CourseName
HAVING AVG(CAST(co.CurrentEnrollment AS FLOAT) / co.MaxStudents * 100) > 80
ORDER BY AvgFillRate DESC;

-- Query 17: Instructor performance (based on student grades)
SELECT 
    i.FirstName || ' ' || i.LastName AS InstructorName,
    d.DepartmentName,
    COUNT(DISTINCT co.OfferingID) AS CoursesT aught,
    COUNT(e.EnrollmentID) AS TotalStudentsGraded,
    ROUND(AVG(
        CASE e.Grade
            WHEN 'A' THEN 4.0
            WHEN 'B' THEN 3.0
            WHEN 'C' THEN 2.0
            WHEN 'D' THEN 1.0
            WHEN 'F' THEN 0.0
        END
    ), 2) AS AverageStudentGPA,
    ROUND(COUNT(CASE WHEN e.Grade IN ('A', 'B') THEN 1 END) * 100.0 / COUNT(e.EnrollmentID), 1) AS PercentAB
FROM Instructor i
JOIN Department d ON i.DepartmentID = d.DepartmentID
JOIN CourseOffering co ON i.InstructorID = co.InstructorID
JOIN Enrollment e ON co.OfferingID = e.OfferingID
WHERE e.Grade IS NOT NULL
GROUP BY i.InstructorID, InstructorName, d.DepartmentName
HAVING COUNT(e.EnrollmentID) >= 5
ORDER BY AverageStudentGPA DESC;

-- Query 18: Find students at risk (low GPA)
SELECT 
    s.FirstName || ' ' || s.LastName AS StudentName,
    s.Email,
    p.ProgramName,
    COUNT(e.EnrollmentID) AS CoursesCompleted,
    ROUND(AVG(
        CASE e.Grade
            WHEN 'A' THEN 4.0
            WHEN 'B' THEN 3.0
            WHEN 'C' THEN 2.0
            WHEN 'D' THEN 1.0
            WHEN 'F' THEN 0.0
        END
    ), 2) AS GPA,
    COUNT(CASE WHEN e.Grade = 'F' THEN 1 END) AS FailedCourses
FROM Student s
JOIN Program p ON s.ProgramID = p.ProgramID
JOIN Enrollment e ON s.StudentID = e.StudentID
WHERE e.Grade IS NOT NULL AND s.Status = 'Active'
GROUP BY s.StudentID, StudentName, s.Email, p.ProgramName
HAVING AVG(
    CASE e.Grade
        WHEN 'A' THEN 4.0
        WHEN 'B' THEN 3.0
        WHEN 'C' THEN 2.0
        WHEN 'D' THEN 1.0
        WHEN 'F' THEN 0.0
    END
) < 2.0
ORDER BY GPA ASC;

-- ============================================================================
-- SECTION 6: REPORTING QUERIES
-- ============================================================================

-- Query 19: Semester enrollment summary report
SELECT 
    co.Semester,
    co.Year,
    COUNT(DISTINCT co.OfferingID) AS CoursesOffered,
    COUNT(DISTINCT e.StudentID) AS UniqueStudents,
    COUNT(e.EnrollmentID) AS TotalEnrollments,
    SUM(co.MaxStudents) AS TotalCapacity,
    SUM(co.CurrentEnrollment) AS TotalEnrolled,
    ROUND(CAST(SUM(co.CurrentEnrollment) AS FLOAT) / SUM(co.MaxStudents) * 100, 1) AS OverallFillRate
FROM CourseOffering co
LEFT JOIN Enrollment e ON co.OfferingID = e.OfferingID
GROUP BY co.Semester, co.Year
ORDER BY co.Year DESC, 
    CASE co.Semester
        WHEN 'Spring' THEN 1
        WHEN 'Summer' THEN 2
        WHEN 'Fall' THEN 3
    END;

-- Query 20: Comprehensive student transcript
SELECT 
    s.FirstName || ' ' || s.LastName AS StudentName,
    s.Email,
    p.ProgramName,
    c.CourseCode,
    c.CourseName,
    c.Credits,
    co.Semester || ' ' || co.Year AS Term,
    i.FirstName || ' ' || i.LastName AS Instructor,
    e.Grade,
    CASE e.Grade
        WHEN 'A' THEN 4.0
        WHEN 'B' THEN 3.0
        WHEN 'C' THEN 2.0
        WHEN 'D' THEN 1.0
        WHEN 'F' THEN 0.0
        ELSE NULL
    END AS GradePoints
FROM Student s
JOIN Program p ON s.ProgramID = p.ProgramID
JOIN Enrollment e ON s.StudentID = e.StudentID
JOIN CourseOffering co ON e.OfferingID = co.OfferingID
JOIN Course c ON co.CourseID = c.CourseID
JOIN Instructor i ON co.InstructorID = i.InstructorID
WHERE s.StudentID = 1
ORDER BY co.Year, 
    CASE co.Semester
        WHEN 'Spring' THEN 1
        WHEN 'Summer' THEN 2
        WHEN 'Fall' THEN 3
    END,
    c.CourseCode;

-- ============================================================================
-- END OF ADVANCED QUERIES
-- ============================================================================
