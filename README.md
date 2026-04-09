# 📚 Biblioteca UniBoyacá

## 📝 Título del Proyecto e Introducción
**Sistema de Gestión Bibliotecaria Web**

El sistema **Biblioteca UniBoyacá** es una aplicación web robusta desarrollada en Java, diseñada para digitalizar y gestionar de manera eficiente los procesos internos de una biblioteca universitaria. 

Su propósito fundamental es optimizar el control y seguimiento de los recursos bibliográficos, ofreciendo una interfaz intuitiva para la administración de libros, usuarios y el flujo de préstamos. Gracias a la centralización de datos, el sistema elimina la duplicidad de información y mejora la precisión en el seguimiento de los materiales.

## 🚦 Estado del Proyecto
![Estado](https://img.shields.io/badge/Estado-Terminado-green)
El proyecto se encuentra funcional y listo para despliegue, cubriendo los módulos principales de administración y atención al usuario.

## ⚙️ Instrucciones de Instalación

### Requisitos Previos
* **Java JDK 8** o superior.
* **Apache NetBeans IDE** (o cualquier IDE compatible con Maven).
* **Apache Tomcat 9.0+** configurado como servidor de aplicaciones.
* **MySQL / MariaDB** para el almacenamiento de datos.

### Pasos para configurar el entorno
1. **Clonación/Extracción:** Descarga y extrae la carpeta del proyecto en tu espacio de trabajo.
2. **Importación en IDE:**
   * Abre NetBeans.
   * Ve a `File` > `Open Project` y selecciona la carpeta del proyecto.
3. **Configuración de la Base de Datos:**
   * Abre tu gestor de base de datos (phpMyAdmin o Workbench).
   * Crea una base de datos llamada `biblioteca`.
   * Importa el archivo `bibliotecauniboyaca final.sql` incluido en la raíz.
4. **Enlace de Datos:**
   * Localiza el archivo `src/main/java/co/edu/uniboyaca/biblioteca/util/Conexion.java`.
   * Verifica que las credenciales (usuario y contraseña) coincidan con las de tu servidor local.

## 📖 Guía de Uso

### Interacción con el Sistema
Una vez ejecutado el proyecto en el servidor Tomcat:
* **Autenticación:** Inicia sesión para acceder a las funcionalidades protegidas.
* **Catálogo:** Navega y consulta la disponibilidad de libros en tiempo real.
* **Procesos:** Registra préstamos y devoluciones de manera ágil.
* **Administración:** Gestiona el registro de nuevos títulos, control de multas y el buzón de quejas.

## 🚀 Tecnologías Utilizadas
* **Lenguaje:** Java (JSP y Servlets).
* **Base de Datos:** MySQL / MariaDB.
* **Gestor de Dependencias:** Maven.
* **Servidor de Aplicaciones:** Apache Tomcat.
* **Frontend:** HTML, CSS y JavaScript.

## 🤝 Contribución
Para colaborar en este proyecto académico:
1. Realiza un Fork del repositorio.
2. Crea una rama para tu mejora.
3. Envía un Pull Request describiendo los cambios realizados.

## 📄 Licencia
Este proyecto ha sido desarrollado bajo una licencia de **Uso Educativo / Académico**.

## 👨‍💻 Autores / Contacto
* **Desarrolladores:** Jhon Ovallos, Johan Salazar, Angel Poveda, Mariana Gonzalez - Aprendices SENA - Análisis y Desarrollo de Software (ADSO).
* **Ubicación:** Sogamoso, Boyacá, Colombia.