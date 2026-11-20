package logica_negocio;

import acceso_datos.AlertaFacade;
import acceso_datos.EquipoFacade;
import acceso_datos.IncidenciaFacade;
import jakarta.ejb.EJB;
import jakarta.ejb.LocalBean;
import jakarta.ejb.Stateless;
import java.io.Serializable;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import modelo.Equipo;

/**
 * Datos de Tableros → Vista general (PR-03, SD-04a).
 *
 * Indicadores (equipos por estado, disponibilidad, alertas activas e incidencias
 * abiertas), equipos por unidad y la lista de equipos que llevan más tiempo sin señal.
 *
 * @author kyriux
 */
@Stateless
@LocalBean
public class TablerosBean {

    @EJB
    private EquipoFacade equipoFacade;

    @EJB
    private AlertaFacade alertaFacade;

    @EJB
    private IncidenciaFacade incidenciaFacade;

    /** Indicadores de la parte de arriba del tablero. */
    public Resumen resumen() {
        Map<String, Long> porEstado = equipoFacade.contarActivosPorEstado();
        Resumen r = new Resumen();
        r.enLinea = porEstado.getOrDefault("ONLINE", 0L);
        r.conAlerta = porEstado.getOrDefault("ALERTA", 0L);
        r.sinConexion = porEstado.entrySet().stream()
                .filter(e -> !"ONLINE".equals(e.getKey()) && !"ALERTA".equals(e.getKey()))
                .mapToLong(Map.Entry::getValue).sum();
        r.activos = r.enLinea + r.conAlerta + r.sinConexion;
        r.bajas = equipoFacade.contarBajas();
        r.alertasActivas = alertaFacade.contarActivas();
        r.incidenciasAbiertas = incidenciaFacade.contarAbiertas();
        return r;
    }

    /** Equipos por unidad (las que más equipos tienen primero). */
    public List<FilaUnidad> equiposPorUnidad() {
        Map<Short, FilaUnidad> filas = new LinkedHashMap<>();
        for (Object[] f : equipoFacade.contarPorUnidadYEstado()) {
            Short id = (Short) f[0];
            FilaUnidad fila = filas.computeIfAbsent(id, k -> new FilaUnidad(k, (String) f[1]));
            long n = ((Number) f[3]).longValue();
            String estado = (String) f[2];
            if ("ONLINE".equals(estado)) {
                fila.enLinea += n;
            } else if ("ALERTA".equals(estado)) {
                fila.conAlerta += n;
            } else {
                fila.sinConexion += n;
            }
            fila.total += n;
        }
        List<FilaUnidad> r = new ArrayList<>(filas.values());
        r.sort(Comparator.comparingLong(FilaUnidad::getTotal).reversed().thenComparing(FilaUnidad::getNombre));
        return r;
    }

    public List<Equipo> sinSenal(int maximo) {
        return equipoFacade.listarSinSenal(maximo);
    }

    public List<Equipo> ultimosRegistrados(int maximo) {
        return equipoFacade.listarUltimosRegistrados(maximo);
    }

    /** Porcentaje entero (0 si no hay base). */
    static long porcentaje(long parte, long total) {
        return total == 0 ? 0 : Math.round(parte * 100.0 / total);
    }

    // ------------------------------------------------------------------

    public static class Resumen implements Serializable {

        private static final long serialVersionUID = 1L;
        long activos;
        long enLinea;
        long sinConexion;
        long conAlerta;
        long bajas;
        long alertasActivas;
        long incidenciasAbiertas;

        public long getActivos() {
            return activos;
        }

        public long getEnLinea() {
            return enLinea;
        }

        public long getSinConexion() {
            return sinConexion;
        }

        public long getConAlerta() {
            return conAlerta;
        }

        public long getBajas() {
            return bajas;
        }

        public long getAlertasActivas() {
            return alertasActivas;
        }

        public long getIncidenciasAbiertas() {
            return incidenciasAbiertas;
        }

        /** Disponibilidad: equipos en línea (o con alerta, que sí reportan) entre los activos. */
        public long getDisponibilidad() {
            return porcentaje(enLinea + conAlerta, activos);
        }
    }

    public static class FilaUnidad implements Serializable {

        private static final long serialVersionUID = 1L;
        private final Short idUnidadHomologada;
        private final String nombre;
        long total;
        long enLinea;
        long sinConexion;
        long conAlerta;

        FilaUnidad(Short idUnidadHomologada, String nombre) {
            this.idUnidadHomologada = idUnidadHomologada;
            this.nombre = nombre;
        }

        public Short getIdUnidadHomologada() {
            return idUnidadHomologada;
        }

        public String getNombre() {
            return nombre;
        }

        public long getTotal() {
            return total;
        }

        public long getEnLinea() {
            return enLinea;
        }

        public long getSinConexion() {
            return sinConexion;
        }

        public long getConAlerta() {
            return conAlerta;
        }

        public long getDisponibilidad() {
            return porcentaje(enLinea + conAlerta, total);
        }
    }
}
