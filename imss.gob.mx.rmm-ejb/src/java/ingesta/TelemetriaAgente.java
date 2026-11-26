package ingesta;

import java.util.ArrayList;
import java.util.List;

/**
 * Captura de rendimiento de un ciclo (registrarInforme(datosTelemetria)).
 * Cada campo corresponde a un "item key" de Zabbix:
 *   porcentajeUsoCpu  ~ system.cpu.util
 *   ramUsadaGb        ~ vm.memory.size[used]
 *   traficoRed*Mb     ~ net.if.in / net.if.out (diferencia contra el ciclo anterior)
 *   totalProcesos     ~ proc.num
 *   particiones       ~ vfs.fs.size[*]
 */
public class TelemetriaAgente {
    public String mac;
    /** Momento de la captura (epoch ms). Puede ser viejo si venía del buffer del agente. */
    public long timestampMs;
    public Double porcentajeUsoCpu;
    public Double ramUsadaGb;
    public Double ramTotalGb;
    public Double traficoRedRxMb;
    public Double traficoRedTxMb;
    public Integer totalProcesos;
    public String ipLocal;
    public List<ParticionAgente> particiones = new ArrayList<>();
}
