package logica_negocio;

import acceso_datos.CatalogoSoftwareFacade;
import excepciones.Excepciones;
import jakarta.ejb.EJB;
import jakarta.ejb.LocalBean;
import jakarta.ejb.Schedule;
import jakarta.ejb.Stateless;
import java.io.Serializable;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Objects;
import java.util.TreeSet;
import java.util.logging.Level;
import java.util.logging.Logger;
import modelo.Software;

/**
 * HU-8: identificación de software no autorizado y desactualizado.
 *
 *   - Autorizado: lo decide un técnico por nombre de software y aplica a
 *     todos los equipos donde esté instalado. null = "sin revisar".
 *     El software nuevo que reporta el agente hereda la marca (IngestaBean).
 *   - Desactualizado: la versión instalada es menor que la más reciente que
 *     hay en el parque para ese mismo software. Se guarda en
 *     Software.actualizado (la ficha del equipo lo muestra) cada 10 minutos.
 *
 * @author kyriux
 */
@Stateless
@LocalBean
public class SoftwareBean {

    private static final Logger LOG = Logger.getLogger(SoftwareBean.class.getName());

    public static final String FILTRO_NO_AUTORIZADO = "NO_AUTORIZADO";
    public static final String FILTRO_SIN_REVISAR = "SIN_REVISAR";
    public static final String FILTRO_DESACTUALIZADO = "DESACTUALIZADO";
    public static final String FILTRO_AUTORIZADO = "AUTORIZADO";

    @EJB
    private CatalogoSoftwareFacade facade;

    /** Catálogo agrupado por nombre de software (un renglón por software). */
    public List<FilaSoftware> catalogo() {
        Map<String, List<Software>> porNombre = agrupar(facade.softwareEquiposActivos());
        List<FilaSoftware> filas = new ArrayList<>();
        for (List<Software> instalaciones : porNombre.values()) {
            filas.add(fila(instalaciones));
        }
        // No autorizado primero, luego sin revisar, luego por nombre
        filas.sort(Comparator.comparingInt(FilaSoftware::orden)
                .thenComparing(f -> f.nombre.toLowerCase(Locale.ROOT)));
        return filas;
    }

    /**
     * Marca un software como autorizado (true), no autorizado (false) o lo
     * regresa a sin revisar (null), en todos los equipos.
     */
    public int marcar(String nombre, Boolean autorizado) {
        if (nombre == null || nombre.isBlank()) {
            throw new Excepciones("Seleccione un software");
        }
        return facade.marcarAutorizado(nombre.trim(), autorizado);
    }

    /** Recalcula Software.actualizado contra la versión más reciente del parque. */
    @Schedule(minute = "*/10", hour = "*", persistent = false, info = "RMM: software desactualizado")
    public void recalcularActualizados() {
        try {
            int cambios = 0;
            for (List<Software> instalaciones : agrupar(facade.softwareEquiposActivos()).values()) {
                String reciente = versionMasReciente(instalaciones);
                for (Software s : instalaciones) {
                    Boolean nuevo = reciente == null || s.getVersion() == null
                            ? null : compararVersiones(s.getVersion(), reciente) >= 0;
                    if (!Objects.equals(nuevo, s.getActualizado())) {
                        s.setActualizado(nuevo);
                        facade.editar(s);
                        cambios++;
                    }
                }
            }
            if (cambios > 0) {
                LOG.log(Level.INFO, "RMM: {0} registro(s) de software cambiaron de actualizado/desactualizado", cambios);
            }
        } catch (RuntimeException e) {
            LOG.log(Level.WARNING, "RMM: no se pudo recalcular el software desactualizado", e);
        }
    }

    // ------------------------------------------------------------------
    // Auxiliares
    // ------------------------------------------------------------------

    private static Map<String, List<Software>> agrupar(List<Software> todo) {
        Map<String, List<Software>> m = new LinkedHashMap<>();
        for (Software s : todo) {
            if (s.getNombre() != null) {
                m.computeIfAbsent(s.getNombre().trim().toLowerCase(Locale.ROOT), k -> new ArrayList<>()).add(s);
            }
        }
        return m;
    }

