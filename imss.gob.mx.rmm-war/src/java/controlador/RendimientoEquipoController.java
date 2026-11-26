package controlador;

import jakarta.ejb.EJB;
import jakarta.faces.context.FacesContext;
import jakarta.faces.view.ViewScoped;
import jakarta.inject.Named;
import jakarta.json.Json;
import jakarta.json.JsonArrayBuilder;
import jakarta.json.JsonObjectBuilder;
import java.io.Serializable;
import java.text.SimpleDateFormat;
import java.time.Duration;
import java.time.Instant;
import java.util.Date;
import java.util.List;
import java.util.Locale;
import java.util.TimeZone;
import logica_negocio.MonitoreoBean;
import logica_negocio.MonitoreoBean.FilaMonitoreo;
import logica_negocio.MonitoreoBean.Historial;
import logica_negocio.MonitoreoBean.Rango;
import modelo.Alerta;
import modelo.Almacenamiento;
import modelo.Area;
import modelo.Equipo;
import modelo.SesionMonitoreo;

/**
 * Monitoreo → rendimiento de un equipo (monitoreo/equipo.xhtml?id=N).
 *
 * Estado actual, última captura, gráficas de CPU / RAM, disco y red del periodo
 * elegido (1 h, 6 h, 24 h, 7 días), particiones, alertas activas y últimas
 * sesiones de monitoreo. Las gráficas son Chart.js (p:chart con JSON).
 *
 * @author kyriux
 */
@Named("rendimientoCtrl")
@ViewScoped
public class RendimientoEquipoController implements Serializable {

    private static final long serialVersionUID = 1L;

    static final String LISTA = "/vista/monitoreo/estado-rendimiento.xhtml?faces-redirect=true";

    private static final TimeZone ZONA = TimeZone.getTimeZone("America/Mexico_City");

    // Colores de las gráficas (los del RMM)
    private static final String AZUL = "#0074B7";
    private static final String VERDE = "#2E9E5B";
    private static final String AMBAR = "#D38B00";
    private static final String MORADO = "#6A4C93";

    @EJB
    private MonitoreoBean monitoreoBean;

    /** f:viewParam id */
    private Integer id;
    private String rango = Rango.HORA.name();

    private Equipo equipo;
    private FilaMonitoreo ultimo;
    private Historial historial;
    private List<SesionMonitoreo> sesiones;
    private List<Alerta> alertas;
    private double disponibilidad;
    private Date actualizado;

    /** f:viewAction */
    public String cargar() {
        equipo = monitoreoBean.buscarEquipo(id);
        if (equipo == null) {
            FacesContext.getCurrentInstance().getExternalContext().getFlash().setKeepMessages(true);
            Mensajes.error("No se encontró el equipo", "Elija un equipo de la lista.");
            return LISTA;
        }
        actualizar();
        return null;
    }

    /** Recarga todo (botón Actualizar, cambio de periodo y p:poll). */
    public void actualizar() {
        if (equipo == null) {
            return;
        }
        equipo = monitoreoBean.buscarEquipo(equipo.getIdEquipo());   // estado y última señal al día
        ultimo = monitoreoBean.ultimo(equipo);
        Rango r = getRangoElegido();
        historial = monitoreoBean.historial(equipo, r);
        disponibilidad = monitoreoBean.disponibilidad(equipo.getIdEquipo(), r);
        sesiones = monitoreoBean.sesiones(equipo.getIdEquipo(), 10);
        alertas = monitoreoBean.alertasActivas(equipo.getIdEquipo());
        actualizado = new Date();
    }

    public Rango getRangoElegido() {
        try {
            return Rango.valueOf(rango);
        } catch (RuntimeException e) {
            return Rango.HORA;
        }
    }

    public Rango[] getRangos() {
        return Rango.values();
    }

    // ------------------------------------------------------------------
    // Gráficas (configuración de Chart.js en JSON para p:chart)
    // ------------------------------------------------------------------

    /** CPU y RAM (%) en la misma gráfica. */
    public String getGraficaCpuRam() {
        return grafica(true, 100, "%",
                serie("CPU %", historial.getCpu(), AZUL, true),
                serie("RAM %", historial.getRam(), VERDE, false));
    }

    /** % de uso de la partición más llena. */
    public String getGraficaDisco() {
        return grafica(true, 100, "%", serie("Disco %", historial.getDisco(), AMBAR, true));
    }

    /** Tráfico de red en Mb/s. */
    public String getGraficaRed() {
        return grafica(false, null, "Mb/s",
                serie("Recibido", historial.getRedRx(), AZUL, true),
                serie("Enviado", historial.getRedTx(), MORADO, false));
    }

