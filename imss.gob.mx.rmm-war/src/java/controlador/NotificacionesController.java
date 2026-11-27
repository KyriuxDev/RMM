package controlador;

import jakarta.annotation.PostConstruct;
import jakarta.ejb.EJB;
import jakarta.faces.view.ViewScoped;
import jakarta.inject.Named;
import java.io.Serializable;
import java.util.Collections;
import java.util.Date;
import java.util.List;
import logica_negocio.NotificacionBean;
import logica_negocio.NotificacionBean.FilaNotificacion;

/**
 * Alertas → Notificaciones (HU-15, Figura "07 · Notificaciones por correo").
 * Lista los correos que el sistema mandó por alertas críticas y su estado
 * (Enviado, Reintentando (2 de 3), Fallido). Se actualiza sola cada 30 s.
 *
 * @author jose
 */
@Named("notificacionesCtrl")
@ViewScoped
public class NotificacionesController implements Serializable {

    private static final long serialVersionUID = 1L;

    @EJB
    private NotificacionBean notificacionBean;

    private List<FilaNotificacion> filas = Collections.emptyList();
    private Date actualizado;

    @PostConstruct
    public void init() {
        consultar();
    }

    public void consultar() {
        filas = notificacionBean.recientes();
        actualizado = new Date();
    }

    /** Color del estado del envío. */
    public String claseEstado(FilaNotificacion f) {
        String e = f.getEstado();
        if ("Enviado".equals(e)) {
            return "estado-activo";
        }
        if ("Fallido".equals(e)) {
            return "estado-inactivo";
        }
        return "estado-alerta";
    }

    public List<FilaNotificacion> getFilas() {
        return filas;
    }

    public Date getActualizado() {
        return actualizado;
    }
}
