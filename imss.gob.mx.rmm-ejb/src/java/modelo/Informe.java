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
@Table(name = "Informe")
@XmlRootElement
@NamedQueries({
    @NamedQuery(name = "Informe.findAll", query = "SELECT i FROM Informe i"),
    @NamedQuery(name = "Informe.findById", query = "SELECT i FROM Informe i WHERE i.id = :id"),
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
    @Column(name = "ID")
    private Integer id;
    // @Max(value=?)  @Min(value=?)//if you know range of your decimal fields consider using these annotations to enforce field validation
    @Column(name = "PorcentajeUsoCpu")
    private Double porcentajeUsoCpu;
    @Column(name = "RamUsadaGb")
    private Double ramUsadaGb;
    @Column(name = "TraficoRedRxMb")
    private Double traficoRedRxMb;
    @Column(name = "TraficoRedTxMb")
    private Double traficoRedTxMb;
    @Column(name = "TotalProcesos")
    private Integer totalProcesos;
    @Column(name = "FechaRegistro")
    @Temporal(TemporalType.TIMESTAMP)
    private Date fechaRegistro;
    @OneToMany(cascade = CascadeType.ALL, mappedBy = "informeID")
    private List<Almacenamiento> almacenamientoList;
    @JoinColumn(name = "EquipoID", referencedColumnName = "ID")
    @ManyToOne(optional = false)
    private Equipo equipoID;

    public Informe() {
    }

    public Informe(Integer id) {
        this.id = id;
    }

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
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

    public Equipo getEquipoID() {
        return equipoID;
    }

    public void setEquipoID(Equipo equipoID) {
        this.equipoID = equipoID;
    }

    @Override
    public int hashCode() {
        int hash = 0;
        hash += (id != null ? id.hashCode() : 0);
        return hash;
    }

    @Override
    public boolean equals(Object object) {
        // TODO: Warning - this method won't work in the case the id fields are not set
        if (!(object instanceof Informe)) {
            return false;
        }
        Informe other = (Informe) object;
        if ((this.id == null && other.id != null) || (this.id != null && !this.id.equals(other.id))) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return "modelo.Informe[ id=" + id + " ]";
    }
    
}
