-- =========================================================================
-- PROYECTO: Hotel Analytics ETL
-- SCRIPT 01: CREACIÓN DEL ÁREA DE STAGING (DATOS EN BRUTO)
-- =========================================================================

-- 1. Borramos la base de datos si existiera para asegurar un inicio 100% limpio
DROP DATABASE IF EXISTS hotel_analytics_pro;
CREATE DATABASE hotel_analytics_pro;
USE hotel_analytics_pro;

-- -------------------------------------------------------------------------
-- 2. TABLAS DE STAGING (Cajas de cartón vacías)
-- Creamos las tablas temporales con tipo VARCHAR para que se traguen los CSVs
-- tal y como vienen de origen, con sus espacios, nulos y duplicados.
-- -------------------------------------------------------------------------

-- Almacén en bruto para el CSV de Ventas
CREATE TABLE stg_ventas (
    factura VARCHAR(255),
    fecha VARCHAR(255),
    cliente VARCHAR(255),
    cobrado VARCHAR(255)
);

-- Almacén en bruto para el CSV de Clientes
CREATE TABLE stg_clientes (
    codigo VARCHAR(255),
    nombre VARCHAR(255)
);

-- Almacén en bruto para el CSV de Artículos (Desglose)
CREATE TABLE stg_articulos (
    No_Doc VARCHAR(255),
    Articulo VARCHAR(255),
    Cantidad VARCHAR(255),
    Precio VARCHAR(255)
);

truncate stg_ventas

USE hotel_analytics_pro;

-- Cambiamos la columna de la tabla de staging para que acepte textos de hasta 500 caracteres
ALTER TABLE stg_ventas MODIFY COLUMN nom_c VARCHAR(500);



