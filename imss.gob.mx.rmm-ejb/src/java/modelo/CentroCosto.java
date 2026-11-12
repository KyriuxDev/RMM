/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package modelo;

import jakarta.persistence.Basic;
import jakarta.persistence.CascadeType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.NamedQueries;
import jakarta.persistence.NamedQuery;
import jakarta.persistence.OneToMany;
import jakarta.persistence.Table;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import jakarta.xml.bind.annotation.XmlRootElement;
import jakarta.xml.bind.annotation.XmlTransient;
import java.io.Serializable;
import java.util.List;

/**
 *
 * @author kyriux
 */
@Entity
@Table(name = "centro_costo")
@XmlRootElement
@NamedQueries({
    @NamedQuery(name = "CentroCosto.findAll", query = "SELECT c FROM CentroCosto c"),
    @NamedQuery(name = "CentroCosto.findByClaveCc", query = "SELECT c FROM CentroCosto c WHERE c.claveCc = :claveCc"),
    @NamedQuery(name = "CentroCosto.findByDescripcion", query = "SELECT c FROM CentroCosto c WHERE c.descripcion = :descripcion")})
public class CentroCosto implements Serializable {

    private static final long serialVersionUID = 1L;
    @Id
    @Basic(optional = false)
    @NotNull
    @Size(min = 1, max = 10)
    @Column(name = "clave_cc")
    private String claveCc;
    @Basic(optional = false)
    @NotNull
    @Size(min = 1, max = 100)
    @Column(name = "descripcion")
    private String descripcion;
    @OneToMany(cascade = CascadeType.ALL, mappedBy = "claveCc")
    private List<UnidadCc> unidadCcList;

    public CentroCosto() {
    }

    public CentroCosto(String claveCc) {
        this.claveCc = claveCc;
    }

    public CentroCosto(String claveCc, String descripcion) {
        this.claveCc = claveCc;
        this.descripcion = descripcion;
    }

    public String getClaveCc() {
        return claveCc;
    }

    public void setClaveCc(String claveCc) {
        this.claveCc = claveCc;
    }

    public String getDescripcion() {
        return descripcion;
    }

    public void setDescripcion(String descripcion) {
        this.descripcion = descripcion;
    }

    @XmlTransient
    public List<UnidadCc> getUnidadCcList() {
        return unidadCcList;
    }

    public void setUnidadCcList(List<UnidadCc> unidadCcList) {
        this.unidadCcList = unidadCcList;
    }

    @Override
    public int hashCode() {
        int hash = 0;
        hash += (claveCc != null ? claveCc.hashCode() : 0);
        return hash;
    }

    @Override
    public boolean equals(Object object) {
        // TODO: Warning - this method won't work in the case the id fields are not set
        if (!(object instanceof CentroCosto)) {
            return false;
        }
        CentroCosto other = (CentroCosto) object;
        if ((this.claveCc == null && other.claveCc != null) || (this.claveCc != null && !this.claveCc.equals(other.claveCc))) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return "modelo.CentroCosto[ claveCc=" + claveCc + " ]";
    }
    
}
