package controlador;

import excepciones.Excepciones;
import jakarta.annotation.PostConstruct;
import jakarta.ejb.EJB;
import jakarta.faces.view.ViewScoped;
import jakarta.inject.Inject;
import jakarta.inject.Named;
import java.io.Serializable;
import java.util.Collections;
import java.util.Date;
import java.util.List;
import java.util.Locale;
import logica_negocio.AlertasBean;
import logica_negocio.AlertasBean.FilaAlerta;
import logica_negocio.NotificacionBean;

/**
 * Alertas → Alertas activas (HU-5, Figura "05 · Alertas activas").
 * Se actualiza sola cada 30 s (p:poll). "Atender" cierra la alerta y
 * "Escalar" manda correo a la jefatura (HU-15).
 *
 * @author jose
 */
@Named("alertasCtrl")
@ViewScoped
public class AlertasController implements Serializable {

    private static final long serialVersionUID = 1L;

    @EJB
    private AlertasBean alertasBean;

    @EJB
    private NotificacionBean notificacionBean;

    @Inject
    private AuthController authCtrl;

    /** SEVERIDAD o FECHA */
    private String orden = AlertasBean.ORDEN_SEVERIDAD;
    /** "" = todos; UsoAnomalo, Desconexion, RiesgoSeguridad */
    private String tipo = "";

    private List<FilaAlerta> filas = Collections.emptyList();
    private Date actualizado;

    @PostConstruct
    public void init() {
        consultar();
    }

    public void consultar() {
        filas = alertasBean.activas(tipo, orden);
        actualizado = new Date();
    }

    public void atender(FilaAlerta f) {
        try {
            alertasBean.atender(f.getIdAlerta());
            Mensajes.info("Alerta atendida", f.getHostname() + ": " + f.getDescripcion());
        } catch (Excepciones e) {
            Mensajes.error("No se pudo atender la alerta", e.getMessage());
        }
        consultar();
    }

    public void escalar(FilaAlerta f) {
        try {
            Integer yo = authCtrl.getUsuario() == null ? null : authCtrl.getUsuario().getIdUsuario();
            int n = notificacionBean.escalar(f.getIdAlerta(), yo);
            Mensajes.info("Alerta escalada",
                    "Se enviará un correo a " + n + (n == 1 ? " persona" : " personas") + " de la jefatura.");
        } catch (Excepciones e) {
            Mensajes.error("No se pudo escalar la alerta", e.getMessage());
        }
        consultar();
    }

    // ------------------------------------------------------------------
    // Formato
    // ------------------------------------------------------------------

    /** Texto de la pastilla de severidad (como en el diseño: Crítica / Media). */
    public String etiquetaGravedad(String gravedad) {
        if ("Critica".equalsIgnoreCase(gravedad)) {
            return "Crítica";
        }
        if ("Advertencia".equalsIgnoreCase(gravedad)) {
            return "Media";
        }
        return gravedad == null ? "—" : gravedad;
    }

    public String claseGravedad(String gravedad) {
        if ("Critica".equalsIgnoreCase(gravedad)) {
            return "al-sev-critica";
        }
        if ("Advertencia".equalsIgnoreCase(gravedad)) {
            return "al-sev-media";
        }
        return "al-sev-info";
    }

    public String etiquetaTipo(String t) {
        if ("UsoAnomalo".equals(t)) {
            return "Uso anómalo de recursos";
        }
        if ("Desconexion".equals(t)) {
            return "Desconexión";
        }
        if ("RiesgoSeguridad".equals(t)) {
            return "Riesgo de seguridad";
        }
        return t == null ? "—" : t;
    }

    /** Color del estado del correo de una fila. */
    public String claseCorreo(FilaAlerta f) {
        String c = f.getCorreo();
        if (c == null) {
            return "";
        }
        String s = c.toLowerCase(Locale.ROOT);
        if (s.equals("enviado")) {
            return "estado-activo";
        }
        if (s.equals("fallido")) {
            return "estado-inactivo";
        }
        return "estado-alerta";
    }

    // Getters y setters

    public String getOrden() {
        return orden;
    }

    public void setOrden(String orden) {
        this.orden = orden;
    }

    public String getTipo() {
        return tipo;
    }

    public void setTipo(String tipo) {
        this.tipo = tipo == null ? "" : tipo;
    }

    public List<FilaAlerta> getFilas() {
        return filas;
    }

    public Date getActualizado() {
        return actualizado;
    }
}
