package logica_negocio;

import acceso_datos.EquipoFacade;
import acceso_datos.IngestaFacade;
import excepciones.Excepciones;
import ingesta.ConfigAgente;
import ingesta.InventarioAgente;
import ingesta.ParticionAgente;
import ingesta.PerifericoAgente;
import ingesta.RegistroAgente;
import ingesta.RespuestaIngesta;
import ingesta.SeguridadAgente;
import ingesta.SoftwareAgente;
import ingesta.TelemetriaAgente;
import jakarta.ejb.EJB;
import jakarta.ejb.LocalBean;
import jakarta.ejb.Stateless;
import jakarta.enterprise.event.Event;
import jakarta.inject.Inject;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import modelo.Alerta;
import modelo.Almacenamiento;
import modelo.Area;
import modelo.Equipo;
import modelo.Hardware;
import modelo.Informe;
import modelo.Periferico;
import modelo.SesionMonitoreo;
import modelo.Software;
import modelo.UmbralAlerta;

/**
 * Lógica de la API de Ingesta: registro del agente e ingesta de telemetría
 * (Figura 23, "Registro de Agente e Ingesta de Telemetría") y la detección de
 * uso anómalo de recursos (Figura de "Detección Automática de Alertas").
 *
 * Inspirado en el agente de Zabbix:
 *   - checks activos: el agente siempre inicia la conexión;
 *   - autoregistro: el primer enlace crea el equipo (o lo liga si ya se dio de alta a mano);
 *   - los umbrales ("triggers") se evalúan aquí, no en el agente;
 *   - la disponibilidad se calcula por falta de datos (ver MonitorConexionBean).
 *
 * @author kyriux
 */
@Stateless
@LocalBean
public class IngestaBean {

    // ------------------------------------------------------------------
    // Configuración (se puede cambiar con -D en las JVM options de GlassFish)
    // ------------------------------------------------------------------

    /** Cada cuántos segundos manda telemetría el agente. */
    public static int intervaloTelemetriaSeg() {
        return Integer.getInteger("rmm.agente.intervaloSeg", 60);
    }

    /** Cada cuántos minutos manda inventario de software y periféricos. */
    public static int intervaloInventarioMin() {
        return Integer.getInteger("rmm.agente.inventarioMin", 1440);
    }

    /** Intervalos sin señal para considerar al equipo OFFLINE (como nodata() de Zabbix). */
    public static int intervalosSinSenal() {
        return Integer.getInteger("rmm.agente.intervalosSinSenal", 3);
    }

    /** Estados de equipo.estado_conexion. */
    public static final String ONLINE = "ONLINE";
    public static final String ALERTA = "ALERTA";
    public static final String OFFLINE = "OFFLINE";

    /** Valores de Alerta (notas inv: del modelo de contenido, iteración 3). */
    public static final String TIPO_DESCONEXION = "Desconexion";
    public static final String TIPO_USO_ANOMALO = "UsoAnomalo";
    public static final String TIPO_RIESGO_SEGURIDAD = "RiesgoSeguridad";
    public static final String GRAVEDAD_INFORMATIVA = "Informativa";
    public static final String GRAVEDAD_ADVERTENCIA = "Advertencia";
    public static final String GRAVEDAD_CRITICA = "Critica";
    public static final String ESTADO_ALERTA_ACTIVA = "Activa";

    /** Códigos de error (van en Excepciones.campo y la API los traduce a HTTP). */
    public static final String ERR_NO_REGISTRADO = "agente.noRegistrado";   // 404
    public static final String ERR_BAJA = "agente.baja";                    // 410
    public static final String ERR_CONFLICTO = "agente.conflicto";          // 409
    public static final String ERR_DATOS = "agente.datos";                  // 400

    @EJB
    private EquipoFacade equipoFacade;

    @EJB
    private IngestaFacade ingestaFacade;

    /** Avisa a otros módulos (p. ej. correo de HU-15) que se generó una alerta. */
    @Inject
    private Event<AlertaGenerada> alertaGenerada;


