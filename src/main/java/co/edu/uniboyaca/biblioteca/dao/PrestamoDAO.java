package co.edu.uniboyaca.biblioteca.dao;

import co.edu.uniboyaca.biblioteca.model.Prestamos;
import java.util.List;
import java.sql.Date;

public interface PrestamoDAO {
    
    // --- GESTION DE PRESTAMOS ---
    
    /**
     * Registra un nuevo prestamo y descuenta el stock del libro.
     */
    public boolean registrarPrestamo(Prestamos p);

    /**
     * Obtiene la lista completa de prestamos con nombres de usuario y titulos de libros.
     */
    public List<Prestamos> listarPrestamos();

    /**
     * Marca un prestamo como devuelto, registra la fecha real y aumenta el stock del libro.
     */
    public boolean finalizarPrestamo(int idPrestamo, Date fechaReal);
    
    /**
     * Elimina un registro de prestamo de la base de datos.
     */
    public boolean eliminarPrestamo(int idPrestamo);

    
    // --- GESTION DE SANCIONES ---

    /**
     * Crea una nueva multa asociada a un prestamo y un usuario.
     */
    public boolean generarMulta(int idPrestamo, int idUsuario, double monto);

    /**
     * Verifica si un usuario tiene multas sin pagar para mostrar alertas.
     */
    public String obtenerNotificacionMulta(int idUsuario);

    /**
     * Cambia el estado de una multa a pagado.
     */
    public boolean pagarMulta(int idPrestamo);

    /**
     * Consulta si existe una multa activa para un prestamo especifico.
     */
    public boolean tieneMultaPendiente(int idPrestamo);
}