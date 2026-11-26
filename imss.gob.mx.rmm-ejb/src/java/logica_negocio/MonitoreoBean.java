package logica_negocio;

import acceso_datos.EquipoFacade;
import acceso_datos.MonitoreoFacade;
import jakarta.ejb.EJB;
import jakarta.ejb.LocalBean;
import jakarta.ejb.Stateless;
import java.io.Serializable;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;
import modelo.Alerta;
import modelo.Almacenamiento;
import modelo.Equipo;
import modelo.Informe;
import modelo.SesionMonitoreo;

/**
 * Lógica de Monitoreo → Estado y rendimiento (HU-2: "monitoreo en vivo del
 * estado ONLINE / ALERTA / OFFLINE y métricas de desempeño").
 *
 *   - estadoEquipos(): cada equipo activo con su último informe (como "Latest data" de Zabbix).
 *   - historial(): series de CPU, RAM, disco y red para las gráficas, agrupadas
 *     en intervalos para que una semana no sean 10,000 puntos.
 *   - disponibilidad(): % del periodo que el equipo tuvo sesión de monitoreo abierta.
 *
 * @author kyriux
 */
@Stateless
@LocalBean
public class MonitoreoBean {

    @EJB
    private EquipoFacade equipoFacade;

    @EJB
    private MonitoreoFacade monitoreoFacade;

    // ------------------------------------------------------------------
    // Lista de equipos con su último informe
    // ------------------------------------------------------------------

    /**
     * Equipos activos (no dados de baja) con su último informe. Los filtros son
     * opcionales; el de estado lo aplica la vista para poder contar cada estado.
     */
    public List<FilaMonitoreo> estadoEquipos(String texto, Short idUnidadHomologada) {
        List<Equipo> equipos = equipoFacade.buscarInventario(Validacion.limpiar(texto), null, idUnidadHomologada)
                .stream().filter(Equipo::getEstaActivo).collect(Collectors.toList());
        Map<Integer, Informe> ultimos = new HashMap<>();
        if (!equipos.isEmpty()) {
            List<Integer> ids = equipos.stream().map(Equipo::getIdEquipo).collect(Collectors.toList());
            for (Informe i : monitoreoFacade.ultimosInformes(ids)) {
                ultimos.put(i.getIdEquipo().getIdEquipo(), i);
            }
        }
        List<FilaMonitoreo> r = new ArrayList<>(equipos.size());
        for (Equipo e : equipos) {
            r.add(new FilaMonitoreo(e, ultimos.get(e.getIdEquipo())));
        }
        return r;
    }

    public Equipo buscarEquipo(Integer idEquipo) {
        return idEquipo == null ? null : equipoFacade.find(idEquipo);
    }

    /** Último informe de un equipo (null si nunca ha reportado). */
    public FilaMonitoreo ultimo(Equipo e) {
        List<Informe> l = monitoreoFacade.ultimosInformes(List.of(e.getIdEquipo()));
        return new FilaMonitoreo(e, l.isEmpty() ? null : l.get(0));
    }

    public List<SesionMonitoreo> sesiones(Integer idEquipo, int maximo) {
        return monitoreoFacade.sesiones(idEquipo, maximo);
    }

    public List<Alerta> alertasActivas(Integer idEquipo) {
        return monitoreoFacade.alertasActivas(idEquipo);
    }

    /**
     * Disponibilidad: porcentaje del periodo [ahora - rango, ahora] en que el
     * equipo tuvo una sesión de monitoreo abierta (es decir, estuvo reportando).
     */
    public double disponibilidad(Integer idEquipo, Rango rango) {
        long hasta = System.currentTimeMillis();
        long desde = hasta - rango.milisegundos;
        long cubierto = 0;
        for (SesionMonitoreo s : monitoreoFacade.sesionesDesde(idEquipo, new Date(desde))) {
            if (s.getInicioSesion() == null) {
                continue;
            }
            long ini = Math.max(desde, s.getInicioSesion().getTime());
            long fin = Math.min(hasta, s.getFinSesion() == null ? hasta : s.getFinSesion().getTime());
            cubierto += Math.max(0, fin - ini);
        }
        return Math.min(100, redondear(cubierto * 100.0 / rango.milisegundos));
    }

    // ------------------------------------------------------------------
    // Historial para las gráficas
    // ------------------------------------------------------------------

    /** Periodos de las gráficas: duración y número de puntos. */
    public enum Rango {
        HORA("Última hora", 3_600_000L, 60, "HH:mm"),
        SEIS_HORAS("6 horas", 6 * 3_600_000L, 180, "HH:mm"),
        DIA("24 horas", 24 * 3_600_000L, 288, "HH:mm"),
        SEMANA("7 días", 7 * 24 * 3_600_000L, 336, "dd/MM HH:mm");

