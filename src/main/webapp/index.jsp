<%-- Proteccion de sesion: Debe ir al puro inicio del archivo --%>
<%
    if (session.getAttribute("nombreUsuario") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Obtenemos el rol para facilitar las validaciones abajo
    String rol = (String) session.getAttribute("tipoUsuario");
%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Biblioteca Uniboyaca - Inicio</title>

        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-sRIl4kxILFvY47J16cr9ZwB07vP4J8+LH7qKQnuqkuIAvNWLzeN8tE5YBujZqJLB" crossorigin="anonymous">
        <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">

        <style>
            :root {
                --brand-red: #ff3b30;
                --brand-red-hover: #d72c21;
                --apple-bg: #f5f5f7;
                --apple-dark: #0a0a0a;
                --nav-bg: rgba(255, 255, 255, 0.85);
                --card-bg: #ffffff;
                --text-main: #121212;
                --transition: all 0.6s cubic-bezier(0.16, 1, 0.3, 1);
            }

            /* Variables para Modo Oscuro */
            body.dark-mode {
                --apple-bg: #0a0a0a;
                --nav-bg: rgba(10, 10, 10, 0.9);
                --card-bg: #1a1a1a;
                --text-main: #f8f9fa;
            }

            body.dark-mode .text-dark {
                color: var(--text-main) !important;
            }

            body {
                font-family: 'Inter', sans-serif;
                background-color: var(--apple-bg);
                color: var(--text-main);
                transition: background-color 0.5s ease, color 0.5s ease;
                min-height: 100vh;
                overflow-x: hidden;
            }

            /* --- ANIMACIONES DE REVELACIÓN --- */
            .reveal {
                opacity: 0;
                transform: translateY(40px);
                transition: var(--transition);
            }
            .reveal.active {
                opacity: 1;
                transform: translateY(0);
            }
            .delay-1 {
                transition-delay: 0.2s;
            }
            .delay-2 {
                transition-delay: 0.4s;
            }
            .delay-3 {
                transition-delay: 0.6s;
            }

            /* --- HERO SECTION TIPO CHENG --- */
            .hero {
                min-height: 85vh;
                display: flex;
                align-items: center;
                padding: 100px 0 60px 0;
            }
            .hero h1 {
                font-size: clamp(3rem, 6vw, 4.5rem);
                font-weight: 800;
                letter-spacing: -2px;
                line-height: 1.1;
                margin-bottom: 20px;
            }
            .hero-image {
                border-radius: 3rem;
                box-shadow: 0 40px 100px rgba(0,0,0,0.15);
                width: 100%;
                height: 500px;
                object-fit: cover;
                transition: 0.5s ease;
            }
            .hero-image:hover {
                transform: scale(1.02);
            }

            .badge-apple {
                background-color: rgba(255, 59, 48, 0.1);
                border: 1px solid rgba(255, 59, 48, 0.3);
                color: var(--brand-red);
                padding: 8px 16px;
                border-radius: 980px;
                margin: 0 5px 10px 0;
                font-weight: 600;
                display: inline-block;
            }

            /* --- APPLE CARDS (MODULOS) --- */
            .apple-card {
                background: var(--card-bg);
                border-radius: 2.5rem;
                padding: 3.5rem 2.5rem;
                border: 1px solid rgba(125,125,125,0.05);
                height: 100%;
                transition: var(--transition);
                text-decoration: none;
                color: var(--text-main);
                display: flex;
                flex-direction: column;
                justify-content: space-between;
                position: relative;
                overflow: hidden;
            }

            .apple-card::before {
                content: '';
                position: absolute;
                top: 0;
                left: 0;
                right: 0;
                height: 6px;
                background: var(--brand-red);
                transform: scaleX(0);
                transform-origin: left;
                transition: transform 0.4s ease;
            }

            .apple-card:hover {
                transform: translateY(-10px);
                box-shadow: 0 25px 50px rgba(0,0,0,0.1);
            }

            .apple-card:hover::before {
                transform: scaleX(1);
            }

            .icon-box {
                width: 70px;
                height: 70px;
                background: rgba(255, 59, 48, 0.1);
                border-radius: 20px;
                display: flex;
                align-items: center;
                justify-content: center;
                font-size: 2rem;
                color: var(--brand-red);
                margin-bottom: 1.5rem;
            }

            .btn-red-custom {
                background-color: var(--brand-red);
                color: white;
                border-radius: 980px;
                padding: 14px 35px;
                font-weight: 600;
                border: none;
                transition: 0.3s;
                display: inline-block;
                text-decoration: none;
                text-align: center;
            }

            .btn-red-custom:hover {
                background-color: var(--brand-red-hover);
                color: white;
                transform: translateY(-2px);
                box-shadow: 0 10px 20px rgba(255, 59, 48, 0.25);
            }

            footer {
                background: var(--card-bg);
                padding: 60px 0;
                border-top: 1px solid rgba(125,125,125,0.1);
                margin-top: 80px;
            }
        </style>
    </head>

    <body class="dark-mode">

        <%@include file="includes/navbar.jsp" %>

        <section id="inicio" class="hero">
            <div class="container">
                <div class="row align-items-center g-5">
                    <div class="col-lg-6">
                        <div class="reveal active">
                            <span class="badge-apple">Plataforma Educativa</span>
                            <span class="badge-apple">Arquitectura DAO</span>
                        </div>
                        <h1 class="reveal active delay-1">Hola, <br><span class="text-danger"><%= session.getAttribute("nombreUsuario")%></span></h1>
                        <p class="lead fs-4 mb-5 opacity-75 reveal active delay-2">Gestiona y explora todos los recursos literarios e investigativos de la Universidad en un solo lugar.</p>

                        <div class="reveal active delay-3 d-flex align-items-center gap-3">
                            <a href="#modulos" class="btn-red-custom">Explorar Módulos</a>
                            <span class="opacity-50 fw-medium">Rol activo: <%= rol%></span>
                        </div>
                    </div>
                    <div class="col-lg-6">
                        <img src="https://images.unsplash.com/photo-1568667256549-094345857637?ixlib=rb-1.2.1&auto=format&fit=crop&w=1000&q=80" class="img-fluid hero-image reveal active delay-2 shadow-lg" alt="Biblioteca Moderna">
                    </div>
                </div>
            </div>
        </section>

        <main id="modulos" class="container py-5">
            <div class="text-center mb-5 reveal">
                <h2 class="display-5 fw-bold">Centro de Control</h2>
                <p class="opacity-50 fs-5">Selecciona el área que deseas administrar o consultar.</p>
            </div>

            <div class="row g-4 justify-content-center">

                <%-- MODULO DE LIBROS --%>
                <div class="col-lg-4 col-md-6 reveal delay-1">
                    <a href="libro.jsp" class="apple-card">
                        <div>
                            <div class="icon-box"><i class="bi bi-book-half"></i></div>
                            <h3 class="fw-bold mb-3">Gestión de Libros</h3>
                            <p class="opacity-75 mb-4 line-height-base">
                                <% if (rol.equals("Docente")) { %>
                                Control total del inventario. Registra nuevos autores, asigna categorías y administra editoriales.
                                <% } else { %>
                                Explora el catálogo completo y verifica la disponibilidad de los ejemplares en tiempo real.
                                <% } %>
                            </p>
                        </div>
                        <div class="mt-auto pt-4 border-top" style="border-color: rgba(125,125,125,0.1) !important;">
                            <span class="text-danger fw-bold d-flex align-items-center justify-content-between">
                                Ingresar al Módulo <i class="bi bi-arrow-right"></i>
                            </span>
                        </div>
                    </a>
                </div>

                <%-- MODULO DE USUARIOS: Solo visible para Docentes --%>
                <% if (rol.equals("Docente")) { %>
                <div class="col-lg-4 col-md-6 reveal delay-2">
                    <a href="Usuarios.jsp" class="apple-card">
                        <div>
                            <div class="icon-box"><i class="bi bi-people-fill"></i></div>
                            <h3 class="fw-bold mb-3">Directorio de Usuarios</h3>
                            <p class="opacity-75 mb-4">
                                Área administrativa para el registro, actualización y control de acceso de estudiantes y personal.
                            </p>
                        </div>
                        <div class="mt-auto pt-4 border-top" style="border-color: rgba(125,125,125,0.1) !important;">
                            <span class="text-danger fw-bold d-flex align-items-center justify-content-between">
                                Gestionar Personal <i class="bi bi-arrow-right"></i>
                            </span>
                        </div>
                    </a>
                </div>
                <% } %>

                <%-- MODULO DE PRESTAMOS --%>
                <div class="col-lg-4 col-md-6 reveal delay-3">
                    <a href="Prestamos.jsp" class="apple-card">
                        <div>
                            <div class="icon-box"><i class="bi bi-calendar-check-fill"></i></div>
                            <h3 class="fw-bold mb-3">Control de Préstamos</h3>
                            <p class="opacity-75 mb-4">
                                <% if (rol.equals("Docente")) { %>
                                Autoriza salidas, registra devoluciones y mantén un control detallado de multas y fechas.
                                <% } else { %>
                                Revisa tu historial de lectura, fechas de vencimiento y estado actual de tus préstamos.
                                <% }%>
                            </p>
                        </div>
                        <div class="mt-auto pt-4 border-top" style="border-color: rgba(125,125,125,0.1) !important;">
                            <span class="text-danger fw-bold d-flex align-items-center justify-content-between">
                                Ver Detalles <i class="bi bi-arrow-right"></i>
                            </span>
                        </div>
                    </a>
                </div>

                <%-- MODULO DE QUEJAS Y SUGERENCIAS (Dinámico por Rol) --%>
                <div class="col-lg-4 col-md-6 reveal delay-1">
                    <a href="quejas.jsp" class="apple-card">
                        <div>
                            <div class="icon-box" style="color: #0d6efd; background: rgba(13, 110, 253, 0.1);"><i class="bi bi-chat-left-text-fill"></i></div>
                            <h3 class="fw-bold mb-3">Buzón de PQRS</h3>
                            <p class="opacity-75 mb-4">
                                <% if (rol.equals("Docente")) { %>
                                Revise, gestione y responda a las peticiones, quejas y sugerencias enviadas por los estudiantes.
                                <% } else { %>
                                Radica nuevas solicitudes o revisa el estado y las respuestas de tus PQRS enviadas anteriormente.
                                <% } %>
                            </p>
                        </div>
                        <div class="mt-auto pt-4 border-top" style="border-color: rgba(125,125,125,0.1) !important;">
                            <span class="text-primary fw-bold d-flex align-items-center justify-content-between">
                                <% if (rol.equals("Docente")) { %>
                                Gestionar Buzón <i class="bi bi-arrow-right"></i>
                                <% } else { %>
                                Mis Quejas / Radicar <i class="bi bi-arrow-right"></i>
                                <% }%>
                            </span>
                        </div>
                    </a>
                </div>

            </div>
        </main>

        <footer>
            <div class="container text-center reveal">
                <div class="mb-3">
                    <span class="fw-bold fs-4 text-danger"><i class="bi bi-book-half me-2"></i>Biblioteca Uniboyaca</span>
                </div>
                <p class="opacity-50 fw-medium mb-1">Sistema de control de la biblioteca de la universidad de uniboyaca</p>
                <p class="opacity-75 fw-bold small">Sogamoso, Boyacá - 2026</p>
            </div>
        </footer>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/js/bootstrap.bundle.min.js" integrity="sha384-FKyoEForCGlyvwx9Hj09JcYn3nv7wiPVlz7YYwJrWVcXK/BmnVDxM+D2scQbITxI" crossorigin="anonymous"></script>

        <script>
            // Lógica restaurada para escuchar el botón del navbar y aplicar el modo claro/oscuro
            const body = document.body;

            function applyTheme(isDark) {
                const themeIcon = document.getElementById('theme-icon');
                if (isDark) {
                    body.classList.add('dark-mode');
                    if (themeIcon)
                        themeIcon.classList.replace('bi-moon-stars-fill', 'bi-sun-fill');
                } else {
                    body.classList.remove('dark-mode');
                    if (themeIcon)
                        themeIcon.classList.replace('bi-sun-fill', 'bi-moon-stars-fill');
                }
            }

            // Verificar Storage al cargar la página
            if (localStorage.getItem('theme') === 'light') {
                applyTheme(false);
            } else {
                applyTheme(true); // Default es oscuro
            }

            // Delegación de eventos para capturar el clic aunque el botón esté en el navbar.jsp
            document.addEventListener('click', function (e) {
                // Busca si se hizo clic en el botón de tema o en su icono
                const target = e.target.closest('#theme-toggle, #theme-toggle-mobile');
                if (target) {
                    const isNowDark = !body.classList.contains('dark-mode');
                    localStorage.setItem('theme', isNowDark ? 'dark' : 'light');
                    applyTheme(isNowDark);
                }
            });

            // Lógica de Animaciones Reveal al hacer Scroll
            const observer = new IntersectionObserver((entries) => {
                entries.forEach(entry => {
                    if (entry.isIntersecting) {
                        entry.target.classList.add('active');
                    }
                });
            }, {threshold: 0.1});

            document.querySelectorAll('.reveal').forEach((el) => {
                if (!el.classList.contains('active')) {
                    observer.observe(el);
                }
            });
        </script>
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