package logica_negocio;

import acceso_datos.AlertaFacade;
import acceso_datos.EquipoFacade;
import acceso_datos.IncidenciaFacade;
import acceso_datos.IncidenciasConsultaFacade;
import acceso_datos.UsuarioFacade;
import excepciones.Excepciones;
import jakarta.ejb.EJB;
import jakarta.ejb.LocalBean;
import jakarta.ejb.Stateless;
import java.io.Serializable;
import java.time.LocalDate;
import java.time.ZoneId;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.Date;
import java.util.List;
import java.util.Locale;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import modelo.Alerta;
import modelo.Equipo;
import modelo.Incidencia;
import modelo.Usuario;

/**
 * Lógica de Incidencias.
 *
 *   - HU-7  registrarManual(): incidencia reportada por un usuario (origen "Manual").
 *   - Alertas  registrarDesdeAlerta(): incidencia creada a partir de una alerta
 *     (origen "Alerta"). La usa el módulo de Alertas.
 *   - listar(): manuales y de alertas juntas, con filtros.
 *
 * Los formatos los valida la vista; aquí queda el respaldo (datos obligatorios,
 * equipo activo y técnico válido), igual que en InventarioBean.
 *
 * @author Sesma
 */
@Stateless
@LocalBean
public class IncidenciasBean {

    /** Valores de incidencia.estado / origen / prioridad. */
    public static final String ESTADO_ABIERTA = "Abierta";
    public static final String ESTADO_EN_PROCESO = "EnProceso";
    public static final String ESTADO_RESUELTA = "Resuelta";
    public static final String ORIGEN_MANUAL = "Manual";
    public static final String ORIGEN_ALERTA = "Alerta";

    /** Prioridades que se pueden elegir al registrar. */
    public static final List<String> PRIORIDADES = List.of("Alta", "Media", "Baja");
    public static final List<String> ESTADOS = List.of("Abierta", "EnProceso", "Resuelta", "Cerrada");
    public static final List<String> ORIGENES = List.of(ORIGEN_MANUAL, ORIGEN_ALERTA);

    private static final int MAX_DESCRIPCION = 255;
    private static final int MAX_SUGERENCIAS = 10;

    /** Tipos de evento del filtro de Historial por equipo (HU-6). */
    public static final String TIPO_TODOS = "TODOS";
    public static final String TIPO_ALERTAS = "ALERTAS";
    public static final String TIPO_INCIDENCIAS = "INCIDENCIAS";

    /** Tope de eventos que regresa el historial de un equipo. */
    private static final int MAX_EVENTOS = 200;

    /** Las fechas "desde / hasta" se toman como días de esta zona (igual que las vistas). */
    private static final ZoneId ZONA = ZoneId.of("America/Mexico_City");

    /** "INC-0016", "inc16" o "16". */
    private static final Pattern CODIGO = Pattern.compile("(?i)^(?:INC-?)?0*(\\d+)$");

    @EJB
    private IncidenciaFacade incidenciaFacade;

    @EJB
    private IncidenciasConsultaFacade consultaFacade;

    @EJB
    private EquipoFacade equipoFacade;

    @EJB
    private AlertaFacade alertaFacade;

    @EJB
    private UsuarioFacade usuarioFacade;

    @EJB
    private AdministracionBean administracionBean;

    // ------------------------------------------------------------------
    // Registro (HU-7 y desde alertas)
    // ------------------------------------------------------------------

    /**
     * HU-7: registra una incidencia reportada por un usuario.
     *
     * @param hostname    equipo afectado
     * @param descripcion descripción de la falla (obligatoria, máximo 255)
     * @param prioridad   Alta, Media o Baja
     * @param idTecnico   usuario al que se asigna
     * @return la incidencia registrada, con su id asignado
     */
    public Incidencia registrarManual(String hostname, String descripcion, String prioridad, Integer idTecnico) {
        String h = InventarioBean.normalizarHostname(hostname);
        Validacion.requerido(h, "equipo", "Seleccione el equipo afectado");
        String d = Validacion.limpiar(descripcion);
        Validacion.requerido(d, "descripcion", "Describa la falla");
        if (d.length() > MAX_DESCRIPCION) {
            throw new Excepciones("descripcion", "La descripción no puede pasar de " + MAX_DESCRIPCION + " caracteres");
        }
        String p = prioridadValida(prioridad);
        Validacion.requerido(idTecnico, "tecnico", "Seleccione el técnico a quien se asigna");

        Equipo equipo = equipoFacade.buscarPorHostname(h);
        if (equipo == null) {
            throw new Excepciones("equipo", "No existe un equipo con el hostname " + h);
        }
        if (!equipo.getEstaActivo()) {
            throw new Excepciones("equipo", "El equipo " + equipo.getHostname()
                    + " está dado de baja; no se le pueden registrar incidencias");
        }
        Usuario tecnico = tecnicoValido(idTecnico);

        return crear(equipo, d, p, ORIGEN_MANUAL, null, tecnico);
    }

