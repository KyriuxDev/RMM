/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package acceso_datos;

import jakarta.ejb.Stateless;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import java.util.List;
import modelo.Sla;

/**
 *
 * @author kyriux
 */
@Stateless
public class SlaFacade extends AbstractFacade<Sla> {

    @PersistenceContext(unitName = "rmmPU")
    private EntityManager em;

    @Override
    protected EntityManager getEntityManager() {
        return em;
    }

    public SlaFacade() {
        super(Sla.class);
    }

    /**
     * Meta registrada para el mismo indicador y ámbito, o null si no existe
     * (metaExistente en SD-07c).
     */
    public Sla buscarMeta(String nombreIndicador, String ambito, String valorAmbito) {
        String jpql = "SELECT s FROM Sla s WHERE s.nombreIndicador = :indicador AND s.ambito = :ambito"
                + (valorAmbito == null ? " AND s.valorAmbito IS NULL" : " AND s.valorAmbito = :valor");
        var q = em.createQuery(jpql, Sla.class)
                .setParameter("indicador", nombreIndicador)
                .setParameter("ambito", ambito);
        if (valorAmbito != null) {
            q.setParameter("valor", valorAmbito);
        }
        List<Sla> r = q.setMaxResults(1).getResultList();
        return r.isEmpty() ? null : r.get(0);
    }

}