    /**
     * Primer enlace del agente. Busca el equipo por MAC; si no existe, por
     * hostname (un equipo dado de alta a mano que nunca ha reportado); si
     * tampoco, lo crea. En todos los casos actualiza su ficha de hardware.
     */
    public ConfigAgente registrar(RegistroAgente datos) {
        if (datos == null) {
            throw new Excepciones(ERR_DATOS, "Faltan los datos del registro");
        }
        String mac = InventarioBean.normalizarMac(datos.mac);
        String hostname = InventarioBean.normalizarHostname(datos.hostname);
        if (mac == null || hostname == null) {
            throw new Excepciones(ERR_DATOS, "El agente debe mandar hostname y MAC");
        }

        Equipo equipo = equipoFacade.buscarPorMac(mac);
        if (equipo == null) {
            Equipo porNombre = equipoFacade.buscarPorHostname(hostname);
            if (porNombre != null) {
                if (porNombre.getUltimaSenal() != null) {
                    // Ya reporta otro agente con ese hostname y otra MAC
                    throw new Excepciones(ERR_CONFLICTO, "El hostname " + hostname
                            + " ya está registrado con la MAC " + porNombre.getDireccionMac());
                }
                // Alta manual que todavía no reportaba: se enlaza y se corrige la MAC
                equipo = porNombre;
                equipo.setDireccionMac(mac);
            }
        }
        if (equipo != null && !equipo.getEstaActivo()) {
            throw new Excepciones(ERR_BAJA, "El equipo " + equipo.getHostname() + " está dado de baja");
        }

        // El hostname es único: no puede quedar igual al de otro equipo
        Equipo mismoNombre = equipoFacade.buscarPorHostname(hostname);
        if (mismoNombre != null && equipo != null && !mismoNombre.getIdEquipo().equals(equipo.getIdEquipo())) {
            throw new Excepciones(ERR_CONFLICTO, "El hostname " + hostname + " ya pertenece a otro equipo");
        }

        boolean nuevo = equipo == null;
        if (nuevo) {
            // 1: create(hostname, direccionMac, ipLocal, nombreSO, versionSO)
            equipo = new Equipo();
            equipo.setDireccionMac(mac);
            equipo.setFechaRegistro(new Date());
            equipo.setEstaActivo(true);
            equipo.setEstadoConexion(OFFLINE);   // pasa a ONLINE con la primera señal
            // El área (unidad / servicio) la asigna después el técnico desde Inventario
        }
        equipo.setHostname(hostname);
        equipo.setIpLocal(recortar(datos.ipLocal, 45));
        equipo.setNombreSo(recortar(datos.nombreSo, 255));
        equipo.setVersionSo(recortar(datos.versionSo, 255));

        // 2: create(modeloCpu, nucleosCpu, totalRamGb, capacidadDiscoGb) — composición
        Hardware hw = equipo.getHardware();
        if (hw == null) {
            hw = new Hardware();
            hw.setIdEquipo(equipo);
            equipo.setHardware(hw);
        }
        hw.setModeloCpu(recortar(datos.modeloCpu, 255));
        hw.setNucleosCpu(datos.nucleosCpu);
        hw.setHilosCpu(datos.hilosCpu);
        hw.setTotalRamGb(redondear(datos.totalRamGb));
        hw.setModeloPlacaBase(recortar(datos.modeloPlacaBase, 255));
        hw.setCapacidadDiscoGb(redondear(datos.capacidadDiscoGb));

        if (nuevo) {
            equipoFacade.create(equipo);   // el hardware se inserta en cascada
        } else {
            equipoFacade.edit(equipo);
        }
        // 3: equipoRegistrado
        return new ConfigAgente(equipo.getIdEquipo(), intervaloTelemetriaSeg(), intervaloInventarioMin());
    }

    /** Configuración vigente para el agente (GET /config). */
    public ConfigAgente configuracion(String mac) {
        Equipo equipo = equipoActivo(mac);
        return new ConfigAgente(equipo.getIdEquipo(), intervaloTelemetriaSeg(), intervaloInventarioMin());
    }


