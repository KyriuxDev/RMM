/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package modelo;

import jakarta.persistence.Basic;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.NamedQueries;
import jakarta.persistence.NamedQuery;
import jakarta.persistence.OneToMany;
import jakarta.persistence.Table;
import jakarta.validation.constraints.NotNull;
import jakarta.xml.bind.annotation.XmlRootElement;
import jakarta.xml.bind.annotation.XmlTransient;
import java.io.Serializable;
import java.util.List;

/**
 *
 * @author kyriux
 */
@Entity
@Table(name = "zona")
@XmlRootElement
@NamedQueries({
    @NamedQuery(name = "Zona.findAll", query = "SELECT z FROM Zona z"),
    @NamedQuery(name = "Zona.findByNumZona", query = "SELECT z FROM Zona z WHERE z.numZona = :numZona")})
public class Zona implements Serializable {

    private static final long serialVersionUID = 1L;
    @Id
    @Basic(optional = false)
    @NotNull
    @Column(name = "num_zona")
    private Short numZona;
    @OneToMany(mappedBy = "numZona")
    private List<UnidadHomologada> unidadHomologadaList;
    @JoinColumn(name = "id_region", referencedColumnName = "id_region")
    @ManyToOne(optional = false)
    private Region idRegion;

    public Zona() {
    }

    public Zona(Short numZona) {
        this.numZona = numZona;
    }

    public Short getNumZona() {
        return numZona;
    }

    public void setNumZona(Short numZona) {
        this.numZona = numZona;
    }

    @XmlTransient
    public List<UnidadHomologada> getUnidadHomologadaList() {
        return unidadHomologadaList;
    }

    public void setUnidadHomologadaList(List<UnidadHomologada> unidadHomologadaList) {
        this.unidadHomologadaList = unidadHomologadaList;
    }

    public Region getIdRegion() {
        return idRegion;
    }

    public void setIdRegion(Region idRegion) {
        this.idRegion = idRegion;
    }

    @Override
    public int hashCode() {
        int hash = 0;
        hash += (numZona != null ? numZona.hashCode() : 0);
        return hash;
    }

    @Override
    public boolean equals(Object object) {
        // TODO: Warning - this method won't work in the case the id fields are not set
        if (!(object instanceof Zona)) {
            return false;
        }
        Zona other = (Zona) object;
        if ((this.numZona == null && other.numZona != null) || (this.numZona != null && !this.numZona.equals(other.numZona))) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return "modelo.Zona[ numZona=" + numZona + " ]";
    }
    
}
