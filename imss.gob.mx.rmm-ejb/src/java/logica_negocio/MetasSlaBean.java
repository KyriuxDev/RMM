package logica_negocio;

import acceso_datos.SlaFacade;
import excepciones.Excepciones;
import jakarta.ejb.EJB;
import jakarta.ejb.LocalBean;
import jakarta.ejb.Stateless;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import modelo.Sla;

/**
 * Lógica de negocio de SD-07c Metas SLA.
 *
 * guardarMetaSLA(datos):
 *   alt metaExistente == false → crear(...)      → insertarMetaSLA
 *       metaExistente == true  → actualizarMeta() → actualizarMetaSLA
 *
 * Una meta es "la misma" si coincide indicador + ámbito + valor del ámbito.
 * El rango del valor lo valida la vista (MetaSlaValidator); aquí queda el
 * respaldo de datos obligatorios.
 *
 * @author kyriux
 */
@Stateless
@LocalBean
public class MetasSlaBean {

    /** Valores de sla.ambito. */
    public static final String AMBITO_GLOBAL = "GLOBAL";
    public static final String AMBITO_REGION = "REGION";
    public static final String AMBITO_UNIDAD = "UNIDAD";

    @EJB
    private SlaFacade slaFacade;

    /**
     * Crea la meta o, si ya había una para el mismo indicador y ámbito,
     * actualiza su valor.
     *
     * @param codigoIndicador código de IndicadorSla
     * @param valorMeta       valor de la meta
     * @param ambito          GLOBAL, REGION o UNIDAD
     * @param valorAmbito     id de la región o id de la unidad homologada (null si es GLOBAL)
     * @return true si se creó, false si se actualizó una existente
     */
    public boolean guardarMetaSLA(String codigoIndicador, Double valorMeta, String ambito, String valorAmbito) {
        // Respaldo: datos obligatorios
        IndicadorSla indicador = IndicadorSla.porCodigo(codigoIndicador);
        Validacion.requerido(indicador, "indicador", "Seleccione el indicador");
        Validacion.requerido(valorMeta, "valorMeta", "La meta es obligatoria");
        String amb = Validacion.limpiar(ambito);
        Validacion.requerido(amb, "ambito", "Seleccione el ámbito");
        String valor = AMBITO_GLOBAL.equals(amb) ? null : Validacion.limpiar(valorAmbito);
        if (!AMBITO_GLOBAL.equals(amb) && valor == null) {
            throw new Excepciones(AMBITO_REGION.equals(amb) ? "region" : "unidad",
                    "Seleccione a qué " + (AMBITO_REGION.equals(amb) ? "región" : "hospital o sede") + " aplica la meta");
        }

        Sla existente = slaFacade.buscarMeta(indicador.getNombre(), amb, valor);
        if (existente == null) {
            // crear(nombre, indicador, valorMeta, unidadMedida, periodo)
            Sla sla = new Sla();
            sla.setNombreIndicador(indicador.getNombre());
            sla.setMetaValor(valorMeta);
            sla.setUnidadMedida(indicador.getUnidadMedida());
            sla.setAmbito(amb);
            sla.setValorAmbito(valor);
            slaFacade.create(sla);
            return true;
        }

        // actualizarMeta(valorMeta)
        existente.setMetaValor(valorMeta);
        slaFacade.edit(existente);
        return false;
    }

    /** Metas registradas, por indicador y ámbito. */
    public List<Sla> listarMetas() {
        List<Sla> lista = new ArrayList<>(slaFacade.findAll());
        lista.sort(Comparator.comparing(Sla::getNombreIndicador)
                .thenComparing(Sla::getAmbito)
                .thenComparing(s -> s.getValorAmbito() == null ? "" : s.getValorAmbito()));
        return lista;
    }
}
