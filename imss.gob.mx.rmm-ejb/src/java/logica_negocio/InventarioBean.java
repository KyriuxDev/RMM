package logica_negocio;

import acceso_datos.AreaFacade;
import acceso_datos.EquipoFacade;
import acceso_datos.UsuarioFacade;
import excepciones.Excepciones;
import jakarta.ejb.EJB;
import jakarta.ejb.LocalBean;
import jakarta.ejb.Stateless;
import java.util.Date;
import modelo.Area;
import modelo.Equipo;
import modelo.Hardware;
import modelo.Usuario;

/**
 * Lógica de negocio de SD-05c Gestión manual de equipos. Por ahora cubre el
 * alta (alt operacion == "alta").
 *
 * Los formatos (hostname, MAC, IP, rangos de RAM/disco) los valida la vista
 * con los validadores del WAR. Aquí queda el respaldo: datos obligatorios,
 * área y responsable existentes, y verificarDuplicado(hostname, direccionMac).
 *
 * @author kyriux
 */
@Stateless
@LocalBean
public class InventarioBean {

    /** Valores de equipo.estado_conexion. */
    public static final String ESTADO_OFFLINE = "OFFLINE";
    public static final String ESTADO_INACTIVO = "INACTIVO";

    @EJB
    private EquipoFacade equipoFacade;

    @EJB
    private AreaFacade areaFacade;

    @EJB
    private UsuarioFacade usuarioFacade;

    /**
     * registrarEquipo(datos, idArea) de SD-05c.
     *
     * @param equipo        hostname, MAC, IP, SO y ubicación física capturados
     * @param hardware      especificaciones (puede venir vacío)
     * @param idArea        área (unidad / servicio) donde queda el equipo
     * @param idResponsable usuario responsable (opcional)
     * @return el equipo registrado, con su id asignado
     */
    public Equipo registrarEquipo(Equipo equipo, Hardware hardware, Integer idArea, Integer idResponsable) {
        if (equipo == null) {
            throw new Excepciones("Los datos del equipo son obligatorios");
        }
        normalizar(equipo);

        // Respaldo: datos obligatorios
        Validacion.requerido(equipo.getHostname(), "hostname", "El hostname es obligatorio");
        Validacion.requerido(equipo.getDireccionMac(), "mac", "La dirección MAC es obligatoria");
        Validacion.requerido(idArea, "area", "Seleccione la unidad / servicio");

        // verificarDuplicado(hostname, direccionMac)
        verificarDuplicado(equipo.getHostname(), equipo.getDireccionMac());

        Area area = areaFacade.find(idArea);
        if (area == null) {
            throw new Excepciones("area", "La unidad / servicio seleccionada no existe");
        }
        if (area.getIdUnidadHomologada() == null) {
            throw new Excepciones("area", "La unidad / servicio no pertenece a ningún hospital o sede");
        }
        equipo.setIdArea(area);

        if (idResponsable != null) {
            Usuario responsable = usuarioFacade.find(idResponsable);
            if (responsable == null) {
                throw new Excepciones("responsable", "El usuario responsable no existe");
            }
            equipo.setIdUsuario(responsable);
        }

        // crear(hostname, direccionMac, ubicacionFisica, area, responsable)
        equipo.setFechaRegistro(new Date());
        equipo.setEstaActivo(true);
        // actualizarEstado("OFFLINE"): todavía no reporta un agente
        equipo.setEstadoConexion(ESTADO_OFFLINE);

        // hw.crear(modeloCpu, nucleosCpu, totalRamGb, capacidadDiscoGb)
        if (hardware != null && tieneDatos(hardware)) {
            hardware.setModeloCpu(Validacion.limpiar(hardware.getModeloCpu()));
            hardware.setIdEquipo(equipo);
            equipo.setHardware(hardware);   // se inserta en cascada con el equipo
        }

        // insertarEquipo(datosEquipo)
        equipoFacade.create(equipo);

        // resultado
        return equipo;
    }

    /**
     * verificarDuplicado(hostname, direccionMac): lanza un error si alguno ya
     * está registrado en otro equipo.
     */
    public void verificarDuplicado(String hostname, String direccionMac) {
        verificarHostnameDisponible(hostname);
        verificarMacDisponible(direccionMac);
    }

    /** También la usa la vista (validador HostnameDisponibleValidator). */
    public void verificarHostnameDisponible(String hostname) {
        String h = normalizarHostname(hostname);
        if (h != null && equipoFacade.buscarPorHostname(h) != null) {
            throw new Excepciones("hostname", "Ya existe un equipo con el hostname " + h);
        }
    }

    /** También la usa la vista (validador MacDisponibleValidator). */
    public void verificarMacDisponible(String direccionMac) {
        String m = normalizarMac(direccionMac);
        if (m != null && equipoFacade.buscarPorMac(m) != null) {
            throw new Excepciones("mac", "La dirección MAC " + m + " ya está registrada en otro equipo");
        }
    }

    // ------------------------------------------------------------------
    // Auxiliares
    // ------------------------------------------------------------------

    /** Hostname en mayúsculas, MAC como AA:BB:CC:DD:EE:FF, textos sin espacios. */
    private void normalizar(Equipo e) {
        e.setHostname(normalizarHostname(e.getHostname()));
        e.setDireccionMac(normalizarMac(e.getDireccionMac()));
        e.setIpLocal(Validacion.limpiar(e.getIpLocal()));
        e.setNombreSo(Validacion.limpiar(e.getNombreSo()));
        e.setVersionSo(Validacion.limpiar(e.getVersionSo()));
        e.setUbicacionFisica(Validacion.limpiar(e.getUbicacionFisica()));
    }

    /** Hostname sin espacios y en mayúsculas (así lo reporta Windows). */
    public static String normalizarHostname(String hostname) {
        String h = Validacion.limpiar(hostname);
        return h == null ? null : h.toUpperCase();
    }

    /** MAC en mayúsculas y separada con ":" (acepta "-" al capturar). */
    public static String normalizarMac(String mac) {
        String m = Validacion.limpiar(mac);
        return m == null ? null : m.toUpperCase().replace('-', ':');
    }

    private boolean tieneDatos(Hardware h) {
        return Validacion.limpiar(h.getModeloCpu()) != null || h.getNucleosCpu() != null
                || h.getTotalRamGb() != null || h.getCapacidadDiscoGb() != null;
    }
}
