CREATE DATABASE IF NOT EXISTS GreenSproutOrganicsDB;
USE GreenSproutOrganicsDB;

-- Enable foreign key checks
SET FOREIGN_KEY_CHECKS = 1;

-- Create tables without foreign key dependencies first
CREATE TABLE IF NOT EXISTS product_categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(50) NOT NULL,
    description TEXT,
    parent_category_id INT
);

CREATE TABLE IF NOT EXISTS suppliers (
    supplier_id INT AUTO_INCREMENT PRIMARY KEY,
    supplier_name VARCHAR(100) NOT NULL,
    contact_name VARCHAR(100),
    email VARCHAR(100),
    phone VARCHAR(20),
    address VARCHAR(200),
    city VARCHAR(50),
    state VARCHAR(2),
    zip_code VARCHAR(10),
    certification_status VARCHAR(50),
    partnership_start_date DATE
);

CREATE TABLE IF NOT EXISTS stores (
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
    manager_id INT
);

CREATE TABLE IF NOT EXISTS departments (
    department_id INT AUTO_INCREMENT PRIMARY KEY,
    department_name VARCHAR(50) NOT NULL,
    manager_id INT,
    budget DECIMAL(12,2)
);

-- Create tables with dependencies
CREATE TABLE IF NOT EXISTS employees (
    employee_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    hire_date DATE NOT NULL,
    job_title VARCHAR(100) NOT NULL,
    department_id INT,
    salary DECIMAL(10,2),
    manager_id INT,
    store_id INT,
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'on_leave', 'terminated')),
    FOREIGN KEY (department_id) REFERENCES departments(department_id),
    FOREIGN KEY (manager_id) REFERENCES employees(employee_id),
    FOREIGN KEY (store_id) REFERENCES stores(store_id)
);

-- Now add the foreign keys that were deferred
ALTER TABLE stores ADD CONSTRAINT fk_store_manager 
    FOREIGN KEY (manager_id) REFERENCES employees(employee_id);
    
ALTER TABLE departments ADD CONSTRAINT fk_department_manager 
    FOREIGN KEY (manager_id) REFERENCES employees(employee_id);

CREATE TABLE IF NOT EXISTS customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(20),
    address VARCHAR(200),
    city VARCHAR(50),
    state VARCHAR(2),
    zip_code VARCHAR(10),
    loyalty_member BOOLEAN DEFAULT FALSE,
    member_since DATE,
    preferred_store_id INT,
    FOREIGN KEY (preferred_store_id) REFERENCES stores(store_id)
);

CREATE TABLE IF NOT EXISTS products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    description TEXT,
    category_id INT,
    supplier_id INT,
    unit_price DECIMAL(10,2) NOT NULL,
    cost DECIMAL(10,2) NOT NULL,
    weight DECIMAL(8,2),
    organic BOOLEAN DEFAULT TRUE,
    fair_trade BOOLEAN DEFAULT FALSE,
    discontinued BOOLEAN DEFAULT FALSE,
    date_added DATE DEFAULT (CURRENT_DATE),
    FOREIGN KEY (category_id) REFERENCES product_categories(category_id),
    FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id)
);

CREATE TABLE IF NOT EXISTS inventory (
    inventory_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT,
    store_id INT,
    quantity_in_stock INT NOT NULL,
    reorder_level INT,
    last_restocked DATE,
    aisle_location VARCHAR(20),
    shelf_location VARCHAR(20),
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    FOREIGN KEY (store_id) REFERENCES stores(store_id)
);

CREATE TABLE IF NOT EXISTS purchases (
    purchase_id INT AUTO_INCREMENT PRIMARY KEY,
    supplier_id INT,
    order_date DATE NOT NULL,
    expected_delivery_date DATE,
    actual_delivery_date DATE,
    status VARCHAR(20) NOT NULL,
    total_cost DECIMAL(12,2) NOT NULL,
    payment_terms VARCHAR(50),
    approved_by INT,
    FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id),
    FOREIGN KEY (approved_by) REFERENCES employees(employee_id)
);

CREATE TABLE IF NOT EXISTS purchase_items (
    purchase_item_id INT AUTO_INCREMENT PRIMARY KEY,
    purchase_id INT,
    product_id INT,
    quantity INT NOT NULL,
    unit_cost DECIMAL(10,2) NOT NULL,
    total_cost DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (purchase_id) REFERENCES purchases(purchase_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE TABLE IF NOT EXISTS sales (
    sale_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    store_id INT,
    employee_id INT,
    sale_date TIMESTAMP NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL,
    tax DECIMAL(10,2) NOT NULL,
    total DECIMAL(10,2) NOT NULL,
    payment_method VARCHAR(20) NOT NULL,
    loyalty_points_earned INT DEFAULT 0,
    loyalty_points_redeemed INT DEFAULT 0,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (store_id) REFERENCES stores(store_id),
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);

CREATE TABLE IF NOT EXISTS sale_items (
    sale_item_id INT AUTO_INCREMENT PRIMARY KEY,
    sale_id INT,
    product_id INT,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    discount DECIMAL(10,2) DEFAULT 0,
    total_price DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (sale_id) REFERENCES sales(sale_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE TABLE IF NOT EXISTS loyalty_program (
    loyalty_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT UNIQUE,
    points_balance INT DEFAULT 0,
    membership_tier VARCHAR(20) DEFAULT 'Basic' CHECK (membership_tier IN ('Basic', 'Silver', 'Gold', 'Platinum')),
    join_date DATE NOT NULL,
    last_activity_date DATE,
    lifetime_points_earned INT DEFAULT 0,
    lifetime_points_redeemed INT DEFAULT 0,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE IF NOT EXISTS marketing_campaigns (
    campaign_id INT AUTO_INCREMENT PRIMARY KEY,
    campaign_name VARCHAR(100) NOT NULL,
    description TEXT,
    start_date DATE NOT NULL,
    end_date DATE,
    budget DECIMAL(10,2),
    target_audience VARCHAR(100),
    channel VARCHAR(50) NOT NULL CHECK (channel IN ('Email', 'Social Media', 'In-Store', 'Direct Mail', 'SMS')),
    status VARCHAR(20) DEFAULT 'Planning' CHECK (status IN ('Planning', 'Active', 'Completed', 'Cancelled'))
);

CREATE TABLE IF NOT EXISTS customer_feedback (
    feedback_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    store_id INT,
    feedback_type VARCHAR(30) NOT NULL CHECK (feedback_type IN ('Compliment', 'Complaint', 'Suggestion', 'Question')),
    feedback_text TEXT NOT NULL,
    submission_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    rating INT CHECK (rating BETWEEN 1 AND 5),
    status VARCHAR(20) DEFAULT 'New' CHECK (status IN ('New', 'In Review', 'Resolved', 'Follow Up')),
    assigned_to INT,
    resolution_notes TEXT,
    resolution_date TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (store_id) REFERENCES stores(store_id),
    FOREIGN KEY (assigned_to) REFERENCES employees(employee_id)
);