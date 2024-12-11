-- 19. Получить список всех лекарств и количество курсов лечения, в которых они используются
SELECT m.medication_name, COUNT(tc.visit_id) AS treatment_count
FROM medications m
JOIN treatment_courses tc ON m.medication_id = tc.medication_id
GROUP BY m.medication_id;