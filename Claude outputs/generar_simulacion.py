"""Genera sql/datos_simulacion.sql: equipos, hardware, software, lecturas, alertas e incidencias
de prueba sobre las áreas reales del catálogo (rmm_base_completa.sql).

Los equipos simulados se reconocen por su MAC 02:5E:xx:xx:xx:xx (dirección local, no existe
en tarjetas reales); el script borra primero todo lo simulado anterior y lo vuelve a crear.
Uso: python3 generar_simulacion.py rmm_base_completa.sql salida.sql
"""
import random
import re
import sys
from collections import defaultdict

random.seed(2026)  # misma simulación cada vez que se genera

base = open(sys.argv[1], encoding='utf-8').read()
areas = re.findall(r"\((\d+),(\d+),'([^']*)','([^']*)',(NULL|'[^']*'),(NULL|\d+),(\d)\)",
                   re.search(r"INSERT INTO `area`.*?;\n", base, re.S).group(0))
por_unidad = defaultdict(list)
for a in areas:
    if a[5] != 'NULL':
        por_unidad[int(a[5])].append(int(a[0]))

# (id_unidad_homologada, abreviatura para el hostname, tercer octeto de la IP, equipos)
PLAN = [
    (1, 'HGZ1', 11, 30),     # HGZ 1 OAXACA
    (3, 'HGZMF2', 13, 18),   # HGZMF 2 SALINA CRUZ
    (2, 'HGZ3', 12, 16),     # HGZ 3 TUXTEPEC
    (5, 'HGSMF41', 15, 12),  # HGSMF 41 HUATULCO
    (583, 'OOAD', 1, 14),    # OFICINAS DEL OOAD
    (26, 'UMF65', 26, 10),   # UMF 65 OAXACA
    (11, 'UMF1', 21, 10),    # UMF 1 OAXACA
    (13, 'UMF64', 64, 8),    # UMF 64 TUXTEPEC
    (25, 'UMF6', 56, 8),     # UMF 6 JUCHITAN
    (15, 'UMF38', 38, 6),    # UMF 38 OAXACA
    (595, 'SUBOAX', 2, 6),   # SUBDELEGACION OAXACA
]

SO = [('Windows 11 Pro', '23H2'), ('Windows 11 Pro', '24H2'), ('Windows 10 Pro', '22H2'),
      ('Windows 10 Pro', '22H2'), ('Ubuntu', '22.04 LTS')]
CPU = [('Intel Core i5-12500', 6, 12), ('Intel Core i5-10500', 6, 12), ('Intel Core i7-12700', 12, 20),
       ('Intel Core i3-10100', 4, 8), ('AMD Ryzen 5 5600G', 6, 12)]
PLACA = ['Dell OptiPlex 7000', 'HP ProDesk 400 G7', 'Lenovo ThinkCentre M70s', 'Dell OptiPlex 3080']
RAM = [8, 8, 16, 16, 16, 32]
DISCO = [256, 512, 512, 1000]
UBICACION = ['Planta baja', 'Primer piso', 'Segundo piso', 'Consultorio', 'Archivo', 'Recepción',
             'Jefatura', 'Ventanilla', 'Sala de juntas', 'Almacén']
SOFTWARE_OK = [('Microsoft Office LTSC', '2021', 'Microsoft'), ('Google Chrome', '131.0', 'Google'),
               ('Adobe Acrobat Reader', '2024.004', 'Adobe'), ('ESET Endpoint Security', '11.0', 'ESET'),
               ('7-Zip', '24.08', 'Igor Pavlov')]
SOFTWARE_NO = [('uTorrent', '3.6', 'BitTorrent Inc.'), ('AnyDesk', '8.1', 'AnyDesk Software'),
               ('Juegos Steam', '2.10', 'Valve')]


def q(t):
    return 'NULL' if t is None else "'" + str(t).replace("'", "''") + "'"


sql = []
w = sql.append
w('''-- =====================================================================
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
''')

