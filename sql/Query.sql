/*
============================================
PRACTICA 9
Equipo: Excelsistas
============================================
*/

-- i. Mostrar el nombre completo de todos los participantes junto con su cuenta de Pokémon Go.
SELECT 
    CONCAT(per.nombres, ' ', per.apellido_paterno, ' ', per.apellido_materno) AS nombre_completo,
    c.username AS cuenta_pokemon_go,
    c.nivel,
    c.equipo
FROM Persona per
INNER JOIN Participante p ON per.id_persona = p.id_persona
INNER JOIN Cuenta c ON p.id_persona = c.id_persona
ORDER BY nombre_completo;

-- ii. Calcular cuántos Pokémons registró cada participante para el torneo de peleas por cada una de las ediciones.
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

-- iii. Listar todos los Pokémones cuya especie contenga la cadena 'chu'.
SELECT 
    pok.id_pokemon,
    pok.apodo,
    pok.especie,
    pok.tipo,
    pok.puntos_combate,
    c.username AS propietario
FROM Pokemon pok
INNER JOIN Cuenta c ON pok.codigo = c.codigo
WHERE LOWER(pok.especie) LIKE '%chu%'
ORDER BY pok.especie;

-- iv. Obtener la lista de participantes que estén inscritos en el Torneo de Captura de Shiny 
--     y a su vez que no estén inscritos en el torneo de distancia recorrida.
SELECT DISTINCT
    CONCAT(per.nombres, ' ', per.apellido_paterno, ' ', per.apellido_materno) AS nombre_participante,
    p.num_cuenta,
    p.facultad
FROM Persona per
INNER JOIN Participante p ON per.id_persona = p.id_persona
INNER JOIN Participar part ON p.id_persona = part.id_persona
INNER JOIN Torneo t ON part.id_torneo = t.id_torneo
INNER JOIN Multi m ON t.id_torneo = m.id_torneo
WHERE m.esCaptura = TRUE
AND p.id_persona NOT IN (
    SELECT DISTINCT p2.id_persona
    FROM Participante p2
    INNER JOIN Participar part2 ON p2.id_persona = part2.id_persona
    INNER JOIN Torneo t2 ON part2.id_torneo = t2.id_torneo
    INNER JOIN Multi m2 ON t2.id_torneo = m2.id_torneo
    WHERE m2.esDistanciaRecorrida = TRUE
)
ORDER BY nombre_participante;

-- v. Calcular la distancia total recorrida por cada participante en el torneo de distancia recorrida.
SELECT 
    CONCAT(per.nombres, ' ', per.apellido_paterno, ' ', per.apellido_materno) AS nombre_participante,
    p.num_cuenta,
    p.facultad,
    SUM(d.distancia) AS distancia_total_km
FROM Persona per
INNER JOIN Participante p ON per.id_persona = p.id_persona
INNER JOIN Participar part ON p.id_persona = part.id_persona
INNER JOIN Torneo t ON part.id_torneo = t.id_torneo
INNER JOIN Multi m ON t.id_torneo = m.id_torneo
INNER JOIN Distancia d ON m.id_torneo = d.id_torneo
WHERE m.esDistanciaRecorrida = TRUE
GROUP BY per.id_persona, per.nombres, per.apellido_paterno, per.apellido_materno, 
         p.num_cuenta, p.facultad
ORDER BY distancia_total_km DESC;

-- vi. Listar los Pokémones shinys que fueron capturados durante el evento, 
--     únicamente si fueron capturados entre las 14:00hrs y las 18:00hrs.
SELECT 
    pok.id_pokemon,
    pok.apodo,
    pok.especie,
    pok.tipo,
    pok.fecha_captura,
    pok.hora_captura,
    c.username AS capturado_por
FROM Pokemon pok
INNER JOIN Cuenta c ON pok.codigo = c.codigo
WHERE pok.esShiny = TRUE
AND pok.hora_captura >= '14:00:00'
AND pok.hora_captura <= '18:00:00'
ORDER BY pok.fecha_captura, pok.hora_captura;

-- vii. Mostrar a todos los vendedores junto con los alimentos que venden, 
--      indicando el precio sin IVA y el precio final con IVA del 16%.
SELECT 
    CONCAT(per.nombres, ' ', per.apellido_paterno, ' ', per.apellido_materno) AS nombre_vendedor,
    v.ubicacion,
    a.nombre AS alimento,
    a.tipo AS tipo_alimento,
    a.precio AS precio_sin_iva,
    ROUND(a.precio * 1.16, 2) AS precio_con_iva
