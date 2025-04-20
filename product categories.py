import random
from faker import Faker
import mysql.connector
from datetime import datetime, timedelta
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

 