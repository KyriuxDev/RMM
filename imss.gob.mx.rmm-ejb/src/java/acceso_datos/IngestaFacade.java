package acceso_datos;

import jakarta.ejb.Stateless;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import java.util.Date;
import java.util.List;
import modelo.Alerta;
import modelo.Equipo;
import modelo.Periferico;
import modelo.SesionMonitoreo;
import modelo.Software;
import modelo.UmbralAlerta;

/**
 * Consultas que necesita la API de Ingesta del agente. Se dejan en un facade
 * aparte para no tocar los facades generados de cada entidad.
 *
 * @author kyriux
 */
@Stateless
public class IngestaFacade {

    @PersistenceContext(unitName = "rmmPU")
    private EntityManager em;

    /** Sesión de monitoreo abierta (sin fin) del equipo, o null. */
    public SesionMonitoreo sesionAbierta(Equipo equipo) {
        List<SesionMonitoreo> r = em.createQuery(
                "SELECT s FROM SesionMonitoreo s WHERE s.idEquipo = :e AND s.finSesion IS NULL"
                + " ORDER BY s.inicioSesion DESC", SesionMonitoreo.class)
                .setParameter("e", equipo)
                .setMaxResults(1)
                .getResultList();
        return r.isEmpty() ? null : r.get(0);
    }

    /** Umbrales activos (los que tienen activo = null también cuentan como activos). */
    public List<UmbralAlerta> umbralesActivos() {
        return em.createQuery(
                "SELECT u FROM UmbralAlerta u WHERE u.activo IS NULL OR u.activo = true", UmbralAlerta.class)
                .getResultList();
    }

    /** ¿Ya hay una alerta "Activa" del equipo por ese umbral? (para no repetirla en cada ciclo). */
    public boolean existeAlertaActiva(Equipo equipo, UmbralAlerta umbral) {
        return em.createQuery(
                "SELECT COUNT(a) FROM Alerta a WHERE a.idEquipo = :e AND a.idUmbralAlerta = :u"
                + " AND UPPER(a.estado) = 'ACTIVA'", Long.class)
                .setParameter("e", equipo)
                .setParameter("u", umbral)
                .getSingleResult() > 0;
    }

    /**
     * ¿Ya hay una alerta "Activa" del equipo de ese tipo que no venga de un umbral?
     * (desconexión, riesgo de seguridad). Evita repetirla en cada ciclo.
     */
    public boolean existeAlertaActivaSinUmbral(Equipo equipo, String tipoAlerta) {
        return em.createQuery(
                "SELECT COUNT(a) FROM Alerta a WHERE a.idEquipo = :e AND a.tipoAlerta = :t"
                + " AND a.idUmbralAlerta IS NULL AND UPPER(a.estado) = 'ACTIVA'", Long.class)
                .setParameter("e", equipo)
                .setParameter("t", tipoAlerta)
                .getSingleResult() > 0;
    }

    public void crearAlerta(Alerta alerta) {
        em.persist(alerta);
    }

    /** Equipos en línea (ONLINE / ALERTA) cuya última señal es anterior a limite. */
    public List<Equipo> equiposSinSenalDesde(Date limite) {
        return em.createQuery(
                "SELECT e FROM Equipo e WHERE e.estaActivo = true"
                + " AND e.estadoConexion IN ('ONLINE', 'ALERTA')"
                + " AND (e.ultimaSenal IS NULL OR e.ultimaSenal < :limite)", Equipo.class)
                .setParameter("limite", limite)
                .getResultList();
    }

    /**
     * Marca "autorizado" que ya tiene ese software en otros equipos (HU-8),
     * o null si nadie lo ha revisado. Se usa para el software nuevo.
     */
    public Boolean autorizacionCatalogo(String nombre) {
        List<Boolean> r = em.createQuery(
                "SELECT s.autorizado FROM Software s WHERE LOWER(s.nombre) = :n AND s.autorizado IS NOT NULL"
                + " ORDER BY s.autorizado", Boolean.class)
                .setParameter("n", nombre.toLowerCase(java.util.Locale.ROOT))
                .setMaxResults(1)
                .getResultList();
        return r.isEmpty() ? null : r.get(0);   // si hay de los dos, false va primero
    }

    public List<Software> softwareDe(Equipo equipo) {
        return em.createQuery("SELECT s FROM Software s WHERE s.idEquipo = :e", Software.class)
                .setParameter("e", equipo)
                .getResultList();
    }

    public List<Periferico> perifericosDe(Equipo equipo) {
        return em.createQuery("SELECT p FROM Periferico p WHERE p.idEquipo = :e", Periferico.class)
                .setParameter("e", equipo)
                .getResultList();
    }

    public void crear(Object entidad) {
        em.persist(entidad);
    }

    public void eliminar(Object entidad) {
        em.remove(em.contains(entidad) ? entidad : em.merge(entidad));
    }
}
