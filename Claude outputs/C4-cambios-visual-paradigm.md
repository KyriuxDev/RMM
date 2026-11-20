# C4 · Cambios en Visual Paradigm

Archivo: `Claude outputs/project_rmm_c4.xml` (sale de tu `project.xml` del 19-nov).
Para abrirlo: **Project → Import → XML**, o ábrelo como proyecto nuevo y compáralo antes de reemplazar el tuyo.

## 1. Ya aplicado en el XML

**Modelo de datos.** Cada tabla es un solo modelo que comparten todos los ERD, así que el cambio aparece en todos (UML-1…5, los ERD por par y los diagramas de clases):

| Tabla / clase | Cambio |
|---|---|
| Usuario | + `Matricula` varchar(15) única / `matricula : string` |
| Usuario | + `IntentosFallidos` integer / `intentosFallidos : int` |
| Usuario | + `BloqueadoHasta` timestamp / `bloqueadoHasta : Timestamp` |
| Usuario | + operaciones `editarDatos(matricula, nombre, correo, estaActivo)` y `estaBloqueado(ahora) : boolean` |
| Equipo | + `FechaBaja` timestamp, + `MotivoBaja` varchar(255) |
| Equipo | `AreaID` pasa de varchar a integer (como `equipo.id_area`) |

Las figuras de Usuario y Equipo tienen el ajuste de tamaño automático activado. Si alguna se ve cortada, haz clic derecho en ella y elige **Fit Size**.

**Diagramas de secuencia** (los mensajes quedan con el mismo nombre que el método del código):

| Diagrama | Antes | Ahora |
|---|---|---|
| SD-07a | `crear(nombre, correo, unidad, contraseñaTemporal)` | `crear(matricula, nombre, correo, rol, contraseñaTemporal)` |
| SD-07a | `verificarCorreoDisponible(correo)` | `verificarMatriculaYCorreoDisponibles(matricula, correo)` |
| SD-07a | `editarDatos(datos)` | `editarDatos(matricula, nombre, correo, estaActivo)` |
| SD-07c | `guardarMetaSLA(indicador, valorMeta, periodo)` | `guardarMetaSLA(indicador, valorMeta, ambito, valorAmbito)` |
| SD-07c | `crear(nombre, indicador, valorMeta, unidadMedida, periodo)` | `crear(indicador, valorMeta, unidadMedida, ambito, valorAmbito)` |
| SD-05c | `seleccionarHospital(claveUi)` / `listarAreas(claveUi)` | `…(idUnidadHomologada)` |
| SD-05c | `darDeBaja(idEquipo)` (2 mensajes) | `darDeBaja(idEquipo, motivoBaja)` |
| SD-05c | `darDeBaja(confirmacion)` | `darDeBaja(motivoBaja, fechaBaja)` |
| SD-05c | `actualizarEstadoEquipo(idEquipo, "INACTIVO")` | `…("INACTIVO", fechaBaja, motivoBaja)` |

SD-00a y SD-00b ya coincidían con el código nuevo (AuthController, bloqueo a los 3 intentos, cerrar sesión), así que no se tocaron.

## 2. Falta hacerlo a mano (≈ 15 min)

1. **SD-07b Consultar catálogo de unidades.** Borra los mensajes viejos, de `guardarUnidad(idUnidad, datos)` hasta el último `resultado`, junto con los fragmentos `alt [unidadNueva…]` y `opt [el jefe desactiva una unidad]`. Deja sólo esta secuencia: `consultarUnidades(filtro)` → `listarUnidades(filtro)` → `recuperarUnidades(filtro)` → `unidades` → `listaUnidades` → `mostrarCatalogo(listaUnidades)`. Hay dos mensajes con el número 7; al borrar se reacomoda la numeración.
2. **SN-07b.** Borra el último tramo, `seleccionar(unidad)` → `navegar` → `mostrar`: el catálogo sólo se consulta y no tiene ficha de unidad.
3. **IOD nuevo: «IOD-08 Funcionalidad realizada (C4)»** (Interaction Overview Diagram). Es el punto 4 de la entrega:
   - Inicial → **SD-00a Iniciar sesión** → decisión «¿Credenciales válidas?» ([no] regresa a SD-00a).
   - [sí] → decisión «¿Qué sección eligió?» → **SD-07a Usuarios y roles** | **SD-07b Consultar catálogo de unidades** | **SD-07c Metas SLA** | **SD-05c Gestión manual de equipos** (alta, edición y baja).
   - Todas llegan a un merge → decisión «¿Cerrar sesión?» → [sí] **SD-00b Cerrar sesión** → final; [no] regresa a «¿Qué sección eligió?».
   - Para que salgan los marcos, arrastra cada SD desde el Model Explorer al diagrama (*Interaction Use*).
4. **PR-18 Administración.** En el código son 4 páginas. Lo mínimo es cambiar en «Usuarios registrados» la columna `Unidad` por `Matrícula`, porque la tabla `usuario` no tiene unidad. Opcional: agregar **PR-18c Unidades** (filtro: clave o nombre, hospital, región, régimen; tabla) y **PR-18d Metas SLA** (indicador, meta, ámbito; tabla con «Editar»).
5. **PR-12 Inventario de equipos.** Lo programado es la versión básica: búsqueda, filtro por estado, tabla con «Editar» y «Nuevo equipo». En el PDF indiquen que los KPI y la ficha completa (PR-13) son de la siguiente iteración.

## 3. Código ↔ diagrama (para el PDF)

| Línea de vida | Código |
|---|---|
| `loginPage` / PR-01 | `vista/acceso/login.xhtml` |
| `authCtrl` (SD-00a, SD-00b) | `controlador.AuthController` (sesión) + `logica_negocio.AutenticacionBean` |
| `plantilla` (SD-00b) | `plantillas/partes/pie.xhtml` → «Cerrar sesión» |
| PR-19 | `vista/acceso/acceso-denegado.xhtml`, `sesion-expirada.xhtml`, `filtro.FiltroAcceso` |
| `adminPage` / `adminCtrl` (SD-07a) | `administracion/usuarios.xhtml`, `roles-permisos.xhtml` / `AdministracionController`, `RolesController` → `AdministracionBean` |
| SD-07b / SD-07c | `unidades.xhtml` / `UnidadesController` → `CatalogoUnidadesBean`; `metas-sla.xhtml` / `MetasSlaController` → `MetasSlaBean` |
| `equipoFormPage` / `inventarioCtrl` (SD-05c) | `inventario/alta-equipo.xhtml` (alta, `?id=N` edición, diálogo de baja) / `InventarioController` → `InventarioBean` |
| InventarioEquipos (SN-05c) | `inventario/equipos.xhtml` / `EquiposController` |
| `usr`, `rol`, `equipo`, `hw`, `sla` | `modelo.*` (`Usuario.registrarIntentoFallido()`, `Rol.obtenerPermisos()`, `Equipo.darDeBaja()`, …) |
| `DBMS` | `acceso_datos.*Facade` → MySQL |
