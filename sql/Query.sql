/*
============================================
Proyecto Final
Equipo: Excelsistas
============================================
*/

-- i. Calcular cuántos Pokémons registró cada participante para el torneo de peleas por cada una de las ediciones.
SELECT 
    CONCAT(per.nombres, ' ', per.apellido_paterno, ' ', per.apellido_materno) AS nombre_participante,
    t.edicion,
    COUNT(pok.id_pokemon) AS total_pokemons
FROM Persona per
INNER JOIN Participante p ON per.id_persona = p.id_persona
INNER JOIN Cuenta c ON p.id_persona = c.id_persona
INNER JOIN Pokemon pok ON c.codigo = pok.codigo
INNER JOIN Torneo t ON pok.id_torneo = t.id_torneo
INNER JOIN Pelea pel ON t.id_torneo = pel.id_torneo
GROUP BY per.id_persona, per.nombres, per.apellido_paterno, per.apellido_materno, t.edicion
ORDER BY t.edicion, nombre_participante;

-- ii. Participantes con más de 1 cuenta de Pokemon GO
SELECT
    p.id_persona,
    CONCAT(per.nombres, ' ', per.apellido_paterno, ' ', per.apellido_materno) AS nombre_completo,
    COUNT(c.codigo) AS num_cuentas,
    STRING_AGG(c.username, ', ') AS usernames
FROM Participante p
JOIN Persona per ON p.id_persona = per.id_persona
JOIN Cuenta c ON p.id_persona = c.id_persona
GROUP BY p.id_persona, nombre_completo
HAVING COUNT(c.codigo) > 1
ORDER BY num_cuentas DESC, nombre_completo;

-- iii. Participantes con cuentas en más de un equipo
SELECT
    p.id_persona,
    CONCAT(per.nombres, ' ', per.apellido_paterno, ' ', per.apellido_materno) AS nombre,
    COUNT(DISTINCT c.equipo) AS equipos_distintos,
    STRING_AGG(DISTINCT c.equipo, ', ') AS equipos
FROM Participante p
JOIN Persona per ON p.id_persona = per.id_persona
JOIN Cuenta c ON p.id_persona = c.id_persona
GROUP BY p.id_persona, nombre
HAVING COUNT(DISTINCT c.equipo) > 1
ORDER BY equipos_distintos DESC;

--  iv. Pokemon más utilizados en combates (por especie)
SELECT
    pok.especie,
    COUNT(*) AS veces_en_combates
FROM Combatir cb
JOIN Pokemon pok ON cb.id_pokemon = pok.id_pokemon AND cb.codigo = pok.codigo
GROUP BY pok.especie
ORDER BY veces_en_combates DESC
LIMIT 20;

-- v. Participantes con al menos 3 registros de distancia (proxy para haber pasado por 3 locaciones)
SELECT
    p.id_persona,
    CONCAT(per.nombres, ' ', per.apellido_paterno, ' ', per.apellido_materno) AS nombre,
    COUNT(*) AS registros_distancia,
    SUM(d.distancia) AS distancia_total
FROM Distancia d
JOIN Participante p ON d.id_persona = p.id_persona
JOIN Persona per ON p.id_persona = per.id_persona
GROUP BY p.id_persona, nombre
HAVING COUNT(*) >= 3
ORDER BY distancia_total DESC;

-- vii. Ganadores de cada torneo (por edición) y el premio
SELECT
    e.edicion,
    t.id_torneo,
    t.premio,
    CONCAT(per.nombres, ' ', per.apellido_paterno, ' ', per.apellido_materno) AS nombre_ganador,
    p.num_cuenta
FROM Torneo t
JOIN Evento e ON t.edicion = e.edicion
LEFT JOIN Enfrentar enf ON t.id_torneo = enf.id_torneo AND enf.esGanador = TRUE
LEFT JOIN Participante p ON enf.id_persona = p.id_persona
LEFT JOIN Persona per ON p.id_persona = per.id_persona
ORDER BY e.edicion, t.id_torneo;

