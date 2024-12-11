-- 10. Получить список всех визитов и соответствующих комнат
SELECT v.visit_id, v.visit_date, r.room_number
FROM visits v
JOIN visits_rooms vr ON v.visit_id = vr.visit_id
JOIN rooms r ON vr.room_id = r.room_id;