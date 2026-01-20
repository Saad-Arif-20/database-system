"""
University Course Management System - Database Application
Main application demonstrating database operations and transactions.
"""

import sqlite3
import os
from datetime import datetime


class DatabaseManager:
    """Manages database connections and operations."""
    
    def __init__(self, db_path='university.db'):
        self.db_path = db_path
        self.conn = None
        self.cursor = None
    
    def connect(self):
        """Establish database connection."""
        self.conn = sqlite3.connect(self.db_path)
        self.conn.row_factory = sqlite3.Row  # Enable column access by name
        self.cursor = self.conn.cursor()
        # Enable foreign key constraints
        self.cursor.execute("PRAGMA foreign_keys = ON")
        return self.conn
    
    def disconnect(self):
        """Close database connection."""
        if self.conn:
            self.conn.close()
    
    def execute_script(self, script_path):
        """Execute SQL script from file."""
        with open(script_path, 'r', encoding='utf-8') as f:
            script = f.read()
        self.cursor.executescript(script)
        self.conn.commit()
    
    def commit(self):
        """Commit current transaction."""
        if self.conn:
            self.conn.commit()
    
    def rollback(self):
        """Rollback current transaction."""
        if self.conn:
            self.conn.rollback()


class StudentOperations:
    """Operations related to students."""
    
    def __init__(self, db_manager):
        self.db = db_manager
    
    def add_student(self, first_name, last_name, email, dob, program_id):
        """Add a new student to the database."""
        try:
            query = """
            INSERT INTO Student (FirstName, LastName, Email, DateOfBirth, ProgramID)
            VALUES (?, ?, ?, ?, ?)
            """
            self.db.cursor.execute(query, (first_name, last_name, email, dob, program_id))
            self.db.commit()
            return self.db.cursor.lastrowid
        except sqlite3.IntegrityError as e:
            self.db.rollback()
            raise Exception(f"Failed to add student: {e}")
    
    def get_student_by_id(self, student_id):
        """Retrieve student information by ID."""
        query = """
        SELECT s.*, p.ProgramName, d.DepartmentName
        FROM Student s
        JOIN Program p ON s.ProgramID = p.ProgramID
        JOIN Department d ON p.DepartmentID = d.DepartmentID
        WHERE s.StudentID = ?
        """
        self.db.cursor.execute(query, (student_id,))
        return self.db.cursor.fetchone()
    
    def get_student_transcript(self, student_id):
        """Get complete transcript for a student."""
        query = """
        SELECT 
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
        FROM Enrollment e
        JOIN CourseOffering co ON e.OfferingID = co.OfferingID
        JOIN Course c ON co.CourseID = c.CourseID
        JOIN Instructor i ON co.InstructorID = i.InstructorID
        WHERE e.StudentID = ?
        ORDER BY co.Year, co.Semester, c.CourseCode
        """
        self.db.cursor.execute(query, (student_id,))
        return self.db.cursor.fetchall()
    
    def calculate_gpa(self, student_id):
        """Calculate student's GPA."""
        query = """
        SELECT 
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
        FROM Enrollment e
        JOIN CourseOffering co ON e.OfferingID = co.OfferingID
        JOIN Course c ON co.CourseID = c.CourseID
        WHERE e.StudentID = ? AND e.Grade IS NOT NULL
        """
        self.db.cursor.execute(query, (student_id,))
        return self.db.cursor.fetchone()


