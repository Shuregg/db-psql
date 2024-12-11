-- 18. Получить список всех комнат и количество пациентов в них
SELECT r.room_number, COUNT(vr.visit_id) AS patient_count
FROM rooms r
JOIN visits_rooms vr ON r.room_id = vr.room_id
GROUP BY r.room_id;