/*
============================================
Proyecto Final
Equipo: Excelsistas
============================================
*/

BEGIN;

-- =====================================================
-- Evento (>=1000)
-- =====================================================
INSERT INTO Evento (fecha)
SELECT DATE '2020-01-01' + (g - 1)
FROM generate_series(1, 1000) AS g;

-- =====================================================
-- Persona (6000 ):
--   1..5000 -> esPersonal = TRUE
--   5001..6000 -> esEspectador = TRUE
-- =====================================================
WITH ap AS (
	SELECT ARRAY[
		'Garcia','Hernandez','Martinez','Lopez','Gonzalez','Perez','Sanchez','Ramirez','Cruz','Flores',
		'Rodriguez','Torres','Reyes','Diaz','Vargas','Castillo','Morales','Ortiz','Ramos','Romero'
	] AS arr
), am AS (
	SELECT ARRAY[
		'Mendoza','Navarro','Suarez','Chavez','Cabrera','Medina','Rojas','Cortes','Aguilar','Vega',
		'Luna','Campos','Herrera','Silva','Guerrero','Delgado','Arias','Soto','Pacheco','Camacho'
	] AS arr
), no AS (
	SELECT ARRAY[
		'Alejandro','Maria','Juan','Lucia','Carlos','Sofia','Luis','Valeria','Jorge','Camila',
		'Diego','Daniela','Miguel','Andrea','Fernando','Paula','Pedro','Gabriela','Ricardo','Renata'
	] AS arr
)
INSERT INTO Persona (fecha_de_nacimiento, apellido_paterno, apellido_materno, nombres, esPersonal, esEspectador)
SELECT
	(CURRENT_DATE - ((2 + (g % 79))::text || ' years')::interval
									- ((g % 365)::text || ' days')::interval)::date AS fecha_de_nacimiento,
	initcap((SELECT arr[((g-1) % 20)+1] FROM ap)) AS apellido_paterno,
	initcap((SELECT arr[((g+7) % 20)+1] FROM am)) AS apellido_materno,
	initcap((SELECT arr[((g+3) % 20)+1] FROM no)) AS nombres,
	CASE WHEN g <= 5000 THEN TRUE ELSE FALSE END AS esPersonal,
	CASE WHEN g <= 5000 THEN FALSE ELSE TRUE END AS esEspectador
FROM generate_series(1, 6000) AS g;

-- =====================================================
-- Espectador: 1000 (ids 5001..6000)
-- =====================================================
INSERT INTO Espectador (id_persona)
SELECT g FROM generate_series(5001, 6000) AS g;

-- =====================================================
-- Personal: 5000 (1..1000 participantes, 1001..5000 organizadores)
-- =====================================================
INSERT INTO Personal (id_persona, esParticipante, esOrganizador)
SELECT g,
			 CASE WHEN g <= 1000 THEN TRUE ELSE FALSE END,
			 CASE WHEN g > 1000 THEN TRUE ELSE FALSE END
FROM generate_series(1, 5000) AS g;

-- =====================================================
-- Organizador: 4000 (1001..5000) 
--   1001..2000: esCuidador
--   2001..3000: esRegistrador
--   3001..4000: esLimpiador
--   4001..5000: esVendedor
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
			 (SELECT arr[((g) % 10)+1] FROM ciudades),
			 (SELECT arr[((g+3) % 10)+1] FROM colonias),
			 (SELECT arr[((g+5) % 10)+1] FROM calles) || ' #' || ((g % 200)+1),
			 LPAD(((10000 + (g % 9000))::text), 5, '0'),
			 ((g % 999)+1)::text,
			 ((g % 50)+1)::text,
			 CASE WHEN g BETWEEN 2001 AND 3000 THEN TRUE ELSE FALSE END,
			 CASE WHEN g BETWEEN 1001 AND 2000 THEN TRUE ELSE FALSE END,
			 CASE WHEN g BETWEEN 3001 AND 4000 THEN TRUE ELSE FALSE END,
			 CASE WHEN g BETWEEN 4001 AND 5000 THEN TRUE ELSE FALSE END
FROM generate_series(1001, 5000) AS g;

-- Subtipos de Organizador (1000 cada uno)
INSERT INTO Cuidador (id_persona, locacion, horario, salario)
SELECT g, 'Zona ' || ((g % 20)+1), '0' || ((g % 9)+8) || ':00-1' || ((g % 4)+3) || ':00', 8000 + (g % 3000)
FROM generate_series(1001, 2000) AS g;

INSERT INTO Registrador (id_persona, salario_base)
SELECT g, 9000 + (g % 4000)
FROM generate_series(2001, 3000) AS g;

INSERT INTO Limpiador (id_persona, locacion, horario, salario)
SELECT g, 'Pabellon ' || ((g % 15)+1), '0' || ((g % 9)+8) || ':00-1' || ((g % 4)+3) || ':00', 7000 + (g % 2500)
FROM generate_series(3001, 4000) AS g;

INSERT INTO Vendedor (id_persona, ubicacion)
SELECT g, 'Puesto ' || ((g % 200)+1)
FROM generate_series(4001, 5000) AS g;