class EnrollmentOperations:
    """Operations related to course enrollments."""
    
    def __init__(self, db_manager):
        self.db = db_manager
    
    def enroll_student(self, student_id, offering_id):
        """
        Enroll a student in a course offering.
        Implements transaction to ensure data consistency.
        """
        try:
            # Begin transaction
            self.db.cursor.execute("BEGIN TRANSACTION")
            
            # Check if course offering exists and has space
            check_query = """
            SELECT MaxStudents, CurrentEnrollment
            FROM CourseOffering
            WHERE OfferingID = ?
            """
            self.db.cursor.execute(check_query, (offering_id,))
            offering = self.db.cursor.fetchone()
            
            if not offering:
                raise Exception("Course offering not found")
            
            if offering['CurrentEnrollment'] >= offering['MaxStudents']:
                raise Exception("Course offering is full")
            
            # Check if student is already enrolled
            duplicate_check = """
            SELECT 1 FROM Enrollment
            WHERE StudentID = ? AND OfferingID = ?
            """
            self.db.cursor.execute(duplicate_check, (student_id, offering_id))
            if self.db.cursor.fetchone():
                raise Exception("Student is already enrolled in this course")
            
            # Insert enrollment record
            insert_query = """
            INSERT INTO Enrollment (StudentID, OfferingID, Status)
            VALUES (?, ?, 'Enrolled')
            """
            self.db.cursor.execute(insert_query, (student_id, offering_id))
            
            # Trigger will automatically update CurrentEnrollment
            
            # Commit transaction
            self.db.commit()
            return self.db.cursor.lastrowid
            
        except Exception as e:
            self.db.rollback()
            raise Exception(f"Enrollment failed: {e}")
    
    def update_grade(self, enrollment_id, grade):
        """Update student grade for an enrollment."""
        try:
            # Validate grade
            valid_grades = ['A', 'B', 'C', 'D', 'F', 'P', 'W']
            if grade not in valid_grades:
                raise Exception(f"Invalid grade. Must be one of: {', '.join(valid_grades)}")
            
            # Update grade and status
            query = """
            UPDATE Enrollment
            SET Grade = ?, Status = 'Completed'
            WHERE EnrollmentID = ?
            """
            self.db.cursor.execute(query, (grade, enrollment_id))
            
            if self.db.cursor.rowcount == 0:
                raise Exception("Enrollment not found")
            
            self.db.commit()
            return True
            
        except Exception as e:
            self.db.rollback()
            raise Exception(f"Grade update failed: {e}")
    
    def withdraw_from_course(self, enrollment_id):
        """Withdraw a student from a course."""
        try:
            self.db.cursor.execute("BEGIN TRANSACTION")
            
            # Update enrollment status
            update_query = """
            UPDATE Enrollment
            SET Status = 'Withdrawn', Grade = 'W'
            WHERE EnrollmentID = ? AND Status = 'Enrolled'
            """
            self.db.cursor.execute(update_query, (enrollment_id,))
            
            if self.db.cursor.rowcount == 0:
                raise Exception("Enrollment not found or already completed")
            
            self.db.commit()
            return True
            
        except Exception as e:
            self.db.rollback()
            raise Exception(f"Withdrawal failed: {e}")


