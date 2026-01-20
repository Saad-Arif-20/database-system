# University Course Management System - Database Project

A comprehensive relational database system demonstrating database design, normalization, SQL proficiency, and transaction management. This project implements a complete university course management system from conceptual design through physical implementation.

## Purpose

This project demonstrates proficiency in:
- **Database modeling** (conceptual → logical → physical design)
- **Normalization** (1NF through BCNF)
- **SQL proficiency** (complex queries, joins, subqueries, aggregations)
- **Transaction management** (ACID properties)
- **Data integrity** (constraints, triggers, referential integrity)
- **Performance optimization** (indexing strategies)

## Quick Start

### Setup (2 Minutes)

```bash
# Navigate to the app directory
cd database-system/app

# Initialize the database
python init_database.py

# Run the demonstration application
python database_app.py
```

### Expected Output

```
================================================================================
  UNIVERSITY DATABASE INITIALIZATION
================================================================================
[+] Database initialized with 8 tables:
  - Department: 5 records
  - Program: 6 records
  - Student: 16 records
  - Course: 20 records
  - Instructor: 12 records
  - CourseOffering: 20 records
  - Enrollment: 39 records

================================================================================
  Student Information Lookup
================================================================================
Student ID: 1
Name: John Smith
Email: john.smith@university.ac.uk
Program: BSc Computer Science
Department: Computer Science

================================================================================
  GPA Calculation
================================================================================
Courses Completed: 2
Total Credits: 60
GPA: 3.5
```

### Quick SQL Query Example

```python
from database_app import DatabaseManager, StudentOperations

# Connect and query
db = DatabaseManager('university.db')
db.connect()

student_ops = StudentOperations(db)
student = student_ops.get_student_by_id(1)
print(f"Student: {student['FirstName']} {student['LastName']}")

gpa = student_ops.calculate_gpa(1)
print(f"GPA: {gpa['GPA']}")

db.disconnect()
```

**For more examples, see [QUICKSTART.md](QUICKSTART.md)**

## Core Concepts Demonstrated

### Database Design
- **ER Modeling**: Complete entity-relationship diagrams
- **Normalization**: Systematic normalization from UNF to BCNF
- **Functional Dependencies**: Documented for all entities
- **Referential Integrity**: Foreign key constraints with cascade rules

### SQL Proficiency
- **Complex Queries**: 20+ advanced SQL queries
- **Joins**: Inner, outer, self-joins across multiple tables
- **Subqueries**: Correlated and non-correlated subqueries
- **Aggregations**: GROUP BY, HAVING, window functions
- **Views**: Materialized query results for common operations

### Transaction Management
- **ACID Properties**: Atomicity, Consistency, Isolation, Durability
- **Concurrency Control**: Locking and isolation levels
- **Error Handling**: Rollback on failures
- **Business Logic**: Complex multi-step transactions

### Data Integrity
- **Primary Keys**: Auto-incrementing identifiers
- **Foreign Keys**: Referential integrity with cascade rules
- **Check Constraints**: Data validation at database level
- **Triggers**: Automatic data maintenance
- **Unique Constraints**: Preventing duplicates

## Project Structure

```
/database-system
 ├── schema/              # Database schema definitions
 │   └── create_schema.sql    # Complete DDL with tables, indexes, views, triggers
 │
 ├── sql/                 # SQL scripts and queries
 │   ├── insert_sample_data.sql    # Realistic sample data
 │   ├── advanced_queries.sql      # 20+ complex queries
 │   └── transaction_examples.sql  # ACID demonstrations
 │
 ├── diagrams/            # ER diagrams and visualizations
 │   └── ER_DIAGRAMS.md       # Mermaid ER diagrams
 │
 ├── app/                 # Python application
 │   ├── database_app.py      # Main application with CRUD operations
 │   └── init_database.py     # Database initialization script
 │
 ├── docs/                # Documentation
 │   └── CONCEPTUAL_DESIGN.md # Design decisions and normalization
 │
 └── README.md            # This file
```

## Getting Started