    /**
     * Recibe una captura del agente.
     *
     * @param ipOrigen dirección desde la que llegó la petición (para la sesión de monitoreo)
     */
    public RespuestaIngesta registrarTelemetria(TelemetriaAgente t, String ipOrigen) {
        if (t == null) {
            throw new Excepciones(ERR_DATOS, "Faltan los datos de telemetría");
        }
        Equipo equipo = equipoActivo(t.mac);
        Date ahora = new Date();

        // 4–8: registrarUltimaSeñal(tsActual)
        registrarUltimaSenal(equipo, ahora, ipOrigen);
        if (t.ipLocal != null) {
            equipo.setIpLocal(recortar(t.ipLocal, 45));
        }

        // 9–14: registrarInforme(datosTelemetria) → Informe + Almacenamiento por partición
        Date fechaCaptura = (t.timestampMs <= 0 || t.timestampMs > ahora.getTime())
                ? ahora : new Date(t.timestampMs);
        Informe informe = new Informe();
        informe.setIdEquipo(equipo);
        informe.setFechaRegistro(fechaCaptura);
        informe.setPorcentajeUsoCpu(redondear(limitar(t.porcentajeUsoCpu)));
        informe.setRamUsadaGb(redondear(t.ramUsadaGb));
        informe.setTraficoRedRxMb(redondear(t.traficoRedRxMb));
        informe.setTraficoRedTxMb(redondear(t.traficoRedTxMb));
        informe.setTotalProcesos(t.totalProcesos);
        List<Almacenamiento> particiones = new ArrayList<>();
        if (t.particiones != null) {
            for (ParticionAgente p : t.particiones) {
                if (p == null || p.puntoMontaje == null || p.capacidadTotalGb <= 0) {
                    continue;
                }
                Almacenamiento a = new Almacenamiento();
                a.setIdInforme(informe);
                a.setPuntoMontaje(recortar(p.puntoMontaje, 255));
                a.setCapacidadTotalGb(redondear(p.capacidadTotalGb));
                a.setEspacioLibreGb(redondear(Math.max(0, p.espacioLibreGb)));
                particiones.add(a);
            }
        }
        informe.setAlmacenamientoList(particiones);
        ingestaFacade.crear(informe);   // las particiones van en cascada

        // Capturas viejas que venían del buffer del agente: se guardan como
        // historial, pero no cambian el estado ni generan alertas.
        long antiguedadMs = ahora.getTime() - fechaCaptura.getTime();
        if (antiguedadMs > 2L * intervaloTelemetriaSeg() * 1000) {
            equipoFacade.edit(equipo);
            return new RespuestaIngesta(equipo.getEstadoConexion(), 0, intervaloTelemetriaSeg());
        }

        // 15–20: porcentajes y esUmbralExcedido(uCpu, uRam, uDisco)
        Double totalRam = equipo.getHardware() != null && equipo.getHardware().getTotalRamGb() != null
                ? equipo.getHardware().getTotalRamGb() : t.ramTotalGb;
        Map<String, Double> uso = new HashMap<>();
        uso.put("CPU", informe.getPorcentajeUsoCpu());
        uso.put("RAM", porcentaje(informe.getRamUsadaGb(), totalRam));
        Almacenamiento masLlena = particionMasLlena(particiones);
        uso.put("DISCO", masLlena == null ? null : porcentajeUso(masLlena));

        int alertas = 0;
        boolean excedido = false;
        for (Map.Entry<String, UmbralAlerta> e : umbralesQueAplican(equipo).entrySet()) {
            String recurso = e.getKey();
            UmbralAlerta umbral = e.getValue();
            Double valor = uso.get(recurso);
            if (valor == null || valor < umbral.getValorUmbral()) {
                continue;
            }
            excedido = true;
            // 4–6 (iteración 3): la alerta se crea una sola vez mientras siga "Activa"
            if (!ingestaFacade.existeAlertaActiva(equipo, umbral)) {
                Alerta alerta = nuevaAlerta(equipo, umbral, recurso, valor, masLlena, ahora);
                ingestaFacade.crearAlerta(alerta);
                alertaGenerada.fire(new AlertaGenerada(alerta));
                alertas++;
            }
        }

        // 21: actualizarEstado("ALERTA") — o regresa a ONLINE si ya se normalizó
        equipo.actualizarEstado(excedido ? ALERTA : ONLINE);
        equipoFacade.edit(equipo);

        // 22: confirmacionIngesta
        return new RespuestaIngesta(equipo.getEstadoConexion(), alertas, intervaloTelemetriaSeg());
    }

