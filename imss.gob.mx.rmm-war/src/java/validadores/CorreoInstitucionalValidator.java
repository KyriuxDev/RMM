package validadores;

import jakarta.faces.component.UIComponent;
import jakarta.faces.validator.FacesValidator;
import java.util.regex.Pattern;

/**
 * Correo institucional: nombre.apellido@imss.gob.mx (sin importar mayúsculas).
 * Uso: &lt;f:validator validatorId="correoInstitucionalValidator"/&gt;
 *
 * @author kyriux
 */
@FacesValidator("correoInstitucionalValidator")
public class CorreoInstitucionalValidator extends ValidadorTexto {

    public static final Pattern PATRON =
            Pattern.compile("[a-z0-9._%+-]+@imss\\.gob\\.mx", Pattern.CASE_INSENSITIVE);

    @Override
    protected void validar(String texto, UIComponent component) {
        if (!PATRON.matcher(texto).matches()) {
            throw error("El correo debe ser institucional (@imss.gob.mx)");
        }
    }
}
