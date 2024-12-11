-- 1. Получить список всех врачей и их отделений
SELECT d.first_name, d.last_name, d.position, dept.department_name
FROM doctors d
JOIN departments dept ON d.department_id = dept.department_id;