### Prerequisites
- Python 3.7 or higher
- SQLite3 (included with Python)
- No external dependencies required

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd database-system
```

2. Initialize the database:
```bash
cd app
python init_database.py
```

3. Run the application:
```bash
python database_app.py
```

## Database Schema

### Tables

1. **Department** - Academic departments
2. **Program** - Degree programs (BSc, MSc, etc.)
3. **Student** - Enrolled students
4. **Course** - Available courses
5. **Instructor** - Faculty members
6. **CourseOffering** - Specific course instances (semester/year)
7. **Enrollment** - Student enrollments in course offerings

### Relationships

- Department → Program (1:M)
- Department → Course (1:M)
- Department → Instructor (1:M)
- Program → Student (1:M)
- Course → CourseOffering (1:M)
- Instructor → CourseOffering (1:M)
- Student ↔ CourseOffering (M:N via Enrollment)

## Normalization Process

### First Normal Form (1NF)
✓ Eliminated repeating groups
✓ Atomic values in all columns
✓ Primary key defined for each table

### Second Normal Form (2NF)
✓ Removed partial dependencies
✓ All non-key attributes fully dependent on primary key
✓ Example: Student name depends on StudentID, not on composite key

### Third Normal Form (3NF)
✓ Removed transitive dependencies
✓ Non-key attributes don't depend on other non-key attributes
✓ Example: ProgramName stored in Program table, not Student table

### Boyce-Codd Normal Form (BCNF)
✓ Every determinant is a candidate key
✓ No anomalies from functional dependencies
✓ Optimal design for data integrity

## SQL Query Examples

### Basic Queries

```sql
-- Student enrollment history
SELECT 
    s.FirstName || ' ' || s.LastName AS StudentName,
    c.CourseCode,
    c.CourseName,
    co.Semester || ' ' || co.Year AS Term,
    e.Grade
FROM Enrollment e
JOIN Student s ON e.StudentID = s.StudentID
JOIN CourseOffering co ON e.OfferingID = co.OfferingID
JOIN Course c ON co.CourseID = c.CourseID
WHERE s.StudentID = 1;
```

### Advanced Queries

```sql
-- Student performance ranking within program
WITH StudentGPAs AS (
    SELECT 
        s.StudentID,
        s.FirstName || ' ' || s.LastName AS StudentName,
        s.ProgramID,
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
    LEFT JOIN Enrollment e ON s.StudentID = e.StudentID
    WHERE e.Grade IS NOT NULL
    GROUP BY s.StudentID
)
SELECT 
    StudentName,
    GPA,
    RANK() OVER (PARTITION BY ProgramID ORDER BY GPA DESC) AS ProgramRank
FROM StudentGPAs
ORDER BY ProgramID, ProgramRank;
```

## Transaction Examples

### Student Enrollment Transaction

```sql
BEGIN TRANSACTION;

-- Check course availability
SELECT CurrentEnrollment, MaxStudents
FROM CourseOffering
WHERE OfferingID = 1;

-- Enroll student
INSERT INTO Enrollment (StudentID, OfferingID, Status)
VALUES (5, 1, 'Enrolled');

-- Trigger automatically updates CurrentEnrollment

COMMIT;
```

### Grade Update with Validation

```sql
BEGIN TRANSACTION;

-- Update grade
UPDATE Enrollment
SET Grade = 'A', Status = 'Completed'
WHERE EnrollmentID = 1;

-- Verify update
SELECT Grade, Status FROM Enrollment WHERE EnrollmentID = 1;

COMMIT;
```

## Performance Optimization

### Indexing Strategy

**Primary Indexes** (automatic on primary keys):
- All table primary keys

**Secondary Indexes** (performance optimization):
```sql
CREATE INDEX idx_student_email ON Student(Email);
CREATE INDEX idx_course_code ON Course(CourseCode);
CREATE INDEX idx_offering_semester_year ON CourseOffering(Semester, Year);
```

**Composite Indexes** (multi-column queries):
```sql
CREATE INDEX idx_offering_course_semester ON CourseOffering(CourseID, Semester, Year);
CREATE INDEX idx_enrollment_student_grade ON Enrollment(StudentID, Grade);
```

## Views for Common Operations

### Student Enrollment View
```sql
CREATE VIEW StudentEnrollmentView AS
SELECT 
    s.StudentID,
    s.FirstName || ' ' || s.LastName AS StudentName,
    c.CourseCode,
    c.CourseName,
    co.Semester,
    co.Year,
    e.Grade
FROM Enrollment e
JOIN Student s ON e.StudentID = s.StudentID
JOIN CourseOffering co ON e.OfferingID = co.OfferingID
JOIN Course c ON co.CourseID = c.CourseID;
```

### Course Availability View
```sql
CREATE VIEW CourseOfferingAvailability AS
SELECT 
    c.CourseCode,
    c.CourseName,
    co.Semester,
    co.Year,
    co.MaxStudents,
    co.CurrentEnrollment,
    (co.MaxStudents - co.CurrentEnrollment) AS AvailableSeats
FROM CourseOffering co
JOIN Course c ON co.CourseID = c.CourseID;
```

## Triggers for Data Integrity

### Automatic Enrollment Count Update
```sql
CREATE TRIGGER trg_enrollment_insert
AFTER INSERT ON Enrollment
BEGIN
    UPDATE CourseOffering
    SET CurrentEnrollment = CurrentEnrollment + 1
    WHERE OfferingID = NEW.OfferingID;
