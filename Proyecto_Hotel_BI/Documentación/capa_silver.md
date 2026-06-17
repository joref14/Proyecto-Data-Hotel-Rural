# Documentaci�n del Proyecto: Capa Silver (Transformaci�n y Limpieza) 
 
## ?? 1. Objetivo de la Capa Silver 
El objetivo de esta fase es transformar los datos en bruto (*raw data*) almacenados en la capa de **Staging** (`stg_clientes`, `stg_ventas`, `stg_articulos`) en tablas limpias, estructuradas y tipadas dentro de la capa **Silver**. 
 
Durante este proceso se han aplicado reglas de negocio, tipado estricto de datos (fechas y decimales) y t�cnicas de deduplicaci�n para corregir las graves deficiencias de integridad detectadas en el software de origen del hotel. 
 
--- 
 
## ??? 2. Retos de Calidad de Datos y Soluciones Aplicadas 
 
Al procesar los archivos reales del hotel, se detectaron tres anomal�as cr�ticas que bloqueaban la carga tradicional. A continuaci�n se detallan las soluciones de ingenier�a implementadas: 
 
### A. C�digos de Cliente Duplicados (Duplicidad en Origen) 
* **El Problema:** El archivo de clientes original conten�a un volumen de registros duplicados (10.168 filas frente a ~5.080 clientes �nicos). El software del hotel reutilizaba c�digos id�nticos (`0638`, `0720`, `0001`, etc.) para personas o volcado de datos distintos, lo que hac�a colapsar la restricci�n de Clave Primaria (`PRIMARY KEY`). 
* **La Soluci�n:** Se implement� una agregaci�n forzada mediante `GROUP BY TRIM(CODIGO)` utilizando funciones de agregaci�n (`MAX()`) para colapsar los duplicados exactos en un �nico registro limpio por cliente. De este modo, la tabla se sanea sin p�rdida de informaci�n real y se mantiene la integridad referencial. 
 
### B. Fechas Corruptas en Transacciones 
* **El Problema:** En la tabla de art�culos, la columna `Fecha` presentaba registros corruptos con texto plano (ej. caracteres aislados como `'A'`), provocando errores fatales de conversi�n (`SQL Error 1411: Incorrect datetime value`). 
* **La Soluci�n:** Se blind� el proceso de tipado utilizando expresiones regulares (REGEXP '[0-9]{2}/[0-9]{2}/[0-9]{2,4}$'). El script valida la estructura de la fecha antes de intentar la conversi�n con `STR_TO_DATE()`. Si el dato no es v�lido, se le asigna `NULL` o una fecha por defecto (`1900-01-01`) permitiendo que el script procese las miles de l�neas restantes sin interrupciones. 
 
### C. Ventas Hu�rfanas (Cafeter�a y Consumos de Barra) 
* **El Problema:** Existen tickets y facturas emitidos a clientes gen�ricos que no constan en la base de datos maestra de clientes registrados. 
* **La Soluci�n:** Se inyect� un **Cliente Comod�n Universal** (`99999 - ?? NO REGISTRADO / CAFETER�A / MESA`) en la tabla `silver_clientes`. Mediante un `LEFT JOIN` en la carga de ventas, cualquier transacci�n hu�rfana se reasigna autom�ticamente a este c�digo para evitar la p�rdida de m�tricas financieras. 
 
--- 
 
## ?? 3. Modelo de Datos (Capa Silver) 
 
Se han definido tres entidades principales con tipos de datos nativos para optimizar el rendimiento de las futuras consultas de anal�tica: 
 
### silver_clientes 
| Campo | Tipo | Restricci�n | Descripci�n | 
| :--- | :--- | :--- | :--- | 
| `cliente_id` | `VARCHAR(50)` | `PRIMARY KEY` | C�digo �nico de cliente limpio de espacios | 
| `nombre` | `VARCHAR(255)` | | Nombre completo en may�sculas | 
| `nif` | `VARCHAR(50)` | | Documento de identidad | 
| `poblacion` | `VARCHAR(100)` | | Ciudad de residencia | 
| `provincia` | `VARCHAR(100)` | | Provincia | 
| `pais` | `VARCHAR(100)` | | Pa�s | 
 
### silver_ventas 
| Campo | Tipo | Restricci�n | Descripci�n | 
| :--- | :--- | :--- | :--- | 
| `venta_unica_id`| `VARCHAR(100)`| `PRIMARY KEY` | Clave compuesta generada (`Factura_Fecha`) | 
| `factura_id` | `VARCHAR(50)` | | C�digo del documento fiscal | 
| `fecha_date` | `DATE` | | Fecha de la venta en formato nativo `YYYY-MM-DD` | 
| `cliente_id` | `VARCHAR(50)` | | ID del cliente (v�nculo a Clientes o `99999`) | 
| `nombre_cliente_venta`| `VARCHAR(255)`| | Nombre del cliente tal y como se imprimi� en el ticket | 
| `monto_total` | `DECIMAL(10,2)`| | Total cobrado con limpieza de formato decimal | 
| `monto_pagado`| `DECIMAL(10,2)`| | Total efectivo con limpieza de formato decimal | 
 
### silver_articulos 
| Campo | Tipo | Restricci�n | Descripci�n | 
| :--- | :--- | :--- | :--- | 
| `articulo_id` | `INT` | `PRIMARY KEY AUTO_INCREMENT` | ID autonum�rico para control de l�neas | 
| `factura_id` | `VARCHAR(50)` | | V�nculo con el documento de venta | 
| `fecha_date` | `DATE` | | Fecha nativa de la transacci�n | 
| `articulo_nombre`| `VARCHAR(255)`| | Nombre del art�culo/servicio en may�sculas | 
| `cantidad` | `INT` | | Unidades vendidas (convertidas a entero) | 
| `precio_unitario`| `DECIMAL(10,2)`| | Precio por unidad sin caracteres extra�os | 
| `total_linea` | `DECIMAL(10,2)`| | Suma total de la l�nea de art�culo | 
 
--- 
 
## ?? 4. Script de Despliegue (SQL) 
 
El script completo de transformaci�n se encuentra en el archivo `Scripts_SQL/02_capa_silver.sql`. Incorpora las cl�usulas `DROP TABLE IF EXISTS` controladas mediante la desactivaci�n temporal de checks de claves for�neas (SET FOREIGN_KEY_CHECKS = 0) para garantizar la idempotencia del proceso. 
 
--- 
 
## ?? 5. Validaciones Post-Carga 
Tras cada ejecuci�n, es obligatorio validar el cuadre de registros mediante los siguientes contadores para asegurar el residuo cero en ventas y art�culos: 
 
```sql 
SELECT COUNT(*) FROM silver_clientes; 
SELECT COUNT(*) FROM silver_ventas; 
SELECT COUNT(*) FROM silver_articulos; 
``` 
