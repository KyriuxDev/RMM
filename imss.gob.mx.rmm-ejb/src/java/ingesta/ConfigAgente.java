package ingesta;

/**
 * Configuración que el servidor le dicta al agente (como la lista de
 * "active checks" de Zabbix): cambia los intervalos sin reinstalar nada.
 */
public class ConfigAgente {
    public Integer idEquipo;
    public int intervaloTelemetriaSeg;
    public int intervaloInventarioMin;

    public ConfigAgente() {
    }

    public ConfigAgente(Integer idEquipo, int intervaloTelemetriaSeg, int intervaloInventarioMin) {
        this.idEquipo = idEquipo;
        this.intervaloTelemetriaSeg = intervaloTelemetriaSeg;
        this.intervaloInventarioMin = intervaloInventarioMin;
    }
}
