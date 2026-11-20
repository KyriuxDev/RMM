package controlador;

import excepciones.Excepciones;
import jakarta.annotation.PostConstruct;
import jakarta.ejb.EJB;
import jakarta.faces.context.FacesContext;
import jakarta.faces.view.ViewScoped;
import jakarta.inject.Named;
import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;
import logica_negocio.AdministracionBean;
import logica_negocio.CatalogoUnidadesBean;
import logica_negocio.InventarioBean;
import modelo.Area;
import modelo.Equipo;
import modelo.Hardware;
import modelo.UnidadHomologada;
import modelo.Usuario;

/**
 * Controlador de Inventario → Alta y edición de equipo (PR-14).
 * Es inventarioCtrl en SD-05c Gestión manual de equipos:
 *
 *   seleccionarHospital(idUnidadHomologada) → listarAreas(idUnidadHomologada) → areas
 *   (hospital / sede = tabla unidad_homologada)
 *
 *   [alta]    guardarNuevoEquipo(datos) → registrarEquipo(datos) → mostrarResultado(resultado)
 *   [edición] cargarEquipo(id) (alta-equipo.xhtml?id=N)
 *             guardarCambios(idEquipo, datos) → editarEquipo(idEquipo, datos)
 *   [baja]    confirmarBaja() (diálogo) → darDeBaja(idEquipo) → equipo INACTIVO
 *
 * @author kyriux
 */
@Named("inventarioCtrl")
@ViewScoped
public class InventarioController implements Serializable {

    private static final long serialVersionUID = 1L;

    static final String LISTA = "/vista/inventario/equipos.xhtml?faces-redirect=true";

    @EJB
    private InventarioBean inventarioBean;

    @EJB
    private CatalogoUnidadesBean catalogoBean;

    @EJB
    private AdministracionBean administracionBean;

    // Formulario
    private Equipo nuevo;
    private Hardware hardware;
    private Short idUnidadHomologada;
    private Integer idArea;
    private Integer idResponsable;

    /** Parámetro "id" de la URL: null en un alta, el id del equipo al editar. */
    private Integer idEquipo;
    /** Parámetro "area" de la URL (desde Estructura): alta con el destino ya elegido. */
    private Integer idAreaInicial;
    /** Motivo capturado en el diálogo de baja (PR-14 "Motivo de la baja"). */
    private String motivoBaja;

    // Datos de la pantalla
    private List<UnidadHomologada> hospitales;
    private List<Area> areas;
    private List<Usuario> responsables;
    private Equipo registrado;

    @PostConstruct
    public void init() {
        hospitales = catalogoBean.listarUnidadesHomologadas();
        responsables = administracionBean.listarUsuariosActivos();
        limpiarFormulario();
    }

    /** f:viewAction de alta-equipo.xhtml: con ?id=N carga el equipo a editar. */
    public String cargarEquipo() {
        if (idEquipo == null) {
            elegirAreaInicial();
            return null;
        }
        Equipo e = inventarioBean.buscarEquipo(idEquipo);
        if (e == null || !e.getEstaActivo()) {
            FacesContext.getCurrentInstance().getExternalContext().getFlash().setKeepMessages(true);
            Mensajes.error("No se puede editar el equipo",
                    e == null ? "El equipo ya no existe." : "El equipo " + e.getHostname() + " está dado de baja.");
            return LISTA;
        }
        // Copia de los datos para el formulario
        nuevo = new Equipo();
        nuevo.setHostname(e.getHostname());
        nuevo.setDireccionMac(e.getDireccionMac());
        nuevo.setIpLocal(e.getIpLocal());
        nuevo.setNombreSo(e.getNombreSo());
        nuevo.setVersionSo(e.getVersionSo());
        nuevo.setUbicacionFisica(e.getUbicacionFisica());
        nuevo.setEstadoConexion(e.getEstadoConexion());
        hardware = new Hardware();
        if (e.getHardware() != null) {
            hardware.setModeloCpu(e.getHardware().getModeloCpu());
            hardware.setNucleosCpu(e.getHardware().getNucleosCpu());
            hardware.setTotalRamGb(e.getHardware().getTotalRamGb());
            hardware.setCapacidadDiscoGb(e.getHardware().getCapacidadDiscoGb());
        }
        Area area = e.getIdArea();
        idUnidadHomologada = area == null || area.getIdUnidadHomologada() == null
                ? null : area.getIdUnidadHomologada().getIdUnidadHomologada();
        areas = catalogoBean.listarAreas(idUnidadHomologada);
        idArea = area == null ? null : area.getIdArea();
        idResponsable = e.getIdUsuario() == null ? null : e.getIdUsuario().getIdUsuario();
        motivoBaja = null;
        return null;
    }

