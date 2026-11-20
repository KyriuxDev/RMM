USE `rmm`;

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

SELECT u.`id_usuario`, u.`matricula`, u.`nombre`, u.`correo`, r.`nombre` AS rol, u.`esta_activo`
  FROM `usuario` u JOIN `rol` r ON r.`id_rol` = u.`id_rol`
 ORDER BY u.`id_usuario`;
