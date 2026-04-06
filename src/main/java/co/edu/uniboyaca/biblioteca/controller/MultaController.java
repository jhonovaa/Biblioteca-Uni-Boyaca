package co.edu.uniboyaca.biblioteca.controller;

import co.edu.uniboyaca.biblioteca.dao.PrestamoDAOImpl;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet(name = "MultaController", urlPatterns = {"/MultaController"})
public class MultaController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Verificamos que solo el Docente pueda acceder a esta ruta por seguridad
        HttpSession sesion = request.getSession();
        String rol = (String) sesion.getAttribute("tipoUsuario");

        if (rol == null || !rol.equals("Docente")) {
            response.sendRedirect("Prestamos.jsp?error=no_autorizado");
            return;
        }

        String accion = request.getParameter("accion");
        PrestamoDAOImpl pDao = new PrestamoDAOImpl();

        try {
            if ("crear".equals(accion)) {
                // Capturamos los datos enviados por la funcion JS sancionar()
                int idPrestamo = Integer.parseInt(request.getParameter("idP"));
                int idUsuario = Integer.parseInt(request.getParameter("idU"));
                double monto = Double.parseDouble(request.getParameter("monto"));

                // Ejecutamos la insercion en la tabla multas (estado_pago inicia en 0)
                boolean exito = pDao.generarMulta(idPrestamo, idUsuario, monto);

                if (exito) {
                    response.sendRedirect("Prestamos.jsp?msj=multa_ok");
                } else {
                    response.sendRedirect("Prestamos.jsp?msj=error_db");
                }

            } else if ("pagar".equals(accion)) {
                // Capturamos el ID del prestamo para marcar la multa como pagada
                int idPrestamo = Integer.parseInt(request.getParameter("idP"));

                // Ejecutamos el UPDATE en la tabla multas (estado_pago pasa a 1)
                boolean exito = pDao.pagarMulta(idPrestamo);

                if (exito) {
                    response.sendRedirect("Prestamos.jsp?msj=pago_ok");
                } else {
                    response.sendRedirect("Prestamos.jsp?msj=error_pago");
                }
            } else {
                // Si no hay una accion valida, regresamos a la lista
                response.sendRedirect("Prestamos.jsp");
            }

        } catch (Exception e) {
            System.out.println("Error en MultaController: " + e.getMessage());
            response.sendRedirect("Prestamos.jsp?msj=error_datos");
        }
    }
}