-- 7. Получить список всех пациентов, находящихся в комнатах
SELECT p.first_name, p.last_name, r.room_number, v.visit_date AS admission_date, v.discharge_date
FROM patients p
JOIN visits v ON p.patient_id = v.patient_id
JOIN visits_rooms vr ON v.visit_id = vr.visit_id
JOIN rooms r ON vr.room_id = r.room_id;
