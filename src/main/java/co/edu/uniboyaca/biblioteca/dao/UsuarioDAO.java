package co.edu.uniboyaca.biblioteca.dao;

import co.edu.uniboyaca.biblioteca.model.Usuarios;
import java.util.List;

public interface UsuarioDAO {

    public boolean insertar(Usuarios usuario);

    public List<Usuarios> listar();

    public boolean actualizar(Usuarios usuario);

    public boolean eliminar(int id);

    public Usuarios obtenerPorId(int id); 
}