package controlador;

import jakarta.annotation.PostConstruct;
import jakarta.ejb.EJB;
import jakarta.faces.view.ViewScoped;
import jakarta.inject.Inject;
import jakarta.inject.Named;
import java.io.Serializable;
import java.time.Duration;
import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Date;
import java.util.List;
import java.util.Locale;
import logica_negocio.TablerosBean;
import logica_negocio.TablerosBean.FilaUnidad;
import logica_negocio.TablerosBean.Resumen;
import modelo.Area;
import modelo.Equipo;

/**
 * Tableros → Vista general (PR-03, SD-04a). Mismo diseño que el inicio de la
 * intranet: saludo, indicadores, equipos por unidad y lo que lleva más tiempo
 * sin señal, más el mapa.
 *
 * @author kyriux
 */
@Named("tableroCtrl")
@ViewScoped
public class TableroController implements Serializable {

    private static final long serialVersionUID = 1L;

    private static final ZoneId ZONA = ZoneId.of("America/Mexico_City");
    private static final Locale ES_MX = Locale.forLanguageTag("es-MX");

    @EJB
    private TablerosBean tablerosBean;

    @Inject
    private AuthController authCtrl;

    private Resumen resumen;
    private List<FilaUnidad> unidades;
    private List<Equipo> sinSenal;

    @PostConstruct
    public void init() {
        actualizar();
    }

    /** SD-04a consultarIndicadores(): también lo llama el botón "Actualizar". */
    public void actualizar() {
        resumen = tablerosBean.resumen();
        unidades = tablerosBean.equiposPorUnidad();
        sinSenal = tablerosBean.sinSenal(8);
    }

    /** "Buenos días, Tania" según la hora. */
    public String getSaludo() {
        int h = ZonedDateTime.now(ZONA).getHour();
        String s = h < 12 ? "Buenos días" : h < 19 ? "Buenas tardes" : "Buenas noches";
        String nombre = authCtrl.getUsuario() == null ? null : authCtrl.getUsuario().getNombre();
        return nombre == null ? s : s + ", " + nombre.trim().split("\\s+")[0];
    }

    /** "jueves 19 de noviembre de 2026" */
    public String getHoy() {
        return ZonedDateTime.now(ZONA).format(DateTimeFormatter.ofPattern("EEEE d 'de' MMMM 'de' y", ES_MX));
    }

    /** Cuánto lleva sin señal: "hace 3 h", "hace 2 d" o "nunca ha reportado". */
    public String haceCuanto(Date fecha) {
        if (fecha == null) {
            return "Nunca ha reportado";
        }
        long min = Math.max(0, Duration.between(fecha.toInstant(), ZonedDateTime.now(ZONA).toInstant()).toMinutes());
        if (min < 60) {
            return "Hace " + min + " min";
        }
        if (min < 60 * 24) {
            return "Hace " + (min / 60) + " h";
        }
        return "Hace " + (min / (60 * 24)) + " d";
    }

    public String unidad(Equipo e) {
        Area a = e.getIdArea();
        return a == null || a.getIdUnidadHomologada() == null ? "Sin área asignada" : a.getIdUnidadHomologada().getNombre();
    }

    /** Clase del color de la barra de disponibilidad. */
    public String claseDisponibilidad(long porcentaje) {
        return porcentaje >= 90 ? "buena" : porcentaje >= 70 ? "regular" : "mala";
    }

    public Resumen getResumen() {
        return resumen;
    }

    public List<FilaUnidad> getUnidades() {
        return unidades;
    }

    public List<Equipo> getSinSenal() {
        return sinSenal;
    }
}
