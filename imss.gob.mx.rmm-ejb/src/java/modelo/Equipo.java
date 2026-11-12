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
import jakarta.persistence.OneToOne;
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
@Table(name = "equipo")
@XmlRootElement
@NamedQueries({
    @NamedQuery(name = "Equipo.findAll", query = "SELECT e FROM Equipo e"),
    @NamedQuery(name = "Equipo.findByIdEquipo", query = "SELECT e FROM Equipo e WHERE e.idEquipo = :idEquipo"),
    @NamedQuery(name = "Equipo.findByHostname", query = "SELECT e FROM Equipo e WHERE e.hostname = :hostname"),
    @NamedQuery(name = "Equipo.findByDireccionMac", query = "SELECT e FROM Equipo e WHERE e.direccionMac = :direccionMac"),
    @NamedQuery(name = "Equipo.findByIpLocal", query = "SELECT e FROM Equipo e WHERE e.ipLocal = :ipLocal"),
    @NamedQuery(name = "Equipo.findByIpPublica", query = "SELECT e FROM Equipo e WHERE e.ipPublica = :ipPublica"),
    @NamedQuery(name = "Equipo.findByNombreSo", query = "SELECT e FROM Equipo e WHERE e.nombreSo = :nombreSo"),
    @NamedQuery(name = "Equipo.findByVersionSo", query = "SELECT e FROM Equipo e WHERE e.versionSo = :versionSo"),
    @NamedQuery(name = "Equipo.findByEstadoConexion", query = "SELECT e FROM Equipo e WHERE e.estadoConexion = :estadoConexion"),
    @NamedQuery(name = "Equipo.findByUltimaSenal", query = "SELECT e FROM Equipo e WHERE e.ultimaSenal = :ultimaSenal"),
    @NamedQuery(name = "Equipo.findByFechaRegistro", query = "SELECT e FROM Equipo e WHERE e.fechaRegistro = :fechaRegistro"),
    @NamedQuery(name = "Equipo.findByUbicacionFisica", query = "SELECT e FROM Equipo e WHERE e.ubicacionFisica = :ubicacionFisica"),
    @NamedQuery(name = "Equipo.findByEstaActivo", query = "SELECT e FROM Equipo e WHERE e.estaActivo = :estaActivo")})
public class Equipo implements Serializable {

    private static final long serialVersionUID = 1L;
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Basic(optional = false)
    @Column(name = "id_equipo")
    private Integer idEquipo;
    @Basic(optional = false)
    @NotNull
    @Size(min = 1, max = 255)
    @Column(name = "hostname")
    private String hostname;
    @Basic(optional = false)
    @NotNull
    @Size(min = 1, max = 17)
    @Column(name = "direccion_mac")
    private String direccionMac;
    @Size(max = 45)
    @Column(name = "ip_local")
    private String ipLocal;
    @Size(max = 45)
    @Column(name = "ip_publica")
    private String ipPublica;
    @Size(max = 255)
    @Column(name = "nombre_so")
    private String nombreSo;
    @Size(max = 255)
    @Column(name = "version_so")
    private String versionSo;
    @Size(max = 20)
    @Column(name = "estado_conexion")
    private String estadoConexion;
    @Column(name = "ultima_senal")
    @Temporal(TemporalType.TIMESTAMP)
    private Date ultimaSenal;
    @Column(name = "fecha_registro")
    @Temporal(TemporalType.TIMESTAMP)
    private Date fechaRegistro;
    @Size(max = 255)
    @Column(name = "ubicacion_fisica")
    private String ubicacionFisica;
    @Basic(optional = false)
    @NotNull
    @Column(name = "esta_activo")
    private boolean estaActivo;
    @OneToMany(cascade = CascadeType.ALL, mappedBy = "idEquipo")
    private List<Alerta> alertaList;
    @OneToMany(cascade = CascadeType.ALL, mappedBy = "idEquipo")
    private List<Software> softwareList;
    @OneToMany(cascade = CascadeType.ALL, mappedBy = "idEquipo")
    private List<Periferico> perifericoList;
    @OneToMany(cascade = CascadeType.ALL, mappedBy = "idEquipo")
    private List<Incidencia> incidenciaList;
    @OneToMany(cascade = CascadeType.ALL, mappedBy = "idEquipo")
    private List<Informe> informeList;
    @OneToMany(cascade = CascadeType.ALL, mappedBy = "idEquipo")
    private List<SesionMonitoreo> sesionMonitoreoList;
    @JoinColumn(name = "id_area", referencedColumnName = "id_area")
    @ManyToOne
    private Area idArea;
    @JoinColumn(name = "id_usuario", referencedColumnName = "id_usuario")
    @ManyToOne
    private Usuario idUsuario;
    @OneToOne(cascade = CascadeType.ALL, mappedBy = "idEquipo")
    private Hardware hardware;

    public Equipo() {
    }

    public Equipo(Integer idEquipo) {
        this.idEquipo = idEquipo;
    }

    public Equipo(Integer idEquipo, String hostname, String direccionMac, boolean estaActivo) {
        this.idEquipo = idEquipo;
        this.hostname = hostname;
        this.direccionMac = direccionMac;
        this.estaActivo = estaActivo;
    }

    public Integer getIdEquipo() {
        return idEquipo;
    }

    public void setIdEquipo(Integer idEquipo) {
        this.idEquipo = idEquipo;
    }

    public String getHostname() {
        return hostname;
    }

    public void setHostname(String hostname) {
        this.hostname = hostname;
    }

    public String getDireccionMac() {
        return direccionMac;
    }

    public void setDireccionMac(String direccionMac) {
        this.direccionMac = direccionMac;
    }

    public String getIpLocal() {
        return ipLocal;
    }

    public void setIpLocal(String ipLocal) {
        this.ipLocal = ipLocal;
    }

    public String getIpPublica() {
        return ipPublica;
    }

    public void setIpPublica(String ipPublica) {
        this.ipPublica = ipPublica;
    }

    public String getNombreSo() {
        return nombreSo;
    }

    public void setNombreSo(String nombreSo) {
        this.nombreSo = nombreSo;
    }

    public String getVersionSo() {
        return versionSo;
    }

    public void setVersionSo(String versionSo) {
        this.versionSo = versionSo;
    }

    public String getEstadoConexion() {
        return estadoConexion;
    }

    public void setEstadoConexion(String estadoConexion) {
        this.estadoConexion = estadoConexion;
    }

    public Date getUltimaSenal() {
        return ultimaSenal;
    }

    public void setUltimaSenal(Date ultimaSenal) {
        this.ultimaSenal = ultimaSenal;
    }

    public Date getFechaRegistro() {
        return fechaRegistro;
    }

    public void setFechaRegistro(Date fechaRegistro) {
        this.fechaRegistro = fechaRegistro;
    }

    public String getUbicacionFisica() {
        return ubicacionFisica;
    }

    public void setUbicacionFisica(String ubicacionFisica) {
        this.ubicacionFisica = ubicacionFisica;
    }

    public boolean getEstaActivo() {
        return estaActivo;
    }

    public void setEstaActivo(boolean estaActivo) {
        this.estaActivo = estaActivo;
    }

    @XmlTransient
    public List<Alerta> getAlertaList() {
        return alertaList;
    }

    public void setAlertaList(List<Alerta> alertaList) {
        this.alertaList = alertaList;
    }

    @XmlTransient
    public List<Software> getSoftwareList() {
        return softwareList;
    }

    public void setSoftwareList(List<Software> softwareList) {
        this.softwareList = softwareList;
    }

    @XmlTransient
    public List<Periferico> getPerifericoList() {
        return perifericoList;
    }

    public void setPerifericoList(List<Periferico> perifericoList) {
        this.perifericoList = perifericoList;
    }

    @XmlTransient
    public List<Incidencia> getIncidenciaList() {
        return incidenciaList;
    }

    public void setIncidenciaList(List<Incidencia> incidenciaList) {
        this.incidenciaList = incidenciaList;
    }

    @XmlTransient
    public List<Informe> getInformeList() {
        return informeList;
    }

    public void setInformeList(List<Informe> informeList) {
        this.informeList = informeList;
    }

    @XmlTransient
    public List<SesionMonitoreo> getSesionMonitoreoList() {
        return sesionMonitoreoList;
    }

    public void setSesionMonitoreoList(List<SesionMonitoreo> sesionMonitoreoList) {
        this.sesionMonitoreoList = sesionMonitoreoList;
    }

    public Area getIdArea() {
        return idArea;
    }

    public void setIdArea(Area idArea) {
        this.idArea = idArea;
    }

    public Usuario getIdUsuario() {
        return idUsuario;
    }

    public void setIdUsuario(Usuario idUsuario) {
        this.idUsuario = idUsuario;
    }

    public Hardware getHardware() {
        return hardware;
    }

    public void setHardware(Hardware hardware) {
        this.hardware = hardware;
    }

    @Override
    public int hashCode() {
        int hash = 0;
        hash += (idEquipo != null ? idEquipo.hashCode() : 0);
        return hash;
    }

    @Override
    public boolean equals(Object object) {
        // TODO: Warning - this method won't work in the case the id fields are not set
        if (!(object instanceof Equipo)) {
            return false;
        }
        Equipo other = (Equipo) object;
        if ((this.idEquipo == null && other.idEquipo != null) || (this.idEquipo != null && !this.idEquipo.equals(other.idEquipo))) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return "modelo.Equipo[ idEquipo=" + idEquipo + " ]";
    }
    
}
