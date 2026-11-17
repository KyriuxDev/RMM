package validadores;

import jakarta.faces.component.UIComponent;
import jakarta.faces.validator.FacesValidator;
import java.util.regex.Pattern;

/**
 * Matrícula IMSS: sólo dígitos, de 6 a 10.
 * Uso: &lt;f:validator validatorId="matriculaValidator"/&gt;
 *
 * @author kyriux
 */
@FacesValidator("matriculaValidator")
public class MatriculaValidator extends ValidadorTexto {

    public static final Pattern PATRON = Pattern.compile("\\d{6,10}");

    @Override
    protected void validar(String texto, UIComponent component) {
        if (!PATRON.matcher(texto).matches()) {
            throw error("La matrícula debe tener de 6 a 10 dígitos");
        }
    }
}
