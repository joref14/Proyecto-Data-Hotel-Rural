# 🏨 Plataforma E2E de Analítica Hotelera e Inteligencia de Negocio
## Caso de Estudio: Hotel Palacio de Atienza

![Power BI](https://img.shields.io/badge/Power%20BI-F2C811?style=for-the-badge&logo=powerbi&logoColor=black)
![MySQL](https://img.shields.io/badge/MySQL-4479A1?style=for-the-badge&logo=mysql&logoColor=white)
![SQL](https://img.shields.io/badge/SQL-Advanced-blue?style=for-the-badge)
![Arquitectura](https://img.shields.io/badge/Arquitectura-Medallion%20(Bronze%2FSilver%2FGold)-success?style=for-the-badge)

Este repositorio contiene el desarrollo completo de una solución integral de **Ingeniería de Datos y Business Intelligence** para la optimización operativa y financiera del Hotel Palacio de Atienza. El proyecto abarca desde la ingesta de datos brutos de un sistema heredado (*legacy*) con graves deficiencias de calidad, hasta la construcción de un modelo dimensional robusto en MySQL y un set de dashboards analíticos de nivel ejecutivo.

---

## 📐 Arquitectura de Datos (Metodología Medallion)

Para garantizar la fiabilidad, trazabilidad y rendimiento de la solución, se implementó una arquitectura de datos en tres capas sobre una base de datos MySQL, culminando en la explotación analítica dentro de Power BI.

```text
  [ Archivos CSV ] (SimplyGest)
         │
         ▼
 ┌───────────────┐
 │  Capa BRONZE  │ <-- Ingesta Raw (Tablas de Staging sin restricciones)
 └───────┬───────┘
         │ (Limpieza, Deduplicación y Tipado)
         ▼
 ┌───────────────┐
 │  Capa SILVER  │ <-- Datos Limpios y Estructurados (Restricciones PK)
 └───────┬───────┘
         │ (Modelo Estrella e Inteligencia de Clasificación)
         ▼
 ┌───────────────┐
 │   Capa GOLD   │ <-- Modelo Dimensional (Fact & Dim Tables)
 └───────┬───────┘
         │
         ▼
 ┌───────────────┐
 │   Power BI    │ <-- Dashboard Ejecutivo Interactivo (4 Páginas)
 └───────────────┘
