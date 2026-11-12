/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package modelo;

import jakarta.persistence.Basic;
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
@Table(name = "ubicacion")
@XmlRootElement
@NamedQueries({
    @NamedQuery(name = "Ubicacion.findAll", query = "SELECT u FROM Ubicacion u"),
    @NamedQuery(name = "Ubicacion.findByCodigoUbicacion", query = "SELECT u FROM Ubicacion u WHERE u.codigoUbicacion = :codigoUbicacion"),
    @NamedQuery(name = "Ubicacion.findByDescripcion", query = "SELECT u FROM Ubicacion u WHERE u.descripcion = :descripcion")})
public class Ubicacion implements Serializable {

    private static final long serialVersionUID = 1L;
    @Id
    @Basic(optional = false)
    @NotNull
    @Size(min = 1, max = 10)
    @Column(name = "codigo_ubicacion")
    private String codigoUbicacion;
    @Size(max = 100)
    @Column(name = "descripcion")
    private String descripcion;
    @OneToMany(mappedBy = "codigoUbicacion")
    private List<Area> areaList;

    public Ubicacion() {
    }

    public Ubicacion(String codigoUbicacion) {
        this.codigoUbicacion = codigoUbicacion;
    }

    public String getCodigoUbicacion() {
        return codigoUbicacion;
    }

    public void setCodigoUbicacion(String codigoUbicacion) {
        this.codigoUbicacion = codigoUbicacion;
    }

    public String getDescripcion() {
        return descripcion;
    }

    public void setDescripcion(String descripcion) {
        this.descripcion = descripcion;
    }

    @XmlTransient
    public List<Area> getAreaList() {
        return areaList;
    }

    public void setAreaList(List<Area> areaList) {
        this.areaList = areaList;
    }

    @Override
    public int hashCode() {
        int hash = 0;
        hash += (codigoUbicacion != null ? codigoUbicacion.hashCode() : 0);
        return hash;
    }

    @Override
    public boolean equals(Object object) {
        // TODO: Warning - this method won't work in the case the id fields are not set
        if (!(object instanceof Ubicacion)) {
            return false;
        }
        Ubicacion other = (Ubicacion) object;
        if ((this.codigoUbicacion == null && other.codigoUbicacion != null) || (this.codigoUbicacion != null && !this.codigoUbicacion.equals(other.codigoUbicacion))) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return "modelo.Ubicacion[ codigoUbicacion=" + codigoUbicacion + " ]";
    }
    
}
