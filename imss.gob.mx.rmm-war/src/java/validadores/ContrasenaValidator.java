package validadores;

import jakarta.faces.application.FacesMessage;
import jakarta.faces.component.UIComponent;
import jakarta.faces.context.FacesContext;
import jakarta.faces.validator.FacesValidator;
import jakarta.faces.validator.Validator;
import jakarta.faces.validator.ValidatorException;

/**
 * Contraseña temporal: de 8 a 64 caracteres.
 * (No recorta espacios: la contraseña se guarda tal cual se escribió.)
 * Uso: &lt;f:validator validatorId="contrasenaValidator"/&gt;
 *
 * @author kyriux
 */
@FacesValidator("contrasenaValidator")
public class ContrasenaValidator implements Validator<Object> {

    public static final int LONGITUD_MINIMA = 8;
    public static final int LONGITUD_MAXIMA = 64;

    @Override
    public void validate(FacesContext context, UIComponent component, Object value) {
        if (value == null || value.toString().isEmpty()) {
            return;   // lo revisa required="true"
        }
        String c = value.toString();
        String mensaje = null;
        if (c.length() < LONGITUD_MINIMA) {
            mensaje = "La contraseña debe tener al menos " + LONGITUD_MINIMA + " caracteres";
        } else if (c.length() > LONGITUD_MAXIMA) {
            mensaje = "La contraseña no puede tener más de " + LONGITUD_MAXIMA + " caracteres";
        }
        if (mensaje != null) {
            throw new ValidatorException(new FacesMessage(FacesMessage.SEVERITY_ERROR, mensaje, mensaje));
        }
    }
}