    /**
     * Crea la incidencia de una alerta (la llama el módulo de Alertas).
     *
     *   - origen "Alerta", estado "Abierta", con id_alerta apuntando a la alerta.
     *   - equipo y descripción salen de la alerta.
     *   - prioridad según la gravedad: Critica → Alta, Advertencia → Media, Informativa → Baja.
     *   - Si la alerta ya tiene una incidencia sin resolver, NO crea otra: regresa esa.
     *   - No cambia el estado de la alerta (eso lo hace el módulo de Alertas).
     *
     * @param idAlerta          alerta de origen
     * @param idUsuarioAsignado técnico al que se asigna (activo y con permiso de incidencias)
     */
    public Incidencia registrarDesdeAlerta(Integer idAlerta, Integer idUsuarioAsignado) {
        Validacion.requerido(idAlerta, "alerta", "Falta la alerta de origen");
        Validacion.requerido(idUsuarioAsignado, "tecnico", "Seleccione el técnico a quien se asigna");

        Alerta alerta = alertaFacade.find(idAlerta);
        if (alerta == null) {
            throw new Excepciones("alerta", "La alerta ya no existe");
        }
        Incidencia existente = consultaFacade.abiertaDeAlerta(idAlerta);
        if (existente != null) {
            return existente;
        }
        Usuario tecnico = tecnicoValido(idUsuarioAsignado);

        String texto = Validacion.limpiar(alerta.getDescripcion());
        if (texto == null) {
            texto = Validacion.limpiar(alerta.getTipoAlerta());
        }
        if (texto == null) {
            texto = "Alerta " + idAlerta;
        }
        return crear(alerta.getIdEquipo(), recortar(texto), prioridadDeGravedad(alerta.getNivelGravedad()),
                ORIGEN_ALERTA, alerta, tecnico);
    }

    private Incidencia crear(Equipo equipo, String descripcion, String prioridad, String origen,
            Alerta alerta, Usuario tecnico) {
        Incidencia i = new Incidencia();
        i.setIdEquipo(equipo);
        i.setDescripcion(descripcion);
        i.setPrioridad(prioridad);
        i.setEstado(ESTADO_ABIERTA);
        i.setOrigen(origen);
        i.setIdAlerta(alerta);
        i.setIdUsuario(tecnico);
        i.setFechaRegistro(new Date());   // JPA no usa el DEFAULT de la columna
        incidenciaFacade.create(i);
        return i;
    }

    // ------------------------------------------------------------------
    // Consultas para la pantalla
    // ------------------------------------------------------------------

    /**
     * Lista de incidencias (manuales y de alertas juntas). Todos los filtros son opcionales.
     * El texto busca en descripción, hostname y técnico; también acepta "INC-0016" o "16".
     */
    public List<Incidencia> listar(String texto, String estado, String prioridad, String origen) {
        String t = Validacion.limpiar(texto);
        Integer id = null;
        if (t != null) {
            Matcher m = CODIGO.matcher(t);
            if (m.matches() && m.group(1).length() <= 9) {
                id = Integer.valueOf(m.group(1));
            }
        }
        return consultaFacade.buscar(t, id, Validacion.limpiar(estado),
                Validacion.limpiar(prioridad), Validacion.limpiar(origen));
    }

    /** Equipo activo con ese hostname, o null (para mostrar su detalle en el formulario). */
    public Equipo buscarEquipoActivo(String hostname) {
        String h = InventarioBean.normalizarHostname(hostname);
        if (h == null) {
            return null;
        }
        Equipo e = equipoFacade.buscarPorHostname(h);
        return e != null && e.getEstaActivo() ? e : null;
    }