class CourseOperations:
    """Operations related to courses and course offerings."""
    
    def __init__(self, db_manager):
        self.db = db_manager
    
    def create_course_offering(self, course_id, instructor_id, semester, year, room, max_students):
        """Create a new course offering."""
        try:
            # Verify course and instructor exist
            verify_query = """
            SELECT 
                (SELECT COUNT(*) FROM Course WHERE CourseID = ?) AS course_exists,
                (SELECT COUNT(*) FROM Instructor WHERE InstructorID = ?) AS instructor_exists
            """
            self.db.cursor.execute(verify_query, (course_id, instructor_id))
            result = self.db.cursor.fetchone()
            
            if not result['course_exists']:
                raise Exception("Course not found")
            if not result['instructor_exists']:
                raise Exception("Instructor not found")
            
            # Insert course offering
            insert_query = """
            INSERT INTO CourseOffering 
            (CourseID, InstructorID, Semester, Year, Room, MaxStudents, CurrentEnrollment)
            VALUES (?, ?, ?, ?, ?, ?, 0)
            """
            self.db.cursor.execute(insert_query, 
                                 (course_id, instructor_id, semester, year, room, max_students))
            
            self.db.commit()
            return self.db.cursor.lastrowid
            
        except sqlite3.IntegrityError as e:
            self.db.rollback()
            raise Exception(f"Failed to create course offering: {e}")
    
    def get_available_courses(self, semester, year):
        """Get all available course offerings for a semester."""
        query = """
        SELECT 
            co.OfferingID,
            c.CourseCode,
            c.CourseName,
            c.Credits,
            c.Level,
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
        JOIN Instructor i ON co.InstructorID = i.InstructorID
        WHERE co.Semester = ? AND co.Year = ?
        ORDER BY c.CourseCode
        """
        self.db.cursor.execute(query, (semester, year))
        return self.db.cursor.fetchall()
    
    def get_course_enrollment_stats(self, course_id):
        """Get enrollment statistics for a course across all offerings."""
        query = """
        SELECT 
            co.Semester || ' ' || co.Year AS Term,
            co.MaxStudents,
            co.CurrentEnrollment,
            ROUND(CAST(co.CurrentEnrollment AS FLOAT) / co.MaxStudents * 100, 1) AS FillRate,
            COUNT(e.EnrollmentID) AS TotalEnrollments,
            COUNT(CASE WHEN e.Grade = 'A' THEN 1 END) AS GradeA,
            COUNT(CASE WHEN e.Grade = 'B' THEN 1 END) AS GradeB,
            COUNT(CASE WHEN e.Grade = 'C' THEN 1 END) AS GradeC,
            COUNT(CASE WHEN e.Grade IN ('D', 'F') THEN 1 END) AS GradeDF
        FROM CourseOffering co
        LEFT JOIN Enrollment e ON co.OfferingID = e.OfferingID
        WHERE co.CourseID = ?
        GROUP BY co.OfferingID, Term, co.MaxStudents, co.CurrentEnrollment
        ORDER BY co.Year DESC, co.Semester
        """
        self.db.cursor.execute(query, (course_id,))
        return self.db.cursor.fetchall()


class ReportingOperations:
    """Operations for generating reports and analytics."""
    
    def __init__(self, db_manager):
        self.db = db_manager
    
    def department_summary(self):
        """Generate summary statistics for all departments."""
        query = """
        SELECT 
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
        GROUP BY d.DepartmentID, d.DepartmentName
        ORDER BY TotalStudents DESC
        """
        self.db.cursor.execute(query)
        return self.db.cursor.fetchall()
    
    def semester_enrollment_report(self, semester, year):
        """Generate enrollment report for a semester."""
        query = """
        SELECT 
            COUNT(DISTINCT co.OfferingID) AS CoursesOffered,
            COUNT(DISTINCT e.StudentID) AS UniqueStudents,
            COUNT(e.EnrollmentID) AS TotalEnrollments,
            SUM(co.MaxStudents) AS TotalCapacity,
            SUM(co.CurrentEnrollment) AS TotalEnrolled,
            ROUND(CAST(SUM(co.CurrentEnrollment) AS FLOAT) / SUM(co.MaxStudents) * 100, 1) AS OverallFillRate
        FROM CourseOffering co
        LEFT JOIN Enrollment e ON co.OfferingID = e.OfferingID
        WHERE co.Semester = ? AND co.Year = ?
        """
        self.db.cursor.execute(query, (semester, year))
        return self.db.cursor.fetchone()
    
    def students_at_risk(self, gpa_threshold=2.0):
        """Identify students with GPA below threshold."""
        query = """
        SELECT 
            s.StudentID,
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
        HAVING GPA < ?
        ORDER BY GPA ASC
        """
        self.db.cursor.execute(query, (gpa_threshold,))
        return self.db.cursor.fetchall()


def print_header(title):
    """Print formatted header."""
    print("\n" + "=" * 80)
    print(f"  {title}")
    print("=" * 80)


