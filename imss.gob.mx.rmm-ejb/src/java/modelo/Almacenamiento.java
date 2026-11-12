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
import jakarta.persistence.ManyToOne;
import jakarta.persistence.NamedQueries;
import jakarta.persistence.NamedQuery;
import jakarta.persistence.Table;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import jakarta.xml.bind.annotation.XmlRootElement;
import java.io.Serializable;

/**
 *
 * @author kyriux
 */
@Entity
@Table(name = "Almacenamiento")
@XmlRootElement
@NamedQueries({
    @NamedQuery(name = "Almacenamiento.findAll", query = "SELECT a FROM Almacenamiento a"),
    @NamedQuery(name = "Almacenamiento.findById", query = "SELECT a FROM Almacenamiento a WHERE a.id = :id"),
    @NamedQuery(name = "Almacenamiento.findByPuntoMontaje", query = "SELECT a FROM Almacenamiento a WHERE a.puntoMontaje = :puntoMontaje"),
    @NamedQuery(name = "Almacenamiento.findByCapacidadTotalGb", query = "SELECT a FROM Almacenamiento a WHERE a.capacidadTotalGb = :capacidadTotalGb"),
    @NamedQuery(name = "Almacenamiento.findByEspacioLibreGb", query = "SELECT a FROM Almacenamiento a WHERE a.espacioLibreGb = :espacioLibreGb")})
public class Almacenamiento implements Serializable {

    private static final long serialVersionUID = 1L;
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Basic(optional = false)
    @Column(name = "ID")
    private Integer id;
    @Basic(optional = false)
    @NotNull
    @Size(min = 1, max = 255)
    @Column(name = "PuntoMontaje")
    private String puntoMontaje;
    @Basic(optional = false)
    @NotNull
    @Column(name = "CapacidadTotalGb")
    private double capacidadTotalGb;
    @Basic(optional = false)
    @NotNull
    @Column(name = "EspacioLibreGb")
    private double espacioLibreGb;
    @JoinColumn(name = "InformeID", referencedColumnName = "ID")
    @ManyToOne(optional = false)
    private Informe informeID;

    public Almacenamiento() {
    }

    public Almacenamiento(Integer id) {
        this.id = id;
    }

    public Almacenamiento(Integer id, String puntoMontaje, double capacidadTotalGb, double espacioLibreGb) {
        this.id = id;
        this.puntoMontaje = puntoMontaje;
        this.capacidadTotalGb = capacidadTotalGb;
        this.espacioLibreGb = espacioLibreGb;
    }

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public String getPuntoMontaje() {
        return puntoMontaje;
    }

    public void setPuntoMontaje(String puntoMontaje) {
        this.puntoMontaje = puntoMontaje;
    }

    public double getCapacidadTotalGb() {
        return capacidadTotalGb;
    }

    public void setCapacidadTotalGb(double capacidadTotalGb) {
        this.capacidadTotalGb = capacidadTotalGb;
    }

    public double getEspacioLibreGb() {
        return espacioLibreGb;
    }

    public void setEspacioLibreGb(double espacioLibreGb) {
        this.espacioLibreGb = espacioLibreGb;
    }

    public Informe getInformeID() {
        return informeID;
    }

    public void setInformeID(Informe informeID) {
        this.informeID = informeID;
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
        if (!(object instanceof Almacenamiento)) {
            return false;
        }
        Almacenamiento other = (Almacenamiento) object;
        if ((this.id == null && other.id != null) || (this.id != null && !this.id.equals(other.id))) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return "modelo.Almacenamiento[ id=" + id + " ]";
    }
    
}
