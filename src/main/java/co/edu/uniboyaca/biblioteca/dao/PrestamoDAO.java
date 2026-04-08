package co.edu.uniboyaca.biblioteca.dao;

import co.edu.uniboyaca.biblioteca.model.Prestamos;
import java.util.List;
import java.sql.Date;

public interface PrestamoDAO {

    public boolean registrarPrestamo(Prestamos p);

    public List<Prestamos> listarPrestamos();

    public boolean finalizarPrestamo(int idPrestamo, Date fechaReal);

    public boolean eliminarPrestamo(int idPrestamo);

    public boolean generarMulta(int idPrestamo, int idUsuario, double monto);

    public String obtenerNotificacionMulta(int idUsuario);

    public boolean pagarMulta(int idPrestamo);

    public boolean tieneMultaPendiente(int idPrestamo);
}
