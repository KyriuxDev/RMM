# Arquitectura — Sistema RMM (Monitoreo y Administración Remota de Equipos)

> Sistema de Monitoreo y Administración Remota de Equipos de Cómputo — IMSS Oaxaca
> Instituto Tecnológico de Oaxaca · Ingeniería en Sistemas Computacionales · Ago–Dic 2026
> Basado en: Propuesta de Anteproyecto + Complemento (Épicas, CRONOGRAMA, HU) · Patrón `profe-santiago/spring_boot`

## 1. Stack

| Capa          | Tecnología                          | Nota                                                        |
|---------------|-------------------------------------|-------------------------------------------------------------|
| Backend       | Spring Boot 3.x + Java 21           | Multicapa, `.env`, Flyway, Swagger (patrón del profe)       |
| Build         | Maven 3.9.9                         | Misma estructura que el ref (que usa Gradle)                |
| BD            | PostgreSQL 17                       | Se inicia servicio local y se crea `rmm_db`                 |
| Migraciones   | Flyway (`V1__*.sql`)                | `ddl-auto=validate`                                         |
| Auth          | JWT (JJWT 0.12.6) + roles           | ADMINISTRADOR / SUPERVISOR / TECNICO                        |
| API docs      | SpringDoc Swagger (`/api/docs`)     |                                                             |
| Frontend      | Angular 21 + Bootstrap + Chart.js   | SPA standalone                                              |
| Email         | spring-boot-starter-mail            | Alertas críticas (HU-15)                                    |
| Reportes      | Apache POI (Excel) + OpenPDF (PDF)  | HU-13                                                       |
| Agente        | **C / Win32** (`TrayC`)             | "DataScan", bandeja de Windows; se extiende dentro de TrayC |

Roles del documento: `ADMINISTRADOR` = Jefe de Oficina · `SUPERVISOR` = Supervisor de Instalaciones · `TECNICO` = Auxiliar de Soporte Técnico.

## 2. Estructura de carpetas

```
rmm/
├── backend/
│   ├── .env / .env.example          # DB_*, JWT_*, SMTP_*, APP_*
│   ├── pom.xml
│   └── src/main/
│       ├── java/.../rmm/
│       │   ├── RmmApplication.java
│       │   ├── config/              # SecurityConfig, OpenApiConfig, JwtFilter, ProgramadorAlertas
│       │   ├── autenticacion/       # login, usuario actual
│       │   ├── usuarios/            # usuarios y roles
│       │   ├── unidades/            # jerarquía organizacional
│       │   ├── equipos/             # + hardware + software_instalado
│       │   ├── telemetria/          # métricas del agente
│       │   ├── agente/              # endpoints del agente C
│       │   ├── alertas/             # + umbrales
│       │   ├── incidencias/
│       │   └── reportes/
│       └── resources/db/migration/  # V1..V6
└── frontend/                        # ng new (standalone, routing)
```

Capas por dominio (patrón del ref): `Controller` → `Service` → `Repository` + `dto/` (entrada con Bean Validation, salida sin exponer internos).

## 3. Modelo de datos (Flyway V1..V6)

| Tabla                 | Campos clave                                                                 |
|-----------------------|------------------------------------------------------------------------------|
| `usuarios`            | nombre, email (único), password_hash (BCrypt), `rol`, activo, creado_en      |
| `unidades`            | nombre, tipo (`HOSPITAL\|UNIDAD_MEDICA\|ADMINISTRATIVA`), unidad_padre_id, ubicacion |
| `equipos`             | hostname (único), ip, sistema_operativo, unidad_id, `token_agente`, estado (`EN_LINEA\|FUERA_DE_LINEA`), ultima_conexion, responsable, activo |
| `hardware`            | 1:1 con equipos: cpu, ram_gb, disco_gb, perifericos                          |
| `software_instalado`  | equipo_id, nombre, version, `antivirus`, `autorizado`                        |
| `telemetria`          | equipo_id, cpu_pct, ram_pct, disco_pct, registrada_en (índice + tiempo)      |
| `umbrales`            | recurso (`CPU\|RAM\|DISCO`), maximo, advertencia, unidad_id/tipo opcional    |
| `alertas`             | equipo_id, tipo (`FUERA_DE_LINEA\|RECURSOS\|SEGURIDAD`), severidad (`ADVERTENCIA\|CRITICA`), mensaje, estado, creada_en, resuelta_en, resuelta_por |
| `incidencias`         | equipo_id, descripcion, prioridad (`BAJA\|MEDIA\|ALTA`), estado (`NUEVA\|EN_PROGRESO\|RESUELTA\|CANCELADA`), asignada_a, creada_por, creada_en, resuelta_en |

## 4. API

### Web (JWT + roles)

