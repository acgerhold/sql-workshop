-- TRANSACTION MANAGEMENT EXAMPLES
-- This file demonstrates PostgreSQL transaction control, error handling, and rollback scenarios

-- Example 1: Basic transaction structure with error handling (template/incomplete)
/*
DO $$
DECLARE
	catid INTEGER;
BEGIN
	-- Transaction logic would go here
	-- CREATE TABLE statements
	-- INSERT statements
	-- IF conditions for validation
	-- IF validation_fails THEN ROLLBACK; END IF;
	COMMIT;

EXCEPTION WHEN OTHERS THEN
	RAISE INFO 'Error: %', SQLERRM;
	ROLLBACK;
END $$;
*/

-- Example 2: Simple transaction with savepoints
BEGIN;

-- Insert a new sales type
INSERT INTO salestypes(sales_type_name)
VALUES('Lease to Own');

-- Create a savepoint before potentially problematic operation
SAVEPOINT before_employee_insert;

-- This insert may fail due to table structure
-- INSERT INTO employees(name) VALUES('Accountant');

-- Roll back to savepoint if needed
ROLLBACK TO SAVEPOINT before_employee_insert;

COMMIT;



-- Example 3: Complex transaction - Adding mechanics to multiple dealerships
-- This demonstrates conditional logic, CTEs within transactions, and error handling
BEGIN;

DO $$
DECLARE
    mechanic_type_id INT;
BEGIN
    -- Check if 'Automotive Mechanic' employee type exists, create if not
    IF NOT EXISTS (SELECT 1 FROM employeetypes WHERE employee_type_name = 'Automotive Mechanic') THEN
        INSERT INTO employeetypes (employee_type_name)
        VALUES ('Automotive Mechanic')
        RETURNING employee_type_id INTO mechanic_type_id;
    ELSE
        SELECT employee_type_id INTO mechanic_type_id
        FROM employeetypes
        WHERE employee_type_name = 'Automotive Mechanic';
    END IF;

    -- Use CTE to insert multiple mechanics and then assign them to dealerships
    WITH new_mechanics AS (
        INSERT INTO employees (first_name, last_name, employee_type_id)
        VALUES 
            ('Mechanic', 'One', mechanic_type_id),
            ('Mechanic', 'Two', mechanic_type_id),
            ('Mike', 'Three', mechanic_type_id),
            ('Emma', 'Four', mechanic_type_id),
            ('Mechanic', 'Five', mechanic_type_id)
        RETURNING employee_id
    )
    -- Assign each new mechanic to multiple dealerships
    INSERT INTO dealershipemployees (dealership_id, employee_id)
    SELECT d.dealership_id, nm.employee_id
    FROM new_mechanics nm
    CROSS JOIN (
        SELECT dealership_id
        FROM dealerships
        WHERE business_name IN ('Meeler Autos of San Diego', 'Meadley Autos of California', 'Major Autos of Florida')
    ) d;

EXCEPTION WHEN OTHERS THEN
    RAISE INFO 'Error occurred: %', SQLERRM;
    ROLLBACK;
    RETURN;
END $$;

COMMIT;
-- Example 4: Adding new vehicle type and multiple vehicles in a transaction
-- This shows how to use RETURNING clause to get generated IDs for related inserts

-- Check current vehicles (for comparison)
SELECT * FROM vehicles ORDER BY vehicle_id DESC LIMIT 5;

-- Transaction to add Honda CR-V vehicles
DO $$
DECLARE 
	cuv_id INT;
BEGIN
	-- First, add the vehicle type and capture its ID
	INSERT INTO vehicletypes(body_type, make, model)
	VALUES ('CUV', 'Honda', 'CR-V')
	RETURNING vehicle_type_id INTO cuv_id;

	-- Then add multiple vehicles of this type
	INSERT INTO vehicles(vin, engine_type, vehicle_type_id, exterior_color, interior_color, floor_price, msr_price, miles_count, year_of_car, is_sold, is_new, dealership_location_id)
	VALUES 
	    ('1HGCM82633A123456', 'I4', cuv_id, 'Lilac', 'Beige', 21755, 18999, 0, 2021, FALSE, TRUE, 1),
	    ('5XYZH4AG4DH678901', 'I4', cuv_id, 'Dark Red', 'Beige', 21755, 18999, 0, 2021, FALSE, TRUE, 1),
	    ('2T1BU4EE5CC234567', 'I4', cuv_id, 'Lime', 'Beige', 21755, 18999, 0, 2021, FALSE, TRUE, 1),
	    ('WAUZZZ8K9DA345678', 'I4', cuv_id, 'Navy', 'Beige', 21755, 18999, 0, 2021, FALSE, TRUE, 1),
	    ('3VWFE21C04M456789', 'I4', cuv_id, 'Sand', 'Beige', 21755, 18999, 0, 2021, FALSE, TRUE, 1);

EXCEPTION WHEN OTHERS THEN 
	RAISE INFO 'Error occurred: %', SQLERRM;
	ROLLBACK;
	RETURN;
END $$;

-- Verify the vehicle types were added
SELECT * FROM vehicletypes ORDER BY vehicle_type_id DESC LIMIT 5; 


-- Example 5: Bulk updates within a transaction
-- Updates multiple vehicle records with different criteria and proper error handling
DO $$
BEGIN
	-- Update specific Mazda models (CX-5, CX-9) to 2021 with new interior
	UPDATE vehicles
	SET year_of_car = 2021,
	    interior_color = 'Red/Black'
	WHERE is_sold = FALSE
	  AND vehicle_type_id IN (
	    SELECT vehicle_type_id
	    FROM vehicletypes vt
	    WHERE vt.model IN ('CX-5', 'CX-9')
	  );

	-- Update other Mazda models to 2020
	UPDATE vehicles
	SET year_of_car = 2020
	WHERE is_sold = FALSE
	  AND vehicle_type_id IN (
	    SELECT vehicle_type_id
	    FROM vehicletypes vt
	    WHERE vt.make LIKE 'Mazda%'
	      AND vt.model NOT IN ('CX-5', 'CX-9')
	  );
	
EXCEPTION WHEN OTHERS THEN
	RAISE INFO 'Error during bulk update: %', SQLERRM;
	ROLLBACK;
	RETURN;
END
$$ LANGUAGE plpgsql;