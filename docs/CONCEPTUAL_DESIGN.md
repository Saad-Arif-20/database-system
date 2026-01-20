# University Course Management System - Database Design

## Conceptual Design (ER Model)

### Entities

1. **Student**
   - Attributes: StudentID (PK), FirstName, LastName, Email, DateOfBirth, EnrollmentDate, ProgramID (FK)
   
2. **Program**
   - Attributes: ProgramID (PK), ProgramName, Department, DurationYears, Credits
   
3. **Course**
   - Attributes: CourseID (PK), CourseName, CourseCode, Credits, Level, DepartmentID (FK)
   
4. **Department**
   - Attributes: DepartmentID (PK), DepartmentName, Building, HeadOfDepartment
   
5. **Instructor**
   - Attributes: InstructorID (PK), FirstName, LastName, Email, DepartmentID (FK), HireDate
   
6. **Enrollment**
   - Attributes: EnrollmentID (PK), StudentID (FK), CourseID (FK), Semester, Year, Grade
   
7. **CourseOffering**
   - Attributes: OfferingID (PK), CourseID (FK), InstructorID (FK), Semester, Year, Room, MaxStudents

### Relationships

1. **Student enrolls in Program** (Many-to-One)
   - A student belongs to one program
   - A program has many students

2. **Program offered by Department** (Many-to-One)
   - A program is offered by one department
   - A department offers many programs

3. **Course belongs to Department** (Many-to-One)
   - A course belongs to one department
   - A department has many courses

4. **Instructor works in Department** (Many-to-One)
   - An instructor works in one department
   - A department has many instructors

5. **Student enrolls in CourseOffering** (Many-to-Many via Enrollment)
   - A student can enroll in many course offerings
   - A course offering can have many students

6. **Instructor teaches CourseOffering** (One-to-Many)
   - An instructor can teach many course offerings
   - A course offering is taught by one instructor

7. **CourseOffering is instance of Course** (Many-to-One)
   - A course offering is an instance of one course
   - A course can have many offerings

## ER Diagram (Textual Representation)

```
┌─────────────┐       ┌──────────────┐       ┌─────────────┐
│  STUDENT    │──────▶│   PROGRAM    │──────▶│ DEPARTMENT  │
│             │ M:1   │              │ M:1   │             │
│ StudentID   │       │ ProgramID    │       │DepartmentID │
│ FirstName   │       │ ProgramName  │       │DeptName     │
│ LastName    │       │ Department   │       │ Building    │
│ Email       │       │ Duration     │       │ HeadOfDept  │
│ DOB         │       │ Credits      │       └─────────────┘
│ EnrollDate  │       └──────────────┘              │
│ ProgramID   │                                     │ 1:M
└─────────────┘                                     ▼
      │                                      ┌─────────────┐
      │ M:N                                  │   COURSE    │
      │                                      │             │
      ▼                                      │ CourseID    │
┌─────────────┐       ┌──────────────┐      │ CourseName  │
│ ENROLLMENT  │──────▶│COURSE        │◀─────│ CourseCode  │
│             │ M:1   │ OFFERING     │ M:1  │ Credits     │
│EnrollmentID │       │              │      │ Level       │
│ StudentID   │       │ OfferingID   │      │DepartmentID │
│ OfferingID  │       │ CourseID     │      └─────────────┘
│ Grade       │       │ InstructorID │             │
└─────────────┘       │ Semester     │             │ 1:M
                      │ Year         │             │
                      │ Room         │             ▼
                      │ MaxStudents  │      ┌─────────────┐
                      └──────────────┘      │ INSTRUCTOR  │
                             │              │             │
                             │ M:1          │InstructorID │
                             └─────────────▶│ FirstName   │
                                            │ LastName    │
                                            │ Email       │
                                            │DepartmentID │
                                            │ HireDate    │
                                            └─────────────┘
```

## Normalization Process

### Initial Unnormalized Form

Consider a flat file storing student enrollment data:

```
StudentID | StudentName | Email | Program | ProgramDept | CourseCode | CourseName | Instructor | Grade | Semester
```

