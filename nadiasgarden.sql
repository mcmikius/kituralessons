--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.4
-- Dumped by pg_dump version 9.6.3

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: customers; Type: TABLE; Schema: public; Owner: mohammadazam
--

CREATE TABLE customers (
    id integer NOT NULL,
    title text
);


ALTER TABLE customers OWNER TO mohammadazam;

--
-- Name: customers_id_seq; Type: SEQUENCE; Schema: public; Owner: mohammadazam
--

CREATE SEQUENCE customers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE customers_id_seq OWNER TO mohammadazam;

--
-- Name: customers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: mohammadazam
--

ALTER SEQUENCE customers_id_seq OWNED BY customers.id;


--
-- Name: dishes; Type: TABLE; Schema: public; Owner: mohammadazam
--

CREATE TABLE dishes (
    id integer NOT NULL,
    title text,
    price double precision,
    course text,
    description text,
    "imageURL" text
);


ALTER TABLE dishes OWNER TO mohammadazam;

--
-- Name: dishes_id_seq; Type: SEQUENCE; Schema: public; Owner: mohammadazam
--

CREATE SEQUENCE dishes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE dishes_id_seq OWNER TO mohammadazam;

--
-- Name: dishes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: mohammadazam
--

ALTER SEQUENCE dishes_id_seq OWNED BY dishes.id;


--
-- Name: fluent; Type: TABLE; Schema: public; Owner: bob
--

