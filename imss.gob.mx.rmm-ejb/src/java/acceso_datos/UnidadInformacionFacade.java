/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package acceso_datos;

import jakarta.ejb.Stateless;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import modelo.UnidadInformacion;

/**
 *
 * @author kyriux
 */
@Stateless
public class UnidadInformacionFacade extends AbstractFacade<UnidadInformacion> {

    @PersistenceContext(unitName = "rmmPU")
    private EntityManager em;

    @Override
    protected EntityManager getEntityManager() {
        return em;
    }

    public UnidadInformacionFacade() {
        super(UnidadInformacion.class);
    }
    
}