**Problems**:
- Redundancy (student info repeated for each course)
- Update anomalies (changing student email requires multiple updates)
- Insertion anomalies (can't add a course without a student)
- Deletion anomalies (deleting last student enrollment loses course info)

### First Normal Form (1NF)

**Rule**: Eliminate repeating groups, ensure atomic values

- Split StudentName into FirstName, LastName
- Create separate tables for entities
- Ensure each cell contains single value

### Second Normal Form (2NF)

**Rule**: Remove partial dependencies (all non-key attributes fully dependent on primary key)

**Before**: Enrollment(EnrollmentID, StudentID, CourseID, StudentName, CourseName, Grade)
- StudentName depends only on StudentID (partial dependency)
- CourseName depends only on CourseID (partial dependency)

**After**:
- Student(StudentID, FirstName, LastName, ...)
- Course(CourseID, CourseName, ...)
- Enrollment(EnrollmentID, StudentID, CourseID, Grade)

### Third Normal Form (3NF)

**Rule**: Remove transitive dependencies (non-key attributes should not depend on other non-key attributes)

**Before**: Student(StudentID, FirstName, LastName, ProgramID, ProgramName, Department)
- ProgramName depends on ProgramID (transitive dependency)
- Department depends on ProgramID (transitive dependency)

**After**:
- Student(StudentID, FirstName, LastName, ProgramID)
- Program(ProgramID, ProgramName, Department)

### Boyce-Codd Normal Form (BCNF)

**Rule**: For every functional dependency X → Y, X must be a superkey

Our design satisfies BCNF as all determinants are candidate keys.

## Functional Dependencies

### Student Table
- StudentID → FirstName, LastName, Email, DateOfBirth, EnrollmentDate, ProgramID

### Program Table
- ProgramID → ProgramName, Department, DurationYears, Credits

### Course Table
- CourseID → CourseName, CourseCode, Credits, Level, DepartmentID
- CourseCode → CourseID (alternate key)

### Department Table
- DepartmentID → DepartmentName, Building, HeadOfDepartment

### Instructor Table
- InstructorID → FirstName, LastName, Email, DepartmentID, HireDate

### Enrollment Table
- EnrollmentID → StudentID, OfferingID, Grade
- (StudentID, OfferingID) → EnrollmentID, Grade (composite candidate key)

### CourseOffering Table
- OfferingID → CourseID, InstructorID, Semester, Year, Room, MaxStudents
- (CourseID, Semester, Year) → OfferingID (composite candidate key)

## Design Decisions

### Why Separate CourseOffering from Course?

**Reason**: A course (e.g., "Database Systems") can be offered multiple times:
- Different semesters
- Different years
- Different instructors
- Different rooms

This separation allows:
- Historical tracking of course offerings
- Multiple sections of the same course
- Instructor assignment per offering
- Enrollment management per offering

### Why ProgramID in Student instead of embedding Program details?

**Reason**: Normalization (3NF)
- Eliminates redundancy (program details stored once)
- Prevents update anomalies
- Allows easy program updates without affecting students

### Why DepartmentID in multiple tables?

**Reason**: Establishes clear organizational hierarchy:
- Programs belong to departments
- Courses belong to departments
- Instructors work in departments

This enables:
- Department-level reporting
- Cross-departmental queries
- Organizational structure maintenance

## Constraints and Business Rules

### Primary Key Constraints
- Every table has a primary key
- Primary keys are auto-incrementing integers for simplicity

### Foreign Key Constraints
- Student.ProgramID references Program.ProgramID
- Program.DepartmentID references Department.DepartmentID
- Course.DepartmentID references Department.DepartmentID
- Instructor.DepartmentID references Department.DepartmentID
- Enrollment.StudentID references Student.StudentID
- Enrollment.OfferingID references CourseOffering.OfferingID
- CourseOffering.CourseID references Course.CourseID
- CourseOffering.InstructorID references Instructor.InstructorID

### Check Constraints
- Credits > 0
- Level IN (4, 5, 6, 7) -- undergraduate and postgraduate levels
- Grade IN ('A', 'B', 'C', 'D', 'F', 'P', 'W', NULL)
- MaxStudents > 0
- DurationYears > 0

### Unique Constraints
- Student.Email (unique)
- Instructor.Email (unique)
- Course.CourseCode (unique)
- (Student.StudentID, CourseOffering.OfferingID) in Enrollment (unique)

### Not Null Constraints
- All primary keys
- Student: FirstName, LastName, Email, EnrollmentDate
- Course: CourseName, CourseCode, Credits
- Instructor: FirstName, LastName, Email

## Indexing Strategy

### Primary Indexes (Automatic)
- All primary keys automatically indexed

### Secondary Indexes (Performance Optimization)

```sql
-- Frequently searched by email
CREATE INDEX idx_student_email ON Student(Email);
CREATE INDEX idx_instructor_email ON Instructor(Email);

-- Frequently filtered by department
CREATE INDEX idx_course_department ON Course(DepartmentID);
CREATE INDEX idx_instructor_department ON Instructor(DepartmentID);

-- Frequently searched by course code
CREATE INDEX idx_course_code ON Course(CourseCode);

-- Frequently filtered by semester/year
CREATE INDEX idx_offering_semester_year ON CourseOffering(Semester, Year);

-- Frequently joined on student enrollments
CREATE INDEX idx_enrollment_student ON Enrollment(StudentID);
CREATE INDEX idx_enrollment_offering ON Enrollment(OfferingID);
```

### Composite Indexes

```sql
-- For queries filtering by course and semester
CREATE INDEX idx_offering_course_semester ON CourseOffering(CourseID, Semester, Year);

-- For enrollment queries by student and grade
CREATE INDEX idx_enrollment_student_grade ON Enrollment(StudentID, Grade);
```

## Transaction Examples

### Scenario 1: Student Enrollment
```
BEGIN TRANSACTION;
  -- Check if course offering has space
  -- Insert enrollment record
  -- Update course offering current enrollment count
COMMIT;
```

### Scenario 2: Grade Update
```
BEGIN TRANSACTION;
  -- Verify enrollment exists
  -- Update grade
  -- Log grade change (audit trail)
COMMIT;
```

### Scenario 3: Course Offering Creation
```
BEGIN TRANSACTION;
  -- Verify course exists
  -- Verify instructor exists
  -- Create course offering
  -- Set initial enrollment count to 0
COMMIT;
```

## Security Considerations

### User Roles
- **Admin**: Full access to all tables
- **Instructor**: Read access to all, write access to grades for their courses
- **Student**: Read access to their own records and course catalog
- **Registrar**: Full access to enrollment and student records

### Views for Security
```sql
-- Students can only see their own enrollments
CREATE VIEW StudentEnrollmentView AS
SELECT e.*, c.CourseName, co.Semester, co.Year
FROM Enrollment e
JOIN CourseOffering co ON e.OfferingID = co.OfferingID
JOIN Course c ON co.CourseID = c.CourseID
WHERE e.StudentID = CURRENT_USER_ID();
```
