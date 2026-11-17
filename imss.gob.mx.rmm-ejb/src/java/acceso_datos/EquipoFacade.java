/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package acceso_datos;

import jakarta.ejb.Stateless;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import java.util.List;
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

}
