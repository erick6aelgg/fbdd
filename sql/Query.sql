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

-- ii. Participantes con cuentas en más de un equipo
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

--- iii. Vendedor con su ubicación, el método de pago y los totales monetarios y de unidades vendidas
select
    CONCAT(per.nombres, ' ', per.apellido_paterno, ' ', per.apellido_materno) AS vendedor,
    v.ubicacion,
    cmp.metodo_pago,
    SUM(cmp.cantidad) AS unidades_vendidas,
    SUM(cmp.cantidad * a.precio) AS total_ingresos
FROM Vendedor v
JOIN Organizador org ON org.id_persona = v.id_persona
JOIN Persona per ON per.id_persona = v.id_persona
JOIN Alimento a ON a.id_persona = v.id_persona
JOIN Comprar cmp ON cmp.id_alimento = a.id_alimento
GROUP BY per.id_persona, v.ubicacion, cmp.metodo_pago
HAVING SUM(cmp.cantidad * a.precio) > 200
ORDER BY total_ingresos DESC, vendedor, metodo_pago;

--  iv. Pokemon más utilizados en combates (por especie)
SELECT
    pok.especie,
    COUNT(*) AS veces_en_combates
FROM Combatir cb
JOIN Pokemon pok ON cb.id_pokemon = pok.id_pokemon AND cb.codigo = pok.codigo
GROUP BY pok.especie
ORDER BY veces_en_combates DESC;

-- v. Participantes con al menos 3 registros de distancia (haber pasado por las 3 locaciones)
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

-- vi. Participantes con más de 1 cuenta de Pokemon GO
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


-- ix. Relaciona a compradores (participantes o espectadores) con los alimentos adquiridos, mostrando método, vendedor, precio unitario y gasto total por fila.
WITH compras_agregadas AS (
    SELECT
        cmp.id_persona AS comprador,
        cmp.id_alimento,
        cmp.metodo_pago,
        SUM(cmp.cantidad) AS unidades,
        SUM(cmp.cantidad * a.precio) AS gasto_total
    FROM Comprar cmp
    JOIN Alimento a ON a.id_alimento = cmp.id_alimento
    GROUP BY cmp.id_persona, cmp.id_alimento, cmp.metodo_pago
    HAVING SUM(cmp.cantidad * a.precio) > 50
)
SELECT
    ca.comprador,
    CONCAT(per_comp.nombres, ' ', per_comp.apellido_paterno, ' ', per_comp.apellido_materno) AS nombre_comprador,
    ca.metodo_pago,
    ca.unidades,
    ca.gasto_total,
    a.nombre AS alimento,
    a.precio AS precio_unitario,
    CONCAT(per_vend.nombres, ' ', per_vend.apellido_paterno, ' ', per_vend.apellido_materno) AS vendedor,
    v.ubicacion
FROM compras_agregadas ca
JOIN Alimento a ON a.id_alimento = ca.id_alimento
JOIN Persona per_vend ON per_vend.id_persona = a.id_persona
JOIN Vendedor v ON v.id_persona = a.id_persona
JOIN Persona per_comp ON per_comp.id_persona = ca.comprador
ORDER BY ca.gasto_total DESC, ca.comprador, a.nombre;

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
    p.id_persona,
    CONCAT(per.nombres,' ',per.apellido_paterno,' ',per.apellido_materno) AS nombre,
    p.id_pokemon,
    p.apodo,
    p.especie,
    p.puntos_combate,
    p.id_torneo,
    p.edicion
FROM pok_por_participante p
JOIN Persona per ON p.id_persona = per.id_persona
WHERE p.rn = 1
ORDER BY p.puntos_combate DESC;

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

-- xiv. Participantes que gastaron mas de 120 pesos y el número de metodos de pago utilizados.
SELECT
    p.id_persona,
    CONCAT(per.nombres, ' ', per.apellido_paterno, ' ', per.apellido_materno) AS nombre,
    SUM(cmp.cantidad * a.precio) AS gasto_total,
    COUNT(DISTINCT cmp.metodo_pago) AS metodos_distintos
FROM Participante p
JOIN Persona per ON per.id_persona = p.id_persona
JOIN Comprar cmp ON cmp.id_persona = p.id_persona
JOIN Alimento a ON a.id_alimento = cmp.id_alimento
GROUP BY 
    p.id_persona,
    per.nombres,
    per.apellido_paterno,
    per.apellido_materno
HAVING SUM(cmp.cantidad * a.precio) > 120
ORDER BY gasto_total DESC;


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