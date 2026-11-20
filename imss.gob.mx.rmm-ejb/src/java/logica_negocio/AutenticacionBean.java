package logica_negocio;

import acceso_datos.UsuarioFacade;
import jakarta.annotation.PostConstruct;
import jakarta.ejb.EJB;
import jakarta.ejb.LocalBean;
import jakarta.ejb.Stateless;
import jakarta.inject.Inject;
import jakarta.security.enterprise.identitystore.Pbkdf2PasswordHash;
import java.util.Arrays;
import java.util.Date;
import java.util.Map;
import java.util.Set;
import modelo.Rol;
import modelo.Usuario;

/**
 * Inicio de sesión (SD-00a Iniciar sesión).
 *
 * Línea de vida "authCtrl" del diagrama, del lado del EJB:
 *   buscarPorUsuario → validarContraseña → [fallido] registrarIntentoFallido
 *   (y bloquearTemporalmente(15) al tercero) / [correcto] reiniciarIntentos
 *   → getRol → obtenerPermisos → crearSesion.
 *
 * @author kyriux
 */
@Stateless
@LocalBean
public class AutenticacionBean {

    /** Intentos fallidos seguidos antes de bloquear la cuenta. */
    public static final int MAX_INTENTOS = 3;
    /** Minutos que dura el bloqueo temporal. */
    public static final int MINUTOS_BLOQUEO = 15;

    static final String MSG_CREDENCIALES = "Usuario o contraseña incorrectos.";

    @EJB
    private UsuarioFacade usuarioFacade;

    @Inject
    private Pbkdf2PasswordHash passwordHash;

    @PostConstruct
    public void init() {
        // Mismos parámetros con los que AdministracionBean genera las contraseñas
        passwordHash.initialize(Map.of(
                "Pbkdf2PasswordHash.Algorithm", "PBKDF2WithHmacSHA256",
                "Pbkdf2PasswordHash.Iterations", "600000",
                "Pbkdf2PasswordHash.SaltSizeBytes", "32",
                "Pbkdf2PasswordHash.KeySizeBytes", "32"));
    }

    /**
     * SD-00a iniciarSesion(cred).
     *
     * @param identificador matrícula o correo institucional
     * @param contrasena    contraseña escrita en el login
     */
    public ResultadoLogin iniciarSesion(String identificador, String contrasena) {
        String id = Validacion.limpiar(identificador);
        if (id == null || contrasena == null || contrasena.isEmpty()) {
            return ResultadoLogin.error(MSG_CREDENCIALES);
        }

        // buscarPorUsuario(usuario)
        Usuario usr = buscarPorUsuario(id);
        if (usr == null || !usr.getEstaActivo()) {
            // Mismo mensaje que con contraseña incorrecta: no se revela qué usuarios existen
            return ResultadoLogin.error(MSG_CREDENCIALES);
        }

        Date ahora = new Date();
        if (usr.estaBloqueado(ahora)) {
            return ResultadoLogin.error(mensajeBloqueo(usr.minutosDeBloqueo(ahora)));
        }

        // validarContraseña(contraseña)
        if (!validarContrasena(usr, contrasena)) {
            // registrarIntentoFallido()
            int intentos = usr.registrarIntentoFallido();
            if (intentos >= MAX_INTENTOS) {
                // bloquearTemporalmente(15)
                usr.bloquearTemporalmente(MINUTOS_BLOQUEO, ahora);
                usuarioFacade.edit(usr);
                return ResultadoLogin.error(mensajeBloqueo(MINUTOS_BLOQUEO));
            }
            usuarioFacade.edit(usr);
            int restantes = MAX_INTENTOS - intentos;
            return ResultadoLogin.error(MSG_CREDENCIALES + " Te queda" + (restantes == 1 ? "" : "n") + " "
                    + restantes + " intento" + (restantes == 1 ? "" : "s") + " antes del bloqueo temporal.");
        }

        // reiniciarIntentos()
        if (usr.getIntentosFallidos() != 0 || usr.getBloqueadoHasta() != null) {
            usr.reiniciarIntentos();
            usuarioFacade.edit(usr);
        }

        // getRol() → obtenerPermisos()
        Rol rol = usr.getIdRol();
        Set<String> listaPermisos = rol.obtenerPermisos();

        // crearSesion(usr, listaPermisos)
        UsuarioSesion sesion = new UsuarioSesion(usr.getIdUsuario(), usr.getMatricula(),
                usr.getNombre(), rol.getNombre(), listaPermisos);
        return ResultadoLogin.correcto(sesion);
    }

    /**
     * Permisos actuales de un usuario (por si el jefe los cambió durante la sesión).
     * Regresa null si el usuario ya no existe o fue desactivado.
     */
    public UsuarioSesion recargarSesion(Integer idUsuario) {
        Usuario usr = idUsuario == null ? null : usuarioFacade.find(idUsuario);
        if (usr == null || !usr.getEstaActivo()) {
            return null;
        }
        Rol rol = usr.getIdRol();
        return new UsuarioSesion(usr.getIdUsuario(), usr.getMatricula(), usr.getNombre(),
                rol.getNombre(), rol.obtenerPermisos());
    }

    /** buscarPorUsuario: con "@" busca por correo, si no, por matrícula. */
    Usuario buscarPorUsuario(String identificador) {
        if (identificador.contains("@")) {
            return usuarioFacade.buscarPorCorreo(identificador.toLowerCase());
        }
        return usuarioFacade.buscarPorMatricula(identificador);
    }

    private boolean validarContrasena(Usuario usr, String contrasena) {
        char[] caracteres = contrasena.toCharArray();
        try {
            return passwordHash.verify(caracteres, usr.getContrasenaHash());
        } catch (RuntimeException e) {
            // Hash con formato inválido en la base: se trata como contraseña incorrecta
            return false;
        } finally {
            Arrays.fill(caracteres, '\0');
        }
    }

    static String mensajeBloqueo(long minutos) {
        return "Tu cuenta está bloqueada temporalmente por varios intentos fallidos. Intenta de nuevo en "
                + minutos + (minutos == 1 ? " minuto." : " minutos.");
    }
}
