package co.edu.uniboyaca.biblioteca.util;

import java.sql.Connection;
import java.sql.DriverManager;

public class Conexion {

    private static final String URL = "jdbc:mysql://localhost:3306/bibliotecauniboyaca?serverTimezone=UTC";
    private static final String USER = "root";
    private static final String PASS = "";

    public static Connection conectar() {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            return DriverManager.getConnection(URL, USER, PASS);
        } catch (Exception e) {

            System.err.println("ERROR DE CONEXION: " + e.getMessage());
            e.printStackTrace();
            return null;
        }
    }
}
