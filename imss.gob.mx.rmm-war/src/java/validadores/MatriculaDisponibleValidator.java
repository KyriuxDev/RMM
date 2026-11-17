package validadores;

import jakarta.ejb.EJB;
import jakarta.enterprise.context.Dependent;
import jakarta.faces.component.UIComponent;
import jakarta.faces.validator.FacesValidator;
import logica_negocio.AdministracionBean;

/**
 * Revisa al salir del campo que la matrícula no esté registrada
 * (usa AdministracionBean.verificarMatriculaDisponible).
 * Va después de matriculaValidator.
 *
 * managed = true + @Dependent: el validador es un bean CDI (por eso se le puede
 * inyectar el EJB). Sin @Dependent, CDI no lo registra en modo "annotated".
 *
 * @author kyriux
 */
@Dependent
@FacesValidator(value = "matriculaDisponibleValidator", managed = true)
public class MatriculaDisponibleValidator extends ValidadorTexto {

    @EJB
    private AdministracionBean administracionBean;

    @Override
    protected void validar(String texto, UIComponent component) {
        if (MatriculaValidator.PATRON.matcher(texto).matches()) {
            administracionBean.verificarMatriculaDisponible(texto);
        }
    }
}
