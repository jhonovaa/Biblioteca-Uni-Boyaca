package co.edu.uniboyaca.biblioteca.controller;

import co.edu.uniboyaca.biblioteca.dao.LibroDAOImpl;
import co.edu.uniboyaca.biblioteca.model.Libro;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.OutputStream;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.Part;

@WebServlet(name = "LibroServlet", urlPatterns = {"/LibroServlet"})
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2, // 2MB
    maxFileSize = 1024 * 1024 * 10,      // 10MB
    maxRequestSize = 1024 * 1024 * 50    // 50MB
)
public class LibroServlet extends HttpServlet {

    // Ruta absoluta física para persistencia total
    private static final String UPLOAD_DIR = "C:\\Users\\angel\\OneDrive\\Desktop\\jabones y git\\Biblioteca-Uni-Boyaca\\biblioteca_uploads";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String accion = request.getParameter("accion");
        
        // --- 1. LÓGICA PARA DESCARGAR PDF ---
        if ("descargar".equals(accion)) {
            try {
                int id = Integer.parseInt(request.getParameter("id"));
                LibroDAOImpl dao = new LibroDAOImpl();
                Libro libro = dao.buscarPorId(id);

                if (libro != null && libro.getUrlPdf() != null && !libro.getUrlPdf().isEmpty()) {
                    File downloadFile = new File(UPLOAD_DIR + File.separator + libro.getUrlPdf());

                    if (downloadFile.exists()) {
                        FileInputStream inStream = new FileInputStream(downloadFile);
                        
                        String mimeType = getServletContext().getMimeType(downloadFile.getAbsolutePath());
                        if (mimeType == null) {        
                            mimeType = "application/pdf";
                        }
                        
                        response.setContentType(mimeType);
                        response.setContentLength((int) downloadFile.length());
                        
                        String headerKey = "Content-Disposition";
                        String headerValue = String.format("attachment; filename=\"%s\"", libro.getUrlPdf());
                        response.setHeader(headerKey, headerValue);

                        OutputStream outStream = response.getOutputStream();
                        byte[] buffer = new byte[4096];
                        int bytesRead = -1;

                        while ((bytesRead = inStream.read(buffer)) != -1) {
                            outStream.write(buffer, 0, bytesRead);
                        }

                        inStream.close();
                        outStream.flush();
                        return; 
                    }
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        } 
        // --- 2. LÓGICA PARA MOSTRAR LA IMAGEN EN LA PÁGINA (NUEVO) ---
        else if ("verImagen".equals(accion)) {
            try {
                int id = Integer.parseInt(request.getParameter("id"));
                LibroDAOImpl dao = new LibroDAOImpl();
                Libro libro = dao.buscarPorId(id);

                if (libro != null && libro.getUrlImg() != null && !libro.getUrlImg().isEmpty()) {
                    File imgFile = new File(UPLOAD_DIR + File.separator + libro.getUrlImg());

                    if (imgFile.exists()) {
                        FileInputStream inStream = new FileInputStream(imgFile);
                        String mimeType = getServletContext().getMimeType(imgFile.getAbsolutePath());
                        if (mimeType == null) {
                            mimeType = "image/jpeg"; // Tipo por defecto para imágenes
                        }

                        response.setContentType(mimeType);
                        response.setContentLength((int) imgFile.length());

                        OutputStream outStream = response.getOutputStream();
                        byte[] buffer = new byte[4096];
                        int bytesRead = -1;

                        while ((bytesRead = inStream.read(buffer)) != -1) {
                            outStream.write(buffer, 0, bytesRead);
                        }

                        inStream.close();
                        outStream.flush();
                        return; // Terminar el flujo aquí
                    }
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
            return; // Si no hay imagen, no hace nada (para no romper el modal)
        }
        
        // Si no es descarga o hay error, vuelve a la lista
        response.sendRedirect("libro.jsp");
    }

    /**
     * El método doPost se encarga de INSERTAR, ACTUALIZAR y SUBIR los archivos
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        String accion = request.getParameter("accion");
        LibroDAOImpl dao = new LibroDAOImpl();
        
        try {
            if ("insertar".equals(accion) || "actualizar".equals(accion)) {
                Libro l = new Libro();
                l.setTitulo(request.getParameter("txtTitulo"));
                l.setIsbn(request.getParameter("txtIsbn"));
                l.setIdAutor(Integer.parseInt(request.getParameter("txtAutor")));
                l.setIdCategoria(Integer.parseInt(request.getParameter("txtCategoria")));
                
                String edi = request.getParameter("txtEditorial");
                l.setIdEditorial((edi != null && !edi.isEmpty()) ? Integer.parseInt(edi) : 0);
                l.setDisponible(Integer.parseInt(request.getParameter("txtStock")));

                // Buscamos el libro original en caso de actualización para no perder sus archivos si no se suben unos nuevos
                Libro libroAnterior = null;
                if ("actualizar".equals(accion)) {
                    int id = Integer.parseInt(request.getParameter("txtId"));
                    l.setIdLibro(id);
                    libroAnterior = dao.buscarPorId(id);
                }

                File uploadDir = new File(UPLOAD_DIR);
                if (!uploadDir.exists()) {
                    uploadDir.mkdirs();
                }

                // --- PROCESAMIENTO DEL ARCHIVO PDF ---
                Part filePdfPart = request.getPart("filePdf");
                String pdfName = getFileName(filePdfPart);
                if (pdfName != null && !pdfName.isEmpty()) {
                    String uniquePdfName = System.currentTimeMillis() + "_pdf_" + pdfName;
                    filePdfPart.write(UPLOAD_DIR + File.separator + uniquePdfName);
                    l.setUrlPdf(uniquePdfName);
                } else if (libroAnterior != null) {
                    l.setUrlPdf(libroAnterior.getUrlPdf());
                }

                // --- PROCESAMIENTO DE LA IMAGEN (NUEVO) ---
                Part fileImgPart = request.getPart("fileImg");
                String imgName = getFileName(fileImgPart);
                if (imgName != null && !imgName.isEmpty()) {
                    String uniqueImgName = System.currentTimeMillis() + "_img_" + imgName;
                    fileImgPart.write(UPLOAD_DIR + File.separator + uniqueImgName);
                    l.setUrlImg(uniqueImgName);
                } else if (libroAnterior != null) {
                    l.setUrlImg(libroAnterior.getUrlImg());
                }

                // --- PERSISTENCIA EN BASE DE DATOS ---
                boolean res = false;
                if ("actualizar".equals(accion)) {
                    res = dao.actualizar(l);
                } else {
                    res = dao.insertar(l);
                }

                if (res) {
                    request.getSession().setAttribute("mensaje", "Operación exitosa.");
                } else {
                    request.getSession().setAttribute("error", "Error en la base de datos.");
                }
            }
        } catch (Exception e) {
            request.getSession().setAttribute("error", "Error: " + e.getMessage());
            e.printStackTrace();
        }

        response.sendRedirect("libro.jsp");
    }

    private String getFileName(Part part) {
        String contentDisp = part.getHeader("content-disposition");
        String[] tokens = contentDisp.split(";");
        for (String token : tokens) {
            if (token.trim().startsWith("filename")) {
                return token.substring(token.indexOf("=") + 2, token.length() - 1);
            }
        }
        return null;
    }
}