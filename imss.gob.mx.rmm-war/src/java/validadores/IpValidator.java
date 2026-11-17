package validadores;

import jakarta.faces.component.UIComponent;
import jakarta.faces.validator.FacesValidator;

/**
 * Dirección IPv4: cuatro números de 0 a 255 separados con puntos.
 * Uso: &lt;f:validator validatorId="ipValidator"/&gt;
 *
 * @author kyriux
 */
@FacesValidator("ipValidator")
public class IpValidator extends ValidadorTexto {

    @Override
    protected void validar(String texto, UIComponent component) {
        if (!esIpv4(texto)) {
            throw error("La IP debe tener el formato 10.21.0.15 (cuatro números de 0 a 255)");
        }
    }

    public static boolean esIpv4(String texto) {
        String[] partes = texto.split("\\.", -1);
        if (partes.length != 4) {
            return false;
        }
        for (String p : partes) {
            if (!p.matches("\\d{1,3}") || (p.length() > 1 && p.startsWith("0"))
                    || Integer.parseInt(p) > 255) {
                return false;
            }
        }
        return true;
    }
}
