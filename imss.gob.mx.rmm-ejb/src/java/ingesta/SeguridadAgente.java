package ingesta;

/**
 * Estado de seguridad que reporta el agente con el inventario (HU-4).
 * Un campo en null significa "no se pudo saber" y no genera alerta.
 */
public class SeguridadAgente {
    public Boolean antivirusActivo;
    public String antivirusNombre;
    public Boolean firewallActivo;
}
