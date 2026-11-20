package validadores;

import jakarta.ejb.EJB;
import jakarta.enterprise.context.Dependent;
import jakarta.faces.component.UIComponent;
import jakarta.faces.validator.FacesValidator;
import logica_negocio.InventarioBean;

/**
 * Revisa al salir del campo que la MAC no esté registrada en otro equipo
 * (usa InventarioBean.verificarMacDisponible). Es el "Aviso de MAC duplicada" de PR-14.
 *
 * @author kyriux
 */
@Dependent
@FacesValidator(value = "macDisponibleValidator", managed = true)
public class MacDisponibleValidator extends ValidadorTexto {

    @EJB
    private InventarioBean inventarioBean;

    @Override
    protected void validar(String texto, UIComponent component) {
        if (MacValidator.PATRON.matcher(texto).matches()) {
            inventarioBean.verificarMacDisponible(texto, idExcluir(component));
        }
    }
}
