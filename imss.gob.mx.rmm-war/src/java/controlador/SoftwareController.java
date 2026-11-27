package controlador;

import excepciones.Excepciones;
import jakarta.annotation.PostConstruct;
import jakarta.ejb.EJB;
import jakarta.faces.view.ViewScoped;
import jakarta.inject.Named;
import java.io.Serializable;
import java.util.List;
import java.util.Locale;
import java.util.stream.Collectors;
import logica_negocio.SoftwareBean;
import logica_negocio.SoftwareBean.FilaSoftware;

/**
 * Inventario → Software no autorizado (HU-8).
 *
 *   - Tarjetas de resumen: clic = filtrar (no autorizado, sin revisar,
 *     desactualizado, autorizado, todos).
 *   - Tabla agrupada por software; al expandir un renglón se ven los equipos
 *     donde está instalado y qué versión tiene cada uno.
 *   - Autorizar / No autorizar aplica a todas las instalaciones de ese software.
 *
 * @author kyriux
 */
@Named("softwareCtrl")
@ViewScoped
public class SoftwareController implements Serializable {

    private static final long serialVersionUID = 1L;

    @EJB
    private SoftwareBean softwareBean;

    private String filtro;
    private String texto;

    private List<FilaSoftware> todos;
    private List<FilaSoftware> filas;

    @PostConstruct
    public void init() {
        consultar();
        // Al entrar: lo no autorizado si hay; si no, lo que falta revisar
        filtro = contar(SoftwareBean.FILTRO_NO_AUTORIZADO) > 0
                ? SoftwareBean.FILTRO_NO_AUTORIZADO : SoftwareBean.FILTRO_SIN_REVISAR;
        aplicarFiltro();
    }

    public void consultar() {
        todos = softwareBean.catalogo();
        aplicarFiltro();
    }

    public void filtrar(String nuevo) {
        filtro = nuevo == null ? "" : nuevo;
        aplicarFiltro();
    }

    public void limpiar() {
        texto = null;
        filtro = "";
        aplicarFiltro();
    }

    public void autorizar(FilaSoftware f) {
        marcar(f, Boolean.TRUE, "Software autorizado");
    }

    public void noAutorizar(FilaSoftware f) {
        marcar(f, Boolean.FALSE, "Software marcado como no autorizado");
    }

    public void sinRevisar(FilaSoftware f) {
        marcar(f, null, "Software regresado a \"sin revisar\"");
    }

    private void marcar(FilaSoftware f, Boolean valor, String resumen) {
        try {
            int n = softwareBean.marcar(f.getNombre(), valor);
            Mensajes.info(resumen, f.getNombre() + " (" + n + (n == 1 ? " equipo)" : " equipos)"));
            consultar();
        } catch (Excepciones e) {
            Mensajes.error("No se pudo guardar", e.getMessage());
        }
    }

    private void aplicarFiltro() {
        String t = texto == null ? "" : texto.trim().toLowerCase(Locale.ROOT);
        filas = todos.stream()
                .filter(f -> f.cumple(filtro))
                .filter(f -> t.isEmpty()
                        || f.getNombre().toLowerCase(Locale.ROOT).contains(t)
                        || (f.getFabricante() != null && f.getFabricante().toLowerCase(Locale.ROOT).contains(t)))
                .collect(Collectors.toList());
    }

    /** Cuántos software caen en ese filtro ("" = todos), sin el texto de búsqueda. */
    public long contar(String f) {
        return todos.stream().filter(x -> x.cumple(f)).count();
    }

    public boolean elegido(String f) {
        return (filtro == null ? "" : filtro).equals(f);
    }

    public String etiqueta(FilaSoftware f) {
        if (Boolean.FALSE.equals(f.getAutorizado())) {
            return "No autorizado";
        }
        return Boolean.TRUE.equals(f.getAutorizado()) ? "Autorizado" : "Sin revisar";
    }

    public String claseEstado(FilaSoftware f) {
        if (Boolean.FALSE.equals(f.getAutorizado())) {
            return "estado-inactivo";
        }
        return Boolean.TRUE.equals(f.getAutorizado()) ? "estado-activo" : "";
    }

    public String getFiltro() {
        return filtro;
    }

    public void setFiltro(String filtro) {
        this.filtro = filtro;
    }

    public String getTexto() {
        return texto;
    }

    public void setTexto(String texto) {
        this.texto = texto;
    }

    public List<FilaSoftware> getFilas() {
        return filas;
    }
}
