package co.edu.uniboyaca.biblioteca.dao;

import co.edu.uniboyaca.biblioteca.model.Libro;
import co.edu.uniboyaca.biblioteca.util.Conexion;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class LibroDAOImpl implements LibroDAO {

    private Connection con;
    private PreparedStatement ps;
    private ResultSet rs;
    private boolean hasUrlPdfColumn = false;
    private boolean hasUrlImgColumn = false;

    public LibroDAOImpl() {
        verificarColumnasArchivos();
    }

    private void verificarColumnasArchivos() {
    
        try {
            con = Conexion.conectar();
            ps = con.prepareStatement("SELECT url_pdf FROM libros LIMIT 1");
            rs = ps.executeQuery();
            hasUrlPdfColumn = true;
        } catch (SQLException e) {
            hasUrlPdfColumn = false;
        } finally {
            cerrarRecursos();
        }

        // Verificar Imagen
        try {
            con = Conexion.conectar();
            ps = con.prepareStatement("SELECT url_img FROM libros LIMIT 1");
            rs = ps.executeQuery();
            hasUrlImgColumn = true;
        } catch (SQLException e) {
            hasUrlImgColumn = false;
        } finally {
            cerrarRecursos();
        }
    }

    @Override
    public List<Libro> listar() {
        List<Libro> lista = new ArrayList<>();
        String sql = "SELECT * FROM libros";
        try {
            con = Conexion.conectar();
            ps = con.prepareStatement(sql);
            rs = ps.executeQuery();
            while (rs.next()) {
                Libro l = new Libro();
                l.setIdLibro(rs.getInt("id_libro"));
                l.setTitulo(rs.getString("titulo"));
                l.setIsbn(rs.getString("isbn"));
                l.setIdAutor(rs.getInt("id_autor"));
                l.setIdCategoria(rs.getInt("id_categoria"));

                int editorial = rs.getInt("id_editorial");
                l.setIdEditorial(rs.wasNull() ? 0 : editorial);

                l.setDisponible(rs.getInt("stock"));

                if (hasUrlPdfColumn) {
                    l.setUrlPdf(rs.getString("url_pdf"));
                } else {
                    l.setUrlPdf(null);
                }

                if (hasUrlImgColumn) {
                    l.setUrlImg(rs.getString("url_img"));
                } else {
                    l.setUrlImg(null);
                }

                lista.add(l);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            cerrarRecursos();
        }
        return lista;
    }

    @Override
    public boolean insertar(Libro l) {
        String sql = "INSERT INTO libros (titulo, isbn, id_autor, id_categoria, stock, id_editorial";
        String values = ") VALUES (?,?,?,?,?,?";

        if (hasUrlPdfColumn) {
            sql += ", url_pdf";
            values += ", ?";
        }
        if (hasUrlImgColumn) {
            sql += ", url_img";
            values += ", ?";
        }
        sql += values + ")";

        try {
            con = Conexion.conectar();
            ps = con.prepareStatement(sql);
            ps.setString(1, l.getTitulo());
            ps.setString(2, l.getIsbn());
            ps.setInt(3, l.getIdAutor());
            ps.setInt(4, l.getIdCategoria());
            ps.setInt(5, l.getDisponible());
            if (l.getIdEditorial() == 0) {
                ps.setNull(6, Types.INTEGER);
            } else {
                ps.setInt(6, l.getIdEditorial());
            }

            int index = 7;
            if (hasUrlPdfColumn) {
                ps.setString(index++, l.getUrlPdf());
            }
            if (hasUrlImgColumn) {
                ps.setString(index, l.getUrlImg());
            }

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            cerrarRecursos();
        }
    }

    @Override
    public boolean actualizar(Libro l) {
        String sql = "UPDATE libros SET titulo=?, isbn=?, id_autor=?, id_categoria=?, stock=?, id_editorial=?";

        if (hasUrlPdfColumn) {
            sql += ", url_pdf=?";
        }
        if (hasUrlImgColumn) {
            sql += ", url_img=?";
        }
        sql += " WHERE id_libro=?";

        try {
            con = Conexion.conectar();
            ps = con.prepareStatement(sql);
            ps.setString(1, l.getTitulo());
            ps.setString(2, l.getIsbn());
            ps.setInt(3, l.getIdAutor());
            ps.setInt(4, l.getIdCategoria());
            ps.setInt(5, l.getDisponible());
            if (l.getIdEditorial() == 0) {
                ps.setNull(6, Types.INTEGER);
            } else {
                ps.setInt(6, l.getIdEditorial());
            }

            int index = 7;
            if (hasUrlPdfColumn) {
                ps.setString(index++, l.getUrlPdf());
            }
            if (hasUrlImgColumn) {
                ps.setString(index++, l.getUrlImg());
            }

            ps.setInt(index, l.getIdLibro());

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            cerrarRecursos();
        }
    }

    @Override
    public boolean eliminar(int id) {
        String sql = "DELETE FROM libros WHERE id_libro=?";
        try {
            con = Conexion.conectar();
            ps = con.prepareStatement(sql);
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            cerrarRecursos();
        }
    }


    public List<String[]> listarAutores() {
        List<String[]> lista = new ArrayList<>();
        String sql = "SELECT id_autor, nombre FROM autores";
        try {
            con = Conexion.conectar();
            ps = con.prepareStatement(sql);
            rs = ps.executeQuery();
            while (rs.next()) {
                lista.add(new String[]{rs.getString("id_autor"), rs.getString("nombre")});
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            cerrarRecursos();
        }
        return lista;
    }

    public List<String[]> listarCategorias() {
        List<String[]> lista = new ArrayList<>();
        String sql = "SELECT id_categoria, nombre_categoria FROM categorias";
        try {
            con = Conexion.conectar();
            ps = con.prepareStatement(sql);
            rs = ps.executeQuery();
            while (rs.next()) {
                lista.add(new String[]{rs.getString("id_categoria"), rs.getString("nombre_categoria")});
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            cerrarRecursos();
        }
        return lista;
    }

    public List<String[]> listarEditoriales() {
        List<String[]> lista = new ArrayList<>();
        String sql = "SELECT id_editorial, nombre FROM editoriales";
        try {
            con = Conexion.conectar();
            ps = con.prepareStatement(sql);
            rs = ps.executeQuery();
            while (rs.next()) {
                lista.add(new String[]{rs.getString("id_editorial"), rs.getString("nombre")});
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            cerrarRecursos();
        }
        return lista;
    }

    public boolean insertarAutor(String nombre, String nacionalidad) {
        String sql = "INSERT INTO autores (nombre, nacionalidad) VALUES (?, ?)";
        try {
            con = Conexion.conectar();
            ps = con.prepareStatement(sql);
            ps.setString(1, nombre);
            ps.setString(2, nacionalidad);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            cerrarRecursos();
        }
    }

    public boolean insertarCategoria(String nombre) {
        String sql = "INSERT INTO categorias (nombre_categoria) VALUES (?)";
        try {
            con = Conexion.conectar();
            ps = con.prepareStatement(sql);
            ps.setString(1, nombre);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            cerrarRecursos();
        }
    }

    public boolean insertarEditorial(String nombre, String pais) {
        String sql = "INSERT INTO editoriales (nombre, pais) VALUES (?, ?)";
        try {
            con = Conexion.conectar();
            ps = con.prepareStatement(sql);
            ps.setString(1, nombre);
            ps.setString(2, pais);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            cerrarRecursos();
        }
    }

    private void cerrarRecursos() {
        try {
            if (rs != null) {
                rs.close();
            }
            if (ps != null) {
                ps.close();
            }
            if (con != null) {
                con.close();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public Libro buscarPorId(int id) {
        Libro libro = null;
        String sql = "SELECT * FROM libros WHERE id_libro = ?";
        try {
            con = Conexion.conectar();
            ps = con.prepareStatement(sql);
            ps.setInt(1, id);
            rs = ps.executeQuery();

            if (rs.next()) {
                libro = new Libro();
                libro.setIdLibro(rs.getInt("id_libro"));
                libro.setTitulo(rs.getString("titulo"));
                libro.setIsbn(rs.getString("isbn"));

                libro.setIdAutor(rs.getInt("id_autor"));
                libro.setIdCategoria(rs.getInt("id_categoria"));
                int editorial = rs.getInt("id_editorial");
                libro.setIdEditorial(rs.wasNull() ? 0 : editorial);
                libro.setDisponible(rs.getInt("stock"));
              

                if (hasUrlPdfColumn) {
                    libro.setUrlPdf(rs.getString("url_pdf"));
                } else {
                    libro.setUrlPdf(null);
                }

                if (hasUrlImgColumn) {
                    libro.setUrlImg(rs.getString("url_img"));
                } else {
                    libro.setUrlImg(null);
                }
            }
        } catch (SQLException e) {
            System.out.println("Error al buscar libro: " + e.getMessage());
        } finally {
            cerrarRecursos();
        }
        return libro;
    }
}
