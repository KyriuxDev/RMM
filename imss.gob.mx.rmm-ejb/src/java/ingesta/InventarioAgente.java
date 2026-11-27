package ingesta;

import java.util.ArrayList;
import java.util.List;

/** Inventario automático (HU-8): software instalado y periféricos; y seguridad (HU-4). */
public class InventarioAgente {
    public String mac;
    public List<SoftwareAgente> software = new ArrayList<>();
    public List<PerifericoAgente> perifericos = new ArrayList<>();
    /** Puede venir null (agentes anteriores a HU-4). */
    public SeguridadAgente seguridad;
}
