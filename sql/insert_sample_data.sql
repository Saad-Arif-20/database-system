-- ============================================================================
-- Sample Data for University Course Management System
-- ============================================================================
-- This file populates the database with realistic sample data
-- ============================================================================

-- ============================================================================
-- DEPARTMENTS
-- ============================================================================

INSERT INTO Department (DepartmentName, Building, HeadOfDepartment) VALUES
('Computer Science', 'Engineering Building A', 'Dr. Alan Turing'),
('Mathematics', 'Science Complex B', 'Dr. Ada Lovelace'),
('Engineering', 'Engineering Building C', 'Dr. Grace Hopper'),
('Business', 'Business School', 'Dr. Peter Drucker'),
('Physics', 'Science Complex A', 'Dr. Marie Curie');

-- ============================================================================
-- PROGRAMS
-- ============================================================================

INSERT INTO Program (ProgramName, ProgramCode, DepartmentID, DurationYears, TotalCredits, Level) VALUES
('BSc Computer Science', 'CS-BSC', 1, 3, 360, 4),
('MSc Data Science', 'DS-MSC', 1, 1, 180, 7),
('BSc Mathematics', 'MATH-BSC', 2, 3, 360, 4),
('BEng Software Engineering', 'SE-BENG', 3, 4, 480, 4),
('MBA Business Administration', 'MBA', 4, 2, 180, 7),
('BSc Physics', 'PHYS-BSC', 5, 3, 360, 4);

-- ============================================================================
-- STUDENTS
-- ============================================================================

INSERT INTO Student (FirstName, LastName, Email, DateOfBirth, EnrollmentDate, ProgramID, Status) VALUES
-- Computer Science Students
('John', 'Smith', 'john.smith@university.ac.uk', '2003-05-15', '2021-09-01', 1, 'Active'),
('Emma', 'Johnson', 'emma.johnson@university.ac.uk', '2003-08-22', '2021-09-01', 1, 'Active'),
('Michael', 'Williams', 'michael.williams@university.ac.uk', '2002-11-30', '2020-09-01', 1, 'Active'),
('Sarah', 'Brown', 'sarah.brown@university.ac.uk', '2003-03-10', '2021-09-01', 1, 'Active'),
('James', 'Davis', 'james.davis@university.ac.uk', '2004-01-25', '2022-09-01', 1, 'Active'),

-- Data Science Students (Postgraduate)
('Emily', 'Miller', 'emily.miller@university.ac.uk', '1998-07-12', '2023-09-01', 2, 'Active'),
('Daniel', 'Wilson', 'daniel.wilson@university.ac.uk', '1999-04-18', '2023-09-01', 2, 'Active'),
('Olivia', 'Moore', 'olivia.moore@university.ac.uk', '1997-12-05', '2023-09-01', 2, 'Active'),

-- Mathematics Students
('William', 'Taylor', 'william.taylor@university.ac.uk', '2003-09-20', '2021-09-01', 3, 'Active'),
('Sophia', 'Anderson', 'sophia.anderson@university.ac.uk', '2003-06-14', '2021-09-01', 3, 'Active'),

-- Software Engineering Students
('Alexander', 'Thomas', 'alexander.thomas@university.ac.uk', '2002-10-08', '2020-09-01', 4, 'Active'),
('Isabella', 'Jackson', 'isabella.jackson@university.ac.uk', '2003-02-28', '2021-09-01', 4, 'Active'),

-- MBA Students
('Christopher', 'White', 'christopher.white@university.ac.uk', '1995-11-16', '2023-09-01', 5, 'Active'),
('Ava', 'Harris', 'ava.harris@university.ac.uk', '1996-08-09', '2023-09-01', 5, 'Active'),

-- Physics Students
('Matthew', 'Martin', 'matthew.martin@university.ac.uk', '2003-04-03', '2021-09-01', 6, 'Active'),
('Charlotte', 'Thompson', 'charlotte.thompson@university.ac.uk', '2003-12-19', '2021-09-01', 6, 'Active');

-- ============================================================================
-- COURSES
-- ============================================================================

