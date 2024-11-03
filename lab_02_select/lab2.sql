
-- 2.1.  Задание 1
-- Исследование типов данных
-- Предположим, что в магазине новый конструктор стоит 999 рублей и 99 копеек.
-- Студент С. решил приобрести для дальнейшей перепродажи 100000 таких товаров.
-- Для расчета общей суммы, которую необходимо заплатить был создан следующий
-- скрипт на языке PL/pgSQL.
-- Более подробно о нём будет рассказано в одной из следующих лабораторных работ.
-- Обратите внимание, что значение суммы имеет тип real. 
DO
$$
DECLARE
    summ_real 		real			:= 0.0;
	summ_money 		money 			:= 0.0;
	summ_numeric 	numeric(10, 2) 	:= 0.0;
BEGIN
    FOR i IN 1..100000 LOOP
    	summ_real 	 := summ_real 	 + 999.99::real;
		summ_money 	 := summ_money 	 + 999.99::money;
		summ_numeric := summ_numeric + 999.99::numeric(10, 2);
    END LOOP;
    RAISE NOTICE 'summ_real = %;', summ_real;
    RAISE NOTICE 'Diff = %;', 99999000.00::real - summ_real;
	
    RAISE NOTICE 'summ_money = %;', summ_money;
    RAISE NOTICE 'Diff = %;', 99999000.00::money - summ_money;
    
	RAISE NOTICE 'summ_numeric = %;', summ_numeric;
    RAISE NOTICE 'Diff = %;', 99999000.00::numeric(10, 2) - summ_numeric;
END
$$ language plpgsql;
-- NOTICE:  summ_real = 9.999999e+07;
-- NOTICE:  Diff = -992;        2.2.  Задание 2
-- NOTICE:  summ_money = 99 999 000,00 ₽;
-- NOTICE:  Diff = 0,00 ₽;
-- NOTICE:  summ_numeric = 99999000.00;
-- NOTICE:  Diff = 0.00;

-- 2.2.  Задание 2
-- Написание запросов на языке SQL
-- Напишите SQL запросы к учебной базе данных в соответствии с вариантом.
-- Запросы брать из сборник запросов к учебной базе данных, расположенного ниже.

-- Numbers of requests: 2, 12, 22, 32, 42, 52, 62, 72

-- 02. Вывести возраст студентов группы, отсортировав по номеру студенческого билета
SELECT student_id, age(CURRENT_DATE, birthday) AS "Age"
FROM students
ORDER BY student_id;

-- 12. Вывести должности всех преподавателей, чей оклад выше 100000, отсортировать по размеру оклада
SELECT professor_id, current_position, salary
FROM professors
WHERE salary > 100000::money
ORDER BY salary DESC;

-- 22. Выведите количество студентов обучающихся в каждой группе и отсортируйте их по количеству
SELECT students_group_number, count(*) AS "Number of students"
FROM students
GROUP BY students_group_number
ORDER BY count(*);

-- 32. Вывести число учащихся по каждой дисциплине, отсортировать по количеству.
--      Оставить только те числа, где число учащихся больше 100
SELECT field, COUNT(*) AS "Number of students"
FROM field_comprehensions
GROUP BY field
HAVING COUNT(*) > 100
ORDER BY COUNT(*);

-- 42. Вывести весь 2-й курс ИВТ, отсортировать по фамилии
SELECT *
FROM students
-- WHERE students_group_number LIKE 'ИВТ-2%'
WHERE students_group_number LIKE 'ИВТ-2_'
ORDER BY last_name ASC;

-- 52. Вывести всех студентов ИТД с фамилией, заканчивающейся на -ин/ов/ев,
--      отсортировать по фам
SELECT last_name, first_name, patronymic, students_group_number
FROM students
WHERE
	((last_name LIKE '%ин') OR
	(last_name LIKE '%ов') OR
	(last_name LIKE '%ев')) AND
	(students_group_number LIKE 'ИТД%')
ORDER BY last_name ASC;

-- 62. Вывести всех студентов-тёзок, родившихся в 2004-2005 годах
SELECT COUNT(*) as "Num of Students", first_name
FROM students
WHERE birthday BETWEEN '01/01/2004' AND '31/12/2005'
GROUP BY first_name
HAVING COUNT(*) > 1;

-- 72. Подсчитать количество студентов в каждой группе, при подсчете учитывать только первые группы,
-- включая вечерников. Вывести группы, в которых количество студентов >20, а также число студентов по группам.
-- Отсортировать по количеству. Всем столбцам дать русские имена.
SELECT COUNT(*) AS "Num of Students", students_group_number
FROM students
WHERE students_group_number LIKE '%-1%'
GROUP BY students_group_number
HAVING COUNT(*) > 20

-- 2.3.  Задание 3
-- Самостоятельно разработайте 7 осмысленных запросов к базе данных,
-- используя приведенные в данной лабораторной работе материалы. 

-- 1.
SELECT first_name, last_name, students_group_number
FROM students
WHERE 
	first_name 	LIKE 'В%' AND
	last_name 	LIKE 'П%' 

-- 2.
SELECT AGE(CURRENT_DATE, birthday) AS "Age", first_name, last_name, students_group_number
FROM students
WHERE EXTRACT(YEAR FROM(AGE(CURRENT_DATE, birthday))) > 17
ORDER BY AGE(CURRENT_DATE, birthday)

-- 3.
SELECT last_name, first_name, patronymic, students_group_number
FROM students
WHERE
	patronymic = 'null' AND
	students_group_number LIKE '%-3%'
ORDER BY students_group_number

-- 4.
SELECT AVG(salary::numeric)::numeric(10, 2) AS "Average salary", current_position
FROM professors
GROUP BY current_position

-- 5.
SELECT * 
FROM students
WHERE student_id > 820000 AND student_id < 821000

-- 6.
SELECT * 
FROM students
WHERE last_name LIKE 'Маслов%'

-- 7.
SELECT last_name, COUNT(*) AS "Num of students"
FROM students
GROUP BY last_name
ORDER BY COUNT(*) DESC;

-- Additional
SELECT
	first_name,
	last_name,
	current_position,
	salary,
	AVG(salary::numeric) OVER (
		PARTITION BY current_position
	)::numeric(10,2)
FROM professors
