-- COMMON TABLE EXPRESSIONS (CTEs) Practice
-- This file demonstrates advanced SQL techniques using WITH clauses (CTEs)

-- 1
-- For the top 5 dealerships, provide a list of vehicle models and the number of that model sold for the specific dealership. 
-- The results should be ordered by the dealership and within the dealership, the number of vehicles sold for a given model from most to least.

WITH top_five_dealerships AS (
	SELECT 
		d.dealership_id, 
		d.business_name, 
		SUM(s.price) AS total_sale_amount, 
		COUNT(s.sale_id) AS total_num_of_sales
	FROM 
		dealerships d
	JOIN 
		sales s ON d.dealership_id = s.dealership_id
	GROUP BY 
		d.dealership_id, 
		d.business_name
	ORDER BY 
		total_sale_amount DESC, 
		total_num_of_sales DESC
	LIMIT 
		5
),
vehicles_with_details AS (
	SELECT 
		v.vehicle_id, 
		CONCAT(v2.make, ' ', v2.model) AS make_model
	FROM 
		vehicles v
	JOIN 
		vehicletypes v2 ON v.vehicle_type_id = v2.vehicle_type_id
)
SELECT 
	d.business_name, 
	vwd.make_model, 
	COUNT(s.sale_id) AS num_of_sales
FROM 
	dealerships d
JOIN 
	sales s ON d.dealership_id = s.dealership_id
JOIN 
	vehicles_with_details vwd ON s.vehicle_id = vwd.vehicle_id
JOIN 
	top_five_dealerships tfd ON d.dealership_id = tfd.dealership_id
GROUP BY 
	d.business_name, 
	make_model
ORDER BY 
	d.business_name, 
	num_of_sales DESC

-- 2 
-- Write a query that lists the top 5 dealerships. Include a column that indicates whether there were more sales or leases for that dealership.

WITH top_five_dealerships AS (
	SELECT 
		d.dealership_id, 
		d.business_name, 
		SUM(s.price) AS total_sale_amount, 
		COUNT(s.sale_id) AS total_num_of_sales
	FROM 
		dealerships d
	JOIN 
		sales s ON d.dealership_id = s.dealership_id
	GROUP BY 
		d.dealership_id, 
		d.business_name
	ORDER BY 
		total_sale_amount DESC, 
		total_num_of_sales DESC
	LIMIT 5
),
sales_with_details AS (
	SELECT 
		s.dealership_id,
	    COUNT(CASE WHEN st.sales_type_name LIKE 'Lease' THEN s.sale_id END) AS num_of_lease,
	    COUNT(CASE WHEN st.sales_type_name LIKE 'Purchase' THEN s.sale_id END) AS num_of_purchase
	FROM 
		sales s
	JOIN 
		salestypes st ON s.sales_type_id = st.sales_type_id
	GROUP BY 
		s.dealership_id
)
SELECT 
	tfd.business_name, 
	tfd.total_sale_amount, 
	tfd.total_num_of_sales, 
	(CASE WHEN num_of_lease > num_of_purchase THEN 'Lease' ELSE 'Purchase' END) AS more_lease_or_purchase
FROM 
	top_five_dealerships tfd
JOIN 
	sales_with_details st ON tfd.dealership_id = st.dealership_id
ORDER BY 
	total_sale_amount DESC, 
	total_num_of_sales DESC

-- 3
-- For all used cars, provide a query that returns the state the car was sold in and the number of sales.
-- Modify the query to return the 5 best states (sold the most).
-- Modify the query again to return the 5 worst states (sold the least).

-- Base query: All used car sales by state
WITH all_used_cars AS ( 
	SELECT 
		* 
	FROM 
		vehicles v
	JOIN 
		vehicletypes vt ON v.vehicle_type_id = vt.vehicle_type_id
	WHERE 
		v.is_sold = TRUE 
	AND 
		v.is_new = FALSE
)
SELECT 
	d.state, 
	COUNT(s.sale_id) AS num_of_sales
FROM 
	dealerships d
JOIN 
	sales s ON d.dealership_id = s.dealership_id
JOIN 
	all_used_cars auc ON s.vehicle_id = auc.vehicle_id
GROUP BY 
	d.state
ORDER BY 
	num_of_sales DESC;

-- Top 5 states with most used car sales
WITH all_used_cars AS ( 
	SELECT 
		* 
	FROM 
		vehicles v
	JOIN 
		vehicletypes vt ON v.vehicle_type_id = vt.vehicle_type_id
	WHERE 
		v.is_sold = TRUE 
	AND 
		v.is_new = FALSE
)
SELECT 
	d.state, 
	COUNT(s.sale_id) AS num_of_sales
FROM 
	dealerships d
JOIN 
	sales s ON d.dealership_id = s.dealership_id
JOIN 
	all_used_cars auc ON s.vehicle_id = auc.vehicle_id
GROUP BY 
	d.state
ORDER BY 
	num_of_sales DESC
LIMIT 5;

-- Bottom 5 states with least used car sales
WITH all_used_cars AS ( 
	SELECT 
		* 
	FROM 
		vehicles v
	JOIN 
		vehicletypes vt ON v.vehicle_type_id = vt.vehicle_type_id
	WHERE 
		v.is_sold = TRUE 
	AND 
		v.is_new = FALSE
)
SELECT 
	d.state, 
	COUNT(s.sale_id) AS num_of_sales
FROM 
	dealerships d
JOIN 
	sales s ON d.dealership_id = s.dealership_id
JOIN 
	all_used_cars auc ON s.vehicle_id = auc.vehicle_id
GROUP BY 
	d.state
ORDER BY 
	num_of_sales ASC
LIMIT 5;
