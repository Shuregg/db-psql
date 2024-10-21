-- Database generated with pgModeler (PostgreSQL Database Modeler).
-- pgModeler version: 1.1.0-beta1
-- PostgreSQL version: 16.0
-- Project Site: pgmodeler.io
-- Model Author: ---
-- object: testuser | type: ROLE --
-- DROP ROLE IF EXISTS testuser;
CREATE ROLE testuser WITH 
	INHERIT
	LOGIN
	 PASSWORD '********';
-- ddl-end --

-- object: alexander | type: ROLE --
-- DROP ROLE IF EXISTS alexander;
CREATE ROLE alexander WITH 
	SUPERUSER
	CREATEDB
	CREATEROLE
	INHERIT
	LOGIN
	 PASSWORD '********';
-- ddl-end --


-- Database creation must be performed outside a multi lined SQL file. 
-- These commands were put in this file only as a convenience.
-- 
-- object: students | type: DATABASE --
-- DROP DATABASE IF EXISTS students;
CREATE DATABASE students
	ENCODING = 'UTF8'
	LC_COLLATE = 'ru_RU.UTF-8'
	LC_CTYPE = 'ru_RU.UTF-8'
	TABLESPACE = pg_default
	OWNER = postgres;
-- ddl-end --


-- object: public.employments | type: TABLE --
-- DROP TABLE IF EXISTS public.employments CASCADE;
CREATE TABLE public.employments (
	structural_unit_id integer NOT NULL,
	professor_id integer NOT NULL,
	contract_number integer NOT NULL,
	wage_rate numeric(3,2) NOT NULL,
	CONSTRAINT employments_pkey PRIMARY KEY (structural_unit_id,professor_id)
);
-- ddl-end --
ALTER TABLE public.employments OWNER TO postgres;
-- ddl-end --

-- object: public.field_comprehensions | type: TABLE --
-- DROP TABLE IF EXISTS public.field_comprehensions CASCADE;
CREATE TABLE public.field_comprehensions (
	student_id integer NOT NULL,
	field uuid NOT NULL,
	mark integer,
	CONSTRAINT field_comprehensions_mark_check CHECK (((mark >= 2) AND (mark <= 5))),
	CONSTRAINT field_comprehensions_pkey PRIMARY KEY (student_id,field)
);
-- ddl-end --
ALTER TABLE public.field_comprehensions OWNER TO postgres;
-- ddl-end --

-- object: public.fields | type: TABLE --
-- DROP TABLE IF EXISTS public.fields CASCADE;
CREATE TABLE public.fields (
	field_id uuid NOT NULL,
	field_name character varying(100) NOT NULL,
	structural_unit_id integer NOT NULL,
	professor_id integer NOT NULL,
	zet integer NOT NULL,
	semester integer NOT NULL,
	CONSTRAINT fields_pkey PRIMARY KEY (field_id)
);
-- ddl-end --
ALTER TABLE public.fields OWNER TO postgres;
-- ddl-end --

-- object: public.professors | type: TABLE --
-- DROP TABLE IF EXISTS public.professors CASCADE;
CREATE TABLE public.professors (
	professor_id integer NOT NULL,
	last_name character varying(30) NOT NULL,
	first_name character varying(30) NOT NULL,
	patronymic character varying(30),
	degree character varying(15),
	academic_title character varying(40),
	current_position character varying(40) NOT NULL,
	experience integer NOT NULL,
	salary money,
	CONSTRAINT professors_degree_check CHECK (((degree)::text ~* '^[кКдД].+[а-яА-Я].+[н].+$'::text)),
	CONSTRAINT professors_pkey PRIMARY KEY (professor_id)
);
-- ddl-end --
ALTER TABLE public.professors OWNER TO postgres;
-- ddl-end --

-- object: public.structural_units_structural_unit_id_seq | type: SEQUENCE --
-- DROP SEQUENCE IF EXISTS public.structural_units_structural_unit_id_seq CASCADE;
CREATE SEQUENCE public.structural_units_structural_unit_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 2147483647
	START WITH 1
	CACHE 1
	NO CYCLE
	OWNED BY NONE;

