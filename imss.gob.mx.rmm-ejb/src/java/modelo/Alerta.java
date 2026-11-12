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
import jakarta.persistence.Temporal;
import jakarta.persistence.TemporalType;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import jakarta.xml.bind.annotation.XmlRootElement;
import jakarta.xml.bind.annotation.XmlTransient;
import java.io.Serializable;
import java.util.Date;
import java.util.List;

/**
 *
 * @author kyriux
 */
@Entity
@Table(name = "Alerta")
@XmlRootElement
@NamedQueries({
    @NamedQuery(name = "Alerta.findAll", query = "SELECT a FROM Alerta a"),
    @NamedQuery(name = "Alerta.findById", query = "SELECT a FROM Alerta a WHERE a.id = :id"),
    @NamedQuery(name = "Alerta.findByTipoAlerta", query = "SELECT a FROM Alerta a WHERE a.tipoAlerta = :tipoAlerta"),
    @NamedQuery(name = "Alerta.findByNivelGravedad", query = "SELECT a FROM Alerta a WHERE a.nivelGravedad = :nivelGravedad"),
    @NamedQuery(name = "Alerta.findByDescripcion", query = "SELECT a FROM Alerta a WHERE a.descripcion = :descripcion"),
    @NamedQuery(name = "Alerta.findByFechaGeneracion", query = "SELECT a FROM Alerta a WHERE a.fechaGeneracion = :fechaGeneracion"),
    @NamedQuery(name = "Alerta.findByEstado", query = "SELECT a FROM Alerta a WHERE a.estado = :estado")})
public class Alerta implements Serializable {

    private static final long serialVersionUID = 1L;
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Basic(optional = false)
    @Column(name = "ID")
    private Integer id;
    @Basic(optional = false)
    @NotNull
    @Size(min = 1, max = 255)
    @Column(name = "TipoAlerta")
    private String tipoAlerta;
    @Basic(optional = false)
    @NotNull
    @Size(min = 1, max = 255)
    @Column(name = "NivelGravedad")
    private String nivelGravedad;
    @Size(max = 255)
    @Column(name = "Descripcion")
    private String descripcion;
    @Column(name = "FechaGeneracion")
    @Temporal(TemporalType.TIMESTAMP)
    private Date fechaGeneracion;
    @Basic(optional = false)
    @NotNull
    @Size(min = 1, max = 255)
    @Column(name = "Estado")
    private String estado;
    @OneToMany(cascade = CascadeType.ALL, mappedBy = "alertaID")
    private List<Notificacion> notificacionList;
    @JoinColumn(name = "EquipoID", referencedColumnName = "ID")
    @ManyToOne(optional = false)
    private Equipo equipoID;
    @JoinColumn(name = "UmbralAlertaID", referencedColumnName = "ID")
    @ManyToOne(optional = false)
    private UmbralAlerta umbralAlertaID;
    @OneToMany(mappedBy = "alertaID")
    private List<Incidencia> incidenciaList;

    public Alerta() {
    }

    public Alerta(Integer id) {
        this.id = id;
    }

    public Alerta(Integer id, String tipoAlerta, String nivelGravedad, String estado) {
        this.id = id;
        this.tipoAlerta = tipoAlerta;
        this.nivelGravedad = nivelGravedad;
        this.estado = estado;
    }

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public String getTipoAlerta() {
        return tipoAlerta;
    }

    public void setTipoAlerta(String tipoAlerta) {
        this.tipoAlerta = tipoAlerta;
    }

    public String getNivelGravedad() {
        return nivelGravedad;
    }

    public void setNivelGravedad(String nivelGravedad) {
        this.nivelGravedad = nivelGravedad;
    }

    public String getDescripcion() {
        return descripcion;
    }

    public void setDescripcion(String descripcion) {
        this.descripcion = descripcion;
    }

    public Date getFechaGeneracion() {
        return fechaGeneracion;
    }

    public void setFechaGeneracion(Date fechaGeneracion) {
        this.fechaGeneracion = fechaGeneracion;
    }

    public String getEstado() {
        return estado;
    }

    public void setEstado(String estado) {
        this.estado = estado;
    }

    @XmlTransient
    public List<Notificacion> getNotificacionList() {
        return notificacionList;
    }

    public void setNotificacionList(List<Notificacion> notificacionList) {
        this.notificacionList = notificacionList;
    }

    public Equipo getEquipoID() {
        return equipoID;
    }

    public void setEquipoID(Equipo equipoID) {
        this.equipoID = equipoID;
    }

    public UmbralAlerta getUmbralAlertaID() {
        return umbralAlertaID;
    }

    public void setUmbralAlertaID(UmbralAlerta umbralAlertaID) {
        this.umbralAlertaID = umbralAlertaID;
    }

    @XmlTransient
    public List<Incidencia> getIncidenciaList() {
        return incidenciaList;
    }

    public void setIncidenciaList(List<Incidencia> incidenciaList) {
        this.incidenciaList = incidenciaList;
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
        if (!(object instanceof Alerta)) {
            return false;
        }
        Alerta other = (Alerta) object;
        if ((this.id == null && other.id != null) || (this.id != null && !this.id.equals(other.id))) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return "modelo.Alerta[ id=" + id + " ]";
    }
    
}