    /** Unidad elegida: se cargan sus áreas; si sólo tiene una, se elige sola. */
    public void seleccionarHospital() {
        idArea = null;
        areas = catalogoBean.listarAreas(idUnidadHomologada);
        if (areas.size() == 1) {
            idArea = areas.get(0).getIdArea();
        }
    }

    /** ?area=N (desde Estructura): deja elegidos la unidad y el área. */
    private void elegirAreaInicial() {
        Area a = catalogoBean.buscarArea(idAreaInicial);
        if (a == null || a.getIdUnidadHomologada() == null) {
            return;
        }
        idUnidadHomologada = a.getIdUnidadHomologada().getIdUnidadHomologada();
        areas = catalogoBean.listarAreas(idUnidadHomologada);
        idArea = a.getIdArea();
    }

    /** Debajo de "Unidad": tipo · región · zona. */
    public String getDetalleUnidad() {
        if (idUnidadHomologada == null || hospitales == null) {
            return null;
        }
        for (UnidadHomologada u : hospitales) {
            if (u.getIdUnidadHomologada().equals(idUnidadHomologada)) {
                List<String> partes = new ArrayList<>();
                if (u.getIdClasificacion() != null) {
                    partes.add(u.getIdClasificacion().getSubTipoUnidad());
                }
                if (u.getNumZona() != null) {
                    if (u.getNumZona().getIdRegion() != null) {
                        partes.add(u.getNumZona().getIdRegion().getNombre());
                    }
                    partes.add("zona " + u.getNumZona().getNumZona());
                } else if (u.getIdRegion() != null) {
                    partes.add(u.getIdRegion().getNombre());
                }
                partes.removeIf(x -> x == null || x.isBlank());
                return String.join(" · ", partes);
            }
        }
        return null;
    }

    /** Debajo de "Área": clave · inmueble. */
    public String getDetalleArea() {
        Area a = areaSeleccionada();
        if (a == null) {
            return null;
        }
        String inmueble = getInmueble();
        return a.getClave() + (inmueble == null ? "" : " · inmueble " + inmueble);
    }

    /** SD-05c guardarNuevoEquipo(datos). */
    public void guardarNuevoEquipo() {
        try {
            registrado = inventarioBean.registrarEquipo(nuevo, hardware, idArea, idResponsable);
            // mostrarResultado(resultado)
            Mensajes.info("Equipo registrado",
                    registrado.getHostname() + " (" + registrado.getDireccionMac()
                    + ") quedó en estado OFFLINE hasta que su agente reporte.");
            limpiarFormulario();
        } catch (Excepciones e) {
            // Respaldo del EJB (por ejemplo, la MAC se registró mientras se llenaba el formulario)
            Mensajes.error("formEquipo", e, "No se pudo registrar el equipo");
        }
    }