-- ddl-end --
ALTER SEQUENCE public.structural_units_structural_unit_id_seq OWNER TO postgres;
-- ddl-end --

-- object: public.structural_units | type: TABLE --
-- DROP TABLE IF EXISTS public.structural_units CASCADE;
CREATE TABLE public.structural_units (
	structural_unit_id integer NOT NULL DEFAULT nextval('public.structural_units_structural_unit_id_seq'::regclass),
	full_title text NOT NULL,
	abbreviated_title character varying(20),
	head_of_the_unit character varying(40) NOT NULL,
	phone_number character varying(5),
	CONSTRAINT structural_units_phone_number_check CHECK (((phone_number)::text ~* '^[0-9]{2}-[0-9]{2}$'::text)),
	CONSTRAINT structural_units_pkey PRIMARY KEY (structural_unit_id)
);
-- ddl-end --
ALTER TABLE public.structural_units OWNER TO postgres;
-- ddl-end --

-- object: public.student_ids | type: TABLE --
-- DROP TABLE IF EXISTS public.student_ids CASCADE;
CREATE TABLE public.student_ids (
	student_id integer NOT NULL,
	issue_date date NOT NULL DEFAULT CURRENT_DATE,
	expiration_date date NOT NULL DEFAULT (CURRENT_DATE + '4 years'::interval),
	status character varying(10) NOT NULL DEFAULT 'inactive',
	CONSTRAINT student_ids_pkey PRIMARY KEY (student_id),
	CONSTRAINT status_check CHECK (((status)::text = ANY ((ARRAY['active'::character varying, 'inactive'::character varying])::text[])))
);
-- ddl-end --
ALTER TABLE public.student_ids OWNER TO postgres;
-- ddl-end --

-- object: public.students | type: TABLE --
-- DROP TABLE IF EXISTS public.students CASCADE;
CREATE TABLE public.students (
	student_id integer NOT NULL,
	last_name character varying(30) NOT NULL,
	first_name character varying(30) NOT NULL,
	patronymic character varying(30),
	students_group_number character varying(7) NOT NULL,
	birthday date NOT NULL,
	email character varying(30),
	CONSTRAINT email_cheak CHECK (((email)::text ~* '^[A-Za-z0-9._+%-]+@[A-Za-z0-9.-]+[.][A-Za-z]+$'::text)),
	CONSTRAINT students_email_key UNIQUE (email),
	CONSTRAINT students_pkey PRIMARY KEY (student_id)
);
-- ddl-end --
ALTER TABLE public.students OWNER TO postgres;
-- ddl-end --

-- object: public.students_groups | type: TABLE --
-- DROP TABLE IF EXISTS public.students_groups CASCADE;
CREATE TABLE public.students_groups (
	students_group_number character varying(7) NOT NULL,
	enrolment_status character varying(12) NOT NULL,
	structural_unit_id integer NOT NULL,
	CONSTRAINT students_groups_enrolment_status_check CHECK (((enrolment_status)::text = ANY (('{Очная,Заочная,Очно-заочная}'::character varying[])::text[]))),
	CONSTRAINT students_groups_students_group_number_check CHECK (((students_group_number)::text ~* '^[А-Яа-я]+-[МВ0-9]+$'::text)),
	CONSTRAINT students_groups_pkey PRIMARY KEY (students_group_number)
);
-- ddl-end --
ALTER TABLE public.students_groups OWNER TO postgres;
-- ddl-end --

-- object: public.professors_fields | type: TABLE --
-- DROP TABLE IF EXISTS public.professors_fields CASCADE;
CREATE TABLE public.professors_fields (
	professor_id integer NOT NULL,
	field_id uuid NOT NULL,
	CONSTRAINT professors_fields_pkey PRIMARY KEY (professor_id,field_id)
);
-- ddl-end --
ALTER TABLE public.professors_fields OWNER TO postgres;
-- ddl-end --

