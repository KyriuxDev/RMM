package logica_negocio;

import acceso_datos.FichaEquipoFacade;
import acceso_datos.IngestaFacade;
import jakarta.ejb.EJB;
import jakarta.ejb.LocalBean;
import jakarta.ejb.Stateless;
import java.io.Serializable;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.Date;
import java.util.List;
import java.util.Locale;
import modelo.Alerta;
import modelo.Equipo;
import modelo.Incidencia;
import modelo.Periferico;
import modelo.Software;

/**
 * Lógica de Inventario → Ficha del equipo (HU-10, Figura 13).
 *
 * Junta lo que la ficha muestra además de lo que ya da MonitoreoBean
 * (equipo, última captura y alertas activas): software, periféricos y el
 * "Historial de eventos e incidencias" (alertas + incidencias + censo de software).
 *
 * @author kyriux
 */
@Stateless
@LocalBean
public class DetalleEquipoBean {

    private static final int MAX_ALERTAS = 10;
    private static final int MAX_INCIDENCIAS = 10;
    private static final int MAX_CENSO = 3;
    private static final int MAX_EVENTOS = 15;

    private static final String SISTEMA = "Sistema RMM";

    @EJB
    private IngestaFacade ingestaFacade;

    @EJB
    private FichaEquipoFacade fichaFacade;

    /** Software instalado, ordenado por nombre. */
    public List<Software> software(Equipo equipo) {
        List<Software> r = new ArrayList<>(ingestaFacade.softwareDe(equipo));
        r.sort(Comparator.comparing((Software s) -> s.getNombre() == null ? "" : s.getNombre(),
                String.CASE_INSENSITIVE_ORDER));
        return r;
    }

    /** Periféricos, ordenados por tipo. */
    public List<Periferico> perifericos(Equipo equipo) {
        List<Periferico> r = new ArrayList<>(ingestaFacade.perifericosDe(equipo));
        r.sort(Comparator.comparing((Periferico p) -> p.getTipo() == null ? "" : p.getTipo(),
                String.CASE_INSENSITIVE_ORDER));
        return r;
    }

    /**
     * Historial reciente, del más nuevo al más viejo:
     * alertas (todas), incidencias y las últimas instalaciones de software ("Censo").
     * Las alertas no guardan quién las atendió, así que su técnico es el sistema.
     */
    public List<Evento> historial(Integer idEquipo, List<Software> software) {
        List<Evento> r = new ArrayList<>();

        for (Alerta a : fichaFacade.alertasDe(idEquipo, MAX_ALERTAS)) {
            String texto = a.getDescripcion() == null || a.getDescripcion().isBlank()
                    ? a.getTipoAlerta() : a.getDescripcion();
            r.add(new Evento(a.getFechaGeneracion(), "Alerta", texto, SISTEMA, etiqueta(a.getEstado())));
        }

        for (Incidencia i : fichaFacade.incidenciasDe(idEquipo, MAX_INCIDENCIAS)) {
            String codigo = String.format(Locale.ROOT, "INC-%04d", i.getIdIncidencia());
            String tecnico = i.getIdUsuario() == null ? "—" : i.getIdUsuario().getNombre();
            r.add(new Evento(i.getFechaRegistro(), "Incidencia", codigo + " · " + i.getDescripcion(),
                    tecnico, etiqueta(i.getEstado())));
        }

        List<Software> instalados = new ArrayList<>();
        for (Software s : software) {
            if (s.getFechaInstalacion() != null) {
                instalados.add(s);
            }
        }
        instalados.sort((a, b) -> b.getFechaInstalacion().compareTo(a.getFechaInstalacion()));
        for (Software s : instalados.subList(0, Math.min(MAX_CENSO, instalados.size()))) {
            String version = s.getVersion() == null || s.getVersion().isBlank() ? "" : " " + s.getVersion();
            r.add(new Evento(s.getFechaInstalacion(), "Censo",
                    "Software instalado: " + s.getNombre() + version, SISTEMA, "Completado"));
        }

        r.sort(Comparator.comparing(Evento::getFecha, Comparator.nullsLast(Comparator.<Date>reverseOrder())));
        return r.size() > MAX_EVENTOS ? new ArrayList<>(r.subList(0, MAX_EVENTOS)) : r;
    }

    /** "ENPROCESO" → "Enproceso", "ACTIVA" → "Activa". */
    private static String etiqueta(String s) {
        if (s == null || s.isBlank()) {
            return "—";
        }
        String t = s.trim().replace('_', ' ').toLowerCase(Locale.ROOT);
        return Character.toUpperCase(t.charAt(0)) + t.substring(1);
    }

    /** Renglón del historial de la ficha. */
    public static final class Evento implements Serializable {

        private static final long serialVersionUID = 1L;

        private final Date fecha;
        private final String tipo;
        private final String descripcion;
        private final String tecnico;
        private final String estado;

        Evento(Date fecha, String tipo, String descripcion, String tecnico, String estado) {
            this.fecha = fecha;
            this.tipo = tipo;
            this.descripcion = descripcion;
            this.tecnico = tecnico;
            this.estado = estado;
        }

        public Date getFecha() {
            return fecha;
        }

        public String getTipo() {
            return tipo;
        }

        public String getDescripcion() {
            return descripcion;
        }

        public String getTecnico() {
            return tecnico;
        }

        public String getEstado() {
            return estado;
        }
    }
}
