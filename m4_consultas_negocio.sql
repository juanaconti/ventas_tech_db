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

/*
Consulta 1 — Resumen ejecutivo mensual Total facturado, cantidad de pedidos y ticket promedio, agrupados por mes. Calculá el total como cantidad * precio_unitario. Usá alias descriptivos en español y agrupá por mes con EXTRACT(MONTH FROM fecha_venta).

Consulta 2 — Ranking de productos Top 5 de id_producto por total facturado, mostrando las unidades vendidas (SUM(cantidad)) y el total generado. Usá GROUP BY id_producto, ORDER BY y limitá el resultado a 5.

Consulta 3 — Clientes recurrentes id_cliente que hayan realizado más de un pedido, mostrando la cantidad de pedidos y el total gastado. Usá GROUP BY id_cliente y HAVING COUNT(*) > 1.

Consulta 4 — Meses por encima/por debajo del promedio Total facturado por mes, con una columna adicional que etiquete con CASE WHEN si ese mes quedó 'Por encima' o 'Por debajo' del promedio mensual general.

Bloque de cierre Al final del archivo agregá un bloque de comentarios -- con 3 hallazgos concretos que encontraste al revisar los resultados. Por ejemplo: "El producto 1 concentra el 40% de la facturación del trimestre."
*/

-- CONSULTA 1
SELECT 
    MONTH(fecha_venta) AS mes,
    SUM(cantidad * precio_unitario) AS total_facturado,
    COUNT(*) AS cantidad_pedidos,
    AVG(cantidad * precio_unitario) AS ticket_promedio
FROM ventas
GROUP BY MONTH(fecha_venta)
ORDER BY mes;


-- CONSULTA 2
SELECT TOP 5
    id_producto,
    SUM(cantidad) AS unidades_vendidas,
    SUM(cantidad * precio_unitario) AS total_facturado
FROM ventas
GROUP BY id_producto
ORDER BY total_facturado DESC;


-- CONSULTA 3
SELECT 
    id_cliente,
    COUNT(*) AS cantidad_pedidos,
    SUM(cantidad * precio_unitario) AS total_gastado
FROM ventas
GROUP BY id_cliente
HAVING COUNT(*) > 1
ORDER BY total_gastado DESC;


-- CONSULTA 4
SELECT 
    mes,
    total_facturado,
    CASE
        WHEN total_facturado > (
            SELECT AVG(total_mensual)
            FROM (
                SELECT 
                    MONTH(fecha_venta) AS mes,
                    SUM(cantidad * precio_unitario) AS total_mensual
                FROM ventas
                GROUP BY MONTH(fecha_venta)
            ) AS promedio_meses
        )
        THEN 'Por encima'

        WHEN total_facturado < (
            SELECT AVG(total_mensual)
            FROM (
                SELECT 
                    MONTH(fecha_venta) AS mes,
                    SUM(cantidad * precio_unitario) AS total_mensual
                FROM ventas
                GROUP BY MONTH(fecha_venta)
            ) AS promedio_meses
        )
        THEN 'Por debajo'

        ELSE 'Igual al promedio'
    END AS comparacion_promedio
FROM (
    SELECT 
        MONTH(fecha_venta) AS mes,
        SUM(cantidad * precio_unitario) AS total_facturado
    FROM ventas
    GROUP BY MONTH(fecha_venta)
) AS ventas_mensuales
ORDER BY mes;

/*
-Todos los clientes del mes de marzo se los consideran clientes recurrentes ya que todos hicieron mas de un pedido.
-El producto 1 fue el que más facturó en el mes de marzo, con un total de $3600, pero el producto más vendido fue el producto 2 con un total de 13 unidades vendidas.
- Todos los clientes hicieron 2 pedidos exactos, pero su monto gastado varió
*/