INSERT INTO Course (CourseName, CourseCode, Credits, Level, DepartmentID, Description, Prerequisites) VALUES
-- Computer Science Courses (Level 4)
('Introduction to Programming', 'CS101', 30, 4, 1, 'Fundamentals of programming using Python', NULL),
('Data Structures and Algorithms', 'CS201', 30, 4, 1, 'Core data structures and algorithmic techniques', 'CS101'),
('Database Systems', 'CS202', 30, 4, 1, 'Relational database design and SQL', 'CS101'),
('Web Development', 'CS203', 30, 4, 1, 'Full-stack web development', 'CS101'),

-- Computer Science Courses (Level 5)
('Operating Systems', 'CS301', 30, 5, 1, 'OS concepts and system programming', 'CS201'),
('Computer Networks', 'CS302', 30, 5, 1, 'Network protocols and architectures', 'CS201'),
('Software Engineering', 'CS303', 30, 5, 1, 'Software development methodologies', 'CS202'),

-- Computer Science Courses (Level 6 & 7)
('Artificial Intelligence', 'CS401', 30, 6, 1, 'AI techniques and machine learning', 'CS201'),
('Advanced Databases', 'CS501', 30, 7, 1, 'NoSQL, distributed databases, big data', 'CS202'),
('Machine Learning', 'CS502', 30, 7, 1, 'Deep learning and neural networks', 'CS401'),

-- Mathematics Courses
('Calculus I', 'MATH101', 30, 4, 2, 'Differential and integral calculus', NULL),
('Linear Algebra', 'MATH102', 30, 4, 2, 'Vectors, matrices, and linear transformations', NULL),
('Discrete Mathematics', 'MATH201', 30, 4, 2, 'Logic, sets, and graph theory', NULL),
('Statistics', 'MATH202', 30, 5, 2, 'Probability and statistical inference', 'MATH101'),

-- Engineering Courses
('Engineering Mathematics', 'ENG101', 30, 4, 3, 'Mathematical methods for engineers', NULL),
('Software Design Patterns', 'ENG201', 30, 5, 3, 'Design patterns and architecture', 'CS201'),

-- Business Courses
('Business Analytics', 'BUS501', 30, 7, 4, 'Data-driven business decision making', NULL),
('Strategic Management', 'BUS502', 30, 7, 4, 'Corporate strategy and competitive advantage', NULL),

-- Physics Courses
('Classical Mechanics', 'PHYS101', 30, 4, 5, 'Newtonian mechanics and dynamics', NULL),
('Quantum Physics', 'PHYS201', 30, 5, 5, 'Introduction to quantum mechanics', 'PHYS101');

-- ============================================================================
-- INSTRUCTORS
-- ============================================================================

INSERT INTO Instructor (FirstName, LastName, Email, DepartmentID, HireDate, Title, Status) VALUES
-- Computer Science Faculty
('Robert', 'Martin', 'robert.martin@university.ac.uk', 1, '2010-09-01', 'Professor', 'Active'),
('Linda', 'Garcia', 'linda.garcia@university.ac.uk', 1, '2015-01-15', 'Senior Lecturer', 'Active'),
('David', 'Martinez', 'david.martinez@university.ac.uk', 1, '2018-09-01', 'Lecturer', 'Active'),
('Jennifer', 'Rodriguez', 'jennifer.rodriguez@university.ac.uk', 1, '2012-03-20', 'Associate Professor', 'Active'),

-- Mathematics Faculty
('Richard', 'Lee', 'richard.lee@university.ac.uk', 2, '2008-09-01', 'Professor', 'Active'),
('Patricia', 'Walker', 'patricia.walker@university.ac.uk', 2, '2016-01-10', 'Senior Lecturer', 'Active'),

-- Engineering Faculty
('Charles', 'Hall', 'charles.hall@university.ac.uk', 3, '2011-09-01', 'Professor', 'Active'),
('Barbara', 'Allen', 'barbara.allen@university.ac.uk', 3, '2017-02-15', 'Lecturer', 'Active'),

-- Business Faculty
('Joseph', 'Young', 'joseph.young@university.ac.uk', 4, '2013-09-01', 'Professor', 'Active'),
('Susan', 'King', 'susan.king@university.ac.uk', 4, '2019-01-20', 'Senior Lecturer', 'Active'),