equipos = []
n_global = 0
for uh, abrev, octeto, cuantos in PLAN:
    lista = por_unidad.get(uh, [])
    if not lista:
        continue
    for k in range(cuantos):
        n_global += 1
        i = n_global
        id_area = lista[(k * 7) % len(lista)]  # salteado para repartir entre áreas
        host = 'OAX-%s-PC%03d' % (abrev, k + 1)
        mac = '02:5E:%02X:%02X:%02X:%02X' % (octeto % 256, (k * 37) % 256, (i * 13) % 256, i % 256)
        ip = '10.21.%d.%d' % (octeto, 20 + k)
        r = i % 20
        estado = 'ONLINE' if r < 14 else 'OFFLINE' if r < 17 else 'ALERTA' if r < 19 else 'INACTIVO'
        so = SO[i % len(SO)]
        cpu = CPU[i % len(CPU)]
        equipos.append(dict(i=i, host=host, mac=mac, ip=ip, area=id_area, estado=estado, so=so, cpu=cpu,
                            ram=RAM[i % len(RAM)], disco=DISCO[i % len(DISCO)], placa=PLACA[i % len(PLACA)],
                            ubic=(UBICACION[i % len(UBICACION)] + (' %d' % ((i % 12) + 1)
                                  if UBICACION[i % len(UBICACION)] == 'Consultorio' else '')),
                            dias_alta=30 + (i * 11) % 300))

w('-- ---------- 3. Equipos (%d) ----------' % len(equipos))
w('-- Si un área no existe en su base, ese equipo simplemente no se inserta.')
for e in equipos:
    est = e['estado']
    if est in ('ONLINE', 'ALERTA'):
        senal = '@ahora - INTERVAL %d SECOND' % (20 + (e['i'] * 17) % 100)
    elif est == 'OFFLINE':
        horas = [3, 9, 26, 50, 120, 220][e['i'] % 6]
        senal = 'NULL' if e['i'] % 7 == 0 else '@ahora - INTERVAL %d HOUR' % horas
    else:
        senal = '@ahora - INTERVAL %d DAY' % (35 + e['i'] % 20)
    activo = 0 if est == 'INACTIVO' else 1
    baja = '@ahora - INTERVAL %d DAY' % (30 + e['i'] % 20) if not activo else 'NULL'
    motivo = q('Equipo dañado sin reparación; reemplazado') if not activo else 'NULL'
    resp = '(SELECT id_usuario FROM usuario WHERE esta_activo = 1 ORDER BY id_usuario LIMIT 1 OFFSET %d)' % (e['i'] % 5)
    w('INSERT INTO equipo (hostname, direccion_mac, ip_local, nombre_so, version_so, estado_conexion, ultima_senal,'
      ' fecha_registro, ubicacion_fisica, esta_activo, fecha_baja, motivo_baja, id_area, id_usuario)\n'
      'SELECT %s, %s, %s, %s, %s, %s, %s, @ahora - INTERVAL %d DAY, %s, %d, %s, %s, a.id_area,\n'
      '       IF(%d < @n_usuarios, %s, NULL) FROM area a WHERE a.id_area = %d;'
      % (q(e['host']), q(e['mac']), q(e['ip']), q(e['so'][0]), q(e['so'][1]), q(est), senal, e['dias_alta'],
         q(e['ubic']), activo, baja, motivo, e['i'] % 5, resp, e['area']))

w('\n-- ---------- 4. Hardware, software y periféricos ----------')
for e in equipos:
    eq = "(SELECT id_equipo FROM equipo WHERE direccion_mac = %s)" % q(e['mac'])
    c = e['cpu']
    w('INSERT INTO hardware (modelo_cpu, nucleos_cpu, hilos_cpu, total_ram_gb, modelo_placa_base, capacidad_disco_gb, id_equipo)'
      ' SELECT %s, %d, %d, %d, %s, %d, id_equipo FROM equipo WHERE direccion_mac = %s;'
      % (q(c[0]), c[1], c[2], e['ram'], q(e['placa']), e['disco'], q(e['mac'])))
    soft = SOFTWARE_OK[:3 + e['i'] % 3]
    filas = []
    for s in soft:
        filas.append("(%s, %s, %s, @ahora - INTERVAL %d DAY, 1, %d, %s)"
                     % (q(s[0]), q(s[1]), q(s[2]), e['dias_alta'], 0 if e['i'] % 9 == 0 else 1, eq))
    if e['i'] % 8 == 0:   # 1 de cada 8 tiene software no autorizado
        s = SOFTWARE_NO[e['i'] % len(SOFTWARE_NO)]
        filas.append("(%s, %s, %s, @ahora - INTERVAL %d DAY, 0, 1, %s)" % (q(s[0]), q(s[1]), q(s[2]), 3 + e['i'] % 20, eq))
    w('INSERT INTO software (nombre, version, fabricante, fecha_instalacion, autorizado, actualizado, id_equipo) VALUES\n  '
      + ',\n  '.join(filas) + ';')
    w("INSERT INTO periferico (tipo, modelo, numero_serie, id_equipo) VALUES ('Monitor', 'Dell P2422H', %s, %s),"
      " ('Teclado', 'Dell KB216', %s, %s);" % (q('CN0%06d' % (e['i'] * 7919 % 999999)), eq,
                                              q('KB%06d' % (e['i'] * 104729 % 999999)), eq))

