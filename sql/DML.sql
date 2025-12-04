/*
============================================
Proyecto Final
Equipo: Excelsistas
============================================
*/

BEGIN;

-- =====================================================
-- Evento: 1200 ediciones (dos por mes aprox.)
-- =====================================================
INSERT INTO Evento (fecha)
SELECT DATE '2024-01-06' + ((g - 1) * 15)
FROM generate_series(1, 1200) AS g;

-- =====================================================
-- Persona: 10000 registros (8000 personal, 2000 espectadores)
-- =====================================================
WITH ap AS (
  SELECT ARRAY[
    'Garcia','Hernandez','Martinez','Lopez','Gonzalez','Perez','Sanchez','Ramirez','Cruz','Flores',
    'Rodriguez','Torres','Reyes','Diaz','Vargas','Castillo','Morales','Ortiz','Ramos','Romero',
    'Maldonado','Pineda','Salazar','Cervantes','Nunez','Velazquez','Villanueva','Fuentes','Camacho','Coronado',
    'Trejo','Arriaga','Galindo','Bautista','Ibarra','Valenzuela','Mejia','Quezada','Montoya','Acosta'
  ] AS arr
), am AS (
  SELECT ARRAY[
    'Mendoza','Navarro','Suarez','Chavez','Cabrera','Medina','Rojas','Cortes','Aguilar','Vega',
    'Luna','Campos','Herrera','Silva','Guerrero','Delgado','Arias','Soto','Pacheco','Camacho',
    'Beltran','Esparza','Franco','Gaytan','Hidalgo','Izaguirre','Juarez','Lira','Miramontes','Noriega',
    'Olivares','Prado','Quintana','Rocha','Saavedra','Tamayo','Uribe','Valdivia','Wong','Zavala'
  ] AS arr
), no AS (
  SELECT ARRAY[
    'Alejandro','Maria','Juan','Lucia','Carlos','Sofia','Luis','Valeria','Jorge','Camila',
    'Diego','Daniela','Miguel','Andrea','Fernando','Paula','Pedro','Gabriela','Ricardo','Renata',
    'Emiliano','Jimena','Sebastian','Regina','Bruno','Adriana','Hector','Montserrat','Pablo','Julieta',
    'Nicolas','Aitana','Mauricio','Itzel','Rafael','Arantza','Hugo','Patricia','Victor','Elena'
  ] AS arr
)
INSERT INTO Persona (fecha_de_nacimiento, apellido_paterno, apellido_materno, nombres, esPersonal, esEspectador)
SELECT
  (CURRENT_DATE - ((18 + (g % 40))::text || ' years')::interval
                  - ((g % 365)::text || ' days')::interval)::date AS fecha_de_nacimiento,
  initcap((SELECT arr[((g - 1) % 40) + 1] FROM ap)) AS apellido_paterno,
  initcap((SELECT arr[(((g - 1) / 40) % 40) + 1] FROM am)) AS apellido_materno,
  initcap((SELECT arr[(((g - 1) / 1600) % 40) + 1] FROM no)) AS nombres,
  CASE WHEN g <= 8000 THEN TRUE ELSE FALSE END AS esPersonal,
  CASE WHEN g > 8000 THEN TRUE ELSE FALSE END AS esEspectador
FROM generate_series(1, 10000) AS g;

-- =====================================================
-- Espectador: ids 8001..10000 (2000 asistentes)
-- =====================================================
INSERT INTO Espectador (id_persona)
SELECT g FROM generate_series(8001, 10000) AS g;

-- =====================================================
-- Personal: ids 1..8000 (4000 participantes, 4000 organizadores)
-- =====================================================
INSERT INTO Personal (id_persona, esParticipante, esOrganizador)
SELECT g,
       CASE WHEN g <= 4000 THEN TRUE ELSE FALSE END,
       CASE WHEN g > 4000 THEN TRUE ELSE FALSE END
FROM generate_series(1, 8000) AS g;

