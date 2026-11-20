-- =====================================================================
-- RMM IMSS - Migración C4 (inicio de sesión, baja de equipos)
--
-- Se puede ejecutar más de una vez sin error.
-- Úsenla si ya tienen la base creada con rmm_base_completa.sql y no
-- quieren borrar los datos. Si van a crear la base desde cero, basta con
-- ejecutar rmm_base_completa.sql (ya trae estos cambios).
--
-- 1. usuario: intentos_fallidos y bloqueado_hasta (SD-00a: bloqueo de
--    15 minutos tras 3 intentos fallidos).
-- 2. equipo: fecha_baja y motivo_baja (SD-05c: baja lógica, PR-14
--    "Motivo de la baja").
-- 3. Usuario administrador inicial, si todavía no existe.
-- =====================================================================

USE `rmm`;

-- Se puede ejecutar varias veces: cada columna sólo se agrega si falta.
-- (Sin procedimientos ni DELIMITER, para que funcione en cualquier Workbench.)

SET @sql = IF((SELECT COUNT(*) FROM information_schema.COLUMNS
                WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'usuario' AND COLUMN_NAME = 'intentos_fallidos') = 0,
              'ALTER TABLE `usuario` ADD COLUMN `intentos_fallidos` tinyint unsigned NOT NULL DEFAULT 0 COMMENT ''Intentos de inicio de sesión fallidos seguidos'' AFTER `esta_activo`',
              'SELECT ''usuario.intentos_fallidos ya existe'' AS aviso');
PREPARE st FROM @sql;
EXECUTE st;
DEALLOCATE PREPARE st;

SET @sql = IF((SELECT COUNT(*) FROM information_schema.COLUMNS
                WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'usuario' AND COLUMN_NAME = 'bloqueado_hasta') = 0,
              'ALTER TABLE `usuario` ADD COLUMN `bloqueado_hasta` datetime DEFAULT NULL COMMENT ''Bloqueo temporal tras 3 intentos fallidos'' AFTER `intentos_fallidos`',
              'SELECT ''usuario.bloqueado_hasta ya existe'' AS aviso');
PREPARE st FROM @sql;
EXECUTE st;
DEALLOCATE PREPARE st;

SET @sql = IF((SELECT COUNT(*) FROM information_schema.COLUMNS
                WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'equipo' AND COLUMN_NAME = 'fecha_baja') = 0,
              'ALTER TABLE `equipo` ADD COLUMN `fecha_baja` datetime DEFAULT NULL COMMENT ''Fecha de la baja lógica (estado INACTIVO)'' AFTER `esta_activo`',
              'SELECT ''equipo.fecha_baja ya existe'' AS aviso');
PREPARE st FROM @sql;
EXECUTE st;
DEALLOCATE PREPARE st;

SET @sql = IF((SELECT COUNT(*) FROM information_schema.COLUMNS
                WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'equipo' AND COLUMN_NAME = 'motivo_baja') = 0,
              'ALTER TABLE `equipo` ADD COLUMN `motivo_baja` varchar(255) DEFAULT NULL COMMENT ''Motivo capturado al dar de baja el equipo'' AFTER `fecha_baja`',
              'SELECT ''equipo.motivo_baja ya existe'' AS aviso');
PREPARE st FROM @sql;
EXECUTE st;
DEALLOCATE PREPARE st;


-- Usuario administrador (rol Jefe).
--   Matrícula: 999999999   Correo: admin.rmm@imss.gob.mx   Contraseña: admin
-- Si ya existe (por matrícula 999999999 o 99000001, o por el correo), sólo se
-- actualiza: matrícula, contraseña, rol Jefe, activo y sin bloqueo.
UPDATE `usuario` u
  JOIN `rol` r ON r.`nombre` = 'Jefe'
   SET u.`matricula` = '999999999',
       u.`contrasena_hash` = 'PBKDF2WithHmacSHA256:600000:VyeOmdGmjXd7WRWW4Xt5MJkENoRL/CQFLKRVjp/TxIE=:ycV9Ugm23tzjN3azGoOMQ8AZO/pxZVLSOmuMU0bv6js=',
       u.`id_rol` = r.`id_rol`,
       u.`esta_activo` = 1,
       u.`intentos_fallidos` = 0,
       u.`bloqueado_hasta` = NULL
 WHERE u.`matricula` IN ('999999999', '99000001') OR u.`correo` = 'admin.rmm@imss.gob.mx';

INSERT INTO `usuario` (`matricula`, `nombre`, `correo`, `contrasena_hash`, `esta_activo`, `id_rol`)
SELECT '999999999', 'Administrador RMM', 'admin.rmm@imss.gob.mx', 'PBKDF2WithHmacSHA256:600000:VyeOmdGmjXd7WRWW4Xt5MJkENoRL/CQFLKRVjp/TxIE=:ycV9Ugm23tzjN3azGoOMQ8AZO/pxZVLSOmuMU0bv6js=', 1, r.`id_rol`
  FROM `rol` r
 WHERE r.`nombre` = 'Jefe'
   AND NOT EXISTS (SELECT 1 FROM (SELECT * FROM `usuario`) x
                    WHERE x.`matricula` = '999999999' OR x.`correo` = 'admin.rmm@imss.gob.mx');

-- Verificación: deben salir las 4 columnas y el usuario 999999999
SELECT TABLE_NAME, COLUMN_NAME FROM information_schema.COLUMNS
 WHERE TABLE_SCHEMA = DATABASE()
   AND COLUMN_NAME IN ('intentos_fallidos', 'bloqueado_hasta', 'fecha_baja', 'motivo_baja');
SELECT `matricula`, `nombre`, `correo`, `intentos_fallidos`, `bloqueado_hasta` FROM `usuario`;
