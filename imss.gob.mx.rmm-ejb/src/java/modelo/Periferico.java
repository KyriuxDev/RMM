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
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import jakarta.xml.bind.annotation.XmlRootElement;
import java.io.Serializable;

/**
 *
 * @author kyriux
 */
@Entity
@Table(name = "Periferico")
@XmlRootElement
@NamedQueries({
    @NamedQuery(name = "Periferico.findAll", query = "SELECT p FROM Periferico p"),
    @NamedQuery(name = "Periferico.findById", query = "SELECT p FROM Periferico p WHERE p.id = :id"),
    @NamedQuery(name = "Periferico.findByTipo", query = "SELECT p FROM Periferico p WHERE p.tipo = :tipo"),
    @NamedQuery(name = "Periferico.findByModelo", query = "SELECT p FROM Periferico p WHERE p.modelo = :modelo"),
    @NamedQuery(name = "Periferico.findByNumeroSerie", query = "SELECT p FROM Periferico p WHERE p.numeroSerie = :numeroSerie")})
public class Periferico implements Serializable {

    private static final long serialVersionUID = 1L;
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Basic(optional = false)
    @Column(name = "ID")
    private Integer id;
    @Basic(optional = false)
    @NotNull
    @Size(min = 1, max = 255)
    @Column(name = "Tipo")
    private String tipo;
    @Size(max = 255)
    @Column(name = "Modelo")
    private String modelo;
    @Size(max = 255)
    @Column(name = "NumeroSerie")
    private String numeroSerie;
    @JoinColumn(name = "EquipoID", referencedColumnName = "ID")
    @ManyToOne(optional = false)
    private Equipo equipoID;

    public Periferico() {
    }

    public Periferico(Integer id) {
        this.id = id;
    }

    public Periferico(Integer id, String tipo) {
        this.id = id;
        this.tipo = tipo;
    }

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public String getTipo() {
        return tipo;
    }

    public void setTipo(String tipo) {
        this.tipo = tipo;
    }

    public String getModelo() {
        return modelo;
    }

    public void setModelo(String modelo) {
        this.modelo = modelo;
    }

    public String getNumeroSerie() {
        return numeroSerie;
    }

    public void setNumeroSerie(String numeroSerie) {
        this.numeroSerie = numeroSerie;
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
        if (!(object instanceof Periferico)) {
            return false;
        }
        Periferico other = (Periferico) object;
        if ((this.id == null && other.id != null) || (this.id != null && !this.id.equals(other.id))) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return "modelo.Periferico[ id=" + id + " ]";
    }
    
}
