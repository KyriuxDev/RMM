package controlador;

import jakarta.annotation.PostConstruct;
import jakarta.ejb.EJB;
import jakarta.faces.view.ViewScoped;
import jakarta.inject.Named;
import java.io.Serializable;
import java.time.Duration;
import java.time.Instant;
import java.util.Date;
import java.util.List;
import java.util.Locale;
import java.util.stream.Collectors;
import logica_negocio.CatalogoUnidadesBean;
import logica_negocio.MonitoreoBean;
import logica_negocio.MonitoreoBean.FilaMonitoreo;
import modelo.Area;
import modelo.Equipo;
import modelo.UnidadHomologada;

/**
 * Monitoreo → Estado y rendimiento (HU-2).
 *
 * Lista de equipos activos con su estado y su última captura (CPU, RAM, disco,
 * red, procesos), como "Latest data" de Zabbix. Se actualiza sola cada 30 s
 * (p:poll) y desde cada renglón se abre la gráfica del equipo (equipo.xhtml?id=N).
 *
 * El resumen cuenta los equipos con el texto y la unidad elegidos, pero sin el
 * filtro de estado, igual que Inventario → Equipos.
 *
 * @author kyriux
 */
@Named("monitoreoCtrl")
@ViewScoped
public class MonitoreoController implements Serializable {

    private static final long serialVersionUID = 1L;

    @EJB
    private MonitoreoBean monitoreoBean;

    @EJB
    private CatalogoUnidadesBean catalogoBean;

    // Filtros
    private String texto;
    private String estado;
    private Short idUnidadHomologada;

    private List<UnidadHomologada> hospitales;
    private List<FilaMonitoreo> todos;   // sin filtro de estado (para el resumen)
    private List<FilaMonitoreo> filas;   // lo que muestra la tabla
    private Date actualizado;

    @PostConstruct
    public void init() {
        hospitales = catalogoBean.listarUnidadesHomologadas();
        consultar();
    }

    /** Consulta (también la llama el p:poll cada 30 s). */
    public void consultar() {
        todos = monitoreoBean.estadoEquipos(texto, idUnidadHomologada);
        aplicarEstado();
        actualizado = new Date();
    }

    /** f:viewAction: monitoreo/estado-rendimiento.xhtml?estado=ALERTA o ?unidad=N */
    public void aplicarParametros() {
        if (estado != null || idUnidadHomologada != null) {
            consultar();
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
        consultar();
    }

    private void aplicarEstado() {
        filas = estado == null ? todos
                : todos.stream().filter(f -> estado.equals(estadoDe(f.getEquipo()))).collect(Collectors.toList());
    }

    /** ONLINE, ALERTA u OFFLINE (null o cualquier otro valor cuenta como sin conexión). */
    private static String estadoDe(Equipo e) {
        String s = e.getEstadoConexion();
        return "ONLINE".equals(s) || "ALERTA".equals(s) ? s : "OFFLINE";
    }

    /** Cuántos equipos hay con ese estado ("" = total). */
    public long contar(String est) {
        if (todos == null) {
            return 0;
        }
        if (est == null || est.isBlank()) {
            return todos.size();
        }
        return todos.stream().filter(f -> est.equals(estadoDe(f.getEquipo()))).count();
    }

    public boolean elegido(String est) {
        return (est == null || est.isBlank()) ? estado == null : est.equals(estado);
    }

    // ------------------------------------------------------------------
    // Formato
    // ------------------------------------------------------------------

    public String unidad(Equipo e) {
        Area a = e.getIdArea();
        return a == null || a.getIdUnidadHomologada() == null ? "Sin área asignada" : a.getIdUnidadHomologada().getNombre();
    }

    public String claseEstado(Equipo e) {
        String s = estadoDe(e);
        return "ONLINE".equals(s) ? "estado-activo" : "ALERTA".equals(s) ? "estado-alerta" : "";
    }

    /** Color de la barra de uso: verde < 70 %, ámbar < 90 %, rojo desde 90 %. */
    public String claseUso(Double pct) {
        return pct == null ? "" : pct >= 90 ? "alto" : pct >= 70 ? "medio" : "normal";
    }

    /** Ancho de la barra (0 a 100). */
    public long ancho(Double pct) {
        return pct == null ? 0 : Math.round(Math.max(0, Math.min(100, pct)));
    }

    public String porcentaje(Double pct) {
        return pct == null ? "—" : String.format(Locale.ROOT, "%.1f %%", pct);
    }

    public String mb(Double v) {
        return v == null ? "—" : String.format(Locale.ROOT, "%.2f", v);
    }

    /** "Hace 40 s", "Hace 3 min", "Hace 2 h", "Hace 5 d" o "Nunca". */
    public String haceCuanto(Date fecha) {
        if (fecha == null) {
            return "Nunca";
        }
        long s = Math.max(0, Duration.between(fecha.toInstant(), Instant.now()).getSeconds());
        if (s < 60) {
            return "Hace " + s + " s";
        }
        if (s < 3600) {
            return "Hace " + (s / 60) + " min";
        }
        if (s < 86400) {
            return "Hace " + (s / 3600) + " h";
        }
        return "Hace " + (s / 86400) + " d";
    }

    /** Más de 3 minutos sin datos: el texto se pinta tenue. */
    public boolean atrasado(Date fecha) {
        return fecha == null || Duration.between(fecha.toInstant(), Instant.now()).toMinutes() >= 3;
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

    public List<UnidadHomologada> getHospitales() {
        return hospitales;
    }

    public List<FilaMonitoreo> getFilas() {
        return filas;
    }

    public Date getActualizado() {
        return actualizado;
    }
}
