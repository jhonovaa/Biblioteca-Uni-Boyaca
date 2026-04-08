<%@page import="java.util.List"%>
<%@page import="co.edu.uniboyaca.biblioteca.model.Queja"%>
<%@page import="co.edu.uniboyaca.biblioteca.dao.QuejaDAO"%>
<%@page import="co.edu.uniboyaca.biblioteca.dao.QuejaDAOImpl"%>
<%
    request.setCharacterEncoding("UTF-8");
    if (session.getAttribute("nombreUsuario") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String rol = (String) session.getAttribute("tipoUsuario");
    String nombreUser = (String) session.getAttribute("nombreUsuario");
    String emailUser = (String) session.getAttribute("emailUsuario");

    QuejaDAO dao = new QuejaDAOImpl();
    List<Queja> listaQuejas = null;

    if ("Docente".equals(rol)) {
        listaQuejas = dao.listarTodasLasQuejas();
    } else {
        listaQuejas = dao.listarQuejasPorCorreo(emailUser);
    }

    int totalPqrs = 0;
    int pendientesPqrs = 0;
    int respondidasPqrs = 0;
    if (listaQuejas != null) {
        totalPqrs = listaQuejas.size();
        for (Queja q : listaQuejas) {
            if ("Pendiente".equals(q.getEstado())) {
                pendientesPqrs++;
            } else {
                respondidasPqrs++;
            }
        }
    }
%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>PQRS - Sistema Biblioteca</title>

        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">

        <style>
            :root {
                --apple-bg: #f5f5f7;
                --card-bg: #ffffff;
                --text-main: #1d1d1f;
                --border-color: rgba(0,0,0,0.1);
                --brand-red: #ff3b30;
                --brand-red-hover: #d72c21;
                --accent-green: #34c759;
                --brand-blue: #007aff;
                --soft-gray: rgba(125, 125, 125, 0.08);
            }

            body.dark-mode {
                --apple-bg: #000000;
                --card-bg: #1c1c1e;
                --text-main: #f5f5f7;
                --border-color: rgba(255,255,255,0.25);
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
                display: block;
            }

            .request-bubble {
                background: var(--soft-gray);
                border-radius: 18px;
                padding: 18px;
                border: 1px solid var(--border-color);
            }
            .response-bubble {
                background: rgba(52, 199, 89, 0.1);
                border-radius: 22px;
                padding: 22px;
                border: 1px solid rgba(52, 199, 89, 0.2);
            }

            .official-seal {
                display: flex;
                align-items: center;
                gap: 12px;
                margin-bottom: 15px;
                color: var(--accent-green);
                font-weight: 700;
                font-size: 0.9rem;
            }

            .table-custom {
                width: 100%;
                border-collapse: separate;
                border-spacing: 0;
                color: var(--text-main) !important;
            }
            .table-custom th {
                border-bottom: 2px solid var(--border-color) !important;
                padding: 15px;
                background: transparent !important;
                color: var(--text-main) !important;
                font-weight: 600;
                opacity: 0.8;
            }
            .table-custom td {
                border-bottom: 1px solid var(--border-color) !important;
                padding: 15px;
                background: transparent !important;
                color: var(--text-main) !important;
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

            .dark-mode .form-select.form-control-apple {
                background-image: url("data:image/svg+xml,%3csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 16 16'%3e%3cpath fill='none' stroke='%23f5f5f7' stroke-linecap='round' stroke-linejoin='round' stroke-width='2' d='m2 5 6 6 6-6'/%3e%3c/svg%3e");
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

            .btn-view-ans {
                background: rgba(52, 199, 89, 0.1);
                color: var(--accent-green);
                border: none;
                border-radius: 10px;
                padding: 6px 12px;
                font-weight: 700;
                font-size: 0.85rem;
                transition: 0.2s;
            }
            .btn-view-ans:hover {
                background: var(--accent-green);
                color: white;
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

            .stat-card {
                border-radius: 20px;
                padding: 1.5rem;
                border: 1px solid var(--border-color);
                background: var(--soft-gray);
                display: flex;
                align-items: center;
                gap: 15px;
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
                <h1 class="fw-bold display-5">Buzón Institucional</h1>
                <p class="opacity-50 fs-5">Seguimiento y respuestas oficiales PQRS</p>
            </header>

            <% if (request.getAttribute("mensaje") != null) {%>
            <div class="alert alert-success border-0 rounded-4 text-center mb-4 shadow-sm" style="background: rgba(52, 199, 89, 0.1); color: var(--accent-green); font-weight: 600;">
                <i class="bi bi-check-circle-fill me-2"></i> <%= request.getAttribute("mensaje")%>
            </div>
            <% }%>

            <div class="row g-3 mb-5 reveal active">
                <div class="col-md-4">
                    <div class="stat-card">
                        <div class="stat-icon" style="background: rgba(0, 122, 255, 0.1); color: var(--brand-blue);"><i class="bi bi-inboxes-fill"></i></div>
                        <div>
                            <p class="info-label mb-0">Total Radicados</p>
                            <h3 class="fw-bold mb-0"><%= totalPqrs%></h3>
                        </div>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="stat-card">
                        <div class="stat-icon" style="background: rgba(255, 159, 10, 0.1); color: #ff9f0a;"><i class="bi bi-hourglass-split"></i></div>
                        <div>
                            <p class="info-label mb-0">En Trámite (Pendientes)</p>
                            <h3 class="fw-bold mb-0"><%= pendientesPqrs%></h3>
                        </div>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="stat-card">
                        <div class="stat-icon" style="background: rgba(52, 199, 89, 0.1); color: var(--accent-green);"><i class="bi bi-check-all"></i></div>
                        <div>
                            <p class="info-label mb-0">Resueltas / Respondidas</p>
                            <h3 class="fw-bold mb-0"><%= respondidasPqrs%></h3>
                        </div>
                    </div>
                </div>
            </div>

            <% if ("Docente".equals(rol)) { %>
            <div class="glass-panel reveal active">


                <div class="d-flex flex-column flex-md-row justify-content-between align-items-center mb-4 gap-3">
                    <h4 class="fw-bold m-0"><i class="bi bi-shield-lock-fill me-2" style="color: var(--brand-red);"></i>Panel de Gestión</h4>
                    <div class="d-flex gap-2 w-100 justify-content-md-end">
                        <div class="input-group" style="max-width: 300px;">
                            <span class="input-group-text bg-transparent border-end-0" style="border-color: var(--border-color); border-radius: 16px 0 0 16px;"><i class="bi bi-search text-muted"></i></span>
                            <input type="text" id="buscadorPQRS" onkeyup="filtrarTabla()" class="form-control form-control-apple border-start-0 ps-0" placeholder="Buscar asunto o usuario..." style="border-radius: 0 16px 16px 0; background: transparent !important;">
                        </div>
                        <button class="btn btn-light rounded-pill fw-bold border" onclick="filtrarEstado('Todas')">Todas</button>
                        <button class="btn btn-warning rounded-pill fw-bold" onclick="filtrarEstado('Pendiente')">Pendientes</button>
                    </div>
                </div>

                <div class="table-responsive">
                    <table class="table table-custom align-middle" id="tablaPQRS">
                        <thead>
                            <tr><th>Solicitante</th><th>Tipo</th><th>Asunto</th><th>Estado</th><th class="text-center">Acción</th></tr>
                        </thead>
                        <tbody>
                            <% if (listaQuejas != null && !listaQuejas.isEmpty()) {
                                    for (Queja q : listaQuejas) {%>
                            <tr>
                                <td>
                                    <div class="fw-bold"><%= q.getNombreSolicitante()%></div>
                                    <div class="small opacity-50"><%= q.getCorreoSolicitante()%></div>
                                </td>
                                <td><span class="badge border border-secondary text-secondary bg-transparent"><%= q.getTipoSolicitud()%></span></td>
                                <td class="fw-medium"><%= q.getAsunto()%></td>
                                <td>
                                    <span class="badge rounded-pill <%= q.getEstado().equals("Pendiente") ? "bg-warning text-dark" : "bg-success text-white"%> px-3 col-estado">
                                        <%= q.getEstado()%>
                                    </span>
                                </td>
                                <td class="text-center">
                                    <div class="d-flex justify-content-center gap-2">
                                        <% if ("Pendiente".equals(q.getEstado())) {%>
                                        <button type="button" class="btn btn-danger rounded-pill px-3 btn-sm fw-bold shadow-sm" data-bs-toggle="modal" data-bs-target="#modalResp<%= q.getId()%>">
                                            <i class="bi bi-chat-left-dots-fill me-1"></i> Atender
                                        </button>
                                        <% } else {%>
                                        <button type="button" class="btn btn-action-primary px-3" data-bs-toggle="modal" data-bs-target="#modalEditResp<%= q.getId()%>">
                                            <i class="bi bi-pencil-square me-1"></i> Corregir
                                        </button>
                                        <% } %>
                                    </div>
                                </td>
                            </tr>
                            <% }
                            } else { %>
                            <tr><td colspan="5" class="text-center py-5 opacity-50">Buzón vacío. No hay PQRS registradas.</td></tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            </div>

            <% } else {%>
            <div class="row g-4">
                <div class="col-lg-5">
                    <div class="glass-panel reveal active h-100">
                        <h4 class="fw-bold mb-4" style="color: var(--brand-red);"><i class="bi bi-plus-circle-fill me-2"></i>Nueva Radicación</h4>
                        <form action="ProcesarQuejaServlet" method="POST">
                            <input type="hidden" name="accion" value="radicar">
                            <input type="hidden" name="nombreSolicitante" value="<%= nombreUser%>">

                            <div class="mb-3">
                                <label class="info-label">Categoría del requerimiento</label>
                                <select name="tipoSolicitud" class="form-select form-control-apple">
                                    <option value="Queja">Queja (Inconformidad con el servicio)</option>
                                    <option value="Reclamo">Reclamo (Problema directo con un proceso)</option>
                                    <option value="Sugerencia">Sugerencia (Propuesta de mejora)</option>
                                    <option value="Peticion">Petición (Solicitud de información o material)</option>
                                    <option value="Felicitacion">Felicitación</option>
                                </select>
                            </div>
                            <div class="mb-3">
                                <label class="info-label">Correo de notificaciones</label>
                                <input type="email" name="correoSolicitante" class="form-control form-control-apple" value="<%= emailUser%>" required>
                            </div>
                            <div class="mb-3">
                                <label class="info-label">Asunto Principal</label>
                                <input type="text" name="asunto" class="form-control form-control-apple" placeholder="Ej: Problema con reserva de cubículo" required>
                            </div>
                            <div class="mb-3">
                                <label class="info-label">Detalle completo de la solicitud</label>
                                <textarea name="descripcion" class="form-control form-control-apple" rows="4" placeholder="Explique detalladamente su situación..." required></textarea>
                            </div>
                            <button type="submit" class="btn-apple-red w-100 shadow mt-2"><i class="bi bi-send-fill me-2"></i>Radicar a Biblioteca</button>
                        </form>
                    </div>
                </div>

                <div class="col-lg-7">
                    <div class="glass-panel reveal active h-100">

                        <div class="d-flex flex-column flex-md-row justify-content-between align-items-center mb-4 gap-3">
                            <h4 class="fw-bold m-0"><i class="bi bi-chat-right-dots-fill me-2"></i>Mis Solicitudes</h4>
                            <div class="input-group" style="max-width: 250px;">
                                <span class="input-group-text bg-transparent border-end-0" style="border-color: var(--border-color); border-radius: 16px 0 0 16px;"><i class="bi bi-search text-muted"></i></span>
                                <input type="text" id="buscadorPQRS" onkeyup="filtrarTabla()" class="form-control form-control-apple border-start-0 ps-0" placeholder="Buscar radicado..." style="border-radius: 0 16px 16px 0; background: transparent !important;">
                            </div>
                        </div>

                        <div class="table-responsive">
                            <table class="table table-custom align-middle" id="tablaPQRS">
                                <thead><tr><th>Radicado</th><th>Asunto</th><th>Estado</th><th class="text-center">Gestión</th></tr></thead>
                                <tbody>
                                    <% if (listaQuejas != null && !listaQuejas.isEmpty()) {
                                            for (Queja q : listaQuejas) {%>
                                    <tr>
                                        <td><span class="fw-bold">#<%= q.getId()%></span><br><span class="small opacity-50"><%= q.getTipoSolicitud()%></span></td>
                                        <td class="fw-medium small"><%= q.getAsunto()%></td>
                                        <td>
                                            <span class="badge rounded-pill <%= q.getEstado().equals("Pendiente") ? "bg-secondary" : "bg-success text-white"%> px-3 col-estado">
                                                <%= q.getEstado()%>
                                            </span>
                                        </td>
                                        <td class="text-center">
                                            <div class="d-flex justify-content-center gap-2">
                                                <% if ("Pendiente".equals(q.getEstado())) {%>
                                                <button type="button" class="btn btn-action-warning px-3" data-bs-toggle="modal" data-bs-target="#modalEditEst<%= q.getId()%>" title="Modificar texto">
                                                    <i class="bi bi-pencil-square"></i>
                                                </button>
                                                <% } %>
                                                <% if ("Respondida".equals(q.getEstado())) {%>
                                                <button type="button" class="btn-view-ans px-3" data-bs-toggle="modal" data-bs-target="#modalVer<%= q.getId()%>" title="Leer Respuesta">
                                                    <i class="bi bi-envelope-open-fill"></i>
                                                </button>
                                                <% } else if (!"Pendiente".equals(q.getEstado())) { %>
                                                <span class="opacity-25 small italic">En trámite...</span>
                                                <% } %>
                                            </div>
                                        </td>
                                    </tr>
                                    <% }
                                    } else { %>
                                    <tr><td colspan="4" class="text-center py-5 opacity-50">No tienes solicitudes registradas.</td></tr>
                                    <% } %>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
            <% } %>
        </div>

        <% if (listaQuejas != null) {
                for (Queja q : listaQuejas) {%>

        <div class="modal fade" id="modalEditEst<%= q.getId()%>" tabindex="-1" aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered">
                <div class="modal-content border-0">
                    <div class="modal-body p-5">
                        <h4 class="fw-bold mb-4">Actualizar mi Solicitud</h4>
                        <form action="ProcesarQuejaServlet" method="POST">
                            <input type="hidden" name="accion" value="actualizar">
                            <input type="hidden" name="idQueja" value="<%= q.getId()%>">
                            <div class="mb-3">
                                <label class="info-label">Asunto</label>
                                <input type="text" name="asunto" class="form-control form-control-apple" value="<%= q.getAsunto()%>" required>
                            </div>
                            <div class="mb-3">
                                <label class="info-label">Descripción</label>
                                <textarea name="descripcion" class="form-control form-control-apple" rows="5" required><%= q.getDescripcion()%></textarea>
                            </div>
                            <div class="d-flex gap-3">
                                <button type="button" class="btn btn-light rounded-pill px-4 w-100 fw-bold" data-bs-dismiss="modal">Cerrar</button>
                                <button type="submit" class="btn-apple-red w-100 shadow">Guardar Cambios</button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>

        <% if ("Docente".equals(rol)) {%>

        <div class="modal fade" id="modalResp<%= q.getId()%>" tabindex="-1" aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered modal-lg">
                <div class="modal-content border-0">
                    <div class="modal-body p-5">
                        <h3 class="fw-bold mb-4">Atender Radicado #PQRS-<%= q.getId()%></h3>

                        <div class="row mb-3">
                            <div class="col-6">
                                <p class="info-label">Usuario Solicitante</p>
                                <p class="fw-bold mb-0 text-truncate"><i class="bi bi-person-circle me-1"></i><%= q.getNombreSolicitante()%></p>
                            </div>
                            <div class="col-6 text-end">
                                <p class="info-label">Categoría</p>
                                <span class="badge bg-secondary bg-opacity-10 text-secondary border border-secondary border-opacity-25 px-3"><%= q.getTipoSolicitud()%></span>
                            </div>
                        </div>

                        <div class="row mb-3">
                            <div class="col-6">
                                <p class="info-label">Contacto del Usuario</p>
                                <p class="fw-bold mb-0" style="color: var(--brand-red);"><i class="bi bi-envelope-at me-1"></i><%= q.getCorreoSolicitante()%></p>
                            </div>
                            <div class="col-6 text-end">
                                <p class="info-label">Fecha de Radicación</p>
                                <p class="small opacity-50 mb-0"><i class="bi bi-calendar3 me-1"></i><%= (q.getFechaRadicado() != null) ? q.getFechaRadicado().toString().substring(0, 16) : "Sin fecha"%></p>
                            </div>
                        </div>

                        <div class="mb-4">
                            <p class="info-label">Asunto de la Petición</p>
                            <p class="fw-bold border-start border-3 border-danger ps-2"><%= q.getAsunto()%></p>
                        </div>

                        <div class="mb-4">
                            <p class="info-label">Descripción del Problema</p>
                            <div class="request-bubble">
                                <p class="mb-0 fs-6 italic">"<%= q.getDescripcion()%>"</p>
                            </div>
                        </div>

                        <form action="ProcesarQuejaServlet" method="POST">
                            <input type="hidden" name="accion" value="responder">
                            <input type="hidden" name="idQueja" value="<%= q.getId()%>">
                            <div class="mb-4">
                                <label class="info-label" style="color: var(--brand-red);">Respuesta Oficial del Sistema</label>
                                <textarea name="respuesta" class="form-control form-control-apple" rows="5" required placeholder="Escriba la resolución técnica o administrativa..."></textarea>
                            </div>
                            <div class="d-flex gap-3">
                                <button type="button" class="btn btn-light rounded-pill px-4 w-100 fw-bold" data-bs-dismiss="modal">Cancelar</button>
                                <button type="submit" class="btn-apple-red w-100 shadow"><i class="bi bi-send-check me-2"></i>Emitir Respuesta</button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>

        <%-- MODAL EDITAR RESPUESTA PARA EL ADMIN (CON MÁS INFORMACIÓN - CORREGIDO) --%>
        <div class="modal fade" id="modalEditResp<%= q.getId()%>" tabindex="-1" aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered modal-lg">
                <div class="modal-content border-0">
                    <div class="modal-body p-5">
                        <h3 class="fw-bold mb-4">Corregir Respuesta Oficial #PQRS-<%= q.getId()%></h3>

                        <div class="row mb-3">
                            <div class="col-6">
                                <p class="info-label">Usuario</p>
                                <p class="fw-bold mb-0"><%= q.getNombreSolicitante()%></p>
                            </div>
                            <div class="col-6 text-end">
                                <p class="info-label">Categoría</p>
                                <span class="badge bg-secondary bg-opacity-10 text-secondary px-3"><%= q.getTipoSolicitud()%></span>
                            </div>
                        </div>

                        <div class="row mb-3">
                            <div class="col-6">
                                <p class="info-label">Contacto</p>
                                <p class="fw-bold mb-0 text-danger"><%= q.getCorreoSolicitante()%></p>
                            </div>
                            <div class="col-6 text-end">
                                <p class="info-label">Fecha Original</p>
                                <p class="small opacity-50 mb-0"><%= (q.getFechaRadicado() != null) ? q.getFechaRadicado().toString().substring(0, 16) : ""%></p>
                            </div>
                        </div>

                        <div class="mb-4">
                            <p class="info-label">Asunto</p>
                            <p class="fw-bold ps-2 border-start border-3 border-primary"><%= q.getAsunto()%></p>
                        </div>

                        <div class="mb-4">
                            <p class="info-label">Problema Radicado</p>
                            <div class="request-bubble" style="opacity: 0.8;">
                                <p class="mb-0 fs-6">"<%= q.getDescripcion()%>"</p>
                            </div>
                        </div>

                        <form action="ProcesarQuejaServlet" method="POST">
                            <input type="hidden" name="accion" value="responder">
                            <input type="hidden" name="idQueja" value="<%= q.getId()%>">
                            <div class="mb-4">
                                <label class="info-label" style="color: var(--brand-red);">Editar texto de resolución:</label>
                                <textarea name="respuesta" class="form-control form-control-apple" rows="5" required><%= q.getRespuesta()%></textarea>
                            </div>
                            <div class="d-flex gap-3">
                                <button type="button" class="btn btn-light rounded-pill px-4 w-100 fw-bold" data-bs-dismiss="modal">Cerrar</button>
                                <button type="submit" class="btn-apple-red w-100 shadow">Actualizar Respuesta</button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>
        <% } else if ("Respondida".equals(q.getEstado())) {%>

        <div class="modal fade" id="modalVer<%= q.getId()%>" tabindex="-1" aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered modal-lg">
                <div class="modal-content border-0">
                    <div class="modal-body p-5">
                        <div class="official-seal">
                            <i class="bi bi-patch-check-fill fs-4"></i>
                            <span>RESOLUCIÓN OFICIAL BIBLIOTECA</span>
                        </div>
                        <h3 class="fw-bold mb-1">Tu solicitud ha sido resuelta</h3>
                        <p class="opacity-50 small mb-4">Radicado #PQRS-<%= q.getId()%> • <%= (q.getFechaRadicado() != null) ? q.getFechaRadicado().toString().substring(0, 10) : ""%></p>

                        <hr class="opacity-10 my-4">

                        <div class="row mb-4">
                            <div class="col-md-12">
                                <p class="info-label">Detalles de tu solicitud original</p>
                                <div class="p-3 rounded-4 bg-light bg-opacity-10 border border-secondary border-opacity-10">
                                    <p class="fw-bold mb-1"><%= q.getAsunto()%></p>
                                    <p class="mb-0 small opacity-75">"<%= q.getDescripcion()%>"</p>
                                </div>
                            </div>
                        </div>

                        <div class="mb-5">
                            <p class="info-label text-success">Respuesta de la Administración:</p>
                            <div class="response-bubble shadow-sm">
                                <p class="mb-0 fs-6 fw-medium"><%= q.getRespuesta()%></p>
                            </div>
                        </div>

                        <button type="button" class="btn-apple-red w-100 py-3 shadow-sm fw-bold" data-bs-dismiss="modal">Entendido, cerrar</button>
                    </div>
                </div>
            </div>
        </div>
        <% } %>

        <% }
            }%>

        <script src="https://cdn.jsdelivr.net/npm/@popperjs/core@2.11.8/dist/umd/popper.min.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.min.js"></script>

        <script>
                                    function filtrarTabla() {
                                        let input = document.getElementById("buscadorPQRS").value.toLowerCase();
                                        let filas = document.querySelectorAll("#tablaPQRS tbody tr");

                                        filas.forEach(fila => {

                                            if (fila.cells.length === 1)
                                                return;

                                            let texto = fila.innerText.toLowerCase();
                                            fila.style.display = texto.includes(input) ? "" : "none";
                                        });
                                    }

                                    function filtrarEstado(estadoBuscar) {
                                        let filas = document.querySelectorAll("#tablaPQRS tbody tr");

                                        filas.forEach(fila => {
                                            if (fila.cells.length === 1)
                                                return;

                                            let spanEstado = fila.querySelector(".col-estado");
                                            if (spanEstado) {
                                                let estadoActual = spanEstado.innerText.trim();
                                                if (estadoBuscar === 'Todas' || estadoActual === estadoBuscar) {
                                                    fila.style.display = "";
                                                } else {
                                                    fila.style.display = "none";
                                                }
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
    </body>
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
</html>