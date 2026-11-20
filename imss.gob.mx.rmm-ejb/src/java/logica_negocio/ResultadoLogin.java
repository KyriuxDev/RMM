package logica_negocio;

import java.io.Serializable;

/**
 * Respuesta de AutenticacionBean.iniciarSesion (SD-00a "resultadoLogin").
 *
 * No se usa una excepción para los errores de inicio de sesión porque
 * excepciones.Excepciones hace rollback: se perdería el registro del intento
 * fallido y el bloqueo de la cuenta.
 *
 * @author kyriux
 */
public class ResultadoLogin implements Serializable {

    private static final long serialVersionUID = 1L;

    private final boolean exito;
    private final String mensaje;
    private final UsuarioSesion usuario;

    private ResultadoLogin(boolean exito, String mensaje, UsuarioSesion usuario) {
        this.exito = exito;
        this.mensaje = mensaje;
        this.usuario = usuario;
    }

    public static ResultadoLogin correcto(UsuarioSesion usuario) {
        return new ResultadoLogin(true, null, usuario);
    }

    public static ResultadoLogin error(String mensaje) {
        return new ResultadoLogin(false, mensaje, null);
    }

    public boolean isExito() {
        return exito;
    }

    public String getMensaje() {
        return mensaje;
    }

    public UsuarioSesion getUsuario() {
        return usuario;
    }
}
