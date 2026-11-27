package logica_negocio;

import acceso_datos.EquipoFacade;
import acceso_datos.GestionAlertasFacade;
import excepciones.Excepciones;
import jakarta.ejb.EJB;
import jakarta.ejb.LocalBean;
import jakarta.ejb.Stateless;
import java.io.Serializable;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import modelo.Equipo;
import modelo.UmbralAlerta;
import modelo.UnidadHomologada;

/**
 * Lógica de Alertas → Umbrales (HU-3).
 *
 * IngestaBean lee los umbrales activos en cada captura del agente, así que lo
 * que se guarda aquí se aplica de inmediato, sin reiniciar nada. El umbral más
 * específico gana: EQUIPO > UNIDAD > GLOBAL (IngestaBean.umbralesQueAplican).
 *
 * El umbral DESCONEXION se muestra pero es informativo: IngestaBean decide la
 * desconexión con rmm.agente.intervalosSinSenal (opciones JVM de GlassFish).
 *
 * @author jose
 */
@Stateless
@LocalBean
public class UmbralesBean {

    public static final String AMBITO_GLOBAL = "GLOBAL";
    public static final String AMBITO_UNIDAD = "UNIDAD";
    public static final String AMBITO_EQUIPO = "EQUIPO";

    /** Recursos que se pueden configurar (los que evalúa IngestaBean). */
    public static final List<String> RECURSOS = List.of("CPU", "RAM", "DISCO");

    @EJB
    private GestionAlertasFacade facade;

    @EJB
    private EquipoFacade equipoFacade;

    @EJB
    private CatalogoUnidadesBean catalogoBean;

    public List<FilaUmbral> listar() {
        Map<String, String> unidades = new HashMap<>();
        for (UnidadHomologada u : catalogoBean.listarUnidadesHomologadas()) {
            unidades.put(String.valueOf(u.getIdUnidadHomologada()), u.getNombre());
        }
        List<FilaUmbral> r = new ArrayList<>();
        for (UmbralAlerta u : facade.umbrales()) {
            r.add(new FilaUmbral(u, textoAmbito(u, unidades)));
        }
        return r;
    }

    /** Unidades para el selector del formulario. */
    public List<UnidadHomologada> unidades() {
        return catalogoBean.listarUnidadesHomologadas();
    }

    /**
     * Crea el umbral o, si ya había uno del mismo recurso y ámbito, le cambia el
     * valor y lo vuelve a activar.
     *
     * @param valorAmbito GLOBAL: se ignora; UNIDAD: id de la unidad; EQUIPO: hostname
     * @return true si se creó uno nuevo, false si se actualizó uno existente
     */
    public boolean guardar(String recurso, Double valor, String ambito, String valorAmbito) {
        String r = recurso == null ? "" : recurso.trim().toUpperCase(Locale.ROOT);
        if (!RECURSOS.contains(r)) {
            throw new Excepciones("umbral.recurso", "Elija el recurso: CPU, RAM o Disco.");
        }
        if (valor == null || valor.isNaN() || valor < 1 || valor > 100) {
            throw new Excepciones("umbral.valor", "El valor debe ser un porcentaje entre 1 y 100.");
        }
        String a = ambito == null ? "" : ambito.trim().toUpperCase(Locale.ROOT);
        String va;
        switch (a) {
            case AMBITO_GLOBAL:
                va = null;
                break;
            case AMBITO_UNIDAD:
                va = Validacion.limpiar(valorAmbito);
                if (va == null) {
                    throw new Excepciones("umbral.unidad", "Elija la unidad.");
                }
                try {
                    Short.parseShort(va);
                } catch (NumberFormatException e) {
                    throw new Excepciones("umbral.unidad", "La unidad no es válida.");
                }
                break;
            case AMBITO_EQUIPO:
                String host = InventarioBean.normalizarHostname(valorAmbito);
                Equipo equipo = host == null ? null : equipoFacade.buscarPorHostname(host);
                if (equipo == null) {
                    throw new Excepciones("umbral.equipo", "No existe un equipo con ese hostname.");
                }
                va = String.valueOf(equipo.getIdEquipo());
                break;
            default:
                throw new Excepciones("umbral.ambito", "Elija el ámbito: Global, Unidad o Equipo.");
        }

        UmbralAlerta u = facade.buscarUmbral(r, a, va);
        boolean nuevo = u == null;
        if (nuevo) {
            u = new UmbralAlerta();
            u.setTipoRecurso(r);
            u.setAmbito(a);
            u.setValorAmbito(va);
            u.setValorUmbral(valor);
            u.setActivo(true);
            facade.crearUmbral(u);
        } else {
            u.setValorUmbral(valor);   // administrada: se guarda al terminar
            u.setActivo(true);
        }
        return nuevo;
    }