w('\n-- ---------- 5. Lecturas del agente ----------')
w('-- Última lectura de cada equipo que ha reportado (con su disco C:) y 24 h de historial')
w('-- (una por hora) para los que están en línea o con alerta.')
for e in equipos:
    est = e['estado']
    if est == 'INACTIVO' or (est == 'OFFLINE' and e['i'] % 7 == 0):
        continue
    alto = est == 'ALERTA'
    eq = "(SELECT id_equipo FROM equipo WHERE direccion_mac = %s)" % q(e['mac'])
    if est in ('ONLINE', 'ALERTA'):
        historial = []
        for h in range(24, 0, -1):
            cpu = round(random.uniform(8, 55) + (25 if 9 <= (24 - h) % 24 <= 15 else 0), 1)
            ramu = round(e['ram'] * random.uniform(0.35, 0.7), 2)
            historial.append("(%s, %s, %s, %s, %d, @ahora - INTERVAL %d HOUR, %s)"
                             % (cpu, ramu, round(random.uniform(5, 400), 1), round(random.uniform(1, 80), 1),
                                random.randint(140, 260), h, eq))
        w('INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos,'
          ' fecha_registro, id_equipo) VALUES\n  ' + ',\n  '.join(historial) + ';')
    cpu = round(random.uniform(92, 99), 1) if alto and e['i'] % 2 == 0 else round(random.uniform(10, 60), 1)
    ramu = round(e['ram'] * (random.uniform(0.91, 0.97) if alto and e['i'] % 2 == 1 else random.uniform(0.35, 0.7)), 2)
    libre = round(e['disco'] * (random.uniform(0.03, 0.08) if alto else random.uniform(0.25, 0.7)), 1)
    fecha = '(SELECT ultima_senal FROM equipo WHERE direccion_mac = %s)' % q(e['mac'])
    w('INSERT INTO informe (porcentaje_uso_cpu, ram_usada_gb, trafico_red_rx_mb, trafico_red_tx_mb, total_procesos,'
      ' fecha_registro, id_equipo) VALUES (%s, %s, %s, %s, %d, %s, %s);'
      % (cpu, ramu, round(random.uniform(5, 400), 1), round(random.uniform(1, 80), 1), random.randint(140, 260), fecha, eq))
    w("INSERT INTO almacenamiento (punto_montaje, capacidad_total_gb, espacio_libre_gb, id_informe)"
      " VALUES ('C:', %d, %s, LAST_INSERT_ID());" % (e['disco'], libre))

w('\n-- ---------- 6. Alertas ----------')
alertas = []
for e in equipos:
    est = e['estado']
    eq = "(SELECT id_equipo FROM equipo WHERE direccion_mac = %s)" % q(e['mac'])
    if est == 'ALERTA':
        tipo, umbral, desc = ([('UsoAnomalo', '@u_cpu', 'Uso de CPU arriba de 90 % por más de 5 minutos'),
                               ('UsoAnomalo', '@u_ram', 'Uso de RAM arriba de 90 %'),
                               ('UsoAnomalo', '@u_disc', 'Disco C: con menos de 10 % libre')][e['i'] % 3])
        alertas.append((e, tipo, 'Critica' if e['i'] % 2 == 0 else 'Advertencia', desc, 'Activa', umbral,
                        '@ahora - INTERVAL %d MINUTE' % (5 + e['i'] % 50)))
    elif est == 'OFFLINE' and e['i'] % 7 != 0 and e['i'] % 3 != 0:
        alertas.append((e, 'Desconexion', 'Advertencia', 'El agente dejó de reportar', 'Activa', '@u_desc',
                        '@ahora - INTERVAL %d HOUR' % (2 + e['i'] % 40)))
    if e['i'] % 6 == 0 and est != 'INACTIVO':   # historial ya atendido
        alertas.append((e, 'UsoAnomalo', 'Informativa', 'Uso de CPU alto (ya atendida)', 'Atendida', '@u_cpu',
                        '@ahora - INTERVAL %d DAY' % (1 + e['i'] % 25)))
    if e['i'] % 11 == 0 and est != 'INACTIVO':
        alertas.append((e, 'RiesgoSeguridad', 'Critica', 'Software no autorizado detectado', 'Atendida', '@u_cpu',
                        '@ahora - INTERVAL %d DAY' % (2 + e['i'] % 20)))
