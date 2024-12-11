-- 6. Получить список всех курсов лечения и соответствующих лекарств
SELECT tc.visit_id, m.medication_name, tc.treatment_description, tc.dosage_mg, tc.times_per_day
FROM treatment_courses tc
JOIN medications m ON tc.medication_id = m.medication_id;
