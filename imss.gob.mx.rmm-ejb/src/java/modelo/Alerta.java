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
@Table(name = "alerta")
@XmlRootElement
@NamedQueries({
    @NamedQuery(name = "Alerta.findAll", query = "SELECT a FROM Alerta a"),
    @NamedQuery(name = "Alerta.findByIdAlerta", query = "SELECT a FROM Alerta a WHERE a.idAlerta = :idAlerta"),
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
    @Column(name = "id_alerta")
    private Integer idAlerta;
    @Basic(optional = false)
    @NotNull
    @Size(min = 1, max = 255)
    @Column(name = "tipo_alerta")
    private String tipoAlerta;
    @Basic(optional = false)
    @NotNull
    @Size(min = 1, max = 255)
    @Column(name = "nivel_gravedad")
    private String nivelGravedad;
    @Size(max = 255)
    @Column(name = "descripcion")
    private String descripcion;
    @Column(name = "fecha_generacion")
    @Temporal(TemporalType.TIMESTAMP)
    private Date fechaGeneracion;
    @Basic(optional = false)
    @NotNull
    @Size(min = 1, max = 255)
    @Column(name = "estado")
    private String estado;
    @JoinColumn(name = "id_equipo", referencedColumnName = "id_equipo")
    @ManyToOne(optional = false)
    private Equipo idEquipo;
    @JoinColumn(name = "id_umbral_alerta", referencedColumnName = "id_umbral_alerta")
    @ManyToOne(optional = false)
    private UmbralAlerta idUmbralAlerta;
    @OneToMany(mappedBy = "idAlerta")
    private List<Incidencia> incidenciaList;
    @OneToMany(cascade = CascadeType.ALL, mappedBy = "idAlerta")
    private List<Notificacion> notificacionList;

    public Alerta() {
    }

    public Alerta(Integer idAlerta) {
        this.idAlerta = idAlerta;
    }

    public Alerta(Integer idAlerta, String tipoAlerta, String nivelGravedad, String estado) {
        this.idAlerta = idAlerta;
        this.tipoAlerta = tipoAlerta;
        this.nivelGravedad = nivelGravedad;
        this.estado = estado;
    }

    public Integer getIdAlerta() {
        return idAlerta;
    }

    public void setIdAlerta(Integer idAlerta) {
        this.idAlerta = idAlerta;
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

    public Equipo getIdEquipo() {
        return idEquipo;
    }

    public void setIdEquipo(Equipo idEquipo) {
        this.idEquipo = idEquipo;
    }

    public UmbralAlerta getIdUmbralAlerta() {
        return idUmbralAlerta;
    }

    public void setIdUmbralAlerta(UmbralAlerta idUmbralAlerta) {
        this.idUmbralAlerta = idUmbralAlerta;
    }

    @XmlTransient
    public List<Incidencia> getIncidenciaList() {
        return incidenciaList;
    }

    public void setIncidenciaList(List<Incidencia> incidenciaList) {
        this.incidenciaList = incidenciaList;
    }

    @XmlTransient
    public List<Notificacion> getNotificacionList() {
        return notificacionList;
    }

    public void setNotificacionList(List<Notificacion> notificacionList) {
        this.notificacionList = notificacionList;
    }

    @Override
    public int hashCode() {
        int hash = 0;
        hash += (idAlerta != null ? idAlerta.hashCode() : 0);
        return hash;
    }

    @Override
    public boolean equals(Object object) {
        // TODO: Warning - this method won't work in the case the id fields are not set
        if (!(object instanceof Alerta)) {
            return false;
        }
        Alerta other = (Alerta) object;
        if ((this.idAlerta == null && other.idAlerta != null) || (this.idAlerta != null && !this.idAlerta.equals(other.idAlerta))) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return "modelo.Alerta[ idAlerta=" + idAlerta + " ]";
    }
    
}
