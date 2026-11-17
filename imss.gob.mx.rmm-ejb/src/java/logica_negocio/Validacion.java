package logica_negocio;

import excepciones.Excepciones;
import java.util.Map;

/**
 * Validación de respaldo que comparten los beans de lógica de negocio.
 *
 * La vista ya valida formato y rangos; aquí sólo se revisa que lleguen
 * los datos obligatorios, por si alguien llama al EJB sin pasar por la página.
 *
 * @author kyriux
 */
final class Validacion {

    private Validacion() {
    }

    /** Lanza Excepciones(campo, mensaje) si el valor es null. */
    static void requerido(Object valor, String campo, String mensaje) {
        if (valor == null || (valor instanceof Map<?, ?> m && m.isEmpty())) {
            throw new Excepciones(campo, mensaje);
        }
    }

    /** Quita espacios; un texto vacío se vuelve null. */
    static String limpiar(String texto) {
        return (texto == null || texto.isBlank()) ? null : texto.trim();
    }
}
