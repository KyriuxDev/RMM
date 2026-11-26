package api;

import jakarta.ws.rs.container.ContainerRequestContext;
import jakarta.ws.rs.container.ContainerRequestFilter;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;
import jakarta.ws.rs.ext.Provider;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.util.Map;
import java.util.logging.Logger;

/**
 * Autentica al agente con una clave compartida en el header X-RMM-Clave
 * (como la PSK del agente de Zabbix). La clave del servidor se configura con
 *   asadmin create-jvm-options "-Drmm.agente.clave=LA_CLAVE"
 * o con la variable de entorno RMM_AGENTE_CLAVE.
 *
 * Junto con HTTPS evita que cualquiera en la red mande telemetría falsa.
 *
 * @author kyriux
 */
@Provider
public class ClaveAgenteFiltro implements ContainerRequestFilter {

    public static final String HEADER = "X-RMM-Clave";
    private static final String CLAVE_DE_EJEMPLO = "cambiar-esta-clave";
    private static final Logger LOG = Logger.getLogger(ClaveAgenteFiltro.class.getName());

    private static final byte[] CLAVE = clave().getBytes(StandardCharsets.UTF_8);

    private static String clave() {
        String c = System.getProperty("rmm.agente.clave");
        if (c == null || c.isBlank()) {
            c = System.getenv("RMM_AGENTE_CLAVE");
        }
        if (c == null || c.isBlank()) {
            LOG.warning("RMM: no se configuró rmm.agente.clave; se usa la clave de ejemplo. Cámbiela en producción.");
            c = CLAVE_DE_EJEMPLO;
        }
        return c.trim();
    }

    @Override
    public void filter(ContainerRequestContext ctx) {
        String recibida = ctx.getHeaderString(HEADER);
        boolean valida = recibida != null
                && MessageDigest.isEqual(CLAVE, recibida.trim().getBytes(StandardCharsets.UTF_8));
        if (!valida) {
            ctx.abortWith(Response.status(Response.Status.UNAUTHORIZED)
                    .type(MediaType.APPLICATION_JSON)
                    .entity(Map.of("error", "agente.clave", "mensaje", "Clave de agente inválida"))
                    .build());
        }
    }
}
