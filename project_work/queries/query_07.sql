-- 7. Получить список всех пациентов, находящихся в комнатах
SELECT p.first_name, p.last_name, r.room_number, vr.admission_date, vr.discharge_date
FROM patients p
JOIN visits_rooms vr ON p.patient_id = vr.visit_id
JOIN rooms r ON vr.room_id = r.room_id;