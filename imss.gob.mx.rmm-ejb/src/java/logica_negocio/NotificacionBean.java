package logica_negocio;

import acceso_datos.GestionAlertasFacade;
import acceso_datos.UsuarioFacade;
import excepciones.Excepciones;
import jakarta.annotation.Resource;
import jakarta.ejb.Asynchronous;
import jakarta.ejb.EJB;
import jakarta.ejb.LocalBean;
import jakarta.ejb.SessionContext;
import jakarta.ejb.Stateless;
import jakarta.ejb.TransactionAttribute;
import jakarta.ejb.TransactionAttributeType;
import jakarta.enterprise.event.Observes;
import jakarta.enterprise.event.TransactionPhase;
import jakarta.mail.Message;
import jakarta.mail.Session;
import jakarta.mail.Transport;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;
import java.io.Serializable;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Date;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.TimeZone;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.naming.InitialContext;
import javax.naming.NamingException;
import modelo.Alerta;
import modelo.Notificacion;
import modelo.Usuario;

/**
 * Correo de alertas críticas (HU-15) y pantalla de Notificaciones.
 *
 *   - Escucha el evento AlertaGenerada con AFTER_SUCCESS (IngestaBean no se toca):
 *     solo corre si la alerta sí se guardó y un error de correo no deshace la ingesta.
 *   - El envío es asíncrono para no frenar al agente. Cada destinatario queda en
 *     la tabla notificacion; si falla, se reintenta hasta MAX_INTENTOS veces.
 *   - Destinatarios de una alerta crítica: usuarios activos con permiso GESTIONAR_ALERTAS.
 *     "Escalar" manda a los usuarios activos con permiso ADMINISTRAR (jefatura).
 *   - El servidor SMTP NO está en el repo: es el recurso JavaMail "mail/rmm" de GlassFish
 *     (ver configurar-correo-glassfish.md).
 *
 * @author jose
 */
@Stateless
@LocalBean
public class NotificacionBean {

    private static final Logger LOG = Logger.getLogger(NotificacionBean.class.getName());

    /** Nombre JNDI de la sesión de correo creada en GlassFish. */
    public static final String JNDI_CORREO = "mail/rmm";

    public static final int MAX_INTENTOS = 3;

    static final String ENVIANDO = "Enviando";
    static final String ENVIADO = "Enviado";
    static final String FALLIDO = "Fallido";

    @EJB
    private GestionAlertasFacade facade;

    @EJB
    private UsuarioFacade usuarioFacade;

    @Resource
    private SessionContext contexto;

    /** Segundos entre reintentos (se puede cambiar con -Drmm.correo.reintentoSeg en GlassFish). */
    private static int reintentoSeg() {
        return Integer.getInteger("rmm.correo.reintentoSeg", 60);
    }

    // ------------------------------------------------------------------
    // HU-15: observador del evento
    // ------------------------------------------------------------------

    /** Solo las alertas críticas mandan correo. */
    public void alGenerarse(@Observes(during = TransactionPhase.AFTER_SUCCESS) AlertaGenerada evento) {
        try {
            if (evento == null || !evento.esCritica() || evento.alerta().getIdAlerta() == null) {
                return;
            }
            contexto.getBusinessObject(NotificacionBean.class)
                    .enviarAsync(evento.alerta().getIdAlerta(), Permiso.GESTIONAR_ALERTAS.name(), "Alerta crítica");
        } catch (RuntimeException e) {
            LOG.log(Level.WARNING, "No se pudo programar el correo de la alerta", e);
        }
    }

    /** "Escalar" (Alertas activas): correo a la jefatura. Regresa a cuántas personas se les avisará. */
    public int escalar(Integer idAlerta, Integer idSolicitante) {
        Alerta a = facade.alertaConEquipo(idAlerta);
        if (a == null) {
            throw new Excepciones("alerta.noExiste", "La alerta ya no existe.");
        }
        if (!IngestaBean.ESTADO_ALERTA_ACTIVA.equalsIgnoreCase(a.getEstado())) {
            throw new Excepciones("alerta.estado", "La alerta ya no está activa.");
        }
        List<Usuario> dest = destinatarios(Permiso.ADMINISTRAR.name());
        if (dest.isEmpty()) {
            throw new Excepciones("alerta.sinDestinatarios",
                    "No hay usuarios activos con permiso de Administración y correo registrado.");
        }
        contexto.getBusinessObject(NotificacionBean.class)
                .enviarAsync(idAlerta, Permiso.ADMINISTRAR.name(), "Alerta escalada");
        return dest.size();
    }

    // ------------------------------------------------------------------
    // Envío
    // ------------------------------------------------------------------

