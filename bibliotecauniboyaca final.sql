-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 08-04-2026 a las 14:15:04
-- Versión del servidor: 10.4.32-MariaDB
-- Versión de PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `bibliotecauniboyaca`
--
CREATE DATABASE IF NOT EXISTS `bibliotecauniboyaca` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE `bibliotecauniboyaca`;

DELIMITER $$
--
-- Procedimientos
--
DROP PROCEDURE IF EXISTS `sp_finalizar_prestamo`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_finalizar_prestamo` (IN `p_id_prestamo` INT)   BEGIN
    DECLARE v_id_libro INT;
    SELECT id_libro INTO v_id_libro FROM prestamos WHERE id_prestamo = p_id_prestamo;
    
    UPDATE prestamos SET estado = 'Devuelto', fecha_devolucion_real = CURDATE() 
    WHERE id_prestamo = p_id_prestamo;
    
    UPDATE libros SET stock = stock + 1 WHERE id_libro = v_id_libro;
    SELECT 'Libro devuelto y stock actualizado' AS mensaje;
END$$

DROP PROCEDURE IF EXISTS `sp_generar_multa`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_generar_multa` (IN `p_id_prestamo` INT, IN `p_monto` DECIMAL(10,2))   BEGIN
    DECLARE v_id_usuario INT;
    SELECT id_usuario INTO v_id_usuario FROM prestamos WHERE id_prestamo = p_id_prestamo;
    
    INSERT INTO multas (id_prestamo, id_usuario, monto, estado_pago)
    VALUES (p_id_prestamo, v_id_usuario, p_monto, 0);
    SELECT 'Multa generada correctamente' AS mensaje;
END$$