    private static FilaSoftware fila(List<Software> instalaciones) {
        FilaSoftware f = new FilaSoftware();
        Software primero = instalaciones.get(0);
        f.nombre = primero.getNombre();
        f.versionReciente = versionMasReciente(instalaciones);
        TreeSet<String> versiones = new TreeSet<>(SoftwareBean::compararVersiones);
        boolean algunoNo = false;
        boolean algunoSi = false;
        for (Software s : instalaciones) {
            if (f.fabricante == null && s.getFabricante() != null) {
                f.fabricante = s.getFabricante();
            }
            if (s.getVersion() != null) {
                versiones.add(s.getVersion());
            }
            algunoNo |= Boolean.FALSE.equals(s.getAutorizado());
            algunoSi |= Boolean.TRUE.equals(s.getAutorizado());
            boolean desact = f.versionReciente != null && s.getVersion() != null
                    && compararVersiones(s.getVersion(), f.versionReciente) < 0;
            if (desact) {
                f.desactualizados++;
            }
            f.instalaciones.add(new Instalacion(s.getIdEquipo().getIdEquipo(),
                    s.getIdEquipo().getHostname(), s.getVersion(), desact));
        }
        // Si quedó mezclado (p. ej. software nuevo antes de marcarlo), gana "no autorizado"
        f.autorizado = algunoNo ? Boolean.FALSE : (algunoSi ? Boolean.TRUE : null);
        f.versiones = new ArrayList<>(versiones.descendingSet());
        f.instalaciones.sort(Comparator.comparing(i -> i.hostname == null ? "" : i.hostname));
        return f;
    }

    private static String versionMasReciente(List<Software> instalaciones) {
        String max = null;
        for (Software s : instalaciones) {
            if (s.getVersion() != null && (max == null || compararVersiones(s.getVersion(), max) > 0)) {
                max = s.getVersion();
            }
        }
        return max;
    }

    /**
     * Compara versiones por sus partes numéricas: "10.2.1" > "9.12",
     * "1.10" > "1.9". Si las partes numéricas empatan ("2.0" y "2.0.0"),
     * se toman como la misma versión.
     */
    public static int compararVersiones(String a, String b) {
        String[] pa = a.split("\\D+");
        String[] pb = b.split("\\D+");
        int n = Math.max(pa.length, pb.length);
        for (int i = 0; i < n; i++) {
            long x = parte(pa, i);
            long y = parte(pb, i);
            if (x != y) {
                return Long.compare(x, y);
            }
        }
        return 0;
    }

    private static long parte(String[] partes, int i) {
        if (i >= partes.length || partes[i].isEmpty()) {
            return 0;
        }
        try {
            String p = partes[i].length() > 15 ? partes[i].substring(0, 15) : partes[i];
            return Long.parseLong(p);
        } catch (NumberFormatException e) {
            return 0;
        }
    }

    // ------------------------------------------------------------------
    // Renglones para la vista
    // ------------------------------------------------------------------

    public static class FilaSoftware implements Serializable {

        private static final long serialVersionUID = 1L;

        private String nombre;
        private String fabricante;
        private Boolean autorizado;
        private String versionReciente;
        private List<String> versiones = new ArrayList<>();
        private int desactualizados;
        private final List<Instalacion> instalaciones = new ArrayList<>();

        int orden() {
            return Boolean.FALSE.equals(autorizado) ? 0 : (autorizado == null ? 1 : 2);
        }

        /** ¿Pasa el filtro de la vista? ("" o null = todos) */
        public boolean cumple(String filtro) {
            if (filtro == null || filtro.isEmpty()) {
                return true;
            }
            return switch (filtro) {
                case FILTRO_NO_AUTORIZADO -> Boolean.FALSE.equals(autorizado);
                case FILTRO_SIN_REVISAR -> autorizado == null;
                case FILTRO_AUTORIZADO -> Boolean.TRUE.equals(autorizado);
                case FILTRO_DESACTUALIZADO -> desactualizados > 0;
                default -> true;
            };
        }

        public String getNombre() {
            return nombre;
        }

        public String getFabricante() {
            return fabricante;
        }

        public Boolean getAutorizado() {
            return autorizado;
        }

        public String getVersionReciente() {
            return versionReciente;
        }

        public List<String> getVersiones() {
            return versiones;
        }

        public int getEquipos() {
            return instalaciones.size();
        }

        public int getDesactualizados() {
            return desactualizados;
        }

        public List<Instalacion> getInstalaciones() {
            return instalaciones;
        }
    }

    public static class Instalacion implements Serializable {

        private static final long serialVersionUID = 1L;

        private final Integer idEquipo;
        private final String hostname;
        private final String version;
        private final boolean desactualizado;

        Instalacion(Integer idEquipo, String hostname, String version, boolean desactualizado) {
            this.idEquipo = idEquipo;
            this.hostname = hostname;
            this.version = version;
            this.desactualizado = desactualizado;
        }

        public Integer getIdEquipo() {
            return idEquipo;
        }

        public String getHostname() {
            return hostname;
        }

        public String getVersion() {
            return version;
        }

        public boolean isDesactualizado() {
            return desactualizado;
        }
    }
}
