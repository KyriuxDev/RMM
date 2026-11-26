package ingesta;

import java.util.ArrayList;
import java.util.List;

/** Inventario automático (HU-8): software instalado y periféricos. */
public class InventarioAgente {
    public String mac;
    public List<SoftwareAgente> software = new ArrayList<>();
    public List<PerifericoAgente> perifericos = new ArrayList<>();
}
