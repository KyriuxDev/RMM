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
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import modelo.Rol;
import modelo.Usuario;

/**
 * Lógica de negocio de la administración de usuarios (SD-07a Usuarios y roles).
 * Por ahora cubre el registro de usuarios y las consultas para la pantalla.
 *
 * @author kyriux
 */
@Stateless
@LocalBean
public class AdministracionBean {

    /** Longitud mínima de la contraseña temporal. */
    public static final int LONGITUD_MINIMA_CONTRASENA = 8;

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


    /**
     * Registra un usuario nuevo con un rol y una contraseña temporal.
     *
     * @param usuario            matrícula, nombre y correo capturados
     * @param idRol              rol asignado
     * @param contrasenaTemporal contraseña inicial (se guarda sólo su hash)
     * @return el usuario registrado, con su id asignado
     */
    public Usuario guardarUsuario(Usuario usuario, Integer idRol, String contrasenaTemporal) {
        normalizar(usuario);
        validarObligatorios(usuario, idRol, contrasenaTemporal);

        // verificarCorreoDisponible(correo) (también la matrícula)
        verificarMatriculaDisponible(usuario.getMatricula());
        verificarCorreoDisponible(usuario.getCorreo());

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

    /** Lanza un error si la matrícula ya pertenece a otro usuario. */
    public void verificarMatriculaDisponible(String matricula) {
        if (usuarioFacade.buscarPorMatricula(matricula) != null) {
            throw new Excepciones("matricula", "La matrícula " + matricula + " ya está registrada");
        }
    }

    /** Lanza un error si el correo ya pertenece a otro usuario. */
    public void verificarCorreoDisponible(String correo) {
        if (usuarioFacade.buscarPorCorreo(correo) != null) {
            throw new Excepciones("correo", "El correo " + correo + " ya está registrado");
        }
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

    /** Roles disponibles para asignar. */
    public List<Rol> listarRoles() {
        List<Rol> lista = new ArrayList<>(rolFacade.findAll());
        lista.sort(Comparator.comparing(Rol::getNombre, String.CASE_INSENSITIVE_ORDER));
        return lista;
    }

    // ------------------------------------------------------------------
    // Auxiliares
    // ------------------------------------------------------------------

    /** Quita espacios; el correo se guarda en minúsculas. */
    private void normalizar(Usuario u) {
        if (u == null) {
            throw new Excepciones("Los datos del usuario son obligatorios");
        }
        u.setMatricula(limpiar(u.getMatricula()));
        u.setNombre(limpiar(u.getNombre()));
        String correo = limpiar(u.getCorreo());
        u.setCorreo(correo == null ? null : correo.toLowerCase());
    }

    /** Validación del lado del servidor (la página también valida). */
    private void validarObligatorios(Usuario u, Integer idRol, String contrasena) {
        if (u.getMatricula() == null || !u.getMatricula().matches("\\d{6,10}")) {
            throw new Excepciones("matricula", "La matrícula debe tener de 6 a 10 dígitos");
        }
        if (u.getNombre() == null) {
            throw new Excepciones("nombre", "El nombre es obligatorio");
        }
        if (u.getCorreo() == null || !u.getCorreo().matches("[a-z0-9._%+-]+@imss\\.gob\\.mx")) {
            throw new Excepciones("correo", "El correo debe ser institucional (@imss.gob.mx)");
        }
        if (idRol == null) {
            throw new Excepciones("rol", "Seleccione el rol del usuario");
        }
        if (contrasena == null || contrasena.length() < LONGITUD_MINIMA_CONTRASENA) {
            throw new Excepciones("contrasena",
                    "La contraseña debe tener al menos " + LONGITUD_MINIMA_CONTRASENA + " caracteres");
        }
    }

    private String limpiar(String texto) {
        return (texto == null || texto.isBlank()) ? null : texto.trim();
    }
}
