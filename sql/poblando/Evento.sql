--1 a 5
insert into Evento (edicion, fecha) values (1, '2025-01-18');
insert into Evento (edicion, fecha) values (2, '2025-03-18');
insert into Evento (edicion, fecha) values (3, '2025-05-09');
insert into Evento (edicion, fecha) values (4, '2025-07-13');
insert into Evento (edicion, fecha) values (5, '2025-10-09');

-- Por cada evento 3 torneos (1 de pelea, 1 de captura y 1 de distancia)
-- Edición 1, los torneos 1 a 3
insert into Torneo (id_torneo, edicion, id_persona, esMulti, esPelea, premio) values (1, 1, 1001, false, true, 8500.00);
insert into Torneo (id_torneo, edicion, id_persona, esMulti, esPelea, premio) values (2, 1, 1002, true, false, 7200.50);
insert into Torneo (id_torneo, edicion, id_persona, esMulti, esPelea, premio) values (3, 1, 1003, true, false, 6800.75);
-- Edición 2, los torneos 4 a 6
insert into Torneo (id_torneo, edicion, id_persona, esMulti, esPelea, premio) values (4, 2, 1004, false, true, 9100.00);
insert into Torneo (id_torneo, edicion, id_persona, esMulti, esPelea, premio) values (5, 2, 1005, true, false, 7800.25);
insert into Torneo (id_torneo, edicion, id_persona, esMulti, esPelea, premio) values (6, 2, 1006, true, false, 7500.60);
-- Edición 3, los torneos 7 a 9
insert into Torneo (id_torneo, edicion, id_persona, esMulti, esPelea, premio) values (7, 3, 1007, false, true, 8800.00);
insert into Torneo (id_torneo, edicion, id_persona, esMulti, esPelea, premio) values (8, 3, 1008, true, false, 7400.90);
insert into Torneo (id_torneo, edicion, id_persona, esMulti, esPelea, premio) values (9, 3, 1009, true, false, 6900.40);
-- Edición 4, los torneos 10 a 12
insert into Torneo (id_torneo, edicion, id_persona, esMulti, esPelea, premio) values (10, 4, 1010, false, true, 9500.00);
insert into Torneo (id_torneo, edicion, id_persona, esMulti, esPelea, premio) values (11, 4, 1011, true, false, 8100.35);
insert into Torneo (id_torneo, edicion, id_persona, esMulti, esPelea, premio) values (12, 4, 1012, true, false, 7700.80);
-- Edición 5, los torneos 13 a 15
insert into Torneo (id_torneo, edicion, id_persona, esMulti, esPelea, premio) values (13, 5, 1013, false, true, 10000.00);
insert into Torneo (id_torneo, edicion, id_persona, esMulti, esPelea, premio) values (14, 5, 1014, true, false, 8500.50);
insert into Torneo (id_torneo, edicion, id_persona, esMulti, esPelea, premio) values (15, 5, 1015, true, false, 8200.25);


-- Torneos de Pelea
insert into Pelea (id_torneo) values (1);
insert into Pelea (id_torneo) values (4);
insert into Pelea (id_torneo) values (7);
insert into Pelea (id_torneo) values (10);
insert into Pelea (id_torneo) values (13);

-- Torneos de Captura
insert into Multi (id_torneo, esCaptura, esDistanciaRecorrida, ubicacion) values (2, true, false, 'Instituto de Astronomía');
insert into Multi (id_torneo, esCaptura, esDistanciaRecorrida, ubicacion) values (5, true, false, 'Facultad de Medicina');
insert into Multi (id_torneo, esCaptura, esDistanciaRecorrida, ubicacion) values (8, true, false, 'Facultad de Química');
insert into Multi (id_torneo, esCaptura, esDistanciaRecorrida, ubicacion) values (11, true, false, 'Facultad de Ingeniería');
insert into Multi (id_torneo, esCaptura, esDistanciaRecorrida, ubicacion) values (14, true, false, 'Ciudad Universitaria');

-- Torneos de Distancia
insert into Multi (id_torneo, esCaptura, esDistanciaRecorrida, ubicacion) values (3, false, true, 'Estadio Olímpico');
insert into Multi (id_torneo, esCaptura, esDistanciaRecorrida, ubicacion) values (6, false, true, 'Jardín Botánico');
insert into Multi (id_torneo, esCaptura, esDistanciaRecorrida, ubicacion) values (9, false, true, 'Zona Deportiva');
insert into Multi (id_torneo, esCaptura, esDistanciaRecorrida, ubicacion) values (12, false, true, 'Reserva Ecológica');
insert into Multi (id_torneo, esCaptura, esDistanciaRecorrida, ubicacion) values (15, false, true, 'Paseo de las Esculturas');

