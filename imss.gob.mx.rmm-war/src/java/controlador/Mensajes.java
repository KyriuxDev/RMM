package controlador;

import excepciones.Excepciones;
import jakarta.faces.application.FacesMessage;
import jakarta.faces.context.FacesContext;

/**
 * Mensajes que muestran los controladores en la página.
 *
 * @author kyriux
 */
final class Mensajes {

    private Mensajes() {
    }

    /** Mensaje de confirmación (verde) arriba del formulario. */
    static void info(String resumen, String detalle) {
        FacesContext.getCurrentInstance().addMessage(null,
                new FacesMessage(FacesMessage.SEVERITY_INFO, resumen, detalle));
    }

    /** Mensaje de error general (rojo) arriba del formulario. */
    static void error(String resumen, String detalle) {
        FacesContext ctx = FacesContext.getCurrentInstance();
        ctx.addMessage(null, new FacesMessage(FacesMessage.SEVERITY_ERROR, resumen, detalle));
        ctx.validationFailed();
    }

    /**
     * Error que llegó del EJB: marca en rojo el campo indicado en la
     * excepción (si lo trae) y muestra el mensaje general.
     *
     * @param idFormulario id del h:form, para armar el id del campo
     * @param resumen      título del mensaje general
     */
    static void error(String idFormulario, Excepciones e, String resumen) {
        FacesContext ctx = FacesContext.getCurrentInstance();
        if (e.getCampo() != null) {
            ctx.addMessage(idFormulario + ":" + e.getCampo(),
                    new FacesMessage(FacesMessage.SEVERITY_ERROR, e.getMessage(), e.getMessage()));
        }
        error(resumen, e.getMessage());
    }
}