-- =====================================================
-- Participante: 1000 (id_torneo inicialmente NULL)
-- =====================================================
WITH fac AS (
	SELECT ARRAY['Ingenieria','Ciencias','Quimica','Medicina','Derecho','Economia','Arquitectura','Filosofia'] AS arr
), car AS (
	SELECT ARRAY['Computacion','Fisica','Matematicas','Biologia','Civil','Industrial','Telecom','Quimica'] AS arr
)
INSERT INTO Participante (id_persona, id_torneo, num_cuenta, facultad, carrera, ubicacion)
SELECT g, NULL,
			 100000 + g,
			 (SELECT arr[((g-1) % 8)+1] FROM fac),
			 (SELECT arr[((g+2) % 8)+1] FROM car),
			 'Sede ' || ((g % 20)+1)
FROM generate_series(1, 1000) AS g;

-- =====================================================
-- Datos de contacto del Personal (>=1000 cada uno)
-- =====================================================
INSERT INTO Emails (id_persona, email)
SELECT g, format('persona%04s@fbdd.example', g)
FROM generate_series(1, 1000) AS g;

INSERT INTO Telefonos (id_persona, telefono)
SELECT g, '55' || LPAD((g % 10000000)::text, 7, '0')
FROM generate_series(1, 1000) AS g;

-- =====================================================
-- Cuenta: 1000 para los 1000 participantes
-- =====================================================
WITH equipos AS (
	SELECT ARRAY['Valor','Mystic','Instinct'] AS arr
)
INSERT INTO Cuenta (id_persona, username, nivel, equipo)
SELECT g,
			 format('user_%04s', g),
			 1 + (g % 100),
			 (SELECT arr[((g) % 3)+1] FROM equipos)
FROM generate_series(1, 1000) AS g;

-- =====================================================
-- Torneo: 2000 (1000 Multi y 1000 Pelea), referencian ediciones y participantes
-- =====================================================
INSERT INTO Torneo (edicion, id_persona, esMulti, esPelea, premio)
SELECT ((g-1) % 1000) + 1, ((g-1) % 1000) + 1, TRUE, FALSE, (g % 5000)
FROM generate_series(1, 1000) AS g;  -- id_torneo 1..1000 -> Multi

INSERT INTO Torneo (edicion, id_persona, esMulti, esPelea, premio)
SELECT ((g-1) % 1000) + 1, ((g-1) % 1000) + 1, FALSE, TRUE, (g % 7000)
FROM generate_series(1, 1000) AS g;  -- id_torneo 1001..2000 -> Pelea

-- Multi para los primeros 1000 torneos (alternando modalidad)
INSERT INTO Multi (id_torneo, esCaptura, esDistanciaRecorrida)
SELECT g, (g % 2) = 1, (g % 2) = 0
FROM generate_series(1, 1000) AS g;

-- Pelea para los siguientes 1000 torneos
INSERT INTO Pelea (id_torneo)
SELECT g FROM generate_series(1001, 2000) AS g;

-- Vincular Participante.id_torneo a su torneo Multi correspondiente (mismo id_persona)
UPDATE Participante p
SET id_torneo = t.id_torneo
FROM Torneo t
WHERE t.esMulti = TRUE AND t.id_persona = p.id_persona;

-- =====================================================
-- Distancia: 1000 registros (1 por participante)
-- =====================================================
INSERT INTO Distancia (id_persona, distancia)
SELECT g, (5 + (g % 96))::decimal -- 5..100 km
FROM generate_series(1, 1000) AS g;

-- =====================================================
-- Alimento: 1000 productos ofrecidos por vendedores (4001..5000)
-- =====================================================
WITH tipos AS (
	SELECT ARRAY['Bebida','Comida','Snack'] AS arr
), nombres AS (
	SELECT ARRAY['Agua','Refresco','Sandwich','Taco','Cafe','Galletas','Jugos','Pizza','Hamburguesa','Ensalada'] AS arr
)
INSERT INTO Alimento (id_persona, tipo, nombre, precio, esPerecedero, fecha_caducidad)
SELECT 4000 + ((g-1) % 1000) + 1,
			 (SELECT arr[((g) % 3)+1] FROM tipos),
			 (SELECT arr[((g) % 10)+1] FROM nombres) || ' ' || ((g % 50)+1),
			 (20 + (g % 80))::decimal,
			 (g % 2) = 0,
			 CURRENT_DATE + ((g % 365) + 30)
FROM generate_series(1, 1000) AS g;

-- =====================================================
-- Comprar: 1000 compras por cualquier persona hacia alimentos
-- =====================================================
WITH pagos AS (
	SELECT ARRAY['Efectivo','Tarjeta','Transferencia'] AS arr
)
INSERT INTO Comprar (id_persona, id_alimento, metodo_pago, cantidad)
SELECT ((g-1) % 6000) + 1,
			 ((g-1) % 1000) + 1,
			 (SELECT arr[((g) % 3)+1] FROM pagos),
			 1 + (g % 5)
FROM generate_series(1, 1000) AS g;

