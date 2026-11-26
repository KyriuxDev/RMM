package controlador;

import jakarta.ejb.EJB;
import jakarta.faces.application.FacesMessage;
import jakarta.faces.context.FacesContext;
import jakarta.faces.view.ViewScoped;
import jakarta.inject.Named;
import java.io.Serializable;
import java.time.Duration;
import java.time.Instant;
import java.util.Collections;
import java.util.Date;
import java.util.List;
import java.util.Locale;
import logica_negocio.DetalleEquipoBean;
import logica_negocio.DetalleEquipoBean.Evento;
import logica_negocio.MonitoreoBean;
import logica_negocio.MonitoreoBean.FilaMonitoreo;
import modelo.Alerta;
import modelo.Area;
import modelo.Equipo;
import modelo.Hardware;
import modelo.Periferico;
import modelo.Software;

/**
 * Inventario → Ficha del equipo (HU-10, Figura 13): detalle-equipo.xhtml?id=N
 *
 * Datos del equipo, consumo de recursos en tiempo real (última captura),
 * alertas activas, historial de eventos e incidencias, y pestañas de
 * hardware, software y periféricos. Lo "en vivo" se refresca solo cada 60 s;
 * el historial se refresca con su botón.
 *
 * Mismo patrón que RendimientoEquipoController.
 *
 * @author kyriux
 */
@Named("detalleCtrl")
@ViewScoped
public class DetalleEquipoController implements Serializable {

    private static final long serialVersionUID = 1L;

    static final String LISTA = "/vista/inventario/equipos.xhtml?faces-redirect=true";

    @EJB
    private MonitoreoBean monitoreoBean;

    @EJB
    private DetalleEquipoBean detalleBean;

    /** f:viewParam id */
    private Integer id;

    private Equipo equipo;
    private FilaMonitoreo ultimo;
    private List<Alerta> alertas = Collections.emptyList();
    private List<Software> software = Collections.emptyList();
    private List<Periferico> perifericos = Collections.emptyList();
    private List<Evento> historial = Collections.emptyList();
    private Date actualizado;

    /** f:viewAction */
    public String cargar() {
        equipo = monitoreoBean.buscarEquipo(id);
        if (equipo == null) {
            FacesContext.getCurrentInstance().getExternalContext().getFlash().setKeepMessages(true);
            FacesContext.getCurrentInstance().addMessage(null, new FacesMessage(
                    FacesMessage.SEVERITY_ERROR, "No se encontró el equipo", "Elija un equipo de la lista."));
            return LISTA;
        }
        actualizar();
        software = detalleBean.software(equipo);
        perifericos = detalleBean.perifericos(equipo);
        actualizarHistorial();
        return null;
    }

    /** Parte "en vivo": estado, última captura y alertas activas (p:poll). */
    public void actualizar() {
        if (equipo == null) {
            return;
        }
        equipo = monitoreoBean.buscarEquipo(equipo.getIdEquipo());
        ultimo = monitoreoBean.ultimo(equipo);
        alertas = monitoreoBean.alertasActivas(equipo.getIdEquipo());
        actualizado = new Date();
    }

    /** Botón "Actualizar" del historial. */
    public void actualizarHistorial() {
        if (equipo != null) {
            historial = detalleBean.historial(equipo.getIdEquipo(), software);
        }
    }

    // ------------------------------------------------------------------
    // Datos de la ficha
    // ------------------------------------------------------------------

    public String getUnidad() {
        Area a = equipo == null ? null : equipo.getIdArea();
        return a == null || a.getIdUnidadHomologada() == null ? "Sin área asignada" : a.getIdUnidadHomologada().getNombre();
    }

    /** "HGZ No. 1 Oaxaca (Laboratorio)": unidad y ubicación física. */
    public String getUbicacion() {
        String fisica = equipo == null ? null : equipo.getUbicacionFisica();
        return fisica == null || fisica.isBlank() ? getUnidad() : getUnidad() + " (" + fisica + ")";
    }

    public String getClaveArea() {
        Area a = equipo == null ? null : equipo.getIdArea();
        String c = a == null ? null : a.getClave();
        return c == null || c.isBlank() ? "—" : c;
    }

