-- 5. Получить список всех лекарств и их информации
SELECT m.medication_name, m.indications, m.form, m.production_date, m.expiration_date, m.price, m.amount
FROM medications m;