for e, tipo, grav, desc, est, umbral, fecha in alertas:
    w("INSERT INTO alerta (tipo_alerta, nivel_gravedad, descripcion, fecha_generacion, estado, id_equipo, id_umbral_alerta)"
      " SELECT %s, %s, %s, %s, %s, id_equipo, %s FROM equipo WHERE direccion_mac = %s;"
      % (q(tipo), q(grav), q(desc), fecha, q(est), umbral, q(e['mac'])))

w('\n-- ---------- 7. Incidencias ----------')
w('-- Técnico: un Auxiliar si hay, si no cualquier usuario activo.')
tecnico = ("COALESCE((SELECT u.id_usuario FROM usuario u JOIN rol r ON r.id_rol = u.id_rol"
           " WHERE r.nombre = 'Auxiliar' AND u.esta_activo = 1 ORDER BY u.id_usuario LIMIT 1 OFFSET %d),"
           " (SELECT MIN(id_usuario) FROM usuario WHERE esta_activo = 1))")
casos = [
    ('El equipo no enciende después del corte de luz', 'Alta'),
    ('Lentitud al abrir el expediente clínico', 'Media'),
    ('No imprime en la impresora del consultorio', 'Baja'),
    ('Pantalla azul al iniciar Windows', 'Alta'),
    ('Sin acceso a la red institucional', 'Critica'),
    ('Solicitud de instalación de software', 'Baja'),
    ('Disco casi lleno, el usuario no puede guardar', 'Media'),
    ('El agente RMM dejó de reportar', 'Media'),
    ('Teclado con teclas que no responden', 'Baja'),
    ('Uso de CPU al 100 % todo el día', 'Alta'),
    ('Virus detectado por el antivirus', 'Critica'),
    ('Cambio de ubicación del equipo', 'Baja'),
    ('Contraseña de Windows bloqueada', 'Media'),
    ('No abre el correo institucional', 'Media'),
    ('Software no autorizado instalado', 'Alta'),
    ('Ruido fuerte en el ventilador', 'Baja'),
]
estados = ['Abierta', 'EnProceso', 'EnProceso', 'Resuelta', 'Cerrada', 'Abierta', 'Cerrada', 'Resuelta']
activos = [e for e in equipos if e['estado'] != 'INACTIVO']
for n, (desc, prio) in enumerate(casos):
    e = activos[(n * 9) % len(activos)]
    est = estados[n % len(estados)]
    dias = 1 + (n * 3) % 20
    resol = '@ahora - INTERVAL %d DAY' % max(0, dias - 1 - n % 3) if est in ('Resuelta', 'Cerrada') else 'NULL'
    w("INSERT INTO incidencia (descripcion, prioridad, estado, origen, fecha_registro, fecha_resolucion, id_alerta,"
      " id_equipo, id_usuario) SELECT %s, %s, %s, 'Manual', @ahora - INTERVAL %d DAY, %s, NULL, id_equipo, %s"
      " FROM equipo WHERE direccion_mac = %s;"
      % (q(desc), q(prio), q(est), dias, resol, tecnico % (n % 3), q(e['mac'])))

w('''
-- ---------- 8. Resumen ----------
SELECT estado_conexion AS estado, COUNT(*) AS equipos
  FROM equipo WHERE direccion_mac LIKE '02:5E:%' GROUP BY estado_conexion;
SELECT
  (SELECT COUNT(*) FROM equipo WHERE direccion_mac LIKE '02:5E:%') AS equipos_simulados,
  (SELECT COUNT(*) FROM informe f JOIN equipo e ON e.id_equipo = f.id_equipo WHERE e.direccion_mac LIKE '02:5E:%') AS lecturas,
  (SELECT COUNT(*) FROM alerta a JOIN equipo e ON e.id_equipo = a.id_equipo WHERE e.direccion_mac LIKE '02:5E:%' AND a.estado = 'Activa') AS alertas_activas,
  (SELECT COUNT(*) FROM incidencia i JOIN equipo e ON e.id_equipo = i.id_equipo WHERE e.direccion_mac LIKE '02:5E:%') AS incidencias;
''')
open(sys.argv[2], 'w', encoding='utf-8').write('\n'.join(sql) + '\n')
print('equipos:', len(equipos), 'alertas:', len(alertas), 'incidencias:', len(casos))
