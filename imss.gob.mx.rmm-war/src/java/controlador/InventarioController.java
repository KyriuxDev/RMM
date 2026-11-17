package controlador;

import excepciones.Excepciones;
import jakarta.annotation.PostConstruct;
import jakarta.ejb.EJB;
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
 * Controlador de Inventario → Alta de equipo (PR-14).
 * Es inventarioCtrl en SD-05c Gestión manual de equipos, rama operacion == "alta":
 *
 *   seleccionarHospital(idUnidadHomologada) → listarAreas(idUnidadHomologada) → areas
 *   (hospital / sede = tabla unidad_homologada)
 *   guardarNuevoEquipo(datos, idArea) → validarCamposObligatorios() (la vista)
 *     → registrarEquipo(datos, idArea) → mostrarResultado(resultado)
 *
 * @author kyriux
 */
@Named("inventarioCtrl")
@ViewScoped
public class InventarioController implements Serializable {

    private static final long serialVersionUID = 1L;

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

    // Datos de la pantalla
    private List<UnidadHomologada> hospitales;
    private List<Area> areas;
    private List<Usuario> responsables;

    /** Último equipo registrado (para el mensaje de resultado). */
    private Equipo registrado;

    @PostConstruct
    public void init() {
        hospitales = catalogoBean.listarUnidadesHomologadas();
        responsables = administracionBean.listarUsuariosActivos();
        limpiarFormulario();
    }

    /** seleccionarHospital(idUnidadHomologada) → listarAreas(idUnidadHomologada) */
    public void seleccionarHospital() {
        idArea = null;
        areas = catalogoBean.listarAreas(idUnidadHomologada);
    }

    /** guardarNuevoEquipo(datos, idArea) → registrarEquipo(datos, idArea) */
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

    /** Botón "Cancelar": descarta lo capturado. */
    public void cancelar() {
        limpiarFormulario();
    }

    /** Inmueble del área seleccionada (se muestra como dato automático). */
    public String getInmueble() {
        Area a = areaSeleccionada();
        if (a == null || a.getCodigoUbicacion() == null) {
            return null;
        }
        return a.getCodigoUbicacion().getCodigoUbicacion() + " – " + a.getCodigoUbicacion().getDescripcion();
    }

    /** Texto con el que se muestra un área en la lista. */
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
