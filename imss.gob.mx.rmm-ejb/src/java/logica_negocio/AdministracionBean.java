package logica_negocio;

import acceso_datos.RolFacade;
import acceso_datos.UsuarioFacade;
import excepciones.Excepciones;
import jakarta.annotation.PostConstruct;
import jakarta.ejb.EJB;
import jakarta.ejb.LocalBean;
import jakarta.ejb.Stateless;
import jakarta.inject.Inject;
import jakarta.security.enterprise.identitystore.Pbkdf2PasswordHash;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.Comparator;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import modelo.Rol;
import modelo.Usuario;

/**
 * Lógica de negocio de SD-07a Usuarios y roles: registro de usuarios y
 * edición de los permisos de cada rol.
 *
 * Las validaciones de formato (matrícula, correo, contraseña, etc.) las hace
 * la vista con los validadores del paquete "validadores" del WAR. Aquí sólo
 * queda una validación de respaldo: que lleguen los datos obligatorios y que
 * no se repitan matrícula ni correo (dos personas pueden guardar al mismo tiempo).
 *
 * @author kyriux
 */
@Stateless
@LocalBean
public class AdministracionBean {

    @EJB
    private UsuarioFacade usuarioFacade;

    @EJB
    private RolFacade rolFacade;

    /**
     * Implementación PBKDF2 incluida en Jakarta Security (GlassFish la provee).
     * Jakarta EE Tutorial, cap. "Using Jakarta Security": The PasswordHash
     * Interface (p. 848) y el ejemplo DatabaseSetup (pp. 851-852).
     */
    @Inject
    private Pbkdf2PasswordHash passwordHash;

    /**
     * Parámetros del hash.
     */
    @PostConstruct
    public void init() {
        passwordHash.initialize(Map.of(
                "Pbkdf2PasswordHash.Algorithm", "PBKDF2WithHmacSHA256",
                "Pbkdf2PasswordHash.Iterations", "600000",
                "Pbkdf2PasswordHash.SaltSizeBytes", "32",
                "Pbkdf2PasswordHash.KeySizeBytes", "32"));
    }

    // ------------------------------------------------------------------
    // Usuarios
    // ------------------------------------------------------------------

    /**
     * Registra un usuario nuevo con un rol y una contraseña temporal.
     *
     * @param usuario            matrícula, nombre y correo capturados
     * @param idRol              rol asignado
     * @param contrasenaTemporal contraseña inicial (se guarda sólo su hash)
     * @return el usuario registrado, con su id asignado
     */
    public Usuario guardarUsuario(Usuario usuario, Integer idRol, String contrasenaTemporal) {
        if (usuario == null) {
            throw new Excepciones("Los datos del usuario son obligatorios");
        }
        normalizar(usuario);

        // Respaldo: datos obligatorios
        Validacion.requerido(usuario.getMatricula(), "matricula", "La matrícula es obligatoria");
        Validacion.requerido(usuario.getNombre(), "nombre", "El nombre es obligatorio");
        Validacion.requerido(usuario.getCorreo(), "correo", "El correo es obligatorio");
        Validacion.requerido(idRol, "rol", "Seleccione el rol del usuario");
        Validacion.requerido(Validacion.limpiar(contrasenaTemporal), "contrasena", "La contraseña es obligatoria");

        // verificarMatriculaYCorreoDisponibles(matricula, correo)
        verificarMatriculaYCorreoDisponibles(usuario.getMatricula(), usuario.getCorreo(), null);

        // asignarRol(rol)
        Rol rol = rolFacade.find(idRol);
        if (rol == null) {
            throw new Excepciones("rol", "El rol seleccionado no existe");
        }
        usuario.setIdRol(rol);

        // crear(nombre, correo, ..., contraseñaTemporal)
        char[] caracteres = contrasenaTemporal.toCharArray();
        try {
            usuario.setContrasenaHash(passwordHash.generate(caracteres));
        } finally {
            Arrays.fill(caracteres, '\0');   // no dejar la contraseña en memoria
        }
        usuario.setEstaActivo(true);
        usuarioFacade.create(usuario);

        // resultado
        return usuario;
    }

    /**
     * Lanza un error si la matrícula ya pertenece a otro usuario.
     * También la usa la vista (validador MatriculaDisponibleValidator).
     */
    /** SD-07a verificarMatriculaYCorreoDisponibles(matricula, correo). */
    public void verificarMatriculaYCorreoDisponibles(String matricula, String correo, Integer idExcluir) {
        verificarMatriculaDisponible(matricula, idExcluir);
        verificarCorreoDisponible(correo, idExcluir);
    }