    /** El agente avisa que se va a detener (apagado normal): cierra la sesión sin marcarla abrupta. */
    public void desconectar(String mac) {
        Equipo equipo = equipoActivo(mac);
        SesionMonitoreo s = ingestaFacade.sesionAbierta(equipo);
        if (s != null) {
            s.setFinSesion(new Date());
            s.setDesconexionAbrupta(false);
        }
        equipo.actualizarEstado(OFFLINE);
        equipoFacade.edit(equipo);
    }


    /**
     * Sincroniza el software y los periféricos con lo que reporta el agente:
     * agrega lo nuevo, actualiza versiones, borra lo que ya no está. Conserva
     * las marcas "autorizado" que haya puesto un técnico.
     */
    public void registrarInventario(InventarioAgente inv) {
        if (inv == null) {
            throw new Excepciones(ERR_DATOS, "Faltan los datos del inventario");
        }
        Equipo equipo = equipoActivo(inv.mac);

        // Software: la llave es el nombre
        Map<String, Software> actuales = new HashMap<>();
        for (Software s : ingestaFacade.softwareDe(equipo)) {
            actuales.put(llave(s.getNombre()), s);
        }
        if (inv.software != null) {
            for (SoftwareAgente sa : inv.software) {
                String nombre = recortar(sa == null ? null : sa.nombre, 255);
                if (nombre == null) {
                    continue;
                }
                Software s = actuales.remove(llave(nombre));
                if (s == null) {
                    s = new Software();
                    s.setIdEquipo(equipo);
                    s.setNombre(nombre);
                    // HU-8: hereda la marca que el técnico ya le puso en otros equipos
                    s.setAutorizado(ingestaFacade.autorizacionCatalogo(nombre));
                    ingestaFacade.crear(s);
                }
                s.setVersion(recortar(sa.version, 255));
                s.setFabricante(recortar(sa.fabricante, 255));
                if (sa.fechaInstalacionMs != null && sa.fechaInstalacionMs > 0) {
                    s.setFechaInstalacion(new Date(sa.fechaInstalacionMs));
                }
            }
        }
        actuales.values().forEach(ingestaFacade::eliminar);   // desinstalado

        // Periféricos: la llave es tipo + modelo + serie
        Map<String, Periferico> perActuales = new HashMap<>();
        for (Periferico p : ingestaFacade.perifericosDe(equipo)) {
            perActuales.put(llave(p.getTipo(), p.getModelo(), p.getNumeroSerie()), p);
        }
        if (inv.perifericos != null) {
            for (PerifericoAgente pa : inv.perifericos) {
                String tipo = recortar(pa == null ? null : pa.tipo, 255);
                if (tipo == null) {
                    continue;
                }
                String modelo = recortar(pa.modelo, 255);
                String serie = recortar(pa.numeroSerie, 255);
                if (perActuales.remove(llave(tipo, modelo, serie)) == null) {
                    Periferico p = new Periferico();
                    p.setIdEquipo(equipo);
                    p.setTipo(tipo);
                    p.setModelo(modelo);
                    p.setNumeroSerie(serie);
                    ingestaFacade.crear(p);
                }
            }
        }
        perActuales.values().forEach(ingestaFacade::eliminar);   // desconectado

        // HU-4: riesgo de seguridad (antivirus / firewall apagados)
        revisarSeguridad(equipo, inv.seguridad);
    }

