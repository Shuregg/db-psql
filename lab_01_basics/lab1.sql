-- 1.1
-- Создайте учебную базу данных Students. Для этого необходимо войти в учетную запись postgres и подключиться к программе psql.
CREATE DATABASE students;

-- 1.2
-- Выйдите из программы psql и заполните базу данных, используя файл резервной копии.
`psql students < students_dump.sql`

-- 1.3
-- Используя программу pgAdmin, ознакомьтесь со схемой данных, содержимым таблиц БД. Определите число строк в каждой из таблиц.  

-- 1.4
-- Определите, какие таблицы в базе данных Students являются главными, а какие для них подчиненными. 
 
-- 2.1 
-- Подключитесь к созданной базе данных Students из-под командной строки. Определите, какой размер на диске занимает таблица student? 
\dt+ students
-- public | students | table | postgres | permanent   | heap          | 88 kB |

-- 2.2 Создайте новую роль «Ваши инициалы junior». Выделите ей привилегии на вход и установите пароль «654321».
CREATE ROLE "IAV junior" WITH
	LOGIN
	PASSWORD '654321';
-- Подключитесь от её имени к базе данных students и попробуйте удалить её с помощью запроса:DROP DATABASE students;
DROP DATABASE students;
-- ERROR:  cannot drop the currently open database
-- SQL state: 55006

-- 3.1. Выполните в соответствии с вариантом задание (см. таблицу ниже) на изменение содержимого базы данных. 
-- 3.2. После внесенных изменений, создайте новую резервную копию базы данных Students. 
-- pg_dump dbname > db_backup_file.sql
-- pg_dump students > students_my_backup.sql

-- variant (11 % 10 + 1) = 2
-- В связи с ошибкой при заполнении документов, студенту Безухову Пьеру Кирилловичу из группы ИТД-12 указали неверно дату рождения.
-- Исправьте её на 12 августа 2004 года.
-- SELECT * FROM public.students

UPDATE students
SET birthday='2004-08-12'
WHERE 	students_group_number='ИТД-12'
	AND last_name='Безухов'
	AND (first_name='Пьер' OR first_name='Пётр')
	AND patronymic='Кириллович';

`pg_dump students > students_dump_lab1.sql`