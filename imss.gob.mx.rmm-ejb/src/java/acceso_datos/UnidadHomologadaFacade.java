/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package acceso_datos;

import jakarta.ejb.Stateless;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import modelo.UnidadHomologada;

/**
 *
 * @author kyriux
 */
@Stateless
public class UnidadHomologadaFacade extends AbstractFacade<UnidadHomologada> {

    @PersistenceContext(unitName = "rmmPU")
    private EntityManager em;

    @Override
    protected EntityManager getEntityManager() {
        return em;
    }

    public UnidadHomologadaFacade() {
        super(UnidadHomologada.class);
    }
    
}
