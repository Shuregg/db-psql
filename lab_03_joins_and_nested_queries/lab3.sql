-- Task 1. Common Table Expressions (CTE)

--  COUNT(degrees) = 7
WITH count_degree AS (
	SELECT DISTINCT degree FROM professors
) 
SELECT COUNT(degree)
FROM count_degree

-- COUNT(*) = 8
WITH count_degree AS (
	SELECT DISTINCT degree FROM professors
) 
SELECT COUNT(*)
FROM count_degree

-- If you check what shows this CTE, you will see, that one of corteges is null
SELECT DISTINCT degree FROM professors
--     degree
-- 1   "Ph.D."
-- 2   "d.e.s."
-- 3   [null]
-- 4   "Ph.D."
-- 5   "d.t.s"
-- 6   "Ph.D.-M.Sc."
-- 7   "c.t.s"

-- null is doesn't count!

-- Task 2. Queries
-- 2.1 Write queries using INNER JOIN
--      2.  Print the full name, student ID numbers, grades for the development of disciplines and names of disciplines for all students
SELECT 
	 s.last_name
	,s.first_name
	,s.patronymic
	,s.student_id
	,fc.mark
	,f.field_name AS "Object"
FROM
	students s
INNER JOIN
	field_comprehensions fc ON fc.student_id = s.student_id
INNER JOIN
	fields f ON f.field_id = fc.field

--      12. Print the full name of all students who have mastered the Database discipline to 5. Sort by last name and first name.
SELECT 
	 s.last_name
	,s.first_name
	,s.patronymic
	,fc.mark
	,f.field_name AS "Object"
FROM
	 students s
INNER JOIN
	field_comprehensions fc ON fc.student_id = s.student_id
INNER JOIN
	fields f ON (f.field_id = fc.field AND
				 f.field_name = 'Базы данных' AND
				 fc.mark = 5
			)
	
	
--      22. Print the names of groups in which there is at least 1 student who has mastered the discipline “Physics“ by 5
--      (the name of the discipline should contain the word “Physics"). Sort by group number.
SELECT s.students_group_number	
FROM students s
INNER JOIN field_comprehensions fc ON s.student_id = fc.student_id
INNER JOIN fields f ON f.field_id = fc.field
WHERE fc.mark = 5
	AND f.field_name LIKE '%Физика%'
GROUP BY s.students_group_number
ORDER BY s.students_group_number

--      32. Display a list of students from the IVT groups. Who passed more than 10 subjects perfectly.
SELECT
	 s.students_group_number
	,COUNT(fc.mark = 5) AS "Perfect marks"
FROM students s
INNER JOIN field_comprehensions fc ON s.student_id = fc.student_id
INNER JOIN fields f ON f.field_id = fc.field
WHERE s.students_group_number LIKE 'ИВТ-%'
	AND fc.mark = 5
GROUP BY s.students_group_number
HAVING COUNT(fc.mark = 5) > 10
ORDER BY COUNT(fc.mark = 5)

-- 2.2 Write queries using LEFT JOIN, RIGHT JOIN, FULL JOIN  
--      42. Print the surnames of the teachers and the surnames of their namesakes among the students (if exists, otherwise null). 
--      Use LEFT JOIN or RIGHT JOIN.
SELECT
	  p.last_name	AS "p last_name"
	 ,p.first_name	AS "p first_name"
	 ,p.patronymic	AS "p patronymic"
	 ,s.last_name	AS "s last_name"
	 ,s.first_name	AS "s first_name"
	 ,s.patronymic	AS "s patronymic"
FROM professors p
LEFT JOIN students s ON (
	s.last_name = p.last_name
-- 	AND s.first_name = p.first_name
-- 	AND s.patronymic = p.patronymic
)

-- 2.3 Write queries using UNION/EXCEPT/INTERSECT
--      52. Print the name of all groups and all structural divisions. Sort by name.
SELECT sg.students_group_number AS "name"
FROM students_groups sg
UNION
SELECT su.full_title AS "name"
FROM structural_units su
ORDER BY "name"

--      62. Print the name of the semester in two columns (for example, “Semester 1”) and
--      the number of subjects taught this semester.
--      At the bottom, add the names of the teachers to the same two columns,
--      who are reading disciplines in the 8th semester and the number of these disciplines.
SELECT CONCAT('Semester ', f.semester) AS "Semester number"
	,COUNT(f.field_name) AS "Subject number"
FROM fields f
GROUP BY f.semester

UNION ALL

SELECT p.last_name
	,COUNT(f.field_name)
FROM fields f
INNER JOIN professors p ON f.professor_id = p.professor_id
WHERE f.semester = 8
GROUP BY p.last_name

ORDER BY "Semester number"

-- 2.4 Nested Queries  
--      72. Print the numbers of employment contracts and the rates of those
--      teachers who have a higher than average value.
--      At the end of the table, add the line - ‘Average rate’ and enter its value.
SELECT CAST(contract_number AS CHAR), wage_rate::numeric
FROM employments
WHERE wage_rate::numeric > 
(
	SELECT AVG(wage_rate::numeric) 
	FROM employments
)

UNION 

SELECT 
	 'Average wage' AS contract_number
	,AVG(wage_rate::numeric)::numeric(2, 2) AS wage_rate
FROM employments

ORDER BY contract_number

--      82. Find the name of the discipline for which the highest number of fives was obtained.
--      Print the last name, first name, patronymic of the students who received five in this discipline.
WITH discipline_with_max_fives AS (
	SELECT fc2.field AS field_id
	FROM field_comprehensions fc2
	WHERE fc2.mark = 5
	GROUP BY fc2.field
	ORDER BY COUNT(fc2.mark) DESC
	LIMIT 1
)

SELECT
	 s.last_name
	,s.first_name
	,s.patronymic
	,f.field_name
FROM students s
INNER JOIN field_comprehensions fc ON fc.student_id = s.student_id
INNER JOIN fields f ON fc.field = f.field_id
WHERE
	fc.mark = 5
	AND fc.field = (
		SELECT field_id
		FROM discipline_with_max_fives
	)

--  Task 3. Create your own queries

SELECT
	 s.student_id
    ,s.last_name
    ,s.first_name 
    ,COUNT(fc.mark) AS "Num of mark=2"
FROM 
    students s
INNER JOIN field_comprehensions fc ON fc.student_id = s.student_id
INNER JOIN fields f ON f.field_id = fc.field
WHERE fc.mark < 3 OR fc.mark = NULL
GROUP BY s.student_id
ORDER BY COUNT(fc.mark) DESC

-- Display a list of all students, their average score in all disciplines and the number of disciplines,
-- in which they passed the exams.
SELECT 
    s.last_name, 
    s.first_name, 
    AVG(fc.mark) AS average_mark, 
    COUNT(fc.mark) AS subjects_count
FROM 
    students s
LEFT JOIN 
    field_comprehensions fc ON s.student_id = fc.student_id
GROUP BY 
    s.student_id
ORDER BY 
    average_mark DESC, s.last_name, s.first_name;

-- Display the unique names of the disciplines and the average grades of students
-- in these disciplines,
-- as well as the names of the teachers who lead them.
SELECT 
    f.field_name AS name,
    AVG(fc.mark) AS average_mark
FROM 
    fields f
INNER JOIN 
    field_comprehensions fc ON f.field_id = fc.field
GROUP BY 
    f.field_name
UNION

SELECT 
    CONCAT(p.first_name, ' ', p.last_name, ' (professor)') AS name,
    NULL AS average_mark
FROM 
    professors p;
	
