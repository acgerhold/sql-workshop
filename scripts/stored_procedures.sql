-- STORED PROCEDURES for Vehicle Management System
-- This file contains procedures for managing vehicle inventory, sales, and returns

-- 1. Procedure to add a new vehicle to the inventory
-- This procedure adds both vehicle type information and vehicle details
CREATE OR REPLACE PROCEDURE add_vehicle(
	IN 
		vin VARCHAR, 
		engine_type VARCHAR(25), 
		exterior_color VARCHAR(30), 
		interior_color VARCHAR(30), 
		floor_price INT, 
		msr_price INT, 
		miles_count INT, 
		year_of_car INT, 
		is_sold BOOL, 
		is_new BOOL,
		dealership_location_id INT, 
		body_type VARCHAR(30), 
		make VARCHAR(30), 
		model VARCHAR(30),
	OUT 
		new_vehicle_id INT
)
LANGUAGE plpgsql
AS 
$$
DECLARE
	vehicle_type_id_var INT;
BEGIN
	-- First, insert or get the vehicle type
	INSERT INTO vehicletypes(
		body_type, 
		make, 
		model
	) 
	VALUES (
		body_type, 
		make, 
		model
	)
	RETURNING vehicle_type_id INTO vehicle_type_id_var;
	
	-- Then insert the vehicle with the correct vehicle_type_id
	INSERT INTO vehicles(
		vin, 
		engine_type, 
		vehicle_type_id,
		exterior_color, 
		interior_color, 
		floor_price, 
		msr_price, 
		miles_count, 
		year_of_car, 
		is_sold, 
		is_new, 
		dealership_location_id
	) 
	VALUES (
		vin, 
		engine_type, 
		vehicle_type_id_var,
		exterior_color, 
		interior_color, 
		floor_price, 
		msr_price, 
		miles_count, 
		year_of_car, 
		is_sold, 
		is_new, 
		dealership_location_id
	)
	RETURNING 
		vehicle_id 
	INTO 
		new_vehicle_id;
END
$$;

-- Test the add_vehicle procedure
CALL add_vehicle('12ASV34AWHJ56789', 'V6', 'White', 'Tan', 12000, 15000, 150000, 2006, FALSE, FALSE, 1, 'Car', 'Acura', 'TSX');

-- Verify the vehicle was added correctly
SELECT * FROM vehicles WHERE vin = '12ASV34AWHJ56789';
SELECT * FROM vehicletypes;

-- Clean up: Drop the add_vehicle procedure when no longer needed
/*
DROP PROCEDURE add_vehicle(
	IN vin VARCHAR, engine_type VARCHAR(25), exterior_color VARCHAR(30), interior_color VARCHAR(30), floor_price INT, msr_price INT, miles_count INT, year_of_car INT, is_sold BOOL, is_new BOOL,
		dealership_location_id INT, body_type VARCHAR(30), make VARCHAR(30), model VARCHAR(30),
	OUT new_vehicle_id INT);
*/

-- VEHICLE SELLING AND RETURNING PROCEDURES
-- Requirements for selling:
	-- 1. Must update vehicle inventory when sale occurs
	-- 2. Must set the is_sold boolean on vehicles table to true
	
-- Procedure to mark a vehicle as sold
-- Updates the vehicle inventory status when a sale occurs
CREATE OR REPLACE PROCEDURE selling_vehicle_update(IN p_vehicle_id INT)
LANGUAGE 
	plpgsql
AS $$
BEGIN
	UPDATE 
		vehicles 
	SET 
		is_sold = TRUE
	WHERE 
		vehicle_id = p_vehicle_id;	
END
$$;

-- Test queries for selling procedure
SELECT * FROM vehicles;
CALL selling_vehicle_update(4);
SELECT * FROM vehicles WHERE vehicle_id = 4;

-- Clean up procedure when not needed
-- DROP PROCEDURE selling_vehicle_update(p_vehicle_id INT);

-- VEHICLE RETURN PROCEDURE
-- Requirements for returning a vehicle:
	-- 1. Must update sale record when vehicle is returned
	-- 2. The vehicle must be added back into the inventory (vehicles)
	-- 3. The sale_returned boolean must be set to true
	-- 4. Must perform oil change before adding vehicle back to inventory
	-- 5. Must log the oil change

-- Procedure to process vehicle returns
-- Handles the complete vehicle return process including oil change logging
CREATE OR REPLACE PROCEDURE returning_vehicle_update(IN p_vehicle_id INT)
LANGUAGE plpgsql
AS $$ 
DECLARE 
	v_latest_sale_id INT;
BEGIN
	-- Find the most recent sale for this vehicle
	SELECT 
		sale_id 
	INTO 
		v_latest_sale_id
	FROM 
		sales
	WHERE 
		vehicle_id = p_vehicle_id
	ORDER BY 
		purchase_date DESC
	LIMIT 1;

	-- Mark the sale as returned
	UPDATE 
		sales
	SET 
		sale_returned = TRUE
	WHERE 
		vehicle_id = p_vehicle_id
	AND 
		sale_id = v_latest_sale_id;

	-- Log the mandatory oil change for returned vehicles
	INSERT INTO oilchangelogs(
		date_occured, 
		vehicle_id
	)
	VALUES (
		CURRENT_DATE, 
		p_vehicle_id
	);

	-- Return the vehicle to available inventory
	UPDATE 
		vehicles
	SET 
		is_sold = FALSE
	WHERE 
		vehicle_id = p_vehicle_id;	
END
$$;

-- Test the vehicle return procedure
CALL returning_vehicle_update(3);

-- BONUS PROCEDURE: Complete Sales Record Creation
-- Procedure to create a complete sales record and update vehicle status
-- This procedure handles both the sales record creation and vehicle inventory update
CREATE OR REPLACE PROCEDURE add_sale_record(
	IN 
		sales_type_id INT, 
		p_vehicle_id INT, 
		employee_id INT, 
		customer_id INT, 
		dealership_id INT, 
		price INT, 
		deposit INT, 
		purchase_date DATE, 
		pickup_date DATE,
		invoice_number INT, 
		payment_method VARCHAR(200), 
		sale_returned BOOL
)
LANGUAGE plpgsql
AS $$
BEGIN
	-- Mark the vehicle as sold
	UPDATE 
		vehicles 
	SET 
		is_sold = TRUE
	WHERE 
		vehicle_id = p_vehicle_id;

	-- Create the sales record
	INSERT INTO sales(
		sales_type_id, 
		vehicle_id, 
		employee_id, 
		customer_id, 
		dealership_id, 
		price, 
		deposit, 
		purchase_date, 
		pickup_date, 
		invoice_number, 
		payment_method, 
		sale_returned
	)
	VALUES (
		sales_type_id, 
		p_vehicle_id, 
		employee_id, 
		customer_id, 
		dealership_id, 
		price, 
		deposit, 
		purchase_date, 
		pickup_date, 
		invoice_number, 
		payment_method, 
		sale_returned
	);		
END
$$;

-- Test the complete sales record procedure
CALL add_sale_record(1, 50, 2, 5, 1, 25000, 10000, CURRENT_DATE, CURRENT_DATE, 132245435345322, 'VISA', FALSE);

-- Verify the sale was recorded correctly
SELECT * FROM sales s ORDER BY sale_id DESC LIMIT 5; 