-- 8. Получить список всех врачей и их пациентов
SELECT d.first_name, d.last_name, p.first_name, p.last_name
FROM doctors d
JOIN visits v ON d.doctor_id = v.doctor_id
JOIN patients p ON v.patient_id = p.patient_id;