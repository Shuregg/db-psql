-- ========= Custom data types =========

-- Room type enum
CREATE TYPE ROOM_TYPE_ENUM AS ENUM (
    'service',
    'ward',
    'reception',
    'procedural',
    'examination'
);

CREATE TYPE GENDER_ENUM AS ENUM (
    'male',
    'female'
);

-- ========= Tables =========

-- departments table
CREATE TABLE departments (
    department_id SERIAL PRIMARY KEY,
    department_name VARCHAR(50) NOT NULL UNIQUE,
    head_id INT,
    local_phone_number VARCHAR(4) NOT NULL UNIQUE,
    public_phone_number VARCHAR(11) UNIQUE
);

-- doctors table
CREATE TABLE doctors (
    doctor_id SERIAL PRIMARY KEY,
    first_name VARCHAR NOT NULL,
    last_name VARCHAR NOT NULL,
    patronymic VARCHAR,
    position VARCHAR NOT NULL,
    department_id INT,
    is_doctor BOOLEAN NOT NULL DEFAULT FALSE
);

-- Adding foreign key to departments table
ALTER TABLE departments
ADD CONSTRAINT fkey_head_id FOREIGN KEY (head_id) REFERENCES doctors(doctor_id);

-- Adding foreign key to doctors table
ALTER TABLE doctors
ADD CONSTRAINT fkey_department_id FOREIGN KEY (department_id) REFERENCES departments(department_id);

-- rooms table
CREATE TABLE rooms (
    room_id SERIAL PRIMARY KEY,
    department_id INT,
    room_number VARCHAR(10) NOT NULL UNIQUE,
    room_name VARCHAR NOT NULL,
    room_type ROOM_TYPE_ENUM NOT NULL,
    number_of_beds SMALLINT DEFAULT NULL,
    CONSTRAINT chk_number_of_beds CHECK (
        (room_type = 'ward' AND number_of_beds IS NOT NULL AND number_of_beds > 0) OR
        (room_type != 'ward' AND number_of_beds IS NULL)
    )
);

-- Adding foreign key to rooms table
ALTER TABLE rooms
ADD CONSTRAINT fkey_department_id FOREIGN KEY (department_id) REFERENCES departments(department_id);

-- Create table for patients
CREATE TABLE patients (
    patient_id SERIAL PRIMARY KEY,
    first_name VARCHAR NOT NULL,
    last_name VARCHAR NOT NULL,
    patronymic VARCHAR,
    birth_date DATE NOT NULL,
    gender GENDER_ENUM NOT NULL,
    phone_number VARCHAR(11) UNIQUE,
    registration_date DATE NOT NULL DEFAULT CURRENT_DATE,
    age INTEGER
);

-- diagnoses table
CREATE TABLE diagnoses (
    diagnosis_id SERIAL PRIMARY KEY,
    diagnosis_name VARCHAR NOT NULL,
    doctor_id INT,
    patient_id INT UNIQUE NOT NULL
);

-- Adding foreign keys to diagnoses table
ALTER TABLE diagnoses
ADD CONSTRAINT fkey_doctor_id FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id),
ADD CONSTRAINT fkey_patient_id FOREIGN KEY (patient_id) REFERENCES patients(patient_id);

-- visits table
CREATE TABLE visits (
    visit_id SERIAL PRIMARY KEY,
    visit_date DATE NOT NULL DEFAULT CURRENT_DATE,
    patient_id INTEGER NOT NULL,
    doctor_id INTEGER NOT NULL,
    diagnosis_id INT,
    FOREIGN KEY (patient_id) REFERENCES patients (patient_id) ON DELETE CASCADE,
    FOREIGN KEY (doctor_id) REFERENCES doctors (doctor_id) ON DELETE CASCADE
);

-- Create table for medications
CREATE TABLE medications (
    medication_id SERIAL PRIMARY KEY,
    medication_name VARCHAR NOT NULL,
    indications VARCHAR,
    form VARCHAR(50) NOT NULL,
    production_date DATE NOT NULL,
    expiration_date DATE NOT NULL,
    price NUMERIC(10, 2) NOT NULL,
    amount INT,
    CONSTRAINT production_date_less_than_expiration_date CHECK (production_date < expiration_date)
);

-- Create table for treatment_courses
CREATE TABLE treatment_courses (
    visit_id INT NOT NULL,
    medication_id INT NOT NULL,
    treatment_description TEXT,
    dosage_mg NUMERIC(5, 2) NOT NULL,          -- Dosage of the medication
    times_per_day INT NOT NULL,   -- Frequency of intake (e.g., 3 times/day)
    PRIMARY KEY (visit_id, medication_id),
    FOREIGN KEY (visit_id) REFERENCES visits(visit_id) ON DELETE CASCADE,
    FOREIGN KEY (medication_id) REFERENCES medications(medication_id) ON DELETE CASCADE
);

-- Create table for visits_diagnoses
CREATE TABLE visits_diagnoses (
    visit_id INT NOT NULL,
    diagnosis_id INT NOT NULL,
    PRIMARY KEY (visit_id, diagnosis_id),
    FOREIGN KEY (visit_id) REFERENCES visits(visit_id) ON DELETE CASCADE,
    FOREIGN KEY (diagnosis_id) REFERENCES diagnoses(diagnosis_id) ON DELETE CASCADE
);

-- Create table for visits_rooms
CREATE TABLE visits_rooms (
    visit_id INT NOT NULL,
    room_id INT NOT NULL,
    admission_date DATE NOT NULL DEFAULT CURRENT_DATE,
    discharge_date DATE,
    PRIMARY KEY (visit_id, room_id),
    FOREIGN KEY (visit_id) REFERENCES visits(visit_id) ON DELETE CASCADE,
    FOREIGN KEY (room_id) REFERENCES rooms(room_id) ON DELETE CASCADE
);

-- ========= Functions & Procedures =========

-- ========= Trigger functions & Triggers =========
-- Trigger function to calculate age
CREATE OR REPLACE FUNCTION calculate_age()
RETURNS TRIGGER AS
$$
BEGIN
    NEW.age := DATE_PART('year', AGE(NEW.birth_date));
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger for calculating age
CREATE TRIGGER update_age_trig
BEFORE INSERT OR UPDATE ON patients
FOR EACH ROW
EXECUTE FUNCTION calculate_age();

-- set_number_of_beds_null() Trigger Function
CREATE OR REPLACE FUNCTION set_number_of_beds_null()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.room_type != 'ward' THEN
        NEW.number_of_beds := NULL;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- set_number_of_beds_null_trig Trigger
CREATE TRIGGER set_number_of_beds_null_trig
BEFORE INSERT OR UPDATE ON rooms
FOR EACH ROW
EXECUTE FUNCTION set_number_of_beds_null();
