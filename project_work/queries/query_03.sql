-- 3. Получить список всех визитов и соответствующих диагнозов
SELECT v.visit_id, v.visit_date, d.diagnosis_name
FROM visits v
JOIN visits_diagnoses vd ON v.visit_id = vd.visit_id
JOIN diagnoses d ON vd.diagnosis_id = d.diagnosis_id;