    /**
     * Genera una alerta "RiesgoSeguridad" si el agente confirmó que el
     * antivirus o el firewall están apagados. Solo un false genera alerta;
     * null (no se pudo saber) se ignora. Una sola alerta activa por equipo:
     * mientras siga "Activa" no se repite en cada inventario.
     *
     * Gravedad: Critica si falta el antivirus (dispara el correo de HU-15),
     * Advertencia si solo es el firewall.
     */
    private void revisarSeguridad(Equipo equipo, SeguridadAgente seg) {
        if (seg == null) {
            return;
        }
        boolean sinAntivirus = Boolean.FALSE.equals(seg.antivirusActivo);
        boolean sinFirewall = Boolean.FALSE.equals(seg.firewallActivo);
        if (!sinAntivirus && !sinFirewall) {
            return;
        }
        if (ingestaFacade.existeAlertaActivaSinUmbral(equipo, TIPO_RIESGO_SEGURIDAD)) {
            return;
        }
        List<String> problemas = new ArrayList<>();
        if (sinAntivirus) {
            problemas.add(seg.antivirusNombre == null || seg.antivirusNombre.isBlank()
                    ? "sin antivirus" : "antivirus desactivado (" + seg.antivirusNombre.trim() + ")");
        }
        if (sinFirewall) {
            problemas.add("firewall desactivado");
        }
        Alerta a = new Alerta();
        a.setIdEquipo(equipo);
        a.setIdUmbralAlerta(null);
        a.setTipoAlerta(TIPO_RIESGO_SEGURIDAD);
        a.setNivelGravedad(sinAntivirus ? GRAVEDAD_CRITICA : GRAVEDAD_ADVERTENCIA);
        a.setDescripcion(recortar("Riesgo de seguridad en " + equipo.getHostname() + ": "
                + String.join(" y ", problemas), 255));
        a.setFechaGeneracion(new Date());
        a.setEstado(ESTADO_ALERTA_ACTIVA);
        ingestaFacade.crearAlerta(a);
        alertaGenerada.fire(new AlertaGenerada(a));
    }

    // ------------------------------------------------------------------
    // Disponibilidad (lo llama MonitorConexionBean cada minuto)
    // ------------------------------------------------------------------

    /**
     * Marca OFFLINE a los equipos sin señal en los últimos N intervalos y
     * cierra su sesión de monitoreo como desconexión abrupta.
     *
     * @return cuántos equipos pasaron a OFFLINE
     */
    public int marcarEquiposSinSenal() {
        long margenMs = (long) intervalosSinSenal() * intervaloTelemetriaSeg() * 1000;
        Date limite = new Date(System.currentTimeMillis() - margenMs);
        int n = 0;
        for (Equipo e : ingestaFacade.equiposSinSenalDesde(limite)) {
            SesionMonitoreo s = ingestaFacade.sesionAbierta(e);
            if (s != null) {
                s.setFinSesion(e.getUltimaSenal() != null ? e.getUltimaSenal() : new Date());
                s.setDesconexionAbrupta(true);
            }
            e.actualizarEstado(OFFLINE);
            equipoFacade.edit(e);
            n++;
            // HU-4: alerta por desconexión (timeout, sin umbral). Solo para caídas
            // abruptas: si el agente avisó que se apagaba (desconectar), no llega aquí.
            if (!ingestaFacade.existeAlertaActivaSinUmbral(e, TIPO_DESCONEXION)) {
                Alerta alerta = alertaDesconexion(e, margenMs);
                ingestaFacade.crearAlerta(alerta);
                alertaGenerada.fire(new AlertaGenerada(alerta));
            }
        }
        return n;
    }

    // ------------------------------------------------------------------
    // Auxiliares
    // ------------------------------------------------------------------

    /** Equipo activo con esa MAC; si no existe, el agente debe volver a registrarse. */
    private Equipo equipoActivo(String macRecibida) {
        String mac = InventarioBean.normalizarMac(macRecibida);
        if (mac == null) {
            throw new Excepciones(ERR_DATOS, "El agente debe mandar su MAC");
        }
        Equipo equipo = equipoFacade.buscarPorMac(mac);
        if (equipo == null) {
            throw new Excepciones(ERR_NO_REGISTRADO, "No hay ningún equipo registrado con la MAC " + mac);
        }
        if (!equipo.getEstaActivo()) {
            throw new Excepciones(ERR_BAJA, "El equipo " + equipo.getHostname() + " está dado de baja");
        }
        return equipo;
    }