-- =====================================================
-- Organizador y subtipos (4000 registros, roles exclusivos)
-- =====================================================
WITH ciudades AS (
  SELECT ARRAY['CDMX','Guadalajara','Monterrey','Puebla','Toluca','Queretaro','Merida','Tijuana','Leon','Morelia'] AS arr
), colonias AS (
  SELECT ARRAY['Centro','Roma','Condesa','Del Valle','Polanco','Lindavista','Narvarte','Juarez','Nativitas','Escandon'] AS arr
), calles AS (
  SELECT ARRAY['Primera','Segunda','Tercera','Cuarta','Quinta','Sexta','Septima','Octava','Novena','Decima'] AS arr
)
INSERT INTO Organizador (
  id_persona, ciudad, colonia, calle, codigo_postal, num_exterior, num_interior,
  esRegistrador, esCuidador, esLimpiador, esVendedor
)
SELECT g,
       (SELECT arr[((g) % 10) + 1] FROM ciudades),
       (SELECT arr[((g + 3) % 10) + 1] FROM colonias),
       (SELECT arr[((g + 5) % 10) + 1] FROM calles) || ' #' || ((g % 200) + 1),
       LPAD(((10000 + (g % 9000))::text), 5, '0'),
       ((g % 999) + 1)::text,
       ((g % 50) + 1)::text,
       CASE WHEN g BETWEEN 5001 AND 6000 THEN TRUE ELSE FALSE END,
       CASE WHEN g BETWEEN 4001 AND 5000 THEN TRUE ELSE FALSE END,
       CASE WHEN g BETWEEN 6001 AND 7000 THEN TRUE ELSE FALSE END,
       CASE WHEN g BETWEEN 7001 AND 8000 THEN TRUE ELSE FALSE END
FROM generate_series(4001, 8000) AS g;

INSERT INTO Cuidador (id_persona, locacion, horario, salario)
SELECT g,
       'Zona ' || ((g % 30) + 1),
       CASE WHEN (g % 2) = 0 THEN '09:00-15:00' ELSE '15:00-21:00' END,
       9000 + (g % 2500)
FROM generate_series(4001, 5000) AS g;

INSERT INTO Registrador (id_persona, salario_base)
SELECT g, 11000 + (g % 4000)
FROM generate_series(5001, 6000) AS g;

INSERT INTO Limpiador (id_persona, locacion, horario, salario)
SELECT g,
       'Pabellon ' || ((g % 20) + 1),
       CASE WHEN (g % 2) = 0 THEN '09:00-15:00' ELSE '15:00-21:00' END,
       8500 + (g % 2200)
FROM generate_series(6001, 7000) AS g;

INSERT INTO Vendedor (id_persona, ubicacion)
SELECT g, 'Puesto ' || ((g % 250) + 1)
FROM generate_series(7001, 8000) AS g;

-- =====================================================
-- Participante: ids 1..4000 (2000 multi, 2000 pelea)
-- =====================================================
WITH fac AS (
  SELECT ARRAY['Ingenieria','Ciencias','Quimica','Medicina','Derecho','Economia','Arquitectura','Filosofia'] AS arr
), car AS (
  SELECT ARRAY['Computacion','Fisica','Matematicas','Biologia','Civil','Industrial','Telecom','Quimica'] AS arr
), ubi AS (
  SELECT ARRAY['Sede Norte','Sede Sur','Sede Oriente','Sede Poniente','Sede Centro','Sede CU','Sede ENP','Sede FES'] AS arr
)
INSERT INTO Participante (id_persona, id_torneo, num_cuenta, facultad, carrera, ubicacion)
SELECT g,
       NULL,
       100000 + g,
       (SELECT arr[((g - 1) % 8) + 1] FROM fac),
       (SELECT arr[((g + 2) % 8) + 1] FROM car),
       (SELECT arr[((g) % 8) + 1] FROM ubi)
FROM generate_series(1, 4000) AS g;

-- =====================================================
-- Contacto del personal (emails y teléfonos para 8000 registros)
-- =====================================================
INSERT INTO Emails (id_persona, email)
SELECT g, format('contact%05s@sba.unam.mx', g)
FROM generate_series(1, 8000) AS g;

INSERT INTO Telefonos (id_persona, telefono)
SELECT g, '55' || LPAD((g % 100000000)::text, 8, '0')
FROM generate_series(1, 8000) AS g;