    public String getResponsable() {
        return equipo == null || equipo.getIdUsuario() == null ? "Sin responsable" : equipo.getIdUsuario().getNombre();
    }

    public String getSistema() {
        if (equipo == null || equipo.getNombreSo() == null) {
            return "—";
        }
        return equipo.getVersionSo() == null ? equipo.getNombreSo() : equipo.getNombreSo() + " " + equipo.getVersionSo();
    }

    public boolean isConHardware() {
        return equipo != null && equipo.getHardware() != null;
    }

    public String getEtiquetaCpu() {
        Hardware h = equipo == null ? null : equipo.getHardware();
        return h == null || h.getModeloCpu() == null ? "CPU" : "CPU (" + h.getModeloCpu() + ")";
    }

    public String getEtiquetaRam() {
        Hardware h = equipo == null ? null : equipo.getHardware();
        return h == null || h.getTotalRamGb() == null ? "Memoria RAM" : "Memoria RAM (" + gb(h.getTotalRamGb()) + ")";
    }

    public String getEtiquetaDisco() {
        String p = ultimo == null ? null : ultimo.getParticionMasLlena();
        return p == null ? "Disco" : "Disco (" + p + ")";
    }

    // ------------------------------------------------------------------
    // Formato (mismo criterio que RendimientoEquipoController)
    // ------------------------------------------------------------------

    public String getClaseEstado() {
        String s = equipo == null ? null : equipo.getEstadoConexion();
        return "ONLINE".equals(s) ? "estado-activo" : "ALERTA".equals(s) ? "estado-alerta"
                : "INACTIVO".equals(s) ? "estado-inactivo" : "";
    }

    public String getEstado() {
        String s = equipo == null ? null : equipo.getEstadoConexion();
        return "ONLINE".equals(s) || "ALERTA".equals(s) || "INACTIVO".equals(s) ? s : "OFFLINE";
    }

    public String claseUso(Double pct) {
        return pct == null ? "" : pct >= 90 ? "alto" : pct >= 70 ? "medio" : "normal";
    }

    public long ancho(Double pct) {
        return pct == null ? 0 : Math.round(Math.max(0, Math.min(100, pct)));
    }

    public String porcentaje(Double pct) {
        return pct == null ? "—" : String.format(Locale.ROOT, "%.1f %%", pct);
    }

    public String gb(Double v) {
        return v == null ? "—" : String.format(Locale.ROOT, "%.1f GB", v);
    }

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

    /** Clase CSS de la tarjeta de alerta: crítica en rojo, el resto en ámbar. */
    public String claseAlerta(Alerta a) {
        String n = a.getNivelGravedad();
        return n != null && n.toLowerCase(Locale.ROOT).startsWith("cr") ? "det-alerta-critica" : "det-alerta-media";
    }

    /** Color del estado de un renglón del historial. */
    public String claseEvento(Evento e) {
        String s = e.getEstado() == null ? "" : e.getEstado().toUpperCase(Locale.ROOT);
        if (s.startsWith("RESUELT") || s.startsWith("CERRAD") || s.startsWith("COMPLET") || s.startsWith("ATENDID")) {
            return "estado-activo";
        }
        if (s.startsWith("ACTIV") || s.startsWith("ABIERT")) {
            return "estado-inactivo";
        }
        return "estado-alerta";
    }

    public String estadoSoftware(Software s) {
        if (s.getAutorizado() != null && !s.getAutorizado()) {
            return "No autorizado";
        }
        if (s.getActualizado() != null && !s.getActualizado()) {
            return "Desactualizado";
        }
        return "";
    }

    public String claseSoftware(Software s) {
        return s.getAutorizado() != null && !s.getAutorizado() ? "estado-inactivo" : "estado-alerta";
    }

    // Getters y setters

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public Equipo getEquipo() {
        return equipo;
    }

    public FilaMonitoreo getUltimo() {
        return ultimo;
    }

    public List<Alerta> getAlertas() {
        return alertas;
    }

    public List<Software> getSoftware() {
        return software;
    }

    public List<Periferico> getPerifericos() {
        return perifericos;
    }

    public List<Evento> getHistorial() {
        return historial;
    }

    public Date getActualizado() {
        return actualizado;
    }
}