    public void verificarMatriculaDisponible(String matricula) {
        verificarMatriculaDisponible(matricula, null);
    }

    /** Igual que la anterior, pero sin contar al usuario idExcluir (el que se está editando). */
    public void verificarMatriculaDisponible(String matricula, Integer idExcluir) {
        String m = Validacion.limpiar(matricula);
        Usuario otro = m == null ? null : usuarioFacade.buscarPorMatricula(m);
        if (otro != null && !otro.getIdUsuario().equals(idExcluir)) {
            throw new Excepciones("matricula", "La matrícula " + m + " ya está registrada");
        }
    }

    /**
     * Lanza un error si el correo ya pertenece a otro usuario.
     * También la usa la vista (validador CorreoDisponibleValidator).
     */
    public void verificarCorreoDisponible(String correo) {
        verificarCorreoDisponible(correo, null);
    }

    /** Igual que la anterior, pero sin contar al usuario idExcluir (el que se está editando). */
    public void verificarCorreoDisponible(String correo, Integer idExcluir) {
        String c = Validacion.limpiar(correo);
        Usuario otro = c == null ? null : usuarioFacade.buscarPorCorreo(c.toLowerCase());
        if (otro != null && !otro.getIdUsuario().equals(idExcluir)) {
            throw new Excepciones("correo", "El correo " + c.toLowerCase() + " ya está registrado");
        }
    }

    // ------------------------------------------------------------------
    // Editar usuario (SD-07a, rama usuario existente: editarDatos + asignarRol)
    // ------------------------------------------------------------------

    public Usuario buscarUsuario(Integer idUsuario) {
        return idUsuario == null ? null : usuarioFacade.find(idUsuario);
    }

    /**
     * Guarda los cambios de un usuario.
     *
     * @param idUsuario      usuario que se edita
     * @param datos          matrícula, nombre, correo y estado capturados
     * @param idRol          rol nuevo
     * @param contrasenaNueva vacía o null para conservar la actual
     * @param idUsuarioActual quien hace el cambio (no puede desactivarse a sí mismo
     *                        ni quitarse el rol con Administración)
     */
    public Usuario editarUsuario(Integer idUsuario, Usuario datos, Integer idRol,
            String contrasenaNueva, Integer idUsuarioActual) {
        Usuario usr = buscarUsuario(idUsuario);
        if (usr == null) {
            throw new Excepciones("El usuario que intenta editar ya no existe");
        }
        if (datos == null) {
            throw new Excepciones("Los datos del usuario son obligatorios");
        }
        normalizar(datos);
        Validacion.requerido(datos.getMatricula(), "matricula", "La matrícula es obligatoria");
        Validacion.requerido(datos.getNombre(), "nombre", "El nombre es obligatorio");
        Validacion.requerido(datos.getCorreo(), "correo", "El correo es obligatorio");
        Validacion.requerido(idRol, "rol", "Seleccione el rol del usuario");

        // verificarMatriculaYCorreoDisponibles(matricula, correo), sin contar al propio usuario
        verificarMatriculaYCorreoDisponibles(datos.getMatricula(), datos.getCorreo(), idUsuario);

        Rol rol = rolFacade.find(idRol);
        if (rol == null) {
            throw new Excepciones("rol", "El rol seleccionado no existe");
        }
        boolean esElMismo = idUsuario.equals(idUsuarioActual);
        if (esElMismo && !datos.getEstaActivo()) {
            throw new Excepciones("estaActivo", "No puede desactivar su propia cuenta");
        }
        if (esElMismo && !rol.obtenerPermisos().contains(Permiso.ADMINISTRAR.name())) {
            throw new Excepciones("rol", "No puede quitarse a sí mismo el acceso a Administración");
        }

        // editarDatos(matricula, nombre, correo, estaActivo)
        usr.editarDatos(datos.getMatricula(), datos.getNombre(), datos.getCorreo(), datos.getEstaActivo());
        // asignarRol(rol)
        usr.asignarRol(rol);
        // Contraseña nueva (opcional)
        String c = Validacion.limpiar(contrasenaNueva);
        if (c != null) {
            char[] caracteres = contrasenaNueva.toCharArray();
            try {
                usr.setContrasenaHash(passwordHash.generate(caracteres));
            } finally {
                Arrays.fill(caracteres, '\0');
            }
            usr.reiniciarIntentos();   // una contraseña nueva también quita el bloqueo
        }
        usuarioFacade.edit(usr);
        return usr;
    }

    // ------------------------------------------------------------------
    // Roles y permisos (opt "el jefe edita permisos de un rol")
    // ------------------------------------------------------------------

