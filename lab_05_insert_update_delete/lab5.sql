CREATE TABLE debtor_students
(
    id SERIAL PRIMARY KEY,
    last_name VARCHAR(30) NOT NULL,
    first_name VARCHAR(30) NOT NULL,
    patronymic VARCHAR(30) NULL,
    group_id VARCHAR(7) NOT NULL,
    debt_number INTEGER NOT NULL
)

INSERT INTO debtor_students (last_name, first_name, patronymic, group_id, debt_number)
(
	SELECT last_name, first_name, patronymic, students_group_number, COUNT(*) AS "Number of debts" 
	FROM students
	INNER JOIN field_comprehensions ON field_comprehensions.student_id = students.student_id
	WHERE field_comprehensions.mark = 2
	GROUP BY last_name, first_name, patronymic, students_group_number
);

SELECT * FROM public.debtor_students
ORDER BY debt_number DESC

-- Task 1. The professor with the highest salary has quit.
-- Spread his salary equally among the professors who have the same position. Give the retired teacher a salary of 0.
-- If there are several professors with the highest salary, select the person with the minimum professor id.

-- 1.1 Check this professor
SELECT professor_id, current_position, salary
FROM professors
WHERE salary = (SELECT MAX(salary) FROM professors)
ORDER BY professor_id
LIMIT 1;

-- -- 1.2 Spread the salary
-- UPDATE professors
-- SET salary = salary + (
--     (
--         SELECT salary
--         FROM professors
--         WHERE professor_id = (
--             SELECT professor_id
--             FROM professors
--             WHERE salary = (SELECT MAX(salary) FROM professors)
--             ORDER BY professor_id
--             LIMIT 1
--         )
--     ) / 
--     (
--         SELECT COUNT(*)
--         FROM professors
--         WHERE current_position = (
--             SELECT current_position
--             FROM professors
--             WHERE professor_id = (
--                 SELECT professor_id
--                 FROM professors
--                 WHERE salary = (SELECT MAX(salary) FROM professors)
--                 ORDER BY professor_id
--                 LIMIT 1
--             )
--         ) AND professor_id != (
--             SELECT professor_id
--             FROM professors
--             WHERE salary = (SELECT MAX(salary) FROM professors)
--             ORDER BY professor_id
--             LIMIT 1
--         )
--     )
-- )
-- WHERE current_position = (
--     SELECT current_position
--     FROM professors
--     WHERE professor_id = (
--         SELECT professor_id
--         FROM professors
--         WHERE salary = (SELECT MAX(salary) FROM professors)
--         ORDER BY professor_id
--         LIMIT 1
--     )
-- ) AND professor_id != (
--     SELECT professor_id
--     FROM professors
--     WHERE salary = (SELECT MAX(salary) FROM professors)
--     ORDER BY professor_id
--     LIMIT 1
-- );

-- -- 1.3 Set salary to 0
-- UPDATE professors
-- SET salary = 0
-- WHERE professor_id = (
--     SELECT professor_id
--     FROM professors
--     WHERE salary = (SELECT MAX(salary) FROM professors)
--     ORDER BY professor_id
--     LIMIT 1
-- );

DO $$
DECLARE
    target_professor_id INT;
    target_position VARCHAR;
    target_salary MONEY;
    num_professors INT;
BEGIN

    -- Find professor with max salary, save his data
    SELECT professor_id, current_position, salary
    INTO target_professor_id, target_position, target_salary
    FROM professors
    WHERE salary = (SELECT MAX(salary) FROM professors)
    ORDER BY professor_id
    LIMIT 1;

    -- Set salary to 0
    UPDATE professors
    SET salary = 0
    WHERE professor_id = target_professor_id;

    -- Number of professors with the same position
    SELECT COUNT(*)
    INTO num_professors
    FROM professors
    WHERE current_position = target_position AND professor_id != target_professor_id;

    -- Spread
    UPDATE professors
    SET salary = salary + (target_salary / num_professors)
    WHERE current_position = target_position AND professor_id != target_professor_id;
    
END $$;

-- 1.4 Check results
SELECT professor_id, first_name, last_name, current_position, salary FROM public.professors
ORDER BY salary ASC 


-- Task 2. If a student have more than 4 debts, set his status to inactive.
UPDATE student_ids
SET status = 'inactive'
WHERE student_id IN (
    SELECT student_id
    FROM debtor_students
    WHERE debt_number > 4
);

SELECT * FROM public.student_ids
ORDER BY status DESC

-- Task 3. Add 10 new rows to the tables.
-- Добавление значений в таблицу debtor_students
INSERT INTO debtor_students (last_name, first_name, patronymic, group_id, debt_number)
VALUES
('Ivanov', 'Ivan', 'Ivanovich', 'ИВТ-22', 3),
('Petrova', 'Anna', 'Sergeevna', 'ПМ-21', 2),
('Sidorov', 'Petr', 'Alexeevich', 'ЭН-34', 5),
('Kuznetsova', 'Olga', 'Ivanovna', 'ИТД-12', 1),
('Smirnov', 'Alexey', 'Dmitrievich', 'УТС-41', 4),
('Nikolaeva', 'Maria', 'Petrovna', 'ИВТ-33', 6),
('Fedorov', 'Andrey', 'Vasilevich', 'ИВТ-33', 2),
('Alekseeva', 'Irina', 'Sergeevna', 'УТС-13', 3),
('Morozov', 'Yuriy', 'Aleksandrovich', 'Л-41', 5),
('Kozlov', 'Dmitry', 'Ivanovich', 'Д-22', 2);

-- Добавление значений в таблицу student_ids
INSERT INTO student_ids (student_id, issue_date, expiration_date, status)
VALUES
(1, '2023-09-01', '2027-06-30', 'active'),
(2, '2023-09-01', '2027-06-30', 'active'),
(3, '2023-09-01', '2027-06-30', 'active'),
(4, '2023-09-01', '2027-06-30', 'active'),
(5, '2023-09-01', '2027-06-30', 'active'),
(6, '2023-09-01', '2027-06-30', 'active'),
(7, '2023-09-01', '2027-06-30', 'active'),
(8, '2023-09-01', '2027-06-30', 'active'),
(9, '2023-09-01', '2027-06-30', 'active'),
(10, '2023-09-01', '2027-06-30', 'active');
