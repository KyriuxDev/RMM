package validadores;

import jakarta.faces.application.FacesMessage;
import jakarta.faces.component.UIComponent;
import jakarta.faces.component.UIInput;
import jakarta.faces.context.FacesContext;
import jakarta.faces.validator.FacesValidator;
import jakarta.faces.validator.Validator;
import jakarta.faces.validator.ValidatorException;
import logica_negocio.IndicadorSla;

/**
 * Valor de la meta SLA dentro del rango del indicador seleccionado
 * (porcentaje: 0.01 a 100; horas: 0.01 a 720).
 *
 * El indicador se lee del componente que llega en el atributo "indicador":
 *   &lt;p:selectOneMenu id="indicador" binding="#{indicadorComp}" .../&gt;
 *   &lt;p:inputNumber ...&gt;
 *       &lt;f:validator validatorId="metaSlaValidator"/&gt;
 *       &lt;f:attribute name="indicador" value="#{indicadorComp}"/&gt;
 *   &lt;/p:inputNumber&gt;
 * Así se usa el valor recién capturado y no el que tenía el controlador.
 *
 * @author kyriux
 */
@FacesValidator("metaSlaValidator")
public class MetaSlaValidator implements Validator<Object> {

    @Override
    public void validate(FacesContext context, UIComponent component, Object value) {
        if (value == null) {
            return;   // lo revisa required="true"
        }
        Object comp = component.getAttributes().get("indicador");
        Object codigo = comp instanceof UIInput in ? in.getValue() : null;
        IndicadorSla indicador = codigo == null ? null : IndicadorSla.porCodigo(codigo.toString());
        if (indicador == null) {
            return;   // sin indicador, el error lo muestra el propio select
        }

        double v = ((Number) value).doubleValue();
        if (v < indicador.getValorMinimo() || v > indicador.getValorMaximo()) {
            String mensaje = String.format("Para \"%s\" la meta debe estar entre %s y %s %s",
                    indicador.getNombre(), numero(indicador.getValorMinimo()),
                    numero(indicador.getValorMaximo()), indicador.getUnidadMedida());
            throw new ValidatorException(new FacesMessage(FacesMessage.SEVERITY_ERROR, mensaje, mensaje));
        }
    }

    private static String numero(double d) {
        return d == Math.rint(d) ? String.valueOf((long) d) : String.valueOf(d);
    }
}
