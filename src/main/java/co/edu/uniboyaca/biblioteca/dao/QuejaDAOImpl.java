package co.edu.uniboyaca.biblioteca.dao;

import co.edu.uniboyaca.biblioteca.model.Queja;
import co.edu.uniboyaca.biblioteca.util.Conexion;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class QuejaDAOImpl implements QuejaDAO {

    private static final String INSERT_QUEJA = "INSERT INTO quejas (nombre_solicitante, correo_solicitante, tipo_solicitud, asunto, descripcion) VALUES (?, ?, ?, ?, ?)";
    private static final String SELECT_ALL = "SELECT * FROM quejas ORDER BY fecha_radicado DESC";
    private static final String SELECT_BY_CORREO = "SELECT * FROM quejas WHERE correo_solicitante = ? ORDER BY fecha_radicado DESC";
    private static final String UPDATE_RESPUESTA = "UPDATE quejas SET respuesta = ?, estado = 'Respondida' WHERE id = ?";
    private static final String SELECT_BY_ID = "SELECT * FROM quejas WHERE id = ?";

    @Override
    public boolean registrarQueja(Queja queja) {
        boolean rowInserted = false;
        try (Connection connection = Conexion.conectar(); PreparedStatement preparedStatement = connection.prepareStatement(INSERT_QUEJA)) {

            preparedStatement.setString(1, queja.getNombreSolicitante());
            preparedStatement.setString(2, queja.getCorreoSolicitante());
            preparedStatement.setString(3, queja.getTipoSolicitud());
            preparedStatement.setString(4, queja.getAsunto());
            preparedStatement.setString(5, queja.getDescripcion());

            rowInserted = preparedStatement.executeUpdate() > 0;
        } catch (SQLException e) {
            System.out.println("Error al registrar queja: " + e.getMessage());
        }
        return rowInserted;
    }

    @Override
    public List<Queja> listarTodasLasQuejas() {
        List<Queja> quejas = new ArrayList<>();
        try (Connection connection = Conexion.conectar(); PreparedStatement preparedStatement = connection.prepareStatement(SELECT_ALL); ResultSet rs = preparedStatement.executeQuery()) {

            while (rs.next()) {
                quejas.add(mapearResultado(rs));
            }
        } catch (SQLException e) {
            System.out.println("Error al listar todas las quejas: " + e.getMessage());
        }
        return quejas;
    }

    @Override
    public List<Queja> listarQuejasPorCorreo(String correo) {
        List<Queja> quejas = new ArrayList<>();
        try (Connection connection = Conexion.conectar(); PreparedStatement preparedStatement = connection.prepareStatement(SELECT_BY_CORREO)) {

            preparedStatement.setString(1, correo);
            try (ResultSet rs = preparedStatement.executeQuery()) {
                while (rs.next()) {
                    quejas.add(mapearResultado(rs));
                }
            }
        } catch (SQLException e) {
            System.out.println("Error al listar quejas por correo: " + e.getMessage());
        }
        return quejas;
    }

    @Override
    public boolean responderQueja(int idQueja, String respuesta) {
        boolean rowUpdated = false;
        try (Connection connection = Conexion.conectar(); PreparedStatement preparedStatement = connection.prepareStatement(UPDATE_RESPUESTA)) {

            preparedStatement.setString(1, respuesta);
            preparedStatement.setInt(2, idQueja);
            rowUpdated = preparedStatement.executeUpdate() > 0;
        } catch (SQLException e) {
            System.out.println("Error al responder queja: " + e.getMessage());
        }
        return rowUpdated;
    }

    @Override
    public Queja obtenerQuejaPorId(int id) {
        Queja queja = null;
        try (Connection connection = Conexion.conectar(); PreparedStatement preparedStatement = connection.prepareStatement(SELECT_BY_ID)) {

            preparedStatement.setInt(1, id);
            try (ResultSet rs = preparedStatement.executeQuery()) {
                if (rs.next()) {
                    queja = mapearResultado(rs);
                }
            }
        } catch (SQLException e) {
            System.out.println("Error al obtener queja por ID: " + e.getMessage());
        }
        return queja;
    }

    private Queja mapearResultado(ResultSet rs) throws SQLException {
        Queja queja = new Queja();
        queja.setId(rs.getInt("id"));
        queja.setNombreSolicitante(rs.getString("nombre_solicitante"));
        queja.setCorreoSolicitante(rs.getString("correo_solicitante"));
        queja.setTipoSolicitud(rs.getString("tipo_solicitud"));
        queja.setAsunto(rs.getString("asunto"));
        queja.setDescripcion(rs.getString("descripcion"));
        queja.setEstado(rs.getString("estado"));
        queja.setRespuesta(rs.getString("respuesta"));
        queja.setFechaRadicado(rs.getTimestamp("fecha_radicado"));
        return queja;
    }
}