END;
```

### Prevent Enrollment in Full Courses
```sql
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
```

## Python Application Features

The included Python application demonstrates:

- **Database Connection Management**: Proper connection handling
- **CRUD Operations**: Create, Read, Update, Delete
- **Transaction Management**: Commit and rollback
- **Error Handling**: Graceful failure recovery
- **Reporting**: Analytics and statistics generation

### Application Classes

1. **DatabaseManager**: Connection and transaction management
2. **StudentOperations**: Student-related operations
3. **EnrollmentOperations**: Enrollment and grade management
4. **CourseOperations**: Course offering management
5. **ReportingOperations**: Analytics and reports

## Learning Context & Academic Alignment

This project demonstrates applied understanding of key database and information systems concepts:

| Outcome | Implementation Evidence |
| :--- | :--- |
| **Database Design** | Complete ER modeling, normalization (1NF → BCNF), and schema optimization. |
| **SQL Proficiency** | 20+ complex queries with joins, subqueries, aggregations, and window functions. |
| **Transaction Management** | ACID property implementation with proper error handling and rollback mechanisms. |
| **Data Integrity** | Comprehensive use of constraints, triggers, and referential integrity rules. |

**Related Concepts**:
*   Database systems and design
*   Data management principles
*   Software engineering practices

---


## Design Decisions

### Why SQLite?

**Reasons**:
- Portable (no server required)
- Zero configuration
- Perfect for demonstration and education
- ACID compliant
- Full SQL support

**Trade-offs**:
- Limited concurrency compared to client-server databases
- No user management (suitable for single-user applications)
- Simpler than PostgreSQL/MySQL but demonstrates same concepts

### Why Separate CourseOffering from Course?

**Reason**: A course can be offered multiple times with different:
- Semesters and years
- Instructors
- Rooms and capacities

This separation enables:
- Historical tracking
- Multiple sections
- Flexible scheduling

### Why Triggers for Enrollment Count?

**Reason**: Automatic maintenance ensures:
- Data consistency
- No manual updates required
- Atomic operations (enrollment + count update)
- Prevents race conditions

## Constraints and Business Rules

### Primary Constraints
- All tables have primary keys
- Auto-incrementing integers for simplicity

### Foreign Key Constraints
- ON DELETE RESTRICT: Prevent orphaned records
- ON UPDATE CASCADE: Maintain referential integrity

### Check Constraints
- Credits > 0
- Level IN (4, 5, 6, 7)
- Grade IN ('A', 'B', 'C', 'D', 'F', 'P', 'W', NULL)
- Status values validated

### Unique Constraints
- Email addresses (Student, Instructor)
- Course codes
- (StudentID, OfferingID) in Enrollment

## Testing and Verification

### Data Integrity Tests
- Foreign key constraint verification
- Check constraint validation
- Unique constraint enforcement
- Trigger functionality

### Query Validation
- Result correctness
- Performance benchmarking
- Edge case handling

### Transaction Testing
- ACID property verification
- Rollback scenarios
- Concurrent access simulation

## Limitations and Future Improvements

### Current Limitations
1. **Single Database**: No distributed database features
2. **Basic Security**: No row-level security or encryption
3. **Limited Audit Trail**: No comprehensive change logging
4. **No Replication**: Single point of failure
5. **SQLite Constraints**: As an embedded database, SQLite lacks built-in user management and role-based access control found in production DBMS (PostgreSQL, MySQL, Oracle)

**Note on Security Implementation**: The schema includes conceptual security views and role-based access patterns (e.g., `StudentEnrollmentView` filtering by `CURRENT_USER_ID()`). In this educational implementation using SQLite, `CURRENT_USER_ID()` is a placeholder demonstrating the security concept. In a production environment with PostgreSQL or MySQL, this would be replaced with actual user session functions (`current_user`, `session_user`, etc.) and proper role-based access control (GRANT/REVOKE statements).

### Potential Improvements
1. **Enhanced Features**:
   - Attendance tracking
   - Assignment and exam management
   - Financial aid integration
   - Room scheduling optimization

2. **Advanced Database Features**:
   - Stored procedures
   - User-defined functions
   - Materialized views
   - Partitioning for large datasets

3. **Security Enhancements**:
   - Row-level security
   - Encryption at rest
   - Audit logging
   - Role-based access control

4. **Performance Optimizations**:
   - Query plan analysis
   - Index tuning
   - Caching strategies
   - Read replicas

## Author

**SAAD ARIF**
**Year**: 2025

Aspiring Computer Science undergraduate (advanced entry)

Background in engineering and software development

## License

This project was created for educational and professional development purposes to consolidate and demonstrate core database design and SQL concepts.

## Acknowledgments

- Database design principles from Elmasri and Navathe
- SQL standards and best practices
- Normalization theory from Codd's relational model
- Transaction management concepts from database systems literature

---

**Note**: This project demonstrates understanding of database systems through practical implementation. All designs and implementations are original and were developed for educational and professional skill consolidation purposes.