-- =====================================================
-- Cuenta: 4000 cuentas de Pokémon Go
-- =====================================================
WITH equipos AS (
  SELECT ARRAY['Valor','Mystic','Instinct'] AS arr
)
INSERT INTO Cuenta (id_persona, username, nivel, equipo)
SELECT g,
       format('trainer_%04s', g),
       10 + (g % 70),
       (SELECT arr[((g) % 3) + 1] FROM equipos)
FROM generate_series(1, 4000) AS g;

-- =====================================================
-- Cuentas adicionales: al menos 100 personas con multicuenta
-- =====================================================
WITH equipos AS (
  SELECT ARRAY['Valor','Mystic','Instinct'] AS arr
)
INSERT INTO Cuenta (id_persona, username, nivel, equipo)
SELECT g,
       format('trainer_%04s_extra', g),
       20 + (g % 50),
       (SELECT arr[((g + 1) % 3) + 1] FROM equipos)
FROM generate_series(1, 150) AS g;

-- =====================================================
-- Torneo: 2000 registros (1000 multi, 1000 pelea)
-- =====================================================
INSERT INTO Torneo (edicion, id_persona, esMulti, esPelea, premio)
SELECT ((g - 1) % 1200) + 1,
       CASE WHEN g <= 1000 THEN ((g - 1) % 2000) + 1 ELSE 2000 + ((g - 1001) % 2000) + 1 END,
       CASE WHEN g <= 1000 THEN TRUE ELSE FALSE END,
       CASE WHEN g > 1000 THEN TRUE ELSE FALSE END,
       CASE WHEN g <= 1000 THEN 3000 + ((g * 73) % 1200) ELSE 5000 + ((g * 91) % 1800) END
FROM generate_series(1, 2000) AS g;

INSERT INTO Multi (id_torneo, esCaptura, esDistanciaRecorrida)
SELECT g,
       CASE WHEN g <= 500 THEN TRUE ELSE FALSE END,
       CASE WHEN g > 500 THEN TRUE ELSE FALSE END
FROM generate_series(1, 1000) AS g;

UPDATE Participante
SET id_torneo = ((id_persona - 1) % 1000) + 1
WHERE id_persona <= 2000;

INSERT INTO Pelea (id_torneo)
SELECT g FROM generate_series(1001, 2000) AS g;

-- =====================================================
-- Participar: relaciones para multi (captura/distancia) y pelea
-- =====================================================
WITH capt AS (
  SELECT pid,
    ((pid + shift) % 500) + 1 AS torneo
  FROM generate_series(1, 2000) AS pid
  CROSS JOIN (VALUES (0),(125)) AS shifts(shift)
)
INSERT INTO Participar (id_persona, id_torneo)
SELECT pid, torneo FROM capt;

WITH dist AS (
  SELECT pid,
    500 + (((pid + shift) % 500) + 1) AS torneo
  FROM generate_series(501, 2000) AS pid
  CROSS JOIN (VALUES (0),(175)) AS shifts(shift)
)
INSERT INTO Participar (id_persona, id_torneo)
SELECT pid, torneo FROM dist;

INSERT INTO Participar (id_persona, id_torneo)
SELECT 2000 + (2 * g - 1), 1000 + g
FROM generate_series(1, 1000) AS g;

INSERT INTO Participar (id_persona, id_torneo)
SELECT 2000 + (2 * g), 1000 + g
FROM generate_series(1, 1000) AS g;

-- =====================================================
-- Distancia: tres checkpoints por participante 501..2000
-- =====================================================
INSERT INTO Distancia (id_persona, distancia)
SELECT pid,
       (5 + (pid % 15) + checkpoint * 10 + ((pid % 3) * 0.5))::decimal(10,2)
FROM generate_series(501, 2000) AS pid
CROSS JOIN generate_series(0, 2) AS checkpoint;

