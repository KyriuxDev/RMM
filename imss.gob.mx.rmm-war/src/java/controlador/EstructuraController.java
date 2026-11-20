package controlador;

import jakarta.annotation.PostConstruct;
import jakarta.ejb.EJB;
import jakarta.faces.view.ViewScoped;
import jakarta.inject.Named;
import java.io.Serializable;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;
import logica_negocio.CatalogoUnidadesBean;
import modelo.Area;
import modelo.Equipo;
import modelo.Region;
import modelo.UnidadHomologada;
import modelo.Zona;

/**
 * Controlador de Administración → Estructura (SD-07b, igual que la sección
 * Estructura de la intranet, sin RCAB).
 *
 * Cada renglón es un área (unidad de información + centro de costo +
 * división / subdivisión) con su unidad homologada, región y zona, y cuántos
 * equipos activos tiene. Al abrir un renglón se ven sus equipos y se puede
 * dar de alta un equipo directamente en esa área.
 *
 * @author kyriux
 */
@Named("estructuraCtrl")
@ViewScoped
public class EstructuraController implements Serializable {

    private static final long serialVersionUID = 1L;

    public static final String CON_EQUIPOS = "CON";
    public static final String SIN_EQUIPOS = "SIN";
    public static final String SIN_UNIDAD = "SIN_UNIDAD";

    @EJB
    private CatalogoUnidadesBean catalogoBean;

    // Filtro
    private String texto;
    private Short idUnidadHomologada;
    private Short idRegion;
    private Short numZona;
    private String tipoUnidad;
    private String regimen;
    /** null = todas, CON = con equipos, SIN = sin equipos, SIN_UNIDAD = sin unidad homologada */
    private String equipos;

    // Datos de la pantalla
    private List<UnidadHomologada> unidades;
    private List<Region> regiones;
    private List<Zona> zonas;
    private List<String> tiposUnidad;
    private List<Area> areas;
    private Map<Integer, Long> equiposPorArea;
    private final Map<Integer, List<Equipo>> equiposCargados = new HashMap<>();

    @PostConstruct
    public void init() {
        unidades = catalogoBean.listarUnidadesHomologadas();
        regiones = catalogoBean.listarRegiones();
        zonas = catalogoBean.listarZonas(null);
        tiposUnidad = catalogoBean.listarTiposUnidad();
        consultarEstructura();
    }

    /** SD-07b consultarEstructura(filtro). */
    public void consultarEstructura() {
        equiposPorArea = catalogoBean.contarEquiposPorArea();
        equiposCargados.clear();
        List<Area> lista = catalogoBean.listarEstructura(texto, idUnidadHomologada, idRegion, numZona,
                tipoUnidad, regimen, SIN_UNIDAD.equals(equipos));
        if (CON_EQUIPOS.equals(equipos)) {
            lista = lista.stream().filter(a -> equipos(a) > 0).collect(Collectors.toList());
        } else if (SIN_EQUIPOS.equals(equipos)) {
            lista = lista.stream().filter(a -> equipos(a) == 0).collect(Collectors.toList());
        }
        areas = lista;
    }

    /** Al elegir región, la lista de zonas sólo muestra las de esa región. */
    public void cambiarRegion() {
        zonas = catalogoBean.listarZonas(idRegion);
        if (numZona != null && zonas.stream().noneMatch(z -> z.getNumZona().equals(numZona))) {
            numZona = null;
        }
    }

    public void limpiarFiltros() {
        texto = null;
        idUnidadHomologada = null;
        idRegion = null;
        numZona = null;
        tipoUnidad = null;
        regimen = null;
        equipos = null;
        zonas = catalogoBean.listarZonas(null);
        consultarEstructura();
    }

    /** Equipos activos del área. */
    public long equipos(Area a) {
        return equiposPorArea == null ? 0 : equiposPorArea.getOrDefault(a.getIdArea(), 0L);
    }

    /** Equipos del área (se consultan al abrir el renglón). */
    public List<Equipo> equiposDe(Area a) {
        return equiposCargados.computeIfAbsent(a.getIdArea(), catalogoBean::listarEquiposDeArea);
    }

    /** "Región · zona N" de la unidad homologada del área. */
    public String regionZona(Area a) {
        UnidadHomologada uh = a.getIdUnidadHomologada();
        if (uh == null) {
            return null;
        }
        if (uh.getNumZona() != null) {
            String region = uh.getNumZona().getIdRegion() == null ? "" : uh.getNumZona().getIdRegion().getNombre();
            return region + " · zona " + uh.getNumZona().getNumZona();
        }
        return uh.getIdRegion() == null ? null : uh.getIdRegion().getNombre();
    }

    public String tipo(Area a) {
        UnidadHomologada uh = a.getIdUnidadHomologada();
        return uh == null || uh.getIdClasificacion() == null ? null : uh.getIdClasificacion().getSubTipoUnidad();
    }

    public String claseEstado(Equipo e) {
        String s = e.getEstadoConexion();
        if ("ONLINE".equals(s)) {
            return "estado-activo";
        }
        if ("ALERTA".equals(s)) {
            return "estado-alerta";
        }
        if ("INACTIVO".equals(s)) {
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

    public Short getIdUnidadHomologada() {
        return idUnidadHomologada;
    }

    public void setIdUnidadHomologada(Short idUnidadHomologada) {
        this.idUnidadHomologada = idUnidadHomologada;
    }

    public Short getIdRegion() {
        return idRegion;
    }

    public void setIdRegion(Short idRegion) {
        this.idRegion = idRegion;
    }

    public Short getNumZona() {
        return numZona;
    }

    public void setNumZona(Short numZona) {
        this.numZona = numZona;
    }

    public String getTipoUnidad() {
        return tipoUnidad;
    }

    public void setTipoUnidad(String tipoUnidad) {
        this.tipoUnidad = tipoUnidad == null || tipoUnidad.isBlank() ? null : tipoUnidad;
    }

    public String getRegimen() {
        return regimen;
    }

    public void setRegimen(String regimen) {
        this.regimen = regimen == null || regimen.isBlank() ? null : regimen;
    }

    public String getEquipos() {
        return equipos;
    }

    public void setEquipos(String equipos) {
        this.equipos = equipos == null || equipos.isBlank() ? null : equipos;
    }

    public List<UnidadHomologada> getUnidades() {
        return unidades;
    }

    public List<Region> getRegiones() {
        return regiones;
    }

    public List<Zona> getZonas() {
        return zonas;
    }

    public List<String> getTiposUnidad() {
        return tiposUnidad;
    }

    public List<String> getRegimenes() {
        return CatalogoUnidadesBean.REGIMENES;
    }

    public List<Area> getAreas() {
        return areas;
    }
}
