-- Create and select database
CREATE DATABASE IF NOT EXISTS inventory_db;
USE inventory_db;

-- Table: Suppliers
CREATE TABLE suppliers (
    supplier_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    contact VARCHAR(100),
    address TEXT
);

-- Table: Products
CREATE TABLE products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    category VARCHAR(50),
    quantity INT DEFAULT 0,
    price DECIMAL(10, 2),
    supplier_id INT,
    FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id)
        ON DELETE SET NULL
);

-- Table: Transactions
CREATE TABLE transactions (
    transaction_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT,
    transaction_type ENUM('IN', 'OUT') NOT NULL,
    quantity INT NOT NULL,
    transaction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(product_id)
        ON DELETE CASCADE
);

-- Stored Procedure: Add Stock
DELIMITER //
CREATE PROCEDURE add_stock(IN p_id INT, IN qty INT)
BEGIN
    UPDATE products SET quantity = quantity + qty WHERE product_id = p_id;
    INSERT INTO transactions (product_id, transaction_type, quantity)
    VALUES (p_id, 'IN', qty);
END;
//
DELIMITER ;

-- Stored Procedure: Reduce Stock
DELIMITER //
CREATE PROCEDURE reduce_stock(IN p_id INT, IN qty INT)
BEGIN
    DECLARE current_qty INT;

    SELECT quantity INTO current_qty FROM products WHERE product_id = p_id;

    IF current_qty >= qty THEN
        UPDATE products SET quantity = quantity - qty WHERE product_id = p_id;
        INSERT INTO transactions (product_id, transaction_type, quantity)
        VALUES (p_id, 'OUT', qty);
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Insufficient stock';
    END IF;
END;
//
DELIMITER ;

-- Stored Procedure: Get Low Stock Products
DELIMITER //
CREATE PROCEDURE get_low_stock_products(IN threshold INT)
BEGIN
    SELECT * FROM products WHERE quantity < threshold;
END;
//
DELIMITER ;

-- Sample Data: Suppliers
INSERT INTO suppliers (name, contact, address) VALUES
('Supplier A', '1234567890', '123 Street, City'),
('Supplier B', '0987654321', '456 Avenue, City');

-- Sample Data: Products
INSERT INTO products (name, category, quantity, price, supplier_id) VALUES
('Keyboard', 'Electronics', 10, 799.99, 1),
('Mouse', 'Electronics', 25, 299.99, 1),
('Chair', 'Furniture', 5, 1500.00, 2);

-- Stored Procedure: Get All Transactions
DELIMITER //
CREATE PROCEDURE get_all_transactions()
BEGIN
    SELECT 
        t.transaction_id,
        p.name AS product_name,
        t.transaction_type,
        t.quantity,
        t.transaction_date
    FROM transactions t
    JOIN products p ON t.product_id = p.product_id
    ORDER BY t.transaction_date DESC;
END;
//
DELIMITER ;