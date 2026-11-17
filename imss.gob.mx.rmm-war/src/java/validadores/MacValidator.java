package validadores;

import jakarta.faces.component.UIComponent;
import jakarta.faces.validator.FacesValidator;
import java.util.regex.Pattern;

/**
 * Dirección MAC: seis pares hexadecimales separados con ":" o "-".
 * Ej. 3C:52:82:1A:9F:04
 * Uso: &lt;f:validator validatorId="macValidator"/&gt;
 *
 * @author kyriux
 */
@FacesValidator("macValidator")
public class MacValidator extends ValidadorTexto {

    public static final Pattern PATRON =
            Pattern.compile("[0-9A-Fa-f]{2}([:-])(?:[0-9A-Fa-f]{2}\\1){4}[0-9A-Fa-f]{2}");

    @Override
    protected void validar(String texto, UIComponent component) {
        if (!PATRON.matcher(texto).matches()) {
            throw error("La MAC debe tener el formato AA:BB:CC:DD:EE:FF");
        }
    }
}