CREATE TABLE fluent (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    batch bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


ALTER TABLE fluent OWNER TO bob;

--
-- Name: fluent_id_seq; Type: SEQUENCE; Schema: public; Owner: bob
--

CREATE SEQUENCE fluent_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE fluent_id_seq OWNER TO bob;

--
-- Name: fluent_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: bob
--

ALTER SEQUENCE fluent_id_seq OWNED BY fluent.id;


--
-- Name: posts; Type: TABLE; Schema: public; Owner: bob
--

CREATE TABLE posts (
    id integer NOT NULL,
    content character varying(255) NOT NULL
);


ALTER TABLE posts OWNER TO bob;

--
-- Name: posts_id_seq; Type: SEQUENCE; Schema: public; Owner: bob
--

CREATE SEQUENCE posts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE posts_id_seq OWNER TO bob;

--
-- Name: posts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: bob
--

ALTER SEQUENCE posts_id_seq OWNED BY posts.id;


--
-- Name: tasks; Type: TABLE; Schema: public; Owner: bob
--

CREATE TABLE tasks (
    id integer NOT NULL,
    title character varying(255) NOT NULL
);


ALTER TABLE tasks OWNER TO bob;

--
-- Name: tasks_id_seq; Type: SEQUENCE; Schema: public; Owner: bob
--

CREATE SEQUENCE tasks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE tasks_id_seq OWNER TO bob;

--
-- Name: tasks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: bob
--

ALTER SEQUENCE tasks_id_seq OWNED BY tasks.id;


--
-- Name: customers id; Type: DEFAULT; Schema: public; Owner: mohammadazam
--

ALTER TABLE ONLY customers ALTER COLUMN id SET DEFAULT nextval('customers_id_seq'::regclass);


--
-- Name: dishes id; Type: DEFAULT; Schema: public; Owner: mohammadazam
--

ALTER TABLE ONLY dishes ALTER COLUMN id SET DEFAULT nextval('dishes_id_seq'::regclass);


--
-- Name: fluent id; Type: DEFAULT; Schema: public; Owner: bob
--

ALTER TABLE ONLY fluent ALTER COLUMN id SET DEFAULT nextval('fluent_id_seq'::regclass);


--
-- Name: posts id; Type: DEFAULT; Schema: public; Owner: bob
--

ALTER TABLE ONLY posts ALTER COLUMN id SET DEFAULT nextval('posts_id_seq'::regclass);


--
-- Name: tasks id; Type: DEFAULT; Schema: public; Owner: bob
--

ALTER TABLE ONLY tasks ALTER COLUMN id SET DEFAULT nextval('tasks_id_seq'::regclass);


--
-- Data for Name: customers; Type: TABLE DATA; Schema: public; Owner: mohammadazam
--

COPY customers (id, title) FROM stdin;
1	Wash the dishes
\.


--
-- Name: customers_id_seq; Type: SEQUENCE SET; Schema: public; Owner: mohammadazam
--

SELECT pg_catalog.setval('customers_id_seq', 1, true);


--
-- Data for Name: dishes; Type: TABLE DATA; Schema: public; Owner: mohammadazam
--

COPY dishes (id, title, price, course, description, "imageURL") FROM stdin;
1	Panko Stuffed Mushrooms	7	starters	Large mushroom caps are filled a savory cream cheese, bacon and panko breadcrumb stuffing, topped with cheddar cheese.	PankoStuffedMushrooms.png
2	Mini Cheeseburgers	8	starters	These mini cheeseburgers are served on a fresh baked pretzel bun with lettuce, tomato, avocado, and your choice of cheese.	MiniCheeseburgers.png
3	Cheesecake	9	dessert	Our New York Style Cheesecake is rich, smooth, and creamy. Available in various flavors, and with seasonal fruit toppings.	Cheesecake.png
4	Chocolate Chip Brownie	6	dessert	A warm chocolate chip brownie served with chocolate or vanilla ice cream and rich chocolate sauce.	ChocolateChipBrownie.png
\.


--
-- Name: dishes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: mohammadazam
--

SELECT pg_catalog.setval('dishes_id_seq', 4, true);


--
-- Data for Name: fluent; Type: TABLE DATA; Schema: public; Owner: bob
--

COPY fluent (id, name, batch, created_at, updated_at) FROM stdin;
1	Post	1	2017-08-13 18:25:05.641749-05	2017-08-13 18:25:05.641749-05
2	Task	1	2017-08-13 18:25:05.650257-05	2017-08-13 18:25:05.650257-05
\.


--
-- Name: fluent_id_seq; Type: SEQUENCE SET; Schema: public; Owner: bob
--

SELECT pg_catalog.setval('fluent_id_seq', 2, true);


--
-- Data for Name: posts; Type: TABLE DATA; Schema: public; Owner: bob
--

COPY posts (id, content) FROM stdin;
\.


--
-- Name: posts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: bob
--

SELECT pg_catalog.setval('posts_id_seq', 1, false);


--
-- Data for Name: tasks; Type: TABLE DATA; Schema: public; Owner: bob
--

COPY tasks (id, title) FROM stdin;
1	Mail the envelopes
2	Do groceries
4	Cook dinner
5	Clean the car
\.


--
-- Name: tasks_id_seq; Type: SEQUENCE SET; Schema: public; Owner: bob
--

SELECT pg_catalog.setval('tasks_id_seq', 5, true);


--
-- Name: customers customers_pkey; Type: CONSTRAINT; Schema: public; Owner: mohammadazam
--

ALTER TABLE ONLY customers
    ADD CONSTRAINT customers_pkey PRIMARY KEY (id);


--
-- Name: dishes dishes_pkey; Type: CONSTRAINT; Schema: public; Owner: mohammadazam
--

ALTER TABLE ONLY dishes
    ADD CONSTRAINT dishes_pkey PRIMARY KEY (id);


--
-- Name: fluent fluent_pkey; Type: CONSTRAINT; Schema: public; Owner: bob
--

ALTER TABLE ONLY fluent
    ADD CONSTRAINT fluent_pkey PRIMARY KEY (id);


--
-- Name: posts posts_pkey; Type: CONSTRAINT; Schema: public; Owner: bob
--

ALTER TABLE ONLY posts
    ADD CONSTRAINT posts_pkey PRIMARY KEY (id);


--
-- Name: tasks tasks_pkey; Type: CONSTRAINT; Schema: public; Owner: bob
--

ALTER TABLE ONLY tasks
    ADD CONSTRAINT tasks_pkey PRIMARY KEY (id);


--
-- PostgreSQL database dump complete
--

