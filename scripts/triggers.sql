-- DATABASE TRIGGERS for Automated Business Logic
-- This file demonstrates various trigger implementations for the vehicle sales system

-- Example 1: Automatic pickup date setting
-- Function to automatically set pickup date to 7 days after purchase
CREATE OR REPLACE FUNCTION set_pickup_date() 
  RETURNS TRIGGER 
  LANGUAGE PlPGSQL
AS $$
BEGIN
  UPDATE 
	sales
  SET 
	pickup_date = NEW.purchase_date + INTERVAL '7 days'
  WHERE 
	sales.sale_id = NEW.sale_id;
  RETURN NULL;
END;
$$;

-- Trigger to execute pickup date function after each sale insert
CREATE OR REPLACE TRIGGER new_sale_made
  AFTER INSERT
  ON sales
  FOR EACH ROW
  EXECUTE PROCEDURE set_pickup_date();

-- Test the pickup date trigger
INSERT INTO sales(
	sales_type_id, 
	vehicle_id, 
	dealership_id, 
	price, 
	purchase_date
)
VALUES(1, 1, 1, 100000, CURRENT_DATE);

-- Verify the trigger worked correctly
SELECT * FROM sales WHERE vehicle_id = 1 AND price = 100000;

-- Exercise 1: Automatic purchase date setting trigger
-- Create a trigger that sets purchase date to 3 days from current date for new sales

-- Function to set purchase date to 3 days in the future
CREATE OR REPLACE FUNCTION set_purchase_date() 
  RETURNS TRIGGER 
  LANGUAGE PlPGSQL
AS $$
BEGIN
  UPDATE 
	sales
  SET 
	purchase_date = CURRENT_DATE + INTERVAL '3 days'
  WHERE 
	sales.sale_id = NEW.sale_id;
  RETURN NULL;
END;
$$;

-- Trigger to automatically set purchase date after sales record creation
CREATE OR REPLACE TRIGGER set_initial_purchase_date
AFTER INSERT
ON sales
FOR EACH ROW
EXECUTE PROCEDURE set_purchase_date();

-- Test the purchase date trigger
INSERT INTO sales(sales_type_id, vehicle_id, dealership_id, price)
	VALUES(1, 1, 1, 999999);

-- Verify the trigger set the purchase date correctly
SELECT * FROM sales WHERE sales.vehicle_id = 1 AND sales.price = 999999;

-- Exercise 2: Complex pickup date adjustment trigger
-- Create a trigger that adjusts pickup dates based on business rules when sales records are updated

-- Function to intelligently adjust pickup dates based on purchase date relationships
CREATE OR REPLACE FUNCTION adjust_pickup_date() 
	RETURNS TRIGGER
	LANGUAGE PlPGSQL
AS $$
BEGIN
	-- Adjust pickup date based on business logic
	UPDATE 
		sales
	SET 
		pickup_date = 
			CASE
				-- If pickup date is before or same as purchase date, add 7 days
				WHEN 
					NEW.pickup_date <= NEW.purchase_date 
						THEN NEW.pickup_date + INTERVAL '7 days'
				-- If pickup date is too close to purchase date (less than 7 days), add 4 days
				WHEN NEW.pickup_date > NEW.purchase_date 
					AND (NEW.pickup_date - NEW.purchase_date) < INTERVAL '7 days' 
						THEN NEW.pickup_date + INTERVAL '4 days'
				-- Otherwise, keep the pickup date as is
				ELSE 
					NEW.pickup_date
			END
	WHERE 
		sales.sale_id = NEW.sale_id;
	
	RETURN NULL;
END;
$$;

-- Trigger to execute pickup date adjustment on sales updates
CREATE OR REPLACE TRIGGER run_adjust_pickup_date
AFTER UPDATE
ON sales
FOR EACH ROW
EXECUTE PROCEDURE adjust_pickup_date();

-- Test the pickup date adjustment trigger
SELECT * FROM sales WHERE vehicle_id = 1 AND price = 100000;

-- Update pickup date to test the trigger logic
UPDATE sales 
SET pickup_date = '2025-03-01'
WHERE sale_id = 5002;

-- Advanced Exercise: Dealership data consistency triggers
-- Requirements:
-- 1. Ensure data consistency across all dealerships (Carnival company standard)
-- 2. Set default phone number (777-111-0305) if not provided
-- 3. Include state name in dealership tax ID for accounting purposes

-- Check existing dealership data structure
SELECT * FROM dealerships LIMIT 5;

-- Function to standardize website URLs for all dealerships
CREATE OR REPLACE FUNCTION new_website()
	RETURNS TRIGGER
	LANGUAGE PlPGSQL
AS $$
BEGIN
	-- Automatically generate standardized website URL based on business name
	NEW.website := 'http://www.carnivalcars.com/' || REPLACE(LOWER(NEW.business_name), ' ', '_');
    RETURN NEW;
END;
$$;

-- Trigger to standardize website URLs on insert or update
CREATE TRIGGER format_website
	BEFORE INSERT OR UPDATE
	ON dealerships
	FOR EACH ROW 
	EXECUTE PROCEDURE new_website();

-- Test the website formatting trigger
INSERT INTO dealerships(business_name, city, state, website)
VALUES('Carlsbad Caverns', 'Nashville', 'TN', 'http://www.website.com');

-- Verify the trigger modified the website URL
SELECT *
FROM dealerships d
WHERE d.dealership_id = (SELECT MAX(dealership_id) FROM dealerships);

-- Test updating dealership data
UPDATE dealerships
SET phone = '615-999-9998'
WHERE dealership_id = (SELECT MAX(dealership_id) FROM dealerships);