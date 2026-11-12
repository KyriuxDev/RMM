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
@Table(name = "sla")
@XmlRootElement
@NamedQueries({
    @NamedQuery(name = "Sla.findAll", query = "SELECT s FROM Sla s"),
    @NamedQuery(name = "Sla.findByIdSla", query = "SELECT s FROM Sla s WHERE s.idSla = :idSla"),
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
    @Column(name = "id_sla")
    private Integer idSla;
    @Basic(optional = false)
    @NotNull
    @Size(min = 1, max = 255)
    @Column(name = "nombre_indicador")
    private String nombreIndicador;
    @Basic(optional = false)
    @NotNull
    @Column(name = "meta_valor")
    private double metaValor;
    @Basic(optional = false)
    @NotNull
    @Size(min = 1, max = 255)
    @Column(name = "unidad_medida")
    private String unidadMedida;
    @Basic(optional = false)
    @NotNull
    @Size(min = 1, max = 255)
    @Column(name = "ambito")
    private String ambito;
    @Size(max = 255)
    @Column(name = "valor_ambito")
    private String valorAmbito;
    @ManyToMany(mappedBy = "slaList")
    private List<ReporteEjecutivo> reporteEjecutivoList;

    public Sla() {
    }

    public Sla(Integer idSla) {
        this.idSla = idSla;
    }

    public Sla(Integer idSla, String nombreIndicador, double metaValor, String unidadMedida, String ambito) {
        this.idSla = idSla;
        this.nombreIndicador = nombreIndicador;
        this.metaValor = metaValor;
        this.unidadMedida = unidadMedida;
        this.ambito = ambito;
    }

    public Integer getIdSla() {
        return idSla;
    }

    public void setIdSla(Integer idSla) {
        this.idSla = idSla;
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
        hash += (idSla != null ? idSla.hashCode() : 0);
        return hash;
    }

    @Override
    public boolean equals(Object object) {
        // TODO: Warning - this method won't work in the case the id fields are not set
        if (!(object instanceof Sla)) {
            return false;
        }
        Sla other = (Sla) object;
        if ((this.idSla == null && other.idSla != null) || (this.idSla != null && !this.idSla.equals(other.idSla))) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return "modelo.Sla[ idSla=" + idSla + " ]";
    }
    
}
