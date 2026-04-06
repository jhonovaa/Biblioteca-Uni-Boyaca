package co.edu.uniboyaca.biblioteca.util;

import java.sql.Connection;
import java.sql.DriverManager;

public class Conexion {
    // CAMBIO AQUÍ: El nombre de la base de datos debe ser bibliotecauniboyaca
    private static final String URL = "jdbc:mysql://localhost:3306/bibliotecauniboyaca?serverTimezone=UTC";
    private static final String USER = "root";
    private static final String PASS = ""; 

    public static Connection conectar() {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            return DriverManager.getConnection(URL, USER, PASS);
        } catch (Exception e) {
            // Esto imprimirá el error real en la consola de Apache Tomcat (abajo en el IDE)
            System.err.println("ERROR DE CONEXION: " + e.getMessage());
            e.printStackTrace(); 
            return null;
        }
    }
}