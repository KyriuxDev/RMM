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
@Table(name = "periferico")
@XmlRootElement
@NamedQueries({
    @NamedQuery(name = "Periferico.findAll", query = "SELECT p FROM Periferico p"),
    @NamedQuery(name = "Periferico.findByIdPeriferico", query = "SELECT p FROM Periferico p WHERE p.idPeriferico = :idPeriferico"),
    @NamedQuery(name = "Periferico.findByTipo", query = "SELECT p FROM Periferico p WHERE p.tipo = :tipo"),
    @NamedQuery(name = "Periferico.findByModelo", query = "SELECT p FROM Periferico p WHERE p.modelo = :modelo"),
    @NamedQuery(name = "Periferico.findByNumeroSerie", query = "SELECT p FROM Periferico p WHERE p.numeroSerie = :numeroSerie")})
public class Periferico implements Serializable {

    private static final long serialVersionUID = 1L;
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Basic(optional = false)
    @Column(name = "id_periferico")
    private Integer idPeriferico;
    @Basic(optional = false)
    @NotNull
    @Size(min = 1, max = 255)
    @Column(name = "tipo")
    private String tipo;
    @Size(max = 255)
    @Column(name = "modelo")
    private String modelo;
    @Size(max = 255)
    @Column(name = "numero_serie")
    private String numeroSerie;
    @JoinColumn(name = "id_equipo", referencedColumnName = "id_equipo")
    @ManyToOne(optional = false)
    private Equipo idEquipo;

    public Periferico() {
    }

    public Periferico(Integer idPeriferico) {
        this.idPeriferico = idPeriferico;
    }

    public Periferico(Integer idPeriferico, String tipo) {
        this.idPeriferico = idPeriferico;
        this.tipo = tipo;
    }

    public Integer getIdPeriferico() {
        return idPeriferico;
    }

    public void setIdPeriferico(Integer idPeriferico) {
        this.idPeriferico = idPeriferico;
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

    public Equipo getIdEquipo() {
        return idEquipo;
    }

    public void setIdEquipo(Equipo idEquipo) {
        this.idEquipo = idEquipo;
    }

    @Override
    public int hashCode() {
        int hash = 0;
        hash += (idPeriferico != null ? idPeriferico.hashCode() : 0);
        return hash;
    }

    @Override
    public boolean equals(Object object) {
        // TODO: Warning - this method won't work in the case the id fields are not set
        if (!(object instanceof Periferico)) {
            return false;
        }
        Periferico other = (Periferico) object;
        if ((this.idPeriferico == null && other.idPeriferico != null) || (this.idPeriferico != null && !this.idPeriferico.equals(other.idPeriferico))) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return "modelo.Periferico[ idPeriferico=" + idPeriferico + " ]";
    }
    
}
