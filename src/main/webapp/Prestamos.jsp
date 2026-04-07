<%@page import="java.sql.Connection"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="co.edu.uniboyaca.biblioteca.util.Conexion"%>
<%@page import="co.edu.uniboyaca.biblioteca.model.Usuarios"%>
<%@page import="co.edu.uniboyaca.biblioteca.dao.UsuarioDAOImpl"%>
<%@page import="co.edu.uniboyaca.biblioteca.model.Libro"%>
<%@page import="co.edu.uniboyaca.biblioteca.dao.LibroDAOImpl"%>
<%@page import="co.edu.uniboyaca.biblioteca.model.Prestamos"%>
<%@page import="co.edu.uniboyaca.biblioteca.dao.PrestamoDAOImpl"%>
<%@page import="java.util.List"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    // Verificacion de sesion
    if (session.getAttribute("nombreUsuario") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Datos de sesion
    Integer idUsuarioLogueado = (Integer) session.getAttribute("idUsuario");
    String nombreCompleto = (String) session.getAttribute("nombreUsuario");
    String rol = (String) session.getAttribute("tipoUsuario");

    PrestamoDAOImpl pDao = new PrestamoDAOImpl();
    LibroDAOImpl lDao = new LibroDAOImpl(); // Instancia para buscar la portada de los libros

    // Cargamos la lista de préstamos desde el principio
    List<Prestamos> listaP = pDao.listarPrestamos();
%>
<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Gestión de Préstamos - Uniboyaca</title>

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

            /* --- PARCHE MODAL --- */
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
                padding: 2.5rem;
                border: 1px solid var(--border-color);
                box-shadow: 0 10px 30px rgba(0,0,0,0.05);
            }

            .info-label {
                font-size: 0.72rem;
                font-weight: 800;
                text-transform: uppercase;
                letter-spacing: 0.8px;
                opacity: 0.5;
                margin-bottom: 6px;
            }

            /* --- TABLAS MODO OSCURO --- */
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

            /* --- FORMULARIOS --- */
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

            /* --- TEXTOS PLACEHOLDER PARA MODO OSCURO --- */
            .dark-mode .form-control-apple::placeholder {
                color: rgba(245, 245, 247, 0.4) !important;
            }
            .dark-mode .text-muted {
                color: rgba(245, 245, 247, 0.5) !important;
            }

            /* --- BOTONES UNIFICADOS --- */
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

            /* Botones de acción en tabla */
            .btn-action-primary {
                background: rgba(0, 122, 255, 0.1);
                color: var(--brand-blue);
                border: none;
                border-radius: 10px;
                padding: 6px 12px;
                font-weight: 600;
                font-size: 0.85rem;
                transition: 0.2s;
            }
            .btn-action-primary:hover {
                background: var(--brand-blue);
                color: white;
            }

            .btn-action-success {
                background: rgba(52, 199, 89, 0.1);
                color: var(--accent-green);
                border: none;
                border-radius: 10px;
                padding: 6px 12px;
                font-weight: 600;
                font-size: 0.85rem;
                transition: 0.2s;
            }
            .btn-action-success:hover {
                background: var(--accent-green);
                color: white;
            }

            .btn-action-warning {
                background: rgba(255, 159, 10, 0.1);
                color: #ff9f0a;
                border: none;
                border-radius: 10px;
                padding: 6px 12px;
                font-weight: 600;
                font-size: 0.85rem;
                transition: 0.2s;
            }
            .btn-action-warning:hover {
                background: #ff9f0a;
                color: white;
            }

            .btn-action-danger {
                background: rgba(255, 59, 48, 0.1);
                color: var(--brand-red);
                border: none;
                border-radius: 10px;
                padding: 6px 12px;
                font-weight: 600;
                font-size: 0.85rem;
                transition: 0.2s;
            }
            .btn-action-danger:hover {
                background: var(--brand-red);
                color: white;
            }

            /* Alertas SweetAlert Premium */
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
                <h1 class="display-5 fw-bold">Gestión de Préstamos</h1>
                <p class="opacity-50 fs-5" style="color: var(--brand-red);">Control centralizado de circulación y sanciones</p>
            </header>

            <div class="row g-4">

                <%-- FORMULARIO PARA ESTUDIANTES --%>
                <% if (rol.equals("Estudiante")) {%>
                <div class="col-lg-4">
                    <div class="glass-panel reveal active h-100">
                        <h4 class="fw-bold mb-4" style="color: var(--brand-red);"><i class="bi bi-plus-circle-fill me-2"></i>Nueva Solicitud</h4>

                        <div class="p-3 mb-4 rounded-4" style="background: rgba(255, 59, 48, 0.05); border-left: 4px solid var(--brand-red);">
                            <p class="small mb-0"><i class="bi bi-info-circle-fill me-2" style="color: var(--brand-red);"></i>Selecciona el material de lectura que deseas retirar.</p>
                        </div>

                        <form action="PrestamoController" method="POST">
                            <input type="hidden" name="id_usuario" value="<%= idUsuarioLogueado%>">

                            <div class="mb-3">
                                <label class="info-label">Usuario Solicitante</label>
                                <input type="text" class="form-control form-control-apple opacity-50" value="<%= nombreCompleto%>" readonly>
                            </div>

                            <div class="mb-3">
                                <label class="info-label">Libro a Solicitar</label>
                                <select name="id_libro" id="select_libro" class="form-select form-control-apple" required onchange="actualizarPortada()">
                                    <option value="" data-hasimg="false">Seleccione un libro...</option>
                                    <%
                                        for (Libro l : lDao.listar()) {
                                            boolean hasImg = (l.getUrlImg() != null && !l.getUrlImg().isEmpty());
                                    %>
                                    <option value="<%= l.getIdLibro()%>" data-hasimg="<%= hasImg%>"><%= l.getTitulo()%></option>
                                    <% } %>
                                </select>
                            </div>

                            <%-- CONTENEDOR NUEVO: PREVISUALIZACIÓN DE PORTADA --%>
                            <div id="preview-container" class="mb-3 text-center p-3 rounded-4 d-none" style="background: var(--soft-gray); border: 1px dashed var(--border-color); min-height: 190px;">
                                <div id="preview-wrapper" class="w-100 h-100 d-flex flex-column justify-content-center align-items-center">
                                </div>
                            </div>

                            <div class="mb-4">
                                <label class="info-label">Fecha de Devolución Esperada</label>
                                <input type="date" name="fecha_esperada" class="form-control form-control-apple" required>
                            </div>

                            <button type="submit" class="btn-apple-red w-100 shadow-sm mt-2">Confirmar Solicitud</button>
                        </form>
                    </div>
                </div>
                <% }%>

                <%-- TABLA DE REGISTROS --%>
                <div class="<%= rol.equals("Docente") ? "col-12" : "col-lg-8"%>">
                    <div class="glass-panel reveal active delay-1 h-100">

                        <div class="d-flex flex-column flex-md-row justify-content-between align-items-center mb-4 gap-3">
                            <h4 class="fw-bold m-0"><i class="bi bi-journal-text me-2" style="color: var(--brand-red);"></i>Registros Actuales</h4>

                            <div class="d-flex flex-wrap justify-content-md-end gap-2 align-items-center">
                                <%-- BARRA DE BÚSQUEDA ADAPTATIVA --%>
                                <div class="input-group" style="max-width: 250px;">
                                    <span class="input-group-text bg-transparent border-end-0" style="border-color: var(--border-color); border-radius: 16px 0 0 16px;">
                                        <i class="bi bi-search text-muted"></i>
                                    </span>
                                    <input type="text" id="buscadorPrestamos" onkeyup="filtrarPrestamos()" class="form-control form-control-apple border-start-0 ps-0" placeholder="Buscar libro o usuario..." style="border-radius: 0 16px 16px 0; background: transparent !important;">
                                </div>
                                <button onclick="exportarExcel()" class="btn-export" title="Exportar a Excel"><i class="bi bi-file-earmark-excel text-success"></i></button>
                                <button onclick="exportarPDF()" class="btn-export" title="Exportar a PDF"><i class="bi bi-file-earmark-pdf text-danger"></i></button>
                            </div>
                        </div>

                        <div class="table-responsive">
                            <table class="table table-custom" id="tablaPrestamos">
                                <thead>
                                    <tr>
                                        <th>Libro</th>
                                        <th>Usuario</th>
                                        <th>Salida</th>
                                        <th>Estado</th>
                                        <th class="text-center">Acciones</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <%
                                        if (listaP == null || listaP.isEmpty()) {
                                    %>
                                    <tr><td colspan="5" class="text-center py-5 opacity-50">No hay registros en el sistema.</td></tr>
                                    <%
                                    } else {
                                        for (Prestamos p : listaP) {
                                            if (rol.equals("Docente") || p.getIdUsuario() == idUsuarioLogueado) {
                                    %>
                                    <tr>
                                        <td>
                                            <div class="fw-bold"><%= p.getTituloLibro()%></div>
                                            <div class="small opacity-50">ID Libro: <%= p.getIdLibro()%></div>
                                        </td>
                                        <td class="small fw-medium"><%= p.getNombreUsuario()%></td>
                                        <td class="small"><%= p.getFechaSalida()%></td>
                                        <td>
                                            <% if (p.getEstado().equals("Activo")) { %>
                                            <span class="badge rounded-pill bg-danger bg-opacity-10 text-danger px-3 border border-danger border-opacity-25">Activo</span>
                                            <% } else { %>
                                            <span class="badge rounded-pill bg-success bg-opacity-10 text-success px-3 border border-success border-opacity-25">Devuelto</span>
                                            <% } %>
                                        </td>
                                        <td class="text-center">
                                            <div class="d-flex justify-content-center gap-2">

                                                <%-- BOTONES DE ACCIÓN UNIFICADOS A ÍCONOS --%>
                                                <% if (rol.equals("Docente") && p.getEstado().equals("Activo")) {%>
                                                <a href="PrestamoController?accion=devolver&idP=<%= p.getIdPrestamo()%>" class="btn-action-primary text-decoration-none" title="Devolver Libro"><i class="bi bi-arrow-return-left"></i></a>

                                                <% if (pDao.tieneMultaPendiente(p.getIdPrestamo())) {%>
                                                <a href="MultaController?accion=pagar&idP=<%= p.getIdPrestamo()%>" class="btn-action-success text-decoration-none" title="Saldar Multa"><i class="bi bi-cash-stack"></i></a>
                                                    <% } else {%>
                                                <button class="btn-action-warning" onclick="sancionar(<%= p.getIdPrestamo()%>, <%= p.getIdUsuario()%>)" title="Generar Multa"><i class="bi bi-exclamation-triangle"></i></button>
                                                    <% } %>
                                                    <% }%>

                                                <button class="btn-export border-0" data-bs-toggle="modal" data-bs-target="#modalDetalle<%= p.getIdPrestamo()%>" title="Ver Detalles">
                                                    <i class="bi bi-eye" style="color: var(--brand-red);"></i>
                                                </button>

                                                <% if (rol.equals("Docente")) {%>
                                                <button class="btn-action-danger" onclick="confirmarEliminar(<%= p.getIdPrestamo()%>)" title="Eliminar registro">
                                                    <i class="bi bi-trash3"></i>
                                                </button>
                                                <% } %>
                                            </div>
                                        </td>
                                    </tr>
                                    <% }
                                            }
                                        } %>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <%-- --- SECCIÓN DE MODALES DE DETALLE (Diseño Premium con Imagen) --- --%>
        <%
            if (listaP != null) {
                for (Prestamos p : listaP) {
                    if (rol.equals("Docente") || p.getIdUsuario() == idUsuarioLogueado) {

                        // 1. Buscamos el libro para traer la portada
                        Libro libroModal = lDao.buscarPorId(p.getIdLibro());

                        // 2. Buscamos si tiene multa y si fue pagada para condicionar el botón de recibo
                        double montoMulta = 0;
                        boolean multaPagada = false;
                        try {
                            Connection conM = Conexion.conectar();
                            PreparedStatement psM = conM.prepareStatement("SELECT monto, estado_pago FROM multas WHERE id_prestamo = ?");
                            psM.setInt(1, p.getIdPrestamo());
                            ResultSet rsM = psM.executeQuery();
                            if (rsM.next()) {
                                montoMulta = rsM.getDouble("monto");
                                multaPagada = rsM.getInt("estado_pago") == 1;
                            }
                            rsM.close();
                            psM.close();
                            conM.close();
                        } catch (Exception e) {
                        }

                        // Validacion estricta para mostrar el recibo
                        boolean mostrarRecibo = p.getEstado().equals("Devuelto") && (montoMulta == 0 || multaPagada);

                        String fechaReferencia = (p.getFechaDevolucionReal() != null) ? p.getFechaDevolucionReal().toString() : "N/A";
        %>
        <div class="modal fade" id="modalDetalle<%= p.getIdPrestamo()%>" tabindex="-1" aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered modal-lg">
                <div class="modal-content shadow-lg border-0">
                    <div class="modal-body p-5">

                        <div class="d-flex justify-content-between align-items-start mb-4">
                            <div class="d-inline-block p-3 rounded-circle bg-danger bg-opacity-10 text-danger">
                                <i class="bi bi-journal-bookmark-fill fs-1"></i>
                            </div>
                            <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                        </div>

                        <div class="row align-items-center mb-4">
                            <%-- Columna de la Portada --%>
                            <div class="col-md-4 text-center mb-4 mb-md-0">
                                <div class="p-3 rounded-4 h-100 d-flex flex-column align-items-center justify-content-center" style="background: var(--soft-gray); border: 1px dashed var(--border-color); min-height: 200px; overflow: hidden;">
                                    <% if (libroModal != null && libroModal.getUrlImg() != null && !libroModal.getUrlImg().isEmpty()) {%>
                                    <img src="LibroServlet?accion=verImagen&id=<%= libroModal.getIdLibro()%>" class="w-100 h-100" style="object-fit: cover; border-radius: 8px;" alt="Portada">
                                    <% } else { %>
                                    <i class="bi bi-image text-muted fs-1 mb-2"></i>
                                    <span class="small opacity-50">Sin Portada</span>
                                    <% }%>
                                </div>
                            </div>

                            <%-- Columna de la Información Básica --%>
                            <div class="col-md-8">
                                <h3 class="fw-bold mb-1">Detalle del Préstamo</h3>
                                <p class="small opacity-50 mb-3">Registro Oficial #<%= p.getIdPrestamo()%></p>

                                <div class="p-3 rounded-4" style="background: var(--soft-gray); border: 1px solid var(--border-color);">
                                    <div class="row g-3">
                                        <div class="col-12">
                                            <p class="info-label mb-1">📖 Libro Prestado</p>
                                            <p class="fw-bold mb-0 fs-5"><%= p.getTituloLibro()%></p>
                                        </div>
                                        <div class="col-12">
                                            <p class="info-label mb-1">👤 Usuario a cargo</p>
                                            <p class="fw-bold mb-0" style="color: var(--brand-red);"><%= p.getNombreUsuario()%></p>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="row g-3 mb-4 text-center">
                            <div class="col-4">
                                <div class="p-3 rounded-4 h-100 d-flex flex-column justify-content-center" style="border: 1px solid var(--border-color);">
                                    <i class="bi bi-calendar-arrow-up text-primary mb-2 fs-5"></i>
                                    <p class="info-label mb-1" style="font-size:0.65rem;">Salida</p>
                                    <p class="small fw-bold mb-0"><%= p.getFechaSalida()%></p>
                                </div>
                            </div>
                            <div class="col-4">
                                <div class="p-3 rounded-4 h-100 d-flex flex-column justify-content-center" style="border: 1px solid var(--border-color);">
                                    <i class="bi bi-calendar-exclamation text-warning mb-2 fs-5"></i>
                                    <p class="info-label mb-1" style="font-size:0.65rem;">Esperada</p>
                                    <p class="small fw-bold mb-0"><%= p.getFechaDevolucionEsperada()%></p>
                                </div>
                            </div>
                            <div class="col-4">
                                <div class="p-3 rounded-4 h-100 d-flex flex-column justify-content-center" style="border: 1px solid var(--border-color);">
                                    <i class="bi bi-calendar-check text-success mb-2 fs-5"></i>
                                    <p class="info-label mb-1" style="font-size:0.65rem;">Real</p>
                                    <p class="small fw-bold mb-0"><%= fechaReferencia%></p>
                                </div>
                            </div>
                        </div>

                        <div class="text-center mb-5">
                            <p class="info-label mb-2">Estado Actual</p>
                            <% if (p.getEstado().equals("Activo")) { %>
                            <span class="badge rounded-pill bg-danger bg-opacity-10 text-danger px-4 py-2 border border-danger border-opacity-25 fs-6">
                                <i class="bi bi-exclamation-circle-fill me-1"></i> En Préstamo (Activo)
                            </span>
                            <% } else { %>
                            <span class="badge rounded-pill bg-success bg-opacity-10 text-success px-4 py-2 border border-success border-opacity-25 fs-6">
                                <i class="bi bi-check-circle-fill me-1"></i> Devuelto con éxito
                            </span>
                            <% } %>
                        </div>

                        <%-- BOTONES DEL MODAL INCLUYENDO EL RECIBO (CONDICIONADO) --%>
                        <div class="d-flex flex-column flex-md-row justify-content-end gap-2">
                            <button type="button" class="btn btn-light rounded-pill px-4 fw-bold" data-bs-dismiss="modal">Cerrar</button>

                            <%-- Botón de Paz y Salvo / Recibo. Solo aparece si ya está devuelto y pagado --%>
                            <% if (mostrarRecibo) {%>
                            <button type="button" class="btn btn-outline-success rounded-pill px-4 fw-bold" onclick="generarRecibo(<%= p.getIdPrestamo()%>, '<%= p.getNombreUsuario()%>', '<%= p.getTituloLibro().replace("'", "\\'")%>', <%= montoMulta%>, '<%= fechaReferencia%>')">
                                <i class="bi bi-receipt me-2"></i>Descargar Recibo / Paz y Salvo
                            </button>
                            <% } %>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <%
                    }
                }
            }
        %>

        <script src="https://cdn.jsdelivr.net/npm/@popperjs/core@2.11.8/dist/umd/popper.min.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.min.js"></script>

        <script>
                                // --- NUEVA LÓGICA: FILTRAR TABLA PRÉSTAMOS ---
                                function filtrarPrestamos() {
                                    let input = document.getElementById("buscadorPrestamos").value.toLowerCase();
                                    let filas = document.querySelectorAll("#tablaPrestamos tbody tr");

                                    filas.forEach(fila => {
                                        if (fila.cells.length === 1)
                                            return; // Ignora fila de tabla vacía
                                        let textoFila = fila.innerText.toLowerCase();
                                        fila.style.display = textoFila.includes(input) ? "" : "none";
                                    });
                                }

                                function actualizarPortada() {
                                    const select = document.getElementById('select_libro');
                                    const option = select.options[select.selectedIndex];
                                    const container = document.getElementById('preview-container');
                                    const wrapper = document.getElementById('preview-wrapper');

                                    if (!option.value) {
                                        container.classList.add('d-none');
                                        return;
                                    }

                                    container.classList.remove('d-none');
                                    const hasImg = option.getAttribute('data-hasimg') === 'true';

                                    if (hasImg) {
                                        wrapper.innerHTML = '<img src="LibroServlet?accion=verImagen&id=' + option.value + '" style="height: 180px; object-fit: cover; border-radius: 8px; box-shadow: 0 4px 15px rgba(0,0,0,0.1);" alt="Portada">';
                                    } else {
                                        wrapper.innerHTML = '<div class="d-flex flex-column align-items-center justify-content-center h-100"><i class="bi bi-image text-muted fs-1 mb-2"></i><span class="small opacity-50">Sin Portada</span></div>';
                                    }
                                }

                                function generarRecibo(id, usuario, libro, montoMulta, fechaReferencia) {
                                    const {jsPDF} = window.jspdf;
                                    const doc = new jsPDF('p', 'pt', 'a5'); // Formato A5 para recibos

                                    doc.setDrawColor(200, 200, 200);
                                    doc.roundedRect(20, 20, 380, 500, 10, 10);

                                    doc.setFontSize(18);
                                    doc.setTextColor(255, 59, 48); // Rojo Uniboyaca
                                    doc.text("UNIBOYACA - BIBLIOTECA", 210, 60, null, null, "center");

                                    doc.setFontSize(12);
                                    doc.setTextColor(100, 100, 100);
                                    doc.text("SISTEMA DE GESTIÓN DE PRÉSTAMOS", 210, 80, null, null, "center");

                                    doc.line(40, 100, 380, 100);

                                    doc.setFontSize(14);
                                    doc.setTextColor(0, 0, 0);
                                    doc.setFont("helvetica", "bold");
                                    doc.text("CERTIFICADO DE PAZ Y SALVO / RECIBO", 210, 130, null, null, "center");

                                    doc.setFontSize(11);
                                    doc.setFont("helvetica", "normal");

                                    const fechaActual = new Date().toLocaleDateString();
                                    const horaActual = new Date().toLocaleTimeString();

                                    doc.text("No. de Transacción:", 50, 180);
                                    doc.text("TX-000" + id, 200, 180);
                                    doc.text("Fecha de Emisión:", 50, 210);
                                    doc.text(fechaActual + " - " + horaActual, 200, 210);
                                    doc.text("Usuario a Cargo:", 50, 240);
                                    doc.text(usuario, 200, 240);

                                    doc.line(50, 260, 370, 260);

                                    doc.text("Libro Asociado:", 50, 290);
                                    doc.setFont("helvetica", "bold");

                                    const splitLibro = doc.splitTextToSize(libro, 170);
                                    doc.text(splitLibro, 200, 290);

                                    doc.setFont("helvetica", "normal");

                                    doc.text("Concepto:", 50, 340);
                                    if (montoMulta > 0) {
                                        doc.text("Pago de Multa por Retraso/Daño", 200, 340);
                                        doc.text("Valor Pagado:", 50, 370);
                                        doc.setFont("helvetica", "bold");
                                        doc.text("$" + montoMulta + " COP", 200, 370);
                                        doc.setFont("helvetica", "normal");
                                        doc.text("Fecha de Pago:", 50, 400);
                                        doc.text(fechaReferencia, 200, 400);
                                    } else {
                                        doc.text("Paz y Salvo - Devolución a tiempo", 200, 340);
                                        doc.text("Fecha de Devolución:", 50, 370);
                                        doc.text(fechaReferencia, 200, 370);
                                    }

                                    doc.setFontSize(12);
                                    doc.setTextColor(52, 199, 89);
                                    doc.setFont("helvetica", "bold");
                                    doc.text("ESTADO: PAGADO / SIN DEUDAS", 210, 440, null, null, "center");

                                    doc.setFontSize(9);
                                    doc.setTextColor(150, 150, 150);
                                    doc.setFont("helvetica", "normal");
                                    doc.text("Este documento certifica electrónicamente que el usuario mencionado", 210, 480, null, null, "center");
                                    doc.text("se encuentra a Paz y Salvo por concepto del material bibliográfico.", 210, 495, null, null, "center");

                                    doc.save("Recibo_Pago_TX000" + id + ".pdf");
                                }

                                function exportarExcel() {
                                    const table = document.getElementById("tablaPrestamos");
                                    const wb = XLSX.utils.table_to_book(table, {sheet: "Prestamos"});
                                    XLSX.writeFile(wb, "Reporte_Prestamos_Uniboyaca.xlsx");
                                }

                                function exportarPDF() {
                                    const {jsPDF} = window.jspdf;
                                    const doc = new jsPDF('p', 'pt', 'a4');
                                    doc.setFontSize(18);
                                    doc.setTextColor(255, 59, 48);
                                    doc.text("UNIBOYACA - REPORTE DE PRÉSTAMOS", 40, 40);
                                    doc.autoTable({
                                        html: '#tablaPrestamos',
                                        startY: 60,
                                        theme: 'grid',
                                        headStyles: {fillColor: [255, 59, 48]},
                                        styles: {fontSize: 9}
                                    });
                                    doc.save("Reporte_Prestamos.pdf");
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

                                function sancionar(idPrestamo, idUsuario) {
                                    const config = getSwalConfig();
                                    Swal.fire({
                                        ...config,
                                        title: 'Generar Sanción',
                                        text: "Ingrese el monto de la multa (COP):",
                                        input: 'number',
                                        inputAttributes: {min: 0, step: 1000},
                                        showCancelButton: true,
                                        confirmButtonText: 'Aplicar Multa',
                                        cancelButtonText: 'Cancelar'
                                    }).then((result) => {
                                        if (result.isConfirmed && result.value) {
                                            window.location.href = "MultaController?accion=crear&idP=" + idPrestamo + "&idU=" + idUsuario + "&monto=" + result.value;
                                        }
                                    });
                                }

                                function confirmarEliminar(idP) {
                                    const config = getSwalConfig();
                                    Swal.fire({
                                        ...config,
                                        title: '¿Eliminar registro?',
                                        text: "Esta acción es permanente y no se puede deshacer.",
                                        icon: 'warning',
                                        showCancelButton: true,
                                        confirmButtonText: 'Sí, eliminar',
                                        cancelButtonText: 'Cancelar'
                                    }).then((result) => {
                                        if (result.isConfirmed) {
                                            window.location.href = "PrestamoController?accion=eliminar&idP=" + idP;
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

        <% if ("devuelto_ok".equals(request.getParameter("msj"))) { %>
        <script>
            Swal.fire({...getSwalConfig(), title: '¡Devuelto!', text: 'El libro ha sido recibido.', icon: 'success'});
        </script>
        <% } %>
        <% if ("multa_ok".equals(request.getParameter("msj"))) { %>
        <script>
            Swal.fire({...getSwalConfig(), title: 'Sanción Registrada', text: 'La multa se aplicó correctamente.', icon: 'warning'});
        </script>
        <% } %>

        <% if ("pago_ok".equals(request.getParameter("msj"))) { %>
        <script>
            Swal.fire({
                ...getSwalConfig(),
                title: '¡Pago Exitoso!',
                text: 'El usuario ya no tiene deudas. Puedes descargar el recibo de Paz y Salvo abriendo los detalles del préstamo (ícono del ojo).',
                icon: 'success'
            });
        </script>
        <% } %>

        <% if ("eliminado_ok".equals(request.getParameter("msj"))) { %>
        <script>
            Swal.fire({...getSwalConfig(), title: 'Eliminado', text: 'El registro ha sido borrado del sistema.', icon: 'success'});
        </script>
        <% } %>

        <% if (request.getParameter("err") != null) {%>
        <script>
            Swal.fire({...getSwalConfig(), title: 'Error en el Servidor', text: 'El sistema no pudo procesar la solicitud (Código: <%= request.getParameter("err")%>).', icon: 'error'});
        </script>
        <% } %>

        <% if (rol.equals("Estudiante")) {
                String msgMulta = pDao.obtenerNotificacionMulta(idUsuarioLogueado);
                if (msgMulta != null) {%>
        <script>
            Swal.fire({
                ...getSwalConfig(),
                icon: 'error',
                title: 'Acceso Restringido',
                text: '<%= msgMulta%>'
            });
        </script>
        <% }
            }%>

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