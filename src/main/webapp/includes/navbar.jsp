<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    String emailUsuario = (String) session.getAttribute("emailUsuario");
    String rolUsuario = (String) session.getAttribute("tipoUsuario");
%>

<nav class="navbar navbar-expand-lg navbar-apple sticky-top px-4">
    <div class="container-fluid">
        <a href="index.jsp" class="navbar-brand fw-bold text-danger">
            <i class="bi bi-book-half me-2"></i>Biblioteca Uniboyaca
        </a>
        
        <button class="navbar-toggler border-0 shadow-none" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
            <span class="custom-toggler-icon"><i class="bi bi-grid-fill fs-3 text-danger"></i></span>
        </button>

        <div class="collapse navbar-collapse" id="navbarNav">
            <ul class="navbar-nav me-auto align-items-center">
                <li class="nav-item">
                    <a href="index.jsp" class="nav-link px-3 fw-medium">Inicio</a>
                </li>
                <li class="nav-item">
                    <a href="libro.jsp" class="nav-link px-3 fw-medium">Libros</a>
                </li>
                
                <% if ("Docente".equals(rolUsuario)) { %>
                <li class="nav-item">
                    <a href="Usuarios.jsp" class="nav-link px-3 fw-medium">Usuarios</a>
                </li>
                <% } %>
                
                <li class="nav-item">
                    <a href="Prestamos.jsp" class="nav-link px-3 fw-medium">Préstamos</a>
                </li>

                <li class="nav-item">
                    <a href="quejas.jsp" class="nav-link px-3 fw-bold text-warning" style="opacity: 0.9;">
                        <i class="bi bi-chat-left-text-fill me-1"></i>Quejas
                    </a>
                </li>
            </ul>

            <ul class="navbar-nav align-items-center">
                
                <li class="nav-item me-3 d-none d-lg-block">
                    <button id="theme-toggle" title="Cambiar Tema" class="btn btn-link nav-link p-0">
                        <i class="bi bi-sun-fill fs-5" id="theme-icon"></i>
                    </button>
                </li>

                <li class="nav-item dropdown">
                    <a class="nav-link dropdown-toggle fw-bold text-danger" href="#" id="navbarDropdown" 
                       role="button" data-bs-toggle="dropdown" aria-expanded="false">
                        <%= (emailUsuario != null) ? emailUsuario : "Usuario" %>
                    </a>
                    <ul class="dropdown-menu dropdown-menu-end apple-dropdown border-0 shadow-lg" aria-labelledby="navbarDropdown">
                        <li><span class="dropdown-item-text small opacity-75">Rol: <%= rolUsuario %></span></li>
                        
                        <li class="d-lg-none">
                            <button id="theme-toggle-mobile" class="dropdown-item d-flex justify-content-between align-items-center" onclick="document.getElementById('theme-toggle').click()">
                                Cambiar Tema <i class="bi bi-circle-half"></i>
                            </button>
                        </li>

                        <li><hr class="dropdown-divider opacity-25"></li>
                        <li>
                            <a class="dropdown-item text-danger fw-bold d-flex justify-content-between align-items-center" href="LogoutServlet">
                                Cerrar Sesión <i class="bi bi-box-arrow-right"></i>
                            </a>
                        </li>
                    </ul>
                </li>
            </ul>
        </div>
    </div>
</nav>

<style>
    .navbar-apple {
        background: var(--nav-bg) !important;
        backdrop-filter: blur(20px) saturate(180%);
        -webkit-backdrop-filter: blur(20px) saturate(180%);
        border-bottom: 1px solid rgba(125,125,125,0.1);
        transition: background-color 0.5s ease;
    }

    .navbar-apple .nav-link {
        color: var(--text-main) !important;
        transition: 0.3s;
    }

    .navbar-apple .nav-link:hover {
        color: #ff3b30 !important;
        transform: translateY(-1px);
    }
    
    .navbar-brand {
        transition: 0.3s;
    }
    
    .navbar-brand:hover {
        transform: scale(1.05);
    }

    .apple-dropdown {
        background: var(--card-bg) !important;
        border-radius: 18px;
        padding: 10px;
        backdrop-filter: blur(15px);
        -webkit-backdrop-filter: blur(15px);
    }

    .apple-dropdown .dropdown-item {
        color: var(--text-main) !important;
        border-radius: 10px;
        transition: 0.2s;
        padding: 8px 16px;
    }

    .apple-dropdown .dropdown-item:hover {
        background-color: rgba(255, 59, 48, 0.1) !important;
        color: #ff3b30 !important;
    }

    .apple-dropdown .dropdown-item-text {
        color: var(--text-main) !important;
    }
    
    #theme-toggle {
        cursor: pointer;
        color: var(--text-main) !important;
        transition: 0.3s;
        text-decoration: none;
    }
    
    #theme-toggle:hover {
        color: #ff3b30 !important;
        transform: scale(1.1) rotate(15deg);
    }
</style>