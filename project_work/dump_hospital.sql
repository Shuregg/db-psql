--
-- PostgreSQL database dump
--

-- Dumped from database version 16.6 (Ubuntu 16.6-0ubuntu0.24.04.1)
-- Dumped by pg_dump version 16.6 (Ubuntu 16.6-0ubuntu0.24.04.1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: gender_enum; Type: TYPE; Schema: public; Owner: alexander
--

CREATE TYPE public.gender_enum AS ENUM (
    'male',
    'female'
);


ALTER TYPE public.gender_enum OWNER TO alexander;

--
-- Name: room_type_enum; Type: TYPE; Schema: public; Owner: alexander
--

CREATE TYPE public.room_type_enum AS ENUM (
    'service',
    'ward',
    'reception',
    'procedural',
    'examination'
);


ALTER TYPE public.room_type_enum OWNER TO alexander;

--
-- Name: add_diagnosis(character varying, integer, integer); Type: PROCEDURE; Schema: public; Owner: alexander
--

CREATE PROCEDURE public.add_diagnosis(IN diagnosis_name character varying, IN doctor_id integer, IN patient_id integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO diagnoses (diagnosis_name, doctor_id, patient_id)
    VALUES (diagnosis_name, doctor_id, patient_id);
END;
$$;


ALTER PROCEDURE public.add_diagnosis(IN diagnosis_name character varying, IN doctor_id integer, IN patient_id integer) OWNER TO alexander;

--
-- Name: add_doctor(character varying, character varying, character varying, character varying, integer, boolean); Type: PROCEDURE; Schema: public; Owner: alexander
--

CREATE PROCEDURE public.add_doctor(IN first_name character varying, IN last_name character varying, IN patronymic character varying, IN current_position character varying, IN department_id integer, IN is_doctor boolean)
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO doctors (first_name, last_name, patronymic, current_position, department_id, is_doctor)
    VALUES (first_name, last_name, patronymic, current_position, department_id, is_doctor);
END;
$$;


ALTER PROCEDURE public.add_doctor(IN first_name character varying, IN last_name character varying, IN patronymic character varying, IN current_position character varying, IN department_id integer, IN is_doctor boolean) OWNER TO alexander;

--
-- Name: add_medication(character varying, character varying, character varying, date, date, numeric, integer); Type: PROCEDURE; Schema: public; Owner: alexander
--

CREATE PROCEDURE public.add_medication(IN medication_name character varying, IN indications character varying, IN form character varying, IN production_date date, IN expiration_date date, IN price numeric, IN amount integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO medications (medication_name, indications, form, production_date, expiration_date, price, amount)
    VALUES (medication_name, indications, form, production_date, expiration_date, price, amount);
END;
$$;


ALTER PROCEDURE public.add_medication(IN medication_name character varying, IN indications character varying, IN form character varying, IN production_date date, IN expiration_date date, IN price numeric, IN amount integer) OWNER TO alexander;

--
-- Name: add_patient(character varying, character varying, character varying, date, public.gender_enum, character varying); Type: PROCEDURE; Schema: public; Owner: alexander
--

CREATE PROCEDURE public.add_patient(IN first_name character varying, IN last_name character varying, IN patronymic character varying, IN birth_date date, IN gender public.gender_enum, IN phone_number character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO patients (first_name, last_name, patronymic, birth_date, gender, phone_number)
    VALUES (first_name, last_name, patronymic, birth_date, gender, phone_number);
END;
$$;


ALTER PROCEDURE public.add_patient(IN first_name character varying, IN last_name character varying, IN patronymic character varying, IN birth_date date, IN gender public.gender_enum, IN phone_number character varying) OWNER TO alexander;

--
-- Name: add_visit(date, date, integer, integer); Type: PROCEDURE; Schema: public; Owner: alexander
--

CREATE PROCEDURE public.add_visit(IN visit_date date, IN discharge_date date, IN patient_id integer, IN doctor_id integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO visits (visit_date, discharge_date, patient_id, doctor_id)
    VALUES (visit_date, discharge_date, patient_id, doctor_id);
END;
$$;


ALTER PROCEDURE public.add_visit(IN visit_date date, IN discharge_date date, IN patient_id integer, IN doctor_id integer) OWNER TO alexander;

--
-- Name: calculate_age(); Type: FUNCTION; Schema: public; Owner: alexander
--

CREATE FUNCTION public.calculate_age() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.age := DATE_PART('year', AGE(NEW.birth_date));
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.calculate_age() OWNER TO alexander;

--
-- Name: check_room_capacity(); Type: FUNCTION; Schema: public; Owner: alexander
--

CREATE FUNCTION public.check_room_capacity() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF (SELECT COUNT(*) FROM visits_rooms WHERE room_id = NEW.room_id) >=
       (SELECT number_of_beds FROM rooms WHERE room_id = NEW.room_id) THEN
        RAISE EXCEPTION 'Room capacity exceeded';
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.check_room_capacity() OWNER TO alexander;

--
-- Name: set_number_of_beds_null(); Type: FUNCTION; Schema: public; Owner: alexander
--

CREATE FUNCTION public.set_number_of_beds_null() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NEW.room_type != 'ward' THEN
        NEW.number_of_beds := NULL;
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.set_number_of_beds_null() OWNER TO alexander;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: departments; Type: TABLE; Schema: public; Owner: alexander
--

CREATE TABLE public.departments (
    department_id integer NOT NULL,
    department_name character varying(50) NOT NULL,
    head_id integer,
    local_phone_number character varying(4) NOT NULL,
    public_phone_number character varying(11)
);


ALTER TABLE public.departments OWNER TO alexander;

--
-- Name: departments_department_id_seq; Type: SEQUENCE; Schema: public; Owner: alexander
--

CREATE SEQUENCE public.departments_department_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.departments_department_id_seq OWNER TO alexander;

--
-- Name: departments_department_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: alexander
--

ALTER SEQUENCE public.departments_department_id_seq OWNED BY public.departments.department_id;


--
-- Name: diagnoses; Type: TABLE; Schema: public; Owner: alexander
--

CREATE TABLE public.diagnoses (
    diagnosis_id integer NOT NULL,
    diagnosis_name character varying NOT NULL,
    doctor_id integer,
    patient_id integer NOT NULL
);


ALTER TABLE public.diagnoses OWNER TO alexander;

--
-- Name: diagnoses_diagnosis_id_seq; Type: SEQUENCE; Schema: public; Owner: alexander
--

CREATE SEQUENCE public.diagnoses_diagnosis_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.diagnoses_diagnosis_id_seq OWNER TO alexander;

--
-- Name: diagnoses_diagnosis_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: alexander
--

ALTER SEQUENCE public.diagnoses_diagnosis_id_seq OWNED BY public.diagnoses.diagnosis_id;


--
-- Name: diagnosis_patient_count_view; Type: VIEW; Schema: public; Owner: alexander
--

CREATE VIEW public.diagnosis_patient_count_view AS
SELECT
    NULL::character varying AS diagnosis_name,
    NULL::bigint AS patient_count;


ALTER VIEW public.diagnosis_patient_count_view OWNER TO alexander;

--
-- Name: doctor_patient_count_view; Type: VIEW; Schema: public; Owner: alexander
--

CREATE VIEW public.doctor_patient_count_view AS
SELECT
    NULL::character varying AS first_name,
    NULL::character varying AS last_name,
    NULL::bigint AS patient_count;


ALTER VIEW public.doctor_patient_count_view OWNER TO alexander;

--
-- Name: doctors; Type: TABLE; Schema: public; Owner: alexander
--

CREATE TABLE public.doctors (
    doctor_id integer NOT NULL,
    first_name character varying NOT NULL,
    last_name character varying NOT NULL,
    patronymic character varying,
    current_position character varying NOT NULL,
    department_id integer,
    is_doctor boolean DEFAULT false NOT NULL
);


ALTER TABLE public.doctors OWNER TO alexander;

--
-- Name: doctors_doctor_id_seq; Type: SEQUENCE; Schema: public; Owner: alexander
--

CREATE SEQUENCE public.doctors_doctor_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.doctors_doctor_id_seq OWNER TO alexander;

--
-- Name: doctors_doctor_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: alexander
--

ALTER SEQUENCE public.doctors_doctor_id_seq OWNED BY public.doctors.doctor_id;


--
-- Name: patients; Type: TABLE; Schema: public; Owner: alexander
--

CREATE TABLE public.patients (
    patient_id integer NOT NULL,
    first_name character varying NOT NULL,
    last_name character varying NOT NULL,
    patronymic character varying,
    birth_date date NOT NULL,
    gender public.gender_enum NOT NULL,
    phone_number character varying(11),
    registration_date date DEFAULT CURRENT_DATE NOT NULL,
    age integer
);


ALTER TABLE public.patients OWNER TO alexander;

--
-- Name: visits; Type: TABLE; Schema: public; Owner: alexander
--

CREATE TABLE public.visits (
    visit_id integer NOT NULL,
    visit_date date DEFAULT CURRENT_DATE NOT NULL,
    discharge_date date DEFAULT CURRENT_DATE NOT NULL,
    patient_id integer NOT NULL,
    doctor_id integer NOT NULL
);


ALTER TABLE public.visits OWNER TO alexander;

--
-- Name: doctors_patients_sorted_view; Type: VIEW; Schema: public; Owner: alexander
--

CREATE VIEW public.doctors_patients_sorted_view AS
 SELECT d.first_name AS doctor_first_name,
    d.last_name AS doctor_last_name,
    p.first_name AS patient_first_name,
    p.last_name AS patient_last_name,
    v.visit_date
   FROM ((public.doctors d
     JOIN public.visits v ON ((d.doctor_id = v.doctor_id)))
     JOIN public.patients p ON ((v.patient_id = p.patient_id)))
  ORDER BY v.visit_date;


ALTER VIEW public.doctors_patients_sorted_view OWNER TO alexander;

--
-- Name: medications; Type: TABLE; Schema: public; Owner: alexander
--

CREATE TABLE public.medications (
    medication_id integer NOT NULL,
    medication_name character varying NOT NULL,
    indications character varying,
    form character varying(50) NOT NULL,
    production_date date NOT NULL,
    expiration_date date NOT NULL,
    price numeric(10,2) NOT NULL,
    amount integer,
    CONSTRAINT production_date_less_than_expiration_date CHECK ((production_date < expiration_date))
);


ALTER TABLE public.medications OWNER TO alexander;

--
-- Name: expiring_medications_view; Type: VIEW; Schema: public; Owner: alexander
--

CREATE VIEW public.expiring_medications_view AS
 SELECT medication_name,
    expiration_date
   FROM public.medications m
  WHERE (expiration_date < (CURRENT_DATE + '1 mon'::interval));


ALTER VIEW public.expiring_medications_view OWNER TO alexander;

--
-- Name: medication_treatment_count_view; Type: VIEW; Schema: public; Owner: alexander
--

CREATE VIEW public.medication_treatment_count_view AS
SELECT
    NULL::character varying AS medication_name,
    NULL::bigint AS treatment_count;


ALTER VIEW public.medication_treatment_count_view OWNER TO alexander;

--
-- Name: medications_medication_id_seq; Type: SEQUENCE; Schema: public; Owner: alexander
--

CREATE SEQUENCE public.medications_medication_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.medications_medication_id_seq OWNER TO alexander;

--
-- Name: medications_medication_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: alexander
--

ALTER SEQUENCE public.medications_medication_id_seq OWNED BY public.medications.medication_id;


--
-- Name: patients_age_view; Type: VIEW; Schema: public; Owner: alexander
--

CREATE VIEW public.patients_age_view AS
 SELECT first_name,
    last_name,
    birth_date,
    EXTRACT(year FROM age((birth_date)::timestamp with time zone)) AS age
   FROM public.patients p;


ALTER VIEW public.patients_age_view OWNER TO alexander;

--
-- Name: rooms; Type: TABLE; Schema: public; Owner: alexander
--

CREATE TABLE public.rooms (
    room_id integer NOT NULL,
    department_id integer,
    room_number character varying(10) NOT NULL,
    room_name character varying NOT NULL,
    room_type public.room_type_enum NOT NULL,
    number_of_beds smallint,
    CONSTRAINT chk_number_of_beds CHECK ((((room_type = 'ward'::public.room_type_enum) AND (number_of_beds IS NOT NULL) AND (number_of_beds > 0)) OR ((room_type <> 'ward'::public.room_type_enum) AND (number_of_beds IS NULL))))
);


ALTER TABLE public.rooms OWNER TO alexander;

--
-- Name: visits_rooms; Type: TABLE; Schema: public; Owner: alexander
--

CREATE TABLE public.visits_rooms (
    visit_id integer NOT NULL,
    room_id integer NOT NULL
);


ALTER TABLE public.visits_rooms OWNER TO alexander;

--
-- Name: patients_in_ward_rooms_view; Type: VIEW; Schema: public; Owner: alexander
--

CREATE VIEW public.patients_in_ward_rooms_view AS
 SELECT p.first_name,
    p.last_name,
    r.room_number
   FROM ((public.patients p
     JOIN public.visits_rooms vr ON ((p.patient_id = vr.visit_id)))
     JOIN public.rooms r ON ((vr.room_id = r.room_id)))
  WHERE (r.room_type = 'ward'::public.room_type_enum);


ALTER VIEW public.patients_in_ward_rooms_view OWNER TO alexander;

--
-- Name: patients_patient_id_seq; Type: SEQUENCE; Schema: public; Owner: alexander
--

CREATE SEQUENCE public.patients_patient_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.patients_patient_id_seq OWNER TO alexander;

--
-- Name: patients_patient_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: alexander
--

ALTER SEQUENCE public.patients_patient_id_seq OWNED BY public.patients.patient_id;


--
-- Name: patients_rooms_diagnoses_view; Type: VIEW; Schema: public; Owner: alexander
--

CREATE VIEW public.patients_rooms_diagnoses_view AS
 SELECT p.first_name,
    p.last_name,
    r.room_number,
    d.diagnosis_name
   FROM (((public.patients p
     JOIN public.visits_rooms vr ON ((p.patient_id = vr.visit_id)))
     JOIN public.rooms r ON ((vr.room_id = r.room_id)))
     JOIN public.diagnoses d ON ((p.patient_id = d.patient_id)));


ALTER VIEW public.patients_rooms_diagnoses_view OWNER TO alexander;

--
-- Name: room_patient_count_view; Type: VIEW; Schema: public; Owner: alexander
--

CREATE VIEW public.room_patient_count_view AS
SELECT
    NULL::character varying(10) AS room_number,
    NULL::bigint AS patient_count;


ALTER VIEW public.room_patient_count_view OWNER TO alexander;

--
-- Name: rooms_beds_view; Type: VIEW; Schema: public; Owner: alexander
--

CREATE VIEW public.rooms_beds_view AS
 SELECT room_id,
    room_number,
    room_name,
    room_type,
    number_of_beds
   FROM public.rooms r
  WHERE (room_type = 'ward'::public.room_type_enum);


ALTER VIEW public.rooms_beds_view OWNER TO alexander;

--
-- Name: rooms_room_id_seq; Type: SEQUENCE; Schema: public; Owner: alexander
--

CREATE SEQUENCE public.rooms_room_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.rooms_room_id_seq OWNER TO alexander;

--
-- Name: rooms_room_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: alexander
--

ALTER SEQUENCE public.rooms_room_id_seq OWNED BY public.rooms.room_id;


--
-- Name: treatment_courses; Type: TABLE; Schema: public; Owner: alexander
--

CREATE TABLE public.treatment_courses (
    visit_id integer NOT NULL,
    medication_id integer NOT NULL,
    treatment_description text,
    dosage_mg numeric(5,2) NOT NULL,
    times_per_day integer NOT NULL
);


ALTER TABLE public.treatment_courses OWNER TO alexander;

--
-- Name: visits_diagnoses; Type: TABLE; Schema: public; Owner: alexander
--

CREATE TABLE public.visits_diagnoses (
    visit_id integer NOT NULL,
    diagnosis_id integer NOT NULL
);


ALTER TABLE public.visits_diagnoses OWNER TO alexander;

--
-- Name: visits_visit_id_seq; Type: SEQUENCE; Schema: public; Owner: alexander
--

CREATE SEQUENCE public.visits_visit_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.visits_visit_id_seq OWNER TO alexander;

--
-- Name: visits_visit_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: alexander
--

ALTER SEQUENCE public.visits_visit_id_seq OWNED BY public.visits.visit_id;


--
-- Name: departments department_id; Type: DEFAULT; Schema: public; Owner: alexander
--

ALTER TABLE ONLY public.departments ALTER COLUMN department_id SET DEFAULT nextval('public.departments_department_id_seq'::regclass);


--
-- Name: diagnoses diagnosis_id; Type: DEFAULT; Schema: public; Owner: alexander
--

ALTER TABLE ONLY public.diagnoses ALTER COLUMN diagnosis_id SET DEFAULT nextval('public.diagnoses_diagnosis_id_seq'::regclass);


--
-- Name: doctors doctor_id; Type: DEFAULT; Schema: public; Owner: alexander
--

ALTER TABLE ONLY public.doctors ALTER COLUMN doctor_id SET DEFAULT nextval('public.doctors_doctor_id_seq'::regclass);


--
-- Name: medications medication_id; Type: DEFAULT; Schema: public; Owner: alexander
--

ALTER TABLE ONLY public.medications ALTER COLUMN medication_id SET DEFAULT nextval('public.medications_medication_id_seq'::regclass);


--
-- Name: patients patient_id; Type: DEFAULT; Schema: public; Owner: alexander
--

ALTER TABLE ONLY public.patients ALTER COLUMN patient_id SET DEFAULT nextval('public.patients_patient_id_seq'::regclass);


--
-- Name: rooms room_id; Type: DEFAULT; Schema: public; Owner: alexander
--

ALTER TABLE ONLY public.rooms ALTER COLUMN room_id SET DEFAULT nextval('public.rooms_room_id_seq'::regclass);


--
-- Name: visits visit_id; Type: DEFAULT; Schema: public; Owner: alexander
--

ALTER TABLE ONLY public.visits ALTER COLUMN visit_id SET DEFAULT nextval('public.visits_visit_id_seq'::regclass);


--
-- Data for Name: departments; Type: TABLE DATA; Schema: public; Owner: alexander
--

COPY public.departments (department_id, department_name, head_id, local_phone_number, public_phone_number) FROM stdin;
1	Кардиология	\N	1001	89234567890
2	Неврология	\N	1002	89234567891
3	Педиатрия	\N	1003	89234567892
4	Хирургия	\N	1004	89234567893
5	Онкология	\N	1005	89234567894
6	Гинекология	\N	1006	89234567895
7	Дерматология	\N	1007	89234567896
8	Эндокринология	\N	1008	89234567897
9	Гастроэнтерология	\N	1009	89234567898
10	Пневмология	\N	1010	89234567899
11	Диагностика	\N	1011	89234567900
12	Патологоанатомия	\N	1012	89234567901
13	Психиатрия	\N	1013	89234567902
\.


--
-- Data for Name: diagnoses; Type: TABLE DATA; Schema: public; Owner: alexander
--

COPY public.diagnoses (diagnosis_id, diagnosis_name, doctor_id, patient_id) FROM stdin;
1	Гипертония	1	1
2	Аппендицит	2	2
3	Грипп	3	3
4	Аритмия	4	4
5	Анемия	5	5
6	Депрессия	6	6
7	Сахарный диабет	7	7
8	Желчнокаменная болезнь	8	8
9	Синусит	9	9
10	Сердечная недостаточность	10	10
11	Гастрит	11	11
12	Бронхит	12	12
13	Пневмония	13	13
14	Остеопороз	14	14
15	Артрит	15	15
\.


--
-- Data for Name: doctors; Type: TABLE DATA; Schema: public; Owner: alexander
--

COPY public.doctors (doctor_id, first_name, last_name, patronymic, current_position, department_id, is_doctor) FROM stdin;
1	Иван	Иванов	Иванович	Кардиолог	1	f
2	Анна	Смирнова	Алексеевна	Невролог	2	f
3	Пётр	Петров	Петрович	Педиатр	3	f
4	Елена	Кузнецова	Сергеевна	Хирург	4	f
5	Сергей	Морозов	Александрович	Онколог	5	f
6	Мария	Волкова	Ивановна	Гинеколог	6	f
7	Алексей	Соколов	Петрович	Дерматолог	7	f
8	Ольга	Лебедева	Владимировна	Эндокринолог	8	f
9	Дмитрий	Козлов	Алексеевич	Гастроэнтеролог	9	f
10	Наталья	Новикова	Сергеевна	Пульмонолог	10	f
11	Грегори	Хаус	\N	Диагност	11	f
12	Стивен	Стрэндж	\N	Хирург	4	f
13	Андрей	Быков	\N	Терапевт	11	f
14	Семён	Лобанов	\N	Кардиолог	1	f
15	Шон	Мёрфи	\N	Патологоанатом	12	f
16	Ганнибал	Лектор	\N	Психиатр	13	f
17	Александр	Петров	Иванович	Кардиолог	1	f
18	Екатерина	Иванова	Алексеевна	Невролог	2	f
19	Владимир	Сидоров	Петрович	Педиатр	3	f
20	Татьяна	Михайлова	Сергеевна	Хирург	4	f
21	Андрей	Кузнецов	Александрович	Онколог	5	f
\.


--
-- Data for Name: medications; Type: TABLE DATA; Schema: public; Owner: alexander
--

COPY public.medications (medication_id, medication_name, indications, form, production_date, expiration_date, price, amount) FROM stdin;
1	Аспирин	Противовоспалительное	Таблетка	2023-01-01	2025-12-31	375.00	100
2	Парацетамол	Обезболивающее	Сироп	2023-02-01	2026-06-30	295.00	200
3	Метформин	Сахароснижающее	Таблетка	2023-03-01	2024-11-30	550.00	150
4	Ибупрофен	Противовоспалительное	Капсула	2023-04-01	2025-03-31	389.00	120
5	Амоксициллин	Антибиотик	Таблетка	2023-05-01	2026-08-15	765.00	180
6	Циталопрам	Антидепрессант	Таблетка	2023-06-01	2027-05-10	890.00	250
7	Аторвастатин	Статин	Таблетка	2023-07-01	2025-01-01	924.00	220
8	Омепразол	Ингибитор протонной помпы	Капсула	2023-08-01	2024-12-15	649.50	280
9	Фуросемид	Диуретик	Инъекция	2023-09-01	2026-03-20	429.99	300
10	Лизиноприл	Ингибитор АПФ	Таблетка	2023-10-01	2025-07-01	345.55	350
\.


--
-- Data for Name: patients; Type: TABLE DATA; Schema: public; Owner: alexander
--

COPY public.patients (patient_id, first_name, last_name, patronymic, birth_date, gender, phone_number, registration_date, age) FROM stdin;
1	Иван	Иванов	Иванович	1980-05-15	male	89234567890	2024-12-14	44
2	Анна	Смирнова	Алексеевна	1990-08-20	female	89987654321	2024-12-14	34
3	Пётр	Петров	Петрович	1975-12-01	male	89122334455	2024-12-14	49
4	Елена	Кузнецова	Сергеевна	2000-07-10	female	89233445566	2024-12-14	24
5	Сергей	Морозов	Александрович	1985-11-25	male	89344556677	2024-12-14	39
6	Мария	Волкова	Ивановна	1995-03-05	female	89455667788	2024-12-14	29
7	Алексей	Соколов	Петрович	1970-02-28	male	89566778899	2024-12-14	54
8	Ольга	Лебедева	Владимировна	1988-06-15	female	89677889900	2024-12-14	36
9	Дмитрий	Козлов	\N	2003-01-01	male	89788990011	2024-12-14	21
10	Наталья	Новикова	Сергеевна	1993-09-09	female	89899001122	2024-12-14	31
11	Александр	Петров	Иванович	1982-04-22	male	89900112233	2024-12-14	42
12	Екатерина	Иванова	Алексеевна	1991-11-11	female	89011223344	2024-12-14	33
13	Владимир	Сидоров	Петрович	1977-07-07	male	89126563654	2024-12-14	47
14	Татьяна	Михайлова	Сергеевна	1984-08-08	female	89233445534	2024-12-14	40
15	Андрей	Кузнецов	Александрович	1989-09-09	male	89344556674	2024-12-14	35
\.


--
-- Data for Name: rooms; Type: TABLE DATA; Schema: public; Owner: alexander
--

COPY public.rooms (room_id, department_id, room_number, room_name, room_type, number_of_beds) FROM stdin;
1	1	101	Палата 101	ward	4
2	2	102	Палата 102	ward	3
3	3	103	Палата 103	ward	5
4	4	104	Палата 104	ward	2
5	5	105	Палата 105	ward	6
6	6	106	Палата 106	ward	4
7	7	107	Палата 107	ward	3
8	8	108	Палата 108	ward	5
9	9	109	Палата 109	ward	2
10	10	110	Палата 110	ward	6
11	1	201	Кабинет 201	examination	\N
12	2	202	Кабинет 202	examination	\N
13	3	203	Кабинет 203	examination	\N
14	4	204	Кабинет 204	examination	\N
15	5	205	Кабинет 205	examination	\N
16	6	206	Кабинет 206	examination	\N
17	7	207	Кабинет 207	examination	\N
18	8	208	Кабинет 208	examination	\N
19	9	209	Кабинет 209	examination	\N
20	10	210	Кабинет 210	examination	\N
\.


--
-- Data for Name: treatment_courses; Type: TABLE DATA; Schema: public; Owner: alexander
--

COPY public.treatment_courses (visit_id, medication_id, treatment_description, dosage_mg, times_per_day) FROM stdin;
1	1	Принимать 1 таблетку 1 раз в день	500.00	1
2	2	Принимать 10 мл 3 раза в день	10.00	3
3	3	Принимать 2 таблетки 2 раза в день	850.00	2
4	4	Принимать 3 капсулы 3 раза в день	600.00	3
5	5	Принимать 5 таблеток 2 раза в день	500.00	2
6	6	Принимать 20 мг 1 раз в день	20.00	1
7	7	Принимать 1 таблетку 1 раз в день	10.00	1
8	8	Принимать 2 капсулы 2 раза в день	40.00	2
9	9	Принимать 1 инъекцию 2 раза в день	20.00	2
10	10	Принимать 2 таблетки 1 раз в день	20.00	1
11	1	Принимать 1 таблетку 1 раз в день	500.00	1
12	2	Принимать 10 мл 3 раза в день	10.00	3
13	3	Принимать 2 таблетки 2 раза в день	850.00	2
14	4	Принимать 3 капсулы 3 раза в день	600.00	3
15	5	Принимать 5 таблеток 2 раза в день	500.00	2
\.


--
-- Data for Name: visits; Type: TABLE DATA; Schema: public; Owner: alexander
--

COPY public.visits (visit_id, visit_date, discharge_date, patient_id, doctor_id) FROM stdin;
1	2024-01-15	2024-01-20	1	1
2	2024-02-20	2024-02-25	2	2
3	2024-03-12	2024-03-15	3	3
4	2024-04-05	2024-04-10	4	4
5	2024-05-10	2024-05-15	5	5
6	2024-06-18	2024-06-20	6	6
7	2024-07-01	2024-07-05	7	7
8	2024-08-09	2024-08-12	8	8
9	2024-09-14	2024-09-18	9	9
10	2024-10-22	2024-10-25	10	10
11	2024-11-01	2024-11-05	11	11
12	2024-12-01	2024-12-05	12	12
13	2024-01-01	2024-01-05	13	13
14	2024-02-01	2024-02-05	14	14
15	2024-03-01	2024-03-05	15	15
16	2024-04-01	2024-04-05	1	1
17	2024-05-01	2024-05-05	2	2
18	2024-06-01	2024-06-05	3	3
19	2024-07-01	2024-07-05	4	4
20	2024-08-01	2024-08-05	5	5
\.


--
-- Data for Name: visits_diagnoses; Type: TABLE DATA; Schema: public; Owner: alexander
--

COPY public.visits_diagnoses (visit_id, diagnosis_id) FROM stdin;
1	1
2	2
3	3
4	4
5	5
6	6
7	7
8	8
9	9
10	10
11	11
12	12
13	13
14	14
15	15
\.


--
-- Data for Name: visits_rooms; Type: TABLE DATA; Schema: public; Owner: alexander
--

COPY public.visits_rooms (visit_id, room_id) FROM stdin;
1	1
2	2
3	3
4	4
5	5
6	6
7	7
8	8
9	9
10	10
11	1
12	2
13	3
14	4
15	5
\.


--
-- Name: departments_department_id_seq; Type: SEQUENCE SET; Schema: public; Owner: alexander
--

SELECT pg_catalog.setval('public.departments_department_id_seq', 13, true);


--
-- Name: diagnoses_diagnosis_id_seq; Type: SEQUENCE SET; Schema: public; Owner: alexander
--

SELECT pg_catalog.setval('public.diagnoses_diagnosis_id_seq', 15, true);


--
-- Name: doctors_doctor_id_seq; Type: SEQUENCE SET; Schema: public; Owner: alexander
--

SELECT pg_catalog.setval('public.doctors_doctor_id_seq', 21, true);


--
-- Name: medications_medication_id_seq; Type: SEQUENCE SET; Schema: public; Owner: alexander
--

SELECT pg_catalog.setval('public.medications_medication_id_seq', 10, true);


--
-- Name: patients_patient_id_seq; Type: SEQUENCE SET; Schema: public; Owner: alexander
--

SELECT pg_catalog.setval('public.patients_patient_id_seq', 15, true);


--
-- Name: rooms_room_id_seq; Type: SEQUENCE SET; Schema: public; Owner: alexander
--

SELECT pg_catalog.setval('public.rooms_room_id_seq', 20, true);


--
-- Name: visits_visit_id_seq; Type: SEQUENCE SET; Schema: public; Owner: alexander
--

SELECT pg_catalog.setval('public.visits_visit_id_seq', 20, true);


--
-- Name: departments departments_department_name_key; Type: CONSTRAINT; Schema: public; Owner: alexander
--

ALTER TABLE ONLY public.departments
    ADD CONSTRAINT departments_department_name_key UNIQUE (department_name);


--
-- Name: departments departments_local_phone_number_key; Type: CONSTRAINT; Schema: public; Owner: alexander
--

ALTER TABLE ONLY public.departments
    ADD CONSTRAINT departments_local_phone_number_key UNIQUE (local_phone_number);


--
-- Name: departments departments_pkey; Type: CONSTRAINT; Schema: public; Owner: alexander
--

ALTER TABLE ONLY public.departments
    ADD CONSTRAINT departments_pkey PRIMARY KEY (department_id);


--
-- Name: departments departments_public_phone_number_key; Type: CONSTRAINT; Schema: public; Owner: alexander
--

ALTER TABLE ONLY public.departments
    ADD CONSTRAINT departments_public_phone_number_key UNIQUE (public_phone_number);


--
-- Name: diagnoses diagnoses_patient_id_key; Type: CONSTRAINT; Schema: public; Owner: alexander
--

ALTER TABLE ONLY public.diagnoses
    ADD CONSTRAINT diagnoses_patient_id_key UNIQUE (patient_id);


--
-- Name: diagnoses diagnoses_pkey; Type: CONSTRAINT; Schema: public; Owner: alexander
--

ALTER TABLE ONLY public.diagnoses
    ADD CONSTRAINT diagnoses_pkey PRIMARY KEY (diagnosis_id);


--
-- Name: doctors doctors_pkey; Type: CONSTRAINT; Schema: public; Owner: alexander
--

ALTER TABLE ONLY public.doctors
    ADD CONSTRAINT doctors_pkey PRIMARY KEY (doctor_id);


--
-- Name: medications medications_pkey; Type: CONSTRAINT; Schema: public; Owner: alexander
--

ALTER TABLE ONLY public.medications
    ADD CONSTRAINT medications_pkey PRIMARY KEY (medication_id);


--
-- Name: patients patients_phone_number_key; Type: CONSTRAINT; Schema: public; Owner: alexander
--

ALTER TABLE ONLY public.patients
    ADD CONSTRAINT patients_phone_number_key UNIQUE (phone_number);


--
-- Name: patients patients_pkey; Type: CONSTRAINT; Schema: public; Owner: alexander
--

ALTER TABLE ONLY public.patients
    ADD CONSTRAINT patients_pkey PRIMARY KEY (patient_id);


--
-- Name: rooms rooms_pkey; Type: CONSTRAINT; Schema: public; Owner: alexander
--

ALTER TABLE ONLY public.rooms
    ADD CONSTRAINT rooms_pkey PRIMARY KEY (room_id);


--
-- Name: rooms rooms_room_number_key; Type: CONSTRAINT; Schema: public; Owner: alexander
--

ALTER TABLE ONLY public.rooms
    ADD CONSTRAINT rooms_room_number_key UNIQUE (room_number);


--
-- Name: treatment_courses treatment_courses_pkey; Type: CONSTRAINT; Schema: public; Owner: alexander
--

ALTER TABLE ONLY public.treatment_courses
    ADD CONSTRAINT treatment_courses_pkey PRIMARY KEY (visit_id, medication_id);


--
-- Name: visits_diagnoses visits_diagnoses_pkey; Type: CONSTRAINT; Schema: public; Owner: alexander
--

ALTER TABLE ONLY public.visits_diagnoses
    ADD CONSTRAINT visits_diagnoses_pkey PRIMARY KEY (visit_id, diagnosis_id);


--
-- Name: visits visits_pkey; Type: CONSTRAINT; Schema: public; Owner: alexander
--

ALTER TABLE ONLY public.visits
    ADD CONSTRAINT visits_pkey PRIMARY KEY (visit_id);


--
-- Name: visits_rooms visits_rooms_pkey; Type: CONSTRAINT; Schema: public; Owner: alexander
--

ALTER TABLE ONLY public.visits_rooms
    ADD CONSTRAINT visits_rooms_pkey PRIMARY KEY (visit_id, room_id);


--
-- Name: idx_doctors_doctor_id; Type: INDEX; Schema: public; Owner: alexander
--

CREATE INDEX idx_doctors_doctor_id ON public.doctors USING btree (last_name);


--
-- Name: idx_doctors_last_name; Type: INDEX; Schema: public; Owner: alexander
--

CREATE INDEX idx_doctors_last_name ON public.doctors USING btree (last_name);


--
-- Name: idx_medications_expiration_date; Type: INDEX; Schema: public; Owner: alexander
--

CREATE INDEX idx_medications_expiration_date ON public.medications USING btree (expiration_date);


--
-- Name: idx_medications_medication_name; Type: INDEX; Schema: public; Owner: alexander
--

CREATE INDEX idx_medications_medication_name ON public.medications USING btree (medication_name);


--
-- Name: idx_patients_last_name; Type: INDEX; Schema: public; Owner: alexander
--

CREATE INDEX idx_patients_last_name ON public.patients USING btree (last_name);


--
-- Name: idx_patients_patient_id; Type: INDEX; Schema: public; Owner: alexander
--

CREATE INDEX idx_patients_patient_id ON public.patients USING btree (patient_id);


--
-- Name: idx_visits_patient_id; Type: INDEX; Schema: public; Owner: alexander
--

CREATE INDEX idx_visits_patient_id ON public.visits USING btree (patient_id);


--
-- Name: idx_visits_visit_date; Type: INDEX; Schema: public; Owner: alexander
--

CREATE INDEX idx_visits_visit_date ON public.visits USING btree (visit_date);


--
-- Name: doctor_patient_count_view _RETURN; Type: RULE; Schema: public; Owner: alexander
--

CREATE OR REPLACE VIEW public.doctor_patient_count_view AS
 SELECT d.first_name,
    d.last_name,
    count(v.patient_id) AS patient_count
   FROM (public.doctors d
     JOIN public.visits v ON ((d.doctor_id = v.doctor_id)))
  GROUP BY d.doctor_id;


--
-- Name: diagnosis_patient_count_view _RETURN; Type: RULE; Schema: public; Owner: alexander
--

CREATE OR REPLACE VIEW public.diagnosis_patient_count_view AS
 SELECT d.diagnosis_name,
    count(p.patient_id) AS patient_count
   FROM (public.diagnoses d
     JOIN public.patients p ON ((d.patient_id = p.patient_id)))
  GROUP BY d.diagnosis_id;


--
-- Name: room_patient_count_view _RETURN; Type: RULE; Schema: public; Owner: alexander
--

CREATE OR REPLACE VIEW public.room_patient_count_view AS
 SELECT r.room_number,
    count(vr.visit_id) AS patient_count
   FROM (public.rooms r
     JOIN public.visits_rooms vr ON ((r.room_id = vr.room_id)))
  GROUP BY r.room_id;


--
-- Name: medication_treatment_count_view _RETURN; Type: RULE; Schema: public; Owner: alexander
--

CREATE OR REPLACE VIEW public.medication_treatment_count_view AS
 SELECT m.medication_name,
    count(tc.visit_id) AS treatment_count
   FROM (public.medications m
     JOIN public.treatment_courses tc ON ((m.medication_id = tc.medication_id)))
  GROUP BY m.medication_id;


--
-- Name: visits_rooms check_room_capacity_trig; Type: TRIGGER; Schema: public; Owner: alexander
--

CREATE TRIGGER check_room_capacity_trig BEFORE INSERT ON public.visits_rooms FOR EACH ROW EXECUTE FUNCTION public.check_room_capacity();


--
-- Name: rooms set_number_of_beds_null_trig; Type: TRIGGER; Schema: public; Owner: alexander
--

CREATE TRIGGER set_number_of_beds_null_trig BEFORE INSERT OR UPDATE ON public.rooms FOR EACH ROW EXECUTE FUNCTION public.set_number_of_beds_null();


--
-- Name: patients update_age_trig; Type: TRIGGER; Schema: public; Owner: alexander
--

CREATE TRIGGER update_age_trig BEFORE INSERT OR UPDATE ON public.patients FOR EACH ROW EXECUTE FUNCTION public.calculate_age();


--
-- Name: doctors fkey_department_id; Type: FK CONSTRAINT; Schema: public; Owner: alexander
--

ALTER TABLE ONLY public.doctors
    ADD CONSTRAINT fkey_department_id FOREIGN KEY (department_id) REFERENCES public.departments(department_id);


--
-- Name: rooms fkey_department_id; Type: FK CONSTRAINT; Schema: public; Owner: alexander
--

ALTER TABLE ONLY public.rooms
    ADD CONSTRAINT fkey_department_id FOREIGN KEY (department_id) REFERENCES public.departments(department_id);


--
-- Name: diagnoses fkey_doctor_id; Type: FK CONSTRAINT; Schema: public; Owner: alexander
--

ALTER TABLE ONLY public.diagnoses
    ADD CONSTRAINT fkey_doctor_id FOREIGN KEY (doctor_id) REFERENCES public.doctors(doctor_id);


--
-- Name: departments fkey_head_id; Type: FK CONSTRAINT; Schema: public; Owner: alexander
--

ALTER TABLE ONLY public.departments
    ADD CONSTRAINT fkey_head_id FOREIGN KEY (head_id) REFERENCES public.doctors(doctor_id);


--
-- Name: diagnoses fkey_patient_id; Type: FK CONSTRAINT; Schema: public; Owner: alexander
--

ALTER TABLE ONLY public.diagnoses
    ADD CONSTRAINT fkey_patient_id FOREIGN KEY (patient_id) REFERENCES public.patients(patient_id);


--
-- Name: treatment_courses treatment_courses_medication_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: alexander
--

ALTER TABLE ONLY public.treatment_courses
    ADD CONSTRAINT treatment_courses_medication_id_fkey FOREIGN KEY (medication_id) REFERENCES public.medications(medication_id) ON DELETE CASCADE;


--
-- Name: treatment_courses treatment_courses_visit_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: alexander
--

ALTER TABLE ONLY public.treatment_courses
    ADD CONSTRAINT treatment_courses_visit_id_fkey FOREIGN KEY (visit_id) REFERENCES public.visits(visit_id) ON DELETE CASCADE;


--
-- Name: visits_diagnoses visits_diagnoses_diagnosis_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: alexander
--

ALTER TABLE ONLY public.visits_diagnoses
    ADD CONSTRAINT visits_diagnoses_diagnosis_id_fkey FOREIGN KEY (diagnosis_id) REFERENCES public.diagnoses(diagnosis_id) ON DELETE CASCADE;


--
-- Name: visits_diagnoses visits_diagnoses_visit_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: alexander
--

ALTER TABLE ONLY public.visits_diagnoses
    ADD CONSTRAINT visits_diagnoses_visit_id_fkey FOREIGN KEY (visit_id) REFERENCES public.visits(visit_id) ON DELETE CASCADE;


--
-- Name: visits visits_doctor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: alexander
--

ALTER TABLE ONLY public.visits
    ADD CONSTRAINT visits_doctor_id_fkey FOREIGN KEY (doctor_id) REFERENCES public.doctors(doctor_id) ON DELETE CASCADE;


--
-- Name: visits visits_patient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: alexander
--

ALTER TABLE ONLY public.visits
    ADD CONSTRAINT visits_patient_id_fkey FOREIGN KEY (patient_id) REFERENCES public.patients(patient_id) ON DELETE CASCADE;


--
-- Name: visits_rooms visits_rooms_room_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: alexander
--

ALTER TABLE ONLY public.visits_rooms
    ADD CONSTRAINT visits_rooms_room_id_fkey FOREIGN KEY (room_id) REFERENCES public.rooms(room_id) ON DELETE CASCADE;


--
-- Name: visits_rooms visits_rooms_visit_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: alexander
--

ALTER TABLE ONLY public.visits_rooms
    ADD CONSTRAINT visits_rooms_visit_id_fkey FOREIGN KEY (visit_id) REFERENCES public.visits(visit_id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