    /** Hostnames de equipos activos que coinciden con lo escrito (hostname, IP, MAC o unidad). */
    public List<String> sugerirHostnames(String texto) {
        String t = Validacion.limpiar(texto);
        List<String> r = new ArrayList<>();
        if (t == null) {
            return r;
        }
        for (Equipo e : equipoFacade.buscarInventario(t, null, null)) {
            if (e.getEstaActivo()) {
                r.add(e.getHostname());
                if (r.size() >= MAX_SUGERENCIAS) {
                    break;
                }
            }
        }
        return r;
    }

    /** Usuarios a quienes se puede asignar: activos y con permiso GESTIONAR_INCIDENCIAS. */
    public List<Usuario> tecnicosAsignables() {
        List<Usuario> r = new ArrayList<>();
        for (Usuario u : administracionBean.listarUsuariosActivos()) {
            if (puedeGestionarIncidencias(u)) {
                r.add(u);
            }
        }
        return r;
    }

    // ------------------------------------------------------------------
    // Mi actividad (HU-14)
    // ------------------------------------------------------------------

    /**
     * HU-14: incidencias pendientes (Abierta o EnProceso) asignadas a un usuario,
     * de la más prioritaria a la menos y, dentro de cada prioridad, la más reciente primero.
     */
    public List<Incidencia> misPendientes(Integer idUsuario) {
        Validacion.requerido(idUsuario, "usuario", "No se identificó al usuario");
        List<Incidencia> r = new ArrayList<>(consultaFacade.pendientesDeUsuario(idUsuario));
        r.sort(Comparator.comparingInt((Incidencia i) -> pesoPrioridad(i.getPrioridad()))
                .thenComparing(Incidencia::getFechaRegistro,
                        Comparator.nullsLast(Comparator.<Date>reverseOrder())));
        return r;
    }

    /**
     * HU-14: el técnico empieza a atender su incidencia (Abierta → EnProceso).
     *
     * @param idUsuario usuario en sesión: sólo puede mover incidencias asignadas a él
     */
    public Incidencia iniciarAtencion(Integer idIncidencia, Integer idUsuario) {
        Incidencia i = incidenciaDelUsuario(idIncidencia, idUsuario);
        if (!esEstado(i.getEstado(), ESTADO_ABIERTA)) {
            throw new Excepciones("incidencia", codigo(i) + " ya no está abierta (estado actual: "
                    + etiquetaEstado(i.getEstado()) + ")");
        }
        i.setEstado(ESTADO_EN_PROCESO);
        incidenciaFacade.edit(i);
        return i;
    }

    /**
     * HU-14: el técnico marca como resuelta su incidencia (EnProceso → Resuelta) y
     * queda registrada la fecha de resolución.
     */
    public Incidencia marcarResuelta(Integer idIncidencia, Integer idUsuario) {
        Incidencia i = incidenciaDelUsuario(idIncidencia, idUsuario);
        if (!esEstado(i.getEstado(), ESTADO_EN_PROCESO)) {
            throw new Excepciones("incidencia", "Primero inicie la atención de " + codigo(i)
                    + " (estado actual: " + etiquetaEstado(i.getEstado()) + ")");
        }
        i.setEstado(ESTADO_RESUELTA);
        i.setFechaResolucion(new Date());
        incidenciaFacade.edit(i);
        return i;
    }

    /** La incidencia, siempre que exista y esté asignada a ese usuario. */
    private Incidencia incidenciaDelUsuario(Integer idIncidencia, Integer idUsuario) {
        Validacion.requerido(idIncidencia, "incidencia", "Falta la incidencia");
        Validacion.requerido(idUsuario, "usuario", "No se identificó al usuario");
        Incidencia i = incidenciaFacade.find(idIncidencia);
        if (i == null) {
            throw new Excepciones("incidencia", "La incidencia ya no existe");
        }
        if (i.getIdUsuario() == null || !idUsuario.equals(i.getIdUsuario().getIdUsuario())) {
            throw new Excepciones("incidencia", codigo(i) + " no está asignada a usted");
        }
        return i;
    }

    /** "EnProceso", "En proceso" y "EN_PROCESO" cuentan como el mismo estado. */
    private static boolean esEstado(String actual, String esperado) {
        return actual != null && actual.replace(" ", "").replace("_", "").equalsIgnoreCase(esperado);
    }