DROP PROCEDURE IF EXISTS `sp_registrar_prestamo`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_registrar_prestamo` (IN `p_id_libro` INT, IN `p_id_usuario` INT, IN `p_dias_prestamo` INT)   BEGIN
    DECLARE v_stock INT;
    SELECT stock INTO v_stock FROM libros WHERE id_libro = p_id_libro;
    
    IF v_stock > 0 THEN
        INSERT INTO prestamos (id_libro, id_usuario, fecha_salida, fecha_devolucion_esperada, estado)
        VALUES (p_id_libro, p_id_usuario, CURDATE(), DATE_ADD(CURDATE(), INTERVAL p_dias_prestamo DAY), 'Activo');
        
        UPDATE libros SET stock = stock - 1 WHERE id_libro = p_id_libro;
        SELECT 'Prestamo registrado exitosamente' AS mensaje;
    ELSE
        SELECT 'Error: El libro no tiene stock disponible' AS mensaje;
    END IF;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `auditoria_libros`
--

DROP TABLE IF EXISTS `auditoria_libros`;
CREATE TABLE `auditoria_libros` (
  `id_log` int(11) NOT NULL,
  `id_libro` int(11) DEFAULT NULL,
  `accion` varchar(100) DEFAULT NULL,
  `fecha_movimiento` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `auditoria_libros`
--

INSERT INTO `auditoria_libros` (`id_log`, `id_libro`, `accion`, `fecha_movimiento`) VALUES(1, 2, 'Stock actualizado de 10 a 11', '2026-04-08 12:02:16');
INSERT INTO `auditoria_libros` (`id_log`, `id_libro`, `accion`, `fecha_movimiento`) VALUES(2, 2, 'Stock actualizado de 11 a 10', '2026-04-08 12:04:40');
INSERT INTO `auditoria_libros` (`id_log`, `id_libro`, `accion`, `fecha_movimiento`) VALUES(3, 2, 'Stock actualizado de 10 a 9', '2026-04-08 12:05:40');
INSERT INTO `auditoria_libros` (`id_log`, `id_libro`, `accion`, `fecha_movimiento`) VALUES(4, 2, 'Stock actualizado de 9 a 10', '2026-04-08 12:07:51');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `autores`
--

DROP TABLE IF EXISTS `autores`;
CREATE TABLE `autores` (
  `id_autor` int(11) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `nacionalidad` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `autores`
--

INSERT INTO `autores` (`id_autor`, `nombre`, `nacionalidad`) VALUES(1, 'Gabriel Garcia Marquez', 'Colombiana');
INSERT INTO `autores` (`id_autor`, `nombre`, `nacionalidad`) VALUES(2, 'Miguel de Cervantes', 'Española');
INSERT INTO `autores` (`id_autor`, `nombre`, `nacionalidad`) VALUES(3, 'George Orwell', 'Britanica');
INSERT INTO `autores` (`id_autor`, `nombre`, `nacionalidad`) VALUES(4, 'Franz Kafka', 'Checa');
INSERT INTO `autores` (`id_autor`, `nombre`, `nacionalidad`) VALUES(5, 'Antoine de Saint-Exupéry', 'Francesa');
INSERT INTO `autores` (`id_autor`, `nombre`, `nacionalidad`) VALUES(6, 'Stephen Hawking', 'Britanica');
INSERT INTO `autores` (`id_autor`, `nombre`, `nacionalidad`) VALUES(7, 'Carl Sagan', 'Estadounidense');
INSERT INTO `autores` (`id_autor`, `nombre`, `nacionalidad`) VALUES(8, 'Julio Cortazar', 'Argentina');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `categorias`
--

DROP TABLE IF EXISTS `categorias`;
CREATE TABLE `categorias` (
  `id_categoria` int(11) NOT NULL,
  `nombre_categoria` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `categorias`
--

INSERT INTO `categorias` (`id_categoria`, `nombre_categoria`) VALUES(1, 'Literatura Clasica');
INSERT INTO `categorias` (`id_categoria`, `nombre_categoria`) VALUES(2, 'Ciencia Ficcion');
INSERT INTO `categorias` (`id_categoria`, `nombre_categoria`) VALUES(3, 'Ciencia y Divulgacion');
INSERT INTO `categorias` (`id_categoria`, `nombre_categoria`) VALUES(4, 'Realismo Magico');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `editoriales`
--

DROP TABLE IF EXISTS `editoriales`;
CREATE TABLE `editoriales` (
  `id_editorial` int(11) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `pais` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `editoriales`
--

INSERT INTO `editoriales` (`id_editorial`, `nombre`, `pais`) VALUES(1, 'Alfaguara', 'España');
INSERT INTO `editoriales` (`id_editorial`, `nombre`, `pais`) VALUES(2, 'Planeta', 'Mexico');
INSERT INTO `editoriales` (`id_editorial`, `nombre`, `pais`) VALUES(3, 'Penguin Random House', 'EEUU');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `libros`
--

DROP TABLE IF EXISTS `libros`;
CREATE TABLE `libros` (
  `id_libro` int(11) NOT NULL,
  `titulo` varchar(150) NOT NULL,
  `isbn` varchar(20) DEFAULT NULL,
  `id_autor` int(11) DEFAULT NULL,
  `id_categoria` int(11) DEFAULT NULL,
  `stock` int(11) DEFAULT 5,
  `id_editorial` int(11) DEFAULT NULL,
  `url_pdf` varchar(255) DEFAULT NULL,
  `url_img` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `libros`
--

INSERT INTO `libros` (`id_libro`, `titulo`, `isbn`, `id_autor`, `id_categoria`, `stock`, `id_editorial`, `url_pdf`, `url_img`) VALUES(1, 'Cien años de soledad', '978-001', 1, 4, 15, 2, '1775648231269_pdf_Cien años de soledad.pdf', '1775647387236_img_cien-anos-de-soledad.jpg');
INSERT INTO `libros` (`id_libro`, `titulo`, `isbn`, `id_autor`, `id_categoria`, `stock`, `id_editorial`, `url_pdf`, `url_img`) VALUES(2, 'Don Quijote de la Mancha', '978-002', 2, 1, 10, 1, NULL, '1775647694490_img_122858226.png');
INSERT INTO `libros` (`id_libro`, `titulo`, `isbn`, `id_autor`, `id_categoria`, `stock`, `id_editorial`, `url_pdf`, `url_img`) VALUES(3, '1984', '978-003', 3, 2, 20, 3, NULL, '1775647798538_img_67c9014aec833f3b2ef2952e6e6cd56a.png');
INSERT INTO `libros` (`id_libro`, `titulo`, `isbn`, `id_autor`, `id_categoria`, `stock`, `id_editorial`, `url_pdf`, `url_img`) VALUES(4, 'La Metamorfosis', '978-004', 4, 1, 12, 1, '1775648247323_pdf_La metamorfosis.pdf', '1775647910268_img_LA-METAMORFOSIS1.png');
INSERT INTO `libros` (`id_libro`, `titulo`, `isbn`, `id_autor`, `id_categoria`, `stock`, `id_editorial`, `url_pdf`, `url_img`) VALUES(5, 'El Principito', '978-005', 5, 1, 25, 3, '1775648262208_pdf_el principito.pdf', '1775647944240_img_71AVK5VIAzL._AC_UF1000,1000_QL80.png');
INSERT INTO `libros` (`id_libro`, `titulo`, `isbn`, `id_autor`, `id_categoria`, `stock`, `id_editorial`, `url_pdf`, `url_img`) VALUES(6, 'Breve historia del tiempo', '978-006', 6, 3, 10, 3, NULL, '1775648006273_img_Stephen-Hawking-Breve-historia-d.png');
INSERT INTO `libros` (`id_libro`, `titulo`, `isbn`, `id_autor`, `id_categoria`, `stock`, `id_editorial`, `url_pdf`, `url_img`) VALUES(7, 'Cosmos', '978-007', 7, 3, 15, 2, NULL, '1775648054786_img_b64396bfa3dff8754439f8127768507c.png');
INSERT INTO `libros` (`id_libro`, `titulo`, `isbn`, `id_autor`, `id_categoria`, `stock`, `id_editorial`, `url_pdf`, `url_img`) VALUES(8, 'Rayuela', '978-008', 8, 4, 8, 1, NULL, '1775648086992_img_905322d10841b36aa311dbd5c90d92ed.png');

--
-- Disparadores `libros`
--
DROP TRIGGER IF EXISTS `tr_auditoria_stock`;
DELIMITER $$
CREATE TRIGGER `tr_auditoria_stock` AFTER UPDATE ON `libros` FOR EACH ROW BEGIN
    IF OLD.stock <> NEW.stock THEN
        INSERT INTO auditoria_libros (id_libro, accion) 
        VALUES (NEW.id_libro, CONCAT('Stock actualizado de ', OLD.stock, ' a ', NEW.stock));
    END IF;
END
$$
DELIMITER ;
DROP TRIGGER IF EXISTS `tr_despues_insertar_libro`;
DELIMITER $$
CREATE TRIGGER `tr_despues_insertar_libro` AFTER INSERT ON `libros` FOR EACH ROW BEGIN
    INSERT INTO auditoria_libros (id_libro, accion) 
    VALUES (NEW.id_libro, CONCAT('Nuevo libro registrado: ', NEW.titulo));
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `multas`
--

DROP TABLE IF EXISTS `multas`;
CREATE TABLE `multas` (
  `id_multa` int(11) NOT NULL,
  `id_prestamo` int(11) DEFAULT NULL,
  `id_usuario` int(11) DEFAULT NULL,
  `monto` decimal(10,2) NOT NULL,
  `estado_pago` tinyint(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `multas`
--

INSERT INTO `multas` (`id_multa`, `id_prestamo`, `id_usuario`, `monto`, `estado_pago`) VALUES(1, 4, 2, 50000.00, 1);
INSERT INTO `multas` (`id_multa`, `id_prestamo`, `id_usuario`, `monto`, `estado_pago`) VALUES(2, 4, 2, 10000.00, 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `prestamos`
--

DROP TABLE IF EXISTS `prestamos`;
CREATE TABLE `prestamos` (
  `id_prestamo` int(11) NOT NULL,
  `id_libro` int(11) DEFAULT NULL,
  `id_usuario` int(11) DEFAULT NULL,
  `fecha_salida` date DEFAULT curdate(),
  `fecha_devolucion_esperada` date DEFAULT NULL,
  `fecha_devolucion_real` date DEFAULT NULL,
  `estado` enum('Activo','Devuelto') DEFAULT 'Activo'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `prestamos`
--

INSERT INTO `prestamos` (`id_prestamo`, `id_libro`, `id_usuario`, `fecha_salida`, `fecha_devolucion_esperada`, `fecha_devolucion_real`, `estado`) VALUES(1, 1, 3, '2026-04-08', '2026-04-15', NULL, 'Activo');
INSERT INTO `prestamos` (`id_prestamo`, `id_libro`, `id_usuario`, `fecha_salida`, `fecha_devolucion_esperada`, `fecha_devolucion_real`, `estado`) VALUES(2, 2, 2, '2026-04-08', '2026-04-13', '2026-04-08', 'Devuelto');
INSERT INTO `prestamos` (`id_prestamo`, `id_libro`, `id_usuario`, `fecha_salida`, `fecha_devolucion_esperada`, `fecha_devolucion_real`, `estado`) VALUES(3, 2, 2, '2026-04-08', '2026-04-17', NULL, 'Activo');
INSERT INTO `prestamos` (`id_prestamo`, `id_libro`, `id_usuario`, `fecha_salida`, `fecha_devolucion_esperada`, `fecha_devolucion_real`, `estado`) VALUES(4, 2, 2, '2026-04-08', '2026-04-08', '2026-04-08', 'Devuelto');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `quejas`
--

DROP TABLE IF EXISTS `quejas`;
CREATE TABLE `quejas` (
  `id` int(11) NOT NULL,
  `nombre_solicitante` varchar(100) NOT NULL,
  `correo_solicitante` varchar(100) NOT NULL,
  `tipo_solicitud` varchar(50) NOT NULL,
  `asunto` varchar(150) NOT NULL,
  `descripcion` text NOT NULL,
  `estado` varchar(50) DEFAULT 'Pendiente',
  `respuesta` text DEFAULT NULL,
  `fecha_radicado` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `quejas`
--

INSERT INTO `quejas` (`id`, `nombre_solicitante`, `correo_solicitante`, `tipo_solicitud`, `asunto`, `descripcion`, `estado`, `respuesta`, `fecha_radicado`) VALUES(1, 'Valentina Gomez', 'valentina.gomez@uniboyaca.edu.co', 'Queja', 'Error acceso plataforma ProQuest', 'No puedo ingresar a la base de datos privada desde mi casa, sale error de credenciales.', 'Respondida', 'deje de invetar\r\n', '2026-04-08 11:45:20');
INSERT INTO `quejas` (`id`, `nombre_solicitante`, `correo_solicitante`, `tipo_solicitud`, `asunto`, `descripcion`, `estado`, `respuesta`, `fecha_radicado`) VALUES(2, 'Mariana Castaño', 'estudiante@uniboyaca.edu.co', 'Reclamo', 'Lentitud visor libros digitales', 'La plataforma privada de libros de ingenieria tarda mucho en cargar las paginas.', 'Pendiente', NULL, '2026-04-08 11:45:20');
INSERT INTO `quejas` (`id`, `nombre_solicitante`, `correo_solicitante`, `tipo_solicitud`, `asunto`, `descripcion`, `estado`, `respuesta`, `fecha_radicado`) VALUES(3, 'Carlos Ruiz', 'carlos.ruiz@uniboyaca.edu.co', 'Sugerencia', 'Integración de base de datos', 'Seria ideal que la plataforma privada se sincronice mejor con el correo institucional.', 'Pendiente', NULL, '2026-04-08 11:45:20');
INSERT INTO `quejas` (`id`, `nombre_solicitante`, `correo_solicitante`, `tipo_solicitud`, `asunto`, `descripcion`, `estado`, `respuesta`, `fecha_radicado`) VALUES(4, 'Andres Paz', 'andres.paz@uniboyaca.edu.co', 'Queja', 'Fallo en descarga de PDF', 'Al intentar descargar un capitulo de la plataforma privada, el archivo sale corrupto.', 'Pendiente', NULL, '2026-04-08 11:45:20');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuarios`
--