-- Physics Faculty
('Thomas', 'Wright', 'thomas.wright@university.ac.uk', 5, '2009-09-01', 'Professor', 'Active'),
('Jessica', 'Lopez', 'jessica.lopez@university.ac.uk', 5, '2014-09-01', 'Senior Lecturer', 'Active');

-- ============================================================================
-- COURSE OFFERINGS (Fall 2023, Spring 2024)
-- ============================================================================

INSERT INTO CourseOffering (CourseID, InstructorID, Semester, Year, Room, MaxStudents) VALUES
-- Fall 2023
(1, 1, 'Fall', 2023, 'A101', 40),  -- CS101 - Intro to Programming
(2, 2, 'Fall', 2023, 'A102', 35),  -- CS201 - Data Structures
(3, 3, 'Fall', 2023, 'A103', 35),  -- CS202 - Database Systems
(4, 4, 'Fall', 2023, 'A104', 30),  -- CS203 - Web Development
(5, 1, 'Fall', 2023, 'A201', 30),  -- CS301 - Operating Systems
(6, 2, 'Fall', 2023, 'A202', 30),  -- CS302 - Computer Networks
(9, 3, 'Fall', 2023, 'A301', 25),  -- CS501 - Advanced Databases
(10, 4, 'Fall', 2023, 'A302', 25), -- CS502 - Machine Learning

-- Mathematics Fall 2023
(11, 5, 'Fall', 2023, 'B101', 40), -- MATH101 - Calculus I
(12, 6, 'Fall', 2023, 'B102', 35), -- MATH102 - Linear Algebra
(13, 5, 'Fall', 2023, 'B201', 30), -- MATH201 - Discrete Math

-- Spring 2024
(1, 2, 'Spring', 2024, 'A101', 40), -- CS101 - Intro to Programming
(2, 1, 'Spring', 2024, 'A102', 35), -- CS201 - Data Structures
(3, 4, 'Spring', 2024, 'A103', 35), -- CS202 - Database Systems
(7, 3, 'Spring', 2024, 'A201', 30), -- CS303 - Software Engineering
(8, 1, 'Spring', 2024, 'A301', 25), -- CS401 - Artificial Intelligence

-- Business Spring 2024
(17, 9, 'Spring', 2024, 'D101', 30),  -- BUS501 - Business Analytics
(18, 10, 'Spring', 2024, 'D102', 30), -- BUS502 - Strategic Management

-- Physics Spring 2024
(19, 11, 'Spring', 2024, 'E101', 35), -- PHYS101 - Classical Mechanics
(20, 12, 'Spring', 2024, 'E201', 30); -- PHYS201 - Quantum Physics

-- ============================================================================
-- ENROLLMENTS
-- ============================================================================

-- Student 1 (John Smith) - CS Year 3
INSERT INTO Enrollment (StudentID, OfferingID, EnrollmentDate, Grade, Status) VALUES
(1, 5, '2023-09-01', 'A', 'Completed'),  -- CS301 - Operating Systems
(1, 6, '2023-09-01', 'B', 'Completed'),  -- CS302 - Computer Networks
(1, 13, '2024-01-15', NULL, 'Enrolled'); -- CS303 - Software Engineering

-- Student 2 (Emma Johnson) - CS Year 3
INSERT INTO Enrollment (StudentID, OfferingID, EnrollmentDate, Grade, Status) VALUES
(2, 5, '2023-09-01', 'A', 'Completed'),
(2, 6, '2023-09-01', 'A', 'Completed'),
(2, 13, '2024-01-15', NULL, 'Enrolled'),
(2, 14, '2024-01-15', NULL, 'Enrolled');

-- Student 3 (Michael Williams) - CS Year 4
INSERT INTO Enrollment (StudentID, OfferingID, EnrollmentDate, Grade, Status) VALUES
(3, 7, '2023-09-01', 'B', 'Completed'),  -- CS501 - Advanced Databases
(3, 8, '2023-09-01', 'A', 'Completed'),  -- CS502 - Machine Learning
(3, 14, '2024-01-15', NULL, 'Enrolled'); -- CS401 - AI