    /** Critica 0, Alta 1, Media 2, cualquier otra 3 (para ordenar). */
    private static int pesoPrioridad(String prioridad) {
        String p = prioridad == null ? "" : prioridad.trim().toUpperCase(Locale.ROOT);
        if (p.startsWith("CRIT")) {
            return 0;
        }
        if (p.startsWith("ALTA")) {
            return 1;
        }
        return p.startsWith("MEDIA") ? 2 : 3;
    }

    // ------------------------------------------------------------------
    // Historial por equipo (HU-6)
    // ------------------------------------------------------------------

    /**
     * HU-6: línea de tiempo de un equipo con sus alertas y sus incidencias juntas, de
     * la más reciente a la más antigua. Funciona también con equipos dados de baja
     * (su historial se conserva).
     *
     * @param hostname equipo a consultar (obligatorio)
     * @param tipo     TODOS, ALERTAS o INCIDENCIAS (null = TODOS)
     * @param desde    primer día a incluir (opcional)
     * @param hasta    último día a incluir (opcional)
     */
    public Historial historialPorEquipo(String hostname, String tipo, LocalDate desde, LocalDate hasta) {
        String h = InventarioBean.normalizarHostname(hostname);
        Validacion.requerido(h, "equipo", "Seleccione el equipo a consultar");
        String t = tipoHistorial(tipo);
        if (desde != null && hasta != null && hasta.isBefore(desde)) {
            throw new Excepciones("hasta", "La fecha final no puede ser anterior a la inicial");
        }
        Equipo equipo = equipoFacade.buscarPorHostname(h);
        if (equipo == null) {
            throw new Excepciones("equipo", "No existe un equipo con el hostname " + h);
        }

        // "hasta" se manda como el inicio del día siguiente para incluir todo ese día
        Date inicio = desde == null ? null : Date.from(desde.atStartOfDay(ZONA).toInstant());
        Date fin = hasta == null ? null : Date.from(hasta.plusDays(1).atStartOfDay(ZONA).toInstant());

        List<EventoHistorial> eventos = new ArrayList<>();
        if (!TIPO_INCIDENCIAS.equals(t)) {
            for (Alerta a : consultaFacade.alertasDeEquipo(equipo.getIdEquipo(), inicio, fin, MAX_EVENTOS + 1)) {
                eventos.add(eventoDeAlerta(a));
            }
        }
        if (!TIPO_ALERTAS.equals(t)) {
            for (Incidencia i : consultaFacade.incidenciasDeEquipo(equipo.getIdEquipo(), inicio, fin, MAX_EVENTOS + 1)) {
                eventos.add(eventoDeIncidencia(i));
            }
        }
        eventos.sort(Comparator.comparing(EventoHistorial::getFecha,
                Comparator.nullsLast(Comparator.<Date>reverseOrder())));

        boolean truncado = eventos.size() > MAX_EVENTOS;
        if (truncado) {
            eventos = new ArrayList<>(eventos.subList(0, MAX_EVENTOS));
        }
        return new Historial(equipo, eventos, truncado);
    }

    /** Equipo por id (para abrir el historial desde otra pantalla), o null. */
    public Equipo buscarEquipo(Integer idEquipo) {
        return idEquipo == null ? null : equipoFacade.find(idEquipo);
    }

    /** Como sugerirHostnames(), pero incluye equipos dados de baja: su historial se conserva. */
    public List<String> sugerirEquipos(String texto) {
        String t = Validacion.limpiar(texto);
        List<String> r = new ArrayList<>();
        if (t == null) {
            return r;
        }
        for (Equipo e : equipoFacade.buscarInventario(t, null, null)) {
            r.add(e.getHostname());
            if (r.size() >= MAX_SUGERENCIAS) {
                break;
            }
        }
        return r;
    }

    private static String tipoHistorial(String tipo) {
        String t = Validacion.limpiar(tipo);
        if (t == null) {
            return TIPO_TODOS;
        }
        t = t.toUpperCase(Locale.ROOT);
        if (TIPO_TODOS.equals(t) || TIPO_ALERTAS.equals(t) || TIPO_INCIDENCIAS.equals(t)) {
            return t;
        }
        throw new Excepciones("tipo", "Elija un tipo de evento válido");
    }

