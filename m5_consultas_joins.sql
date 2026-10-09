CREATE DATABASE Ventas_Tech_DB;
USE Ventas_Tech_DB;

DROP TABLE IF EXISTS ventas;
DROP TABLE IF EXISTS productos;
DROP TABLE IF EXISTS clientes;
DROP TABLE IF EXISTS categorias;

CREATE TABLE categorias (
	id_categoria int PRIMARY KEY,
	nombre_categoria varchar(50) NOT NULL,
	descripcion varchar (200) 
	);

CREATE TABLE clientes (
	id_cliente int PRIMARY KEY,
	nombre varchar(100) NOT NULL,
	email varchar (100) UNIQUE,
	ciudad varchar (50),
	fecha_registro DATE NOT NULL
	);

	
CREATE TABLE productos (
	id_producto int PRIMARY KEY,
	nombre_producto varchar(100) NOT NULL,
	id_categoria int NOT NULL FOREIGN KEY REFERENCES categorias (id_categoria),
	precio DECIMAL (10,2) NOT NULL,
	stock INT DEFAULT 0,
	activo TINYINT DEFAULT 1
	);

CREATE TABLE ventas (
	id_ventas int PRIMARY KEY,
	id_cliente int NOT NULL FOREIGN KEY REFERENCES clientes (id_cliente),
	id_producto int NOT NULL FOREIGN KEY REFERENCES productos (id_producto),
	cantidad INT NOT NULL,
	precio_unitario DECIMAL (10,2) NOT NULL,
	fecha_venta DATE NOT NULL
	);

INSERT INTO categorias VALUES (1, 'Computación', 'Laptops, PCs y monitores');
INSERT INTO categorias VALUES (2, 'Accesorios', 'Periféricos y complementos');
INSERT INTO categorias VALUES (3, 'Audio', 'Auriculares y parlantes');
INSERT INTO categorias VALUES (4, 'Almacenamiento', 'Discos y memorias');

INSERT INTO clientes VALUES (1, 'María López',   'maria@mail.com',   'Buenos Aires', '2024-01-05');
INSERT INTO clientes VALUES (2, 'Carlos Ruiz',   'carlos@mail.com',  'Córdoba',      '2024-01-10');
INSERT INTO clientes VALUES (3, 'Ana Gómez',     'ana@mail.com',     'Rosario',      '2024-02-01');
INSERT INTO clientes VALUES (4, 'Pedro Sanz',    'pedro@mail.com',   'Mendoza',      '2024-02-15');
INSERT INTO clientes VALUES (5, 'Laura Torres',  'laura@mail.com',   'Tucumán',      '2024-03-01');

INSERT INTO productos VALUES (1, 'Laptop Pro 15',       1, 1200.00, 15, 1);
INSERT INTO productos VALUES (2, 'Mouse Inalámbrico',   2,   28.00, 80, 1);
INSERT INTO productos VALUES (3, 'Monitor 4K 27"',      1,  450.00, 12, 1);
INSERT INTO productos VALUES (4, 'Auriculares BT Pro',  3,  120.00, 35, 1);
INSERT INTO productos VALUES (5, 'SSD Externo 1TB',     4,  130.00, 18, 1);
INSERT INTO productos VALUES (6, 'Teclado Mecánico',    2,   95.00, 40, 1);

INSERT INTO ventas VALUES (1,  1, 1, 2, 1200.00, '2024-03-05');
INSERT INTO ventas VALUES (2,  2, 2, 5,   28.00, '2024-03-06');
INSERT INTO ventas VALUES (3,  3, 3, 1,  450.00, '2024-03-07');
INSERT INTO ventas VALUES (4,  1, 4, 2,  120.00, '2024-03-08');
INSERT INTO ventas VALUES (5,  4, 5, 3,  130.00, '2024-03-10');
INSERT INTO ventas VALUES (6,  2, 6, 4,   95.00, '2024-03-11');
INSERT INTO ventas VALUES (7,  5, 1, 1, 1200.00, '2024-03-12');
INSERT INTO ventas VALUES (8,  3, 2, 8,   28.00, '2024-03-13');
INSERT INTO ventas VALUES (9,  4, 4, 1,  120.00, '2024-03-14');
INSERT INTO ventas VALUES (10, 5, 3, 2,  450.00, '2024-03-15');

SELECT * FROM categorias;
SELECT * FROM clientes;
SELECT * FROM productos;
SELECT * FROM ventas;


-- CONSULTA 1: VISTA BASE DEL PROYECTO (INNER JOIN)
-- Combinar las ventas con las tablas de clientes, productos
-- y categorias para obtener una vista enriquecida.
-- Mostrar fecha, cliente, producto, categoria, ciudad,
-- cantidad, precio unitario y total de venta.

SELECT
    v.fecha_venta,
    c.id_cliente,
    c.nombre AS nombre_cliente,
    c.ciudad,
    p.nombre_producto,
    cat.nombre_categoria AS categoria,
    v.cantidad,
    v.precio_unitario,
    v.cantidad * v.precio_unitario AS total_venta
FROM ventas AS v
INNER JOIN clientes AS c
    ON v.id_cliente = c.id_cliente
INNER JOIN productos AS p
    ON v.id_producto = p.id_producto
INNER JOIN categorias AS cat
    ON p.id_categoria = cat.id_categoria;


-- CONSULTA 2: CLIENTES SIN VENTAS (LEFT JOIN)
-- Identificar clientes registrados que no realizaron
-- ninguna compra. Mostrar nombre, email y fecha de registro.

SELECT
    c.nombre,
    c.email,
    c.fecha_registro
FROM clientes AS c
LEFT JOIN ventas AS v
    ON c.id_cliente = v.id_cliente
WHERE v.id_ventas IS NULL;


-- CONSULTA 3: PRODUCTOS SIN VENTAS (LEFT JOIN)
-- Identificar productos del catalogo que no registraron
-- ninguna venta. Mostrar producto, categoria y precio.

SELECT
    p.nombre_producto,
    cat.nombre_categoria AS categoria,
    p.precio
FROM productos AS p
INNER JOIN categorias AS cat
    ON p.id_categoria = cat.id_categoria
LEFT JOIN ventas AS v
    ON p.id_producto = v.id_producto
WHERE v.id_ventas IS NULL;


-- CONSULTA 4: CONSOLIDADO POR CANAL (UNION ALL)
-- Dividir las ventas en dos periodos de marzo de 2024.
-- Crear una columna literal para identificar cada origen.
-- Unir ambos resultados y calcular el total por periodo.

SELECT
    canal,
    SUM(total) AS total_canal
FROM (
    SELECT
        fecha_venta,
        cantidad * precio_unitario AS total,
        '05 al 10 de marzo' AS canal
    FROM ventas
    WHERE fecha_venta BETWEEN '2024-03-05' AND '2024-03-10'

    UNION ALL

    SELECT
        fecha_venta,
        cantidad * precio_unitario AS total,
        '11 al 15 de marzo' AS canal
    FROM ventas
    WHERE fecha_venta BETWEEN '2024-03-11' AND '2024-03-15'
) AS consolidado
GROUP BY canal;