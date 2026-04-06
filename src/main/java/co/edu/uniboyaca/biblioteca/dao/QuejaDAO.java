package co.edu.uniboyaca.biblioteca.dao;

import co.edu.uniboyaca.biblioteca.model.Queja;
import java.util.List;

public interface QuejaDAO {

    boolean registrarQueja(Queja queja);

    List<Queja> listarTodasLasQuejas();

    List<Queja> listarQuejasPorCorreo(String correo);

    boolean responderQueja(int idQueja, String respuesta);

    Queja obtenerQuejaPorId(int id);
}
