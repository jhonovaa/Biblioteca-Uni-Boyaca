package co.edu.uniboyaca.biblioteca.controller;

import co.edu.uniboyaca.biblioteca.dao.PrestamoDAOImpl;
import co.edu.uniboyaca.biblioteca.model.Prestamos;
import java.io.IOException;
import java.sql.Date;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet(name = "PrestamoController", urlPatterns = {"/PrestamoController"})
public class PrestamoController extends HttpServlet {

    /**
     * El metodo doGet gestiona acciones por URL: Devolucion y Eliminacion
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String accion = request.getParameter("accion");
        PrestamoDAOImpl pDao = new PrestamoDAOImpl();

        try {
            if ("devolver".equals(accion)) {
                int idP = Integer.parseInt(request.getParameter("idP"));
                Date fechaHoy = new Date(System.currentTimeMillis());

                if (pDao.finalizarPrestamo(idP, fechaHoy)) {
                    response.sendRedirect("Prestamos.jsp?msj=devuelto_ok");
                } else {
                    response.sendRedirect("Prestamos.jsp?msj=error");
                }
            } 
            else if ("eliminar".equals(accion)) {
                int idP = Integer.parseInt(request.getParameter("idP"));

                if (pDao.eliminarPrestamo(idP)) {
                    response.sendRedirect("Prestamos.jsp?msj=eliminado_ok");
                } else {
                    response.sendRedirect("Prestamos.jsp?msj=error");
                }
            }
        } catch (Exception e) {
            response.sendRedirect("Prestamos.jsp?msj=error_datos");
        }
    }

    /**
     * El metodo doPost gestiona el formulario de nuevas solicitudes
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        try {
            int idUsuario = Integer.parseInt(request.getParameter("id_usuario"));
            int idLibro = Integer.parseInt(request.getParameter("id_libro"));
            String fechaEsp = request.getParameter("fecha_esperada");

            Prestamos p = new Prestamos();
            p.setIdLibro(idLibro);
            p.setIdUsuario(idUsuario);
            p.setFechaSalida(new Date(System.currentTimeMillis()));
            p.setFechaDevolucionEsperada(Date.valueOf(fechaEsp));

            PrestamoDAOImpl pDao = new PrestamoDAOImpl();
            if (pDao.registrarPrestamo(p)) {
                response.sendRedirect("Prestamos.jsp?msj=success");
            } else {
                response.sendRedirect("Prestamos.jsp?msj=error");
            }

        } catch (Exception e) {
            response.sendRedirect("Prestamos.jsp?msj=error_datos");
        }
    }
}