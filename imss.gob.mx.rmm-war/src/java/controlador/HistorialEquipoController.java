package controlador;

import excepciones.Excepciones;
import jakarta.ejb.EJB;
import jakarta.faces.application.FacesMessage;
import jakarta.faces.context.FacesContext;
import jakarta.faces.view.ViewScoped;
import jakarta.inject.Named;
import java.io.Serializable;
import java.time.LocalDate;
import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Collections;
import java.util.List;
import java.util.Locale;
import logica_negocio.IncidenciasBean;
import logica_negocio.IncidenciasBean.EventoHistorial;
import logica_negocio.IncidenciasBean.Historial;
import modelo.Area;
import modelo.Equipo;

/**
 * Controlador de Incidencias → Historial por equipo (HU-6).
 *
 *   - Línea de tiempo con las alertas y las incidencias de un equipo juntas.
 *   - Filtros: equipo, tipo de evento (todos / alertas / incidencias) y rango de fechas.
 *   - Se puede abrir desde otra pantalla con ?id=N (id del equipo), por ejemplo
 *     /vista/incidencias/historial-equipo.xhtml?id=11
 *
 * Mismo patrón que IncidenciasController y DetalleEquipoController.
 *
 * @author Sesma
 */
@Named("historialCtrl")
@ViewScoped
public class HistorialEquipoController implements Serializable {

    private static final long serialVersionUID = 1L;

    private static final ZoneId ZONA = ZoneId.of("America/Mexico_City");
    private static final Locale ES = Locale.forLanguageTag("es-MX");
    private static final DateTimeFormatter FORMATO = DateTimeFormatter.ofPattern("dd MMM HH:mm", ES);
    private static final DateTimeFormatter FORMATO_CON_ANIO = DateTimeFormatter.ofPattern("dd MMM yyyy HH:mm", ES);

    @EJB
    private IncidenciasBean incidenciasBean;

    /** f:viewParam id (opcional): equipo que se abre ya consultado. */
    private Integer id;

    // Filtros
    private String hostname;
    private String tipo = IncidenciasBean.TIPO_TODOS;
    private LocalDate desde;
    private LocalDate hasta;

    // Resultado
    private Historial historial;
    private boolean conPeriodo;

    /** f:viewAction: si llegó ?id=N, deja el equipo escrito y consulta. */
    public String cargar() {
        if (id == null) {
            return null;
        }
        Equipo e = incidenciasBean.buscarEquipo(id);
        if (e == null) {
            FacesContext.getCurrentInstance().addMessage(null, new FacesMessage(
                    FacesMessage.SEVERITY_ERROR, "No se encontró el equipo", "Escriba el hostname del equipo a consultar."));
            return null;
        }
        hostname = e.getHostname();
        consultar();
        return null;
    }

    /** Botón "Consultar". */
    public void consultar() {
        try {
            historial = incidenciasBean.historialPorEquipo(hostname, tipo, desde, hasta);
            conPeriodo = desde != null || hasta != null;
        } catch (Excepciones e) {
            historial = null;
            Mensajes.error("formHistorial", e, "No se pudo consultar el historial");
        }
    }

    /** Sugerencias del campo "Equipo consultado" (hostname, IP, MAC o unidad; incluye equipos dados de baja). */
    public List<String> completarEquipo(String consulta) {
        return incidenciasBean.sugerirEquipos(consulta);
    }

    // ------------------------------------------------------------------
    // Datos para la vista
    // ------------------------------------------------------------------

    public boolean isHayResultado() {
        return historial != null;
    }

    public List<EventoHistorial> getEventos() {
        return historial == null ? Collections.emptyList() : historial.getEventos();
    }

    public int getTotalEventos() {
        return historial == null ? 0 : historial.getTotal();
    }

    /** "9 eventos registrados en el periodo". */
    public String getResumen() {
        int n = getTotalEventos();
        String periodo = conPeriodo ? " en el periodo" : "";
        if (historial != null && historial.isTruncado()) {
            return "Se muestran los " + n + " eventos más recientes" + periodo;
        }
        if (n == 0) {
            return "Sin eventos registrados" + periodo;
        }
        return n + (n == 1 ? " evento registrado" : " eventos registrados") + periodo;
    }

    /** "Admisión hospitalaria, HGZ No. 2 Salina Cruz": ubicación física y unidad. */
    public String getDescripcionEquipo() {
        Equipo e = historial == null ? null : historial.getEquipo();
        if (e == null) {
            return "";
        }
        Area a = e.getIdArea();
        String unidad = a == null || a.getIdUnidadHomologada() == null
                ? "Sin área asignada" : a.getIdUnidadHomologada().getNombre();
        String fisica = e.getUbicacionFisica();
        return fisica == null || fisica.isBlank() ? unidad : fisica + ", " + unidad;
    }

    /** "08 nov 10:02" (con el año si no es el actual). */
    public String fecha(EventoHistorial ev) {
        if (ev == null || ev.getFecha() == null) {
            return "—";
        }
        ZonedDateTime z = ev.getFecha().toInstant().atZone(ZONA);
        boolean esteAnio = z.getYear() == ZonedDateTime.now(ZONA).getYear();
        return (esteAnio ? FORMATO : FORMATO_CON_ANIO).format(z).replace(".", "");
    }

    /** incidencia, critica, advertencia o info: sufijo de las clases "punto-" y "tipo-". */
    public String claseNivel(EventoHistorial ev) {
        return ev.getNivel() == null ? "info" : ev.getNivel();
    }

    /** Verde si ya se atendió, rojo si sigue sin atender, ámbar si está en proceso. */
    public String claseEstado(EventoHistorial ev) {
        String s = ev.getEstado() == null ? "" : ev.getEstado().toUpperCase(Locale.ROOT);
        if (s.startsWith("RESUELT") || s.startsWith("CERRAD") || s.startsWith("ATENDID")) {
            return "estado-activo";
        }
        if (s.startsWith("ACTIV") || s.startsWith("ABIERT")) {
            return "estado-inactivo";
        }
        return "estado-alerta";
    }

    // Getters y setters

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public String getHostname() {
        return hostname;
    }

    public void setHostname(String hostname) {
        this.hostname = hostname;
    }

    public String getTipo() {
        return tipo;
    }

    public void setTipo(String tipo) {
        this.tipo = tipo == null || tipo.isBlank() ? IncidenciasBean.TIPO_TODOS : tipo;
    }

    public LocalDate getDesde() {
        return desde;
    }

    public void setDesde(LocalDate desde) {
        this.desde = desde;
    }

    public LocalDate getHasta() {
        return hasta;
    }

    public void setHasta(LocalDate hasta) {
        this.hasta = hasta;
    }

    public Historial getHistorial() {
        return historial;
    }
}
