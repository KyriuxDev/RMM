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
}
