-- JOIN and FILTERING Practice Queries
-- This file contains various examples of JOIN operations and WHERE clause filtering

-- 1. Basic dealership information query
-- Retrieve basic business information for all dealerships
SELECT 
	business_name, 
	city, 
	state, 
	website 
FROM 
	dealerships d;

-- 2. High-value sales query with customer and sales type information
-- Find all sales over $50,000 with customer details and sales type
SELECT 
	c.first_name, 
	c.last_name, 
	s.price, 
	s.purchase_date, 
	s2.sales_type_name 
FROM 
	sales s
LEFT JOIN 
	customers c ON s.customer_id = c.customer_id 
LEFT JOIN 
	salestypes s2 ON s.sales_type_id = s2.sales_type_id 
WHERE 
	s.price > 50000;

-- 3. Complex join showing vehicle, customer, employee, and dealership relationships
-- Retrieve detailed information about vehicles sold including all related parties
SELECT 
	v.vin, 
	c.first_name, 
	c.last_name, 
	e.first_name, 
	e.last_name, 
	d.business_name, 
	d.city, 
	d.state 
FROM 
	sales s
LEFT JOIN 
	customers c ON s.customer_id = c.customer_id 
LEFT JOIN 
	vehicles v ON s.vehicle_id = v.vehicle_id 
LEFT JOIN 
	dealershipemployees de ON s.employee_id = de.employee_id AND s.dealership_id = de.dealership_id
RIGHT JOIN 
	employees e ON de.employee_id = e.employee_id
LEFT JOIN 
	dealerships d ON s.dealership_id = d.dealership_id;

-- 4. Dealership employee roster
-- List all dealerships and their employees (if any)
SELECT 
	d.business_name, 
	CONCAT(e.first_name, ' ', e.last_name) AS name
FROM 
	dealerships d
LEFT JOIN 
	dealershipemployees d2 ON d.dealership_id = d2.dealership_id 
LEFT JOIN 
	employees e ON d2.employee_id = e.employee_id 
ORDER BY 
	d.business_name DESC;

-- 5. Filtered dealership employee query
-- Find employees at specific dealerships (filtered by business name patterns)
SELECT
	d.business_name, 
	e.first_name, 
	e.last_name 
FROM 
	dealerships d
LEFT JOIN 
	dealershipemployees d2 ON d.dealership_id = d2.dealership_id 
LEFT JOIN 
	employees e ON d2.employee_id = e.employee_id 
WHERE 
	d.business_name LIKE '%Christophe%' 
OR 
	d.business_name LIKE '%Andrysiak%'
OR 
	d.business_name LIKE '%Claypool%'
ORDER BY 
	d.business_name DESC; 

-- Additional Practice Queries

-- Distinct Chevrolet models available at Carnival
-- Get a unique list of all Chevrolet models (no duplicates)
SELECT 
	v.make, 
	v.model 
FROM 
	vehicletypes v 
WHERE 
	v.make ILIKE '%Chevrolet%'
GROUP BY 
	v.make, 
	v.model;

-- Employee dealership assignments
-- Find all dealerships where a specific employee (ID 3) works
SELECT DISTINCT
	e.employee_id,
	e.first_name || ' ' || e.last_name AS employee,
	d.business_name
FROM 
	employees e
LEFT JOIN 
	dealershipemployees de ON e.employee_id = de.employee_id
LEFT JOIN 
	dealerships d ON de.dealership_id = d.dealership_id
WHERE 
	e.employee_id = 3;

-- Dealership employee roster
-- List all employees working at dealerships (shows employee-dealership relationships)
SELECT 
	e.first_name,
	e.last_name,
	d2.business_name
FROM 
	employees e 
RIGHT JOIN 
	dealershipemployees d ON e.employee_id = d.employee_id
RIGHT JOIN 
	dealerships d2 ON d.dealership_id = d2.dealership_id;