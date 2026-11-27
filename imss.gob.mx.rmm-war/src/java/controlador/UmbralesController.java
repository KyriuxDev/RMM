package controlador;

import excepciones.Excepciones;
import jakarta.annotation.PostConstruct;
import jakarta.ejb.EJB;
import jakarta.faces.view.ViewScoped;
import jakarta.inject.Named;
import java.io.Serializable;
import java.util.Collections;
import java.util.List;
import logica_negocio.UmbralesBean;
import logica_negocio.UmbralesBean.FilaUmbral;
import modelo.UnidadHomologada;

/**
 * Alertas → Umbrales (HU-3, Figura "06 · Umbrales de alerta").
 * Los cambios se aplican de inmediato: IngestaBean lee los umbrales activos
 * en cada captura. El más específico gana: equipo > unidad > global.
 *
 * @author jose
 */
@Named("umbralesCtrl")
@ViewScoped
public class UmbralesController implements Serializable {

    private static final long serialVersionUID = 1L;

    @EJB
    private UmbralesBean umbralesBean;

    // Formulario "Nuevo umbral"
    private String recurso;
    private Double valor;
    private String ambito = UmbralesBean.AMBITO_GLOBAL;
    private Short idUnidad;
    private String hostname;

    private List<FilaUmbral> filas = Collections.emptyList();
    private List<UnidadHomologada> unidades = Collections.emptyList();

    @PostConstruct
    public void init() {
        unidades = umbralesBean.unidades();
        recargar();
    }

    public void guardar() {
        try {
            String valorAmbito = UmbralesBean.AMBITO_UNIDAD.equals(ambito)
                    ? (idUnidad == null ? null : String.valueOf(idUnidad))
                    : UmbralesBean.AMBITO_EQUIPO.equals(ambito) ? hostname : null;
            boolean nuevo = umbralesBean.guardar(recurso, valor, ambito, valorAmbito);
            Mensajes.info(nuevo ? "Umbral guardado" : "Umbral actualizado",
                    "Se aplica desde la siguiente captura de los equipos.");
            limpiar();
            recargar();
        } catch (Excepciones e) {
            Mensajes.error("No se pudo guardar el umbral", e.getMessage());
        }
    }

    public void cambiarEstado(FilaUmbral f) {
        try {
            umbralesBean.cambiarEstado(f.getId(), !f.isActivo());
            Mensajes.info(f.isActivo() ? "Umbral desactivado" : "Umbral activado",
                    f.getEtiquetaRecurso() + " · " + f.getAmbito());
        } catch (Excepciones e) {
            Mensajes.error("No se pudo cambiar el umbral", e.getMessage());
        }
        recargar();
    }

    public void limpiar() {
        recurso = null;
        valor = null;
        ambito = UmbralesBean.AMBITO_GLOBAL;
        idUnidad = null;
        hostname = null;
    }

    private void recargar() {
        filas = umbralesBean.listar();
    }

    public boolean isPorUnidad() {
        return UmbralesBean.AMBITO_UNIDAD.equals(ambito);
    }

    public boolean isPorEquipo() {
        return UmbralesBean.AMBITO_EQUIPO.equals(ambito);
    }

    // Getters y setters

    public String getRecurso() {
        return recurso;
    }

    public void setRecurso(String recurso) {
        this.recurso = recurso;
    }

    public Double getValor() {
        return valor;
    }

    public void setValor(Double valor) {
        this.valor = valor;
    }

    public String getAmbito() {
        return ambito;
    }

    public void setAmbito(String ambito) {
        this.ambito = ambito;
    }

    public Short getIdUnidad() {
        return idUnidad;
    }

    public void setIdUnidad(Short idUnidad) {
        this.idUnidad = idUnidad;
    }

    public String getHostname() {
        return hostname;
    }

    public void setHostname(String hostname) {
        this.hostname = hostname;
    }

    public List<FilaUmbral> getFilas() {
        return filas;
    }

    public List<UnidadHomologada> getUnidades() {
        return unidades;
    }
}
