package co.edu.uniboyaca.biblioteca.model;

import java.sql.Timestamp;

public class Queja {

    private int id;
    private String nombreSolicitante;
    private String correoSolicitante;
    private String tipoSolicitud;
    private String asunto;
    private String descripcion;
    private String estado;
    private String respuesta;
    private Timestamp fechaRadicado;

    public Queja() {
    }

    public Queja(String nombreSolicitante, String correoSolicitante, String tipoSolicitud, String asunto, String descripcion) {
        this.nombreSolicitante = nombreSolicitante;
        this.correoSolicitante = correoSolicitante;
        this.tipoSolicitud = tipoSolicitud;
        this.asunto = asunto;
        this.descripcion = descripcion;
        this.estado = "Pendiente"; // Estado por defecto
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getNombreSolicitante() {
        return nombreSolicitante;
    }

    public void setNombreSolicitante(String nombreSolicitante) {
        this.nombreSolicitante = nombreSolicitante;
    }

    public String getCorreoSolicitante() {
        return correoSolicitante;
    }

    public void setCorreoSolicitante(String correoSolicitante) {
        this.correoSolicitante = correoSolicitante;
    }

    public String getTipoSolicitud() {
        return tipoSolicitud;
    }

    public void setTipoSolicitud(String tipoSolicitud) {
        this.tipoSolicitud = tipoSolicitud;
    }

    public String getAsunto() {
        return asunto;
    }

    public void setAsunto(String asunto) {
        this.asunto = asunto;
    }

    public String getDescripcion() {
        return descripcion;
    }

    public void setDescripcion(String descripcion) {
        this.descripcion = descripcion;
    }

    public String getEstado() {
        return estado;
    }

    public void setEstado(String estado) {
        this.estado = estado;
    }

    public String getRespuesta() {
        return respuesta;
    }

    public void setRespuesta(String respuesta) {
        this.respuesta = respuesta;
    }

    public Timestamp getFechaRadicado() {
        return fechaRadicado;
    }

    public void setFechaRadicado(Timestamp fechaRadicado) {
        this.fechaRadicado = fechaRadicado;
    }
}
