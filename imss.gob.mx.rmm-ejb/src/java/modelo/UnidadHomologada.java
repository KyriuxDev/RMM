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
@Table(name = "unidad_homologada")
@XmlRootElement
@NamedQueries({
    @NamedQuery(name = "UnidadHomologada.findAll", query = "SELECT u FROM UnidadHomologada u"),
    @NamedQuery(name = "UnidadHomologada.findByIdUnidadHomologada", query = "SELECT u FROM UnidadHomologada u WHERE u.idUnidadHomologada = :idUnidadHomologada"),
    @NamedQuery(name = "UnidadHomologada.findByNombre", query = "SELECT u FROM UnidadHomologada u WHERE u.nombre = :nombre")})
public class UnidadHomologada implements Serializable {

    private static final long serialVersionUID = 1L;
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Basic(optional = false)
    @Column(name = "id_unidad_homologada")
    private Short idUnidadHomologada;
    @Basic(optional = false)
    @NotNull
    @Size(min = 1, max = 150)
    @Column(name = "nombre")
    private String nombre;
    @OneToMany(mappedBy = "idUnidadHomologada")
    private List<Area> areaList;
    @JoinColumn(name = "id_clasificacion", referencedColumnName = "id_clasificacion")
    @ManyToOne(optional = false)
    private ClasificacionUnidad idClasificacion;
    @JoinColumn(name = "id_region", referencedColumnName = "id_region")
    @ManyToOne
    private Region idRegion;
    @JoinColumn(name = "num_zona", referencedColumnName = "num_zona")
    @ManyToOne
    private Zona numZona;

    public UnidadHomologada() {
    }

    public UnidadHomologada(Short idUnidadHomologada) {
        this.idUnidadHomologada = idUnidadHomologada;
    }

    public UnidadHomologada(Short idUnidadHomologada, String nombre) {
        this.idUnidadHomologada = idUnidadHomologada;
        this.nombre = nombre;
    }

    public Short getIdUnidadHomologada() {
        return idUnidadHomologada;
    }

    public void setIdUnidadHomologada(Short idUnidadHomologada) {
        this.idUnidadHomologada = idUnidadHomologada;
    }

    public String getNombre() {
        return nombre;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
    }

    @XmlTransient
    public List<Area> getAreaList() {
        return areaList;
    }

    public void setAreaList(List<Area> areaList) {
        this.areaList = areaList;
    }

    public ClasificacionUnidad getIdClasificacion() {
        return idClasificacion;
    }

    public void setIdClasificacion(ClasificacionUnidad idClasificacion) {
        this.idClasificacion = idClasificacion;
    }

    public Region getIdRegion() {
        return idRegion;
    }

    public void setIdRegion(Region idRegion) {
        this.idRegion = idRegion;
    }

    public Zona getNumZona() {
        return numZona;
    }

    public void setNumZona(Zona numZona) {
        this.numZona = numZona;
    }

    @Override
    public int hashCode() {
        int hash = 0;
        hash += (idUnidadHomologada != null ? idUnidadHomologada.hashCode() : 0);
        return hash;
    }

    @Override
    public boolean equals(Object object) {
        // TODO: Warning - this method won't work in the case the id fields are not set
        if (!(object instanceof UnidadHomologada)) {
            return false;
        }
        UnidadHomologada other = (UnidadHomologada) object;
        if ((this.idUnidadHomologada == null && other.idUnidadHomologada != null) || (this.idUnidadHomologada != null && !this.idUnidadHomologada.equals(other.idUnidadHomologada))) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return "modelo.UnidadHomologada[ idUnidadHomologada=" + idUnidadHomologada + " ]";
    }
    
}
