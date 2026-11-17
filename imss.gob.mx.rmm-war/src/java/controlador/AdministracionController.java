package controlador;

import jakarta.annotation.PostConstruct;
import jakarta.ejb.EJB;
import jakarta.faces.view.ViewScoped;
import jakarta.inject.Named;
import java.io.Serializable;
import java.util.List;
import excepciones.Excepciones;
import logica_negocio.AdministracionBean;
import modelo.Rol;
import modelo.Usuario;

/**
 * Controlador de la pantalla Administración → Usuarios (PR-18).
 * Es adminCtrl en el diagrama SD-07a (rama usuarioNuevo == true).
 *
 * validarCampos() del diagrama lo hacen los validadores del paquete
 * "validadores" que usa usuarios.xhtml; aquí sólo se llama a
 * AdministracionBean y se muestra el resultado.
 *
 * @author kyriux
 */
@Named("adminCtrl")
@ViewScoped
public class AdministracionController implements Serializable {

    private static final long serialVersionUID = 1L;

    @EJB
    private AdministracionBean administracionBean;

    // Datos del formulario "Nuevo usuario"
    private Usuario nuevo;
    private Integer idRol;
    private transient String contrasena;

    // Datos de la pantalla
    private List<Rol> roles;
    private List<Usuario> usuarios;

    @PostConstruct
    public void init() {
        roles = administracionBean.listarRoles();
        usuarios = administracionBean.listarUsuarios();
        limpiarFormulario();
    }

    /** guardarUsuario(datos, idRol) **/
    public void guardarUsuario() {
        try {
            Usuario registrado = administracionBean.guardarUsuario(nuevo, idRol, contrasena);

            // mostrarConfirmacion()
            Mensajes.info("Usuario registrado",
                    registrado.getNombre() + " (" + registrado.getMatricula() + ") ya puede iniciar sesión.");
            usuarios = administracionBean.listarUsuarios();
            limpiarFormulario();

        } catch (Excepciones e) {
            // Respaldo del EJB (por ejemplo, otra persona registró la misma matrícula al mismo tiempo)
            Mensajes.error("formUsuarios", e, "No se pudo registrar el usuario");
        } finally {
            contrasena = null;
        }
    }

    /** Botón "Limpiar": descarta lo capturado. */
    public void cancelar() {
        limpiarFormulario();
    }

    private void limpiarFormulario() {
        nuevo = new Usuario();
        idRol = null;
        contrasena = null;
    }

    // Getters y setters

    public Usuario getNuevo() {
        return nuevo;
    }

    public Integer getIdRol() {
        return idRol;
    }

    public void setIdRol(Integer idRol) {
        this.idRol = idRol;
    }

    public String getContrasena() {
        return contrasena;
    }

    public void setContrasena(String contrasena) {
        this.contrasena = contrasena;
    }

    public List<Rol> getRoles() {
        return roles;
    }

    public List<Usuario> getUsuarios() {
        return usuarios;
    }
}
