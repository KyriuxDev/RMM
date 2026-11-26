package api;

import ingesta.ConfigAgente;
import ingesta.InventarioAgente;
import ingesta.RegistroAgente;
import ingesta.RespuestaIngesta;
import ingesta.TelemetriaAgente;
import jakarta.ejb.EJB;
import jakarta.enterprise.context.RequestScoped;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.ws.rs.Consumes;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.POST;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.QueryParam;
import jakarta.ws.rs.core.Context;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;
import logica_negocio.IngestaBean;

/**
 * Endpoints que usa el agente de monitoreo (checks activos: el agente siempre
 * inicia la conexión, como el agente de Zabbix en modo activo).
 *
 *   POST /api/agente/registro     primer enlace (HU-1)          → ConfigAgente
 *   POST /api/agente/telemetria   señal de vida + informe (HU-2) → RespuestaIngesta
 *   POST /api/agente/inventario   software y periféricos (HU-8)  → 204
 *   GET  /api/agente/config?mac=  intervalos vigentes            → ConfigAgente
 *   POST /api/agente/desconexion?mac=  apagado normal del agente → 204
 *
 * Todas piden el header X-RMM-Clave (ClaveAgenteFiltro).
 *
 * @author kyriux
 */
@Path("agente")
@RequestScoped
@Consumes(MediaType.APPLICATION_JSON)
@Produces(MediaType.APPLICATION_JSON)
public class AgenteResource {

    @EJB
    private IngestaBean ingesta;

    @Context
    private HttpServletRequest request;

    @POST
    @Path("registro")
    public ConfigAgente registrar(RegistroAgente datos) {
        return ingesta.registrar(datos);
    }

    @POST
    @Path("telemetria")
    public RespuestaIngesta telemetria(TelemetriaAgente datos) {
        return ingesta.registrarTelemetria(datos, ipOrigen());
    }

    @POST
    @Path("inventario")
    public Response inventario(InventarioAgente datos) {
        ingesta.registrarInventario(datos);
        return Response.noContent().build();
    }

    @GET
    @Path("config")
    public ConfigAgente config(@QueryParam("mac") String mac) {
        return ingesta.configuracion(mac);
    }

    @POST
    @Path("desconexion")
    @Consumes(MediaType.WILDCARD)
    public Response desconexion(@QueryParam("mac") String mac) {
        ingesta.desconectar(mac);
        return Response.noContent().build();
    }

    /** IP del agente; si viene por el Proxy Regional, la que éste puso en X-Forwarded-For. */
    private String ipOrigen() {
        String xff = request.getHeader("X-Forwarded-For");
        if (xff != null && !xff.isBlank()) {
            return xff.split(",")[0].trim();
        }
        return request.getRemoteAddr();
    }
}
