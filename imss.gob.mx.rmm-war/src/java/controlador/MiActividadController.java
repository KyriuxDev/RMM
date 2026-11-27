package controlador;

import excepciones.Excepciones;
import jakarta.annotation.PostConstruct;
import jakarta.ejb.EJB;
import jakarta.faces.view.ViewScoped;
import jakarta.inject.Inject;
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
import modelo.Area;
import modelo.Incidencia;

/**
 * Controlador de Incidencias → Mi actividad (HU-14).
 *
 *   - Lista las incidencias pendientes (Abierta o En proceso) asignadas al usuario
 *     en sesión, de la más prioritaria a la menos.
 *   - "Iniciar atención" (Abierta → En proceso) y "Marcar resuelta" (En proceso →
 *     Resuelta) llaman a IncidenciasBean, que sólo deja mover las incidencias del
 *     propio usuario.
 *
 * Mismo patrón que IncidenciasController e HistorialEquipoController.
 *
 * @author Sesma
 */
@Named("miActividadCtrl")
@ViewScoped
public class MiActividadController implements Serializable {

    private static final long serialVersionUID = 1L;

    private static final ZoneId ZONA = ZoneId.of("America/Mexico_City");
    private static final Locale ES = Locale.forLanguageTag("es-MX");
    private static final DateTimeFormatter HORA = DateTimeFormatter.ofPattern("HH:mm", ES);
    private static final DateTimeFormatter DIA = DateTimeFormatter.ofPattern("dd MMM", ES);
    private static final DateTimeFormatter DIA_CON_ANIO = DateTimeFormatter.ofPattern("dd MMM yyyy", ES);

    @EJB
    private IncidenciasBean incidenciasBean;

    @Inject
    private AuthController authCtrl;

    private List<Incidencia> incidencias = Collections.emptyList();

    @PostConstruct
    public void init() {
        cargar();
    }

    /** Vuelve a leer las incidencias pendientes del usuario. */
    public void cargar() {
        try {
            incidencias = incidenciasBean.misPendientes(idUsuario());
        } catch (Excepciones e) {
            incidencias = Collections.emptyList();
            Mensajes.error("No se pudo consultar su actividad", e.getMessage());
        }
    }

    // ------------------------------------------------------------------
    // Acciones
    // ------------------------------------------------------------------

    /** Botón "Iniciar atención". */
    public void iniciar(Incidencia i) {
        try {
            Incidencia r = incidenciasBean.iniciarAtencion(i.getIdIncidencia(), idUsuario());
            Mensajes.info("Atención iniciada",
                    IncidenciasBean.codigo(r) + " · " + r.getIdEquipo().getHostname() + " pasó a En proceso.");
        } catch (Excepciones e) {
            Mensajes.error("No se pudo iniciar la atención", e.getMessage());
        }
        cargar();
    }

    /** Botón "Marcar resuelta". */
    public void resolver(Incidencia i) {
        try {
            Incidencia r = incidenciasBean.marcarResuelta(i.getIdIncidencia(), idUsuario());
            Mensajes.info("Incidencia resuelta",
                    IncidenciasBean.codigo(r) + " · " + r.getIdEquipo().getHostname()
                    + " quedó resuelta y salió de su lista de pendientes.");
        } catch (Excepciones e) {
            Mensajes.error("No se pudo marcar como resuelta", e.getMessage());
        }
        cargar();
    }

    private Integer idUsuario() {
        return authCtrl.getUsuario() == null ? null : authCtrl.getUsuario().getIdUsuario();
    }

    // ------------------------------------------------------------------
    // Datos para la vista
    // ------------------------------------------------------------------

    public List<Incidencia> getIncidencias() {
        return incidencias;
    }

    public boolean isHayIncidencias() {
        return !incidencias.isEmpty();
    }

    /** "5 pendientes": pastilla junto al título de la página. */
    public String getEtiquetaPendientes() {
        int n = incidencias.size();
        return n == 0 ? "Sin pendientes" : n + (n == 1 ? " pendiente" : " pendientes");
    }

    public String codigo(Incidencia i) {
        return IncidenciasBean.codigo(i);
    }

    /** "Critica" se muestra como "Crítica". */
    public String etiquetaPrioridad(Incidencia i) {
        return "CRITICA".equalsIgnoreCase(i.getPrioridad()) ? "Crítica" : i.getPrioridad();
    }

    /** Alta (y Crítica) en rojo, Media en ámbar, Baja en gris. */
    public String clasePrioridad(Incidencia i) {
        String p = i.getPrioridad() == null ? "" : i.getPrioridad().toUpperCase(Locale.ROOT);
        if (p.startsWith("ALTA") || p.startsWith("CRIT")) {
            return "act-prio-alta";
        }
        return p.startsWith("MEDIA") ? "act-prio-media" : "act-prio-baja";
    }

    /** "EnProceso" se muestra como "En proceso". */
    public String etiquetaEstado(Incidencia i) {
        return esEnProceso(i) ? "En proceso" : i.getEstado();
    }

    /** Abierta en azul, En proceso en ámbar. */
    public String claseEstado(Incidencia i) {
        return esEnProceso(i) ? "act-est-proceso" : "act-est-abierta";
    }

    public boolean puedeIniciar(Incidencia i) {
        return i.getEstado() != null && "ABIERTA".equalsIgnoreCase(i.getEstado().trim());
    }

    public boolean puedeResolver(Incidencia i) {
        return esEnProceso(i);
    }

    /** "HGZ 1 OAXACA": unidad donde está el equipo. */
    public String unidad(Incidencia i) {
        Area a = i.getIdEquipo() == null ? null : i.getIdEquipo().getIdArea();
        return a == null || a.getIdUnidadHomologada() == null
                ? "Sin área asignada" : a.getIdUnidadHomologada().getNombre();
    }

    /** "Hoy 11:46", "Ayer 16:20" o "05 nov" (con el año si no es el actual). */
    public String fecha(Incidencia i) {
        if (i.getFechaRegistro() == null) {
            return "—";
        }
        ZonedDateTime z = i.getFechaRegistro().toInstant().atZone(ZONA);
        LocalDate hoy = LocalDate.now(ZONA);
        LocalDate dia = z.toLocalDate();
        if (dia.equals(hoy)) {
            return "Hoy " + HORA.format(z);
        }
        if (dia.equals(hoy.minusDays(1))) {
            return "Ayer " + HORA.format(z);
        }
        return (dia.getYear() == hoy.getYear() ? DIA : DIA_CON_ANIO).format(z).replace(".", "");
    }

    private static boolean esEnProceso(Incidencia i) {
        return i.getEstado() != null
                && i.getEstado().replace(" ", "").replace("_", "").equalsIgnoreCase("EnProceso");
    }
}