def print_table(rows, headers=None):
    """Print results in table format."""
    if not rows:
        print("No results found.")
        return
    
    # Get headers from first row if not provided
    if headers is None and hasattr(rows[0], 'keys'):
        headers = rows[0].keys()
    
    if headers:
        print("\n" + " | ".join(str(h) for h in headers))
        print("-" * 80)
    
    for row in rows:
        if hasattr(row, 'keys'):
            print(" | ".join(str(row[key]) for key in headers))
        else:
            print(" | ".join(str(val) for val in row))


def main():
    """Main application demonstrating database operations."""
    
    print_header("UNIVERSITY COURSE MANAGEMENT SYSTEM")
    print("\nDatabase Application Demonstration")
    
    # Initialize database
    db = DatabaseManager('university.db')
    db.connect()
    
    # Initialize operation classes
    student_ops = StudentOperations(db)
    enrollment_ops = EnrollmentOperations(db)
    course_ops = CourseOperations(db)
    reporting_ops = ReportingOperations(db)
    
    try:
        # Demonstration 1: Student Information
        print_header("Student Information Lookup")
        student = student_ops.get_student_by_id(1)
        if student:
            print(f"\nStudent ID: {student['StudentID']}")
            print(f"Name: {student['FirstName']} {student['LastName']}")
            print(f"Email: {student['Email']}")
            print(f"Program: {student['ProgramName']}")
            print(f"Department: {student['DepartmentName']}")
            print(f"Status: {student['Status']}")
        
        # Demonstration 2: Student Transcript
        print_header("Student Transcript")
        transcript = student_ops.get_student_transcript(1)
        print_table(transcript)
        
        # Demonstration 3: GPA Calculation
        print_header("GPA Calculation")
        gpa_info = student_ops.calculate_gpa(1)
        if gpa_info:
            print(f"\nCourses Completed: {gpa_info['CoursesCompleted']}")
            print(f"Total Credits: {gpa_info['TotalCredits']}")
            print(f"GPA: {gpa_info['GPA']}")
        
        # Demonstration 4: Available Courses
        print_header("Available Courses - Spring 2024")
        available_courses = course_ops.get_available_courses('Spring', 2024)
        print_table(available_courses[:10])  # Show first 10
        
        # Demonstration 5: Department Summary
        print_header("Department Statistics")
        dept_stats = reporting_ops.department_summary()
        print_table(dept_stats)
        
        # Demonstration 6: Semester Enrollment Report
        print_header("Semester Enrollment Report - Spring 2024")
        semester_report = reporting_ops.semester_enrollment_report('Spring', 2024)
        if semester_report:
            print(f"\nCourses Offered: {semester_report['CoursesOffered']}")
            print(f"Unique Students: {semester_report['UniqueStudents']}")
            print(f"Total Enrollments: {semester_report['TotalEnrollments']}")
            print(f"Total Capacity: {semester_report['TotalCapacity']}")
            print(f"Total Enrolled: {semester_report['TotalEnrolled']}")
            print(f"Overall Fill Rate: {semester_report['OverallFillRate']}%")
        
        # Demonstration 7: Students at Risk
        print_header("Students at Risk (GPA < 2.5)")
        at_risk = reporting_ops.students_at_risk(2.5)
        print_table(at_risk)
        
        print_header("DEMONSTRATION COMPLETE")
        print("\nAll database operations executed successfully!")
        print("\nKey Features Demonstrated:")
        print("  [+] Student information retrieval")
        print("  [+] Transcript generation")
        print("  [+] GPA calculation")
        print("  [+] Course availability queries")
        print("  [+] Department statistics")
        print("  [+] Enrollment reporting")
        print("  [+] At-risk student identification")
        
    except Exception as e:
        print(f"\nError: {e}")
        import traceback
        traceback.print_exc()
    
    finally:
        db.disconnect()


if __name__ == "__main__":
    main()
