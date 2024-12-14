-- 10. Представление для получения списка всех пациентов и их возраст
CREATE OR REPLACE VIEW patients_age_view AS
SELECT p.first_name, p.last_name, p.birth_date, EXTRACT(YEAR FROM AGE(p.birth_date)) AS age
FROM patients p;

-- 11. Представление для получения списка всех врачей и их пациентов, отсортированных по дате визита
CREATE OR REPLACE VIEW doctors_patients_sorted_view AS
SELECT d.first_name AS doctor_first_name, d.last_name AS doctor_last_name, p.first_name AS patient_first_name, p.last_name AS patient_last_name, v.visit_date
FROM doctors d
JOIN visits v ON d.doctor_id = v.doctor_id
JOIN patients p ON v.patient_id = p.patient_id
ORDER BY v.visit_date;

-- 12. Представление для получения списка всех комнат и количество коек в них
CREATE OR REPLACE VIEW rooms_beds_view AS
SELECT r.room_id, r.room_number, r.room_name, r.room_type, r.number_of_beds
FROM rooms r
WHERE r.room_type = 'ward';

-- 13. Представление для получения списка всех лекарств, которые скоро истекают (менее чем через месяц)
CREATE OR REPLACE VIEW expiring_medications_view AS
SELECT m.medication_name, m.expiration_date
FROM medications m
WHERE m.expiration_date < CURRENT_DATE + INTERVAL '1 month';

-- 14. Представление для получения списка всех пациентов, которые находятся в комнатах типа 'ward'
CREATE OR REPLACE VIEW patients_in_ward_rooms_view AS
SELECT p.first_name, p.last_name, r.room_number
FROM patients p
JOIN visits_rooms vr ON p.patient_id = vr.visit_id
JOIN rooms r ON vr.room_id = r.room_id
WHERE r.room_type = 'ward';

-- 15. Представление для получения списка всех врачей и количество их пациентов
CREATE OR REPLACE VIEW doctor_patient_count_view AS
SELECT d.first_name, d.last_name, COUNT(v.patient_id) AS patient_count
FROM doctors d
JOIN visits v ON d.doctor_id = v.doctor_id
GROUP BY d.doctor_id;

-- 16. Представление для получения списка всех диагнозов и количество пациентов с этими диагнозами
CREATE OR REPLACE VIEW diagnosis_patient_count_view AS
SELECT d.diagnosis_name, COUNT(p.patient_id) AS patient_count
FROM diagnoses d
JOIN patients p ON d.patient_id = p.patient_id
GROUP BY d.diagnosis_id;

-- 17. Представление для получения списка всех комнат и количество пациентов в них
CREATE OR REPLACE VIEW room_patient_count_view AS
SELECT r.room_number, COUNT(vr.visit_id) AS patient_count
FROM rooms r
JOIN visits_rooms vr ON r.room_id = vr.room_id
GROUP BY r.room_id;

-- 18. Представление для получения списка всех лекарств и количество курсов лечения, в которых они используются
CREATE OR REPLACE VIEW medication_treatment_count_view AS
SELECT m.medication_name, COUNT(tc.visit_id) AS treatment_count
FROM medications m
JOIN treatment_courses tc ON m.medication_id = tc.medication_id
GROUP BY m.medication_id;

-- 19. Представление для получения списка всех пациентов, которые находятся в комнатах и их диагнозы
CREATE OR REPLACE VIEW patients_rooms_diagnoses_view AS
SELECT p.first_name, p.last_name, r.room_number, d.diagnosis_name
FROM patients p
JOIN visits_rooms vr ON p.patient_id = vr.visit_id
JOIN rooms r ON vr.room_id = r.room_id
JOIN diagnoses d ON p.patient_id = d.patient_id;
