--
-- PostgreSQL database dump
--

\restrict v4jYgUAmaQuZd1QQ4ZFfcl7xOfgyjeNhlrp74UqllMyRodSbkiI4FdtrBatqyXs

-- Dumped from database version 18.1
-- Dumped by pg_dump version 18.1

-- Started on 2026-11-20 19:20:35

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

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 220 (class 1259 OID 33082)
-- Name: categorias; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.categorias (
    id_categoria integer NOT NULL,
    nombre_categoria character varying(60) NOT NULL,
    descripcion character varying(200)
);


ALTER TABLE public.categorias OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 33081)
-- Name: categorias_id_categoria_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.categorias_id_categoria_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.categorias_id_categoria_seq OWNER TO postgres;

--
-- TOC entry 5070 (class 0 OID 0)
-- Dependencies: 219
-- Name: categorias_id_categoria_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.categorias_id_categoria_seq OWNED BY public.categorias.id_categoria;


--
-- TOC entry 224 (class 1259 OID 33113)
-- Name: clientes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.clientes (
    id_cliente integer NOT NULL,
    nombre_cliente character varying(100) NOT NULL,
    ciudad character varying(60) NOT NULL,
    segmento character varying(30) NOT NULL,
    email character varying(120),
    CONSTRAINT clientes_segmento_check CHECK (((segmento)::text = ANY ((ARRAY['Persona natural'::character varying, 'Pyme'::character varying, 'Corporativo'::character varying])::text[])))
);


ALTER TABLE public.clientes OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 33112)
-- Name: clientes_id_cliente_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.clientes_id_cliente_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.clientes_id_cliente_seq OWNER TO postgres;

--
-- TOC entry 5071 (class 0 OID 0)
-- Dependencies: 223
-- Name: clientes_id_cliente_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.clientes_id_cliente_seq OWNED BY public.clientes.id_cliente;


--
-- TOC entry 222 (class 1259 OID 33093)
-- Name: productos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.productos (
    id_producto integer NOT NULL,
    nombre_producto character varying(100) NOT NULL,
    id_categoria integer NOT NULL,
    precio_lista numeric(12,2) NOT NULL,
    stock integer DEFAULT 0 NOT NULL,
    CONSTRAINT productos_precio_lista_check CHECK ((precio_lista > (0)::numeric)),
    CONSTRAINT productos_stock_check CHECK ((stock >= 0))
);


ALTER TABLE public.productos OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 33092)
-- Name: productos_id_producto_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.productos_id_producto_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.productos_id_producto_seq OWNER TO postgres;

--
-- TOC entry 5072 (class 0 OID 0)
-- Dependencies: 221
-- Name: productos_id_producto_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.productos_id_producto_seq OWNED BY public.productos.id_producto;


--
-- TOC entry 226 (class 1259 OID 33127)
-- Name: vendedores; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.vendedores (
    id_vendedor integer NOT NULL,
    nombre_vendedor character varying(100) NOT NULL,
    zona character varying(30) NOT NULL,
    meta_mensual numeric(14,2) NOT NULL,
    CONSTRAINT vendedores_meta_mensual_check CHECK ((meta_mensual >= (0)::numeric))
);


ALTER TABLE public.vendedores OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 33126)
-- Name: vendedores_id_vendedor_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.vendedores_id_vendedor_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.vendedores_id_vendedor_seq OWNER TO postgres;

--
-- TOC entry 5073 (class 0 OID 0)
-- Dependencies: 225
-- Name: vendedores_id_vendedor_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.vendedores_id_vendedor_seq OWNED BY public.vendedores.id_vendedor;


--
-- TOC entry 228 (class 1259 OID 33139)
-- Name: ventas; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ventas (
    id_venta integer NOT NULL,
    fecha date NOT NULL,
    id_cliente integer NOT NULL,
    id_producto integer NOT NULL,
    id_vendedor integer NOT NULL,
    cantidad integer NOT NULL,
    precio_unitario numeric(12,2) NOT NULL,
    descuento numeric(4,2) DEFAULT 0 NOT NULL,
    CONSTRAINT ventas_cantidad_check CHECK ((cantidad > 0)),
    CONSTRAINT ventas_descuento_check CHECK (((descuento >= (0)::numeric) AND (descuento <= (1)::numeric))),
    CONSTRAINT ventas_precio_unitario_check CHECK ((precio_unitario > (0)::numeric))
);


ALTER TABLE public.ventas OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 33138)
-- Name: ventas_id_venta_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.ventas_id_venta_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.ventas_id_venta_seq OWNER TO postgres;

--
-- TOC entry 5074 (class 0 OID 0)
-- Dependencies: 227
-- Name: ventas_id_venta_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.ventas_id_venta_seq OWNED BY public.ventas.id_venta;


