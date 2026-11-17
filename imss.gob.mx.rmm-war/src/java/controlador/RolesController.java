package controlador;

import excepciones.Excepciones;
import jakarta.annotation.PostConstruct;
import jakarta.ejb.EJB;
import jakarta.faces.context.FacesContext;
import jakarta.faces.view.ViewScoped;
import jakarta.inject.Named;
import java.io.Serializable;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import logica_negocio.AdministracionBean;
import logica_negocio.Permiso;
import modelo.Rol;

/**
 * Controlador de Administración → Roles y permisos (PR-18, "Permisos por rol").
 * Es adminCtrl en SD-07a, opt "el jefe edita permisos de un rol":
 * editarPermisosRol(idRol, permisos) → actualizarPermisos(idRol, permisos).
 *
 * La matriz se guarda completa con "Guardar cambios de permisos". Antes de
 * llamar al EJB se valida aquí (en la vista) que cada rol tenga al menos un
 * permiso y que algún rol conserve Administración.
 *
 * @author kyriux
 */
@Named("rolesCtrl")
@ViewScoped
public class RolesController implements Serializable {

    private static final long serialVersionUID = 1L;

    @EJB
    private AdministracionBean administracionBean;

    private List<Rol> roles;
    private final List<Permiso> permisos = Arrays.asList(Permiso.values());

    /** idRol → (código de permiso → marcado). */
    private Map<Integer, Map<String, Boolean>> matriz;

    @PostConstruct
    public void init() {
        cargar();
    }

    /** editarPermisosRol(idRol, permisos) para todos los roles de la matriz. */
    public void guardarPermisos() {
        if (!validarMatriz()) {
            return;
        }
        try {
            administracionBean.actualizarPermisos(permisosMarcados());
            Mensajes.info("Permisos actualizados",
                    "Los cambios se aplican la próxima vez que cada usuario inicie sesión.");
            cargar();
        } catch (Excepciones e) {
            Mensajes.error("No se pudieron guardar los permisos", e.getMessage());
        }
    }

    /** Botón "Descartar cambios": vuelve a leer los permisos guardados. */
    public void descartar() {
        cargar();
    }

    /** Cuántos permisos tiene marcados un rol en la matriz. */
    public int contarPermisos(Integer idRol) {
        Map<String, Boolean> fila = matriz.get(idRol);
        return fila == null ? 0 : (int) fila.values().stream().filter(Boolean.TRUE::equals).count();
    }

    // ------------------------------------------------------------------
    // Validación de la vista
    // ------------------------------------------------------------------

    /**
     * Revisa la matriz antes de guardar. Si algo falla agrega el mensaje,
     * marca la validación como fallida y regresa false.
     */
    private boolean validarMatriz() {
        boolean valido = true;
        boolean hayAdministrador = false;
        for (Rol r : roles) {
            if (contarPermisos(r.getIdRol()) == 0) {
                Mensajes.error("Permisos incompletos",
                        "El rol " + r.getNombre() + " debe tener al menos un permiso.");
                valido = false;
            }
            if (Boolean.TRUE.equals(matriz.get(r.getIdRol()).get(Permiso.ADMINISTRAR.name()))) {
                hayAdministrador = true;
            }
        }
        if (!hayAdministrador) {
            Mensajes.error("Permisos incompletos",
                    "Al menos un rol debe conservar el permiso de Administración; si no, nadie podría volver a esta pantalla.");
            valido = false;
        }
        if (!valido) {
            FacesContext.getCurrentInstance().validationFailed();
        }
        return valido;
    }

    // ------------------------------------------------------------------
    // Auxiliares
    // ------------------------------------------------------------------

    private void cargar() {
        roles = administracionBean.listarRoles();
        matriz = new HashMap<>();
        for (Rol r : roles) {
            Set<String> actuales = AdministracionBean.permisosDe(r);
            Map<String, Boolean> fila = new LinkedHashMap<>();
            for (Permiso p : permisos) {
                fila.put(p.name(), actuales.contains(p.name()));
            }
            matriz.put(r.getIdRol(), fila);
        }
    }

    private Map<Integer, List<String>> permisosMarcados() {
        Map<Integer, List<String>> r = new LinkedHashMap<>();
        for (Rol rol : roles) {
            List<String> codigos = new ArrayList<>();
            matriz.get(rol.getIdRol()).forEach((codigo, marcado) -> {
                if (Boolean.TRUE.equals(marcado)) {
                    codigos.add(codigo);
                }
            });
            r.put(rol.getIdRol(), codigos);
        }
        return r;
    }

    // Getters

    public List<Rol> getRoles() {
        return roles;
    }

    public List<Permiso> getPermisos() {
        return permisos;
    }

    public Map<Integer, Map<String, Boolean>> getMatriz() {
        return matriz;
    }
}
