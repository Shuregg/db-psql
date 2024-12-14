CREATE OR REPLACE PROCEDURE add_patient(
    IN first_name VARCHAR,
    IN last_name VARCHAR,
    IN patronymic VARCHAR,
    IN birth_date DATE,
    IN gender GENDER_ENUM,
    IN phone_number VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO patients (first_name, last_name, patronymic, birth_date, gender, phone_number)
    VALUES (first_name, last_name, patronymic, birth_date, gender, phone_number);
END;
$$;

CREATE OR REPLACE PROCEDURE add_doctor(
    IN first_name VARCHAR,
    IN last_name VARCHAR,
    IN patronymic VARCHAR,
    IN current_position VARCHAR,
    IN department_id INT,
    IN is_doctor BOOLEAN
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO doctors (first_name, last_name, patronymic, current_position, department_id, is_doctor)
    VALUES (first_name, last_name, patronymic, current_position, department_id, is_doctor);
END;
$$;

CREATE OR REPLACE PROCEDURE add_diagnosis(
    IN diagnosis_name VARCHAR,
    IN doctor_id INT,
    IN patient_id INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO diagnoses (diagnosis_name, doctor_id, patient_id)
    VALUES (diagnosis_name, doctor_id, patient_id);
END;
$$;

CREATE OR REPLACE PROCEDURE add_visit(
    IN visit_date DATE,
    IN discharge_date DATE,
    IN patient_id INT,
    IN doctor_id INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO visits (visit_date, discharge_date, patient_id, doctor_id)
    VALUES (visit_date, discharge_date, patient_id, doctor_id);
END;
$$;

CREATE OR REPLACE PROCEDURE add_medication(
    IN medication_name VARCHAR,
    IN indications VARCHAR,
    IN form VARCHAR,
    IN production_date DATE,
    IN expiration_date DATE,
    IN price NUMERIC,
    IN amount INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO medications (medication_name, indications, form, production_date, expiration_date, price, amount)
    VALUES (medication_name, indications, form, production_date, expiration_date, price, amount);
END;
$$;
