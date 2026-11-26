package ingesta;

/** confirmacionIngesta (mensaje 22 de la Figura 23). */
public class RespuestaIngesta {
    /** Estado en que quedó el equipo: ONLINE o ALERTA. */
    public String estado;
    /** Alertas nuevas creadas con esta captura. */
    public int alertasGeneradas;
    /** Intervalo vigente, por si el administrador lo cambió. */
    public int intervaloTelemetriaSeg;

    public RespuestaIngesta() {
    }

    public RespuestaIngesta(String estado, int alertasGeneradas, int intervaloTelemetriaSeg) {
        this.estado = estado;
        this.alertasGeneradas = alertasGeneradas;
        this.intervaloTelemetriaSeg = intervaloTelemetriaSeg;
    }
}
