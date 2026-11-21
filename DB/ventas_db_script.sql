-- =========================================================
-- Base de datos: ventas_db  (PostgreSQL)
-- Script de creación de tablas y carga de 10 registros por tabla
-- =========================================================

-- CREATE DATABASE ventas_db;
-- \c ventas_db

DROP TABLE IF EXISTS ventas;
DROP TABLE IF EXISTS productos;
DROP TABLE IF EXISTS categorias;
DROP TABLE IF EXISTS clientes;
DROP TABLE IF EXISTS vendedores;

-- ---------------------------------------------------------
-- Tablas
-- ---------------------------------------------------------
CREATE TABLE categorias (
    id_categoria     SERIAL PRIMARY KEY,
    nombre_categoria VARCHAR(60)  NOT NULL UNIQUE,
    descripcion      VARCHAR(200)
);

CREATE TABLE productos (
    id_producto     SERIAL PRIMARY KEY,
    nombre_producto VARCHAR(100)  NOT NULL,
    id_categoria    INTEGER       NOT NULL,
    precio_lista    NUMERIC(12,2) NOT NULL CHECK (precio_lista > 0),
    stock           INTEGER       NOT NULL DEFAULT 0 CHECK (stock >= 0),
    CONSTRAINT fk_productos_categoria
        FOREIGN KEY (id_categoria) REFERENCES categorias (id_categoria)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE clientes (
    id_cliente     SERIAL PRIMARY KEY,
    nombre_cliente VARCHAR(100) NOT NULL,
    ciudad         VARCHAR(60)  NOT NULL,
    segmento       VARCHAR(30)  NOT NULL
        CHECK (segmento IN ('Persona natural', 'Pyme', 'Corporativo')),
    email          VARCHAR(120) UNIQUE
);

CREATE TABLE vendedores (
    id_vendedor     SERIAL PRIMARY KEY,
    nombre_vendedor VARCHAR(100)  NOT NULL,
    zona            VARCHAR(30)   NOT NULL,
    meta_mensual    NUMERIC(14,2) NOT NULL CHECK (meta_mensual >= 0)
);

CREATE TABLE ventas (
    id_venta        SERIAL PRIMARY KEY,
    fecha           DATE          NOT NULL,
    id_cliente      INTEGER       NOT NULL,
    id_producto     INTEGER       NOT NULL,
    id_vendedor     INTEGER       NOT NULL,
    cantidad        INTEGER       NOT NULL CHECK (cantidad > 0),
    precio_unitario NUMERIC(12,2) NOT NULL CHECK (precio_unitario > 0),
    descuento       NUMERIC(4,2)  NOT NULL DEFAULT 0
        CHECK (descuento >= 0 AND descuento <= 1),   -- fracción: 0.10 = 10 %
    CONSTRAINT fk_ventas_cliente
        FOREIGN KEY (id_cliente)  REFERENCES clientes (id_cliente)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_ventas_producto
        FOREIGN KEY (id_producto) REFERENCES productos (id_producto)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_ventas_vendedor
        FOREIGN KEY (id_vendedor) REFERENCES vendedores (id_vendedor)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE INDEX idx_productos_categoria ON productos (id_categoria);
CREATE INDEX idx_ventas_cliente      ON ventas (id_cliente);
CREATE INDEX idx_ventas_producto     ON ventas (id_producto);
CREATE INDEX idx_ventas_vendedor     ON ventas (id_vendedor);
CREATE INDEX idx_ventas_fecha        ON ventas (fecha);

-- ---------------------------------------------------------
-- Datos (10 registros por tabla)
-- ---------------------------------------------------------
INSERT INTO categorias (nombre_categoria, descripcion) VALUES
('Computadores',     'Portátiles y equipos de escritorio'),
('Celulares',        'Teléfonos inteligentes y accesorios móviles'),
('Periféricos',      'Teclados, mouse y dispositivos de entrada'),
('Monitores',        'Pantallas y monitores para oficina y gaming'),
('Impresoras',       'Impresoras láser, de tinta y multifuncionales'),
('Almacenamiento',   'Discos duros, SSD y memorias USB'),
('Redes',            'Routers, switches y antenas Wi-Fi'),
('Audio',            'Audífonos, parlantes y micrófonos'),
('Software',         'Licencias de sistemas operativos y ofimática'),
('Muebles de oficina','Sillas y escritorios ergonómicos');

INSERT INTO productos (nombre_producto, id_categoria, precio_lista, stock) VALUES
('Portátil Lenovo IdeaPad 5',        1, 3200000.00,  15),
('Smartphone Samsung Galaxy A55',    2, 1650000.00,  40),
('Teclado mecánico Logitech G413',   3,  320000.00,  60),
('Monitor LG 27" IPS',               4,  980000.00,  25),
('Impresora Epson EcoTank L3250',    5,  850000.00,  18),
('SSD Kingston 1 TB NVMe',           6,  360000.00,  70),
('Router TP-Link Archer AX55',       7,  420000.00,  30),
('Audífonos Sony WH-CH720N',         8,  540000.00,  35),
('Licencia Microsoft 365 Empresa',   9,  480000.00, 100),
('Silla ergonómica ejecutiva',      10,  750000.00,  12);

INSERT INTO clientes (nombre_cliente, ciudad, segmento, email) VALUES
('Laura Gómez Rojas',              'Neiva',        'Persona natural', 'laura.gomez@mail.com'),
('Distribuidora El Huila S.A.S.',  'Neiva',        'Pyme',            'compras@elhuila.com.co'),
('Carlos Andrés Perdomo',          'Pitalito',     'Persona natural', 'carlos.perdomo@mail.com'),
('Clínica San Rafael',             'Bogotá',       'Corporativo',     'sistemas@clinicasanrafael.co'),
('Agroinsumos del Sur Ltda.',      'Garzón',       'Pyme',            'gerencia@agrosur.co'),
('María Fernanda Cuéllar',         'Cali',         'Persona natural', 'mafe.cuellar@mail.com'),
('Constructora Andina S.A.',       'Medellín',     'Corporativo',     'ti@constructoraandina.com'),
('Papelería La Estudiantil',       'La Plata',     'Pyme',            'ventas@laestudiantil.co'),
('Julián Esteban Trujillo',        'Ibagué',       'Persona natural', 'julian.trujillo@mail.com'),
('Universidad Regional del Sur',   'Florencia',    'Corporativo',     'adquisiciones@urs.edu.co');

INSERT INTO vendedores (nombre_vendedor, zona, meta_mensual) VALUES
('Andrés Felipe Motta',    'Norte',   25000000.00),
('Diana Marcela Polanía',  'Sur',     20000000.00),
('Jorge Iván Charry',      'Centro',  30000000.00),
('Paola Andrea Vargas',    'Oriente', 18000000.00),
('Sebastián Ramírez',      'Occidente',22000000.00),
('Natalia Sánchez Losada', 'Norte',   24000000.00),
('Ricardo Bahamón',        'Sur',     19000000.00),
('Camila Ortiz Tovar',     'Centro',  28000000.00),
('Hernán Darío Quintero',  'Oriente', 17000000.00),
('Valentina Cabrera',      'Occidente',21000000.00);

INSERT INTO ventas (fecha, id_cliente, id_producto, id_vendedor, cantidad, precio_unitario, descuento) VALUES
('2026-09-01',  1,  2,  1,  1, 1650000.00, 0.00),
('2026-09-03',  2,  6,  3, 10,  360000.00, 0.10),
('2026-09-05',  4,  1,  8,  5, 3200000.00, 0.12),
('2026-09-08',  3,  8,  2,  1,  540000.00, 0.05),
('2026-09-12',  7,  4,  5,  8,  980000.00, 0.08),
('2026-09-15',  5,  5,  7,  2,  850000.00, 0.00),
('2026-09-19', 10,  9,  4, 40,  480000.00, 0.15),
('2026-09-22',  6,  3,  10, 2,  320000.00, 0.00),
('2026-09-26',  8,  7,  6,  3,  420000.00, 0.05),
('2026-09-30',  9, 10,  9,  1,  750000.00, 0.00);
