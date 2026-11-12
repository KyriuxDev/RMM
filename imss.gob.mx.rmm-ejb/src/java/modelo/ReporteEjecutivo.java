/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package modelo;

import jakarta.persistence.Basic;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.JoinTable;
import jakarta.persistence.ManyToMany;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.NamedQueries;
import jakarta.persistence.NamedQuery;
import jakarta.persistence.Table;
import jakarta.persistence.Temporal;
import jakarta.persistence.TemporalType;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import jakarta.xml.bind.annotation.XmlRootElement;
import jakarta.xml.bind.annotation.XmlTransient;
import java.io.Serializable;
import java.util.Date;
import java.util.List;

/**
 *
 * @author kyriux
 */
@Entity
@Table(name = "reporte_ejecutivo")
@XmlRootElement
@NamedQueries({
    @NamedQuery(name = "ReporteEjecutivo.findAll", query = "SELECT r FROM ReporteEjecutivo r"),
    @NamedQuery(name = "ReporteEjecutivo.findByIdReporteEjecutivo", query = "SELECT r FROM ReporteEjecutivo r WHERE r.idReporteEjecutivo = :idReporteEjecutivo"),
    @NamedQuery(name = "ReporteEjecutivo.findByTipoReporte", query = "SELECT r FROM ReporteEjecutivo r WHERE r.tipoReporte = :tipoReporte"),
    @NamedQuery(name = "ReporteEjecutivo.findByFechaInicio", query = "SELECT r FROM ReporteEjecutivo r WHERE r.fechaInicio = :fechaInicio"),
    @NamedQuery(name = "ReporteEjecutivo.findByFechaFin", query = "SELECT r FROM ReporteEjecutivo r WHERE r.fechaFin = :fechaFin"),
    @NamedQuery(name = "ReporteEjecutivo.findByFormatoExportacion", query = "SELECT r FROM ReporteEjecutivo r WHERE r.formatoExportacion = :formatoExportacion"),
    @NamedQuery(name = "ReporteEjecutivo.findByFechaGeneracion", query = "SELECT r FROM ReporteEjecutivo r WHERE r.fechaGeneracion = :fechaGeneracion"),
    @NamedQuery(name = "ReporteEjecutivo.findByFiltroUnidad", query = "SELECT r FROM ReporteEjecutivo r WHERE r.filtroUnidad = :filtroUnidad"),
    @NamedQuery(name = "ReporteEjecutivo.findByFiltroTecnico", query = "SELECT r FROM ReporteEjecutivo r WHERE r.filtroTecnico = :filtroTecnico")})
public class ReporteEjecutivo implements Serializable {

    private static final long serialVersionUID = 1L;
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Basic(optional = false)
    @Column(name = "id_reporte_ejecutivo")
    private Integer idReporteEjecutivo;
    @Basic(optional = false)
    @NotNull
    @Size(min = 1, max = 255)
    @Column(name = "tipo_reporte")
    private String tipoReporte;
    @Basic(optional = false)
    @NotNull
    @Column(name = "fecha_inicio")
    @Temporal(TemporalType.TIMESTAMP)
    private Date fechaInicio;
    @Basic(optional = false)
    @NotNull
    @Column(name = "fecha_fin")
    @Temporal(TemporalType.TIMESTAMP)
    private Date fechaFin;
    @Basic(optional = false)
    @NotNull
    @Size(min = 1, max = 255)
    @Column(name = "formato_exportacion")
    private String formatoExportacion;
    @Column(name = "fecha_generacion")
    @Temporal(TemporalType.TIMESTAMP)
    private Date fechaGeneracion;
    @Size(max = 255)
    @Column(name = "filtro_unidad")
    private String filtroUnidad;
    @Size(max = 255)
    @Column(name = "filtro_tecnico")
    private String filtroTecnico;
    @JoinTable(name = "reporte_ejecutivo_sla", joinColumns = {
        @JoinColumn(name = "id_reporte_ejecutivo", referencedColumnName = "id_reporte_ejecutivo")}, inverseJoinColumns = {
        @JoinColumn(name = "id_sla", referencedColumnName = "id_sla")})
    @ManyToMany
    private List<Sla> slaList;
    @JoinColumn(name = "id_usuario", referencedColumnName = "id_usuario")
    @ManyToOne(optional = false)
    private Usuario idUsuario;

    public ReporteEjecutivo() {
    }

    public ReporteEjecutivo(Integer idReporteEjecutivo) {
        this.idReporteEjecutivo = idReporteEjecutivo;
    }

    public ReporteEjecutivo(Integer idReporteEjecutivo, String tipoReporte, Date fechaInicio, Date fechaFin, String formatoExportacion) {
        this.idReporteEjecutivo = idReporteEjecutivo;
        this.tipoReporte = tipoReporte;
        this.fechaInicio = fechaInicio;
        this.fechaFin = fechaFin;
        this.formatoExportacion = formatoExportacion;
    }

    public Integer getIdReporteEjecutivo() {
        return idReporteEjecutivo;
    }

    public void setIdReporteEjecutivo(Integer idReporteEjecutivo) {
        this.idReporteEjecutivo = idReporteEjecutivo;
    }

    public String getTipoReporte() {
        return tipoReporte;
    }

    public void setTipoReporte(String tipoReporte) {
        this.tipoReporte = tipoReporte;
    }

    public Date getFechaInicio() {
        return fechaInicio;
    }

    public void setFechaInicio(Date fechaInicio) {
        this.fechaInicio = fechaInicio;
    }

    public Date getFechaFin() {
        return fechaFin;
    }

    public void setFechaFin(Date fechaFin) {
        this.fechaFin = fechaFin;
    }

    public String getFormatoExportacion() {
        return formatoExportacion;
    }

    public void setFormatoExportacion(String formatoExportacion) {
        this.formatoExportacion = formatoExportacion;
    }

    public Date getFechaGeneracion() {
        return fechaGeneracion;
    }

    public void setFechaGeneracion(Date fechaGeneracion) {
        this.fechaGeneracion = fechaGeneracion;
    }

    public String getFiltroUnidad() {
        return filtroUnidad;
    }

    public void setFiltroUnidad(String filtroUnidad) {
        this.filtroUnidad = filtroUnidad;
    }

    public String getFiltroTecnico() {
        return filtroTecnico;
    }

    public void setFiltroTecnico(String filtroTecnico) {
        this.filtroTecnico = filtroTecnico;
    }

    @XmlTransient
    public List<Sla> getSlaList() {
        return slaList;
    }

    public void setSlaList(List<Sla> slaList) {
        this.slaList = slaList;
    }

    public Usuario getIdUsuario() {
        return idUsuario;
    }

    public void setIdUsuario(Usuario idUsuario) {
        this.idUsuario = idUsuario;
    }

    @Override
    public int hashCode() {
        int hash = 0;
        hash += (idReporteEjecutivo != null ? idReporteEjecutivo.hashCode() : 0);
        return hash;
    }

    @Override
    public boolean equals(Object object) {
        // TODO: Warning - this method won't work in the case the id fields are not set
        if (!(object instanceof ReporteEjecutivo)) {
            return false;
        }
        ReporteEjecutivo other = (ReporteEjecutivo) object;
        if ((this.idReporteEjecutivo == null && other.idReporteEjecutivo != null) || (this.idReporteEjecutivo != null && !this.idReporteEjecutivo.equals(other.idReporteEjecutivo))) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return "modelo.ReporteEjecutivo[ idReporteEjecutivo=" + idReporteEjecutivo + " ]";
    }
    
}