--
-- TOC entry 4876 (class 2604 OID 33085)
-- Name: categorias id_categoria; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categorias ALTER COLUMN id_categoria SET DEFAULT nextval('public.categorias_id_categoria_seq'::regclass);


--
-- TOC entry 4879 (class 2604 OID 33116)
-- Name: clientes id_cliente; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clientes ALTER COLUMN id_cliente SET DEFAULT nextval('public.clientes_id_cliente_seq'::regclass);


--
-- TOC entry 4877 (class 2604 OID 33096)
-- Name: productos id_producto; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.productos ALTER COLUMN id_producto SET DEFAULT nextval('public.productos_id_producto_seq'::regclass);


--
-- TOC entry 4880 (class 2604 OID 33130)
-- Name: vendedores id_vendedor; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vendedores ALTER COLUMN id_vendedor SET DEFAULT nextval('public.vendedores_id_vendedor_seq'::regclass);


--
-- TOC entry 4881 (class 2604 OID 33142)
-- Name: ventas id_venta; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ventas ALTER COLUMN id_venta SET DEFAULT nextval('public.ventas_id_venta_seq'::regclass);


--
-- TOC entry 5056 (class 0 OID 33082)
-- Dependencies: 220
-- Data for Name: categorias; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.categorias (id_categoria, nombre_categoria, descripcion) FROM stdin;
1	Gambas Neocaridina	Camarones enanos de agua dulce fáciles de cuidar
2	Gambas Caridina	Gambas exóticas de parámetros específicos
3	Caracoles Limpiadores	Moluscos controladores de algas en cristales
4	Caracoles Ornamentales	Caracoles exóticos de colores y formas únicas
5	Plantas de Tallo	Plantas acuáticas de crecimiento rápido
6	Plantas Tapizantes	Plantas bajas para cubrir el sustrato
7	Plantas Flotantes	Plantas de superficie que absorben nitratos
8	Musgos Acuáticos	Musgos ideales para enraizar en troncos y rocas
9	Helechos y Anubias	Plantas epífitas de bajos requerimientos lumínicos
10	Cangrejos y Microfauna	Invertebrados enanos pacíficos para nanoacuarios
\.


--
-- TOC entry 5060 (class 0 OID 33113)
-- Dependencies: 224
-- Data for Name: clientes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.clientes (id_cliente, nombre_cliente, ciudad, segmento, email) FROM stdin;
1	Laura Gómez Rojas	Neiva	Persona natural	laura.gomez@mail.com
2	Acuarios del Huila S.A.S.	Neiva	Pyme	compras@acuarioshuila.com.co
3	Carlos Andrés Perdomo	Pitalito	Persona natural	carlos.perdomo@mail.com
4	Bioparque Acuático Central	Bogotá	Corporativo	logistica@bioparquecentral.co
5	Tienda Mascotas Exóticas Sur	Garzón	Pyme	pedidos@exoticassur.co
6	María Fernanda Cuéllar	Cali	Persona natural	mafe.cuellar@mail.com
7	Hotel Resort Río Magdalena	Rivera	Corporativo	mantenimiento@hotelmagdalena.com
8	Paisajismo Acuático Neiva	Neiva	Pyme	contacto@aquascapingneiva.co
9	Julián Esteban Trujillo	Ibagué	Persona natural	julian.trujillo@mail.com
10	Laboratorio Hidrobiológico Sur	Florencia	Corporativo	adquisiciones@labhidro.edu.co
\.


--
-- TOC entry 5058 (class 0 OID 33093)
-- Dependencies: 222
-- Data for Name: productos; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.productos (id_producto, nombre_producto, id_categoria, precio_lista, stock) FROM stdin;
1	Gamba Red Cherry (Neocaridina)	1	6000.00	120
2	Gamba Blue Dream Velvet	1	14000.00	65
3	Gamba Crystal Red (Caridina)	2	22000.00	30
4	Caracol Cebra Neritina	3	8000.00	50
5	Caracol Asesino Helena	4	7500.00	40
6	Planta Ambulia (Limnophila)	5	4500.00	90
7	Planta Montecarlo (Tapizante)	6	15000.00	25
8	Lechuga de Agua (Pistia)	7	3000.00	150
9	Musgo de Java (Porción 5x5 cm)	8	9000.00	45
10	Anubia Nana Petite	9	18000.00	20
\.


--
-- TOC entry 5062 (class 0 OID 33127)
-- Dependencies: 226
-- Data for Name: vendedores; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.vendedores (id_vendedor, nombre_vendedor, zona, meta_mensual) FROM stdin;
1	Andrés Felipe Motta	Norte	2500000.00
2	Diana Marcela Polanía	Sur	2000000.00
3	Jorge Iván Charry	Centro	3000000.00
4	Paola Andrea Vargas	Oriente	1800000.00
5	Sebastián Ramírez	Occidente	2200000.00
6	Natalia Sánchez Losada	Norte	2400000.00
7	Ricardo Bahamón	Sur	1900000.00
8	Camila Ortiz Tovar	Centro	2800000.00
9	Hernán Darío Quintero	Oriente	1700000.00
10	Valentina Cabrera	Occidente	2100000.00
\.


