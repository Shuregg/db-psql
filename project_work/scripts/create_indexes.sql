-- Индексирование пациентов по фамилии
CREATE INDEX idx_patients_last_name ON patients (last_name);
-- Индексирование пациентов по id
CREATE INDEX idx_patients_patient_id ON patients (patient_id);

-- Индексирование врачей по фамилии
CREATE INDEX idx_doctors_last_name ON doctors (last_name);
-- Индексирование врачей по id
CREATE INDEX idx_doctors_doctor_id ON doctors (last_name);

-- Индексирование посещений по id пациента
CREATE INDEX idx_visits_patient_id ON visits (patient_id);
-- Индексирование посещений по дате посещения
CREATE INDEX idx_visits_visit_date ON visits (visit_date);

-- Индексирование медикаментов по названию
CREATE INDEX idx_medications_medication_name ON medications (medication_name);
-- Индексирование медикаментов по сроку годности
CREATE INDEX idx_medications_expiration_date ON medications (expiration_date);