DROP TABLE IF EXISTS `usuarios`;
CREATE TABLE `usuarios` (
  `id_usuario` int(11) NOT NULL,
  `correo` varchar(100) DEFAULT NULL,
  `contrasena` varchar(255) NOT NULL,
  `tipo_usuario` enum('Estudiante','Docente') NOT NULL,
  `documento` varchar(50) DEFAULT NULL,
  `nombres` varchar(100) DEFAULT NULL,
  `apellidos` varchar(100) DEFAULT NULL,
  `telefono` varchar(20) DEFAULT NULL,
  `estado` varchar(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `usuarios`
--

INSERT INTO `usuarios` (`id_usuario`, `correo`, `contrasena`, `tipo_usuario`, `documento`, `nombres`, `apellidos`, `telefono`, `estado`) VALUES(1, 'admin@uniboyaca.edu.co', '12345', 'Docente', '80123456', 'Felipe', 'Nuñez', '3105554433', 'Activo');
INSERT INTO `usuarios` (`id_usuario`, `correo`, `contrasena`, `tipo_usuario`, `documento`, `nombres`, `apellidos`, `telefono`, `estado`) VALUES(2, 'estudiante@uniboyaca.edu.co', '12345', 'Estudiante', '1050987654', 'Mariana', 'Castaño', '3201112233', 'Activo');
INSERT INTO `usuarios` (`id_usuario`, `correo`, `contrasena`, `tipo_usuario`, `documento`, `nombres`, `apellidos`, `telefono`, `estado`) VALUES(3, 'valentina.gomez@uniboyaca.edu.co', '12345', 'Estudiante', '1090112233', 'Valentina', 'Gomez', '3114445566', 'Activo');
INSERT INTO `usuarios` (`id_usuario`, `correo`, `contrasena`, `tipo_usuario`, `documento`, `nombres`, `apellidos`, `telefono`, `estado`) VALUES(4, 'carlos.ruiz@uniboyaca.edu.co', '12345', 'Docente', '46112233', 'Carlos', 'Ruiz', '3009990011', 'Activo');

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vw_catalogo_detallado`
-- (Véase abajo para la vista actual)
--
DROP VIEW IF EXISTS `vw_catalogo_detallado`;
CREATE TABLE `vw_catalogo_detallado` (
`id_libro` int(11)
,`titulo` varchar(150)
,`isbn` varchar(20)
,`autor` varchar(100)
,`categoria` varchar(50)
,`editorial` varchar(100)
,`stock` int(11)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vw_prestamos_vigentes`
-- (Véase abajo para la vista actual)
--
DROP VIEW IF EXISTS `vw_prestamos_vigentes`;
CREATE TABLE `vw_prestamos_vigentes` (
`id_prestamo` int(11)
,`usuario` varchar(100)
,`libro` varchar(150)
,`fecha_salida` date
,`fecha_devolucion_esperada` date
);

-- --------------------------------------------------------

--
-- Estructura para la vista `vw_catalogo_detallado`
--
DROP TABLE IF EXISTS `vw_catalogo_detallado`;

DROP VIEW IF EXISTS `vw_catalogo_detallado`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vw_catalogo_detallado`  AS SELECT `l`.`id_libro` AS `id_libro`, `l`.`titulo` AS `titulo`, `l`.`isbn` AS `isbn`, `a`.`nombre` AS `autor`, `c`.`nombre_categoria` AS `categoria`, `e`.`nombre` AS `editorial`, `l`.`stock` AS `stock` FROM (((`libros` `l` join `autores` `a` on(`l`.`id_autor` = `a`.`id_autor`)) join `categorias` `c` on(`l`.`id_categoria` = `c`.`id_categoria`)) left join `editoriales` `e` on(`l`.`id_editorial` = `e`.`id_editorial`)) ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vw_prestamos_vigentes`
--
DROP TABLE IF EXISTS `vw_prestamos_vigentes`;

DROP VIEW IF EXISTS `vw_prestamos_vigentes`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vw_prestamos_vigentes`  AS SELECT `p`.`id_prestamo` AS `id_prestamo`, `u`.`nombres` AS `usuario`, `l`.`titulo` AS `libro`, `p`.`fecha_salida` AS `fecha_salida`, `p`.`fecha_devolucion_esperada` AS `fecha_devolucion_esperada` FROM ((`prestamos` `p` join `usuarios` `u` on(`p`.`id_usuario` = `u`.`id_usuario`)) join `libros` `l` on(`p`.`id_libro` = `l`.`id_libro`)) WHERE `p`.`estado` = 'Activo' ;

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `auditoria_libros`
--
ALTER TABLE `auditoria_libros`
  ADD PRIMARY KEY (`id_log`);

--
-- Indices de la tabla `autores`
--
ALTER TABLE `autores`
  ADD PRIMARY KEY (`id_autor`);

--
-- Indices de la tabla `categorias`
--
ALTER TABLE `categorias`
  ADD PRIMARY KEY (`id_categoria`);

--
-- Indices de la tabla `editoriales`
--
ALTER TABLE `editoriales`
  ADD PRIMARY KEY (`id_editorial`);

--
-- Indices de la tabla `libros`
--
ALTER TABLE `libros`
  ADD PRIMARY KEY (`id_libro`),
  ADD UNIQUE KEY `isbn` (`isbn`),
  ADD KEY `fk_autor` (`id_autor`),
  ADD KEY `fk_categoria` (`id_categoria`),
  ADD KEY `fk_editorial` (`id_editorial`);

--
-- Indices de la tabla `multas`
--
ALTER TABLE `multas`
  ADD PRIMARY KEY (`id_multa`),
  ADD KEY `fk_prestamo_m` (`id_prestamo`);

--
-- Indices de la tabla `prestamos`
--
ALTER TABLE `prestamos`
  ADD PRIMARY KEY (`id_prestamo`),
  ADD KEY `fk_libro_p` (`id_libro`),
  ADD KEY `fk_usuario_p` (`id_usuario`);

--
-- Indices de la tabla `quejas`
--
ALTER TABLE `quejas`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `usuarios`
--
ALTER TABLE `usuarios`
  ADD PRIMARY KEY (`id_usuario`),
  ADD UNIQUE KEY `correo` (`correo`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `auditoria_libros`
--
ALTER TABLE `auditoria_libros`
  MODIFY `id_log` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT de la tabla `autores`
--
ALTER TABLE `autores`
  MODIFY `id_autor` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT de la tabla `categorias`
--
ALTER TABLE `categorias`
  MODIFY `id_categoria` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT de la tabla `editoriales`
--
ALTER TABLE `editoriales`
  MODIFY `id_editorial` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `libros`
--
ALTER TABLE `libros`
  MODIFY `id_libro` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT de la tabla `multas`
--
ALTER TABLE `multas`
  MODIFY `id_multa` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `prestamos`
--
ALTER TABLE `prestamos`
  MODIFY `id_prestamo` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT de la tabla `quejas`
--
ALTER TABLE `quejas`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT de la tabla `usuarios`
--
ALTER TABLE `usuarios`
  MODIFY `id_usuario` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `libros`
--
ALTER TABLE `libros`
  ADD CONSTRAINT `fk_autor` FOREIGN KEY (`id_autor`) REFERENCES `autores` (`id_autor`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_categoria` FOREIGN KEY (`id_categoria`) REFERENCES `categorias` (`id_categoria`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_editorial` FOREIGN KEY (`id_editorial`) REFERENCES `editoriales` (`id_editorial`);

--
-- Filtros para la tabla `multas`
--
ALTER TABLE `multas`
  ADD CONSTRAINT `fk_prestamo_m` FOREIGN KEY (`id_prestamo`) REFERENCES `prestamos` (`id_prestamo`) ON DELETE CASCADE;

--
-- Filtros para la tabla `prestamos`
--
ALTER TABLE `prestamos`
  ADD CONSTRAINT `fk_libro_p` FOREIGN KEY (`id_libro`) REFERENCES `libros` (`id_libro`),
  ADD CONSTRAINT `fk_usuario_p` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