    /** 4–8: si estaba desconectado, abre una sesión de monitoreo y pasa a ONLINE. */
    private void registrarUltimaSenal(Equipo equipo, Date ahora, String ipOrigen) {
        String estado = equipo.getEstadoConexion();
        boolean enLinea = ONLINE.equals(estado) || ALERTA.equals(estado);   // esOnline()
        if (!enLinea) {
            SesionMonitoreo colgada = ingestaFacade.sesionAbierta(equipo);
            if (colgada != null) {   // quedó abierta (p. ej. se reinició el servidor)
                colgada.setFinSesion(equipo.getUltimaSenal() != null ? equipo.getUltimaSenal() : ahora);
                colgada.setDesconexionAbrupta(true);
            }
            SesionMonitoreo sesion = new SesionMonitoreo();
            sesion.setIdEquipo(equipo);
            sesion.setInicioSesion(ahora);
            sesion.setDesconexionAbrupta(false);
            sesion.setIpOrigen(recortar(ipOrigen, 45));
            ingestaFacade.crear(sesion);
            equipo.actualizarEstado(ONLINE);
        }
        equipo.setUltimaSenal(ahora);
    }

    /**
     * Para cada recurso (CPU, RAM, DISCO) el umbral más específico que aplica
     * al equipo: EQUIPO > AREA > UNIDAD > CLASIFICACION > GLOBAL (HU-3).
     */
    private Map<String, UmbralAlerta> umbralesQueAplican(Equipo equipo) {
        Map<String, UmbralAlerta> elegido = new HashMap<>();
        Map<String, Integer> prioridad = new HashMap<>();
        for (UmbralAlerta u : ingestaFacade.umbralesActivos()) {
            String recurso = recurso(u.getTipoRecurso());
            int p = prioridadSiAplica(u, equipo);
            if (recurso == null || p < 0) {
                continue;
            }
            if (p > prioridad.getOrDefault(recurso, -1)) {
                elegido.put(recurso, u);
                prioridad.put(recurso, p);
            }
        }
        return elegido;
    }

    /** "CPU", "RAM" o "DISCO" según tipo_recurso; null si no se reconoce. */
    static String recurso(String tipoRecurso) {
        String t = tipoRecurso == null ? "" : tipoRecurso.toUpperCase(Locale.ROOT);
        if (t.contains("CPU") || t.contains("PROCESADOR")) {
            return "CPU";
        }
        if (t.contains("RAM") || t.contains("MEMORIA")) {
            return "RAM";
        }
        if (t.contains("DISCO") || t.contains("ALMACENAMIENTO")) {
            return "DISCO";
        }
        return null;
    }

    /**
     * Prioridad del umbral para el equipo, o -1 si no le aplica.
     * ambito / valor_ambito admitidos:
     *   GLOBAL (o vacío)          → todos los equipos
     *   CLASIFICACION, valor = id_clasificacion de la unidad (tipo de unidad)
     *   UNIDAD,        valor = id_unidad_homologada (hospital / sede)
     *   AREA,          valor = id_area
     *   EQUIPO,        valor = id_equipo o hostname
     */
    private int prioridadSiAplica(UmbralAlerta u, Equipo e) {
        String ambito = u.getAmbito() == null ? "GLOBAL" : u.getAmbito().trim().toUpperCase(Locale.ROOT);
        String valor = Validacion.limpiar(u.getValorAmbito());
        Area area = e.getIdArea();
        switch (ambito) {
            case "GLOBAL", "GENERAL", "TODOS", "":
                return 0;
            case "CLASIFICACION", "TIPO_UNIDAD":
                return area != null && area.getIdUnidadHomologada() != null
                        && area.getIdUnidadHomologada().getIdClasificacion() != null
                        && igual(valor, area.getIdUnidadHomologada().getIdClasificacion().getIdClasificacion()) ? 1 : -1;
            case "UNIDAD", "HOSPITAL", "SEDE", "UNIDAD_HOMOLOGADA":
                return area != null && area.getIdUnidadHomologada() != null
                        && igual(valor, area.getIdUnidadHomologada().getIdUnidadHomologada()) ? 2 : -1;
            case "AREA", "SERVICIO":
                return area != null && igual(valor, area.getIdArea()) ? 3 : -1;
            case "EQUIPO":
                return valor != null && (igual(valor, e.getIdEquipo()) || valor.equalsIgnoreCase(e.getHostname())) ? 4 : -1;
            default:
                return valor == null ? 0 : -1;   // ámbito desconocido sin valor: se trata como global
        }
    }

