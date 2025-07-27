-- Database initialization script for Expense Tracker
--Create expenses table
CREATE TABLE IF NOT EXISTS expenses(
    expense_id SERIAL PRIMARY KEY,
    title VARCHAR(30) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    category VARCHAR(30) NOT NULL,
    essential BOOLEAN NOT NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);
INSERT INTO expenses (title,price,category,essential,created_at) VALUES
('Groceries', 85.50, 'Food',true, CURRENT_TIMESTAMP);

--verify data
SELECT * FROM expenses;

-- Show table structure
\d expenses;