-- =====================================================
-- Alimento: 1500 productos para vendedores 7001..8000
-- =====================================================
WITH tipos AS (
  SELECT ARRAY['Bebida','Comida','Snack'] AS arr
), nombres AS (
  SELECT ARRAY['Agua','Refresco','Sandwich','Taco','Cafe','Galletas','Jugos','Pizza','Hamburguesa','Ensalada'] AS arr
)
INSERT INTO Alimento (id_persona, tipo, nombre, precio, esPerecedero, fecha_caducidad)
SELECT 7000 + ((g - 1) % 1000) + 1,
       (SELECT arr[((g) % 3) + 1] FROM tipos),
       (SELECT arr[((g) % 10) + 1] FROM nombres) || ' ' || ((g % 80) + 1),
       (25 + (g % 70))::decimal(6,2),
       (g % 2) = 0,
       CURRENT_DATE + ((g % 180) + 30)
FROM generate_series(1, 1500) AS g;

-- =====================================================
-- Trabajar: cada organizador atiende 2 ediciones
-- =====================================================
INSERT INTO Trabajar (id_organizador, edicion)
SELECT org,
  ((org + shift - 1) % 1200) + 1
FROM generate_series(4001, 8000) AS org
CROSS JOIN (VALUES (0),(200)) AS shifts(shift);

-- =====================================================
-- Registrar / Ser: asignar 4000 participantes a 1000 registradores
-- =====================================================
INSERT INTO Registrar (id_persona_p, id_persona_r)
SELECT pid, 5000 + ((pid - 1) % 1000) + 1
FROM generate_series(1, 4000) AS pid;

INSERT INTO Ser (id_persona_r, id_persona_p)
SELECT 5000 + ((pid - 1) % 1000) + 1, pid
FROM generate_series(1, 4000) AS pid;

-- =====================================================
-- Cuenta ya creada -> ahora Poblar Pokémon (3 por cuenta)
-- =====================================================
WITH especies AS (
  SELECT ARRAY['Pikachu','Charmander','Squirtle','Bulbasaur','Eevee','Snorlax','Gengar','Machop','Psyduck','Dratini','Absol','Gardevoir'] AS arr
), tipos AS (
  SELECT ARRAY['Electrico','Fuego','Agua','Planta','Normal','Fantasma','Lucha','Psiquico','Dragon','Roca'] AS arr
), sexos AS (
  SELECT ARRAY['M','F','N'] AS arr
), cuentas AS (
  SELECT c.codigo,
         c.id_persona,
         CASE WHEN c.id_persona <= 2000 THEN ((c.id_persona - 1) % 1000) + 1 ELSE 1000 + CEIL((c.id_persona - 2000)::numeric / 2) END AS torneo_destino,
         ROW_NUMBER() OVER (ORDER BY c.codigo) AS rn
  FROM Cuenta c
)
INSERT INTO Pokemon (codigo, id_torneo, apodo, especie, tipo, sexo, peso, puntos_combate, fecha_captura, esShiny, hora_captura)
SELECT cu.codigo,
       cu.torneo_destino,
       format('Pkmn_%04s_%s', cu.codigo, gs.slot),
       (SELECT arr[((cu.rn + gs.slot) % 12) + 1] FROM especies),
       (SELECT arr[((cu.rn + gs.slot + 4) % 10) + 1] FROM tipos),
       (SELECT arr[((cu.rn + gs.slot) % 3) + 1] FROM sexos),
       (8 + ((cu.rn + gs.slot) % 40))::decimal(6,2),
      400 + ((cu.rn * 37 + gs.slot * 53) % 3500),
      (CURRENT_DATE - ((((cu.rn + gs.slot) % 800) + 5) * INTERVAL '1 day'))::date,
       (cu.id_persona <= 2000 AND gs.slot = 3 AND ((cu.rn + gs.slot) % 4 = 0)),
       TIME '07:00:00' + (((cu.rn * 3 + gs.slot * 11) % 360) || ' minutes')::interval
FROM cuentas cu
CROSS JOIN LATERAL generate_series(1, 3) AS gs(slot);

-- =====================================================
-- Combate: 3 combates por torneo de pelea
-- =====================================================
WITH fases AS (
  SELECT * FROM (VALUES ('Clasificatoria',1),('Semifinal',2),('Final',3)) AS f(fase, orden)
)
INSERT INTO Combate (id_torneo, fase)
SELECT 1000 + t, f.fase
FROM generate_series(1, 1000) AS t
JOIN fases f ON TRUE
ORDER BY t, f.orden;

