import random
from faker import Faker
import mysql.connector
from datetime import datetime, timedelta
import time
from mysql.connector import Error

fake = Faker()

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
    
def create_stores():
    """Create and populate stores table"""
    conn = create_connection()
    if not conn:
        print("Cannot proceed without database connection")
        return

    try:
        cursor = conn.cursor()
        
        # Check if stores table exists
        cursor.execute("SHOW TABLES LIKE 'stores'")
        if not cursor.fetchone():
            print("Creating stores table...")
            cursor.execute("""
                CREATE TABLE stores (
                    store_id INT AUTO_INCREMENT PRIMARY KEY,
                    store_name VARCHAR(100) NOT NULL,
                    address VARCHAR(200) NOT NULL,
                    city VARCHAR(50) NOT NULL,
                    state VARCHAR(2) NOT NULL,
                    zip_code VARCHAR(10) NOT NULL,
                    phone VARCHAR(20),
                    email VARCHAR(100),
                    opening_date DATE NOT NULL,
                    square_footage INT,
                    manager_id INT NULL,
                    FOREIGN KEY (manager_id) REFERENCES employees(employee_id)
                )
            """)
            conn.commit()

        cities = [
            ('Portland', 'OR'), ('Seattle', 'WA'), ('Eugene', 'OR'),
            ('Boise', 'ID'), ('Spokane', 'WA'), ('Tacoma', 'WA'),
            ('Salem', 'OR'), ('Vancouver', 'WA'), ('Bend', 'OR'),
            ('Missoula', 'MT'), ('Ashland', 'OR'), ('Bellingham', 'WA')
        ]

        stores = []
        for city, state in cities:
            stores.append((
                f"{city} {fake.street_suffix()}",
                fake.street_address(),
                city,
                state,
                fake.zipcode_in_state(state),
                fake.numerify(text='(###) ###-####'),
                f"info.{city.lower()}@greensprout.com",
                fake.date_between(start_date='-8y', end_date='today'),
                random.randint(2000, 5000),
                None  # manager_id will be set later
            ))

        cursor.executemany(
            """INSERT INTO stores (store_name, address, city, state, zip_code, 
               phone, email, opening_date, square_footage, manager_id) 
               VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)""",
            stores
        )
        conn.commit()
        print(f"Successfully inserted {len(stores)} stores")

        # Verify insertion
        cursor.execute("SELECT store_id, store_name FROM stores")
        print("\nCurrent stores in database:")
        for store_id, store_name in cursor:
            print(f"{store_id}: {store_name}")

    except mysql.connector.Error as err:
        print(f"MySQL Error: {err}")
        conn.rollback()
    except Exception as e:
        print(f"Error: {e}")
    finally:
        if 'cursor' in locals():
            cursor.close()
        if conn.is_connected():
            conn.close()
            print("Database connection closed")

if __name__ == "__main__":
    create_stores()