/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package acceso_datos;

import jakarta.ejb.Stateless;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import modelo.Incidencia;

/**
 *
 * @author kyriux
 */
@Stateless
public class IncidenciaFacade extends AbstractFacade<Incidencia> {

    @PersistenceContext(unitName = "rmmPU")
    private EntityManager em;

    @Override
    protected EntityManager getEntityManager() {
        return em;
    }

    public IncidenciaFacade() {
        super(Incidencia.class);
    }
    

    /** Incidencias abiertas o en proceso. */
    public long contarAbiertas() {
        return em.createQuery("SELECT COUNT(i) FROM Incidencia i"
                + " WHERE UPPER(i.estado) IN ('ABIERTA', 'ENPROCESO', 'EN PROCESO', 'EN_PROCESO')", Long.class)
                .getSingleResult();
    }
}
