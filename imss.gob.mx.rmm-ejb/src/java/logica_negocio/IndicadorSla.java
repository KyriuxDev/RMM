package logica_negocio;

/**
 * Indicadores a los que se les puede fijar una meta SLA (SD-07c).
 *
 * El nombre se guarda en sla.nombre_indicador y la unidad en sla.unidad_medida.
 * valorMinimo y valorMaximo son el rango que acepta la meta; la vista
 * los usa para validar lo que se captura.
 *
 * @author kyriux
 */
public enum IndicadorSla {

    DISPONIBILIDAD("Disponibilidad de equipos", "%", 0.01, 100),
    INCIDENCIAS_EN_TIEMPO("Incidencias resueltas dentro del SLA", "%", 0.01, 100),
    TIEMPO_ATENCION("Tiempo de primera atención", "horas", 0.01, 720),
    TIEMPO_RESOLUCION("Tiempo de resolución de incidencias", "horas", 0.01, 720);

    private final String nombre;
    private final String unidadMedida;
    private final double valorMinimo;
    private final double valorMaximo;

    IndicadorSla(String nombre, String unidadMedida, double valorMinimo, double valorMaximo) {
        this.nombre = nombre;
        this.unidadMedida = unidadMedida;
        this.valorMinimo = valorMinimo;
        this.valorMaximo = valorMaximo;
    }

    public String getCodigo() {
        return name();
    }

    public String getNombre() {
        return nombre;
    }

    public String getUnidadMedida() {
        return unidadMedida;
    }

    public double getValorMinimo() {
        return valorMinimo;
    }

    public double getValorMaximo() {
        return valorMaximo;
    }

    /** Indicador con ese código, o null si no existe. */
    public static IndicadorSla porCodigo(String codigo) {
        for (IndicadorSla i : values()) {
            if (i.name().equals(codigo)) {
                return i;
            }
        }
        return null;
    }

    /** Indicador con ese nombre (como se guarda en la tabla), o null. */
    public static IndicadorSla porNombre(String nombre) {
        for (IndicadorSla i : values()) {
            if (i.nombre.equals(nombre)) {
                return i;
            }
        }
        return null;
    }
}
