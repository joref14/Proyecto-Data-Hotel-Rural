-- =========================================================================
-- SCRIPT 02: CAPA SILVER - SÚPER BLINDADO CONTRA DATOS RADIACTIVOS
-- =========================================================================

USE hotel_analytics_pro;

-- Forzamos la limpieza total para empezar de cero sin bloqueos de Foreign Keys
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS silver_articulos;
DROP TABLE IF EXISTS silver_ventas;
DROP TABLE IF EXISTS silver_clientes;
SET FOREIGN_KEY_CHECKS = 1;

-- -------------------------------------------------------------------------
-- 1. CREACIÓN DE TABLAS INTERMEDIAS
-- -------------------------------------------------------------------------

CREATE TABLE silver_clientes (
    cliente_id VARCHAR(50) PRIMARY KEY,
    nombre VARCHAR(255),
    nif VARCHAR(50),
    poblacion VARCHAR(100),
    provincia VARCHAR(100),
    pais VARCHAR(100)
);

CREATE TABLE silver_ventas (
    venta_unica_id VARCHAR(100) PRIMARY KEY, 
    factura_id VARCHAR(50),
    fecha_date DATE,
    cliente_id VARCHAR(50),
    nombre_cliente_venta VARCHAR(255),
    monto_total DECIMAL(10,2),
    monto_pagado DECIMAL(10,2)
);

CREATE TABLE silver_articulos (
    articulo_id INT AUTO_INCREMENT PRIMARY KEY,
    factura_id VARCHAR(50),
    fecha_date DATE,
    articulo_nombre VARCHAR(255),
    cantidad INT,
    precio_unitario DECIMAL(10,2),
    total_linea DECIMAL(10,2)
);

-- -------------------------------------------------------------------------
-- 2. CARGA DE DATOS SEGUROS (Fuerza bruta contra fallos de origen)
-- -------------------------------------------------------------------------

-- === PASO A: Clientes ===
-- Con INSERT IGNORE nos saltamos los códigos repetidos del hotel (Manuel Klose, etc.)
-- === PASO A: Clientes (Filtrando duplicados antes de insertar) ===
INSERT INTO silver_clientes (cliente_id, nombre, nif, poblacion, provincia, pais)
SELECT 
    TRIM(CODIGO),
    UPPER(TRIM(MAX(NOMBRE))), -- Si por algún motivo cambian las mayúsculas, nos quedamos con uno
    TRIM(MAX(NIF)),
    UPPER(TRIM(MAX(POBLACION))),
    UPPER(TRIM(MAX(PROVINCIA))),
    UPPER(TRIM(MAX(PAIS)))
FROM stg_clientes
WHERE CODIGO IS NOT NULL AND TRIM(CODIGO) <> ''
GROUP BY TRIM(CODIGO); -- Esto colapsa las 10.168 filas en los ~5.084 clientes reales únicos

-- Inyectamos el cliente comodín universal
INSERT IGNORE INTO silver_clientes (cliente_id, width, nombre) 
VALUES ('99999', '⚠️ NO REGISTRADO / CAFETERÍA / MESA');

-- Inyectamos el cliente comodín para las ventas de barra y cafetería
INSERT IGNORE INTO silver_clientes (cliente_id, nombre) 
VALUES ('99999', '⚠️ NO REGISTRADO / CAFETERÍA / MESA');


-- === PASO B: Ventas ===
INSERT IGNORE INTO silver_ventas (venta_unica_id, factura_id, fecha_date, cliente_id, nombre_cliente_venta, monto_total, monto_pagado)
SELECT 
    CONCAT(TRIM(v.FACTURA), '_', 
        CASE 
            WHEN TRIM(v.FECHA) REGEXP '^[0-9]{2}/[0-9]{2}/[0-9]{4}$' THEN STR_TO_DATE(TRIM(v.FECHA), '%d/%m/%Y')
            ELSE '1900-01-01'
        END
    ),
    TRIM(v.FACTURA),
    CASE 
        WHEN TRIM(v.FECHA) REGEXP '^[0-9]{2}/[0-9]{2}/[0-9]{4}$' THEN STR_TO_DATE(TRIM(v.FECHA), '%d/%m/%Y')
        ELSE '1900-01-01'
    END,
    CASE 
        WHEN c.cliente_id IS NULL THEN '99999'
        ELSE TRIM(v.CLIENTE) 
    END,
    TRIM(v.NOM_C),
    CAST(NULLIF(REPLACE(TRIM(v.COBRADO), ',', '.'), '') AS DECIMAL(10,2)),
    CAST(NULLIF(REPLACE(TRIM(v.TOTAL_E), ',', '.'), '') AS DECIMAL(10,2))
FROM stg_ventas v
LEFT JOIN silver_clientes c ON TRIM(v.CLIENTE) = c.cliente_id
WHERE v.FACTURA IS NOT NULL AND TRIM(v.FACTURA) <> '';


-- === PASO C: Artículos ===
-- Protegemos la conversión de fecha controlando que cumpla el patrón de barras extraído de tus archivos
INSERT INTO silver_articulos (factura_id, fecha_date, articulo_nombre, cantidad, precio_unitario, total_linea)
SELECT 
    TRIM(No_Doc),
    CASE 
        WHEN TRIM(Fecha) REGEXP '^[0-9]{2}/[0-9]{2}/[0-9]{2,4}$' THEN STR_TO_DATE(TRIM(Fecha), '%d/%m/%Y')
        ELSE NULL 
    END,
    UPPER(TRIM(Articulo)),
    CAST(CAST(NULLIF(REPLACE(TRIM(Cant), ',', '.'), '') AS DECIMAL(10,2)) AS SIGNED),
    CAST(NULLIF(REPLACE(TRIM(Precio), ',', '.'), '') AS DECIMAL(10,2)),
    CAST(NULLIF(REPLACE(TRIM(Total), ',', '.'), '') AS DECIMAL(10,2))
FROM stg_articulos
WHERE No_Doc IS NOT NULL AND TRIM(No_Doc) <> '';