    private String grafica(boolean desdeCero, Integer maximo, String unidad, JsonObjectBuilder... series) {
        SimpleDateFormat f = new SimpleDateFormat(getRangoElegido().getFormato(), Locale.ROOT);
        f.setTimeZone(ZONA);
        JsonArrayBuilder etiquetas = Json.createArrayBuilder();
        for (Date d : historial.getFechas()) {
            etiquetas.add(f.format(d));
        }
        JsonArrayBuilder datasets = Json.createArrayBuilder();
        for (JsonObjectBuilder s : series) {
            datasets.add(s);
        }

        JsonObjectBuilder ejeY = Json.createObjectBuilder()
                .add("beginAtZero", desdeCero)
                .add("title", Json.createObjectBuilder().add("display", true).add("text", unidad))
                .add("ticks", Json.createObjectBuilder().add("font", Json.createObjectBuilder().add("size", 11)))
                .add("grid", Json.createObjectBuilder().add("color", "#EBEEF0"));
        if (maximo != null) {
            ejeY.add("min", 0).add("max", maximo);
        }
        JsonObjectBuilder ejeX = Json.createObjectBuilder()
                .add("ticks", Json.createObjectBuilder()
                        .add("autoSkip", true).add("maxTicksLimit", 8).add("maxRotation", 0)
                        .add("font", Json.createObjectBuilder().add("size", 11)))
                .add("grid", Json.createObjectBuilder().add("display", false));

        return Json.createObjectBuilder()
                .add("type", "line")
                .add("data", Json.createObjectBuilder().add("labels", etiquetas).add("datasets", datasets))
                .add("options", Json.createObjectBuilder()
                        .add("animation", false)
                        .add("responsive", true)
                        .add("maintainAspectRatio", false)
                        .add("interaction", Json.createObjectBuilder().add("mode", "index").add("intersect", false))
                        .add("scales", Json.createObjectBuilder().add("x", ejeX).add("y", ejeY))
                        .add("plugins", Json.createObjectBuilder()
                                .add("legend", Json.createObjectBuilder().add("position", "bottom")
                                        .add("labels", Json.createObjectBuilder().add("boxWidth", 12)
                                                .add("font", Json.createObjectBuilder().add("size", 11))))))
                .build().toString();
    }

    /** Una serie: los null quedan como huecos (sin datos = sin conexión). */
    private static JsonObjectBuilder serie(String nombre, List<Double> valores, String color, boolean relleno) {
        JsonArrayBuilder datos = Json.createArrayBuilder();
        for (Double v : valores) {
            if (v == null) {
                datos.addNull();
            } else {
                datos.add(v);
            }
        }
        return Json.createObjectBuilder()
                .add("label", nombre)
                .add("data", datos)
                .add("borderColor", color)
                .add("backgroundColor", color + "22")
                .add("fill", relleno)
                .add("borderWidth", 1.5)
                .add("pointRadius", 0)
                .add("pointHitRadius", 6)
                .add("tension", 0.2)
                .add("spanGaps", false);
    }

    // ------------------------------------------------------------------
    // Formato
    // ------------------------------------------------------------------

    public String getUnidad() {
        Area a = equipo == null ? null : equipo.getIdArea();
        return a == null || a.getIdUnidadHomologada() == null ? "Sin área asignada" : a.getIdUnidadHomologada().getNombre();
    }

    public String getClaseEstado() {
        String s = equipo == null ? null : equipo.getEstadoConexion();
        return "ONLINE".equals(s) ? "estado-activo" : "ALERTA".equals(s) ? "estado-alerta" : "";
    }

    public String getEstado() {
        String s = equipo == null ? null : equipo.getEstadoConexion();
        return "ONLINE".equals(s) || "ALERTA".equals(s) ? s : "OFFLINE";
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

    public double usoParticion(Almacenamiento a) {
        return MonitoreoBean.porcentajeUso(a);
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

    /** Duración de una sesión: "2 h 15 min" (abierta = hasta ahora). */
    public String duracion(SesionMonitoreo s) {
        if (s.getInicioSesion() == null) {
            return "—";
        }
        Date fin = s.getFinSesion() == null ? new Date() : s.getFinSesion();
        long min = Math.max(0, (fin.getTime() - s.getInicioSesion().getTime()) / 60000);
        if (min < 60) {
            return min + " min";
        }
        if (min < 1440) {
            return (min / 60) + " h " + (min % 60) + " min";
        }
        return (min / 1440) + " d " + ((min % 1440) / 60) + " h";
    }

    public String claseGravedad(Alerta a) {
        return "Critica".equalsIgnoreCase(a.getNivelGravedad()) ? "estado-inactivo" : "estado-alerta";
    }

    // Getters y setters

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public String getRango() {
        return rango;
    }

    public void setRango(String rango) {
        this.rango = rango;
    }

    public Equipo getEquipo() {
        return equipo;
    }

    public FilaMonitoreo getUltimo() {
        return ultimo;
    }

    public Historial getHistorial() {
        return historial;
    }

    public List<SesionMonitoreo> getSesiones() {
        return sesiones;
    }

    public List<Alerta> getAlertas() {
        return alertas;
    }

    public double getDisponibilidad() {
        return disponibilidad;
    }

    public Date getActualizado() {
        return actualizado;
    }
}
