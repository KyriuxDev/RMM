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
@Table(name = "area")
@XmlRootElement
@NamedQueries({
    @NamedQuery(name = "Area.findAll", query = "SELECT a FROM Area a"),
    @NamedQuery(name = "Area.findByIdArea", query = "SELECT a FROM Area a WHERE a.idArea = :idArea"),
    @NamedQuery(name = "Area.findByDivision", query = "SELECT a FROM Area a WHERE a.division = :division"),
    @NamedQuery(name = "Area.findBySubdivision", query = "SELECT a FROM Area a WHERE a.subdivision = :subdivision"),
    @NamedQuery(name = "Area.findByCuenta", query = "SELECT a FROM Area a WHERE a.cuenta = :cuenta")})
public class Area implements Serializable {

    private static final long serialVersionUID = 1L;
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Basic(optional = false)
    @Column(name = "id_area")
    private Integer idArea;
    @Basic(optional = false)
    @NotNull
    @Size(min = 1, max = 5)
    @Column(name = "division")
    private String division;
    @Basic(optional = false)
    @NotNull
    @Size(min = 1, max = 5)
    @Column(name = "subdivision")
    private String subdivision;
    @Basic(optional = false)
    @NotNull
    @Column(name = "cuenta")
    private short cuenta;
    @JoinColumn(name = "codigo_ubicacion", referencedColumnName = "codigo_ubicacion")
    @ManyToOne
    private Ubicacion codigoUbicacion;
    @JoinColumn(name = "id_unidad_cc", referencedColumnName = "id_unidad_cc")
    @ManyToOne(optional = false)
    private UnidadCc idUnidadCc;
    @JoinColumn(name = "id_unidad_homologada", referencedColumnName = "id_unidad_homologada")
    @ManyToOne
    private UnidadHomologada idUnidadHomologada;
    @OneToMany(mappedBy = "idArea")
    private List<Equipo> equipoList;

    public Area() {
    }

    public Area(Integer idArea) {
        this.idArea = idArea;
    }

    public Area(Integer idArea, String division, String subdivision, short cuenta) {
        this.idArea = idArea;
        this.division = division;
        this.subdivision = subdivision;
        this.cuenta = cuenta;
    }

    public Integer getIdArea() {
        return idArea;
    }

    public void setIdArea(Integer idArea) {
        this.idArea = idArea;
    }

    public String getDivision() {
        return division;
    }

    public void setDivision(String division) {
        this.division = division;
    }

    public String getSubdivision() {
        return subdivision;
    }

    public void setSubdivision(String subdivision) {
        this.subdivision = subdivision;
    }

    public short getCuenta() {
        return cuenta;
    }

    public void setCuenta(short cuenta) {
        this.cuenta = cuenta;
    }

    public Ubicacion getCodigoUbicacion() {
        return codigoUbicacion;
    }

    public void setCodigoUbicacion(Ubicacion codigoUbicacion) {
        this.codigoUbicacion = codigoUbicacion;
    }

    public UnidadCc getIdUnidadCc() {
        return idUnidadCc;
    }

    public void setIdUnidadCc(UnidadCc idUnidadCc) {
        this.idUnidadCc = idUnidadCc;
    }

    public UnidadHomologada getIdUnidadHomologada() {
        return idUnidadHomologada;
    }

    public void setIdUnidadHomologada(UnidadHomologada idUnidadHomologada) {
        this.idUnidadHomologada = idUnidadHomologada;
    }

    @XmlTransient
    public List<Equipo> getEquipoList() {
        return equipoList;
    }

    public void setEquipoList(List<Equipo> equipoList) {
        this.equipoList = equipoList;
    }

    @Override
    public int hashCode() {
        int hash = 0;
        hash += (idArea != null ? idArea.hashCode() : 0);
        return hash;
    }

    @Override
    public boolean equals(Object object) {
        // TODO: Warning - this method won't work in the case the id fields are not set
        if (!(object instanceof Area)) {
            return false;
        }
        Area other = (Area) object;
        if ((this.idArea == null && other.idArea != null) || (this.idArea != null && !this.idArea.equals(other.idArea))) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return "modelo.Area[ idArea=" + idArea + " ]";
    }
    
}
