-- Database Performance Optimization with Indexes
-- This file demonstrates creating a complex view and using indexes to improve query performance

-- Create a comprehensive view that joins multiple tables for sales reporting
CREATE OR REPLACE VIEW SALES_BY_EMPLOYEE AS
	SELECT
		s.employee_id,
		CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
		s.price AS purchase_price,
		s.purchase_date,
		s.pickup_date,
		s.deposit,
		CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
		d.business_name AS purchased_at,
		CONCAT(vt.make, ' ', vt.model) AS make_and_model,
		v.year_of_car,
		v.miles_count,
		v.vin
	FROM sales s
	JOIN employees e USING (employee_id)
	JOIN dealerships d USING (dealership_id)
	JOIN vehicles v USING (vehicle_id)
	JOIN vehicletypes vt USING (vehicle_type_id)
	JOIN customers c USING (customer_id);

-- Analyze query performance before creating indexes
EXPLAIN 
SELECT * FROM SALES_BY_EMPLOYEE 
ORDER BY employee_id, purchase_price, purchase_date, pickup_date, deposit, customer_name, purchased_at, make_and_model, year_of_car;

-- Create composite index on sales table for employee-related queries
CREATE INDEX index_employee_purchases
ON sales (employee_id, price, purchase_date, pickup_date, deposit);

-- Create index on employees table for name lookups
CREATE INDEX index_employees
ON employees (employee_id, first_name, last_name);

-- Create index on vehicles table for vehicle details (Note: vin is duplicated, should be cleaned)
CREATE INDEX index_vehicles
ON vehicles (vehicle_id, year_of_car, miles_count, vin);

-- Create index on vehicletypes table for make/model searches
CREATE INDEX index_vehicle_types
ON vehicletypes (make, model, vehicle_type_id);

-- Create index on dealerships table for business name searches
CREATE INDEX index_dealerships
ON dealerships (dealership_id, business_name);

-- Clean up: Drop all created indexes when no longer needed
DROP INDEX index_employee_purchases, index_employees, index_vehicles, index_vehicle_types, index_dealerships;

-- Clean up: Drop the view when no longer needed
DROP VIEW SALES_BY_EMPLOYEE;