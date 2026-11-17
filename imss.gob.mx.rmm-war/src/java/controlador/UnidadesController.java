package controlador;

import jakarta.annotation.PostConstruct;
import jakarta.ejb.EJB;
import jakarta.faces.view.ViewScoped;
import jakarta.inject.Named;
import java.io.Serializable;
import java.util.List;
import logica_negocio.CatalogoUnidadesBean;
import modelo.Area;
import modelo.Region;
import modelo.UnidadHomologada;

/**
 * Controlador de Administración → Unidades (PR-18).
 * Es adminCtrl en SD-07b Consultar catálogo de unidades:
 * consultarUnidades(filtro) → listarUnidades(filtro) → mostrarCatalogo(listaUnidades).
 *
 * La validación del filtro (largo del texto) la hace la vista.
 *
 * @author kyriux
 */
@Named("unidadesCtrl")
@ViewScoped
public class UnidadesController implements Serializable {

    private static final long serialVersionUID = 1L;

    @EJB
    private CatalogoUnidadesBean catalogoBean;

    // Filtro
    private String texto;
    private Short idRegion;
    private String regimen;
    private Short idUnidadHomologada;

    // Datos de la pantalla
    private List<Region> regiones;
    private List<UnidadHomologada> hospitales;
    private List<Area> unidades;

    @PostConstruct
    public void init() {
        regiones = catalogoBean.listarRegiones();
        hospitales = catalogoBean.listarUnidadesHomologadas();
        consultarUnidades();
    }

    /** consultarUnidades(filtro) */
    public void consultarUnidades() {
        // mostrarCatalogo(listaUnidades)
        unidades = catalogoBean.listarUnidades(texto, idRegion, regimen, idUnidadHomologada);
    }

    /** Botón "Limpiar filtros". */
    public void limpiarFiltros() {
        texto = null;
        idRegion = null;
        regimen = null;
        idUnidadHomologada = null;
        consultarUnidades();
    }

    /**
     * Región de un área: la de su unidad homologada o, si ésta sólo tiene zona,
     * la región de esa zona.
     */
    public String region(Area a) {
        UnidadHomologada uh = a.getIdUnidadHomologada();
        if (uh == null) {
            return null;
        }
        if (uh.getIdRegion() != null) {
            return uh.getIdRegion().getNombre();
        }
        return uh.getNumZona() == null ? null : uh.getNumZona().getIdRegion().getNombre();
    }

    // Getters y setters

    public String getTexto() {
        return texto;
    }

    public void setTexto(String texto) {
        this.texto = texto;
    }

    public Short getIdRegion() {
        return idRegion;
    }

    public void setIdRegion(Short idRegion) {
        this.idRegion = idRegion;
    }

    public String getRegimen() {
        return regimen;
    }

    public void setRegimen(String regimen) {
        this.regimen = regimen;
    }

    public Short getIdUnidadHomologada() {
        return idUnidadHomologada;
    }

    public void setIdUnidadHomologada(Short idUnidadHomologada) {
        this.idUnidadHomologada = idUnidadHomologada;
    }

    public List<UnidadHomologada> getHospitales() {
        return hospitales;
    }

    public List<String> getRegimenes() {
        return CatalogoUnidadesBean.REGIMENES;
    }

    public List<Region> getRegiones() {
        return regiones;
    }

    public List<Area> getUnidades() {
        return unidades;
    }
}
