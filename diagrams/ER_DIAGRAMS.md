# Entity-Relationship Diagrams

This document contains ER diagrams for the University Course Management System using Mermaid notation.

## Complete ER Diagram

```mermaid
erDiagram
    DEPARTMENT ||--o{ PROGRAM : offers
    DEPARTMENT ||--o{ COURSE : provides
    DEPARTMENT ||--o{ INSTRUCTOR : employs
    
    PROGRAM ||--o{ STUDENT : enrolls
    
    STUDENT ||--o{ ENROLLMENT : has
    
    COURSE ||--o{ COURSE_OFFERING : "has instances"
    
    INSTRUCTOR ||--o{ COURSE_OFFERING : teaches
    
    COURSE_OFFERING ||--o{ ENROLLMENT : contains
    
    DEPARTMENT {
        int DepartmentID PK
        string DepartmentName
        string Building
        string HeadOfDepartment
        datetime CreatedDate
    }
    
    PROGRAM {
        int ProgramID PK
        string ProgramName
        string ProgramCode
        int DepartmentID FK
        int DurationYears
        int TotalCredits
        int Level
        datetime CreatedDate
    }
    
    STUDENT {
        int StudentID PK
        string FirstName
        string LastName
        string Email
        date DateOfBirth
        date EnrollmentDate
        int ProgramID FK
        string Status
        datetime CreatedDate
    }
    
    COURSE {
        int CourseID PK
        string CourseName
        string CourseCode
        int Credits
        int Level
        int DepartmentID FK
        string Description
        string Prerequisites
        datetime CreatedDate
    }
    
    INSTRUCTOR {
        int InstructorID PK
        string FirstName
        string LastName
        string Email
        int DepartmentID FK
        date HireDate
        string Title
        string Status
        datetime CreatedDate
    }
    
    COURSE_OFFERING {
        int OfferingID PK
        int CourseID FK
        int InstructorID FK
        string Semester
        int Year
        string Room
        int MaxStudents
        int CurrentEnrollment
        datetime CreatedDate
    }
    
    ENROLLMENT {
        int EnrollmentID PK
        int StudentID FK
        int OfferingID FK
        date EnrollmentDate
        string Grade
        string Status
        datetime CreatedDate
    }
```

## Simplified Relationship Diagram

```mermaid
graph TD
    D[Department] --> P[Program]
    D --> C[Course]
    D --> I[Instructor]
    
    P --> S[Student]
    
    C --> CO[Course Offering]
    I --> CO
    
    S --> E[Enrollment]
    CO --> E
    
    style D fill:#e1f5ff
    style P fill:#fff4e1
    style S fill:#e8f5e9
    style C fill:#fce4ec
    style I fill:#f3e5f5
    style CO fill:#fff9c4
    style E fill:#ffebee
```

## Cardinality Relationships

```mermaid
erDiagram
    DEPARTMENT ||--o{ PROGRAM : "1 to Many"
    DEPARTMENT ||--o{ COURSE : "1 to Many"
    DEPARTMENT ||--o{ INSTRUCTOR : "1 to Many"
    PROGRAM ||--o{ STUDENT : "1 to Many"
    COURSE ||--o{ COURSE_OFFERING : "1 to Many"
    INSTRUCTOR ||--o{ COURSE_OFFERING : "1 to Many"
    STUDENT }o--o{ COURSE_OFFERING : "Many to Many via ENROLLMENT"
```

## Database Schema Relationships

### One-to-Many Relationships

1. **Department → Program**
   - One department offers many programs
   - Each program belongs to one department

2. **Department → Course**
   - One department provides many courses
   - Each course belongs to one department

3. **Department → Instructor**
   - One department employs many instructors
   - Each instructor works in one department

4. **Program → Student**
   - One program enrolls many students
   - Each student is enrolled in one program

5. **Course → CourseOffering**
   - One course has many offerings (different semesters/years)
   - Each offering is an instance of one course

6. **Instructor → CourseOffering**
   - One instructor teaches many course offerings
   - Each offering is taught by one instructor

### Many-to-Many Relationships

1. **Student ↔ CourseOffering** (via Enrollment)
   - A student can enroll in many course offerings
   - A course offering can have many students
   - Resolved through the Enrollment junction table

## Normalization Verification

### First Normal Form (1NF)
✓ All attributes contain atomic values
✓ No repeating groups
✓ Each table has a primary key

### Second Normal Form (2NF)
✓ Satisfies 1NF
✓ No partial dependencies (all non-key attributes fully dependent on primary key)
✓ Example: Student name depends on StudentID, not on part of a composite key

### Third Normal Form (3NF)
✓ Satisfies 2NF
✓ No transitive dependencies
✓ Example: ProgramName is in Program table, not Student table

### Boyce-Codd Normal Form (BCNF)
✓ Satisfies 3NF
✓ Every determinant is a candidate key
✓ No anomalies from functional dependencies

## Referential Integrity

All foreign key relationships enforce referential integrity:

- **ON DELETE RESTRICT**: Prevents deletion of referenced records (e.g., cannot delete a Department if it has Programs)
- **ON UPDATE CASCADE**: Automatically updates foreign keys when primary key changes
- **Triggers**: Maintain CurrentEnrollment count automatically

## Indexes for Performance

Primary indexes (automatic):
- All primary keys

Secondary indexes (explicit):
- Email fields (Student, Instructor)
- Department foreign keys
- Course codes
- Semester/Year combinations
- Enrollment lookups

Composite indexes:
- (CourseID, Semester, Year) for course offering queries
- (StudentID, Status) for enrollment queries
