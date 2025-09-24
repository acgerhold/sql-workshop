-- CRUD OPERATIONS and Database Normalization
-- This file demonstrates Create, Read, Update, and Delete operations

-- Create normalized tables for vehicle data structure
-- These tables will help normalize the vehicle information by separating body types, makes, and models

-- Create table for vehicle body types (SUV, Sedan, Truck, etc.)
CREATE TABLE IF NOT EXISTS vehiclebodytype(
	vehicle_body_type_id SERIAL PRIMARY KEY,
	name VARCHAR(20)
);

-- Create table for vehicle manufacturers/makes (Ford, Toyota, Honda, etc.)
CREATE TABLE IF NOT EXISTS vehiclemake(
	vehicle_make_id SERIAL PRIMARY KEY,
	name VARCHAR(20)
);

-- Create table for vehicle models (Camry, F-150, Civic, etc.)
CREATE TABLE IF NOT EXISTS vehiclemodel(
	vehicle_model_id SERIAL PRIMARY KEY,
	name VARCHAR(20)
);

-- Populate vehiclemake table with distinct makes from existing vehicletypes table
INSERT INTO vehiclemake(name)
SELECT DISTINCT make FROM vehicletypes;

-- Query to view all vehicle makes
SELECT * FROM vehiclemake v;

-- Query to view all vehicle types
SELECT * FROM vehicletypes v;

-- Query to view all vehicle body types
SELECT * FROM vehiclebodytype v;

-- Update vehicletypes table to link with normalized vehiclebodytype table
UPDATE 
	vehicletypes 
SET 
	vehicle_body_type_id = (
		SELECT vehiclebodytype.vehicle_body_type_id 
		FROM vehiclebodytype 
		WHERE vehicletypes.body_type = vehiclebodytype.name
	);