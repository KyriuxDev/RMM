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
import jakarta.persistence.ManyToMany;
import jakarta.persistence.NamedQueries;
import jakarta.persistence.NamedQuery;
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
@Table(name = "SLA")
@XmlRootElement
@NamedQueries({
    @NamedQuery(name = "Sla.findAll", query = "SELECT s FROM Sla s"),
    @NamedQuery(name = "Sla.findById", query = "SELECT s FROM Sla s WHERE s.id = :id"),
    @NamedQuery(name = "Sla.findByNombreIndicador", query = "SELECT s FROM Sla s WHERE s.nombreIndicador = :nombreIndicador"),
    @NamedQuery(name = "Sla.findByMetaValor", query = "SELECT s FROM Sla s WHERE s.metaValor = :metaValor"),
    @NamedQuery(name = "Sla.findByUnidadMedida", query = "SELECT s FROM Sla s WHERE s.unidadMedida = :unidadMedida"),
    @NamedQuery(name = "Sla.findByAmbito", query = "SELECT s FROM Sla s WHERE s.ambito = :ambito"),
    @NamedQuery(name = "Sla.findByValorAmbito", query = "SELECT s FROM Sla s WHERE s.valorAmbito = :valorAmbito")})
public class Sla implements Serializable {

    private static final long serialVersionUID = 1L;
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Basic(optional = false)
    @Column(name = "ID")
    private Integer id;
    @Basic(optional = false)
    @NotNull
    @Size(min = 1, max = 255)
    @Column(name = "NombreIndicador")
    private String nombreIndicador;
    @Basic(optional = false)
    @NotNull
    @Column(name = "MetaValor")
    private double metaValor;
    @Basic(optional = false)
    @NotNull
    @Size(min = 1, max = 255)
    @Column(name = "UnidadMedida")
    private String unidadMedida;
    @Basic(optional = false)
    @NotNull
    @Size(min = 1, max = 255)
    @Column(name = "Ambito")
    private String ambito;
    @Size(max = 255)
    @Column(name = "ValorAmbito")
    private String valorAmbito;
    @ManyToMany(mappedBy = "slaList")
    private List<ReporteEjecutivo> reporteEjecutivoList;

    public Sla() {
    }

    public Sla(Integer id) {
        this.id = id;
    }

    public Sla(Integer id, String nombreIndicador, double metaValor, String unidadMedida, String ambito) {
        this.id = id;
        this.nombreIndicador = nombreIndicador;
        this.metaValor = metaValor;
        this.unidadMedida = unidadMedida;
        this.ambito = ambito;
    }

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public String getNombreIndicador() {
        return nombreIndicador;
    }

    public void setNombreIndicador(String nombreIndicador) {
        this.nombreIndicador = nombreIndicador;
    }

    public double getMetaValor() {
        return metaValor;
    }

    public void setMetaValor(double metaValor) {
        this.metaValor = metaValor;
    }

    public String getUnidadMedida() {
        return unidadMedida;
    }

    public void setUnidadMedida(String unidadMedida) {
        this.unidadMedida = unidadMedida;
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

    @XmlTransient
    public List<ReporteEjecutivo> getReporteEjecutivoList() {
        return reporteEjecutivoList;
    }

    public void setReporteEjecutivoList(List<ReporteEjecutivo> reporteEjecutivoList) {
        this.reporteEjecutivoList = reporteEjecutivoList;
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
        if (!(object instanceof Sla)) {
            return false;
        }
        Sla other = (Sla) object;
        if ((this.id == null && other.id != null) || (this.id != null && !this.id.equals(other.id))) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return "modelo.Sla[ id=" + id + " ]";
    }
    
}
