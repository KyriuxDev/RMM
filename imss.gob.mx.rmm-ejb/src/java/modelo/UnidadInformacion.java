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
@Table(name = "unidad_informacion")
@XmlRootElement
@NamedQueries({
    @NamedQuery(name = "UnidadInformacion.findAll", query = "SELECT u FROM UnidadInformacion u"),
    @NamedQuery(name = "UnidadInformacion.findByClaveUi", query = "SELECT u FROM UnidadInformacion u WHERE u.claveUi = :claveUi"),
    @NamedQuery(name = "UnidadInformacion.findByDescripcion", query = "SELECT u FROM UnidadInformacion u WHERE u.descripcion = :descripcion"),
    @NamedQuery(name = "UnidadInformacion.findByTipoRegimen", query = "SELECT u FROM UnidadInformacion u WHERE u.tipoRegimen = :tipoRegimen")})
public class UnidadInformacion implements Serializable {

    private static final long serialVersionUID = 1L;
    @Id
    @Basic(optional = false)
    @NotNull
    @Size(min = 1, max = 10)
    @Column(name = "clave_ui")
    private String claveUi;
    @Basic(optional = false)
    @NotNull
    @Size(min = 1, max = 100)
    @Column(name = "descripcion")
    private String descripcion;
    @Basic(optional = false)
    @NotNull
    @Size(min = 1, max = 12)
    @Column(name = "tipo_regimen")
    private String tipoRegimen;
    @OneToMany(cascade = CascadeType.ALL, mappedBy = "claveUi")
    private List<UnidadCc> unidadCcList;

    public UnidadInformacion() {
    }

    public UnidadInformacion(String claveUi) {
        this.claveUi = claveUi;
    }

    public UnidadInformacion(String claveUi, String descripcion, String tipoRegimen) {
        this.claveUi = claveUi;
        this.descripcion = descripcion;
        this.tipoRegimen = tipoRegimen;
    }

    public String getClaveUi() {
        return claveUi;
    }

    public void setClaveUi(String claveUi) {
        this.claveUi = claveUi;
    }

    public String getDescripcion() {
        return descripcion;
    }

    public void setDescripcion(String descripcion) {
        this.descripcion = descripcion;
    }

    public String getTipoRegimen() {
        return tipoRegimen;
    }

    public void setTipoRegimen(String tipoRegimen) {
        this.tipoRegimen = tipoRegimen;
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
        hash += (claveUi != null ? claveUi.hashCode() : 0);
        return hash;
    }

    @Override
    public boolean equals(Object object) {
        // TODO: Warning - this method won't work in the case the id fields are not set
        if (!(object instanceof UnidadInformacion)) {
            return false;
        }
        UnidadInformacion other = (UnidadInformacion) object;
        if ((this.claveUi == null && other.claveUi != null) || (this.claveUi != null && !this.claveUi.equals(other.claveUi))) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return "modelo.UnidadInformacion[ claveUi=" + claveUi + " ]";
    }
    
}
