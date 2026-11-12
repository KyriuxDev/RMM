/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package modelo;

import jakarta.persistence.Basic;
import jakarta.persistence.CascadeType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.NamedQueries;
import jakarta.persistence.NamedQuery;
import jakarta.persistence.OneToMany;
import jakarta.persistence.Table;
import jakarta.persistence.Temporal;
import jakarta.persistence.TemporalType;
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
@Table(name = "informe")
@XmlRootElement
@NamedQueries({
    @NamedQuery(name = "Informe.findAll", query = "SELECT i FROM Informe i"),
    @NamedQuery(name = "Informe.findByIdInforme", query = "SELECT i FROM Informe i WHERE i.idInforme = :idInforme"),
    @NamedQuery(name = "Informe.findByPorcentajeUsoCpu", query = "SELECT i FROM Informe i WHERE i.porcentajeUsoCpu = :porcentajeUsoCpu"),
    @NamedQuery(name = "Informe.findByRamUsadaGb", query = "SELECT i FROM Informe i WHERE i.ramUsadaGb = :ramUsadaGb"),
    @NamedQuery(name = "Informe.findByTraficoRedRxMb", query = "SELECT i FROM Informe i WHERE i.traficoRedRxMb = :traficoRedRxMb"),
    @NamedQuery(name = "Informe.findByTraficoRedTxMb", query = "SELECT i FROM Informe i WHERE i.traficoRedTxMb = :traficoRedTxMb"),
    @NamedQuery(name = "Informe.findByTotalProcesos", query = "SELECT i FROM Informe i WHERE i.totalProcesos = :totalProcesos"),
    @NamedQuery(name = "Informe.findByFechaRegistro", query = "SELECT i FROM Informe i WHERE i.fechaRegistro = :fechaRegistro")})
public class Informe implements Serializable {

    private static final long serialVersionUID = 1L;
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Basic(optional = false)
    @Column(name = "id_informe")
    private Integer idInforme;
    // @Max(value=?)  @Min(value=?)//if you know range of your decimal fields consider using these annotations to enforce field validation
    @Column(name = "porcentaje_uso_cpu")
    private Double porcentajeUsoCpu;
    @Column(name = "ram_usada_gb")
    private Double ramUsadaGb;
    @Column(name = "trafico_red_rx_mb")
    private Double traficoRedRxMb;
    @Column(name = "trafico_red_tx_mb")
    private Double traficoRedTxMb;
    @Column(name = "total_procesos")
    private Integer totalProcesos;
    @Column(name = "fecha_registro")
    @Temporal(TemporalType.TIMESTAMP)
    private Date fechaRegistro;
    @OneToMany(cascade = CascadeType.ALL, mappedBy = "idInforme")
    private List<Almacenamiento> almacenamientoList;
    @JoinColumn(name = "id_equipo", referencedColumnName = "id_equipo")
    @ManyToOne(optional = false)
    private Equipo idEquipo;

    public Informe() {
    }

    public Informe(Integer idInforme) {
        this.idInforme = idInforme;
    }

    public Integer getIdInforme() {
        return idInforme;
    }

    public void setIdInforme(Integer idInforme) {
        this.idInforme = idInforme;
    }

    public Double getPorcentajeUsoCpu() {
        return porcentajeUsoCpu;
    }

    public void setPorcentajeUsoCpu(Double porcentajeUsoCpu) {
        this.porcentajeUsoCpu = porcentajeUsoCpu;
    }

    public Double getRamUsadaGb() {
        return ramUsadaGb;
    }

    public void setRamUsadaGb(Double ramUsadaGb) {
        this.ramUsadaGb = ramUsadaGb;
    }

    public Double getTraficoRedRxMb() {
        return traficoRedRxMb;
    }

    public void setTraficoRedRxMb(Double traficoRedRxMb) {
        this.traficoRedRxMb = traficoRedRxMb;
    }

    public Double getTraficoRedTxMb() {
        return traficoRedTxMb;
    }

    public void setTraficoRedTxMb(Double traficoRedTxMb) {
        this.traficoRedTxMb = traficoRedTxMb;
    }

    public Integer getTotalProcesos() {
        return totalProcesos;
    }

    public void setTotalProcesos(Integer totalProcesos) {
        this.totalProcesos = totalProcesos;
    }

    public Date getFechaRegistro() {
        return fechaRegistro;
    }

    public void setFechaRegistro(Date fechaRegistro) {
        this.fechaRegistro = fechaRegistro;
    }

    @XmlTransient
    public List<Almacenamiento> getAlmacenamientoList() {
        return almacenamientoList;
    }

    public void setAlmacenamientoList(List<Almacenamiento> almacenamientoList) {
        this.almacenamientoList = almacenamientoList;
    }

    public Equipo getIdEquipo() {
        return idEquipo;
    }

    public void setIdEquipo(Equipo idEquipo) {
        this.idEquipo = idEquipo;
    }

    @Override
    public int hashCode() {
        int hash = 0;
        hash += (idInforme != null ? idInforme.hashCode() : 0);
        return hash;
    }

    @Override
    public boolean equals(Object object) {
        // TODO: Warning - this method won't work in the case the id fields are not set
        if (!(object instanceof Informe)) {
            return false;
        }
        Informe other = (Informe) object;
        if ((this.idInforme == null && other.idInforme != null) || (this.idInforme != null && !this.idInforme.equals(other.idInforme))) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return "modelo.Informe[ idInforme=" + idInforme + " ]";
    }
    
}
