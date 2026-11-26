package ingesta;

/**
 * Datos que el agente manda en su primer enlace (HU-1, autoregistro).
 * Equivale al "HostMetadata" del autoregistro de Zabbix: identifica el equipo
 * (MAC + hostname) y trae su ficha de hardware.
 */
public class RegistroAgente {
    public String hostname;
    public String mac;
    public String ipLocal;
    public String nombreSo;
    public String versionSo;
    public String versionAgente;
    // Ficha de hardware (entidad Hardware)
    public String modeloCpu;
    public Integer nucleosCpu;
    public Integer hilosCpu;
    public Double totalRamGb;
    public String modeloPlacaBase;
    public Double capacidadDiscoGb;
}