    private static EventoHistorial eventoDeAlerta(Alerta a) {
        String tipoLegible = tipoAlertaLegible(a.getTipoAlerta());
        String titulo = Validacion.limpiar(a.getDescripcion());
        if (titulo == null) {
            titulo = tipoLegible;
        }
        List<String> partes = new ArrayList<>();
        partes.add("Gravedad " + gravedadLegible(a.getNivelGravedad()));
        partes.add(tipoLegible);
        Incidencia escalada = ultimaIncidencia(a.getIncidenciaList());
        if (escalada != null) {
            partes.add("Escalada a " + codigo(escalada));
        }
        return new EventoHistorial(a.getFechaGeneracion(), "Alerta", titulo,
                String.join(" · ", partes), etiquetaEstado(a.getEstado()), nivelAlerta(a.getNivelGravedad()));
    }

    private static EventoHistorial eventoDeIncidencia(Incidencia i) {
        List<String> partes = new ArrayList<>();
        partes.add(ORIGEN_ALERTA.equalsIgnoreCase(i.getOrigen()) ? "Escalada desde alerta" : "Reporte manual");
        if (i.getPrioridad() != null) {
            partes.add("Prioridad " + i.getPrioridad());
        }
        if (i.getIdUsuario() != null) {
            partes.add("Asignada a " + i.getIdUsuario().getNombre());
        }
        if (i.getFechaResolucion() != null && i.getFechaRegistro() != null) {
            partes.add("Resuelta en " + duracion(i.getFechaRegistro(), i.getFechaResolucion()));
        }
        return new EventoHistorial(i.getFechaRegistro(), "Incidencia",
                codigo(i) + " · " + i.getDescripcion(), String.join(" · ", partes),
                etiquetaEstado(i.getEstado()), "incidencia");
    }

    /** La incidencia más reciente que nació de la alerta, o null. */
    private static Incidencia ultimaIncidencia(List<Incidencia> lista) {
        Incidencia r = null;
        if (lista != null) {
            for (Incidencia i : lista) {
                if (r == null || (i.getIdIncidencia() != null && r.getIdIncidencia() != null
                        && i.getIdIncidencia() > r.getIdIncidencia())) {
                    r = i;
                }
            }
        }
        return r;
    }

    /** "UsoAnomalo" → "Uso anómalo", "Desconexion" → "Desconexión"... */
    private static String tipoAlertaLegible(String tipo) {
        String t = tipo == null ? "" : tipo.trim().toLowerCase(Locale.ROOT);
        switch (t) {
            case "usoanomalo":
                return "Uso anómalo";
            case "riesgoseguridad":
                return "Riesgo de seguridad";
            case "desconexion":
                return "Desconexión";
            default:
                return t.isEmpty() ? "Alerta" : tipo.trim();
        }
    }

    private static String gravedadLegible(String nivel) {
        String n = nivel == null ? "" : nivel.trim().toLowerCase(Locale.ROOT);
        return n.startsWith("cr") ? "crítica" : n.startsWith("adv") ? "advertencia" : "informativa";
    }

    /** Código para el color en la vista: critica, advertencia o info. */
    private static String nivelAlerta(String nivel) {
        String n = nivel == null ? "" : nivel.trim().toLowerCase(Locale.ROOT);
        return n.startsWith("cr") ? "critica" : n.startsWith("adv") ? "advertencia" : "info";
    }

    /** "EnProceso" → "En proceso", "ACTIVA" → "Activa". */
    private static String etiquetaEstado(String estado) {
        if (estado == null || estado.isBlank()) {
            return "—";
        }
        String e = estado.trim().replace('_', ' ').toLowerCase(Locale.ROOT);
        if (e.equals("enproceso") || e.equals("en proceso")) {
            return "En proceso";
        }
        return Character.toUpperCase(e.charAt(0)) + e.substring(1);
    }

    /** "35 min", "2 h 10 min", "3 d 4 h". */
    private static String duracion(Date desde, Date hasta) {
        long min = Math.max(0, (hasta.getTime() - desde.getTime()) / 60000);
        if (min < 60) {
            return min + " min";
        }
        long horas = min / 60;
        if (horas < 24) {
            long m = min % 60;
            return m == 0 ? horas + " h" : horas + " h " + m + " min";
        }
        long dias = horas / 24;
        long h = horas % 24;
        return h == 0 ? dias + " d" : dias + " d " + h + " h";
    }

