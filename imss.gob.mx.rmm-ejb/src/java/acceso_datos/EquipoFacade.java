/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package acceso_datos;

import jakarta.ejb.Stateless;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.persistence.TypedQuery;
import java.util.List;
import java.util.Map;
import java.util.HashMap;
import modelo.Equipo;

/**
 *
 * @author kyriux
 */
@Stateless
public class EquipoFacade extends AbstractFacade<Equipo> {

    @PersistenceContext(unitName = "rmmPU")
    private EntityManager em;

    @Override
    protected EntityManager getEntityManager() {
        return em;
    }

    public EquipoFacade() {
        super(Equipo.class);
    }

    /** Equipo con ese hostname (sin distinguir mayúsculas), o null si no existe. */
    public Equipo buscarPorHostname(String hostname) {
        List<Equipo> r = em.createQuery(
                "SELECT e FROM Equipo e WHERE LOWER(e.hostname) = LOWER(:hostname)", Equipo.class)
                .setParameter("hostname", hostname)
                .setMaxResults(1)
                .getResultList();
        return r.isEmpty() ? null : r.get(0);
    }

    /** Equipo con esa dirección MAC, o null si no existe. */
    public Equipo buscarPorMac(String direccionMac) {
        List<Equipo> r = em.createNamedQuery("Equipo.findByDireccionMac", Equipo.class)
                .setParameter("direccionMac", direccionMac)
                .setMaxResults(1)
                .getResultList();
        return r.isEmpty() ? null : r.get(0);
    }


    /**
     * Lista del inventario (PR-12). texto busca en hostname, MAC, IP, hospital y
     * unidad / servicio; estado filtra por estado_conexion; idUnidadHomologada
     * por hospital / sede. Todos son opcionales.
     */
    public List<Equipo> buscarInventario(String texto, String estado, Short idUnidadHomologada) {
        StringBuilder jpql = new StringBuilder(
                "SELECT e FROM Equipo e LEFT JOIN e.idArea a LEFT JOIN a.idUnidadHomologada uh"
                + " LEFT JOIN a.idUnidadCc ucc LEFT JOIN ucc.claveCc cc WHERE 1 = 1");
        if (texto != null) {
            jpql.append(" AND (LOWER(e.hostname) LIKE :t OR LOWER(e.direccionMac) LIKE :t"
                    + " OR LOWER(e.ipLocal) LIKE :t OR LOWER(uh.nombre) LIKE :t OR LOWER(cc.descripcion) LIKE :t)");
        }
        if (estado != null) {
            jpql.append(" AND e.estadoConexion = :estado");
        }
        if (idUnidadHomologada != null) {
            jpql.append(" AND uh.idUnidadHomologada = :uh");
        }
        jpql.append(" ORDER BY e.estaActivo DESC, e.hostname");
        TypedQuery<Equipo> q = em.createQuery(jpql.toString(), Equipo.class);
        if (texto != null) {
            q.setParameter("t", "%" + texto.toLowerCase() + "%");
        }
        if (estado != null) {
            q.setParameter("estado", estado);
        }
        if (idUnidadHomologada != null) {
            q.setParameter("uh", idUnidadHomologada);
        }
        return q.getResultList();
    }

    /** Equipos activos de cada área: idArea → cantidad. */
    public Map<Integer, Long> contarActivosPorArea() {
        List<Object[]> filas = em.createQuery(
                "SELECT e.idArea.idArea, COUNT(e) FROM Equipo e"
                + " WHERE e.estaActivo = true AND e.idArea IS NOT NULL GROUP BY e.idArea.idArea", Object[].class)
                .getResultList();
        Map<Integer, Long> r = new HashMap<>();
        for (Object[] f : filas) {
            r.put((Integer) f[0], ((Number) f[1]).longValue());
        }
        return r;
    }

    /** Equipos de un área (primero los activos). */
    public List<Equipo> listarPorArea(Integer idArea) {
        return em.createQuery(
                "SELECT e FROM Equipo e WHERE e.idArea.idArea = :idArea ORDER BY e.estaActivo DESC, e.hostname",
                Equipo.class)
                .setParameter("idArea", idArea)
                .getResultList();
    }

    // ------------------------------------------------------------------
    // Tablero (Vista general)
    // ------------------------------------------------------------------

    /** Equipos activos por estado de conexión: ONLINE → n, OFFLINE → n, ... */
    public Map<String, Long> contarActivosPorEstado() {
        Map<String, Long> r = new HashMap<>();
        for (Object[] f : em.createQuery(
                "SELECT e.estadoConexion, COUNT(e) FROM Equipo e WHERE e.estaActivo = true GROUP BY e.estadoConexion",
                Object[].class).getResultList()) {
            r.put(f[0] == null ? "OFFLINE" : (String) f[0], ((Number) f[1]).longValue());
        }
        return r;
    }

    /** Equipos dados de baja. */
    public long contarBajas() {
        return em.createQuery("SELECT COUNT(e) FROM Equipo e WHERE e.estaActivo = false", Long.class)
                .getSingleResult();
    }

    /** Equipos activos por unidad y estado: [idUnidadHomologada, nombre, estadoConexion, cantidad]. */
    public List<Object[]> contarPorUnidadYEstado() {
        return em.createQuery(
                "SELECT uh.idUnidadHomologada, uh.nombre, e.estadoConexion, COUNT(e) FROM Equipo e"
                + " JOIN e.idArea a JOIN a.idUnidadHomologada uh"
                + " WHERE e.estaActivo = true"
                + " GROUP BY uh.idUnidadHomologada, uh.nombre, e.estadoConexion", Object[].class)
                .getResultList();
    }

    /** Equipos activos que no están en línea, primero los que llevan más tiempo sin señal. */
    public List<Equipo> listarSinSenal(int maximo) {
        return em.createQuery(
                "SELECT e FROM Equipo e WHERE e.estaActivo = true AND (e.estadoConexion IS NULL OR e.estadoConexion <> 'ONLINE')"
                + " ORDER BY e.ultimaSenal, e.fechaRegistro",   // en MySQL los NULL (nunca reportó) van primero
                Equipo.class)
                .setMaxResults(maximo)
                .getResultList();
    }

    /** Últimos equipos dados de alta. */
    public List<Equipo> listarUltimosRegistrados(int maximo) {
        return em.createQuery("SELECT e FROM Equipo e ORDER BY e.fechaRegistro DESC, e.idEquipo DESC", Equipo.class)
                .setMaxResults(maximo)
                .getResultList();
    }
}
