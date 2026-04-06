package co.edu.uniboyaca.biblioteca.dao;

import co.edu.uniboyaca.biblioteca.model.Libro;
import java.util.List;

public interface LibroDAO {
    // Metodos CRUD principales para Libros
    public boolean insertar(Libro libro);
    public List<Libro> listar();
    public boolean actualizar(Libro libro);
    public boolean eliminar(int id);

    // Metodos para cargar los Selects en el JSP
    public List<String[]> listarAutores();
    public List<String[]> listarCategorias();
    public List<String[]> listarEditoriales();

    // Metodos de insercion rapida (Modales)
    public boolean insertarAutor(String nombre, String nacionalidad);
    public boolean insertarCategoria(String nombre);
    public boolean insertarEditorial(String nombre, String pais);
}