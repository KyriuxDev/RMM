package excepciones;

import jakarta.ejb.ApplicationException;

/**
 * Excepción que lanza la lógica de negocio cuando una regla no se cumple
 * (por ejemplo, matrícula o correo ya registrados).
 *
 * Se marca como @ApplicationException para que llegue tal cual al controlador
 * (sin envolverse en EJBException) y para que la transacción se deshaga.
 *
 * @author kyriux
 */
@ApplicationException(rollback = true)
public class Excepciones extends RuntimeException {

    private static final long serialVersionUID = 1L;

    /** Campo del formulario relacionado con el error (puede ser null). */
    private final String campo;

    public Excepciones(String mensaje) {
        this(null, mensaje);
    }

    public Excepciones(String campo, String mensaje) {
        super(mensaje);
        this.campo = campo;
    }

    public String getCampo() {
        return campo;
    }
}
