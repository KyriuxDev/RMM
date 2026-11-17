package validadores;

import jakarta.ejb.EJB;
import jakarta.enterprise.context.Dependent;
import jakarta.faces.component.UIComponent;
import jakarta.faces.validator.FacesValidator;
import logica_negocio.AdministracionBean;

/**
 * Revisa al salir del campo que el correo no esté registrado
 * (usa AdministracionBean.verificarCorreoDisponible).
 * Va después de correoInstitucionalValidator.
 *
 * @author kyriux
 */
@Dependent
@FacesValidator(value = "correoDisponibleValidator", managed = true)
public class CorreoDisponibleValidator extends ValidadorTexto {

    @EJB
    private AdministracionBean administracionBean;

    @Override
    protected void validar(String texto, UIComponent component) {
        if (CorreoInstitucionalValidator.PATRON.matcher(texto).matches()) {
            administracionBean.verificarCorreoDisponible(texto);
        }
    }
}
