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
import jakarta.persistence.Table;
import jakarta.persistence.Temporal;
import jakarta.persistence.TemporalType;
import jakarta.validation.constraints.Size;
import jakarta.xml.bind.annotation.XmlRootElement;
import java.io.Serializable;
import java.util.Date;

/**
 *
 * @author kyriux
 */
@Entity
@Table(name = "SesionMonitoreo")
@XmlRootElement
@NamedQueries({
    @NamedQuery(name = "SesionMonitoreo.findAll", query = "SELECT s FROM SesionMonitoreo s"),
    @NamedQuery(name = "SesionMonitoreo.findById", query = "SELECT s FROM SesionMonitoreo s WHERE s.id = :id"),
    @NamedQuery(name = "SesionMonitoreo.findByInicioSesion", query = "SELECT s FROM SesionMonitoreo s WHERE s.inicioSesion = :inicioSesion"),
    @NamedQuery(name = "SesionMonitoreo.findByFinSesion", query = "SELECT s FROM SesionMonitoreo s WHERE s.finSesion = :finSesion"),
    @NamedQuery(name = "SesionMonitoreo.findByDesconexionAbrupta", query = "SELECT s FROM SesionMonitoreo s WHERE s.desconexionAbrupta = :desconexionAbrupta"),
    @NamedQuery(name = "SesionMonitoreo.findByIpOrigen", query = "SELECT s FROM SesionMonitoreo s WHERE s.ipOrigen = :ipOrigen")})
public class SesionMonitoreo implements Serializable {

    private static final long serialVersionUID = 1L;
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Basic(optional = false)
    @Column(name = "ID")
    private Integer id;
    @Column(name = "InicioSesion")
    @Temporal(TemporalType.TIMESTAMP)
    private Date inicioSesion;
    @Column(name = "FinSesion")
    @Temporal(TemporalType.TIMESTAMP)
    private Date finSesion;
    @Column(name = "DesconexionAbrupta")
    private Boolean desconexionAbrupta;
    @Size(max = 255)
    @Column(name = "IpOrigen")
    private String ipOrigen;
    @JoinColumn(name = "EquipoID", referencedColumnName = "ID")
    @ManyToOne(optional = false)
    private Equipo equipoID;

    public SesionMonitoreo() {
    }

    public SesionMonitoreo(Integer id) {
        this.id = id;
    }

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public Date getInicioSesion() {
        return inicioSesion;
    }

    public void setInicioSesion(Date inicioSesion) {
        this.inicioSesion = inicioSesion;
    }

    public Date getFinSesion() {
        return finSesion;
    }

    public void setFinSesion(Date finSesion) {
        this.finSesion = finSesion;
    }

    public Boolean getDesconexionAbrupta() {
        return desconexionAbrupta;
    }

    public void setDesconexionAbrupta(Boolean desconexionAbrupta) {
        this.desconexionAbrupta = desconexionAbrupta;
    }

    public String getIpOrigen() {
        return ipOrigen;
    }

    public void setIpOrigen(String ipOrigen) {
        this.ipOrigen = ipOrigen;
    }

    public Equipo getEquipoID() {
        return equipoID;
    }

    public void setEquipoID(Equipo equipoID) {
        this.equipoID = equipoID;
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
        if (!(object instanceof SesionMonitoreo)) {
            return false;
        }
        SesionMonitoreo other = (SesionMonitoreo) object;
        if ((this.id == null && other.id != null) || (this.id != null && !this.id.equals(other.id))) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return "modelo.SesionMonitoreo[ id=" + id + " ]";
    }
    
}
