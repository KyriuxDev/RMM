package validadores;

import excepciones.Excepciones;
import jakarta.faces.application.FacesMessage;
import jakarta.faces.component.UIComponent;
import jakarta.faces.context.FacesContext;
import jakarta.faces.validator.Validator;
import jakarta.faces.validator.ValidatorException;

/**
 * Base de los validadores de texto de la vista.
 *
 * - Si el campo viene vacío no hace nada: eso lo revisa required="true".
 * - Quita los espacios de los extremos antes de validar.
 * - El mensaje de error se muestra en el p:message del campo.
 *
 * Los validadores que revisan duplicados llaman al EJB, que lanza
 * excepciones.Excepciones; aquí se convierte en ValidatorException para
 * que la vista marque el campo en rojo.
 *
 * @author kyriux
 */
public abstract class ValidadorTexto implements Validator<Object> {

    @Override
    public void validate(FacesContext context, UIComponent component, Object value) {
        if (value == null) {
            return;
        }
        String texto = value.toString().trim();
        if (texto.isEmpty()) {
            return;
        }
        try {
            validar(texto, component);
        } catch (Excepciones e) {
            throw error(e.getMessage());
        }
    }

    /**
     * Revisa el texto (ya sin espacios en los extremos y no vacío).
     * Lanza ValidatorException (con error(...)) o Excepciones si no es válido.
     */
    protected abstract void validar(String texto, UIComponent component);

    /**
     * Id del registro que se está editando, para no marcarlo como duplicado
     * de sí mismo. Se pasa desde la vista con
     * &lt;f:attribute name="idExcluir" value="#{...}"/&gt;; null en un alta.
     */
    protected static Integer idExcluir(UIComponent component) {
        Object v = component.getAttributes().get("idExcluir");
        if (v instanceof Number n) {
            return n.intValue();
        }
        if (v != null && !v.toString().isBlank()) {
            try {
                return Integer.valueOf(v.toString().trim());
            } catch (NumberFormatException e) {
                return null;
            }
        }
        return null;
    }

    /** Crea la excepción con el mensaje que verá el usuario. */
    protected static ValidatorException error(String mensaje) {
        return new ValidatorException(new FacesMessage(FacesMessage.SEVERITY_ERROR, mensaje, mensaje));
    }
}