-- viii. Participantes que participaron en distancia y captura
SELECT DISTINCT
    per.id_persona,
    CONCAT(per.nombres, ' ', per.apellido_paterno, ' ', per.apellido_materno) AS nombre
FROM Persona per
JOIN Participante part ON per.id_persona = part.id_persona
WHERE EXISTS (
    SELECT 1
    FROM Participar pa
    JOIN Torneo t ON pa.id_torneo = t.id_torneo
    JOIN Multi m ON t.id_torneo = m.id_torneo
    WHERE pa.id_persona = part.id_persona AND m.esDistanciaRecorrida = TRUE
)
AND EXISTS (
    SELECT 1
    FROM Participar pa2
    JOIN Torneo t2 ON pa2.id_torneo = t2.id_torneo
    JOIN Multi m2 ON t2.id_torneo = m2.id_torneo
    WHERE pa2.id_persona = part.id_persona AND m2.esCaptura = TRUE
)
ORDER BY nombre;


-- ix. Edad promedio de espectadores por edición (usa Asistir)
SELECT
    a.edicion,
    ROUND(AVG(date_part('year', age(current_date, per.fecha_de_nacimiento))), 2) AS edad_promedio_por_edicion,
    COUNT(a.id_persona) AS asistentes_registrados
FROM Asistir a
JOIN Espectador esp ON a.id_persona = esp.id_persona
JOIN Persona per ON esp.id_persona = per.id_persona
GROUP BY a.edicion
ORDER BY a.edicion;

-- x. Participantes por suma total de CP
SELECT
    p.id_persona,
    CONCAT(per.nombres, ' ', per.apellido_paterno, ' ', per.apellido_materno) AS nombre,
    COUNT(pok.id_pokemon) AS total_pokemons,
    COALESCE(SUM(pok.puntos_combate), 0) AS suma_total_cp,
    ROUND(COALESCE(AVG(pok.puntos_combate),0),2) AS cp_promedio
FROM Participante p
JOIN Persona per ON p.id_persona = per.id_persona
LEFT JOIN Cuenta c ON p.id_persona = c.id_persona
LEFT JOIN Pokemon pok ON c.codigo = pok.codigo
GROUP BY p.id_persona, nombre
ORDER BY suma_total_cp DESC;

-- xi. Participantes inscritos en torneos de captura sin capturas registradas en la misma edicion
WITH capturistas AS (
    SELECT DISTINCT pa.id_persona, t.edicion, t.id_torneo
    FROM Participar pa
    JOIN Torneo t ON pa.id_torneo = t.id_torneo
    JOIN Multi m ON t.id_torneo = m.id_torneo
    WHERE m.esCaptura = TRUE
),
capturas_por_persona AS (
    SELECT c.id_persona, e.edicion, COUNT(pok.id_pokemon) AS capturas
    FROM Cuenta c
    JOIN Pokemon pok ON c.codigo = pok.codigo
    JOIN Torneo t ON pok.id_torneo = t.id_torneo
    JOIN Evento e ON t.edicion = e.edicion
    GROUP BY c.id_persona, e.edicion
)
SELECT
    cp.id_persona,
    CONCAT(per.nombres,' ',per.apellido_paterno,' ',per.apellido_materno) AS nombre,
    cp.edicion
FROM capturistas cp
LEFT JOIN capturas_por_persona cap ON cp.id_persona = cap.id_persona AND cp.edicion = cap.edicion
JOIN Persona per ON cp.id_persona = per.id_persona
WHERE COALESCE(cap.capturas,0) = 0
ORDER BY cp.edicion, nombre;

-- xii. Pokemon de mayor CP por participante y edicion
WITH pok_por_participante AS (
    SELECT
        c.id_persona,
        pok.id_pokemon,
        pok.apodo,
        pok.especie,
        pok.puntos_combate,
        t.id_torneo,
        t.edicion,
        ROW_NUMBER() OVER (PARTITION BY c.id_persona ORDER BY pok.puntos_combate DESC, pok.id_pokemon) AS rn
    FROM Cuenta c
    JOIN Pokemon pok ON c.codigo = pok.codigo
    JOIN Torneo t ON pok.id_torneo = t.id_torneo
)
SELECT
    ppp.id_persona,
    CONCAT(per.nombres,' ',per.apellido_paterno,' ',per.apellido_materno) AS nombre,
    ppp.id_pokemon,
    ppp.apodo,
    ppp.especie,
    ppp.puntos_combate,
    ppp.id_torneo,
    ppp.edicion