-- Student 4 (Sarah Brown) - CS Year 3
INSERT INTO Enrollment (StudentID, OfferingID, EnrollmentDate, Grade, Status) VALUES
(4, 5, '2023-09-01', 'B', 'Completed'),
(4, 6, '2023-09-01', 'C', 'Completed'),
(4, 13, '2024-01-15', NULL, 'Enrolled');

-- Student 5 (James Davis) - CS Year 2
INSERT INTO Enrollment (StudentID, OfferingID, EnrollmentDate, Grade, Status) VALUES
(5, 2, '2023-09-01', 'A', 'Completed'),  -- CS201 - Data Structures
(5, 3, '2023-09-01', 'B', 'Completed'),  -- CS202 - Database Systems
(5, 4, '2023-09-01', 'A', 'Completed'),  -- CS203 - Web Development
(5, 10, '2024-01-15', NULL, 'Enrolled'), -- CS201 (Spring)
(5, 11, '2024-01-15', NULL, 'Enrolled'); -- CS202 (Spring)

-- Student 6 (Emily Miller) - Data Science MSc
INSERT INTO Enrollment (StudentID, OfferingID, EnrollmentDate, Grade, Status) VALUES
(6, 7, '2023-09-01', 'A', 'Completed'),
(6, 8, '2023-09-01', 'A', 'Completed'),
(6, 14, '2024-01-15', NULL, 'Enrolled');

-- Student 7 (Daniel Wilson) - Data Science MSc
INSERT INTO Enrollment (StudentID, OfferingID, EnrollmentDate, Grade, Status) VALUES
(7, 7, '2023-09-01', 'B', 'Completed'),
(7, 8, '2023-09-01', 'A', 'Completed'),
(7, 15, '2024-01-15', NULL, 'Enrolled');

-- Student 8 (Olivia Moore) - Data Science MSc
INSERT INTO Enrollment (StudentID, OfferingID, EnrollmentDate, Grade, Status) VALUES
(8, 7, '2023-09-01', 'A', 'Completed'),
(8, 8, '2023-09-01', 'A', 'Completed');

-- Student 9 (William Taylor) - Mathematics
INSERT INTO Enrollment (StudentID, OfferingID, EnrollmentDate, Grade, Status) VALUES
(9, 9, '2023-09-01', 'A', 'Completed'),   -- MATH101
(9, 10, '2023-09-01', 'B', 'Completed'),  -- MATH102
(9, 11, '2023-09-01', 'A', 'Completed');  -- MATH201

-- Student 10 (Sophia Anderson) - Mathematics
INSERT INTO Enrollment (StudentID, OfferingID, EnrollmentDate, Grade, Status) VALUES
(10, 9, '2023-09-01', 'B', 'Completed'),
(10, 10, '2023-09-01', 'B', 'Completed'),
(10, 11, '2023-09-01', 'C', 'Completed');

-- Student 13 (Christopher White) - MBA
INSERT INTO Enrollment (StudentID, OfferingID, EnrollmentDate, Grade, Status) VALUES
(13, 15, '2024-01-15', NULL, 'Enrolled'), -- BUS501
(13, 16, '2024-01-15', NULL, 'Enrolled'); -- BUS502

-- Student 14 (Ava Harris) - MBA
INSERT INTO Enrollment (StudentID, OfferingID, EnrollmentDate, Grade, Status) VALUES
(14, 15, '2024-01-15', NULL, 'Enrolled'),
(14, 16, '2024-01-15', NULL, 'Enrolled');

-- Student 15 (Matthew Martin) - Physics
INSERT INTO Enrollment (StudentID, OfferingID, EnrollmentDate, Grade, Status) VALUES
(15, 17, '2024-01-15', NULL, 'Enrolled'); -- PHYS101

-- Student 16 (Charlotte Thompson) - Physics
INSERT INTO Enrollment (StudentID, OfferingID, EnrollmentDate, Grade, Status) VALUES
(16, 17, '2024-01-15', NULL, 'Enrolled'),
(16, 18, '2024-01-15', NULL, 'Enrolled');

-- ============================================================================
-- END OF SAMPLE DATA
-- ============================================================================