--
-- TOC entry 5064 (class 0 OID 33139)
-- Dependencies: 228
-- Data for Name: ventas; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ventas (id_venta, fecha, id_cliente, id_producto, id_vendedor, cantidad, precio_unitario, descuento) FROM stdin;
1	2026-11-01	1	1	1	10	6000.00	0.05
2	2026-11-02	2	2	2	15	14000.00	0.10
3	2026-11-03	3	4	3	4	8000.00	0.00
4	2026-11-04	4	3	1	20	22000.00	0.15
5	2026-11-05	5	5	4	12	7500.00	0.05
6	2026-11-06	6	6	5	6	4500.00	0.00
7	2026-11-07	7	7	2	8	15000.00	0.10
8	2026-11-08	8	9	3	10	9000.00	0.05
9	2026-11-09	9	8	4	5	3000.00	0.00
10	2026-11-10	10	10	5	6	18000.00	0.10
\.


--
-- TOC entry 5075 (class 0 OID 0)
-- Dependencies: 219
-- Name: categorias_id_categoria_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.categorias_id_categoria_seq', 10, true);


--
-- TOC entry 5076 (class 0 OID 0)
-- Dependencies: 223
-- Name: clientes_id_cliente_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.clientes_id_cliente_seq', 10, true);


--
-- TOC entry 5077 (class 0 OID 0)
-- Dependencies: 221
-- Name: productos_id_producto_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.productos_id_producto_seq', 10, true);


--
-- TOC entry 5078 (class 0 OID 0)
-- Dependencies: 225
-- Name: vendedores_id_vendedor_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.vendedores_id_vendedor_seq', 10, true);


--
-- TOC entry 5079 (class 0 OID 0)
-- Dependencies: 227
-- Name: ventas_id_venta_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ventas_id_venta_seq', 10, true);


--
-- TOC entry 4891 (class 2606 OID 33091)
-- Name: categorias categorias_nombre_categoria_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categorias
    ADD CONSTRAINT categorias_nombre_categoria_key UNIQUE (nombre_categoria);


--
-- TOC entry 4893 (class 2606 OID 33089)
-- Name: categorias categorias_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categorias
    ADD CONSTRAINT categorias_pkey PRIMARY KEY (id_categoria);


--
-- TOC entry 4897 (class 2606 OID 33125)
-- Name: clientes clientes_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clientes
    ADD CONSTRAINT clientes_email_key UNIQUE (email);


--
-- TOC entry 4899 (class 2606 OID 33123)
-- Name: clientes clientes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clientes
    ADD CONSTRAINT clientes_pkey PRIMARY KEY (id_cliente);


--
-- TOC entry 4895 (class 2606 OID 33106)
-- Name: productos productos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.productos
    ADD CONSTRAINT productos_pkey PRIMARY KEY (id_producto);


--
-- TOC entry 4901 (class 2606 OID 33137)
-- Name: vendedores vendedores_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vendedores
    ADD CONSTRAINT vendedores_pkey PRIMARY KEY (id_vendedor);


--
-- TOC entry 4903 (class 2606 OID 33156)
-- Name: ventas ventas_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ventas
    ADD CONSTRAINT ventas_pkey PRIMARY KEY (id_venta);


--
-- TOC entry 4904 (class 2606 OID 33107)
-- Name: productos fk_productos_categoria; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.productos
    ADD CONSTRAINT fk_productos_categoria FOREIGN KEY (id_categoria) REFERENCES public.categorias(id_categoria) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 4905 (class 2606 OID 33157)
-- Name: ventas fk_ventas_cliente; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ventas
    ADD CONSTRAINT fk_ventas_cliente FOREIGN KEY (id_cliente) REFERENCES public.clientes(id_cliente) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 4906 (class 2606 OID 33162)
-- Name: ventas fk_ventas_producto; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ventas
    ADD CONSTRAINT fk_ventas_producto FOREIGN KEY (id_producto) REFERENCES public.productos(id_producto) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 4907 (class 2606 OID 33167)
-- Name: ventas fk_ventas_vendedor; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ventas
    ADD CONSTRAINT fk_ventas_vendedor FOREIGN KEY (id_vendedor) REFERENCES public.vendedores(id_vendedor) ON UPDATE CASCADE ON DELETE RESTRICT;


-- Completed on 2026-11-20 19:20:35

--
-- PostgreSQL database dump complete
--

\unrestrict v4jYgUAmaQuZd1QQ4ZFfcl7xOfgyjeNhlrp74UqllMyRodSbkiI4FdtrBatqyXs

