-- Запросы к базе данных

-- 1. Получить список всех врачей и их отделений
SELECT d.first_name, d.last_name, d.position, dept.department_name
FROM doctors d
JOIN departments dept ON d.department_id = dept.department_id;

-- 2. Получить список всех пациентов и их диагнозов
SELECT p.first_name, p.last_name, d.diagnosis_name
FROM patients p
JOIN diagnoses d ON p.patient_id = d.patient_id;

-- 3. Получить список всех визитов и соответствующих диагнозов
SELECT v.visit_id, v.visit_date, d.diagnosis_name
FROM visits v
JOIN visits_diagnoses vd ON v.visit_id = vd.visit_id
JOIN diagnoses d ON vd.diagnosis_id = d.diagnosis_id;

-- 4. Получить список всех комнат и их типов
SELECT r.room_id, r.room_number, r.room_name, r.room_type
FROM rooms r;

-- 5. Получить список всех лекарств и их информации
SELECT m.medication_name, m.indications, m.form, m.production_date, m.expiration_date, m.price, m.amount
FROM medications m;

-- 6. Получить список всех курсов лечения и соответствующих лекарств
SELECT tc.visit_id, m.medication_name, tc.treatment_description, tc.dosage_mg, tc.times_per_day
FROM treatment_courses tc
JOIN medications m ON tc.medication_id = m.medication_id;

-- 7. Получить список всех пациентов, находящихся в комнатах
SELECT p.first_name, p.last_name, r.room_number, vr.admission_date, vr.discharge_date
FROM patients p
JOIN visits_rooms vr ON p.patient_id = vr.visit_id
JOIN rooms r ON vr.room_id = r.room_id;

-- 8. Получить список всех врачей и их пациентов
SELECT d.first_name, d.last_name, p.first_name, p.last_name
FROM doctors d
JOIN visits v ON d.doctor_id = v.doctor_id
JOIN patients p ON v.patient_id = p.patient_id;

-- 9. Получить список всех диагнозов и соответствующих врачей
SELECT d.diagnosis_name, doc.first_name, doc.last_name
FROM diagnoses d
JOIN doctors doc ON d.doctor_id = doc.doctor_id;

-- 10. Получить список всех визитов и соответствующих комнат
SELECT v.visit_id, v.visit_date, r.room_number
FROM visits v
JOIN visits_rooms vr ON v.visit_id = vr.visit_id
JOIN rooms r ON vr.room_id = r.room_id;

-- 11. Получить список всех пациентов и их возраст
SELECT p.first_name, p.last_name, p.birth_date, p.age
FROM patients p;

-- 12. Получить список всех врачей и их пациентов, отсортированных по дате визита
SELECT d.first_name, d.last_name, p.first_name, p.last_name, v.visit_date
FROM doctors d
JOIN visits v ON d.doctor_id = v.doctor_id
JOIN patients p ON v.patient_id = p.patient_id
ORDER BY v.visit_date;

-- 13. Получить список всех комнат и количество коек в них
SELECT r.room_id, r.room_number, r.room_name, r.room_type, r.number_of_beds
FROM rooms r
WHERE r.room_type = 'ward';

-- 14. Получить список всех лекарств, которые скоро истекают (менее чем через месяц)
SELECT m.medication_name, m.expiration_date
FROM medications m
WHERE m.expiration_date < CURRENT_DATE + INTERVAL '1 month';

-- 15. Получить список всех пациентов, которые находятся в комнатах типа 'ward'
SELECT p.first_name, p.last_name, r.room_number
FROM patients p
JOIN visits_rooms vr ON p.patient_id = vr.visit_id
JOIN rooms r ON vr.room_id = r.room_id
WHERE r.room_type = 'ward';

-- 16. Получить список всех врачей и количество их пациентов
SELECT d.first_name, d.last_name, COUNT(v.patient_id) AS patient_count
FROM doctors d
JOIN visits v ON d.doctor_id = v.doctor_id
GROUP BY d.doctor_id;

-- 17. Получить список всех диагнозов и количество пациентов с этими диагнозами
SELECT d.diagnosis_name, COUNT(p.patient_id) AS patient_count
FROM diagnoses d
JOIN patients p ON d.patient_id = p.patient_id
GROUP BY d.diagnosis_id;

-- 18. Получить список всех комнат и количество пациентов в них
SELECT r.room_number, COUNT(vr.visit_id) AS patient_count
FROM rooms r
JOIN visits_rooms vr ON r.room_id = vr.room_id
GROUP BY r.room_id;

-- 19. Получить список всех лекарств и количество курсов лечения, в которых они используются
SELECT m.medication_name, COUNT(tc.visit_id) AS treatment_count
FROM medications m
JOIN treatment_courses tc ON m.medication_id = tc.medication_id
GROUP BY m.medication_id;

-- 20. Получить список всех пациентов, которые находятся в комнатах и их диагнозы
SELECT p.first_name, p.last_name, r.room_number, d.diagnosis_name
FROM patients p
JOIN visits_rooms vr ON p.patient_id = vr.visit_id
JOIN rooms r ON vr.room_id = r.room_id
JOIN diagnoses d ON p.patient_id = d.patient_id;

-- Представления (Views)

-- 1. Представление для получения списка всех врачей и их отделений
CREATE VIEW doctor_departments AS
SELECT d.first_name, d.last_name, d.position, dept.department_name
FROM doctors d
JOIN departments dept ON d.department_id = dept.department_id;

-- 2. Представление для получения списка всех пациентов и их диагнозов
CREATE VIEW patient_diagnoses AS
SELECT p.first_name, p.last_name, d.diagnosis_name
FROM patients p
JOIN diagnoses d ON p.patient_id = d.patient_id;

