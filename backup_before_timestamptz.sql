--
-- PostgreSQL database dump
--

-- Dumped from database version 17.4
-- Dumped by pg_dump version 17.4

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: attendance_status; Type: TYPE; Schema: public; Owner: samiransari
--

CREATE TYPE public.attendance_status AS ENUM (
    'present',
    'absent',
    'late'
);


ALTER TYPE public.attendance_status OWNER TO samiransari;

--
-- Name: notification_status; Type: TYPE; Schema: public; Owner: samiransari
--

CREATE TYPE public.notification_status AS ENUM (
    'pending',
    'sent',
    'failed'
);


ALTER TYPE public.notification_status OWNER TO samiransari;

--
-- Name: user_role; Type: TYPE; Schema: public; Owner: shahk
--

CREATE TYPE public.user_role AS ENUM (
    'student',
    'teacher',
    'admin'
);


ALTER TYPE public.user_role OWNER TO shahk;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: admin_logs; Type: TABLE; Schema: public; Owner: samiransari
--

CREATE TABLE public.admin_logs (
    id integer NOT NULL,
    admin_id integer NOT NULL,
    action text NOT NULL,
    target_user_id integer NOT NULL,
    class_id integer NOT NULL,
    "timestamp" timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.admin_logs OWNER TO samiransari;

--
-- Name: admin_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: samiransari
--

CREATE SEQUENCE public.admin_logs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.admin_logs_id_seq OWNER TO samiransari;

--
-- Name: admin_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: samiransari
--

ALTER SEQUENCE public.admin_logs_id_seq OWNED BY public.admin_logs.id;


--
-- Name: attendance; Type: TABLE; Schema: public; Owner: samiransari
--

CREATE TABLE public.attendance (
    id integer NOT NULL,
    student_id integer NOT NULL,
    class_id integer NOT NULL,
    "timestamp" timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    status public.attendance_status NOT NULL,
    location jsonb,
    is_manual boolean DEFAULT false,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.attendance OWNER TO samiransari;

--
-- Name: attendance_id_seq; Type: SEQUENCE; Schema: public; Owner: samiransari
--

CREATE SEQUENCE public.attendance_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.attendance_id_seq OWNER TO samiransari;

--
-- Name: attendance_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: samiransari
--

ALTER SEQUENCE public.attendance_id_seq OWNED BY public.attendance.id;


--
-- Name: class_enrollments; Type: TABLE; Schema: public; Owner: samiransari
--

CREATE TABLE public.class_enrollments (
    id integer NOT NULL,
    class_id integer NOT NULL,
    student_id integer NOT NULL,
    enrolled_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    currently_enrolled boolean DEFAULT true
);


ALTER TABLE public.class_enrollments OWNER TO samiransari;

--
-- Name: class_enrollments_id_seq; Type: SEQUENCE; Schema: public; Owner: samiransari
--

CREATE SEQUENCE public.class_enrollments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.class_enrollments_id_seq OWNER TO samiransari;

--
-- Name: class_enrollments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: samiransari
--

ALTER SEQUENCE public.class_enrollments_id_seq OWNED BY public.class_enrollments.id;


--
-- Name: classes; Type: TABLE; Schema: public; Owner: samiransari
--

CREATE TABLE public.classes (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    teacher_id integer NOT NULL,
    schedule jsonb,
    ble_id text,
    timezone text NOT NULL,
    start_date date NOT NULL,
    end_date date NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.classes OWNER TO samiransari;

--
-- Name: classes_id_seq; Type: SEQUENCE; Schema: public; Owner: samiransari
--

CREATE SEQUENCE public.classes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.classes_id_seq OWNER TO samiransari;

--
-- Name: classes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: samiransari
--

ALTER SEQUENCE public.classes_id_seq OWNED BY public.classes.id;


--
-- Name: notifications; Type: TABLE; Schema: public; Owner: samiransari
--

CREATE TABLE public.notifications (
    id integer NOT NULL,
    user_id integer NOT NULL,
    message text NOT NULL,
    status public.notification_status NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.notifications OWNER TO samiransari;

--
-- Name: notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: samiransari
--

CREATE SEQUENCE public.notifications_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.notifications_id_seq OWNER TO samiransari;

--
-- Name: notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: samiransari
--

ALTER SEQUENCE public.notifications_id_seq OWNED BY public.notifications.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: shahk
--

CREATE TABLE public.users (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    email character varying(100) NOT NULL,
    password_hash text NOT NULL,
    role public.user_role DEFAULT 'student'::public.user_role NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.users OWNER TO shahk;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: shahk
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_id_seq OWNER TO shahk;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: shahk
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: admin_logs id; Type: DEFAULT; Schema: public; Owner: samiransari
--

ALTER TABLE ONLY public.admin_logs ALTER COLUMN id SET DEFAULT nextval('public.admin_logs_id_seq'::regclass);


--
-- Name: attendance id; Type: DEFAULT; Schema: public; Owner: samiransari
--

ALTER TABLE ONLY public.attendance ALTER COLUMN id SET DEFAULT nextval('public.attendance_id_seq'::regclass);


--
-- Name: class_enrollments id; Type: DEFAULT; Schema: public; Owner: samiransari
--

ALTER TABLE ONLY public.class_enrollments ALTER COLUMN id SET DEFAULT nextval('public.class_enrollments_id_seq'::regclass);


--
-- Name: classes id; Type: DEFAULT; Schema: public; Owner: samiransari
--

ALTER TABLE ONLY public.classes ALTER COLUMN id SET DEFAULT nextval('public.classes_id_seq'::regclass);


--
-- Name: notifications id; Type: DEFAULT; Schema: public; Owner: samiransari
--

ALTER TABLE ONLY public.notifications ALTER COLUMN id SET DEFAULT nextval('public.notifications_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: shahk
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Data for Name: admin_logs; Type: TABLE DATA; Schema: public; Owner: samiransari
--

COPY public.admin_logs (id, admin_id, action, target_user_id, class_id, "timestamp") FROM stdin;
\.


--
-- Data for Name: attendance; Type: TABLE DATA; Schema: public; Owner: samiransari
--

COPY public.attendance (id, student_id, class_id, "timestamp", status, location, is_manual, created_at, updated_at) FROM stdin;
1	1	1	2026-03-18 01:06:43.401708	present	{}	f	2026-03-18 01:06:43.401708	2026-03-18 01:06:43.401708
2	1	1	2026-03-21 23:06:29.49719	present	{}	f	2026-03-21 23:06:29.49719	2026-03-21 23:06:29.49719
3	1	1	2026-03-22 17:29:37.403354	absent	{}	t	2026-03-22 17:29:37.403354	2026-03-22 22:20:54.010425
\.


--
-- Data for Name: class_enrollments; Type: TABLE DATA; Schema: public; Owner: samiransari
--

COPY public.class_enrollments (id, class_id, student_id, enrolled_at, currently_enrolled) FROM stdin;
1	1	1	2026-03-18 00:36:14.791327	t
\.


--
-- Data for Name: classes; Type: TABLE DATA; Schema: public; Owner: samiransari
--

COPY public.classes (id, name, teacher_id, schedule, ble_id, timezone, start_date, end_date, created_at) FROM stdin;
1	Senior Seminar	2	{"saturday": "00:00-23:59"}	BCPro_207342	America/Chicago	2026-01-01	2026-12-31	2026-03-18 00:26:44.073166
2	Machine Learning	2	{"Monday": ["1100-1230"], "Wednesday": ["1100-1230"]}	beaconId	America/Chicago	2026-01-01	2026-05-10	2026-03-21 23:24:09.834538
\.


--
-- Data for Name: notifications; Type: TABLE DATA; Schema: public; Owner: samiransari
--

COPY public.notifications (id, user_id, message, status, created_at) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: shahk
--

COPY public.users (id, name, email, password_hash, role, created_at) FROM stdin;
1	Krishna	Kpkanu04@fisk.edu	ai99Oi5xJ76GqpXoKkQ1FA$epz01qUOTR+uOxci1M+OMQWdH19MF65Nq8a+f/uIYmU	student	2026-03-17 16:00:57.162018
2	Professor Shah	teacher@test.com	ntHqjLe5H2xtqoJivw7MkQ$1+uJFRP2ymDVRRVZ1lZNB5a+Q8IJWaijxAiCoMxzhbo	teacher	2026-03-18 00:03:16.71893
\.


--
-- Name: admin_logs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: samiransari
--

SELECT pg_catalog.setval('public.admin_logs_id_seq', 1, false);


--
-- Name: attendance_id_seq; Type: SEQUENCE SET; Schema: public; Owner: samiransari
--

SELECT pg_catalog.setval('public.attendance_id_seq', 3, true);


--
-- Name: class_enrollments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: samiransari
--

SELECT pg_catalog.setval('public.class_enrollments_id_seq', 1, true);


--
-- Name: classes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: samiransari
--

SELECT pg_catalog.setval('public.classes_id_seq', 2, true);


--
-- Name: notifications_id_seq; Type: SEQUENCE SET; Schema: public; Owner: samiransari
--

SELECT pg_catalog.setval('public.notifications_id_seq', 1, false);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: shahk
--

SELECT pg_catalog.setval('public.users_id_seq', 2, true);


--
-- Name: admin_logs admin_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: samiransari
--

ALTER TABLE ONLY public.admin_logs
    ADD CONSTRAINT admin_logs_pkey PRIMARY KEY (id);


--
-- Name: attendance attendance_pkey; Type: CONSTRAINT; Schema: public; Owner: samiransari
--

ALTER TABLE ONLY public.attendance
    ADD CONSTRAINT attendance_pkey PRIMARY KEY (id);


--
-- Name: class_enrollments class_enrollments_class_id_student_id_key; Type: CONSTRAINT; Schema: public; Owner: samiransari
--

ALTER TABLE ONLY public.class_enrollments
    ADD CONSTRAINT class_enrollments_class_id_student_id_key UNIQUE (class_id, student_id);


--
-- Name: class_enrollments class_enrollments_pkey; Type: CONSTRAINT; Schema: public; Owner: samiransari
--

ALTER TABLE ONLY public.class_enrollments
    ADD CONSTRAINT class_enrollments_pkey PRIMARY KEY (id);


--
-- Name: classes classes_pkey; Type: CONSTRAINT; Schema: public; Owner: samiransari
--

ALTER TABLE ONLY public.classes
    ADD CONSTRAINT classes_pkey PRIMARY KEY (id);


--
-- Name: notifications notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: samiransari
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: shahk
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: shahk
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: admin_logs admin_logs_admin_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: samiransari
--

ALTER TABLE ONLY public.admin_logs
    ADD CONSTRAINT admin_logs_admin_id_fkey FOREIGN KEY (admin_id) REFERENCES public.users(id);


--
-- Name: admin_logs admin_logs_class_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: samiransari
--

ALTER TABLE ONLY public.admin_logs
    ADD CONSTRAINT admin_logs_class_id_fkey FOREIGN KEY (class_id) REFERENCES public.classes(id);


--
-- Name: admin_logs admin_logs_target_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: samiransari
--

ALTER TABLE ONLY public.admin_logs
    ADD CONSTRAINT admin_logs_target_user_id_fkey FOREIGN KEY (target_user_id) REFERENCES public.users(id);


--
-- Name: attendance attendance_class_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: samiransari
--

ALTER TABLE ONLY public.attendance
    ADD CONSTRAINT attendance_class_id_fkey FOREIGN KEY (class_id) REFERENCES public.classes(id) ON DELETE CASCADE;


--
-- Name: attendance attendance_student_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: samiransari
--

ALTER TABLE ONLY public.attendance
    ADD CONSTRAINT attendance_student_id_fkey FOREIGN KEY (student_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: class_enrollments class_enrollments_class_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: samiransari
--

ALTER TABLE ONLY public.class_enrollments
    ADD CONSTRAINT class_enrollments_class_id_fkey FOREIGN KEY (class_id) REFERENCES public.classes(id) ON DELETE CASCADE;


--
-- Name: class_enrollments class_enrollments_student_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: samiransari
--

ALTER TABLE ONLY public.class_enrollments
    ADD CONSTRAINT class_enrollments_student_id_fkey FOREIGN KEY (student_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: classes classes_teacher_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: samiransari
--

ALTER TABLE ONLY public.classes
    ADD CONSTRAINT classes_teacher_id_fkey FOREIGN KEY (teacher_id) REFERENCES public.users(id);


--
-- Name: notifications notifications_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: samiransari
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: pg_database_owner
--

GRANT ALL ON SCHEMA public TO samiransari;


--
-- PostgreSQL database dump complete
--

