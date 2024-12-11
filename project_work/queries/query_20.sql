-- 20. Получить список всех пациентов, которые находятся в комнатах и их диагнозы
SELECT p.first_name, p.last_name, r.room_number, d.diagnosis_name
FROM patients p
JOIN visits_rooms vr ON p.patient_id = vr.visit_id
JOIN rooms r ON vr.room_id = r.room_id
JOIN diagnoses d ON p.patient_id = d.patient_id;