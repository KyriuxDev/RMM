package acceso_datos;

import jakarta.ejb.Stateless;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import modelo.Alerta;
import modelo.Informe;
import modelo.SesionMonitoreo;

/**
 * Consultas de Monitoreo → Estado y rendimiento (HU-2): último informe de cada
 * equipo, historial para las gráficas, sesiones de monitoreo y alertas activas.
 *
 * La tabla informe crece rápido (1 renglón por equipo por minuto), por eso las
 * consultas siempre van por equipo y por fecha. Conviene el índice:
 *   CREATE INDEX ix_informe_equipo_fecha ON informe (id_equipo, fecha_registro);
 *
 * @author kyriux
 */
@Stateless
public class MonitoreoFacade {

    /** Máximo de ids por consulta IN (...). */
    private static final int LOTE = 500;

    @PersistenceContext(unitName = "rmmPU")
    private EntityManager em;

    /**
     * Último informe (con sus particiones) de cada uno de los equipos. Se toma
     * el id más alto de cada equipo, que es el último que llegó.
     */
    public List<Informe> ultimosInformes(List<Integer> idsEquipo) {
        List<Informe> r = new ArrayList<>();
        for (int i = 0; i < idsEquipo.size(); i += LOTE) {
            List<Integer> lote = idsEquipo.subList(i, Math.min(i + LOTE, idsEquipo.size()));
            r.addAll(em.createQuery(
                    "SELECT DISTINCT i FROM Informe i LEFT JOIN FETCH i.almacenamientoList"
                    + " WHERE i.idInforme IN (SELECT MAX(i2.idInforme) FROM Informe i2"
                    + " WHERE i2.idEquipo.idEquipo IN :ids GROUP BY i2.idEquipo.idEquipo)", Informe.class)
                    .setParameter("ids", lote)
                    .getResultList());
        }
        return r;
    }

    /**
     * Métricas de un equipo desde una fecha, en orden cronológico:
     * [fechaRegistro, porcentajeUsoCpu, ramUsadaGb, traficoRedRxMb, traficoRedTxMb, totalProcesos].
     */
    public List<Object[]> metricasDesde(Integer idEquipo, Date desde) {
        return em.createQuery(
                "SELECT i.fechaRegistro, i.porcentajeUsoCpu, i.ramUsadaGb, i.traficoRedRxMb, i.traficoRedTxMb,"
                + " i.totalProcesos FROM Informe i"
                + " WHERE i.idEquipo.idEquipo = :id AND i.fechaRegistro >= :desde ORDER BY i.fechaRegistro", Object[].class)
                .setParameter("id", idEquipo)
                .setParameter("desde", desde)
                .getResultList();
    }

    /**
     * Particiones de un equipo desde una fecha:
     * [idInforme, fechaRegistro, capacidadTotalGb, espacioLibreGb].
     */
    public List<Object[]> particionesDesde(Integer idEquipo, Date desde) {
        return em.createQuery(
                "SELECT i.idInforme, i.fechaRegistro, a.capacidadTotalGb, a.espacioLibreGb"
                + " FROM Almacenamiento a JOIN a.idInforme i"
                + " WHERE i.idEquipo.idEquipo = :id AND i.fechaRegistro >= :desde ORDER BY i.fechaRegistro", Object[].class)
                .setParameter("id", idEquipo)
                .setParameter("desde", desde)
                .getResultList();
    }

    /** Últimas sesiones de monitoreo del equipo (la más reciente primero). */
    public List<SesionMonitoreo> sesiones(Integer idEquipo, int maximo) {
        return em.createQuery(
                "SELECT s FROM SesionMonitoreo s WHERE s.idEquipo.idEquipo = :id ORDER BY s.inicioSesion DESC",
                SesionMonitoreo.class)
                .setParameter("id", idEquipo)
                .setMaxResults(maximo)
                .getResultList();
    }

    /** Sesiones que tocan el periodo [desde, ahora]: abiertas o cerradas después de desde. */
    public List<SesionMonitoreo> sesionesDesde(Integer idEquipo, Date desde) {
        return em.createQuery(
                "SELECT s FROM SesionMonitoreo s WHERE s.idEquipo.idEquipo = :id"
                + " AND (s.finSesion IS NULL OR s.finSesion >= :desde)", SesionMonitoreo.class)
                .setParameter("id", idEquipo)
                .setParameter("desde", desde)
                .getResultList();
    }

    /** Alertas sin atender del equipo (la más reciente primero). */
    public List<Alerta> alertasActivas(Integer idEquipo) {
        return em.createQuery(
                "SELECT a FROM Alerta a WHERE a.idEquipo.idEquipo = :id AND UPPER(a.estado) = 'ACTIVA'"
                + " ORDER BY a.fechaGeneracion DESC", Alerta.class)
                .setParameter("id", idEquipo)
                .getResultList();
    }
}
