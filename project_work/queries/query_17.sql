-- 17. Получить список всех диагнозов и количество пациентов с этими диагнозами
SELECT d.diagnosis_name, COUNT(p.patient_id) AS patient_count
FROM diagnoses d
JOIN patients p ON d.patient_id = p.patient_id
GROUP BY d.diagnosis_id;