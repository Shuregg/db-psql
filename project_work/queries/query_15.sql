-- 15. Получить список всех пациентов, которые находятся в комнатах типа 'ward'
SELECT p.first_name, p.last_name, r.room_number
FROM patients p
JOIN visits_rooms vr ON p.patient_id = vr.visit_id
JOIN rooms r ON vr.room_id = r.room_id
WHERE r.room_type = 'ward';