        private final String etiqueta;
        private final long milisegundos;
        private final int puntos;
        private final String formato;

        Rango(String etiqueta, long milisegundos, int puntos, String formato) {
            this.etiqueta = etiqueta;
            this.milisegundos = milisegundos;
            this.puntos = puntos;
            this.formato = formato;
        }

        public String getEtiqueta() {
            return etiqueta;
        }

        public String getFormato() {
            return formato;
        }

        public String getCodigo() {
            return name();
        }
    }

    /**
     * Series del equipo en el rango, promediadas por intervalo. Un intervalo sin
     * datos queda en null (en la gráfica se ve como un hueco = sin conexión).
     */
    public Historial historial(Equipo equipo, Rango rango) {
        long hasta = System.currentTimeMillis();
        long desde = hasta - rango.milisegundos;
        long paso = rango.milisegundos / rango.puntos;
        Historial h = new Historial(rango.puntos);
        for (int i = 0; i < rango.puntos; i++) {
            h.fechas.add(new Date(desde + (i + 1) * paso));
        }

        Double ramTotal = equipo.getHardware() == null ? null : equipo.getHardware().getTotalRamGb();
        // Mb/s = MB de la captura × 8 / segundos del intervalo
        double factorRed = 8.0 / IngestaBean.intervaloTelemetriaSeg();

        Acumulador cpu = new Acumulador(rango.puntos);
        Acumulador ram = new Acumulador(rango.puntos);
        Acumulador rx = new Acumulador(rango.puntos);
        Acumulador tx = new Acumulador(rango.puntos);
        Acumulador procesos = new Acumulador(rango.puntos);
        for (Object[] f : monitoreoFacade.metricasDesde(equipo.getIdEquipo(), new Date(desde))) {
            int k = indice((Date) f[0], desde, paso, rango.puntos);
            if (k < 0) {
                continue;
            }
            cpu.sumar(k, (Double) f[1]);
            if (f[2] != null && ramTotal != null && ramTotal > 0) {
                ram.sumar(k, Math.min(100, (Double) f[2] * 100 / ramTotal));
            }
            rx.sumar(k, f[3] == null ? null : (Double) f[3] * factorRed);
            tx.sumar(k, f[4] == null ? null : (Double) f[4] * factorRed);
            procesos.sumar(k, f[5] == null ? null : ((Number) f[5]).doubleValue());
        }

        // Disco: la partición más llena de cada informe
        Map<Integer, Object[]> masLlena = new HashMap<>();
        for (Object[] f : monitoreoFacade.particionesDesde(equipo.getIdEquipo(), new Date(desde))) {
            double total = ((Number) f[2]).doubleValue();
            if (total <= 0) {
                continue;
            }
            double pct = (total - ((Number) f[3]).doubleValue()) * 100 / total;
            Object[] actual = masLlena.get((Integer) f[0]);
            if (actual == null || pct > (Double) actual[1]) {
                masLlena.put((Integer) f[0], new Object[] {f[1], pct});
            }
        }
        Acumulador disco = new Acumulador(rango.puntos);
        for (Object[] v : masLlena.values()) {
            int k = indice((Date) v[0], desde, paso, rango.puntos);
            if (k >= 0) {
                disco.sumar(k, (Double) v[1]);
            }
        }

        h.cpu = cpu.promedios();
        h.ram = ram.promedios();
        h.disco = disco.promedios();
        h.redRx = rx.promedios();
        h.redTx = tx.promedios();
        h.procesos = procesos.promedios();
        h.capturas = cpu.total();
        return h;
    }

    private static int indice(Date fecha, long desde, long paso, int puntos) {
        if (fecha == null) {
            return -1;
        }
        long k = (fecha.getTime() - desde) / paso;
        return k < 0 ? -1 : (int) Math.min(puntos - 1, k);
    }

    /** Suma y cuenta por intervalo para sacar el promedio. */
    private static final class Acumulador {
        private final double[] suma;
        private final int[] cuenta;

        Acumulador(int n) {
            suma = new double[n];
            cuenta = new int[n];
        }

        void sumar(int k, Double v) {
            if (v != null && !v.isNaN()) {
                suma[k] += v;
                cuenta[k]++;
            }
        }

        List<Double> promedios() {
            List<Double> r = new ArrayList<>(suma.length);
            for (int i = 0; i < suma.length; i++) {
                r.add(cuenta[i] == 0 ? null : redondear(suma[i] / cuenta[i]));
            }
            return r;
        }

        int total() {
            int t = 0;
            for (int c : cuenta) {
                t += c;
            }
            return t;
        }
    }