-- object: public.sports_sections | type: TABLE --
-- DROP TABLE IF EXISTS public.sports_sections CASCADE;
CREATE TABLE public.sports_sections (
	section_name varchar NOT NULL,
	coach_id integer NOT NULL,
	sport_id integer NOT NULL,
	CONSTRAINT sports_sections_pk PRIMARY KEY (sport_id),
	CONSTRAINT unique_section_id UNIQUE (sport_id)
);
-- ddl-end --
ALTER TABLE public.sports_sections OWNER TO postgres;
-- ddl-end --

-- object: public.coaches | type: TABLE --
-- DROP TABLE IF EXISTS public.coaches CASCADE;
CREATE TABLE public.coaches (
	coach_id integer NOT NULL,
	sport_id integer NOT NULL,
	first_name varchar,
	last_name varchar,
	patronymic varchar,
	CONSTRAINT coaches_pk PRIMARY KEY (coach_id)
);
-- ddl-end --
ALTER TABLE public.coaches OWNER TO postgres;
-- ddl-end --

-- object: public.strudent_sections | type: TABLE --
-- DROP TABLE IF EXISTS public.strudent_sections CASCADE;
CREATE TABLE public.strudent_sections (
	student_id integer NOT NULL,
	sport_id integer NOT NULL,
	CONSTRAINT strudent_sections_pk PRIMARY KEY (student_id,sport_id)
);
-- ddl-end --
ALTER TABLE public.strudent_sections OWNER TO postgres;
-- ddl-end --

-- object: employments_professor_id_fkey | type: CONSTRAINT --
-- ALTER TABLE public.employments DROP CONSTRAINT IF EXISTS employments_professor_id_fkey CASCADE;
ALTER TABLE public.employments ADD CONSTRAINT employments_professor_id_fkey FOREIGN KEY (professor_id)
REFERENCES public.professors (professor_id) MATCH SIMPLE
ON DELETE CASCADE ON UPDATE NO ACTION;
-- ddl-end --

-- object: employments_structural_unit_id_fkey | type: CONSTRAINT --
-- ALTER TABLE public.employments DROP CONSTRAINT IF EXISTS employments_structural_unit_id_fkey CASCADE;
ALTER TABLE public.employments ADD CONSTRAINT employments_structural_unit_id_fkey FOREIGN KEY (structural_unit_id)
REFERENCES public.structural_units (structural_unit_id) MATCH SIMPLE
ON DELETE CASCADE ON UPDATE NO ACTION;
-- ddl-end --

-- object: field_comprehensions_field_fkey | type: CONSTRAINT --
-- ALTER TABLE public.field_comprehensions DROP CONSTRAINT IF EXISTS field_comprehensions_field_fkey CASCADE;
ALTER TABLE public.field_comprehensions ADD CONSTRAINT field_comprehensions_field_fkey FOREIGN KEY (field)
REFERENCES public.fields (field_id) MATCH SIMPLE
ON DELETE CASCADE ON UPDATE NO ACTION;
-- ddl-end --

-- object: field_comprehensions_student_id_fkey | type: CONSTRAINT --
-- ALTER TABLE public.field_comprehensions DROP CONSTRAINT IF EXISTS field_comprehensions_student_id_fkey CASCADE;
ALTER TABLE public.field_comprehensions ADD CONSTRAINT field_comprehensions_student_id_fkey FOREIGN KEY (student_id)
REFERENCES public.students (student_id) MATCH SIMPLE
ON DELETE CASCADE ON UPDATE NO ACTION;
-- ddl-end --

-- object: fields_structural_unit_id_fkey | type: CONSTRAINT --
-- ALTER TABLE public.fields DROP CONSTRAINT IF EXISTS fields_structural_unit_id_fkey CASCADE;
ALTER TABLE public.fields ADD CONSTRAINT fields_structural_unit_id_fkey FOREIGN KEY (structural_unit_id)
REFERENCES public.structural_units (structural_unit_id) MATCH SIMPLE
ON DELETE CASCADE ON UPDATE NO ACTION;
-- ddl-end --

