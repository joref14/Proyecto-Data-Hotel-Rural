# Documentaci�n del Proyecto: Capa Gold (Modelo Dimensional) 
 
## ?? 1. Objetivo de la Capa Gold 
El objetivo de la capa **Gold** es transformar las tablas independientes y limpias de la capa Silver en un **Modelo Dimensional en Estrella**. Este modelo est� optimizado espec�ficamente para Business Intelligence, garantizando que los tableros de Power BI carguen de forma instant�nea y las m�tricas de negocio sean 100%% consistentes. 
 
--- 
 
## ?? 2. Dise�o del Modelo en Estrella 
 
El modelo se ha dividido en dos estructuras fundamentales: 
* **Tabla de Hechos (`gold_fact_consumos`):** Centraliza todas las m�tricas num�ricas del hotel (cantidad, precio unitario, total de la l�nea) y almacena �nicamente claves num�ricas (IDs) que conectan con las dimensiones. 
* **Tablas de Dimensiones:** Aportan el contexto anal�tico y permiten filtrar los datos de la tabla de hechos: 
  * `gold_dim_clientes`: Datos geogr�ficos y demogr�ficos de los hu�spedes. 
  * `gold_dim_articulos`: Cat�logo unificado de los 31 servicios reales del hotel. 
  * `gold_dim_tiempo`: Dimensi�n generada mediante un procedimiento almacenado para segmentar por A�o, Mes, Trimestre, D�a de la semana y Fines de semana. 
 
--- 
 
## ?? 3. Imprevisto Detectado y Soluci�n de Ingenier�a (Mapeo de Art�culos) 
 
### El Problema: Caos en el Texto Libre de Origen 
Al intentar extraer el cat�logo de art�culos de forma �nica mediante un `DISTINCT` tradicional, la dimensi�n explot� a **m�s de 1.000 registros** cuando el cat�logo real del hotel cuenta �nicamente con **31 servicios**. 
 
Esto se deb�a a que el software del hotel permit�a a los recepcionistas escribir texto libre en cada transacci�n. Un mismo concepto real, como la **Habitaci�n 01**, ven�a registrado de decenas de formas ca�ticas debido a anotaciones manuales, ofertas o erratas: 
* *\"NOCHE HABITACION 01\"* 
* *\"noche habitacion 01 y 07\"* 
* *\"Noche Habitacion 01 Oferta Web\"* 
 
### La Soluci�n: Clasificaci�n Inteligente por Palabras Clave (Categorizaci�n) 
Para corregir esta dispersi�n que habr�a hecho ilegibles los informes de BI, se aplic� una reingenier�a en el script de carga: 
1. Se forz� la creaci�n estricta de las **31 categor�as corporativas reales** en la tabla `gold_dim_articulos`. 
2. En la carga de la Tabla de Hechos, se sustituy� el cruce directo por un bloque de l�gica condicional utilizando `CASE WHEN` combinado con operadores de coincidencia parcial `LIKE` y conversi�n a may�sculas `UPPER()`. 
 
De este modo, cualquier variante de texto que contenga patrones clave (ej. `%HABITACION%01%`) se redirige y unifica de forma autom�tica bajo un �nico ID num�rico correspondiente a su categor�a oficial en la dimensi�n. 
 
--- 
 
## ?? 4. Script de Despliegue 
El proceso se encuentra completamente automatizado e integrado en el archivo `scripts/03_capa_gold.sql`, el cual limpia los hist�ricos previos, regenera el calendario din�mico y repobla el modelo aplicando las reglas de unificaci�n mediante `LEFT JOIN`s optimizados. 
 
--- 
 
## ?? 5. Validaciones de Integridad 
Al finalizar la carga, la dimensi�n de art�culos debe arrojar **exactamente 31 registros**, mientras que la tabla de hechos debe mantener el cuadre total de transacciones financieras heredadas de la capa Silver sin p�rdida de registros hu�rfanos. 
