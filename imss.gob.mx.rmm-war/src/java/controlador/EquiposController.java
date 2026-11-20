package controlador;

import jakarta.annotation.PostConstruct;
import jakarta.ejb.EJB;
import jakarta.faces.view.ViewScoped;
import jakarta.inject.Named;
import java.io.Serializable;
import java.util.List;
import java.util.stream.Collectors;
import logica_negocio.CatalogoUnidadesBean;
import logica_negocio.InventarioBean;
import modelo.Area;
import modelo.Equipo;
import modelo.UnidadHomologada;

/**
 * Controlador de Inventario → Equipos (PR-12 Inventario de equipos, versión
 * básica; SN-05a / SN-05c).
 *
 *   - Tarjetas de resumen (Total, Online, Offline, Alerta, Inactivos): clic = filtrar por estado.
 *   - Filtro (estilo Zabbix): texto (hostname, MAC, IP, hospital o servicio), hospital / sede
 *     y estado; se aplica con "Aplicar" (consultarInventario) y "Restablecer" lo limpia.
 *   - Desde cada renglón se abre la edición, donde también está la baja (SD-05c).
 *
 * El resumen cuenta los equipos con el texto y el hospital elegidos, pero sin el
 * filtro de estado, para que cada tarjeta muestre cuántos hay de ese estado.
 *
 * @author kyriux
 */
@Named("equiposCtrl")
@ViewScoped
public class EquiposController implements Serializable {

    private static final long serialVersionUID = 1L;

    @EJB
    private InventarioBean inventarioBean;

    @EJB
    private CatalogoUnidadesBean catalogoBean;

    // Filtros
    private String texto;
    private String estado;
    private Short idUnidadHomologada;

    // Datos de la pantalla
    private List<UnidadHomologada> hospitales;
    private List<Equipo> todos;      // con texto y hospital, sin filtro de estado (para el resumen)
    private List<Equipo> equipos;    // lo que muestra la tabla

    @PostConstruct
    public void init() {
        hospitales = catalogoBean.listarUnidadesHomologadas();
        consultarInventario();
    }

    /** SN-05a consultarInventario(filtros). */
    public void consultarInventario() {
        todos = inventarioBean.listarEquipos(texto, null, idUnidadHomologada);
        aplicarEstado();
    }

    /**
     * f:viewAction: desde la Vista general se llega con ?estado=ONLINE o ?unidad=N
     * (los f:viewParam ya pusieron el filtro); se vuelve a consultar con él.
     */
    public void aplicarParametros() {
        if (estado != null || idUnidadHomologada != null) {
            consultarInventario();
        }
    }

    /** Clic en una tarjeta del resumen ("" = todos). */
    public void filtrarEstado(String nuevo) {
        estado = nuevo == null || nuevo.isBlank() ? null : nuevo;
        aplicarEstado();
    }

    public void limpiarFiltros() {
        texto = null;
        estado = null;
        idUnidadHomologada = null;
        consultarInventario();
    }

    private void aplicarEstado() {
        equipos = estado == null ? todos
                : todos.stream().filter(e -> estado.equals(e.getEstadoConexion())).collect(Collectors.toList());
    }

    public boolean isHayFiltros() {
        return (texto != null && !texto.isBlank()) || estado != null || idUnidadHomologada != null;
    }

    /** Cuántos equipos hay con ese estado ("" = total). */
    public long contar(String est) {
        if (todos == null) {
            return 0;
        }
        if (est == null || est.isBlank()) {
            return todos.size();
        }
        return todos.stream().filter(e -> est.equals(e.getEstadoConexion())).count();
    }

    /** true si la tarjeta de ese estado es la elegida ("" = Total). */
    public boolean elegido(String est) {
        return (est == null || est.isBlank()) ? estado == null : est.equals(estado);
    }

    public String hospital(Equipo e) {
        Area a = e.getIdArea();
        return a == null || a.getIdUnidadHomologada() == null ? null : a.getIdUnidadHomologada().getNombre();
    }

    public String area(Equipo e) {
        Area a = e.getIdArea();
        if (a == null || a.getIdUnidadCc() == null || a.getIdUnidadCc().getClaveCc() == null) {
            return null;
        }
        return a.getIdUnidadCc().getClaveCc().getDescripcion();
    }

    /** Clase CSS de la pastilla de estado. */
    public String claseEstado(Equipo e) {
        String s = e.getEstadoConexion();
        if ("ONLINE".equals(s)) {
            return "estado-activo";
        }
        if ("ALERTA".equals(s)) {
            return "estado-alerta";
        }
        if (InventarioBean.ESTADO_INACTIVO.equals(s)) {
            return "estado-inactivo";
        }
        return "";
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

    public Short getIdUnidadHomologada() {
        return idUnidadHomologada;
    }

    public void setIdUnidadHomologada(Short idUnidadHomologada) {
        this.idUnidadHomologada = idUnidadHomologada;
    }

    public List<String> getEstados() {
        return InventarioBean.ESTADOS;
    }

    public List<UnidadHomologada> getHospitales() {
        return hospitales;
    }

    public List<Equipo> getEquipos() {
        return equipos;
    }
}
