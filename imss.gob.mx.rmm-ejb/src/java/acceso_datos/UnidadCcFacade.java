/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package acceso_datos;

import jakarta.ejb.Stateless;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import modelo.UnidadCc;

/**
 *
 * @author kyriux
 */
@Stateless
public class UnidadCcFacade extends AbstractFacade<UnidadCc> {

    @PersistenceContext(unitName = "rmmPU")
    private EntityManager em;

    @Override
    protected EntityManager getEntityManager() {
        return em;
    }

    public UnidadCcFacade() {
        super(UnidadCc.class);
    }
    
}
