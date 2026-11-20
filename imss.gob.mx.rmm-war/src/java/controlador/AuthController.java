package controlador;

import jakarta.ejb.EJB;
import jakarta.enterprise.context.SessionScoped;
import jakarta.faces.context.ExternalContext;
import jakarta.faces.context.FacesContext;
import jakarta.inject.Named;
import jakarta.servlet.http.HttpServletRequest;
import java.io.Serializable;
import logica_negocio.AutenticacionBean;
import logica_negocio.Permiso;
import logica_negocio.ResultadoLogin;
import logica_negocio.UsuarioSesion;

/**
 * Sesión del usuario (SD-00a Iniciar sesión y SD-00b Cerrar sesión).
 *
 * Es la línea de vida "authCtrl" de los diagramas del lado de la vista:
 *   - login.xhtml llama iniciarSesion(); el EJB AutenticacionBean valida las
 *     credenciales y aquí se crea la sesión (crearSesion) y se manda al inicio.
 *   - El menú lateral (sidebar.xhtml) pregunta tienePermiso(...) para mostrar
 *     sólo las secciones del rol (construirMenuLateral(listaPermisos)).
 *   - pie.xhtml llama cerrarSesion() (invalidarSesion → redirigirALogin).
 *
 * El usuario también se guarda en la sesión HTTP (ATRIBUTO_SESION) para que
 * filtro.FiltroAcceso pueda revisar cada página sin depender de CDI.
 *
 * @author kyriux
 */
@Named("authCtrl")
@SessionScoped
public class AuthController implements Serializable {

    private static final long serialVersionUID = 1L;

    /** Nombre del atributo de la sesión HTTP con el UsuarioSesion. */
    public static final String ATRIBUTO_SESION = "usuarioSesion";

    public static final String LOGIN = "/vista/acceso/login.xhtml";
    public static final String ACCESO_DENEGADO = "/vista/acceso/acceso-denegado.xhtml";
    public static final String SESION_EXPIRADA = "/vista/acceso/sesion-expirada.xhtml";

    @EJB
    private AutenticacionBean autenticacionBean;

    // Formulario del login
    private String identificador;
    private transient String contrasena;

    // Usuario que inició sesión
    private UsuarioSesion usuario;

    /** SD-00a iniciarSesion(cred). */
    public String iniciarSesion() {
        ResultadoLogin resultado;
        try {
            resultado = autenticacionBean.iniciarSesion(identificador, contrasena);
        } finally {
            contrasena = null;
        }
        if (!resultado.isExito()) {
            // mostrarError(mensaje)
            Mensajes.error(resultado.getMensaje(), resultado.getMensaje());
            return null;
        }
        // crearSesion(usr, listaPermisos): nuevo id de sesión para evitar fijación de sesión
        ExternalContext ec = FacesContext.getCurrentInstance().getExternalContext();
        ((HttpServletRequest) ec.getRequest()).changeSessionId();
        usuario = resultado.getUsuario();
        ec.getSessionMap().put(ATRIBUTO_SESION, usuario);
        identificador = null;
        // mostrarInicio()
        return inicio();
    }

    /** SD-00b cerrarSesion(idSesion) → invalidarSesion → redirigirALogin. */
    public String cerrarSesion() {
        usuario = null;
        FacesContext.getCurrentInstance().getExternalContext().invalidateSession();
        return LOGIN + "?faces-redirect=true&cerrada=true";
    }

    /** Primera sección que puede ver el usuario ("Volver al inicio"). */
    public String inicio() {
        return getPaginaInicio() + "?faces-redirect=true";
    }

    /** Vista de inicio sin parámetros (para h:link del logo RMM). */
    public String getPaginaInicio() {
        if (usuario == null) {
            return LOGIN;
        }
        String pagina = usuario.paginaInicio();
        return pagina == null ? ACCESO_DENEGADO : pagina;
    }

    /** f:viewAction del login: si ya hay sesión, no vuelve a pedir credenciales. */
    public String redirigirSiAutenticado() {
        return usuario == null ? null : inicio();
    }

    /** Vuelve a leer nombre, rol y permisos (por ejemplo, después de editarse a sí mismo). */
    public void recargar() {
        if (usuario == null) {
            return;
        }
        UsuarioSesion nuevo = autenticacionBean.recargarSesion(usuario.getIdUsuario());
        if (nuevo != null) {
            usuario = nuevo;
            FacesContext.getCurrentInstance().getExternalContext().getSessionMap().put(ATRIBUTO_SESION, usuario);
        }
    }

    public boolean tienePermiso(String codigo) {
        return usuario != null && usuario.tienePermiso(codigo);
    }

    public boolean isAutenticado() {
        return usuario != null;
    }

    public boolean isTieneInicio() {
        return usuario != null && usuario.paginaInicio() != null;
    }

    /** Nombre del módulo para el aviso de acceso denegado (PR-19 MensajeRol). */
    public String nombreModulo(String codigo) {
        for (Permiso p : Permiso.values()) {
            if (p.name().equals(codigo)) {
                return p.getModulo();
            }
        }
        return null;
    }

    // Getters y setters

    public String getIdentificador() {
        return identificador;
    }

    public void setIdentificador(String identificador) {
        this.identificador = identificador;
    }

    public String getContrasena() {
        return contrasena;
    }

    public void setContrasena(String contrasena) {
        this.contrasena = contrasena;
    }

    public UsuarioSesion getUsuario() {
        return usuario;
    }
}
