-- 2. Получить список всех пациентов и их диагнозов
SELECT p.first_name, p.last_name, d.diagnosis_name
FROM patients p
JOIN diagnoses d ON p.patient_id = d.patient_id;