    /** SD-05c guardarCambios(idEquipo, datos). Regresa a la lista si todo salió bien. */
    public String guardarCambios() {
        try {
            Equipo editado = inventarioBean.editarEquipo(idEquipo, nuevo, hardware, idArea, idResponsable);
            FacesContext.getCurrentInstance().getExternalContext().getFlash().setKeepMessages(true);
            Mensajes.info("Equipo actualizado", "Se guardaron los cambios de " + editado.getHostname() + ".");
            return LISTA;
        } catch (Excepciones e) {
            Mensajes.error("formEquipo", e, "No se pudieron guardar los cambios");
            return null;
        }
    }

    /** SD-05c darDeBaja(idEquipo), después de confirmarBaja() en el diálogo. */
    public String darDeBaja() {
        try {
            Equipo baja = inventarioBean.darDeBaja(idEquipo, motivoBaja);
            FacesContext.getCurrentInstance().getExternalContext().getFlash().setKeepMessages(true);
            Mensajes.info("Equipo dado de baja",
                    baja.getHostname() + " quedó INACTIVO; su historial se conserva.");
            return LISTA;
        } catch (Excepciones e) {
            Mensajes.error("formBaja", e, "No se pudo dar de baja el equipo");
            return null;
        }
    }

    /** Alta: limpia el formulario. Edición: regresa a la lista sin guardar. */
    public String cancelar() {
        if (isEditando()) {
            return LISTA;
        }
        limpiarFormulario();
        return null;
    }

    public boolean isEditando() {
        return idEquipo != null;
    }

    public String getInmueble() {
        Area a = areaSeleccionada();
        if (a == null || a.getCodigoUbicacion() == null) {
            return null;
        }
        return a.getCodigoUbicacion().getCodigoUbicacion() + " – " + a.getCodigoUbicacion().getDescripcion();
    }

    public String etiquetaArea(Area a) {
        return a.getIdUnidadCc().getClaveCc().getDescripcion()
                + " (" + a.getIdUnidadCc().getClaveCc().getClaveCc()
                + " " + a.getDivision() + "-" + a.getSubdivision() + ")";
    }

    private Area areaSeleccionada() {
        if (idArea == null || areas == null) {
            return null;
        }
        for (Area a : areas) {
            if (a.getIdArea().equals(idArea)) {
                return a;
            }
        }
        return null;
    }

    private void limpiarFormulario() {
        nuevo = new Equipo();
        hardware = new Hardware();
        idUnidadHomologada = null;
        idArea = null;
        idResponsable = null;
        areas = new ArrayList<>();
        motivoBaja = null;
    }

    // Getters y setters

    public Equipo getNuevo() {
        return nuevo;
    }

    public Hardware getHardware() {
        return hardware;
    }

    public Short getIdUnidadHomologada() {
        return idUnidadHomologada;
    }

    public void setIdUnidadHomologada(Short idUnidadHomologada) {
        this.idUnidadHomologada = idUnidadHomologada;
    }

    public Integer getIdArea() {
        return idArea;
    }

    public void setIdArea(Integer idArea) {
        this.idArea = idArea;
    }

    public Integer getIdResponsable() {
        return idResponsable;
    }

    public void setIdResponsable(Integer idResponsable) {
        this.idResponsable = idResponsable;
    }

    public Integer getIdEquipo() {
        return idEquipo;
    }

    public void setIdEquipo(Integer idEquipo) {
        this.idEquipo = idEquipo;
    }

    public Integer getIdAreaInicial() {
        return idAreaInicial;
    }

    public void setIdAreaInicial(Integer idAreaInicial) {
        this.idAreaInicial = idAreaInicial;
    }

    public String getMotivoBaja() {
        return motivoBaja;
    }

    public void setMotivoBaja(String motivoBaja) {
        this.motivoBaja = motivoBaja;
    }

    public List<UnidadHomologada> getHospitales() {
        return hospitales;
    }

    public List<Area> getAreas() {
        return areas;
    }

    public List<Usuario> getResponsables() {
        return responsables;
    }

    public Equipo getRegistrado() {
        return registrado;
    }
}
