-- 9. Получить список всех диагнозов и соответствующих врачей
SELECT d.diagnosis_name, doc.first_name, doc.last_name
FROM diagnoses d
JOIN doctors doc ON d.doctor_id = doc.doctor_id;