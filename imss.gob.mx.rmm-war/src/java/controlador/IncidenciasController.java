package controlador;

import excepciones.Excepciones;
import jakarta.annotation.PostConstruct;
import jakarta.ejb.EJB;
import jakarta.faces.view.ViewScoped;
import jakarta.inject.Inject;
import jakarta.inject.Named;
import java.io.Serializable;
import java.util.List;
import java.util.Locale;
import logica_negocio.IncidenciasBean;
import modelo.Area;
import modelo.Equipo;
import modelo.Incidencia;
import modelo.Usuario;

/**
 * Controlador de Incidencias → Lista de incidencias (HU-7).
 *
 *   - Lista: incidencias manuales y de alertas juntas, con filtros.
 *   - Diálogo "Registrar incidencia" (HU-7): equipo, descripción, prioridad y
 *     técnico; al guardar se llama a IncidenciasBean.registrarManual().
 *
 * Mismo patrón que EquiposController e InventarioController.
 *
 * @author Sesma
 */
@Named("incidenciasCtrl")
@ViewScoped
public class IncidenciasController implements Serializable {

    private static final long serialVersionUID = 1L;

    private static final String PRIORIDAD_INICIAL = "Media";

    @EJB
    private IncidenciasBean incidenciasBean;

    @Inject
    private AuthController authCtrl;

    // Filtros (se aplican con "Aplicar")
    private String texto;
    private String estado;
    private String prioridad;
    private String origen;

    // Formulario "Registrar incidencia"
    private String hostname;
    private String descripcion;
    private String prioridadNueva;
    private Integer idTecnico;
    private Equipo equipoSeleccionado;

    // Datos de la pantalla
    private List<Incidencia> incidencias;
    private List<Usuario> tecnicos;

    @PostConstruct
    public void init() {
        tecnicos = incidenciasBean.tecnicosAsignables();
        limpiarFormulario();
        consultar();
    }

    // ------------------------------------------------------------------
    // Lista
    // ------------------------------------------------------------------

    public void consultar() {
        incidencias = incidenciasBean.listar(texto, estado, prioridad, origen);
    }

    public void limpiarFiltros() {
        texto = null;
        estado = null;
        prioridad = null;
        origen = null;
        consultar();
    }

    public boolean isHayFiltros() {
        return (texto != null && !texto.isBlank()) || estado != null || prioridad != null || origen != null;
    }

    // ------------------------------------------------------------------
    // Registrar incidencia (HU-7)
    // ------------------------------------------------------------------

    /** Botón "Registrar incidencia": deja el formulario limpio antes de abrir el diálogo. */
    public void nuevaIncidencia() {
        limpiarFormulario();
    }

    /** Sugerencias del campo "Equipo afectado" (hostname, IP, MAC o unidad). */
    public List<String> completarEquipo(String consulta) {
        return incidenciasBean.sugerirHostnames(consulta);
    }

    /** Al elegir o escribir un equipo: se muestra su estado, unidad y responsable debajo del campo. */
    public void seleccionarEquipo() {
        equipoSeleccionado = incidenciasBean.buscarEquipoActivo(hostname);
    }

    /** Botón "Registrar incidencia" del diálogo. */
    public void guardar() {
        try {
            Incidencia i = incidenciasBean.registrarManual(hostname, descripcion, prioridadNueva, idTecnico);
            Mensajes.info("Incidencia registrada",
                    IncidenciasBean.codigo(i) + " · " + i.getIdEquipo().getHostname()
                    + " · asignada a " + i.getIdUsuario().getNombre()
                    + " con prioridad " + i.getPrioridad() + ". Ya aparece en la lista.");
            limpiarFormulario();
            consultar();
        } catch (Excepciones e) {
            Mensajes.error("formDialogo", e, "No se pudo registrar la incidencia");
        }
    }

    private void limpiarFormulario() {
        hostname = null;
        descripcion = null;
        prioridadNueva = PRIORIDAD_INICIAL;
        equipoSeleccionado = null;
        // Por defecto, la incidencia queda asignada a quien la registra
        Integer actual = authCtrl.getUsuario() == null ? null : authCtrl.getUsuario().getIdUsuario();
        idTecnico = null;
        for (Usuario u : tecnicos) {
            if (u.getIdUsuario().equals(actual)) {
                idTecnico = actual;
                break;
            }
        }
    }

    // ------------------------------------------------------------------
    // Formato para la vista
    // ------------------------------------------------------------------

    public String codigo(Incidencia i) {
        return IncidenciasBean.codigo(i);
    }

