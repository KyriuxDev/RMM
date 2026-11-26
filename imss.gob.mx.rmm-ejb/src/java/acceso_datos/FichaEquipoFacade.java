package acceso_datos;

import jakarta.ejb.Stateless;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import java.util.List;
import modelo.Alerta;
import modelo.Incidencia;

/**
 * Consultas de Inventario → Ficha del equipo (HU-10): historial de alertas
 * (activas y atendidas) e incidencias de un equipo. Se deja en un facade aparte
 * para no tocar IncidenciaFacade ni MonitoreoFacade.
 *
 * @author kyriux
 */
@Stateless
public class FichaEquipoFacade {

    @PersistenceContext(unitName = "rmmPU")
    private EntityManager em;

    /** Últimas alertas del equipo, en cualquier estado (la más reciente primero). */
    public List<Alerta> alertasDe(Integer idEquipo, int maximo) {
        return em.createQuery(
                "SELECT a FROM Alerta a WHERE a.idEquipo.idEquipo = :id ORDER BY a.fechaGeneracion DESC",
                Alerta.class)
                .setParameter("id", idEquipo)
                .setMaxResults(maximo)
                .getResultList();
    }

    /** Últimas incidencias del equipo, con su técnico (la más reciente primero). */
    public List<Incidencia> incidenciasDe(Integer idEquipo, int maximo) {
        return em.createQuery(
                "SELECT i FROM Incidencia i JOIN FETCH i.idUsuario WHERE i.idEquipo.idEquipo = :id"
                + " ORDER BY i.fechaRegistro DESC", Incidencia.class)
                .setParameter("id", idEquipo)
                .setMaxResults(maximo)
                .getResultList();
    }
}
