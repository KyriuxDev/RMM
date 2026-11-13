/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package acceso_datos;

import jakarta.ejb.Stateless;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import java.util.List;
import modelo.Usuario;

/**
 *
 * @author kyriux
 */
@Stateless
public class UsuarioFacade extends AbstractFacade<Usuario> {

    @PersistenceContext(unitName = "rmmPU")
    private EntityManager em;

    @Override
    protected EntityManager getEntityManager() {
        return em;
    }

    public UsuarioFacade() {
        super(Usuario.class);
    }

    /** Usuario con esa matrícula, o null si no existe. */
    public Usuario buscarPorMatricula(String matricula) {
        List<Usuario> r = em.createNamedQuery("Usuario.findByMatricula", Usuario.class)
                .setParameter("matricula", matricula)
                .getResultList();
        return r.isEmpty() ? null : r.get(0);
    }

    /** Usuario con ese correo, o null si no existe. */
    public Usuario buscarPorCorreo(String correo) {
        List<Usuario> r = em.createNamedQuery("Usuario.findByCorreo", Usuario.class)
                .setParameter("correo", correo)
                .getResultList();
        return r.isEmpty() ? null : r.get(0);
    }

}
