package logica_negocio;

import jakarta.ejb.EJB;
import jakarta.ejb.Schedule;
import jakarta.ejb.Singleton;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Revisa cada minuto qué equipos dejaron de mandar señal de vida y los pasa a
 * OFFLINE (equivalente al trigger nodata() / disponibilidad del agente en
 * Zabbix). El umbral es intervalosSinSenal × intervaloTelemetriaSeg
 * (3 × 60 s = 3 min por defecto).
 *
 * @author kyriux
 */
@Singleton
public class MonitorConexionBean {

    private static final Logger LOG = Logger.getLogger(MonitorConexionBean.class.getName());

    @EJB
    private IngestaBean ingesta;

    @Schedule(second = "0", minute = "*", hour = "*", persistent = false, info = "RMM: equipos sin señal")
    public void revisarSinSenal() {
        try {
            int n = ingesta.marcarEquiposSinSenal();
            if (n > 0) {
                LOG.log(Level.INFO, "RMM: {0} equipo(s) pasaron a OFFLINE por falta de señal", n);
            }
        } catch (RuntimeException e) {
            LOG.log(Level.WARNING, "RMM: no se pudo revisar la señal de los equipos", e);
        }
    }
}