    /** Series de las gráficas (mismo número de puntos que fechas; null = sin datos). */
    public static final class Historial implements Serializable {

        private static final long serialVersionUID = 1L;

        private final List<Date> fechas;
        private List<Double> cpu = Collections.emptyList();
        private List<Double> ram = Collections.emptyList();
        private List<Double> disco = Collections.emptyList();
        private List<Double> redRx = Collections.emptyList();
        private List<Double> redTx = Collections.emptyList();
        private List<Double> procesos = Collections.emptyList();
        private int capturas;

        Historial(int puntos) {
            fechas = new ArrayList<>(puntos);
        }

        public List<Date> getFechas() {
            return fechas;
        }

        public List<Double> getCpu() {
            return cpu;
        }

        public List<Double> getRam() {
            return ram;
        }

        public List<Double> getDisco() {
            return disco;
        }

        public List<Double> getRedRx() {
            return redRx;
        }

        public List<Double> getRedTx() {
            return redTx;
        }

        public List<Double> getProcesos() {
            return procesos;
        }

        /** Capturas recibidas en el periodo (0 = no hay nada que graficar). */
        public int getCapturas() {
            return capturas;
        }
    }

    // ------------------------------------------------------------------
    // Renglón de la lista: equipo + su último informe
    // ------------------------------------------------------------------

    public static final class FilaMonitoreo implements Serializable {

        private static final long serialVersionUID = 1L;

        private final Equipo equipo;
        private final Date fechaInforme;
        private final Double cpu;
        private final Double ramUsadaGb;
        private final Double ramTotalGb;
        private final Double ram;
        private final Double disco;
        private final String particionMasLlena;
        private final Double redRxMb;
        private final Double redTxMb;
        private final Integer procesos;
        private final List<Almacenamiento> particiones;

        FilaMonitoreo(Equipo e, Informe i) {
            this.equipo = e;
            this.ramTotalGb = e.getHardware() == null ? null : e.getHardware().getTotalRamGb();
            if (i == null) {
                fechaInforme = null;
                cpu = null;
                ramUsadaGb = null;
                ram = null;
                disco = null;
                particionMasLlena = null;
                redRxMb = null;
                redTxMb = null;
                procesos = null;
                particiones = Collections.emptyList();
                return;
            }
            fechaInforme = i.getFechaRegistro();
            cpu = i.getPorcentajeUsoCpu();
            ramUsadaGb = i.getRamUsadaGb();
            ram = ramUsadaGb == null || ramTotalGb == null || ramTotalGb <= 0 ? null
                    : redondear(Math.min(100, ramUsadaGb * 100 / ramTotalGb));
            redRxMb = i.getTraficoRedRxMb();
            redTxMb = i.getTraficoRedTxMb();
            procesos = i.getTotalProcesos();
            particiones = i.getAlmacenamientoList() == null ? Collections.emptyList()
                    : new ArrayList<>(i.getAlmacenamientoList());
            particiones.sort((a, b) -> a.getPuntoMontaje().compareToIgnoreCase(b.getPuntoMontaje()));
            Almacenamiento max = null;
            for (Almacenamiento a : particiones) {
                if (max == null || porcentajeUso(a) > porcentajeUso(max)) {
                    max = a;
                }
            }
            disco = max == null ? null : porcentajeUso(max);
            particionMasLlena = max == null ? null : max.getPuntoMontaje();
        }

        public Equipo getEquipo() {
            return equipo;
        }

        /** Fecha de la última captura (null = nunca ha reportado). */
        public Date getFechaInforme() {
            return fechaInforme;
        }

        public boolean isConDatos() {
            return fechaInforme != null;
        }

        public Double getCpu() {
            return cpu;
        }

        public Double getRamUsadaGb() {
            return ramUsadaGb;
        }

        public Double getRamTotalGb() {
            return ramTotalGb;
        }

        /** % de RAM usada. */
        public Double getRam() {
            return ram;
        }

        /** % de uso de la partición más llena. */
        public Double getDisco() {
            return disco;
        }

        public String getParticionMasLlena() {
            return particionMasLlena;
        }

        public Double getRedRxMb() {
            return redRxMb;
        }

        public Double getRedTxMb() {
            return redTxMb;
        }

        public Integer getProcesos() {
            return procesos;
        }

        public List<Almacenamiento> getParticiones() {
            return particiones;
        }
    }

    /** % de uso de una partición. */
    public static double porcentajeUso(Almacenamiento a) {
        return a.getCapacidadTotalGb() <= 0 ? 0
                : redondear((a.getCapacidadTotalGb() - a.getEspacioLibreGb()) * 100 / a.getCapacidadTotalGb());
    }

    private static double redondear(double v) {
        return Math.round(v * 10) / 10.0;
    }
}
