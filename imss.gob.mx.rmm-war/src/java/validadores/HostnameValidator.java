package validadores;

import jakarta.faces.component.UIComponent;
import jakarta.faces.validator.FacesValidator;
import java.util.regex.Pattern;

/**
 * Hostname: letras, números y guiones (de 2 a 63), sin empezar ni terminar
 * con guion. Ej. OAX-HGZ1-PC014.
 * Uso: &lt;f:validator validatorId="hostnameValidator"/&gt;
 *
 * @author kyriux
 */
@FacesValidator("hostnameValidator")
public class HostnameValidator extends ValidadorTexto {

    public static final Pattern PATRON =
            Pattern.compile("[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])");

    @Override
    protected void validar(String texto, UIComponent component) {
        if (!PATRON.matcher(texto).matches()) {
            throw error("El hostname sólo admite letras, números y guiones (2 a 63), "
                    + "y no puede empezar ni terminar con guion");
        }
    }
}
