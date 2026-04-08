<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Acceso Seguro - Biblioteca Uniboyaca</title>

        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-sRIl4kxILFvY47J16cr9ZwB07vP4J8+LH7qKQnuqkuIAvNWLzeN8tE5YBujZqJLB" crossorigin="anonymous">
        <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">

        <style>
            :root {
                --brand-red: #ff3b30;
                --brand-red-hover: #d72c21;
                --apple-bg: #f5f5f7;
                --card-bg: rgba(255, 255, 255, 0.75);
                --text-main: #121212;
                --input-bg: rgba(0, 0, 0, 0.03);
                --input-placeholder: rgba(0, 0, 0, 0.4);
                --glass-border: rgba(125, 125, 125, 0.2);
            }

            body.dark-mode {
                --apple-bg: #0a0a0a;
                --card-bg: rgba(26, 26, 26, 0.85);
                --text-main: #f8f9fa;
                --input-bg: rgba(255, 255, 255, 0.05);
                --input-placeholder: rgba(255, 255, 255, 0.5);
                --glass-border: rgba(255, 255, 255, 0.1);
            }

            body {
                font-family: 'Inter', sans-serif;
                background: var(--apple-bg);
                color: var(--text-main);
                display: flex;
                align-items: center;
                justify-content: center;
                height: 100vh;
                margin: 0;
                transition: background 0.5s ease;
                overflow: hidden;
            }


            .text-adaptive {
                color: var(--text-main) !important;
                opacity: 0.7;
            }


            @keyframes fadeInUp {
                from {
                    opacity: 0;
                    transform: translateY(20px);
                }
                to {
                    opacity: 1;
                    transform: translateY(0);
                }
            }
            @keyframes cardScale {
                from {
                    transform: scale(0.95);
                    opacity: 0;
                }
                to {
                    transform: scale(1);
                    opacity: 1;
                }
            }

            .login-card {
                display: flex;
                width: 100%;
                max-width: 1000px;
                height: 650px;
                background: var(--card-bg);
                backdrop-filter: saturate(180%) blur(25px);
                -webkit-backdrop-filter: saturate(180%) blur(25px);
                border: 1px solid var(--glass-border);
                border-radius: 40px;
                overflow: hidden;
                box-shadow: 0 40px 100px rgba(0, 0, 0, 0.1);
                animation: cardScale 0.8s cubic-bezier(0.2, 0.8, 0.2, 1) forwards;
            }

            .left-panel {
                flex: 1.3;
                position: relative;
                background: url('https://images.unsplash.com/photo-1507842217343-583bb7270b66?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80') center/cover no-repeat;
                display: flex;
                align-items: center;
                justify-content: center;
            }

            .left-panel::before {
                content: '';
                position: absolute;
                inset: 0;
                background: linear-gradient(135deg, rgba(255, 59, 48, 0.8) 0%, rgba(20, 5, 5, 0.9) 100%);
                z-index: 1;
            }

            .left-content {
                position: relative;
                z-index: 2;
                color: white;
                text-align: center;
                padding: 40px;
            }
            .left-content h2 {
                font-size: 48px;
                font-weight: 800;
                letter-spacing: -0.04em;
                animation: fadeInUp 1s ease 0.2s forwards;
                opacity: 0;
                color: white !important;
            }
            .left-content p {
                font-size: 18px;
                opacity: 0.9;
                animation: fadeInUp 1s ease 0.4s forwards;
                opacity: 0;
                color: white !important;
            }

            .right-panel {
                flex: 1;
                padding: 60px;
                display: flex;
                flex-direction: column;
                justify-content: center;
                position: relative;
            }

            #theme-toggle {
                position: absolute;
                top: 30px;
                right: 30px;
                cursor: pointer;
                font-size: 1.4rem;
                opacity: 0.6;
                transition: 0.3s;
                color: var(--text-main);
            }
            #theme-toggle:hover {
                opacity: 1;
                transform: rotate(15deg);
            }

            .login-box {
                width: 100%;
                max-width: 340px;
                margin: 0 auto;
            }
            .login-box h3 {
                font-size: 34px;
                font-weight: 700;
                margin-bottom: 10px;
                color: var(--text-main);
            }

            .form-group-apple {
                position: relative;
                margin-bottom: 20px;
            }

            .form-group-apple input {
                width: 100%;
                padding: 16px 50px;
                border-radius: 18px;
                border: 1px solid rgba(125, 125, 125, 0.1);
                background: var(--input-bg);
                color: var(--text-main) !important;
                font-size: 16px;
                transition: all 0.3s;
            }
            input:-webkit-autofill,
            input:-webkit-autofill:hover,
            input:-webkit-autofill:focus,
            input:-webkit-autofill:active{
                -webkit-box-shadow: 0 0 0 30px var(--card-bg) inset !important;
                -webkit-text-fill-color: var(--text-main) !important;
                transition: background-color 5000s ease-in-out 0s;
            }

            .form-group-apple input::placeholder {
                color: var(--input-placeholder);
            }

            .form-group-apple input:focus {
                background: var(--card-bg);
                border-color: var(--brand-red);
                box-shadow: 0 0 0 4px rgba(255, 59, 48, 0.15);
                outline: none;
            }

            .form-group-apple i.bi-main {
                position: absolute;
                left: 20px;
                top: 50%;
                transform: translateY(-50%);
                color: var(--brand-red);
                font-size: 20px;
            }

            .toggle-password {
                position: absolute;
                right: 15px;
                top: 50%;
                transform: translateY(-50%);
                background: transparent;
                border: none;
                color: var(--text-main);
                opacity: 0.5;
                cursor: pointer;
            }

            .btn-red-custom {
                background: var(--brand-red);
                color: #ffffff;
                border-radius: 18px;
                padding: 16px;
                font-weight: 700;
                border: none;
                width: 100%;
                margin-top: 15px;
                transition: 0.3s;
                box-shadow: 0 10px 25px rgba(255, 59, 48, 0.25);
            }
            .btn-red-custom:hover {
                background: var(--brand-red-hover);
                transform: translateY(-2px);
                box-shadow: 0 15px 30px rgba(255, 59, 48, 0.35);
                color: #ffffff;
            }

            .text-danger-custom {
                color: var(--brand-red) !important;
            }

            .animate-item {
                opacity: 0;
                animation: fadeInUp 0.8s cubic-bezier(0.2, 0.8, 0.2, 1) forwards;
            }
            .delay-1 {
                animation-delay: 0.4s;
            }
            .delay-2 {
                animation-delay: 0.5s;
            }
            .delay-3 {
                animation-delay: 0.6s;
            }

            @media (max-width: 850px) {
                .login-card {
                    flex-direction: column;
                    height: auto;
                    max-width: 450px;
                    margin: 20px;
                }
                .left-panel {
                    padding: 80px 20px;
                }
                .right-panel {
                    padding: 40px 30px;
                }
            }
        </style>
    </head>
    <body class="dark-mode">

        <div class="login-card">
            <div class="left-panel">
                <div class="left-content">
                    <i class="bi bi-book-half mb-3" style="font-size: 60px;"></i>
                    <h2>Biblioteca<br>Uniboyaca</h2>
                    <p>Sistema integral de gestión de recursos y préstamos.</p>
                </div>
            </div>

            <div class="right-panel">
                <div id="theme-toggle" title="Cambiar Tema"><i class="bi bi-sun-fill" id="theme-icon"></i></div>

                <div class="login-box">
                    <h3 class="animate-item">Acceso</h3>
                    <p class="small mb-4 animate-item delay-1 text-adaptive">Ingresa tus credenciales institucionales.</p>


                    <% if (request.getAttribute("error") != null) {%>
                    <div class="alert alert-danger border-0 py-2 small animate-item" style="border-radius:15px; background: rgba(255, 59, 48, 0.1); color: var(--brand-red);">
                        <i class="bi bi-exclamation-triangle-fill me-2"></i> <%= request.getAttribute("error")%>
                    </div>
                    <% }%>

                    <form action="ValidarLogin" method="POST" class="needs-validation" novalidate>

                        <div class="form-group-apple animate-item delay-2">
                            <input type="email" name="txtCorreo" placeholder="Correo electrónico" required>
                            <i class="bi bi-envelope-fill bi-main"></i>
                        </div>

                        <div class="form-group-apple animate-item delay-3">
                            <input type="password" name="txtPassword" id="passwordField" placeholder="Contraseña" required>
                            <i class="bi bi-lock-fill bi-main"></i>
                            <button type="button" class="toggle-password" onclick="togglePassword()" title="Mostrar/Ocultar">
                                <i class="bi bi-eye" id="eyeIcon"></i>
                            </button>
                        </div>

                        <div class="d-flex justify-content-between mb-4 animate-item delay-3">
                            <div class="form-check">
                                <input class="form-check-input" type="checkbox" id="rem">
                                <label class="form-check-label small text-adaptive" for="rem">Recordar sesión</label>
                            </div>
                            <a href="#" class="small text-danger-custom text-decoration-none fw-bold">¿Olvidaste tu clave?</a>
                        </div>

                        <button type="submit" class="btn-red-custom animate-item delay-3">Iniciar Sesión</button>
                    </form>

                    <div class="text-center mt-5 animate-item delay-3">
                        <p class="small text-adaptive">
                            ¿Problemas con tu cuenta? <br> Contacta al administrador o docente.
                        </p>
                    </div>
                </div>
            </div>
        </div>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/js/bootstrap.bundle.min.js"></script>
        <script>
                                const body = document.body;
                                const themeIcon = document.getElementById('theme-icon');
                                const themeToggle = document.getElementById('theme-toggle');

                                if (localStorage.getItem('theme') === 'light') {
                                    body.classList.remove('dark-mode');
                                    themeIcon.classList.replace('bi-sun-fill', 'bi-moon-stars-fill');
                                }

                                themeToggle.addEventListener('click', () => {
                                    body.classList.toggle('dark-mode');
                                    if (body.classList.contains('dark-mode')) {
                                        themeIcon.classList.replace('bi-moon-stars-fill', 'bi-sun-fill');
                                        localStorage.setItem('theme', 'dark');
                                    } else {
                                        themeIcon.classList.replace('bi-sun-fill', 'bi-moon-stars-fill');
                                        localStorage.setItem('theme', 'light');
                                    }
                                });

                                function togglePassword() {
                                    const field = document.getElementById('passwordField');
                                    const icon = document.getElementById('eyeIcon');
                                    if (field.type === 'password') {
                                        field.type = 'text';
                                        icon.classList.replace('bi-eye', 'bi-eye-slash');
                                    } else {
                                        field.type = 'password';
                                        icon.classList.replace('bi-eye-slash', 'bi-eye');
                                    }
                                }
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