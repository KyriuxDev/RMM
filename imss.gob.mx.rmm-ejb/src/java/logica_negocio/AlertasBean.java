package logica_negocio;

import acceso_datos.GestionAlertasFacade;
import excepciones.Excepciones;
import jakarta.ejb.EJB;
import jakarta.ejb.LocalBean;
import jakarta.ejb.Stateless;
import java.io.Serializable;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import modelo.Alerta;
import modelo.Area;
import modelo.Equipo;
import modelo.Notificacion;

/**
 * Lógica de Alertas → Alertas activas (HU-5).
 *
 * Lista las alertas en estado "Activa" (ordenadas por severidad o por fecha,
 * con filtro por tipo) junto con el estado de su correo (HU-15), y permite
 * atenderlas. "Escalar" está en NotificacionBean (manda correo a la jefatura).
 *
 * @author jose
 */
@Stateless
@LocalBean
public class AlertasBean {

    public static final String ESTADO_ATENDIDA = "Atendida";

    public static final String ORDEN_SEVERIDAD = "SEVERIDAD";
    public static final String ORDEN_FECHA = "FECHA";

    @EJB
    private GestionAlertasFacade facade;

    /**
     * @param tipo  null o vacío = todos; UsoAnomalo, Desconexion o RiesgoSeguridad
     * @param orden SEVERIDAD (crítica primero, luego la más reciente) o FECHA
     */
    public List<FilaAlerta> activas(String tipo, String orden) {
        String t = Validacion.limpiar(tipo);
        List<Alerta> alertas = new ArrayList<>(facade.activas(t));

        Comparator<Alerta> porFecha = Comparator.comparing(Alerta::getFechaGeneracion,
                Comparator.nullsLast(Comparator.<Date>reverseOrder()));
        if (ORDEN_FECHA.equals(orden)) {
            alertas.sort(porFecha);
        } else {
            alertas.sort(Comparator.comparingInt((Alerta a) -> rangoGravedad(a.getNivelGravedad()))
                    .thenComparing(porFecha));
        }

        // Estado del correo de cada alerta (Enviado, Reintentando, Fallido, o sin correo)
        List<Integer> ids = new ArrayList<>();
        for (Alerta a : alertas) {
            ids.add(a.getIdAlerta());
        }
        Map<Integer, List<String>> estados = new HashMap<>();
        for (Notificacion n : facade.notificacionesDe(ids)) {
            estados.computeIfAbsent(n.getIdAlerta().getIdAlerta(), k -> new ArrayList<>()).add(n.getEstadoEnvio());
        }

        List<FilaAlerta> r = new ArrayList<>(alertas.size());
        for (Alerta a : alertas) {
            List<String> e = estados.get(a.getIdAlerta());
            r.add(new FilaAlerta(a, e == null ? null : NotificacionBean.resumen(e)));
        }
        return r;
    }

    /** "Atender": la alerta pasa de Activa a Atendida y sale de la lista. */
    public void atender(Integer idAlerta) {
        Alerta a = facade.alertaConEquipo(idAlerta);
        if (a == null) {
            throw new Excepciones("alerta.noExiste", "La alerta ya no existe.");
        }
        if (!IngestaBean.ESTADO_ALERTA_ACTIVA.equalsIgnoreCase(a.getEstado())) {
            throw new Excepciones("alerta.estado", "La alerta ya no está activa (quizá otra persona la atendió).");
        }
        a.setEstado(ESTADO_ATENDIDA);   // la entidad está administrada: se guarda al terminar el método
    }

    /** Crítica primero. */
    static int rangoGravedad(String nivel) {
        if (IngestaBean.GRAVEDAD_CRITICA.equalsIgnoreCase(nivel)) {
            return 0;
        }
        if (IngestaBean.GRAVEDAD_ADVERTENCIA.equalsIgnoreCase(nivel)) {
            return 1;
        }
        if (IngestaBean.GRAVEDAD_INFORMATIVA.equalsIgnoreCase(nivel)) {
            return 2;
        }
        return 3;
    }

    /** Renglón de la tabla de alertas activas. */
    public static final class FilaAlerta implements Serializable {

        private static final long serialVersionUID = 1L;

        private final Integer idAlerta;
        private final String gravedad;
        private final String tipo;
        private final String descripcion;
        private final Date fecha;
        private final Integer idEquipo;
        private final String hostname;
        private final String unidad;
        /** Resumen del envío de correo (Enviado, Reintentando (2 de 3), Fallido...) o null si no hay. */
        private final String correo;

        FilaAlerta(Alerta a, String correo) {
            Equipo e = a.getIdEquipo();
            Area area = e == null ? null : e.getIdArea();
            this.idAlerta = a.getIdAlerta();
            this.gravedad = a.getNivelGravedad();
            this.tipo = a.getTipoAlerta();
            this.descripcion = a.getDescripcion();
            this.fecha = a.getFechaGeneracion();
            this.idEquipo = e == null ? null : e.getIdEquipo();
            this.hostname = e == null ? "—" : e.getHostname();
            this.unidad = area == null || area.getIdUnidadHomologada() == null
                    ? "Sin área asignada" : area.getIdUnidadHomologada().getNombre();
            this.correo = correo;
        }

        public Integer getIdAlerta() {
            return idAlerta;
        }

        public String getGravedad() {
            return gravedad;
        }

        public String getTipo() {
            return tipo;
        }

        public String getDescripcion() {
            return descripcion;
        }

        public Date getFecha() {
            return fecha;
        }

        public Integer getIdEquipo() {
            return idEquipo;
        }

        public String getHostname() {
            return hostname;
        }

        public String getUnidad() {
            return unidad;
        }

        public String getCorreo() {
            return correo;
        }

        public boolean isCritica() {
            return IngestaBean.GRAVEDAD_CRITICA.equalsIgnoreCase(gravedad);
        }

        /** Texto de la columna "Notificación". */
        public String getTextoCorreo() {
            if (correo == null) {
                return "Sin correo";
            }
            return "Correo " + correo.toLowerCase(Locale.ROOT);
        }
    }
}
