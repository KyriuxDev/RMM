package logica_negocio;

import acceso_datos.AreaFacade;
import acceso_datos.EquipoFacade;
import acceso_datos.UsuarioFacade;
import excepciones.Excepciones;
import jakarta.ejb.EJB;
import jakarta.ejb.LocalBean;
import jakarta.ejb.Stateless;
import java.util.Date;
import java.util.List;
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
        verificarHostnameDisponible(hostname, null);
    }

    /** Sin contar al equipo idExcluir (el que se está editando). */
    public void verificarHostnameDisponible(String hostname, Integer idExcluir) {
        String h = normalizarHostname(hostname);
        Equipo otro = h == null ? null : equipoFacade.buscarPorHostname(h);
        if (otro != null && !otro.getIdEquipo().equals(idExcluir)) {
            throw new Excepciones("hostname", "Ya existe un equipo con el hostname " + h);
        }
    }

    /** También la usa la vista (validador MacDisponibleValidator). */
    public void verificarMacDisponible(String direccionMac) {
        verificarMacDisponible(direccionMac, null);
    }

    /** Sin contar al equipo idExcluir (el que se está editando). */
    public void verificarMacDisponible(String direccionMac, Integer idExcluir) {
        String m = normalizarMac(direccionMac);
        Equipo otro = m == null ? null : equipoFacade.buscarPorMac(m);
        if (otro != null && !otro.getIdEquipo().equals(idExcluir)) {
            throw new Excepciones("mac", "La dirección MAC " + m + " ya está registrada en otro equipo");
        }
    }

    // ------------------------------------------------------------------
    // Inventario de equipos (lista) y edición / baja (SD-05c)
    // ------------------------------------------------------------------

    /** Estados que se pueden filtrar en la lista de equipos. */
    public static final List<String> ESTADOS = List.of("ONLINE", "OFFLINE", "ALERTA", ESTADO_INACTIVO);

    /** SN-05a consultarInventario(filtros): texto, estado y hospital / sede (opcionales). */
    public List<Equipo> listarEquipos(String texto, String estado, Short idUnidadHomologada) {
        return equipoFacade.buscarInventario(Validacion.limpiar(texto), Validacion.limpiar(estado), idUnidadHomologada);
    }

    public Equipo buscarEquipo(Integer idEquipo) {
        return idEquipo == null ? null : equipoFacade.find(idEquipo);
    }

    /** SD-05c editarEquipo(idEquipo, datos) → equipo.editarDatos(datos). */
    public Equipo editarEquipo(Integer idEquipo, Equipo datos, Hardware datosHw, Integer idArea, Integer idResponsable) {
        Equipo equipo = buscarEquipo(idEquipo);
        if (equipo == null) {
            throw new Excepciones("El equipo que intenta editar ya no existe");
        }
        if (!equipo.getEstaActivo()) {
            throw new Excepciones("El equipo está dado de baja; ya no se puede editar");
        }
        if (datos == null) {
            throw new Excepciones("Los datos del equipo son obligatorios");
        }
        normalizar(datos);
        Validacion.requerido(datos.getHostname(), "hostname", "El hostname es obligatorio");
        Validacion.requerido(datos.getDireccionMac(), "mac", "La dirección MAC es obligatoria");
        Validacion.requerido(idArea, "area", "Seleccione la unidad / servicio");
        verificarHostnameDisponible(datos.getHostname(), idEquipo);
        verificarMacDisponible(datos.getDireccionMac(), idEquipo);

        Area area = areaFacade.find(idArea);
        if (area == null) {
            throw new Excepciones("area", "La unidad / servicio seleccionada no existe");
        }
        Usuario responsable = null;
        if (idResponsable != null) {
            responsable = usuarioFacade.find(idResponsable);
            if (responsable == null) {
                throw new Excepciones("responsable", "El usuario responsable no existe");
            }
        }

        // editarDatos(datos)
        equipo.editarDatos(datos);
        equipo.setIdArea(area);
        equipo.setIdUsuario(responsable);

        // Hardware: se actualiza el existente o se crea si antes no había
        if (datosHw != null && tieneDatos(datosHw)) {
            Hardware hw = equipo.getHardware();
            if (hw == null) {
                hw = new Hardware();
                hw.setIdEquipo(equipo);
                equipo.setHardware(hw);
            }
            hw.setModeloCpu(Validacion.limpiar(datosHw.getModeloCpu()));
            hw.setNucleosCpu(datosHw.getNucleosCpu());
            hw.setTotalRamGb(datosHw.getTotalRamGb());
            hw.setCapacidadDiscoGb(datosHw.getCapacidadDiscoGb());
        }
        // actualizarEquipo(idEquipo, datos)
        equipoFacade.edit(equipo);
        return equipo;
    }

    /** SD-05c darDeBaja(idEquipo) → equipo.darDeBaja(confirmacion): queda INACTIVO. */
    public Equipo darDeBaja(Integer idEquipo, String motivo) {
        Equipo equipo = buscarEquipo(idEquipo);
        if (equipo == null) {
            throw new Excepciones("El equipo que intenta dar de baja ya no existe");
        }
        if (!equipo.getEstaActivo()) {
            throw new Excepciones("El equipo ya estaba dado de baja");
        }
        String m = Validacion.limpiar(motivo);
        Validacion.requerido(m, "motivoBaja", "Escriba el motivo de la baja");
        if (m.length() > 255) {
            throw new Excepciones("motivoBaja", "El motivo no puede pasar de 255 caracteres");
        }
        equipo.darDeBaja(m, new Date());
        // actualizarEstadoEquipo(idEquipo, "INACTIVO")
        equipoFacade.edit(equipo);
        return equipo;
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
