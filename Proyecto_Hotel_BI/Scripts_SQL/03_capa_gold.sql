-- ============================================================================
-- ARQUITECTURA MEDALLION - CAPA GOLD (MODELO DIMENSIONAL EN ESTRELLA)
-- ============================================================================
-- Objetivo: Crear las dimensiones y la tabla de hechos uniendo de forma física
-- y relacional las tablas limpias de la capa Silver.
-- ============================================================================

-- Desactivamos temporalmente los checks de claves foráneas para poder hacer un DROP limpio
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------------------------------------------------------
-- 1. DIMENSIÓN: CLIENTES (gold_dim_clientes)
-- ----------------------------------------------------------------------------
-- Traspasamos el maestro de clientes únicos y saneados para segmentar por geografía.
DROP TABLE IF EXISTS gold_dim_clientes;

CREATE TABLE gold_dim_clientes (
    cliente_key VARCHAR(50) PRIMARY KEY,
    nombre VARCHAR(255),
    nif VARCHAR(50),
    poblacion VARCHAR(100),
    provincia VARCHAR(100),
    pais VARCHAR(100)
);

INSERT INTO gold_dim_clientes
SELECT cliente_id, nombre, nif, poblacion, provincia, pais 
FROM silver_clientes;


-- ----------------------------------------------------------------------------
-- 2. DIMENSIÓN: ARTÍCULOS / SERVICIOS (gold_dim_articulos)
-- ----------------------------------------------------------------------------
-- Extraemos de manera única cada concepto cobrado para asignarle una Clave Subrogada (ID numérico).
DROP TABLE IF EXISTS gold_dim_articulos;

CREATE TABLE gold_dim_articulos (
    articulo_key INT AUTO_INCREMENT PRIMARY KEY,
    articulo_nombre VARCHAR(255) UNIQUE
);

INSERT INTO gold_dim_articulos (articulo_nombre)
SELECT DISTINCT articulo_nombre 
FROM silver_articulos 
WHERE articulo_nombre IS NOT NULL;


-- ----------------------------------------------------------------------------
-- 3. DIMENSIÓN: TIEMPO / CALENDARIO (gold_dim_tiempo)
-- ----------------------------------------------------------------------------
-- Tabla fundamental para analizar las temporadas del hotel, fines de semana y meses.
DROP TABLE IF EXISTS gold_dim_tiempo;

CREATE TABLE gold_dim_tiempo (
    fecha_key DATE PRIMARY KEY,
    anio INT,
    mes INT,
    mes_nombre VARCHAR(20),
    trimestre INT,
    dia_semana INT,
    dia_semana_nombre VARCHAR(20),
    es_fin_semana TINYINT
);

-- Creamos un procedimiento almacenado temporal en MySQL para rellenar el calendario
DROP PROCEDURE IF EXISTS LlenarDimTiempo;

DELIMITER //
CREATE PROCEDURE LlenarDimTiempo(CONVERT_START DATE, CONVERT_END DATE)
BEGIN
    WHILE CONVERT_START <= CONVERT_END DO
        INSERT INTO gold_dim_tiempo VALUES (
            CONVERT_START,
            YEAR(CONVERT_START),
            MONTH(CONVERT_START),
            MONTHNAME(CONVERT_START),
            QUARTER(CONVERT_START),
            WEEKDAY(CONVERT_START) + 1,
            DAYNAME(CONVERT_START),
            IF(WEEKDAY(CONVERT_START) IN (5,6), 1, 0) -- 1 si es Sábado (5) o Domingo (6)
        );
        SET CONVERT_START = DATE_ADD(CONVERT_START, INTERVAL 1 DAY);
    END WHILE;
END //
DELIMITER ;

-- Ejecutamos el procedimiento para generar los días desde 2005 hasta finales de 2027
CALL LlenarDimTiempo('2005-01-01', '2027-12-31');


-- ----------------------------------------------------------------------------
-- 4. TABLA DE HECHOS CENTRAL: CONSUMOS (gold_fact_consumos)
-- ----------------------------------------------------------------------------
-- Aquí unimos lógicamente las transacciones y enlazamos físicamente las claves (Foreign Keys).
DROP TABLE IF EXISTS gold_fact_consumos;

CREATE TABLE gold_fact_consumos (
    hecho_id INT AUTO_INCREMENT PRIMARY KEY,
    factura_id VARCHAR(50),
    fecha_key DATE,
    cliente_key VARCHAR(50),
    articulo_key INT,
    cantidad INT,
    precio_unitario DECIMAL(10,2),
    total_linea DECIMAL(10,2),
    
    -- Establecemos las relaciones físicas estrictas del Modelo en Estrella
    FOREIGN KEY (fecha_key) REFERENCES gold_dim_tiempo(fecha_key),
    FOREIGN KEY (cliente_key) REFERENCES gold_dim_clientes(cliente_key),
    FOREIGN KEY (articulo_key) REFERENCES gold_dim_articulos(articulo_key)
);

-- Poblamos la tabla de hechos cruzando las tablas mediante LEFT JOINs estratégicos
INSERT INTO gold_fact_consumos (factura_id, fecha_key, cliente_key, articulo_key, cantidad, precio_unitario, total_linea)
SELECT 
    sa.factura_id,
    IFNULL(sa.fecha_date, '1900-01-01'),             -- Control de fechas corruptas
    IFNULL(sv.cliente_id, '99999'),                  -- Control de clientes huérfanos (cafetería)
    da.articulo_key,                                 -- Mapeo al ID numérico óptimo de la dimensión
    sa.cantidad,
    sa.precio_unitario,
    sa.total_linea
FROM silver_articulos sa
LEFT JOIN silver_ventas sv ON sa.factura_id = sv.factura_id
LEFT JOIN gold_dim_articulos da ON sa.articulo_nombre = da.articulo_nombre;

-- Volvemos a activar la restricción de integridad referencial
SET FOREIGN_KEY_CHECKS = 1;


-- ============================================================================
-- VERIFICACIÓN DE CARGA EN DBEAVER
-- ============================================================================
SELECT 'gold_dim_clientes' AS tabla, COUNT(*) AS total FROM gold_dim_clientes
UNION ALL
SELECT 'gold_dim_articulos', COUNT(*) FROM gold_dim_articulos
UNION ALL
SELECT 'gold_dim_tiempo', COUNT(*) FROM gold_dim_tiempo
UNION ALL
SELECT 'gold_fact_consumos', COUNT(*) FROM gold_fact_consumos;
