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
@Table(name = "unidad_cc")
@XmlRootElement
@NamedQueries({
    @NamedQuery(name = "UnidadCc.findAll", query = "SELECT u FROM UnidadCc u"),
    @NamedQuery(name = "UnidadCc.findByIdUnidadCc", query = "SELECT u FROM UnidadCc u WHERE u.idUnidadCc = :idUnidadCc"),
    @NamedQuery(name = "UnidadCc.findByNombreImanDesglosado", query = "SELECT u FROM UnidadCc u WHERE u.nombreImanDesglosado = :nombreImanDesglosado"),
    @NamedQuery(name = "UnidadCc.findByUicc", query = "SELECT u FROM UnidadCc u WHERE u.uicc = :uicc")})
public class UnidadCc implements Serializable {

    private static final long serialVersionUID = 1L;
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Basic(optional = false)
    @Column(name = "id_unidad_cc")
    private Integer idUnidadCc;
    @Size(max = 150)
    @Column(name = "nombre_iman_desglosado")
    private String nombreImanDesglosado;
    @Size(max = 20)
    @Column(name = "uicc")
    private String uicc;
    @OneToMany(cascade = CascadeType.ALL, mappedBy = "idUnidadCc")
    private List<Area> areaList;
    @JoinColumn(name = "clave_cc", referencedColumnName = "clave_cc")
    @ManyToOne(optional = false)
    private CentroCosto claveCc;
    @JoinColumn(name = "clave_ui", referencedColumnName = "clave_ui")
    @ManyToOne(optional = false)
    private UnidadInformacion claveUi;

    public UnidadCc() {
    }

    public UnidadCc(Integer idUnidadCc) {
        this.idUnidadCc = idUnidadCc;
    }

    public Integer getIdUnidadCc() {
        return idUnidadCc;
    }

    public void setIdUnidadCc(Integer idUnidadCc) {
        this.idUnidadCc = idUnidadCc;
    }

    public String getNombreImanDesglosado() {
        return nombreImanDesglosado;
    }

    public void setNombreImanDesglosado(String nombreImanDesglosado) {
        this.nombreImanDesglosado = nombreImanDesglosado;
    }

    public String getUicc() {
        return uicc;
    }

    public void setUicc(String uicc) {
        this.uicc = uicc;
    }

    @XmlTransient
    public List<Area> getAreaList() {
        return areaList;
    }

    public void setAreaList(List<Area> areaList) {
        this.areaList = areaList;
    }

    public CentroCosto getClaveCc() {
        return claveCc;
    }

    public void setClaveCc(CentroCosto claveCc) {
        this.claveCc = claveCc;
    }

    public UnidadInformacion getClaveUi() {
        return claveUi;
    }

    public void setClaveUi(UnidadInformacion claveUi) {
        this.claveUi = claveUi;
    }

    @Override
    public int hashCode() {
        int hash = 0;
        hash += (idUnidadCc != null ? idUnidadCc.hashCode() : 0);
        return hash;
    }

    @Override
    public boolean equals(Object object) {
        // TODO: Warning - this method won't work in the case the id fields are not set
        if (!(object instanceof UnidadCc)) {
            return false;
        }
        UnidadCc other = (UnidadCc) object;
        if ((this.idUnidadCc == null && other.idUnidadCc != null) || (this.idUnidadCc != null && !this.idUnidadCc.equals(other.idUnidadCc))) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return "modelo.UnidadCc[ idUnidadCc=" + idUnidadCc + " ]";
    }
    
}
