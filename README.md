# 🏨 Plataforma End-to-End de Analytics e Inteligencia de Negocio
## Caso de Éxito: Transformación Digital y Control Operativo del Hotel Palacio de Atienza

![Power BI](https://img.shields.io/badge/Power%20BI-F2C811?style=for-the-badge&logo=powerbi&logoColor=black)
![MySQL](https://img.shields.io/badge/MySQL-4479A1?style=for-the-badge&logo=mysql&logoColor=white)
![SQL](https://img.shields.io/badge/SQL-Advanced-blue?style=for-the-badge)
![Arquitectura](https://img.shields.io/badge/Arquitectura-Medallion%20(Bronze%2FSilver%2FGold)-success?style=for-the-badge)

---

## 🎯 1. El Reto del Negocio: De la Ceguera Operativa a las Decisiones Basadas en Datos

El **Hotel Palacio de Atienza**, un establecimiento de turismo rural con encanto, gestionaba toda su actividad comercial, reservas y restauración a través de **SimplyGest**, un software local de escritorio antiguo. Debido a las limitaciones de este sistema y a la introducción de texto libre por parte del personal de recepción, la dirección se encontraba ante una **ceguera operativa total**:
* ❌ **Imposibilidad de calcular métricas hoteleras clave** como el RevPAR (Ingresos por habitación disponible) o el ADR (Precio medio por habitación).
* ❌ **Fugas de ingresos** en servicios extras (cafetería, restaurante) por falta de traza real con los clientes alojados.
* ❌ **Catálogo colapsado:** Lo que debían ser 31 servicios únicos se convirtieron en más de 1.000 registros debido a variantes tipográficas manuales.

**El objetivo de este proyecto:** Diseñar e implementar desde cero una infraestructura de datos robusta (E2E) que extraiga los datos en bruto, los limpie mediante una arquitectura de datos moderna y los transforme en un **Cuadro de Mando Ejecutivo de nivel corporativo** para maximizar la rentabilidad del hotel.

---

## 🏗️ 2. Arquitectura de Datos Avanzada (Metodología Medallion)

Para garantizar la estabilidad del proyecto, el rendimiento de las consultas y la privacidad de la información, se ha implementado una arquitectura de tres capas sobre **MySQL**, garantizando que el cuadro de mando final consuma datos puros, validados y de alta velocidad.

```text
  [ Sistema Legacy: SimplyGest ] ──> Archivos RAW (CSV)
                                         │
                                         ▼
 ┌───────────────────────────────────────────────────────────────────────┐
 │ 🟫 CAPA BRONZE (Staging / Ingesta Primaria)                          │
 │ - Absorción sin restricciones de tipos de datos (Campos TEXT).        │
 │ - Preservación exacta del caos de origen para auditoría.              │
 └──────────────────────────────────┬────────────────────────────────────┘
                                    │
                                    ▼ (Validación por Regex y Deduplicación)
 ┌───────────────────────────────────────────────────────────────────────┐
 │ ⬜ CAPA SILVER (Limpieza y Calidad de Datos)                          │
 │ - Eliminación de >5.000 registros duplicados en la maestra de clientes.│
 │ - Sanitización de fechas corruptas (SQL Error 1411 corregido).         │
 └──────────────────────────────────┬────────────────────────────────────┘
                                    │
                                    ▼ (Modelado Dimensional en Estrella)
 ┌───────────────────────────────────────────────────────────────────────┐
 │ 🟨 CAPA GOLD (Data Warehouse / Explotación)                          │
 │ - Creación del Modelo en Estrella: 1 Tabla de Hechos + 3 Dimensiones. │
 │ - Homogeneización del catálogo de servicios mediante lógica CASE/LIKE.│
 └──────────────────────────────────┬────────────────────────────────────┘
                                    │
                                    ▼ (Conexión Optimizada)
 ┌───────────────────────────────────────────────────────────────────────┐
 │ 📊 FRONT-END: POWER BI EXECUTIVE DASHBOARD                            │
 └───────────────────────────────────────────────────────────────────────┘