    private Alerta nuevaAlerta(Equipo equipo, UmbralAlerta umbral, String recurso, double valor,
            Almacenamiento particion, Date ahora) {
        Alerta a = new Alerta();
        a.setIdEquipo(equipo);
        a.setIdUmbralAlerta(umbral);
        a.setTipoAlerta(TIPO_USO_ANOMALO);
        // Crítica si rebasa el umbral por 10 puntos o más, o si pasa de 95 %
        boolean critica = valor >= umbral.getValorUmbral() + 10 || valor >= 95;
        a.setNivelGravedad(critica ? GRAVEDAD_CRITICA : GRAVEDAD_ADVERTENCIA);
        String donde = "DISCO".equals(recurso) && particion != null ? " en " + particion.getPuntoMontaje() : "";
        a.setDescripcion(recortar(String.format(Locale.ROOT, "%s al %.1f%%%s (umbral %.0f%%) en %s",
                recurso, valor, donde, umbral.getValorUmbral(), equipo.getHostname()), 255));
        a.setFechaGeneracion(ahora);
        a.setEstado(ESTADO_ALERTA_ACTIVA);
        // HU-15: el correo NO va aquí; se hace observando el evento AlertaGenerada.
        return a;
    }

    /**
     * Alerta "Desconexion": el equipo dejó de mandar señal sin avisar.
     * Es Advertencia y no Critica porque un equipo apagado al final del turno
     * también cae aquí; así no se manda un correo (HU-15) por cada uno.
     */
    private static Alerta alertaDesconexion(Equipo equipo, long margenMs) {
        Alerta a = new Alerta();
        a.setIdEquipo(equipo);
        a.setIdUmbralAlerta(null);
        a.setTipoAlerta(TIPO_DESCONEXION);
        a.setNivelGravedad(GRAVEDAD_ADVERTENCIA);
        long minutos = Math.max(1, Math.round(margenMs / 60000.0));
        a.setDescripcion(recortar(String.format(Locale.ROOT,
                "%s dejó de enviar señal (más de %d min sin comunicación)",
                equipo.getHostname(), minutos), 255));
        a.setFechaGeneracion(new Date());
        a.setEstado(ESTADO_ALERTA_ACTIVA);
        return a;
    }

    private static Almacenamiento particionMasLlena(List<Almacenamiento> particiones) {
        Almacenamiento max = null;
        for (Almacenamiento a : particiones) {
            if (max == null || porcentajeUso(a) > porcentajeUso(max)) {
                max = a;
            }
        }
        return max;
    }

    /** calcularPorcentajeUso() de Almacenamiento. */
    private static double porcentajeUso(Almacenamiento a) {
        return a.getCapacidadTotalGb() <= 0 ? 0
                : redondear((a.getCapacidadTotalGb() - a.getEspacioLibreGb()) * 100 / a.getCapacidadTotalGb());
    }

    private static Double porcentaje(Double usado, Double total) {
        return usado == null || total == null || total <= 0 ? null : redondear(limitar(usado * 100 / total));
    }

    private static Double limitar(Double pct) {
        return pct == null ? null : Math.max(0, Math.min(100, pct));
    }

    private static Double redondear(Double v) {
        return v == null || v.isNaN() || v.isInfinite() ? null : Math.round(v * 100) / 100.0;
    }

    private static double redondear(double v) {
        return Math.round(v * 100) / 100.0;
    }

    private static boolean igual(String valor, Number id) {
        return valor != null && id != null && valor.equals(String.valueOf(id));
    }

    private static String recortar(String s, int max) {
        String l = Validacion.limpiar(s);
        return l == null ? null : (l.length() > max ? l.substring(0, max) : l);
    }

    private static String llave(String... partes) {
        StringBuilder sb = new StringBuilder();
        for (String p : partes) {
            sb.append(p == null ? "" : p.trim().toLowerCase(Locale.ROOT)).append('|');
        }
        return sb.toString();
    }
}
