SET FOREIGN_KEY_CHECKS = 0;

-- 1. Recreamos la dimensión con tu catálogo limpio real de la foto
DROP TABLE IF EXISTS gold_dim_articulos;

CREATE TABLE gold_dim_articulos (
    articulo_key INT AUTO_INCREMENT PRIMARY KEY,
    articulo_nombre VARCHAR(255) UNIQUE
);

-- Insertamos estrictamente las categorías reales que necesitas analizar
INSERT INTO gold_dim_articulos (articulo_nombre) VALUES
('BARRA'), ('LAVANDERIA'), ('RESTAURANTE'), ('ABONADO A CUENTA'), 
('SUPLETORIA'), ('SUPLEMENTO MASCOTA'), ('CAFETERIA'), ('PENSION COMPRETA'), 
('DESAYUNO'), ('DESAYUNO 2'), ('EXTRAS PERSONAL'), ('ALOJAMIENTO'), 
('PESCADERIA FRUTERIA'), ('MASCOTA'),
('ALQUILER DIARIO AULA SÓTANO'), ('ALQUILER DIARIO ESPACIO COMEDOR'), ('ALQUILER DIARIO JARDIN-PISCINA'),
('NOCHE HABITACIÓN 01'), ('NOCHE HABITACIÓN 02 SUPERIOR'), ('NOCHE HABITACIÓN 03 SUPERIOR'),
('NOCHE HABITACIÓN 04'), ('NOCHE HABITACIÓN 05 SUPERIOR'), ('NOCHE HABITACIÓN 06'),
('NOCHE HABITACIÓN 07'), ('NOCHE HABITACIÓN 08'), ('NOCHE HABITACIÓN 09'),
('NOCHE HABITACIÓN 10'), ('NOCHE HABITACIÓN 11'), ('NOCHE HABITACIÓN 12'),
('NOCHE HABITACIÓN 13'), ('NOCHE HABITACIÓN 14'), ('NOCHE HABITACIÓN 15');


-- 2. Volvemos a vaciar la tabla de hechos para remapear los textos caóticos
TRUNCATE TABLE gold_fact_consumos;

INSERT INTO gold_fact_consumos (factura_id, fecha_key, cliente_key, articulo_key, cantidad, precio_unitario, total_linea)
SELECT 
    sa.factura_id,
    IFNULL(sa.fecha_date, '1900-01-01'),
    IFNULL(sv.cliente_id, '99999'),
    -- Aquí ocurre la magia: agrupamos los mil textos diferentes en tus categorías oficiales
    da.articulo_key, 
    sa.cantidad,
    sa.precio_unitario,
    sa.total_linea
