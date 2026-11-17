/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package acceso_datos;

import jakarta.ejb.Stateless;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import java.util.List;
import jakarta.persistence.TypedQuery;
import modelo.Area;

/**
 *
 * @author kyriux
 */
@Stateless
public class AreaFacade extends AbstractFacade<Area> {

    @PersistenceContext(unitName = "rmmPU")
    private EntityManager em;

    @Override
    protected EntityManager getEntityManager() {
        return em;
    }

    public AreaFacade() {
        super(Area.class);
    }

    /**
     * Áreas (unidad / servicio) de una unidad homologada (hospital o sede),
     * ordenadas por centro de costo, división y subdivisión.
     */
    public List<Area> listarPorUnidadHomologada(Short idUnidadHomologada) {
        return em.createQuery(
                "SELECT a FROM Area a JOIN a.idUnidadCc ucc JOIN ucc.claveCc cc"
                + " WHERE a.idUnidadHomologada.idUnidadHomologada = :idUh"
                + " ORDER BY cc.descripcion, a.division, a.subdivision", Area.class)
                .setParameter("idUh", idUnidadHomologada)
                .getResultList();
    }

    /**
     * recuperarUnidades(filtro) de SD-07b.
     *
     * @param texto      busca en clave/nombre de la unidad, centro de costo,
     *                   nombre homologado e inmueble (null = sin filtro)
     * @param idRegion   región de la unidad homologada (null = todas)
     * @param regimen    ORDINARIO o EX BIENESTAR (null = todos)
     * @param idUnidadHomologada hospital o sede (null = todos)
     */
    public List<Area> buscarCatalogo(String texto, Short idRegion, String regimen, Short idUnidadHomologada) {
        StringBuilder jpql = new StringBuilder(
                "SELECT a FROM Area a"
                + " JOIN a.idUnidadCc ucc JOIN ucc.claveUi ui JOIN ucc.claveCc cc"
                + " LEFT JOIN a.codigoUbicacion ub"
                + " LEFT JOIN a.idUnidadHomologada uh"
                + " LEFT JOIN uh.idRegion r"
                + " LEFT JOIN uh.numZona z LEFT JOIN z.idRegion rz"
                + " WHERE 1 = 1");
        if (texto != null) {
            jpql.append(" AND (LOWER(ui.claveUi) LIKE :texto OR LOWER(ui.descripcion) LIKE :texto"
                    + " OR LOWER(cc.claveCc) LIKE :texto OR LOWER(cc.descripcion) LIKE :texto"
                    + " OR LOWER(uh.nombre) LIKE :texto OR LOWER(ub.descripcion) LIKE :texto)");
        }
        if (idRegion != null) {
            jpql.append(" AND (r.idRegion = :idRegion OR rz.idRegion = :idRegion)");
        }
        if (regimen != null) {
            jpql.append(" AND ui.tipoRegimen = :regimen");
        }
        if (idUnidadHomologada != null) {
            jpql.append(" AND uh.idUnidadHomologada = :idUh");
        }
        jpql.append(" ORDER BY uh.nombre, cc.descripcion, a.division, a.subdivision");

        TypedQuery<Area> q = em.createQuery(jpql.toString(), Area.class);
        if (texto != null) {
            q.setParameter("texto", "%" + texto.toLowerCase() + "%");
        }
        if (idRegion != null) {
            q.setParameter("idRegion", idRegion);
        }
        if (regimen != null) {
            q.setParameter("regimen", regimen);
        }
        if (idUnidadHomologada != null) {
            q.setParameter("idUh", idUnidadHomologada);
        }
        return q.getResultList();
    }

}