-- =====================================================
-- Enfrentar: mismos dos participantes disputan las 3 rondas
-- =====================================================
WITH comb AS (
  SELECT id_combate, id_torneo,
         ROW_NUMBER() OVER (PARTITION BY id_torneo ORDER BY id_combate) AS ronda
  FROM Combate
), parejas AS (
  SELECT id_torneo,
         2000 + ((id_torneo - 1001) * 2) + 1 AS fighter_a,
         2000 + ((id_torneo - 1001) * 2) + 2 AS fighter_b
  FROM (SELECT DISTINCT id_torneo FROM Combate) AS t
)
INSERT INTO Enfrentar (id_combate, id_persona, id_torneo, esGanador)
SELECT c.id_combate,
       CASE WHEN s.slot = 1 THEN p.fighter_a ELSE p.fighter_b END,
       c.id_torneo,
       CASE WHEN ((c.ronda + s.slot) % 2) = 0 THEN TRUE ELSE FALSE END
FROM comb c
JOIN parejas p ON p.id_torneo = c.id_torneo
CROSS JOIN (VALUES (1),(2)) AS s(slot);

-- =====================================================
-- Combatir: asociar dos pokémon por pelea
-- =====================================================
WITH fighter_pkm AS (
  SELECT p.id_pokemon, p.codigo, c.id_persona, p.id_torneo,
         ROW_NUMBER() OVER (PARTITION BY c.id_persona ORDER BY p.id_pokemon) AS rn
  FROM Pokemon p
  JOIN Cuenta c ON c.codigo = p.codigo
  WHERE c.id_persona BETWEEN 2001 AND 4000
    AND p.id_torneo BETWEEN 1001 AND 2000
), pkm_slots AS (
  SELECT id_pokemon, codigo, id_persona, id_torneo,
         CASE WHEN rn % 2 = 1 THEN 1 ELSE 2 END AS slot
  FROM fighter_pkm
  WHERE rn <= 2
), comb AS (
  SELECT id_combate, id_torneo
  FROM Combate
), parejas AS (
  SELECT id_torneo,
         2000 + ((id_torneo - 1001) * 2) + 1 AS fighter_a,
         2000 + ((id_torneo - 1001) * 2) + 2 AS fighter_b
  FROM (SELECT DISTINCT id_torneo FROM Combate) AS t
)
INSERT INTO Combatir (id_pokemon, id_combate, id_torneo, codigo)
SELECT CASE WHEN s.slot = 1 THEN pa.id_pokemon ELSE pb.id_pokemon END,
       c.id_combate,
       c.id_torneo,
       CASE WHEN s.slot = 1 THEN pa.codigo ELSE pb.codigo END
FROM comb c
JOIN parejas pr ON pr.id_torneo = c.id_torneo
JOIN pkm_slots pa ON pa.id_persona = pr.fighter_a AND pa.id_torneo = c.id_torneo AND pa.slot = 1
JOIN pkm_slots pb ON pb.id_persona = pr.fighter_b AND pb.id_torneo = c.id_torneo AND pb.slot = 2
CROSS JOIN (VALUES (1),(2)) AS s(slot);

-- =====================================================
-- Comprar: 3000 compras diversas
-- =====================================================
WITH pagos AS (
  SELECT ARRAY['Efectivo','Tarjeta','Paypal'] AS arr
)
INSERT INTO Comprar (id_persona, id_alimento, metodo_pago, cantidad)
SELECT ((g - 1) % 10000) + 1,
       ((g - 1) % 1500) + 1,
       (SELECT arr[((g) % 3) + 1] FROM pagos),
       1 + (g % 4)
FROM generate_series(1, 3000) AS g;

-- =====================================================
-- Asistir: 2000 espectadores, horarios coherentes
-- =====================================================
INSERT INTO Asistir (edicion, id_persona, hora_ingreso, hora_salida)
SELECT ((g - 1) % 1200) + 1,
       8000 + g,
       TIME '09:00:00' + ((g % 180) || ' minutes')::interval,
       TIME '11:45:00' + ((g % 90) || ' minutes')::interval
FROM generate_series(1, 2000) AS g;

COMMIT;
