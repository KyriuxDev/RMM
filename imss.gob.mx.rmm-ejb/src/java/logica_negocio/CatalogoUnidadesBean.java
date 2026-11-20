package logica_negocio;

import acceso_datos.AreaFacade;
import acceso_datos.RegionFacade;
import acceso_datos.UnidadHomologadaFacade;
import jakarta.ejb.EJB;
import jakarta.ejb.LocalBean;
import jakarta.ejb.Stateless;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import modelo.Equipo;
import modelo.ClasificacionUnidad;
import modelo.Zona;
import java.util.stream.Collectors;
import java.util.Map;
import acceso_datos.EquipoFacade;
import acceso_datos.ClasificacionUnidadFacade;
import acceso_datos.ZonaFacade;
import modelo.Area;
import modelo.Region;
import modelo.UnidadHomologada;

/**
 * Lógica de negocio de SD-07b Consultar catálogo de unidades, y consultas
 * del catálogo que usan otras pantallas (por ejemplo, el alta de equipo).
 *
 * Es sólo de consulta, así que no tiene validaciones de respaldo.
 *
 * @author kyriux
 */
@Stateless
@LocalBean
public class CatalogoUnidadesBean {

    /** Valores de unidad_informacion.tipo_regimen. */
    public static final List<String> REGIMENES = List.of("ORDINARIO", "EX BIENESTAR");

    @EJB
    private AreaFacade areaFacade;

    @EJB
    private RegionFacade regionFacade;

    @EJB
    private UnidadHomologadaFacade unidadHomologadaFacade;

    @EJB
    private ZonaFacade zonaFacade;

    @EJB
    private ClasificacionUnidadFacade clasificacionFacade;

    @EJB
    private EquipoFacade equipoFacade;

    /**
     * listarUnidades(filtro) de SD-07b: cada fila es un área con su unidad de
     * información, centro de costo, inmueble, unidad homologada y región.
     *
     * @param texto    texto a buscar (null o vacío = sin filtro)
     * @param idRegion región (null = todas)
     * @param regimen  ORDINARIO / EX BIENESTAR (null = todos)
     * @param idUnidadHomologada hospital o sede (null = todos)
     */
    public List<Area> listarUnidades(String texto, Short idRegion, String regimen, Short idUnidadHomologada) {
        String t = Validacion.limpiar(texto);
        String r = Validacion.limpiar(regimen);
        return areaFacade.buscarCatalogo(t, idRegion, r, idUnidadHomologada);
    }

    /** Regiones ordenadas por número (I, II, III...). */
    public List<Region> listarRegiones() {
        List<Region> lista = new ArrayList<>(regionFacade.findAll());
        lista.sort(Comparator.comparing(Region::getNombre));
        return lista;
    }

    /** Hospitales y sedes (tabla unidad_homologada), ordenados por nombre. */
    public List<UnidadHomologada> listarUnidadesHomologadas() {
        List<UnidadHomologada> lista = new ArrayList<>(unidadHomologadaFacade.findAll());
        lista.sort(Comparator.comparing(UnidadHomologada::getNombre));
        return lista;
    }

    /** Áreas (unidad / servicio) de un hospital o sede (unidad homologada). */
    public List<Area> listarAreas(Short idUnidadHomologada) {
        return idUnidadHomologada == null ? new ArrayList<>()
                : areaFacade.listarPorUnidadHomologada(idUnidadHomologada);
    }

    /** Área por id, o null. */
    public Area buscarArea(Integer idArea) {
        return idArea == null ? null : areaFacade.find(idArea);
    }

    /** Región por id, o null. */
    public Region buscarRegion(Short idRegion) {
        return idRegion == null ? null : regionFacade.find(idRegion);
    }

    /** Unidad homologada por id, o null. */
    public UnidadHomologada buscarUnidadHomologada(Short idUnidadHomologada) {
        return idUnidadHomologada == null ? null : unidadHomologadaFacade.find(idUnidadHomologada);
    }

    // ------------------------------------------------------------------
    // Estructura (SD-07b consultarEstructura): áreas y sus equipos
    // ------------------------------------------------------------------

    /** Áreas con los filtros de la pantalla Estructura (todos opcionales). */
    public List<Area> listarEstructura(String texto, Short idUnidadHomologada, Short idRegion, Short numZona,
            String tipoUnidad, String regimen, boolean sinUnidad) {
        return areaFacade.buscarEstructura(Validacion.limpiar(texto), idUnidadHomologada, idRegion, numZona,
                Validacion.limpiar(tipoUnidad), Validacion.limpiar(regimen), sinUnidad);
    }

    /** Equipos activos por área (idArea → cantidad). */
    public Map<Integer, Long> contarEquiposPorArea() {
        return equipoFacade.contarActivosPorArea();
    }

    /** Equipos de un área (los dados de baja al final). */
    public List<Equipo> listarEquiposDeArea(Integer idArea) {
        return idArea == null ? new ArrayList<>() : equipoFacade.listarPorArea(idArea);
    }

    /** Zonas ordenadas por número; con idRegion sólo las de esa región. */
    public List<Zona> listarZonas(Short idRegion) {
        List<Zona> lista = new ArrayList<>(zonaFacade.findAll());
        if (idRegion != null) {
            lista.removeIf(z -> z.getIdRegion() == null || !idRegion.equals(z.getIdRegion().getIdRegion()));
        }
        lista.sort(Comparator.comparing(Zona::getNumZona));
        return lista;
    }

    /** Tipos de unidad (HGZ, UMF, ...) sin repetir, en orden alfabético. */
    public List<String> listarTiposUnidad() {
        return clasificacionFacade.findAll().stream()
                .map(ClasificacionUnidad::getTipoUnidad)
                .filter(t -> t != null && !t.isBlank())
                .distinct().sorted().collect(Collectors.toList());
    }
}
