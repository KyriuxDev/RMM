package ingesta;

public class SoftwareAgente {
    public String nombre;
    public String version;
    public String fabricante;
    /** Fecha de instalación (epoch ms) o null si el SO no la reporta. */
    public Long fechaInstalacionMs;
}
