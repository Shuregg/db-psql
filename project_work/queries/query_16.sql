-- 16. Получить список всех врачей и количество их пациентов
SELECT d.first_name, d.last_name, COUNT(v.patient_id) AS patient_count
FROM doctors d
JOIN visits v ON d.doctor_id = v.doctor_id
GROUP BY d.doctor_id;