-- =====================================================
-- Trabajar: 1000 relaciones Organizador-Evento
-- =====================================================
INSERT INTO Trabajar (id_organizador, edicion)
SELECT 1000 + g, g
FROM generate_series(1, 1000) AS g;

-- =====================================================
-- Participar: 1000 relaciones Participante-Torneo (usar torneos de pelea)
-- =====================================================
INSERT INTO Participar (id_persona, id_torneo)
SELECT g, 1000 + g
FROM generate_series(1, 1000) AS g;

-- =====================================================
-- Pokemon: 1000 pokémon (1 por cuenta), asignados a torneos de pelea
-- =====================================================
WITH cuentas AS (
	SELECT c.codigo, c.id_persona, ROW_NUMBER() OVER (ORDER BY c.codigo) AS rn
	FROM Cuenta c
), peleas AS (
	SELECT p.id_torneo, ROW_NUMBER() OVER (ORDER BY p.id_torneo) AS rn
	FROM Pelea p
	ORDER BY p.id_torneo
	LIMIT 1000
), especies AS (
	SELECT ARRAY['Pikachu','Charmander','Squirtle','Bulbasaur','Eevee','Snorlax','Gengar','Machop','Psyduck','Dratini'] AS arr
), tipos AS (
	SELECT ARRAY['Electrico','Fuego','Agua','Planta','Normal','Fantasma','Lucha','Psiquico','Dragon','Roca'] AS arr
), sexos AS (
	SELECT ARRAY['M','F','N'] AS arr
)
INSERT INTO Pokemon (codigo, id_torneo, apodo, especie, tipo, sexo, peso, puntos_combate, fecha_captura, esShiny, hora_captura)
SELECT c.codigo,
			 p.id_torneo,
			 'Pkmn_' || c.codigo::text,
			 (SELECT arr[((c.rn) % 10)+1] FROM especies),
			 (SELECT arr[((c.rn+3) % 10)+1] FROM tipos),
			 (SELECT arr[((c.rn+1) % 3)+1] FROM sexos),
			 (10 + (c.rn % 90))::decimal,
			 (c.rn % 4000),
			 CURRENT_DATE - ((c.rn % 1500))::int,
			 (c.rn % 10) = 0,
			 TIME '08:00:00' + ((c.rn % 3600) || ' seconds')::interval
FROM cuentas c
JOIN peleas p ON p.rn = c.rn
ORDER BY c.rn
LIMIT 1000;

-- =====================================================
-- Combate: 1000 (uno por torneo de pelea)
-- =====================================================
WITH fases AS (
	SELECT ARRAY['Octavos','Cuartos','Semifinal','Final'] AS arr
)
INSERT INTO Combate (id_torneo, fase)
SELECT p.id_torneo,
			 (SELECT arr[((ROW_NUMBER() OVER (ORDER BY p.id_torneo)) % 4)+1] FROM fases)
FROM Pelea p
ORDER BY p.id_torneo
LIMIT 1000;

-- =====================================================
-- Enfrentar: 1000 relaciones (un participante por combate)
-- =====================================================
WITH comb AS (
	SELECT c.id_combate, c.id_torneo, ROW_NUMBER() OVER (ORDER BY c.id_combate) AS rn
	FROM Combate c
	ORDER BY c.id_combate
	LIMIT 1000
)
INSERT INTO Enfrentar (id_combate, id_persona, id_torneo, esGanador)
SELECT cb.id_combate, ((cb.rn - 1) % 1000) + 1, cb.id_torneo, (cb.rn % 2) = 0
FROM comb cb;

-- =====================================================
-- Combatir: 1000 relaciones Pokemon-Combate
-- =====================================================
WITH pkm AS (
	SELECT id_pokemon, codigo, ROW_NUMBER() OVER (ORDER BY id_pokemon) AS rn
	FROM Pokemon
	ORDER BY id_pokemon
	LIMIT 1000
), cb AS (
	SELECT id_combate, id_torneo, ROW_NUMBER() OVER (ORDER BY id_combate) AS rn
	FROM Combate
	ORDER BY id_combate
	LIMIT 1000
)
INSERT INTO Combatir (id_pokemon, id_combate, id_torneo, codigo)
SELECT p.id_pokemon, c.id_combate, c.id_torneo, p.codigo
FROM pkm p
JOIN cb c ON c.rn = p.rn;

-- =====================================================
-- Registrar y Ser: 1000 relaciones Registrador-Participante
-- =====================================================
INSERT INTO Registrar (id_persona_p, id_persona_r)
SELECT g, 2000 + g
FROM generate_series(1, 1000) AS g;

INSERT INTO Ser (id_persona_r, id_persona_p)
SELECT 2000 + g, g
FROM generate_series(1, 1000) AS g;

-- =====================================================
-- Asistir: 1000 asistencias de espectadores a eventos
-- =====================================================
INSERT INTO Asistir (edicion, id_persona, hora_ingreso, hora_salida)
SELECT ((g-1) % 1000) + 1,
			 5000 + g,
			 TIME '10:00:00' + ((g % 300) || ' minutes')::interval,
			 TIME '12:00:00' + ((g % 300) || ' minutes')::interval
FROM generate_series(1, 1000) AS g;

COMMIT;
