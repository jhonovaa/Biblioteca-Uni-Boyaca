package co.edu.uniboyaca.biblioteca.dao;

import co.edu.uniboyaca.biblioteca.model.Usuarios;
import co.edu.uniboyaca.biblioteca.util.Conexion;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class UsuarioDAOImpl implements UsuarioDAO {

    @Override
    public boolean insertar(Usuarios u) {
        // Usamos 'contrasena' que es el nombre real en tu tabla
        String sql = "INSERT INTO usuarios (documento, nombres, apellidos, correo, telefono, tipo_usuario, estado, contrasena) VALUES (?,?,?,?,?,?,?,?)";

        try (Connection con = Conexion.conectar();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, u.getDocumento());
            ps.setString(2, u.getNombres());
            ps.setString(3, u.getApellidos());
            ps.setString(4, u.getEmail());
            ps.setString(5, u.getTelefono());
            ps.setString(6, u.getTipoUsuario());
            ps.setString(7, u.getEstado());
            ps.setString(8, u.getPassword()); 

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            System.out.println("ERROR INSERTAR: " + e.getMessage());
            return false;
        }
    }

    @Override
    public boolean actualizar(Usuarios u) {
        String sql = "UPDATE usuarios SET documento=?, nombres=?, apellidos=?, correo=?, telefono=?, tipo_usuario=?, estado=?, contrasena=? WHERE id_usuario=?";

        try (Connection con = Conexion.conectar();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, u.getDocumento());
            ps.setString(2, u.getNombres());
            ps.setString(3, u.getApellidos());
            ps.setString(4, u.getEmail());
            ps.setString(5, u.getTelefono());
            ps.setString(6, u.getTipoUsuario());
            ps.setString(7, u.getEstado());
            ps.setString(8, u.getPassword()); 
            ps.setInt(9, u.getIdUsuario());

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            System.out.println("ERROR ACTUALIZAR: " + e.getMessage());
            return false;
        }
    }

    @Override
    public List<Usuarios> listar() {
        List<Usuarios> lista = new ArrayList<>();
        String sql = "SELECT * FROM usuarios";

        try (Connection con = Conexion.conectar();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Usuarios u = new Usuarios();
                u.setIdUsuario(rs.getInt("id_usuario"));
                u.setDocumento(rs.getString("documento"));
                u.setNombres(rs.getString("nombres"));
                u.setApellidos(rs.getString("apellidos"));
                u.setEmail(rs.getString("correo"));
                u.setTelefono(rs.getString("telefono"));
                u.setTipoUsuario(rs.getString("tipo_usuario"));
                u.setEstado(rs.getString("estado"));
                // Cambiado de "password" a "contrasena"
                u.setPassword(rs.getString("contrasena")); 

                lista.add(u);
            }
        } catch (SQLException e) {
            System.out.println("ERROR LISTAR: " + e.getMessage());
        }
        return lista;
    }

    @Override
    public boolean eliminar(int id) {
        String sql = "DELETE FROM usuarios WHERE id_usuario=?";
        try (Connection con = Conexion.conectar();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public Usuarios obtenerPorId(int id) {
        Usuarios u = null;
        String sql = "SELECT * FROM usuarios WHERE id_usuario=?";

        try (Connection con = Conexion.conectar();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                u = new Usuarios();
                u.setIdUsuario(rs.getInt("id_usuario"));
                u.setDocumento(rs.getString("documento"));
                u.setNombres(rs.getString("nombres"));
                u.setApellidos(rs.getString("apellidos"));
                u.setEmail(rs.getString("correo"));
                u.setTelefono(rs.getString("telefono"));
                u.setTipoUsuario(rs.getString("tipo_usuario"));
                u.setEstado(rs.getString("estado"));
                // Cambiado de "password" a "contrasena"
                u.setPassword(rs.getString("contrasena")); 
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return u;
    }
}