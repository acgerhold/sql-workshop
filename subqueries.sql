-- SUBQUERY PRACTICE EXERCISES
-- This file demonstrates various types of subqueries including correlated and scalar subqueries

-- 1. Find the total number of sales each employee made
-- Uses a correlated subquery to count sales for each employee
SELECT 
	CONCAT(e.first_name, ' ', e.last_name) AS employee_name, 
	(SELECT COUNT(*) FROM sales s WHERE s.employee_id = e.employee_id) AS num_of_sales
FROM 
	employees e
ORDER BY 
	num_of_sales ASC;

-- 2. Find the average sales amount for each employee
-- Uses a correlated subquery to calculate average sale price per employee
SELECT 
	CONCAT(e.first_name, ' ', e.last_name) AS employee_name, 
	(SELECT AVG(s.price) FROM sales s WHERE s.employee_id = e.employee_id) AS avg_sale_price
FROM 
	employees e
ORDER BY 
	avg_sale_price DESC;

-- 3. Return a list of sales where the sale price was lower than average
-- Uses scalar subquery to compare individual sales against overall average
SELECT 
	s.sale_id, 
	s.price,
	ROUND((SELECT AVG(s.price) FROM sales s), 2) AS avg_price_overall
FROM 
	sales s
WHERE 
	s.price < (SELECT AVG(s.price) FROM sales s)
ORDER BY 
	s.price DESC;

-- 4. Return a list of sales with employee details and their personal average
-- Combines JOIN with correlated subquery to show each sale with employee's average performance
SELECT 
	CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
	s.price,
	ROUND((SELECT AVG(s.price) FROM sales s WHERE s.employee_id = e.employee_id), 2) AS avg_sale_price
FROM 
	employees e
JOIN 
	sales s ON e.employee_id = s.employee_id
ORDER BY 
	employee_name;

-- GROUP ASSIGNMENT EXERCISES

-- 1. Return a list of employees and the number of sales they've made
-- Include employees who have not made any sales yet (shows 0)
SELECT 
	CONCAT(e.first_name, ' ', e.last_name) AS employee_name, 
	(SELECT COUNT(*) FROM sales s WHERE s.employee_id = e.employee_id) AS num_of_sales
FROM 
	employees e
ORDER BY 
	num_of_sales ASC;

-- 2. List vehicle pricing with make/model averages
-- Shows each vehicle's MSRP compared to the average MSRP for that specific make and model
SELECT 
	v.msr_price, 
	vt.make, 
	vt.model,
	(SELECT ROUND(AVG(v2.msr_price), 2) 
	 FROM vehicles v2 
	 JOIN vehicletypes vt2 ON v2.vehicle_type_id = vt2.vehicle_type_id 
	 WHERE vt2.make = vt.make AND vt2.model = vt.model) AS avg_msr_price_for_make_model
FROM 
	vehicles v 
JOIN 
	vehicletypes vt ON v.vehicle_type_id = vt.vehicle_type_id
LIMIT 
	200;