| Método | Endpoint                                      | HU   |
|--------|-----------------------------------------------|------|
| POST   | `/api/v1/auth/login` · GET `/api/v1/auth/me`  | –    |
| GET    | `/api/v1/unidades`                            | catálogo |
| GET    | `/api/v1/equipos` (paginado + filtros unidad/estado/texto) | HU-11 |
| POST   | `/api/v1/equipos` · PUT · PATCH `/{id}/baja`  | HU-9 |
| GET    | `/api/v1/equipos/{id}` (ficha completa)       | HU-10 |
| GET    | `/api/v1/equipos/{id}/historial` (telemetria + eventos) | HU-6 |
| GET    | `/api/v1/dashboard` (indicadores + % por unidad) | HU-12 |
| GET    | `/api/v1/alertas` · PATCH `/{id}/resolver`    | HU-5 |
| GET/POST/PUT | `/api/v1/umbrales`                     | HU-3 |
| POST/GET/PATCH | `/api/v1/incidencias` (+ asignar/estado) | HU-7 |
| GET    | `/api/v1/trabajo/mio` (actividad asignada al técnico) | HU-14 |
| GET    | `/api/v1/reportes/disponibilidad?unidad=&desde=&hasta=` + `exportar.{pdf,xlsx}` | HU-13 |

### Agente DataScan (`TrayC`) — estado actual y cambios

Agente en C/Win32 (bandeja de Windows). Recopilación lista hoy (`gather_hardware`): hostname, usuario, dominio, IP, MAC, marca, modelo, serial (WMI), versión del SO y último parche (`KB + fecha`). Además: autoarranque, singleton, `Ctrl+Alt+I` (datos), `Alt+Shift+Q` (QR) y firma con certificado de codesign.

Módulos: `src/main.c` (arranque/singleton/tray), `src/hwinfo.c` (hardware/IP/SO/parche), `src/tray.c` (bandeja + ventana de datos + QR), `crypto`/`qr_gen` (soporte), `Makefile`/`build.sh` (compilación y firma).

**En `TrayC`**:
- ✔ Lectura de **CPU, RAM y disco** (`gather_telemetry`) — HU-2.
- ✔ Listado de **software instalado** (registro Uninstall) y **antivirus** (WMI SecurityCenter2), con lista local `noautorizado.txt` — HU-8.
- **Pendiente:** cliente **HTTP(S)** al servidor central (registro/telemetría/inventario con reintento) — HU-1.

### API de agente (API key por agente, emitida en el registro)

| Método | Endpoint                    | Body                                    | HU   |
|--------|-----------------------------|-----------------------------------------|------|
| POST   | `/api/agente/registro`      | hostname, mac, ip, sistema_operativo, marca, modelo, serial, ultimo_parche → `{equipoId, tokenAgente}` · auto-alta + reintento | HU-1 |
| POST   | `/api/agente/telemetria`    | `{cpu, ram, disco}` (por agregar en el agente) | HU-2 |
| POST   | `/api/agente/inventario`    | `{software[], antivirusActivo, noAutorizado[]}` (por agregar en el agente) | HU-8 |

### Motor de alertas (programador ~60 s)

- Equipo sin telemetría > 5 min → alerta `FUERA_DE_LINEA`.
- Uso sobre umbral **persistente 2 corridas** → `RECURSOS` (evita falsos picos).
- Antivirus apagado / software no autorizado → `SEGURIDAD` + **email al ADMINISTRADOR**.
- Auto-resolución cuando la condición se normaliza.

## 5. Frontend (Bootstrap + Chart.js)

Páginas: `/login` · `/dashboard` (Chart.js) · `/equipos` (tabla filtrable + alta/edición/baja) · `/equipos/:id` (ficha + historial) · `/alertas` + `/umbrales` · `/incidencias` · `/reportes` (rango + export PDF/Excel).

Menú por roles. Refresco por polling cada 30 s (el doc acepta ≤ 5 min).

## 6. Orden de implementación (mapeado a las 5 iteraciones del cronograma)

1. **Base** — Initializr, `.env`, Flyway V1 (usuarios/unidades), JWT, Swagger, login Angular
2. **Iteración 1 · Monitoreo** — equipos/hardware/software/telemetría + contrato del agente, listado, dashboard
3. **Iteración 2 · Incidencias** — incidencias, historial por equipo, "mi actividad"
4. **Iteración 3 · Alertas** — umbrales, motor de alertas, listado, email críticas
5. **Iteración 4 · Reportes** — analítica y exportación
6. **Iteración 5 · Inventario** — CRUD manual, filtros, ficha; *seed* con `equipos_todos.csv` del workspace o simulador

## 7. Puntos abiertos

- Agente: definir lectura de CPU/RAM/disco y software/antivirus en C (WMI/Pdh) y el cliente HTTP al servidor.
- Exportación con gráficos embebidos: simplificar a tablas exportadas + gráficas solo en pantalla.
- Iniciar PostgreSQL local o usar MariaDB de XAMPP si el arranque de PG falla.