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
@Table(name = "clasificacion_unidad")
@XmlRootElement
@NamedQueries({
    @NamedQuery(name = "ClasificacionUnidad.findAll", query = "SELECT c FROM ClasificacionUnidad c"),
    @NamedQuery(name = "ClasificacionUnidad.findByIdClasificacion", query = "SELECT c FROM ClasificacionUnidad c WHERE c.idClasificacion = :idClasificacion"),
    @NamedQuery(name = "ClasificacionUnidad.findByTipoUnidad", query = "SELECT c FROM ClasificacionUnidad c WHERE c.tipoUnidad = :tipoUnidad"),
    @NamedQuery(name = "ClasificacionUnidad.findBySubTipoUnidad", query = "SELECT c FROM ClasificacionUnidad c WHERE c.subTipoUnidad = :subTipoUnidad"),
    @NamedQuery(name = "ClasificacionUnidad.findByAgrupacionTipo", query = "SELECT c FROM ClasificacionUnidad c WHERE c.agrupacionTipo = :agrupacionTipo")})
public class ClasificacionUnidad implements Serializable {

    private static final long serialVersionUID = 1L;
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Basic(optional = false)
    @Column(name = "id_clasificacion")
    private Short idClasificacion;
    @Basic(optional = false)
    @NotNull
    @Size(min = 1, max = 50)
    @Column(name = "tipo_unidad")
    private String tipoUnidad;
    @Basic(optional = false)
    @NotNull
    @Size(min = 1, max = 50)
    @Column(name = "sub_tipo_unidad")
    private String subTipoUnidad;
    @Basic(optional = false)
    @NotNull
    @Size(min = 1, max = 100)
    @Column(name = "agrupacion_tipo")
    private String agrupacionTipo;
    @OneToMany(cascade = CascadeType.ALL, mappedBy = "idClasificacion")
    private List<UnidadHomologada> unidadHomologadaList;

    public ClasificacionUnidad() {
    }

    public ClasificacionUnidad(Short idClasificacion) {
        this.idClasificacion = idClasificacion;
    }

    public ClasificacionUnidad(Short idClasificacion, String tipoUnidad, String subTipoUnidad, String agrupacionTipo) {
        this.idClasificacion = idClasificacion;
        this.tipoUnidad = tipoUnidad;
        this.subTipoUnidad = subTipoUnidad;
        this.agrupacionTipo = agrupacionTipo;
    }

    public Short getIdClasificacion() {
        return idClasificacion;
    }

    public void setIdClasificacion(Short idClasificacion) {
        this.idClasificacion = idClasificacion;
    }

    public String getTipoUnidad() {
        return tipoUnidad;
    }

    public void setTipoUnidad(String tipoUnidad) {
        this.tipoUnidad = tipoUnidad;
    }

    public String getSubTipoUnidad() {
        return subTipoUnidad;
    }

    public void setSubTipoUnidad(String subTipoUnidad) {
        this.subTipoUnidad = subTipoUnidad;
    }

    public String getAgrupacionTipo() {
        return agrupacionTipo;
    }

    public void setAgrupacionTipo(String agrupacionTipo) {
        this.agrupacionTipo = agrupacionTipo;
    }

    @XmlTransient
    public List<UnidadHomologada> getUnidadHomologadaList() {
        return unidadHomologadaList;
    }

    public void setUnidadHomologadaList(List<UnidadHomologada> unidadHomologadaList) {
        this.unidadHomologadaList = unidadHomologadaList;
    }

    @Override
    public int hashCode() {
        int hash = 0;
        hash += (idClasificacion != null ? idClasificacion.hashCode() : 0);
        return hash;
    }

    @Override
    public boolean equals(Object object) {
        // TODO: Warning - this method won't work in the case the id fields are not set
        if (!(object instanceof ClasificacionUnidad)) {
            return false;
        }
        ClasificacionUnidad other = (ClasificacionUnidad) object;
        if ((this.idClasificacion == null && other.idClasificacion != null) || (this.idClasificacion != null && !this.idClasificacion.equals(other.idClasificacion))) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return "modelo.ClasificacionUnidad[ idClasificacion=" + idClasificacion + " ]";
    }
    
}
