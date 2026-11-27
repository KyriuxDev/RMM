package acceso_datos;

import jakarta.ejb.Stateless;
import jakarta.ejb.TransactionAttribute;
import jakarta.ejb.TransactionAttributeType;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.persistence.TypedQuery;
import java.util.Collection;
import java.util.Collections;
import java.util.Date;
import java.util.List;
import modelo.Alerta;
import modelo.Notificacion;
import modelo.UmbralAlerta;
import modelo.Usuario;

/**
 * Consultas del módulo Alertas (HU-5 alertas activas, HU-3 umbrales, HU-15
 * correo). Se deja en un facade aparte para no tocar AlertaFacade,
 * UmbralAlertaFacade ni IngestaFacade.
 *
 * @author jose
 */
@Stateless
public class GestionAlertasFacade {

    @PersistenceContext(unitName = "rmmPU")
    private EntityManager em;

    // ------------------------------------------------------------------
    // Alertas
    // ------------------------------------------------------------------

    /** Alertas en estado "Activa" (con su equipo); tipo = null trae todas. */
    public List<Alerta> activas(String tipo) {
        String jpql = "SELECT a FROM Alerta a JOIN FETCH a.idEquipo WHERE UPPER(a.estado) = 'ACTIVA'"
                + (tipo == null ? "" : " AND a.tipoAlerta = :t");
        TypedQuery<Alerta> q = em.createQuery(jpql, Alerta.class);
        if (tipo != null) {
            q.setParameter("t", tipo);
        }
        return q.getResultList();
    }

    /** Alerta con su equipo, o null. Si se llama dentro de una transacción, queda administrada. */
    public Alerta alertaConEquipo(Integer idAlerta) {
        List<Alerta> r = em.createQuery(
                "SELECT a FROM Alerta a JOIN FETCH a.idEquipo WHERE a.idAlerta = :id", Alerta.class)
                .setParameter("id", idAlerta)
                .getResultList();
        return r.isEmpty() ? null : r.get(0);
    }

    // ------------------------------------------------------------------
    // Notificaciones (correos enviados)
    // ------------------------------------------------------------------

    /** Notificaciones de varias alertas (con su destinatario). */
    public List<Notificacion> notificacionesDe(Collection<Integer> idsAlerta) {
        if (idsAlerta == null || idsAlerta.isEmpty()) {
            return Collections.emptyList();
        }
        return em.createQuery(
                "SELECT n FROM Notificacion n JOIN FETCH n.idUsuario WHERE n.idAlerta.idAlerta IN :ids"
                + " ORDER BY n.idNotificacion DESC", Notificacion.class)
                .setParameter("ids", idsAlerta)
                .getResultList();
    }

    /** Últimas notificaciones, con alerta, equipo y destinatario (la más reciente primero). */
    public List<Notificacion> recientes(int maximo) {
        return em.createQuery(
                "SELECT n FROM Notificacion n JOIN FETCH n.idAlerta a JOIN FETCH a.idEquipo"
                + " JOIN FETCH n.idUsuario ORDER BY n.idNotificacion DESC", Notificacion.class)
                .setMaxResults(maximo)
                .getResultList();
    }

    /**
     * Registra un correo por enviar. REQUIRES_NEW: se guarda al instante, así la
     * pantalla de Notificaciones ya lo ve mientras el envío está en proceso.
     */
    @TransactionAttribute(TransactionAttributeType.REQUIRES_NEW)
    public Integer crearNotificacion(Integer idAlerta, Integer idUsuario, String estado) {
        Notificacion n = new Notificacion();
        n.setMedio("Correo");
        n.setEstadoEnvio(estado);
        n.setFechaEnvio(new Date());
        n.setIdAlerta(em.getReference(Alerta.class, idAlerta));
        n.setIdUsuario(em.getReference(Usuario.class, idUsuario));
        em.persist(n);
        em.flush();
        return n.getIdNotificacion();
    }

    /** Cambia el estado de un envío (Enviado, Reintentando (2 de 3), Fallido). */
    @TransactionAttribute(TransactionAttributeType.REQUIRES_NEW)
    public void actualizarEnvio(Integer idNotificacion, String estado) {
        Notificacion n = em.find(Notificacion.class, idNotificacion);
        if (n != null) {
            n.setEstadoEnvio(estado);
            n.setFechaEnvio(new Date());
        }
    }

    // ------------------------------------------------------------------
    // Usuarios (destinatarios)
    // ------------------------------------------------------------------

    /** Usuarios activos con su rol; el filtro por permiso se hace en el bean. */
    public List<Usuario> usuariosActivos() {
        return em.createQuery(
                "SELECT u FROM Usuario u JOIN FETCH u.idRol WHERE u.estaActivo = true ORDER BY u.nombre",
                Usuario.class).getResultList();
    }

    // ------------------------------------------------------------------
    // Umbrales
    // ------------------------------------------------------------------

    public List<UmbralAlerta> umbrales() {
        return em.createQuery(
                "SELECT u FROM UmbralAlerta u ORDER BY u.tipoRecurso, u.ambito, u.valorAmbito", UmbralAlerta.class)
                .getResultList();
    }

    public UmbralAlerta umbral(Integer id) {
        return em.find(UmbralAlerta.class, id);
    }

    /** Umbral del mismo recurso y ámbito (valorAmbito = null para GLOBAL), o null. */
    public UmbralAlerta buscarUmbral(String recurso, String ambito, String valorAmbito) {
        String jpql = "SELECT u FROM UmbralAlerta u WHERE UPPER(u.tipoRecurso) = :r AND UPPER(u.ambito) = :a AND "
                + (valorAmbito == null ? "u.valorAmbito IS NULL" : "u.valorAmbito = :v");
        TypedQuery<UmbralAlerta> q = em.createQuery(jpql, UmbralAlerta.class)
                .setParameter("r", recurso.toUpperCase())
                .setParameter("a", ambito.toUpperCase());
        if (valorAmbito != null) {
            q.setParameter("v", valorAmbito);
        }
        List<UmbralAlerta> r = q.setMaxResults(1).getResultList();
        return r.isEmpty() ? null : r.get(0);
    }

    public void crearUmbral(UmbralAlerta umbral) {
        em.persist(umbral);
    }
}
