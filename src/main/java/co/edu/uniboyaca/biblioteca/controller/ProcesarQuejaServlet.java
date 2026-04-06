package co.edu.uniboyaca.biblioteca.controller;

import co.edu.uniboyaca.biblioteca.dao.QuejaDAO;
import co.edu.uniboyaca.biblioteca.dao.QuejaDAOImpl;
import co.edu.uniboyaca.biblioteca.model.Queja;
import java.io.IOException;
// CAMBIO CLAVE: De jakarta a javax para compatibilidad con Tomcat 8.5
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Servlet para gestionar el ciclo de vida de las PQRS.
 * URL física: /ProcesarQuejaServlet
 */
@WebServlet(name = "ProcesarQuejaServlet", urlPatterns = {"/ProcesarQuejaServlet"})
public class ProcesarQuejaServlet extends HttpServlet {

    private QuejaDAO quejaDAO;

    @Override
    public void init() {
        quejaDAO = new QuejaDAOImpl();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect("quejas.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        String accion = request.getParameter("accion");
        
        try {
            if ("responder".equals(accion)) {
                int idQueja = Integer.parseInt(request.getParameter("idQueja"));
                String respuestaTexto = request.getParameter("respuesta");
                boolean exito = quejaDAO.responderQueja(idQueja, respuestaTexto);
                
                if (exito) {
                    request.setAttribute("mensaje", "Respuesta enviada con éxito al radicado #" + idQueja);
                } else {
                    request.setAttribute("error", "No se pudo guardar la respuesta.");
                }
            } else {
                String nombre = request.getParameter("nombreSolicitante");
                String correo = request.getParameter("correoSolicitante"); 
                String tipo = request.getParameter("tipoSolicitud");
                String asunto = request.getParameter("asunto");
                String descripcion = request.getParameter("descripcion");

                Queja nuevaQueja = new Queja(nombre, correo, tipo, asunto, descripcion);
                boolean exito = quejaDAO.registrarQueja(nuevaQueja);

                if (exito) {
                    request.setAttribute("mensaje", "Radicada correctamente.");
                } else {
                    request.setAttribute("error", "Error al procesar la queja.");
                }
            }
        } catch (Exception e) {
            request.setAttribute("error", "Error en el servidor: " + e.getMessage());
        }

        request.getRequestDispatcher("quejas.jsp").forward(request, response);
    }
}