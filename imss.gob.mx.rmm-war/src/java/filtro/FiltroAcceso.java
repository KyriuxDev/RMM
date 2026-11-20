package filtro;

import controlador.AuthController;
import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.Set;
import logica_negocio.Permiso;
import logica_negocio.UsuarioSesion;

/**
 * Control de acceso a las vistas (PR-19 Acceso denegado y sesión expirada).
 *
 *   - Login y "Sesión expirada" son públicas.
 *   - Sin sesión: si el navegador traía una sesión que ya venció, va a
 *     "Sesión expirada"; si no, al login.
 *   - Con sesión: cada carpeta /vista/<módulo>/ pide su permiso
 *     (Permiso.paraRuta). Si el rol no lo tiene, va a "Acceso denegado".
 *   - Las páginas protegidas no se guardan en caché, para que el botón
 *     "Atrás" no muestre datos después de cerrar sesión.
 *
 * @author kyriux
 */
@WebFilter(filterName = "FiltroAcceso", urlPatterns = "/faces/vista/*")
public class FiltroAcceso implements Filter {

    private static final String PREFIJO = "/faces";

    private static final Set<String> PUBLICAS = Set.of(
            AuthController.LOGIN,
            AuthController.SESION_EXPIRADA);

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;

        String ruta = rutaDeVista(req);
        if (PUBLICAS.contains(ruta)) {
            chain.doFilter(request, response);
            return;
        }

        sinCache(resp);
        HttpSession sesion = req.getSession(false);
        UsuarioSesion usuario = sesion == null ? null
                : (UsuarioSesion) sesion.getAttribute(AuthController.ATRIBUTO_SESION);

        if (usuario == null) {
            boolean expirada = req.getRequestedSessionId() != null && !req.isRequestedSessionIdValid();
            redirigir(req, resp, expirada ? AuthController.SESION_EXPIRADA : AuthController.LOGIN);
            return;
        }

        Permiso requerido = Permiso.paraRuta(ruta);
        if (requerido != null && !usuario.tienePermiso(requerido)) {
            redirigir(req, resp, AuthController.ACCESO_DENEGADO + "?modulo=" + requerido.name());
            return;
        }
        chain.doFilter(request, response);
    }

    /** "/rmm/faces/vista/inventario/equipos.xhtml" → "/vista/inventario/equipos.xhtml". */
    static String rutaDeVista(HttpServletRequest req) {
        String ruta = req.getRequestURI().substring(req.getContextPath().length());
        if (ruta.startsWith(PREFIJO)) {
            ruta = ruta.substring(PREFIJO.length());
        }
        int pc = ruta.indexOf(';');          // quita ";jsessionid=..."
        return pc >= 0 ? ruta.substring(0, pc) : ruta;
    }

    private static void redirigir(HttpServletRequest req, HttpServletResponse resp, String vista) throws IOException {
        String url = req.getContextPath() + PREFIJO + vista;
        if ("partial/ajax".equals(req.getHeader("Faces-Request"))) {
            // Petición AJAX de PrimeFaces: la redirección se manda como respuesta parcial de Faces
            resp.setContentType("text/xml");
            resp.setCharacterEncoding("UTF-8");
            resp.getWriter().printf("<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
                    + "<partial-response><redirect url=\"%s\"/></partial-response>", url.replace("&", "&amp;"));
        } else {
            resp.sendRedirect(url);
        }
    }

    private static void sinCache(HttpServletResponse resp) {
        resp.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        resp.setHeader("Pragma", "no-cache");
        resp.setDateHeader("Expires", 0);
    }
}
