# Documentaci¢n del Proyecto: Capa Bronze (Staging / Datos en Bruto) 
 
## ?? 1. Objetivo de la Capa Bronze 
El objetivo de la capa **Bronze** es actuar como la zona de aterrizaje de los datos del hotel. Aqu¡ se realiza la ingesta directa de los archivos en bruto desde los sistemas de origen, sin aplicar ning£n tipo de filtro, limpieza o transformaci¢n. El lema de esta capa es: *\"Cargar los datos tal y como vienen\"*. 
 
--- 
## ?? 2. Origen de los Datos e Ingesta 
 
* **Sistema de Origen:** Los datos se extraen de **SimplyGest**, un software de gesti¢n de escritorio bastante antiguo utilizado por el hotel. 
* **Estado de los Datos:** Al tratarse de un sistema heredado (legacy) y con muchas limitaciones de validaci¢n en la interfaz, los datos extra¡dos en los archivos CSV vienen **extremadamente sucios**. Presentan graves problemas de redundancia, campos de texto libre ca¢ticos, registros duplicados y fechas corruptas con caracteres alfanum‚ricos. 
* **Estrategia de Ingesta (Modo Import):** Se ha utilizado un proceso de integraci¢n directa en modo **Import** hacia la base de datos MySQL. Esto significa que volcamos el contenido completo de los archivos en tablas espejo (`stg_clientes`, `stg_ventas`, `stg_articulos`) utilizando tipos de datos gen‚ricos (como `TEXT` o `VARCHAR`) para garantizar que la base de datos trague toda la informaci¢n sin lanzar errores de conversi¢n en esta primera fase. 
 
--- 
 
## ?? 3. Estructura de Almacenamiento 
Las tablas de Staging creadas no aplican restricciones de integridad referencial (no hay `PRIMARY KEY` reales ni `FOREIGN KEY`). Solo sirven como un b£fer temporal para que los scripts de la capa Silver puedan meter mano al texto sucio y empezar la purificaci¢n. 