-- object: student_ids_student_id_fkey | type: CONSTRAINT --
-- ALTER TABLE public.student_ids DROP CONSTRAINT IF EXISTS student_ids_student_id_fkey CASCADE;
ALTER TABLE public.student_ids ADD CONSTRAINT student_ids_student_id_fkey FOREIGN KEY (student_id)
REFERENCES public.students (student_id) MATCH SIMPLE
ON DELETE CASCADE ON UPDATE NO ACTION;
-- ddl-end --

-- object: students_group_key | type: CONSTRAINT --
-- ALTER TABLE public.students DROP CONSTRAINT IF EXISTS students_group_key CASCADE;
ALTER TABLE public.students ADD CONSTRAINT students_group_key FOREIGN KEY (students_group_number)
REFERENCES public.students_groups (students_group_number) MATCH SIMPLE
ON DELETE CASCADE ON UPDATE NO ACTION;
-- ddl-end --

-- object: students_groups_structural_unit_id_fkey | type: CONSTRAINT --
-- ALTER TABLE public.students_groups DROP CONSTRAINT IF EXISTS students_groups_structural_unit_id_fkey CASCADE;
ALTER TABLE public.students_groups ADD CONSTRAINT students_groups_structural_unit_id_fkey FOREIGN KEY (structural_unit_id)
REFERENCES public.structural_units (structural_unit_id) MATCH SIMPLE
ON DELETE CASCADE ON UPDATE NO ACTION;
-- ddl-end --

-- object: professors_fields_professor_id_fkey | type: CONSTRAINT --
-- ALTER TABLE public.professors_fields DROP CONSTRAINT IF EXISTS professors_fields_professor_id_fkey CASCADE;
ALTER TABLE public.professors_fields ADD CONSTRAINT professors_fields_professor_id_fkey FOREIGN KEY (professor_id)
REFERENCES public.professors (professor_id) MATCH SIMPLE
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: professors_fields_field_id_fkey | type: CONSTRAINT --
-- ALTER TABLE public.professors_fields DROP CONSTRAINT IF EXISTS professors_fields_field_id_fkey CASCADE;
ALTER TABLE public.professors_fields ADD CONSTRAINT professors_fields_field_id_fkey FOREIGN KEY (field_id)
REFERENCES public.fields (field_id) MATCH SIMPLE
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: coach_id_fkey | type: CONSTRAINT --
-- ALTER TABLE public.sports_sections DROP CONSTRAINT IF EXISTS coach_id_fkey CASCADE;
ALTER TABLE public.sports_sections ADD CONSTRAINT coach_id_fkey FOREIGN KEY (coach_id)
REFERENCES public.coaches (coach_id) MATCH SIMPLE
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: sport_id_fkey | type: CONSTRAINT --
-- ALTER TABLE public.coaches DROP CONSTRAINT IF EXISTS sport_id_fkey CASCADE;
ALTER TABLE public.coaches ADD CONSTRAINT sport_id_fkey FOREIGN KEY (sport_id)
REFERENCES public.sports_sections (sport_id) MATCH SIMPLE
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: student_id_fkey | type: CONSTRAINT --
-- ALTER TABLE public.strudent_sections DROP CONSTRAINT IF EXISTS student_id_fkey CASCADE;
ALTER TABLE public.strudent_sections ADD CONSTRAINT student_id_fkey FOREIGN KEY (student_id)
REFERENCES public.students (student_id) MATCH SIMPLE
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: sport_id_fkey | type: CONSTRAINT --
-- ALTER TABLE public.strudent_sections DROP CONSTRAINT IF EXISTS sport_id_fkey CASCADE;
ALTER TABLE public.strudent_sections ADD CONSTRAINT sport_id_fkey FOREIGN KEY (sport_id)
REFERENCES public.sports_sections (sport_id) MATCH SIMPLE
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --


