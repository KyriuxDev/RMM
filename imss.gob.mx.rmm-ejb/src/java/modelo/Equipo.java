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
@Table(name = "Equipo")
@XmlRootElement
@NamedQueries({
    @NamedQuery(name = "Equipo.findAll", query = "SELECT e FROM Equipo e"),
    @NamedQuery(name = "Equipo.findById", query = "SELECT e FROM Equipo e WHERE e.id = :id"),
    @NamedQuery(name = "Equipo.findByHostname", query = "SELECT e FROM Equipo e WHERE e.hostname = :hostname"),
    @NamedQuery(name = "Equipo.findByDireccionMac", query = "SELECT e FROM Equipo e WHERE e.direccionMac = :direccionMac"),
    @NamedQuery(name = "Equipo.findByIpLocal", query = "SELECT e FROM Equipo e WHERE e.ipLocal = :ipLocal"),
    @NamedQuery(name = "Equipo.findByIpPublica", query = "SELECT e FROM Equipo e WHERE e.ipPublica = :ipPublica"),
    @NamedQuery(name = "Equipo.findByNombreSO", query = "SELECT e FROM Equipo e WHERE e.nombreSO = :nombreSO"),
    @NamedQuery(name = "Equipo.findByVersionSO", query = "SELECT e FROM Equipo e WHERE e.versionSO = :versionSO"),
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
    @Column(name = "ID")
    private Integer id;
    @Basic(optional = false)
    @NotNull
    @Size(min = 1, max = 255)
    @Column(name = "Hostname")
    private String hostname;
    @Basic(optional = false)
    @NotNull
    @Size(min = 1, max = 255)
    @Column(name = "DireccionMac")
    private String direccionMac;
    @Size(max = 255)
    @Column(name = "IpLocal")
    private String ipLocal;
    @Size(max = 255)
    @Column(name = "IpPublica")
    private String ipPublica;
    @Size(max = 255)
    @Column(name = "NombreSO")
    private String nombreSO;
    @Size(max = 255)
    @Column(name = "VersionSO")
    private String versionSO;
    @Size(max = 255)
    @Column(name = "EstadoConexion")
    private String estadoConexion;
    @Column(name = "UltimaSenal")
    @Temporal(TemporalType.TIMESTAMP)
    private Date ultimaSenal;
    @Column(name = "FechaRegistro")
    @Temporal(TemporalType.TIMESTAMP)
    private Date fechaRegistro;
    @Size(max = 255)
    @Column(name = "UbicacionFisica")
    private String ubicacionFisica;
    @Basic(optional = false)
    @NotNull
    @Column(name = "EstaActivo")
    private boolean estaActivo;
    @OneToMany(cascade = CascadeType.ALL, mappedBy = "equipoID")
    private List<SesionMonitoreo> sesionMonitoreoList;
    @OneToMany(cascade = CascadeType.ALL, mappedBy = "equipoID")
    private List<Alerta> alertaList;
    @OneToMany(cascade = CascadeType.ALL, mappedBy = "equipoID")
    private List<Informe> informeList;
    @JoinColumn(name = "UnidadID", referencedColumnName = "ID")
    @ManyToOne(optional = false)
    private Unidad unidadID;
    @JoinColumn(name = "UsuarioID", referencedColumnName = "ID")
    @ManyToOne
    private Usuario usuarioID;
    @OneToMany(cascade = CascadeType.ALL, mappedBy = "equipoID")
    private List<Periferico> perifericoList;
    @OneToMany(cascade = CascadeType.ALL, mappedBy = "equipoID")
    private List<Hardware> hardwareList;
    @OneToMany(cascade = CascadeType.ALL, mappedBy = "equipoID")
    private List<Incidencia> incidenciaList;
    @OneToMany(cascade = CascadeType.ALL, mappedBy = "equipoID")
    private List<Software> softwareList;

    public Equipo() {
    }

    public Equipo(Integer id) {
        this.id = id;
    }

    public Equipo(Integer id, String hostname, String direccionMac, boolean estaActivo) {
        this.id = id;
        this.hostname = hostname;
        this.direccionMac = direccionMac;
        this.estaActivo = estaActivo;
    }

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
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

    public String getNombreSO() {
        return nombreSO;
    }

    public void setNombreSO(String nombreSO) {
        this.nombreSO = nombreSO;
    }

    public String getVersionSO() {
        return versionSO;
    }

    public void setVersionSO(String versionSO) {
        this.versionSO = versionSO;
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
    public List<SesionMonitoreo> getSesionMonitoreoList() {
        return sesionMonitoreoList;
    }

    public void setSesionMonitoreoList(List<SesionMonitoreo> sesionMonitoreoList) {
        this.sesionMonitoreoList = sesionMonitoreoList;
    }

    @XmlTransient
    public List<Alerta> getAlertaList() {
        return alertaList;
    }

    public void setAlertaList(List<Alerta> alertaList) {
        this.alertaList = alertaList;
    }

    @XmlTransient
    public List<Informe> getInformeList() {
        return informeList;
    }

    public void setInformeList(List<Informe> informeList) {
        this.informeList = informeList;
    }

    public Unidad getUnidadID() {
        return unidadID;
    }

    public void setUnidadID(Unidad unidadID) {
        this.unidadID = unidadID;
    }

    public Usuario getUsuarioID() {
        return usuarioID;
    }

    public void setUsuarioID(Usuario usuarioID) {
        this.usuarioID = usuarioID;
    }

    @XmlTransient
    public List<Periferico> getPerifericoList() {
        return perifericoList;
    }

    public void setPerifericoList(List<Periferico> perifericoList) {
        this.perifericoList = perifericoList;
    }

    @XmlTransient
    public List<Hardware> getHardwareList() {
        return hardwareList;
    }

    public void setHardwareList(List<Hardware> hardwareList) {
        this.hardwareList = hardwareList;
    }

    @XmlTransient
    public List<Incidencia> getIncidenciaList() {
        return incidenciaList;
    }

    public void setIncidenciaList(List<Incidencia> incidenciaList) {
        this.incidenciaList = incidenciaList;
    }

    @XmlTransient
    public List<Software> getSoftwareList() {
        return softwareList;
    }

    public void setSoftwareList(List<Software> softwareList) {
        this.softwareList = softwareList;
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
        if (!(object instanceof Equipo)) {
            return false;
        }
        Equipo other = (Equipo) object;
        if ((this.id == null && other.id != null) || (this.id != null && !this.id.equals(other.id))) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return "modelo.Equipo[ id=" + id + " ]";
    }
    
}
