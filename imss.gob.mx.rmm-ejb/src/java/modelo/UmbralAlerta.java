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
@Table(name = "umbral_alerta")
@XmlRootElement
@NamedQueries({
    @NamedQuery(name = "UmbralAlerta.findAll", query = "SELECT u FROM UmbralAlerta u"),
    @NamedQuery(name = "UmbralAlerta.findByIdUmbralAlerta", query = "SELECT u FROM UmbralAlerta u WHERE u.idUmbralAlerta = :idUmbralAlerta"),
    @NamedQuery(name = "UmbralAlerta.findByTipoRecurso", query = "SELECT u FROM UmbralAlerta u WHERE u.tipoRecurso = :tipoRecurso"),
    @NamedQuery(name = "UmbralAlerta.findByValorUmbral", query = "SELECT u FROM UmbralAlerta u WHERE u.valorUmbral = :valorUmbral"),
    @NamedQuery(name = "UmbralAlerta.findByAmbito", query = "SELECT u FROM UmbralAlerta u WHERE u.ambito = :ambito"),
    @NamedQuery(name = "UmbralAlerta.findByValorAmbito", query = "SELECT u FROM UmbralAlerta u WHERE u.valorAmbito = :valorAmbito"),
    @NamedQuery(name = "UmbralAlerta.findByActivo", query = "SELECT u FROM UmbralAlerta u WHERE u.activo = :activo")})
public class UmbralAlerta implements Serializable {

    private static final long serialVersionUID = 1L;
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Basic(optional = false)
    @Column(name = "id_umbral_alerta")
    private Integer idUmbralAlerta;
    @Basic(optional = false)
    @NotNull
    @Size(min = 1, max = 255)
    @Column(name = "tipo_recurso")
    private String tipoRecurso;
    @Basic(optional = false)
    @NotNull
    @Column(name = "valor_umbral")
    private double valorUmbral;
    @Basic(optional = false)
    @NotNull
    @Size(min = 1, max = 255)
    @Column(name = "ambito")
    private String ambito;
    @Size(max = 255)
    @Column(name = "valor_ambito")
    private String valorAmbito;
    @Column(name = "activo")
    private Boolean activo;
    @OneToMany(cascade = CascadeType.ALL, mappedBy = "idUmbralAlerta")
    private List<Alerta> alertaList;

    public UmbralAlerta() {
    }

    public UmbralAlerta(Integer idUmbralAlerta) {
        this.idUmbralAlerta = idUmbralAlerta;
    }

    public UmbralAlerta(Integer idUmbralAlerta, String tipoRecurso, double valorUmbral, String ambito) {
        this.idUmbralAlerta = idUmbralAlerta;
        this.tipoRecurso = tipoRecurso;
        this.valorUmbral = valorUmbral;
        this.ambito = ambito;
    }

    public Integer getIdUmbralAlerta() {
        return idUmbralAlerta;
    }

    public void setIdUmbralAlerta(Integer idUmbralAlerta) {
        this.idUmbralAlerta = idUmbralAlerta;
    }

    public String getTipoRecurso() {
        return tipoRecurso;
    }

    public void setTipoRecurso(String tipoRecurso) {
        this.tipoRecurso = tipoRecurso;
    }

    public double getValorUmbral() {
        return valorUmbral;
    }

    public void setValorUmbral(double valorUmbral) {
        this.valorUmbral = valorUmbral;
    }

    public String getAmbito() {
        return ambito;
    }

    public void setAmbito(String ambito) {
        this.ambito = ambito;
    }

    public String getValorAmbito() {
        return valorAmbito;
    }

    public void setValorAmbito(String valorAmbito) {
        this.valorAmbito = valorAmbito;
    }

    public Boolean getActivo() {
        return activo;
    }

    public void setActivo(Boolean activo) {
        this.activo = activo;
    }

    @XmlTransient
    public List<Alerta> getAlertaList() {
        return alertaList;
    }

    public void setAlertaList(List<Alerta> alertaList) {
        this.alertaList = alertaList;
    }

    @Override
    public int hashCode() {
        int hash = 0;
        hash += (idUmbralAlerta != null ? idUmbralAlerta.hashCode() : 0);
        return hash;
    }

    @Override
    public boolean equals(Object object) {
        // TODO: Warning - this method won't work in the case the id fields are not set
        if (!(object instanceof UmbralAlerta)) {
            return false;
        }
        UmbralAlerta other = (UmbralAlerta) object;
        if ((this.idUmbralAlerta == null && other.idUmbralAlerta != null) || (this.idUmbralAlerta != null && !this.idUmbralAlerta.equals(other.idUmbralAlerta))) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return "modelo.UmbralAlerta[ idUmbralAlerta=" + idUmbralAlerta + " ]";
    }
    
}
