package controlador;

import jakarta.annotation.PostConstruct;
import jakarta.ejb.EJB;
import jakarta.faces.view.ViewScoped;
import jakarta.inject.Inject;
import jakarta.inject.Named;
import java.io.Serializable;
import java.util.List;
import excepciones.Excepciones;
import logica_negocio.AdministracionBean;
import modelo.Rol;
import modelo.Usuario;

/**
 * Controlador de la pantalla Administración → Usuarios (PR-18).
 * Es adminCtrl en el diagrama SD-07a:
 *   - usuario nuevo:      guardarUsuario → crear(...) → asignarRol(rol)
 *   - usuario existente:  editar(u) carga el formulario y guardarUsuario
 *                         → editarDatos(datos) → asignarRol(rol)
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

    @Inject
    private AuthController authCtrl;

    // Datos del formulario (nuevo usuario o el que se edita)
    private Usuario nuevo;
    private Integer idRol;
    private transient String contrasena;
    /** null: alta de usuario; con valor: id del usuario que se edita. */
    private Integer idEditando;

    /** El formulario sólo se ve al dar "Nuevo usuario" o "Editar". */
    private boolean formularioVisible;

    // Filtros de la tabla (se aplican solos)
    private String texto;
    private Integer idRolFiltro;
    private String estadoFiltro;   // null = todos, "ACTIVO" o "INACTIVO"

    // Datos de la pantalla
    private List<Rol> roles;
    private List<Usuario> todos;
    private List<Usuario> usuarios;

    @PostConstruct
    public void init() {
        roles = administracionBean.listarRoles();
        recargarLista();
        limpiarFormulario();
    }

    /** SD-07a guardarUsuario(datos, idRol): alta o edición según idEditando. */
    public void guardarUsuario() {
        try {
            if (idEditando == null) {
                Usuario registrado = administracionBean.guardarUsuario(nuevo, idRol, contrasena);
                // mostrarConfirmacion()
                Mensajes.info("Usuario registrado",
                        registrado.getNombre() + " (" + registrado.getMatricula() + ") ya puede iniciar sesión.");
            } else {
                Integer actual = authCtrl.getUsuario() == null ? null : authCtrl.getUsuario().getIdUsuario();
                Usuario editado = administracionBean.editarUsuario(idEditando, nuevo, idRol, contrasena, actual);
                Mensajes.info("Usuario actualizado",
                        editado.getNombre() + " (" + editado.getMatricula() + ")"
                        + (editado.getEstaActivo() ? "" : " quedó inactivo y ya no podrá iniciar sesión") + ".");
                if (idEditando.equals(actual)) {
                    authCtrl.recargar();   // actualiza nombre y rol del menú lateral
                }
            }
            recargarLista();
            limpiarFormulario();
        } catch (Excepciones e) {
            // Respaldo del EJB (por ejemplo, otra persona registró la misma matrícula al mismo tiempo)
            Mensajes.error("formUsuarios", e, "No se pudo guardar el usuario");
        } finally {
            contrasena = null;
        }
    }

    /** Botón "Editar" de la tabla (PR-18): carga el usuario en el formulario. */
    public void editar(Usuario u) {
        Usuario actual = administracionBean.buscarUsuario(u.getIdUsuario());
        if (actual == null) {
            Mensajes.error("Usuario no encontrado", "El usuario ya no existe; se recargó la lista.");
            recargarLista();
            return;
        }
        idEditando = actual.getIdUsuario();
        formularioVisible = true;
        // Copia para no modificar la fila de la tabla mientras se edita
        nuevo = new Usuario();
        nuevo.setMatricula(actual.getMatricula());
        nuevo.setNombre(actual.getNombre());
        nuevo.setCorreo(actual.getCorreo());
        nuevo.setEstaActivo(actual.getEstaActivo());
        idRol = actual.getIdRol() == null ? null : actual.getIdRol().getIdRol();
        contrasena = null;
    }

    /** Botón "Nuevo usuario": muestra el formulario vacío. */
    public void nuevoUsuario() {
        limpiarFormulario();
        formularioVisible = true;
    }

    public void cancelar() {
        limpiarFormulario();
    }

    // ------------------------------------------------------------------
    // Filtros de la tabla
    // ------------------------------------------------------------------

    public void filtrar() {
        String t = texto == null || texto.isBlank() ? null : texto.trim().toLowerCase();
        usuarios = todos.stream()
                .filter(u -> t == null
                        || contiene(u.getNombre(), t) || contiene(u.getMatricula(), t) || contiene(u.getCorreo(), t))
                .filter(u -> idRolFiltro == null
                        || (u.getIdRol() != null && idRolFiltro.equals(u.getIdRol().getIdRol())))
                .filter(u -> estadoFiltro == null || ("ACTIVO".equals(estadoFiltro) == u.getEstaActivo()))
                .collect(java.util.stream.Collectors.toList());
    }

    public void limpiarFiltros() {
        texto = null;
        idRolFiltro = null;
        estadoFiltro = null;
        filtrar();
    }

    public boolean isHayFiltros() {
        return (texto != null && !texto.isBlank()) || idRolFiltro != null || estadoFiltro != null;
    }

    private static boolean contiene(String valor, String t) {
        return valor != null && valor.toLowerCase().contains(t);
    }

    private void recargarLista() {
        todos = administracionBean.listarUsuarios();
        filtrar();
    }

    private void limpiarFormulario() {
        formularioVisible = false;
        nuevo = new Usuario();
        nuevo.setEstaActivo(true);
        idRol = null;
        contrasena = null;
        idEditando = null;
    }

    public boolean isEditando() {
        return idEditando != null;
    }

    /** true si el usuario que se edita es el que tiene la sesión abierta. */
    public boolean isEditandoseASiMismo() {
        return idEditando != null && authCtrl.getUsuario() != null
                && idEditando.equals(authCtrl.getUsuario().getIdUsuario());
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

    public boolean isFormularioVisible() {
        return formularioVisible;
    }

    public String getTexto() {
        return texto;
    }

    public void setTexto(String texto) {
        this.texto = texto;
    }

    public Integer getIdRolFiltro() {
        return idRolFiltro;
    }

    public void setIdRolFiltro(Integer idRolFiltro) {
        this.idRolFiltro = idRolFiltro;
    }

    public String getEstadoFiltro() {
        return estadoFiltro;
    }

    public void setEstadoFiltro(String estadoFiltro) {
        this.estadoFiltro = estadoFiltro == null || estadoFiltro.isBlank() ? null : estadoFiltro;
    }

    public Integer getIdEditando() {
        return idEditando;
    }

    public List<Rol> getRoles() {
        return roles;
    }

    public List<Usuario> getUsuarios() {
        return usuarios;
    }
}
