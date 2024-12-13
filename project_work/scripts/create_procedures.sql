CREATE OR REPLACE PROCEDURE add_patient(
    first_name VARCHAR,
    last_name VARCHAR,
    patronymic VARCHAR,
    birth_date DATE,
    gender GENDER_ENUM,
    phone_number VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO patients (first_name, last_name, patronymic, birth_date, gender, phone_number)
    VALUES (first_name, last_name, patronymic, birth_date, gender, phone_number);
END;
$$;

CREATE OR REPLACE PROCEDURE add_doctor(
    first_name VARCHAR,
    last_name VARCHAR,
    patronymic VARCHAR,
    position VARCHAR,
    department_id INT,
    is_doctor BOOLEAN
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO doctors (first_name, last_name, patronymic, position, department_id, is_doctor)
    VALUES (first_name, last_name, patronymic, position, department_id, is_doctor);
END;
$$;

CREATE OR REPLACE PROCEDURE add_diagnosis(
    diagnosis_name VARCHAR,
    doctor_id INT,
    patient_id INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO diagnoses (diagnosis_name, doctor_id, patient_id)
    VALUES (diagnosis_name, doctor_id, patient_id);
END;
$$;

CREATE OR REPLACE PROCEDURE add_visit(
    visit_date DATE,
    discharge_date DATE,
    patient_id INT,
    doctor_id INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO visits (visit_date, discharge_date, patient_id, doctor_id)
    VALUES (visit_date, discharge_date, patient_id, doctor_id);
END;
$$;

CREATE OR REPLACE PROCEDURE add_medication(
    medication_name VARCHAR,
    indications VARCHAR,
    form VARCHAR,
    production_date DATE,
    expiration_date DATE,
    price NUMERIC,
    amount INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO medications (medication_name, indications, form, production_date, expiration_date, price, amount)
    VALUES (medication_name, indications, form, production_date, expiration_date, price, amount);
END;
$$;
