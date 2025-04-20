import random
from faker import Faker
import mysql.connector
from datetime import datetime, timedelta
import time
from mysql.connector import Error

def create_connection():
    try:
        conn = mysql.connector.connect(
            host='localhost',
            user='root',
            password='Augengneiss@8189',
            database='greensproutorganicsdb',
        )
        print("MySQL connection established")
        return conn
    except Error as e:
        print(f"Error connecting to MySQL: {e}")
        return None

def create_departments(conn):
    if not conn:
        print("No database connection")
        return

    try:
        cursor = conn.cursor()
        
        # Verify table exists
        cursor.execute("SHOW TABLES LIKE 'departments'")
        if not cursor.fetchone():
            print("Creating departments table...")
            cursor.execute("""
                CREATE TABLE departments (
                    department_id INT AUTO_INCREMENT PRIMARY KEY,
                    department_name VARCHAR(50) NOT NULL,
                    budget DECIMAL(12,2)
                )
            """)
            conn.commit()
        
        # Insert data
        departments = [
            ('Executive', 500000),
            ('Finance', 300000),
            ('Human Resources', 250000),
            ('Marketing', 200000),
            ('Operations', 400000),
            ('Produce', 350000),
            ('Grocery', 300000),
            ('Deli/Bakery', 280000),
            ('Customer Service', 220000),
            ('Inventory', 270000),
            ('IT', 180000),
            ('Maintenance', 150000)
        ]
        
        cursor.executemany(
            "INSERT INTO departments (department_name, budget) VALUES (%s, %s)",
            departments
        )
        conn.commit()
        print(f"Inserted {cursor.rowcount} departments")
        
        # Verification
        cursor.execute("SELECT * FROM departments")
        for row in cursor.fetchall():
            print(row)
            
    except Error as e:
        print(f"Error: {e}")
        conn.rollback()
    finally:
        if cursor:
            cursor.close()

# Usage
conn = create_connection()
if conn:
    create_departments(conn)
    conn.close()