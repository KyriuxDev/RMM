package validadores;

import jakarta.ejb.EJB;
import jakarta.enterprise.context.Dependent;
import jakarta.faces.component.UIComponent;
import jakarta.faces.validator.FacesValidator;
import logica_negocio.InventarioBean;

/**
 * Revisa al salir del campo que el hostname no esté registrado
 * (usa InventarioBean.verificarHostnameDisponible).
 *
 * @author kyriux
 */
@Dependent
@FacesValidator(value = "hostnameDisponibleValidator", managed = true)
public class HostnameDisponibleValidator extends ValidadorTexto {

    @EJB
    private InventarioBean inventarioBean;

    @Override
    protected void validar(String texto, UIComponent component) {
        if (HostnameValidator.PATRON.matcher(texto).matches()) {
            inventarioBean.verificarHostnameDisponible(texto);
        }
    }
}
