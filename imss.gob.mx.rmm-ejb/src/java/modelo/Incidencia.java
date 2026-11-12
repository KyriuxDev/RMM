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
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import jakarta.xml.bind.annotation.XmlRootElement;
import java.io.Serializable;
import java.util.Date;

/**
 *
 * @author kyriux
 */
@Entity
@Table(name = "Incidencia")
@XmlRootElement
@NamedQueries({
    @NamedQuery(name = "Incidencia.findAll", query = "SELECT i FROM Incidencia i"),
    @NamedQuery(name = "Incidencia.findById", query = "SELECT i FROM Incidencia i WHERE i.id = :id"),
    @NamedQuery(name = "Incidencia.findByDescripcion", query = "SELECT i FROM Incidencia i WHERE i.descripcion = :descripcion"),
    @NamedQuery(name = "Incidencia.findByPrioridad", query = "SELECT i FROM Incidencia i WHERE i.prioridad = :prioridad"),
    @NamedQuery(name = "Incidencia.findByEstado", query = "SELECT i FROM Incidencia i WHERE i.estado = :estado"),
    @NamedQuery(name = "Incidencia.findByOrigen", query = "SELECT i FROM Incidencia i WHERE i.origen = :origen"),
    @NamedQuery(name = "Incidencia.findByFechaRegistro", query = "SELECT i FROM Incidencia i WHERE i.fechaRegistro = :fechaRegistro"),
    @NamedQuery(name = "Incidencia.findByFechaResolucion", query = "SELECT i FROM Incidencia i WHERE i.fechaResolucion = :fechaResolucion")})
public class Incidencia implements Serializable {

    private static final long serialVersionUID = 1L;
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Basic(optional = false)
    @Column(name = "ID")
    private Integer id;
    @Basic(optional = false)
    @NotNull
    @Size(min = 1, max = 255)
    @Column(name = "Descripcion")
    private String descripcion;
    @Basic(optional = false)
    @NotNull
    @Size(min = 1, max = 255)
    @Column(name = "Prioridad")
    private String prioridad;
    @Basic(optional = false)
    @NotNull
    @Size(min = 1, max = 255)
    @Column(name = "Estado")
    private String estado;
    @Basic(optional = false)
    @NotNull
    @Size(min = 1, max = 255)
    @Column(name = "Origen")
    private String origen;
    @Column(name = "FechaRegistro")
    @Temporal(TemporalType.TIMESTAMP)
    private Date fechaRegistro;
    @Column(name = "FechaResolucion")
    @Temporal(TemporalType.TIMESTAMP)
    private Date fechaResolucion;
    @JoinColumn(name = "AlertaID", referencedColumnName = "ID")
    @ManyToOne
    private Alerta alertaID;
    @JoinColumn(name = "EquipoID", referencedColumnName = "ID")
    @ManyToOne(optional = false)
    private Equipo equipoID;
    @JoinColumn(name = "UsuarioID", referencedColumnName = "ID")
    @ManyToOne(optional = false)
    private Usuario usuarioID;

    public Incidencia() {
    }

    public Incidencia(Integer id) {
        this.id = id;
    }

    public Incidencia(Integer id, String descripcion, String prioridad, String estado, String origen) {
        this.id = id;
        this.descripcion = descripcion;
        this.prioridad = prioridad;
        this.estado = estado;
        this.origen = origen;
    }

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public String getDescripcion() {
        return descripcion;
    }

    public void setDescripcion(String descripcion) {
        this.descripcion = descripcion;
    }

    public String getPrioridad() {
        return prioridad;
    }

    public void setPrioridad(String prioridad) {
        this.prioridad = prioridad;
    }

    public String getEstado() {
        return estado;
    }

    public void setEstado(String estado) {
        this.estado = estado;
    }

    public String getOrigen() {
        return origen;
    }

    public void setOrigen(String origen) {
        this.origen = origen;
    }

    public Date getFechaRegistro() {
        return fechaRegistro;
    }

    public void setFechaRegistro(Date fechaRegistro) {
        this.fechaRegistro = fechaRegistro;
    }

    public Date getFechaResolucion() {
        return fechaResolucion;
    }

    public void setFechaResolucion(Date fechaResolucion) {
        this.fechaResolucion = fechaResolucion;
    }

    public Alerta getAlertaID() {
        return alertaID;
    }

    public void setAlertaID(Alerta alertaID) {
        this.alertaID = alertaID;
    }

    public Equipo getEquipoID() {
        return equipoID;
    }

    public void setEquipoID(Equipo equipoID) {
        this.equipoID = equipoID;
    }

    public Usuario getUsuarioID() {
        return usuarioID;
    }

    public void setUsuarioID(Usuario usuarioID) {
        this.usuarioID = usuarioID;
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
        if (!(object instanceof Incidencia)) {
            return false;
        }
        Incidencia other = (Incidencia) object;
        if ((this.id == null && other.id != null) || (this.id != null && !this.id.equals(other.id))) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return "modelo.Incidencia[ id=" + id + " ]";
    }
    
}
