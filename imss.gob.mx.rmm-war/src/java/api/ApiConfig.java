package api;

import jakarta.ws.rs.ApplicationPath;
import jakarta.ws.rs.core.Application;

/**
 * API de Ingesta (REST) que usan los agentes: /rmm/api/...
 *
 * No pasa por FiltroAcceso (ése sólo cubre /faces/vista/*); la protege
 * ClaveAgenteFiltro con la clave compartida de los agentes.
 *
 * @author kyriux
 */
@ApplicationPath("api")
public class ApiConfig extends Application {
}
