package controlador;

import excepciones.Excepciones;
import jakarta.annotation.PostConstruct;
import jakarta.ejb.EJB;
import jakarta.faces.view.ViewScoped;
import jakarta.inject.Named;
import java.io.Serializable;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import logica_negocio.CatalogoUnidadesBean;
import logica_negocio.IndicadorSla;
import logica_negocio.MetasSlaBean;
import modelo.Region;
import modelo.Sla;
import modelo.UnidadHomologada;

/**
 * Controlador de Administración → Metas SLA (PR-18).
 * Es adminCtrl en SD-07c: guardarMetaSLA(indicador, valorMeta, ...) →
 * crear (meta nueva) o actualizarMeta (ya existía) → mostrarConfirmacion().
 *
 * El rango de la meta lo valida la vista con MetaSlaValidator.
 *
 * @author kyriux
 */
@Named("metasSlaCtrl")
@ViewScoped
public class MetasSlaController implements Serializable {

    private static final long serialVersionUID = 1L;

    @EJB
    private MetasSlaBean metasSlaBean;

    @EJB
    private CatalogoUnidadesBean catalogoBean;

    // Formulario
    private String indicador;
    private Double valorMeta;
    private String ambito;
    private Short idRegion;
    private Short idUnidadHomologada;

    // Datos de la pantalla
    private final List<IndicadorSla> indicadores = Arrays.asList(IndicadorSla.values());
    private List<Region> regiones;
    private List<UnidadHomologada> unidades;
    private List<Sla> metas;

    /** Para mostrar en la tabla el nombre de la región o unidad del ámbito. */
    private Map<String, String> nombresRegion;
    private Map<String, String> nombresUnidad;

    @PostConstruct
    public void init() {
        regiones = catalogoBean.listarRegiones();
        unidades = catalogoBean.listarUnidadesHomologadas();
        nombresRegion = new HashMap<>();
        regiones.forEach(r -> nombresRegion.put(String.valueOf(r.getIdRegion()), r.getNombre()));
        nombresUnidad = new HashMap<>();
        unidades.forEach(u -> nombresUnidad.put(String.valueOf(u.getIdUnidadHomologada()), u.getNombre()));
        metas = metasSlaBean.listarMetas();
        limpiarFormulario();
    }

    /** guardarMetaSLA(datos) */
    public void guardarMetaSLA() {
        try {
            String valorAmbito = MetasSlaBean.AMBITO_REGION.equals(ambito)
                    ? (idRegion == null ? null : String.valueOf(idRegion))
                    : MetasSlaBean.AMBITO_UNIDAD.equals(ambito)
                    ? (idUnidadHomologada == null ? null : String.valueOf(idUnidadHomologada)) : null;

            boolean nueva = metasSlaBean.guardarMetaSLA(indicador, valorMeta, ambito, valorAmbito);

            // mostrarConfirmacion()
            IndicadorSla i = IndicadorSla.porCodigo(indicador);
            Mensajes.info(nueva ? "Meta registrada" : "Meta actualizada",
                    i.getNombre() + ": " + valorMeta + " " + i.getUnidadMedida()
                    + " (" + nombreAmbito(ambito, valorAmbito) + ")");
            metas = metasSlaBean.listarMetas();
            limpiarFormulario();

        } catch (Excepciones e) {
            Mensajes.error("formMetas", e, "No se pudo guardar la meta");
        }
    }

    /** Botón "Editar" de la tabla: pasa la meta al formulario. */
    public void editar(Sla s) {
        IndicadorSla i = IndicadorSla.porNombre(s.getNombreIndicador());
        indicador = i == null ? null : i.getCodigo();
        valorMeta = s.getMetaValor();
        ambito = s.getAmbito();
        idRegion = MetasSlaBean.AMBITO_REGION.equals(ambito) && s.getValorAmbito() != null
                ? Short.valueOf(s.getValorAmbito()) : null;
        idUnidadHomologada = MetasSlaBean.AMBITO_UNIDAD.equals(ambito) && s.getValorAmbito() != null
                ? Short.valueOf(s.getValorAmbito()) : null;
    }

    /** Botón "Limpiar". */
    public void cancelar() {
        limpiarFormulario();
    }

    /** "Global", el nombre de la región o el de la unidad. */
    public String nombreAmbito(String amb, String valor) {
        if (MetasSlaBean.AMBITO_REGION.equals(amb)) {
            return nombresRegion.getOrDefault(valor, "Región " + valor);
        }
        if (MetasSlaBean.AMBITO_UNIDAD.equals(amb)) {
            return nombresUnidad.getOrDefault(valor, "Unidad " + valor);
        }
        return "Todo el OOAD";
    }

    /** Unidad de medida del indicador seleccionado (se muestra junto al valor). */
    public String getUnidadMedida() {
        IndicadorSla i = IndicadorSla.porCodigo(indicador);
        return i == null ? "" : i.getUnidadMedida();
    }

    public boolean isAmbitoRegion() {
        return MetasSlaBean.AMBITO_REGION.equals(ambito);
    }

    public boolean isAmbitoUnidad() {
        return MetasSlaBean.AMBITO_UNIDAD.equals(ambito);
    }

    private void limpiarFormulario() {
        indicador = null;
        valorMeta = null;
        ambito = MetasSlaBean.AMBITO_GLOBAL;
        idRegion = null;
        idUnidadHomologada = null;
    }

    // Getters y setters

    public String getIndicador() {
        return indicador;
    }

    public void setIndicador(String indicador) {
        this.indicador = indicador;
    }

    public Double getValorMeta() {
        return valorMeta;
    }

    public void setValorMeta(Double valorMeta) {
        this.valorMeta = valorMeta;
    }

    public String getAmbito() {
        return ambito;
    }

    public void setAmbito(String ambito) {
        this.ambito = ambito;
    }

    public Short getIdRegion() {
        return idRegion;
    }

    public void setIdRegion(Short idRegion) {
        this.idRegion = idRegion;
    }

    public Short getIdUnidadHomologada() {
        return idUnidadHomologada;
    }

    public void setIdUnidadHomologada(Short idUnidadHomologada) {
        this.idUnidadHomologada = idUnidadHomologada;
    }

    public List<IndicadorSla> getIndicadores() {
        return indicadores;
    }

    public List<Region> getRegiones() {
        return regiones;
    }

    public List<UnidadHomologada> getUnidades() {
        return unidades;
    }

    public List<Sla> getMetas() {
        return metas;
    }

    public String getAmbitoGlobal() {
        return MetasSlaBean.AMBITO_GLOBAL;
    }

    public String getAmbitoRegion() {
        return MetasSlaBean.AMBITO_REGION;
    }

    public String getAmbitoUnidad() {
        return MetasSlaBean.AMBITO_UNIDAD;
    }
}
