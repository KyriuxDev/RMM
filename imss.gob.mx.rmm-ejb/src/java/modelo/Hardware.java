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
import jakarta.persistence.NamedQueries;
import jakarta.persistence.NamedQuery;
import jakarta.persistence.OneToOne;
import jakarta.persistence.Table;
import jakarta.validation.constraints.Size;
import jakarta.xml.bind.annotation.XmlRootElement;
import java.io.Serializable;

/**
 *
 * @author kyriux
 */
@Entity
@Table(name = "hardware")
@XmlRootElement
@NamedQueries({
    @NamedQuery(name = "Hardware.findAll", query = "SELECT h FROM Hardware h"),
    @NamedQuery(name = "Hardware.findByIdHardware", query = "SELECT h FROM Hardware h WHERE h.idHardware = :idHardware"),
    @NamedQuery(name = "Hardware.findByModeloCpu", query = "SELECT h FROM Hardware h WHERE h.modeloCpu = :modeloCpu"),
    @NamedQuery(name = "Hardware.findByNucleosCpu", query = "SELECT h FROM Hardware h WHERE h.nucleosCpu = :nucleosCpu"),
    @NamedQuery(name = "Hardware.findByHilosCpu", query = "SELECT h FROM Hardware h WHERE h.hilosCpu = :hilosCpu"),
    @NamedQuery(name = "Hardware.findByTotalRamGb", query = "SELECT h FROM Hardware h WHERE h.totalRamGb = :totalRamGb"),
    @NamedQuery(name = "Hardware.findByModeloPlacaBase", query = "SELECT h FROM Hardware h WHERE h.modeloPlacaBase = :modeloPlacaBase"),
    @NamedQuery(name = "Hardware.findByCapacidadDiscoGb", query = "SELECT h FROM Hardware h WHERE h.capacidadDiscoGb = :capacidadDiscoGb")})
public class Hardware implements Serializable {

    private static final long serialVersionUID = 1L;
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Basic(optional = false)
    @Column(name = "id_hardware")
    private Integer idHardware;
    @Size(max = 255)
    @Column(name = "modelo_cpu")
    private String modeloCpu;
    @Column(name = "nucleos_cpu")
    private Integer nucleosCpu;
    @Column(name = "hilos_cpu")
    private Integer hilosCpu;
    // @Max(value=?)  @Min(value=?)//if you know range of your decimal fields consider using these annotations to enforce field validation
    @Column(name = "total_ram_gb")
    private Double totalRamGb;
    @Size(max = 255)
    @Column(name = "modelo_placa_base")
    private String modeloPlacaBase;
    @Column(name = "capacidad_disco_gb")
    private Double capacidadDiscoGb;
    @JoinColumn(name = "id_equipo", referencedColumnName = "id_equipo")
    @OneToOne(optional = false)
    private Equipo idEquipo;

    public Hardware() {
    }

    public Hardware(Integer idHardware) {
        this.idHardware = idHardware;
    }

    public Integer getIdHardware() {
        return idHardware;
    }

    public void setIdHardware(Integer idHardware) {
        this.idHardware = idHardware;
    }

    public String getModeloCpu() {
        return modeloCpu;
    }

    public void setModeloCpu(String modeloCpu) {
        this.modeloCpu = modeloCpu;
    }

    public Integer getNucleosCpu() {
        return nucleosCpu;
    }

    public void setNucleosCpu(Integer nucleosCpu) {
        this.nucleosCpu = nucleosCpu;
    }

    public Integer getHilosCpu() {
        return hilosCpu;
    }

    public void setHilosCpu(Integer hilosCpu) {
        this.hilosCpu = hilosCpu;
    }

    public Double getTotalRamGb() {
        return totalRamGb;
    }

    public void setTotalRamGb(Double totalRamGb) {
        this.totalRamGb = totalRamGb;
    }

    public String getModeloPlacaBase() {
        return modeloPlacaBase;
    }

    public void setModeloPlacaBase(String modeloPlacaBase) {
        this.modeloPlacaBase = modeloPlacaBase;
    }

    public Double getCapacidadDiscoGb() {
        return capacidadDiscoGb;
    }

    public void setCapacidadDiscoGb(Double capacidadDiscoGb) {
        this.capacidadDiscoGb = capacidadDiscoGb;
    }

    public Equipo getIdEquipo() {
        return idEquipo;
    }

    public void setIdEquipo(Equipo idEquipo) {
        this.idEquipo = idEquipo;
    }

    @Override
    public int hashCode() {
        int hash = 0;
        hash += (idHardware != null ? idHardware.hashCode() : 0);
        return hash;
    }

    @Override
    public boolean equals(Object object) {
        // TODO: Warning - this method won't work in the case the id fields are not set
        if (!(object instanceof Hardware)) {
            return false;
        }
        Hardware other = (Hardware) object;
        if ((this.idHardware == null && other.idHardware != null) || (this.idHardware != null && !this.idHardware.equals(other.idHardware))) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return "modelo.Hardware[ idHardware=" + idHardware + " ]";
    }
    
}