    @Asynchronous
    @TransactionAttribute(TransactionAttributeType.NOT_SUPPORTED)
    public void enviarAsync(Integer idAlerta, String permiso, String encabezado) {
        try {
            enviar(idAlerta, permiso, encabezado);
        } catch (RuntimeException e) {
            LOG.log(Level.WARNING, "No se pudo enviar el correo de la alerta " + idAlerta, e);
        }
    }

    private void enviar(Integer idAlerta, String permiso, String encabezado) {
        Alerta a = facade.alertaConEquipo(idAlerta);
        if (a == null) {
            return;
        }
        List<Usuario> dest = destinatarios(permiso);
        if (dest.isEmpty()) {
            LOG.log(Level.WARNING, "La alerta {0} no tiene destinatarios con permiso {1}",
                    new Object[] {idAlerta, permiso});
            return;
        }
        String asunto = "[RMM] " + encabezado + ": " + a.getIdEquipo().getHostname();
        String cuerpo = cuerpo(a, encabezado);

        // idNotificacion → destinatario; salen de aquí cuando se envían
        Map<Integer, Usuario> pendientes = new LinkedHashMap<>();
        for (Usuario u : dest) {
            pendientes.put(facade.crearNotificacion(idAlerta, u.getIdUsuario(), ENVIANDO), u);
        }

        for (int intento = 1; intento <= MAX_INTENTOS && !pendientes.isEmpty(); intento++) {
            Iterator<Map.Entry<Integer, Usuario>> it = pendientes.entrySet().iterator();
            while (it.hasNext()) {
                Map.Entry<Integer, Usuario> p = it.next();
                try {
                    enviarCorreo(p.getValue().getCorreo(), asunto, cuerpo);
                    facade.actualizarEnvio(p.getKey(), ENVIADO);
                    it.remove();
                } catch (Exception e) {
                    LOG.log(Level.WARNING, "Falló el correo a " + p.getValue().getCorreo()
                            + " (intento " + intento + " de " + MAX_INTENTOS + "): " + e.getMessage());
                    facade.actualizarEnvio(p.getKey(), intento < MAX_INTENTOS
                            ? "Reintentando (" + (intento + 1) + " de " + MAX_INTENTOS + ")" : FALLIDO);
                }
            }
            if (!pendientes.isEmpty() && intento < MAX_INTENTOS) {
                try {
                    Thread.sleep(reintentoSeg() * 1000L);
                } catch (InterruptedException ie) {
                    Thread.currentThread().interrupt();
                    return;
                }
            }
        }
    }

    private static String cuerpo(Alerta a, String encabezado) {
        SimpleDateFormat f = new SimpleDateFormat("dd/MM/yyyy HH:mm");
        f.setTimeZone(TimeZone.getTimeZone("America/Mexico_City"));
        return encabezado + " en el equipo " + a.getIdEquipo().getHostname() + "\n\n"
                + (a.getDescripcion() == null ? "" : a.getDescripcion() + "\n")
                + "Tipo: " + a.getTipoAlerta() + "\n"
                + "Gravedad: " + a.getNivelGravedad() + "\n"
                + "Generada: " + (a.getFechaGeneracion() == null ? "—" : f.format(a.getFechaGeneracion())) + "\n\n"
                + "Revise la sección Alertas activas del sistema RMM.\n";
    }

    /** Manda un correo con la sesión "mail/rmm" de GlassFish. */
    private void enviarCorreo(String para, String asunto, String texto) throws Exception {
        Session sesion = (Session) new InitialContext().lookup(JNDI_CORREO);
        MimeMessage m = new MimeMessage(sesion);
        m.setFrom();   // toma mail.from de la sesión (Default Sender Address en GlassFish)
        m.setRecipients(Message.RecipientType.TO, InternetAddress.parse(para, false));
        m.setSubject(asunto, "UTF-8");
        m.setText(texto, "UTF-8");
        m.setSentDate(new Date());
        Transport.send(m);
    }

    // ------------------------------------------------------------------
    // Destinatarios y configuración (Administración → Correo y conectores)
    // ------------------------------------------------------------------

    /** Usuarios activos, con correo, cuyo rol tiene el permiso. */
    public List<Usuario> destinatarios(String permiso) {
        List<Usuario> r = new ArrayList<>();
        for (Usuario u : facade.usuariosActivos()) {
            if (u.getIdRol() != null && u.getIdRol().obtenerPermisos().contains(permiso)
                    && u.getCorreo() != null && !u.getCorreo().isBlank()) {
                r.add(u);
            }
        }
        return r;
    }

