# 🏨 Plataforma End-to-End de Analytics e Inteligencia de Negocio
## Caso de Éxito: Transformación Digital y Control Operativo en un Hotel Rural

![Power BI](https://img.shields.io/badge/Power%20BI-F2C811?style=for-the-badge&logo=powerbi&logoColor=black)
![MySQL](https://img.shields.io/badge/MySQL-4479A1?style=for-the-badge&logo=mysql&logoColor=white)
![SQL](https://img.shields.io/badge/SQL-Advanced-blue?style=for-the-badge)
![Arquitectura](https://img.shields.io/badge/Arquitectura-Medallion%20(Bronze%2FSilver%2FGold)-success?style=for-the-badge)

---TODOS LOS DATOS DE ESTE PROYECTO SON FICTICIOS, HAN SIDO MODIFICADOS CON RESPECTOA LOS DATOS REALES POR PROTECCIÓN DE DATOS SENSIBLES, NINGUNA CIFRA ES CORRECTA



## 🎯 1. El Contexto Real y el Reto de Negocio

Este proyecto nace de una necesidad real de negocio: un **pequeño hotel rural** gestionaba toda su actividad diaria (reservas de habitaciones, comandas de restaurante, venta de servicios extras y facturación) utilizando **SimplyGest**, un software local de escritorio muy anticuado. 

Al no disponer de validaciones en la interfaz, el personal de recepción introducía la información mediante **texto libre**. Esto generó un caos absoluto en los datos históricos: fechas corruptas, miles de clientes duplicados y un catálogo de productos totalmente ingobernable.

La dirección del hotel se encontraba en una situación de **ceguera operativa total**:
* **Falta de métricas hoteleras:** Imposibilidad de calcular indicadores clave como el **RevPAR** (Ingresos por habitación disponible) o el **ADR** (Precio medio por habitación ocupada).
* **Descontrol en Venta Cruzada:** Incapacidad de medir con precisión el impacto de los servicios extras (cafetería, restaurante, parking) en el beneficio global.
* **Catálogo colapsado:** Lo que operativamente eran **31 servicios únicos** se convirtió en una base de datos con más de 1.000 registros debido a faltas de ortografía y variantes tipográficas manuales.

**La solución:** Diseñar e implementar una infraestructura de datos completa (End-to-End) para extraer estos datos en bruto, limpiarlos mediante código profesional en una base de datos **MySQL** estructurada en capas, y explotarlos visualmente en un **Dashboard Ejecutivo en Power BI** interactivo y seguro.

---

## 🏗️ 2. Arquitectura de Datos (Metodología Medallion)

Para garantizar la estabilidad del proyecto y limpiar el caos del sistema antiguo sin perder información, se ha diseñado una arquitectura de tres capas sobre **MySQL Workbench**:

### 🟫 Capa BRONZE (Staging)
* **Script:** `Scripts_SQL/01_capa_bronze.sql`
* **Función:** Actúa como zona de aterrizaje primaria (*landing zone*). Recibe los datos crudos extraídos de SimplyGest (archivos CSV de la carpeta `Extract`) y los vuelca en tablas espejo (`stg_clientes`, `stg_ventas`, `stg_articulos`). 
* **Estrategia:** Todos los campos se configuran como `TEXT` o `VARCHAR` genéricos. De esta forma, la base de datos "traga" toda la información sin lanzar errores de formato, asegurando un histórico inmutable para su posterior auditoría.

### ⬜ Capa SILVER (Limpieza y Tipado Estricto)
* **Script:** `Scripts_SQL/02_capa_silver.sql`
* **Función:** Es la fase de purificación del dato mediante transformaciones avanzadas de SQL:
  * **Deduplicación de Clientes:** El sistema original duplicaba los códigos de cliente, arrojando más de 10.168 filas para unos 5.080 clientes reales. Se eliminaron usando un filtrado con `GROUP BY TRIM(CODIGO)` y funciones `MAX()` para rescatar la información más actualizada.
  * **Sanitización de Fechas (SQL Error 1411):** La introducción manual permitía texto libre en campos de fecha, rompiendo la base de datos al intentar convertirlas. Se programó una validación previa con **expresiones regulares (REGEXP)**; las fechas corruptas insalvables se reasignaron a un valor pivote de seguridad (`1900-01-01`).
  * **Clientes Huérfanos:** Los consumos de cafetería o barra emitidos sin asociar a un huésped registrado se redirigieron a un **Cliente Comodín Universal** (`99999 - NO REGISTRADO / CAFETERÍA`), evitando descuadres en la facturación global.

### 🟨 Capa GOLD (Modelo Dimensional en Estrella)
* **Script:** `Scripts_SQL/03_capa_gold.sql`
* **Función:** Transforma los datos limpios en un almacén de datos (*Data Warehouse*) estructurado en un **Modelo en Estrella** (1 Tabla de Hechos `gold_fact_consumos` y 3 Dimensiones: `gold_dim_clientes`, `gold_dim_articulos`, `gold_dim_tiempo`), optimizando el rendimiento de las consultas para Power BI.
  * **Reingeniería del Catálogo:** Para solucionar las variantes del texto libre de recepción (ej: *"HABITACION 01"*, *"Noche Hab 01 Oferta Web"*, *"Hab. 1 standar"*), se desarrolló una lógica condicional masiva (`CASE WHEN UPPER(nombre) LIKE '%HAB%01%' THEN ID_HAB_01...`) que agrupó automáticamente todo el caos de mil registros en las **31 categorías reales** del hotel.
 ---

## 📊 3. Front-End: Cuadro de Mando de Alto Impacto UX/UI (Power BI)

El diseño del informe se ha creado desde cero aplicando estrictas pautas de **diseño UX/UI avanzado** para entornos corporativos: menús de navegación flotantes mediante marcadores, tarjetas KPI con esquinas redondeadas para estructurar la información, uso de una paleta de colores coherente con el entorno rural del hotel y eliminación total de gráficos innecesarios para evitar la fatiga visual.

El dashboard está estructurado en **4 páginas estratégicas e interactivas**:

### 📈 Página 1: Resumen Ejecutivo (Dirección General)
Diseñada para dar una respuesta inmediata sobre la salud financiera y operativa del negocio en tres segundos.
* **Rigor Financiero:** Se ha forzado el formato numérico entero y real, eliminando el redondeo automático por defecto de Power BI (como *1.2M*) para garantizar que la dirección visualice cifras exactas al céntimo.
* **Correlación de Métricas:** Incluye un gráfico mixto de barras y líneas que cruza los Ingresos Totales con las Noches de Ocupación para evaluar la eficiencia comercial mes a mes.
* <img width="671" height="374" alt="Resumen_Ejecutivo" src="https://github.com/user-attachments/assets/b4b2a7a1-6a36-49f6-b3f9-5161570007e6" />


### 🛏️ Página 2: Control de Alojamiento (Gestión Hotelera)
Enfocada exclusivamente en medir y exprimir el rendimiento del inventario de habitaciones del hotel.
* **Métricas Estándar de la Industria:** Implementación analítica de fórmulas clave: **ADR** (Precio medio por habitación ocupada) y **RevPAR** (Ingresos por habitación disponible).
* **Matriz de Calor de Ocupación:** Un mapa de densidad que cruza los días de la semana con los meses del año, detectando al instante qué habitaciones rinden por debajo de la media y qué días de la semana flojea la demanda para lanzar ofertas relámpago.
* <img width="667" height="376" alt="Alojamiento" src="https://github.com/user-attachments/assets/ef3855da-88f1-4f17-9784-43ed89e0d330" />


### ☕ Página 3: Servicios Extras & Venta Cruzada (Restauración y Eventos)
Crucial para descubrir el comportamiento de gasto del cliente fuera de la habitación (cafetería, restaurante, parking, masajes).
* **Análisis de Impacto:** Desglosa el peso porcentual de los servicios extras sobre la facturación global del hotel, identificando dependencias.
* **Visualización Interactiva:** Un *Treemap* dinámico permite filtrar por familias y productos unificados para conocer qué elementos del menú o servicios complementarios generan el mayor volumen de caja.
* <img width="665" height="377" alt="Servicios" src="https://github.com/user-attachments/assets/5c81408a-a100-4fc5-bbb9-c329fe8b785a" />


### 👥 Página 4: Analítica de Clientes (Estrategia de Marketing)
Diseñada para guiar las campañas de captación, procedencia y fidelización de huéspedes.
* **DAX Avanzado (Customer Lifetime Value):** Para calcular el Gasto Medio Real por cliente, se programó una medida en DAX que rompe el filtro de la dimensión de artículos (permitiendo sumar la habitación + las cenas del restaurante de forma agregada para un mismo cliente) pero respetando escrupulosamente los filtros temporales de año y mes elegidos por el usuario
* <img width="667" height="377" alt="Clientes" src="https://github.com/user-attachments/assets/7a337c6e-90e9-4292-89ef-4e7ee8d068d1" />


