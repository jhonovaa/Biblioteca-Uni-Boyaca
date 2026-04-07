<%
    request.setCharacterEncoding("UTF-8");
    if (session.getAttribute("nombreUsuario") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    String rol = (String) session.getAttribute("tipoUsuario");
%>

<%@page import="co.edu.uniboyaca.biblioteca.model.Libro"%>
<%@page import="co.edu.uniboyaca.biblioteca.dao.LibroDAOImpl"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Map"%>
<%@page import="java.util.HashMap"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%
    LibroDAOImpl dao = new LibroDAOImpl();
    String accion = request.getParameter("accion");
    String accionRapida = request.getParameter("accionRapida");
    Libro libEdit = new Libro();

    Map<Integer, String> mapAutores = new HashMap<>();
    for (String[] a : dao.listarAutores()) {
        mapAutores.put(Integer.parseInt(a[0]), a[1]);
    }

    Map<Integer, String> mapCategorias = new HashMap<>();
    for (String[] c : dao.listarCategorias()) {
        mapCategorias.put(Integer.parseInt(c[0]), c[1]);
    }

    Map<Integer, String> mapEditoriales = new HashMap<>();
    for (String[] e : dao.listarEditoriales()) {
        mapEditoriales.put(Integer.parseInt(e[0]), e[1]);
    }

    if (rol.equals("Docente")) {

        if (accionRapida != null) {
            if (accionRapida.equals("crearAutor")) {
                dao.insertarAutor(request.getParameter("txtNomAut"), request.getParameter("txtNacAut"));
                request.setAttribute("mensaje", "Autor registrado correctamente.");
            } else if (accionRapida.equals("crearCat")) {
                dao.insertarCategoria(request.getParameter("txtNomCat"));
                request.setAttribute("mensaje", "Categoría registrada correctamente.");
            } else if (accionRapida.equals("crearEdi")) {
                dao.insertarEditorial(request.getParameter("txtNomEdi"), request.getParameter("txtPaisEdi"));
                request.setAttribute("mensaje", "Editorial registrada correctamente.");
            }
        }

        String idEdit = request.getParameter("idEdit");
        if (idEdit != null) {
            for (Libro aux : dao.listar()) {
                if (aux.getIdLibro() == Integer.parseInt(idEdit)) {
                    libEdit = aux;
                    break;
                }
            }
        }

        if (accion != null) {
            if (accion.equals("eliminar")) {
                String idStr = request.getParameter("id");
                try {
                    if (idStr != null && !idStr.isEmpty()) {
                        int idEliminar = Integer.parseInt(idStr);
                        dao.eliminar(idEliminar);

                        boolean sigueExistiendo = false;
                        for (Libro aux : dao.listar()) {
                            if (aux.getIdLibro() == idEliminar) {
                                sigueExistiendo = true;
                                break;
                            }
                        }

                        if (sigueExistiendo) {
                            response.sendRedirect("libro.jsp?err=en_uso");
                        } else {
                            response.sendRedirect("libro.jsp?msj=eliminado");
                        }
                    } else {
                        response.sendRedirect("libro.jsp");
                    }
                } catch (Exception e) {
                    response.sendRedirect("libro.jsp?err=en_uso");
                }
                return;
            }
        }
    }

    // Lógica de PDF fuera del bloque de Docente para que estudiantes también descarguen
    if (accion != null && (accion.equals("PDF") || accion.equals("descargar"))) {
        String idStr = request.getParameter("id");
        try {
            if (idStr != null && !idStr.isEmpty()) {
                int idLibro = Integer.parseInt(idStr);
                Libro libro = dao.buscarPorId(idLibro);

                if (libro != null && libro.getUrlPdf() != null && !libro.getUrlPdf().isEmpty()) {
                    String filePath = "C:/Users/angel/OneDrive/Desktop/bibliotecaUniboyaca/bibliotecaUniboyaca/biblioteca_uploads/" + libro.getUrlPdf();
                    java.io.File downloadFile = new java.io.File(filePath);

                    if (downloadFile.exists()) {
                        java.io.FileInputStream inStream = new java.io.FileInputStream(downloadFile);

                        String mimeType = getServletContext().getMimeType(filePath);
                        if (mimeType == null) {
                            mimeType = "application/pdf";
                        }

                        response.setContentType(mimeType);
                        response.setContentLength((int) downloadFile.length());

                        String headerKey = "Content-Disposition";
                        String headerValue = String.format("attachment; filename=\"%s\"", libro.getTitulo() + ".pdf");
                        response.setHeader(headerKey, headerValue);

                        java.io.OutputStream outStream = response.getOutputStream();
                        byte[] buffer = new byte[4096];
                        int bytesRead = -1;

                        while ((bytesRead = inStream.read(buffer)) != -1) {
                            outStream.write(buffer, 0, bytesRead);
                        }

                        inStream.close();
                        outStream.flush();
                        return; // IMPORTANTE: terminar el flujo aquí para no enviar el resto del HTML
                    } else {
                        response.sendRedirect("libro.jsp?err=archivo_no_encontrado");
                    }
                } else {
                    response.sendRedirect("libro.jsp?err=sin_pdf");
                }
            }
        } catch (Exception e) {
            response.sendRedirect("libro.jsp?err=error_descarga");
        }
        return;
    }
%>


<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Gestión de Libros - Uniboyaca</title>

        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
        <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

        <script src="https://cdnjs.cloudflare.com/ajax/libs/xlsx/0.18.5/xlsx.full.min.js"></script>
        <script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js"></script>
        <script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf-autotable/3.5.25/jspdf.plugin.autotable.min.js"></script>

        <style>
            :root {
                --apple-bg: #f5f5f7;
                --card-bg: #ffffff;
                --text-main: #1d1d1f;
                --border-color: rgba(0,0,0,0.1);
                --brand-red: #ff3b30;
                --brand-red-hover: #d72c21;
                --brand-blue: #007aff;
                --accent-green: #34c759;
                --soft-gray: rgba(125, 125, 125, 0.08);
            }

            body.dark-mode {
                --apple-bg: #000000;
                --card-bg: #1c1c1e;
                --text-main: #f5f5f7;
                --border-color: rgba(255,255,255,0.1);
                --soft-gray: rgba(255, 255, 255, 0.05);
            }

            body {
                font-family: 'Inter', sans-serif;
                background-color: var(--apple-bg);
                color: var(--text-main);
                transition: 0.3s ease;
                min-height: 100vh;
            }

            .modal-backdrop {
                z-index: 1040 !important;
            }
            .modal {
                z-index: 1060 !important;
            }

            .modal-content {
                background-color: var(--card-bg) !important;
                color: var(--text-main) !important;
                border: 1px solid var(--border-color);
                border-radius: 32px;
                overflow: hidden;
            }

            .glass-panel {
                background: var(--card-bg);
                border-radius: 24px;
                padding: 2rem;
                border: 1px solid var(--border-color);
                box-shadow: 0 10px 30px rgba(0,0,0,0.05);
            }

            .info-label {
                font-size: 0.72rem;
                font-weight: 800;
                text-transform: uppercase;
                letter-spacing: 0.8px;
                opacity: 0.6;
                margin-bottom: 6px;
                display: block;
            }

            .table-custom {
                width: 100%;
                border-collapse: separate;
                border-spacing: 0;
                color: var(--text-main) !important;
            }
            .table-custom th {
                border-bottom: 2px solid var(--border-color) !important;
                color: var(--text-main) !important;
                font-size: 0.85rem;
                padding: 15px;
                background: transparent !important;
            }
            .table-custom td {
                border-bottom: 1px solid var(--border-color) !important;
                color: var(--text-main) !important;
                padding: 15px;
                background: transparent !important;
                vertical-align: middle;
            }

            .form-control-apple {
                background-color: var(--soft-gray) !important;
                color: var(--text-main) !important;
                border: 1px solid var(--border-color);
                border-radius: 16px;
                padding: 12px 15px;
                transition: 0.3s;
            }

            .form-control-apple:focus {
                border-color: var(--brand-red);
                box-shadow: 0 0 0 0.25rem rgba(255, 59, 48, 0.25);
            }

            .dark-mode select.form-control-apple option {
                background-color: #1c1c1e !important;
                color: #f5f5f7 !important;
            }

            .input-group-apple .form-control-apple {
                border-top-right-radius: 0;
                border-bottom-right-radius: 0;
            }
            .btn-plus-apple {
                background: rgba(255, 59, 48, 0.1);
                color: var(--brand-red);
                border: 1px solid var(--border-color);
                border-left: none;
                border-top-right-radius: 16px;
                border-bottom-right-radius: 16px;
                padding: 0 18px;
                font-weight: bold;
                transition: 0.3s;
            }
            .btn-plus-apple:hover {
                background: var(--brand-red);
                color: white;
            }

            .btn-apple-red {
                background: var(--brand-red);
                color: white;
                border: none;
                border-radius: 16px;
                padding: 14px 25px;
                font-weight: 600;
                transition: 0.2s;
            }
            .btn-apple-red:hover {
                background: var(--brand-red-hover);
                color: white;
                transform: translateY(-1px);
            }

            .btn-apple-outline {
                background: transparent;
                color: var(--text-main);
                border: 1px solid var(--border-color);
                border-radius: 16px;
                padding: 12px 25px;
                font-weight: 600;
                transition: 0.2s;
                text-decoration: none;
                display: block;
                text-align: center;
            }
            .btn-apple-outline:hover {
                background: var(--soft-gray);
                color: var(--text-main);
            }

            .btn-export {
                background: rgba(125,125,125,0.1);
                color: var(--text-main);
                border: 1px solid var(--border-color);
                border-radius: 12px;
                padding: 8px 16px;
                font-weight: 600;
                transition: 0.2s;
            }
            .btn-export:hover {
                background: var(--text-main);
                color: var(--apple-bg);
            }

            .badge-bright {
                background: rgba(255, 255, 255, 0.1);
                color: var(--text-main);
                border: 1px solid rgba(255, 255, 255, 0.2);
            }
            .dark-mode .badge-bright {
                background: rgba(255, 255, 255, 0.08);
                color: #f5f5f7;
                border: 1px solid rgba(255, 255, 255, 0.15);
            }

            .badge-red {
                background: rgba(255, 59, 48, 0.1);
                color: var(--brand-red);
                border: 1px solid rgba(255, 59, 48, 0.2);
            }

            .btn-action-primary {
                background: rgba(255, 255, 255, 0.1);
                color: var(--text-main);
                border: 1px solid var(--border-color);
                border-radius: 10px;
                padding: 6px 12px;
                font-weight: 600;
                font-size: 0.85rem;
            }
            .btn-action-primary:hover {
                background: var(--text-main);
                color: var(--apple-bg);
            }

            .btn-action-danger {
                background: rgba(255, 59, 48, 0.1);
                color: var(--brand-red);
                border: none;
                border-radius: 10px;
                padding: 6px 12px;
                font-weight: 600;
                font-size: 0.85rem;
            }
            .btn-action-danger:hover {
                background: var(--brand-red);
                color: white;
            }

            .swal2-popup {
                border-radius: 24px !important;
                border: 1px solid var(--border-color) !important;
            }

            .reveal {
                opacity: 0;
                transform: translateY(20px);
                transition: 0.5s ease;
            }
            .reveal.active {
                opacity: 1;
                transform: translateY(0);
            }

            .book-cover-preview {
                width: 120px;
                height: 180px;
                object-fit: cover;
                border-radius: 12px;
                border: 1px solid var(--border-color);
                box-shadow: 0 4px 15px rgba(0,0,0,0.1);
            }
        </style>
    </head>
    <body class="dark-mode">

        <%@include file="includes/navbar.jsp" %>

        <div class="container py-5">
            <header class="text-center mb-5 reveal active">
                <h1 class="display-5 fw-bold">Inventario de Libros</h1>
                <p class="opacity-50 fs-5" style="color: var(--brand-red);">Gestión de catálogo, autores y categorías</p>
            </header>

            <%
                String msj = (String) request.getAttribute("mensaje");
                if (msj == null) {
                    msj = (String) session.getAttribute("mensaje");
                }
                if (msj != null) {
                    session.removeAttribute("mensaje");
            %>
            <div class="alert alert-success border-0 rounded-4 text-center mb-4 shadow-sm" style="background: rgba(52, 199, 89, 0.1); color: var(--accent-green); font-weight: 600;">
                <i class="bi bi-check-circle-fill me-2"></i> <%= msj%>
            </div>
            <% } %>

            <%
                String err = (String) request.getAttribute("error");
                if (err == null) {
                    err = (String) session.getAttribute("error");
                }
                if (err != null) {
                    session.removeAttribute("error");
            %>
            <div class="alert alert-danger border-0 rounded-4 text-center mb-4 shadow-sm" style="background: rgba(255, 59, 48, 0.1); color: var(--brand-red); font-weight: 600;">
                <i class="bi bi-exclamation-triangle-fill me-2"></i> <%= err%>
            </div>
            <% } %>

            <div class="row g-4">

                <% if (rol.equals("Docente")) {%>
                <div class="col-lg-4">
                    <div class="glass-panel reveal active h-100">
                        <h4 class="fw-bold mb-4" style="color: var(--brand-red);">
                            <i class="bi <%= (libEdit.getIdLibro() > 0) ? "bi-pencil-square" : "bi-journal-plus"%> me-2"></i>
                            <%= (libEdit.getIdLibro() > 0) ? "Editar Libro" : "Nuevo Libro"%>
                        </h4>

                        <form method="POST" action="LibroServlet" enctype="multipart/form-data">
                            <input type="hidden" name="txtId" value="<%= libEdit.getIdLibro()%>">

                            <div class="mb-3">
                                <label class="info-label">Título del Libro</label>
                                <input type="text" name="txtTitulo" class="form-control form-control-apple" value="<%= libEdit.getTitulo() != null ? libEdit.getTitulo() : ""%>" required>
                            </div>

                            <div class="mb-3">
                                <label class="info-label">Código ISBN</label>
                                <input type="text" name="txtIsbn" class="form-control form-control-apple" value="<%= libEdit.getIsbn() != null ? libEdit.getIsbn() : ""%>" required>
                            </div>

                            <div class="mb-3">
                                <label class="info-label">Autor</label>
                                <div class="input-group input-group-apple">
                                    <select name="txtAutor" class="form-select form-control-apple" required>
                                        <option value="">Seleccione...</option>
                                        <% for (String[] a : dao.listarAutores()) {%>
                                        <option value="<%= a[0]%>" <%= (libEdit.getIdAutor() == Integer.parseInt(a[0])) ? "selected" : ""%>><%= a[1]%></option>
                                        <% } %>
                                    </select>
                                    <button type="button" class="btn-plus-apple" data-bs-toggle="modal" data-bs-target="#modalAutor" title="Añadir nuevo autor"><i class="bi bi-plus-lg"></i></button>
                                </div>
                            </div>

                            <div class="mb-3">
                                <label class="info-label">Categoría</label>
                                <div class="input-group input-group-apple">
                                    <select name="txtCategoria" class="form-select form-control-apple" required>
                                        <option value="">Seleccione...</option>
                                        <% for (String[] c : dao.listarCategorias()) {%>
                                        <option value="<%= c[0]%>" <%= (libEdit.getIdCategoria() == Integer.parseInt(c[0])) ? "selected" : ""%>><%= c[1]%></option>
                                        <% } %>
                                    </select>
                                    <button type="button" class="btn-plus-apple" data-bs-toggle="modal" data-bs-target="#modalCat" title="Añadir nueva categoría"><i class="bi bi-plus-lg"></i></button>
                                </div>
                            </div>

                            <div class="mb-3">
                                <label class="info-label">Editorial</label>
                                <div class="input-group input-group-apple">
                                    <select name="txtEditorial" class="form-select form-control-apple">
                                        <option value="">No aplica (N/A)</option>
                                        <% for (String[] e : dao.listarEditoriales()) {%>
                                        <option value="<%= e[0]%>" <%= (libEdit.getIdEditorial() == Integer.parseInt(e[0])) ? "selected" : ""%>><%= e[1]%></option>
                                        <% }%>
                                    </select>
                                    <button type="button" class="btn-plus-apple" data-bs-toggle="modal" data-bs-target="#modalEdi" title="Añadir nueva editorial"><i class="bi bi-plus-lg"></i></button>
                                </div>
                            </div>

                            <div class="mb-4">
                                <label class="info-label">Cantidad en Stock</label>
                                <input type="number" name="txtStock" class="form-control form-control-apple" value="<%= (libEdit.getIdLibro() > 0) ? libEdit.getDisponible() : ""%>" min="0" required>
                            </div>

                            <%-- Botón para subir la Portada en Imagen --%>
                            <div class="mb-3">
                                <label class="info-label">Portada del Libro (Imagen)</label>
                                <div class="input-group input-group-apple">
                                    <input type="file" name="fileImg" id="fileImg" class="form-control form-control-apple" accept="image/png, image/jpeg, image/jpg">
                                    <button type="button" class="btn-plus-apple" onclick="document.getElementById('fileImg').click();" title="Seleccionar imagen"><i class="bi bi-image"></i></button>
                                </div>
                                <%-- SE DESCOMENTÓ: Muestra la información de la imagen subida en el formulario de edición --%>
                                <% if (libEdit.getUrlImg() != null && !libEdit.getUrlImg().isEmpty()) {%>
                                <small class="text-success d-block mt-1"><i class="bi bi-check-circle-fill"></i> Imagen actual: <%= libEdit.getUrlImg()%></small>
                                <% }%> 
                            </div>

                            <%-- Botón para subir el PDF --%>
                            <div class="mb-4">
                                <label class="info-label">Documento PDF (Opcional)</label>
                                <div class="input-group input-group-apple">
                                    <input type="file" name="filePdf" id="filePdf" class="form-control form-control-apple" accept="application/pdf">
                                    <button type="button" class="btn-plus-apple" onclick="document.getElementById('filePdf').click();" title="Seleccionar archivo"><i class="bi bi-file-earmark-pdf"></i></button>
                                </div>
                                <% if (libEdit.getUrlPdf() != null && !libEdit.getUrlPdf().isEmpty()) {%>
                                <small class="text-success d-block mt-1"><i class="bi bi-check-circle-fill"></i> <%= libEdit.getUrlPdf()%></small>
                                <% }%>
                            </div>

                            <button type="submit" name="accion" value="<%= (libEdit.getIdLibro() > 0) ? "actualizar" : "insertar"%>" class="btn-apple-red w-100 shadow-sm">
                                <%= (libEdit.getIdLibro() > 0) ? "Guardar Cambios" : "Registrar Libro"%>
                            </button>

                            <% if (libEdit.getIdLibro() > 0) { %>
                            <a href="libro.jsp" class="btn-apple-outline w-100 mt-2 text-center text-decoration-none d-block">Cancelar Edición</a>
                            <% } %>
                        </form>
                    </div>
                </div>
                <% }%>

                <div class="<%= rol.equals("Docente") ? "col-lg-8" : "col-12"%>">
                    <div class="glass-panel reveal active delay-1 h-100">
                        <div class="d-flex flex-column flex-md-row justify-content-between align-items-center mb-4 gap-3">
                            <h4 class="fw-bold m-0"><i class="bi bi-collection me-2" style="color: var(--brand-red);"></i>Catálogo de Libros</h4>

                            <div class="d-flex gap-2">
                                <button onclick="exportarExcel()" class="btn-export">
                                    <i class="bi bi-file-earmark-excel text-success me-1"></i> Excel
                                </button>
                                <button onclick="exportarPDF()" class="btn-export">
                                    <i class="bi bi-file-earmark-pdf text-danger me-1"></i> PDF
                                </button>
                            </div>
                        </div>

                        <div class="table-responsive">
                            <table class="table table-custom align-middle" id="tablaLibros">
                                <thead>
                                    <tr>
                                        <th>Detalles del Libro</th>
                                        <th class="text-center">Clasificación</th>
                                        <th class="text-center">Stock</th>
                                        <th class="text-center">Acciones</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <%
                                        List<Libro> lista = dao.listar();
                                        if (lista == null || lista.isEmpty()) {
                                    %>
                                    <tr><td colspan="4" class="text-center py-5 opacity-50">No hay libros registrados en el inventario.</td></tr>
                                    <%  } else {
                                            for (Libro b : lista) {
                                    %>
                                    <tr>
                                        <td>
                                            <div class="fw-bold fs-6"><%= b.getTitulo()%></div>
                                            <div class="small opacity-50"><i class="bi bi-upc-scan me-1"></i>ISBN: <%= b.getIsbn()%> | ID: #<%= b.getIdLibro()%></div>
                                        </td>
                                        <td class="text-center">
                                            <span class="badge badge-bright px-3 mb-1 w-100 text-truncate" style="max-width: 150px;" title="Autor">
                                                <i class="bi bi-person-fill me-1 opacity-50"></i> <%= mapAutores.getOrDefault(b.getIdAutor(), "Desconocido")%>
                                            </span><br>
                                            <span class="badge badge-red px-3 w-100 text-truncate" style="max-width: 150px;" title="Categoría">
                                                <i class="bi bi-tags-fill me-1"></i> <%= mapCategorias.getOrDefault(b.getIdCategoria(), "Sin Categoría")%>
                                            </span>
                                        </td>
                                        <td class="text-center">
                                            <span class="badge rounded-pill <%= b.getDisponible() > 0 ? "bg-success bg-opacity-10 text-success border-success" : "bg-danger bg-opacity-10 text-danger border-danger"%> border border-opacity-25 px-3 py-2">
                                                <%= b.getDisponible()%> disp.
                                            </span>
                                        </td>
                                        <td class="text-center">
                                            <div class="d-flex justify-content-center gap-2">
                                                <% if (rol.equals("Docente")) {%>
                                                <a href="libro.jsp?idEdit=<%= b.getIdLibro()%>" class="btn-action-primary text-decoration-none" title="Editar Libro"><i class="bi bi-pencil-square"></i></a>
                                                <button onclick="confirmarEliminar(<%= b.getIdLibro()%>)" class="btn-action-danger text-decoration-none" title="Eliminar Libro"><i class="bi bi-trash3"></i></button>
                                                <% } %>

                                                <%-- BOTÓN PARA VER DETALLES (MODAL) --%>
                                                <button class="btn-export border-0" data-bs-toggle="modal" data-bs-target="#modalDetalle<%= b.getIdLibro()%>" title="Ver Info del Libro">
                                                    <i class="bi bi-eye" style="color: var(--brand-red);"></i>
                                                </button>

                                                <% if (b.getUrlPdf() != null && !b.getUrlPdf().isEmpty()) {%>
                                                <a href="LibroServlet?accion=descargar&id=<%= b.getIdLibro()%>" class="btn btn-sm btn-outline-danger" title="Descargar PDF"><i class="bi bi-file-earmark-pdf"></i></a>
                                                <% } else { %>
                                                <button class="btn btn-sm btn-outline-secondary disabled" title="Sin PDF disponible"><i class="bi bi-file-earmark-x"></i></button>
                                                <% } %>
                                            </div>
                                        </td>
                                    </tr>
                                    <% }
                                        } %>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <%-- ==========================================
             MODALES DE DETALLE DE LIBROS 
             ========================================== --%>
        <% if (lista != null) {
            for (Libro b : lista) {%>
        <div class="modal fade" id="modalDetalle<%= b.getIdLibro()%>" tabindex="-1" aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered modal-lg">
                <div class="modal-content shadow-lg border-0">
                    <div class="modal-body p-5">
                        <div class="d-flex justify-content-between align-items-start mb-4">
                            <div class="d-inline-block p-3 rounded-circle bg-danger bg-opacity-10 text-danger">
                                <i class="bi bi-book-half fs-1"></i>
                            </div>
                            <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                        </div>
                        
                        <div class="row align-items-center">
                            <%-- Columna para la imagen --%>
                            <div class="col-md-4 text-center mb-4 mb-md-0">
                                <%-- SE CORRIGIÓ: Lógica actualizada para renderizar la portada desde el Servlet --%>
                                <div class="p-3 rounded-4 h-100 d-flex flex-column align-items-center justify-content-center" style="background: var(--soft-gray); border: 1px dashed var(--border-color); min-height: 200px; overflow: hidden;">
                                    <% if (b.getUrlImg() != null && !b.getUrlImg().isEmpty()) { %>
                                        <img src="LibroServlet?accion=verImagen&id=<%= b.getIdLibro() %>" class="book-cover-preview w-100 h-100" style="object-fit: cover;" alt="Portada de <%= b.getTitulo() %>">
                                    <% } else { %>
                                        <i class="bi bi-image text-muted fs-1 mb-2"></i>
                                        <span class="small opacity-50">Portada no disponible</span>
                                    <% } %>
                                </div>
                            </div>

                            <%-- Columna para la información --%>
                            <div class="col-md-8">
                                <h3 class="fw-bold mb-1"><%= b.getTitulo()%></h3>
                                <p class="small opacity-50 mb-4">ISBN: <%= b.getIsbn()%></p>

                                <div class="row g-3">
                                    <div class="col-sm-6">
                                        <p class="info-label mb-1">Autor</p>
                                        <p class="fw-bold mb-0"><%= mapAutores.getOrDefault(b.getIdAutor(), "Desconocido")%></p>
                                    </div>
                                    <div class="col-sm-6">
                                        <p class="info-label mb-1">Categoría</p>
                                        <p class="fw-bold mb-0" style="color: var(--brand-red);"><%= mapCategorias.getOrDefault(b.getIdCategoria(), "Sin Categoría")%></p>
                                    </div>
                                    <div class="col-sm-6">
                                        <p class="info-label mb-1">Editorial</p>
                                        <p class="fw-bold mb-0"><%= mapEditoriales.getOrDefault(b.getIdEditorial(), "N/A")%></p>
                                    </div>
                                    <div class="col-sm-6">
                                        <p class="info-label mb-1">Stock Disponible</p>
                                        <p class="fw-bold mb-0 <%= b.getDisponible() > 0 ? "text-success" : "text-danger" %>"><%= b.getDisponible()%> unidades</p>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <hr class="my-4" style="border-color: var(--border-color);">
                        
                        <div class="d-flex justify-content-end gap-2">
                            <button type="button" class="btn btn-light rounded-pill px-4 fw-bold" data-bs-dismiss="modal">Cerrar</button>
                            <% if (b.getUrlPdf() != null && !b.getUrlPdf().isEmpty()) {%>
                            <a href="LibroServlet?accion=descargar&id=<%= b.getIdLibro()%>" class="btn-apple-red text-decoration-none">
                                <i class="bi bi-file-earmark-pdf me-2"></i>Descargar PDF
                            </a>
                            <% } %>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <% }
        } %>


        <%-- ==========================================
             MODALES DE CREACIÓN RÁPIDA 
             ========================================== --%>
        <div class="modal fade" id="modalAutor" tabindex="-1" aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered">
                <div class="modal-content border-0 shadow-lg">
                    <form action="libro.jsp" method="POST">
                        <div class="modal-body p-5">
                            <div class="text-center mb-4">
                                <div class="d-inline-block p-3 rounded-circle bg-danger bg-opacity-10 text-danger mb-3">
                                    <i class="bi bi-person-plus-fill fs-2"></i>
                                </div>
                                <h4 class="fw-bold">Registrar Autor</h4>
                            </div>

                            <div class="mb-3">
                                <label class="info-label">Nombre Completo</label>
                                <input type="text" name="txtNomAut" class="form-control form-control-apple" placeholder="Ej. Gabriel García Márquez" required>
                            </div>
                            <div class="mb-4">
                                <label class="info-label">Nacionalidad</label>
                                <input type="text" name="txtNacAut" class="form-control form-control-apple" placeholder="Ej. Colombiana">
                            </div>

                            <div class="d-flex gap-3">
                                <button type="button" class="btn btn-light rounded-pill w-100 fw-bold" data-bs-dismiss="modal">Cancelar</button>
                                <button type="submit" name="accionRapida" value="crearAutor" class="btn-apple-red w-100 shadow-sm">Guardar</button>
                            </div>
                        </div>
                    </form>
                </div>
            </div>
        </div>

        <div class="modal fade" id="modalCat" tabindex="-1" aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered">
                <div class="modal-content border-0 shadow-lg">
                    <form action="libro.jsp" method="POST">
                        <div class="modal-body p-5">
                            <div class="text-center mb-4">
                                <div class="d-inline-block p-3 rounded-circle bg-danger bg-opacity-10 text-danger mb-3">
                                    <i class="bi bi-tags-fill fs-2"></i>
                                </div>
                                <h4 class="fw-bold">Nueva Categoría</h4>
                            </div>

                            <div class="mb-4">
                                <label class="info-label">Nombre de la Categoría</label>
                                <input type="text" name="txtNomCat" class="form-control form-control-apple" placeholder="Ej. Ciencia Ficción" required>
                            </div>

                            <div class="d-flex gap-3">
                                <button type="button" class="btn btn-light rounded-pill w-100 fw-bold" data-bs-dismiss="modal">Cancelar</button>
                                <button type="submit" name="accionRapida" value="crearCat" class="btn-apple-red w-100 shadow-sm">Guardar</button>
                            </div>
                        </div>
                    </form>
                </div>
            </div>
        </div>

        <div class="modal fade" id="modalEdi" tabindex="-1" aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered">
                <div class="modal-content border-0 shadow-lg">
                    <form action="libro.jsp" method="POST">
                        <div class="modal-body p-5">
                            <div class="text-center mb-4">
                                <div class="d-inline-block p-3 rounded-circle bg-danger bg-opacity-10 text-danger mb-3">
                                    <i class="bi bi-building-fill fs-2"></i>
                                </div>
                                <h4 class="fw-bold">Registrar Editorial</h4>
                            </div>

                            <div class="mb-3">
                                <label class="info-label">Nombre de Editorial</label>
                                <input type="text" name="txtNomEdi" class="form-control form-control-apple" placeholder="Ej. Planeta" required>
                            </div>
                            <div class="mb-4">
                                <label class="info-label">País de Origen</label>
                                <input type="text" name="txtPaisEdi" class="form-control form-control-apple" placeholder="Ej. España">
                            </div>

                            <div class="d-flex gap-3">
                                <button type="button" class="btn btn-light rounded-pill w-100 fw-bold" data-bs-dismiss="modal">Cancelar</button>
                                <button type="submit" name="accionRapida" value="crearEdi" class="btn-apple-red w-100 shadow-sm">Guardar</button>
                            </div>
                        </div>
                    </form>
                </div>
            </div>
        </div>

        <script src="https://cdn.jsdelivr.net/npm/@popperjs/core@2.11.8/dist/umd/popper.min.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.min.js"></script>

        <script>
            function exportarExcel() {
                const table = document.getElementById("tablaLibros");
                const wb = XLSX.utils.table_to_book(table, {sheet: "Catalogo_Libros"});
                XLSX.writeFile(wb, "Reporte_Catalogo_Uniboyaca.xlsx");
            }

            function exportarPDF() {
                const {jsPDF} = window.jspdf;
                const doc = new jsPDF('p', 'pt', 'a4');
                doc.setFontSize(18);
                doc.setTextColor(255, 59, 48);
                doc.text("UNIBOYACA - CATALOGO DE LIBROS", 40, 40);
                doc.autoTable({
                    html: '#tablaLibros',
                    startY: 60,
                    theme: 'grid',
                    headStyles: {fillColor: [255, 59, 48]},
                    styles: {fontSize: 9}
                });
                doc.save("Reporte_Catalogo.pdf");
            }

            function getSwalConfig() {
                const isDark = document.body.classList.contains('dark-mode');
                return {
                    background: isDark ? '#1c1c1e' : '#ffffff',
                    color: isDark ? '#f5f5f7' : '#121212',
                    confirmButtonColor: '#ff3b30',
                    cancelButtonColor: '#6c757d',
                    customClass: {popup: 'swal2-popup'}
                };
            }

            function confirmarEliminar(idLibro) {
                Swal.fire({
                    ...getSwalConfig(),
                    title: '¿Eliminar este libro?',
                    text: "Esta acción borrará el libro del catálogo de forma permanente.",
                    icon: 'warning',
                    showCancelButton: true,
                    confirmButtonText: 'Sí, eliminar',
                    cancelButtonText: 'Cancelar'
                }).then((result) => {
                    if (result.isConfirmed) {
                        window.location.href = "libro.jsp?accion=eliminar&id=" + idLibro;
                    }
                });
            }

            const body = document.body;
            function applyTheme(isDark) {
                if (isDark)
                    body.classList.add('dark-mode');
                else
                    body.classList.remove('dark-mode');
            }
            if (localStorage.getItem('theme') === 'light')
                applyTheme(false);
            else
                applyTheme(true);

            document.addEventListener('click', function (e) {
                const target = e.target.closest('#theme-toggle');
                if (target) {
                    const isNowDark = !body.classList.contains('dark-mode');
                    localStorage.setItem('theme', isNowDark ? 'dark' : 'light');
                    applyTheme(isNowDark);
                }
            });

            const observer = new IntersectionObserver((entries) => {
                entries.forEach(entry => {
                    if (entry.isIntersecting)
                        entry.target.classList.add('active');
                });
            }, {threshold: 0.1});
            document.querySelectorAll('.reveal').forEach((el) => observer.observe(el));
        </script>

        <% if ("eliminado".equals(request.getParameter("msj"))) { %>
        <script>
            Swal.fire({...getSwalConfig(), title: 'Eliminado', text: 'El libro fue borrado del catálogo exitosamente.', icon: 'success'});
        </script>
        <% } %>

        <% if ("en_uso".equals(request.getParameter("err"))) { %>
        <script>
            Swal.fire({
                ...getSwalConfig(),
                title: '¡Libro en uso!',
                text: 'El libro está prestado y no se puede eliminar.',
                icon: 'error'
            });
        </script>
        <% } %>

        <% if (request.getAttribute("mensaje") != null) {%>
        <script>
            Swal.fire({...getSwalConfig(), title: '¡Éxito!', text: '<%= request.getAttribute("mensaje")%>', icon: 'success'});
        </script>
        <% } %>
        <% if (request.getAttribute("error") != null) {%>
        <script>
            Swal.fire({...getSwalConfig(), title: 'Error', text: '<%= request.getAttribute("error")%>', icon: 'error'});
        </script>
        <% }%>
        <script type="text/javascript">
            var Tawk_API = Tawk_API || {}, Tawk_LoadStart = new Date();
            (function () {
                var s1 = document.createElement("script"), s0 = document.getElementsByTagName("script")[0];
                s1.async = true;
                s1.src = 'https://embed.tawk.to/69c40061f00bc41c3bc91228/1jkiq2v8r';
                s1.charset = 'UTF-8';
                s1.setAttribute('crossorigin', '*');
                s0.parentNode.insertBefore(s1, s0);
            })();
        </script>

    </body>
</html>