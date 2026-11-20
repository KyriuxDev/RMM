package logica_negocio;

/**
 * Permisos que se pueden asignar a un rol (matriz "Permisos por rol" de PR-18).
 *
 * En la base de datos, rol.permisos guarda los códigos separados por comas,
 * por ejemplo: VER_TABLEROS,VER_MONITOREO,ADMINISTRAR
 *
 * Cada permiso abre una carpeta de vistas (/vista/tableros/, /vista/inventario/, ...).
 * El filtro de acceso del WAR usa paraRuta(...) para saber qué permiso pide
 * cada página, y el inicio de sesión usa paginaInicio para mandar al usuario
 * a la primera sección que puede ver.
 *
 * @author kyriux
 */
public enum Permiso {

    VER_TABLEROS("Tableros", "Ver la vista general y los indicadores por unidad",
            "/vista/tableros/", "/vista/tableros/vista-general.xhtml"),
    VER_MONITOREO("Monitoreo", "Ver el estado de conexión y el rendimiento de los equipos",
            "/vista/monitoreo/", null),
    GESTIONAR_ALERTAS("Alertas", "Atender y escalar alertas, configurar umbrales y ver notificaciones",
            "/vista/alertas/", null),
    GESTIONAR_INCIDENCIAS("Incidencias", "Registrar, asignar y dar seguimiento a incidencias",
            "/vista/incidencias/", null),
    GESTIONAR_INVENTARIO("Inventario", "Dar de alta, editar y dar de baja equipos",
            "/vista/inventario/", "/vista/inventario/equipos.xhtml"),
    VER_REPORTES("Reportes", "Generar y exportar reportes de disponibilidad, SLA e incidencias",
            "/vista/reportes/", null),
    ADMINISTRAR("Administración", "Usuarios, roles y permisos, estructura y metas SLA",
            "/vista/administracion/", "/vista/administracion/usuarios.xhtml");

    private final String modulo;
    private final String descripcion;
    private final String carpeta;
    private final String paginaInicio;

    Permiso(String modulo, String descripcion, String carpeta, String paginaInicio) {
        this.modulo = modulo;
        this.descripcion = descripcion;
        this.carpeta = carpeta;
        this.paginaInicio = paginaInicio;
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

    /** Carpeta de vistas que protege este permiso, p. ej. "/vista/inventario/". */
    public String getCarpeta() {
        return carpeta;
    }

    /** Primera página del módulo, o null si el módulo todavía no tiene vistas. */
    public String getPaginaInicio() {
        return paginaInicio;
    }

    public static boolean existe(String codigo) {
        for (Permiso p : values()) {
            if (p.name().equals(codigo)) {
                return true;
            }
        }
        return false;
    }

    /**
     * Permiso que pide una ruta de vista (p. ej. "/vista/inventario/equipos.xhtml"),
     * o null si la ruta no pertenece a ningún módulo (login, acceso denegado, etc.).
     */
    public static Permiso paraRuta(String ruta) {
        if (ruta == null) {
            return null;
        }
        for (Permiso p : values()) {
            if (ruta.startsWith(p.carpeta)) {
                return p;
            }
        }
        return null;
    }
}
