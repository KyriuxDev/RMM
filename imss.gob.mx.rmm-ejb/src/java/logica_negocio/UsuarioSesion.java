package logica_negocio;

import java.io.Serializable;
import java.util.Collections;
import java.util.LinkedHashSet;
import java.util.Set;

/**
 * Datos del usuario que inició sesión (SD-00a crearSesion(usr, listaPermisos)).
 *
 * Es una copia simple (no una entidad JPA) para poder guardarla en la sesión
 * HTTP sin llevar la contraseña ni las relaciones de la base.
 *
 * @author kyriux
 */
public class UsuarioSesion implements Serializable {

    private static final long serialVersionUID = 1L;

    private final Integer idUsuario;
    private final String matricula;
    private final String nombre;
    private final String rol;
    private final Set<String> permisos;

    public UsuarioSesion(Integer idUsuario, String matricula, String nombre, String rol, Set<String> permisos) {
        this.idUsuario = idUsuario;
        this.matricula = matricula;
        this.nombre = nombre;
        this.rol = rol;
        this.permisos = Collections.unmodifiableSet(new LinkedHashSet<>(permisos));
    }

    public boolean tienePermiso(String codigo) {
        return permisos.contains(codigo);
    }

    public boolean tienePermiso(Permiso permiso) {
        return permiso != null && permisos.contains(permiso.name());
    }

    /**
     * Primera página que puede ver el usuario, en el orden del menú lateral
     * (Tableros, ..., Inventario, ..., Administración). null si ningún módulo
     * suyo tiene vistas todavía.
     */
    public String paginaInicio() {
        for (Permiso p : Permiso.values()) {
            if (tienePermiso(p) && p.getPaginaInicio() != null) {
                return p.getPaginaInicio();
            }
        }
        return null;
    }

    /** Iniciales para el avatar del menú lateral (máximo 2 letras). */
    public String getIniciales() {
        if (nombre == null || nombre.isBlank()) {
            return "?";
        }
        String[] partes = nombre.trim().split("\\s+");
        StringBuilder r = new StringBuilder();
        r.append(Character.toUpperCase(partes[0].charAt(0)));
        if (partes.length > 1) {
            r.append(Character.toUpperCase(partes[partes.length > 2 ? partes.length - 2 : 1].charAt(0)));
        }
        return r.toString();
    }

    public Integer getIdUsuario() {
        return idUsuario;
    }

    public String getMatricula() {
        return matricula;
    }

    public String getNombre() {
        return nombre;
    }

    public String getRol() {
        return rol;
    }

    public Set<String> getPermisos() {
        return permisos;
    }
}
