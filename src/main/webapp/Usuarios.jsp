<%
    request.setCharacterEncoding("UTF-8");
    if (session.getAttribute("nombreUsuario") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    String rol = (String) session.getAttribute("tipoUsuario");
%>

<%@page import="co.edu.uniboyaca.biblioteca.model.Usuarios"%>
<%@page import="co.edu.uniboyaca.biblioteca.dao.UsuarioDAOImpl"%>
<%@page import="co.edu.uniboyaca.biblioteca.dao.UsuarioDAO"%>
<%@page import="java.util.List"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%
    UsuarioDAO dao = new UsuarioDAOImpl();
    String accion = request.getParameter("accion");
    Usuarios uEdit = new Usuarios();

    if ("editar".equals(accion)) {
        String idStr = request.getParameter("id");
        if (idStr != null && !idStr.isEmpty()) {
            uEdit = dao.obtenerPorId(Integer.parseInt(idStr));
        }
    }

    if ("eliminar".equals(accion)) {
        String idStr = request.getParameter("id");
        try {
            if (idStr != null && !idStr.isEmpty()) {
                dao.eliminar(Integer.parseInt(idStr));
                response.sendRedirect("Usuarios.jsp?msj=eliminado");
            } else {
                response.sendRedirect("Usuarios.jsp");
            }
        } catch (Exception e) {
            response.sendRedirect("Usuarios.jsp?err=en_uso");
        }
        return;
    }

    if ("insertar".equals(accion) || "actualizar".equals(accion)) {
        try {
            Usuarios u = new Usuarios();
            u.setDocumento(request.getParameter("txtDocumento"));
            u.setNombres(request.getParameter("txtNombres"));
            u.setApellidos(request.getParameter("txtApellidos"));
            u.setEmail(request.getParameter("txtEmail"));
            u.setTelefono(request.getParameter("txtTelefono"));
            u.setTipoUsuario(request.getParameter("txtTipo"));
            u.setEstado(request.getParameter("txtEstado"));
            u.setPassword(request.getParameter("txtPassword"));

            boolean resultado;
            if ("actualizar".equals(accion)) {
                u.setIdUsuario(Integer.parseInt(request.getParameter("txtId")));
                resultado = dao.actualizar(u);
            } else {
                resultado = dao.insertar(u);
            }

            if (resultado) {
                request.setAttribute("mensaje", "Usuario guardado correctamente.");
            } else {
                request.setAttribute("error", "Error interno al procesar la solicitud.");
            }
        } catch (Exception e) {
            request.setAttribute("error", "Error: " + e.getMessage());
        }
    }

    // --- NUEVO: CÁLCULO DE ESTADÍSTICAS E INFORMACIÓN ---
    List<Usuarios> listaUsuarios = dao.listar();
    int totalUsuarios = 0;
    int usuariosActivos = 0;
    int usuariosProblema = 0; // Sancionados o Inactivos

    if (listaUsuarios != null) {
        totalUsuarios = listaUsuarios.size();
        for (Usuarios user : listaUsuarios) {
            if ("Activo".equals(user.getEstado())) {
                usuariosActivos++;
            } else {
                usuariosProblema++;
            }
        }
    }
%>

<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Gestión de Usuarios - Biblioteca</title>

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
                --brand-blue-hover: #0062cc;
                --accent-green: #34c759;
                --soft-gray: rgba(125, 125, 125, 0.08);

                /* Variables para el boton de editar */
                --btn-edit-bg: rgba(0, 0, 0, 0.05);
                --btn-edit-text: var(--text-main);
                --btn-edit-hover-bg: rgba(0, 0, 0, 0.1);
            }

            body.dark-mode {
                --apple-bg: #000000;
                --card-bg: #1c1c1e;
                --text-main: #f5f5f7;
                --border-color: rgba(255,255,255,0.1);
                --soft-gray: rgba(255, 255, 255, 0.05);

                /* Variables para el boton de editar en oscuro */
                --btn-edit-bg: rgba(255, 255, 255, 0.1);
                --btn-edit-text: #ffffff;
                --btn-edit-hover-bg: rgba(255, 255, 255, 0.2);
            }

            body {
                font-family: 'Inter', sans-serif;
                background-color: var(--apple-bg);
                color: var(--text-main);
                transition: 0.3s ease;
                min-height: 100vh;
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

            .form-control-apple, .form-select.form-control-apple {
                background-color: var(--soft-gray) !important;
                color: var(--text-main) !important;
                border: 1px solid var(--border-color);
                border-radius: 16px;
                padding: 12px 15px;
                transition: 0.3s;
            }

            .form-control-apple:focus, .form-select.form-control-apple:focus {
                border-color: var(--brand-red);
                box-shadow: 0 0 0 0.25rem rgba(255, 59, 48, 0.25);
            }

            .dark-mode select.form-control-apple option {
                background-color: #1c1c1e !important;
                color: #f5f5f7 !important;
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

            .btn-action-primary {
                background: var(--btn-edit-bg);
                color: var(--btn-edit-text);
                border: none;
                border-radius: 10px;
                padding: 6px 12px;
                font-weight: 600;
                font-size: 0.85rem;
                transition: 0.2s;
            }
            .btn-action-primary:hover {
                background: var(--btn-edit-hover-bg);
                color: var(--btn-edit-text);
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

            .apple-alert {
                background: rgba(255, 255, 255, 0.85) !important;
                backdrop-filter: blur(25px) !important;
                -webkit-backdrop-filter: blur(25px) !important;
                border-radius: 24px !important;
                border: 1px solid rgba(0,0,0,0.1) !important;
                box-shadow: 0 25px 50px rgba(0,0,0,0.1) !important;
                padding: 2rem 1.5rem 1.5rem !important;
            }

            body.dark-mode .apple-alert {
                background: rgba(28, 28, 30, 0.8) !important;
                border: 1px solid rgba(255,255,255,0.1) !important;
                box-shadow: 0 25px 50px rgba(0,0,0,0.5) !important;
            }

            .apple-alert .swal2-title {
                font-family: 'Inter', -apple-system, sans-serif !important;
                font-weight: 700 !important;
                font-size: 1.3rem !important;
                color: var(--text-main) !important;
                padding: 0 !important;
                margin-bottom: 10px !important;
            }

            .apple-alert .swal2-html-container {
                font-family: 'Inter', -apple-system, sans-serif !important;
                font-size: 0.95rem !important;
                color: var(--text-main) !important;
                opacity: 0.8;
                padding: 0 10px !important;
                margin-bottom: 24px !important;
            }

            .apple-alert .swal2-actions {
                width: 100% !important;
                margin-top: 1rem !important;
                gap: 12px !important;
                display: flex !important;
                flex-direction: column !important;
            }

            .apple-btn {
                border-radius: 14px !important;
                font-weight: 600 !important;
                font-family: 'Inter', -apple-system, sans-serif !important;
                padding: 14px !important;
                width: 100% !important;
                margin: 0 !important;
                border: none !important;
                transition: transform 0.2s, opacity 0.2s !important;
            }

            .apple-btn:active {
                transform: scale(0.98) !important;
            }

            .apple-btn-primary {
                background: var(--brand-blue) !important;
                color: #fff !important;
            }
            .apple-btn-primary:hover {
                background: var(--brand-blue-hover) !important;
            }

            .apple-btn-danger {
                background: var(--brand-red) !important;
                color: #fff !important;
            }
            .apple-btn-danger:hover {
                background: var(--brand-red-hover) !important;
            }

            .apple-btn-cancel {
                background: var(--soft-gray) !important;
                color: var(--text-main) !important;
            }
            .apple-btn-cancel:hover {
                background: rgba(125,125,125,0.15) !important;
            }

            .swal2-icon {
                border: none !important;
                margin-top: 0 !important;
                margin-bottom: 1rem !important;
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

            /* --- ESTILOS DE TARJETAS DE ESTADÍSTICAS --- */
            .stat-card {
                border-radius: 20px;
                padding: 1.5rem;
                border: 1px solid var(--border-color);
                background: var(--glass-bg, var(--card-bg));
                display: flex;
                align-items: center;
                gap: 15px;
                transition: transform 0.3s;
            }
            .stat-card:hover {
                transform: translateY(-5px);
            }
            .stat-icon {
                width: 50px;
                height: 50px;
                border-radius: 12px;
                display: flex;
                align-items: center;
                justify-content: center;
                font-size: 1.5rem;
            }
        </style>
    </head>
    <body class="dark-mode">

        <%@include file="includes/navbar.jsp" %>

        <div class="container py-5">
            <header class="text-center mb-5 reveal active">
                <h1 class="display-5 fw-bold">Gestión de Usuarios</h1>
                <p class="opacity-50 fs-5" style="color: var(--brand-red);">Administración de cuentas, roles y accesos</p>
            </header>

            <%-- DASHBOARD DE ESTADÍSTICAS --%>
            <div class="row g-3 mb-5 reveal active">
                <div class="col-md-4">
                    <div class="stat-card shadow-sm">
                        <div class="stat-icon" style="background: rgba(0, 122, 255, 0.1); color: var(--brand-blue);"><i class="bi bi-people-fill"></i></div>
                        <div>
                            <p class="info-label mb-0">Total Usuarios</p>
                            <h3 class="fw-bold mb-0"><%= totalUsuarios%></h3>
                        </div>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="stat-card shadow-sm">
                        <div class="stat-icon" style="background: rgba(52, 199, 89, 0.1); color: var(--accent-green);"><i class="bi bi-person-check-fill"></i></div>
                        <div>
                            <p class="info-label mb-0">Usuarios Activos</p>
                            <h3 class="fw-bold mb-0"><%= usuariosActivos%></h3>
                        </div>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="stat-card shadow-sm">
                        <div class="stat-icon" style="background: rgba(255, 59, 48, 0.1); color: var(--brand-red);"><i class="bi bi-person-dash-fill"></i></div>
                        <div>
                            <p class="info-label mb-0">Inactivos / Sancionados</p>
                            <h3 class="fw-bold mb-0"><%= usuariosProblema%></h3>
                        </div>
                    </div>
                </div>
            </div>

            <div class="row g-4">

                <div class="col-lg-4">
                    <div class="glass-panel reveal active h-100">
                        <h4 class="fw-bold mb-4" style="color: var(--brand-red);">
                            <i class="bi <%= (uEdit.getIdUsuario() > 0) ? "bi-person-gear" : "bi-person-plus-fill"%> me-2"></i>
                            <%= (uEdit.getIdUsuario() > 0) ? "Editar Usuario #" + uEdit.getIdUsuario() : "Nuevo Usuario"%>
                        </h4>

                        <form method="POST" action="Usuarios.jsp">
                            <input type="hidden" name="txtId" value="<%= uEdit.getIdUsuario()%>">
                            <input type="hidden" name="txtPassword" value="<%= (uEdit.getPassword() != null && !uEdit.getPassword().isEmpty()) ? uEdit.getPassword() : "123456"%>">

                            <div class="mb-3">
                                <label class="info-label">Documento de Identidad</label>
                                <input type="text" name="txtDocumento" class="form-control form-control-apple" placeholder="Ej: 1050..." 
                                       value="<%= (uEdit.getDocumento() != null) ? uEdit.getDocumento() : ""%>" required>
                            </div>

                            <div class="row g-2 mb-3">
                                <div class="col-6">
                                    <label class="info-label">Nombres</label>
                                    <input type="text" name="txtNombres" class="form-control form-control-apple" 
                                           value="<%= (uEdit.getNombres() != null) ? uEdit.getNombres() : ""%>" required>
                                </div>
                                <div class="col-6">
                                    <label class="info-label">Apellidos</label>
                                    <input type="text" name="txtApellidos" class="form-control form-control-apple" 
                                           value="<%= (uEdit.getApellidos() != null) ? uEdit.getApellidos() : ""%>" required>
                                </div>
                            </div>

                            <div class="mb-3">
                                <label class="info-label">Correo Electrónico</label>
                                <input type="email" name="txtEmail" class="form-control form-control-apple" 
                                       value="<%= (uEdit.getEmail() != null) ? uEdit.getEmail() : ""%>">
                            </div>

                            <div class="mb-3">
                                <label class="info-label">Teléfono de Contacto</label>
                                <input type="text" name="txtTelefono" class="form-control form-control-apple" 
                                       value="<%= (uEdit.getTelefono() != null) ? uEdit.getTelefono() : ""%>">
                            </div>

                            <div class="row g-2 mb-4">
                                <div class="col-6">
                                    <label class="info-label">Rol del Sistema</label>
                                    <select name="txtTipo" class="form-select form-control-apple">
                                        <option value="Estudiante" <%= "Estudiante".equals(uEdit.getTipoUsuario()) ? "selected" : ""%>>Estudiante</option>
                                        <option value="Docente" <%= "Docente".equals(uEdit.getTipoUsuario()) ? "selected" : ""%>>Docente</option>
                                    </select>
                                </div>
                                <div class="col-6">
                                    <label class="info-label">Estado</label>
                                    <select name="txtEstado" class="form-select form-control-apple">
                                        <option value="Activo" <%= "Activo".equals(uEdit.getEstado()) ? "selected" : ""%>>Activo</option>
                                        <option value="Inactivo" <%= "Inactivo".equals(uEdit.getEstado()) ? "selected" : ""%>>Inactivo</option>
                                        <option value="Sancionado" <%= "Sancionado".equals(uEdit.getEstado()) ? "selected" : ""%>>Sancionado</option>
                                    </select>
                                </div>
                            </div>

                            <button type="submit" name="accion" value="<%= (uEdit.getIdUsuario() > 0) ? "actualizar" : "insertar"%>" 
                                    class="btn-apple-red w-100 shadow-sm">
                                <%= (uEdit.getIdUsuario() > 0) ? "Guardar Cambios" : "Registrar Usuario"%>
                            </button>

                            <% if (uEdit.getIdUsuario() > 0) { %>
                            <a href="Usuarios.jsp" class="btn-apple-outline w-100 mt-2">Cancelar Edición</a>
                            <% } %>
                        </form>
                    </div>
                </div>

                <div class="col-lg-8">
                    <div class="glass-panel reveal active delay-1 h-100">
                        <div class="d-flex flex-column flex-md-row justify-content-between align-items-center mb-4 gap-3">
                            <h4 class="fw-bold m-0"><i class="bi bi-people-fill me-2" style="color: var(--brand-red);"></i>Directorio</h4>

                            <div class="d-flex flex-wrap justify-content-md-end gap-2 align-items-center">

                                <%-- BARRA DE BÚSQUEDA --%>
                                <div class="input-group" style="max-width: 250px;">
                                    <span class="input-group-text bg-transparent border-end-0" style="border-color: var(--border-color); border-radius: 16px 0 0 16px;">
                                        <i class="bi bi-search text-muted"></i>
                                    </span>
                                    <input type="text" id="buscadorUsuarios" onkeyup="filtrarUsuarios()" class="form-control form-control-apple border-start-0 ps-0" placeholder="Buscar usuario..." style="border-radius: 0 16px 16px 0; background: transparent !important;">
                                </div>

                                <button onclick="exportarExcel()" class="btn-export" title="Exportar Excel">
                                    <i class="bi bi-file-earmark-excel text-success"></i>
                                </button>
                                <button onclick="exportarPDF()" class="btn-export" title="Exportar PDF">
                                    <i class="bi bi-file-earmark-pdf text-danger"></i>
                                </button>
                            </div>
                        </div>

                        <div class="table-responsive">
                            <table class="table table-custom align-middle mb-0" id="tablaUsuarios">
                                <thead>
                                    <tr>
                                        <th>Documento</th>
                                        <th>Nombre Completo</th>
                                        <th>Contacto</th>
                                        <th>Rol / Estado</th>
                                        <th class="text-center">Acciones</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <%
                                        if (listaUsuarios == null || listaUsuarios.isEmpty()) {
                                    %>
                                    <tr>
                                        <td colspan="5" class="text-center py-5 opacity-50">
                                            No hay usuarios en la base de datos.
                                        </td>
                                    </tr>
                                    <%
                                    } else {
                                        for (Usuarios u : listaUsuarios) {
                                            String nombreComp = (u.getNombres() != null ? u.getNombres() : "") + " "
                                                    + (u.getApellidos() != null ? u.getApellidos() : "");
                                            if (nombreComp.trim().isEmpty())
                                                nombreComp = "Sin nombre registrado";
                                    %>
                                    <tr>
                                        <td class="fw-bold opacity-75"><i class="bi bi-person-badge me-1"></i><%= u.getDocumento()%></td>
                                        <td class="fw-bold"><%= nombreComp%></td>
                                        <td>
                                            <div class="small opacity-75"><i class="bi bi-envelope-at me-1"></i><%= (u.getEmail() != null) ? u.getEmail() : "N/A"%></div>
                                            <div class="small opacity-75"><i class="bi bi-telephone me-1"></i><%= (u.getTelefono() != null) ? u.getTelefono() : "N/A"%></div>
                                        </td>
                                        <td>
                                            <span class="badge bg-secondary bg-opacity-10 text-secondary border border-secondary border-opacity-25 px-3 mb-1"><%= u.getTipoUsuario()%></span><br>
                                            <% if ("Activo".equals(u.getEstado())) { %>
                                            <span class="badge bg-success bg-opacity-10 text-success border border-success border-opacity-25 px-3">Activo</span>
                                            <% } else if ("Sancionado".equals(u.getEstado())) { %>
                                            <span class="badge bg-warning bg-opacity-10 text-warning border border-warning border-opacity-25 px-3">Sancionado</span>
                                            <% } else { %>
                                            <span class="badge bg-danger bg-opacity-10 text-danger border border-danger border-opacity-25 px-3">Inactivo</span>
                                            <% }%>
                                        </td>
                                        <td class="text-center">
                                            <div class="d-flex justify-content-center gap-2">
                                                <a href="Usuarios.jsp?accion=editar&id=<%= u.getIdUsuario()%>" class="btn-action-primary text-decoration-none" title="Editar"><i class="bi bi-pencil-square"></i></a>
                                                <button onclick="confirmarEliminar(<%= u.getIdUsuario()%>)" class="btn-action-danger text-decoration-none" title="Eliminar"><i class="bi bi-trash3"></i></button>
                                            </div>
                                        </td>
                                    </tr>
                                    <%
                                            }
                                        }
                                    %>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <script src="https://cdn.jsdelivr.net/npm/@popperjs/core@2.11.8/dist/umd/popper.min.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.min.js"></script>

        <script>
                                                    // --- NUEVO: FILTRAR TABLA USUARIOS ---
                                                    function filtrarUsuarios() {
                                                        let input = document.getElementById("buscadorUsuarios").value.toLowerCase();
                                                        let filas = document.querySelectorAll("#tablaUsuarios tbody tr");

                                                        filas.forEach(fila => {
                                                            // Evitar ocultar el mensaje de "No hay usuarios"
                                                            if (fila.cells.length === 1)
                                                                return;

                                                            let textoFila = fila.innerText.toLowerCase();
                                                            fila.style.display = textoFila.includes(input) ? "" : "none";
                                                        });
                                                    }

                                                    function exportarExcel() {
                                                        const table = document.getElementById("tablaUsuarios");
                                                        const wb = XLSX.utils.table_to_book(table, {sheet: "Usuarios"});
                                                        XLSX.writeFile(wb, "Reporte_Usuarios_Uniboyaca.xlsx");
                                                    }

                                                    function exportarPDF() {
                                                        const {jsPDF} = window.jspdf;
                                                        const doc = new jsPDF('l', 'pt', 'a4');
                                                        doc.setFontSize(18);
                                                        doc.setTextColor(255, 59, 48);
                                                        doc.text("UNIBOYACA - DIRECTORIO DE USUARIOS", 40, 40);
                                                        doc.autoTable({
                                                            html: '#tablaUsuarios',
                                                            startY: 60,
                                                            theme: 'grid',
                                                            headStyles: {fillColor: [255, 59, 48]},
                                                            styles: {fontSize: 9}
                                                        });
                                                        doc.save("Reporte_Usuarios.pdf");
                                                    }

                                                    function getSwalConfig(isDanger = false) {
                                                        return {
                                                            buttonsStyling: false,
                                                            customClass: {
                                                                popup: 'apple-alert',
                                                                title: 'swal2-title',
                                                                htmlContainer: 'swal2-html-container',
                                                                actions: 'swal2-actions',
                                                                confirmButton: isDanger ? 'apple-btn apple-btn-danger' : 'apple-btn apple-btn-primary',
                                                                cancelButton: 'apple-btn apple-btn-cancel'
                                                            }
                                                        };
                                                    }

                                                    function confirmarEliminar(idUsuario) {
                                                        Swal.fire({
                                                            ...getSwalConfig(true),
                                                            title: '¿Eliminar Usuario?',
                                                            text: "Esta acción borrará permanentemente la cuenta del sistema.",
                                                            icon: 'warning',
                                                            showCancelButton: true,
                                                            confirmButtonText: 'Sí, eliminar',
                                                            cancelButtonText: 'Cancelar'
                                                        }).then((result) => {
                                                            if (result.isConfirmed) {
                                                                window.location.href = "Usuarios.jsp?accion=eliminar&id=" + idUsuario;
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
            Swal.fire({...getSwalConfig(false), title: 'Eliminado', text: 'El usuario fue borrado del sistema exitosamente.', icon: 'success'});
        </script>
        <% } %>

        <% if ("en_uso".equals(request.getParameter("err"))) { %>
        <script>
            Swal.fire({
                ...getSwalConfig(true),
                title: '¡Usuario en uso!',
                text: 'Este usuario no se puede eliminar porque tiene préstamos o multas registradas en el sistema.',
                icon: 'error'
            });
        </script>
        <% } %>

        <% if (request.getAttribute("mensaje") != null) {%>
        <script>
            Swal.fire({...getSwalConfig(false), title: '¡Éxito!', text: '<%= request.getAttribute("mensaje")%>', icon: 'success'});
        </script>
        <% } %>
        <% if (request.getAttribute("error") != null) {%>
        <script>
            Swal.fire({...getSwalConfig(true), title: 'Error', text: '<%= request.getAttribute("error")%>', icon: 'error'});
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