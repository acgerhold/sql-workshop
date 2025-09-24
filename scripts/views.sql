-- DATABASE VIEWS for Simplified Data Access
-- This file demonstrates creating various views to simplify complex queries and provide data abstraraction

-- 1. Vehicle catalog view
-- Create a view that lists all distinct vehicle body types, makes and models
CREATE OR REPLACE VIEW vehicle_details AS
	SELECT DISTINCT 
		body_type, 
		make, 
		model
	FROM 
		vehicletypes v
	ORDER BY 
		make, 
		model;
		
-- Test the vehicle details view
SELECT * FROM vehicle_details;

-- 2. Employee type summary view
-- Create a view that shows the total number of employees for each employee type
CREATE OR REPLACE VIEW employee_type_breakdown AS 
	SELECT 
		e2.employee_type_name AS employee_type, 
		COUNT(e.employee_id) AS num_of_employees 
	FROM 
		employees e 
	JOIN 
		employeetypes e2 ON e.employee_type_id = e2.employee_type_id
	GROUP BY 
		employee_type 
	ORDER BY 
		num_of_employees DESC;
	
-- Test the employee type breakdown view
SELECT * FROM employee_type_breakdown;

-- 3. Privacy-protected customer view
-- Create a view that lists customers without exposing sensitive personal information
CREATE OR REPLACE VIEW customer_details_short AS
	SELECT 
		CONCAT(c.first_name, ' ', c.last_name) AS customer_name, 
		CONCAT(c.city, ', ', c.state) AS location, 
		c.company_name
	FROM 
		customers c
	ORDER BY 
		customer_name;
	
-- Test the customer details view
SELECT * FROM customer_details_short;

-- 4. Annual sales summary view
-- Create a view that shows total sales by type for the year 2023
CREATE OR REPLACE VIEW sales2023 AS 
	SELECT 
		s2.sales_type_name AS sales_type, 
		COUNT(s.sale_id) AS num_of_sales
	FROM 
		sales s
	JOIN 
		salestypes s2 ON s.sales_type_id = s2.sales_type_id
	WHERE 
		EXTRACT(YEAR FROM s.purchase_date) = 2023
	GROUP BY 
		sales_type
	ORDER BY 
		num_of_sales DESC;
	
-- Test the 2023 sales summary view
SELECT * FROM sales2023;

-- GROUP PRACTICE EXERCISES

-- Advanced Exercise: Top performing employee per dealership
-- Create a view that shows the employee with the highest number of sales at each dealership

-- Original exploratory query (shows ranking logic)

SELECT 
	d.dealership_id, 
	d.business_name, 
	CONCAT(e.first_name, ' ', e.last_name) AS employee_name, 
	COUNT(s.sale_id) AS num_of_sales, 
	ROW_NUMBER() OVER (PARTITION BY d.dealership_id ORDER BY COUNT(s.sale_id) DESC) AS sales_rank
FROM 
	employees e
JOIN 
	sales s ON e.employee_id = s.employee_id
JOIN 
	dealerships d ON d.dealership_id = s.dealership_id
GROUP BY 
	d.dealership_id, 
	d.business_name, 
	employee_name
ORDER BY 
	d.business_name DESC, 
	sales_rank;


-- Step 1: Create base view with employee rankings by dealership
CREATE OR REPLACE VIEW top_employees AS 
    SELECT
        s.dealership_id,
        s.employee_id,
        e.first_name,
        e.last_name,
        COUNT(s.sale_id) AS total_sales,
        ROW_NUMBER() OVER (PARTITION BY s.dealership_id ORDER BY COUNT(s.sale_id) DESC) AS rank
    FROM 
    	sales s
    JOIN 
    	employees e ON s.employee_id = e.employee_id
    GROUP BY 
    	s.dealership_id, s.employee_id, e.first_name, e.last_name;
    
-- Step 2: Create final view showing only the top employee per dealership
CREATE OR REPLACE VIEW top_employees_by_dealership AS
	SELECT 
		d.dealership_id, 
		d.business_name, 
		CONCAT(te.first_name, ' ', te.last_name) AS employee_name, 
		te.total_sales
	FROM 
		dealerships d
	JOIN 
		top_employees te ON d.dealership_id = te.dealership_id
	WHERE 
		te.rank = 1
	ORDER BY 
		d.business_name;
	
-- Test the top employees by dealership view
SELECT * FROM top_employees_by_dealership;