FROM pok_por_participante ppp
JOIN Persona per ON ppp.id_persona = per.id_persona
WHERE ppp.rn = 1
ORDER BY ppp.puntos_combate DESC;

-- xiii. Pokemon inscritos en torneo de pelea pero que no aparecen en ninguna fila de Combatir para ese torneo
SELECT
    pok.id_pokemon,
    pok.apodo,
    pok.especie,
    pok.codigo,
    pok.id_torneo
FROM Pokemon pok
JOIN Torneo t ON pok.id_torneo = t.id_torneo
JOIN Pelea pel ON t.id_torneo = pel.id_torneo
LEFT JOIN Combatir cb ON pok.id_pokemon = cb.id_pokemon AND pok.codigo = cb.codigo AND cb.id_torneo = pok.id_torneo
WHERE cb.id_pokemon IS NULL
ORDER BY pok.id_torneo, pok.especie;

-- xiv. Top 10 organizadores por cantidad de ediciones trabajadas y rol predominante
WITH roles AS (
    SELECT o.id_persona,
           SUM(CASE WHEN o.esRegistrador = TRUE THEN 1 ELSE 0 END) AS cnt_registrador,
           SUM(CASE WHEN o.esCuidador = TRUE THEN 1 ELSE 0 END) AS cnt_cuidador,
           SUM(CASE WHEN o.esLimpiador = TRUE THEN 1 ELSE 0 END) AS cnt_limpiador,
           SUM(CASE WHEN o.esVendedor = TRUE THEN 1 ELSE 0 END) AS cnt_vendedor
    FROM Organizador o
    GROUP BY o.id_persona
),
ediciones AS (
    SELECT tr.id_organizador, COUNT(DISTINCT tr.edicion) AS ediciones_trabajadas
    FROM Trabajar tr
    GROUP BY tr.id_organizador
)
SELECT
    e.id_organizador AS id_persona,
    CONCAT(p.nombres,' ',p.apellido_paterno) AS nombre,
    e.ediciones_trabajadas,
    GREATEST(r.cnt_registrador, r.cnt_cuidador, r.cnt_limpiador, r.cnt_vendedor) AS rol_cnt_max,
    CASE
      WHEN r.cnt_registrador = GREATEST(r.cnt_registrador, r.cnt_cuidador, r.cnt_limpiador, r.cnt_vendedor) THEN 'Registrador'
      WHEN r.cnt_cuidador = GREATEST(r.cnt_registrador, r.cnt_cuidador, r.cnt_limpiador, r.cnt_vendedor) THEN 'Cuidador'
      WHEN r.cnt_limpiador = GREATEST(r.cnt_registrador, r.cnt_cuidador, r.cnt_limpiador, r.cnt_vendedor) THEN 'Limpiador'
      ELSE 'Vendedor'
    END AS rol_predominante
FROM ediciones e
LEFT JOIN roles r ON e.id_organizador = r.id_persona
LEFT JOIN Persona p ON e.id_organizador = p.id_persona
ORDER BY e.ediciones_trabajadas DESC
LIMIT 10;

-- xv. Participantes con cuentas en un mismo equipo
WITH equipos_por_persona AS (
    SELECT c.id_persona, COUNT(DISTINCT c.equipo) AS equipos_distintos,
           MIN(c.equipo) AS equipo_predominante
    FROM Cuenta c
    GROUP BY c.id_persona
)
SELECT
    CASE WHEN equipos_distintos = 1 THEN 'consistente' ELSE 'mixto' END AS tipo,
    COUNT(*) AS num_personas,
    ROUND(100.0 * COUNT(*) / NULLIF((SELECT COUNT(*) FROM Participante),0),2) AS pct_participantes
FROM equipos_por_persona ep
JOIN Participante p ON ep.id_persona = p.id_persona
GROUP BY tipo;