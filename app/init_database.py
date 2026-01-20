"""
Database Initialization Script
Creates and populates the university database.
"""

import sqlite3
import os
import sys


def initialize_database(db_path='university.db'):
    """
    Initialize the database by:
    1. Creating the schema
    2. Inserting sample data
    """
    
    # Get paths to SQL scripts
    script_dir = os.path.dirname(os.path.abspath(__file__))
    project_root = os.path.dirname(script_dir)
    schema_path = os.path.join(project_root, 'schema', 'create_schema.sql')
    data_path = os.path.join(project_root, 'sql', 'insert_sample_data.sql')
    
    # Remove existing database if it exists
    if os.path.exists(db_path):
        print(f"Removing existing database: {db_path}")
        os.remove(db_path)
    
    print(f"Creating new database: {db_path}")
    
    try:
        # Connect to database
        conn = sqlite3.connect(db_path)
        cursor = conn.cursor()
        
        # Enable foreign key constraints
        cursor.execute("PRAGMA foreign_keys = ON")
        
        # Execute schema creation script
        print("Creating database schema...")
        with open(schema_path, 'r', encoding='utf-8') as f:
            schema_script = f.read()
        cursor.executescript(schema_script)
        conn.commit()
        print("[+] Schema created successfully")
        
        # Execute data insertion script
        print("Inserting sample data...")
        with open(data_path, 'r', encoding='utf-8') as f:
            data_script = f.read()
        cursor.executescript(data_script)
        conn.commit()
        print("[+] Sample data inserted successfully")
        
        # Verify database creation
        cursor.execute("SELECT name FROM sqlite_master WHERE type='table'")
        tables = cursor.fetchall()
        print(f"\n[+] Database initialized with {len(tables)} tables:")
        for table in tables:
            cursor.execute(f"SELECT COUNT(*) FROM {table[0]}")
            count = cursor.fetchone()[0]
            print(f"  - {table[0]}: {count} records")
        
        conn.close()
        print(f"\n[+] Database initialization complete: {db_path}")
        return True
        
    except Exception as e:
        print(f"\n[!] Error initializing database: {e}")
        import traceback
        traceback.print_exc()
        return False


if __name__ == "__main__":
    # Allow custom database path from command line
    db_path = sys.argv[1] if len(sys.argv) > 1 else 'university.db'
    
    print("=" * 80)
    print("  UNIVERSITY DATABASE INITIALIZATION")
    print("=" * 80)
    
    success = initialize_database(db_path)
    
    if success:
        print("\nYou can now run the application:")
        print("  python database_app.py")
    else:
        print("\nInitialization failed. Please check the error messages above.")
        sys.exit(1)
