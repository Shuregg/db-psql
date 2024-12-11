-- 14. Получить список всех лекарств, которые скоро истекают (менее чем через месяц)
SELECT m.medication_name, m.expiration_date
FROM medications m
WHERE m.expiration_date < CURRENT_DATE + INTERVAL '1 month';
