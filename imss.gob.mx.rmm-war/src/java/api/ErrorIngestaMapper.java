package api;

import excepciones.Excepciones;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;
import jakarta.ws.rs.ext.ExceptionMapper;
import jakarta.ws.rs.ext.Provider;
import java.util.Map;
import logica_negocio.IngestaBean;

/**
 * Traduce las Excepciones de IngestaBean a códigos HTTP que el agente entiende:
 *   404 no registrado → el agente se vuelve a registrar
 *   410 dado de baja  → el agente deja de reportar
 *   409 conflicto     → hostname/MAC en otro equipo (lo revisa un técnico)
 *   400 datos         → petición mal formada
 *
 * @author kyriux
 */
@Provider
public class ErrorIngestaMapper implements ExceptionMapper<Excepciones> {

    @Override
    public Response toResponse(Excepciones e) {
        String codigo = e.getCampo() == null ? "agente.datos" : e.getCampo();
        int status = switch (codigo) {
            case IngestaBean.ERR_NO_REGISTRADO -> 404;
            case IngestaBean.ERR_BAJA -> 410;
            case IngestaBean.ERR_CONFLICTO -> 409;
            default -> 400;
        };
        return Response.status(status)
                .type(MediaType.APPLICATION_JSON)
                .entity(Map.of("error", codigo, "mensaje", String.valueOf(e.getMessage())))
                .build();
    }
}
