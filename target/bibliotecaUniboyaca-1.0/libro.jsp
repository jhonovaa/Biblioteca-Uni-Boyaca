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
            } else if (accion.equals("insertar") || accion.equals("actualizar")) {
                try {
                    Libro l = new Libro();
                    l.setTitulo(request.getParameter("txtTitulo"));
                    l.setIsbn(request.getParameter("txtIsbn"));
                    l.setIdAutor(Integer.parseInt(request.getParameter("txtAutor")));
                    l.setIdCategoria(Integer.parseInt(request.getParameter("txtCategoria")));
                    String edi = request.getParameter("txtEditorial");
                    l.setIdEditorial((edi != null && !edi.isEmpty()) ? Integer.parseInt(edi) : 0);
                    l.setDisponible(Integer.parseInt(request.getParameter("txtStock")));

                    boolean res = false;
                    if (accion.equals("actualizar")) {
                        l.setIdLibro(Integer.parseInt(request.getParameter("txtId")));
                        res = dao.actualizar(l);
                    } else {
                        res = dao.insertar(l);
                    }

                    if (res) {
                        request.setAttribute("mensaje", "Operación exitosa con el libro.");
                    }
                } catch (Exception e) {
                    request.setAttribute("error", "Error: " + e.getMessage());
                }
            }
        }
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
        </style>
    </head>
    <body class="dark-mode">

        <%@include file="includes/navbar.jsp" %>

        <div class="container py-5">
            <header class="text-center mb-5 reveal active">
                <h1 class="display-5 fw-bold">Inventario de Libros</h1>
                <p class="opacity-50 fs-5" style="color: var(--brand-red);">Gestión de catálogo, autores y categorías</p>
            </header>

            <% if (request.getAttribute("mensaje") != null) {%>
            <div class="alert alert-success border-0 rounded-4 text-center mb-4 shadow-sm" style="background: rgba(52, 199, 89, 0.1); color: var(--accent-green); font-weight: 600;">
                <i class="bi bi-check-circle-fill me-2"></i> <%= request.getAttribute("mensaje")%>
            </div>
            <% } %>
            <% if (request.getAttribute("error") != null) {%>
            <div class="alert alert-danger border-0 rounded-4 text-center mb-4 shadow-sm" style="background: rgba(255, 59, 48, 0.1); color: var(--brand-red); font-weight: 600;">
                <i class="bi bi-exclamation-triangle-fill me-2"></i> <%= request.getAttribute("error")%>
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

                        <form method="POST" action="libro.jsp">
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
                                        <% if (rol.equals("Docente")) { %> <th class="text-center">Acciones</th> <% } %>
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
                                        <% if (rol.equals("Docente")) {%>
                                        <td class="text-center">
                                            <div class="d-flex justify-content-center gap-2">
                                                <a href="libro.jsp?idEdit=<%= b.getIdLibro()%>" class="btn-action-primary text-decoration-none" title="Editar Libro"><i class="bi bi-pencil-square"></i> Editar</a>
                                                <button onclick="confirmarEliminar(<%= b.getIdLibro()%>)" class="btn-action-danger text-decoration-none" title="Eliminar Libro"><i class="bi bi-trash3"></i> Borrar</button>
                                            </div>
                                        </td>
                                        <% } %>
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