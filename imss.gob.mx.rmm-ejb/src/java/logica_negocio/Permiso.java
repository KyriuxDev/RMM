package logica_negocio;

/**
 * Permisos que se pueden asignar a un rol (matriz "Permisos por rol" de PR-18).
 *
 * En la base de datos, rol.permisos guarda los códigos separados por comas,
 * por ejemplo: VER_TABLEROS,VER_MONITOREO,ADMINISTRAR
 *
 * @author kyriux
 */
public enum Permiso {

    VER_TABLEROS("Tableros", "Ver la vista general y los indicadores por unidad"),
    VER_MONITOREO("Monitoreo", "Ver el estado de conexión y el rendimiento de los equipos"),
    GESTIONAR_ALERTAS("Alertas", "Atender y escalar alertas, configurar umbrales y ver notificaciones"),
    GESTIONAR_INCIDENCIAS("Incidencias", "Registrar, asignar y dar seguimiento a incidencias"),
    GESTIONAR_INVENTARIO("Inventario", "Dar de alta, editar y dar de baja equipos"),
    VER_REPORTES("Reportes", "Generar y exportar reportes de disponibilidad, SLA e incidencias"),
    ADMINISTRAR("Administración", "Usuarios, roles y permisos, unidades y metas SLA");

    private final String modulo;
    private final String descripcion;

    Permiso(String modulo, String descripcion) {
        this.modulo = modulo;
        this.descripcion = descripcion;
    }

    public String getCodigo() {
        return name();
    }

    public String getModulo() {
        return modulo;
    }

    public String getDescripcion() {
        return descripcion;
    }

    /** true si el texto es el código de algún permiso. */
    public static boolean existe(String codigo) {
        for (Permiso p : values()) {
            if (p.name().equals(codigo)) {
                return true;
            }
        }
        return false;
    }
}