-- 3. Представление для получения списка всех визитов и соответствующих диагнозов
CREATE VIEW visit_diagnoses AS
SELECT v.visit_id, v.visit_date, d.diagnosis_name
FROM visits v
JOIN visits_diagnoses vd ON v.visit_id = vd.visit_id
JOIN diagnoses d ON vd.diagnosis_id = d.diagnosis_id;

-- 4. Представление для получения списка всех комнат и их типов
CREATE VIEW room_types AS
SELECT r.room_id, r.room_number, r.room_name, r.room_type
FROM rooms r;

-- 5. Представление для получения списка всех лекарств и их информации
CREATE VIEW medication_info AS
SELECT m.medication_name, m.indications, m.form, m.production_date, m.expiration_date, m.price, m.amount
FROM medications m;

-- 6. Представление для получения списка всех пациентов, находящихся в комнатах
CREATE VIEW patients_in_rooms AS
SELECT p.first_name, p.last_name, r.room_number, vr.admission_date, vr.discharge_date
FROM patients p
JOIN visits_rooms vr ON p.patient_id = vr.visit_id
JOIN rooms r ON vr.room_id = r.room_id;

-- 7. Представление для получения списка всех врачей и их пациентов
CREATE VIEW doctors_patients AS
SELECT d.first_name, d.last_name, p.first_name, p.last_name
FROM doctors d
JOIN visits v ON d.doctor_id = v.doctor_id
JOIN patients p ON v.patient_id = p.patient_id;

-- 8. Представление для получения списка всех диагнозов и соответствующих врачей
CREATE VIEW diagnoses_doctors AS
SELECT d.diagnosis_name, doc.first_name, doc.last_name
FROM diagnoses d
JOIN doctors doc ON d.doctor_id = doc.doctor_id;

-- 9. Представление для получения списка всех визитов и соответствующих комнат
CREATE VIEW visits_rooms_info AS
SELECT v.visit_id, v.visit_date, r.room_number
FROM visits v
JOIN visits_rooms vr ON v.visit_id = vr.visit_id
JOIN rooms r ON vr.room_id = r.room_id;

-- 10. Представление для получения списка всех пациентов и их возраст
CREATE VIEW patients_age AS
SELECT p.first_name, p.last_name, p.birth_date, EXTRACT(YEAR FROM AGE(p.birth_date)) AS age
FROM patients p;

-- 11. Представление для получения списка всех врачей и их пациентов, отсортированных по дате визита
CREATE VIEW doctors_patients_sorted AS
SELECT d.first_name, d.last_name, p.first_name, p.last_name, v.visit_date
FROM doctors d
JOIN visits v ON d.doctor_id = v.doctor_id
JOIN patients p ON v.patient_id = p.patient_id
ORDER BY v.visit_date;

-- 12. Представление для получения списка всех комнат и количество коек в них
CREATE VIEW rooms_beds AS
SELECT r.room_id, r.room_number, r.room_name, r.room_type, r.number_of_beds
FROM rooms r
WHERE r.room_type = 'ward';

-- 13. Представление для получения списка всех лекарств, которые скоро истекают (менее чем через месяц)
CREATE VIEW expiring_medications AS
SELECT m.medication_name, m.expiration_date
FROM medications m
WHERE m.expiration_date < CURRENT_DATE + INTERVAL '1 month';

-- 14. Представление для получения списка всех пациентов, которые находятся в комнатах типа 'ward'
CREATE VIEW patients_in_ward_rooms AS
SELECT p.first_name, p.last_name, r.room_number
FROM patients p
JOIN visits_rooms vr ON p.patient_id = vr.visit_id
JOIN rooms r ON vr.room_id = r.room_id
WHERE r.room_type = 'ward';

-- 15. Представление для получения списка всех врачей и количество их пациентов
CREATE VIEW doctor_patient_count AS
SELECT d.first_name, d.last_name, COUNT(v.patient_id) AS patient_count
FROM doctors d
JOIN visits v ON d.doctor_id = v.doctor_id
GROUP BY d.doctor_id;

-- 16. Представление для получения списка всех диагнозов и количество пациентов с этими диагнозами
CREATE VIEW diagnosis_patient_count AS
SELECT d.diagnosis_name, COUNT(p.patient_id) AS patient_count
FROM diagnoses d
JOIN patients p ON d.patient_id = p.patient_id
GROUP BY d.diagnosis_id;

-- 17. Представление для получения списка всех комнат и количество пациентов в них
CREATE VIEW room_patient_count AS
SELECT r.room_number, COUNT(vr.visit_id) AS patient_count
FROM rooms r
JOIN visits_rooms vr ON r.room_id = vr.room_id
GROUP BY r.room_id;

-- 18. Представление для получения списка всех лекарств и количество курсов лечения, в которых они используются
CREATE VIEW medication_treatment_count AS
SELECT m.medication_name, COUNT(tc.visit_id) AS treatment_count
FROM medications m
JOIN treatment_courses tc ON m.medication_id = tc.medication_id
GROUP BY m.medication_id;

-- 19. Представление для получения списка всех пациентов, которые находятся в комнатах и их диагнозы
CREATE VIEW patients_rooms_diagnoses AS
SELECT p.first_name, p.last_name, r.room_number, d.diagnosis_name
FROM patients p
JOIN visits_rooms vr ON p.patient_id = vr.visit_id
JOIN rooms r ON vr.room_id = r.room_id
JOIN diagnoses d ON p.patient_id = d.patient_id;