FROM Persona per
INNER JOIN Organizador org ON per.id_persona = org.id_persona
INNER JOIN Vendedor v ON org.id_persona = v.id_persona
INNER JOIN Alimento a ON v.id_persona = a.id_persona
ORDER BY nombre_vendedor, a.nombre;

-- viii. Mostrar las facultades que tienen más de 5 participantes inscritos en cualquier torneo.
SELECT 
    p.facultad,
    COUNT(DISTINCT p.id_persona) AS total_participantes
FROM Participante p
INNER JOIN Participar part ON p.id_persona = part.id_persona
GROUP BY p.facultad
HAVING COUNT(DISTINCT p.id_persona) > 5
ORDER BY total_participantes DESC;

-- ix. Listar a los vendedores cuyo total de alimentos (número de productos distintos que ofrecen) sea mayor a 3.
SELECT 
    CONCAT(per.nombres, ' ', per.apellido_paterno, ' ', per.apellido_materno) AS nombre_vendedor,
    v.ubicacion,
    COUNT(DISTINCT a.id_alimento) AS total_productos_distintos
FROM Persona per
INNER JOIN Organizador org ON per.id_persona = org.id_persona
INNER JOIN Vendedor v ON org.id_persona = v.id_persona
INNER JOIN Alimento a ON v.id_persona = a.id_persona
GROUP BY per.id_persona, per.nombres, per.apellido_paterno, per.apellido_materno, v.ubicacion
HAVING COUNT(DISTINCT a.id_alimento) > 3
ORDER BY total_productos_distintos DESC;

-- x. Obtener el nombre completo de los participantes y su facultad que hayan participado 
--    tanto en el torneo de distancia recorrida como en el de captura de shinys, 
--    cuya distancia total recorrida sea mayor al promedio de distancia de todos los participantes 
--    y además que su número de capturas de shinys sean mayor a 5.
SELECT 
    CONCAT(per.nombres, ' ', per.apellido_paterno, ' ', per.apellido_materno) AS nombre_participante,
    p.num_cuenta,
    p.facultad,
    distancias.distancia_total,
    shinys.total_shinys
FROM Persona per
INNER JOIN Participante p ON per.id_persona = p.id_persona
INNER JOIN (
    -- Subconsulta para distancia total por participante
    SELECT 
        part.id_persona,
        SUM(d.distancia) AS distancia_total
    FROM Participar part
    INNER JOIN Torneo t ON part.id_torneo = t.id_torneo
    INNER JOIN Multi m ON t.id_torneo = m.id_torneo
    INNER JOIN Distancia d ON m.id_torneo = d.id_torneo
    WHERE m.esDistanciaRecorrida = TRUE
    GROUP BY part.id_persona
) distancias ON p.id_persona = distancias.id_persona
INNER JOIN (
    -- Subconsulta para contar shinys capturados por participante
    SELECT 
        c.id_persona,
        COUNT(pok.id_pokemon) AS total_shinys
    FROM Cuenta c
    INNER JOIN Pokemon pok ON c.codigo = pok.codigo
    INNER JOIN Torneo t ON pok.id_torneo = t.id_torneo
    INNER JOIN Multi m ON t.id_torneo = m.id_torneo
    WHERE pok.esShiny = TRUE
    AND m.esCaptura = TRUE
    GROUP BY c.id_persona
) shinys ON p.id_persona = shinys.id_persona
WHERE distancias.distancia_total > (
    -- Promedio de distancia de todos los participantes
    SELECT AVG(distancia_total)
    FROM (
        SELECT SUM(d.distancia) AS distancia_total
        FROM Participar part
        INNER JOIN Torneo t ON part.id_torneo = t.id_torneo
        INNER JOIN Multi m ON t.id_torneo = m.id_torneo
        INNER JOIN Distancia d ON m.id_torneo = d.id_torneo
        WHERE m.esDistanciaRecorrida = TRUE
        GROUP BY part.id_persona
    ) AS promedios
)
AND shinys.total_shinys > 5
ORDER BY distancias.distancia_total DESC, shinys.total_shinys DESC;