    /** "INC-0016": el mismo formato que usa la ficha del equipo. */
    public static String codigo(Incidencia i) {
        return i == null || i.getIdIncidencia() == null ? "—"
                : String.format(Locale.ROOT, "INC-%04d", i.getIdIncidencia());
    }

    /** Critica → Alta, Advertencia → Media, cualquier otra → Baja. */
    public static String prioridadDeGravedad(String nivelGravedad) {
        String n = nivelGravedad == null ? "" : nivelGravedad.trim().toLowerCase(Locale.ROOT);
        if (n.startsWith("cr")) {
            return "Alta";
        }
        return n.startsWith("adv") ? "Media" : "Baja";
    }

    // ------------------------------------------------------------------
    // Auxiliares
    // ------------------------------------------------------------------

    /** Prioridad con la mayúscula de la lista (acepta "alta", "ALTA"...). */
    private static String prioridadValida(String prioridad) {
        String p = Validacion.limpiar(prioridad);
        Validacion.requerido(p, "prioridad", "Seleccione la prioridad");
        for (String valida : PRIORIDADES) {
            if (valida.equalsIgnoreCase(p)) {
                return valida;
            }
        }
        throw new Excepciones("prioridad", "La prioridad debe ser Alta, Media o Baja");
    }

    /** Usuario activo con permiso de incidencias, o error. */
    private Usuario tecnicoValido(Integer idUsuario) {
        Usuario u = usuarioFacade.find(idUsuario);
        if (u == null) {
            throw new Excepciones("tecnico", "El técnico seleccionado no existe");
        }
        if (!u.getEstaActivo()) {
            throw new Excepciones("tecnico", u.getNombre() + " está inactivo; elija otro técnico");
        }
        if (!puedeGestionarIncidencias(u)) {
            throw new Excepciones("tecnico", u.getNombre() + " no tiene permiso para atender incidencias");
        }
        return u;
    }

    private static boolean puedeGestionarIncidencias(Usuario u) {
        return u.getIdRol() != null
                && u.getIdRol().obtenerPermisos().contains(Permiso.GESTIONAR_INCIDENCIAS.name());
    }

    /** Resultado del historial de un equipo (HU-6). */
    public static final class Historial implements Serializable {

        private static final long serialVersionUID = 1L;

        private final Equipo equipo;
        private final List<EventoHistorial> eventos;
        private final boolean truncado;

        Historial(Equipo equipo, List<EventoHistorial> eventos, boolean truncado) {
            this.equipo = equipo;
            this.eventos = eventos;
            this.truncado = truncado;
        }

        public Equipo getEquipo() {
            return equipo;
        }

        /** De la más reciente a la más antigua. */
        public List<EventoHistorial> getEventos() {
            return eventos;
        }

        /** true si había más eventos que el tope y se muestran sólo los más recientes. */
        public boolean isTruncado() {
            return truncado;
        }

        public int getTotal() {
            return eventos.size();
        }
    }

    /** Un renglón de la línea de tiempo: una alerta o una incidencia. */
    public static final class EventoHistorial implements Serializable {

        private static final long serialVersionUID = 1L;

        private final Date fecha;
        private final String tipo;       // "Alerta" o "Incidencia"
        private final String titulo;
        private final String detalle;
        private final String estado;     // ya con formato: "Activa", "En proceso"...
        private final String nivel;      // incidencia, critica, advertencia o info (color)

        EventoHistorial(Date fecha, String tipo, String titulo, String detalle, String estado, String nivel) {
            this.fecha = fecha;
            this.tipo = tipo;
            this.titulo = titulo;
            this.detalle = detalle;
            this.estado = estado;
            this.nivel = nivel;
        }

        public Date getFecha() {
            return fecha;
        }

        public String getTipo() {
            return tipo;
        }

        public String getTitulo() {
            return titulo;
        }

        public String getDetalle() {
            return detalle;
        }

        public String getEstado() {
            return estado;
        }

        public String getNivel() {
            return nivel;
        }
    }

    private static String recortar(String texto) {
        return texto.length() <= MAX_DESCRIPCION ? texto : texto.substring(0, MAX_DESCRIPCION - 1) + "…";
    }
}