    /** ¿Existe el recurso JavaMail "mail/rmm" en GlassFish? */
    public boolean correoConfigurado() {
        try {
            return new InitialContext().lookup(JNDI_CORREO) instanceof Session;
        } catch (NamingException | RuntimeException e) {
            return false;
        }
    }

    /** Correo de prueba al usuario que lo pide (para comprobar la configuración de GlassFish). */
    public void enviarPrueba(Integer idUsuario) {
        Usuario u = idUsuario == null ? null : usuarioFacade.find(idUsuario);
        if (u == null || u.getCorreo() == null || u.getCorreo().isBlank()) {
            throw new Excepciones("correo.destino", "Su usuario no tiene un correo registrado.");
        }
        if (!correoConfigurado()) {
            throw new Excepciones("correo.config",
                    "No existe el recurso de correo " + JNDI_CORREO + " en GlassFish. "
                    + "Revise configurar-correo-glassfish.md.");
        }
        try {
            enviarCorreo(u.getCorreo(), "[RMM] Correo de prueba",
                    "Si recibe este mensaje, el envío de alertas por correo funciona.\n");
        } catch (Exception e) {
            Throwable causa = e.getCause() != null ? e.getCause() : e;
            throw new Excepciones("correo.envio", "No se pudo enviar el correo: " + causa.getMessage());
        }
    }

    // ------------------------------------------------------------------
    // Notificaciones por correo (pantalla)
    // ------------------------------------------------------------------

    /** Una renglón por alerta: a quiénes se les mandó y cómo va el envío. */
    public List<FilaNotificacion> recientes() {
        Map<Integer, Grupo> grupos = new LinkedHashMap<>();
        for (Notificacion n : facade.recientes(300)) {
            Alerta a = n.getIdAlerta();
            Grupo g = grupos.computeIfAbsent(a.getIdAlerta(), k -> new Grupo(a));
            g.destinatarios.add(n.getIdUsuario().getNombre());
            g.estados.add(n.getEstadoEnvio());
            if (n.getFechaEnvio() != null && (g.fecha == null || n.getFechaEnvio().after(g.fecha))) {
                g.fecha = n.getFechaEnvio();
            }
        }
        List<FilaNotificacion> r = new ArrayList<>();
        for (Grupo g : grupos.values()) {
            r.add(new FilaNotificacion(g.fecha, g.alerta, String.join(", ", g.destinatarios), resumen(g.estados)));
        }
        return r;
    }

    /**
     * Estado del envío de una alerta a partir del de cada destinatario:
     * Enviado, Reintentando (n de 3), Enviando, Parcial, Fallido.
     */
    public static String resumen(Collection<String> estados) {
        boolean enviado = false;
        boolean enviando = false;
        boolean fallido = false;
        String reintento = null;
        for (String s : estados) {
            if (s == null) {
                continue;
            }
            if (s.startsWith("Reintentando")) {
                if (reintento == null) {
                    reintento = s;
                }
            } else if (ENVIANDO.equals(s)) {
                enviando = true;
            } else if (ENVIADO.equals(s)) {
                enviado = true;
            } else {
                fallido = true;
            }
        }
        if (reintento != null) {
            return reintento;
        }
        if (enviando) {
            return ENVIANDO;
        }
        if (enviado && fallido) {
            return "Parcial";
        }
        if (fallido) {
            return FALLIDO;
        }
        return enviado ? ENVIADO : "—";
    }

    private static final class Grupo {

        final Alerta alerta;
        final Set<String> destinatarios = new LinkedHashSet<>();
        final List<String> estados = new ArrayList<>();
        Date fecha;

        Grupo(Alerta alerta) {
            this.alerta = alerta;
        }
    }

    /** Renglón de la tabla "Notificaciones por correo". */
    public static final class FilaNotificacion implements Serializable {

        private static final long serialVersionUID = 1L;

        private final Date fecha;
        private final String alerta;
        private final String hostname;
        private final String destinatarios;
        private final String estado;

        FilaNotificacion(Date fecha, Alerta a, String destinatarios, String estado) {
            this.fecha = fecha;
            this.alerta = a.getDescripcion() == null || a.getDescripcion().isBlank()
                    ? a.getTipoAlerta() : a.getDescripcion();
            this.hostname = a.getIdEquipo() == null ? "—" : a.getIdEquipo().getHostname();
            this.destinatarios = destinatarios;
            this.estado = estado;
        }

        public Date getFecha() {
            return fecha;
        }

        public String getAlerta() {
            return alerta;
        }

        public String getHostname() {
            return hostname;
        }

        public String getDestinatarios() {
            return destinatarios;
        }

        public String getEstado() {
            return estado;
        }
    }
}