    /** "Juan López (yo)" para el usuario en sesión. */
    public String etiquetaTecnico(Usuario u) {
        Integer actual = authCtrl.getUsuario() == null ? null : authCtrl.getUsuario().getIdUsuario();
        return u.getNombre() + (u.getIdUsuario().equals(actual) ? " (yo)" : "");
    }

    /** Estado de la incidencia: "EnProceso" se muestra como "En proceso". */
    public String etiquetaEstado(Incidencia i) {
        return "EnProceso".equalsIgnoreCase(i.getEstado()) ? "En proceso" : i.getEstado();
    }

    /** Mismo criterio de color que el historial de la ficha del equipo. */
    public String claseEstado(Incidencia i) {
        String s = i.getEstado() == null ? "" : i.getEstado().toUpperCase(Locale.ROOT);
        if (s.startsWith("RESUELT") || s.startsWith("CERRAD")) {
            return "estado-activo";
        }
        return s.startsWith("ABIERT") ? "estado-inactivo" : "estado-alerta";
    }

    /** Alta (y Critica) en rojo, Media en ámbar, Baja en gris. */
    public String clasePrioridad(Incidencia i) {
        String p = i.getPrioridad() == null ? "" : i.getPrioridad().toUpperCase(Locale.ROOT);
        if (p.startsWith("ALTA") || p.startsWith("CRIT")) {
            return "estado-inactivo";
        }
        return p.startsWith("MEDIA") ? "estado-alerta" : "";
    }

    // Detalle del equipo elegido (debajo del campo)

    public boolean isEquipoElegido() {
        return equipoSeleccionado != null;
    }

    public String getEtiquetaEstadoEquipo() {
        String s = equipoSeleccionado == null ? null : equipoSeleccionado.getEstadoConexion();
        return "ONLINE".equals(s) ? "En línea" : "ALERTA".equals(s) ? "Con alerta" : "Sin conexión";
    }

    public String getClaseEstadoEquipo() {
        String s = equipoSeleccionado == null ? null : equipoSeleccionado.getEstadoConexion();
        return "ONLINE".equals(s) ? "estado-activo" : "ALERTA".equals(s) ? "estado-alerta" : "";
    }

    /** "UMF No. 38 Oaxaca · Consultorio 7". */
    public String getDetalleEquipo() {
        if (equipoSeleccionado == null) {
            return null;
        }
        Area a = equipoSeleccionado.getIdArea();
        String unidad = a == null || a.getIdUnidadHomologada() == null
                ? "Sin área asignada" : a.getIdUnidadHomologada().getNombre();
        String fisica = equipoSeleccionado.getUbicacionFisica();
        return fisica == null || fisica.isBlank() ? unidad : unidad + " · " + fisica;
    }

    public String getResponsableEquipo() {
        return equipoSeleccionado == null || equipoSeleccionado.getIdUsuario() == null
                ? "Sin responsable" : equipoSeleccionado.getIdUsuario().getNombre();
    }

    // Getters y setters

    public String getTexto() {
        return texto;
    }

    public void setTexto(String texto) {
        this.texto = texto;
    }

    public String getEstado() {
        return estado;
    }

    public void setEstado(String estado) {
        this.estado = estado == null || estado.isBlank() ? null : estado;
    }

    public String getPrioridad() {
        return prioridad;
    }

    public void setPrioridad(String prioridad) {
        this.prioridad = prioridad == null || prioridad.isBlank() ? null : prioridad;
    }

    public String getOrigen() {
        return origen;
    }

    public void setOrigen(String origen) {
        this.origen = origen == null || origen.isBlank() ? null : origen;
    }

    public String getHostname() {
        return hostname;
    }

    public void setHostname(String hostname) {
        this.hostname = hostname;
    }

    public String getDescripcion() {
        return descripcion;
    }

    public void setDescripcion(String descripcion) {
        this.descripcion = descripcion;
    }

    public String getPrioridadNueva() {
        return prioridadNueva;
    }

    public void setPrioridadNueva(String prioridadNueva) {
        this.prioridadNueva = prioridadNueva;
    }

    public Integer getIdTecnico() {
        return idTecnico;
    }

    public void setIdTecnico(Integer idTecnico) {
        this.idTecnico = idTecnico;
    }

    public List<Incidencia> getIncidencias() {
        return incidencias;
    }

    public List<Usuario> getTecnicos() {
        return tecnicos;
    }

    public List<String> getEstados() {
        return IncidenciasBean.ESTADOS;
    }

    public List<String> getPrioridades() {
        return IncidenciasBean.PRIORIDADES;
    }

    public List<String> getOrigenes() {
        return IncidenciasBean.ORIGENES;
    }
}
