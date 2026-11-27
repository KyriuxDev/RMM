package acceso_datos;

import jakarta.ejb.Stateless;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.persistence.TypedQuery;
import java.util.Date;
import java.util.List;
import modelo.Alerta;
import modelo.Incidencia;

/**
 * Consultas de Incidencias (HU-7 lista de incidencias). Se deja en un facade
 * aparte para no tocar IncidenciaFacade (la usan los tableros) y evitar
 * conflictos al unir las ramas.
 *
 * @author Sesma
 */
@Stateless
public class IncidenciasConsultaFacade {

    @PersistenceContext(unitName = "rmmPU")
    private EntityManager em;

    /**
     * Lista de incidencias (manuales y de alertas juntas), la más reciente primero.
     * Todos los filtros son opcionales.
     *
     * @param texto        busca en descripción, hostname del equipo y nombre del técnico
     * @param idIncidencia si no es null, también coincide con ese número de incidencia
     * @param estado       Abierta, EnProceso, Resuelta o Cerrada
     * @param prioridad    Alta, Media, Baja o Critica
     * @param origen       Manual o Alerta
     */
    public List<Incidencia> buscar(String texto, Integer idIncidencia, String estado,
            String prioridad, String origen) {
        StringBuilder jpql = new StringBuilder(
                "SELECT i FROM Incidencia i JOIN FETCH i.idEquipo e JOIN FETCH i.idUsuario u WHERE 1 = 1");
        if (texto != null) {
            jpql.append(" AND (LOWER(i.descripcion) LIKE :t OR LOWER(e.hostname) LIKE :t"
                    + " OR LOWER(u.nombre) LIKE :t");
            if (idIncidencia != null) {
                jpql.append(" OR i.idIncidencia = :id");
            }
            jpql.append(")");
        }
        if (estado != null) {
            jpql.append(" AND UPPER(i.estado) = :estado");
        }
        if (prioridad != null) {
            jpql.append(" AND UPPER(i.prioridad) = :prioridad");
        }
        if (origen != null) {
            jpql.append(" AND UPPER(i.origen) = :origen");
        }
        jpql.append(" ORDER BY i.fechaRegistro DESC, i.idIncidencia DESC");

        TypedQuery<Incidencia> q = em.createQuery(jpql.toString(), Incidencia.class);
        if (texto != null) {
            q.setParameter("t", "%" + texto.toLowerCase() + "%");
            if (idIncidencia != null) {
                q.setParameter("id", idIncidencia);
            }
        }
        if (estado != null) {
            q.setParameter("estado", estado.toUpperCase());
        }
        if (prioridad != null) {
            q.setParameter("prioridad", prioridad.toUpperCase());
        }
        if (origen != null) {
            q.setParameter("origen", origen.toUpperCase());
        }
        return q.getResultList();
    }

    /**
     * Incidencia todavía no resuelta que nació de esa alerta, o null si no hay.
     * Sirve para no crear dos incidencias de la misma alerta.
     */
    public Incidencia abiertaDeAlerta(Integer idAlerta) {
        List<Incidencia> r = em.createQuery(
                "SELECT i FROM Incidencia i WHERE i.idAlerta.idAlerta = :id"
                + " AND UPPER(i.estado) NOT IN ('RESUELTA', 'CERRADA') ORDER BY i.idIncidencia DESC",
                Incidencia.class)
                .setParameter("id", idAlerta)
                .setMaxResults(1)
                .getResultList();
        return r.isEmpty() ? null : r.get(0);
    }

    /**
     * HU-14: incidencias pendientes (Abierta o EnProceso) asignadas a un usuario,
     * con su equipo. El orden por prioridad lo da IncidenciasBean.misPendientes().
     */
    public List<Incidencia> pendientesDeUsuario(Integer idUsuario) {
        return em.createQuery(
                "SELECT i FROM Incidencia i JOIN FETCH i.idEquipo WHERE i.idUsuario.idUsuario = :u"
                + " AND UPPER(i.estado) IN ('ABIERTA', 'ENPROCESO', 'EN PROCESO', 'EN_PROCESO')",
                Incidencia.class)
                .setParameter("u", idUsuario)
                .getResultList();
    }

    /**
     * HU-6: alertas de un equipo (activas y atendidas), la más reciente primero.
     * Las fechas son opcionales: "desde" se incluye y "hasta" se excluye (el
     * llamador manda el inicio del día siguiente para incluir todo el último día).
     *
     * @param maximo tope de renglones
     */
    public List<Alerta> alertasDeEquipo(Integer idEquipo, Date desde, Date hasta, int maximo) {
        StringBuilder jpql = new StringBuilder(
                "SELECT a FROM Alerta a WHERE a.idEquipo.idEquipo = :id");
        if (desde != null) {
            jpql.append(" AND a.fechaGeneracion >= :desde");
        }
        if (hasta != null) {
            jpql.append(" AND a.fechaGeneracion < :hasta");
        }
        jpql.append(" ORDER BY a.fechaGeneracion DESC, a.idAlerta DESC");

        TypedQuery<Alerta> q = em.createQuery(jpql.toString(), Alerta.class)
                .setParameter("id", idEquipo);
        if (desde != null) {
            q.setParameter("desde", desde);
        }
        if (hasta != null) {
            q.setParameter("hasta", hasta);
        }
        return q.setMaxResults(maximo).getResultList();
    }

    /**
     * HU-6: incidencias de un equipo (manuales y de alertas), con su técnico, la más
     * reciente primero. Mismo criterio de fechas que alertasDeEquipo().
     */
    public List<Incidencia> incidenciasDeEquipo(Integer idEquipo, Date desde, Date hasta, int maximo) {
        StringBuilder jpql = new StringBuilder(
                "SELECT i FROM Incidencia i JOIN FETCH i.idUsuario WHERE i.idEquipo.idEquipo = :id");
        if (desde != null) {
            jpql.append(" AND i.fechaRegistro >= :desde");
        }
        if (hasta != null) {
            jpql.append(" AND i.fechaRegistro < :hasta");
        }
        jpql.append(" ORDER BY i.fechaRegistro DESC, i.idIncidencia DESC");

        TypedQuery<Incidencia> q = em.createQuery(jpql.toString(), Incidencia.class)
                .setParameter("id", idEquipo);
        if (desde != null) {
            q.setParameter("desde", desde);
        }
        if (hasta != null) {
            q.setParameter("hasta", hasta);
        }
        return q.setMaxResults(maximo).getResultList();
    }
}
