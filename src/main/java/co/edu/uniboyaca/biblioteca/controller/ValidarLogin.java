package co.edu.uniboyaca.biblioteca.controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet(name = "ValidarLogin", urlPatterns = {"/ValidarLogin"})
public class ValidarLogin extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String correoIn = request.getParameter("txtCorreo");
        String passIn = request.getParameter("txtPassword");

        String url = "jdbc:mysql://localhost:3306/bibliotecauniboyaca";
        String user = "root";
        String password = "";

        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            con = DriverManager.getConnection(url, user, password);

            String sql = "SELECT * FROM usuarios WHERE correo = ? AND contrasena = ? AND estado = 'Activo'";
            ps = con.prepareStatement(sql);
            ps.setString(1, correoIn);
            ps.setString(2, passIn);

            rs = ps.executeQuery();

            if (rs.next()) {

                HttpSession session = request.getSession();

                session.setAttribute("emailUsuario", rs.getString("correo"));

                session.setAttribute("nombreUsuario", rs.getString("nombres") + " " + rs.getString("apellidos"));
                session.setAttribute("tipoUsuario", rs.getString("tipo_usuario"));
                session.setAttribute("idUsuario", rs.getInt("id_usuario"));

                response.sendRedirect("index.jsp");

            } else {

                request.setAttribute("error", "Correo o contraseña incorrectos o cuenta inactiva");
                request.getRequestDispatcher("login.jsp").forward(request, response);
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Error tecnico: " + e.getMessage());
            request.getRequestDispatcher("login.jsp").forward(request, response);
        } finally {

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
    }
}
