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

            /* --- BOTONES --- */
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
            }
            .btn-action-success:hover {
                background: var(--accent-green);
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
                                <select name="id_libro" class="form-select form-control-apple" required>
                                    <option value="">Seleccione un libro...</option>
                                    <%
                                        LibroDAOImpl lDao = new LibroDAOImpl();
                                        for (Libro l : lDao.listar()) {
                                    %>
                                    <option value="<%= l.getIdLibro()%>"><%= l.getTitulo()%></option>
                                    <% } %>
                                </select>
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

                                                <% if (rol.equals("Docente") && p.getEstado().equals("Activo")) {%>
                                                <a href="PrestamoController?accion=devolver&idP=<%= p.getIdPrestamo()%>" class="btn-action-primary text-decoration-none">Devolver</a>

                                                <% if (pDao.tieneMultaPendiente(p.getIdPrestamo())) {%>
                                                <a href="MultaController?accion=pagar&idP=<%= p.getIdPrestamo()%>" class="btn-action-success text-decoration-none">Saldar</a>
                                                <% } else {%>
                                                <button class="btn-action-danger" onclick="sancionar(<%= p.getIdPrestamo()%>, <%= p.getIdUsuario()%>)">Multar</button>
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

        <%-- --- SECCIÓN DE MODALES DE DETALLE (Diseño Premium) --- --%>
        <%
            if (listaP != null) {
                for (Prestamos p : listaP) {
                    if (rol.equals("Docente") || p.getIdUsuario() == idUsuarioLogueado) {
        %>
        <div class="modal fade" id="modalDetalle<%= p.getIdPrestamo()%>" tabindex="-1" aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered">
                <div class="modal-content shadow-lg border-0">
                    <div class="modal-body p-5">

                        <div class="text-center mb-4">
                            <div class="d-inline-block p-3 rounded-circle bg-danger bg-opacity-10 text-danger mb-3">
                                <i class="bi bi-journal-bookmark-fill fs-1"></i>
                            </div>
                            <h3 class="fw-bold mb-1">Detalle del Préstamo</h3>
                            <p class="small opacity-50">Registro Oficial #<%= p.getIdPrestamo()%></p>
                        </div>

                        <div class="p-4 rounded-4 mb-4" style="background: var(--soft-gray); border: 1px solid var(--border-color);">
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
                                    <p class="small fw-bold mb-0"><%= (p.getFechaDevolucionReal() != null) ? p.getFechaDevolucionReal() : "Pendiente"%></p>
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

                        <button type="button" class="btn-apple-red w-100 py-3 shadow-sm fs-6" data-bs-dismiss="modal">
                            Cerrar Detalles
                        </button>
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
                                                    // Lógica de Exportación
                                                    function exportarExcel() {
                                                        const table = document.getElementById("tablaPrestamos");
                                                        const wb = XLSX.utils.table_to_book(table, {sheet: "Prestamos"});
                                                        XLSX.writeFile(wb, "Reporte_Prestamos_Uniboyaca.xlsx");
                                                    }

                                                    function exportarPDF() {
                                                        const {jsPDF} = window.jspdf;
                                                        const doc = new jsPDF('p', 'pt', 'a4');
                                                        doc.setFontSize(18);
                                                        doc.setTextColor(255, 59, 48); // Rojo Uniboyaca
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

                                                    // Función para obtener configuracion de alertas dinámicas
                                                    function getSwalConfig() {
                                                        const isDark = document.body.classList.contains('dark-mode');
                                                        return {
                                                            background: isDark ? '#1c1c1e' : '#ffffff',
                                                            color: isDark ? '#f5f5f7' : '#121212',
                                                            confirmButtonColor: '#ff3b30',
                                                            cancelButtonColor: '#6c757d',
                                                            customClass: {popup: 'swal2-popup'} // Clase para bordes redondeados
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

                                                    // Lógica de UI (Tema y Animaciones)
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

        <%-- ALERTAS DE SISTEMA (Manejadas por el Controller) --%>
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
            Swal.fire({...getSwalConfig(), title: '¡Pago Exitoso!', text: 'El usuario ya no tiene deudas en este préstamo.', icon: 'success'});
        </script>
        <% } %>
        <% if ("eliminado_ok".equals(request.getParameter("msj"))) { %>
        <script>
            Swal.fire({...getSwalConfig(), title: 'Eliminado', text: 'El registro ha sido borrado del sistema.', icon: 'success'});
        </script>
        <% } %>

        <%-- NINO: Alerta agregada para atrapar si el backend te devuelve un error invisible --%>
        <% if (request.getParameter("err") != null) { %>
        <script>
            Swal.fire({...getSwalConfig(), title: 'Error en el Servidor', text: 'El sistema no pudo procesar la solicitud (Código: <%= request.getParameter("err") %>).', icon: 'error'});
        </script>
        <% } %>

        <%-- ALERTA PARA ESTUDIANTES POR MULTAS PENDIENTES --%>
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