FROM silver_articulos sa
LEFT JOIN silver_ventas sv ON sa.factura_id = sv.factura_id
-- Cruzamos usando un CASE WHEN para buscar palabras clave dentro del texto sucio
LEFT JOIN gold_dim_articulos da ON da.articulo_nombre = (
    CASE 
        WHEN UPPER(sa.articulo_nombre) LIKE '%HABITACION%01%' OR UPPER(sa.articulo_nombre) LIKE '%HABITACIÓN%01%' THEN 'NOCHE HABITACIÓN 01'
        WHEN UPPER(sa.articulo_nombre) LIKE '%HABITACION%02%' OR UPPER(sa.articulo_nombre) LIKE '%HABITACIÓN%02%' THEN 'NOCHE HABITACIÓN 02 SUPERIOR'
        WHEN UPPER(sa.articulo_nombre) LIKE '%HABITACION%03%' OR UPPER(sa.articulo_nombre) LIKE '%HABITACIÓN%03%' THEN 'NOCHE HABITACIÓN 03 SUPERIOR'
        WHEN UPPER(sa.articulo_nombre) LIKE '%HABITACION%04%' OR UPPER(sa.articulo_nombre) LIKE '%HABITACIÓN%04%' THEN 'NOCHE HABITACIÓN 04'
        WHEN UPPER(sa.articulo_nombre) LIKE '%HABITACION%05%' OR UPPER(sa.articulo_nombre) LIKE '%HABITACIÓN%05%' THEN 'NOCHE HABITACIÓN 05 SUPERIOR'
        WHEN UPPER(sa.articulo_nombre) LIKE '%HABITACION%06%' OR UPPER(sa.articulo_nombre) LIKE '%HABITACIÓN%06%' THEN 'NOCHE HABITACIÓN 06'
        WHEN UPPER(sa.articulo_nombre) LIKE '%HABITACION%07%' OR UPPER(sa.articulo_nombre) LIKE '%HABITACIÓN%07%' THEN 'NOCHE HABITACIÓN 07'
        WHEN UPPER(sa.articulo_nombre) LIKE '%HABITACION%08%' OR UPPER(sa.articulo_nombre) LIKE '%HABITACIÓN%08%' THEN 'NOCHE HABITACIÓN 08'
        WHEN UPPER(sa.articulo_nombre) LIKE '%HABITACION%09%' OR UPPER(sa.articulo_nombre) LIKE '%HABITACIÓN%09%' THEN 'NOCHE HABITACIÓN 09'
        WHEN UPPER(sa.articulo_nombre) LIKE '%HABITACION%10%' OR UPPER(sa.articulo_nombre) LIKE '%HABITACIÓN%10%' THEN 'NOCHE HABITACIÓN 10'
        WHEN UPPER(sa.articulo_nombre) LIKE '%HABITACION%11%' OR UPPER(sa.articulo_nombre) LIKE '%HABITACIÓN%11%' THEN 'NOCHE HABITACIÓN 11'
        WHEN UPPER(sa.articulo_nombre) LIKE '%HABITACION%12%' OR UPPER(sa.articulo_nombre) LIKE '%HABITACIÓN%12%' THEN 'NOCHE HABITACIÓN 12'
        WHEN UPPER(sa.articulo_nombre) LIKE '%HABITACION%13%' OR UPPER(sa.articulo_nombre) LIKE '%HABITACIÓN%13%' THEN 'NOCHE HABITACIÓN 13'
        WHEN UPPER(sa.articulo_nombre) LIKE '%HABITACION%14%' OR UPPER(sa.articulo_nombre) LIKE '%HABITACIÓN%14%' THEN 'NOCHE HABITACIÓN 14'
        WHEN UPPER(sa.articulo_nombre) LIKE '%HABITACION%15%' OR UPPER(sa.articulo_nombre) LIKE '%HABITACIÓN%15%' THEN 'NOCHE HABITACIÓN 15'
        WHEN UPPER(sa.articulo_nombre) LIKE '%BARRA%' THEN 'BARRA'
        WHEN UPPER(sa.articulo_nombre) LIKE '%LAVANDERIA%' OR UPPER(sa.articulo_nombre) LIKE '%LAVANDERÍA%' THEN 'LAVANDERIA'
        WHEN UPPER(sa.articulo_nombre) LIKE '%RESTAURANTE%' THEN 'RESTAURANTE'
        WHEN UPPER(sa.articulo_nombre) LIKE '%ABONADO%' THEN 'ABONADO A CUENTA'
        WHEN UPPER(sa.articulo_nombre) LIKE '%SUPLETORIA%' THEN 'SUPLETORIA'
        WHEN UPPER(sa.articulo_nombre) LIKE '%MASCOTA%' THEN 'MASCOTA'
        WHEN UPPER(sa.articulo_nombre) LIKE '%CAFETERIA%' OR UPPER(sa.articulo_nombre) LIKE '%CAFETERÍA%' THEN 'CAFETERIA'
        WHEN UPPER(sa.articulo_nombre) LIKE '%PENSION%COMPLETA%' OR UPPER(sa.articulo_nombre) LIKE '%PENSIÓN%COMPLETA%' THEN 'PENSION COMPRETA'
        WHEN UPPER(sa.articulo_nombre) LIKE '%DESAYUNO%2%' THEN 'DESAYUNO 2'
        WHEN UPPER(sa.articulo_nombre) LIKE '%DESAYUNO%' THEN 'DESAYUNO'
        WHEN UPPER(sa.articulo_nombre) LIKE '%ALOJAMIENTO%' THEN 'ALOJAMIENTO'
        WHEN UPPER(sa.articulo_nombre) LIKE '%SOTANO%' OR UPPER(sa.articulo_nombre) LIKE '%SÓTANO%' THEN 'ALQUILER DIARIO AULA SÓTANO'
        WHEN UPPER(sa.articulo_nombre) LIKE '%COMEDOR%' THEN 'ALQUILER DIARIO ESPACIO COMEDOR'
        WHEN UPPER(sa.articulo_nombre) LIKE '%JARDIN%' OR UPPER(sa.articulo_nombre) LIKE '%JARDÍN%' THEN 'ALQUILER DIARIO JARDIN-PISCINA'
        -- Si hay algún texto raro que no sabemos qué es, lo dejamos como ALOJAMIENTO o GENERAL
        ELSE 'ALOJAMIENTO' 
    END
);

SET FOREIGN_KEY_CHECKS = 1;

-- 3. COMPROBACIÓN FÁCIL: Tu catálogo tiene que tener exactamente 31 filas (las de tu foto)
SELECT * FROM gold_dim_articulos ORDER BY articulo_key;