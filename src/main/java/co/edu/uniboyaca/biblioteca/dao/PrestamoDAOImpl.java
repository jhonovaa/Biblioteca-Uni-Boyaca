package co.edu.uniboyaca.biblioteca.dao;

import co.edu.uniboyaca.biblioteca.model.Prestamos;
import co.edu.uniboyaca.biblioteca.util.Conexion;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class PrestamoDAOImpl implements PrestamoDAO {

    @Override
    public boolean registrarPrestamo(Prestamos p) {
        String sqlPrestamo = "INSERT INTO prestamos (id_libro, id_usuario, fecha_salida, fecha_devolucion_esperada, estado) VALUES (?,?,?,?,'Activo')";
        String sqlStock = "UPDATE libros SET stock = stock - 1 WHERE id_libro = ? AND stock > 0";
        
        try (Connection con = Conexion.conectar()) {
            con.setAutoCommit(false);
            
            try (PreparedStatement psP = con.prepareStatement(sqlPrestamo);
                 PreparedStatement psS = con.prepareStatement(sqlStock)) {
                
                psP.setInt(1, p.getIdLibro());
                psP.setInt(2, p.getIdUsuario());
                psP.setDate(3, p.getFechaSalida());
                psP.setDate(4, p.getFechaDevolucionEsperada());
                psP.executeUpdate();
                
                psS.setInt(1, p.getIdLibro());
                int filasStock = psS.executeUpdate();
                
                if (filasStock > 0) {
                    con.commit();
                    return true;
                } else {
                    con.rollback();
                    return false;
                }
            } catch (SQLException e) {
                con.rollback();
                System.out.println("ERROR REGISTRAR PRESTAMO/STOCK: " + e.getMessage());
                return false;
            }
        } catch (SQLException e) {
            return false;
        }
    }

    @Override
    public List<Prestamos> listarPrestamos() {
        List<Prestamos> lista = new ArrayList<>();
        String sql = "SELECT p.*, " +
                     "CONCAT(u.nombres, ' ', u.apellidos) AS nombre_completo, " +
                     "l.titulo AS titulo_libro " +
                     "FROM prestamos p " +
                     "INNER JOIN usuarios u ON p.id_usuario = u.id_usuario " +
                     "INNER JOIN libros l ON p.id_libro = l.id_libro " +
                     "ORDER BY p.fecha_salida DESC";
        
        try (Connection con = Conexion.conectar(); 
             PreparedStatement ps = con.prepareStatement(sql); 
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                Prestamos p = new Prestamos();
                p.setIdPrestamo(rs.getInt("id_prestamo"));
                p.setIdLibro(rs.getInt("id_libro"));
                p.setIdUsuario(rs.getInt("id_usuario"));
                p.setNombreUsuario(rs.getString("nombre_completo")); 
                p.setTituloLibro(rs.getString("titulo_libro"));
                p.setFechaSalida(rs.getDate("fecha_salida"));
                p.setFechaDevolucionEsperada(rs.getDate("fecha_devolucion_esperada"));
                // Mapeo corregido segun tu base de datos
                p.setFechaDevolucionReal(rs.getDate("fecha_devolucion_real"));
                p.setEstado(rs.getString("estado"));
                lista.add(p);
            }
        } catch (SQLException e) {
            System.out.println("ERROR LISTAR PRESTAMOS: " + e.getMessage());
        }
        return lista;
    }

    @Override
    public boolean finalizarPrestamo(int idPrestamo, Date fechaReal) {
        String sqlGetLibro = "SELECT id_libro FROM prestamos WHERE id_prestamo = ?";
        String sqlUpdateP = "UPDATE prestamos SET fecha_devolucion_real=?, estado='Devuelto' WHERE id_prestamo=?";
        String sqlStock = "UPDATE libros SET stock = stock + 1 WHERE id_libro = ?";
        
        try (Connection con = Conexion.conectar()) {
            con.setAutoCommit(false);
            int idLibro = -1;

            try (PreparedStatement psG = con.prepareStatement(sqlGetLibro)) {
                psG.setInt(1, idPrestamo);
                ResultSet rs = psG.executeQuery();
                if (rs.next()) idLibro = rs.getInt("id_libro");
            }

            try (PreparedStatement psP = con.prepareStatement(sqlUpdateP);
                 PreparedStatement psS = con.prepareStatement(sqlStock)) {
                
                psP.setDate(1, fechaReal);
                psP.setInt(2, idPrestamo);
                psP.executeUpdate();
                
                psS.setInt(1, idLibro);
                psS.executeUpdate();
                
                con.commit();
                return true;
            } catch (SQLException e) {
                con.rollback();
                System.out.println("ERROR FINALIZAR PRESTAMO/STOCK: " + e.getMessage());
                return false;
            }
        } catch (SQLException e) {
            return false;
        }
    }

    @Override
    public boolean eliminarPrestamo(int idPrestamo) {
        String sql = "DELETE FROM prestamos WHERE id_prestamo = ?";
        try (Connection con = Conexion.conectar(); 
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, idPrestamo);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.out.println("ERROR ELIMINAR PRESTAMO: " + e.getMessage());
            return false;
        }
    }

    @Override
    public boolean generarMulta(int idPrestamo, int idUsuario, double monto) {
        String sql = "INSERT INTO multas (id_prestamo, id_usuario, monto, estado_pago) VALUES (?, ?, ?, 0)";
        try (Connection con = Conexion.conectar(); 
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, idPrestamo);
            ps.setInt(2, idUsuario);
            ps.setDouble(3, monto);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.out.println("ERROR GENERAR MULTA: " + e.getMessage());
            return false;
        }
    }

    @Override
    public String obtenerNotificacionMulta(int idUsuario) {
        String sql = "SELECT monto FROM multas WHERE id_usuario = ? AND estado_pago = 0 LIMIT 1";
        try (Connection con = Conexion.conectar(); 
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, idUsuario);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return "Atencion: Tienes una multa pendiente de $" + rs.getDouble("monto");
                }
            }
        } catch (SQLException e) {
            System.out.println("ERROR NOTIFICACION MULTA: " + e.getMessage());
        }
        return null;
    }

    @Override
    public boolean pagarMulta(int idPrestamo) {
        String sql = "UPDATE multas SET estado_pago = 1 WHERE id_prestamo = ?";
        try (Connection con = Conexion.conectar(); 
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, idPrestamo);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.out.println("ERROR AL PAGAR MULTA: " + e.getMessage());
            return false;
        }
    }

    @Override
    public boolean tieneMultaPendiente(int idPrestamo) {
        String sql = "SELECT id_multa FROM multas WHERE id_prestamo = ? AND estado_pago = 0";
        try (Connection con = Conexion.conectar(); 
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, idPrestamo);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) {
            System.out.println("ERROR AL VERIFICAR MULTA: " + e.getMessage());
            return false;
        }
    }
}