package acceso_datos;

import jakarta.ejb.Stateless;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import java.util.List;
import modelo.Software;

/**
 * Consultas del catálogo de software (HU-8): todo el software instalado en
 * los equipos activos y la marca "autorizado", que se maneja por nombre.
 *
 * @author kyriux
 */
@Stateless
public class CatalogoSoftwareFacade {

    @PersistenceContext(unitName = "rmmPU")
    private EntityManager em;

    /** Software de los equipos activos, con su equipo ya cargado. */
    public List<Software> softwareEquiposActivos() {
        return em.createQuery(
                "SELECT s FROM Software s JOIN FETCH s.idEquipo e WHERE e.estaActivo = true"
                + " ORDER BY s.nombre", Software.class)
                .getResultList();
    }

    /**
     * Marca todas las instalaciones de un software (por nombre, sin importar
     * mayúsculas). autorizado = null lo regresa a "sin revisar".
     *
     * @return cuántos registros cambiaron
     */
    public int marcarAutorizado(String nombre, Boolean autorizado) {
        return em.createQuery(
                "UPDATE Software s SET s.autorizado = :a WHERE LOWER(s.nombre) = :n")
                .setParameter("a", autorizado)
                .setParameter("n", nombre.toLowerCase(java.util.Locale.ROOT))
                .executeUpdate();
    }

    public Software editar(Software s) {
        return em.merge(s);
    }
}
