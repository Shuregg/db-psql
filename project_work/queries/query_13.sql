-- 13. Получить список всех комнат и количество коек в них
SELECT r.room_id, r.room_number, r.room_name, r.room_type, r.number_of_beds
FROM rooms r
WHERE r.room_type = 'ward';