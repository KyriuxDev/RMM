package controlador;

import excepciones.Excepciones;
import jakarta.annotation.PostConstruct;
import jakarta.ejb.EJB;
import jakarta.faces.view.ViewScoped;
import jakarta.inject.Inject;
import jakarta.inject.Named;
import java.io.Serializable;
import java.util.Collections;
import java.util.List;
import logica_negocio.NotificacionBean;
import logica_negocio.Permiso;
import modelo.Usuario;

/**
 * Administración → Correo y conectores (HU-15).
 * Muestra si GlassFish ya tiene el recurso de correo, quién recibe las alertas
 * críticas y permite mandarse un correo de prueba.
 *
 * @author jose
 */
@Named("correoCtrl")
@ViewScoped
public class CorreoController implements Serializable {

    private static final long serialVersionUID = 1L;

    @EJB
    private NotificacionBean notificacionBean;

    @Inject
    private AuthController authCtrl;

    private boolean configurado;
    private List<Usuario> destinatarios = Collections.emptyList();
    private List<Usuario> jefatura = Collections.emptyList();

    @PostConstruct
    public void init() {
        recargar();
    }

    public void recargar() {
        configurado = notificacionBean.correoConfigurado();
        destinatarios = notificacionBean.destinatarios(Permiso.GESTIONAR_ALERTAS.name());
        jefatura = notificacionBean.destinatarios(Permiso.ADMINISTRAR.name());
    }

    public void probar() {
        try {
            Integer yo = authCtrl.getUsuario() == null ? null : authCtrl.getUsuario().getIdUsuario();
            notificacionBean.enviarPrueba(yo);
            Mensajes.info("Correo de prueba enviado", "Revise la bandeja de su correo registrado.");
        } catch (Excepciones e) {
            Mensajes.error("No se pudo enviar el correo de prueba", e.getMessage());
        }
        recargar();
    }

    public boolean isConfigurado() {
        return configurado;
    }

    public String getRecursoJndi() {
        return NotificacionBean.JNDI_CORREO;
    }

    public int getIntentos() {
        return NotificacionBean.MAX_INTENTOS;
    }

    public List<Usuario> getDestinatarios() {
        return destinatarios;
    }

    public List<Usuario> getJefatura() {
        return jefatura;
    }
}