    /** Activa o desactiva un umbral (no se borran: las alertas ya generadas lo referencian). */
    public void cambiarEstado(Integer idUmbral, boolean activo) {
        UmbralAlerta u = facade.umbral(idUmbral);
        if (u == null) {
            throw new Excepciones("umbral.noExiste", "El umbral ya no existe.");
        }
        if (!RECURSOS.contains(u.getTipoRecurso() == null ? "" : u.getTipoRecurso().toUpperCase(Locale.ROOT))) {
            throw new Excepciones("umbral.informativo", "Este umbral es informativo y no se puede cambiar aquí.");
        }
        u.setActivo(activo);
    }

    private String textoAmbito(UmbralAlerta u, Map<String, String> unidades) {
        String a = u.getAmbito() == null ? AMBITO_GLOBAL : u.getAmbito().trim().toUpperCase(Locale.ROOT);
        String v = Validacion.limpiar(u.getValorAmbito());
        switch (a) {
            case AMBITO_GLOBAL:
                return "Global";
            case AMBITO_UNIDAD:
                return "Unidad: " + (v == null ? "—" : unidades.getOrDefault(v, "#" + v));
            case AMBITO_EQUIPO:
                if (v != null) {
                    try {
                        Equipo e = equipoFacade.find(Integer.valueOf(v));
                        if (e != null) {
                            return "Equipo: " + e.getHostname();
                        }
                    } catch (NumberFormatException ex) {
                        return "Equipo: " + v;
                    }
                }
                return "Equipo: " + (v == null ? "—" : "#" + v);
            default:
                return v == null ? a : a + ": " + v;
        }
    }

    /** Renglón de la tabla de umbrales. */
    public static final class FilaUmbral implements Serializable {

        private static final long serialVersionUID = 1L;

        private final Integer id;
        private final String recurso;
        private final double valor;
        private final String ambito;
        private final boolean activo;

        FilaUmbral(UmbralAlerta u, String ambito) {
            this.id = u.getIdUmbralAlerta();
            this.recurso = u.getTipoRecurso() == null ? "" : u.getTipoRecurso().toUpperCase(Locale.ROOT);
            this.valor = u.getValorUmbral();
            this.ambito = ambito;
            this.activo = u.getActivo() == null || u.getActivo();
        }

        public Integer getId() {
            return id;
        }

        public String getRecurso() {
            return recurso;
        }

        public String getEtiquetaRecurso() {
            switch (recurso) {
                case "DISCO":
                    return "Disco (partición)";
                case "DESCONEXION":
                    return "Desconexión";
                default:
                    return recurso;
            }
        }

        public double getValor() {
            return valor;
        }

        public String getValorTexto() {
            String n = valor == Math.rint(valor) ? String.valueOf((long) valor) : String.valueOf(valor);
            return isInformativo() ? n + " min sin señal" : n + " %";
        }

        public String getAmbito() {
            return ambito;
        }

        public boolean isActivo() {
            return activo;
        }

        /** Los que no son CPU, RAM o DISCO (p. ej. DESCONEXION) no los evalúa IngestaBean. */
        public boolean isInformativo() {
            return !RECURSOS.contains(recurso);
        }
    }
}