    /**
     * Guarda los permisos de varios roles a la vez (botón "Guardar cambios
     * de permisos"). Para cada rol llama a actualizarPermisos(idRol, permisos).
     * Si alguno falla, la transacción se deshace completa.
     *
     * @param permisosPorRol idRol → códigos de Permiso marcados
     */
    public void actualizarPermisos(Map<Integer, ? extends Collection<String>> permisosPorRol) {
        Validacion.requerido(permisosPorRol, null, "No llegaron los permisos a guardar");
        for (Map.Entry<Integer, ? extends Collection<String>> e : permisosPorRol.entrySet()) {
            aplicarPermisos(e.getKey(), e.getValue());
        }
        // Se revisa al final: así se puede pasar Administración de un rol a otro en el mismo guardado
        verificarQueHayaAdministrador();
    }

    /**
     * actualizarPermisos(idRol, permisos) de SD-07a.
     *
     * Respaldo: el rol existe, los códigos son permisos conocidos, el rol
     * conserva al menos un permiso y algún rol conserva ADMINISTRAR (si no,
     * nadie podría volver a entrar a Administración).
     */
    public void actualizarPermisos(Integer idRol, Collection<String> permisos) {
        aplicarPermisos(idRol, permisos);
        verificarQueHayaAdministrador();
    }

    /** Valida y guarda los permisos de un rol (sin revisar el resto de los roles). */
    private void aplicarPermisos(Integer idRol, Collection<String> permisos) {
        Rol rol = idRol == null ? null : rolFacade.find(idRol);
        if (rol == null) {
            throw new Excepciones("El rol seleccionado no existe");
        }

        Set<String> codigos = new LinkedHashSet<>();
        if (permisos != null) {
            for (String p : permisos) {
                if (!Permiso.existe(p)) {
                    throw new Excepciones("El permiso " + p + " no existe");
                }
                codigos.add(p);
            }
        }
        if (codigos.isEmpty()) {
            throw new Excepciones("El rol " + rol.getNombre() + " debe tener al menos un permiso");
        }

        // actualizarPermisosRol(idRol, permisos)
        rol.actualizarPermisos(ordenar(codigos));
        rolFacade.edit(rol);
    }

    /** Lanza un error si ningún rol tiene el permiso ADMINISTRAR. */
    private void verificarQueHayaAdministrador() {
        boolean hayAdministrador = rolFacade.findAll().stream()
                .anyMatch(r -> permisosDe(r).contains(Permiso.ADMINISTRAR.name()));
        if (!hayAdministrador) {
            throw new Excepciones("Al menos un rol debe conservar el permiso de Administración");
        }
    }

    /** Códigos de permiso guardados en un rol. */
    public static Set<String> permisosDe(Rol rol) {
        return rol == null ? new LinkedHashSet<>() : rol.obtenerPermisos();
    }

    // ------------------------------------------------------------------
    // Consultas para la pantalla
    // ------------------------------------------------------------------

    /** Usuarios registrados, ordenados por nombre. */
    public List<Usuario> listarUsuarios() {
        List<Usuario> lista = new ArrayList<>(usuarioFacade.findAll());
        lista.sort(Comparator.comparing(Usuario::getNombre, String.CASE_INSENSITIVE_ORDER));
        return lista;
    }

    /** Usuarios activos (para elegir el responsable de un equipo). */
    public List<Usuario> listarUsuariosActivos() {
        List<Usuario> lista = listarUsuarios();
        lista.removeIf(u -> !u.getEstaActivo());
        return lista;
    }

    /** Roles en el orden en que se crearon (Jefe, Supervisor, Auxiliar). */
    public List<Rol> listarRoles() {
        List<Rol> lista = new ArrayList<>(rolFacade.findAll());
        lista.sort(Comparator.comparing(Rol::getIdRol));
        return lista;
    }

    // ------------------------------------------------------------------
    // Auxiliares
    // ------------------------------------------------------------------

    /** Quita espacios; el correo se guarda en minúsculas. */
    private void normalizar(Usuario u) {
        u.setMatricula(Validacion.limpiar(u.getMatricula()));
        u.setNombre(Validacion.limpiar(u.getNombre()));
        String correo = Validacion.limpiar(u.getCorreo());
        u.setCorreo(correo == null ? null : correo.toLowerCase());
    }

    /** Permisos en el orden del enum, para que la columna quede siempre igual. */
    private List<String> ordenar(Set<String> codigos) {
        List<String> r = new ArrayList<>();
        for (Permiso p : Permiso.values()) {
            if (codigos.contains(p.name())) {
                r.add(p.name());
            }
        }
        return r;
    }
}
