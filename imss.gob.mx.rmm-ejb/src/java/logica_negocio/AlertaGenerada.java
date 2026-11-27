package logica_negocio;

import modelo.Alerta;

/**
 * Evento CDI que se lanza cada vez que el sistema genera una alerta
 * (IngestaBean, HU-4). Sirve para que otros módulos reaccionen sin
 * tocar IngestaBean; por ejemplo, el envío de correo de HU-15:
 *
 * <pre>
 * public void alGenerarse(&#64;Observes(during = TransactionPhase.AFTER_SUCCESS) AlertaGenerada evento) {
 *     if (evento.esCritica()) { ... }
 * }
 * </pre>
 *
 * Usen AFTER_SUCCESS: así el observador solo corre si la alerta sí se guardó
 * (y ya tiene idAlerta), y un error al mandar el correo no deshace la ingesta.
 * Para no frenar al agente, el envío conviene hacerlo con &#64;Asynchronous.
 *
 * @author kyriux
 */
public record AlertaGenerada(Alerta alerta) {

    public boolean esCritica() {
        return IngestaBean.GRAVEDAD_CRITICA.equals(alerta.getNivelGravedad());
    }
}
