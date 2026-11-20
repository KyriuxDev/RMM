-- =====================================================================
-- RMM IMSS - Datos de simulación (generado por scripts/generar_simulacion.py)
--
-- Llena el RMM como si estuviera funcionando, sobre las áreas reales del
-- catálogo: equipos con hardware, software y periféricos, su última
-- lectura de CPU / RAM / disco (y 24 h de historial en los que están en
-- línea), umbrales, alertas e incidencias.
--
-- Se puede ejecutar varias veces: primero borra lo simulado anterior.
-- Los equipos simulados se reconocen por su MAC 02:5E:xx:xx:xx:xx.
-- No toca los equipos que ustedes dieron de alta a mano.
--
-- Requiere la migración C4 (migracion_c4.sql) y al menos un usuario.
-- =====================================================================

USE `rmm`;
SET @ahora = NOW();

-- ---------- 1. Borrar la simulación anterior ----------
DELETE n FROM notificacion n JOIN alerta a ON a.id_alerta = n.id_alerta JOIN equipo e ON e.id_equipo = a.id_equipo
 WHERE e.direccion_mac LIKE '02:5E:%';
DELETE i FROM incidencia i JOIN equipo e ON e.id_equipo = i.id_equipo WHERE e.direccion_mac LIKE '02:5E:%';
DELETE a FROM alerta a JOIN equipo e ON e.id_equipo = a.id_equipo WHERE e.direccion_mac LIKE '02:5E:%';
DELETE s FROM almacenamiento s JOIN informe f ON f.id_informe = s.id_informe JOIN equipo e ON e.id_equipo = f.id_equipo
 WHERE e.direccion_mac LIKE '02:5E:%';
DELETE f FROM informe f JOIN equipo e ON e.id_equipo = f.id_equipo WHERE e.direccion_mac LIKE '02:5E:%';
DELETE x FROM software x JOIN equipo e ON e.id_equipo = x.id_equipo WHERE e.direccion_mac LIKE '02:5E:%';
DELETE x FROM periferico x JOIN equipo e ON e.id_equipo = x.id_equipo WHERE e.direccion_mac LIKE '02:5E:%';
DELETE x FROM sesion_monitoreo x JOIN equipo e ON e.id_equipo = x.id_equipo WHERE e.direccion_mac LIKE '02:5E:%';
DELETE h FROM hardware h JOIN equipo e ON e.id_equipo = h.id_equipo WHERE e.direccion_mac LIKE '02:5E:%';
DELETE FROM equipo WHERE direccion_mac LIKE '02:5E:%';

-- ---------- 2. Umbrales globales (si no existen) ----------
INSERT INTO umbral_alerta (tipo_recurso, valor_umbral, ambito, valor_ambito, activo)
SELECT t.recurso, t.valor, 'GLOBAL', NULL, 1
  FROM (SELECT 'CPU' AS recurso, 90 AS valor UNION ALL SELECT 'RAM', 90
        UNION ALL SELECT 'DISCO', 90 UNION ALL SELECT 'DESCONEXION', 30) t
 WHERE NOT EXISTS (SELECT 1 FROM umbral_alerta u WHERE u.tipo_recurso = t.recurso AND u.ambito = 'GLOBAL');

SET @u_cpu  = (SELECT MIN(id_umbral_alerta) FROM umbral_alerta WHERE tipo_recurso = 'CPU' AND ambito = 'GLOBAL');
SET @u_ram  = (SELECT MIN(id_umbral_alerta) FROM umbral_alerta WHERE tipo_recurso = 'RAM' AND ambito = 'GLOBAL');
SET @u_disc = (SELECT MIN(id_umbral_alerta) FROM umbral_alerta WHERE tipo_recurso = 'DISCO' AND ambito = 'GLOBAL');
SET @u_desc = (SELECT MIN(id_umbral_alerta) FROM umbral_alerta WHERE tipo_recurso = 'DESCONEXION' AND ambito = 'GLOBAL');

-- Usuarios para responsables y técnicos (los que haya; si no hay Auxiliar se usa cualquiera)
SET @n_usuarios = (SELECT COUNT(*) FROM usuario WHERE esta_activo = 1);

-- ---------- 3. Equipos (138) ----------
-- Si un área no existe en su base, ese equipo simplemente no se inserta.
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-HGZ1-PC001', '02:5E:0B:00:0D:01', '10.21.11.20', 'Windows 11 Pro', '24H2', 'ONLINE', @ahora - INTERVAL 37 SECOND, @ahora - INTERVAL 41 DAY, 'Primer piso', 1, NULL, NULL, a.id_area,
       IF(1 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 1), NULL) FROM area a WHERE a.id_area = 1;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-HGZ1-PC002', '02:5E:0B:25:1A:02', '10.21.11.21', 'Windows 10 Pro', '22H2', 'ONLINE', @ahora - INTERVAL 54 SECOND, @ahora - INTERVAL 52 DAY, 'Segundo piso', 1, NULL, NULL, a.id_area,
       IF(2 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 2), NULL) FROM area a WHERE a.id_area = 8;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-HGZ1-PC003', '02:5E:0B:4A:27:03', '10.21.11.22', 'Windows 10 Pro', '22H2', 'ONLINE', @ahora - INTERVAL 71 SECOND, @ahora - INTERVAL 63 DAY, 'Consultorio 4', 1, NULL, NULL, a.id_area,
       IF(3 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 3), NULL) FROM area a WHERE a.id_area = 15;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-HGZ1-PC004', '02:5E:0B:6F:34:04', '10.21.11.23', 'Ubuntu', '22.04 LTS', 'ONLINE', @ahora - INTERVAL 88 SECOND, @ahora - INTERVAL 74 DAY, 'Archivo', 1, NULL, NULL, a.id_area,
       IF(4 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 4), NULL) FROM area a WHERE a.id_area = 22;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-HGZ1-PC005', '02:5E:0B:94:41:05', '10.21.11.24', 'Windows 11 Pro', '23H2', 'ONLINE', @ahora - INTERVAL 105 SECOND, @ahora - INTERVAL 85 DAY, 'Recepción', 1, NULL, NULL, a.id_area,
       IF(0 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 0), NULL) FROM area a WHERE a.id_area = 29;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-HGZ1-PC006', '02:5E:0B:B9:4E:06', '10.21.11.25', 'Windows 11 Pro', '24H2', 'ONLINE', @ahora - INTERVAL 22 SECOND, @ahora - INTERVAL 96 DAY, 'Jefatura', 1, NULL, NULL, a.id_area,
       IF(1 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 1), NULL) FROM area a WHERE a.id_area = 36;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-HGZ1-PC007', '02:5E:0B:DE:5B:07', '10.21.11.26', 'Windows 10 Pro', '22H2', 'ONLINE', @ahora - INTERVAL 39 SECOND, @ahora - INTERVAL 107 DAY, 'Ventanilla', 1, NULL, NULL, a.id_area,
       IF(2 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 2), NULL) FROM area a WHERE a.id_area = 43;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-HGZ1-PC008', '02:5E:0B:03:68:08', '10.21.11.27', 'Windows 10 Pro', '22H2', 'ONLINE', @ahora - INTERVAL 56 SECOND, @ahora - INTERVAL 118 DAY, 'Sala de juntas', 1, NULL, NULL, a.id_area,
       IF(3 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 3), NULL) FROM area a WHERE a.id_area = 50;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-HGZ1-PC009', '02:5E:0B:28:75:09', '10.21.11.28', 'Ubuntu', '22.04 LTS', 'ONLINE', @ahora - INTERVAL 73 SECOND, @ahora - INTERVAL 129 DAY, 'Almacén', 1, NULL, NULL, a.id_area,
       IF(4 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 4), NULL) FROM area a WHERE a.id_area = 6;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-HGZ1-PC010', '02:5E:0B:4D:82:0A', '10.21.11.29', 'Windows 11 Pro', '23H2', 'ONLINE', @ahora - INTERVAL 90 SECOND, @ahora - INTERVAL 140 DAY, 'Planta baja', 1, NULL, NULL, a.id_area,
       IF(0 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 0), NULL) FROM area a WHERE a.id_area = 13;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-HGZ1-PC011', '02:5E:0B:72:8F:0B', '10.21.11.30', 'Windows 11 Pro', '24H2', 'ONLINE', @ahora - INTERVAL 107 SECOND, @ahora - INTERVAL 151 DAY, 'Primer piso', 1, NULL, NULL, a.id_area,
       IF(1 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 1), NULL) FROM area a WHERE a.id_area = 20;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-HGZ1-PC012', '02:5E:0B:97:9C:0C', '10.21.11.31', 'Windows 10 Pro', '22H2', 'ONLINE', @ahora - INTERVAL 24 SECOND, @ahora - INTERVAL 162 DAY, 'Segundo piso', 1, NULL, NULL, a.id_area,
       IF(2 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 2), NULL) FROM area a WHERE a.id_area = 27;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-HGZ1-PC013', '02:5E:0B:BC:A9:0D', '10.21.11.32', 'Windows 10 Pro', '22H2', 'ONLINE', @ahora - INTERVAL 41 SECOND, @ahora - INTERVAL 173 DAY, 'Consultorio 2', 1, NULL, NULL, a.id_area,
       IF(3 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 3), NULL) FROM area a WHERE a.id_area = 34;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-HGZ1-PC014', '02:5E:0B:E1:B6:0E', '10.21.11.33', 'Ubuntu', '22.04 LTS', 'OFFLINE', NULL, @ahora - INTERVAL 184 DAY, 'Archivo', 1, NULL, NULL, a.id_area,
       IF(4 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 4), NULL) FROM area a WHERE a.id_area = 41;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-HGZ1-PC015', '02:5E:0B:06:C3:0F', '10.21.11.34', 'Windows 11 Pro', '23H2', 'OFFLINE', @ahora - INTERVAL 50 HOUR, @ahora - INTERVAL 195 DAY, 'Recepción', 1, NULL, NULL, a.id_area,
       IF(0 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 0), NULL) FROM area a WHERE a.id_area = 48;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-HGZ1-PC016', '02:5E:0B:2B:D0:10', '10.21.11.35', 'Windows 11 Pro', '24H2', 'OFFLINE', @ahora - INTERVAL 120 HOUR, @ahora - INTERVAL 206 DAY, 'Jefatura', 1, NULL, NULL, a.id_area,
       IF(1 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 1), NULL) FROM area a WHERE a.id_area = 4;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-HGZ1-PC017', '02:5E:0B:50:DD:11', '10.21.11.36', 'Windows 10 Pro', '22H2', 'ALERTA', @ahora - INTERVAL 109 SECOND, @ahora - INTERVAL 217 DAY, 'Ventanilla', 1, NULL, NULL, a.id_area,
       IF(2 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 2), NULL) FROM area a WHERE a.id_area = 11;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-HGZ1-PC018', '02:5E:0B:75:EA:12', '10.21.11.37', 'Windows 10 Pro', '22H2', 'ALERTA', @ahora - INTERVAL 26 SECOND, @ahora - INTERVAL 228 DAY, 'Sala de juntas', 1, NULL, NULL, a.id_area,
       IF(3 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 3), NULL) FROM area a WHERE a.id_area = 18;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-HGZ1-PC019', '02:5E:0B:9A:F7:13', '10.21.11.38', 'Ubuntu', '22.04 LTS', 'INACTIVO', @ahora - INTERVAL 54 DAY, @ahora - INTERVAL 239 DAY, 'Almacén', 0, @ahora - INTERVAL 49 DAY, 'Equipo dañado sin reparación; reemplazado', a.id_area,
       IF(4 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 4), NULL) FROM area a WHERE a.id_area = 25;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-HGZ1-PC020', '02:5E:0B:BF:04:14', '10.21.11.39', 'Windows 11 Pro', '23H2', 'ONLINE', @ahora - INTERVAL 60 SECOND, @ahora - INTERVAL 250 DAY, 'Planta baja', 1, NULL, NULL, a.id_area,
       IF(0 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 0), NULL) FROM area a WHERE a.id_area = 32;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-HGZ1-PC021', '02:5E:0B:E4:11:15', '10.21.11.40', 'Windows 11 Pro', '24H2', 'ONLINE', @ahora - INTERVAL 77 SECOND, @ahora - INTERVAL 261 DAY, 'Primer piso', 1, NULL, NULL, a.id_area,
       IF(1 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 1), NULL) FROM area a WHERE a.id_area = 39;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-HGZ1-PC022', '02:5E:0B:09:1E:16', '10.21.11.41', 'Windows 10 Pro', '22H2', 'ONLINE', @ahora - INTERVAL 94 SECOND, @ahora - INTERVAL 272 DAY, 'Segundo piso', 1, NULL, NULL, a.id_area,
       IF(2 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 2), NULL) FROM area a WHERE a.id_area = 46;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-HGZ1-PC023', '02:5E:0B:2E:2B:17', '10.21.11.42', 'Windows 10 Pro', '22H2', 'ONLINE', @ahora - INTERVAL 111 SECOND, @ahora - INTERVAL 283 DAY, 'Consultorio 12', 1, NULL, NULL, a.id_area,
       IF(3 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 3), NULL) FROM area a WHERE a.id_area = 2;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-HGZ1-PC024', '02:5E:0B:53:38:18', '10.21.11.43', 'Ubuntu', '22.04 LTS', 'ONLINE', @ahora - INTERVAL 28 SECOND, @ahora - INTERVAL 294 DAY, 'Archivo', 1, NULL, NULL, a.id_area,
       IF(4 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 4), NULL) FROM area a WHERE a.id_area = 9;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-HGZ1-PC025', '02:5E:0B:78:45:19', '10.21.11.44', 'Windows 11 Pro', '23H2', 'ONLINE', @ahora - INTERVAL 45 SECOND, @ahora - INTERVAL 305 DAY, 'Recepción', 1, NULL, NULL, a.id_area,
       IF(0 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 0), NULL) FROM area a WHERE a.id_area = 16;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-HGZ1-PC026', '02:5E:0B:9D:52:1A', '10.21.11.45', 'Windows 11 Pro', '24H2', 'ONLINE', @ahora - INTERVAL 62 SECOND, @ahora - INTERVAL 316 DAY, 'Jefatura', 1, NULL, NULL, a.id_area,
       IF(1 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 1), NULL) FROM area a WHERE a.id_area = 23;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-HGZ1-PC027', '02:5E:0B:C2:5F:1B', '10.21.11.46', 'Windows 10 Pro', '22H2', 'ONLINE', @ahora - INTERVAL 79 SECOND, @ahora - INTERVAL 327 DAY, 'Ventanilla', 1, NULL, NULL, a.id_area,
       IF(2 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 2), NULL) FROM area a WHERE a.id_area = 30;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-HGZ1-PC028', '02:5E:0B:E7:6C:1C', '10.21.11.47', 'Windows 10 Pro', '22H2', 'ONLINE', @ahora - INTERVAL 96 SECOND, @ahora - INTERVAL 38 DAY, 'Sala de juntas', 1, NULL, NULL, a.id_area,
       IF(3 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 3), NULL) FROM area a WHERE a.id_area = 37;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-HGZ1-PC029', '02:5E:0B:0C:79:1D', '10.21.11.48', 'Ubuntu', '22.04 LTS', 'ONLINE', @ahora - INTERVAL 113 SECOND, @ahora - INTERVAL 49 DAY, 'Almacén', 1, NULL, NULL, a.id_area,
       IF(4 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 4), NULL) FROM area a WHERE a.id_area = 44;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-HGZ1-PC030', '02:5E:0B:31:86:1E', '10.21.11.49', 'Windows 11 Pro', '23H2', 'ONLINE', @ahora - INTERVAL 30 SECOND, @ahora - INTERVAL 60 DAY, 'Planta baja', 1, NULL, NULL, a.id_area,
       IF(0 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 0), NULL) FROM area a WHERE a.id_area = 51;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-HGZMF2-PC001', '02:5E:0D:00:93:1F', '10.21.13.20', 'Windows 11 Pro', '24H2', 'ONLINE', @ahora - INTERVAL 47 SECOND, @ahora - INTERVAL 71 DAY, 'Primer piso', 1, NULL, NULL, a.id_area,
       IF(1 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 1), NULL) FROM area a WHERE a.id_area = 82;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-HGZMF2-PC002', '02:5E:0D:25:A0:20', '10.21.13.21', 'Windows 10 Pro', '22H2', 'ONLINE', @ahora - INTERVAL 64 SECOND, @ahora - INTERVAL 82 DAY, 'Segundo piso', 1, NULL, NULL, a.id_area,
       IF(2 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 2), NULL) FROM area a WHERE a.id_area = 89;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-HGZMF2-PC003', '02:5E:0D:4A:AD:21', '10.21.13.22', 'Windows 10 Pro', '22H2', 'ONLINE', @ahora - INTERVAL 81 SECOND, @ahora - INTERVAL 93 DAY, 'Consultorio 10', 1, NULL, NULL, a.id_area,
       IF(3 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 3), NULL) FROM area a WHERE a.id_area = 96;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-HGZMF2-PC004', '02:5E:0D:6F:BA:22', '10.21.13.23', 'Ubuntu', '22.04 LTS', 'OFFLINE', @ahora - INTERVAL 120 HOUR, @ahora - INTERVAL 104 DAY, 'Archivo', 1, NULL, NULL, a.id_area,
       IF(4 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 4), NULL) FROM area a WHERE a.id_area = 103;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-HGZMF2-PC005', '02:5E:0D:94:C7:23', '10.21.13.24', 'Windows 11 Pro', '23H2', 'OFFLINE', NULL, @ahora - INTERVAL 115 DAY, 'Recepción', 1, NULL, NULL, a.id_area,
       IF(0 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 0), NULL) FROM area a WHERE a.id_area = 110;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-HGZMF2-PC006', '02:5E:0D:B9:D4:24', '10.21.13.25', 'Windows 11 Pro', '24H2', 'OFFLINE', @ahora - INTERVAL 3 HOUR, @ahora - INTERVAL 126 DAY, 'Jefatura', 1, NULL, NULL, a.id_area,
       IF(1 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 1), NULL) FROM area a WHERE a.id_area = 117;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-HGZMF2-PC007', '02:5E:0D:DE:E1:25', '10.21.13.26', 'Windows 10 Pro', '22H2', 'ALERTA', @ahora - INTERVAL 49 SECOND, @ahora - INTERVAL 137 DAY, 'Ventanilla', 1, NULL, NULL, a.id_area,
       IF(2 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 2), NULL) FROM area a WHERE a.id_area = 124;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-HGZMF2-PC008', '02:5E:0D:03:EE:26', '10.21.13.27', 'Windows 10 Pro', '22H2', 'ALERTA', @ahora - INTERVAL 66 SECOND, @ahora - INTERVAL 148 DAY, 'Sala de juntas', 1, NULL, NULL, a.id_area,
       IF(3 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 3), NULL) FROM area a WHERE a.id_area = 131;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-HGZMF2-PC009', '02:5E:0D:28:FB:27', '10.21.13.28', 'Ubuntu', '22.04 LTS', 'INACTIVO', @ahora - INTERVAL 54 DAY, @ahora - INTERVAL 159 DAY, 'Almacén', 0, @ahora - INTERVAL 49 DAY, 'Equipo dañado sin reparación; reemplazado', a.id_area,
       IF(4 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 4), NULL) FROM area a WHERE a.id_area = 138;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-HGZMF2-PC010', '02:5E:0D:4D:08:28', '10.21.13.29', 'Windows 11 Pro', '23H2', 'ONLINE', @ahora - INTERVAL 100 SECOND, @ahora - INTERVAL 170 DAY, 'Planta baja', 1, NULL, NULL, a.id_area,
       IF(0 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 0), NULL) FROM area a WHERE a.id_area = 86;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-HGZMF2-PC011', '02:5E:0D:72:15:29', '10.21.13.30', 'Windows 11 Pro', '24H2', 'ONLINE', @ahora - INTERVAL 117 SECOND, @ahora - INTERVAL 181 DAY, 'Primer piso', 1, NULL, NULL, a.id_area,
       IF(1 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 1), NULL) FROM area a WHERE a.id_area = 93;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-HGZMF2-PC012', '02:5E:0D:97:22:2A', '10.21.13.31', 'Windows 10 Pro', '22H2', 'ONLINE', @ahora - INTERVAL 34 SECOND, @ahora - INTERVAL 192 DAY, 'Segundo piso', 1, NULL, NULL, a.id_area,
       IF(2 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 2), NULL) FROM area a WHERE a.id_area = 100;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-HGZMF2-PC013', '02:5E:0D:BC:2F:2B', '10.21.13.32', 'Windows 10 Pro', '22H2', 'ONLINE', @ahora - INTERVAL 51 SECOND, @ahora - INTERVAL 203 DAY, 'Consultorio 8', 1, NULL, NULL, a.id_area,
       IF(3 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 3), NULL) FROM area a WHERE a.id_area = 107;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-HGZMF2-PC014', '02:5E:0D:E1:3C:2C', '10.21.13.33', 'Ubuntu', '22.04 LTS', 'ONLINE', @ahora - INTERVAL 68 SECOND, @ahora - INTERVAL 214 DAY, 'Archivo', 1, NULL, NULL, a.id_area,
       IF(4 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 4), NULL) FROM area a WHERE a.id_area = 114;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-HGZMF2-PC015', '02:5E:0D:06:49:2D', '10.21.13.34', 'Windows 11 Pro', '23H2', 'ONLINE', @ahora - INTERVAL 85 SECOND, @ahora - INTERVAL 225 DAY, 'Recepción', 1, NULL, NULL, a.id_area,
       IF(0 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 0), NULL) FROM area a WHERE a.id_area = 121;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-HGZMF2-PC016', '02:5E:0D:2B:56:2E', '10.21.13.35', 'Windows 11 Pro', '24H2', 'ONLINE', @ahora - INTERVAL 102 SECOND, @ahora - INTERVAL 236 DAY, 'Jefatura', 1, NULL, NULL, a.id_area,
       IF(1 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 1), NULL) FROM area a WHERE a.id_area = 128;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-HGZMF2-PC017', '02:5E:0D:50:63:2F', '10.21.13.36', 'Windows 10 Pro', '22H2', 'ONLINE', @ahora - INTERVAL 119 SECOND, @ahora - INTERVAL 247 DAY, 'Ventanilla', 1, NULL, NULL, a.id_area,
       IF(2 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 2), NULL) FROM area a WHERE a.id_area = 135;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-HGZMF2-PC018', '02:5E:0D:75:70:30', '10.21.13.37', 'Windows 10 Pro', '22H2', 'ONLINE', @ahora - INTERVAL 36 SECOND, @ahora - INTERVAL 258 DAY, 'Sala de juntas', 1, NULL, NULL, a.id_area,
       IF(3 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 3), NULL) FROM area a WHERE a.id_area = 83;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-HGZ3-PC001', '02:5E:0C:00:7D:31', '10.21.12.20', 'Ubuntu', '22.04 LTS', 'ONLINE', @ahora - INTERVAL 53 SECOND, @ahora - INTERVAL 269 DAY, 'Almacén', 1, NULL, NULL, a.id_area,
       IF(4 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 4), NULL) FROM area a WHERE a.id_area = 52;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-HGZ3-PC002', '02:5E:0C:25:8A:32', '10.21.12.21', 'Windows 11 Pro', '23H2', 'ONLINE', @ahora - INTERVAL 70 SECOND, @ahora - INTERVAL 280 DAY, 'Planta baja', 1, NULL, NULL, a.id_area,
       IF(0 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 0), NULL) FROM area a WHERE a.id_area = 59;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-HGZ3-PC003', '02:5E:0C:4A:97:33', '10.21.12.22', 'Windows 11 Pro', '24H2', 'ONLINE', @ahora - INTERVAL 87 SECOND, @ahora - INTERVAL 291 DAY, 'Primer piso', 1, NULL, NULL, a.id_area,
       IF(1 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 1), NULL) FROM area a WHERE a.id_area = 66;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-HGZ3-PC004', '02:5E:0C:6F:A4:34', '10.21.12.23', 'Windows 10 Pro', '22H2', 'ONLINE', @ahora - INTERVAL 104 SECOND, @ahora - INTERVAL 302 DAY, 'Segundo piso', 1, NULL, NULL, a.id_area,
       IF(2 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 2), NULL) FROM area a WHERE a.id_area = 73;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-HGZ3-PC005', '02:5E:0C:94:B1:35', '10.21.12.24', 'Windows 10 Pro', '22H2', 'ONLINE', @ahora - INTERVAL 21 SECOND, @ahora - INTERVAL 313 DAY, 'Consultorio 6', 1, NULL, NULL, a.id_area,
       IF(3 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 3), NULL) FROM area a WHERE a.id_area = 80;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-HGZ3-PC006', '02:5E:0C:B9:BE:36', '10.21.12.25', 'Ubuntu', '22.04 LTS', 'OFFLINE', @ahora - INTERVAL 3 HOUR, @ahora - INTERVAL 324 DAY, 'Archivo', 1, NULL, NULL, a.id_area,
       IF(4 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 4), NULL) FROM area a WHERE a.id_area = 57;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-HGZ3-PC007', '02:5E:0C:DE:CB:37', '10.21.12.26', 'Windows 11 Pro', '23H2', 'OFFLINE', @ahora - INTERVAL 9 HOUR, @ahora - INTERVAL 35 DAY, 'Recepción', 1, NULL, NULL, a.id_area,
       IF(0 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 0), NULL) FROM area a WHERE a.id_area = 64;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-HGZ3-PC008', '02:5E:0C:03:D8:38', '10.21.12.27', 'Windows 11 Pro', '24H2', 'OFFLINE', NULL, @ahora - INTERVAL 46 DAY, 'Jefatura', 1, NULL, NULL, a.id_area,
       IF(1 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 1), NULL) FROM area a WHERE a.id_area = 71;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-HGZ3-PC009', '02:5E:0C:28:E5:39', '10.21.12.28', 'Windows 10 Pro', '22H2', 'ALERTA', @ahora - INTERVAL 89 SECOND, @ahora - INTERVAL 57 DAY, 'Ventanilla', 1, NULL, NULL, a.id_area,
       IF(2 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 2), NULL) FROM area a WHERE a.id_area = 78;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-HGZ3-PC010', '02:5E:0C:4D:F2:3A', '10.21.12.29', 'Windows 10 Pro', '22H2', 'ALERTA', @ahora - INTERVAL 106 SECOND, @ahora - INTERVAL 68 DAY, 'Sala de juntas', 1, NULL, NULL, a.id_area,
       IF(3 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 3), NULL) FROM area a WHERE a.id_area = 55;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-HGZ3-PC011', '02:5E:0C:72:FF:3B', '10.21.12.30', 'Ubuntu', '22.04 LTS', 'INACTIVO', @ahora - INTERVAL 54 DAY, @ahora - INTERVAL 79 DAY, 'Almacén', 0, @ahora - INTERVAL 49 DAY, 'Equipo dañado sin reparación; reemplazado', a.id_area,
       IF(4 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 4), NULL) FROM area a WHERE a.id_area = 62;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-HGZ3-PC012', '02:5E:0C:97:0C:3C', '10.21.12.31', 'Windows 11 Pro', '23H2', 'ONLINE', @ahora - INTERVAL 40 SECOND, @ahora - INTERVAL 90 DAY, 'Planta baja', 1, NULL, NULL, a.id_area,
       IF(0 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 0), NULL) FROM area a WHERE a.id_area = 69;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-HGZ3-PC013', '02:5E:0C:BC:19:3D', '10.21.12.32', 'Windows 11 Pro', '24H2', 'ONLINE', @ahora - INTERVAL 57 SECOND, @ahora - INTERVAL 101 DAY, 'Primer piso', 1, NULL, NULL, a.id_area,
       IF(1 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 1), NULL) FROM area a WHERE a.id_area = 76;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-HGZ3-PC014', '02:5E:0C:E1:26:3E', '10.21.12.33', 'Windows 10 Pro', '22H2', 'ONLINE', @ahora - INTERVAL 74 SECOND, @ahora - INTERVAL 112 DAY, 'Segundo piso', 1, NULL, NULL, a.id_area,
       IF(2 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 2), NULL) FROM area a WHERE a.id_area = 53;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-HGZ3-PC015', '02:5E:0C:06:33:3F', '10.21.12.34', 'Windows 10 Pro', '22H2', 'ONLINE', @ahora - INTERVAL 91 SECOND, @ahora - INTERVAL 123 DAY, 'Consultorio 4', 1, NULL, NULL, a.id_area,
       IF(3 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 3), NULL) FROM area a WHERE a.id_area = 60;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-HGZ3-PC016', '02:5E:0C:2B:40:40', '10.21.12.35', 'Ubuntu', '22.04 LTS', 'ONLINE', @ahora - INTERVAL 108 SECOND, @ahora - INTERVAL 134 DAY, 'Archivo', 1, NULL, NULL, a.id_area,
       IF(4 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 4), NULL) FROM area a WHERE a.id_area = 67;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-HGSMF41-PC001', '02:5E:0F:00:4D:41', '10.21.15.20', 'Windows 11 Pro', '23H2', 'ONLINE', @ahora - INTERVAL 25 SECOND, @ahora - INTERVAL 145 DAY, 'Recepción', 1, NULL, NULL, a.id_area,
       IF(0 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 0), NULL) FROM area a WHERE a.id_area = 142;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-HGSMF41-PC002', '02:5E:0F:25:5A:42', '10.21.15.21', 'Windows 11 Pro', '24H2', 'ONLINE', @ahora - INTERVAL 42 SECOND, @ahora - INTERVAL 156 DAY, 'Jefatura', 1, NULL, NULL, a.id_area,
       IF(1 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 1), NULL) FROM area a WHERE a.id_area = 149;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-HGSMF41-PC003', '02:5E:0F:4A:67:43', '10.21.15.22', 'Windows 10 Pro', '22H2', 'ONLINE', @ahora - INTERVAL 59 SECOND, @ahora - INTERVAL 167 DAY, 'Ventanilla', 1, NULL, NULL, a.id_area,
       IF(2 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 2), NULL) FROM area a WHERE a.id_area = 156;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-HGSMF41-PC004', '02:5E:0F:6F:74:44', '10.21.15.23', 'Windows 10 Pro', '22H2', 'ONLINE', @ahora - INTERVAL 76 SECOND, @ahora - INTERVAL 178 DAY, 'Sala de juntas', 1, NULL, NULL, a.id_area,
       IF(3 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 3), NULL) FROM area a WHERE a.id_area = 163;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-HGSMF41-PC005', '02:5E:0F:94:81:45', '10.21.15.24', 'Ubuntu', '22.04 LTS', 'ONLINE', @ahora - INTERVAL 93 SECOND, @ahora - INTERVAL 189 DAY, 'Almacén', 1, NULL, NULL, a.id_area,
       IF(4 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 4), NULL) FROM area a WHERE a.id_area = 170;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-HGSMF41-PC006', '02:5E:0F:B9:8E:46', '10.21.15.25', 'Windows 11 Pro', '23H2', 'ONLINE', @ahora - INTERVAL 110 SECOND, @ahora - INTERVAL 200 DAY, 'Planta baja', 1, NULL, NULL, a.id_area,
       IF(0 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 0), NULL) FROM area a WHERE a.id_area = 147;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-HGSMF41-PC007', '02:5E:0F:DE:9B:47', '10.21.15.26', 'Windows 11 Pro', '24H2', 'ONLINE', @ahora - INTERVAL 27 SECOND, @ahora - INTERVAL 211 DAY, 'Primer piso', 1, NULL, NULL, a.id_area,
       IF(1 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 1), NULL) FROM area a WHERE a.id_area = 154;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-HGSMF41-PC008', '02:5E:0F:03:A8:48', '10.21.15.27', 'Windows 10 Pro', '22H2', 'ONLINE', @ahora - INTERVAL 44 SECOND, @ahora - INTERVAL 222 DAY, 'Segundo piso', 1, NULL, NULL, a.id_area,
       IF(2 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 2), NULL) FROM area a WHERE a.id_area = 161;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-HGSMF41-PC009', '02:5E:0F:28:B5:49', '10.21.15.28', 'Windows 10 Pro', '22H2', 'ONLINE', @ahora - INTERVAL 61 SECOND, @ahora - INTERVAL 233 DAY, 'Consultorio 2', 1, NULL, NULL, a.id_area,
       IF(3 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 3), NULL) FROM area a WHERE a.id_area = 168;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-HGSMF41-PC010', '02:5E:0F:4D:C2:4A', '10.21.15.29', 'Ubuntu', '22.04 LTS', 'OFFLINE', @ahora - INTERVAL 26 HOUR, @ahora - INTERVAL 244 DAY, 'Archivo', 1, NULL, NULL, a.id_area,
       IF(4 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 4), NULL) FROM area a WHERE a.id_area = 145;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-HGSMF41-PC011', '02:5E:0F:72:CF:4B', '10.21.15.30', 'Windows 11 Pro', '23H2', 'OFFLINE', @ahora - INTERVAL 50 HOUR, @ahora - INTERVAL 255 DAY, 'Recepción', 1, NULL, NULL, a.id_area,
       IF(0 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 0), NULL) FROM area a WHERE a.id_area = 152;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-HGSMF41-PC012', '02:5E:0F:97:DC:4C', '10.21.15.31', 'Windows 11 Pro', '24H2', 'OFFLINE', @ahora - INTERVAL 120 HOUR, @ahora - INTERVAL 266 DAY, 'Jefatura', 1, NULL, NULL, a.id_area,
       IF(1 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 1), NULL) FROM area a WHERE a.id_area = 159;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-OOAD-PC001', '02:5E:01:00:E9:4D', '10.21.1.20', 'Windows 10 Pro', '22H2', 'ALERTA', @ahora - INTERVAL 29 SECOND, @ahora - INTERVAL 277 DAY, 'Ventanilla', 1, NULL, NULL, a.id_area,
       IF(2 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 2), NULL) FROM area a WHERE a.id_area = 950;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-OOAD-PC002', '02:5E:01:25:F6:4E', '10.21.1.21', 'Windows 10 Pro', '22H2', 'ALERTA', @ahora - INTERVAL 46 SECOND, @ahora - INTERVAL 288 DAY, 'Sala de juntas', 1, NULL, NULL, a.id_area,
       IF(3 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 3), NULL) FROM area a WHERE a.id_area = 951;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-OOAD-PC003', '02:5E:01:4A:03:4F', '10.21.1.22', 'Ubuntu', '22.04 LTS', 'INACTIVO', @ahora - INTERVAL 54 DAY, @ahora - INTERVAL 299 DAY, 'Almacén', 0, @ahora - INTERVAL 49 DAY, 'Equipo dañado sin reparación; reemplazado', a.id_area,
       IF(4 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 4), NULL) FROM area a WHERE a.id_area = 950;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-OOAD-PC004', '02:5E:01:6F:10:50', '10.21.1.23', 'Windows 11 Pro', '23H2', 'ONLINE', @ahora - INTERVAL 80 SECOND, @ahora - INTERVAL 310 DAY, 'Planta baja', 1, NULL, NULL, a.id_area,
       IF(0 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 0), NULL) FROM area a WHERE a.id_area = 951;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-OOAD-PC005', '02:5E:01:94:1D:51', '10.21.1.24', 'Windows 11 Pro', '24H2', 'ONLINE', @ahora - INTERVAL 97 SECOND, @ahora - INTERVAL 321 DAY, 'Primer piso', 1, NULL, NULL, a.id_area,
       IF(1 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 1), NULL) FROM area a WHERE a.id_area = 950;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-OOAD-PC006', '02:5E:01:B9:2A:52', '10.21.1.25', 'Windows 10 Pro', '22H2', 'ONLINE', @ahora - INTERVAL 114 SECOND, @ahora - INTERVAL 32 DAY, 'Segundo piso', 1, NULL, NULL, a.id_area,
       IF(2 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 2), NULL) FROM area a WHERE a.id_area = 951;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-OOAD-PC007', '02:5E:01:DE:37:53', '10.21.1.26', 'Windows 10 Pro', '22H2', 'ONLINE', @ahora - INTERVAL 31 SECOND, @ahora - INTERVAL 43 DAY, 'Consultorio 12', 1, NULL, NULL, a.id_area,
       IF(3 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 3), NULL) FROM area a WHERE a.id_area = 950;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-OOAD-PC008', '02:5E:01:03:44:54', '10.21.1.27', 'Ubuntu', '22.04 LTS', 'ONLINE', @ahora - INTERVAL 48 SECOND, @ahora - INTERVAL 54 DAY, 'Archivo', 1, NULL, NULL, a.id_area,
       IF(4 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 4), NULL) FROM area a WHERE a.id_area = 951;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-OOAD-PC009', '02:5E:01:28:51:55', '10.21.1.28', 'Windows 11 Pro', '23H2', 'ONLINE', @ahora - INTERVAL 65 SECOND, @ahora - INTERVAL 65 DAY, 'Recepción', 1, NULL, NULL, a.id_area,
       IF(0 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 0), NULL) FROM area a WHERE a.id_area = 950;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-OOAD-PC010', '02:5E:01:4D:5E:56', '10.21.1.29', 'Windows 11 Pro', '24H2', 'ONLINE', @ahora - INTERVAL 82 SECOND, @ahora - INTERVAL 76 DAY, 'Jefatura', 1, NULL, NULL, a.id_area,
       IF(1 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 1), NULL) FROM area a WHERE a.id_area = 951;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-OOAD-PC011', '02:5E:01:72:6B:57', '10.21.1.30', 'Windows 10 Pro', '22H2', 'ONLINE', @ahora - INTERVAL 99 SECOND, @ahora - INTERVAL 87 DAY, 'Ventanilla', 1, NULL, NULL, a.id_area,
       IF(2 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 2), NULL) FROM area a WHERE a.id_area = 950;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-OOAD-PC012', '02:5E:01:97:78:58', '10.21.1.31', 'Windows 10 Pro', '22H2', 'ONLINE', @ahora - INTERVAL 116 SECOND, @ahora - INTERVAL 98 DAY, 'Sala de juntas', 1, NULL, NULL, a.id_area,
       IF(3 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 3), NULL) FROM area a WHERE a.id_area = 951;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-OOAD-PC013', '02:5E:01:BC:85:59', '10.21.1.32', 'Ubuntu', '22.04 LTS', 'ONLINE', @ahora - INTERVAL 33 SECOND, @ahora - INTERVAL 109 DAY, 'Almacén', 1, NULL, NULL, a.id_area,
       IF(4 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 4), NULL) FROM area a WHERE a.id_area = 950;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-OOAD-PC014', '02:5E:01:E1:92:5A', '10.21.1.33', 'Windows 11 Pro', '23H2', 'ONLINE', @ahora - INTERVAL 50 SECOND, @ahora - INTERVAL 120 DAY, 'Planta baja', 1, NULL, NULL, a.id_area,
       IF(0 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 0), NULL) FROM area a WHERE a.id_area = 951;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-UMF65-PC001', '02:5E:1A:00:9F:5B', '10.21.26.20', 'Windows 11 Pro', '24H2', 'ONLINE', @ahora - INTERVAL 67 SECOND, @ahora - INTERVAL 131 DAY, 'Primer piso', 1, NULL, NULL, a.id_area,
       IF(1 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 1), NULL) FROM area a WHERE a.id_area = 343;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-UMF65-PC002', '02:5E:1A:25:AC:5C', '10.21.26.21', 'Windows 10 Pro', '22H2', 'ONLINE', @ahora - INTERVAL 84 SECOND, @ahora - INTERVAL 142 DAY, 'Segundo piso', 1, NULL, NULL, a.id_area,
       IF(2 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 2), NULL) FROM area a WHERE a.id_area = 350;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-UMF65-PC003', '02:5E:1A:4A:B9:5D', '10.21.26.22', 'Windows 10 Pro', '22H2', 'ONLINE', @ahora - INTERVAL 101 SECOND, @ahora - INTERVAL 153 DAY, 'Consultorio 10', 1, NULL, NULL, a.id_area,
       IF(3 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 3), NULL) FROM area a WHERE a.id_area = 357;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-UMF65-PC004', '02:5E:1A:6F:C6:5E', '10.21.26.23', 'Ubuntu', '22.04 LTS', 'OFFLINE', @ahora - INTERVAL 120 HOUR, @ahora - INTERVAL 164 DAY, 'Archivo', 1, NULL, NULL, a.id_area,
       IF(4 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 4), NULL) FROM area a WHERE a.id_area = 364;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-UMF65-PC005', '02:5E:1A:94:D3:5F', '10.21.26.24', 'Windows 11 Pro', '23H2', 'OFFLINE', @ahora - INTERVAL 220 HOUR, @ahora - INTERVAL 175 DAY, 'Recepción', 1, NULL, NULL, a.id_area,
       IF(0 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 0), NULL) FROM area a WHERE a.id_area = 347;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-UMF65-PC006', '02:5E:1A:B9:E0:60', '10.21.26.25', 'Windows 11 Pro', '24H2', 'OFFLINE', @ahora - INTERVAL 3 HOUR, @ahora - INTERVAL 186 DAY, 'Jefatura', 1, NULL, NULL, a.id_area,
       IF(1 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 1), NULL) FROM area a WHERE a.id_area = 354;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-UMF65-PC007', '02:5E:1A:DE:ED:61', '10.21.26.26', 'Windows 10 Pro', '22H2', 'ALERTA', @ahora - INTERVAL 69 SECOND, @ahora - INTERVAL 197 DAY, 'Ventanilla', 1, NULL, NULL, a.id_area,
       IF(2 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 2), NULL) FROM area a WHERE a.id_area = 361;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-UMF65-PC008', '02:5E:1A:03:FA:62', '10.21.26.27', 'Windows 10 Pro', '22H2', 'ALERTA', @ahora - INTERVAL 86 SECOND, @ahora - INTERVAL 208 DAY, 'Sala de juntas', 1, NULL, NULL, a.id_area,
       IF(3 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 3), NULL) FROM area a WHERE a.id_area = 344;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-UMF65-PC009', '02:5E:1A:28:07:63', '10.21.26.28', 'Ubuntu', '22.04 LTS', 'INACTIVO', @ahora - INTERVAL 54 DAY, @ahora - INTERVAL 219 DAY, 'Almacén', 0, @ahora - INTERVAL 49 DAY, 'Equipo dañado sin reparación; reemplazado', a.id_area,
       IF(4 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 4), NULL) FROM area a WHERE a.id_area = 351;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-UMF65-PC010', '02:5E:1A:4D:14:64', '10.21.26.29', 'Windows 11 Pro', '23H2', 'ONLINE', @ahora - INTERVAL 20 SECOND, @ahora - INTERVAL 230 DAY, 'Planta baja', 1, NULL, NULL, a.id_area,
       IF(0 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 0), NULL) FROM area a WHERE a.id_area = 358;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-UMF1-PC001', '02:5E:15:00:21:65', '10.21.21.20', 'Windows 11 Pro', '24H2', 'ONLINE', @ahora - INTERVAL 37 SECOND, @ahora - INTERVAL 241 DAY, 'Primer piso', 1, NULL, NULL, a.id_area,
       IF(1 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 1), NULL) FROM area a WHERE a.id_area = 200;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-UMF1-PC002', '02:5E:15:25:2E:66', '10.21.21.21', 'Windows 10 Pro', '22H2', 'ONLINE', @ahora - INTERVAL 54 SECOND, @ahora - INTERVAL 252 DAY, 'Segundo piso', 1, NULL, NULL, a.id_area,
       IF(2 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 2), NULL) FROM area a WHERE a.id_area = 207;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-UMF1-PC003', '02:5E:15:4A:3B:67', '10.21.21.22', 'Windows 10 Pro', '22H2', 'ONLINE', @ahora - INTERVAL 71 SECOND, @ahora - INTERVAL 263 DAY, 'Consultorio 8', 1, NULL, NULL, a.id_area,
       IF(3 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 3), NULL) FROM area a WHERE a.id_area = 214;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-UMF1-PC004', '02:5E:15:6F:48:68', '10.21.21.23', 'Ubuntu', '22.04 LTS', 'ONLINE', @ahora - INTERVAL 88 SECOND, @ahora - INTERVAL 274 DAY, 'Archivo', 1, NULL, NULL, a.id_area,
       IF(4 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 4), NULL) FROM area a WHERE a.id_area = 202;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-UMF1-PC005', '02:5E:15:94:55:69', '10.21.21.24', 'Windows 11 Pro', '23H2', 'ONLINE', @ahora - INTERVAL 105 SECOND, @ahora - INTERVAL 285 DAY, 'Recepción', 1, NULL, NULL, a.id_area,
       IF(0 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 0), NULL) FROM area a WHERE a.id_area = 209;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-UMF1-PC006', '02:5E:15:B9:62:6A', '10.21.21.25', 'Windows 11 Pro', '24H2', 'ONLINE', @ahora - INTERVAL 22 SECOND, @ahora - INTERVAL 296 DAY, 'Jefatura', 1, NULL, NULL, a.id_area,
       IF(1 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 1), NULL) FROM area a WHERE a.id_area = 216;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-UMF1-PC007', '02:5E:15:DE:6F:6B', '10.21.21.26', 'Windows 10 Pro', '22H2', 'ONLINE', @ahora - INTERVAL 39 SECOND, @ahora - INTERVAL 307 DAY, 'Ventanilla', 1, NULL, NULL, a.id_area,
       IF(2 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 2), NULL) FROM area a WHERE a.id_area = 204;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-UMF1-PC008', '02:5E:15:03:7C:6C', '10.21.21.27', 'Windows 10 Pro', '22H2', 'ONLINE', @ahora - INTERVAL 56 SECOND, @ahora - INTERVAL 318 DAY, 'Sala de juntas', 1, NULL, NULL, a.id_area,
       IF(3 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 3), NULL) FROM area a WHERE a.id_area = 211;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-UMF1-PC009', '02:5E:15:28:89:6D', '10.21.21.28', 'Ubuntu', '22.04 LTS', 'ONLINE', @ahora - INTERVAL 73 SECOND, @ahora - INTERVAL 329 DAY, 'Almacén', 1, NULL, NULL, a.id_area,
       IF(4 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 4), NULL) FROM area a WHERE a.id_area = 218;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-UMF1-PC010', '02:5E:15:4D:96:6E', '10.21.21.29', 'Windows 11 Pro', '23H2', 'ONLINE', @ahora - INTERVAL 90 SECOND, @ahora - INTERVAL 40 DAY, 'Planta baja', 1, NULL, NULL, a.id_area,
       IF(0 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 0), NULL) FROM area a WHERE a.id_area = 206;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-UMF64-PC001', '02:5E:40:00:A3:6F', '10.21.64.20', 'Windows 11 Pro', '24H2', 'ONLINE', @ahora - INTERVAL 107 SECOND, @ahora - INTERVAL 51 DAY, 'Primer piso', 1, NULL, NULL, a.id_area,
       IF(1 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 1), NULL) FROM area a WHERE a.id_area = 224;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-UMF64-PC002', '02:5E:40:25:B0:70', '10.21.64.21', 'Windows 10 Pro', '22H2', 'ONLINE', @ahora - INTERVAL 24 SECOND, @ahora - INTERVAL 62 DAY, 'Segundo piso', 1, NULL, NULL, a.id_area,
       IF(2 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 2), NULL) FROM area a WHERE a.id_area = 231;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-UMF64-PC003', '02:5E:40:4A:BD:71', '10.21.64.22', 'Windows 10 Pro', '22H2', 'ONLINE', @ahora - INTERVAL 41 SECOND, @ahora - INTERVAL 73 DAY, 'Consultorio 6', 1, NULL, NULL, a.id_area,
       IF(3 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 3), NULL) FROM area a WHERE a.id_area = 238;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-UMF64-PC004', '02:5E:40:6F:CA:72', '10.21.64.23', 'Ubuntu', '22.04 LTS', 'OFFLINE', @ahora - INTERVAL 3 HOUR, @ahora - INTERVAL 84 DAY, 'Archivo', 1, NULL, NULL, a.id_area,
       IF(4 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 4), NULL) FROM area a WHERE a.id_area = 245;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-UMF64-PC005', '02:5E:40:94:D7:73', '10.21.64.24', 'Windows 11 Pro', '23H2', 'OFFLINE', @ahora - INTERVAL 9 HOUR, @ahora - INTERVAL 95 DAY, 'Recepción', 1, NULL, NULL, a.id_area,
       IF(0 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 0), NULL) FROM area a WHERE a.id_area = 252;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-UMF64-PC006', '02:5E:40:B9:E4:74', '10.21.64.25', 'Windows 11 Pro', '24H2', 'OFFLINE', @ahora - INTERVAL 26 HOUR, @ahora - INTERVAL 106 DAY, 'Jefatura', 1, NULL, NULL, a.id_area,
       IF(1 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 1), NULL) FROM area a WHERE a.id_area = 228;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-UMF64-PC007', '02:5E:40:DE:F1:75', '10.21.64.26', 'Windows 10 Pro', '22H2', 'ALERTA', @ahora - INTERVAL 109 SECOND, @ahora - INTERVAL 117 DAY, 'Ventanilla', 1, NULL, NULL, a.id_area,
       IF(2 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 2), NULL) FROM area a WHERE a.id_area = 235;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-UMF64-PC008', '02:5E:40:03:FE:76', '10.21.64.27', 'Windows 10 Pro', '22H2', 'ALERTA', @ahora - INTERVAL 26 SECOND, @ahora - INTERVAL 128 DAY, 'Sala de juntas', 1, NULL, NULL, a.id_area,
       IF(3 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 3), NULL) FROM area a WHERE a.id_area = 242;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-UMF6-PC001', '02:5E:38:00:0B:77', '10.21.56.20', 'Ubuntu', '22.04 LTS', 'INACTIVO', @ahora - INTERVAL 54 DAY, @ahora - INTERVAL 139 DAY, 'Almacén', 0, @ahora - INTERVAL 49 DAY, 'Equipo dañado sin reparación; reemplazado', a.id_area,
       IF(4 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 4), NULL) FROM area a WHERE a.id_area = 326;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-UMF6-PC002', '02:5E:38:25:18:78', '10.21.56.21', 'Windows 11 Pro', '23H2', 'ONLINE', @ahora - INTERVAL 60 SECOND, @ahora - INTERVAL 150 DAY, 'Planta baja', 1, NULL, NULL, a.id_area,
       IF(0 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 0), NULL) FROM area a WHERE a.id_area = 333;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-UMF6-PC003', '02:5E:38:4A:25:79', '10.21.56.22', 'Windows 11 Pro', '24H2', 'ONLINE', @ahora - INTERVAL 77 SECOND, @ahora - INTERVAL 161 DAY, 'Primer piso', 1, NULL, NULL, a.id_area,
       IF(1 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 1), NULL) FROM area a WHERE a.id_area = 340;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-UMF6-PC004', '02:5E:38:6F:32:7A', '10.21.56.23', 'Windows 10 Pro', '22H2', 'ONLINE', @ahora - INTERVAL 94 SECOND, @ahora - INTERVAL 172 DAY, 'Segundo piso', 1, NULL, NULL, a.id_area,
       IF(2 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 2), NULL) FROM area a WHERE a.id_area = 330;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-UMF6-PC005', '02:5E:38:94:3F:7B', '10.21.56.24', 'Windows 10 Pro', '22H2', 'ONLINE', @ahora - INTERVAL 111 SECOND, @ahora - INTERVAL 183 DAY, 'Consultorio 4', 1, NULL, NULL, a.id_area,
       IF(3 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 3), NULL) FROM area a WHERE a.id_area = 337;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-UMF6-PC006', '02:5E:38:B9:4C:7C', '10.21.56.25', 'Ubuntu', '22.04 LTS', 'ONLINE', @ahora - INTERVAL 28 SECOND, @ahora - INTERVAL 194 DAY, 'Archivo', 1, NULL, NULL, a.id_area,
       IF(4 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 4), NULL) FROM area a WHERE a.id_area = 327;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-UMF6-PC007', '02:5E:38:DE:59:7D', '10.21.56.26', 'Windows 11 Pro', '23H2', 'ONLINE', @ahora - INTERVAL 45 SECOND, @ahora - INTERVAL 205 DAY, 'Recepción', 1, NULL, NULL, a.id_area,
       IF(0 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 0), NULL) FROM area a WHERE a.id_area = 334;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-UMF6-PC008', '02:5E:38:03:66:7E', '10.21.56.27', 'Windows 11 Pro', '24H2', 'ONLINE', @ahora - INTERVAL 62 SECOND, @ahora - INTERVAL 216 DAY, 'Jefatura', 1, NULL, NULL, a.id_area,
       IF(1 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 1), NULL) FROM area a WHERE a.id_area = 341;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-UMF38-PC001', '02:5E:26:00:73:7F', '10.21.38.20', 'Windows 10 Pro', '22H2', 'ONLINE', @ahora - INTERVAL 79 SECOND, @ahora - INTERVAL 227 DAY, 'Ventanilla', 1, NULL, NULL, a.id_area,
       IF(2 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 2), NULL) FROM area a WHERE a.id_area = 264;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-UMF38-PC002', '02:5E:26:25:80:80', '10.21.38.21', 'Windows 10 Pro', '22H2', 'ONLINE', @ahora - INTERVAL 96 SECOND, @ahora - INTERVAL 238 DAY, 'Sala de juntas', 1, NULL, NULL, a.id_area,
       IF(3 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 3), NULL) FROM area a WHERE a.id_area = 271;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-UMF38-PC003', '02:5E:26:4A:8D:81', '10.21.38.22', 'Ubuntu', '22.04 LTS', 'ONLINE', @ahora - INTERVAL 113 SECOND, @ahora - INTERVAL 249 DAY, 'Almacén', 1, NULL, NULL, a.id_area,
       IF(4 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 4), NULL) FROM area a WHERE a.id_area = 266;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-UMF38-PC004', '02:5E:26:6F:9A:82', '10.21.38.23', 'Windows 11 Pro', '23H2', 'ONLINE', @ahora - INTERVAL 30 SECOND, @ahora - INTERVAL 260 DAY, 'Planta baja', 1, NULL, NULL, a.id_area,
       IF(0 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 0), NULL) FROM area a WHERE a.id_area = 273;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-UMF38-PC005', '02:5E:26:94:A7:83', '10.21.38.24', 'Windows 11 Pro', '24H2', 'ONLINE', @ahora - INTERVAL 47 SECOND, @ahora - INTERVAL 271 DAY, 'Primer piso', 1, NULL, NULL, a.id_area,
       IF(1 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 1), NULL) FROM area a WHERE a.id_area = 268;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-UMF38-PC006', '02:5E:26:B9:B4:84', '10.21.38.25', 'Windows 10 Pro', '22H2', 'ONLINE', @ahora - INTERVAL 64 SECOND, @ahora - INTERVAL 282 DAY, 'Segundo piso', 1, NULL, NULL, a.id_area,
       IF(2 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 2), NULL) FROM area a WHERE a.id_area = 275;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-SUBOAX-PC001', '02:5E:02:00:C1:85', '10.21.2.20', 'Windows 10 Pro', '22H2', 'ONLINE', @ahora - INTERVAL 81 SECOND, @ahora - INTERVAL 293 DAY, 'Consultorio 2', 1, NULL, NULL, a.id_area,
       IF(3 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 3), NULL) FROM area a WHERE a.id_area = 969;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-SUBOAX-PC002', '02:5E:02:25:CE:86', '10.21.2.21', 'Ubuntu', '22.04 LTS', 'OFFLINE', @ahora - INTERVAL 26 HOUR, @ahora - INTERVAL 304 DAY, 'Archivo', 1, NULL, NULL, a.id_area,
       IF(4 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 4), NULL) FROM area a WHERE a.id_area = 971;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-SUBOAX-PC003', '02:5E:02:4A:DB:87', '10.21.2.22', 'Windows 11 Pro', '23H2', 'OFFLINE', @ahora - INTERVAL 50 HOUR, @ahora - INTERVAL 315 DAY, 'Recepción', 1, NULL, NULL, a.id_area,
       IF(0 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 0), NULL) FROM area a WHERE a.id_area = 973;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-SUBOAX-PC004', '02:5E:02:6F:E8:88', '10.21.2.23', 'Windows 11 Pro', '24H2', 'OFFLINE', @ahora - INTERVAL 120 HOUR, @ahora - INTERVAL 326 DAY, 'Jefatura', 1, NULL, NULL, a.id_area,
       IF(1 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 1), NULL) FROM area a WHERE a.id_area = 970;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-SUBOAX-PC005', '02:5E:02:94:F5:89', '10.21.2.24', 'Windows 10 Pro', '22H2', 'ALERTA', @ahora - INTERVAL 49 SECOND, @ahora - INTERVAL 37 DAY, 'Ventanilla', 1, NULL, NULL, a.id_area,
       IF(2 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 2), NULL) FROM area a WHERE a.id_area = 972;
INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal, fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)
SELECT 'OAX-SUBOAX-PC006', '02:5E:02:B9:02:8A', '10.21.2.25', 'Windows 10 Pro', '22H2', 'ALERTA', @ahora - INTERVAL 66 SECOND, @ahora - INTERVAL 48 DAY, 'Sala de juntas', 1, NULL, NULL, a.id_area,
       IF(3 < @n_usuarios, (SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET 3), NULL) FROM area a WHERE a.id_area = 969;

-- ---------- 4. Hardware, software y periféricos ----------
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'Intel Core i5-10500', 6, 12, 8, 'HP ProDesk 400 G7', 512, id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:00:0D:01';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 41 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:00:0D:01')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 41 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:00:0D:01')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 41 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:00:0D:01')),
  ('ESET Endpoint Security', '11.0', 'ESET', @ahora - INTERVAL 41 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:00:0D:01'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0007919', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:00:0D:01')), ('Teclado', 'Dell KB216', 'KB104729', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:00:0D:01'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'Intel Core i7-12700', 12, 20, 16, 'Lenovo ThinkCentre M70s', 512, id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:25:1A:02';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 52 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:25:1A:02')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 52 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:25:1A:02')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 52 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:25:1A:02')),
  ('ESET Endpoint Security', '11.0', 'ESET', @ahora - INTERVAL 52 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:25:1A:02')),
  ('7-Zip', '24.08', 'Igor Pavlov', @ahora - INTERVAL 52 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:25:1A:02'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0015838', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:25:1A:02')), ('Teclado', 'Dell KB216', 'KB209458', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:25:1A:02'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'Intel Core i3-10100', 4, 8, 16, 'Dell OptiPlex 3080', 1000, id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:4A:27:03';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 63 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:4A:27:03')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 63 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:4A:27:03')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 63 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:4A:27:03'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0023757', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:4A:27:03')), ('Teclado', 'Dell KB216', 'KB314187', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:4A:27:03'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'AMD Ryzen 5 5600G', 6, 12, 16, 'Dell OptiPlex 7000', 256, id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:6F:34:04';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 74 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:6F:34:04')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 74 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:6F:34:04')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 74 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:6F:34:04')),
  ('ESET Endpoint Security', '11.0', 'ESET', @ahora - INTERVAL 74 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:6F:34:04'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0031676', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:6F:34:04')), ('Teclado', 'Dell KB216', 'KB418916', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:6F:34:04'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'Intel Core i5-12500', 6, 12, 32, 'HP ProDesk 400 G7', 512, id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:94:41:05';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 85 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:94:41:05')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 85 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:94:41:05')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 85 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:94:41:05')),
  ('ESET Endpoint Security', '11.0', 'ESET', @ahora - INTERVAL 85 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:94:41:05')),
  ('7-Zip', '24.08', 'Igor Pavlov', @ahora - INTERVAL 85 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:94:41:05'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0039595', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:94:41:05')), ('Teclado', 'Dell KB216', 'KB523645', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:94:41:05'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'Intel Core i5-10500', 6, 12, 8, 'Lenovo ThinkCentre M70s', 512, id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:B9:4E:06';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 96 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:B9:4E:06')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 96 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:B9:4E:06')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 96 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:B9:4E:06'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0047514', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:B9:4E:06')), ('Teclado', 'Dell KB216', 'KB628374', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:B9:4E:06'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'Intel Core i7-12700', 12, 20, 8, 'Dell OptiPlex 3080', 1000, id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:DE:5B:07';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 107 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:DE:5B:07')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 107 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:DE:5B:07')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 107 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:DE:5B:07')),
  ('ESET Endpoint Security', '11.0', 'ESET', @ahora - INTERVAL 107 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:DE:5B:07'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0055433', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:DE:5B:07')), ('Teclado', 'Dell KB216', 'KB733103', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:DE:5B:07'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'Intel Core i3-10100', 4, 8, 16, 'Dell OptiPlex 7000', 256, id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:03:68:08';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 118 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:03:68:08')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 118 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:03:68:08')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 118 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:03:68:08')),
  ('ESET Endpoint Security', '11.0', 'ESET', @ahora - INTERVAL 118 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:03:68:08')),
  ('7-Zip', '24.08', 'Igor Pavlov', @ahora - INTERVAL 118 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:03:68:08')),
  ('Juegos Steam', '2.10', 'Valve', @ahora - INTERVAL 11 DAY, 0, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:03:68:08'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0063352', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:03:68:08')), ('Teclado', 'Dell KB216', 'KB837832', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:03:68:08'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'AMD Ryzen 5 5600G', 6, 12, 16, 'HP ProDesk 400 G7', 512, id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:28:75:09';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 129 DAY, 1, 0, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:28:75:09')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 129 DAY, 1, 0, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:28:75:09')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 129 DAY, 1, 0, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:28:75:09'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0071271', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:28:75:09')), ('Teclado', 'Dell KB216', 'KB942561', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:28:75:09'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'Intel Core i5-12500', 6, 12, 16, 'Lenovo ThinkCentre M70s', 512, id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:4D:82:0A';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 140 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:4D:82:0A')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 140 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:4D:82:0A')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 140 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:4D:82:0A')),
  ('ESET Endpoint Security', '11.0', 'ESET', @ahora - INTERVAL 140 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:4D:82:0A'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0079190', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:4D:82:0A')), ('Teclado', 'Dell KB216', 'KB047291', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:4D:82:0A'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'Intel Core i5-10500', 6, 12, 32, 'Dell OptiPlex 3080', 1000, id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:72:8F:0B';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 151 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:72:8F:0B')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 151 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:72:8F:0B')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 151 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:72:8F:0B')),
  ('ESET Endpoint Security', '11.0', 'ESET', @ahora - INTERVAL 151 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:72:8F:0B')),
  ('7-Zip', '24.08', 'Igor Pavlov', @ahora - INTERVAL 151 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:72:8F:0B'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0087109', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:72:8F:0B')), ('Teclado', 'Dell KB216', 'KB152020', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:72:8F:0B'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'Intel Core i7-12700', 12, 20, 8, 'Dell OptiPlex 7000', 256, id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:97:9C:0C';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 162 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:97:9C:0C')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 162 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:97:9C:0C')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 162 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:97:9C:0C'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0095028', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:97:9C:0C')), ('Teclado', 'Dell KB216', 'KB256749', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:97:9C:0C'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'Intel Core i3-10100', 4, 8, 8, 'HP ProDesk 400 G7', 512, id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:BC:A9:0D';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 173 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:BC:A9:0D')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 173 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:BC:A9:0D')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 173 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:BC:A9:0D')),
  ('ESET Endpoint Security', '11.0', 'ESET', @ahora - INTERVAL 173 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:BC:A9:0D'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0102947', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:BC:A9:0D')), ('Teclado', 'Dell KB216', 'KB361478', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:BC:A9:0D'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'AMD Ryzen 5 5600G', 6, 12, 16, 'Lenovo ThinkCentre M70s', 512, id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:E1:B6:0E';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 184 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:E1:B6:0E')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 184 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:E1:B6:0E')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 184 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:E1:B6:0E')),
  ('ESET Endpoint Security', '11.0', 'ESET', @ahora - INTERVAL 184 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:E1:B6:0E')),
  ('7-Zip', '24.08', 'Igor Pavlov', @ahora - INTERVAL 184 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:E1:B6:0E'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0110866', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:E1:B6:0E')), ('Teclado', 'Dell KB216', 'KB466207', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:E1:B6:0E'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'Intel Core i5-12500', 6, 12, 16, 'Dell OptiPlex 3080', 1000, id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:06:C3:0F';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 195 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:06:C3:0F')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 195 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:06:C3:0F')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 195 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:06:C3:0F'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0118785', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:06:C3:0F')), ('Teclado', 'Dell KB216', 'KB570936', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:06:C3:0F'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'Intel Core i5-10500', 6, 12, 16, 'Dell OptiPlex 7000', 256, id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:2B:D0:10';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 206 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:2B:D0:10')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 206 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:2B:D0:10')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 206 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:2B:D0:10')),
  ('ESET Endpoint Security', '11.0', 'ESET', @ahora - INTERVAL 206 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:2B:D0:10')),
  ('AnyDesk', '8.1', 'AnyDesk Software', @ahora - INTERVAL 19 DAY, 0, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:2B:D0:10'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0126704', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:2B:D0:10')), ('Teclado', 'Dell KB216', 'KB675665', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:2B:D0:10'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'Intel Core i7-12700', 12, 20, 32, 'HP ProDesk 400 G7', 512, id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:50:DD:11';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 217 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:50:DD:11')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 217 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:50:DD:11')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 217 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:50:DD:11')),
  ('ESET Endpoint Security', '11.0', 'ESET', @ahora - INTERVAL 217 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:50:DD:11')),
  ('7-Zip', '24.08', 'Igor Pavlov', @ahora - INTERVAL 217 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:50:DD:11'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0134623', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:50:DD:11')), ('Teclado', 'Dell KB216', 'KB780394', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:50:DD:11'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'Intel Core i3-10100', 4, 8, 8, 'Lenovo ThinkCentre M70s', 512, id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:75:EA:12';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 228 DAY, 1, 0, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:75:EA:12')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 228 DAY, 1, 0, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:75:EA:12')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 228 DAY, 1, 0, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:75:EA:12'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0142542', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:75:EA:12')), ('Teclado', 'Dell KB216', 'KB885123', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:75:EA:12'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'AMD Ryzen 5 5600G', 6, 12, 8, 'Dell OptiPlex 3080', 1000, id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:9A:F7:13';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 239 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:9A:F7:13')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 239 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:9A:F7:13')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 239 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:9A:F7:13')),
  ('ESET Endpoint Security', '11.0', 'ESET', @ahora - INTERVAL 239 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:9A:F7:13'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0150461', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:9A:F7:13')), ('Teclado', 'Dell KB216', 'KB989852', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:9A:F7:13'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'Intel Core i5-12500', 6, 12, 16, 'Dell OptiPlex 7000', 256, id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:BF:04:14';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 250 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:BF:04:14')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 250 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:BF:04:14')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 250 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:BF:04:14')),
  ('ESET Endpoint Security', '11.0', 'ESET', @ahora - INTERVAL 250 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:BF:04:14')),
  ('7-Zip', '24.08', 'Igor Pavlov', @ahora - INTERVAL 250 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:BF:04:14'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0158380', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:BF:04:14')), ('Teclado', 'Dell KB216', 'KB094582', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:BF:04:14'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'Intel Core i5-10500', 6, 12, 16, 'HP ProDesk 400 G7', 512, id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:E4:11:15';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 261 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:E4:11:15')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 261 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:E4:11:15')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 261 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:E4:11:15'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0166299', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:E4:11:15')), ('Teclado', 'Dell KB216', 'KB199311', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:E4:11:15'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'Intel Core i7-12700', 12, 20, 16, 'Lenovo ThinkCentre M70s', 512, id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:09:1E:16';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 272 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:09:1E:16')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 272 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:09:1E:16')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 272 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:09:1E:16')),
  ('ESET Endpoint Security', '11.0', 'ESET', @ahora - INTERVAL 272 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:09:1E:16'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0174218', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:09:1E:16')), ('Teclado', 'Dell KB216', 'KB304040', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:09:1E:16'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'Intel Core i3-10100', 4, 8, 32, 'Dell OptiPlex 3080', 1000, id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:2E:2B:17';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 283 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:2E:2B:17')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 283 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:2E:2B:17')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 283 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:2E:2B:17')),
  ('ESET Endpoint Security', '11.0', 'ESET', @ahora - INTERVAL 283 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:2E:2B:17')),
  ('7-Zip', '24.08', 'Igor Pavlov', @ahora - INTERVAL 283 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:2E:2B:17'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0182137', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:2E:2B:17')), ('Teclado', 'Dell KB216', 'KB408769', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:2E:2B:17'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'AMD Ryzen 5 5600G', 6, 12, 8, 'Dell OptiPlex 7000', 256, id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:53:38:18';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 294 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:53:38:18')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 294 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:53:38:18')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 294 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:53:38:18')),
  ('uTorrent', '3.6', 'BitTorrent Inc.', @ahora - INTERVAL 7 DAY, 0, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:53:38:18'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0190056', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:53:38:18')), ('Teclado', 'Dell KB216', 'KB513498', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:53:38:18'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'Intel Core i5-12500', 6, 12, 8, 'HP ProDesk 400 G7', 512, id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:78:45:19';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 305 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:78:45:19')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 305 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:78:45:19')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 305 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:78:45:19')),
  ('ESET Endpoint Security', '11.0', 'ESET', @ahora - INTERVAL 305 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:78:45:19'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0197975', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:78:45:19')), ('Teclado', 'Dell KB216', 'KB618227', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:78:45:19'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'Intel Core i5-10500', 6, 12, 16, 'Lenovo ThinkCentre M70s', 512, id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:9D:52:1A';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 316 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:9D:52:1A')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 316 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:9D:52:1A')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 316 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:9D:52:1A')),
  ('ESET Endpoint Security', '11.0', 'ESET', @ahora - INTERVAL 316 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:9D:52:1A')),
  ('7-Zip', '24.08', 'Igor Pavlov', @ahora - INTERVAL 316 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:9D:52:1A'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0205894', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:9D:52:1A')), ('Teclado', 'Dell KB216', 'KB722956', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:9D:52:1A'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'Intel Core i7-12700', 12, 20, 16, 'Dell OptiPlex 3080', 1000, id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:C2:5F:1B';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 327 DAY, 1, 0, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:C2:5F:1B')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 327 DAY, 1, 0, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:C2:5F:1B')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 327 DAY, 1, 0, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:C2:5F:1B'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0213813', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:C2:5F:1B')), ('Teclado', 'Dell KB216', 'KB827685', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:C2:5F:1B'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'Intel Core i3-10100', 4, 8, 16, 'Dell OptiPlex 7000', 256, id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:E7:6C:1C';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 38 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:E7:6C:1C')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 38 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:E7:6C:1C')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 38 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:E7:6C:1C')),
  ('ESET Endpoint Security', '11.0', 'ESET', @ahora - INTERVAL 38 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:E7:6C:1C'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0221732', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:E7:6C:1C')), ('Teclado', 'Dell KB216', 'KB932414', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:E7:6C:1C'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'AMD Ryzen 5 5600G', 6, 12, 32, 'HP ProDesk 400 G7', 512, id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:0C:79:1D';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 49 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:0C:79:1D')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 49 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:0C:79:1D')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 49 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:0C:79:1D')),
  ('ESET Endpoint Security', '11.0', 'ESET', @ahora - INTERVAL 49 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:0C:79:1D')),
  ('7-Zip', '24.08', 'Igor Pavlov', @ahora - INTERVAL 49 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:0C:79:1D'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0229651', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:0C:79:1D')), ('Teclado', 'Dell KB216', 'KB037144', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:0C:79:1D'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'Intel Core i5-12500', 6, 12, 8, 'Lenovo ThinkCentre M70s', 512, id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:31:86:1E';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 60 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:31:86:1E')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 60 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:31:86:1E')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 60 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:31:86:1E'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0237570', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:31:86:1E')), ('Teclado', 'Dell KB216', 'KB141873', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:31:86:1E'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'Intel Core i5-10500', 6, 12, 8, 'Dell OptiPlex 3080', 1000, id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:00:93:1F';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 71 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:00:93:1F')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 71 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:00:93:1F')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 71 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:00:93:1F')),
  ('ESET Endpoint Security', '11.0', 'ESET', @ahora - INTERVAL 71 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:00:93:1F'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0245489', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:00:93:1F')), ('Teclado', 'Dell KB216', 'KB246602', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:00:93:1F'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'Intel Core i7-12700', 12, 20, 16, 'Dell OptiPlex 7000', 256, id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:25:A0:20';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 82 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:25:A0:20')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 82 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:25:A0:20')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 82 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:25:A0:20')),
  ('ESET Endpoint Security', '11.0', 'ESET', @ahora - INTERVAL 82 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:25:A0:20')),
  ('7-Zip', '24.08', 'Igor Pavlov', @ahora - INTERVAL 82 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:25:A0:20')),
  ('Juegos Steam', '2.10', 'Valve', @ahora - INTERVAL 15 DAY, 0, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:25:A0:20'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0253408', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:25:A0:20')), ('Teclado', 'Dell KB216', 'KB351331', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:25:A0:20'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'Intel Core i3-10100', 4, 8, 16, 'HP ProDesk 400 G7', 512, id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:4A:AD:21';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 93 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:4A:AD:21')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 93 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:4A:AD:21')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 93 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:4A:AD:21'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0261327', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:4A:AD:21')), ('Teclado', 'Dell KB216', 'KB456060', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:4A:AD:21'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'AMD Ryzen 5 5600G', 6, 12, 16, 'Lenovo ThinkCentre M70s', 512, id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:6F:BA:22';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 104 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:6F:BA:22')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 104 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:6F:BA:22')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 104 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:6F:BA:22')),
  ('ESET Endpoint Security', '11.0', 'ESET', @ahora - INTERVAL 104 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:6F:BA:22'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0269246', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:6F:BA:22')), ('Teclado', 'Dell KB216', 'KB560789', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:6F:BA:22'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'Intel Core i5-12500', 6, 12, 32, 'Dell OptiPlex 3080', 1000, id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:94:C7:23';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 115 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:94:C7:23')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 115 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:94:C7:23')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 115 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:94:C7:23')),
  ('ESET Endpoint Security', '11.0', 'ESET', @ahora - INTERVAL 115 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:94:C7:23')),
  ('7-Zip', '24.08', 'Igor Pavlov', @ahora - INTERVAL 115 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:94:C7:23'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0277165', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:94:C7:23')), ('Teclado', 'Dell KB216', 'KB665518', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:94:C7:23'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'Intel Core i5-10500', 6, 12, 8, 'Dell OptiPlex 7000', 256, id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:B9:D4:24';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 126 DAY, 1, 0, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:B9:D4:24')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 126 DAY, 1, 0, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:B9:D4:24')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 126 DAY, 1, 0, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:B9:D4:24'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0285084', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:B9:D4:24')), ('Teclado', 'Dell KB216', 'KB770247', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:B9:D4:24'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'Intel Core i7-12700', 12, 20, 8, 'HP ProDesk 400 G7', 512, id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:DE:E1:25';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 137 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:DE:E1:25')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 137 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:DE:E1:25')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 137 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:DE:E1:25')),
  ('ESET Endpoint Security', '11.0', 'ESET', @ahora - INTERVAL 137 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:DE:E1:25'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0293003', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:DE:E1:25')), ('Teclado', 'Dell KB216', 'KB874976', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:DE:E1:25'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'Intel Core i3-10100', 4, 8, 16, 'Lenovo ThinkCentre M70s', 512, id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:03:EE:26';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 148 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:03:EE:26')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 148 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:03:EE:26')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 148 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:03:EE:26')),
  ('ESET Endpoint Security', '11.0', 'ESET', @ahora - INTERVAL 148 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:03:EE:26')),
  ('7-Zip', '24.08', 'Igor Pavlov', @ahora - INTERVAL 148 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:03:EE:26'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0300922', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:03:EE:26')), ('Teclado', 'Dell KB216', 'KB979705', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:03:EE:26'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'AMD Ryzen 5 5600G', 6, 12, 16, 'Dell OptiPlex 3080', 1000, id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:28:FB:27';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 159 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:28:FB:27')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 159 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:28:FB:27')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 159 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:28:FB:27'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0308841', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:28:FB:27')), ('Teclado', 'Dell KB216', 'KB084435', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:28:FB:27'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'Intel Core i5-12500', 6, 12, 16, 'Dell OptiPlex 7000', 256, id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:4D:08:28';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 170 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:4D:08:28')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 170 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:4D:08:28')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 170 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:4D:08:28')),
  ('ESET Endpoint Security', '11.0', 'ESET', @ahora - INTERVAL 170 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:4D:08:28')),
  ('AnyDesk', '8.1', 'AnyDesk Software', @ahora - INTERVAL 3 DAY, 0, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:4D:08:28'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0316760', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:4D:08:28')), ('Teclado', 'Dell KB216', 'KB189164', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:4D:08:28'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'Intel Core i5-10500', 6, 12, 32, 'HP ProDesk 400 G7', 512, id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:72:15:29';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 181 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:72:15:29')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 181 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:72:15:29')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 181 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:72:15:29')),
  ('ESET Endpoint Security', '11.0', 'ESET', @ahora - INTERVAL 181 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:72:15:29')),
  ('7-Zip', '24.08', 'Igor Pavlov', @ahora - INTERVAL 181 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:72:15:29'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0324679', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:72:15:29')), ('Teclado', 'Dell KB216', 'KB293893', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:72:15:29'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'Intel Core i7-12700', 12, 20, 8, 'Lenovo ThinkCentre M70s', 512, id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:97:22:2A';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 192 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:97:22:2A')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 192 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:97:22:2A')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 192 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:97:22:2A'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0332598', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:97:22:2A')), ('Teclado', 'Dell KB216', 'KB398622', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:97:22:2A'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'Intel Core i3-10100', 4, 8, 8, 'Dell OptiPlex 3080', 1000, id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:BC:2F:2B';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 203 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:BC:2F:2B')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 203 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:BC:2F:2B')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 203 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:BC:2F:2B')),
  ('ESET Endpoint Security', '11.0', 'ESET', @ahora - INTERVAL 203 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:BC:2F:2B'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0340517', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:BC:2F:2B')), ('Teclado', 'Dell KB216', 'KB503351', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:BC:2F:2B'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'AMD Ryzen 5 5600G', 6, 12, 16, 'Dell OptiPlex 7000', 256, id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:E1:3C:2C';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 214 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:E1:3C:2C')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 214 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:E1:3C:2C')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 214 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:E1:3C:2C')),
  ('ESET Endpoint Security', '11.0', 'ESET', @ahora - INTERVAL 214 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:E1:3C:2C')),
  ('7-Zip', '24.08', 'Igor Pavlov', @ahora - INTERVAL 214 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:E1:3C:2C'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0348436', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:E1:3C:2C')), ('Teclado', 'Dell KB216', 'KB608080', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:E1:3C:2C'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'Intel Core i5-12500', 6, 12, 16, 'HP ProDesk 400 G7', 512, id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:06:49:2D';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 225 DAY, 1, 0, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:06:49:2D')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 225 DAY, 1, 0, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:06:49:2D')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 225 DAY, 1, 0, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:06:49:2D'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0356355', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:06:49:2D')), ('Teclado', 'Dell KB216', 'KB712809', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:06:49:2D'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'Intel Core i5-10500', 6, 12, 16, 'Lenovo ThinkCentre M70s', 512, id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:2B:56:2E';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 236 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:2B:56:2E')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 236 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:2B:56:2E')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 236 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:2B:56:2E')),
  ('ESET Endpoint Security', '11.0', 'ESET', @ahora - INTERVAL 236 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:2B:56:2E'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0364274', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:2B:56:2E')), ('Teclado', 'Dell KB216', 'KB817538', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:2B:56:2E'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'Intel Core i7-12700', 12, 20, 32, 'Dell OptiPlex 3080', 1000, id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:50:63:2F';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 247 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:50:63:2F')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 247 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:50:63:2F')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 247 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:50:63:2F')),
  ('ESET Endpoint Security', '11.0', 'ESET', @ahora - INTERVAL 247 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:50:63:2F')),
  ('7-Zip', '24.08', 'Igor Pavlov', @ahora - INTERVAL 247 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:50:63:2F'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0372193', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:50:63:2F')), ('Teclado', 'Dell KB216', 'KB922267', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:50:63:2F'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'Intel Core i3-10100', 4, 8, 8, 'Dell OptiPlex 7000', 256, id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:75:70:30';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 258 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:75:70:30')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 258 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:75:70:30')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 258 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:75:70:30')),
  ('uTorrent', '3.6', 'BitTorrent Inc.', @ahora - INTERVAL 11 DAY, 0, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:75:70:30'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0380112', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:75:70:30')), ('Teclado', 'Dell KB216', 'KB026997', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:75:70:30'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'AMD Ryzen 5 5600G', 6, 12, 8, 'HP ProDesk 400 G7', 512, id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:00:7D:31';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 269 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:00:7D:31')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 269 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:00:7D:31')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 269 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:00:7D:31')),
  ('ESET Endpoint Security', '11.0', 'ESET', @ahora - INTERVAL 269 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:00:7D:31'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0388031', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:00:7D:31')), ('Teclado', 'Dell KB216', 'KB131726', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:00:7D:31'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'Intel Core i5-12500', 6, 12, 16, 'Lenovo ThinkCentre M70s', 512, id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:25:8A:32';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 280 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:25:8A:32')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 280 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:25:8A:32')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 280 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:25:8A:32')),
  ('ESET Endpoint Security', '11.0', 'ESET', @ahora - INTERVAL 280 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:25:8A:32')),
  ('7-Zip', '24.08', 'Igor Pavlov', @ahora - INTERVAL 280 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:25:8A:32'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0395950', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:25:8A:32')), ('Teclado', 'Dell KB216', 'KB236455', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:25:8A:32'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'Intel Core i5-10500', 6, 12, 16, 'Dell OptiPlex 3080', 1000, id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:4A:97:33';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 291 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:4A:97:33')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 291 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:4A:97:33')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 291 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:4A:97:33'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0403869', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:4A:97:33')), ('Teclado', 'Dell KB216', 'KB341184', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:4A:97:33'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'Intel Core i7-12700', 12, 20, 16, 'Dell OptiPlex 7000', 256, id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:6F:A4:34';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 302 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:6F:A4:34')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 302 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:6F:A4:34')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 302 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:6F:A4:34')),
  ('ESET Endpoint Security', '11.0', 'ESET', @ahora - INTERVAL 302 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:6F:A4:34'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0411788', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:6F:A4:34')), ('Teclado', 'Dell KB216', 'KB445913', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:6F:A4:34'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'Intel Core i3-10100', 4, 8, 32, 'HP ProDesk 400 G7', 512, id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:94:B1:35';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 313 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:94:B1:35')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 313 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:94:B1:35')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 313 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:94:B1:35')),
  ('ESET Endpoint Security', '11.0', 'ESET', @ahora - INTERVAL 313 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:94:B1:35')),
  ('7-Zip', '24.08', 'Igor Pavlov', @ahora - INTERVAL 313 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:94:B1:35'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0419707', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:94:B1:35')), ('Teclado', 'Dell KB216', 'KB550642', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:94:B1:35'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'AMD Ryzen 5 5600G', 6, 12, 8, 'Lenovo ThinkCentre M70s', 512, id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:B9:BE:36';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 324 DAY, 1, 0, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:B9:BE:36')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 324 DAY, 1, 0, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:B9:BE:36')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 324 DAY, 1, 0, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:B9:BE:36'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0427626', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:B9:BE:36')), ('Teclado', 'Dell KB216', 'KB655371', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:B9:BE:36'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'Intel Core i5-12500', 6, 12, 8, 'Dell OptiPlex 3080', 1000, id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:DE:CB:37';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 35 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:DE:CB:37')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 35 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:DE:CB:37')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 35 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:DE:CB:37')),
  ('ESET Endpoint Security', '11.0', 'ESET', @ahora - INTERVAL 35 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:DE:CB:37'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0435545', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:DE:CB:37')), ('Teclado', 'Dell KB216', 'KB760100', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:DE:CB:37'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'Intel Core i5-10500', 6, 12, 16, 'Dell OptiPlex 7000', 256, id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:03:D8:38';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 46 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:03:D8:38')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 46 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:03:D8:38')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 46 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:03:D8:38')),
  ('ESET Endpoint Security', '11.0', 'ESET', @ahora - INTERVAL 46 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:03:D8:38')),
  ('7-Zip', '24.08', 'Igor Pavlov', @ahora - INTERVAL 46 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:03:D8:38')),
  ('Juegos Steam', '2.10', 'Valve', @ahora - INTERVAL 19 DAY, 0, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:03:D8:38'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0443464', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:03:D8:38')), ('Teclado', 'Dell KB216', 'KB864829', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:03:D8:38'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'Intel Core i7-12700', 12, 20, 16, 'HP ProDesk 400 G7', 512, id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:28:E5:39';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 57 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:28:E5:39')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 57 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:28:E5:39')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 57 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:28:E5:39'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0451383', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:28:E5:39')), ('Teclado', 'Dell KB216', 'KB969558', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:28:E5:39'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'Intel Core i3-10100', 4, 8, 16, 'Lenovo ThinkCentre M70s', 512, id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:4D:F2:3A';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 68 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:4D:F2:3A')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 68 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:4D:F2:3A')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 68 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:4D:F2:3A')),
  ('ESET Endpoint Security', '11.0', 'ESET', @ahora - INTERVAL 68 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:4D:F2:3A'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0459302', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:4D:F2:3A')), ('Teclado', 'Dell KB216', 'KB074288', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:4D:F2:3A'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'AMD Ryzen 5 5600G', 6, 12, 32, 'Dell OptiPlex 3080', 1000, id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:72:FF:3B';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 79 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:72:FF:3B')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 79 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:72:FF:3B')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 79 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:72:FF:3B')),
  ('ESET Endpoint Security', '11.0', 'ESET', @ahora - INTERVAL 79 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:72:FF:3B')),
  ('7-Zip', '24.08', 'Igor Pavlov', @ahora - INTERVAL 79 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:72:FF:3B'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0467221', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:72:FF:3B')), ('Teclado', 'Dell KB216', 'KB179017', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:72:FF:3B'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'Intel Core i5-12500', 6, 12, 8, 'Dell OptiPlex 7000', 256, id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:97:0C:3C';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 90 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:97:0C:3C')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 90 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:97:0C:3C')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 90 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:97:0C:3C'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0475140', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:97:0C:3C')), ('Teclado', 'Dell KB216', 'KB283746', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:97:0C:3C'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'Intel Core i5-10500', 6, 12, 8, 'HP ProDesk 400 G7', 512, id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:BC:19:3D';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 101 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:BC:19:3D')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 101 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:BC:19:3D')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 101 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:BC:19:3D')),
  ('ESET Endpoint Security', '11.0', 'ESET', @ahora - INTERVAL 101 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:BC:19:3D'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0483059', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:BC:19:3D')), ('Teclado', 'Dell KB216', 'KB388475', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:BC:19:3D'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'Intel Core i7-12700', 12, 20, 16, 'Lenovo ThinkCentre M70s', 512, id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:E1:26:3E';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 112 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:E1:26:3E')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 112 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:E1:26:3E')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 112 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:E1:26:3E')),
  ('ESET Endpoint Security', '11.0', 'ESET', @ahora - INTERVAL 112 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:E1:26:3E')),
  ('7-Zip', '24.08', 'Igor Pavlov', @ahora - INTERVAL 112 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:E1:26:3E'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0490978', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:E1:26:3E')), ('Teclado', 'Dell KB216', 'KB493204', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:E1:26:3E'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'Intel Core i3-10100', 4, 8, 16, 'Dell OptiPlex 3080', 1000, id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:06:33:3F';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 123 DAY, 1, 0, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:06:33:3F')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 123 DAY, 1, 0, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:06:33:3F')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 123 DAY, 1, 0, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:06:33:3F'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0498897', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:06:33:3F')), ('Teclado', 'Dell KB216', 'KB597933', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:06:33:3F'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'AMD Ryzen 5 5600G', 6, 12, 16, 'Dell OptiPlex 7000', 256, id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:2B:40:40';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 134 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:2B:40:40')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 134 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:2B:40:40')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 134 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:2B:40:40')),
  ('ESET Endpoint Security', '11.0', 'ESET', @ahora - INTERVAL 134 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:2B:40:40')),
  ('AnyDesk', '8.1', 'AnyDesk Software', @ahora - INTERVAL 7 DAY, 0, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:2B:40:40'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0506816', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:2B:40:40')), ('Teclado', 'Dell KB216', 'KB702662', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:2B:40:40'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'Intel Core i5-12500', 6, 12, 32, 'HP ProDesk 400 G7', 512, id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:00:4D:41';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 145 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:00:4D:41')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 145 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:00:4D:41')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 145 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:00:4D:41')),
  ('ESET Endpoint Security', '11.0', 'ESET', @ahora - INTERVAL 145 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:00:4D:41')),
  ('7-Zip', '24.08', 'Igor Pavlov', @ahora - INTERVAL 145 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:00:4D:41'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0514735', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:00:4D:41')), ('Teclado', 'Dell KB216', 'KB807391', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:00:4D:41'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'Intel Core i5-10500', 6, 12, 8, 'Lenovo ThinkCentre M70s', 512, id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:25:5A:42';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 156 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:25:5A:42')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 156 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:25:5A:42')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 156 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:25:5A:42'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0522654', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:25:5A:42')), ('Teclado', 'Dell KB216', 'KB912120', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:25:5A:42'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'Intel Core i7-12700', 12, 20, 8, 'Dell OptiPlex 3080', 1000, id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:4A:67:43';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 167 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:4A:67:43')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 167 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:4A:67:43')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 167 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:4A:67:43')),
  ('ESET Endpoint Security', '11.0', 'ESET', @ahora - INTERVAL 167 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:4A:67:43'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0530573', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:4A:67:43')), ('Teclado', 'Dell KB216', 'KB016850', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:4A:67:43'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'Intel Core i3-10100', 4, 8, 16, 'Dell OptiPlex 7000', 256, id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:6F:74:44';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 178 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:6F:74:44')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 178 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:6F:74:44')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 178 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:6F:74:44')),
  ('ESET Endpoint Security', '11.0', 'ESET', @ahora - INTERVAL 178 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:6F:74:44')),
  ('7-Zip', '24.08', 'Igor Pavlov', @ahora - INTERVAL 178 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:6F:74:44'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0538492', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:6F:74:44')), ('Teclado', 'Dell KB216', 'KB121579', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:6F:74:44'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'AMD Ryzen 5 5600G', 6, 12, 16, 'HP ProDesk 400 G7', 512, id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:94:81:45';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 189 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:94:81:45')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 189 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:94:81:45')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 189 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:94:81:45'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0546411', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:94:81:45')), ('Teclado', 'Dell KB216', 'KB226308', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:94:81:45'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'Intel Core i5-12500', 6, 12, 16, 'Lenovo ThinkCentre M70s', 512, id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:B9:8E:46';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 200 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:B9:8E:46')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 200 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:B9:8E:46')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 200 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:B9:8E:46')),
  ('ESET Endpoint Security', '11.0', 'ESET', @ahora - INTERVAL 200 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:B9:8E:46'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0554330', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:B9:8E:46')), ('Teclado', 'Dell KB216', 'KB331037', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:B9:8E:46'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'Intel Core i5-10500', 6, 12, 32, 'Dell OptiPlex 3080', 1000, id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:DE:9B:47';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 211 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:DE:9B:47')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 211 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:DE:9B:47')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 211 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:DE:9B:47')),
  ('ESET Endpoint Security', '11.0', 'ESET', @ahora - INTERVAL 211 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:DE:9B:47')),
  ('7-Zip', '24.08', 'Igor Pavlov', @ahora - INTERVAL 211 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:DE:9B:47'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0562249', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:DE:9B:47')), ('Teclado', 'Dell KB216', 'KB435766', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:DE:9B:47'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'Intel Core i7-12700', 12, 20, 8, 'Dell OptiPlex 7000', 256, id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:03:A8:48';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 222 DAY, 1, 0, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:03:A8:48')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 222 DAY, 1, 0, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:03:A8:48')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 222 DAY, 1, 0, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:03:A8:48')),
  ('uTorrent', '3.6', 'BitTorrent Inc.', @ahora - INTERVAL 15 DAY, 0, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:03:A8:48'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0570168', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:03:A8:48')), ('Teclado', 'Dell KB216', 'KB540495', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:03:A8:48'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'Intel Core i3-10100', 4, 8, 8, 'HP ProDesk 400 G7', 512, id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:28:B5:49';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 233 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:28:B5:49')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 233 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:28:B5:49')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 233 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:28:B5:49')),
  ('ESET Endpoint Security', '11.0', 'ESET', @ahora - INTERVAL 233 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:28:B5:49'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0578087', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:28:B5:49')), ('Teclado', 'Dell KB216', 'KB645224', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:28:B5:49'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'AMD Ryzen 5 5600G', 6, 12, 16, 'Lenovo ThinkCentre M70s', 512, id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:4D:C2:4A';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 244 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:4D:C2:4A')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 244 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:4D:C2:4A')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 244 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:4D:C2:4A')),
  ('ESET Endpoint Security', '11.0', 'ESET', @ahora - INTERVAL 244 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:4D:C2:4A')),
  ('7-Zip', '24.08', 'Igor Pavlov', @ahora - INTERVAL 244 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:4D:C2:4A'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0586006', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:4D:C2:4A')), ('Teclado', 'Dell KB216', 'KB749953', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:4D:C2:4A'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'Intel Core i5-12500', 6, 12, 16, 'Dell OptiPlex 3080', 1000, id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:72:CF:4B';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 255 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:72:CF:4B')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 255 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:72:CF:4B')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 255 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:72:CF:4B'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0593925', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:72:CF:4B')), ('Teclado', 'Dell KB216', 'KB854682', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:72:CF:4B'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'Intel Core i5-10500', 6, 12, 16, 'Dell OptiPlex 7000', 256, id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:97:DC:4C';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 266 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:97:DC:4C')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 266 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:97:DC:4C')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 266 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:97:DC:4C')),
  ('ESET Endpoint Security', '11.0', 'ESET', @ahora - INTERVAL 266 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:97:DC:4C'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0601844', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:97:DC:4C')), ('Teclado', 'Dell KB216', 'KB959411', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:97:DC:4C'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'Intel Core i7-12700', 12, 20, 32, 'HP ProDesk 400 G7', 512, id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:00:E9:4D';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 277 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:00:E9:4D')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 277 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:00:E9:4D')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 277 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:00:E9:4D')),
  ('ESET Endpoint Security', '11.0', 'ESET', @ahora - INTERVAL 277 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:00:E9:4D')),
  ('7-Zip', '24.08', 'Igor Pavlov', @ahora - INTERVAL 277 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:00:E9:4D'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0609763', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:00:E9:4D')), ('Teclado', 'Dell KB216', 'KB064141', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:00:E9:4D'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'Intel Core i3-10100', 4, 8, 8, 'Lenovo ThinkCentre M70s', 512, id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:25:F6:4E';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 288 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:25:F6:4E')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 288 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:25:F6:4E')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 288 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:25:F6:4E'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0617682', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:25:F6:4E')), ('Teclado', 'Dell KB216', 'KB168870', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:25:F6:4E'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'AMD Ryzen 5 5600G', 6, 12, 8, 'Dell OptiPlex 3080', 1000, id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:4A:03:4F';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 299 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:4A:03:4F')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 299 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:4A:03:4F')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 299 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:4A:03:4F')),
  ('ESET Endpoint Security', '11.0', 'ESET', @ahora - INTERVAL 299 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:4A:03:4F'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0625601', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:4A:03:4F')), ('Teclado', 'Dell KB216', 'KB273599', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:4A:03:4F'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'Intel Core i5-12500', 6, 12, 16, 'Dell OptiPlex 7000', 256, id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:6F:10:50';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 310 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:6F:10:50')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 310 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:6F:10:50')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 310 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:6F:10:50')),
  ('ESET Endpoint Security', '11.0', 'ESET', @ahora - INTERVAL 310 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:6F:10:50')),
  ('7-Zip', '24.08', 'Igor Pavlov', @ahora - INTERVAL 310 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:6F:10:50')),
  ('Juegos Steam', '2.10', 'Valve', @ahora - INTERVAL 3 DAY, 0, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:6F:10:50'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0633520', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:6F:10:50')), ('Teclado', 'Dell KB216', 'KB378328', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:6F:10:50'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'Intel Core i5-10500', 6, 12, 16, 'HP ProDesk 400 G7', 512, id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:94:1D:51';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 321 DAY, 1, 0, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:94:1D:51')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 321 DAY, 1, 0, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:94:1D:51')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 321 DAY, 1, 0, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:94:1D:51'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0641439', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:94:1D:51')), ('Teclado', 'Dell KB216', 'KB483057', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:94:1D:51'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'Intel Core i7-12700', 12, 20, 16, 'Lenovo ThinkCentre M70s', 512, id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:B9:2A:52';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 32 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:B9:2A:52')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 32 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:B9:2A:52')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 32 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:B9:2A:52')),
  ('ESET Endpoint Security', '11.0', 'ESET', @ahora - INTERVAL 32 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:B9:2A:52'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0649358', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:B9:2A:52')), ('Teclado', 'Dell KB216', 'KB587786', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:B9:2A:52'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'Intel Core i3-10100', 4, 8, 32, 'Dell OptiPlex 3080', 1000, id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:DE:37:53';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 43 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:DE:37:53')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 43 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:DE:37:53')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 43 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:DE:37:53')),
  ('ESET Endpoint Security', '11.0', 'ESET', @ahora - INTERVAL 43 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:DE:37:53')),
  ('7-Zip', '24.08', 'Igor Pavlov', @ahora - INTERVAL 43 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:DE:37:53'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0657277', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:DE:37:53')), ('Teclado', 'Dell KB216', 'KB692515', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:DE:37:53'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'AMD Ryzen 5 5600G', 6, 12, 8, 'Dell OptiPlex 7000', 256, id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:03:44:54';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 54 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:03:44:54')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 54 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:03:44:54')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 54 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:03:44:54'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0665196', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:03:44:54')), ('Teclado', 'Dell KB216', 'KB797244', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:03:44:54'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'Intel Core i5-12500', 6, 12, 8, 'HP ProDesk 400 G7', 512, id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:28:51:55';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 65 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:28:51:55')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 65 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:28:51:55')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 65 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:28:51:55')),
  ('ESET Endpoint Security', '11.0', 'ESET', @ahora - INTERVAL 65 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:28:51:55'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0673115', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:28:51:55')), ('Teclado', 'Dell KB216', 'KB901973', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:28:51:55'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'Intel Core i5-10500', 6, 12, 16, 'Lenovo ThinkCentre M70s', 512, id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:4D:5E:56';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 76 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:4D:5E:56')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 76 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:4D:5E:56')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 76 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:4D:5E:56')),
  ('ESET Endpoint Security', '11.0', 'ESET', @ahora - INTERVAL 76 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:4D:5E:56')),
  ('7-Zip', '24.08', 'Igor Pavlov', @ahora - INTERVAL 76 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:4D:5E:56'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0681034', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:4D:5E:56')), ('Teclado', 'Dell KB216', 'KB006703', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:4D:5E:56'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'Intel Core i7-12700', 12, 20, 16, 'Dell OptiPlex 3080', 1000, id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:72:6B:57';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 87 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:72:6B:57')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 87 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:72:6B:57')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 87 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:72:6B:57'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0688953', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:72:6B:57')), ('Teclado', 'Dell KB216', 'KB111432', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:72:6B:57'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'Intel Core i3-10100', 4, 8, 16, 'Dell OptiPlex 7000', 256, id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:97:78:58';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 98 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:97:78:58')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 98 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:97:78:58')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 98 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:97:78:58')),
  ('ESET Endpoint Security', '11.0', 'ESET', @ahora - INTERVAL 98 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:97:78:58')),
  ('AnyDesk', '8.1', 'AnyDesk Software', @ahora - INTERVAL 11 DAY, 0, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:97:78:58'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0696872', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:97:78:58')), ('Teclado', 'Dell KB216', 'KB216161', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:97:78:58'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'AMD Ryzen 5 5600G', 6, 12, 32, 'HP ProDesk 400 G7', 512, id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:BC:85:59';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 109 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:BC:85:59')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 109 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:BC:85:59')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 109 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:BC:85:59')),
  ('ESET Endpoint Security', '11.0', 'ESET', @ahora - INTERVAL 109 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:BC:85:59')),
  ('7-Zip', '24.08', 'Igor Pavlov', @ahora - INTERVAL 109 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:BC:85:59'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0704791', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:BC:85:59')), ('Teclado', 'Dell KB216', 'KB320890', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:BC:85:59'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'Intel Core i5-12500', 6, 12, 8, 'Lenovo ThinkCentre M70s', 512, id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:E1:92:5A';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 120 DAY, 1, 0, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:E1:92:5A')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 120 DAY, 1, 0, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:E1:92:5A')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 120 DAY, 1, 0, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:E1:92:5A'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0712710', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:E1:92:5A')), ('Teclado', 'Dell KB216', 'KB425619', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:E1:92:5A'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'Intel Core i5-10500', 6, 12, 8, 'Dell OptiPlex 3080', 1000, id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:00:9F:5B';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 131 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:00:9F:5B')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 131 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:00:9F:5B')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 131 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:00:9F:5B')),
  ('ESET Endpoint Security', '11.0', 'ESET', @ahora - INTERVAL 131 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:00:9F:5B'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0720629', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:00:9F:5B')), ('Teclado', 'Dell KB216', 'KB530348', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:00:9F:5B'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'Intel Core i7-12700', 12, 20, 16, 'Dell OptiPlex 7000', 256, id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:25:AC:5C';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 142 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:25:AC:5C')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 142 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:25:AC:5C')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 142 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:25:AC:5C')),
  ('ESET Endpoint Security', '11.0', 'ESET', @ahora - INTERVAL 142 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:25:AC:5C')),
  ('7-Zip', '24.08', 'Igor Pavlov', @ahora - INTERVAL 142 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:25:AC:5C'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0728548', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:25:AC:5C')), ('Teclado', 'Dell KB216', 'KB635077', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:25:AC:5C'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'Intel Core i3-10100', 4, 8, 16, 'HP ProDesk 400 G7', 512, id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:4A:B9:5D';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 153 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:4A:B9:5D')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 153 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:4A:B9:5D')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 153 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:4A:B9:5D'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0736467', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:4A:B9:5D')), ('Teclado', 'Dell KB216', 'KB739806', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:4A:B9:5D'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'AMD Ryzen 5 5600G', 6, 12, 16, 'Lenovo ThinkCentre M70s', 512, id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:6F:C6:5E';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 164 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:6F:C6:5E')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 164 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:6F:C6:5E')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 164 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:6F:C6:5E')),
  ('ESET Endpoint Security', '11.0', 'ESET', @ahora - INTERVAL 164 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:6F:C6:5E'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0744386', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:6F:C6:5E')), ('Teclado', 'Dell KB216', 'KB844535', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:6F:C6:5E'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'Intel Core i5-12500', 6, 12, 32, 'Dell OptiPlex 3080', 1000, id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:94:D3:5F';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 175 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:94:D3:5F')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 175 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:94:D3:5F')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 175 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:94:D3:5F')),
  ('ESET Endpoint Security', '11.0', 'ESET', @ahora - INTERVAL 175 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:94:D3:5F')),
  ('7-Zip', '24.08', 'Igor Pavlov', @ahora - INTERVAL 175 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:94:D3:5F'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0752305', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:94:D3:5F')), ('Teclado', 'Dell KB216', 'KB949264', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:94:D3:5F'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'Intel Core i5-10500', 6, 12, 8, 'Dell OptiPlex 7000', 256, id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:B9:E0:60';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 186 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:B9:E0:60')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 186 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:B9:E0:60')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 186 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:B9:E0:60')),
  ('uTorrent', '3.6', 'BitTorrent Inc.', @ahora - INTERVAL 19 DAY, 0, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:B9:E0:60'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0760224', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:B9:E0:60')), ('Teclado', 'Dell KB216', 'KB053994', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:B9:E0:60'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'Intel Core i7-12700', 12, 20, 8, 'HP ProDesk 400 G7', 512, id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:DE:ED:61';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 197 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:DE:ED:61')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 197 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:DE:ED:61')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 197 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:DE:ED:61')),
  ('ESET Endpoint Security', '11.0', 'ESET', @ahora - INTERVAL 197 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:DE:ED:61'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0768143', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:DE:ED:61')), ('Teclado', 'Dell KB216', 'KB158723', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:DE:ED:61'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'Intel Core i3-10100', 4, 8, 16, 'Lenovo ThinkCentre M70s', 512, id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:03:FA:62';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 208 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:03:FA:62')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 208 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:03:FA:62')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 208 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:03:FA:62')),
  ('ESET Endpoint Security', '11.0', 'ESET', @ahora - INTERVAL 208 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:03:FA:62')),
  ('7-Zip', '24.08', 'Igor Pavlov', @ahora - INTERVAL 208 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:03:FA:62'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0776062', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:03:FA:62')), ('Teclado', 'Dell KB216', 'KB263452', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:03:FA:62'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'AMD Ryzen 5 5600G', 6, 12, 16, 'Dell OptiPlex 3080', 1000, id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:28:07:63';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 219 DAY, 1, 0, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:28:07:63')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 219 DAY, 1, 0, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:28:07:63')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 219 DAY, 1, 0, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:28:07:63'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0783981', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:28:07:63')), ('Teclado', 'Dell KB216', 'KB368181', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:28:07:63'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'Intel Core i5-12500', 6, 12, 16, 'Dell OptiPlex 7000', 256, id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:4D:14:64';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 230 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:4D:14:64')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 230 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:4D:14:64')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 230 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:4D:14:64')),
  ('ESET Endpoint Security', '11.0', 'ESET', @ahora - INTERVAL 230 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:4D:14:64'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0791900', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:4D:14:64')), ('Teclado', 'Dell KB216', 'KB472910', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:4D:14:64'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'Intel Core i5-10500', 6, 12, 32, 'HP ProDesk 400 G7', 512, id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:00:21:65';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 241 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:00:21:65')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 241 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:00:21:65')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 241 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:00:21:65')),
  ('ESET Endpoint Security', '11.0', 'ESET', @ahora - INTERVAL 241 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:00:21:65')),
  ('7-Zip', '24.08', 'Igor Pavlov', @ahora - INTERVAL 241 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:00:21:65'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0799819', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:00:21:65')), ('Teclado', 'Dell KB216', 'KB577639', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:00:21:65'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'Intel Core i7-12700', 12, 20, 8, 'Lenovo ThinkCentre M70s', 512, id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:25:2E:66';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 252 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:25:2E:66')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 252 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:25:2E:66')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 252 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:25:2E:66'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0807738', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:25:2E:66')), ('Teclado', 'Dell KB216', 'KB682368', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:25:2E:66'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'Intel Core i3-10100', 4, 8, 8, 'Dell OptiPlex 3080', 1000, id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:4A:3B:67';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 263 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:4A:3B:67')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 263 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:4A:3B:67')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 263 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:4A:3B:67')),
  ('ESET Endpoint Security', '11.0', 'ESET', @ahora - INTERVAL 263 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:4A:3B:67'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0815657', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:4A:3B:67')), ('Teclado', 'Dell KB216', 'KB787097', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:4A:3B:67'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'AMD Ryzen 5 5600G', 6, 12, 16, 'Dell OptiPlex 7000', 256, id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:6F:48:68';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 274 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:6F:48:68')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 274 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:6F:48:68')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 274 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:6F:48:68')),
  ('ESET Endpoint Security', '11.0', 'ESET', @ahora - INTERVAL 274 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:6F:48:68')),
  ('7-Zip', '24.08', 'Igor Pavlov', @ahora - INTERVAL 274 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:6F:48:68')),
  ('Juegos Steam', '2.10', 'Valve', @ahora - INTERVAL 7 DAY, 0, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:6F:48:68'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0823576', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:6F:48:68')), ('Teclado', 'Dell KB216', 'KB891826', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:6F:48:68'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'Intel Core i5-12500', 6, 12, 16, 'HP ProDesk 400 G7', 512, id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:94:55:69';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 285 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:94:55:69')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 285 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:94:55:69')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 285 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:94:55:69'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0831495', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:94:55:69')), ('Teclado', 'Dell KB216', 'KB996555', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:94:55:69'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'Intel Core i5-10500', 6, 12, 16, 'Lenovo ThinkCentre M70s', 512, id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:B9:62:6A';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 296 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:B9:62:6A')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 296 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:B9:62:6A')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 296 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:B9:62:6A')),
  ('ESET Endpoint Security', '11.0', 'ESET', @ahora - INTERVAL 296 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:B9:62:6A'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0839414', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:B9:62:6A')), ('Teclado', 'Dell KB216', 'KB101285', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:B9:62:6A'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'Intel Core i7-12700', 12, 20, 32, 'Dell OptiPlex 3080', 1000, id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:DE:6F:6B';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 307 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:DE:6F:6B')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 307 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:DE:6F:6B')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 307 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:DE:6F:6B')),
  ('ESET Endpoint Security', '11.0', 'ESET', @ahora - INTERVAL 307 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:DE:6F:6B')),
  ('7-Zip', '24.08', 'Igor Pavlov', @ahora - INTERVAL 307 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:DE:6F:6B'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0847333', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:DE:6F:6B')), ('Teclado', 'Dell KB216', 'KB206014', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:DE:6F:6B'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'Intel Core i3-10100', 4, 8, 8, 'Dell OptiPlex 7000', 256, id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:03:7C:6C';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 318 DAY, 1, 0, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:03:7C:6C')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 318 DAY, 1, 0, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:03:7C:6C')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 318 DAY, 1, 0, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:03:7C:6C'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0855252', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:03:7C:6C')), ('Teclado', 'Dell KB216', 'KB310743', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:03:7C:6C'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'AMD Ryzen 5 5600G', 6, 12, 8, 'HP ProDesk 400 G7', 512, id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:28:89:6D';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 329 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:28:89:6D')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 329 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:28:89:6D')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 329 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:28:89:6D')),
  ('ESET Endpoint Security', '11.0', 'ESET', @ahora - INTERVAL 329 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:28:89:6D'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0863171', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:28:89:6D')), ('Teclado', 'Dell KB216', 'KB415472', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:28:89:6D'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'Intel Core i5-12500', 6, 12, 16, 'Lenovo ThinkCentre M70s', 512, id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:4D:96:6E';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 40 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:4D:96:6E')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 40 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:4D:96:6E')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 40 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:4D:96:6E')),
  ('ESET Endpoint Security', '11.0', 'ESET', @ahora - INTERVAL 40 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:4D:96:6E')),
  ('7-Zip', '24.08', 'Igor Pavlov', @ahora - INTERVAL 40 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:4D:96:6E'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0871090', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:4D:96:6E')), ('Teclado', 'Dell KB216', 'KB520201', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:4D:96:6E'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'Intel Core i5-10500', 6, 12, 16, 'Dell OptiPlex 3080', 1000, id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:00:A3:6F';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 51 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:00:A3:6F')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 51 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:00:A3:6F')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 51 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:00:A3:6F'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0879009', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:00:A3:6F')), ('Teclado', 'Dell KB216', 'KB624930', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:00:A3:6F'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'Intel Core i7-12700', 12, 20, 16, 'Dell OptiPlex 7000', 256, id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:25:B0:70';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 62 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:25:B0:70')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 62 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:25:B0:70')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 62 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:25:B0:70')),
  ('ESET Endpoint Security', '11.0', 'ESET', @ahora - INTERVAL 62 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:25:B0:70')),
  ('AnyDesk', '8.1', 'AnyDesk Software', @ahora - INTERVAL 15 DAY, 0, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:25:B0:70'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0886928', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:25:B0:70')), ('Teclado', 'Dell KB216', 'KB729659', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:25:B0:70'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'Intel Core i3-10100', 4, 8, 32, 'HP ProDesk 400 G7', 512, id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:4A:BD:71';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 73 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:4A:BD:71')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 73 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:4A:BD:71')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 73 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:4A:BD:71')),
  ('ESET Endpoint Security', '11.0', 'ESET', @ahora - INTERVAL 73 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:4A:BD:71')),
  ('7-Zip', '24.08', 'Igor Pavlov', @ahora - INTERVAL 73 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:4A:BD:71'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0894847', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:4A:BD:71')), ('Teclado', 'Dell KB216', 'KB834388', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:4A:BD:71'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'AMD Ryzen 5 5600G', 6, 12, 8, 'Lenovo ThinkCentre M70s', 512, id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:6F:CA:72';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 84 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:6F:CA:72')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 84 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:6F:CA:72')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 84 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:6F:CA:72'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0902766', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:6F:CA:72')), ('Teclado', 'Dell KB216', 'KB939117', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:6F:CA:72'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'Intel Core i5-12500', 6, 12, 8, 'Dell OptiPlex 3080', 1000, id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:94:D7:73';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 95 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:94:D7:73')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 95 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:94:D7:73')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 95 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:94:D7:73')),
  ('ESET Endpoint Security', '11.0', 'ESET', @ahora - INTERVAL 95 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:94:D7:73'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0910685', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:94:D7:73')), ('Teclado', 'Dell KB216', 'KB043847', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:94:D7:73'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'Intel Core i5-10500', 6, 12, 16, 'Dell OptiPlex 7000', 256, id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:B9:E4:74';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 106 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:B9:E4:74')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 106 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:B9:E4:74')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 106 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:B9:E4:74')),
  ('ESET Endpoint Security', '11.0', 'ESET', @ahora - INTERVAL 106 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:B9:E4:74')),
  ('7-Zip', '24.08', 'Igor Pavlov', @ahora - INTERVAL 106 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:B9:E4:74'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0918604', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:B9:E4:74')), ('Teclado', 'Dell KB216', 'KB148576', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:B9:E4:74'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'Intel Core i7-12700', 12, 20, 16, 'HP ProDesk 400 G7', 512, id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:DE:F1:75';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 117 DAY, 1, 0, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:DE:F1:75')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 117 DAY, 1, 0, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:DE:F1:75')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 117 DAY, 1, 0, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:DE:F1:75'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0926523', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:DE:F1:75')), ('Teclado', 'Dell KB216', 'KB253305', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:DE:F1:75'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'Intel Core i3-10100', 4, 8, 16, 'Lenovo ThinkCentre M70s', 512, id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:03:FE:76';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 128 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:03:FE:76')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 128 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:03:FE:76')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 128 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:03:FE:76')),
  ('ESET Endpoint Security', '11.0', 'ESET', @ahora - INTERVAL 128 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:03:FE:76'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0934442', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:03:FE:76')), ('Teclado', 'Dell KB216', 'KB358034', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:03:FE:76'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'AMD Ryzen 5 5600G', 6, 12, 32, 'Dell OptiPlex 3080', 1000, id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:00:0B:77';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 139 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:00:0B:77')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 139 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:00:0B:77')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 139 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:00:0B:77')),
  ('ESET Endpoint Security', '11.0', 'ESET', @ahora - INTERVAL 139 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:00:0B:77')),
  ('7-Zip', '24.08', 'Igor Pavlov', @ahora - INTERVAL 139 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:00:0B:77'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0942361', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:00:0B:77')), ('Teclado', 'Dell KB216', 'KB462763', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:00:0B:77'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'Intel Core i5-12500', 6, 12, 8, 'Dell OptiPlex 7000', 256, id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:25:18:78';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 150 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:25:18:78')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 150 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:25:18:78')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 150 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:25:18:78')),
  ('uTorrent', '3.6', 'BitTorrent Inc.', @ahora - INTERVAL 3 DAY, 0, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:25:18:78'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0950280', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:25:18:78')), ('Teclado', 'Dell KB216', 'KB567492', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:25:18:78'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'Intel Core i5-10500', 6, 12, 8, 'HP ProDesk 400 G7', 512, id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:4A:25:79';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 161 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:4A:25:79')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 161 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:4A:25:79')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 161 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:4A:25:79')),
  ('ESET Endpoint Security', '11.0', 'ESET', @ahora - INTERVAL 161 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:4A:25:79'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0958199', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:4A:25:79')), ('Teclado', 'Dell KB216', 'KB672221', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:4A:25:79'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'Intel Core i7-12700', 12, 20, 16, 'Lenovo ThinkCentre M70s', 512, id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:6F:32:7A';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 172 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:6F:32:7A')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 172 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:6F:32:7A')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 172 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:6F:32:7A')),
  ('ESET Endpoint Security', '11.0', 'ESET', @ahora - INTERVAL 172 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:6F:32:7A')),
  ('7-Zip', '24.08', 'Igor Pavlov', @ahora - INTERVAL 172 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:6F:32:7A'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0966118', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:6F:32:7A')), ('Teclado', 'Dell KB216', 'KB776950', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:6F:32:7A'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'Intel Core i3-10100', 4, 8, 16, 'Dell OptiPlex 3080', 1000, id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:94:3F:7B';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 183 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:94:3F:7B')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 183 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:94:3F:7B')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 183 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:94:3F:7B'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0974037', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:94:3F:7B')), ('Teclado', 'Dell KB216', 'KB881679', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:94:3F:7B'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'AMD Ryzen 5 5600G', 6, 12, 16, 'Dell OptiPlex 7000', 256, id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:B9:4C:7C';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 194 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:B9:4C:7C')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 194 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:B9:4C:7C')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 194 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:B9:4C:7C')),
  ('ESET Endpoint Security', '11.0', 'ESET', @ahora - INTERVAL 194 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:B9:4C:7C'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0981956', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:B9:4C:7C')), ('Teclado', 'Dell KB216', 'KB986408', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:B9:4C:7C'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'Intel Core i5-12500', 6, 12, 32, 'HP ProDesk 400 G7', 512, id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:DE:59:7D';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 205 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:DE:59:7D')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 205 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:DE:59:7D')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 205 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:DE:59:7D')),
  ('ESET Endpoint Security', '11.0', 'ESET', @ahora - INTERVAL 205 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:DE:59:7D')),
  ('7-Zip', '24.08', 'Igor Pavlov', @ahora - INTERVAL 205 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:DE:59:7D'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0989875', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:DE:59:7D')), ('Teclado', 'Dell KB216', 'KB091138', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:DE:59:7D'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'Intel Core i5-10500', 6, 12, 8, 'Lenovo ThinkCentre M70s', 512, id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:03:66:7E';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 216 DAY, 1, 0, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:03:66:7E')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 216 DAY, 1, 0, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:03:66:7E')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 216 DAY, 1, 0, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:03:66:7E'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0997794', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:03:66:7E')), ('Teclado', 'Dell KB216', 'KB195867', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:03:66:7E'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'Intel Core i7-12700', 12, 20, 8, 'Dell OptiPlex 3080', 1000, id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:00:73:7F';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 227 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:00:73:7F')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 227 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:00:73:7F')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 227 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:00:73:7F')),
  ('ESET Endpoint Security', '11.0', 'ESET', @ahora - INTERVAL 227 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:00:73:7F'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0005714', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:00:73:7F')), ('Teclado', 'Dell KB216', 'KB300596', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:00:73:7F'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'Intel Core i3-10100', 4, 8, 16, 'Dell OptiPlex 7000', 256, id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:25:80:80';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 238 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:25:80:80')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 238 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:25:80:80')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 238 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:25:80:80')),
  ('ESET Endpoint Security', '11.0', 'ESET', @ahora - INTERVAL 238 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:25:80:80')),
  ('7-Zip', '24.08', 'Igor Pavlov', @ahora - INTERVAL 238 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:25:80:80')),
  ('Juegos Steam', '2.10', 'Valve', @ahora - INTERVAL 11 DAY, 0, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:25:80:80'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0013633', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:25:80:80')), ('Teclado', 'Dell KB216', 'KB405325', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:25:80:80'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'AMD Ryzen 5 5600G', 6, 12, 16, 'HP ProDesk 400 G7', 512, id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:4A:8D:81';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 249 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:4A:8D:81')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 249 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:4A:8D:81')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 249 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:4A:8D:81'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0021552', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:4A:8D:81')), ('Teclado', 'Dell KB216', 'KB510054', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:4A:8D:81'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'Intel Core i5-12500', 6, 12, 16, 'Lenovo ThinkCentre M70s', 512, id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:6F:9A:82';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 260 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:6F:9A:82')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 260 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:6F:9A:82')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 260 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:6F:9A:82')),
  ('ESET Endpoint Security', '11.0', 'ESET', @ahora - INTERVAL 260 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:6F:9A:82'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0029471', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:6F:9A:82')), ('Teclado', 'Dell KB216', 'KB614783', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:6F:9A:82'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'Intel Core i5-10500', 6, 12, 32, 'Dell OptiPlex 3080', 1000, id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:94:A7:83';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 271 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:94:A7:83')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 271 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:94:A7:83')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 271 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:94:A7:83')),
  ('ESET Endpoint Security', '11.0', 'ESET', @ahora - INTERVAL 271 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:94:A7:83')),
  ('7-Zip', '24.08', 'Igor Pavlov', @ahora - INTERVAL 271 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:94:A7:83'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0037390', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:94:A7:83')), ('Teclado', 'Dell KB216', 'KB719512', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:94:A7:83'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'Intel Core i7-12700', 12, 20, 8, 'Dell OptiPlex 7000', 256, id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:B9:B4:84';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 282 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:B9:B4:84')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 282 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:B9:B4:84')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 282 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:B9:B4:84'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0045309', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:B9:B4:84')), ('Teclado', 'Dell KB216', 'KB824241', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:B9:B4:84'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'Intel Core i3-10100', 4, 8, 8, 'HP ProDesk 400 G7', 512, id_equipo FROM equipo WHERE direccion_mac = '02:5E:02:00:C1:85';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 293 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:02:00:C1:85')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 293 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:02:00:C1:85')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 293 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:02:00:C1:85')),
  ('ESET Endpoint Security', '11.0', 'ESET', @ahora - INTERVAL 293 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:02:00:C1:85'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0053228', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:02:00:C1:85')), ('Teclado', 'Dell KB216', 'KB928970', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:02:00:C1:85'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'AMD Ryzen 5 5600G', 6, 12, 16, 'Lenovo ThinkCentre M70s', 512, id_equipo FROM equipo WHERE direccion_mac = '02:5E:02:25:CE:86';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 304 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:02:25:CE:86')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 304 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:02:25:CE:86')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 304 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:02:25:CE:86')),
  ('ESET Endpoint Security', '11.0', 'ESET', @ahora - INTERVAL 304 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:02:25:CE:86')),
  ('7-Zip', '24.08', 'Igor Pavlov', @ahora - INTERVAL 304 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:02:25:CE:86'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0061147', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:02:25:CE:86')), ('Teclado', 'Dell KB216', 'KB033700', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:02:25:CE:86'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'Intel Core i5-12500', 6, 12, 16, 'Dell OptiPlex 3080', 1000, id_equipo FROM equipo WHERE direccion_mac = '02:5E:02:4A:DB:87';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 315 DAY, 1, 0, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:02:4A:DB:87')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 315 DAY, 1, 0, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:02:4A:DB:87')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 315 DAY, 1, 0, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:02:4A:DB:87'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0069066', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:02:4A:DB:87')), ('Teclado', 'Dell KB216', 'KB138429', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:02:4A:DB:87'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'Intel Core i5-10500', 6, 12, 16, 'Dell OptiPlex 7000', 256, id_equipo FROM equipo WHERE direccion_mac = '02:5E:02:6F:E8:88';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 326 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:02:6F:E8:88')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 326 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:02:6F:E8:88')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 326 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:02:6F:E8:88')),
  ('ESET Endpoint Security', '11.0', 'ESET', @ahora - INTERVAL 326 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:02:6F:E8:88')),
  ('AnyDesk', '8.1', 'AnyDesk Software', @ahora - INTERVAL 19 DAY, 0, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:02:6F:E8:88'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0076985', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:02:6F:E8:88')), ('Teclado', 'Dell KB216', 'KB243158', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:02:6F:E8:88'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'Intel Core i7-12700', 12, 20, 32, 'HP ProDesk 400 G7', 512, id_equipo FROM equipo WHERE direccion_mac = '02:5E:02:94:F5:89';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 37 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:02:94:F5:89')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 37 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:02:94:F5:89')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 37 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:02:94:F5:89')),
  ('ESET Endpoint Security', '11.0', 'ESET', @ahora - INTERVAL 37 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:02:94:F5:89')),
  ('7-Zip', '24.08', 'Igor Pavlov', @ahora - INTERVAL 37 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:02:94:F5:89'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0084904', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:02:94:F5:89')), ('Teclado', 'Dell KB216', 'KB347887', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:02:94:F5:89'));
INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo) SELECT 'Intel Core i3-10100', 4, 8, 8, 'Lenovo ThinkCentre M70s', 512, id_equipo FROM equipo WHERE direccion_mac = '02:5E:02:B9:02:8A';
INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES
  ('Microsoft Office LTSC', '2021', 'Microsoft', @ahora - INTERVAL 48 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:02:B9:02:8A')),
  ('Google Chrome', '131.0', 'Google', @ahora - INTERVAL 48 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:02:B9:02:8A')),
  ('Adobe Acrobat Reader', '2024.004', 'Adobe', @ahora - INTERVAL 48 DAY, 1, 1, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:02:B9:02:8A'));
INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', 'CN0092823', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:02:B9:02:8A')), ('Teclado', 'Dell KB216', 'KB452616', (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:02:B9:02:8A'));

-- ---------- 5. Lecturas del agente ----------
-- Última lectura de cada equipo que ha reportado (con su disco C:) y 24 h de historial
-- (una por hora) para los que están en línea o con alerta.
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES
  (13.6, 4.21, 207.2, 68.9, 153, @ahora - INTERVAL 24 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:00:0D:01')),
  (49.6, 5.31, 250.5, 34.2, 213, @ahora - INTERVAL 23 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:00:0D:01')),
  (33.7, 4.85, 308.4, 60.3, 215, @ahora - INTERVAL 22 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:00:0D:01')),
  (28.7, 2.81, 36.9, 23.7, 152, @ahora - INTERVAL 21 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:00:0D:01')),
  (29.1, 5.08, 275.6, 54.7, 166, @ahora - INTERVAL 20 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:00:0D:01')),
  (26.7, 3.77, 399.6, 29.2, 188, @ahora - INTERVAL 19 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:00:0D:01')),
  (55.0, 4.24, 35.1, 27.9, 211, @ahora - INTERVAL 18 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:00:0D:01')),
  (33.3, 3.61, 60.7, 51.9, 231, @ahora - INTERVAL 17 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:00:0D:01')),
  (35.1, 2.87, 285.8, 29.7, 194, @ahora - INTERVAL 16 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:00:0D:01')),
  (37.3, 5.29, 224.0, 69.5, 194, @ahora - INTERVAL 15 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:00:0D:01')),
  (56.8, 4.9, 242.1, 39.8, 257, @ahora - INTERVAL 14 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:00:0D:01')),
  (57.7, 5.16, 227.8, 78.6, 205, @ahora - INTERVAL 13 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:00:0D:01')),
  (57.3, 2.87, 93.7, 11.2, 146, @ahora - INTERVAL 12 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:00:0D:01')),
  (78.2, 4.27, 269.8, 57.7, 194, @ahora - INTERVAL 11 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:00:0D:01')),
  (55.1, 4.15, 95.4, 71.0, 220, @ahora - INTERVAL 10 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:00:0D:01')),
  (65.9, 4.69, 287.2, 76.8, 209, @ahora - INTERVAL 9 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:00:0D:01')),
  (19.8, 3.93, 399.3, 44.3, 222, @ahora - INTERVAL 8 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:00:0D:01')),
  (31.6, 4.14, 354.4, 35.2, 177, @ahora - INTERVAL 7 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:00:0D:01')),
  (47.1, 2.83, 64.2, 70.7, 198, @ahora - INTERVAL 6 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:00:0D:01')),
  (45.8, 5.4, 147.2, 16.8, 228, @ahora - INTERVAL 5 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:00:0D:01')),
  (30.8, 4.23, 331.3, 64.8, 211, @ahora - INTERVAL 4 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:00:0D:01')),
  (39.2, 2.89, 119.6, 37.2, 243, @ahora - INTERVAL 3 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:00:0D:01')),
  (12.6, 4.73, 315.1, 41.7, 197, @ahora - INTERVAL 2 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:00:0D:01')),
  (51.3, 3.31, 173.2, 58.5, 260, @ahora - INTERVAL 1 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:00:0D:01'));
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES (13.2, 3.55, 43.2, 60.1, 192, (SELECT ultima_senal FROM equipo WHERE direccion_mac = '02:5E:0B:00:0D:01'), (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:00:0D:01'));
INSERT INTO almacenamiento (punto_montaje, capacidad_total_gb, espacio_libre_gb, id_informe) VALUES ('C:', 512, 242.8, LAST_INSERT_ID());
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES
  (14.9, 10.73, 41.4, 36.6, 209, @ahora - INTERVAL 24 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:25:1A:02')),
  (51.8, 6.07, 318.5, 20.6, 219, @ahora - INTERVAL 23 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:25:1A:02')),
  (10.1, 8.66, 111.1, 60.9, 185, @ahora - INTERVAL 22 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:25:1A:02')),
  (15.3, 7.36, 235.3, 61.8, 250, @ahora - INTERVAL 21 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:25:1A:02')),
  (31.1, 9.63, 58.3, 18.6, 215, @ahora - INTERVAL 20 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:25:1A:02')),
  (14.2, 8.95, 278.6, 24.0, 193, @ahora - INTERVAL 19 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:25:1A:02')),
  (39.4, 10.84, 314.5, 73.3, 179, @ahora - INTERVAL 18 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:25:1A:02')),
  (31.9, 7.79, 63.7, 64.7, 188, @ahora - INTERVAL 17 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:25:1A:02')),
  (8.7, 6.19, 355.7, 5.1, 184, @ahora - INTERVAL 16 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:25:1A:02')),
  (63.4, 10.83, 378.3, 3.0, 200, @ahora - INTERVAL 15 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:25:1A:02')),
  (48.4, 7.3, 133.8, 10.6, 199, @ahora - INTERVAL 14 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:25:1A:02')),
  (59.9, 10.11, 65.8, 42.0, 195, @ahora - INTERVAL 13 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:25:1A:02')),
  (62.3, 8.17, 97.2, 57.2, 210, @ahora - INTERVAL 12 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:25:1A:02')),
  (51.8, 6.69, 369.0, 4.6, 209, @ahora - INTERVAL 11 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:25:1A:02')),
  (76.8, 5.87, 347.9, 51.6, 201, @ahora - INTERVAL 10 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:25:1A:02')),
  (66.4, 10.52, 56.0, 42.9, 240, @ahora - INTERVAL 9 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:25:1A:02')),
  (49.5, 10.61, 59.4, 53.2, 163, @ahora - INTERVAL 8 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:25:1A:02')),
  (26.3, 7.98, 168.6, 7.2, 179, @ahora - INTERVAL 7 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:25:1A:02')),
  (16.8, 6.58, 188.2, 79.9, 244, @ahora - INTERVAL 6 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:25:1A:02')),
  (27.5, 8.22, 133.7, 39.1, 155, @ahora - INTERVAL 5 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:25:1A:02')),
  (32.8, 8.54, 113.2, 8.5, 167, @ahora - INTERVAL 4 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:25:1A:02')),
  (18.9, 10.94, 352.1, 52.0, 192, @ahora - INTERVAL 3 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:25:1A:02')),
  (33.6, 10.27, 339.3, 15.4, 143, @ahora - INTERVAL 2 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:25:1A:02')),
  (24.5, 6.48, 227.0, 46.2, 208, @ahora - INTERVAL 1 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:25:1A:02'));
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES (20.8, 9.08, 301.7, 58.7, 212, (SELECT ultima_senal FROM equipo WHERE direccion_mac = '02:5E:0B:25:1A:02'), (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:25:1A:02'));
INSERT INTO almacenamiento (punto_montaje, capacidad_total_gb, espacio_libre_gb, id_informe) VALUES ('C:', 512, 192.6, LAST_INSERT_ID());
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES
  (21.9, 7.1, 224.5, 9.0, 173, @ahora - INTERVAL 24 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:4A:27:03')),
  (12.5, 8.04, 46.9, 5.8, 185, @ahora - INTERVAL 23 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:4A:27:03')),
  (42.0, 6.64, 253.9, 41.0, 175, @ahora - INTERVAL 22 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:4A:27:03')),
  (35.6, 5.96, 373.1, 13.7, 172, @ahora - INTERVAL 21 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:4A:27:03')),
  (11.0, 7.91, 359.7, 62.4, 193, @ahora - INTERVAL 20 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:4A:27:03')),
  (53.4, 5.92, 97.9, 25.5, 152, @ahora - INTERVAL 19 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:4A:27:03')),
  (40.2, 8.83, 374.8, 28.7, 239, @ahora - INTERVAL 18 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:4A:27:03')),
  (29.4, 9.1, 287.1, 4.0, 191, @ahora - INTERVAL 17 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:4A:27:03')),
  (22.9, 6.81, 187.8, 78.3, 252, @ahora - INTERVAL 16 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:4A:27:03')),
  (38.6, 7.7, 203.0, 78.0, 172, @ahora - INTERVAL 15 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:4A:27:03')),
  (51.3, 10.9, 145.7, 59.1, 195, @ahora - INTERVAL 14 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:4A:27:03')),
  (74.3, 7.18, 135.6, 58.4, 238, @ahora - INTERVAL 13 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:4A:27:03')),
  (70.6, 6.28, 308.3, 26.2, 255, @ahora - INTERVAL 12 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:4A:27:03')),
  (34.0, 10.96, 83.0, 5.4, 154, @ahora - INTERVAL 11 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:4A:27:03')),
  (40.6, 6.29, 19.7, 42.3, 216, @ahora - INTERVAL 10 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:4A:27:03')),
  (63.5, 9.27, 16.4, 46.7, 185, @ahora - INTERVAL 9 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:4A:27:03')),
  (27.5, 7.71, 311.8, 53.3, 239, @ahora - INTERVAL 8 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:4A:27:03')),
  (13.9, 8.64, 266.3, 74.8, 227, @ahora - INTERVAL 7 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:4A:27:03')),
  (34.1, 10.58, 315.7, 19.0, 142, @ahora - INTERVAL 6 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:4A:27:03')),
  (21.0, 8.28, 109.2, 25.9, 260, @ahora - INTERVAL 5 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:4A:27:03')),
  (37.5, 6.1, 75.8, 4.0, 250, @ahora - INTERVAL 4 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:4A:27:03')),
  (53.2, 8.48, 109.8, 51.0, 236, @ahora - INTERVAL 3 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:4A:27:03')),
  (42.9, 5.92, 337.1, 50.6, 171, @ahora - INTERVAL 2 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:4A:27:03')),
  (30.1, 11.03, 273.3, 69.1, 258, @ahora - INTERVAL 1 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:4A:27:03'));
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES (47.3, 10.48, 147.2, 63.4, 211, (SELECT ultima_senal FROM equipo WHERE direccion_mac = '02:5E:0B:4A:27:03'), (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:4A:27:03'));
INSERT INTO almacenamiento (punto_montaje, capacidad_total_gb, espacio_libre_gb, id_informe) VALUES ('C:', 1000, 568.3, LAST_INSERT_ID());
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES
  (47.0, 7.52, 84.4, 29.4, 221, @ahora - INTERVAL 24 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:6F:34:04')),
  (29.5, 10.14, 359.3, 54.2, 179, @ahora - INTERVAL 23 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:6F:34:04')),
  (16.8, 9.12, 65.7, 71.6, 185, @ahora - INTERVAL 22 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:6F:34:04')),
  (46.2, 10.28, 282.4, 63.8, 221, @ahora - INTERVAL 21 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:6F:34:04')),
  (16.1, 7.27, 221.0, 21.9, 231, @ahora - INTERVAL 20 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:6F:34:04')),
  (42.8, 11.19, 12.2, 18.2, 248, @ahora - INTERVAL 19 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:6F:34:04')),
  (40.7, 7.32, 22.6, 32.1, 208, @ahora - INTERVAL 18 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:6F:34:04')),
  (53.3, 8.49, 259.4, 13.5, 205, @ahora - INTERVAL 17 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:6F:34:04')),
  (12.9, 6.39, 158.7, 44.3, 179, @ahora - INTERVAL 16 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:6F:34:04')),
  (35.0, 8.92, 316.0, 13.8, 177, @ahora - INTERVAL 15 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:6F:34:04')),
  (46.9, 7.2, 57.9, 31.7, 235, @ahora - INTERVAL 14 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:6F:34:04')),
  (62.6, 10.34, 260.9, 75.2, 185, @ahora - INTERVAL 13 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:6F:34:04')),
  (71.2, 10.65, 391.7, 79.7, 161, @ahora - INTERVAL 12 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:6F:34:04')),
  (66.9, 5.77, 129.3, 12.4, 143, @ahora - INTERVAL 11 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:6F:34:04')),
  (74.7, 8.48, 353.5, 51.8, 140, @ahora - INTERVAL 10 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:6F:34:04')),
  (72.6, 5.96, 124.5, 43.0, 216, @ahora - INTERVAL 9 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:6F:34:04')),
  (36.7, 6.31, 394.1, 39.3, 251, @ahora - INTERVAL 8 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:6F:34:04')),
  (47.3, 6.01, 108.7, 24.8, 155, @ahora - INTERVAL 7 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:6F:34:04')),
  (24.3, 10.69, 52.8, 42.0, 246, @ahora - INTERVAL 6 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:6F:34:04')),
  (24.9, 10.17, 367.5, 28.3, 148, @ahora - INTERVAL 5 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:6F:34:04')),
  (44.6, 6.09, 200.5, 25.7, 236, @ahora - INTERVAL 4 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:6F:34:04')),
  (39.1, 6.54, 175.9, 45.4, 181, @ahora - INTERVAL 3 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:6F:34:04')),
  (50.6, 9.65, 343.6, 32.8, 162, @ahora - INTERVAL 2 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:6F:34:04')),
  (17.2, 8.19, 346.8, 73.7, 237, @ahora - INTERVAL 1 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:6F:34:04'));
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES (49.4, 7.89, 155.7, 13.2, 235, (SELECT ultima_senal FROM equipo WHERE direccion_mac = '02:5E:0B:6F:34:04'), (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:6F:34:04'));
INSERT INTO almacenamiento (punto_montaje, capacidad_total_gb, espacio_libre_gb, id_informe) VALUES ('C:', 256, 156.5, LAST_INSERT_ID());
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES
  (34.6, 19.44, 175.4, 27.0, 155, @ahora - INTERVAL 24 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:94:41:05')),
  (23.0, 20.62, 180.6, 12.5, 220, @ahora - INTERVAL 23 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:94:41:05')),
  (20.6, 14.92, 61.7, 62.0, 174, @ahora - INTERVAL 22 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:94:41:05')),
  (21.8, 16.33, 163.5, 2.7, 231, @ahora - INTERVAL 21 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:94:41:05')),
  (23.5, 15.79, 42.5, 61.6, 203, @ahora - INTERVAL 20 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:94:41:05')),
  (50.7, 20.69, 381.3, 53.7, 209, @ahora - INTERVAL 19 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:94:41:05')),
  (32.3, 15.95, 261.0, 5.7, 191, @ahora - INTERVAL 18 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:94:41:05')),
  (42.0, 11.32, 225.8, 20.9, 182, @ahora - INTERVAL 17 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:94:41:05')),
  (35.2, 18.05, 334.0, 64.4, 248, @ahora - INTERVAL 16 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:94:41:05')),
  (74.8, 14.99, 19.8, 18.4, 155, @ahora - INTERVAL 15 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:94:41:05')),
  (64.1, 21.75, 134.0, 62.6, 241, @ahora - INTERVAL 14 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:94:41:05')),
  (54.5, 14.3, 253.9, 7.2, 228, @ahora - INTERVAL 13 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:94:41:05')),
  (41.8, 19.81, 393.1, 13.3, 168, @ahora - INTERVAL 12 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:94:41:05')),
  (77.3, 13.51, 270.9, 56.7, 150, @ahora - INTERVAL 11 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:94:41:05')),
  (59.7, 19.17, 274.1, 45.2, 153, @ahora - INTERVAL 10 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:94:41:05')),
  (34.3, 21.72, 22.6, 44.5, 205, @ahora - INTERVAL 9 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:94:41:05')),
  (54.5, 22.27, 364.6, 53.0, 183, @ahora - INTERVAL 8 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:94:41:05')),
  (24.1, 14.76, 194.5, 39.6, 181, @ahora - INTERVAL 7 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:94:41:05')),
  (47.4, 11.61, 198.6, 2.7, 243, @ahora - INTERVAL 6 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:94:41:05')),
  (25.2, 20.57, 189.1, 30.0, 205, @ahora - INTERVAL 5 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:94:41:05')),
  (47.6, 15.68, 91.2, 5.3, 192, @ahora - INTERVAL 4 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:94:41:05')),
  (48.6, 19.33, 260.0, 41.2, 208, @ahora - INTERVAL 3 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:94:41:05')),
  (44.0, 14.54, 195.6, 8.2, 205, @ahora - INTERVAL 2 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:94:41:05')),
  (53.8, 17.87, 198.2, 53.2, 186, @ahora - INTERVAL 1 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:94:41:05'));
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES (19.1, 22.28, 73.9, 21.3, 251, (SELECT ultima_senal FROM equipo WHERE direccion_mac = '02:5E:0B:94:41:05'), (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:94:41:05'));
INSERT INTO almacenamiento (punto_montaje, capacidad_total_gb, espacio_libre_gb, id_informe) VALUES ('C:', 512, 327.0, LAST_INSERT_ID());
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES
  (32.8, 5.23, 254.1, 74.1, 167, @ahora - INTERVAL 24 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:B9:4E:06')),
  (9.4, 3.47, 174.5, 68.6, 156, @ahora - INTERVAL 23 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:B9:4E:06')),
  (32.1, 5.02, 111.9, 70.0, 202, @ahora - INTERVAL 22 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:B9:4E:06')),
  (14.4, 4.7, 343.4, 29.7, 223, @ahora - INTERVAL 21 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:B9:4E:06')),
  (26.4, 4.52, 217.9, 13.0, 210, @ahora - INTERVAL 20 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:B9:4E:06')),
  (41.1, 3.23, 61.9, 64.0, 242, @ahora - INTERVAL 19 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:B9:4E:06')),
  (38.9, 2.97, 268.3, 3.7, 241, @ahora - INTERVAL 18 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:B9:4E:06')),
  (22.1, 5.1, 60.0, 77.1, 228, @ahora - INTERVAL 17 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:B9:4E:06')),
  (24.8, 4.08, 78.7, 5.2, 163, @ahora - INTERVAL 16 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:B9:4E:06')),
  (65.0, 3.96, 251.0, 73.1, 143, @ahora - INTERVAL 15 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:B9:4E:06')),
  (47.1, 4.24, 355.8, 8.3, 227, @ahora - INTERVAL 14 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:B9:4E:06')),
  (68.1, 3.23, 133.2, 57.5, 145, @ahora - INTERVAL 13 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:B9:4E:06')),
  (55.1, 2.96, 144.4, 67.7, 229, @ahora - INTERVAL 12 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:B9:4E:06')),
  (71.2, 3.52, 303.9, 13.9, 164, @ahora - INTERVAL 11 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:B9:4E:06')),
  (73.8, 3.05, 267.0, 16.8, 247, @ahora - INTERVAL 10 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:B9:4E:06')),
  (41.0, 3.43, 387.3, 17.8, 160, @ahora - INTERVAL 9 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:B9:4E:06')),
  (33.2, 5.24, 289.8, 37.3, 186, @ahora - INTERVAL 8 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:B9:4E:06')),
  (41.1, 5.51, 253.6, 35.8, 211, @ahora - INTERVAL 7 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:B9:4E:06')),
  (36.5, 3.06, 359.3, 59.4, 154, @ahora - INTERVAL 6 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:B9:4E:06')),
  (43.5, 3.79, 273.2, 55.3, 154, @ahora - INTERVAL 5 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:B9:4E:06')),
  (16.1, 4.6, 79.8, 75.9, 194, @ahora - INTERVAL 4 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:B9:4E:06')),
  (9.4, 5.52, 261.0, 73.2, 241, @ahora - INTERVAL 3 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:B9:4E:06')),
  (20.6, 4.87, 162.3, 38.6, 198, @ahora - INTERVAL 2 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:B9:4E:06')),
  (49.7, 5.15, 197.8, 11.9, 241, @ahora - INTERVAL 1 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:B9:4E:06'));
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES (17.2, 3.42, 154.1, 51.0, 146, (SELECT ultima_senal FROM equipo WHERE direccion_mac = '02:5E:0B:B9:4E:06'), (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:B9:4E:06'));
INSERT INTO almacenamiento (punto_montaje, capacidad_total_gb, espacio_libre_gb, id_informe) VALUES ('C:', 512, 210.7, LAST_INSERT_ID());
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES
  (51.7, 4.68, 133.9, 21.1, 227, @ahora - INTERVAL 24 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:DE:5B:07')),
  (11.7, 4.11, 220.7, 63.9, 245, @ahora - INTERVAL 23 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:DE:5B:07')),
  (32.9, 3.08, 114.1, 3.9, 215, @ahora - INTERVAL 22 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:DE:5B:07')),
  (10.0, 4.28, 183.7, 9.6, 242, @ahora - INTERVAL 21 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:DE:5B:07')),
  (38.3, 4.41, 185.5, 38.8, 142, @ahora - INTERVAL 20 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:DE:5B:07')),
  (15.2, 3.69, 15.5, 32.0, 161, @ahora - INTERVAL 19 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:DE:5B:07')),
  (33.1, 3.51, 388.9, 60.2, 149, @ahora - INTERVAL 18 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:DE:5B:07')),
  (43.4, 4.26, 294.3, 68.7, 182, @ahora - INTERVAL 17 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:DE:5B:07')),
  (41.7, 3.66, 191.0, 26.5, 254, @ahora - INTERVAL 16 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:DE:5B:07')),
  (55.0, 3.48, 99.2, 69.0, 180, @ahora - INTERVAL 15 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:DE:5B:07')),
  (52.7, 4.17, 240.3, 35.6, 238, @ahora - INTERVAL 14 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:DE:5B:07')),
  (38.3, 4.13, 155.7, 42.9, 203, @ahora - INTERVAL 13 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:DE:5B:07')),
  (77.4, 3.88, 18.4, 37.8, 157, @ahora - INTERVAL 12 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:DE:5B:07')),
  (46.8, 5.21, 129.0, 61.6, 250, @ahora - INTERVAL 11 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:DE:5B:07')),
  (67.6, 2.87, 242.9, 42.1, 207, @ahora - INTERVAL 10 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:DE:5B:07')),
  (38.7, 3.83, 90.6, 7.0, 161, @ahora - INTERVAL 9 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:DE:5B:07')),
  (29.5, 5.06, 321.7, 64.6, 193, @ahora - INTERVAL 8 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:DE:5B:07')),
  (26.8, 2.82, 82.7, 21.8, 242, @ahora - INTERVAL 7 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:DE:5B:07')),
  (15.9, 3.55, 152.8, 21.2, 259, @ahora - INTERVAL 6 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:DE:5B:07')),
  (50.8, 3.41, 337.7, 64.4, 211, @ahora - INTERVAL 5 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:DE:5B:07')),
  (13.4, 4.05, 268.5, 29.1, 252, @ahora - INTERVAL 4 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:DE:5B:07')),
  (54.0, 4.74, 337.2, 41.7, 259, @ahora - INTERVAL 3 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:DE:5B:07')),
  (9.6, 5.41, 344.4, 16.0, 223, @ahora - INTERVAL 2 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:DE:5B:07')),
  (53.6, 2.93, 41.0, 52.5, 175, @ahora - INTERVAL 1 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:DE:5B:07'));
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES (20.2, 3.6, 191.2, 21.5, 253, (SELECT ultima_senal FROM equipo WHERE direccion_mac = '02:5E:0B:DE:5B:07'), (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:DE:5B:07'));
INSERT INTO almacenamiento (punto_montaje, capacidad_total_gb, espacio_libre_gb, id_informe) VALUES ('C:', 1000, 540.9, LAST_INSERT_ID());
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES
  (40.9, 8.66, 221.2, 41.8, 209, @ahora - INTERVAL 24 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:03:68:08')),
  (19.2, 10.19, 219.0, 19.0, 190, @ahora - INTERVAL 23 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:03:68:08')),
  (29.8, 6.96, 11.0, 31.5, 151, @ahora - INTERVAL 22 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:03:68:08')),
  (28.7, 9.09, 72.8, 14.0, 165, @ahora - INTERVAL 21 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:03:68:08')),
  (31.7, 7.49, 115.2, 52.0, 161, @ahora - INTERVAL 20 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:03:68:08')),
  (30.0, 5.71, 34.4, 60.5, 260, @ahora - INTERVAL 19 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:03:68:08')),
  (34.6, 8.49, 101.1, 65.6, 251, @ahora - INTERVAL 18 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:03:68:08')),
  (40.6, 9.45, 132.3, 40.1, 154, @ahora - INTERVAL 17 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:03:68:08')),
  (14.5, 10.16, 40.4, 56.1, 220, @ahora - INTERVAL 16 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:03:68:08')),
  (52.7, 8.77, 207.4, 29.1, 235, @ahora - INTERVAL 15 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:03:68:08')),
  (65.0, 5.72, 104.7, 10.1, 252, @ahora - INTERVAL 14 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:03:68:08')),
  (44.5, 7.3, 271.8, 54.7, 212, @ahora - INTERVAL 13 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:03:68:08')),
  (41.4, 9.78, 9.1, 3.3, 257, @ahora - INTERVAL 12 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:03:68:08')),
  (67.6, 9.6, 238.0, 20.2, 200, @ahora - INTERVAL 11 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:03:68:08')),
  (68.3, 6.49, 382.0, 74.7, 201, @ahora - INTERVAL 10 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:03:68:08')),
  (38.3, 6.31, 247.1, 25.6, 192, @ahora - INTERVAL 9 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:03:68:08')),
  (52.2, 5.71, 245.4, 75.9, 188, @ahora - INTERVAL 8 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:03:68:08')),
  (37.8, 5.63, 237.0, 8.6, 246, @ahora - INTERVAL 7 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:03:68:08')),
  (23.3, 10.13, 339.1, 76.3, 196, @ahora - INTERVAL 6 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:03:68:08')),
  (44.2, 9.68, 333.2, 20.8, 234, @ahora - INTERVAL 5 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:03:68:08')),
  (37.2, 8.23, 344.7, 65.6, 153, @ahora - INTERVAL 4 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:03:68:08')),
  (36.8, 5.77, 89.3, 56.2, 231, @ahora - INTERVAL 3 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:03:68:08')),
  (54.0, 11.17, 93.8, 55.7, 181, @ahora - INTERVAL 2 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:03:68:08')),
  (15.8, 6.17, 157.1, 48.5, 222, @ahora - INTERVAL 1 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:03:68:08'));
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES (36.8, 6.76, 365.2, 43.5, 188, (SELECT ultima_senal FROM equipo WHERE direccion_mac = '02:5E:0B:03:68:08'), (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:03:68:08'));
INSERT INTO almacenamiento (punto_montaje, capacidad_total_gb, espacio_libre_gb, id_informe) VALUES ('C:', 256, 127.3, LAST_INSERT_ID());
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES
  (40.6, 7.55, 369.3, 20.2, 205, @ahora - INTERVAL 24 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:28:75:09')),
  (22.2, 9.72, 330.8, 24.7, 248, @ahora - INTERVAL 23 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:28:75:09')),
  (28.2, 8.85, 180.7, 30.6, 203, @ahora - INTERVAL 22 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:28:75:09')),
  (40.0, 9.03, 296.5, 64.2, 205, @ahora - INTERVAL 21 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:28:75:09')),
  (23.9, 7.27, 168.5, 78.7, 220, @ahora - INTERVAL 20 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:28:75:09')),
  (49.4, 10.54, 379.3, 41.4, 242, @ahora - INTERVAL 19 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:28:75:09')),
  (39.2, 10.96, 204.9, 66.7, 184, @ahora - INTERVAL 18 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:28:75:09')),
  (43.3, 8.54, 10.3, 42.5, 189, @ahora - INTERVAL 17 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:28:75:09')),
  (37.3, 10.69, 342.4, 64.2, 211, @ahora - INTERVAL 16 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:28:75:09')),
  (60.5, 7.59, 298.5, 69.9, 153, @ahora - INTERVAL 15 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:28:75:09')),
  (44.1, 6.58, 249.0, 38.4, 244, @ahora - INTERVAL 14 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:28:75:09')),
  (40.4, 8.47, 152.7, 44.1, 152, @ahora - INTERVAL 13 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:28:75:09')),
  (38.5, 7.83, 185.7, 28.4, 206, @ahora - INTERVAL 12 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:28:75:09')),
  (79.7, 9.11, 169.5, 26.4, 254, @ahora - INTERVAL 11 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:28:75:09')),
  (33.2, 10.59, 305.9, 53.1, 198, @ahora - INTERVAL 10 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:28:75:09')),
  (62.5, 6.16, 46.7, 65.7, 251, @ahora - INTERVAL 9 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:28:75:09')),
  (45.5, 10.42, 139.6, 15.3, 151, @ahora - INTERVAL 8 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:28:75:09')),
  (24.3, 6.44, 189.2, 68.5, 152, @ahora - INTERVAL 7 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:28:75:09')),
  (51.2, 8.68, 392.7, 60.5, 156, @ahora - INTERVAL 6 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:28:75:09')),
  (12.3, 9.44, 172.1, 79.3, 196, @ahora - INTERVAL 5 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:28:75:09')),
  (31.4, 8.11, 143.9, 8.8, 146, @ahora - INTERVAL 4 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:28:75:09')),
  (27.2, 8.0, 32.1, 57.3, 207, @ahora - INTERVAL 3 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:28:75:09')),
  (19.7, 6.21, 380.7, 1.9, 158, @ahora - INTERVAL 2 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:28:75:09')),
  (36.3, 10.03, 107.0, 64.3, 240, @ahora - INTERVAL 1 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:28:75:09'));
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES (15.1, 6.87, 34.9, 70.2, 150, (SELECT ultima_senal FROM equipo WHERE direccion_mac = '02:5E:0B:28:75:09'), (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:28:75:09'));
INSERT INTO almacenamiento (punto_montaje, capacidad_total_gb, espacio_libre_gb, id_informe) VALUES ('C:', 512, 342.9, LAST_INSERT_ID());
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES
  (35.2, 9.06, 131.1, 68.8, 250, @ahora - INTERVAL 24 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:4D:82:0A')),
  (35.2, 6.91, 330.8, 42.4, 207, @ahora - INTERVAL 23 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:4D:82:0A')),
  (27.7, 5.79, 245.8, 42.7, 177, @ahora - INTERVAL 22 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:4D:82:0A')),
  (27.4, 10.37, 107.9, 56.9, 238, @ahora - INTERVAL 21 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:4D:82:0A')),
  (42.2, 8.07, 146.3, 41.9, 173, @ahora - INTERVAL 20 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:4D:82:0A')),
  (22.6, 10.48, 102.5, 73.5, 216, @ahora - INTERVAL 19 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:4D:82:0A')),
  (36.0, 9.5, 292.6, 76.8, 155, @ahora - INTERVAL 18 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:4D:82:0A')),
  (39.1, 7.87, 172.6, 37.5, 188, @ahora - INTERVAL 17 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:4D:82:0A')),
  (39.8, 11.06, 348.4, 79.4, 236, @ahora - INTERVAL 16 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:4D:82:0A')),
  (65.0, 8.87, 229.9, 29.3, 237, @ahora - INTERVAL 15 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:4D:82:0A')),
  (49.7, 9.72, 318.0, 62.8, 141, @ahora - INTERVAL 14 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:4D:82:0A')),
  (49.9, 8.21, 243.3, 69.2, 177, @ahora - INTERVAL 13 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:4D:82:0A')),
  (58.4, 8.65, 26.6, 61.8, 195, @ahora - INTERVAL 12 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:4D:82:0A')),
  (45.3, 7.28, 346.6, 57.1, 140, @ahora - INTERVAL 11 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:4D:82:0A')),
  (42.7, 5.92, 95.4, 4.9, 186, @ahora - INTERVAL 10 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:4D:82:0A')),
  (77.0, 10.98, 218.2, 9.1, 218, @ahora - INTERVAL 9 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:4D:82:0A')),
  (33.2, 9.14, 26.5, 11.0, 251, @ahora - INTERVAL 8 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:4D:82:0A')),
  (27.7, 6.25, 399.3, 72.7, 241, @ahora - INTERVAL 7 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:4D:82:0A')),
  (45.3, 11.19, 350.4, 57.9, 144, @ahora - INTERVAL 6 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:4D:82:0A')),
  (14.4, 11.03, 226.9, 2.9, 238, @ahora - INTERVAL 5 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:4D:82:0A')),
  (48.5, 7.89, 151.5, 54.4, 241, @ahora - INTERVAL 4 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:4D:82:0A')),
  (28.7, 10.81, 168.8, 12.8, 221, @ahora - INTERVAL 3 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:4D:82:0A')),
  (51.7, 8.6, 244.6, 57.6, 148, @ahora - INTERVAL 2 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:4D:82:0A')),
  (29.3, 8.82, 329.4, 35.8, 221, @ahora - INTERVAL 1 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:4D:82:0A'));
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES (17.3, 5.6, 42.3, 11.2, 164, (SELECT ultima_senal FROM equipo WHERE direccion_mac = '02:5E:0B:4D:82:0A'), (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:4D:82:0A'));
INSERT INTO almacenamiento (punto_montaje, capacidad_total_gb, espacio_libre_gb, id_informe) VALUES ('C:', 512, 307.3, LAST_INSERT_ID());
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES
  (20.7, 19.49, 211.9, 12.9, 181, @ahora - INTERVAL 24 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:72:8F:0B')),
  (15.5, 20.17, 121.6, 71.0, 164, @ahora - INTERVAL 23 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:72:8F:0B')),
  (29.9, 12.06, 159.4, 6.9, 141, @ahora - INTERVAL 22 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:72:8F:0B')),
  (25.3, 18.7, 114.2, 18.3, 183, @ahora - INTERVAL 21 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:72:8F:0B')),
  (20.0, 14.6, 227.1, 66.1, 149, @ahora - INTERVAL 20 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:72:8F:0B')),
  (40.4, 16.4, 142.3, 62.9, 157, @ahora - INTERVAL 19 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:72:8F:0B')),
  (16.0, 13.37, 104.6, 10.5, 172, @ahora - INTERVAL 18 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:72:8F:0B')),
  (35.6, 16.47, 80.5, 61.0, 260, @ahora - INTERVAL 17 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:72:8F:0B')),
  (24.9, 11.92, 257.7, 11.7, 176, @ahora - INTERVAL 16 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:72:8F:0B')),
  (70.5, 20.14, 24.4, 44.9, 248, @ahora - INTERVAL 15 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:72:8F:0B')),
  (77.0, 19.25, 192.1, 73.8, 257, @ahora - INTERVAL 14 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:72:8F:0B')),
  (47.4, 14.2, 160.1, 63.4, 231, @ahora - INTERVAL 13 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:72:8F:0B')),
  (37.9, 14.64, 107.1, 54.6, 193, @ahora - INTERVAL 12 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:72:8F:0B')),
  (36.4, 14.74, 123.0, 77.7, 229, @ahora - INTERVAL 11 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:72:8F:0B')),
  (75.8, 11.73, 31.8, 60.8, 151, @ahora - INTERVAL 10 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:72:8F:0B')),
  (74.2, 18.53, 375.2, 1.9, 180, @ahora - INTERVAL 9 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:72:8F:0B')),
  (17.5, 18.21, 130.8, 21.0, 206, @ahora - INTERVAL 8 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:72:8F:0B')),
  (47.4, 18.85, 218.5, 49.6, 145, @ahora - INTERVAL 7 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:72:8F:0B')),
  (24.8, 18.77, 288.3, 75.0, 202, @ahora - INTERVAL 6 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:72:8F:0B')),
  (40.4, 11.9, 262.2, 70.0, 165, @ahora - INTERVAL 5 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:72:8F:0B')),
  (33.5, 14.04, 255.4, 28.2, 191, @ahora - INTERVAL 4 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:72:8F:0B')),
  (33.3, 19.75, 256.4, 71.1, 240, @ahora - INTERVAL 3 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:72:8F:0B')),
  (9.0, 16.42, 274.5, 51.8, 145, @ahora - INTERVAL 2 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:72:8F:0B')),
  (30.2, 20.92, 191.9, 10.5, 257, @ahora - INTERVAL 1 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:72:8F:0B'));
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES (42.3, 15.19, 51.5, 34.4, 222, (SELECT ultima_senal FROM equipo WHERE direccion_mac = '02:5E:0B:72:8F:0B'), (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:72:8F:0B'));
INSERT INTO almacenamiento (punto_montaje, capacidad_total_gb, espacio_libre_gb, id_informe) VALUES ('C:', 1000, 304.8, LAST_INSERT_ID());
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES
  (17.8, 5.56, 186.8, 55.1, 155, @ahora - INTERVAL 24 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:97:9C:0C')),
  (9.8, 5.52, 192.5, 14.6, 255, @ahora - INTERVAL 23 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:97:9C:0C')),
  (45.7, 4.6, 326.7, 56.4, 178, @ahora - INTERVAL 22 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:97:9C:0C')),
  (16.4, 4.9, 118.0, 65.9, 211, @ahora - INTERVAL 21 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:97:9C:0C')),
  (28.3, 3.05, 153.5, 30.1, 167, @ahora - INTERVAL 20 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:97:9C:0C')),
  (36.6, 4.87, 231.3, 56.7, 202, @ahora - INTERVAL 19 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:97:9C:0C')),
  (20.3, 3.69, 287.1, 58.8, 243, @ahora - INTERVAL 18 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:97:9C:0C')),
  (42.8, 5.0, 222.2, 68.6, 234, @ahora - INTERVAL 17 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:97:9C:0C')),
  (20.6, 3.02, 74.4, 58.0, 168, @ahora - INTERVAL 16 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:97:9C:0C')),
  (76.7, 4.54, 189.3, 36.9, 175, @ahora - INTERVAL 15 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:97:9C:0C')),
  (73.2, 4.82, 330.2, 55.8, 220, @ahora - INTERVAL 14 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:97:9C:0C')),
  (35.2, 5.13, 312.3, 27.6, 243, @ahora - INTERVAL 13 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:97:9C:0C')),
  (36.2, 3.89, 212.5, 35.1, 180, @ahora - INTERVAL 12 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:97:9C:0C')),
  (52.7, 3.14, 275.9, 10.4, 147, @ahora - INTERVAL 11 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:97:9C:0C')),
  (57.5, 3.16, 379.6, 65.0, 256, @ahora - INTERVAL 10 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:97:9C:0C')),
  (47.9, 3.43, 247.6, 22.3, 226, @ahora - INTERVAL 9 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:97:9C:0C')),
  (21.3, 3.28, 372.4, 62.3, 175, @ahora - INTERVAL 8 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:97:9C:0C')),
  (29.6, 4.25, 288.6, 59.6, 238, @ahora - INTERVAL 7 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:97:9C:0C')),
  (33.8, 3.54, 110.2, 1.6, 190, @ahora - INTERVAL 6 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:97:9C:0C')),
  (53.3, 4.53, 164.5, 45.1, 140, @ahora - INTERVAL 5 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:97:9C:0C')),
  (42.7, 2.8, 26.6, 2.3, 231, @ahora - INTERVAL 4 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:97:9C:0C')),
  (10.0, 3.68, 56.8, 2.7, 146, @ahora - INTERVAL 3 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:97:9C:0C')),
  (44.2, 4.46, 47.8, 61.7, 165, @ahora - INTERVAL 2 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:97:9C:0C')),
  (43.4, 4.46, 199.6, 77.7, 144, @ahora - INTERVAL 1 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:97:9C:0C'));
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES (28.7, 2.89, 212.5, 40.8, 197, (SELECT ultima_senal FROM equipo WHERE direccion_mac = '02:5E:0B:97:9C:0C'), (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:97:9C:0C'));
INSERT INTO almacenamiento (punto_montaje, capacidad_total_gb, espacio_libre_gb, id_informe) VALUES ('C:', 256, 68.2, LAST_INSERT_ID());
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES
  (40.6, 4.74, 43.1, 34.2, 230, @ahora - INTERVAL 24 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:BC:A9:0D')),
  (26.8, 3.02, 46.5, 32.7, 185, @ahora - INTERVAL 23 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:BC:A9:0D')),
  (11.9, 2.81, 16.2, 41.4, 144, @ahora - INTERVAL 22 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:BC:A9:0D')),
  (10.3, 3.66, 253.8, 1.3, 140, @ahora - INTERVAL 21 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:BC:A9:0D')),
  (22.5, 3.89, 303.3, 77.2, 252, @ahora - INTERVAL 20 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:BC:A9:0D')),
  (28.3, 3.08, 363.8, 15.1, 215, @ahora - INTERVAL 19 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:BC:A9:0D')),
  (19.5, 2.93, 356.3, 11.9, 196, @ahora - INTERVAL 18 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:BC:A9:0D')),
  (10.0, 4.77, 314.0, 62.3, 250, @ahora - INTERVAL 17 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:BC:A9:0D')),
  (46.2, 4.13, 346.9, 63.2, 217, @ahora - INTERVAL 16 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:BC:A9:0D')),
  (66.9, 4.44, 249.5, 17.1, 248, @ahora - INTERVAL 15 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:BC:A9:0D')),
  (56.9, 4.86, 359.2, 16.5, 147, @ahora - INTERVAL 14 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:BC:A9:0D')),
  (72.5, 5.57, 275.3, 9.0, 193, @ahora - INTERVAL 13 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:BC:A9:0D')),
  (38.8, 4.36, 52.4, 65.2, 250, @ahora - INTERVAL 12 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:BC:A9:0D')),
  (74.2, 4.48, 366.4, 78.8, 258, @ahora - INTERVAL 11 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:BC:A9:0D')),
  (34.1, 3.93, 330.4, 25.8, 209, @ahora - INTERVAL 10 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:BC:A9:0D')),
  (75.5, 2.96, 161.1, 77.4, 244, @ahora - INTERVAL 9 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:BC:A9:0D')),
  (23.5, 3.91, 168.9, 67.3, 158, @ahora - INTERVAL 8 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:BC:A9:0D')),
  (54.4, 5.08, 234.8, 16.5, 210, @ahora - INTERVAL 7 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:BC:A9:0D')),
  (42.1, 3.19, 51.9, 71.6, 254, @ahora - INTERVAL 6 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:BC:A9:0D')),
  (40.1, 4.71, 68.6, 22.0, 244, @ahora - INTERVAL 5 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:BC:A9:0D')),
  (54.4, 5.59, 161.2, 13.0, 243, @ahora - INTERVAL 4 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:BC:A9:0D')),
  (16.0, 2.87, 265.4, 49.3, 162, @ahora - INTERVAL 3 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:BC:A9:0D')),
  (8.7, 4.85, 287.4, 11.6, 232, @ahora - INTERVAL 2 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:BC:A9:0D')),
  (22.6, 4.57, 15.7, 24.2, 191, @ahora - INTERVAL 1 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:BC:A9:0D'));
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES (18.2, 3.43, 391.3, 63.0, 227, (SELECT ultima_senal FROM equipo WHERE direccion_mac = '02:5E:0B:BC:A9:0D'), (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:BC:A9:0D'));
INSERT INTO almacenamiento (punto_montaje, capacidad_total_gb, espacio_libre_gb, id_informe) VALUES ('C:', 512, 235.6, LAST_INSERT_ID());
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES (49.9, 9.15, 155.9, 70.3, 222, (SELECT ultima_senal FROM equipo WHERE direccion_mac = '02:5E:0B:06:C3:0F'), (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:06:C3:0F'));
INSERT INTO almacenamiento (punto_montaje, capacidad_total_gb, espacio_libre_gb, id_informe) VALUES ('C:', 1000, 414.2, LAST_INSERT_ID());
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES (16.0, 11.12, 224.2, 1.9, 155, (SELECT ultima_senal FROM equipo WHERE direccion_mac = '02:5E:0B:2B:D0:10'), (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:2B:D0:10'));
INSERT INTO almacenamiento (punto_montaje, capacidad_total_gb, espacio_libre_gb, id_informe) VALUES ('C:', 256, 131.7, LAST_INSERT_ID());
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES
  (22.7, 16.38, 216.7, 65.8, 169, @ahora - INTERVAL 24 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:50:DD:11')),
  (18.9, 18.2, 140.5, 15.1, 215, @ahora - INTERVAL 23 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:50:DD:11')),
  (25.1, 19.54, 293.1, 16.4, 222, @ahora - INTERVAL 22 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:50:DD:11')),
  (30.1, 21.74, 322.6, 73.3, 190, @ahora - INTERVAL 21 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:50:DD:11')),
  (40.7, 18.4, 57.7, 55.4, 215, @ahora - INTERVAL 20 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:50:DD:11')),
  (26.9, 12.42, 42.1, 42.8, 184, @ahora - INTERVAL 19 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:50:DD:11')),
  (26.9, 16.31, 12.9, 11.1, 209, @ahora - INTERVAL 18 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:50:DD:11')),
  (27.0, 19.73, 234.1, 48.5, 182, @ahora - INTERVAL 17 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:50:DD:11')),
  (17.6, 13.68, 198.8, 62.3, 251, @ahora - INTERVAL 16 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:50:DD:11')),
  (48.0, 14.79, 31.0, 69.7, 235, @ahora - INTERVAL 15 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:50:DD:11')),
  (50.0, 11.79, 282.8, 64.5, 195, @ahora - INTERVAL 14 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:50:DD:11')),
  (42.1, 21.07, 196.4, 6.6, 231, @ahora - INTERVAL 13 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:50:DD:11')),
  (76.2, 19.76, 33.7, 51.9, 161, @ahora - INTERVAL 12 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:50:DD:11')),
  (68.8, 20.83, 94.4, 50.8, 149, @ahora - INTERVAL 11 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:50:DD:11')),
  (52.6, 17.4, 19.0, 69.3, 223, @ahora - INTERVAL 10 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:50:DD:11')),
  (52.1, 17.31, 310.1, 26.7, 167, @ahora - INTERVAL 9 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:50:DD:11')),
  (13.1, 12.05, 81.8, 50.6, 143, @ahora - INTERVAL 8 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:50:DD:11')),
  (14.8, 15.13, 66.8, 29.0, 160, @ahora - INTERVAL 7 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:50:DD:11')),
  (8.1, 22.15, 51.5, 22.5, 254, @ahora - INTERVAL 6 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:50:DD:11')),
  (14.4, 18.5, 329.3, 64.8, 167, @ahora - INTERVAL 5 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:50:DD:11')),
  (21.6, 17.55, 345.1, 11.5, 167, @ahora - INTERVAL 4 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:50:DD:11')),
  (54.6, 15.71, 256.4, 66.3, 187, @ahora - INTERVAL 3 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:50:DD:11')),
  (45.6, 19.4, 362.2, 11.3, 162, @ahora - INTERVAL 2 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:50:DD:11')),
  (52.3, 19.06, 322.0, 71.0, 228, @ahora - INTERVAL 1 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:50:DD:11'));
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES (28.9, 30.06, 317.0, 37.7, 190, (SELECT ultima_senal FROM equipo WHERE direccion_mac = '02:5E:0B:50:DD:11'), (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:50:DD:11'));
INSERT INTO almacenamiento (punto_montaje, capacidad_total_gb, espacio_libre_gb, id_informe) VALUES ('C:', 512, 38.4, LAST_INSERT_ID());
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES
  (10.2, 4.8, 147.0, 72.8, 176, @ahora - INTERVAL 24 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:75:EA:12')),
  (47.6, 4.25, 133.4, 54.7, 172, @ahora - INTERVAL 23 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:75:EA:12')),
  (14.6, 4.05, 111.2, 72.2, 221, @ahora - INTERVAL 22 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:75:EA:12')),
  (41.1, 4.52, 359.7, 50.6, 202, @ahora - INTERVAL 21 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:75:EA:12')),
  (22.6, 4.85, 180.6, 32.7, 175, @ahora - INTERVAL 20 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:75:EA:12')),
  (47.0, 5.38, 189.5, 18.7, 169, @ahora - INTERVAL 19 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:75:EA:12')),
  (26.4, 2.94, 147.8, 2.7, 213, @ahora - INTERVAL 18 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:75:EA:12')),
  (26.5, 5.46, 9.2, 33.6, 183, @ahora - INTERVAL 17 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:75:EA:12')),
  (28.1, 4.75, 95.2, 41.2, 258, @ahora - INTERVAL 16 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:75:EA:12')),
  (70.0, 4.68, 70.8, 44.0, 201, @ahora - INTERVAL 15 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:75:EA:12')),
  (54.8, 2.83, 303.9, 48.4, 176, @ahora - INTERVAL 14 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:75:EA:12')),
  (45.0, 3.92, 241.1, 64.7, 145, @ahora - INTERVAL 13 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:75:EA:12')),
  (74.2, 4.09, 15.5, 34.0, 171, @ahora - INTERVAL 12 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:75:EA:12')),
  (71.5, 5.37, 331.4, 31.7, 226, @ahora - INTERVAL 11 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:75:EA:12')),
  (76.2, 4.14, 158.5, 47.8, 188, @ahora - INTERVAL 10 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:75:EA:12')),
  (49.6, 3.95, 124.3, 5.6, 211, @ahora - INTERVAL 9 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:75:EA:12')),
  (32.6, 2.92, 378.7, 20.7, 195, @ahora - INTERVAL 8 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:75:EA:12')),
  (16.0, 3.31, 234.4, 43.1, 196, @ahora - INTERVAL 7 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:75:EA:12')),
  (27.3, 3.73, 291.8, 79.7, 218, @ahora - INTERVAL 6 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:75:EA:12')),
  (31.4, 3.11, 15.3, 45.9, 216, @ahora - INTERVAL 5 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:75:EA:12')),
  (44.9, 3.94, 13.8, 14.9, 205, @ahora - INTERVAL 4 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:75:EA:12')),
  (46.2, 3.27, 9.9, 40.0, 260, @ahora - INTERVAL 3 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:75:EA:12')),
  (12.1, 5.38, 172.6, 49.7, 219, @ahora - INTERVAL 2 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:75:EA:12')),
  (32.5, 3.67, 395.7, 41.8, 146, @ahora - INTERVAL 1 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:75:EA:12'));
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES (96.9, 4.86, 114.2, 22.0, 148, (SELECT ultima_senal FROM equipo WHERE direccion_mac = '02:5E:0B:75:EA:12'), (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:75:EA:12'));
INSERT INTO almacenamiento (punto_montaje, capacidad_total_gb, espacio_libre_gb, id_informe) VALUES ('C:', 512, 36.1, LAST_INSERT_ID());
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES
  (47.8, 9.95, 112.9, 74.8, 189, @ahora - INTERVAL 24 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:BF:04:14')),
  (20.8, 6.53, 87.0, 35.1, 200, @ahora - INTERVAL 23 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:BF:04:14')),
  (50.4, 8.11, 67.5, 23.6, 229, @ahora - INTERVAL 22 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:BF:04:14')),
  (25.5, 10.95, 344.2, 61.0, 177, @ahora - INTERVAL 21 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:BF:04:14')),
  (22.1, 9.2, 243.7, 53.0, 196, @ahora - INTERVAL 20 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:BF:04:14')),
  (14.3, 7.57, 73.0, 43.0, 215, @ahora - INTERVAL 19 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:BF:04:14')),
  (35.0, 10.07, 90.5, 6.8, 233, @ahora - INTERVAL 18 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:BF:04:14')),
  (28.3, 7.82, 169.6, 47.6, 252, @ahora - INTERVAL 17 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:BF:04:14')),
  (15.8, 10.28, 91.9, 15.9, 238, @ahora - INTERVAL 16 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:BF:04:14')),
  (38.6, 10.52, 112.9, 74.4, 151, @ahora - INTERVAL 15 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:BF:04:14')),
  (50.5, 5.75, 385.1, 11.0, 235, @ahora - INTERVAL 14 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:BF:04:14')),
  (69.1, 7.69, 248.2, 5.4, 177, @ahora - INTERVAL 13 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:BF:04:14')),
  (41.0, 7.76, 131.9, 46.0, 164, @ahora - INTERVAL 12 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:BF:04:14')),
  (55.1, 8.33, 164.7, 24.4, 159, @ahora - INTERVAL 11 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:BF:04:14')),
  (53.2, 10.06, 284.6, 71.6, 173, @ahora - INTERVAL 10 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:BF:04:14')),
  (47.8, 11.18, 32.9, 24.1, 218, @ahora - INTERVAL 9 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:BF:04:14')),
  (52.7, 7.21, 17.9, 72.4, 195, @ahora - INTERVAL 8 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:BF:04:14')),
  (53.1, 10.3, 215.6, 27.0, 237, @ahora - INTERVAL 7 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:BF:04:14')),
  (51.1, 5.76, 254.4, 57.3, 181, @ahora - INTERVAL 6 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:BF:04:14')),
  (13.4, 7.19, 51.2, 1.1, 166, @ahora - INTERVAL 5 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:BF:04:14')),
  (45.7, 5.96, 313.9, 34.8, 173, @ahora - INTERVAL 4 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:BF:04:14')),
  (44.0, 5.76, 286.1, 16.7, 199, @ahora - INTERVAL 3 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:BF:04:14')),
  (32.0, 10.66, 245.6, 66.5, 239, @ahora - INTERVAL 2 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:BF:04:14')),
  (41.0, 9.08, 30.5, 79.1, 149, @ahora - INTERVAL 1 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:BF:04:14'));
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES (13.1, 8.82, 333.5, 57.3, 176, (SELECT ultima_senal FROM equipo WHERE direccion_mac = '02:5E:0B:BF:04:14'), (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:BF:04:14'));
INSERT INTO almacenamiento (punto_montaje, capacidad_total_gb, espacio_libre_gb, id_informe) VALUES ('C:', 256, 174.5, LAST_INSERT_ID());
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES
  (52.1, 7.33, 30.5, 9.1, 185, @ahora - INTERVAL 24 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:E4:11:15')),
  (52.1, 7.55, 269.4, 49.8, 221, @ahora - INTERVAL 23 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:E4:11:15')),
  (14.3, 5.99, 269.1, 28.7, 213, @ahora - INTERVAL 22 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:E4:11:15')),
  (48.3, 5.82, 252.9, 64.6, 161, @ahora - INTERVAL 21 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:E4:11:15')),
  (52.5, 10.31, 222.3, 40.8, 245, @ahora - INTERVAL 20 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:E4:11:15')),
  (50.3, 5.93, 236.4, 27.2, 252, @ahora - INTERVAL 19 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:E4:11:15')),
  (11.6, 7.27, 92.3, 50.5, 167, @ahora - INTERVAL 18 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:E4:11:15')),
  (38.2, 9.22, 304.2, 45.7, 249, @ahora - INTERVAL 17 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:E4:11:15')),
  (54.7, 7.94, 134.0, 75.7, 158, @ahora - INTERVAL 16 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:E4:11:15')),
  (45.6, 7.3, 360.8, 41.2, 182, @ahora - INTERVAL 15 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:E4:11:15')),
  (60.4, 11.11, 203.1, 58.9, 187, @ahora - INTERVAL 14 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:E4:11:15')),
  (50.2, 10.36, 366.2, 60.2, 239, @ahora - INTERVAL 13 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:E4:11:15')),
  (39.5, 7.44, 215.6, 26.5, 238, @ahora - INTERVAL 12 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:E4:11:15')),
  (53.4, 11.17, 322.5, 34.3, 167, @ahora - INTERVAL 11 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:E4:11:15')),
  (45.3, 9.21, 162.6, 18.1, 203, @ahora - INTERVAL 10 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:E4:11:15')),
  (70.2, 5.73, 236.3, 23.6, 193, @ahora - INTERVAL 9 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:E4:11:15')),
  (38.5, 9.21, 218.6, 10.5, 179, @ahora - INTERVAL 8 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:E4:11:15')),
  (38.9, 6.98, 189.2, 76.2, 150, @ahora - INTERVAL 7 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:E4:11:15')),
  (51.4, 6.84, 16.2, 22.6, 197, @ahora - INTERVAL 6 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:E4:11:15')),
  (28.8, 6.69, 355.9, 44.9, 222, @ahora - INTERVAL 5 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:E4:11:15')),
  (27.0, 8.78, 217.4, 25.4, 241, @ahora - INTERVAL 4 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:E4:11:15')),
  (48.4, 7.12, 210.3, 66.3, 256, @ahora - INTERVAL 3 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:E4:11:15')),
  (46.9, 9.25, 262.3, 4.6, 256, @ahora - INTERVAL 2 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:E4:11:15')),
  (47.1, 9.04, 129.0, 75.6, 153, @ahora - INTERVAL 1 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:E4:11:15'));
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES (58.8, 6.66, 343.0, 29.5, 175, (SELECT ultima_senal FROM equipo WHERE direccion_mac = '02:5E:0B:E4:11:15'), (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:E4:11:15'));
INSERT INTO almacenamiento (punto_montaje, capacidad_total_gb, espacio_libre_gb, id_informe) VALUES ('C:', 512, 262.4, LAST_INSERT_ID());
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES
  (42.3, 11.13, 48.7, 5.8, 197, @ahora - INTERVAL 24 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:09:1E:16')),
  (51.5, 7.56, 178.1, 9.9, 203, @ahora - INTERVAL 23 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:09:1E:16')),
  (14.8, 9.46, 280.4, 32.6, 149, @ahora - INTERVAL 22 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:09:1E:16')),
  (16.0, 6.42, 392.2, 74.9, 163, @ahora - INTERVAL 21 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:09:1E:16')),
  (31.5, 7.1, 138.1, 53.9, 182, @ahora - INTERVAL 20 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:09:1E:16')),
  (46.6, 5.72, 67.1, 30.0, 220, @ahora - INTERVAL 19 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:09:1E:16')),
  (29.9, 9.04, 272.3, 43.2, 246, @ahora - INTERVAL 18 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:09:1E:16')),
  (30.9, 8.49, 200.0, 21.0, 213, @ahora - INTERVAL 17 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:09:1E:16')),
  (35.6, 7.85, 268.3, 39.7, 198, @ahora - INTERVAL 16 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:09:1E:16')),
  (58.4, 10.65, 141.3, 39.7, 192, @ahora - INTERVAL 15 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:09:1E:16')),
  (53.2, 9.79, 147.0, 61.2, 222, @ahora - INTERVAL 14 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:09:1E:16')),
  (57.9, 10.71, 291.9, 53.5, 226, @ahora - INTERVAL 13 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:09:1E:16')),
  (75.7, 9.74, 257.9, 39.6, 209, @ahora - INTERVAL 12 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:09:1E:16')),
  (58.7, 8.37, 138.9, 6.5, 254, @ahora - INTERVAL 11 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:09:1E:16')),
  (41.8, 9.95, 352.3, 37.0, 202, @ahora - INTERVAL 10 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:09:1E:16')),
  (54.3, 8.52, 372.8, 33.2, 175, @ahora - INTERVAL 9 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:09:1E:16')),
  (10.0, 6.72, 10.2, 45.8, 196, @ahora - INTERVAL 8 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:09:1E:16')),
  (16.0, 6.37, 26.6, 61.6, 198, @ahora - INTERVAL 7 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:09:1E:16')),
  (24.0, 7.35, 21.8, 65.4, 199, @ahora - INTERVAL 6 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:09:1E:16')),
  (31.8, 11.18, 138.4, 24.9, 200, @ahora - INTERVAL 5 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:09:1E:16')),
  (35.6, 5.76, 390.6, 69.1, 214, @ahora - INTERVAL 4 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:09:1E:16')),
  (50.0, 6.6, 246.5, 59.4, 207, @ahora - INTERVAL 3 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:09:1E:16')),
  (17.0, 8.1, 381.9, 69.9, 175, @ahora - INTERVAL 2 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:09:1E:16')),
  (22.8, 6.29, 293.7, 17.7, 250, @ahora - INTERVAL 1 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:09:1E:16'));
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES (16.0, 7.42, 255.8, 36.8, 191, (SELECT ultima_senal FROM equipo WHERE direccion_mac = '02:5E:0B:09:1E:16'), (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:09:1E:16'));
INSERT INTO almacenamiento (punto_montaje, capacidad_total_gb, espacio_libre_gb, id_informe) VALUES ('C:', 512, 176.0, LAST_INSERT_ID());
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES
  (27.0, 19.85, 315.6, 79.0, 201, @ahora - INTERVAL 24 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:2E:2B:17')),
  (11.6, 22.09, 82.2, 18.7, 161, @ahora - INTERVAL 23 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:2E:2B:17')),
  (53.5, 14.23, 58.7, 78.9, 238, @ahora - INTERVAL 22 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:2E:2B:17')),
  (50.2, 21.17, 197.8, 10.1, 162, @ahora - INTERVAL 21 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:2E:2B:17')),
  (42.2, 14.23, 350.4, 63.7, 177, @ahora - INTERVAL 20 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:2E:2B:17')),
  (18.5, 11.64, 312.8, 23.0, 206, @ahora - INTERVAL 19 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:2E:2B:17')),
  (15.5, 22.04, 355.2, 17.2, 155, @ahora - INTERVAL 18 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:2E:2B:17')),
  (53.0, 20.49, 82.8, 46.5, 252, @ahora - INTERVAL 17 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:2E:2B:17')),
  (45.2, 21.29, 86.7, 41.3, 221, @ahora - INTERVAL 16 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:2E:2B:17')),
  (46.6, 18.11, 136.9, 38.5, 251, @ahora - INTERVAL 15 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:2E:2B:17')),
  (68.4, 14.47, 313.7, 26.8, 208, @ahora - INTERVAL 14 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:2E:2B:17')),
  (51.0, 13.1, 261.9, 6.9, 157, @ahora - INTERVAL 13 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:2E:2B:17')),
  (50.1, 21.86, 14.4, 57.9, 178, @ahora - INTERVAL 12 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:2E:2B:17')),
  (62.9, 15.63, 356.3, 7.2, 226, @ahora - INTERVAL 11 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:2E:2B:17')),
  (65.0, 21.11, 158.2, 32.1, 244, @ahora - INTERVAL 10 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:2E:2B:17')),
  (62.3, 22.39, 218.8, 29.3, 259, @ahora - INTERVAL 9 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:2E:2B:17')),
  (43.1, 21.51, 75.0, 64.9, 146, @ahora - INTERVAL 8 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:2E:2B:17')),
  (54.8, 15.24, 218.0, 62.2, 185, @ahora - INTERVAL 7 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:2E:2B:17')),
  (42.8, 14.61, 12.8, 28.3, 244, @ahora - INTERVAL 6 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:2E:2B:17')),
  (37.6, 13.69, 12.0, 67.7, 144, @ahora - INTERVAL 5 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:2E:2B:17')),
  (29.3, 14.7, 157.0, 69.6, 182, @ahora - INTERVAL 4 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:2E:2B:17')),
  (29.1, 13.2, 72.0, 68.0, 206, @ahora - INTERVAL 3 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:2E:2B:17')),
  (33.2, 21.69, 24.0, 60.6, 159, @ahora - INTERVAL 2 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:2E:2B:17')),
  (26.8, 15.04, 247.2, 3.6, 215, @ahora - INTERVAL 1 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:2E:2B:17'));
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES (36.1, 13.66, 110.7, 1.0, 183, (SELECT ultima_senal FROM equipo WHERE direccion_mac = '02:5E:0B:2E:2B:17'), (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:2E:2B:17'));
INSERT INTO almacenamiento (punto_montaje, capacidad_total_gb, espacio_libre_gb, id_informe) VALUES ('C:', 1000, 476.2, LAST_INSERT_ID());
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES
  (47.7, 4.46, 314.3, 55.8, 154, @ahora - INTERVAL 24 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:53:38:18')),
  (50.8, 3.16, 324.9, 30.2, 169, @ahora - INTERVAL 23 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:53:38:18')),
  (49.1, 3.67, 334.9, 63.7, 176, @ahora - INTERVAL 22 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:53:38:18')),
  (31.4, 3.66, 143.2, 48.5, 255, @ahora - INTERVAL 21 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:53:38:18')),
  (34.5, 5.32, 322.9, 70.0, 219, @ahora - INTERVAL 20 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:53:38:18')),
  (37.8, 4.86, 342.5, 48.1, 209, @ahora - INTERVAL 19 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:53:38:18')),
  (12.1, 2.93, 297.8, 57.2, 151, @ahora - INTERVAL 18 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:53:38:18')),
  (37.7, 4.73, 180.1, 1.9, 171, @ahora - INTERVAL 17 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:53:38:18')),
  (29.0, 3.2, 365.3, 41.3, 180, @ahora - INTERVAL 16 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:53:38:18')),
  (56.2, 4.93, 25.7, 59.0, 154, @ahora - INTERVAL 15 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:53:38:18')),
  (78.9, 5.05, 224.0, 62.2, 250, @ahora - INTERVAL 14 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:53:38:18')),
  (64.1, 3.94, 62.4, 19.8, 243, @ahora - INTERVAL 13 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:53:38:18')),
  (59.2, 5.43, 77.9, 28.1, 181, @ahora - INTERVAL 12 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:53:38:18')),
  (65.5, 4.07, 292.3, 38.2, 143, @ahora - INTERVAL 11 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:53:38:18')),
  (56.5, 4.39, 217.4, 77.0, 197, @ahora - INTERVAL 10 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:53:38:18')),
  (55.0, 3.17, 113.1, 22.9, 160, @ahora - INTERVAL 9 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:53:38:18')),
  (31.2, 5.52, 171.4, 44.6, 141, @ahora - INTERVAL 8 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:53:38:18')),
  (20.5, 3.13, 119.5, 55.7, 202, @ahora - INTERVAL 7 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:53:38:18')),
  (15.4, 3.05, 275.8, 11.8, 182, @ahora - INTERVAL 6 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:53:38:18')),
  (52.7, 3.09, 131.9, 71.7, 190, @ahora - INTERVAL 5 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:53:38:18')),
  (54.6, 3.75, 162.6, 59.5, 185, @ahora - INTERVAL 4 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:53:38:18')),
  (39.1, 5.06, 383.5, 2.7, 211, @ahora - INTERVAL 3 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:53:38:18')),
  (39.8, 4.79, 212.3, 41.2, 184, @ahora - INTERVAL 2 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:53:38:18')),
  (33.4, 4.41, 81.8, 18.3, 160, @ahora - INTERVAL 1 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:53:38:18'));
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES (39.4, 4.86, 181.5, 3.9, 152, (SELECT ultima_senal FROM equipo WHERE direccion_mac = '02:5E:0B:53:38:18'), (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:53:38:18'));
INSERT INTO almacenamiento (punto_montaje, capacidad_total_gb, espacio_libre_gb, id_informe) VALUES ('C:', 256, 175.9, LAST_INSERT_ID());
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES
  (18.5, 3.04, 140.3, 3.3, 253, @ahora - INTERVAL 24 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:78:45:19')),
  (26.3, 3.13, 240.3, 70.6, 189, @ahora - INTERVAL 23 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:78:45:19')),
  (22.3, 3.55, 182.4, 36.8, 205, @ahora - INTERVAL 22 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:78:45:19')),
  (19.3, 4.01, 234.4, 62.0, 155, @ahora - INTERVAL 21 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:78:45:19')),
  (29.9, 4.07, 175.6, 5.9, 256, @ahora - INTERVAL 20 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:78:45:19')),
  (21.6, 3.15, 158.7, 78.8, 213, @ahora - INTERVAL 19 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:78:45:19')),
  (27.7, 4.77, 22.1, 35.4, 210, @ahora - INTERVAL 18 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:78:45:19')),
  (19.6, 4.03, 110.3, 37.3, 152, @ahora - INTERVAL 17 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:78:45:19')),
  (23.5, 3.59, 193.1, 15.8, 221, @ahora - INTERVAL 16 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:78:45:19')),
  (41.8, 3.59, 268.6, 19.4, 225, @ahora - INTERVAL 15 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:78:45:19')),
  (51.3, 5.12, 10.4, 65.5, 179, @ahora - INTERVAL 14 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:78:45:19')),
  (45.1, 3.07, 371.8, 10.5, 204, @ahora - INTERVAL 13 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:78:45:19')),
  (71.5, 3.46, 43.9, 43.3, 255, @ahora - INTERVAL 12 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:78:45:19')),
  (35.5, 3.67, 268.5, 72.3, 179, @ahora - INTERVAL 11 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:78:45:19')),
  (60.1, 3.84, 76.3, 33.8, 204, @ahora - INTERVAL 10 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:78:45:19')),
  (55.6, 4.11, 284.4, 23.7, 228, @ahora - INTERVAL 9 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:78:45:19')),
  (52.7, 3.36, 327.3, 59.3, 198, @ahora - INTERVAL 8 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:78:45:19')),
  (18.9, 4.92, 143.7, 64.2, 253, @ahora - INTERVAL 7 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:78:45:19')),
  (43.9, 4.19, 67.8, 28.6, 181, @ahora - INTERVAL 6 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:78:45:19')),
  (42.1, 4.7, 133.6, 35.7, 236, @ahora - INTERVAL 5 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:78:45:19')),
  (31.4, 4.84, 335.3, 5.1, 150, @ahora - INTERVAL 4 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:78:45:19')),
  (14.6, 4.64, 74.4, 31.8, 163, @ahora - INTERVAL 3 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:78:45:19')),
  (28.8, 4.09, 170.3, 52.9, 190, @ahora - INTERVAL 2 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:78:45:19')),
  (50.3, 4.51, 33.7, 30.8, 224, @ahora - INTERVAL 1 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:78:45:19'));
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES (34.2, 3.35, 220.7, 63.3, 212, (SELECT ultima_senal FROM equipo WHERE direccion_mac = '02:5E:0B:78:45:19'), (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:78:45:19'));
INSERT INTO almacenamiento (punto_montaje, capacidad_total_gb, espacio_libre_gb, id_informe) VALUES ('C:', 512, 226.9, LAST_INSERT_ID());
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES
  (32.1, 7.16, 371.8, 49.8, 216, @ahora - INTERVAL 24 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:9D:52:1A')),
  (17.9, 9.77, 311.5, 45.7, 260, @ahora - INTERVAL 23 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:9D:52:1A')),
  (51.1, 8.22, 246.3, 70.7, 157, @ahora - INTERVAL 22 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:9D:52:1A')),
  (22.3, 9.71, 251.6, 4.6, 197, @ahora - INTERVAL 21 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:9D:52:1A')),
  (13.4, 9.97, 127.7, 68.0, 259, @ahora - INTERVAL 20 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:9D:52:1A')),
  (33.8, 8.38, 222.3, 33.5, 217, @ahora - INTERVAL 19 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:9D:52:1A')),
  (24.2, 7.61, 19.1, 18.1, 239, @ahora - INTERVAL 18 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:9D:52:1A')),
  (49.8, 11.14, 347.0, 24.5, 159, @ahora - INTERVAL 17 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:9D:52:1A')),
  (24.4, 6.16, 172.4, 38.8, 260, @ahora - INTERVAL 16 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:9D:52:1A')),
  (44.5, 10.68, 129.0, 28.5, 228, @ahora - INTERVAL 15 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:9D:52:1A')),
  (60.9, 5.86, 191.1, 42.7, 254, @ahora - INTERVAL 14 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:9D:52:1A')),
  (54.1, 7.89, 39.1, 19.6, 183, @ahora - INTERVAL 13 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:9D:52:1A')),
  (35.1, 10.97, 241.1, 46.4, 228, @ahora - INTERVAL 12 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:9D:52:1A')),
  (72.2, 6.19, 71.5, 53.2, 189, @ahora - INTERVAL 11 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:9D:52:1A')),
  (65.9, 7.21, 77.1, 53.3, 240, @ahora - INTERVAL 10 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:9D:52:1A')),
  (63.3, 8.13, 356.7, 58.5, 178, @ahora - INTERVAL 9 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:9D:52:1A')),
  (23.9, 7.08, 271.1, 11.4, 224, @ahora - INTERVAL 8 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:9D:52:1A')),
  (43.0, 10.11, 365.0, 21.7, 181, @ahora - INTERVAL 7 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:9D:52:1A')),
  (14.0, 6.52, 260.1, 75.1, 220, @ahora - INTERVAL 6 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:9D:52:1A')),
  (20.1, 6.9, 134.3, 73.1, 213, @ahora - INTERVAL 5 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:9D:52:1A')),
  (28.6, 10.16, 112.1, 23.7, 210, @ahora - INTERVAL 4 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:9D:52:1A')),
  (12.2, 8.08, 318.7, 33.0, 209, @ahora - INTERVAL 3 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:9D:52:1A')),
  (17.0, 9.09, 138.8, 41.7, 253, @ahora - INTERVAL 2 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:9D:52:1A')),
  (12.7, 9.56, 177.0, 15.0, 256, @ahora - INTERVAL 1 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:9D:52:1A'));
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES (10.8, 8.44, 366.7, 65.4, 176, (SELECT ultima_senal FROM equipo WHERE direccion_mac = '02:5E:0B:9D:52:1A'), (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:9D:52:1A'));
INSERT INTO almacenamiento (punto_montaje, capacidad_total_gb, espacio_libre_gb, id_informe) VALUES ('C:', 512, 140.9, LAST_INSERT_ID());
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES
  (30.5, 8.12, 84.8, 3.6, 145, @ahora - INTERVAL 24 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:C2:5F:1B')),
  (16.6, 9.53, 198.9, 50.6, 244, @ahora - INTERVAL 23 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:C2:5F:1B')),
  (42.3, 10.76, 151.9, 25.3, 208, @ahora - INTERVAL 22 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:C2:5F:1B')),
  (30.8, 6.06, 278.4, 2.0, 152, @ahora - INTERVAL 21 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:C2:5F:1B')),
  (10.1, 11.06, 57.7, 49.3, 232, @ahora - INTERVAL 20 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:C2:5F:1B')),
  (17.6, 8.01, 317.9, 78.7, 203, @ahora - INTERVAL 19 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:C2:5F:1B')),
  (49.1, 8.4, 54.9, 19.7, 239, @ahora - INTERVAL 18 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:C2:5F:1B')),
  (28.1, 10.53, 378.9, 57.1, 246, @ahora - INTERVAL 17 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:C2:5F:1B')),
  (38.4, 10.0, 19.4, 22.1, 249, @ahora - INTERVAL 16 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:C2:5F:1B')),
  (71.9, 6.73, 371.3, 32.7, 207, @ahora - INTERVAL 15 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:C2:5F:1B')),
  (59.0, 7.07, 306.4, 69.9, 164, @ahora - INTERVAL 14 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:C2:5F:1B')),
  (53.8, 10.13, 11.3, 78.8, 255, @ahora - INTERVAL 13 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:C2:5F:1B')),
  (40.6, 6.63, 252.5, 55.9, 189, @ahora - INTERVAL 12 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:C2:5F:1B')),
  (75.0, 6.24, 335.7, 52.2, 182, @ahora - INTERVAL 11 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:C2:5F:1B')),
  (76.1, 9.14, 333.0, 56.8, 210, @ahora - INTERVAL 10 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:C2:5F:1B')),
  (39.2, 11.11, 13.4, 54.1, 240, @ahora - INTERVAL 9 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:C2:5F:1B')),
  (10.2, 7.01, 148.8, 33.9, 156, @ahora - INTERVAL 8 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:C2:5F:1B')),
  (53.1, 7.98, 281.2, 20.8, 151, @ahora - INTERVAL 7 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:C2:5F:1B')),
  (17.5, 9.25, 44.4, 22.4, 230, @ahora - INTERVAL 6 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:C2:5F:1B')),
  (26.0, 10.62, 304.9, 4.5, 161, @ahora - INTERVAL 5 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:C2:5F:1B')),
  (45.1, 7.49, 259.2, 41.0, 209, @ahora - INTERVAL 4 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:C2:5F:1B')),
  (19.5, 6.36, 43.7, 79.0, 235, @ahora - INTERVAL 3 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:C2:5F:1B')),
  (46.8, 6.74, 233.7, 43.4, 153, @ahora - INTERVAL 2 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:C2:5F:1B')),
  (9.8, 5.86, 229.8, 60.0, 163, @ahora - INTERVAL 1 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:C2:5F:1B'));
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES (59.9, 7.29, 351.2, 20.5, 241, (SELECT ultima_senal FROM equipo WHERE direccion_mac = '02:5E:0B:C2:5F:1B'), (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:C2:5F:1B'));
INSERT INTO almacenamiento (punto_montaje, capacidad_total_gb, espacio_libre_gb, id_informe) VALUES ('C:', 1000, 696.0, LAST_INSERT_ID());
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES
  (18.8, 10.87, 293.3, 13.1, 141, @ahora - INTERVAL 24 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:E7:6C:1C')),
  (52.3, 8.68, 328.5, 71.7, 240, @ahora - INTERVAL 23 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:E7:6C:1C')),
  (23.6, 9.75, 227.5, 46.5, 256, @ahora - INTERVAL 22 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:E7:6C:1C')),
  (48.5, 6.28, 246.5, 56.4, 164, @ahora - INTERVAL 21 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:E7:6C:1C')),
  (10.5, 10.41, 147.8, 79.0, 252, @ahora - INTERVAL 20 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:E7:6C:1C')),
  (38.8, 9.92, 312.6, 33.4, 202, @ahora - INTERVAL 19 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:E7:6C:1C')),
  (40.6, 8.69, 134.2, 3.8, 230, @ahora - INTERVAL 18 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:E7:6C:1C')),
  (23.1, 7.89, 77.5, 70.0, 249, @ahora - INTERVAL 17 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:E7:6C:1C')),
  (54.2, 6.01, 78.0, 9.0, 240, @ahora - INTERVAL 16 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:E7:6C:1C')),
  (67.1, 10.59, 351.4, 44.5, 176, @ahora - INTERVAL 15 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:E7:6C:1C')),
  (49.5, 8.69, 375.5, 70.5, 221, @ahora - INTERVAL 14 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:E7:6C:1C')),
  (36.2, 7.45, 26.2, 62.4, 175, @ahora - INTERVAL 13 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:E7:6C:1C')),
  (71.7, 9.06, 91.8, 73.2, 251, @ahora - INTERVAL 12 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:E7:6C:1C')),
  (78.3, 7.29, 256.9, 47.6, 259, @ahora - INTERVAL 11 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:E7:6C:1C')),
  (62.3, 10.37, 363.3, 47.7, 202, @ahora - INTERVAL 10 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:E7:6C:1C')),
  (34.2, 10.19, 194.1, 21.7, 242, @ahora - INTERVAL 9 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:E7:6C:1C')),
  (35.2, 6.31, 378.2, 24.1, 143, @ahora - INTERVAL 8 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:E7:6C:1C')),
  (44.0, 7.19, 288.7, 6.0, 207, @ahora - INTERVAL 7 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:E7:6C:1C')),
  (9.1, 9.38, 96.9, 70.9, 144, @ahora - INTERVAL 6 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:E7:6C:1C')),
  (11.0, 6.18, 236.1, 31.7, 158, @ahora - INTERVAL 5 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:E7:6C:1C')),
  (10.8, 6.98, 121.3, 42.7, 159, @ahora - INTERVAL 4 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:E7:6C:1C')),
  (8.1, 6.73, 17.9, 37.4, 176, @ahora - INTERVAL 3 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:E7:6C:1C')),
  (12.7, 6.31, 234.1, 67.0, 142, @ahora - INTERVAL 2 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:E7:6C:1C')),
  (23.8, 6.89, 135.2, 12.5, 227, @ahora - INTERVAL 1 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:E7:6C:1C'));
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES (48.0, 5.94, 42.9, 44.7, 196, (SELECT ultima_senal FROM equipo WHERE direccion_mac = '02:5E:0B:E7:6C:1C'), (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:E7:6C:1C'));
INSERT INTO almacenamiento (punto_montaje, capacidad_total_gb, espacio_libre_gb, id_informe) VALUES ('C:', 256, 76.9, LAST_INSERT_ID());
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES
  (23.2, 13.73, 202.0, 1.9, 228, @ahora - INTERVAL 24 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:0C:79:1D')),
  (45.0, 19.23, 259.9, 28.2, 167, @ahora - INTERVAL 23 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:0C:79:1D')),
  (31.4, 20.89, 355.0, 2.0, 197, @ahora - INTERVAL 22 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:0C:79:1D')),
  (14.2, 16.57, 301.8, 14.3, 178, @ahora - INTERVAL 21 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:0C:79:1D')),
  (42.5, 20.48, 324.9, 23.4, 251, @ahora - INTERVAL 20 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:0C:79:1D')),
  (43.7, 14.31, 60.9, 57.4, 223, @ahora - INTERVAL 19 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:0C:79:1D')),
  (12.1, 13.31, 82.4, 77.6, 140, @ahora - INTERVAL 18 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:0C:79:1D')),
  (40.4, 19.26, 173.8, 59.0, 144, @ahora - INTERVAL 17 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:0C:79:1D')),
  (37.7, 12.5, 172.3, 27.1, 166, @ahora - INTERVAL 16 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:0C:79:1D')),
  (51.5, 21.4, 344.2, 61.7, 155, @ahora - INTERVAL 15 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:0C:79:1D')),
  (43.1, 20.49, 243.1, 75.4, 188, @ahora - INTERVAL 14 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:0C:79:1D')),
  (62.6, 21.19, 327.5, 53.6, 229, @ahora - INTERVAL 13 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:0C:79:1D')),
  (55.9, 17.73, 252.1, 37.3, 175, @ahora - INTERVAL 12 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:0C:79:1D')),
  (52.9, 13.92, 55.4, 58.1, 203, @ahora - INTERVAL 11 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:0C:79:1D')),
  (71.5, 22.05, 55.7, 66.8, 244, @ahora - INTERVAL 10 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:0C:79:1D')),
  (55.8, 20.12, 394.0, 4.6, 147, @ahora - INTERVAL 9 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:0C:79:1D')),
  (9.5, 19.68, 102.8, 74.7, 177, @ahora - INTERVAL 8 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:0C:79:1D')),
  (25.3, 17.64, 135.3, 49.8, 197, @ahora - INTERVAL 7 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:0C:79:1D')),
  (54.7, 11.68, 189.9, 16.5, 215, @ahora - INTERVAL 6 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:0C:79:1D')),
  (20.7, 20.13, 147.2, 24.5, 167, @ahora - INTERVAL 5 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:0C:79:1D')),
  (32.1, 15.01, 164.6, 75.8, 234, @ahora - INTERVAL 4 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:0C:79:1D')),
  (11.5, 13.31, 112.6, 58.5, 200, @ahora - INTERVAL 3 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:0C:79:1D')),
  (23.7, 13.06, 352.5, 44.8, 143, @ahora - INTERVAL 2 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:0C:79:1D')),
  (32.8, 15.01, 344.6, 50.7, 219, @ahora - INTERVAL 1 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:0C:79:1D'));
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES (52.6, 13.85, 98.9, 66.7, 177, (SELECT ultima_senal FROM equipo WHERE direccion_mac = '02:5E:0B:0C:79:1D'), (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:0C:79:1D'));
INSERT INTO almacenamiento (punto_montaje, capacidad_total_gb, espacio_libre_gb, id_informe) VALUES ('C:', 512, 215.3, LAST_INSERT_ID());
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES
  (28.2, 3.22, 167.8, 76.4, 183, @ahora - INTERVAL 24 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:31:86:1E')),
  (42.3, 4.64, 186.0, 9.6, 146, @ahora - INTERVAL 23 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:31:86:1E')),
  (25.6, 4.0, 364.2, 61.0, 192, @ahora - INTERVAL 22 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:31:86:1E')),
  (29.6, 5.09, 7.6, 56.9, 192, @ahora - INTERVAL 21 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:31:86:1E')),
  (23.5, 3.05, 178.7, 18.6, 223, @ahora - INTERVAL 20 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:31:86:1E')),
  (37.8, 4.41, 242.1, 32.0, 164, @ahora - INTERVAL 19 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:31:86:1E')),
  (32.4, 3.67, 58.3, 38.5, 194, @ahora - INTERVAL 18 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:31:86:1E')),
  (32.4, 5.09, 297.3, 18.0, 248, @ahora - INTERVAL 17 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:31:86:1E')),
  (14.3, 4.19, 318.0, 29.7, 145, @ahora - INTERVAL 16 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:31:86:1E')),
  (69.2, 3.38, 343.5, 47.4, 250, @ahora - INTERVAL 15 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:31:86:1E')),
  (73.9, 2.9, 375.7, 17.7, 252, @ahora - INTERVAL 14 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:31:86:1E')),
  (40.1, 5.49, 245.1, 68.7, 149, @ahora - INTERVAL 13 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:31:86:1E')),
  (44.1, 4.15, 128.7, 39.4, 254, @ahora - INTERVAL 12 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:31:86:1E')),
  (35.2, 3.54, 106.8, 10.3, 205, @ahora - INTERVAL 11 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:31:86:1E')),
  (45.6, 4.28, 138.2, 14.5, 238, @ahora - INTERVAL 10 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:31:86:1E')),
  (77.3, 4.9, 297.9, 62.0, 182, @ahora - INTERVAL 9 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:31:86:1E')),
  (51.4, 4.49, 235.5, 41.5, 219, @ahora - INTERVAL 8 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:31:86:1E')),
  (17.2, 4.81, 60.5, 30.8, 236, @ahora - INTERVAL 7 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:31:86:1E')),
  (18.1, 2.95, 139.5, 53.3, 196, @ahora - INTERVAL 6 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:31:86:1E')),
  (35.4, 5.58, 288.9, 36.9, 249, @ahora - INTERVAL 5 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:31:86:1E')),
  (24.4, 5.23, 37.8, 33.5, 160, @ahora - INTERVAL 4 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:31:86:1E')),
  (12.2, 5.28, 291.1, 8.7, 175, @ahora - INTERVAL 3 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:31:86:1E')),
  (47.0, 3.41, 322.1, 67.2, 244, @ahora - INTERVAL 2 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:31:86:1E')),
  (44.6, 4.85, 232.0, 67.7, 180, @ahora - INTERVAL 1 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:31:86:1E'));
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES (45.3, 3.87, 309.8, 34.1, 258, (SELECT ultima_senal FROM equipo WHERE direccion_mac = '02:5E:0B:31:86:1E'), (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0B:31:86:1E'));
INSERT INTO almacenamiento (punto_montaje, capacidad_total_gb, espacio_libre_gb, id_informe) VALUES ('C:', 512, 353.1, LAST_INSERT_ID());
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES
  (53.5, 3.81, 357.6, 44.5, 181, @ahora - INTERVAL 24 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:00:93:1F')),
  (48.3, 4.21, 110.4, 12.4, 168, @ahora - INTERVAL 23 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:00:93:1F')),
  (37.8, 4.36, 44.4, 54.2, 163, @ahora - INTERVAL 22 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:00:93:1F')),
  (23.6, 4.4, 291.2, 73.4, 233, @ahora - INTERVAL 21 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:00:93:1F')),
  (35.8, 3.68, 9.4, 37.0, 238, @ahora - INTERVAL 20 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:00:93:1F')),
  (11.6, 3.81, 292.8, 25.4, 240, @ahora - INTERVAL 19 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:00:93:1F')),
  (19.7, 5.03, 164.8, 32.7, 234, @ahora - INTERVAL 18 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:00:93:1F')),
  (29.4, 5.32, 345.4, 5.0, 179, @ahora - INTERVAL 17 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:00:93:1F')),
  (13.5, 3.47, 376.8, 45.7, 179, @ahora - INTERVAL 16 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:00:93:1F')),
  (57.0, 3.21, 337.6, 42.7, 226, @ahora - INTERVAL 15 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:00:93:1F')),
  (56.9, 4.84, 59.3, 74.9, 224, @ahora - INTERVAL 14 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:00:93:1F')),
  (45.6, 4.53, 39.4, 78.4, 143, @ahora - INTERVAL 13 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:00:93:1F')),
  (33.6, 4.74, 361.5, 22.4, 143, @ahora - INTERVAL 12 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:00:93:1F')),
  (35.0, 3.71, 53.3, 58.6, 159, @ahora - INTERVAL 11 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:00:93:1F')),
  (61.2, 2.88, 228.5, 71.6, 151, @ahora - INTERVAL 10 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:00:93:1F')),
  (33.5, 2.83, 24.3, 39.6, 176, @ahora - INTERVAL 9 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:00:93:1F')),
  (21.9, 5.41, 391.0, 31.5, 202, @ahora - INTERVAL 8 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:00:93:1F')),
  (52.4, 3.02, 235.8, 22.3, 198, @ahora - INTERVAL 7 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:00:93:1F')),
  (46.4, 4.23, 94.3, 42.3, 175, @ahora - INTERVAL 6 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:00:93:1F')),
  (24.9, 4.86, 290.8, 8.6, 181, @ahora - INTERVAL 5 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:00:93:1F')),
  (18.7, 2.82, 139.5, 24.7, 220, @ahora - INTERVAL 4 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:00:93:1F')),
  (16.8, 5.03, 190.5, 60.7, 141, @ahora - INTERVAL 3 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:00:93:1F')),
  (25.4, 3.57, 214.9, 13.3, 141, @ahora - INTERVAL 2 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:00:93:1F')),
  (21.2, 4.71, 111.9, 43.1, 216, @ahora - INTERVAL 1 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:00:93:1F'));
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES (41.5, 3.01, 129.4, 55.3, 183, (SELECT ultima_senal FROM equipo WHERE direccion_mac = '02:5E:0D:00:93:1F'), (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:00:93:1F'));
INSERT INTO almacenamiento (punto_montaje, capacidad_total_gb, espacio_libre_gb, id_informe) VALUES ('C:', 1000, 304.8, LAST_INSERT_ID());
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES
  (30.5, 10.41, 250.7, 51.6, 250, @ahora - INTERVAL 24 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:25:A0:20')),
  (35.0, 7.05, 153.4, 21.5, 162, @ahora - INTERVAL 23 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:25:A0:20')),
  (45.8, 8.26, 224.8, 57.5, 193, @ahora - INTERVAL 22 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:25:A0:20')),
  (54.5, 7.05, 40.0, 34.6, 206, @ahora - INTERVAL 21 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:25:A0:20')),
  (53.1, 7.69, 174.6, 59.5, 143, @ahora - INTERVAL 20 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:25:A0:20')),
  (18.7, 10.94, 116.0, 50.3, 150, @ahora - INTERVAL 19 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:25:A0:20')),
  (36.2, 8.88, 41.4, 2.7, 185, @ahora - INTERVAL 18 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:25:A0:20')),
  (21.2, 7.43, 354.8, 64.8, 258, @ahora - INTERVAL 17 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:25:A0:20')),
  (23.7, 8.66, 370.4, 55.9, 150, @ahora - INTERVAL 16 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:25:A0:20')),
  (59.5, 8.4, 319.9, 42.3, 165, @ahora - INTERVAL 15 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:25:A0:20')),
  (39.7, 8.52, 134.2, 44.5, 246, @ahora - INTERVAL 14 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:25:A0:20')),
  (40.8, 7.87, 100.1, 37.0, 223, @ahora - INTERVAL 13 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:25:A0:20')),
  (62.3, 7.76, 112.2, 57.8, 260, @ahora - INTERVAL 12 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:25:A0:20')),
  (71.5, 10.18, 324.0, 72.4, 257, @ahora - INTERVAL 11 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:25:A0:20')),
  (57.1, 9.76, 393.0, 15.3, 237, @ahora - INTERVAL 10 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:25:A0:20')),
  (71.7, 5.96, 304.7, 37.7, 171, @ahora - INTERVAL 9 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:25:A0:20')),
  (46.1, 10.99, 285.0, 47.8, 167, @ahora - INTERVAL 8 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:25:A0:20')),
  (16.5, 10.51, 26.7, 49.8, 169, @ahora - INTERVAL 7 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:25:A0:20')),
  (20.5, 6.24, 19.1, 59.3, 247, @ahora - INTERVAL 6 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:25:A0:20')),
  (16.2, 10.7, 235.9, 38.5, 257, @ahora - INTERVAL 5 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:25:A0:20')),
  (47.7, 9.98, 339.9, 14.5, 218, @ahora - INTERVAL 4 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:25:A0:20')),
  (46.9, 9.46, 160.1, 78.2, 220, @ahora - INTERVAL 3 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:25:A0:20')),
  (32.9, 8.23, 97.9, 63.6, 173, @ahora - INTERVAL 2 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:25:A0:20')),
  (14.1, 8.28, 149.7, 68.6, 181, @ahora - INTERVAL 1 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:25:A0:20'));
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES (23.7, 8.59, 246.5, 77.9, 258, (SELECT ultima_senal FROM equipo WHERE direccion_mac = '02:5E:0D:25:A0:20'), (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:25:A0:20'));
INSERT INTO almacenamiento (punto_montaje, capacidad_total_gb, espacio_libre_gb, id_informe) VALUES ('C:', 256, 176.4, LAST_INSERT_ID());
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES
  (8.1, 6.88, 306.3, 45.9, 260, @ahora - INTERVAL 24 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:4A:AD:21')),
  (14.8, 8.83, 50.8, 72.0, 203, @ahora - INTERVAL 23 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:4A:AD:21')),
  (47.6, 9.85, 243.9, 68.1, 185, @ahora - INTERVAL 22 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:4A:AD:21')),
  (30.8, 10.97, 336.4, 39.3, 153, @ahora - INTERVAL 21 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:4A:AD:21')),
  (35.0, 9.32, 222.0, 10.4, 215, @ahora - INTERVAL 20 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:4A:AD:21')),
  (37.9, 8.68, 6.5, 73.6, 166, @ahora - INTERVAL 19 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:4A:AD:21')),
  (20.0, 6.58, 90.2, 23.5, 252, @ahora - INTERVAL 18 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:4A:AD:21')),
  (23.2, 5.97, 183.2, 56.6, 185, @ahora - INTERVAL 17 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:4A:AD:21')),
  (37.3, 8.62, 289.1, 34.3, 150, @ahora - INTERVAL 16 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:4A:AD:21')),
  (41.0, 10.04, 183.0, 61.6, 215, @ahora - INTERVAL 15 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:4A:AD:21')),
  (41.3, 6.58, 23.5, 7.7, 200, @ahora - INTERVAL 14 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:4A:AD:21')),
  (65.7, 10.18, 302.9, 21.0, 239, @ahora - INTERVAL 13 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:4A:AD:21')),
  (50.4, 6.55, 77.7, 13.5, 232, @ahora - INTERVAL 12 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:4A:AD:21')),
  (56.0, 5.93, 38.6, 18.8, 189, @ahora - INTERVAL 11 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:4A:AD:21')),
  (41.3, 8.4, 336.6, 72.5, 254, @ahora - INTERVAL 10 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:4A:AD:21')),
  (49.0, 10.73, 107.4, 55.7, 194, @ahora - INTERVAL 9 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:4A:AD:21')),
  (9.2, 8.6, 261.2, 74.8, 225, @ahora - INTERVAL 8 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:4A:AD:21')),
  (50.0, 9.73, 314.3, 58.8, 222, @ahora - INTERVAL 7 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:4A:AD:21')),
  (15.6, 6.65, 278.7, 25.8, 193, @ahora - INTERVAL 6 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:4A:AD:21')),
  (23.2, 5.62, 107.5, 59.2, 179, @ahora - INTERVAL 5 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:4A:AD:21')),
  (15.0, 7.0, 305.6, 14.6, 154, @ahora - INTERVAL 4 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:4A:AD:21')),
  (53.7, 9.54, 260.1, 9.6, 214, @ahora - INTERVAL 3 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:4A:AD:21')),
  (20.8, 6.5, 41.3, 24.5, 180, @ahora - INTERVAL 2 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:4A:AD:21')),
  (44.8, 7.51, 332.9, 15.8, 230, @ahora - INTERVAL 1 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:4A:AD:21'));
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES (36.5, 6.4, 297.2, 41.7, 255, (SELECT ultima_senal FROM equipo WHERE direccion_mac = '02:5E:0D:4A:AD:21'), (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:4A:AD:21'));
INSERT INTO almacenamiento (punto_montaje, capacidad_total_gb, espacio_libre_gb, id_informe) VALUES ('C:', 512, 273.6, LAST_INSERT_ID());
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES (56.4, 8.34, 386.2, 30.6, 246, (SELECT ultima_senal FROM equipo WHERE direccion_mac = '02:5E:0D:6F:BA:22'), (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:6F:BA:22'));
INSERT INTO almacenamiento (punto_montaje, capacidad_total_gb, espacio_libre_gb, id_informe) VALUES ('C:', 512, 197.2, LAST_INSERT_ID());
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES (14.1, 3.3, 71.2, 40.9, 215, (SELECT ultima_senal FROM equipo WHERE direccion_mac = '02:5E:0D:B9:D4:24'), (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:B9:D4:24'));
INSERT INTO almacenamiento (punto_montaje, capacidad_total_gb, espacio_libre_gb, id_informe) VALUES ('C:', 256, 80.9, LAST_INSERT_ID());
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES
  (34.0, 4.08, 264.9, 2.4, 252, @ahora - INTERVAL 24 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:DE:E1:25')),
  (28.5, 4.62, 68.5, 46.9, 236, @ahora - INTERVAL 23 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:DE:E1:25')),
  (17.0, 4.4, 306.6, 27.9, 227, @ahora - INTERVAL 22 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:DE:E1:25')),
  (20.8, 4.45, 313.1, 25.2, 172, @ahora - INTERVAL 21 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:DE:E1:25')),
  (19.5, 4.31, 98.5, 47.0, 143, @ahora - INTERVAL 20 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:DE:E1:25')),
  (31.9, 3.67, 375.3, 25.7, 243, @ahora - INTERVAL 19 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:DE:E1:25')),
  (53.6, 3.67, 287.2, 75.0, 141, @ahora - INTERVAL 18 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:DE:E1:25')),
  (28.9, 3.85, 103.0, 21.3, 146, @ahora - INTERVAL 17 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:DE:E1:25')),
  (21.9, 4.25, 280.7, 71.3, 151, @ahora - INTERVAL 16 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:DE:E1:25')),
  (55.5, 4.35, 20.1, 79.9, 254, @ahora - INTERVAL 15 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:DE:E1:25')),
  (36.7, 5.58, 155.0, 73.8, 187, @ahora - INTERVAL 14 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:DE:E1:25')),
  (46.0, 3.97, 38.4, 40.2, 184, @ahora - INTERVAL 13 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:DE:E1:25')),
  (44.3, 5.01, 301.5, 60.3, 254, @ahora - INTERVAL 12 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:DE:E1:25')),
  (48.2, 3.14, 374.4, 64.1, 146, @ahora - INTERVAL 11 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:DE:E1:25')),
  (63.1, 4.01, 71.6, 70.9, 167, @ahora - INTERVAL 10 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:DE:E1:25')),
  (37.7, 3.1, 108.4, 21.4, 246, @ahora - INTERVAL 9 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:DE:E1:25')),
  (22.3, 3.71, 232.9, 48.5, 202, @ahora - INTERVAL 8 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:DE:E1:25')),
  (12.7, 2.99, 120.4, 78.0, 168, @ahora - INTERVAL 7 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:DE:E1:25')),
  (8.5, 4.34, 246.6, 21.0, 161, @ahora - INTERVAL 6 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:DE:E1:25')),
  (35.9, 4.23, 106.9, 31.0, 220, @ahora - INTERVAL 5 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:DE:E1:25')),
  (54.8, 4.16, 136.0, 1.7, 251, @ahora - INTERVAL 4 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:DE:E1:25')),
  (26.0, 5.17, 5.0, 8.5, 212, @ahora - INTERVAL 3 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:DE:E1:25')),
  (43.0, 3.1, 44.8, 66.6, 159, @ahora - INTERVAL 2 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:DE:E1:25')),
  (38.1, 5.17, 33.0, 74.2, 200, @ahora - INTERVAL 1 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:DE:E1:25'));
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES (59.0, 7.39, 380.2, 51.9, 171, (SELECT ultima_senal FROM equipo WHERE direccion_mac = '02:5E:0D:DE:E1:25'), (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:DE:E1:25'));
INSERT INTO almacenamiento (punto_montaje, capacidad_total_gb, espacio_libre_gb, id_informe) VALUES ('C:', 512, 19.3, LAST_INSERT_ID());
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES
  (53.1, 11.19, 378.0, 58.1, 211, @ahora - INTERVAL 24 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:03:EE:26')),
  (46.6, 10.78, 160.3, 25.6, 209, @ahora - INTERVAL 23 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:03:EE:26')),
  (44.6, 10.31, 191.0, 32.6, 255, @ahora - INTERVAL 22 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:03:EE:26')),
  (41.8, 6.98, 126.9, 2.8, 249, @ahora - INTERVAL 21 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:03:EE:26')),
  (28.6, 9.28, 325.4, 46.7, 155, @ahora - INTERVAL 20 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:03:EE:26')),
  (39.3, 7.56, 201.1, 41.1, 175, @ahora - INTERVAL 19 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:03:EE:26')),
  (30.5, 10.59, 177.5, 40.3, 188, @ahora - INTERVAL 18 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:03:EE:26')),
  (44.1, 7.16, 366.2, 41.0, 155, @ahora - INTERVAL 17 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:03:EE:26')),
  (9.3, 9.78, 230.3, 18.4, 238, @ahora - INTERVAL 16 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:03:EE:26')),
  (64.6, 6.02, 218.1, 74.6, 169, @ahora - INTERVAL 15 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:03:EE:26')),
  (70.6, 10.56, 117.6, 21.1, 248, @ahora - INTERVAL 14 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:03:EE:26')),
  (79.1, 6.74, 73.8, 24.3, 168, @ahora - INTERVAL 13 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:03:EE:26')),
  (67.2, 6.97, 108.4, 73.1, 179, @ahora - INTERVAL 12 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:03:EE:26')),
  (73.2, 10.27, 200.7, 79.4, 185, @ahora - INTERVAL 11 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:03:EE:26')),
  (76.6, 10.23, 265.8, 2.1, 200, @ahora - INTERVAL 10 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:03:EE:26')),
  (38.8, 5.96, 388.5, 31.7, 256, @ahora - INTERVAL 9 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:03:EE:26')),
  (16.0, 5.61, 84.4, 4.0, 257, @ahora - INTERVAL 8 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:03:EE:26')),
  (22.5, 9.87, 314.7, 59.9, 240, @ahora - INTERVAL 7 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:03:EE:26')),
  (41.0, 7.98, 243.2, 7.6, 184, @ahora - INTERVAL 6 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:03:EE:26')),
  (44.7, 9.86, 305.8, 59.8, 237, @ahora - INTERVAL 5 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:03:EE:26')),
  (27.4, 10.54, 297.4, 27.6, 215, @ahora - INTERVAL 4 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:03:EE:26')),
  (16.7, 7.27, 211.1, 73.8, 161, @ahora - INTERVAL 3 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:03:EE:26')),
  (48.2, 9.31, 128.9, 24.7, 200, @ahora - INTERVAL 2 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:03:EE:26')),
  (42.3, 10.43, 60.2, 40.2, 234, @ahora - INTERVAL 1 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:03:EE:26'));
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES (94.1, 11.03, 379.1, 3.7, 254, (SELECT ultima_senal FROM equipo WHERE direccion_mac = '02:5E:0D:03:EE:26'), (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:03:EE:26'));
INSERT INTO almacenamiento (punto_montaje, capacidad_total_gb, espacio_libre_gb, id_informe) VALUES ('C:', 512, 19.3, LAST_INSERT_ID());
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES
  (14.0, 9.01, 207.5, 28.0, 259, @ahora - INTERVAL 24 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:4D:08:28')),
  (45.3, 10.99, 213.2, 69.5, 151, @ahora - INTERVAL 23 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:4D:08:28')),
  (9.1, 8.6, 221.4, 12.8, 180, @ahora - INTERVAL 22 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:4D:08:28')),
  (45.0, 10.99, 345.7, 54.6, 219, @ahora - INTERVAL 21 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:4D:08:28')),
  (19.3, 10.84, 329.6, 25.8, 213, @ahora - INTERVAL 20 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:4D:08:28')),
  (13.4, 7.91, 152.5, 27.2, 204, @ahora - INTERVAL 19 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:4D:08:28')),
  (17.5, 7.01, 97.6, 35.3, 148, @ahora - INTERVAL 18 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:4D:08:28')),
  (34.2, 9.98, 302.0, 38.3, 188, @ahora - INTERVAL 17 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:4D:08:28')),
  (38.7, 9.13, 104.7, 23.1, 148, @ahora - INTERVAL 16 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:4D:08:28')),
  (48.6, 8.51, 372.3, 55.5, 232, @ahora - INTERVAL 15 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:4D:08:28')),
  (59.3, 10.98, 390.3, 77.6, 190, @ahora - INTERVAL 14 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:4D:08:28')),
  (43.5, 8.35, 269.4, 10.2, 199, @ahora - INTERVAL 13 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:4D:08:28')),
  (39.3, 9.56, 329.0, 12.5, 189, @ahora - INTERVAL 12 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:4D:08:28')),
  (71.3, 10.71, 93.9, 29.9, 173, @ahora - INTERVAL 11 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:4D:08:28')),
  (49.3, 9.21, 169.2, 1.5, 237, @ahora - INTERVAL 10 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:4D:08:28')),
  (77.2, 10.85, 339.3, 79.8, 196, @ahora - INTERVAL 9 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:4D:08:28')),
  (20.0, 10.16, 58.7, 34.6, 157, @ahora - INTERVAL 8 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:4D:08:28')),
  (36.8, 6.86, 67.0, 27.8, 165, @ahora - INTERVAL 7 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:4D:08:28')),
  (33.6, 7.46, 354.0, 26.4, 172, @ahora - INTERVAL 6 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:4D:08:28')),
  (49.7, 9.25, 207.3, 22.1, 188, @ahora - INTERVAL 5 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:4D:08:28')),
  (22.5, 10.83, 367.0, 44.7, 259, @ahora - INTERVAL 4 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:4D:08:28')),
  (22.6, 8.85, 374.6, 72.5, 227, @ahora - INTERVAL 3 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:4D:08:28')),
  (44.5, 6.88, 102.9, 15.9, 194, @ahora - INTERVAL 2 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:4D:08:28')),
  (16.0, 9.26, 350.4, 68.8, 158, @ahora - INTERVAL 1 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:4D:08:28'));
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES (40.6, 11.04, 275.5, 49.1, 201, (SELECT ultima_senal FROM equipo WHERE direccion_mac = '02:5E:0D:4D:08:28'), (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:4D:08:28'));
INSERT INTO almacenamiento (punto_montaje, capacidad_total_gb, espacio_libre_gb, id_informe) VALUES ('C:', 256, 67.9, LAST_INSERT_ID());
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES
  (34.2, 12.1, 123.2, 42.4, 146, @ahora - INTERVAL 24 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:72:15:29')),
  (40.7, 13.06, 331.2, 66.6, 164, @ahora - INTERVAL 23 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:72:15:29')),
  (30.0, 16.8, 236.7, 38.4, 215, @ahora - INTERVAL 22 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:72:15:29')),
  (40.5, 19.48, 188.3, 77.3, 240, @ahora - INTERVAL 21 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:72:15:29')),
  (51.6, 20.87, 266.0, 52.9, 155, @ahora - INTERVAL 20 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:72:15:29')),
  (45.4, 21.14, 120.3, 69.6, 246, @ahora - INTERVAL 19 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:72:15:29')),
  (27.2, 19.19, 362.9, 53.2, 251, @ahora - INTERVAL 18 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:72:15:29')),
  (10.1, 11.34, 166.9, 77.1, 198, @ahora - INTERVAL 17 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:72:15:29')),
  (14.8, 12.65, 16.9, 56.6, 193, @ahora - INTERVAL 16 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:72:15:29')),
  (44.1, 11.3, 199.8, 58.1, 173, @ahora - INTERVAL 15 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:72:15:29')),
  (48.7, 17.41, 9.9, 46.4, 239, @ahora - INTERVAL 14 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:72:15:29')),
  (36.8, 14.41, 199.3, 20.5, 148, @ahora - INTERVAL 13 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:72:15:29')),
  (43.2, 20.8, 62.9, 48.9, 169, @ahora - INTERVAL 12 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:72:15:29')),
  (39.5, 18.19, 308.5, 16.0, 211, @ahora - INTERVAL 11 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:72:15:29')),
  (65.2, 19.54, 144.3, 32.1, 252, @ahora - INTERVAL 10 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:72:15:29')),
  (70.4, 13.68, 354.2, 30.0, 186, @ahora - INTERVAL 9 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:72:15:29')),
  (47.6, 17.24, 233.4, 1.0, 209, @ahora - INTERVAL 8 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:72:15:29')),
  (22.8, 18.29, 113.0, 7.8, 159, @ahora - INTERVAL 7 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:72:15:29')),
  (43.7, 14.23, 90.0, 78.6, 247, @ahora - INTERVAL 6 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:72:15:29')),
  (22.1, 11.78, 188.2, 72.3, 177, @ahora - INTERVAL 5 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:72:15:29')),
  (51.8, 12.67, 42.4, 62.2, 195, @ahora - INTERVAL 4 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:72:15:29')),
  (32.1, 13.26, 204.3, 15.1, 185, @ahora - INTERVAL 3 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:72:15:29')),
  (21.6, 15.4, 179.9, 39.1, 259, @ahora - INTERVAL 2 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:72:15:29')),
  (45.2, 11.42, 6.3, 24.9, 248, @ahora - INTERVAL 1 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:72:15:29'));
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES (40.0, 22.13, 253.2, 71.3, 230, (SELECT ultima_senal FROM equipo WHERE direccion_mac = '02:5E:0D:72:15:29'), (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:72:15:29'));
INSERT INTO almacenamiento (punto_montaje, capacidad_total_gb, espacio_libre_gb, id_informe) VALUES ('C:', 512, 305.0, LAST_INSERT_ID());
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES
  (52.8, 4.19, 43.4, 16.6, 202, @ahora - INTERVAL 24 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:97:22:2A')),
  (52.2, 3.0, 313.6, 77.5, 180, @ahora - INTERVAL 23 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:97:22:2A')),
  (49.2, 3.14, 251.9, 25.5, 232, @ahora - INTERVAL 22 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:97:22:2A')),
  (29.4, 3.74, 282.9, 45.8, 233, @ahora - INTERVAL 21 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:97:22:2A')),
  (9.7, 3.06, 107.5, 25.0, 183, @ahora - INTERVAL 20 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:97:22:2A')),
  (24.8, 4.66, 266.3, 33.1, 241, @ahora - INTERVAL 19 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:97:22:2A')),
  (20.2, 3.97, 391.6, 60.1, 147, @ahora - INTERVAL 18 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:97:22:2A')),
  (44.0, 4.3, 235.9, 79.3, 195, @ahora - INTERVAL 17 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:97:22:2A')),
  (22.1, 4.56, 299.9, 74.0, 254, @ahora - INTERVAL 16 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:97:22:2A')),
  (39.7, 3.7, 282.3, 50.8, 196, @ahora - INTERVAL 15 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:97:22:2A')),
  (78.7, 4.56, 234.6, 72.8, 177, @ahora - INTERVAL 14 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:97:22:2A')),
  (72.3, 5.04, 273.3, 62.0, 260, @ahora - INTERVAL 13 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:97:22:2A')),
  (70.2, 3.73, 102.3, 11.5, 182, @ahora - INTERVAL 12 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:97:22:2A')),
  (63.5, 3.84, 198.7, 31.5, 175, @ahora - INTERVAL 11 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:97:22:2A')),
  (76.2, 4.49, 105.1, 73.3, 237, @ahora - INTERVAL 10 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:97:22:2A')),
  (65.0, 4.17, 183.6, 74.3, 184, @ahora - INTERVAL 9 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:97:22:2A')),
  (13.7, 3.0, 252.4, 38.5, 174, @ahora - INTERVAL 8 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:97:22:2A')),
  (30.1, 3.3, 187.0, 28.4, 242, @ahora - INTERVAL 7 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:97:22:2A')),
  (46.7, 5.42, 93.5, 12.9, 234, @ahora - INTERVAL 6 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:97:22:2A')),
  (27.7, 5.27, 51.3, 56.0, 238, @ahora - INTERVAL 5 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:97:22:2A')),
  (18.8, 2.87, 125.6, 62.9, 161, @ahora - INTERVAL 4 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:97:22:2A')),
  (51.2, 4.21, 100.0, 57.2, 164, @ahora - INTERVAL 3 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:97:22:2A')),
  (47.6, 5.19, 143.2, 18.9, 167, @ahora - INTERVAL 2 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:97:22:2A')),
  (13.8, 4.79, 146.0, 55.1, 219, @ahora - INTERVAL 1 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:97:22:2A'));
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES (55.9, 3.29, 230.7, 40.3, 225, (SELECT ultima_senal FROM equipo WHERE direccion_mac = '02:5E:0D:97:22:2A'), (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:97:22:2A'));
INSERT INTO almacenamiento (punto_montaje, capacidad_total_gb, espacio_libre_gb, id_informe) VALUES ('C:', 512, 158.2, LAST_INSERT_ID());
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES
  (50.4, 4.43, 155.9, 33.1, 255, @ahora - INTERVAL 24 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:BC:2F:2B')),
  (25.4, 3.83, 185.9, 14.6, 227, @ahora - INTERVAL 23 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:BC:2F:2B')),
  (44.7, 4.01, 187.0, 7.7, 196, @ahora - INTERVAL 22 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:BC:2F:2B')),
  (32.3, 5.22, 344.9, 6.3, 156, @ahora - INTERVAL 21 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:BC:2F:2B')),
  (47.5, 5.0, 378.1, 67.8, 215, @ahora - INTERVAL 20 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:BC:2F:2B')),
  (17.0, 4.88, 83.6, 70.4, 153, @ahora - INTERVAL 19 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:BC:2F:2B')),
  (28.8, 3.86, 181.3, 29.6, 246, @ahora - INTERVAL 18 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:BC:2F:2B')),
  (26.1, 5.11, 303.6, 5.0, 207, @ahora - INTERVAL 17 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:BC:2F:2B')),
  (24.4, 4.42, 153.3, 59.3, 211, @ahora - INTERVAL 16 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:BC:2F:2B')),
  (37.2, 4.85, 229.4, 50.9, 148, @ahora - INTERVAL 15 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:BC:2F:2B')),
  (66.0, 4.1, 237.6, 8.2, 183, @ahora - INTERVAL 14 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:BC:2F:2B')),
  (44.1, 4.96, 89.7, 30.6, 199, @ahora - INTERVAL 13 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:BC:2F:2B')),
  (38.1, 4.29, 150.1, 58.5, 190, @ahora - INTERVAL 12 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:BC:2F:2B')),
  (38.4, 2.95, 157.7, 15.6, 233, @ahora - INTERVAL 11 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:BC:2F:2B')),
  (42.4, 5.15, 129.1, 7.2, 163, @ahora - INTERVAL 10 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:BC:2F:2B')),
  (65.2, 4.97, 23.0, 3.1, 156, @ahora - INTERVAL 9 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:BC:2F:2B')),
  (19.7, 3.73, 193.0, 41.9, 257, @ahora - INTERVAL 8 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:BC:2F:2B')),
  (29.2, 3.6, 191.2, 2.3, 210, @ahora - INTERVAL 7 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:BC:2F:2B')),
  (41.5, 4.13, 208.5, 70.1, 243, @ahora - INTERVAL 6 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:BC:2F:2B')),
  (23.0, 4.07, 86.1, 39.8, 170, @ahora - INTERVAL 5 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:BC:2F:2B')),
  (11.9, 3.0, 161.3, 2.5, 164, @ahora - INTERVAL 4 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:BC:2F:2B')),
  (20.7, 3.59, 381.7, 39.7, 186, @ahora - INTERVAL 3 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:BC:2F:2B')),
  (28.3, 4.22, 149.0, 59.1, 147, @ahora - INTERVAL 2 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:BC:2F:2B')),
  (37.9, 4.16, 208.2, 28.7, 191, @ahora - INTERVAL 1 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:BC:2F:2B'));
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES (46.5, 3.5, 399.0, 16.6, 216, (SELECT ultima_senal FROM equipo WHERE direccion_mac = '02:5E:0D:BC:2F:2B'), (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:BC:2F:2B'));
INSERT INTO almacenamiento (punto_montaje, capacidad_total_gb, espacio_libre_gb, id_informe) VALUES ('C:', 1000, 489.7, LAST_INSERT_ID());
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES
  (46.3, 8.16, 175.0, 54.2, 232, @ahora - INTERVAL 24 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:E1:3C:2C')),
  (25.0, 9.2, 379.5, 72.9, 152, @ahora - INTERVAL 23 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:E1:3C:2C')),
  (30.2, 7.39, 287.1, 79.1, 196, @ahora - INTERVAL 22 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:E1:3C:2C')),
  (16.1, 7.78, 64.2, 24.0, 235, @ahora - INTERVAL 21 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:E1:3C:2C')),
  (27.4, 9.66, 189.9, 27.1, 200, @ahora - INTERVAL 20 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:E1:3C:2C')),
  (9.5, 8.7, 195.2, 44.8, 145, @ahora - INTERVAL 19 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:E1:3C:2C')),
  (22.6, 6.56, 30.2, 40.1, 229, @ahora - INTERVAL 18 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:E1:3C:2C')),
  (8.6, 8.84, 307.1, 53.1, 202, @ahora - INTERVAL 17 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:E1:3C:2C')),
  (15.2, 9.16, 155.5, 37.0, 195, @ahora - INTERVAL 16 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:E1:3C:2C')),
  (77.8, 6.93, 283.7, 42.2, 236, @ahora - INTERVAL 15 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:E1:3C:2C')),
  (74.2, 6.81, 107.4, 14.3, 200, @ahora - INTERVAL 14 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:E1:3C:2C')),
  (39.7, 8.87, 399.5, 15.4, 243, @ahora - INTERVAL 13 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:E1:3C:2C')),
  (53.0, 7.13, 347.7, 16.4, 182, @ahora - INTERVAL 12 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:E1:3C:2C')),
  (37.2, 9.35, 126.3, 28.8, 189, @ahora - INTERVAL 11 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:E1:3C:2C')),
  (56.6, 8.48, 365.5, 2.2, 141, @ahora - INTERVAL 10 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:E1:3C:2C')),
  (36.4, 10.21, 279.1, 53.2, 187, @ahora - INTERVAL 9 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:E1:3C:2C')),
  (52.9, 5.83, 7.8, 59.8, 171, @ahora - INTERVAL 8 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:E1:3C:2C')),
  (40.0, 10.87, 55.6, 1.6, 204, @ahora - INTERVAL 7 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:E1:3C:2C')),
  (26.2, 6.36, 43.5, 29.9, 191, @ahora - INTERVAL 6 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:E1:3C:2C')),
  (52.5, 10.12, 289.1, 25.8, 161, @ahora - INTERVAL 5 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:E1:3C:2C')),
  (42.6, 6.95, 308.5, 5.8, 214, @ahora - INTERVAL 4 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:E1:3C:2C')),
  (51.7, 7.13, 28.0, 19.3, 175, @ahora - INTERVAL 3 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:E1:3C:2C')),
  (14.5, 7.82, 178.0, 34.3, 226, @ahora - INTERVAL 2 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:E1:3C:2C')),
  (25.5, 10.04, 279.1, 45.5, 194, @ahora - INTERVAL 1 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:E1:3C:2C'));
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES (14.8, 9.28, 33.2, 62.6, 200, (SELECT ultima_senal FROM equipo WHERE direccion_mac = '02:5E:0D:E1:3C:2C'), (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:E1:3C:2C'));
INSERT INTO almacenamiento (punto_montaje, capacidad_total_gb, espacio_libre_gb, id_informe) VALUES ('C:', 256, 95.1, LAST_INSERT_ID());
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES
  (30.9, 7.71, 95.5, 58.2, 154, @ahora - INTERVAL 24 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:06:49:2D')),
  (45.1, 7.57, 43.8, 68.9, 188, @ahora - INTERVAL 23 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:06:49:2D')),
  (15.3, 9.66, 108.3, 27.0, 169, @ahora - INTERVAL 22 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:06:49:2D')),
  (18.6, 9.19, 388.8, 77.1, 255, @ahora - INTERVAL 21 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:06:49:2D')),
  (24.2, 6.3, 330.4, 71.4, 200, @ahora - INTERVAL 20 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:06:49:2D')),
  (28.9, 9.72, 366.7, 45.0, 172, @ahora - INTERVAL 19 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:06:49:2D')),
  (15.2, 7.81, 20.2, 20.5, 183, @ahora - INTERVAL 18 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:06:49:2D')),
  (48.3, 8.14, 274.5, 10.7, 149, @ahora - INTERVAL 17 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:06:49:2D')),
  (16.0, 9.71, 99.4, 30.7, 196, @ahora - INTERVAL 16 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:06:49:2D')),
  (65.5, 10.31, 142.8, 24.7, 163, @ahora - INTERVAL 15 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:06:49:2D')),
  (37.2, 5.65, 23.0, 68.0, 166, @ahora - INTERVAL 14 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:06:49:2D')),
  (42.8, 6.92, 56.8, 5.9, 238, @ahora - INTERVAL 13 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:06:49:2D')),
  (50.8, 8.27, 190.5, 22.9, 249, @ahora - INTERVAL 12 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:06:49:2D')),
  (45.4, 5.84, 42.4, 38.7, 180, @ahora - INTERVAL 11 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:06:49:2D')),
  (60.6, 5.72, 70.6, 56.1, 224, @ahora - INTERVAL 10 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:06:49:2D')),
  (70.3, 5.87, 261.7, 23.6, 248, @ahora - INTERVAL 9 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:06:49:2D')),
  (43.5, 6.61, 365.7, 59.0, 232, @ahora - INTERVAL 8 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:06:49:2D')),
  (54.7, 9.01, 296.8, 75.9, 195, @ahora - INTERVAL 7 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:06:49:2D')),
  (29.6, 6.89, 28.6, 3.2, 236, @ahora - INTERVAL 6 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:06:49:2D')),
  (11.2, 7.15, 361.4, 53.3, 228, @ahora - INTERVAL 5 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:06:49:2D')),
  (13.9, 10.59, 250.3, 4.9, 217, @ahora - INTERVAL 4 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:06:49:2D')),
  (14.7, 7.41, 139.1, 2.2, 187, @ahora - INTERVAL 3 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:06:49:2D')),
  (15.3, 7.45, 301.2, 62.5, 155, @ahora - INTERVAL 2 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:06:49:2D')),
  (41.2, 9.54, 136.4, 74.3, 198, @ahora - INTERVAL 1 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:06:49:2D'));
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES (23.1, 10.57, 348.9, 38.4, 144, (SELECT ultima_senal FROM equipo WHERE direccion_mac = '02:5E:0D:06:49:2D'), (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:06:49:2D'));
INSERT INTO almacenamiento (punto_montaje, capacidad_total_gb, espacio_libre_gb, id_informe) VALUES ('C:', 512, 344.7, LAST_INSERT_ID());
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES
  (16.5, 9.77, 98.1, 3.0, 203, @ahora - INTERVAL 24 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:2B:56:2E')),
  (13.7, 6.17, 396.4, 32.0, 221, @ahora - INTERVAL 23 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:2B:56:2E')),
  (20.3, 6.58, 176.1, 75.4, 216, @ahora - INTERVAL 22 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:2B:56:2E')),
  (21.4, 5.76, 11.5, 74.0, 172, @ahora - INTERVAL 21 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:2B:56:2E')),
  (38.1, 5.96, 252.3, 77.1, 156, @ahora - INTERVAL 20 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:2B:56:2E')),
  (22.9, 9.88, 59.5, 70.7, 236, @ahora - INTERVAL 19 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:2B:56:2E')),
  (32.3, 9.86, 104.6, 58.6, 206, @ahora - INTERVAL 18 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:2B:56:2E')),
  (19.0, 10.66, 341.5, 24.3, 239, @ahora - INTERVAL 17 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:2B:56:2E')),
  (24.4, 9.26, 184.2, 35.6, 213, @ahora - INTERVAL 16 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:2B:56:2E')),
  (50.4, 6.79, 318.1, 74.5, 145, @ahora - INTERVAL 15 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:2B:56:2E')),
  (67.3, 6.77, 284.6, 68.8, 225, @ahora - INTERVAL 14 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:2B:56:2E')),
  (77.6, 10.92, 46.4, 3.0, 220, @ahora - INTERVAL 13 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:2B:56:2E')),
  (71.4, 10.92, 235.6, 54.7, 203, @ahora - INTERVAL 12 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:2B:56:2E')),
  (58.0, 6.25, 135.4, 29.8, 192, @ahora - INTERVAL 11 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:2B:56:2E')),
  (35.0, 6.58, 63.8, 11.7, 221, @ahora - INTERVAL 10 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:2B:56:2E')),
  (35.0, 10.47, 393.8, 13.1, 227, @ahora - INTERVAL 9 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:2B:56:2E')),
  (41.4, 9.3, 329.4, 21.6, 217, @ahora - INTERVAL 8 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:2B:56:2E')),
  (52.0, 7.3, 302.5, 24.7, 214, @ahora - INTERVAL 7 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:2B:56:2E')),
  (24.6, 11.12, 105.7, 47.6, 167, @ahora - INTERVAL 6 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:2B:56:2E')),
  (10.6, 6.68, 291.0, 50.9, 224, @ahora - INTERVAL 5 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:2B:56:2E')),
  (46.5, 10.95, 361.9, 75.9, 162, @ahora - INTERVAL 4 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:2B:56:2E')),
  (28.5, 9.38, 282.5, 36.4, 187, @ahora - INTERVAL 3 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:2B:56:2E')),
  (29.9, 8.4, 99.7, 48.4, 154, @ahora - INTERVAL 2 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:2B:56:2E')),
  (13.5, 6.8, 146.5, 10.7, 144, @ahora - INTERVAL 1 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:2B:56:2E'));
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES (51.6, 10.86, 394.5, 51.2, 179, (SELECT ultima_senal FROM equipo WHERE direccion_mac = '02:5E:0D:2B:56:2E'), (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:2B:56:2E'));
INSERT INTO almacenamiento (punto_montaje, capacidad_total_gb, espacio_libre_gb, id_informe) VALUES ('C:', 512, 228.5, LAST_INSERT_ID());
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES
  (37.9, 14.02, 46.5, 27.0, 205, @ahora - INTERVAL 24 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:50:63:2F')),
  (49.9, 15.59, 35.1, 74.2, 219, @ahora - INTERVAL 23 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:50:63:2F')),
  (44.5, 16.64, 138.6, 36.8, 162, @ahora - INTERVAL 22 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:50:63:2F')),
  (41.5, 12.61, 110.7, 39.0, 143, @ahora - INTERVAL 21 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:50:63:2F')),
  (30.0, 16.89, 358.7, 10.0, 147, @ahora - INTERVAL 20 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:50:63:2F')),
  (33.7, 19.76, 325.4, 9.7, 226, @ahora - INTERVAL 19 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:50:63:2F')),
  (38.6, 14.63, 323.9, 20.4, 229, @ahora - INTERVAL 18 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:50:63:2F')),
  (37.4, 12.6, 365.8, 32.0, 179, @ahora - INTERVAL 17 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:50:63:2F')),
  (22.3, 20.15, 342.6, 55.0, 150, @ahora - INTERVAL 16 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:50:63:2F')),
  (49.1, 13.3, 259.8, 37.9, 176, @ahora - INTERVAL 15 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:50:63:2F')),
  (55.4, 14.59, 198.2, 71.4, 228, @ahora - INTERVAL 14 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:50:63:2F')),
  (35.8, 17.75, 163.4, 61.8, 216, @ahora - INTERVAL 13 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:50:63:2F')),
  (67.0, 12.99, 209.6, 53.6, 167, @ahora - INTERVAL 12 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:50:63:2F')),
  (79.1, 21.01, 390.2, 6.6, 145, @ahora - INTERVAL 11 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:50:63:2F')),
  (69.2, 15.85, 179.5, 10.4, 223, @ahora - INTERVAL 10 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:50:63:2F')),
  (60.3, 20.25, 148.5, 5.3, 244, @ahora - INTERVAL 9 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:50:63:2F')),
  (29.7, 19.22, 78.8, 64.8, 222, @ahora - INTERVAL 8 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:50:63:2F')),
  (13.4, 13.22, 146.3, 6.5, 169, @ahora - INTERVAL 7 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:50:63:2F')),
  (45.7, 18.12, 382.1, 57.0, 151, @ahora - INTERVAL 6 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:50:63:2F')),
  (53.7, 15.0, 348.9, 20.4, 210, @ahora - INTERVAL 5 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:50:63:2F')),
  (32.3, 11.93, 268.8, 41.2, 183, @ahora - INTERVAL 4 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:50:63:2F')),
  (47.6, 13.01, 251.5, 53.0, 240, @ahora - INTERVAL 3 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:50:63:2F')),
  (54.7, 22.02, 289.3, 55.6, 143, @ahora - INTERVAL 2 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:50:63:2F')),
  (50.1, 13.27, 51.2, 46.3, 222, @ahora - INTERVAL 1 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:50:63:2F'));
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES (42.3, 14.25, 348.0, 51.7, 232, (SELECT ultima_senal FROM equipo WHERE direccion_mac = '02:5E:0D:50:63:2F'), (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:50:63:2F'));
INSERT INTO almacenamiento (punto_montaje, capacidad_total_gb, espacio_libre_gb, id_informe) VALUES ('C:', 1000, 574.3, LAST_INSERT_ID());
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES
  (47.6, 3.79, 156.6, 45.2, 243, @ahora - INTERVAL 24 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:75:70:30')),
  (26.0, 4.63, 395.3, 65.2, 182, @ahora - INTERVAL 23 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:75:70:30')),
  (23.0, 5.04, 206.1, 46.2, 229, @ahora - INTERVAL 22 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:75:70:30')),
  (25.2, 3.62, 199.6, 14.0, 172, @ahora - INTERVAL 21 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:75:70:30')),
  (48.2, 5.33, 293.6, 28.3, 152, @ahora - INTERVAL 20 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:75:70:30')),
  (18.6, 4.29, 237.0, 57.8, 214, @ahora - INTERVAL 19 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:75:70:30')),
  (32.0, 3.02, 40.3, 70.3, 220, @ahora - INTERVAL 18 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:75:70:30')),
  (37.9, 5.56, 173.6, 29.8, 193, @ahora - INTERVAL 17 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:75:70:30')),
  (38.1, 4.39, 379.7, 55.5, 232, @ahora - INTERVAL 16 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:75:70:30')),
  (70.2, 3.09, 217.7, 46.2, 174, @ahora - INTERVAL 15 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:75:70:30')),
  (68.5, 3.34, 118.9, 61.8, 193, @ahora - INTERVAL 14 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:75:70:30')),
  (62.9, 3.62, 149.5, 7.7, 148, @ahora - INTERVAL 13 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:75:70:30')),
  (52.8, 3.77, 328.6, 20.0, 175, @ahora - INTERVAL 12 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:75:70:30')),
  (33.0, 4.54, 152.3, 12.7, 213, @ahora - INTERVAL 11 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:75:70:30')),
  (68.2, 3.69, 326.9, 52.7, 180, @ahora - INTERVAL 10 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:75:70:30')),
  (45.7, 2.92, 132.2, 21.6, 228, @ahora - INTERVAL 9 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:75:70:30')),
  (27.8, 4.94, 90.4, 29.2, 208, @ahora - INTERVAL 8 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:75:70:30')),
  (33.9, 5.05, 285.9, 26.5, 155, @ahora - INTERVAL 7 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:75:70:30')),
  (38.1, 2.89, 378.3, 26.7, 172, @ahora - INTERVAL 6 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:75:70:30')),
  (16.1, 4.88, 281.6, 11.3, 190, @ahora - INTERVAL 5 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:75:70:30')),
  (30.4, 5.14, 107.3, 12.9, 216, @ahora - INTERVAL 4 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:75:70:30')),
  (9.2, 5.15, 198.7, 37.7, 258, @ahora - INTERVAL 3 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:75:70:30')),
  (20.4, 3.38, 108.0, 36.8, 231, @ahora - INTERVAL 2 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:75:70:30')),
  (47.9, 3.54, 195.9, 77.8, 250, @ahora - INTERVAL 1 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:75:70:30'));
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES (55.8, 4.46, 286.7, 3.8, 156, (SELECT ultima_senal FROM equipo WHERE direccion_mac = '02:5E:0D:75:70:30'), (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0D:75:70:30'));
INSERT INTO almacenamiento (punto_montaje, capacidad_total_gb, espacio_libre_gb, id_informe) VALUES ('C:', 256, 90.7, LAST_INSERT_ID());
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES
  (43.0, 3.13, 143.3, 34.0, 189, @ahora - INTERVAL 24 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:00:7D:31')),
  (8.4, 3.19, 25.9, 12.3, 226, @ahora - INTERVAL 23 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:00:7D:31')),
  (18.2, 3.14, 123.0, 53.3, 150, @ahora - INTERVAL 22 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:00:7D:31')),
  (37.8, 3.53, 135.2, 3.9, 233, @ahora - INTERVAL 21 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:00:7D:31')),
  (44.7, 3.39, 65.8, 45.6, 256, @ahora - INTERVAL 20 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:00:7D:31')),
  (21.1, 4.45, 235.8, 61.1, 203, @ahora - INTERVAL 19 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:00:7D:31')),
  (53.0, 4.55, 130.7, 67.6, 161, @ahora - INTERVAL 18 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:00:7D:31')),
  (42.1, 3.24, 46.6, 21.6, 249, @ahora - INTERVAL 17 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:00:7D:31')),
  (38.2, 4.58, 230.0, 60.0, 229, @ahora - INTERVAL 16 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:00:7D:31')),
  (66.8, 4.53, 295.0, 3.2, 197, @ahora - INTERVAL 15 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:00:7D:31')),
  (44.6, 5.34, 146.7, 2.9, 140, @ahora - INTERVAL 14 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:00:7D:31')),
  (43.2, 3.55, 362.3, 39.1, 225, @ahora - INTERVAL 13 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:00:7D:31')),
  (38.1, 4.61, 192.9, 30.5, 141, @ahora - INTERVAL 12 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:00:7D:31')),
  (38.2, 4.93, 320.7, 66.6, 221, @ahora - INTERVAL 11 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:00:7D:31')),
  (33.9, 3.97, 39.6, 35.9, 162, @ahora - INTERVAL 10 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:00:7D:31')),
  (37.9, 4.9, 124.5, 74.3, 161, @ahora - INTERVAL 9 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:00:7D:31')),
  (37.9, 4.12, 139.3, 76.6, 190, @ahora - INTERVAL 8 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:00:7D:31')),
  (46.8, 4.16, 224.5, 52.2, 152, @ahora - INTERVAL 7 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:00:7D:31')),
  (44.5, 4.77, 13.7, 55.5, 177, @ahora - INTERVAL 6 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:00:7D:31')),
  (36.0, 5.07, 180.2, 76.6, 214, @ahora - INTERVAL 5 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:00:7D:31')),
  (47.9, 3.69, 156.9, 6.1, 208, @ahora - INTERVAL 4 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:00:7D:31')),
  (11.8, 5.05, 362.8, 43.1, 202, @ahora - INTERVAL 3 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:00:7D:31')),
  (14.4, 3.19, 163.9, 25.1, 225, @ahora - INTERVAL 2 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:00:7D:31')),
  (20.1, 4.94, 290.9, 55.2, 212, @ahora - INTERVAL 1 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:00:7D:31'));
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES (43.1, 5.36, 171.8, 60.7, 257, (SELECT ultima_senal FROM equipo WHERE direccion_mac = '02:5E:0C:00:7D:31'), (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:00:7D:31'));
INSERT INTO almacenamiento (punto_montaje, capacidad_total_gb, espacio_libre_gb, id_informe) VALUES ('C:', 512, 210.3, LAST_INSERT_ID());
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES
  (17.0, 7.63, 251.0, 60.0, 173, @ahora - INTERVAL 24 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:25:8A:32')),
  (18.3, 7.76, 46.9, 16.9, 140, @ahora - INTERVAL 23 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:25:8A:32')),
  (36.4, 10.36, 384.2, 33.2, 201, @ahora - INTERVAL 22 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:25:8A:32')),
  (40.6, 8.3, 18.1, 45.8, 197, @ahora - INTERVAL 21 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:25:8A:32')),
  (16.5, 7.8, 201.1, 78.3, 152, @ahora - INTERVAL 20 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:25:8A:32')),
  (28.9, 10.78, 299.0, 28.4, 232, @ahora - INTERVAL 19 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:25:8A:32')),
  (32.8, 7.93, 387.0, 2.0, 177, @ahora - INTERVAL 18 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:25:8A:32')),
  (33.3, 9.8, 126.6, 54.2, 208, @ahora - INTERVAL 17 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:25:8A:32')),
  (52.5, 10.82, 102.3, 15.0, 258, @ahora - INTERVAL 16 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:25:8A:32')),
  (69.1, 6.61, 272.4, 78.9, 249, @ahora - INTERVAL 15 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:25:8A:32')),
  (50.6, 7.98, 143.5, 20.8, 155, @ahora - INTERVAL 14 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:25:8A:32')),
  (71.9, 8.13, 7.7, 54.6, 229, @ahora - INTERVAL 13 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:25:8A:32')),
  (40.9, 7.42, 341.8, 76.0, 229, @ahora - INTERVAL 12 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:25:8A:32')),
  (45.5, 6.41, 135.5, 6.5, 222, @ahora - INTERVAL 11 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:25:8A:32')),
  (35.8, 11.07, 398.3, 46.0, 215, @ahora - INTERVAL 10 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:25:8A:32')),
  (58.5, 5.94, 358.4, 56.6, 165, @ahora - INTERVAL 9 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:25:8A:32')),
  (18.0, 8.21, 107.0, 19.7, 218, @ahora - INTERVAL 8 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:25:8A:32')),
  (32.1, 9.89, 98.7, 38.8, 160, @ahora - INTERVAL 7 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:25:8A:32')),
  (46.6, 11.11, 258.9, 32.6, 240, @ahora - INTERVAL 6 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:25:8A:32')),
  (31.5, 9.42, 259.5, 62.9, 196, @ahora - INTERVAL 5 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:25:8A:32')),
  (43.3, 10.2, 279.4, 72.3, 232, @ahora - INTERVAL 4 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:25:8A:32')),
  (26.7, 6.93, 112.4, 34.6, 177, @ahora - INTERVAL 3 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:25:8A:32')),
  (9.3, 8.51, 366.1, 40.0, 151, @ahora - INTERVAL 2 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:25:8A:32')),
  (34.7, 5.69, 48.0, 37.0, 222, @ahora - INTERVAL 1 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:25:8A:32'));
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES (45.9, 9.62, 216.9, 30.5, 236, (SELECT ultima_senal FROM equipo WHERE direccion_mac = '02:5E:0C:25:8A:32'), (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:25:8A:32'));
INSERT INTO almacenamiento (punto_montaje, capacidad_total_gb, espacio_libre_gb, id_informe) VALUES ('C:', 512, 160.4, LAST_INSERT_ID());
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES
  (15.8, 10.36, 94.8, 40.4, 193, @ahora - INTERVAL 24 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:4A:97:33')),
  (25.0, 6.26, 128.5, 41.2, 239, @ahora - INTERVAL 23 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:4A:97:33')),
  (47.4, 9.81, 136.3, 69.7, 172, @ahora - INTERVAL 22 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:4A:97:33')),
  (33.6, 10.9, 11.3, 6.2, 174, @ahora - INTERVAL 21 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:4A:97:33')),
  (21.5, 9.76, 119.4, 2.6, 160, @ahora - INTERVAL 20 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:4A:97:33')),
  (8.8, 5.73, 212.7, 12.8, 239, @ahora - INTERVAL 19 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:4A:97:33')),
  (10.2, 10.69, 100.2, 61.8, 238, @ahora - INTERVAL 18 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:4A:97:33')),
  (20.5, 10.98, 229.4, 18.4, 254, @ahora - INTERVAL 17 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:4A:97:33')),
  (40.5, 5.71, 354.8, 36.4, 214, @ahora - INTERVAL 16 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:4A:97:33')),
  (58.8, 9.3, 284.1, 40.7, 233, @ahora - INTERVAL 15 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:4A:97:33')),
  (71.3, 8.46, 192.0, 79.6, 151, @ahora - INTERVAL 14 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:4A:97:33')),
  (56.3, 8.09, 54.4, 7.8, 140, @ahora - INTERVAL 13 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:4A:97:33')),
  (78.3, 6.78, 237.2, 47.9, 238, @ahora - INTERVAL 12 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:4A:97:33')),
  (43.8, 5.73, 239.4, 70.2, 243, @ahora - INTERVAL 11 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:4A:97:33')),
  (75.9, 7.31, 190.0, 19.3, 195, @ahora - INTERVAL 10 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:4A:97:33')),
  (72.1, 5.87, 40.8, 57.3, 227, @ahora - INTERVAL 9 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:4A:97:33')),
  (37.4, 6.36, 152.5, 64.6, 235, @ahora - INTERVAL 8 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:4A:97:33')),
  (39.0, 9.02, 359.5, 48.9, 200, @ahora - INTERVAL 7 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:4A:97:33')),
  (29.3, 6.97, 362.8, 31.5, 154, @ahora - INTERVAL 6 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:4A:97:33')),
  (30.2, 10.15, 171.1, 58.9, 252, @ahora - INTERVAL 5 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:4A:97:33')),
  (47.7, 5.72, 220.9, 26.4, 151, @ahora - INTERVAL 4 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:4A:97:33')),
  (14.0, 7.7, 20.7, 69.1, 140, @ahora - INTERVAL 3 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:4A:97:33')),
  (27.7, 11.04, 290.7, 26.1, 164, @ahora - INTERVAL 2 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:4A:97:33')),
  (31.1, 9.99, 388.9, 69.2, 212, @ahora - INTERVAL 1 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:4A:97:33'));
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES (51.7, 7.59, 53.7, 62.0, 192, (SELECT ultima_senal FROM equipo WHERE direccion_mac = '02:5E:0C:4A:97:33'), (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:4A:97:33'));
INSERT INTO almacenamiento (punto_montaje, capacidad_total_gb, espacio_libre_gb, id_informe) VALUES ('C:', 1000, 503.1, LAST_INSERT_ID());
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES
  (37.3, 8.47, 158.1, 61.0, 164, @ahora - INTERVAL 24 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:6F:A4:34')),
  (25.6, 8.62, 265.3, 2.5, 171, @ahora - INTERVAL 23 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:6F:A4:34')),
  (42.9, 8.84, 356.2, 19.4, 160, @ahora - INTERVAL 22 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:6F:A4:34')),
  (14.6, 7.47, 103.4, 11.8, 144, @ahora - INTERVAL 21 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:6F:A4:34')),
  (33.6, 10.6, 83.9, 34.9, 170, @ahora - INTERVAL 20 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:6F:A4:34')),
  (46.9, 8.86, 67.1, 57.7, 223, @ahora - INTERVAL 19 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:6F:A4:34')),
  (35.4, 6.17, 89.4, 78.8, 160, @ahora - INTERVAL 18 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:6F:A4:34')),
  (24.9, 5.84, 253.3, 5.1, 226, @ahora - INTERVAL 17 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:6F:A4:34')),
  (46.9, 8.25, 30.3, 68.4, 145, @ahora - INTERVAL 16 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:6F:A4:34')),
  (79.4, 9.62, 359.8, 42.9, 158, @ahora - INTERVAL 15 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:6F:A4:34')),
  (46.4, 7.52, 129.9, 30.9, 186, @ahora - INTERVAL 14 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:6F:A4:34')),
  (62.2, 8.47, 354.9, 1.2, 191, @ahora - INTERVAL 13 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:6F:A4:34')),
  (35.9, 7.33, 27.3, 5.0, 200, @ahora - INTERVAL 12 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:6F:A4:34')),
  (61.5, 6.84, 345.5, 18.8, 144, @ahora - INTERVAL 11 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:6F:A4:34')),
  (68.2, 10.14, 112.4, 44.2, 172, @ahora - INTERVAL 10 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:6F:A4:34')),
  (68.5, 10.32, 26.9, 62.6, 206, @ahora - INTERVAL 9 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:6F:A4:34')),
  (51.1, 10.65, 211.1, 10.9, 250, @ahora - INTERVAL 8 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:6F:A4:34')),
  (38.8, 7.42, 46.9, 74.5, 165, @ahora - INTERVAL 7 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:6F:A4:34')),
  (43.2, 6.4, 329.3, 3.1, 177, @ahora - INTERVAL 6 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:6F:A4:34')),
  (30.8, 6.42, 224.0, 3.1, 225, @ahora - INTERVAL 5 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:6F:A4:34')),
  (9.3, 7.1, 279.8, 11.8, 214, @ahora - INTERVAL 4 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:6F:A4:34')),
  (27.5, 8.64, 350.5, 35.1, 175, @ahora - INTERVAL 3 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:6F:A4:34')),
  (49.0, 7.06, 99.4, 55.2, 251, @ahora - INTERVAL 2 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:6F:A4:34')),
  (23.4, 10.97, 167.2, 63.8, 227, @ahora - INTERVAL 1 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:6F:A4:34'));
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES (43.2, 5.68, 167.8, 20.7, 244, (SELECT ultima_senal FROM equipo WHERE direccion_mac = '02:5E:0C:6F:A4:34'), (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:6F:A4:34'));
INSERT INTO almacenamiento (punto_montaje, capacidad_total_gb, espacio_libre_gb, id_informe) VALUES ('C:', 256, 77.9, LAST_INSERT_ID());
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES
  (35.6, 14.13, 211.4, 38.9, 197, @ahora - INTERVAL 24 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:94:B1:35')),
  (21.7, 21.95, 371.9, 63.7, 242, @ahora - INTERVAL 23 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:94:B1:35')),
  (13.2, 16.64, 378.7, 72.9, 182, @ahora - INTERVAL 22 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:94:B1:35')),
  (19.6, 11.75, 345.2, 46.2, 224, @ahora - INTERVAL 21 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:94:B1:35')),
  (12.1, 14.33, 182.1, 28.4, 142, @ahora - INTERVAL 20 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:94:B1:35')),
  (31.0, 19.83, 113.0, 40.8, 146, @ahora - INTERVAL 19 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:94:B1:35')),
  (52.2, 12.83, 378.7, 19.3, 245, @ahora - INTERVAL 18 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:94:B1:35')),
  (21.4, 21.95, 318.6, 10.6, 190, @ahora - INTERVAL 17 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:94:B1:35')),
  (19.5, 16.82, 13.7, 57.6, 220, @ahora - INTERVAL 16 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:94:B1:35')),
  (62.1, 20.85, 31.2, 69.7, 154, @ahora - INTERVAL 15 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:94:B1:35')),
  (36.4, 22.03, 67.3, 68.4, 187, @ahora - INTERVAL 14 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:94:B1:35')),
  (36.9, 16.6, 193.8, 47.4, 192, @ahora - INTERVAL 13 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:94:B1:35')),
  (67.3, 13.82, 177.3, 58.8, 260, @ahora - INTERVAL 12 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:94:B1:35')),
  (73.6, 15.72, 395.1, 74.4, 163, @ahora - INTERVAL 11 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:94:B1:35')),
  (35.6, 16.05, 46.4, 74.5, 220, @ahora - INTERVAL 10 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:94:B1:35')),
  (57.8, 19.77, 30.3, 21.7, 192, @ahora - INTERVAL 9 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:94:B1:35')),
  (54.3, 19.54, 186.7, 74.9, 198, @ahora - INTERVAL 8 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:94:B1:35')),
  (27.0, 22.3, 33.9, 48.2, 163, @ahora - INTERVAL 7 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:94:B1:35')),
  (40.3, 13.52, 81.6, 56.5, 224, @ahora - INTERVAL 6 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:94:B1:35')),
  (9.7, 17.09, 344.9, 15.2, 213, @ahora - INTERVAL 5 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:94:B1:35')),
  (44.2, 19.93, 376.7, 64.4, 189, @ahora - INTERVAL 4 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:94:B1:35')),
  (27.6, 13.74, 174.8, 50.6, 174, @ahora - INTERVAL 3 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:94:B1:35')),
  (44.4, 20.23, 236.2, 79.6, 242, @ahora - INTERVAL 2 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:94:B1:35')),
  (45.3, 11.57, 19.4, 43.3, 177, @ahora - INTERVAL 1 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:94:B1:35'));
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES (55.2, 19.96, 93.0, 2.9, 154, (SELECT ultima_senal FROM equipo WHERE direccion_mac = '02:5E:0C:94:B1:35'), (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:94:B1:35'));
INSERT INTO almacenamiento (punto_montaje, capacidad_total_gb, espacio_libre_gb, id_informe) VALUES ('C:', 512, 319.9, LAST_INSERT_ID());
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES (43.4, 4.97, 256.3, 50.8, 245, (SELECT ultima_senal FROM equipo WHERE direccion_mac = '02:5E:0C:B9:BE:36'), (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:B9:BE:36'));
INSERT INTO almacenamiento (punto_montaje, capacidad_total_gb, espacio_libre_gb, id_informe) VALUES ('C:', 512, 352.4, LAST_INSERT_ID());
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES (16.8, 3.22, 278.8, 70.4, 237, (SELECT ultima_senal FROM equipo WHERE direccion_mac = '02:5E:0C:DE:CB:37'), (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:DE:CB:37'));
INSERT INTO almacenamiento (punto_montaje, capacidad_total_gb, espacio_libre_gb, id_informe) VALUES ('C:', 1000, 646.9, LAST_INSERT_ID());
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES
  (51.7, 10.34, 293.0, 65.6, 144, @ahora - INTERVAL 24 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:28:E5:39')),
  (52.6, 11.17, 260.5, 76.2, 205, @ahora - INTERVAL 23 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:28:E5:39')),
  (24.2, 10.4, 24.1, 76.7, 175, @ahora - INTERVAL 22 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:28:E5:39')),
  (24.6, 9.05, 10.8, 60.4, 184, @ahora - INTERVAL 21 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:28:E5:39')),
  (14.8, 7.52, 113.3, 47.8, 178, @ahora - INTERVAL 20 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:28:E5:39')),
  (49.8, 6.82, 311.8, 12.8, 194, @ahora - INTERVAL 19 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:28:E5:39')),
  (53.6, 10.99, 275.5, 66.2, 183, @ahora - INTERVAL 18 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:28:E5:39')),
  (40.5, 8.93, 147.0, 15.5, 163, @ahora - INTERVAL 17 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:28:E5:39')),
  (53.8, 10.25, 13.3, 24.4, 229, @ahora - INTERVAL 16 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:28:E5:39')),
  (49.9, 9.54, 159.6, 1.8, 165, @ahora - INTERVAL 15 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:28:E5:39')),
  (34.4, 7.25, 49.2, 39.3, 168, @ahora - INTERVAL 14 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:28:E5:39')),
  (33.7, 8.12, 319.2, 36.2, 245, @ahora - INTERVAL 13 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:28:E5:39')),
  (74.6, 6.27, 139.5, 67.1, 190, @ahora - INTERVAL 12 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:28:E5:39')),
  (40.8, 9.31, 359.7, 66.8, 248, @ahora - INTERVAL 11 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:28:E5:39')),
  (43.9, 9.37, 365.8, 1.9, 157, @ahora - INTERVAL 10 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:28:E5:39')),
  (33.0, 8.39, 107.7, 36.9, 146, @ahora - INTERVAL 9 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:28:E5:39')),
  (12.3, 9.88, 344.1, 37.1, 164, @ahora - INTERVAL 8 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:28:E5:39')),
  (12.7, 8.84, 153.4, 39.8, 172, @ahora - INTERVAL 7 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:28:E5:39')),
  (13.9, 9.82, 169.0, 53.3, 141, @ahora - INTERVAL 6 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:28:E5:39')),
  (26.9, 10.76, 291.2, 28.3, 220, @ahora - INTERVAL 5 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:28:E5:39')),
  (54.8, 6.2, 141.9, 11.7, 210, @ahora - INTERVAL 4 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:28:E5:39')),
  (32.8, 7.77, 47.5, 63.3, 208, @ahora - INTERVAL 3 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:28:E5:39')),
  (36.8, 9.27, 110.4, 57.4, 167, @ahora - INTERVAL 2 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:28:E5:39')),
  (24.8, 7.96, 387.5, 51.0, 208, @ahora - INTERVAL 1 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:28:E5:39'));
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES (48.9, 14.86, 297.1, 13.2, 144, (SELECT ultima_senal FROM equipo WHERE direccion_mac = '02:5E:0C:28:E5:39'), (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:28:E5:39'));
INSERT INTO almacenamiento (punto_montaje, capacidad_total_gb, espacio_libre_gb, id_informe) VALUES ('C:', 512, 37.4, LAST_INSERT_ID());
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES
  (12.1, 8.36, 283.4, 38.8, 248, @ahora - INTERVAL 24 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:4D:F2:3A')),
  (37.8, 10.29, 49.4, 36.3, 184, @ahora - INTERVAL 23 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:4D:F2:3A')),
  (24.7, 7.07, 260.7, 44.3, 217, @ahora - INTERVAL 22 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:4D:F2:3A')),
  (24.6, 8.83, 137.0, 37.1, 217, @ahora - INTERVAL 21 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:4D:F2:3A')),
  (16.1, 9.89, 32.9, 78.8, 215, @ahora - INTERVAL 20 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:4D:F2:3A')),
  (48.5, 9.36, 330.0, 22.1, 174, @ahora - INTERVAL 19 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:4D:F2:3A')),
  (15.3, 7.59, 282.5, 72.7, 168, @ahora - INTERVAL 18 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:4D:F2:3A')),
  (38.4, 10.37, 243.4, 25.3, 243, @ahora - INTERVAL 17 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:4D:F2:3A')),
  (9.7, 6.05, 282.9, 53.5, 195, @ahora - INTERVAL 16 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:4D:F2:3A')),
  (41.2, 7.65, 102.5, 62.8, 185, @ahora - INTERVAL 15 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:4D:F2:3A')),
  (44.4, 10.02, 274.0, 22.2, 258, @ahora - INTERVAL 14 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:4D:F2:3A')),
  (52.7, 10.54, 90.8, 25.1, 169, @ahora - INTERVAL 13 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:4D:F2:3A')),
  (56.8, 10.0, 70.3, 29.8, 222, @ahora - INTERVAL 12 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:4D:F2:3A')),
  (43.9, 10.29, 44.0, 5.3, 209, @ahora - INTERVAL 11 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:4D:F2:3A')),
  (66.5, 9.51, 264.0, 30.3, 191, @ahora - INTERVAL 10 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:4D:F2:3A')),
  (42.3, 10.97, 397.9, 41.6, 175, @ahora - INTERVAL 9 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:4D:F2:3A')),
  (47.1, 5.6, 363.2, 4.9, 255, @ahora - INTERVAL 8 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:4D:F2:3A')),
  (27.8, 6.96, 242.1, 26.9, 240, @ahora - INTERVAL 7 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:4D:F2:3A')),
  (23.7, 10.65, 5.3, 63.3, 179, @ahora - INTERVAL 6 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:4D:F2:3A')),
  (43.7, 7.76, 306.6, 11.1, 196, @ahora - INTERVAL 5 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:4D:F2:3A')),
  (51.8, 7.69, 391.8, 28.2, 259, @ahora - INTERVAL 4 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:4D:F2:3A')),
  (53.5, 7.63, 297.7, 21.6, 146, @ahora - INTERVAL 3 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:4D:F2:3A')),
  (41.6, 6.84, 388.0, 6.1, 197, @ahora - INTERVAL 2 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:4D:F2:3A')),
  (49.2, 6.03, 383.3, 51.8, 233, @ahora - INTERVAL 1 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:4D:F2:3A'));
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES (92.5, 6.45, 205.6, 45.6, 217, (SELECT ultima_senal FROM equipo WHERE direccion_mac = '02:5E:0C:4D:F2:3A'), (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:4D:F2:3A'));
INSERT INTO almacenamiento (punto_montaje, capacidad_total_gb, espacio_libre_gb, id_informe) VALUES ('C:', 512, 19.1, LAST_INSERT_ID());
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES
  (35.0, 4.21, 41.5, 68.1, 154, @ahora - INTERVAL 24 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:97:0C:3C')),
  (51.7, 4.71, 186.3, 75.8, 175, @ahora - INTERVAL 23 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:97:0C:3C')),
  (45.1, 4.21, 184.2, 34.2, 259, @ahora - INTERVAL 22 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:97:0C:3C')),
  (19.0, 3.69, 84.9, 17.1, 259, @ahora - INTERVAL 21 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:97:0C:3C')),
  (51.3, 3.43, 163.3, 73.3, 177, @ahora - INTERVAL 20 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:97:0C:3C')),
  (9.0, 4.26, 73.6, 67.1, 150, @ahora - INTERVAL 19 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:97:0C:3C')),
  (42.7, 4.74, 94.4, 76.1, 169, @ahora - INTERVAL 18 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:97:0C:3C')),
  (18.9, 4.51, 67.4, 53.3, 242, @ahora - INTERVAL 17 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:97:0C:3C')),
  (35.7, 3.17, 16.7, 35.3, 199, @ahora - INTERVAL 16 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:97:0C:3C')),
  (74.4, 4.84, 396.7, 52.6, 159, @ahora - INTERVAL 15 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:97:0C:3C')),
  (41.2, 3.46, 189.9, 35.7, 159, @ahora - INTERVAL 14 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:97:0C:3C')),
  (75.5, 5.17, 240.1, 17.9, 168, @ahora - INTERVAL 13 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:97:0C:3C')),
  (40.1, 5.23, 389.0, 42.0, 169, @ahora - INTERVAL 12 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:97:0C:3C')),
  (38.2, 4.43, 196.1, 14.9, 179, @ahora - INTERVAL 11 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:97:0C:3C')),
  (35.8, 3.63, 81.3, 15.9, 198, @ahora - INTERVAL 10 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:97:0C:3C')),
  (72.2, 2.87, 362.4, 33.6, 259, @ahora - INTERVAL 9 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:97:0C:3C')),
  (9.1, 2.83, 161.7, 34.6, 206, @ahora - INTERVAL 8 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:97:0C:3C')),
  (22.0, 3.36, 350.3, 62.6, 143, @ahora - INTERVAL 7 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:97:0C:3C')),
  (53.4, 3.17, 222.1, 77.9, 226, @ahora - INTERVAL 6 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:97:0C:3C')),
  (49.1, 3.03, 350.5, 39.3, 213, @ahora - INTERVAL 5 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:97:0C:3C')),
  (36.8, 5.28, 43.1, 46.7, 206, @ahora - INTERVAL 4 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:97:0C:3C')),
  (26.4, 5.49, 211.7, 23.5, 247, @ahora - INTERVAL 3 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:97:0C:3C')),
  (12.4, 4.96, 5.2, 36.5, 169, @ahora - INTERVAL 2 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:97:0C:3C')),
  (29.6, 3.23, 229.6, 70.9, 183, @ahora - INTERVAL 1 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:97:0C:3C'));
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES (25.7, 5.31, 52.9, 72.7, 210, (SELECT ultima_senal FROM equipo WHERE direccion_mac = '02:5E:0C:97:0C:3C'), (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:97:0C:3C'));
INSERT INTO almacenamiento (punto_montaje, capacidad_total_gb, espacio_libre_gb, id_informe) VALUES ('C:', 256, 110.2, LAST_INSERT_ID());
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES
  (41.7, 3.77, 33.3, 21.6, 172, @ahora - INTERVAL 24 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:BC:19:3D')),
  (17.6, 3.99, 151.7, 50.3, 186, @ahora - INTERVAL 23 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:BC:19:3D')),
  (23.2, 4.27, 258.1, 58.8, 184, @ahora - INTERVAL 22 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:BC:19:3D')),
  (44.7, 3.69, 260.3, 69.2, 234, @ahora - INTERVAL 21 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:BC:19:3D')),
  (19.5, 4.93, 132.8, 60.2, 240, @ahora - INTERVAL 20 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:BC:19:3D')),
  (43.5, 4.05, 249.9, 17.5, 156, @ahora - INTERVAL 19 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:BC:19:3D')),
  (30.8, 4.91, 254.6, 73.2, 153, @ahora - INTERVAL 18 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:BC:19:3D')),
  (40.0, 5.32, 202.6, 45.8, 189, @ahora - INTERVAL 17 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:BC:19:3D')),
  (12.1, 3.25, 12.7, 21.2, 157, @ahora - INTERVAL 16 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:BC:19:3D')),
  (54.6, 5.03, 271.6, 59.7, 162, @ahora - INTERVAL 15 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:BC:19:3D')),
  (45.5, 5.29, 307.7, 28.2, 246, @ahora - INTERVAL 14 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:BC:19:3D')),
  (69.5, 3.06, 288.0, 11.0, 216, @ahora - INTERVAL 13 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:BC:19:3D')),
  (49.7, 3.35, 163.2, 60.7, 187, @ahora - INTERVAL 12 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:BC:19:3D')),
  (65.6, 4.64, 311.1, 15.8, 225, @ahora - INTERVAL 11 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:BC:19:3D')),
  (45.8, 3.1, 64.7, 27.9, 173, @ahora - INTERVAL 10 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:BC:19:3D')),
  (52.9, 4.16, 172.9, 64.2, 237, @ahora - INTERVAL 9 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:BC:19:3D')),
  (8.9, 4.35, 217.1, 79.3, 144, @ahora - INTERVAL 8 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:BC:19:3D')),
  (24.4, 4.32, 32.3, 52.0, 169, @ahora - INTERVAL 7 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:BC:19:3D')),
  (18.1, 3.92, 98.0, 14.1, 192, @ahora - INTERVAL 6 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:BC:19:3D')),
  (28.9, 4.02, 264.4, 54.5, 249, @ahora - INTERVAL 5 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:BC:19:3D')),
  (45.6, 4.85, 31.0, 9.6, 212, @ahora - INTERVAL 4 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:BC:19:3D')),
  (45.1, 3.28, 16.9, 60.6, 143, @ahora - INTERVAL 3 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:BC:19:3D')),
  (31.4, 2.99, 236.2, 28.5, 195, @ahora - INTERVAL 2 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:BC:19:3D')),
  (33.7, 5.48, 27.6, 22.1, 242, @ahora - INTERVAL 1 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:BC:19:3D'));
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES (59.7, 3.41, 271.0, 79.6, 260, (SELECT ultima_senal FROM equipo WHERE direccion_mac = '02:5E:0C:BC:19:3D'), (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:BC:19:3D'));
INSERT INTO almacenamiento (punto_montaje, capacidad_total_gb, espacio_libre_gb, id_informe) VALUES ('C:', 512, 230.1, LAST_INSERT_ID());
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES
  (49.1, 10.34, 314.1, 75.5, 210, @ahora - INTERVAL 24 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:E1:26:3E')),
  (47.1, 6.48, 319.4, 6.4, 212, @ahora - INTERVAL 23 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:E1:26:3E')),
  (30.1, 5.98, 54.9, 23.3, 229, @ahora - INTERVAL 22 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:E1:26:3E')),
  (15.6, 6.67, 52.8, 16.1, 226, @ahora - INTERVAL 21 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:E1:26:3E')),
  (40.8, 7.92, 60.9, 14.7, 192, @ahora - INTERVAL 20 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:E1:26:3E')),
  (15.4, 7.51, 356.3, 65.5, 152, @ahora - INTERVAL 19 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:E1:26:3E')),
  (45.9, 9.77, 364.4, 29.4, 251, @ahora - INTERVAL 18 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:E1:26:3E')),
  (18.1, 7.03, 167.3, 10.3, 244, @ahora - INTERVAL 17 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:E1:26:3E')),
  (39.4, 8.4, 377.1, 69.0, 230, @ahora - INTERVAL 16 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:E1:26:3E')),
  (67.9, 6.21, 43.2, 78.8, 255, @ahora - INTERVAL 15 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:E1:26:3E')),
  (57.9, 10.71, 88.0, 66.9, 161, @ahora - INTERVAL 14 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:E1:26:3E')),
  (72.8, 6.48, 210.7, 39.2, 148, @ahora - INTERVAL 13 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:E1:26:3E')),
  (45.6, 6.17, 213.0, 9.6, 177, @ahora - INTERVAL 12 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:E1:26:3E')),
  (61.2, 6.56, 137.5, 56.2, 214, @ahora - INTERVAL 11 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:E1:26:3E')),
  (64.2, 10.5, 138.3, 28.4, 229, @ahora - INTERVAL 10 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:E1:26:3E')),
  (39.7, 6.16, 242.1, 15.7, 237, @ahora - INTERVAL 9 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:E1:26:3E')),
  (36.3, 8.01, 255.5, 79.3, 150, @ahora - INTERVAL 8 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:E1:26:3E')),
  (41.1, 10.3, 57.6, 43.8, 177, @ahora - INTERVAL 7 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:E1:26:3E')),
  (40.6, 10.54, 336.2, 78.4, 237, @ahora - INTERVAL 6 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:E1:26:3E')),
  (40.1, 7.57, 42.3, 62.3, 226, @ahora - INTERVAL 5 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:E1:26:3E')),
  (41.8, 8.4, 100.5, 60.5, 188, @ahora - INTERVAL 4 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:E1:26:3E')),
  (26.1, 6.97, 341.5, 74.6, 170, @ahora - INTERVAL 3 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:E1:26:3E')),
  (11.5, 7.08, 389.4, 30.9, 154, @ahora - INTERVAL 2 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:E1:26:3E')),
  (12.1, 9.68, 114.4, 18.9, 237, @ahora - INTERVAL 1 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:E1:26:3E'));
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES (54.5, 6.31, 187.1, 68.1, 217, (SELECT ultima_senal FROM equipo WHERE direccion_mac = '02:5E:0C:E1:26:3E'), (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:E1:26:3E'));
INSERT INTO almacenamiento (punto_montaje, capacidad_total_gb, espacio_libre_gb, id_informe) VALUES ('C:', 512, 211.7, LAST_INSERT_ID());
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES
  (38.3, 10.57, 226.6, 45.4, 255, @ahora - INTERVAL 24 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:06:33:3F')),
  (13.3, 9.97, 256.1, 31.2, 140, @ahora - INTERVAL 23 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:06:33:3F')),
  (13.7, 8.59, 329.5, 63.1, 148, @ahora - INTERVAL 22 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:06:33:3F')),
  (19.0, 10.71, 218.2, 65.7, 253, @ahora - INTERVAL 21 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:06:33:3F')),
  (24.5, 7.76, 7.5, 4.5, 184, @ahora - INTERVAL 20 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:06:33:3F')),
  (13.7, 6.79, 78.9, 51.3, 212, @ahora - INTERVAL 19 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:06:33:3F')),
  (35.3, 5.91, 274.8, 61.5, 182, @ahora - INTERVAL 18 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:06:33:3F')),
  (31.2, 9.59, 53.9, 7.6, 181, @ahora - INTERVAL 17 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:06:33:3F')),
  (31.2, 9.53, 163.1, 13.6, 256, @ahora - INTERVAL 16 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:06:33:3F')),
  (43.5, 6.24, 362.3, 53.0, 179, @ahora - INTERVAL 15 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:06:33:3F')),
  (69.0, 11.06, 265.4, 4.7, 188, @ahora - INTERVAL 14 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:06:33:3F')),
  (65.0, 9.98, 280.8, 20.3, 260, @ahora - INTERVAL 13 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:06:33:3F')),
  (53.8, 6.26, 6.6, 18.2, 214, @ahora - INTERVAL 12 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:06:33:3F')),
  (52.6, 6.08, 91.4, 11.1, 195, @ahora - INTERVAL 11 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:06:33:3F')),
  (49.0, 10.87, 79.8, 43.8, 247, @ahora - INTERVAL 10 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:06:33:3F')),
  (77.1, 10.36, 267.8, 15.8, 140, @ahora - INTERVAL 9 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:06:33:3F')),
  (33.7, 6.8, 132.0, 52.6, 210, @ahora - INTERVAL 8 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:06:33:3F')),
  (8.0, 10.76, 12.4, 16.5, 254, @ahora - INTERVAL 7 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:06:33:3F')),
  (37.8, 9.71, 376.5, 74.4, 195, @ahora - INTERVAL 6 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:06:33:3F')),
  (49.0, 6.04, 19.5, 29.6, 211, @ahora - INTERVAL 5 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:06:33:3F')),
  (15.7, 7.49, 145.9, 38.9, 177, @ahora - INTERVAL 4 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:06:33:3F')),
  (45.5, 10.8, 199.4, 59.2, 242, @ahora - INTERVAL 3 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:06:33:3F')),
  (28.1, 7.53, 342.5, 24.7, 234, @ahora - INTERVAL 2 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:06:33:3F')),
  (11.1, 9.91, 16.2, 11.1, 216, @ahora - INTERVAL 1 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:06:33:3F'));
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES (24.6, 6.59, 290.8, 76.2, 175, (SELECT ultima_senal FROM equipo WHERE direccion_mac = '02:5E:0C:06:33:3F'), (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:06:33:3F'));
INSERT INTO almacenamiento (punto_montaje, capacidad_total_gb, espacio_libre_gb, id_informe) VALUES ('C:', 1000, 408.7, LAST_INSERT_ID());
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES
  (36.4, 6.76, 249.1, 18.7, 161, @ahora - INTERVAL 24 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:2B:40:40')),
  (53.6, 9.68, 158.7, 14.4, 149, @ahora - INTERVAL 23 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:2B:40:40')),
  (33.1, 10.28, 145.8, 44.6, 218, @ahora - INTERVAL 22 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:2B:40:40')),
  (28.8, 5.98, 26.3, 53.0, 188, @ahora - INTERVAL 21 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:2B:40:40')),
  (25.5, 5.91, 169.4, 50.4, 245, @ahora - INTERVAL 20 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:2B:40:40')),
  (30.5, 8.37, 41.9, 43.7, 251, @ahora - INTERVAL 19 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:2B:40:40')),
  (22.9, 9.58, 137.4, 46.6, 168, @ahora - INTERVAL 18 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:2B:40:40')),
  (52.1, 6.76, 180.1, 49.1, 231, @ahora - INTERVAL 17 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:2B:40:40')),
  (16.5, 5.65, 165.3, 21.4, 228, @ahora - INTERVAL 16 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:2B:40:40')),
  (70.1, 5.78, 330.7, 70.7, 248, @ahora - INTERVAL 15 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:2B:40:40')),
  (68.9, 9.59, 301.8, 2.4, 202, @ahora - INTERVAL 14 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:2B:40:40')),
  (37.9, 7.65, 125.7, 24.8, 205, @ahora - INTERVAL 13 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:2B:40:40')),
  (65.7, 10.95, 281.8, 25.2, 187, @ahora - INTERVAL 12 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:2B:40:40')),
  (40.0, 9.21, 147.1, 59.3, 158, @ahora - INTERVAL 11 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:2B:40:40')),
  (71.7, 9.75, 281.0, 78.0, 176, @ahora - INTERVAL 10 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:2B:40:40')),
  (78.9, 6.92, 230.2, 40.6, 253, @ahora - INTERVAL 9 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:2B:40:40')),
  (54.2, 7.72, 333.7, 75.6, 180, @ahora - INTERVAL 8 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:2B:40:40')),
  (37.5, 10.86, 111.9, 6.1, 212, @ahora - INTERVAL 7 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:2B:40:40')),
  (52.0, 6.04, 396.6, 18.0, 189, @ahora - INTERVAL 6 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:2B:40:40')),
  (47.5, 7.81, 63.3, 12.4, 150, @ahora - INTERVAL 5 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:2B:40:40')),
  (14.7, 11.07, 130.9, 64.3, 161, @ahora - INTERVAL 4 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:2B:40:40')),
  (36.0, 10.94, 366.6, 58.8, 186, @ahora - INTERVAL 3 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:2B:40:40')),
  (38.0, 8.22, 83.1, 64.4, 148, @ahora - INTERVAL 2 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:2B:40:40')),
  (26.3, 7.63, 350.1, 18.4, 173, @ahora - INTERVAL 1 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:2B:40:40'));
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES (11.3, 7.35, 189.8, 12.0, 249, (SELECT ultima_senal FROM equipo WHERE direccion_mac = '02:5E:0C:2B:40:40'), (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0C:2B:40:40'));
INSERT INTO almacenamiento (punto_montaje, capacidad_total_gb, espacio_libre_gb, id_informe) VALUES ('C:', 256, 67.5, LAST_INSERT_ID());
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES
  (27.5, 18.28, 21.8, 17.2, 155, @ahora - INTERVAL 24 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:00:4D:41')),
  (47.9, 16.35, 67.8, 55.5, 232, @ahora - INTERVAL 23 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:00:4D:41')),
  (15.4, 21.18, 229.0, 19.5, 223, @ahora - INTERVAL 22 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:00:4D:41')),
  (47.6, 20.11, 57.7, 52.2, 171, @ahora - INTERVAL 21 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:00:4D:41')),
  (24.7, 20.27, 59.8, 31.4, 256, @ahora - INTERVAL 20 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:00:4D:41')),
  (15.7, 17.36, 159.3, 77.6, 232, @ahora - INTERVAL 19 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:00:4D:41')),
  (51.8, 16.63, 393.7, 60.7, 230, @ahora - INTERVAL 18 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:00:4D:41')),
  (33.0, 19.3, 286.6, 33.8, 190, @ahora - INTERVAL 17 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:00:4D:41')),
  (35.7, 20.95, 147.3, 48.9, 186, @ahora - INTERVAL 16 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:00:4D:41')),
  (73.0, 19.53, 260.4, 6.9, 197, @ahora - INTERVAL 15 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:00:4D:41')),
  (33.2, 16.34, 388.5, 14.1, 208, @ahora - INTERVAL 14 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:00:4D:41')),
  (39.3, 16.38, 191.8, 21.0, 213, @ahora - INTERVAL 13 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:00:4D:41')),
  (34.6, 21.33, 20.0, 59.6, 234, @ahora - INTERVAL 12 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:00:4D:41')),
  (61.1, 11.74, 29.3, 74.0, 161, @ahora - INTERVAL 11 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:00:4D:41')),
  (76.1, 14.87, 384.1, 13.1, 226, @ahora - INTERVAL 10 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:00:4D:41')),
  (59.6, 19.43, 375.2, 56.9, 153, @ahora - INTERVAL 9 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:00:4D:41')),
  (54.1, 15.69, 121.2, 51.9, 234, @ahora - INTERVAL 8 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:00:4D:41')),
  (38.5, 13.73, 317.5, 9.5, 162, @ahora - INTERVAL 7 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:00:4D:41')),
  (17.8, 19.31, 330.1, 76.7, 251, @ahora - INTERVAL 6 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:00:4D:41')),
  (35.8, 15.96, 135.6, 38.9, 187, @ahora - INTERVAL 5 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:00:4D:41')),
  (26.1, 17.79, 125.3, 13.0, 195, @ahora - INTERVAL 4 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:00:4D:41')),
  (32.3, 12.55, 182.4, 1.1, 172, @ahora - INTERVAL 3 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:00:4D:41')),
  (36.7, 12.04, 139.6, 74.0, 235, @ahora - INTERVAL 2 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:00:4D:41')),
  (19.0, 18.36, 31.4, 44.6, 231, @ahora - INTERVAL 1 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:00:4D:41'));
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES (24.5, 11.81, 111.5, 48.8, 154, (SELECT ultima_senal FROM equipo WHERE direccion_mac = '02:5E:0F:00:4D:41'), (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:00:4D:41'));
INSERT INTO almacenamiento (punto_montaje, capacidad_total_gb, espacio_libre_gb, id_informe) VALUES ('C:', 512, 208.4, LAST_INSERT_ID());
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES
  (38.3, 3.75, 163.2, 75.7, 239, @ahora - INTERVAL 24 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:25:5A:42')),
  (30.4, 3.3, 367.9, 23.1, 148, @ahora - INTERVAL 23 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:25:5A:42')),
  (28.0, 3.72, 72.6, 53.3, 206, @ahora - INTERVAL 22 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:25:5A:42')),
  (26.0, 3.95, 127.9, 20.5, 231, @ahora - INTERVAL 21 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:25:5A:42')),
  (42.4, 4.07, 101.0, 40.1, 184, @ahora - INTERVAL 20 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:25:5A:42')),
  (29.0, 4.74, 86.2, 2.1, 184, @ahora - INTERVAL 19 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:25:5A:42')),
  (41.0, 5.14, 297.2, 43.6, 152, @ahora - INTERVAL 18 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:25:5A:42')),
  (44.2, 4.28, 235.5, 13.8, 251, @ahora - INTERVAL 17 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:25:5A:42')),
  (20.8, 3.26, 280.7, 17.6, 238, @ahora - INTERVAL 16 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:25:5A:42')),
  (39.3, 3.22, 192.4, 65.9, 226, @ahora - INTERVAL 15 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:25:5A:42')),
  (77.5, 4.54, 342.5, 44.2, 185, @ahora - INTERVAL 14 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:25:5A:42')),
  (77.3, 4.13, 59.4, 52.8, 140, @ahora - INTERVAL 13 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:25:5A:42')),
  (45.3, 4.0, 393.7, 63.6, 192, @ahora - INTERVAL 12 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:25:5A:42')),
  (72.6, 4.27, 255.2, 27.9, 144, @ahora - INTERVAL 11 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:25:5A:42')),
  (44.1, 3.31, 218.9, 63.3, 215, @ahora - INTERVAL 10 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:25:5A:42')),
  (62.6, 5.31, 118.1, 51.5, 199, @ahora - INTERVAL 9 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:25:5A:42')),
  (28.8, 4.86, 75.6, 2.0, 218, @ahora - INTERVAL 8 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:25:5A:42')),
  (15.1, 4.65, 71.3, 26.6, 202, @ahora - INTERVAL 7 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:25:5A:42')),
  (23.7, 3.01, 118.4, 16.2, 172, @ahora - INTERVAL 6 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:25:5A:42')),
  (8.2, 5.3, 122.1, 1.3, 223, @ahora - INTERVAL 5 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:25:5A:42')),
  (13.2, 5.33, 307.9, 17.9, 229, @ahora - INTERVAL 4 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:25:5A:42')),
  (48.8, 3.62, 183.0, 45.6, 224, @ahora - INTERVAL 3 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:25:5A:42')),
  (9.8, 3.35, 47.4, 12.5, 191, @ahora - INTERVAL 2 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:25:5A:42')),
  (46.9, 5.08, 220.1, 78.3, 167, @ahora - INTERVAL 1 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:25:5A:42'));
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES (19.7, 4.06, 188.5, 73.0, 192, (SELECT ultima_senal FROM equipo WHERE direccion_mac = '02:5E:0F:25:5A:42'), (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:25:5A:42'));
INSERT INTO almacenamiento (punto_montaje, capacidad_total_gb, espacio_libre_gb, id_informe) VALUES ('C:', 512, 268.9, LAST_INSERT_ID());
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES
  (49.0, 4.39, 310.7, 8.7, 258, @ahora - INTERVAL 24 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:4A:67:43')),
  (38.0, 3.6, 90.2, 13.7, 200, @ahora - INTERVAL 23 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:4A:67:43')),
  (16.4, 2.97, 396.8, 52.4, 169, @ahora - INTERVAL 22 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:4A:67:43')),
  (10.1, 5.49, 64.5, 25.2, 199, @ahora - INTERVAL 21 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:4A:67:43')),
  (49.5, 5.07, 91.2, 2.1, 187, @ahora - INTERVAL 20 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:4A:67:43')),
  (21.4, 4.72, 21.4, 77.4, 185, @ahora - INTERVAL 19 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:4A:67:43')),
  (10.0, 5.48, 254.5, 75.9, 213, @ahora - INTERVAL 18 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:4A:67:43')),
  (30.3, 5.4, 305.3, 56.2, 227, @ahora - INTERVAL 17 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:4A:67:43')),
  (33.5, 5.43, 138.9, 47.7, 247, @ahora - INTERVAL 16 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:4A:67:43')),
  (73.8, 3.22, 346.7, 70.1, 213, @ahora - INTERVAL 15 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:4A:67:43')),
  (58.6, 5.11, 12.4, 46.1, 144, @ahora - INTERVAL 14 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:4A:67:43')),
  (37.5, 2.84, 47.9, 24.5, 184, @ahora - INTERVAL 13 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:4A:67:43')),
  (64.6, 4.54, 40.9, 77.1, 215, @ahora - INTERVAL 12 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:4A:67:43')),
  (77.6, 4.92, 352.6, 60.8, 176, @ahora - INTERVAL 11 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:4A:67:43')),
  (58.1, 3.97, 136.9, 5.4, 167, @ahora - INTERVAL 10 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:4A:67:43')),
  (70.2, 3.51, 36.1, 55.0, 188, @ahora - INTERVAL 9 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:4A:67:43')),
  (35.6, 3.6, 185.4, 63.9, 230, @ahora - INTERVAL 8 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:4A:67:43')),
  (23.1, 5.19, 255.6, 21.5, 165, @ahora - INTERVAL 7 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:4A:67:43')),
  (13.4, 3.18, 89.4, 60.9, 155, @ahora - INTERVAL 6 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:4A:67:43')),
  (21.5, 2.8, 354.0, 12.5, 180, @ahora - INTERVAL 5 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:4A:67:43')),
  (41.5, 4.76, 141.8, 15.0, 214, @ahora - INTERVAL 4 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:4A:67:43')),
  (39.0, 3.88, 144.7, 22.0, 192, @ahora - INTERVAL 3 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:4A:67:43')),
  (38.3, 4.96, 123.7, 4.9, 232, @ahora - INTERVAL 2 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:4A:67:43')),
  (19.0, 3.33, 339.3, 67.3, 162, @ahora - INTERVAL 1 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:4A:67:43'));
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES (13.5, 5.41, 33.4, 73.0, 159, (SELECT ultima_senal FROM equipo WHERE direccion_mac = '02:5E:0F:4A:67:43'), (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:4A:67:43'));
INSERT INTO almacenamiento (punto_montaje, capacidad_total_gb, espacio_libre_gb, id_informe) VALUES ('C:', 1000, 373.2, LAST_INSERT_ID());
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES
  (46.4, 6.02, 393.8, 52.9, 158, @ahora - INTERVAL 24 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:6F:74:44')),
  (9.1, 10.92, 5.2, 2.6, 233, @ahora - INTERVAL 23 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:6F:74:44')),
  (26.9, 7.23, 100.0, 2.5, 247, @ahora - INTERVAL 22 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:6F:74:44')),
  (27.7, 8.35, 225.4, 19.3, 152, @ahora - INTERVAL 21 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:6F:74:44')),
  (40.8, 8.32, 112.9, 63.0, 176, @ahora - INTERVAL 20 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:6F:74:44')),
  (45.3, 8.63, 157.1, 79.6, 249, @ahora - INTERVAL 19 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:6F:74:44')),
  (38.4, 8.75, 223.4, 67.0, 179, @ahora - INTERVAL 18 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:6F:74:44')),
  (22.2, 6.51, 74.6, 79.9, 148, @ahora - INTERVAL 17 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:6F:74:44')),
  (17.7, 8.04, 225.0, 52.8, 245, @ahora - INTERVAL 16 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:6F:74:44')),
  (53.9, 6.62, 122.9, 3.3, 161, @ahora - INTERVAL 15 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:6F:74:44')),
  (45.8, 9.18, 257.7, 55.0, 222, @ahora - INTERVAL 14 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:6F:74:44')),
  (35.9, 7.67, 399.5, 59.0, 198, @ahora - INTERVAL 13 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:6F:74:44')),
  (64.8, 7.24, 119.0, 23.4, 217, @ahora - INTERVAL 12 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:6F:74:44')),
  (39.0, 7.19, 328.9, 32.6, 247, @ahora - INTERVAL 11 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:6F:74:44')),
  (67.2, 8.48, 360.5, 16.0, 204, @ahora - INTERVAL 10 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:6F:74:44')),
  (68.7, 10.49, 155.7, 49.2, 242, @ahora - INTERVAL 9 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:6F:74:44')),
  (54.8, 9.28, 162.8, 57.4, 249, @ahora - INTERVAL 8 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:6F:74:44')),
  (47.7, 6.95, 381.3, 7.0, 153, @ahora - INTERVAL 7 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:6F:74:44')),
  (25.9, 9.13, 254.9, 16.8, 178, @ahora - INTERVAL 6 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:6F:74:44')),
  (27.7, 6.3, 231.5, 14.6, 223, @ahora - INTERVAL 5 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:6F:74:44')),
  (15.7, 9.32, 295.6, 14.4, 153, @ahora - INTERVAL 4 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:6F:74:44')),
  (39.5, 7.61, 366.4, 43.1, 198, @ahora - INTERVAL 3 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:6F:74:44')),
  (46.5, 7.71, 236.6, 67.1, 157, @ahora - INTERVAL 2 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:6F:74:44')),
  (34.5, 6.94, 260.9, 20.5, 197, @ahora - INTERVAL 1 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:6F:74:44'));
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES (52.2, 7.91, 214.3, 3.1, 252, (SELECT ultima_senal FROM equipo WHERE direccion_mac = '02:5E:0F:6F:74:44'), (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:6F:74:44'));
INSERT INTO almacenamiento (punto_montaje, capacidad_total_gb, espacio_libre_gb, id_informe) VALUES ('C:', 256, 151.4, LAST_INSERT_ID());
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES
  (21.1, 7.16, 202.7, 52.9, 217, @ahora - INTERVAL 24 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:94:81:45')),
  (30.5, 7.2, 374.8, 67.2, 216, @ahora - INTERVAL 23 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:94:81:45')),
  (36.5, 9.61, 170.8, 25.7, 250, @ahora - INTERVAL 22 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:94:81:45')),
  (52.7, 6.72, 270.7, 36.5, 159, @ahora - INTERVAL 21 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:94:81:45')),
  (33.8, 7.11, 286.6, 6.0, 184, @ahora - INTERVAL 20 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:94:81:45')),
  (52.2, 10.57, 312.5, 45.1, 211, @ahora - INTERVAL 19 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:94:81:45')),
  (47.1, 8.72, 31.5, 70.5, 202, @ahora - INTERVAL 18 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:94:81:45')),
  (38.6, 6.71, 394.7, 69.1, 191, @ahora - INTERVAL 17 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:94:81:45')),
  (31.8, 8.5, 77.1, 75.0, 235, @ahora - INTERVAL 16 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:94:81:45')),
  (60.2, 5.84, 340.6, 56.5, 152, @ahora - INTERVAL 15 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:94:81:45')),
  (34.2, 7.15, 255.7, 72.8, 195, @ahora - INTERVAL 14 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:94:81:45')),
  (75.4, 8.26, 13.1, 50.1, 190, @ahora - INTERVAL 13 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:94:81:45')),
  (34.2, 10.09, 221.7, 11.2, 140, @ahora - INTERVAL 12 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:94:81:45')),
  (64.8, 8.75, 5.4, 3.7, 216, @ahora - INTERVAL 11 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:94:81:45')),
  (33.3, 8.23, 12.4, 30.8, 258, @ahora - INTERVAL 10 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:94:81:45')),
  (55.8, 8.42, 270.9, 14.5, 140, @ahora - INTERVAL 9 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:94:81:45')),
  (24.6, 9.12, 297.4, 40.1, 237, @ahora - INTERVAL 8 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:94:81:45')),
  (23.5, 10.29, 301.4, 40.1, 145, @ahora - INTERVAL 7 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:94:81:45')),
  (39.7, 8.39, 386.6, 47.8, 172, @ahora - INTERVAL 6 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:94:81:45')),
  (43.6, 9.29, 275.8, 27.5, 171, @ahora - INTERVAL 5 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:94:81:45')),
  (13.6, 8.27, 9.0, 17.7, 180, @ahora - INTERVAL 4 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:94:81:45')),
  (49.2, 10.39, 74.9, 67.9, 227, @ahora - INTERVAL 3 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:94:81:45')),
  (31.3, 5.84, 70.7, 55.5, 175, @ahora - INTERVAL 2 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:94:81:45')),
  (9.3, 8.6, 241.1, 41.3, 144, @ahora - INTERVAL 1 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:94:81:45'));
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES (55.9, 10.97, 193.0, 62.8, 172, (SELECT ultima_senal FROM equipo WHERE direccion_mac = '02:5E:0F:94:81:45'), (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:94:81:45'));
INSERT INTO almacenamiento (punto_montaje, capacidad_total_gb, espacio_libre_gb, id_informe) VALUES ('C:', 512, 261.6, LAST_INSERT_ID());
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES
  (11.4, 5.86, 359.4, 10.4, 215, @ahora - INTERVAL 24 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:B9:8E:46')),
  (18.4, 7.79, 151.7, 61.4, 167, @ahora - INTERVAL 23 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:B9:8E:46')),
  (48.9, 10.72, 53.5, 69.5, 213, @ahora - INTERVAL 22 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:B9:8E:46')),
  (36.5, 10.06, 148.4, 42.9, 193, @ahora - INTERVAL 21 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:B9:8E:46')),
  (50.8, 6.15, 211.0, 7.2, 230, @ahora - INTERVAL 20 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:B9:8E:46')),
  (45.7, 11.0, 157.4, 45.7, 214, @ahora - INTERVAL 19 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:B9:8E:46')),
  (37.0, 9.34, 185.0, 1.3, 243, @ahora - INTERVAL 18 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:B9:8E:46')),
  (14.7, 10.0, 202.3, 50.8, 241, @ahora - INTERVAL 17 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:B9:8E:46')),
  (19.3, 7.67, 290.7, 63.1, 187, @ahora - INTERVAL 16 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:B9:8E:46')),
  (63.1, 10.4, 334.5, 2.4, 231, @ahora - INTERVAL 15 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:B9:8E:46')),
  (50.9, 10.91, 106.5, 40.3, 174, @ahora - INTERVAL 14 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:B9:8E:46')),
  (77.4, 11.06, 244.0, 75.4, 142, @ahora - INTERVAL 13 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:B9:8E:46')),
  (33.7, 7.65, 42.6, 77.9, 200, @ahora - INTERVAL 12 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:B9:8E:46')),
  (41.1, 5.67, 276.6, 67.6, 188, @ahora - INTERVAL 11 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:B9:8E:46')),
  (79.3, 8.0, 87.7, 31.2, 141, @ahora - INTERVAL 10 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:B9:8E:46')),
  (70.1, 11.02, 265.2, 41.6, 154, @ahora - INTERVAL 9 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:B9:8E:46')),
  (18.0, 9.75, 137.3, 62.9, 248, @ahora - INTERVAL 8 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:B9:8E:46')),
  (34.9, 8.98, 383.7, 69.8, 184, @ahora - INTERVAL 7 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:B9:8E:46')),
  (47.1, 8.66, 31.1, 6.3, 191, @ahora - INTERVAL 6 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:B9:8E:46')),
  (44.8, 7.45, 139.1, 6.9, 244, @ahora - INTERVAL 5 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:B9:8E:46')),
  (11.7, 6.37, 116.2, 62.8, 238, @ahora - INTERVAL 4 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:B9:8E:46')),
  (15.8, 5.66, 315.0, 67.7, 205, @ahora - INTERVAL 3 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:B9:8E:46')),
  (43.8, 10.47, 151.6, 56.8, 155, @ahora - INTERVAL 2 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:B9:8E:46')),
  (19.0, 11.15, 290.1, 42.5, 233, @ahora - INTERVAL 1 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:B9:8E:46'));
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES (23.9, 6.01, 220.3, 65.4, 182, (SELECT ultima_senal FROM equipo WHERE direccion_mac = '02:5E:0F:B9:8E:46'), (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:B9:8E:46'));
INSERT INTO almacenamiento (punto_montaje, capacidad_total_gb, espacio_libre_gb, id_informe) VALUES ('C:', 512, 257.8, LAST_INSERT_ID());
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES
  (37.4, 20.62, 206.4, 12.7, 198, @ahora - INTERVAL 24 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:DE:9B:47')),
  (25.8, 11.46, 51.9, 17.9, 246, @ahora - INTERVAL 23 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:DE:9B:47')),
  (29.5, 17.6, 113.8, 33.4, 256, @ahora - INTERVAL 22 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:DE:9B:47')),
  (27.4, 14.89, 213.7, 68.5, 231, @ahora - INTERVAL 21 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:DE:9B:47')),
  (26.2, 20.49, 365.7, 28.6, 238, @ahora - INTERVAL 20 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:DE:9B:47')),
  (43.4, 20.83, 313.6, 72.0, 166, @ahora - INTERVAL 19 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:DE:9B:47')),
  (40.2, 15.7, 156.0, 42.2, 253, @ahora - INTERVAL 18 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:DE:9B:47')),
  (39.7, 20.89, 128.5, 53.4, 177, @ahora - INTERVAL 17 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:DE:9B:47')),
  (30.1, 18.64, 255.4, 53.9, 178, @ahora - INTERVAL 16 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:DE:9B:47')),
  (69.3, 12.0, 199.3, 7.6, 236, @ahora - INTERVAL 15 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:DE:9B:47')),
  (55.6, 21.89, 130.1, 38.1, 228, @ahora - INTERVAL 14 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:DE:9B:47')),
  (34.5, 15.05, 229.4, 52.8, 221, @ahora - INTERVAL 13 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:DE:9B:47')),
  (36.6, 16.42, 99.2, 33.9, 257, @ahora - INTERVAL 12 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:DE:9B:47')),
  (35.1, 12.26, 341.4, 68.6, 160, @ahora - INTERVAL 11 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:DE:9B:47')),
  (37.0, 13.4, 214.6, 4.1, 183, @ahora - INTERVAL 10 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:DE:9B:47')),
  (56.6, 18.29, 20.0, 4.3, 218, @ahora - INTERVAL 9 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:DE:9B:47')),
  (38.4, 14.53, 157.4, 21.2, 185, @ahora - INTERVAL 8 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:DE:9B:47')),
  (40.9, 17.98, 118.8, 33.4, 196, @ahora - INTERVAL 7 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:DE:9B:47')),
  (42.5, 20.77, 318.5, 41.8, 187, @ahora - INTERVAL 6 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:DE:9B:47')),
  (36.7, 12.69, 183.8, 7.1, 245, @ahora - INTERVAL 5 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:DE:9B:47')),
  (26.1, 21.79, 261.3, 35.7, 174, @ahora - INTERVAL 4 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:DE:9B:47')),
  (23.3, 15.51, 307.1, 9.5, 252, @ahora - INTERVAL 3 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:DE:9B:47')),
  (13.1, 20.8, 275.6, 77.3, 156, @ahora - INTERVAL 2 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:DE:9B:47')),
  (48.2, 13.32, 306.3, 56.4, 160, @ahora - INTERVAL 1 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:DE:9B:47'));
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES (23.4, 15.41, 236.8, 12.4, 141, (SELECT ultima_senal FROM equipo WHERE direccion_mac = '02:5E:0F:DE:9B:47'), (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:DE:9B:47'));
INSERT INTO almacenamiento (punto_montaje, capacidad_total_gb, espacio_libre_gb, id_informe) VALUES ('C:', 1000, 445.9, LAST_INSERT_ID());
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES
  (30.4, 3.37, 356.2, 63.6, 251, @ahora - INTERVAL 24 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:03:A8:48')),
  (40.8, 3.53, 304.3, 66.9, 182, @ahora - INTERVAL 23 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:03:A8:48')),
  (12.9, 4.28, 28.5, 48.6, 230, @ahora - INTERVAL 22 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:03:A8:48')),
  (47.6, 4.61, 51.2, 7.8, 191, @ahora - INTERVAL 21 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:03:A8:48')),
  (10.0, 2.8, 131.7, 24.4, 167, @ahora - INTERVAL 20 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:03:A8:48')),
  (45.0, 3.64, 20.5, 44.8, 177, @ahora - INTERVAL 19 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:03:A8:48')),
  (32.9, 5.09, 297.2, 31.9, 218, @ahora - INTERVAL 18 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:03:A8:48')),
  (19.2, 5.07, 41.9, 56.2, 153, @ahora - INTERVAL 17 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:03:A8:48')),
  (20.0, 3.58, 14.2, 35.0, 248, @ahora - INTERVAL 16 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:03:A8:48')),
  (38.2, 5.3, 278.6, 62.3, 227, @ahora - INTERVAL 15 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:03:A8:48')),
  (60.2, 4.32, 246.9, 75.4, 248, @ahora - INTERVAL 14 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:03:A8:48')),
  (54.8, 4.01, 18.1, 78.3, 191, @ahora - INTERVAL 13 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:03:A8:48')),
  (72.3, 3.95, 60.0, 45.4, 196, @ahora - INTERVAL 12 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:03:A8:48')),
  (67.4, 3.7, 72.1, 59.1, 167, @ahora - INTERVAL 11 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:03:A8:48')),
  (36.6, 2.98, 198.2, 14.9, 147, @ahora - INTERVAL 10 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:03:A8:48')),
  (45.6, 4.12, 184.8, 16.3, 197, @ahora - INTERVAL 9 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:03:A8:48')),
  (50.2, 2.97, 192.1, 21.9, 253, @ahora - INTERVAL 8 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:03:A8:48')),
  (47.6, 4.96, 155.1, 10.0, 260, @ahora - INTERVAL 7 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:03:A8:48')),
  (22.2, 5.24, 109.9, 12.8, 192, @ahora - INTERVAL 6 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:03:A8:48')),
  (35.4, 5.41, 180.8, 16.7, 223, @ahora - INTERVAL 5 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:03:A8:48')),
  (52.1, 5.49, 54.1, 59.6, 186, @ahora - INTERVAL 4 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:03:A8:48')),
  (51.3, 4.4, 250.5, 47.1, 152, @ahora - INTERVAL 3 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:03:A8:48')),
  (42.8, 4.94, 56.4, 38.7, 246, @ahora - INTERVAL 2 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:03:A8:48')),
  (28.7, 4.35, 345.0, 32.6, 257, @ahora - INTERVAL 1 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:03:A8:48'));
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES (58.0, 3.89, 324.3, 35.8, 211, (SELECT ultima_senal FROM equipo WHERE direccion_mac = '02:5E:0F:03:A8:48'), (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:03:A8:48'));
INSERT INTO almacenamiento (punto_montaje, capacidad_total_gb, espacio_libre_gb, id_informe) VALUES ('C:', 256, 77.9, LAST_INSERT_ID());
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES
  (27.0, 3.51, 142.3, 52.5, 221, @ahora - INTERVAL 24 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:28:B5:49')),
  (11.0, 4.13, 312.2, 8.4, 205, @ahora - INTERVAL 23 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:28:B5:49')),
  (19.2, 3.32, 190.0, 14.9, 220, @ahora - INTERVAL 22 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:28:B5:49')),
  (21.2, 5.0, 234.1, 30.0, 153, @ahora - INTERVAL 21 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:28:B5:49')),
  (17.0, 4.32, 10.7, 30.3, 173, @ahora - INTERVAL 20 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:28:B5:49')),
  (29.0, 5.26, 32.0, 16.3, 236, @ahora - INTERVAL 19 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:28:B5:49')),
  (51.6, 5.22, 160.9, 41.0, 209, @ahora - INTERVAL 18 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:28:B5:49')),
  (43.9, 2.82, 131.0, 73.2, 193, @ahora - INTERVAL 17 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:28:B5:49')),
  (10.2, 4.49, 183.9, 36.2, 199, @ahora - INTERVAL 16 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:28:B5:49')),
  (39.8, 5.46, 154.9, 54.3, 201, @ahora - INTERVAL 15 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:28:B5:49')),
  (34.8, 5.27, 292.3, 36.5, 217, @ahora - INTERVAL 14 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:28:B5:49')),
  (72.7, 3.64, 381.8, 12.3, 201, @ahora - INTERVAL 13 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:28:B5:49')),
  (51.7, 4.1, 9.4, 8.3, 186, @ahora - INTERVAL 12 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:28:B5:49')),
  (72.7, 4.38, 254.4, 54.6, 238, @ahora - INTERVAL 11 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:28:B5:49')),
  (49.9, 3.2, 105.9, 55.1, 185, @ahora - INTERVAL 10 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:28:B5:49')),
  (53.8, 3.94, 242.2, 72.2, 169, @ahora - INTERVAL 9 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:28:B5:49')),
  (44.6, 3.41, 54.3, 65.8, 150, @ahora - INTERVAL 8 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:28:B5:49')),
  (22.6, 3.69, 216.1, 14.0, 142, @ahora - INTERVAL 7 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:28:B5:49')),
  (19.8, 5.34, 25.1, 67.2, 240, @ahora - INTERVAL 6 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:28:B5:49')),
  (46.2, 5.25, 389.9, 10.7, 152, @ahora - INTERVAL 5 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:28:B5:49')),
  (46.7, 4.76, 381.5, 8.4, 149, @ahora - INTERVAL 4 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:28:B5:49')),
  (16.5, 4.04, 298.0, 77.7, 168, @ahora - INTERVAL 3 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:28:B5:49')),
  (47.8, 4.99, 83.2, 30.7, 159, @ahora - INTERVAL 2 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:28:B5:49')),
  (19.7, 4.89, 54.9, 40.2, 174, @ahora - INTERVAL 1 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:28:B5:49'));
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES (12.2, 2.94, 362.1, 20.0, 167, (SELECT ultima_senal FROM equipo WHERE direccion_mac = '02:5E:0F:28:B5:49'), (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:28:B5:49'));
INSERT INTO almacenamiento (punto_montaje, capacidad_total_gb, espacio_libre_gb, id_informe) VALUES ('C:', 512, 356.7, LAST_INSERT_ID());
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES (18.0, 9.33, 282.7, 66.0, 231, (SELECT ultima_senal FROM equipo WHERE direccion_mac = '02:5E:0F:4D:C2:4A'), (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:4D:C2:4A'));
INSERT INTO almacenamiento (punto_montaje, capacidad_total_gb, espacio_libre_gb, id_informe) VALUES ('C:', 512, 283.5, LAST_INSERT_ID());
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES (23.3, 9.51, 124.6, 51.8, 231, (SELECT ultima_senal FROM equipo WHERE direccion_mac = '02:5E:0F:72:CF:4B'), (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:72:CF:4B'));
INSERT INTO almacenamiento (punto_montaje, capacidad_total_gb, espacio_libre_gb, id_informe) VALUES ('C:', 1000, 269.9, LAST_INSERT_ID());
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES (54.5, 5.8, 333.5, 16.9, 222, (SELECT ultima_senal FROM equipo WHERE direccion_mac = '02:5E:0F:97:DC:4C'), (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:0F:97:DC:4C'));
INSERT INTO almacenamiento (punto_montaje, capacidad_total_gb, espacio_libre_gb, id_informe) VALUES ('C:', 256, 85.2, LAST_INSERT_ID());
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES
  (16.1, 18.16, 365.2, 68.9, 240, @ahora - INTERVAL 24 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:00:E9:4D')),
  (11.1, 16.31, 325.7, 51.3, 252, @ahora - INTERVAL 23 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:00:E9:4D')),
  (49.6, 19.77, 252.7, 67.0, 193, @ahora - INTERVAL 22 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:00:E9:4D')),
  (31.3, 18.7, 227.3, 35.4, 176, @ahora - INTERVAL 21 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:00:E9:4D')),
  (41.6, 20.05, 217.9, 66.3, 164, @ahora - INTERVAL 20 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:00:E9:4D')),
  (19.3, 19.41, 253.6, 74.4, 176, @ahora - INTERVAL 19 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:00:E9:4D')),
  (16.4, 21.23, 380.0, 2.8, 190, @ahora - INTERVAL 18 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:00:E9:4D')),
  (21.6, 18.62, 77.6, 40.6, 165, @ahora - INTERVAL 17 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:00:E9:4D')),
  (50.6, 13.86, 82.7, 70.0, 141, @ahora - INTERVAL 16 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:00:E9:4D')),
  (52.9, 18.22, 130.2, 7.9, 192, @ahora - INTERVAL 15 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:00:E9:4D')),
  (38.7, 17.84, 26.4, 77.9, 192, @ahora - INTERVAL 14 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:00:E9:4D')),
  (51.9, 17.26, 163.2, 20.2, 175, @ahora - INTERVAL 13 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:00:E9:4D')),
  (43.1, 12.95, 46.8, 36.7, 255, @ahora - INTERVAL 12 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:00:E9:4D')),
  (71.7, 18.1, 52.0, 52.8, 227, @ahora - INTERVAL 11 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:00:E9:4D')),
  (49.7, 15.32, 30.2, 32.5, 247, @ahora - INTERVAL 10 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:00:E9:4D')),
  (34.7, 19.99, 246.8, 24.1, 172, @ahora - INTERVAL 9 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:00:E9:4D')),
  (25.3, 11.45, 40.6, 36.1, 189, @ahora - INTERVAL 8 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:00:E9:4D')),
  (22.1, 20.64, 138.3, 25.8, 241, @ahora - INTERVAL 7 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:00:E9:4D')),
  (18.0, 17.34, 284.6, 78.5, 145, @ahora - INTERVAL 6 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:00:E9:4D')),
  (29.8, 21.98, 346.9, 31.7, 146, @ahora - INTERVAL 5 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:00:E9:4D')),
  (21.0, 18.21, 303.8, 77.6, 253, @ahora - INTERVAL 4 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:00:E9:4D')),
  (44.7, 19.65, 82.3, 63.2, 202, @ahora - INTERVAL 3 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:00:E9:4D')),
  (29.7, 22.33, 89.6, 22.2, 256, @ahora - INTERVAL 2 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:00:E9:4D')),
  (40.3, 20.81, 378.6, 61.6, 203, @ahora - INTERVAL 1 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:00:E9:4D'));
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES (21.2, 29.87, 140.0, 47.7, 173, (SELECT ultima_senal FROM equipo WHERE direccion_mac = '02:5E:01:00:E9:4D'), (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:00:E9:4D'));
INSERT INTO almacenamiento (punto_montaje, capacidad_total_gb, espacio_libre_gb, id_informe) VALUES ('C:', 512, 22.9, LAST_INSERT_ID());
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES
  (39.6, 4.99, 134.0, 69.4, 171, @ahora - INTERVAL 24 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:25:F6:4E')),
  (40.0, 4.05, 46.7, 12.2, 258, @ahora - INTERVAL 23 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:25:F6:4E')),
  (11.8, 4.56, 285.7, 39.8, 217, @ahora - INTERVAL 22 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:25:F6:4E')),
  (11.9, 3.7, 212.2, 17.5, 211, @ahora - INTERVAL 21 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:25:F6:4E')),
  (16.0, 4.94, 346.3, 19.6, 167, @ahora - INTERVAL 20 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:25:F6:4E')),
  (53.1, 4.73, 151.2, 79.7, 247, @ahora - INTERVAL 19 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:25:F6:4E')),
  (41.8, 3.75, 281.9, 2.4, 225, @ahora - INTERVAL 18 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:25:F6:4E')),
  (47.2, 4.58, 56.3, 6.8, 182, @ahora - INTERVAL 17 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:25:F6:4E')),
  (9.1, 5.47, 297.4, 68.8, 181, @ahora - INTERVAL 16 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:25:F6:4E')),
  (71.0, 5.12, 70.7, 49.1, 229, @ahora - INTERVAL 15 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:25:F6:4E')),
  (34.8, 4.89, 370.1, 22.7, 156, @ahora - INTERVAL 14 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:25:F6:4E')),
  (44.2, 4.76, 96.2, 51.8, 238, @ahora - INTERVAL 13 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:25:F6:4E')),
  (77.8, 4.97, 24.4, 40.1, 233, @ahora - INTERVAL 12 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:25:F6:4E')),
  (57.2, 4.02, 177.6, 29.5, 253, @ahora - INTERVAL 11 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:25:F6:4E')),
  (53.8, 5.11, 75.1, 42.9, 221, @ahora - INTERVAL 10 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:25:F6:4E')),
  (54.7, 4.27, 92.3, 9.0, 188, @ahora - INTERVAL 9 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:25:F6:4E')),
  (22.5, 3.56, 216.4, 13.1, 222, @ahora - INTERVAL 8 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:25:F6:4E')),
  (43.3, 4.01, 242.2, 31.4, 197, @ahora - INTERVAL 7 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:25:F6:4E')),
  (53.0, 5.29, 9.0, 50.2, 166, @ahora - INTERVAL 6 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:25:F6:4E')),
  (51.8, 3.42, 327.2, 21.4, 226, @ahora - INTERVAL 5 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:25:F6:4E')),
  (29.3, 4.33, 155.4, 26.2, 248, @ahora - INTERVAL 4 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:25:F6:4E')),
  (37.3, 4.71, 36.3, 6.7, 244, @ahora - INTERVAL 3 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:25:F6:4E')),
  (11.3, 5.23, 327.3, 45.7, 146, @ahora - INTERVAL 2 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:25:F6:4E')),
  (21.6, 4.26, 355.2, 4.1, 226, @ahora - INTERVAL 1 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:25:F6:4E'));
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES (94.4, 5.22, 248.0, 70.2, 172, (SELECT ultima_senal FROM equipo WHERE direccion_mac = '02:5E:01:25:F6:4E'), (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:25:F6:4E'));
INSERT INTO almacenamiento (punto_montaje, capacidad_total_gb, espacio_libre_gb, id_informe) VALUES ('C:', 512, 40.9, LAST_INSERT_ID());
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES
  (44.7, 8.14, 292.8, 3.8, 147, @ahora - INTERVAL 24 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:6F:10:50')),
  (13.3, 9.63, 78.7, 18.6, 147, @ahora - INTERVAL 23 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:6F:10:50')),
  (30.9, 6.19, 379.3, 30.6, 190, @ahora - INTERVAL 22 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:6F:10:50')),
  (44.6, 7.38, 252.8, 45.0, 189, @ahora - INTERVAL 21 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:6F:10:50')),
  (20.6, 8.19, 358.6, 28.3, 222, @ahora - INTERVAL 20 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:6F:10:50')),
  (25.2, 11.06, 193.0, 15.2, 235, @ahora - INTERVAL 19 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:6F:10:50')),
  (53.9, 8.38, 28.9, 6.1, 160, @ahora - INTERVAL 18 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:6F:10:50')),
  (23.3, 9.65, 398.3, 54.1, 167, @ahora - INTERVAL 17 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:6F:10:50')),
  (12.9, 9.4, 141.8, 15.7, 198, @ahora - INTERVAL 16 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:6F:10:50')),
  (44.3, 9.08, 257.2, 40.6, 153, @ahora - INTERVAL 15 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:6F:10:50')),
  (67.0, 5.93, 229.9, 11.4, 148, @ahora - INTERVAL 14 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:6F:10:50')),
  (35.8, 9.52, 258.8, 2.8, 245, @ahora - INTERVAL 13 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:6F:10:50')),
  (47.0, 6.24, 281.4, 41.8, 242, @ahora - INTERVAL 12 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:6F:10:50')),
  (50.0, 8.95, 53.0, 69.7, 222, @ahora - INTERVAL 11 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:6F:10:50')),
  (48.9, 6.91, 254.1, 34.5, 202, @ahora - INTERVAL 10 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:6F:10:50')),
  (70.3, 7.01, 201.5, 13.0, 169, @ahora - INTERVAL 9 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:6F:10:50')),
  (22.0, 5.75, 244.4, 32.2, 223, @ahora - INTERVAL 8 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:6F:10:50')),
  (40.5, 9.17, 122.1, 53.7, 174, @ahora - INTERVAL 7 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:6F:10:50')),
  (14.3, 8.09, 183.9, 48.2, 148, @ahora - INTERVAL 6 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:6F:10:50')),
  (8.8, 10.16, 374.9, 79.5, 221, @ahora - INTERVAL 5 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:6F:10:50')),
  (33.4, 10.89, 40.0, 69.8, 250, @ahora - INTERVAL 4 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:6F:10:50')),
  (44.1, 10.31, 198.0, 49.1, 175, @ahora - INTERVAL 3 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:6F:10:50')),
  (21.8, 10.02, 153.2, 13.4, 191, @ahora - INTERVAL 2 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:6F:10:50')),
  (54.7, 7.19, 31.1, 33.0, 144, @ahora - INTERVAL 1 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:6F:10:50'));
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES (49.0, 7.68, 290.3, 67.6, 244, (SELECT ultima_senal FROM equipo WHERE direccion_mac = '02:5E:01:6F:10:50'), (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:6F:10:50'));
INSERT INTO almacenamiento (punto_montaje, capacidad_total_gb, espacio_libre_gb, id_informe) VALUES ('C:', 256, 153.5, LAST_INSERT_ID());
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES
  (20.3, 8.78, 116.4, 55.5, 194, @ahora - INTERVAL 24 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:94:1D:51')),
  (36.6, 10.92, 378.4, 43.8, 169, @ahora - INTERVAL 23 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:94:1D:51')),
  (28.7, 8.95, 367.3, 32.7, 218, @ahora - INTERVAL 22 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:94:1D:51')),
  (32.6, 10.27, 210.0, 57.9, 242, @ahora - INTERVAL 21 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:94:1D:51')),
  (28.0, 7.92, 248.8, 5.4, 177, @ahora - INTERVAL 20 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:94:1D:51')),
  (37.9, 11.1, 322.5, 67.8, 246, @ahora - INTERVAL 19 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:94:1D:51')),
  (37.3, 10.46, 269.7, 57.0, 223, @ahora - INTERVAL 18 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:94:1D:51')),
  (8.8, 7.21, 355.7, 7.8, 241, @ahora - INTERVAL 17 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:94:1D:51')),
  (23.5, 6.31, 161.2, 66.4, 140, @ahora - INTERVAL 16 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:94:1D:51')),
  (74.0, 6.74, 352.1, 61.3, 258, @ahora - INTERVAL 15 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:94:1D:51')),
  (51.0, 6.03, 342.9, 44.0, 205, @ahora - INTERVAL 14 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:94:1D:51')),
  (58.1, 7.54, 52.3, 42.8, 249, @ahora - INTERVAL 13 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:94:1D:51')),
  (36.6, 8.63, 170.7, 55.9, 166, @ahora - INTERVAL 12 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:94:1D:51')),
  (49.5, 11.03, 260.0, 65.3, 211, @ahora - INTERVAL 11 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:94:1D:51')),
  (60.6, 6.3, 218.5, 36.2, 198, @ahora - INTERVAL 10 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:94:1D:51')),
  (49.1, 6.44, 243.0, 55.1, 186, @ahora - INTERVAL 9 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:94:1D:51')),
  (38.0, 11.02, 197.4, 13.4, 245, @ahora - INTERVAL 8 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:94:1D:51')),
  (29.9, 6.47, 348.1, 49.0, 195, @ahora - INTERVAL 7 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:94:1D:51')),
  (24.6, 9.78, 309.4, 56.8, 200, @ahora - INTERVAL 6 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:94:1D:51')),
  (32.9, 7.69, 78.8, 45.1, 221, @ahora - INTERVAL 5 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:94:1D:51')),
  (48.1, 9.92, 235.6, 49.0, 224, @ahora - INTERVAL 4 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:94:1D:51')),
  (25.0, 9.44, 272.9, 18.5, 197, @ahora - INTERVAL 3 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:94:1D:51')),
  (51.5, 6.53, 270.0, 34.9, 216, @ahora - INTERVAL 2 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:94:1D:51')),
  (37.1, 7.03, 159.0, 23.3, 241, @ahora - INTERVAL 1 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:94:1D:51'));
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES (21.0, 10.51, 99.6, 64.6, 234, (SELECT ultima_senal FROM equipo WHERE direccion_mac = '02:5E:01:94:1D:51'), (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:94:1D:51'));
INSERT INTO almacenamiento (punto_montaje, capacidad_total_gb, espacio_libre_gb, id_informe) VALUES ('C:', 512, 258.5, LAST_INSERT_ID());
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES
  (44.3, 10.1, 62.2, 74.6, 166, @ahora - INTERVAL 24 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:B9:2A:52')),
  (15.0, 7.53, 248.1, 13.9, 202, @ahora - INTERVAL 23 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:B9:2A:52')),
  (50.3, 8.63, 399.4, 60.0, 170, @ahora - INTERVAL 22 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:B9:2A:52')),
  (9.5, 6.79, 366.1, 40.2, 164, @ahora - INTERVAL 21 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:B9:2A:52')),
  (10.8, 9.46, 250.8, 31.3, 189, @ahora - INTERVAL 20 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:B9:2A:52')),
  (38.5, 7.47, 19.1, 57.7, 197, @ahora - INTERVAL 19 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:B9:2A:52')),
  (40.5, 5.92, 196.2, 67.0, 213, @ahora - INTERVAL 18 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:B9:2A:52')),
  (31.3, 6.69, 311.8, 74.8, 159, @ahora - INTERVAL 17 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:B9:2A:52')),
  (39.3, 8.97, 136.5, 5.9, 241, @ahora - INTERVAL 16 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:B9:2A:52')),
  (55.2, 6.57, 31.6, 45.8, 231, @ahora - INTERVAL 15 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:B9:2A:52')),
  (70.5, 8.57, 352.7, 46.3, 221, @ahora - INTERVAL 14 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:B9:2A:52')),
  (42.9, 6.85, 327.6, 75.0, 259, @ahora - INTERVAL 13 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:B9:2A:52')),
  (41.3, 6.26, 284.8, 58.4, 171, @ahora - INTERVAL 12 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:B9:2A:52')),
  (61.2, 9.52, 305.6, 42.4, 164, @ahora - INTERVAL 11 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:B9:2A:52')),
  (79.7, 9.07, 112.2, 77.6, 176, @ahora - INTERVAL 10 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:B9:2A:52')),
  (48.3, 8.1, 188.1, 55.4, 199, @ahora - INTERVAL 9 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:B9:2A:52')),
  (10.8, 7.05, 358.0, 40.9, 226, @ahora - INTERVAL 8 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:B9:2A:52')),
  (37.9, 9.0, 387.9, 9.1, 208, @ahora - INTERVAL 7 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:B9:2A:52')),
  (46.9, 9.89, 217.1, 28.1, 259, @ahora - INTERVAL 6 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:B9:2A:52')),
  (49.3, 8.94, 5.3, 29.8, 154, @ahora - INTERVAL 5 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:B9:2A:52')),
  (44.5, 10.68, 66.8, 14.4, 172, @ahora - INTERVAL 4 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:B9:2A:52')),
  (18.6, 9.97, 345.5, 75.2, 244, @ahora - INTERVAL 3 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:B9:2A:52')),
  (43.2, 7.37, 201.0, 50.0, 182, @ahora - INTERVAL 2 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:B9:2A:52')),
  (34.1, 6.31, 168.5, 25.2, 143, @ahora - INTERVAL 1 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:B9:2A:52'));
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES (25.1, 9.8, 137.9, 54.5, 251, (SELECT ultima_senal FROM equipo WHERE direccion_mac = '02:5E:01:B9:2A:52'), (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:B9:2A:52'));
INSERT INTO almacenamiento (punto_montaje, capacidad_total_gb, espacio_libre_gb, id_informe) VALUES ('C:', 512, 217.7, LAST_INSERT_ID());
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES
  (28.8, 11.32, 296.1, 34.6, 211, @ahora - INTERVAL 24 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:DE:37:53')),
  (45.9, 15.64, 21.9, 43.1, 194, @ahora - INTERVAL 23 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:DE:37:53')),
  (39.5, 11.6, 175.0, 32.8, 260, @ahora - INTERVAL 22 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:DE:37:53')),
  (53.4, 22.19, 51.6, 68.7, 177, @ahora - INTERVAL 21 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:DE:37:53')),
  (18.2, 19.92, 266.7, 61.2, 183, @ahora - INTERVAL 20 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:DE:37:53')),
  (28.0, 16.67, 70.3, 33.3, 238, @ahora - INTERVAL 19 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:DE:37:53')),
  (34.3, 17.36, 298.8, 72.7, 147, @ahora - INTERVAL 18 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:DE:37:53')),
  (19.1, 15.95, 39.3, 62.3, 241, @ahora - INTERVAL 17 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:DE:37:53')),
  (33.9, 18.77, 368.0, 47.3, 154, @ahora - INTERVAL 16 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:DE:37:53')),
  (33.2, 15.55, 97.5, 18.8, 162, @ahora - INTERVAL 15 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:DE:37:53')),
  (61.1, 17.31, 199.9, 20.8, 224, @ahora - INTERVAL 14 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:DE:37:53')),
  (59.2, 18.05, 199.9, 46.7, 247, @ahora - INTERVAL 13 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:DE:37:53')),
  (55.1, 17.87, 173.7, 9.9, 254, @ahora - INTERVAL 12 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:DE:37:53')),
  (59.8, 18.13, 36.7, 78.0, 194, @ahora - INTERVAL 11 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:DE:37:53')),
  (46.9, 13.21, 343.9, 4.9, 195, @ahora - INTERVAL 10 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:DE:37:53')),
  (39.0, 22.05, 383.6, 43.0, 257, @ahora - INTERVAL 9 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:DE:37:53')),
  (11.9, 13.78, 16.4, 5.4, 258, @ahora - INTERVAL 8 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:DE:37:53')),
  (44.4, 15.67, 218.6, 37.7, 145, @ahora - INTERVAL 7 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:DE:37:53')),
  (34.6, 14.47, 158.9, 43.4, 142, @ahora - INTERVAL 6 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:DE:37:53')),
  (13.8, 18.74, 10.1, 62.3, 222, @ahora - INTERVAL 5 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:DE:37:53')),
  (41.2, 13.81, 33.2, 35.4, 166, @ahora - INTERVAL 4 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:DE:37:53')),
  (17.1, 21.85, 398.1, 1.7, 148, @ahora - INTERVAL 3 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:DE:37:53')),
  (8.5, 11.26, 62.0, 57.8, 210, @ahora - INTERVAL 2 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:DE:37:53')),
  (19.4, 14.35, 310.7, 22.8, 171, @ahora - INTERVAL 1 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:DE:37:53'));
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES (23.9, 12.26, 103.2, 4.1, 146, (SELECT ultima_senal FROM equipo WHERE direccion_mac = '02:5E:01:DE:37:53'), (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:DE:37:53'));
INSERT INTO almacenamiento (punto_montaje, capacidad_total_gb, espacio_libre_gb, id_informe) VALUES ('C:', 1000, 623.4, LAST_INSERT_ID());
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES
  (12.4, 3.58, 398.8, 48.4, 229, @ahora - INTERVAL 24 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:03:44:54')),
  (46.4, 5.5, 363.2, 22.7, 171, @ahora - INTERVAL 23 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:03:44:54')),
  (29.3, 4.19, 368.6, 38.9, 188, @ahora - INTERVAL 22 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:03:44:54')),
  (22.2, 3.26, 281.3, 56.8, 217, @ahora - INTERVAL 21 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:03:44:54')),
  (42.0, 4.69, 221.1, 11.4, 212, @ahora - INTERVAL 20 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:03:44:54')),
  (28.4, 3.21, 159.5, 8.2, 222, @ahora - INTERVAL 19 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:03:44:54')),
  (9.4, 5.42, 385.8, 57.1, 211, @ahora - INTERVAL 18 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:03:44:54')),
  (37.1, 4.77, 194.5, 56.3, 191, @ahora - INTERVAL 17 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:03:44:54')),
  (16.9, 3.1, 314.4, 5.2, 187, @ahora - INTERVAL 16 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:03:44:54')),
  (67.5, 5.24, 113.5, 58.4, 148, @ahora - INTERVAL 15 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:03:44:54')),
  (57.5, 4.92, 174.2, 64.0, 172, @ahora - INTERVAL 14 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:03:44:54')),
  (33.0, 3.14, 140.6, 67.6, 210, @ahora - INTERVAL 13 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:03:44:54')),
  (46.1, 4.97, 219.4, 1.6, 192, @ahora - INTERVAL 12 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:03:44:54')),
  (64.6, 3.97, 160.1, 55.9, 183, @ahora - INTERVAL 11 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:03:44:54')),
  (64.4, 4.69, 36.9, 39.8, 193, @ahora - INTERVAL 10 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:03:44:54')),
  (47.2, 3.34, 36.4, 29.2, 218, @ahora - INTERVAL 9 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:03:44:54')),
  (8.9, 5.01, 245.7, 61.4, 248, @ahora - INTERVAL 8 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:03:44:54')),
  (49.3, 5.5, 287.1, 52.9, 201, @ahora - INTERVAL 7 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:03:44:54')),
  (34.5, 3.92, 347.5, 18.6, 251, @ahora - INTERVAL 6 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:03:44:54')),
  (42.1, 5.19, 313.3, 64.5, 203, @ahora - INTERVAL 5 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:03:44:54')),
  (54.2, 3.29, 39.2, 39.0, 158, @ahora - INTERVAL 4 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:03:44:54')),
  (29.7, 2.97, 221.8, 78.2, 190, @ahora - INTERVAL 3 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:03:44:54')),
  (27.1, 5.24, 347.0, 54.5, 219, @ahora - INTERVAL 2 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:03:44:54')),
  (10.6, 3.12, 107.7, 23.7, 177, @ahora - INTERVAL 1 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:03:44:54'));
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES (37.5, 4.72, 221.8, 18.3, 232, (SELECT ultima_senal FROM equipo WHERE direccion_mac = '02:5E:01:03:44:54'), (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:03:44:54'));
INSERT INTO almacenamiento (punto_montaje, capacidad_total_gb, espacio_libre_gb, id_informe) VALUES ('C:', 256, 168.7, LAST_INSERT_ID());
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES
  (10.0, 4.76, 252.0, 76.9, 144, @ahora - INTERVAL 24 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:28:51:55')),
  (23.8, 3.2, 56.5, 39.7, 223, @ahora - INTERVAL 23 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:28:51:55')),
  (43.1, 3.21, 336.5, 79.5, 257, @ahora - INTERVAL 22 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:28:51:55')),
  (44.8, 4.5, 73.0, 43.3, 222, @ahora - INTERVAL 21 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:28:51:55')),
  (38.6, 5.49, 382.6, 24.3, 153, @ahora - INTERVAL 20 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:28:51:55')),
  (49.4, 4.45, 104.7, 9.3, 217, @ahora - INTERVAL 19 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:28:51:55')),
  (31.5, 5.16, 309.9, 45.6, 171, @ahora - INTERVAL 18 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:28:51:55')),
  (49.3, 4.18, 30.1, 32.5, 210, @ahora - INTERVAL 17 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:28:51:55')),
  (21.6, 3.31, 319.0, 17.4, 236, @ahora - INTERVAL 16 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:28:51:55')),
  (61.1, 3.73, 32.6, 6.8, 260, @ahora - INTERVAL 15 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:28:51:55')),
  (44.4, 4.43, 183.8, 51.8, 150, @ahora - INTERVAL 14 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:28:51:55')),
  (52.3, 5.21, 87.5, 34.1, 242, @ahora - INTERVAL 13 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:28:51:55')),
  (70.0, 4.8, 26.1, 58.4, 202, @ahora - INTERVAL 12 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:28:51:55')),
  (40.0, 5.07, 132.6, 71.7, 155, @ahora - INTERVAL 11 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:28:51:55')),
  (45.2, 5.11, 162.0, 41.7, 232, @ahora - INTERVAL 10 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:28:51:55')),
  (41.2, 3.48, 272.3, 21.0, 257, @ahora - INTERVAL 9 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:28:51:55')),
  (12.9, 5.47, 72.9, 24.6, 160, @ahora - INTERVAL 8 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:28:51:55')),
  (10.1, 5.0, 320.0, 36.1, 191, @ahora - INTERVAL 7 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:28:51:55')),
  (17.1, 4.21, 85.5, 16.6, 199, @ahora - INTERVAL 6 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:28:51:55')),
  (40.8, 4.64, 245.6, 39.8, 211, @ahora - INTERVAL 5 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:28:51:55')),
  (20.6, 4.57, 91.8, 27.7, 144, @ahora - INTERVAL 4 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:28:51:55')),
  (14.0, 3.86, 222.9, 45.6, 143, @ahora - INTERVAL 3 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:28:51:55')),
  (41.8, 5.05, 284.3, 38.1, 163, @ahora - INTERVAL 2 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:28:51:55')),
  (43.9, 3.97, 33.8, 62.8, 178, @ahora - INTERVAL 1 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:28:51:55'));
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES (25.9, 4.34, 296.0, 30.3, 177, (SELECT ultima_senal FROM equipo WHERE direccion_mac = '02:5E:01:28:51:55'), (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:28:51:55'));
INSERT INTO almacenamiento (punto_montaje, capacidad_total_gb, espacio_libre_gb, id_informe) VALUES ('C:', 512, 294.1, LAST_INSERT_ID());
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES
  (39.8, 7.31, 7.9, 2.9, 158, @ahora - INTERVAL 24 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:4D:5E:56')),
  (26.8, 8.52, 35.1, 27.0, 183, @ahora - INTERVAL 23 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:4D:5E:56')),
  (47.0, 9.22, 307.6, 43.8, 184, @ahora - INTERVAL 22 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:4D:5E:56')),
  (37.3, 9.65, 71.2, 38.7, 145, @ahora - INTERVAL 21 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:4D:5E:56')),
  (48.6, 8.73, 386.5, 16.9, 192, @ahora - INTERVAL 20 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:4D:5E:56')),
  (11.0, 6.98, 151.2, 59.6, 159, @ahora - INTERVAL 19 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:4D:5E:56')),
  (19.4, 8.73, 346.7, 75.1, 231, @ahora - INTERVAL 18 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:4D:5E:56')),
  (17.3, 10.92, 62.5, 20.0, 243, @ahora - INTERVAL 17 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:4D:5E:56')),
  (43.5, 7.16, 129.9, 79.7, 238, @ahora - INTERVAL 16 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:4D:5E:56')),
  (56.7, 5.79, 250.9, 19.9, 208, @ahora - INTERVAL 15 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:4D:5E:56')),
  (35.6, 9.79, 380.2, 24.9, 161, @ahora - INTERVAL 14 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:4D:5E:56')),
  (64.6, 8.82, 268.2, 3.4, 198, @ahora - INTERVAL 13 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:4D:5E:56')),
  (72.8, 5.86, 165.3, 3.8, 212, @ahora - INTERVAL 12 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:4D:5E:56')),
  (48.5, 6.39, 74.7, 30.5, 163, @ahora - INTERVAL 11 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:4D:5E:56')),
  (70.0, 10.11, 396.0, 43.9, 225, @ahora - INTERVAL 10 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:4D:5E:56')),
  (78.8, 10.45, 84.7, 4.8, 229, @ahora - INTERVAL 9 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:4D:5E:56')),
  (30.8, 8.88, 101.0, 34.5, 158, @ahora - INTERVAL 8 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:4D:5E:56')),
  (24.8, 8.9, 324.7, 21.0, 160, @ahora - INTERVAL 7 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:4D:5E:56')),
  (54.7, 9.75, 141.5, 34.0, 234, @ahora - INTERVAL 6 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:4D:5E:56')),
  (44.2, 9.69, 205.3, 47.0, 166, @ahora - INTERVAL 5 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:4D:5E:56')),
  (50.4, 9.79, 331.5, 64.0, 211, @ahora - INTERVAL 4 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:4D:5E:56')),
  (43.9, 6.0, 340.7, 18.2, 159, @ahora - INTERVAL 3 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:4D:5E:56')),
  (17.4, 5.64, 373.7, 54.2, 183, @ahora - INTERVAL 2 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:4D:5E:56')),
  (52.7, 6.51, 122.9, 15.5, 236, @ahora - INTERVAL 1 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:4D:5E:56'));
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES (15.3, 7.69, 390.1, 29.6, 231, (SELECT ultima_senal FROM equipo WHERE direccion_mac = '02:5E:01:4D:5E:56'), (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:4D:5E:56'));
INSERT INTO almacenamiento (punto_montaje, capacidad_total_gb, espacio_libre_gb, id_informe) VALUES ('C:', 512, 147.5, LAST_INSERT_ID());
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES
  (51.4, 10.74, 283.4, 67.9, 162, @ahora - INTERVAL 24 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:72:6B:57')),
  (43.3, 7.71, 348.1, 34.7, 193, @ahora - INTERVAL 23 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:72:6B:57')),
  (12.0, 5.93, 158.0, 44.6, 166, @ahora - INTERVAL 22 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:72:6B:57')),
  (54.5, 9.45, 223.1, 2.9, 234, @ahora - INTERVAL 21 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:72:6B:57')),
  (42.5, 7.55, 137.5, 17.7, 159, @ahora - INTERVAL 20 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:72:6B:57')),
  (8.3, 6.71, 391.7, 26.1, 232, @ahora - INTERVAL 19 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:72:6B:57')),
  (44.5, 10.02, 69.7, 61.7, 253, @ahora - INTERVAL 18 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:72:6B:57')),
  (27.6, 8.32, 117.6, 38.8, 171, @ahora - INTERVAL 17 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:72:6B:57')),
  (40.4, 9.45, 347.3, 69.9, 151, @ahora - INTERVAL 16 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:72:6B:57')),
  (45.8, 10.1, 198.9, 43.8, 259, @ahora - INTERVAL 15 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:72:6B:57')),
  (50.1, 7.66, 362.4, 9.6, 140, @ahora - INTERVAL 14 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:72:6B:57')),
  (73.2, 10.0, 143.4, 66.1, 217, @ahora - INTERVAL 13 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:72:6B:57')),
  (70.8, 6.03, 121.0, 60.5, 252, @ahora - INTERVAL 12 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:72:6B:57')),
  (48.7, 7.06, 294.4, 79.1, 254, @ahora - INTERVAL 11 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:72:6B:57')),
  (51.9, 9.87, 139.9, 18.6, 146, @ahora - INTERVAL 10 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:72:6B:57')),
  (54.1, 6.87, 48.9, 69.3, 199, @ahora - INTERVAL 9 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:72:6B:57')),
  (38.9, 11.05, 115.9, 33.3, 141, @ahora - INTERVAL 8 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:72:6B:57')),
  (40.0, 9.4, 74.6, 47.5, 190, @ahora - INTERVAL 7 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:72:6B:57')),
  (9.8, 7.33, 43.4, 56.2, 165, @ahora - INTERVAL 6 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:72:6B:57')),
  (10.0, 9.27, 14.2, 7.2, 249, @ahora - INTERVAL 5 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:72:6B:57')),
  (23.4, 9.29, 147.8, 54.6, 233, @ahora - INTERVAL 4 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:72:6B:57')),
  (16.9, 6.86, 287.5, 34.8, 219, @ahora - INTERVAL 3 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:72:6B:57')),
  (27.9, 6.94, 35.7, 47.1, 189, @ahora - INTERVAL 2 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:72:6B:57')),
  (11.2, 10.07, 351.1, 2.2, 257, @ahora - INTERVAL 1 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:72:6B:57'));
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES (25.2, 9.19, 285.9, 45.5, 253, (SELECT ultima_senal FROM equipo WHERE direccion_mac = '02:5E:01:72:6B:57'), (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:72:6B:57'));
INSERT INTO almacenamiento (punto_montaje, capacidad_total_gb, espacio_libre_gb, id_informe) VALUES ('C:', 1000, 618.5, LAST_INSERT_ID());
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES
  (11.9, 10.17, 108.8, 17.8, 256, @ahora - INTERVAL 24 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:97:78:58')),
  (9.2, 6.75, 45.9, 63.0, 153, @ahora - INTERVAL 23 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:97:78:58')),
  (49.1, 11.0, 149.5, 61.5, 232, @ahora - INTERVAL 22 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:97:78:58')),
  (19.9, 11.16, 63.2, 55.9, 234, @ahora - INTERVAL 21 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:97:78:58')),
  (16.0, 11.06, 108.8, 72.8, 248, @ahora - INTERVAL 20 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:97:78:58')),
  (34.3, 7.48, 281.3, 66.1, 236, @ahora - INTERVAL 19 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:97:78:58')),
  (36.3, 8.22, 195.3, 35.1, 213, @ahora - INTERVAL 18 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:97:78:58')),
  (29.6, 9.87, 107.2, 57.9, 154, @ahora - INTERVAL 17 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:97:78:58')),
  (26.9, 7.27, 219.0, 7.8, 171, @ahora - INTERVAL 16 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:97:78:58')),
  (63.8, 9.07, 152.9, 33.9, 196, @ahora - INTERVAL 15 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:97:78:58')),
  (72.1, 8.13, 165.1, 13.4, 165, @ahora - INTERVAL 14 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:97:78:58')),
  (62.3, 5.85, 331.6, 37.1, 219, @ahora - INTERVAL 13 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:97:78:58')),
  (45.9, 5.66, 368.9, 8.7, 236, @ahora - INTERVAL 12 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:97:78:58')),
  (79.2, 7.1, 34.0, 71.3, 159, @ahora - INTERVAL 11 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:97:78:58')),
  (53.3, 10.83, 269.5, 64.4, 201, @ahora - INTERVAL 10 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:97:78:58')),
  (49.5, 8.7, 36.6, 8.2, 221, @ahora - INTERVAL 9 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:97:78:58')),
  (28.8, 7.65, 381.2, 18.1, 243, @ahora - INTERVAL 8 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:97:78:58')),
  (41.6, 7.3, 274.3, 53.5, 248, @ahora - INTERVAL 7 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:97:78:58')),
  (21.8, 8.45, 136.9, 64.6, 161, @ahora - INTERVAL 6 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:97:78:58')),
  (26.4, 10.39, 212.4, 37.2, 212, @ahora - INTERVAL 5 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:97:78:58')),
  (23.8, 7.4, 96.5, 55.4, 198, @ahora - INTERVAL 4 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:97:78:58')),
  (28.0, 5.81, 187.2, 79.9, 255, @ahora - INTERVAL 3 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:97:78:58')),
  (18.6, 10.21, 25.2, 54.3, 168, @ahora - INTERVAL 2 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:97:78:58')),
  (33.5, 6.13, 10.0, 75.2, 222, @ahora - INTERVAL 1 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:97:78:58'));
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES (31.8, 9.91, 9.1, 75.7, 248, (SELECT ultima_senal FROM equipo WHERE direccion_mac = '02:5E:01:97:78:58'), (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:97:78:58'));
INSERT INTO almacenamiento (punto_montaje, capacidad_total_gb, espacio_libre_gb, id_informe) VALUES ('C:', 256, 126.0, LAST_INSERT_ID());
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES
  (8.0, 18.97, 304.5, 63.5, 150, @ahora - INTERVAL 24 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:BC:85:59')),
  (29.1, 16.74, 211.2, 59.2, 171, @ahora - INTERVAL 23 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:BC:85:59')),
  (13.5, 14.89, 75.7, 74.9, 250, @ahora - INTERVAL 22 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:BC:85:59')),
  (30.1, 14.01, 261.8, 32.0, 252, @ahora - INTERVAL 21 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:BC:85:59')),
  (28.2, 22.34, 306.3, 37.2, 252, @ahora - INTERVAL 20 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:BC:85:59')),
  (8.7, 22.07, 125.2, 79.9, 160, @ahora - INTERVAL 19 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:BC:85:59')),
  (20.9, 11.27, 26.4, 36.9, 237, @ahora - INTERVAL 18 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:BC:85:59')),
  (24.1, 15.03, 127.7, 49.7, 171, @ahora - INTERVAL 17 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:BC:85:59')),
  (19.3, 20.95, 147.7, 29.9, 168, @ahora - INTERVAL 16 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:BC:85:59')),
  (58.5, 19.67, 191.1, 52.7, 209, @ahora - INTERVAL 15 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:BC:85:59')),
  (56.8, 19.05, 267.7, 79.4, 205, @ahora - INTERVAL 14 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:BC:85:59')),
  (72.2, 12.6, 146.4, 7.7, 166, @ahora - INTERVAL 13 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:BC:85:59')),
  (49.0, 14.4, 191.5, 71.5, 206, @ahora - INTERVAL 12 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:BC:85:59')),
  (56.8, 20.95, 152.6, 12.6, 231, @ahora - INTERVAL 11 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:BC:85:59')),
  (52.2, 14.72, 155.0, 34.4, 260, @ahora - INTERVAL 10 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:BC:85:59')),
  (75.9, 13.98, 38.8, 12.1, 241, @ahora - INTERVAL 9 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:BC:85:59')),
  (9.7, 21.16, 352.6, 4.8, 251, @ahora - INTERVAL 8 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:BC:85:59')),
  (33.3, 11.66, 335.8, 12.0, 190, @ahora - INTERVAL 7 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:BC:85:59')),
  (24.5, 20.58, 268.4, 36.2, 151, @ahora - INTERVAL 6 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:BC:85:59')),
  (29.4, 12.54, 217.0, 78.3, 247, @ahora - INTERVAL 5 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:BC:85:59')),
  (34.7, 18.94, 204.1, 56.4, 216, @ahora - INTERVAL 4 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:BC:85:59')),
  (14.2, 20.9, 361.4, 15.3, 163, @ahora - INTERVAL 3 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:BC:85:59')),
  (33.7, 20.67, 90.1, 13.1, 225, @ahora - INTERVAL 2 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:BC:85:59')),
  (32.7, 17.53, 395.4, 1.6, 245, @ahora - INTERVAL 1 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:BC:85:59'));
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES (18.7, 11.21, 338.5, 53.1, 158, (SELECT ultima_senal FROM equipo WHERE direccion_mac = '02:5E:01:BC:85:59'), (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:BC:85:59'));
INSERT INTO almacenamiento (punto_montaje, capacidad_total_gb, espacio_libre_gb, id_informe) VALUES ('C:', 512, 215.5, LAST_INSERT_ID());
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES
  (43.3, 5.42, 200.4, 26.7, 221, @ahora - INTERVAL 24 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:E1:92:5A')),
  (41.9, 5.03, 34.2, 59.4, 154, @ahora - INTERVAL 23 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:E1:92:5A')),
  (23.4, 4.89, 323.5, 69.0, 186, @ahora - INTERVAL 22 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:E1:92:5A')),
  (32.6, 3.45, 23.6, 44.5, 172, @ahora - INTERVAL 21 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:E1:92:5A')),
  (40.6, 5.12, 371.4, 26.7, 234, @ahora - INTERVAL 20 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:E1:92:5A')),
  (43.2, 2.98, 330.0, 73.9, 142, @ahora - INTERVAL 19 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:E1:92:5A')),
  (52.7, 4.06, 36.5, 54.0, 141, @ahora - INTERVAL 18 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:E1:92:5A')),
  (16.1, 3.34, 386.6, 70.6, 167, @ahora - INTERVAL 17 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:E1:92:5A')),
  (42.6, 4.46, 23.3, 9.9, 166, @ahora - INTERVAL 16 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:E1:92:5A')),
  (46.4, 5.25, 95.9, 78.6, 244, @ahora - INTERVAL 15 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:E1:92:5A')),
  (40.3, 3.98, 160.5, 47.6, 218, @ahora - INTERVAL 14 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:E1:92:5A')),
  (48.6, 5.19, 242.3, 37.0, 232, @ahora - INTERVAL 13 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:E1:92:5A')),
  (52.4, 4.75, 239.8, 44.4, 245, @ahora - INTERVAL 12 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:E1:92:5A')),
  (79.8, 3.36, 172.7, 31.5, 190, @ahora - INTERVAL 11 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:E1:92:5A')),
  (77.3, 3.39, 316.3, 44.1, 173, @ahora - INTERVAL 10 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:E1:92:5A')),
  (57.1, 5.18, 37.6, 70.2, 252, @ahora - INTERVAL 9 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:E1:92:5A')),
  (49.9, 4.24, 248.1, 17.7, 209, @ahora - INTERVAL 8 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:E1:92:5A')),
  (43.4, 3.19, 26.0, 35.6, 222, @ahora - INTERVAL 7 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:E1:92:5A')),
  (28.1, 4.37, 131.3, 68.5, 256, @ahora - INTERVAL 6 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:E1:92:5A')),
  (34.8, 2.96, 230.1, 22.4, 177, @ahora - INTERVAL 5 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:E1:92:5A')),
  (31.9, 2.87, 82.5, 60.0, 172, @ahora - INTERVAL 4 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:E1:92:5A')),
  (8.0, 4.24, 222.0, 21.7, 146, @ahora - INTERVAL 3 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:E1:92:5A')),
  (44.0, 3.43, 392.7, 66.8, 154, @ahora - INTERVAL 2 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:E1:92:5A')),
  (51.4, 3.36, 206.0, 62.5, 182, @ahora - INTERVAL 1 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:E1:92:5A'));
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES (38.6, 4.42, 365.4, 14.8, 217, (SELECT ultima_senal FROM equipo WHERE direccion_mac = '02:5E:01:E1:92:5A'), (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:01:E1:92:5A'));
INSERT INTO almacenamiento (punto_montaje, capacidad_total_gb, espacio_libre_gb, id_informe) VALUES ('C:', 512, 234.3, LAST_INSERT_ID());
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES
  (14.5, 3.82, 171.3, 41.5, 210, @ahora - INTERVAL 24 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:00:9F:5B')),
  (19.4, 3.91, 251.2, 59.2, 155, @ahora - INTERVAL 23 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:00:9F:5B')),
  (31.8, 4.17, 339.2, 64.1, 188, @ahora - INTERVAL 22 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:00:9F:5B')),
  (48.9, 3.58, 113.4, 47.5, 238, @ahora - INTERVAL 21 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:00:9F:5B')),
  (47.5, 3.36, 394.0, 15.0, 183, @ahora - INTERVAL 20 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:00:9F:5B')),
  (34.2, 4.83, 12.2, 9.5, 205, @ahora - INTERVAL 19 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:00:9F:5B')),
  (19.7, 3.11, 201.8, 50.1, 142, @ahora - INTERVAL 18 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:00:9F:5B')),
  (13.0, 5.25, 215.8, 79.9, 208, @ahora - INTERVAL 17 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:00:9F:5B')),
  (42.9, 3.98, 165.6, 36.1, 251, @ahora - INTERVAL 16 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:00:9F:5B')),
  (41.4, 4.52, 336.2, 17.3, 145, @ahora - INTERVAL 15 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:00:9F:5B')),
  (63.5, 4.43, 53.7, 55.1, 240, @ahora - INTERVAL 14 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:00:9F:5B')),
  (59.4, 4.74, 8.5, 17.7, 172, @ahora - INTERVAL 13 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:00:9F:5B')),
  (50.3, 3.45, 301.7, 77.8, 192, @ahora - INTERVAL 12 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:00:9F:5B')),
  (46.1, 4.54, 316.5, 22.7, 158, @ahora - INTERVAL 11 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:00:9F:5B')),
  (45.3, 5.32, 268.4, 52.0, 166, @ahora - INTERVAL 10 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:00:9F:5B')),
  (35.8, 4.37, 73.3, 40.4, 219, @ahora - INTERVAL 9 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:00:9F:5B')),
  (51.0, 3.38, 49.5, 14.8, 201, @ahora - INTERVAL 8 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:00:9F:5B')),
  (34.8, 3.18, 333.1, 24.1, 185, @ahora - INTERVAL 7 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:00:9F:5B')),
  (13.0, 4.37, 79.5, 68.0, 145, @ahora - INTERVAL 6 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:00:9F:5B')),
  (40.2, 5.03, 398.5, 52.7, 213, @ahora - INTERVAL 5 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:00:9F:5B')),
  (18.3, 3.63, 324.4, 40.5, 231, @ahora - INTERVAL 4 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:00:9F:5B')),
  (17.3, 3.56, 371.2, 44.0, 242, @ahora - INTERVAL 3 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:00:9F:5B')),
  (25.8, 4.58, 205.3, 54.4, 150, @ahora - INTERVAL 2 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:00:9F:5B')),
  (44.0, 4.91, 96.8, 31.8, 154, @ahora - INTERVAL 1 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:00:9F:5B'));
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES (30.7, 3.18, 339.2, 60.8, 202, (SELECT ultima_senal FROM equipo WHERE direccion_mac = '02:5E:1A:00:9F:5B'), (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:00:9F:5B'));
INSERT INTO almacenamiento (punto_montaje, capacidad_total_gb, espacio_libre_gb, id_informe) VALUES ('C:', 1000, 622.6, LAST_INSERT_ID());
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES
  (46.4, 7.58, 198.5, 29.1, 181, @ahora - INTERVAL 24 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:25:AC:5C')),
  (53.6, 9.54, 29.4, 68.0, 208, @ahora - INTERVAL 23 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:25:AC:5C')),
  (43.3, 7.38, 328.7, 60.5, 208, @ahora - INTERVAL 22 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:25:AC:5C')),
  (20.8, 6.35, 206.0, 7.2, 166, @ahora - INTERVAL 21 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:25:AC:5C')),
  (52.1, 6.24, 339.2, 21.5, 221, @ahora - INTERVAL 20 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:25:AC:5C')),
  (20.5, 7.59, 182.6, 5.3, 187, @ahora - INTERVAL 19 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:25:AC:5C')),
  (45.4, 7.15, 194.4, 40.5, 198, @ahora - INTERVAL 18 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:25:AC:5C')),
  (22.2, 8.64, 35.6, 16.3, 196, @ahora - INTERVAL 17 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:25:AC:5C')),
  (15.2, 6.31, 32.9, 20.7, 190, @ahora - INTERVAL 16 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:25:AC:5C')),
  (37.9, 6.54, 344.8, 13.1, 208, @ahora - INTERVAL 15 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:25:AC:5C')),
  (43.5, 7.13, 22.6, 71.4, 158, @ahora - INTERVAL 14 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:25:AC:5C')),
  (35.5, 6.57, 382.9, 69.2, 199, @ahora - INTERVAL 13 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:25:AC:5C')),
  (44.1, 7.26, 158.7, 36.7, 161, @ahora - INTERVAL 12 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:25:AC:5C')),
  (34.8, 9.9, 291.0, 33.4, 143, @ahora - INTERVAL 11 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:25:AC:5C')),
  (76.5, 6.59, 382.4, 55.8, 149, @ahora - INTERVAL 10 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:25:AC:5C')),
  (66.2, 8.33, 233.2, 41.8, 237, @ahora - INTERVAL 9 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:25:AC:5C')),
  (34.4, 7.57, 153.9, 25.1, 213, @ahora - INTERVAL 8 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:25:AC:5C')),
  (47.5, 7.04, 90.8, 14.0, 153, @ahora - INTERVAL 7 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:25:AC:5C')),
  (48.7, 9.86, 177.8, 67.9, 182, @ahora - INTERVAL 6 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:25:AC:5C')),
  (9.2, 9.79, 129.7, 17.7, 218, @ahora - INTERVAL 5 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:25:AC:5C')),
  (41.3, 6.72, 127.8, 45.4, 228, @ahora - INTERVAL 4 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:25:AC:5C')),
  (35.5, 8.7, 84.3, 2.7, 191, @ahora - INTERVAL 3 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:25:AC:5C')),
  (44.4, 7.49, 184.9, 49.4, 251, @ahora - INTERVAL 2 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:25:AC:5C')),
  (44.6, 7.62, 381.8, 56.0, 195, @ahora - INTERVAL 1 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:25:AC:5C'));
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES (48.2, 8.46, 151.3, 32.4, 239, (SELECT ultima_senal FROM equipo WHERE direccion_mac = '02:5E:1A:25:AC:5C'), (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:25:AC:5C'));
INSERT INTO almacenamiento (punto_montaje, capacidad_total_gb, espacio_libre_gb, id_informe) VALUES ('C:', 256, 90.5, LAST_INSERT_ID());
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES
  (10.5, 8.84, 396.2, 56.8, 259, @ahora - INTERVAL 24 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:4A:B9:5D')),
  (30.1, 7.51, 27.2, 22.7, 167, @ahora - INTERVAL 23 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:4A:B9:5D')),
  (53.1, 7.4, 207.2, 58.6, 243, @ahora - INTERVAL 22 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:4A:B9:5D')),
  (54.8, 9.91, 159.4, 53.0, 257, @ahora - INTERVAL 21 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:4A:B9:5D')),
  (18.2, 5.93, 141.3, 34.0, 233, @ahora - INTERVAL 20 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:4A:B9:5D')),
  (17.0, 6.23, 382.9, 43.2, 167, @ahora - INTERVAL 19 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:4A:B9:5D')),
  (36.4, 5.97, 229.9, 38.5, 234, @ahora - INTERVAL 18 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:4A:B9:5D')),
  (43.0, 8.98, 324.0, 30.0, 197, @ahora - INTERVAL 17 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:4A:B9:5D')),
  (33.4, 9.17, 166.2, 35.1, 248, @ahora - INTERVAL 16 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:4A:B9:5D')),
  (38.3, 7.23, 370.9, 18.5, 250, @ahora - INTERVAL 15 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:4A:B9:5D')),
  (45.8, 6.53, 75.8, 32.8, 149, @ahora - INTERVAL 14 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:4A:B9:5D')),
  (54.0, 10.4, 185.1, 63.0, 193, @ahora - INTERVAL 13 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:4A:B9:5D')),
  (64.9, 6.61, 312.9, 56.7, 238, @ahora - INTERVAL 12 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:4A:B9:5D')),
  (51.0, 10.17, 192.0, 28.2, 142, @ahora - INTERVAL 11 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:4A:B9:5D')),
  (71.2, 6.89, 186.7, 73.7, 226, @ahora - INTERVAL 10 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:4A:B9:5D')),
  (33.3, 11.18, 292.2, 56.7, 241, @ahora - INTERVAL 9 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:4A:B9:5D')),
  (52.0, 8.33, 288.7, 44.1, 233, @ahora - INTERVAL 8 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:4A:B9:5D')),
  (11.5, 6.66, 112.4, 18.2, 217, @ahora - INTERVAL 7 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:4A:B9:5D')),
  (51.6, 5.72, 86.4, 20.7, 201, @ahora - INTERVAL 6 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:4A:B9:5D')),
  (36.0, 9.14, 236.3, 44.2, 155, @ahora - INTERVAL 5 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:4A:B9:5D')),
  (43.7, 9.74, 307.6, 3.1, 199, @ahora - INTERVAL 4 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:4A:B9:5D')),
  (10.0, 10.76, 137.6, 25.3, 242, @ahora - INTERVAL 3 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:4A:B9:5D')),
  (26.3, 7.18, 136.9, 3.4, 204, @ahora - INTERVAL 2 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:4A:B9:5D')),
  (36.0, 8.38, 325.8, 14.5, 252, @ahora - INTERVAL 1 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:4A:B9:5D'));
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES (15.2, 8.92, 191.1, 27.7, 171, (SELECT ultima_senal FROM equipo WHERE direccion_mac = '02:5E:1A:4A:B9:5D'), (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:4A:B9:5D'));
INSERT INTO almacenamiento (punto_montaje, capacidad_total_gb, espacio_libre_gb, id_informe) VALUES ('C:', 512, 311.2, LAST_INSERT_ID());
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES (37.8, 5.65, 86.4, 16.0, 238, (SELECT ultima_senal FROM equipo WHERE direccion_mac = '02:5E:1A:6F:C6:5E'), (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:6F:C6:5E'));
INSERT INTO almacenamiento (punto_montaje, capacidad_total_gb, espacio_libre_gb, id_informe) VALUES ('C:', 512, 315.3, LAST_INSERT_ID());
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES (17.1, 16.59, 224.9, 27.9, 181, (SELECT ultima_senal FROM equipo WHERE direccion_mac = '02:5E:1A:94:D3:5F'), (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:94:D3:5F'));
INSERT INTO almacenamiento (punto_montaje, capacidad_total_gb, espacio_libre_gb, id_informe) VALUES ('C:', 1000, 316.3, LAST_INSERT_ID());
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES (53.0, 2.82, 308.5, 75.7, 226, (SELECT ultima_senal FROM equipo WHERE direccion_mac = '02:5E:1A:B9:E0:60'), (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:B9:E0:60'));
INSERT INTO almacenamiento (punto_montaje, capacidad_total_gb, espacio_libre_gb, id_informe) VALUES ('C:', 256, 71.7, LAST_INSERT_ID());
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES
  (39.7, 2.82, 159.1, 79.5, 217, @ahora - INTERVAL 24 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:DE:ED:61')),
  (38.5, 5.57, 73.9, 69.5, 140, @ahora - INTERVAL 23 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:DE:ED:61')),
  (29.5, 4.8, 88.7, 14.8, 224, @ahora - INTERVAL 22 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:DE:ED:61')),
  (37.6, 4.7, 304.5, 50.8, 143, @ahora - INTERVAL 21 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:DE:ED:61')),
  (8.8, 2.89, 298.5, 62.6, 155, @ahora - INTERVAL 20 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:DE:ED:61')),
  (27.5, 4.17, 272.9, 68.2, 236, @ahora - INTERVAL 19 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:DE:ED:61')),
  (44.4, 3.22, 345.3, 66.1, 180, @ahora - INTERVAL 18 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:DE:ED:61')),
  (38.0, 2.84, 76.3, 9.7, 183, @ahora - INTERVAL 17 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:DE:ED:61')),
  (30.9, 4.83, 335.2, 59.9, 194, @ahora - INTERVAL 16 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:DE:ED:61')),
  (60.6, 4.29, 155.7, 45.4, 236, @ahora - INTERVAL 15 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:DE:ED:61')),
  (47.7, 3.22, 65.5, 69.8, 170, @ahora - INTERVAL 14 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:DE:ED:61')),
  (35.5, 2.9, 100.8, 64.7, 152, @ahora - INTERVAL 13 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:DE:ED:61')),
  (55.9, 5.14, 388.5, 29.7, 200, @ahora - INTERVAL 12 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:DE:ED:61')),
  (34.7, 3.22, 142.8, 42.5, 243, @ahora - INTERVAL 11 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:DE:ED:61')),
  (79.6, 3.09, 276.7, 32.4, 259, @ahora - INTERVAL 10 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:DE:ED:61')),
  (75.1, 3.5, 29.1, 9.3, 216, @ahora - INTERVAL 9 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:DE:ED:61')),
  (19.7, 4.09, 75.5, 20.1, 171, @ahora - INTERVAL 8 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:DE:ED:61')),
  (24.1, 4.62, 26.9, 12.2, 159, @ahora - INTERVAL 7 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:DE:ED:61')),
  (34.4, 5.29, 46.4, 37.0, 248, @ahora - INTERVAL 6 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:DE:ED:61')),
  (31.3, 3.23, 387.0, 17.1, 252, @ahora - INTERVAL 5 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:DE:ED:61')),
  (37.4, 4.02, 383.4, 39.8, 181, @ahora - INTERVAL 4 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:DE:ED:61')),
  (23.2, 5.33, 72.0, 60.5, 166, @ahora - INTERVAL 3 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:DE:ED:61')),
  (38.5, 4.18, 272.5, 65.2, 252, @ahora - INTERVAL 2 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:DE:ED:61')),
  (25.2, 3.64, 199.7, 24.6, 252, @ahora - INTERVAL 1 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:DE:ED:61'));
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES (36.3, 7.55, 229.5, 36.0, 238, (SELECT ultima_senal FROM equipo WHERE direccion_mac = '02:5E:1A:DE:ED:61'), (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:DE:ED:61'));
INSERT INTO almacenamiento (punto_montaje, capacidad_total_gb, espacio_libre_gb, id_informe) VALUES ('C:', 512, 25.8, LAST_INSERT_ID());
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES
  (20.4, 6.33, 223.7, 11.5, 161, @ahora - INTERVAL 24 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:03:FA:62')),
  (8.3, 5.68, 355.2, 40.2, 236, @ahora - INTERVAL 23 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:03:FA:62')),
  (19.5, 6.68, 368.7, 16.7, 222, @ahora - INTERVAL 22 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:03:FA:62')),
  (47.6, 8.86, 319.8, 41.2, 258, @ahora - INTERVAL 21 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:03:FA:62')),
  (26.6, 10.25, 154.5, 72.2, 219, @ahora - INTERVAL 20 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:03:FA:62')),
  (13.5, 9.51, 306.0, 69.5, 190, @ahora - INTERVAL 19 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:03:FA:62')),
  (51.8, 10.24, 271.3, 57.9, 165, @ahora - INTERVAL 18 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:03:FA:62')),
  (46.3, 5.91, 243.5, 26.6, 239, @ahora - INTERVAL 17 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:03:FA:62')),
  (12.3, 6.76, 188.8, 54.8, 250, @ahora - INTERVAL 16 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:03:FA:62')),
  (66.6, 10.07, 390.4, 67.1, 181, @ahora - INTERVAL 15 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:03:FA:62')),
  (71.2, 8.3, 244.5, 37.9, 207, @ahora - INTERVAL 14 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:03:FA:62')),
  (52.7, 8.57, 101.2, 44.7, 240, @ahora - INTERVAL 13 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:03:FA:62')),
  (37.9, 7.91, 209.7, 48.5, 232, @ahora - INTERVAL 12 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:03:FA:62')),
  (49.8, 8.94, 371.0, 74.6, 222, @ahora - INTERVAL 11 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:03:FA:62')),
  (76.8, 10.79, 100.6, 50.4, 256, @ahora - INTERVAL 10 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:03:FA:62')),
  (46.1, 6.65, 71.6, 13.7, 204, @ahora - INTERVAL 9 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:03:FA:62')),
  (17.4, 10.86, 385.0, 23.6, 247, @ahora - INTERVAL 8 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:03:FA:62')),
  (41.2, 10.12, 145.7, 62.1, 256, @ahora - INTERVAL 7 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:03:FA:62')),
  (52.0, 6.97, 381.4, 49.3, 178, @ahora - INTERVAL 6 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:03:FA:62')),
  (55.0, 9.13, 363.8, 26.2, 194, @ahora - INTERVAL 5 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:03:FA:62')),
  (30.6, 7.29, 142.7, 10.3, 258, @ahora - INTERVAL 4 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:03:FA:62')),
  (30.2, 7.52, 210.9, 43.5, 158, @ahora - INTERVAL 3 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:03:FA:62')),
  (16.5, 10.01, 126.1, 44.6, 218, @ahora - INTERVAL 2 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:03:FA:62')),
  (48.5, 7.34, 51.6, 25.1, 158, @ahora - INTERVAL 1 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:03:FA:62'));
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES (97.8, 11.09, 197.4, 18.6, 180, (SELECT ultima_senal FROM equipo WHERE direccion_mac = '02:5E:1A:03:FA:62'), (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:03:FA:62'));
INSERT INTO almacenamiento (punto_montaje, capacidad_total_gb, espacio_libre_gb, id_informe) VALUES ('C:', 512, 37.2, LAST_INSERT_ID());
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES
  (8.3, 7.0, 235.9, 34.7, 158, @ahora - INTERVAL 24 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:4D:14:64')),
  (38.2, 8.02, 23.9, 56.8, 258, @ahora - INTERVAL 23 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:4D:14:64')),
  (27.3, 6.68, 259.6, 50.4, 186, @ahora - INTERVAL 22 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:4D:14:64')),
  (41.2, 10.59, 65.0, 20.6, 213, @ahora - INTERVAL 21 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:4D:14:64')),
  (33.5, 10.23, 44.1, 49.7, 144, @ahora - INTERVAL 20 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:4D:14:64')),
  (17.8, 6.02, 290.9, 51.9, 147, @ahora - INTERVAL 19 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:4D:14:64')),
  (22.3, 8.97, 274.3, 7.9, 216, @ahora - INTERVAL 18 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:4D:14:64')),
  (53.7, 9.86, 271.1, 66.4, 158, @ahora - INTERVAL 17 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:4D:14:64')),
  (43.0, 9.54, 373.5, 48.9, 257, @ahora - INTERVAL 16 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:4D:14:64')),
  (37.9, 10.71, 288.6, 22.0, 234, @ahora - INTERVAL 15 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:4D:14:64')),
  (48.1, 5.66, 287.5, 17.8, 187, @ahora - INTERVAL 14 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:4D:14:64')),
  (69.5, 9.39, 246.7, 36.9, 173, @ahora - INTERVAL 13 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:4D:14:64')),
  (67.7, 9.96, 337.6, 16.3, 257, @ahora - INTERVAL 12 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:4D:14:64')),
  (45.2, 7.5, 379.1, 51.8, 217, @ahora - INTERVAL 11 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:4D:14:64')),
  (66.9, 9.46, 82.5, 44.8, 241, @ahora - INTERVAL 10 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:4D:14:64')),
  (38.9, 6.74, 255.2, 42.8, 149, @ahora - INTERVAL 9 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:4D:14:64')),
  (17.6, 10.78, 205.6, 53.7, 207, @ahora - INTERVAL 8 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:4D:14:64')),
  (50.2, 6.02, 301.9, 40.0, 260, @ahora - INTERVAL 7 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:4D:14:64')),
  (24.6, 9.67, 262.8, 47.2, 211, @ahora - INTERVAL 6 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:4D:14:64')),
  (9.1, 6.38, 31.4, 15.4, 214, @ahora - INTERVAL 5 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:4D:14:64')),
  (13.6, 6.69, 129.3, 22.4, 242, @ahora - INTERVAL 4 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:4D:14:64')),
  (30.8, 10.66, 206.7, 28.8, 144, @ahora - INTERVAL 3 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:4D:14:64')),
  (12.5, 8.71, 139.2, 55.1, 157, @ahora - INTERVAL 2 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:4D:14:64')),
  (43.7, 10.42, 253.9, 74.4, 198, @ahora - INTERVAL 1 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:4D:14:64'));
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES (36.7, 7.57, 266.8, 32.3, 215, (SELECT ultima_senal FROM equipo WHERE direccion_mac = '02:5E:1A:4D:14:64'), (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:1A:4D:14:64'));
INSERT INTO almacenamiento (punto_montaje, capacidad_total_gb, espacio_libre_gb, id_informe) VALUES ('C:', 256, 85.8, LAST_INSERT_ID());
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES
  (33.6, 19.7, 214.8, 44.4, 254, @ahora - INTERVAL 24 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:00:21:65')),
  (44.3, 17.82, 224.7, 34.0, 178, @ahora - INTERVAL 23 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:00:21:65')),
  (48.8, 18.14, 265.7, 77.7, 252, @ahora - INTERVAL 22 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:00:21:65')),
  (47.1, 17.45, 230.0, 15.5, 187, @ahora - INTERVAL 21 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:00:21:65')),
  (26.1, 14.72, 129.5, 71.6, 190, @ahora - INTERVAL 20 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:00:21:65')),
  (37.6, 21.39, 32.7, 23.1, 187, @ahora - INTERVAL 19 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:00:21:65')),
  (46.0, 19.66, 379.0, 36.6, 143, @ahora - INTERVAL 18 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:00:21:65')),
  (41.8, 21.9, 252.8, 17.1, 255, @ahora - INTERVAL 17 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:00:21:65')),
  (35.8, 15.86, 318.6, 58.2, 150, @ahora - INTERVAL 16 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:00:21:65')),
  (53.9, 19.12, 370.4, 74.3, 202, @ahora - INTERVAL 15 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:00:21:65')),
  (34.9, 17.19, 334.5, 68.6, 203, @ahora - INTERVAL 14 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:00:21:65')),
  (35.9, 11.2, 282.8, 69.7, 202, @ahora - INTERVAL 13 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:00:21:65')),
  (75.4, 21.49, 85.8, 75.5, 144, @ahora - INTERVAL 12 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:00:21:65')),
  (77.1, 12.52, 77.7, 14.6, 181, @ahora - INTERVAL 11 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:00:21:65')),
  (57.0, 18.7, 321.5, 64.8, 162, @ahora - INTERVAL 10 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:00:21:65')),
  (40.6, 16.17, 107.7, 31.2, 141, @ahora - INTERVAL 9 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:00:21:65')),
  (20.5, 20.42, 346.4, 40.3, 145, @ahora - INTERVAL 8 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:00:21:65')),
  (18.5, 20.58, 263.8, 64.2, 238, @ahora - INTERVAL 7 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:00:21:65')),
  (34.9, 17.23, 108.8, 14.6, 193, @ahora - INTERVAL 6 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:00:21:65')),
  (26.0, 16.3, 243.6, 24.9, 158, @ahora - INTERVAL 5 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:00:21:65')),
  (41.3, 16.76, 238.0, 39.4, 195, @ahora - INTERVAL 4 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:00:21:65')),
  (23.4, 12.15, 332.3, 46.6, 192, @ahora - INTERVAL 3 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:00:21:65')),
  (35.3, 11.39, 234.0, 11.5, 184, @ahora - INTERVAL 2 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:00:21:65')),
  (48.8, 14.04, 101.8, 22.1, 236, @ahora - INTERVAL 1 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:00:21:65'));
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES (47.4, 18.85, 319.1, 49.7, 197, (SELECT ultima_senal FROM equipo WHERE direccion_mac = '02:5E:15:00:21:65'), (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:00:21:65'));
INSERT INTO almacenamiento (punto_montaje, capacidad_total_gb, espacio_libre_gb, id_informe) VALUES ('C:', 512, 201.6, LAST_INSERT_ID());
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES
  (25.2, 4.57, 41.5, 35.5, 192, @ahora - INTERVAL 24 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:25:2E:66')),
  (48.5, 5.4, 58.3, 53.0, 194, @ahora - INTERVAL 23 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:25:2E:66')),
  (43.9, 4.62, 14.7, 39.0, 173, @ahora - INTERVAL 22 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:25:2E:66')),
  (50.3, 4.01, 55.1, 21.4, 260, @ahora - INTERVAL 21 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:25:2E:66')),
  (31.4, 4.79, 75.7, 47.9, 184, @ahora - INTERVAL 20 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:25:2E:66')),
  (39.9, 5.41, 53.8, 51.0, 145, @ahora - INTERVAL 19 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:25:2E:66')),
  (25.3, 3.33, 303.3, 37.4, 157, @ahora - INTERVAL 18 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:25:2E:66')),
  (34.1, 4.03, 390.6, 45.8, 235, @ahora - INTERVAL 17 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:25:2E:66')),
  (18.5, 3.04, 167.5, 69.3, 225, @ahora - INTERVAL 16 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:25:2E:66')),
  (47.6, 3.64, 342.5, 65.5, 238, @ahora - INTERVAL 15 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:25:2E:66')),
  (49.7, 4.88, 101.5, 6.3, 173, @ahora - INTERVAL 14 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:25:2E:66')),
  (44.8, 4.6, 34.4, 37.1, 165, @ahora - INTERVAL 13 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:25:2E:66')),
  (39.7, 3.56, 228.0, 40.6, 184, @ahora - INTERVAL 12 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:25:2E:66')),
  (74.0, 3.98, 47.7, 37.7, 246, @ahora - INTERVAL 11 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:25:2E:66')),
  (45.8, 5.59, 100.6, 69.3, 235, @ahora - INTERVAL 10 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:25:2E:66')),
  (38.7, 4.95, 195.4, 33.2, 166, @ahora - INTERVAL 9 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:25:2E:66')),
  (50.2, 4.56, 269.8, 57.7, 205, @ahora - INTERVAL 8 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:25:2E:66')),
  (23.2, 3.64, 167.5, 56.9, 196, @ahora - INTERVAL 7 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:25:2E:66')),
  (54.8, 3.35, 87.0, 25.6, 245, @ahora - INTERVAL 6 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:25:2E:66')),
  (27.9, 4.04, 329.3, 74.6, 244, @ahora - INTERVAL 5 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:25:2E:66')),
  (41.1, 2.85, 110.2, 17.1, 217, @ahora - INTERVAL 4 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:25:2E:66')),
  (30.1, 4.47, 18.6, 50.2, 242, @ahora - INTERVAL 3 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:25:2E:66')),
  (19.7, 3.77, 208.1, 70.0, 197, @ahora - INTERVAL 2 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:25:2E:66')),
  (41.5, 4.5, 61.3, 25.8, 220, @ahora - INTERVAL 1 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:25:2E:66'));
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES (42.9, 5.57, 243.7, 67.1, 200, (SELECT ultima_senal FROM equipo WHERE direccion_mac = '02:5E:15:25:2E:66'), (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:25:2E:66'));
INSERT INTO almacenamiento (punto_montaje, capacidad_total_gb, espacio_libre_gb, id_informe) VALUES ('C:', 512, 323.3, LAST_INSERT_ID());
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES
  (41.5, 3.19, 11.7, 79.7, 157, @ahora - INTERVAL 24 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:4A:3B:67')),
  (13.8, 3.45, 191.8, 67.9, 165, @ahora - INTERVAL 23 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:4A:3B:67')),
  (41.9, 4.8, 356.2, 32.1, 173, @ahora - INTERVAL 22 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:4A:3B:67')),
  (28.2, 2.83, 217.4, 60.8, 248, @ahora - INTERVAL 21 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:4A:3B:67')),
  (48.6, 4.23, 48.5, 13.2, 192, @ahora - INTERVAL 20 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:4A:3B:67')),
  (16.9, 4.95, 161.5, 48.1, 143, @ahora - INTERVAL 19 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:4A:3B:67')),
  (50.2, 4.68, 36.4, 32.6, 150, @ahora - INTERVAL 18 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:4A:3B:67')),
  (45.2, 3.56, 281.4, 27.7, 259, @ahora - INTERVAL 17 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:4A:3B:67')),
  (25.0, 3.7, 5.9, 43.4, 147, @ahora - INTERVAL 16 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:4A:3B:67')),
  (71.7, 3.4, 124.6, 16.8, 178, @ahora - INTERVAL 15 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:4A:3B:67')),
  (59.2, 2.81, 40.2, 18.6, 176, @ahora - INTERVAL 14 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:4A:3B:67')),
  (35.5, 5.1, 322.1, 41.1, 260, @ahora - INTERVAL 13 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:4A:3B:67')),
  (51.4, 3.06, 113.3, 73.1, 235, @ahora - INTERVAL 12 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:4A:3B:67')),
  (63.1, 4.7, 324.7, 78.1, 230, @ahora - INTERVAL 11 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:4A:3B:67')),
  (47.5, 3.38, 341.4, 42.2, 237, @ahora - INTERVAL 10 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:4A:3B:67')),
  (59.8, 4.6, 191.9, 52.6, 156, @ahora - INTERVAL 9 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:4A:3B:67')),
  (20.5, 3.9, 325.7, 43.6, 201, @ahora - INTERVAL 8 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:4A:3B:67')),
  (47.6, 3.37, 349.8, 15.9, 165, @ahora - INTERVAL 7 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:4A:3B:67')),
  (22.0, 3.64, 219.0, 63.8, 207, @ahora - INTERVAL 6 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:4A:3B:67')),
  (29.6, 4.64, 295.2, 23.6, 194, @ahora - INTERVAL 5 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:4A:3B:67')),
  (16.1, 3.19, 204.1, 28.9, 180, @ahora - INTERVAL 4 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:4A:3B:67')),
  (8.4, 3.55, 145.7, 10.1, 161, @ahora - INTERVAL 3 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:4A:3B:67')),
  (36.5, 4.86, 381.5, 50.3, 178, @ahora - INTERVAL 2 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:4A:3B:67')),
  (29.1, 4.46, 173.3, 67.9, 203, @ahora - INTERVAL 1 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:4A:3B:67'));
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES (20.0, 5.23, 318.6, 69.7, 174, (SELECT ultima_senal FROM equipo WHERE direccion_mac = '02:5E:15:4A:3B:67'), (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:4A:3B:67'));
INSERT INTO almacenamiento (punto_montaje, capacidad_total_gb, espacio_libre_gb, id_informe) VALUES ('C:', 1000, 636.7, LAST_INSERT_ID());
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES
  (22.8, 6.38, 242.1, 24.3, 188, @ahora - INTERVAL 24 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:6F:48:68')),
  (32.1, 8.45, 338.7, 42.4, 238, @ahora - INTERVAL 23 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:6F:48:68')),
  (11.7, 5.84, 260.2, 69.8, 214, @ahora - INTERVAL 22 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:6F:48:68')),
  (12.8, 6.92, 169.9, 62.0, 204, @ahora - INTERVAL 21 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:6F:48:68')),
  (25.2, 6.06, 200.6, 63.4, 150, @ahora - INTERVAL 20 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:6F:48:68')),
  (15.9, 9.47, 228.8, 11.5, 218, @ahora - INTERVAL 19 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:6F:48:68')),
  (26.0, 10.17, 193.1, 21.9, 224, @ahora - INTERVAL 18 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:6F:48:68')),
  (27.2, 10.23, 354.8, 4.4, 249, @ahora - INTERVAL 17 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:6F:48:68')),
  (42.9, 6.07, 371.9, 24.4, 184, @ahora - INTERVAL 16 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:6F:48:68')),
  (65.6, 9.66, 63.6, 44.7, 222, @ahora - INTERVAL 15 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:6F:48:68')),
  (70.5, 9.48, 105.9, 56.8, 225, @ahora - INTERVAL 14 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:6F:48:68')),
  (72.5, 6.11, 325.0, 46.9, 212, @ahora - INTERVAL 13 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:6F:48:68')),
  (43.1, 9.98, 371.5, 31.8, 156, @ahora - INTERVAL 12 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:6F:48:68')),
  (34.3, 5.68, 77.9, 23.9, 149, @ahora - INTERVAL 11 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:6F:48:68')),
  (55.2, 10.21, 62.7, 69.2, 260, @ahora - INTERVAL 10 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:6F:48:68')),
  (52.2, 5.96, 221.8, 73.2, 169, @ahora - INTERVAL 9 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:6F:48:68')),
  (39.6, 9.39, 351.2, 54.7, 220, @ahora - INTERVAL 8 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:6F:48:68')),
  (24.1, 10.91, 7.6, 44.5, 205, @ahora - INTERVAL 7 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:6F:48:68')),
  (43.7, 6.6, 62.7, 56.0, 258, @ahora - INTERVAL 6 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:6F:48:68')),
  (46.1, 8.65, 30.5, 17.1, 158, @ahora - INTERVAL 5 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:6F:48:68')),
  (39.4, 10.68, 205.2, 63.0, 231, @ahora - INTERVAL 4 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:6F:48:68')),
  (28.7, 5.64, 134.3, 6.2, 161, @ahora - INTERVAL 3 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:6F:48:68')),
  (37.1, 7.12, 191.7, 65.3, 222, @ahora - INTERVAL 2 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:6F:48:68')),
  (16.1, 6.19, 179.7, 31.4, 215, @ahora - INTERVAL 1 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:6F:48:68'));
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES (37.0, 6.64, 22.2, 68.8, 184, (SELECT ultima_senal FROM equipo WHERE direccion_mac = '02:5E:15:6F:48:68'), (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:6F:48:68'));
INSERT INTO almacenamiento (punto_montaje, capacidad_total_gb, espacio_libre_gb, id_informe) VALUES ('C:', 256, 166.4, LAST_INSERT_ID());
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES
  (15.2, 8.18, 97.5, 36.8, 247, @ahora - INTERVAL 24 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:94:55:69')),
  (42.5, 6.02, 317.2, 22.6, 197, @ahora - INTERVAL 23 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:94:55:69')),
  (18.9, 9.24, 91.7, 46.7, 252, @ahora - INTERVAL 22 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:94:55:69')),
  (8.0, 9.7, 160.3, 20.7, 146, @ahora - INTERVAL 21 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:94:55:69')),
  (13.9, 8.78, 191.8, 29.5, 230, @ahora - INTERVAL 20 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:94:55:69')),
  (29.2, 10.05, 271.0, 34.0, 233, @ahora - INTERVAL 19 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:94:55:69')),
  (34.9, 7.24, 252.2, 63.7, 213, @ahora - INTERVAL 18 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:94:55:69')),
  (36.5, 8.93, 219.0, 68.5, 165, @ahora - INTERVAL 17 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:94:55:69')),
  (43.6, 7.04, 22.3, 62.9, 179, @ahora - INTERVAL 16 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:94:55:69')),
  (44.9, 9.28, 39.8, 54.8, 209, @ahora - INTERVAL 15 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:94:55:69')),
  (36.2, 10.1, 260.9, 29.4, 173, @ahora - INTERVAL 14 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:94:55:69')),
  (58.3, 11.01, 190.8, 17.2, 214, @ahora - INTERVAL 13 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:94:55:69')),
  (52.5, 6.13, 277.2, 54.0, 175, @ahora - INTERVAL 12 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:94:55:69')),
  (41.7, 9.44, 126.3, 60.6, 195, @ahora - INTERVAL 11 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:94:55:69')),
  (50.9, 10.99, 150.8, 58.5, 180, @ahora - INTERVAL 10 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:94:55:69')),
  (49.2, 7.54, 103.0, 20.7, 214, @ahora - INTERVAL 9 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:94:55:69')),
  (33.2, 9.11, 139.1, 62.8, 251, @ahora - INTERVAL 8 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:94:55:69')),
  (30.1, 8.52, 163.5, 28.8, 182, @ahora - INTERVAL 7 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:94:55:69')),
  (29.7, 10.68, 390.5, 21.1, 145, @ahora - INTERVAL 6 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:94:55:69')),
  (17.4, 8.65, 82.7, 59.8, 145, @ahora - INTERVAL 5 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:94:55:69')),
  (31.9, 8.03, 227.7, 16.1, 232, @ahora - INTERVAL 4 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:94:55:69')),
  (22.0, 9.6, 338.6, 60.7, 233, @ahora - INTERVAL 3 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:94:55:69')),
  (43.7, 7.51, 157.4, 26.3, 221, @ahora - INTERVAL 2 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:94:55:69')),
  (40.6, 10.55, 283.7, 35.1, 217, @ahora - INTERVAL 1 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:94:55:69'));
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES (25.3, 9.1, 335.2, 36.6, 148, (SELECT ultima_senal FROM equipo WHERE direccion_mac = '02:5E:15:94:55:69'), (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:94:55:69'));
INSERT INTO almacenamiento (punto_montaje, capacidad_total_gb, espacio_libre_gb, id_informe) VALUES ('C:', 512, 243.2, LAST_INSERT_ID());
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES
  (31.6, 8.95, 17.7, 58.5, 193, @ahora - INTERVAL 24 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:B9:62:6A')),
  (11.2, 7.68, 379.0, 18.4, 182, @ahora - INTERVAL 23 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:B9:62:6A')),
  (10.4, 7.29, 286.9, 8.3, 195, @ahora - INTERVAL 22 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:B9:62:6A')),
  (47.9, 7.24, 110.9, 53.5, 147, @ahora - INTERVAL 21 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:B9:62:6A')),
  (49.6, 6.85, 159.2, 8.0, 169, @ahora - INTERVAL 20 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:B9:62:6A')),
  (15.1, 6.23, 45.9, 77.9, 155, @ahora - INTERVAL 19 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:B9:62:6A')),
  (38.9, 5.86, 133.5, 38.1, 260, @ahora - INTERVAL 18 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:B9:62:6A')),
  (49.5, 7.56, 105.5, 39.2, 207, @ahora - INTERVAL 17 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:B9:62:6A')),
  (30.7, 7.69, 203.6, 27.1, 142, @ahora - INTERVAL 16 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:B9:62:6A')),
  (47.6, 9.54, 249.6, 59.7, 173, @ahora - INTERVAL 15 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:B9:62:6A')),
  (70.4, 6.49, 379.5, 29.5, 195, @ahora - INTERVAL 14 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:B9:62:6A')),
  (62.9, 10.61, 96.1, 46.5, 237, @ahora - INTERVAL 13 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:B9:62:6A')),
  (66.3, 8.64, 303.3, 64.0, 168, @ahora - INTERVAL 12 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:B9:62:6A')),
  (43.3, 9.5, 125.6, 42.2, 177, @ahora - INTERVAL 11 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:B9:62:6A')),
  (41.9, 6.73, 195.3, 4.1, 165, @ahora - INTERVAL 10 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:B9:62:6A')),
  (72.5, 6.94, 275.6, 41.5, 219, @ahora - INTERVAL 9 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:B9:62:6A')),
  (12.0, 6.91, 149.4, 18.6, 251, @ahora - INTERVAL 8 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:B9:62:6A')),
  (15.2, 8.48, 59.4, 9.6, 252, @ahora - INTERVAL 7 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:B9:62:6A')),
  (24.5, 7.78, 103.7, 33.5, 254, @ahora - INTERVAL 6 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:B9:62:6A')),
  (20.5, 5.87, 237.1, 3.8, 172, @ahora - INTERVAL 5 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:B9:62:6A')),
  (17.9, 9.31, 154.1, 67.9, 256, @ahora - INTERVAL 4 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:B9:62:6A')),
  (30.7, 9.38, 136.8, 12.9, 193, @ahora - INTERVAL 3 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:B9:62:6A')),
  (17.9, 8.58, 299.7, 28.3, 197, @ahora - INTERVAL 2 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:B9:62:6A')),
  (31.3, 9.37, 23.5, 27.6, 260, @ahora - INTERVAL 1 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:B9:62:6A'));
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES (15.2, 6.7, 163.7, 77.5, 166, (SELECT ultima_senal FROM equipo WHERE direccion_mac = '02:5E:15:B9:62:6A'), (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:B9:62:6A'));
INSERT INTO almacenamiento (punto_montaje, capacidad_total_gb, espacio_libre_gb, id_informe) VALUES ('C:', 512, 303.5, LAST_INSERT_ID());
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES
  (47.3, 13.36, 374.4, 34.2, 241, @ahora - INTERVAL 24 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:DE:6F:6B')),
  (52.5, 14.4, 257.7, 1.5, 258, @ahora - INTERVAL 23 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:DE:6F:6B')),
  (36.9, 14.18, 191.0, 21.9, 170, @ahora - INTERVAL 22 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:DE:6F:6B')),
  (49.9, 14.99, 129.1, 28.6, 203, @ahora - INTERVAL 21 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:DE:6F:6B')),
  (22.5, 17.78, 178.1, 60.1, 176, @ahora - INTERVAL 20 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:DE:6F:6B')),
  (20.2, 14.19, 233.8, 32.3, 140, @ahora - INTERVAL 19 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:DE:6F:6B')),
  (44.1, 15.83, 113.6, 59.5, 192, @ahora - INTERVAL 18 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:DE:6F:6B')),
  (31.3, 18.9, 263.1, 55.9, 166, @ahora - INTERVAL 17 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:DE:6F:6B')),
  (24.4, 21.42, 208.7, 16.7, 197, @ahora - INTERVAL 16 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:DE:6F:6B')),
  (63.6, 20.13, 16.1, 13.4, 173, @ahora - INTERVAL 15 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:DE:6F:6B')),
  (42.5, 14.26, 164.5, 1.9, 156, @ahora - INTERVAL 14 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:DE:6F:6B')),
  (33.4, 13.56, 35.2, 9.1, 189, @ahora - INTERVAL 13 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:DE:6F:6B')),
  (35.8, 16.45, 373.6, 33.9, 248, @ahora - INTERVAL 12 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:DE:6F:6B')),
  (48.9, 12.75, 159.5, 62.0, 181, @ahora - INTERVAL 11 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:DE:6F:6B')),
  (48.8, 21.92, 126.5, 57.9, 201, @ahora - INTERVAL 10 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:DE:6F:6B')),
  (55.9, 13.18, 83.5, 21.1, 254, @ahora - INTERVAL 9 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:DE:6F:6B')),
  (16.6, 13.78, 92.1, 57.9, 222, @ahora - INTERVAL 8 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:DE:6F:6B')),
  (8.0, 14.22, 96.0, 43.9, 199, @ahora - INTERVAL 7 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:DE:6F:6B')),
  (11.8, 13.16, 362.8, 70.9, 176, @ahora - INTERVAL 6 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:DE:6F:6B')),
  (36.1, 18.71, 203.3, 64.3, 187, @ahora - INTERVAL 5 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:DE:6F:6B')),
  (43.9, 20.89, 108.3, 16.0, 235, @ahora - INTERVAL 4 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:DE:6F:6B')),
  (47.3, 18.4, 34.5, 23.4, 173, @ahora - INTERVAL 3 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:DE:6F:6B')),
  (45.1, 20.14, 257.5, 15.8, 213, @ahora - INTERVAL 2 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:DE:6F:6B')),
  (27.8, 13.83, 353.4, 55.8, 226, @ahora - INTERVAL 1 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:DE:6F:6B'));
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES (17.3, 17.85, 256.8, 62.5, 219, (SELECT ultima_senal FROM equipo WHERE direccion_mac = '02:5E:15:DE:6F:6B'), (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:DE:6F:6B'));
INSERT INTO almacenamiento (punto_montaje, capacidad_total_gb, espacio_libre_gb, id_informe) VALUES ('C:', 1000, 419.9, LAST_INSERT_ID());
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES
  (11.8, 5.18, 306.2, 52.6, 257, @ahora - INTERVAL 24 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:03:7C:6C')),
  (39.7, 4.43, 89.5, 18.7, 171, @ahora - INTERVAL 23 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:03:7C:6C')),
  (44.1, 4.03, 35.9, 25.3, 217, @ahora - INTERVAL 22 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:03:7C:6C')),
  (24.4, 3.31, 315.3, 10.7, 210, @ahora - INTERVAL 21 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:03:7C:6C')),
  (50.0, 4.03, 289.3, 18.3, 148, @ahora - INTERVAL 20 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:03:7C:6C')),
  (45.7, 3.98, 318.6, 47.4, 187, @ahora - INTERVAL 19 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:03:7C:6C')),
  (39.2, 4.29, 139.0, 9.2, 191, @ahora - INTERVAL 18 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:03:7C:6C')),
  (8.1, 4.09, 288.4, 54.9, 166, @ahora - INTERVAL 17 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:03:7C:6C')),
  (11.5, 3.67, 209.2, 7.9, 146, @ahora - INTERVAL 16 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:03:7C:6C')),
  (65.4, 5.38, 91.6, 2.2, 177, @ahora - INTERVAL 15 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:03:7C:6C')),
  (70.4, 4.05, 81.9, 29.1, 224, @ahora - INTERVAL 14 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:03:7C:6C')),
  (71.8, 3.31, 327.7, 46.9, 179, @ahora - INTERVAL 13 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:03:7C:6C')),
  (33.5, 3.03, 275.5, 51.4, 159, @ahora - INTERVAL 12 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:03:7C:6C')),
  (79.9, 5.22, 350.4, 65.8, 210, @ahora - INTERVAL 11 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:03:7C:6C')),
  (48.7, 5.52, 380.3, 26.9, 166, @ahora - INTERVAL 10 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:03:7C:6C')),
  (62.7, 4.95, 278.7, 29.6, 162, @ahora - INTERVAL 9 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:03:7C:6C')),
  (27.3, 5.11, 212.0, 34.6, 155, @ahora - INTERVAL 8 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:03:7C:6C')),
  (39.2, 4.85, 27.8, 56.8, 258, @ahora - INTERVAL 7 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:03:7C:6C')),
  (40.7, 3.78, 394.2, 46.3, 196, @ahora - INTERVAL 6 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:03:7C:6C')),
  (26.9, 3.48, 41.6, 23.8, 157, @ahora - INTERVAL 5 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:03:7C:6C')),
  (26.2, 3.25, 5.2, 65.0, 156, @ahora - INTERVAL 4 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:03:7C:6C')),
  (42.2, 3.21, 224.0, 41.4, 215, @ahora - INTERVAL 3 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:03:7C:6C')),
  (44.2, 3.28, 84.9, 8.9, 191, @ahora - INTERVAL 2 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:03:7C:6C')),
  (39.4, 5.59, 65.8, 39.2, 252, @ahora - INTERVAL 1 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:03:7C:6C'));
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES (25.8, 3.56, 256.4, 7.0, 223, (SELECT ultima_senal FROM equipo WHERE direccion_mac = '02:5E:15:03:7C:6C'), (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:03:7C:6C'));
INSERT INTO almacenamiento (punto_montaje, capacidad_total_gb, espacio_libre_gb, id_informe) VALUES ('C:', 256, 103.2, LAST_INSERT_ID());
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES
  (17.8, 5.19, 249.1, 14.5, 215, @ahora - INTERVAL 24 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:28:89:6D')),
  (48.5, 4.15, 76.7, 12.5, 153, @ahora - INTERVAL 23 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:28:89:6D')),
  (23.8, 4.38, 97.0, 62.7, 240, @ahora - INTERVAL 22 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:28:89:6D')),
  (49.9, 3.99, 124.4, 3.8, 144, @ahora - INTERVAL 21 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:28:89:6D')),
  (44.0, 3.08, 393.5, 31.3, 142, @ahora - INTERVAL 20 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:28:89:6D')),
  (48.3, 3.41, 70.5, 73.8, 199, @ahora - INTERVAL 19 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:28:89:6D')),
  (8.3, 3.9, 381.7, 1.3, 200, @ahora - INTERVAL 18 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:28:89:6D')),
  (28.2, 2.86, 67.0, 9.7, 213, @ahora - INTERVAL 17 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:28:89:6D')),
  (41.9, 4.44, 148.6, 14.0, 233, @ahora - INTERVAL 16 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:28:89:6D')),
  (62.2, 4.78, 155.7, 31.5, 242, @ahora - INTERVAL 15 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:28:89:6D')),
  (78.3, 3.16, 195.8, 78.7, 249, @ahora - INTERVAL 14 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:28:89:6D')),
  (44.9, 3.67, 250.9, 30.9, 192, @ahora - INTERVAL 13 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:28:89:6D')),
  (33.1, 3.85, 78.6, 49.7, 201, @ahora - INTERVAL 12 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:28:89:6D')),
  (79.8, 5.45, 317.6, 71.4, 158, @ahora - INTERVAL 11 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:28:89:6D')),
  (77.3, 3.81, 258.3, 72.7, 168, @ahora - INTERVAL 10 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:28:89:6D')),
  (61.0, 4.4, 91.3, 79.7, 180, @ahora - INTERVAL 9 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:28:89:6D')),
  (49.0, 3.59, 358.1, 38.2, 253, @ahora - INTERVAL 8 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:28:89:6D')),
  (9.9, 4.1, 217.0, 17.6, 236, @ahora - INTERVAL 7 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:28:89:6D')),
  (35.5, 5.6, 368.6, 28.5, 173, @ahora - INTERVAL 6 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:28:89:6D')),
  (52.0, 2.86, 114.4, 22.4, 244, @ahora - INTERVAL 5 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:28:89:6D')),
  (41.0, 4.17, 119.8, 41.2, 155, @ahora - INTERVAL 4 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:28:89:6D')),
  (41.9, 4.95, 142.7, 65.8, 176, @ahora - INTERVAL 3 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:28:89:6D')),
  (36.5, 3.09, 59.7, 27.5, 153, @ahora - INTERVAL 2 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:28:89:6D')),
  (30.2, 5.37, 49.9, 25.1, 147, @ahora - INTERVAL 1 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:28:89:6D'));
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES (25.2, 3.99, 130.1, 21.5, 231, (SELECT ultima_senal FROM equipo WHERE direccion_mac = '02:5E:15:28:89:6D'), (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:28:89:6D'));
INSERT INTO almacenamiento (punto_montaje, capacidad_total_gb, espacio_libre_gb, id_informe) VALUES ('C:', 512, 137.8, LAST_INSERT_ID());
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES
  (40.7, 8.65, 82.8, 67.4, 244, @ahora - INTERVAL 24 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:4D:96:6E')),
  (43.2, 6.29, 32.8, 9.8, 237, @ahora - INTERVAL 23 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:4D:96:6E')),
  (17.6, 9.45, 154.2, 36.8, 214, @ahora - INTERVAL 22 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:4D:96:6E')),
  (22.4, 9.21, 265.2, 43.4, 153, @ahora - INTERVAL 21 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:4D:96:6E')),
  (31.2, 8.27, 269.6, 43.8, 203, @ahora - INTERVAL 20 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:4D:96:6E')),
  (8.6, 10.64, 59.3, 51.1, 149, @ahora - INTERVAL 19 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:4D:96:6E')),
  (53.2, 10.85, 333.5, 5.9, 160, @ahora - INTERVAL 18 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:4D:96:6E')),
  (40.7, 6.99, 350.4, 79.9, 245, @ahora - INTERVAL 17 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:4D:96:6E')),
  (13.9, 7.06, 341.0, 51.7, 156, @ahora - INTERVAL 16 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:4D:96:6E')),
  (74.4, 6.52, 29.1, 33.6, 215, @ahora - INTERVAL 15 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:4D:96:6E')),
  (47.1, 6.69, 298.3, 27.4, 194, @ahora - INTERVAL 14 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:4D:96:6E')),
  (50.3, 11.11, 399.7, 9.7, 252, @ahora - INTERVAL 13 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:4D:96:6E')),
  (42.1, 7.21, 57.6, 33.4, 196, @ahora - INTERVAL 12 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:4D:96:6E')),
  (64.0, 11.04, 371.5, 76.6, 217, @ahora - INTERVAL 11 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:4D:96:6E')),
  (65.8, 9.19, 201.4, 36.6, 177, @ahora - INTERVAL 10 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:4D:96:6E')),
  (37.4, 6.17, 252.7, 24.6, 185, @ahora - INTERVAL 9 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:4D:96:6E')),
  (33.8, 9.15, 251.9, 64.5, 221, @ahora - INTERVAL 8 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:4D:96:6E')),
  (50.8, 8.92, 157.8, 49.3, 229, @ahora - INTERVAL 7 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:4D:96:6E')),
  (36.7, 9.24, 230.1, 3.8, 232, @ahora - INTERVAL 6 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:4D:96:6E')),
  (53.0, 6.92, 150.4, 15.5, 252, @ahora - INTERVAL 5 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:4D:96:6E')),
  (11.9, 7.66, 353.9, 48.5, 210, @ahora - INTERVAL 4 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:4D:96:6E')),
  (51.9, 7.5, 383.2, 26.4, 232, @ahora - INTERVAL 3 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:4D:96:6E')),
  (47.6, 9.94, 7.9, 35.7, 155, @ahora - INTERVAL 2 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:4D:96:6E')),
  (39.3, 10.77, 377.0, 61.5, 217, @ahora - INTERVAL 1 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:4D:96:6E'));
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES (23.3, 5.7, 372.2, 26.8, 254, (SELECT ultima_senal FROM equipo WHERE direccion_mac = '02:5E:15:4D:96:6E'), (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:15:4D:96:6E'));
INSERT INTO almacenamiento (punto_montaje, capacidad_total_gb, espacio_libre_gb, id_informe) VALUES ('C:', 512, 207.3, LAST_INSERT_ID());
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES
  (45.5, 6.38, 60.0, 25.7, 251, @ahora - INTERVAL 24 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:00:A3:6F')),
  (14.3, 10.02, 265.9, 73.1, 209, @ahora - INTERVAL 23 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:00:A3:6F')),
  (38.8, 6.57, 192.7, 58.7, 192, @ahora - INTERVAL 22 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:00:A3:6F')),
  (37.9, 10.14, 342.2, 56.0, 230, @ahora - INTERVAL 21 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:00:A3:6F')),
  (50.3, 9.34, 313.3, 9.2, 191, @ahora - INTERVAL 20 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:00:A3:6F')),
  (29.7, 8.05, 89.2, 48.8, 178, @ahora - INTERVAL 19 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:00:A3:6F')),
  (16.1, 9.83, 374.5, 48.6, 182, @ahora - INTERVAL 18 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:00:A3:6F')),
  (45.6, 6.91, 369.6, 55.9, 159, @ahora - INTERVAL 17 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:00:A3:6F')),
  (29.1, 7.96, 339.5, 42.2, 151, @ahora - INTERVAL 16 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:00:A3:6F')),
  (69.3, 10.94, 348.0, 7.5, 199, @ahora - INTERVAL 15 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:00:A3:6F')),
  (44.5, 6.08, 174.4, 42.7, 250, @ahora - INTERVAL 14 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:00:A3:6F')),
  (65.0, 6.03, 96.6, 3.6, 164, @ahora - INTERVAL 13 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:00:A3:6F')),
  (56.2, 8.98, 373.7, 25.4, 257, @ahora - INTERVAL 12 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:00:A3:6F')),
  (78.0, 8.08, 129.1, 53.7, 249, @ahora - INTERVAL 11 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:00:A3:6F')),
  (42.3, 7.44, 207.5, 28.2, 187, @ahora - INTERVAL 10 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:00:A3:6F')),
  (47.7, 9.81, 306.4, 71.2, 141, @ahora - INTERVAL 9 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:00:A3:6F')),
  (52.6, 10.61, 219.4, 75.5, 182, @ahora - INTERVAL 8 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:00:A3:6F')),
  (35.8, 6.07, 373.3, 72.5, 257, @ahora - INTERVAL 7 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:00:A3:6F')),
  (45.7, 6.47, 84.6, 67.7, 186, @ahora - INTERVAL 6 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:00:A3:6F')),
  (45.7, 10.78, 176.0, 4.0, 200, @ahora - INTERVAL 5 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:00:A3:6F')),
  (35.6, 7.51, 262.5, 1.5, 182, @ahora - INTERVAL 4 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:00:A3:6F')),
  (52.3, 9.32, 366.8, 11.0, 243, @ahora - INTERVAL 3 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:00:A3:6F')),
  (51.2, 7.32, 343.1, 17.4, 194, @ahora - INTERVAL 2 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:00:A3:6F')),
  (45.8, 10.06, 24.4, 29.2, 190, @ahora - INTERVAL 1 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:00:A3:6F'));
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES (14.2, 7.6, 273.0, 8.3, 213, (SELECT ultima_senal FROM equipo WHERE direccion_mac = '02:5E:40:00:A3:6F'), (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:00:A3:6F'));
INSERT INTO almacenamiento (punto_montaje, capacidad_total_gb, espacio_libre_gb, id_informe) VALUES ('C:', 1000, 311.6, LAST_INSERT_ID());
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES
  (13.1, 5.98, 34.7, 32.8, 239, @ahora - INTERVAL 24 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:25:B0:70')),
  (14.6, 5.86, 206.8, 16.3, 162, @ahora - INTERVAL 23 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:25:B0:70')),
  (19.7, 10.93, 199.0, 32.8, 180, @ahora - INTERVAL 22 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:25:B0:70')),
  (53.7, 8.57, 18.3, 75.2, 184, @ahora - INTERVAL 21 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:25:B0:70')),
  (34.0, 7.79, 139.6, 39.6, 177, @ahora - INTERVAL 20 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:25:B0:70')),
  (35.1, 8.89, 44.1, 67.5, 192, @ahora - INTERVAL 19 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:25:B0:70')),
  (20.7, 7.45, 151.7, 13.4, 219, @ahora - INTERVAL 18 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:25:B0:70')),
  (28.8, 10.33, 83.7, 76.2, 194, @ahora - INTERVAL 17 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:25:B0:70')),
  (46.5, 7.92, 121.3, 49.1, 231, @ahora - INTERVAL 16 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:25:B0:70')),
  (56.0, 10.92, 93.7, 47.2, 141, @ahora - INTERVAL 15 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:25:B0:70')),
  (44.7, 10.29, 73.8, 16.7, 187, @ahora - INTERVAL 14 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:25:B0:70')),
  (71.2, 6.22, 104.3, 21.3, 164, @ahora - INTERVAL 13 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:25:B0:70')),
  (60.4, 6.58, 85.8, 74.6, 165, @ahora - INTERVAL 12 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:25:B0:70')),
  (43.9, 8.01, 225.3, 14.6, 168, @ahora - INTERVAL 11 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:25:B0:70')),
  (60.3, 8.19, 189.9, 45.7, 170, @ahora - INTERVAL 10 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:25:B0:70')),
  (49.2, 9.4, 18.5, 73.6, 236, @ahora - INTERVAL 9 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:25:B0:70')),
  (18.7, 7.69, 298.0, 71.6, 189, @ahora - INTERVAL 8 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:25:B0:70')),
  (54.1, 7.3, 55.6, 28.2, 144, @ahora - INTERVAL 7 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:25:B0:70')),
  (32.5, 9.07, 364.0, 13.8, 206, @ahora - INTERVAL 6 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:25:B0:70')),
  (11.5, 5.66, 327.3, 1.9, 194, @ahora - INTERVAL 5 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:25:B0:70')),
  (20.6, 8.41, 22.0, 35.8, 260, @ahora - INTERVAL 4 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:25:B0:70')),
  (36.7, 6.42, 262.5, 51.8, 167, @ahora - INTERVAL 3 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:25:B0:70')),
  (35.5, 6.72, 218.0, 68.2, 226, @ahora - INTERVAL 2 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:25:B0:70')),
  (29.0, 7.69, 332.7, 16.6, 238, @ahora - INTERVAL 1 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:25:B0:70'));
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES (53.5, 10.43, 257.8, 28.7, 222, (SELECT ultima_senal FROM equipo WHERE direccion_mac = '02:5E:40:25:B0:70'), (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:25:B0:70'));
INSERT INTO almacenamiento (punto_montaje, capacidad_total_gb, espacio_libre_gb, id_informe) VALUES ('C:', 256, 102.9, LAST_INSERT_ID());
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES
  (11.0, 16.54, 105.3, 18.7, 158, @ahora - INTERVAL 24 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:4A:BD:71')),
  (14.6, 15.59, 60.7, 72.8, 248, @ahora - INTERVAL 23 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:4A:BD:71')),
  (42.2, 18.46, 136.0, 23.0, 166, @ahora - INTERVAL 22 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:4A:BD:71')),
  (21.2, 19.13, 136.1, 60.7, 165, @ahora - INTERVAL 21 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:4A:BD:71')),
  (17.5, 18.69, 295.8, 58.3, 141, @ahora - INTERVAL 20 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:4A:BD:71')),
  (28.8, 21.32, 161.3, 17.0, 205, @ahora - INTERVAL 19 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:4A:BD:71')),
  (38.3, 12.67, 212.7, 22.1, 192, @ahora - INTERVAL 18 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:4A:BD:71')),
  (47.7, 16.88, 108.7, 58.2, 237, @ahora - INTERVAL 17 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:4A:BD:71')),
  (24.5, 21.61, 394.9, 44.6, 208, @ahora - INTERVAL 16 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:4A:BD:71')),
  (49.6, 19.53, 288.2, 74.0, 228, @ahora - INTERVAL 15 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:4A:BD:71')),
  (41.2, 12.19, 174.8, 7.5, 178, @ahora - INTERVAL 14 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:4A:BD:71')),
  (76.2, 20.7, 37.9, 79.2, 232, @ahora - INTERVAL 13 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:4A:BD:71')),
  (61.7, 14.84, 6.8, 64.9, 204, @ahora - INTERVAL 12 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:4A:BD:71')),
  (47.1, 17.09, 307.1, 35.7, 213, @ahora - INTERVAL 11 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:4A:BD:71')),
  (68.7, 14.31, 120.9, 34.0, 160, @ahora - INTERVAL 10 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:4A:BD:71')),
  (56.0, 11.58, 334.7, 5.9, 163, @ahora - INTERVAL 9 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:4A:BD:71')),
  (32.4, 16.86, 395.8, 40.1, 187, @ahora - INTERVAL 8 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:4A:BD:71')),
  (9.4, 15.43, 171.6, 42.0, 193, @ahora - INTERVAL 7 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:4A:BD:71')),
  (16.5, 13.05, 78.4, 16.2, 180, @ahora - INTERVAL 6 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:4A:BD:71')),
  (42.0, 19.33, 14.0, 76.2, 141, @ahora - INTERVAL 5 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:4A:BD:71')),
  (38.2, 16.09, 70.4, 29.4, 238, @ahora - INTERVAL 4 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:4A:BD:71')),
  (24.6, 20.26, 242.8, 55.9, 207, @ahora - INTERVAL 3 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:4A:BD:71')),
  (35.3, 16.57, 280.8, 44.7, 201, @ahora - INTERVAL 2 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:4A:BD:71')),
  (14.2, 13.0, 205.0, 78.7, 195, @ahora - INTERVAL 1 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:4A:BD:71'));
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES (13.2, 15.31, 334.5, 3.0, 217, (SELECT ultima_senal FROM equipo WHERE direccion_mac = '02:5E:40:4A:BD:71'), (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:4A:BD:71'));
INSERT INTO almacenamiento (punto_montaje, capacidad_total_gb, espacio_libre_gb, id_informe) VALUES ('C:', 512, 153.0, LAST_INSERT_ID());
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES (59.1, 4.3, 394.7, 43.8, 242, (SELECT ultima_senal FROM equipo WHERE direccion_mac = '02:5E:40:6F:CA:72'), (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:6F:CA:72'));
INSERT INTO almacenamiento (punto_montaje, capacidad_total_gb, espacio_libre_gb, id_informe) VALUES ('C:', 512, 284.6, LAST_INSERT_ID());
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES (13.9, 3.36, 111.2, 39.5, 142, (SELECT ultima_senal FROM equipo WHERE direccion_mac = '02:5E:40:94:D7:73'), (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:94:D7:73'));
INSERT INTO almacenamiento (punto_montaje, capacidad_total_gb, espacio_libre_gb, id_informe) VALUES ('C:', 1000, 479.9, LAST_INSERT_ID());
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES (26.0, 6.0, 249.4, 32.1, 145, (SELECT ultima_senal FROM equipo WHERE direccion_mac = '02:5E:40:B9:E4:74'), (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:B9:E4:74'));
INSERT INTO almacenamiento (punto_montaje, capacidad_total_gb, espacio_libre_gb, id_informe) VALUES ('C:', 256, 170.4, LAST_INSERT_ID());
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES
  (27.9, 8.03, 270.5, 6.9, 170, @ahora - INTERVAL 24 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:DE:F1:75')),
  (43.0, 11.1, 353.2, 34.0, 229, @ahora - INTERVAL 23 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:DE:F1:75')),
  (37.4, 6.17, 289.9, 1.7, 194, @ahora - INTERVAL 22 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:DE:F1:75')),
  (26.4, 9.16, 15.8, 3.2, 140, @ahora - INTERVAL 21 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:DE:F1:75')),
  (10.4, 6.27, 209.7, 27.5, 183, @ahora - INTERVAL 20 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:DE:F1:75')),
  (50.5, 7.13, 46.6, 30.1, 180, @ahora - INTERVAL 19 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:DE:F1:75')),
  (24.4, 5.8, 53.9, 55.5, 170, @ahora - INTERVAL 18 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:DE:F1:75')),
  (16.6, 10.71, 389.3, 65.5, 214, @ahora - INTERVAL 17 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:DE:F1:75')),
  (53.6, 6.24, 269.4, 8.8, 233, @ahora - INTERVAL 16 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:DE:F1:75')),
  (56.8, 9.25, 46.0, 51.3, 238, @ahora - INTERVAL 15 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:DE:F1:75')),
  (68.7, 10.77, 218.1, 55.4, 171, @ahora - INTERVAL 14 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:DE:F1:75')),
  (60.6, 8.11, 174.9, 79.4, 226, @ahora - INTERVAL 13 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:DE:F1:75')),
  (60.9, 10.37, 72.1, 32.9, 185, @ahora - INTERVAL 12 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:DE:F1:75')),
  (36.7, 10.05, 117.4, 66.6, 190, @ahora - INTERVAL 11 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:DE:F1:75')),
  (46.4, 8.28, 353.8, 4.7, 223, @ahora - INTERVAL 10 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:DE:F1:75')),
  (48.3, 8.5, 189.4, 13.8, 148, @ahora - INTERVAL 9 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:DE:F1:75')),
  (24.9, 9.62, 326.0, 40.4, 195, @ahora - INTERVAL 8 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:DE:F1:75')),
  (42.6, 10.12, 329.6, 64.5, 180, @ahora - INTERVAL 7 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:DE:F1:75')),
  (20.2, 6.23, 354.1, 14.3, 189, @ahora - INTERVAL 6 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:DE:F1:75')),
  (41.5, 9.2, 197.9, 42.4, 195, @ahora - INTERVAL 5 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:DE:F1:75')),
  (26.8, 6.36, 259.1, 49.1, 244, @ahora - INTERVAL 4 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:DE:F1:75')),
  (19.6, 7.39, 218.0, 19.3, 260, @ahora - INTERVAL 3 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:DE:F1:75')),
  (29.1, 10.64, 370.9, 3.3, 251, @ahora - INTERVAL 2 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:DE:F1:75')),
  (35.2, 10.37, 213.3, 7.7, 144, @ahora - INTERVAL 1 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:DE:F1:75'));
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES (20.6, 15.26, 252.5, 7.6, 170, (SELECT ultima_senal FROM equipo WHERE direccion_mac = '02:5E:40:DE:F1:75'), (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:DE:F1:75'));
INSERT INTO almacenamiento (punto_montaje, capacidad_total_gb, espacio_libre_gb, id_informe) VALUES ('C:', 512, 35.5, LAST_INSERT_ID());
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES
  (49.7, 8.9, 90.7, 58.1, 191, @ahora - INTERVAL 24 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:03:FE:76')),
  (20.5, 5.68, 46.6, 48.4, 244, @ahora - INTERVAL 23 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:03:FE:76')),
  (13.4, 10.94, 207.0, 76.0, 243, @ahora - INTERVAL 22 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:03:FE:76')),
  (54.8, 6.28, 165.7, 13.1, 240, @ahora - INTERVAL 21 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:03:FE:76')),
  (34.8, 7.94, 149.9, 43.4, 148, @ahora - INTERVAL 20 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:03:FE:76')),
  (33.5, 8.63, 119.9, 9.0, 202, @ahora - INTERVAL 19 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:03:FE:76')),
  (36.1, 7.91, 21.2, 59.7, 226, @ahora - INTERVAL 18 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:03:FE:76')),
  (40.5, 6.55, 268.6, 3.6, 191, @ahora - INTERVAL 17 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:03:FE:76')),
  (19.1, 6.98, 200.7, 43.5, 151, @ahora - INTERVAL 16 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:03:FE:76')),
  (78.4, 10.51, 172.7, 53.4, 185, @ahora - INTERVAL 15 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:03:FE:76')),
  (41.6, 8.44, 374.9, 73.8, 144, @ahora - INTERVAL 14 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:03:FE:76')),
  (38.4, 10.22, 8.7, 13.7, 199, @ahora - INTERVAL 13 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:03:FE:76')),
  (44.8, 11.16, 290.4, 10.9, 189, @ahora - INTERVAL 12 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:03:FE:76')),
  (68.3, 6.96, 86.2, 15.8, 229, @ahora - INTERVAL 11 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:03:FE:76')),
  (43.0, 10.71, 61.7, 62.3, 150, @ahora - INTERVAL 10 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:03:FE:76')),
  (55.1, 7.38, 15.5, 30.4, 179, @ahora - INTERVAL 9 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:03:FE:76')),
  (52.5, 8.87, 181.9, 31.5, 242, @ahora - INTERVAL 8 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:03:FE:76')),
  (19.0, 8.76, 323.2, 27.3, 217, @ahora - INTERVAL 7 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:03:FE:76')),
  (52.5, 10.32, 61.8, 46.4, 185, @ahora - INTERVAL 6 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:03:FE:76')),
  (36.6, 7.78, 398.5, 14.7, 233, @ahora - INTERVAL 5 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:03:FE:76')),
  (15.9, 6.42, 275.4, 39.8, 142, @ahora - INTERVAL 4 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:03:FE:76')),
  (19.4, 9.59, 111.7, 39.4, 259, @ahora - INTERVAL 3 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:03:FE:76')),
  (47.7, 8.5, 247.7, 63.1, 228, @ahora - INTERVAL 2 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:03:FE:76')),
  (12.8, 7.69, 398.9, 66.1, 248, @ahora - INTERVAL 1 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:03:FE:76'));
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES (97.8, 6.3, 208.0, 14.2, 246, (SELECT ultima_senal FROM equipo WHERE direccion_mac = '02:5E:40:03:FE:76'), (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:40:03:FE:76'));
INSERT INTO almacenamiento (punto_montaje, capacidad_total_gb, espacio_libre_gb, id_informe) VALUES ('C:', 512, 28.6, LAST_INSERT_ID());
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES
  (44.7, 2.94, 119.4, 64.2, 211, @ahora - INTERVAL 24 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:25:18:78')),
  (32.9, 4.38, 242.3, 37.2, 224, @ahora - INTERVAL 23 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:25:18:78')),
  (14.3, 3.72, 165.7, 68.3, 224, @ahora - INTERVAL 22 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:25:18:78')),
  (38.1, 4.1, 107.2, 15.7, 188, @ahora - INTERVAL 21 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:25:18:78')),
  (34.6, 3.76, 197.9, 79.4, 236, @ahora - INTERVAL 20 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:25:18:78')),
  (12.2, 4.01, 172.1, 23.9, 192, @ahora - INTERVAL 19 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:25:18:78')),
  (22.4, 4.61, 388.3, 4.7, 200, @ahora - INTERVAL 18 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:25:18:78')),
  (9.1, 3.54, 366.8, 39.5, 165, @ahora - INTERVAL 17 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:25:18:78')),
  (34.7, 4.8, 329.6, 26.1, 247, @ahora - INTERVAL 16 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:25:18:78')),
  (72.6, 5.53, 297.7, 50.7, 214, @ahora - INTERVAL 15 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:25:18:78')),
  (57.0, 3.96, 158.1, 37.0, 157, @ahora - INTERVAL 14 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:25:18:78')),
  (39.3, 4.95, 212.8, 51.1, 234, @ahora - INTERVAL 13 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:25:18:78')),
  (56.1, 4.57, 322.1, 43.0, 163, @ahora - INTERVAL 12 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:25:18:78')),
  (54.3, 5.08, 27.2, 70.4, 237, @ahora - INTERVAL 11 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:25:18:78')),
  (79.2, 5.3, 260.2, 35.3, 240, @ahora - INTERVAL 10 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:25:18:78')),
  (73.6, 5.5, 240.8, 13.3, 177, @ahora - INTERVAL 9 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:25:18:78')),
  (38.5, 2.94, 79.0, 39.3, 147, @ahora - INTERVAL 8 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:25:18:78')),
  (17.0, 4.07, 101.7, 34.1, 204, @ahora - INTERVAL 7 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:25:18:78')),
  (29.4, 3.66, 59.6, 66.8, 250, @ahora - INTERVAL 6 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:25:18:78')),
  (19.4, 5.55, 131.3, 46.4, 186, @ahora - INTERVAL 5 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:25:18:78')),
  (22.2, 4.68, 211.7, 78.1, 169, @ahora - INTERVAL 4 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:25:18:78')),
  (13.5, 5.43, 245.2, 76.2, 199, @ahora - INTERVAL 3 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:25:18:78')),
  (44.6, 3.12, 22.7, 73.4, 170, @ahora - INTERVAL 2 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:25:18:78')),
  (11.8, 3.49, 127.5, 3.6, 177, @ahora - INTERVAL 1 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:25:18:78'));
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES (17.1, 4.78, 97.0, 36.3, 243, (SELECT ultima_senal FROM equipo WHERE direccion_mac = '02:5E:38:25:18:78'), (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:25:18:78'));
INSERT INTO almacenamiento (punto_montaje, capacidad_total_gb, espacio_libre_gb, id_informe) VALUES ('C:', 256, 127.6, LAST_INSERT_ID());
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES
  (25.6, 4.82, 234.3, 18.9, 214, @ahora - INTERVAL 24 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:4A:25:79')),
  (50.6, 5.24, 243.9, 58.1, 173, @ahora - INTERVAL 23 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:4A:25:79')),
  (31.4, 5.46, 86.9, 44.1, 216, @ahora - INTERVAL 22 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:4A:25:79')),
  (48.4, 5.0, 46.9, 17.9, 190, @ahora - INTERVAL 21 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:4A:25:79')),
  (38.7, 4.85, 386.0, 2.4, 253, @ahora - INTERVAL 20 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:4A:25:79')),
  (8.2, 3.19, 38.2, 28.0, 219, @ahora - INTERVAL 19 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:4A:25:79')),
  (21.1, 4.93, 126.5, 34.4, 153, @ahora - INTERVAL 18 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:4A:25:79')),
  (15.7, 5.1, 119.6, 72.0, 181, @ahora - INTERVAL 17 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:4A:25:79')),
  (30.1, 3.92, 259.7, 39.9, 226, @ahora - INTERVAL 16 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:4A:25:79')),
  (48.5, 2.98, 135.2, 8.7, 142, @ahora - INTERVAL 15 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:4A:25:79')),
  (79.6, 4.73, 26.3, 76.1, 157, @ahora - INTERVAL 14 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:4A:25:79')),
  (73.1, 2.97, 275.8, 41.6, 150, @ahora - INTERVAL 13 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:4A:25:79')),
  (63.4, 4.39, 140.1, 57.9, 233, @ahora - INTERVAL 12 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:4A:25:79')),
  (77.0, 5.06, 196.8, 55.2, 155, @ahora - INTERVAL 11 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:4A:25:79')),
  (44.6, 4.79, 24.8, 46.1, 216, @ahora - INTERVAL 10 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:4A:25:79')),
  (75.5, 3.06, 96.6, 28.4, 193, @ahora - INTERVAL 9 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:4A:25:79')),
  (41.2, 4.59, 385.5, 1.3, 255, @ahora - INTERVAL 8 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:4A:25:79')),
  (36.9, 5.55, 357.8, 4.5, 167, @ahora - INTERVAL 7 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:4A:25:79')),
  (37.3, 3.63, 293.6, 23.3, 214, @ahora - INTERVAL 6 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:4A:25:79')),
  (18.1, 4.81, 319.0, 47.1, 245, @ahora - INTERVAL 5 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:4A:25:79')),
  (34.4, 2.93, 380.5, 67.8, 197, @ahora - INTERVAL 4 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:4A:25:79')),
  (24.2, 3.31, 68.2, 52.4, 239, @ahora - INTERVAL 3 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:4A:25:79')),
  (27.3, 4.38, 45.3, 77.0, 145, @ahora - INTERVAL 2 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:4A:25:79')),
  (37.2, 4.75, 283.3, 22.6, 177, @ahora - INTERVAL 1 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:4A:25:79'));
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES (59.0, 3.33, 180.4, 27.0, 253, (SELECT ultima_senal FROM equipo WHERE direccion_mac = '02:5E:38:4A:25:79'), (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:4A:25:79'));
INSERT INTO almacenamiento (punto_montaje, capacidad_total_gb, espacio_libre_gb, id_informe) VALUES ('C:', 512, 300.2, LAST_INSERT_ID());
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES
  (26.2, 9.53, 87.2, 66.0, 213, @ahora - INTERVAL 24 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:6F:32:7A')),
  (21.8, 5.65, 313.0, 36.8, 177, @ahora - INTERVAL 23 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:6F:32:7A')),
  (41.5, 5.99, 390.1, 5.6, 195, @ahora - INTERVAL 22 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:6F:32:7A')),
  (35.6, 9.16, 99.3, 19.4, 154, @ahora - INTERVAL 21 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:6F:32:7A')),
  (32.7, 7.29, 269.9, 6.5, 184, @ahora - INTERVAL 20 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:6F:32:7A')),
  (43.7, 7.88, 271.6, 58.1, 182, @ahora - INTERVAL 19 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:6F:32:7A')),
  (40.3, 6.32, 114.1, 10.7, 154, @ahora - INTERVAL 18 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:6F:32:7A')),
  (15.5, 10.15, 287.5, 33.8, 237, @ahora - INTERVAL 17 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:6F:32:7A')),
  (50.9, 9.76, 303.2, 20.0, 156, @ahora - INTERVAL 16 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:6F:32:7A')),
  (71.3, 7.37, 134.9, 71.0, 160, @ahora - INTERVAL 15 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:6F:32:7A')),
  (67.9, 10.5, 155.7, 1.6, 175, @ahora - INTERVAL 14 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:6F:32:7A')),
  (46.4, 7.05, 263.2, 31.1, 206, @ahora - INTERVAL 13 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:6F:32:7A')),
  (58.2, 7.14, 248.2, 58.7, 144, @ahora - INTERVAL 12 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:6F:32:7A')),
  (79.1, 7.22, 336.0, 31.2, 152, @ahora - INTERVAL 11 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:6F:32:7A')),
  (67.2, 10.53, 95.3, 60.6, 201, @ahora - INTERVAL 10 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:6F:32:7A')),
  (53.6, 9.72, 286.5, 9.4, 168, @ahora - INTERVAL 9 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:6F:32:7A')),
  (52.0, 6.22, 169.6, 10.7, 226, @ahora - INTERVAL 8 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:6F:32:7A')),
  (37.0, 6.6, 53.2, 9.9, 166, @ahora - INTERVAL 7 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:6F:32:7A')),
  (38.9, 6.37, 199.9, 22.7, 143, @ahora - INTERVAL 6 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:6F:32:7A')),
  (29.0, 9.67, 186.9, 7.4, 231, @ahora - INTERVAL 5 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:6F:32:7A')),
  (32.2, 5.73, 221.1, 9.1, 161, @ahora - INTERVAL 4 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:6F:32:7A')),
  (11.5, 7.39, 251.1, 2.6, 198, @ahora - INTERVAL 3 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:6F:32:7A')),
  (27.1, 10.03, 23.1, 35.4, 215, @ahora - INTERVAL 2 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:6F:32:7A')),
  (38.2, 10.83, 269.1, 52.2, 178, @ahora - INTERVAL 1 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:6F:32:7A'));
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES (23.8, 7.34, 261.8, 11.5, 202, (SELECT ultima_senal FROM equipo WHERE direccion_mac = '02:5E:38:6F:32:7A'), (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:6F:32:7A'));
INSERT INTO almacenamiento (punto_montaje, capacidad_total_gb, espacio_libre_gb, id_informe) VALUES ('C:', 512, 323.0, LAST_INSERT_ID());
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES
  (20.3, 8.41, 362.5, 14.1, 226, @ahora - INTERVAL 24 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:94:3F:7B')),
  (14.2, 10.55, 348.4, 36.9, 200, @ahora - INTERVAL 23 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:94:3F:7B')),
  (9.5, 6.57, 234.2, 26.2, 155, @ahora - INTERVAL 22 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:94:3F:7B')),
  (13.7, 9.64, 54.0, 4.9, 175, @ahora - INTERVAL 21 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:94:3F:7B')),
  (24.5, 5.92, 354.3, 44.5, 253, @ahora - INTERVAL 20 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:94:3F:7B')),
  (49.2, 8.34, 232.1, 73.1, 156, @ahora - INTERVAL 19 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:94:3F:7B')),
  (23.3, 10.55, 247.1, 41.3, 142, @ahora - INTERVAL 18 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:94:3F:7B')),
  (53.5, 7.03, 163.7, 47.0, 187, @ahora - INTERVAL 17 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:94:3F:7B')),
  (43.1, 6.47, 363.9, 69.4, 209, @ahora - INTERVAL 16 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:94:3F:7B')),
  (49.1, 11.07, 320.1, 7.6, 241, @ahora - INTERVAL 15 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:94:3F:7B')),
  (67.6, 11.19, 37.4, 14.5, 216, @ahora - INTERVAL 14 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:94:3F:7B')),
  (69.5, 10.57, 209.9, 51.2, 230, @ahora - INTERVAL 13 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:94:3F:7B')),
  (64.4, 5.8, 81.3, 4.1, 200, @ahora - INTERVAL 12 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:94:3F:7B')),
  (64.0, 10.48, 196.2, 44.9, 255, @ahora - INTERVAL 11 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:94:3F:7B')),
  (71.5, 10.79, 135.6, 74.2, 149, @ahora - INTERVAL 10 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:94:3F:7B')),
  (63.1, 6.05, 232.0, 62.4, 256, @ahora - INTERVAL 9 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:94:3F:7B')),
  (10.2, 7.92, 50.6, 27.1, 166, @ahora - INTERVAL 8 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:94:3F:7B')),
  (39.1, 8.9, 388.9, 33.3, 202, @ahora - INTERVAL 7 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:94:3F:7B')),
  (33.2, 6.07, 81.0, 6.6, 197, @ahora - INTERVAL 6 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:94:3F:7B')),
  (15.3, 6.63, 398.0, 79.6, 140, @ahora - INTERVAL 5 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:94:3F:7B')),
  (16.2, 6.43, 79.4, 38.4, 232, @ahora - INTERVAL 4 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:94:3F:7B')),
  (40.0, 10.63, 120.8, 45.8, 196, @ahora - INTERVAL 3 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:94:3F:7B')),
  (46.0, 7.15, 239.2, 5.9, 211, @ahora - INTERVAL 2 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:94:3F:7B')),
  (14.7, 9.83, 354.5, 65.2, 235, @ahora - INTERVAL 1 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:94:3F:7B'));
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES (24.8, 9.52, 225.7, 62.8, 212, (SELECT ultima_senal FROM equipo WHERE direccion_mac = '02:5E:38:94:3F:7B'), (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:94:3F:7B'));
INSERT INTO almacenamiento (punto_montaje, capacidad_total_gb, espacio_libre_gb, id_informe) VALUES ('C:', 1000, 551.9, LAST_INSERT_ID());
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES
  (45.9, 5.74, 97.9, 32.7, 176, @ahora - INTERVAL 24 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:B9:4C:7C')),
  (10.4, 7.71, 105.4, 26.1, 160, @ahora - INTERVAL 23 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:B9:4C:7C')),
  (26.9, 9.24, 333.5, 25.6, 153, @ahora - INTERVAL 22 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:B9:4C:7C')),
  (34.8, 9.42, 79.6, 7.0, 157, @ahora - INTERVAL 21 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:B9:4C:7C')),
  (42.1, 9.04, 132.1, 6.8, 189, @ahora - INTERVAL 20 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:B9:4C:7C')),
  (27.6, 8.65, 245.0, 28.0, 251, @ahora - INTERVAL 19 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:B9:4C:7C')),
  (41.1, 10.89, 31.2, 79.6, 169, @ahora - INTERVAL 18 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:B9:4C:7C')),
  (39.7, 8.63, 267.9, 33.4, 227, @ahora - INTERVAL 17 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:B9:4C:7C')),
  (8.2, 5.77, 160.1, 20.1, 257, @ahora - INTERVAL 16 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:B9:4C:7C')),
  (79.8, 7.28, 330.9, 46.0, 191, @ahora - INTERVAL 15 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:B9:4C:7C')),
  (70.1, 8.46, 72.3, 17.7, 230, @ahora - INTERVAL 14 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:B9:4C:7C')),
  (49.6, 7.59, 177.0, 20.1, 211, @ahora - INTERVAL 13 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:B9:4C:7C')),
  (39.1, 10.91, 315.6, 59.5, 185, @ahora - INTERVAL 12 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:B9:4C:7C')),
  (34.5, 7.12, 332.1, 58.8, 158, @ahora - INTERVAL 11 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:B9:4C:7C')),
  (65.0, 9.17, 68.4, 21.3, 192, @ahora - INTERVAL 10 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:B9:4C:7C')),
  (54.7, 8.67, 135.1, 27.0, 215, @ahora - INTERVAL 9 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:B9:4C:7C')),
  (41.3, 8.76, 356.5, 7.7, 150, @ahora - INTERVAL 8 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:B9:4C:7C')),
  (33.9, 6.16, 309.8, 77.8, 260, @ahora - INTERVAL 7 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:B9:4C:7C')),
  (33.0, 7.59, 231.7, 8.4, 163, @ahora - INTERVAL 6 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:B9:4C:7C')),
  (8.7, 9.91, 296.3, 40.2, 155, @ahora - INTERVAL 5 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:B9:4C:7C')),
  (38.4, 8.95, 218.2, 23.6, 170, @ahora - INTERVAL 4 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:B9:4C:7C')),
  (52.9, 10.77, 243.6, 31.0, 200, @ahora - INTERVAL 3 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:B9:4C:7C')),
  (43.4, 5.88, 176.3, 43.4, 197, @ahora - INTERVAL 2 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:B9:4C:7C')),
  (31.5, 10.07, 207.2, 2.1, 244, @ahora - INTERVAL 1 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:B9:4C:7C'));
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES (45.6, 6.54, 145.1, 26.8, 223, (SELECT ultima_senal FROM equipo WHERE direccion_mac = '02:5E:38:B9:4C:7C'), (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:B9:4C:7C'));
INSERT INTO almacenamiento (punto_montaje, capacidad_total_gb, espacio_libre_gb, id_informe) VALUES ('C:', 256, 143.9, LAST_INSERT_ID());
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES
  (20.3, 16.0, 92.4, 72.3, 193, @ahora - INTERVAL 24 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:DE:59:7D')),
  (52.3, 21.51, 370.8, 70.6, 257, @ahora - INTERVAL 23 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:DE:59:7D')),
  (51.2, 15.13, 187.8, 5.6, 180, @ahora - INTERVAL 22 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:DE:59:7D')),
  (11.2, 20.53, 42.9, 3.4, 253, @ahora - INTERVAL 21 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:DE:59:7D')),
  (29.4, 19.03, 41.0, 13.5, 227, @ahora - INTERVAL 20 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:DE:59:7D')),
  (45.7, 18.23, 222.5, 66.6, 241, @ahora - INTERVAL 19 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:DE:59:7D')),
  (15.2, 19.52, 140.5, 64.7, 212, @ahora - INTERVAL 18 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:DE:59:7D')),
  (53.5, 16.04, 49.1, 21.6, 231, @ahora - INTERVAL 17 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:DE:59:7D')),
  (29.3, 20.56, 57.2, 16.8, 152, @ahora - INTERVAL 16 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:DE:59:7D')),
  (76.6, 21.01, 392.4, 59.7, 248, @ahora - INTERVAL 15 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:DE:59:7D')),
  (38.4, 19.42, 367.9, 50.4, 188, @ahora - INTERVAL 14 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:DE:59:7D')),
  (51.2, 19.64, 253.8, 10.0, 209, @ahora - INTERVAL 13 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:DE:59:7D')),
  (69.7, 14.3, 164.6, 46.7, 246, @ahora - INTERVAL 12 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:DE:59:7D')),
  (56.7, 22.33, 11.6, 68.8, 250, @ahora - INTERVAL 11 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:DE:59:7D')),
  (50.6, 17.18, 301.0, 11.1, 199, @ahora - INTERVAL 10 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:DE:59:7D')),
  (51.9, 14.32, 229.0, 17.1, 142, @ahora - INTERVAL 9 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:DE:59:7D')),
  (29.3, 13.67, 398.8, 43.3, 215, @ahora - INTERVAL 8 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:DE:59:7D')),
  (13.2, 15.6, 234.0, 10.2, 147, @ahora - INTERVAL 7 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:DE:59:7D')),
  (54.8, 13.13, 300.5, 12.1, 212, @ahora - INTERVAL 6 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:DE:59:7D')),
  (39.5, 20.22, 332.4, 53.4, 248, @ahora - INTERVAL 5 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:DE:59:7D')),
  (12.6, 15.45, 138.4, 53.4, 250, @ahora - INTERVAL 4 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:DE:59:7D')),
  (25.5, 16.93, 353.4, 2.3, 234, @ahora - INTERVAL 3 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:DE:59:7D')),
  (47.3, 16.17, 295.4, 27.3, 187, @ahora - INTERVAL 2 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:DE:59:7D')),
  (20.9, 13.75, 280.8, 74.3, 147, @ahora - INTERVAL 1 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:DE:59:7D'));
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES (51.5, 14.73, 11.7, 23.5, 229, (SELECT ultima_senal FROM equipo WHERE direccion_mac = '02:5E:38:DE:59:7D'), (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:DE:59:7D'));
INSERT INTO almacenamiento (punto_montaje, capacidad_total_gb, espacio_libre_gb, id_informe) VALUES ('C:', 512, 268.0, LAST_INSERT_ID());
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES
  (54.3, 4.9, 40.4, 52.0, 201, @ahora - INTERVAL 24 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:03:66:7E')),
  (13.8, 4.03, 19.6, 60.1, 175, @ahora - INTERVAL 23 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:03:66:7E')),
  (47.3, 4.24, 212.7, 20.8, 173, @ahora - INTERVAL 22 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:03:66:7E')),
  (45.8, 3.96, 156.3, 56.4, 168, @ahora - INTERVAL 21 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:03:66:7E')),
  (36.4, 5.52, 60.0, 64.8, 249, @ahora - INTERVAL 20 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:03:66:7E')),
  (13.5, 5.43, 245.2, 58.3, 190, @ahora - INTERVAL 19 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:03:66:7E')),
  (53.6, 4.25, 205.4, 75.8, 167, @ahora - INTERVAL 18 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:03:66:7E')),
  (25.5, 5.52, 332.1, 72.4, 169, @ahora - INTERVAL 17 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:03:66:7E')),
  (31.5, 4.69, 30.3, 67.4, 238, @ahora - INTERVAL 16 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:03:66:7E')),
  (61.5, 3.12, 10.4, 25.1, 156, @ahora - INTERVAL 15 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:03:66:7E')),
  (42.0, 3.75, 310.4, 78.3, 165, @ahora - INTERVAL 14 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:03:66:7E')),
  (65.2, 3.65, 222.1, 55.9, 158, @ahora - INTERVAL 13 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:03:66:7E')),
  (36.4, 4.32, 336.5, 10.8, 227, @ahora - INTERVAL 12 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:03:66:7E')),
  (41.3, 5.33, 252.1, 49.9, 228, @ahora - INTERVAL 11 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:03:66:7E')),
  (64.8, 4.62, 78.0, 53.4, 231, @ahora - INTERVAL 10 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:03:66:7E')),
  (38.2, 4.49, 98.3, 68.6, 233, @ahora - INTERVAL 9 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:03:66:7E')),
  (32.9, 3.19, 100.7, 22.4, 176, @ahora - INTERVAL 8 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:03:66:7E')),
  (30.3, 3.44, 165.0, 69.5, 182, @ahora - INTERVAL 7 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:03:66:7E')),
  (50.1, 5.36, 167.7, 74.6, 230, @ahora - INTERVAL 6 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:03:66:7E')),
  (32.2, 3.55, 290.7, 13.2, 153, @ahora - INTERVAL 5 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:03:66:7E')),
  (50.4, 3.32, 102.6, 16.4, 152, @ahora - INTERVAL 4 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:03:66:7E')),
  (36.6, 5.43, 279.5, 42.4, 173, @ahora - INTERVAL 3 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:03:66:7E')),
  (45.5, 3.72, 194.9, 34.1, 205, @ahora - INTERVAL 2 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:03:66:7E')),
  (15.6, 4.92, 359.5, 30.2, 235, @ahora - INTERVAL 1 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:03:66:7E'));
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES (55.5, 5.28, 144.4, 9.2, 204, (SELECT ultima_senal FROM equipo WHERE direccion_mac = '02:5E:38:03:66:7E'), (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:38:03:66:7E'));
INSERT INTO almacenamiento (punto_montaje, capacidad_total_gb, espacio_libre_gb, id_informe) VALUES ('C:', 512, 201.4, LAST_INSERT_ID());
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES
  (29.7, 3.52, 97.9, 26.0, 198, @ahora - INTERVAL 24 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:00:73:7F')),
  (24.0, 4.87, 262.8, 28.5, 155, @ahora - INTERVAL 23 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:00:73:7F')),
  (47.0, 3.15, 216.4, 14.6, 167, @ahora - INTERVAL 22 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:00:73:7F')),
  (30.1, 3.2, 390.6, 44.9, 230, @ahora - INTERVAL 21 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:00:73:7F')),
  (45.5, 4.7, 25.6, 23.1, 179, @ahora - INTERVAL 20 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:00:73:7F')),
  (25.8, 4.0, 45.0, 50.3, 235, @ahora - INTERVAL 19 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:00:73:7F')),
  (40.5, 3.24, 46.1, 35.3, 240, @ahora - INTERVAL 18 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:00:73:7F')),
  (26.6, 3.86, 328.7, 23.1, 201, @ahora - INTERVAL 17 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:00:73:7F')),
  (27.1, 3.17, 137.8, 27.3, 180, @ahora - INTERVAL 16 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:00:73:7F')),
  (42.3, 4.45, 374.3, 67.4, 140, @ahora - INTERVAL 15 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:00:73:7F')),
  (60.8, 4.04, 117.8, 71.7, 191, @ahora - INTERVAL 14 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:00:73:7F')),
  (50.5, 3.17, 286.8, 35.1, 159, @ahora - INTERVAL 13 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:00:73:7F')),
  (75.1, 5.12, 86.8, 30.5, 143, @ahora - INTERVAL 12 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:00:73:7F')),
  (42.3, 5.47, 139.2, 40.1, 189, @ahora - INTERVAL 11 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:00:73:7F')),
  (38.5, 3.71, 185.9, 66.7, 245, @ahora - INTERVAL 10 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:00:73:7F')),
  (53.3, 3.62, 358.3, 36.8, 167, @ahora - INTERVAL 9 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:00:73:7F')),
  (17.0, 4.55, 150.7, 15.2, 197, @ahora - INTERVAL 8 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:00:73:7F')),
  (43.9, 3.19, 188.2, 30.3, 157, @ahora - INTERVAL 7 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:00:73:7F')),
  (37.7, 3.58, 111.4, 23.1, 258, @ahora - INTERVAL 6 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:00:73:7F')),
  (44.0, 3.08, 305.0, 31.5, 247, @ahora - INTERVAL 5 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:00:73:7F')),
  (13.5, 4.12, 308.2, 34.1, 168, @ahora - INTERVAL 4 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:00:73:7F')),
  (19.2, 3.31, 201.0, 78.6, 155, @ahora - INTERVAL 3 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:00:73:7F')),
  (51.0, 2.99, 134.6, 79.6, 143, @ahora - INTERVAL 2 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:00:73:7F')),
  (9.7, 4.46, 243.0, 40.2, 206, @ahora - INTERVAL 1 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:00:73:7F'));
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES (20.1, 3.62, 303.3, 33.5, 224, (SELECT ultima_senal FROM equipo WHERE direccion_mac = '02:5E:26:00:73:7F'), (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:00:73:7F'));
INSERT INTO almacenamiento (punto_montaje, capacidad_total_gb, espacio_libre_gb, id_informe) VALUES ('C:', 1000, 305.9, LAST_INSERT_ID());
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES
  (12.4, 6.77, 85.4, 41.7, 175, @ahora - INTERVAL 24 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:25:80:80')),
  (22.1, 6.54, 118.2, 68.6, 158, @ahora - INTERVAL 23 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:25:80:80')),
  (37.5, 7.15, 80.3, 16.2, 174, @ahora - INTERVAL 22 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:25:80:80')),
  (26.3, 7.99, 197.2, 28.2, 154, @ahora - INTERVAL 21 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:25:80:80')),
  (47.1, 8.94, 361.3, 8.4, 160, @ahora - INTERVAL 20 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:25:80:80')),
  (29.7, 11.1, 244.8, 36.2, 239, @ahora - INTERVAL 19 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:25:80:80')),
  (33.0, 9.82, 87.8, 71.5, 188, @ahora - INTERVAL 18 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:25:80:80')),
  (53.2, 8.71, 340.3, 53.8, 230, @ahora - INTERVAL 17 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:25:80:80')),
  (10.2, 9.92, 153.3, 3.0, 143, @ahora - INTERVAL 16 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:25:80:80')),
  (66.2, 9.55, 221.8, 39.2, 231, @ahora - INTERVAL 15 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:25:80:80')),
  (51.3, 6.41, 141.6, 9.9, 245, @ahora - INTERVAL 14 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:25:80:80')),
  (80.0, 9.65, 319.2, 74.9, 236, @ahora - INTERVAL 13 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:25:80:80')),
  (60.8, 8.64, 123.7, 45.2, 201, @ahora - INTERVAL 12 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:25:80:80')),
  (79.3, 10.76, 72.4, 52.9, 212, @ahora - INTERVAL 11 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:25:80:80')),
  (49.6, 9.22, 313.3, 12.6, 157, @ahora - INTERVAL 10 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:25:80:80')),
  (62.2, 10.84, 218.7, 23.6, 207, @ahora - INTERVAL 9 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:25:80:80')),
  (29.8, 9.67, 355.9, 51.6, 146, @ahora - INTERVAL 8 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:25:80:80')),
  (11.3, 7.2, 383.8, 40.5, 151, @ahora - INTERVAL 7 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:25:80:80')),
  (52.8, 10.97, 56.9, 16.3, 246, @ahora - INTERVAL 6 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:25:80:80')),
  (8.5, 8.67, 178.2, 45.9, 230, @ahora - INTERVAL 5 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:25:80:80')),
  (17.7, 6.68, 383.2, 46.3, 167, @ahora - INTERVAL 4 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:25:80:80')),
  (37.3, 6.23, 49.3, 37.4, 260, @ahora - INTERVAL 3 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:25:80:80')),
  (16.2, 7.0, 306.3, 12.3, 164, @ahora - INTERVAL 2 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:25:80:80')),
  (37.8, 7.68, 358.1, 12.9, 229, @ahora - INTERVAL 1 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:25:80:80'));
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES (33.2, 7.44, 338.8, 79.4, 255, (SELECT ultima_senal FROM equipo WHERE direccion_mac = '02:5E:26:25:80:80'), (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:25:80:80'));
INSERT INTO almacenamiento (punto_montaje, capacidad_total_gb, espacio_libre_gb, id_informe) VALUES ('C:', 256, 91.5, LAST_INSERT_ID());
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES
  (46.9, 6.99, 64.2, 37.4, 194, @ahora - INTERVAL 24 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:4A:8D:81')),
  (10.4, 6.59, 108.1, 59.3, 154, @ahora - INTERVAL 23 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:4A:8D:81')),
  (45.6, 8.09, 122.7, 8.5, 208, @ahora - INTERVAL 22 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:4A:8D:81')),
  (42.7, 9.64, 71.5, 68.9, 194, @ahora - INTERVAL 21 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:4A:8D:81')),
  (38.4, 10.46, 16.3, 69.9, 158, @ahora - INTERVAL 20 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:4A:8D:81')),
  (50.2, 8.59, 200.4, 5.8, 172, @ahora - INTERVAL 19 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:4A:8D:81')),
  (17.1, 7.52, 188.4, 11.2, 144, @ahora - INTERVAL 18 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:4A:8D:81')),
  (17.0, 9.79, 86.4, 18.8, 203, @ahora - INTERVAL 17 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:4A:8D:81')),
  (28.7, 9.65, 62.0, 79.7, 183, @ahora - INTERVAL 16 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:4A:8D:81')),
  (66.1, 6.28, 376.9, 28.3, 256, @ahora - INTERVAL 15 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:4A:8D:81')),
  (48.7, 6.75, 247.3, 32.7, 252, @ahora - INTERVAL 14 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:4A:8D:81')),
  (43.9, 9.65, 29.5, 38.9, 218, @ahora - INTERVAL 13 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:4A:8D:81')),
  (37.3, 5.71, 135.9, 20.3, 234, @ahora - INTERVAL 12 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:4A:8D:81')),
  (36.1, 7.83, 315.2, 6.7, 163, @ahora - INTERVAL 11 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:4A:8D:81')),
  (49.8, 7.75, 76.8, 42.9, 217, @ahora - INTERVAL 10 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:4A:8D:81')),
  (50.7, 8.67, 133.0, 76.9, 216, @ahora - INTERVAL 9 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:4A:8D:81')),
  (47.0, 10.83, 226.2, 30.4, 157, @ahora - INTERVAL 8 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:4A:8D:81')),
  (34.0, 6.08, 349.2, 12.5, 142, @ahora - INTERVAL 7 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:4A:8D:81')),
  (23.7, 8.13, 302.0, 28.0, 205, @ahora - INTERVAL 6 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:4A:8D:81')),
  (22.5, 8.04, 131.5, 10.9, 176, @ahora - INTERVAL 5 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:4A:8D:81')),
  (20.4, 8.64, 97.0, 13.3, 219, @ahora - INTERVAL 4 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:4A:8D:81')),
  (46.9, 6.52, 19.3, 70.0, 228, @ahora - INTERVAL 3 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:4A:8D:81')),
  (27.2, 7.69, 326.0, 40.6, 187, @ahora - INTERVAL 2 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:4A:8D:81')),
  (21.2, 9.22, 252.3, 19.7, 155, @ahora - INTERVAL 1 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:4A:8D:81'));
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES (47.4, 9.12, 358.1, 20.1, 165, (SELECT ultima_senal FROM equipo WHERE direccion_mac = '02:5E:26:4A:8D:81'), (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:4A:8D:81'));
INSERT INTO almacenamiento (punto_montaje, capacidad_total_gb, espacio_libre_gb, id_informe) VALUES ('C:', 512, 312.8, LAST_INSERT_ID());
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES
  (12.5, 8.91, 199.8, 65.0, 260, @ahora - INTERVAL 24 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:6F:9A:82')),
  (38.4, 6.89, 42.2, 74.0, 224, @ahora - INTERVAL 23 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:6F:9A:82')),
  (38.1, 6.01, 113.3, 8.4, 238, @ahora - INTERVAL 22 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:6F:9A:82')),
  (45.8, 10.01, 44.4, 31.9, 155, @ahora - INTERVAL 21 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:6F:9A:82')),
  (18.5, 9.57, 20.0, 39.7, 196, @ahora - INTERVAL 20 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:6F:9A:82')),
  (39.5, 8.77, 203.9, 13.9, 240, @ahora - INTERVAL 19 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:6F:9A:82')),
  (47.7, 8.3, 317.7, 10.1, 147, @ahora - INTERVAL 18 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:6F:9A:82')),
  (27.5, 7.18, 319.8, 47.2, 230, @ahora - INTERVAL 17 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:6F:9A:82')),
  (8.0, 10.57, 258.6, 64.9, 185, @ahora - INTERVAL 16 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:6F:9A:82')),
  (72.7, 6.12, 341.1, 60.8, 199, @ahora - INTERVAL 15 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:6F:9A:82')),
  (71.8, 7.25, 363.4, 43.2, 176, @ahora - INTERVAL 14 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:6F:9A:82')),
  (60.5, 9.4, 329.3, 32.5, 221, @ahora - INTERVAL 13 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:6F:9A:82')),
  (77.8, 7.94, 36.3, 25.0, 178, @ahora - INTERVAL 12 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:6F:9A:82')),
  (63.9, 9.76, 92.8, 77.9, 212, @ahora - INTERVAL 11 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:6F:9A:82')),
  (72.5, 8.76, 199.5, 76.7, 164, @ahora - INTERVAL 10 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:6F:9A:82')),
  (76.6, 7.15, 175.7, 7.2, 225, @ahora - INTERVAL 9 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:6F:9A:82')),
  (21.9, 8.21, 245.4, 22.7, 195, @ahora - INTERVAL 8 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:6F:9A:82')),
  (23.9, 9.71, 5.4, 74.4, 165, @ahora - INTERVAL 7 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:6F:9A:82')),
  (17.9, 10.84, 67.0, 79.6, 145, @ahora - INTERVAL 6 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:6F:9A:82')),
  (38.6, 9.43, 380.4, 8.3, 219, @ahora - INTERVAL 5 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:6F:9A:82')),
  (30.0, 8.32, 355.1, 68.8, 148, @ahora - INTERVAL 4 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:6F:9A:82')),
  (43.6, 10.82, 52.9, 40.0, 145, @ahora - INTERVAL 3 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:6F:9A:82')),
  (49.8, 8.47, 248.7, 34.9, 195, @ahora - INTERVAL 2 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:6F:9A:82')),
  (44.8, 6.92, 52.4, 31.5, 216, @ahora - INTERVAL 1 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:6F:9A:82'));
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES (25.7, 7.22, 171.8, 21.2, 187, (SELECT ultima_senal FROM equipo WHERE direccion_mac = '02:5E:26:6F:9A:82'), (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:6F:9A:82'));
INSERT INTO almacenamiento (punto_montaje, capacidad_total_gb, espacio_libre_gb, id_informe) VALUES ('C:', 512, 217.7, LAST_INSERT_ID());
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES
  (36.2, 14.78, 281.6, 29.1, 158, @ahora - INTERVAL 24 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:94:A7:83')),
  (35.3, 16.47, 252.4, 53.8, 257, @ahora - INTERVAL 23 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:94:A7:83')),
  (31.5, 21.08, 370.1, 48.7, 173, @ahora - INTERVAL 22 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:94:A7:83')),
  (8.9, 19.87, 206.8, 32.1, 220, @ahora - INTERVAL 21 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:94:A7:83')),
  (23.9, 17.04, 67.6, 37.8, 165, @ahora - INTERVAL 20 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:94:A7:83')),
  (31.0, 18.6, 30.0, 71.2, 206, @ahora - INTERVAL 19 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:94:A7:83')),
  (32.9, 20.4, 24.3, 19.7, 199, @ahora - INTERVAL 18 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:94:A7:83')),
  (26.2, 16.72, 384.5, 70.0, 251, @ahora - INTERVAL 17 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:94:A7:83')),
  (23.4, 17.3, 104.4, 74.4, 176, @ahora - INTERVAL 16 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:94:A7:83')),
  (69.6, 13.27, 295.3, 37.5, 224, @ahora - INTERVAL 15 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:94:A7:83')),
  (59.5, 17.41, 178.1, 12.2, 184, @ahora - INTERVAL 14 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:94:A7:83')),
  (72.7, 12.08, 131.7, 78.7, 190, @ahora - INTERVAL 13 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:94:A7:83')),
  (54.3, 12.7, 360.3, 17.4, 248, @ahora - INTERVAL 12 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:94:A7:83')),
  (71.4, 13.72, 109.3, 77.9, 162, @ahora - INTERVAL 11 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:94:A7:83')),
  (39.5, 17.56, 193.4, 32.4, 147, @ahora - INTERVAL 10 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:94:A7:83')),
  (65.3, 12.54, 277.5, 14.2, 175, @ahora - INTERVAL 9 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:94:A7:83')),
  (40.1, 21.45, 275.0, 4.1, 257, @ahora - INTERVAL 8 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:94:A7:83')),
  (27.3, 22.39, 286.4, 48.0, 239, @ahora - INTERVAL 7 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:94:A7:83')),
  (25.4, 19.54, 218.2, 53.9, 155, @ahora - INTERVAL 6 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:94:A7:83')),
  (44.1, 11.66, 31.9, 38.6, 196, @ahora - INTERVAL 5 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:94:A7:83')),
  (19.4, 17.2, 41.9, 75.4, 220, @ahora - INTERVAL 4 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:94:A7:83')),
  (16.5, 13.97, 105.2, 30.1, 239, @ahora - INTERVAL 3 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:94:A7:83')),
  (50.2, 13.98, 277.2, 62.3, 237, @ahora - INTERVAL 2 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:94:A7:83')),
  (32.8, 18.31, 397.2, 3.9, 253, @ahora - INTERVAL 1 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:94:A7:83'));
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES (28.6, 21.93, 348.1, 26.6, 218, (SELECT ultima_senal FROM equipo WHERE direccion_mac = '02:5E:26:94:A7:83'), (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:94:A7:83'));
INSERT INTO almacenamiento (punto_montaje, capacidad_total_gb, espacio_libre_gb, id_informe) VALUES ('C:', 1000, 541.5, LAST_INSERT_ID());
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES
  (15.9, 3.42, 126.6, 3.9, 229, @ahora - INTERVAL 24 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:B9:B4:84')),
  (15.8, 5.28, 242.1, 24.1, 254, @ahora - INTERVAL 23 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:B9:B4:84')),
  (39.6, 3.87, 142.0, 45.0, 150, @ahora - INTERVAL 22 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:B9:B4:84')),
  (53.8, 3.13, 289.6, 56.6, 257, @ahora - INTERVAL 21 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:B9:B4:84')),
  (38.3, 3.79, 356.7, 61.5, 150, @ahora - INTERVAL 20 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:B9:B4:84')),
  (17.4, 3.44, 117.8, 68.9, 197, @ahora - INTERVAL 19 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:B9:B4:84')),
  (54.8, 3.17, 313.1, 20.8, 196, @ahora - INTERVAL 18 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:B9:B4:84')),
  (24.9, 3.07, 84.3, 33.6, 196, @ahora - INTERVAL 17 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:B9:B4:84')),
  (32.2, 3.4, 139.9, 46.9, 201, @ahora - INTERVAL 16 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:B9:B4:84')),
  (62.3, 5.34, 172.8, 55.5, 211, @ahora - INTERVAL 15 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:B9:B4:84')),
  (64.2, 5.35, 388.0, 75.8, 169, @ahora - INTERVAL 14 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:B9:B4:84')),
  (42.7, 3.85, 151.7, 32.8, 194, @ahora - INTERVAL 13 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:B9:B4:84')),
  (38.2, 3.58, 323.2, 34.2, 257, @ahora - INTERVAL 12 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:B9:B4:84')),
  (70.2, 3.87, 91.8, 62.9, 188, @ahora - INTERVAL 11 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:B9:B4:84')),
  (62.2, 5.21, 5.2, 50.2, 232, @ahora - INTERVAL 10 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:B9:B4:84')),
  (40.4, 3.4, 209.4, 40.6, 181, @ahora - INTERVAL 9 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:B9:B4:84')),
  (22.6, 4.01, 197.0, 7.9, 148, @ahora - INTERVAL 8 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:B9:B4:84')),
  (8.8, 4.14, 129.8, 39.9, 181, @ahora - INTERVAL 7 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:B9:B4:84')),
  (46.0, 3.8, 9.7, 12.4, 159, @ahora - INTERVAL 6 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:B9:B4:84')),
  (41.7, 3.71, 60.4, 14.2, 164, @ahora - INTERVAL 5 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:B9:B4:84')),
  (8.4, 2.81, 170.8, 71.8, 194, @ahora - INTERVAL 4 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:B9:B4:84')),
  (39.9, 4.11, 335.4, 32.7, 159, @ahora - INTERVAL 3 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:B9:B4:84')),
  (14.5, 3.04, 233.9, 2.5, 150, @ahora - INTERVAL 2 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:B9:B4:84')),
  (52.6, 4.29, 301.6, 41.4, 211, @ahora - INTERVAL 1 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:B9:B4:84'));
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES (20.0, 4.6, 382.4, 59.2, 175, (SELECT ultima_senal FROM equipo WHERE direccion_mac = '02:5E:26:B9:B4:84'), (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:26:B9:B4:84'));
INSERT INTO almacenamiento (punto_montaje, capacidad_total_gb, espacio_libre_gb, id_informe) VALUES ('C:', 256, 124.5, LAST_INSERT_ID());
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES
  (9.4, 5.23, 122.1, 64.9, 254, @ahora - INTERVAL 24 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:02:00:C1:85')),
  (29.2, 3.91, 109.5, 15.6, 189, @ahora - INTERVAL 23 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:02:00:C1:85')),
  (8.4, 4.16, 98.9, 4.0, 222, @ahora - INTERVAL 22 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:02:00:C1:85')),
  (54.0, 5.31, 325.6, 11.2, 252, @ahora - INTERVAL 21 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:02:00:C1:85')),
  (12.4, 3.29, 250.9, 22.8, 163, @ahora - INTERVAL 20 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:02:00:C1:85')),
  (21.1, 3.48, 235.4, 68.0, 150, @ahora - INTERVAL 19 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:02:00:C1:85')),
  (29.8, 4.5, 371.6, 10.0, 176, @ahora - INTERVAL 18 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:02:00:C1:85')),
  (53.9, 5.42, 192.5, 47.6, 142, @ahora - INTERVAL 17 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:02:00:C1:85')),
  (45.6, 5.22, 130.9, 11.9, 245, @ahora - INTERVAL 16 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:02:00:C1:85')),
  (44.0, 3.14, 140.6, 39.7, 211, @ahora - INTERVAL 15 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:02:00:C1:85')),
  (62.0, 3.83, 13.0, 52.9, 232, @ahora - INTERVAL 14 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:02:00:C1:85')),
  (35.3, 5.44, 372.9, 36.7, 160, @ahora - INTERVAL 13 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:02:00:C1:85')),
  (68.7, 2.82, 289.3, 55.7, 186, @ahora - INTERVAL 12 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:02:00:C1:85')),
  (77.2, 4.07, 315.5, 50.9, 165, @ahora - INTERVAL 11 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:02:00:C1:85')),
  (73.0, 3.82, 394.9, 11.3, 190, @ahora - INTERVAL 10 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:02:00:C1:85')),
  (37.7, 5.36, 131.1, 11.3, 179, @ahora - INTERVAL 9 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:02:00:C1:85')),
  (53.8, 5.24, 265.5, 68.3, 227, @ahora - INTERVAL 8 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:02:00:C1:85')),
  (21.0, 3.16, 317.0, 77.9, 186, @ahora - INTERVAL 7 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:02:00:C1:85')),
  (52.3, 3.56, 313.8, 43.3, 147, @ahora - INTERVAL 6 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:02:00:C1:85')),
  (25.9, 2.82, 132.9, 9.5, 217, @ahora - INTERVAL 5 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:02:00:C1:85')),
  (36.6, 4.47, 291.8, 30.8, 185, @ahora - INTERVAL 4 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:02:00:C1:85')),
  (21.9, 3.65, 380.6, 21.5, 182, @ahora - INTERVAL 3 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:02:00:C1:85')),
  (45.0, 3.22, 231.2, 46.9, 211, @ahora - INTERVAL 2 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:02:00:C1:85')),
  (14.7, 4.39, 319.3, 32.8, 192, @ahora - INTERVAL 1 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:02:00:C1:85'));
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES (16.1, 5.0, 108.4, 35.3, 196, (SELECT ultima_senal FROM equipo WHERE direccion_mac = '02:5E:02:00:C1:85'), (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:02:00:C1:85'));
INSERT INTO almacenamiento (punto_montaje, capacidad_total_gb, espacio_libre_gb, id_informe) VALUES ('C:', 512, 354.3, LAST_INSERT_ID());
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES (36.5, 8.07, 29.8, 56.9, 192, (SELECT ultima_senal FROM equipo WHERE direccion_mac = '02:5E:02:25:CE:86'), (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:02:25:CE:86'));
INSERT INTO almacenamiento (punto_montaje, capacidad_total_gb, espacio_libre_gb, id_informe) VALUES ('C:', 512, 136.2, LAST_INSERT_ID());
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES (46.7, 10.22, 337.9, 75.9, 193, (SELECT ultima_senal FROM equipo WHERE direccion_mac = '02:5E:02:4A:DB:87'), (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:02:4A:DB:87'));
INSERT INTO almacenamiento (punto_montaje, capacidad_total_gb, espacio_libre_gb, id_informe) VALUES ('C:', 1000, 693.2, LAST_INSERT_ID());
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES (38.0, 6.42, 20.5, 46.7, 200, (SELECT ultima_senal FROM equipo WHERE direccion_mac = '02:5E:02:6F:E8:88'), (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:02:6F:E8:88'));
INSERT INTO almacenamiento (punto_montaje, capacidad_total_gb, espacio_libre_gb, id_informe) VALUES ('C:', 256, 104.2, LAST_INSERT_ID());
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES
  (9.0, 19.44, 103.8, 16.2, 252, @ahora - INTERVAL 24 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:02:94:F5:89')),
  (36.0, 20.58, 257.2, 61.3, 171, @ahora - INTERVAL 23 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:02:94:F5:89')),
  (55.0, 17.63, 344.0, 61.1, 188, @ahora - INTERVAL 22 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:02:94:F5:89')),
  (8.8, 17.22, 102.7, 19.4, 221, @ahora - INTERVAL 21 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:02:94:F5:89')),
  (36.6, 20.61, 174.4, 60.3, 148, @ahora - INTERVAL 20 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:02:94:F5:89')),
  (31.1, 16.49, 68.5, 31.2, 230, @ahora - INTERVAL 19 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:02:94:F5:89')),
  (11.9, 16.89, 267.4, 62.4, 214, @ahora - INTERVAL 18 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:02:94:F5:89')),
  (25.2, 20.36, 381.4, 51.6, 144, @ahora - INTERVAL 17 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:02:94:F5:89')),
  (13.7, 12.97, 146.2, 33.0, 247, @ahora - INTERVAL 16 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:02:94:F5:89')),
  (48.3, 22.27, 36.3, 6.4, 168, @ahora - INTERVAL 15 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:02:94:F5:89')),
  (57.9, 13.07, 210.6, 69.7, 155, @ahora - INTERVAL 14 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:02:94:F5:89')),
  (67.2, 21.91, 391.0, 23.8, 252, @ahora - INTERVAL 13 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:02:94:F5:89')),
  (71.6, 14.43, 51.2, 41.6, 225, @ahora - INTERVAL 12 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:02:94:F5:89')),
  (46.2, 17.23, 31.5, 76.5, 155, @ahora - INTERVAL 11 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:02:94:F5:89')),
  (75.6, 11.68, 59.2, 45.0, 171, @ahora - INTERVAL 10 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:02:94:F5:89')),
  (75.3, 11.48, 188.5, 61.3, 167, @ahora - INTERVAL 9 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:02:94:F5:89')),
  (46.7, 15.01, 76.5, 70.0, 175, @ahora - INTERVAL 8 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:02:94:F5:89')),
  (52.5, 20.94, 137.6, 5.5, 202, @ahora - INTERVAL 7 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:02:94:F5:89')),
  (44.6, 14.6, 315.4, 67.6, 241, @ahora - INTERVAL 6 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:02:94:F5:89')),
  (20.3, 22.1, 323.8, 44.9, 174, @ahora - INTERVAL 5 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:02:94:F5:89')),
  (53.6, 17.7, 70.9, 25.3, 187, @ahora - INTERVAL 4 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:02:94:F5:89')),
  (37.7, 17.14, 281.0, 26.0, 191, @ahora - INTERVAL 3 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:02:94:F5:89')),
  (17.2, 20.66, 296.5, 61.4, 259, @ahora - INTERVAL 2 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:02:94:F5:89')),
  (39.3, 16.12, 327.7, 19.3, 230, @ahora - INTERVAL 1 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:02:94:F5:89'));
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES (56.5, 29.19, 287.5, 61.9, 243, (SELECT ultima_senal FROM equipo WHERE direccion_mac = '02:5E:02:94:F5:89'), (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:02:94:F5:89'));
INSERT INTO almacenamiento (punto_montaje, capacidad_total_gb, espacio_libre_gb, id_informe) VALUES ('C:', 512, 27.3, LAST_INSERT_ID());
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES
  (11.6, 4.06, 299.1, 6.9, 260, @ahora - INTERVAL 24 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:02:B9:02:8A')),
  (28.0, 5.59, 261.7, 9.6, 208, @ahora - INTERVAL 23 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:02:B9:02:8A')),
  (36.2, 3.33, 151.6, 50.8, 190, @ahora - INTERVAL 22 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:02:B9:02:8A')),
  (51.4, 4.28, 219.2, 48.2, 210, @ahora - INTERVAL 21 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:02:B9:02:8A')),
  (35.9, 4.06, 221.3, 55.2, 184, @ahora - INTERVAL 20 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:02:B9:02:8A')),
  (10.2, 3.45, 288.3, 27.1, 144, @ahora - INTERVAL 19 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:02:B9:02:8A')),
  (23.5, 3.52, 105.1, 6.5, 227, @ahora - INTERVAL 18 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:02:B9:02:8A')),
  (27.1, 3.45, 206.5, 21.4, 183, @ahora - INTERVAL 17 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:02:B9:02:8A')),
  (18.7, 5.03, 240.8, 16.4, 222, @ahora - INTERVAL 16 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:02:B9:02:8A')),
  (72.0, 3.38, 146.1, 64.4, 214, @ahora - INTERVAL 15 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:02:B9:02:8A')),
  (50.0, 3.7, 55.5, 4.7, 163, @ahora - INTERVAL 14 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:02:B9:02:8A')),
  (60.3, 3.54, 131.4, 71.7, 243, @ahora - INTERVAL 13 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:02:B9:02:8A')),
  (58.2, 3.37, 396.9, 46.1, 223, @ahora - INTERVAL 12 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:02:B9:02:8A')),
  (58.5, 3.3, 24.5, 16.9, 151, @ahora - INTERVAL 11 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:02:B9:02:8A')),
  (61.5, 5.43, 128.7, 44.3, 172, @ahora - INTERVAL 10 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:02:B9:02:8A')),
  (50.3, 4.6, 290.2, 30.3, 198, @ahora - INTERVAL 9 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:02:B9:02:8A')),
  (25.8, 5.59, 90.1, 77.2, 193, @ahora - INTERVAL 8 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:02:B9:02:8A')),
  (15.7, 2.81, 5.3, 20.5, 210, @ahora - INTERVAL 7 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:02:B9:02:8A')),
  (45.4, 5.15, 301.1, 13.6, 237, @ahora - INTERVAL 6 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:02:B9:02:8A')),
  (37.6, 5.1, 205.2, 58.5, 161, @ahora - INTERVAL 5 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:02:B9:02:8A')),
  (21.2, 4.95, 64.7, 72.4, 153, @ahora - INTERVAL 4 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:02:B9:02:8A')),
  (49.2, 4.56, 295.4, 13.5, 254, @ahora - INTERVAL 3 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:02:B9:02:8A')),
  (51.0, 5.44, 383.5, 42.7, 234, @ahora - INTERVAL 2 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:02:B9:02:8A')),
  (39.2, 2.89, 310.4, 45.4, 161, @ahora - INTERVAL 1 HOUR, (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:02:B9:02:8A'));
INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos, fecha_registro, id_equipo) VALUES (92.1, 3.89, 16.1, 56.2, 260, (SELECT ultima_senal FROM equipo WHERE direccion_mac = '02:5E:02:B9:02:8A'), (SELECT id_equipo FROM equipo WHERE direccion_mac = '02:5E:02:B9:02:8A'));
INSERT INTO almacenamiento (punto_montaje, capacidad_total_gb, espacio_libre_gb, id_informe) VALUES ('C:', 512, 23.9, LAST_INSERT_ID());

-- ---------- 6. Alertas ----------
INSERT INTO alerta (tipo_alerta, nivel_gravedad, descripcion, fecha_generacion, estado, id_equipo, id_umbral_alerta) SELECT 'UsoAnomalo', 'Informativa', 'Uso de CPU alto (ya atendida)', @ahora - INTERVAL 7 DAY, 'Atendida', id_equipo, @u_cpu FROM equipo WHERE direccion_mac = '02:5E:0B:B9:4E:06';
INSERT INTO alerta (tipo_alerta, nivel_gravedad, descripcion, fecha_generacion, estado, id_equipo, id_umbral_alerta) SELECT 'RiesgoSeguridad', 'Critica', 'Software no autorizado detectado', @ahora - INTERVAL 13 DAY, 'Atendida', id_equipo, @u_cpu FROM equipo WHERE direccion_mac = '02:5E:0B:72:8F:0B';
INSERT INTO alerta (tipo_alerta, nivel_gravedad, descripcion, fecha_generacion, estado, id_equipo, id_umbral_alerta) SELECT 'UsoAnomalo', 'Informativa', 'Uso de CPU alto (ya atendida)', @ahora - INTERVAL 13 DAY, 'Atendida', id_equipo, @u_cpu FROM equipo WHERE direccion_mac = '02:5E:0B:97:9C:0C';
INSERT INTO alerta (tipo_alerta, nivel_gravedad, descripcion, fecha_generacion, estado, id_equipo, id_umbral_alerta) SELECT 'Desconexion', 'Advertencia', 'El agente dejó de reportar', @ahora - INTERVAL 18 HOUR, 'Activa', id_equipo, @u_desc FROM equipo WHERE direccion_mac = '02:5E:0B:2B:D0:10';
INSERT INTO alerta (tipo_alerta, nivel_gravedad, descripcion, fecha_generacion, estado, id_equipo, id_umbral_alerta) SELECT 'UsoAnomalo', 'Advertencia', 'Disco C: con menos de 10 % libre', @ahora - INTERVAL 22 MINUTE, 'Activa', id_equipo, @u_disc FROM equipo WHERE direccion_mac = '02:5E:0B:50:DD:11';
INSERT INTO alerta (tipo_alerta, nivel_gravedad, descripcion, fecha_generacion, estado, id_equipo, id_umbral_alerta) SELECT 'UsoAnomalo', 'Critica', 'Uso de CPU arriba de 90 % por más de 5 minutos', @ahora - INTERVAL 23 MINUTE, 'Activa', id_equipo, @u_cpu FROM equipo WHERE direccion_mac = '02:5E:0B:75:EA:12';
INSERT INTO alerta (tipo_alerta, nivel_gravedad, descripcion, fecha_generacion, estado, id_equipo, id_umbral_alerta) SELECT 'UsoAnomalo', 'Informativa', 'Uso de CPU alto (ya atendida)', @ahora - INTERVAL 19 DAY, 'Atendida', id_equipo, @u_cpu FROM equipo WHERE direccion_mac = '02:5E:0B:75:EA:12';
INSERT INTO alerta (tipo_alerta, nivel_gravedad, descripcion, fecha_generacion, estado, id_equipo, id_umbral_alerta) SELECT 'RiesgoSeguridad', 'Critica', 'Software no autorizado detectado', @ahora - INTERVAL 4 DAY, 'Atendida', id_equipo, @u_cpu FROM equipo WHERE direccion_mac = '02:5E:0B:09:1E:16';
INSERT INTO alerta (tipo_alerta, nivel_gravedad, descripcion, fecha_generacion, estado, id_equipo, id_umbral_alerta) SELECT 'UsoAnomalo', 'Informativa', 'Uso de CPU alto (ya atendida)', @ahora - INTERVAL 25 DAY, 'Atendida', id_equipo, @u_cpu FROM equipo WHERE direccion_mac = '02:5E:0B:53:38:18';
INSERT INTO alerta (tipo_alerta, nivel_gravedad, descripcion, fecha_generacion, estado, id_equipo, id_umbral_alerta) SELECT 'UsoAnomalo', 'Informativa', 'Uso de CPU alto (ya atendida)', @ahora - INTERVAL 6 DAY, 'Atendida', id_equipo, @u_cpu FROM equipo WHERE direccion_mac = '02:5E:0B:31:86:1E';
INSERT INTO alerta (tipo_alerta, nivel_gravedad, descripcion, fecha_generacion, estado, id_equipo, id_umbral_alerta) SELECT 'RiesgoSeguridad', 'Critica', 'Software no autorizado detectado', @ahora - INTERVAL 15 DAY, 'Atendida', id_equipo, @u_cpu FROM equipo WHERE direccion_mac = '02:5E:0D:4A:AD:21';
INSERT INTO alerta (tipo_alerta, nivel_gravedad, descripcion, fecha_generacion, estado, id_equipo, id_umbral_alerta) SELECT 'Desconexion', 'Advertencia', 'El agente dejó de reportar', @ahora - INTERVAL 36 HOUR, 'Activa', id_equipo, @u_desc FROM equipo WHERE direccion_mac = '02:5E:0D:6F:BA:22';
INSERT INTO alerta (tipo_alerta, nivel_gravedad, descripcion, fecha_generacion, estado, id_equipo, id_umbral_alerta) SELECT 'UsoAnomalo', 'Informativa', 'Uso de CPU alto (ya atendida)', @ahora - INTERVAL 12 DAY, 'Atendida', id_equipo, @u_cpu FROM equipo WHERE direccion_mac = '02:5E:0D:B9:D4:24';
INSERT INTO alerta (tipo_alerta, nivel_gravedad, descripcion, fecha_generacion, estado, id_equipo, id_umbral_alerta) SELECT 'UsoAnomalo', 'Advertencia', 'Uso de RAM arriba de 90 %', @ahora - INTERVAL 42 MINUTE, 'Activa', id_equipo, @u_ram FROM equipo WHERE direccion_mac = '02:5E:0D:DE:E1:25';
INSERT INTO alerta (tipo_alerta, nivel_gravedad, descripcion, fecha_generacion, estado, id_equipo, id_umbral_alerta) SELECT 'UsoAnomalo', 'Critica', 'Disco C: con menos de 10 % libre', @ahora - INTERVAL 43 MINUTE, 'Activa', id_equipo, @u_disc FROM equipo WHERE direccion_mac = '02:5E:0D:03:EE:26';
INSERT INTO alerta (tipo_alerta, nivel_gravedad, descripcion, fecha_generacion, estado, id_equipo, id_umbral_alerta) SELECT 'UsoAnomalo', 'Informativa', 'Uso de CPU alto (ya atendida)', @ahora - INTERVAL 18 DAY, 'Atendida', id_equipo, @u_cpu FROM equipo WHERE direccion_mac = '02:5E:0D:97:22:2A';
INSERT INTO alerta (tipo_alerta, nivel_gravedad, descripcion, fecha_generacion, estado, id_equipo, id_umbral_alerta) SELECT 'RiesgoSeguridad', 'Critica', 'Software no autorizado detectado', @ahora - INTERVAL 6 DAY, 'Atendida', id_equipo, @u_cpu FROM equipo WHERE direccion_mac = '02:5E:0D:E1:3C:2C';
INSERT INTO alerta (tipo_alerta, nivel_gravedad, descripcion, fecha_generacion, estado, id_equipo, id_umbral_alerta) SELECT 'UsoAnomalo', 'Informativa', 'Uso de CPU alto (ya atendida)', @ahora - INTERVAL 24 DAY, 'Atendida', id_equipo, @u_cpu FROM equipo WHERE direccion_mac = '02:5E:0D:75:70:30';
INSERT INTO alerta (tipo_alerta, nivel_gravedad, descripcion, fecha_generacion, estado, id_equipo, id_umbral_alerta) SELECT 'UsoAnomalo', 'Informativa', 'Uso de CPU alto (ya atendida)', @ahora - INTERVAL 5 DAY, 'Atendida', id_equipo, @u_cpu FROM equipo WHERE direccion_mac = '02:5E:0C:B9:BE:36';
INSERT INTO alerta (tipo_alerta, nivel_gravedad, descripcion, fecha_generacion, estado, id_equipo, id_umbral_alerta) SELECT 'Desconexion', 'Advertencia', 'El agente dejó de reportar', @ahora - INTERVAL 17 HOUR, 'Activa', id_equipo, @u_desc FROM equipo WHERE direccion_mac = '02:5E:0C:DE:CB:37';
INSERT INTO alerta (tipo_alerta, nivel_gravedad, descripcion, fecha_generacion, estado, id_equipo, id_umbral_alerta) SELECT 'RiesgoSeguridad', 'Critica', 'Software no autorizado detectado', @ahora - INTERVAL 17 DAY, 'Atendida', id_equipo, @u_cpu FROM equipo WHERE direccion_mac = '02:5E:0C:DE:CB:37';
INSERT INTO alerta (tipo_alerta, nivel_gravedad, descripcion, fecha_generacion, estado, id_equipo, id_umbral_alerta) SELECT 'UsoAnomalo', 'Advertencia', 'Uso de CPU arriba de 90 % por más de 5 minutos', @ahora - INTERVAL 12 MINUTE, 'Activa', id_equipo, @u_cpu FROM equipo WHERE direccion_mac = '02:5E:0C:28:E5:39';
INSERT INTO alerta (tipo_alerta, nivel_gravedad, descripcion, fecha_generacion, estado, id_equipo, id_umbral_alerta) SELECT 'UsoAnomalo', 'Critica', 'Uso de RAM arriba de 90 %', @ahora - INTERVAL 13 MINUTE, 'Activa', id_equipo, @u_ram FROM equipo WHERE direccion_mac = '02:5E:0C:4D:F2:3A';
INSERT INTO alerta (tipo_alerta, nivel_gravedad, descripcion, fecha_generacion, estado, id_equipo, id_umbral_alerta) SELECT 'UsoAnomalo', 'Informativa', 'Uso de CPU alto (ya atendida)', @ahora - INTERVAL 11 DAY, 'Atendida', id_equipo, @u_cpu FROM equipo WHERE direccion_mac = '02:5E:0C:97:0C:3C';
INSERT INTO alerta (tipo_alerta, nivel_gravedad, descripcion, fecha_generacion, estado, id_equipo, id_umbral_alerta) SELECT 'UsoAnomalo', 'Informativa', 'Uso de CPU alto (ya atendida)', @ahora - INTERVAL 17 DAY, 'Atendida', id_equipo, @u_cpu FROM equipo WHERE direccion_mac = '02:5E:0F:25:5A:42';
INSERT INTO alerta (tipo_alerta, nivel_gravedad, descripcion, fecha_generacion, estado, id_equipo, id_umbral_alerta) SELECT 'RiesgoSeguridad', 'Critica', 'Software no autorizado detectado', @ahora - INTERVAL 8 DAY, 'Atendida', id_equipo, @u_cpu FROM equipo WHERE direccion_mac = '02:5E:0F:25:5A:42';
INSERT INTO alerta (tipo_alerta, nivel_gravedad, descripcion, fecha_generacion, estado, id_equipo, id_umbral_alerta) SELECT 'UsoAnomalo', 'Informativa', 'Uso de CPU alto (ya atendida)', @ahora - INTERVAL 23 DAY, 'Atendida', id_equipo, @u_cpu FROM equipo WHERE direccion_mac = '02:5E:0F:03:A8:48';
INSERT INTO alerta (tipo_alerta, nivel_gravedad, descripcion, fecha_generacion, estado, id_equipo, id_umbral_alerta) SELECT 'Desconexion', 'Advertencia', 'El agente dejó de reportar', @ahora - INTERVAL 36 HOUR, 'Activa', id_equipo, @u_desc FROM equipo WHERE direccion_mac = '02:5E:0F:4D:C2:4A';
INSERT INTO alerta (tipo_alerta, nivel_gravedad, descripcion, fecha_generacion, estado, id_equipo, id_umbral_alerta) SELECT 'Desconexion', 'Advertencia', 'El agente dejó de reportar', @ahora - INTERVAL 38 HOUR, 'Activa', id_equipo, @u_desc FROM equipo WHERE direccion_mac = '02:5E:0F:97:DC:4C';
INSERT INTO alerta (tipo_alerta, nivel_gravedad, descripcion, fecha_generacion, estado, id_equipo, id_umbral_alerta) SELECT 'UsoAnomalo', 'Advertencia', 'Disco C: con menos de 10 % libre', @ahora - INTERVAL 32 MINUTE, 'Activa', id_equipo, @u_disc FROM equipo WHERE direccion_mac = '02:5E:01:00:E9:4D';
INSERT INTO alerta (tipo_alerta, nivel_gravedad, descripcion, fecha_generacion, estado, id_equipo, id_umbral_alerta) SELECT 'RiesgoSeguridad', 'Critica', 'Software no autorizado detectado', @ahora - INTERVAL 19 DAY, 'Atendida', id_equipo, @u_cpu FROM equipo WHERE direccion_mac = '02:5E:01:00:E9:4D';
INSERT INTO alerta (tipo_alerta, nivel_gravedad, descripcion, fecha_generacion, estado, id_equipo, id_umbral_alerta) SELECT 'UsoAnomalo', 'Critica', 'Uso de CPU arriba de 90 % por más de 5 minutos', @ahora - INTERVAL 33 MINUTE, 'Activa', id_equipo, @u_cpu FROM equipo WHERE direccion_mac = '02:5E:01:25:F6:4E';
INSERT INTO alerta (tipo_alerta, nivel_gravedad, descripcion, fecha_generacion, estado, id_equipo, id_umbral_alerta) SELECT 'UsoAnomalo', 'Informativa', 'Uso de CPU alto (ya atendida)', @ahora - INTERVAL 4 DAY, 'Atendida', id_equipo, @u_cpu FROM equipo WHERE direccion_mac = '02:5E:01:25:F6:4E';
INSERT INTO alerta (tipo_alerta, nivel_gravedad, descripcion, fecha_generacion, estado, id_equipo, id_umbral_alerta) SELECT 'UsoAnomalo', 'Informativa', 'Uso de CPU alto (ya atendida)', @ahora - INTERVAL 10 DAY, 'Atendida', id_equipo, @u_cpu FROM equipo WHERE direccion_mac = '02:5E:01:03:44:54';
INSERT INTO alerta (tipo_alerta, nivel_gravedad, descripcion, fecha_generacion, estado, id_equipo, id_umbral_alerta) SELECT 'RiesgoSeguridad', 'Critica', 'Software no autorizado detectado', @ahora - INTERVAL 10 DAY, 'Atendida', id_equipo, @u_cpu FROM equipo WHERE direccion_mac = '02:5E:01:97:78:58';
INSERT INTO alerta (tipo_alerta, nivel_gravedad, descripcion, fecha_generacion, estado, id_equipo, id_umbral_alerta) SELECT 'UsoAnomalo', 'Informativa', 'Uso de CPU alto (ya atendida)', @ahora - INTERVAL 16 DAY, 'Atendida', id_equipo, @u_cpu FROM equipo WHERE direccion_mac = '02:5E:01:E1:92:5A';
INSERT INTO alerta (tipo_alerta, nivel_gravedad, descripcion, fecha_generacion, estado, id_equipo, id_umbral_alerta) SELECT 'Desconexion', 'Advertencia', 'El agente dejó de reportar', @ahora - INTERVAL 16 HOUR, 'Activa', id_equipo, @u_desc FROM equipo WHERE direccion_mac = '02:5E:1A:6F:C6:5E';
INSERT INTO alerta (tipo_alerta, nivel_gravedad, descripcion, fecha_generacion, estado, id_equipo, id_umbral_alerta) SELECT 'Desconexion', 'Advertencia', 'El agente dejó de reportar', @ahora - INTERVAL 17 HOUR, 'Activa', id_equipo, @u_desc FROM equipo WHERE direccion_mac = '02:5E:1A:94:D3:5F';
INSERT INTO alerta (tipo_alerta, nivel_gravedad, descripcion, fecha_generacion, estado, id_equipo, id_umbral_alerta) SELECT 'UsoAnomalo', 'Informativa', 'Uso de CPU alto (ya atendida)', @ahora - INTERVAL 22 DAY, 'Atendida', id_equipo, @u_cpu FROM equipo WHERE direccion_mac = '02:5E:1A:B9:E0:60';
INSERT INTO alerta (tipo_alerta, nivel_gravedad, descripcion, fecha_generacion, estado, id_equipo, id_umbral_alerta) SELECT 'UsoAnomalo', 'Advertencia', 'Uso de RAM arriba de 90 %', @ahora - INTERVAL 52 MINUTE, 'Activa', id_equipo, @u_ram FROM equipo WHERE direccion_mac = '02:5E:1A:DE:ED:61';
INSERT INTO alerta (tipo_alerta, nivel_gravedad, descripcion, fecha_generacion, estado, id_equipo, id_umbral_alerta) SELECT 'UsoAnomalo', 'Critica', 'Disco C: con menos de 10 % libre', @ahora - INTERVAL 53 MINUTE, 'Activa', id_equipo, @u_disc FROM equipo WHERE direccion_mac = '02:5E:1A:03:FA:62';
INSERT INTO alerta (tipo_alerta, nivel_gravedad, descripcion, fecha_generacion, estado, id_equipo, id_umbral_alerta) SELECT 'UsoAnomalo', 'Informativa', 'Uso de CPU alto (ya atendida)', @ahora - INTERVAL 3 DAY, 'Atendida', id_equipo, @u_cpu FROM equipo WHERE direccion_mac = '02:5E:15:25:2E:66';
INSERT INTO alerta (tipo_alerta, nivel_gravedad, descripcion, fecha_generacion, estado, id_equipo, id_umbral_alerta) SELECT 'UsoAnomalo', 'Informativa', 'Uso de CPU alto (ya atendida)', @ahora - INTERVAL 9 DAY, 'Atendida', id_equipo, @u_cpu FROM equipo WHERE direccion_mac = '02:5E:15:03:7C:6C';
INSERT INTO alerta (tipo_alerta, nivel_gravedad, descripcion, fecha_generacion, estado, id_equipo, id_umbral_alerta) SELECT 'RiesgoSeguridad', 'Critica', 'Software no autorizado detectado', @ahora - INTERVAL 12 DAY, 'Atendida', id_equipo, @u_cpu FROM equipo WHERE direccion_mac = '02:5E:15:4D:96:6E';
INSERT INTO alerta (tipo_alerta, nivel_gravedad, descripcion, fecha_generacion, estado, id_equipo, id_umbral_alerta) SELECT 'UsoAnomalo', 'Informativa', 'Uso de CPU alto (ya atendida)', @ahora - INTERVAL 15 DAY, 'Atendida', id_equipo, @u_cpu FROM equipo WHERE direccion_mac = '02:5E:40:6F:CA:72';
INSERT INTO alerta (tipo_alerta, nivel_gravedad, descripcion, fecha_generacion, estado, id_equipo, id_umbral_alerta) SELECT 'Desconexion', 'Advertencia', 'El agente dejó de reportar', @ahora - INTERVAL 37 HOUR, 'Activa', id_equipo, @u_desc FROM equipo WHERE direccion_mac = '02:5E:40:94:D7:73';
INSERT INTO alerta (tipo_alerta, nivel_gravedad, descripcion, fecha_generacion, estado, id_equipo, id_umbral_alerta) SELECT 'Desconexion', 'Advertencia', 'El agente dejó de reportar', @ahora - INTERVAL 38 HOUR, 'Activa', id_equipo, @u_desc FROM equipo WHERE direccion_mac = '02:5E:40:B9:E4:74';
INSERT INTO alerta (tipo_alerta, nivel_gravedad, descripcion, fecha_generacion, estado, id_equipo, id_umbral_alerta) SELECT 'UsoAnomalo', 'Advertencia', 'Uso de CPU arriba de 90 % por más de 5 minutos', @ahora - INTERVAL 22 MINUTE, 'Activa', id_equipo, @u_cpu FROM equipo WHERE direccion_mac = '02:5E:40:DE:F1:75';
INSERT INTO alerta (tipo_alerta, nivel_gravedad, descripcion, fecha_generacion, estado, id_equipo, id_umbral_alerta) SELECT 'UsoAnomalo', 'Critica', 'Uso de RAM arriba de 90 %', @ahora - INTERVAL 23 MINUTE, 'Activa', id_equipo, @u_ram FROM equipo WHERE direccion_mac = '02:5E:40:03:FE:76';
INSERT INTO alerta (tipo_alerta, nivel_gravedad, descripcion, fecha_generacion, estado, id_equipo, id_umbral_alerta) SELECT 'UsoAnomalo', 'Informativa', 'Uso de CPU alto (ya atendida)', @ahora - INTERVAL 21 DAY, 'Atendida', id_equipo, @u_cpu FROM equipo WHERE direccion_mac = '02:5E:38:25:18:78';
INSERT INTO alerta (tipo_alerta, nivel_gravedad, descripcion, fecha_generacion, estado, id_equipo, id_umbral_alerta) SELECT 'RiesgoSeguridad', 'Critica', 'Software no autorizado detectado', @ahora - INTERVAL 3 DAY, 'Atendida', id_equipo, @u_cpu FROM equipo WHERE direccion_mac = '02:5E:38:4A:25:79';
INSERT INTO alerta (tipo_alerta, nivel_gravedad, descripcion, fecha_generacion, estado, id_equipo, id_umbral_alerta) SELECT 'UsoAnomalo', 'Informativa', 'Uso de CPU alto (ya atendida)', @ahora - INTERVAL 2 DAY, 'Atendida', id_equipo, @u_cpu FROM equipo WHERE direccion_mac = '02:5E:38:03:66:7E';
INSERT INTO alerta (tipo_alerta, nivel_gravedad, descripcion, fecha_generacion, estado, id_equipo, id_umbral_alerta) SELECT 'UsoAnomalo', 'Informativa', 'Uso de CPU alto (ya atendida)', @ahora - INTERVAL 8 DAY, 'Atendida', id_equipo, @u_cpu FROM equipo WHERE direccion_mac = '02:5E:26:B9:B4:84';
INSERT INTO alerta (tipo_alerta, nivel_gravedad, descripcion, fecha_generacion, estado, id_equipo, id_umbral_alerta) SELECT 'RiesgoSeguridad', 'Critica', 'Software no autorizado detectado', @ahora - INTERVAL 14 DAY, 'Atendida', id_equipo, @u_cpu FROM equipo WHERE direccion_mac = '02:5E:26:B9:B4:84';
INSERT INTO alerta (tipo_alerta, nivel_gravedad, descripcion, fecha_generacion, estado, id_equipo, id_umbral_alerta) SELECT 'Desconexion', 'Advertencia', 'El agente dejó de reportar', @ahora - INTERVAL 16 HOUR, 'Activa', id_equipo, @u_desc FROM equipo WHERE direccion_mac = '02:5E:02:25:CE:86';
INSERT INTO alerta (tipo_alerta, nivel_gravedad, descripcion, fecha_generacion, estado, id_equipo, id_umbral_alerta) SELECT 'Desconexion', 'Advertencia', 'El agente dejó de reportar', @ahora - INTERVAL 18 HOUR, 'Activa', id_equipo, @u_desc FROM equipo WHERE direccion_mac = '02:5E:02:6F:E8:88';
INSERT INTO alerta (tipo_alerta, nivel_gravedad, descripcion, fecha_generacion, estado, id_equipo, id_umbral_alerta) SELECT 'UsoAnomalo', 'Advertencia', 'Disco C: con menos de 10 % libre', @ahora - INTERVAL 42 MINUTE, 'Activa', id_equipo, @u_disc FROM equipo WHERE direccion_mac = '02:5E:02:94:F5:89';
INSERT INTO alerta (tipo_alerta, nivel_gravedad, descripcion, fecha_generacion, estado, id_equipo, id_umbral_alerta) SELECT 'UsoAnomalo', 'Critica', 'Uso de CPU arriba de 90 % por más de 5 minutos', @ahora - INTERVAL 43 MINUTE, 'Activa', id_equipo, @u_cpu FROM equipo WHERE direccion_mac = '02:5E:02:B9:02:8A';
INSERT INTO alerta (tipo_alerta, nivel_gravedad, descripcion, fecha_generacion, estado, id_equipo, id_umbral_alerta) SELECT 'UsoAnomalo', 'Informativa', 'Uso de CPU alto (ya atendida)', @ahora - INTERVAL 14 DAY, 'Atendida', id_equipo, @u_cpu FROM equipo WHERE direccion_mac = '02:5E:02:B9:02:8A';

-- ---------- 7. Incidencias ----------
-- Técnico: un Auxiliar si hay, si no cualquier usuario activo.
INSERT INTO incidencia (descripcion, prioridad, estado, origen, fecha_registro, fecha_resolucion, id_alerta, id_equipo, id_usuario) SELECT 'El equipo no enciende después del corte de luz', 'Alta', 'Abierta', 'Manual', @ahora - INTERVAL 1 DAY, NULL, NULL, id_equipo, COALESCE((SELECT u.id_usuario FROM usuario u JOIN rol r ON r.id_rol = u.id_rol WHERE r.nombre = 'Auxiliar' AND u.esta_activo = 1 ORDER BY u.id_usuario LIMIT 1 OFFSET 0), (SELECT MIN(id_usuario) FROM usuario WHERE esta_activo = 1)) FROM equipo WHERE direccion_mac = '02:5E:0B:00:0D:01';
INSERT INTO incidencia (descripcion, prioridad, estado, origen, fecha_registro, fecha_resolucion, id_alerta, id_equipo, id_usuario) SELECT 'Lentitud al abrir el expediente clínico', 'Media', 'EnProceso', 'Manual', @ahora - INTERVAL 4 DAY, NULL, NULL, id_equipo, COALESCE((SELECT u.id_usuario FROM usuario u JOIN rol r ON r.id_rol = u.id_rol WHERE r.nombre = 'Auxiliar' AND u.esta_activo = 1 ORDER BY u.id_usuario LIMIT 1 OFFSET 1), (SELECT MIN(id_usuario) FROM usuario WHERE esta_activo = 1)) FROM equipo WHERE direccion_mac = '02:5E:0B:4D:82:0A';
INSERT INTO incidencia (descripcion, prioridad, estado, origen, fecha_registro, fecha_resolucion, id_alerta, id_equipo, id_usuario) SELECT 'No imprime en la impresora del consultorio', 'Baja', 'EnProceso', 'Manual', @ahora - INTERVAL 7 DAY, NULL, NULL, id_equipo, COALESCE((SELECT u.id_usuario FROM usuario u JOIN rol r ON r.id_rol = u.id_rol WHERE r.nombre = 'Auxiliar' AND u.esta_activo = 1 ORDER BY u.id_usuario LIMIT 1 OFFSET 2), (SELECT MIN(id_usuario) FROM usuario WHERE esta_activo = 1)) FROM equipo WHERE direccion_mac = '02:5E:0B:BF:04:14';
INSERT INTO incidencia (descripcion, prioridad, estado, origen, fecha_registro, fecha_resolucion, id_alerta, id_equipo, id_usuario) SELECT 'Pantalla azul al iniciar Windows', 'Alta', 'Resuelta', 'Manual', @ahora - INTERVAL 10 DAY, @ahora - INTERVAL 9 DAY, NULL, id_equipo, COALESCE((SELECT u.id_usuario FROM usuario u JOIN rol r ON r.id_rol = u.id_rol WHERE r.nombre = 'Auxiliar' AND u.esta_activo = 1 ORDER BY u.id_usuario LIMIT 1 OFFSET 0), (SELECT MIN(id_usuario) FROM usuario WHERE esta_activo = 1)) FROM equipo WHERE direccion_mac = '02:5E:0B:0C:79:1D';
INSERT INTO incidencia (descripcion, prioridad, estado, origen, fecha_registro, fecha_resolucion, id_alerta, id_equipo, id_usuario) SELECT 'Sin acceso a la red institucional', 'Critica', 'Cerrada', 'Manual', @ahora - INTERVAL 13 DAY, @ahora - INTERVAL 11 DAY, NULL, id_equipo, COALESCE((SELECT u.id_usuario FROM usuario u JOIN rol r ON r.id_rol = u.id_rol WHERE r.nombre = 'Auxiliar' AND u.esta_activo = 1 ORDER BY u.id_usuario LIMIT 1 OFFSET 1), (SELECT MIN(id_usuario) FROM usuario WHERE esta_activo = 1)) FROM equipo WHERE direccion_mac = '02:5E:0D:03:EE:26';
INSERT INTO incidencia (descripcion, prioridad, estado, origen, fecha_registro, fecha_resolucion, id_alerta, id_equipo, id_usuario) SELECT 'Solicitud de instalación de software', 'Baja', 'Abierta', 'Manual', @ahora - INTERVAL 16 DAY, NULL, NULL, id_equipo, COALESCE((SELECT u.id_usuario FROM usuario u JOIN rol r ON r.id_rol = u.id_rol WHERE r.nombre = 'Auxiliar' AND u.esta_activo = 1 ORDER BY u.id_usuario LIMIT 1 OFFSET 2), (SELECT MIN(id_usuario) FROM usuario WHERE esta_activo = 1)) FROM equipo WHERE direccion_mac = '02:5E:0D:75:70:30';
INSERT INTO incidencia (descripcion, prioridad, estado, origen, fecha_registro, fecha_resolucion, id_alerta, id_equipo, id_usuario) SELECT 'Disco casi lleno, el usuario no puede guardar', 'Media', 'Cerrada', 'Manual', @ahora - INTERVAL 19 DAY, @ahora - INTERVAL 18 DAY, NULL, id_equipo, COALESCE((SELECT u.id_usuario FROM usuario u JOIN rol r ON r.id_rol = u.id_rol WHERE r.nombre = 'Auxiliar' AND u.esta_activo = 1 ORDER BY u.id_usuario LIMIT 1 OFFSET 0), (SELECT MIN(id_usuario) FROM usuario WHERE esta_activo = 1)) FROM equipo WHERE direccion_mac = '02:5E:0C:28:E5:39';
INSERT INTO incidencia (descripcion, prioridad, estado, origen, fecha_registro, fecha_resolucion, id_alerta, id_equipo, id_usuario) SELECT 'El agente RMM dejó de reportar', 'Media', 'Resuelta', 'Manual', @ahora - INTERVAL 2 DAY, @ahora - INTERVAL 0 DAY, NULL, id_equipo, COALESCE((SELECT u.id_usuario FROM usuario u JOIN rol r ON r.id_rol = u.id_rol WHERE r.nombre = 'Auxiliar' AND u.esta_activo = 1 ORDER BY u.id_usuario LIMIT 1 OFFSET 1), (SELECT MIN(id_usuario) FROM usuario WHERE esta_activo = 1)) FROM equipo WHERE direccion_mac = '02:5E:0F:4A:67:43';
INSERT INTO incidencia (descripcion, prioridad, estado, origen, fecha_registro, fecha_resolucion, id_alerta, id_equipo, id_usuario) SELECT 'Teclado con teclas que no responden', 'Baja', 'Abierta', 'Manual', @ahora - INTERVAL 5 DAY, NULL, NULL, id_equipo, COALESCE((SELECT u.id_usuario FROM usuario u JOIN rol r ON r.id_rol = u.id_rol WHERE r.nombre = 'Auxiliar' AND u.esta_activo = 1 ORDER BY u.id_usuario LIMIT 1 OFFSET 2), (SELECT MIN(id_usuario) FROM usuario WHERE esta_activo = 1)) FROM equipo WHERE direccion_mac = '02:5E:0F:97:DC:4C';
INSERT INTO incidencia (descripcion, prioridad, estado, origen, fecha_registro, fecha_resolucion, id_alerta, id_equipo, id_usuario) SELECT 'Uso de CPU al 100 % todo el día', 'Alta', 'EnProceso', 'Manual', @ahora - INTERVAL 8 DAY, NULL, NULL, id_equipo, COALESCE((SELECT u.id_usuario FROM usuario u JOIN rol r ON r.id_rol = u.id_rol WHERE r.nombre = 'Auxiliar' AND u.esta_activo = 1 ORDER BY u.id_usuario LIMIT 1 OFFSET 0), (SELECT MIN(id_usuario) FROM usuario WHERE esta_activo = 1)) FROM equipo WHERE direccion_mac = '02:5E:01:4D:5E:56';
INSERT INTO incidencia (descripcion, prioridad, estado, origen, fecha_registro, fecha_resolucion, id_alerta, id_equipo, id_usuario) SELECT 'Virus detectado por el antivirus', 'Critica', 'EnProceso', 'Manual', @ahora - INTERVAL 11 DAY, NULL, NULL, id_equipo, COALESCE((SELECT u.id_usuario FROM usuario u JOIN rol r ON r.id_rol = u.id_rol WHERE r.nombre = 'Auxiliar' AND u.esta_activo = 1 ORDER BY u.id_usuario LIMIT 1 OFFSET 1), (SELECT MIN(id_usuario) FROM usuario WHERE esta_activo = 1)) FROM equipo WHERE direccion_mac = '02:5E:1A:94:D3:5F';
INSERT INTO incidencia (descripcion, prioridad, estado, origen, fecha_registro, fecha_resolucion, id_alerta, id_equipo, id_usuario) SELECT 'Cambio de ubicación del equipo', 'Baja', 'Resuelta', 'Manual', @ahora - INTERVAL 14 DAY, @ahora - INTERVAL 11 DAY, NULL, id_equipo, COALESCE((SELECT u.id_usuario FROM usuario u JOIN rol r ON r.id_rol = u.id_rol WHERE r.nombre = 'Auxiliar' AND u.esta_activo = 1 ORDER BY u.id_usuario LIMIT 1 OFFSET 2), (SELECT MIN(id_usuario) FROM usuario WHERE esta_activo = 1)) FROM equipo WHERE direccion_mac = '02:5E:15:94:55:69';
INSERT INTO incidencia (descripcion, prioridad, estado, origen, fecha_registro, fecha_resolucion, id_alerta, id_equipo, id_usuario) SELECT 'Contraseña de Windows bloqueada', 'Media', 'Cerrada', 'Manual', @ahora - INTERVAL 17 DAY, @ahora - INTERVAL 16 DAY, NULL, id_equipo, COALESCE((SELECT u.id_usuario FROM usuario u JOIN rol r ON r.id_rol = u.id_rol WHERE r.nombre = 'Auxiliar' AND u.esta_activo = 1 ORDER BY u.id_usuario LIMIT 1 OFFSET 0), (SELECT MIN(id_usuario) FROM usuario WHERE esta_activo = 1)) FROM equipo WHERE direccion_mac = '02:5E:40:6F:CA:72';
INSERT INTO incidencia (descripcion, prioridad, estado, origen, fecha_registro, fecha_resolucion, id_alerta, id_equipo, id_usuario) SELECT 'No abre el correo institucional', 'Media', 'Abierta', 'Manual', @ahora - INTERVAL 20 DAY, NULL, NULL, id_equipo, COALESCE((SELECT u.id_usuario FROM usuario u JOIN rol r ON r.id_rol = u.id_rol WHERE r.nombre = 'Auxiliar' AND u.esta_activo = 1 ORDER BY u.id_usuario LIMIT 1 OFFSET 1), (SELECT MIN(id_usuario) FROM usuario WHERE esta_activo = 1)) FROM equipo WHERE direccion_mac = '02:5E:38:B9:4C:7C';
INSERT INTO incidencia (descripcion, prioridad, estado, origen, fecha_registro, fecha_resolucion, id_alerta, id_equipo, id_usuario) SELECT 'Software no autorizado instalado', 'Alta', 'Cerrada', 'Manual', @ahora - INTERVAL 3 DAY, @ahora - INTERVAL 0 DAY, NULL, id_equipo, COALESCE((SELECT u.id_usuario FROM usuario u JOIN rol r ON r.id_rol = u.id_rol WHERE r.nombre = 'Auxiliar' AND u.esta_activo = 1 ORDER BY u.id_usuario LIMIT 1 OFFSET 2), (SELECT MIN(id_usuario) FROM usuario WHERE esta_activo = 1)) FROM equipo WHERE direccion_mac = '02:5E:02:00:C1:85';
INSERT INTO incidencia (descripcion, prioridad, estado, origen, fecha_registro, fecha_resolucion, id_alerta, id_equipo, id_usuario) SELECT 'Ruido fuerte en el ventilador', 'Baja', 'Resuelta', 'Manual', @ahora - INTERVAL 6 DAY, @ahora - INTERVAL 5 DAY, NULL, id_equipo, COALESCE((SELECT u.id_usuario FROM usuario u JOIN rol r ON r.id_rol = u.id_rol WHERE r.nombre = 'Auxiliar' AND u.esta_activo = 1 ORDER BY u.id_usuario LIMIT 1 OFFSET 0), (SELECT MIN(id_usuario) FROM usuario WHERE esta_activo = 1)) FROM equipo WHERE direccion_mac = '02:5E:0B:6F:34:04';

-- ---------- 8. Resumen ----------
SELECT estado_conexion AS estado, COUNT(*) AS equipos
  FROM equipo WHERE direccion_mac LIKE '02:5E:%' GROUP BY estado_conexion;
SELECT
  (SELECT COUNT(*) FROM equipo WHERE direccion_mac LIKE '02:5E:%') AS equipos_simulados,
  (SELECT COUNT(*) FROM informe f JOIN equipo e ON e.id_equipo = f.id_equipo WHERE e.direccion_mac LIKE '02:5E:%') AS lecturas,
  (SELECT COUNT(*) FROM alerta a JOIN equipo e ON e.id_equipo = a.id_equipo WHERE e.direccion_mac LIKE '02:5E:%' AND a.estado = 'Activa') AS alertas_activas,
  (SELECT COUNT(*) FROM incidencia i JOIN equipo e ON e.id_equipo = i.id_equipo WHERE e.direccion_mac LIKE '02:5E:%') AS incidencias;

