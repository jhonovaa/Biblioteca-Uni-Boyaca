package co.edu.uniboyaca.biblioteca.controller;

import co.edu.uniboyaca.biblioteca.dao.LibroDAOImpl;
import co.edu.uniboyaca.biblioteca.model.Libro;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.nio.file.Paths;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.Part;

@WebServlet(
   name = "LibroServlet",
   urlPatterns = {"/LibroServlet"}
)
@MultipartConfig(
   fileSizeThreshold = 2097152,
   maxFileSize = 52428800L,
   maxRequestSize = 104857600L
)
public class LibroServlet extends HttpServlet {

   // ✅ RUTA DINÁMICA DENTRO DE WEBAPP
   private String getUploadPath(HttpServletRequest request) {
      String path = request.getServletContext().getRealPath("/biblioteca_uploads");

      File dir = new File(path);
      if (!dir.exists()) {
         dir.mkdirs();
      }

      System.out.println("📁 RUTA DINÁMICA WEB: " + path);
      return path;
   }

   @Override
   protected void doGet(HttpServletRequest request, HttpServletResponse response)
         throws ServletException, IOException {

      String accion = request.getParameter("accion");

      if ("descargar".equals(accion)) {
         try {
            int id = Integer.parseInt(request.getParameter("id"));
            LibroDAOImpl dao = new LibroDAOImpl();
            Libro libro = dao.buscarPorId(id);

            if (libro != null && libro.getUrlPdf() != null && !libro.getUrlPdf().isEmpty()) {

               String uploadPath = getUploadPath(request);
               File downloadFile = new File(uploadPath, libro.getUrlPdf());

               if (downloadFile.exists()) {

                  FileInputStream inStream = new FileInputStream(downloadFile);
                  String mimeType = getServletContext().getMimeType(downloadFile.getAbsolutePath());

                  if (mimeType == null) {
                     mimeType = "application/pdf";
                  }

                  response.setContentType(mimeType);
                  response.setContentLength((int) downloadFile.length());

                  String headerValue = String.format("attachment; filename=\"%s\"", libro.getUrlPdf());
                  response.setHeader("Content-Disposition", headerValue);

                  OutputStream outStream = response.getOutputStream();

                  byte[] buffer = new byte[4096];
                  int bytesRead;

                  while ((bytesRead = inStream.read(buffer)) != -1) {
                     outStream.write(buffer, 0, bytesRead);
                  }

                  inStream.close();
                  outStream.flush();
                  return;
               } else {
                  System.out.println("❌ PDF NO ENCONTRADO");
               }
            }

         } catch (Exception e) {
            e.printStackTrace();
         }

      } else if ("verImagen".equals(accion)) {

         try {
            int id = Integer.parseInt(request.getParameter("id"));
            LibroDAOImpl dao = new LibroDAOImpl();
            Libro libro = dao.buscarPorId(id);

            if (libro != null && libro.getUrlImg() != null && !libro.getUrlImg().isEmpty()) {

               String uploadPath = getUploadPath(request);
               File imgFile = new File(uploadPath, libro.getUrlImg());

               if (imgFile.exists()) {

                  FileInputStream inStream = new FileInputStream(imgFile);
                  String mimeType = getServletContext().getMimeType(imgFile.getAbsolutePath());

                  if (mimeType == null) {
                     mimeType = "image/jpeg";
                  }

                  response.setContentType(mimeType);
                  response.setContentLength((int) imgFile.length());

                  OutputStream outStream = response.getOutputStream();

                  byte[] buffer = new byte[4096];
                  int bytesRead;

                  while ((bytesRead = inStream.read(buffer)) != -1) {
                     outStream.write(buffer, 0, bytesRead);
                  }

                  inStream.close();
                  outStream.flush();
                  return;
               } else {
                  System.out.println("❌ IMAGEN NO ENCONTRADA");
               }
            }

         } catch (Exception e) {
            e.printStackTrace();
         }

         return;
      }

      response.sendRedirect("libro.jsp");
   }

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
            l.setIdEditorial(edi != null && !edi.isEmpty() ? Integer.parseInt(edi) : 0);

            l.setDisponible(Integer.parseInt(request.getParameter("txtStock")));

            Libro libroAnterior = null;

            if ("actualizar".equals(accion)) {
               int id = Integer.parseInt(request.getParameter("txtId"));
               l.setIdLibro(id);
               libroAnterior = dao.buscarPorId(id);
            }

            String uploadPath = getUploadPath(request);

            // 📄 PDF
            Part filePdfPart = request.getPart("filePdf");
            String pdfName = getFileName(filePdfPart);

            if (pdfName != null && !pdfName.isEmpty()) {
               String uniquePdfName = System.currentTimeMillis() + "_pdf_" + pdfName;
               filePdfPart.write(uploadPath + File.separator + uniquePdfName);
               l.setUrlPdf(uniquePdfName);
            } else if (libroAnterior != null) {
               l.setUrlPdf(libroAnterior.getUrlPdf());
            }

            // 🖼️ IMAGEN
            Part fileImgPart = request.getPart("fileImg");
            String imgName = getFileName(fileImgPart);

            if (imgName != null && !imgName.isEmpty()) {
               String uniqueImgName = System.currentTimeMillis() + "_img_" + imgName;
               fileImgPart.write(uploadPath + File.separator + uniqueImgName);
               l.setUrlImg(uniqueImgName);
            } else if (libroAnterior != null) {
               l.setUrlImg(libroAnterior.getUrlImg());
            }

            boolean res;

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

   // 🔹 Obtener nombre del archivo
   private String getFileName(Part part) {
      if (part == null) return null;
      return Paths.get(part.getSubmittedFileName()).getFileName().toString();
   }
}