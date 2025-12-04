/*
============================================
Proyecto Final
Equipo: Excelsistas
============================================
*/

-- Creación del esquema
DROP SCHEMA IF EXISTS public CASCADE;
CREATE SCHEMA public;

-- ============================================
-- TABLAS CON LLAVES PRIMARIAS SIMPLES
-- ============================================

-- Tabla Persona
CREATE TABLE Persona (
    id_persona SERIAL,
    fecha_de_nacimiento DATE,
    apellido_paterno VARCHAR(100),
    apellido_materno VARCHAR(100),
    nombres VARCHAR(100),
    esPersonal BOOLEAN,
    esEspectador BOOLEAN
);

-- Restricciones Persona
-- Dominio
ALTER TABLE Persona ADD CONSTRAINT persona_d1
CHECK (fecha_de_nacimiento <= CURRENT_DATE - INTERVAL '1 year' AND
       fecha_de_nacimiento >= CURRENT_DATE - INTERVAL '149 years');
ALTER TABLE Persona ALTER COLUMN fecha_de_nacimiento SET NOT NULL;

ALTER TABLE Persona ADD CONSTRAINT persona_d2
CHECK (apellido_paterno <> '');
ALTER TABLE Persona ALTER COLUMN apellido_paterno SET NOT NULL;

ALTER TABLE Persona ADD CONSTRAINT persona_d3
CHECK (nombres <> '');
ALTER TABLE Persona ALTER COLUMN nombres SET NOT NULL;

ALTER TABLE Persona ALTER COLUMN esPersonal SET NOT NULL;
ALTER TABLE Persona ALTER COLUMN esEspectador SET NOT NULL;

ALTER TABLE Persona ADD CONSTRAINT persona_d4
CHECK (
    (esPersonal = TRUE AND esEspectador = FALSE) OR
    (esPersonal = FALSE AND esEspectador = TRUE)
);

ALTER TABLE Persona ADD CONSTRAINT persona_d5
CHECK (apellido_materno <> '');
ALTER TABLE Persona ALTER COLUMN apellido_materno SET NOT NULL;

-- Entidad
    ALTER TABLE Persona ADD CONSTRAINT persona_pkey
    PRIMARY KEY (id_persona);

    -- COMENTARIOS Persona
    COMMENT ON TABLE Persona IS 'Tabla que almacena información de personas que pueden ser personal o espectadores';
    COMMENT ON COLUMN Persona.id_persona IS 'Identificador único de la persona';
    COMMENT ON COLUMN Persona.fecha_de_nacimiento IS 'Fecha de nacimiento de la persona';
    COMMENT ON COLUMN Persona.apellido_paterno IS 'Apellido paterno de la persona';
    COMMENT ON COLUMN Persona.apellido_materno IS 'Apellido materno de la persona';
    COMMENT ON COLUMN Persona.nombres IS 'Nombres de la persona';
    COMMENT ON COLUMN Persona.esPersonal IS 'Indica si la persona es personal del evento';
    COMMENT ON COLUMN Persona.esEspectador IS 'Indica si la persona es espectador del evento';
    COMMENT ON CONSTRAINT persona_pkey ON Persona IS 'Llave primaria de la tabla Persona';
    COMMENT ON CONSTRAINT persona_d1 ON Persona IS 'Para asegurarnos de que la edad sea válida';
    COMMENT ON CONSTRAINT persona_d2 ON Persona IS 'Para asegurar que apellido paterno no sea vacío';
    COMMENT ON CONSTRAINT persona_d3 ON Persona IS 'Para asegurar que nombres no sea vacío';
    COMMENT ON CONSTRAINT persona_d4 ON Persona IS 'Para que sea personal o espectador pero no ambos';
    COMMENT ON CONSTRAINT persona_d5 ON Persona IS 'Para asegurar que apellido materno no sea vacío';

-- Tabla Evento
CREATE TABLE Evento (
    edicion SERIAL,
    fecha DATE
);

-- Restricciones Evento
-- Dominio
ALTER TABLE Evento ALTER COLUMN fecha SET NOT NULL;

-- Entidad
ALTER TABLE Evento ADD CONSTRAINT evento_pkey
PRIMARY KEY (edicion);

-- COMENTARIOS Evento
COMMENT ON TABLE Evento IS 'Tabla que almacena los eventos por edición';
COMMENT ON COLUMN Evento.edicion IS 'Número de edición del evento';
COMMENT ON COLUMN Evento.fecha IS 'Fecha en que se realiza el evento';
COMMENT ON CONSTRAINT evento_pkey ON Evento IS 'Llave primaria de la tabla Evento';

-- Tabla Espectador
CREATE TABLE Espectador (
    id_persona INTEGER
);

-- Restricciones Espectador
-- Dominio

-- Entidad
ALTER TABLE Espectador ADD CONSTRAINT espectador_pkey
PRIMARY KEY (id_persona);

-- Referencial
ALTER TABLE Espectador ADD CONSTRAINT espectador_fkey1
FOREIGN KEY (id_persona) REFERENCES Persona(id_persona)
ON DELETE CASCADE
ON UPDATE CASCADE;

-- COMENTARIOS Espectador
COMMENT ON TABLE Espectador IS 'Tabla que almacena información de los espectadores';
COMMENT ON COLUMN Espectador.id_persona IS 'Identificador de la persona que es espectador';
COMMENT ON CONSTRAINT espectador_pkey ON Espectador IS 'Llave primaria de la tabla Espectador';
COMMENT ON CONSTRAINT espectador_fkey1 ON Espectador IS 'Llave foránea que referencia a Persona';

-- Tabla Personal
CREATE TABLE Personal (
    id_persona INTEGER,
    esParticipante BOOLEAN,
    esOrganizador BOOLEAN
);

-- Restricciones Personal
-- Dominio
ALTER TABLE Personal ALTER COLUMN esParticipante SET NOT NULL;
ALTER TABLE Personal ALTER COLUMN esOrganizador SET NOT NULL;

-- Entidad
ALTER TABLE Personal ADD CONSTRAINT personal_pkey
PRIMARY KEY (id_persona);

-- Referencial
ALTER TABLE Personal ADD CONSTRAINT personal_fkey1
FOREIGN KEY (id_persona) REFERENCES Persona(id_persona)
ON DELETE CASCADE
ON UPDATE CASCADE;


-- COMENTARIOS Personal
COMMENT ON TABLE Personal IS 'Tabla que almacena información del personal del evento';
COMMENT ON COLUMN Personal.id_persona IS 'Identificador de la persona que es personal';
COMMENT ON COLUMN Personal.esParticipante IS 'Indica si la persona es participante';
COMMENT ON COLUMN Personal.esOrganizador IS 'Indica si la persona es organizador';
COMMENT ON CONSTRAINT personal_pkey ON Personal IS 'Llave primaria de la tabla Personal';
COMMENT ON CONSTRAINT personal_fkey1 ON Personal IS 'Llave foránea que referencia a Persona';

-- Tabla Participante
CREATE TABLE Participante (
    id_persona INTEGER,
    id_torneo INTEGER,
    num_cuenta INTEGER,
    facultad VARCHAR(100),
    carrera VARCHAR(100),
    ubicacion VARCHAR(100)
);

-- Restricciones Participante
-- Dominio
ALTER TABLE Participante ADD CONSTRAINT participante_d1
CHECK (facultad <> '');
ALTER TABLE Participante ALTER COLUMN facultad SET NOT NULL;

ALTER TABLE Participante ADD CONSTRAINT participante_d2
CHECK (carrera <> '');
ALTER TABLE Participante ALTER COLUMN carrera SET NOT NULL;

ALTER TABLE Participante ADD CONSTRAINT participante_d3
CHECK (num_cuenta > 0 AND num_cuenta < 999999999);
ALTER TABLE Participante ALTER COLUMN num_cuenta SET NOT NULL;

-- Entidad
ALTER TABLE Participante ADD CONSTRAINT participante_pkey
PRIMARY KEY (id_persona);

-- Referencial
ALTER TABLE Participante ADD CONSTRAINT participante_fkey1
FOREIGN KEY (id_persona) REFERENCES Personal(id_persona)
ON DELETE CASCADE
ON UPDATE CASCADE;

/*
Dado que multi debe de existir, se agrega tras la creación de Multi
===
ALTER TABLE Participante ADD CONSTRAINT participante_fkey2
FOREIGN KEY (id_torneo) REFERENCES Multi(id_torneo)
ON DELETE CASCADE
ON UPDATE CASCADE;
===
*/

-- Asegurar que el vínculo a la persona exista
ALTER TABLE Participante ALTER COLUMN id_persona SET NOT NULL;

-- COMENTARIOS Participante
COMMENT ON TABLE Participante IS 'Tabla que almacena información de participantes';
COMMENT ON COLUMN Participante.id_persona IS 'Identificador de la persona que es participante';
COMMENT ON COLUMN Participante.num_cuenta IS 'Número de cuenta del participante';
COMMENT ON COLUMN Participante.facultad IS 'Facultad a la que pertenece el participante';
COMMENT ON COLUMN Participante.carrera IS 'Carrera del participante';
COMMENT ON COLUMN Participante.ubicacion IS 'Ubicación actual del participante';
COMMENT ON CONSTRAINT participante_pkey ON Participante IS 'Llave primaria de la tabla Participante';
COMMENT ON CONSTRAINT participante_fkey1 ON Participante IS 'Llave foránea que referencia a Personal';
COMMENT ON CONSTRAINT participante_d1 ON Participante IS 'Restricción para que facultad no sea vacío';
COMMENT ON CONSTRAINT participante_d2 ON Participante IS 'Restricción para que carrera no sea vacío';
COMMENT ON CONSTRAINT participante_d3 ON Participante IS 'Restricción para que num_cuenta esté entre 1 y 999998';

-- Tabla Cuenta
CREATE TABLE Cuenta (
    codigo SERIAL,
    id_persona INTEGER,
    username VARCHAR(50),
    nivel INTEGER,
    equipo VARCHAR(100)
);

-- Restricciones Cuenta
-- Dominio
ALTER TABLE Cuenta ALTER COLUMN id_persona SET NOT NULL;

ALTER TABLE Cuenta ADD CONSTRAINT cuenta_d1
CHECK (username <> '');
ALTER TABLE Cuenta ALTER COLUMN username SET NOT NULL;
ALTER TABLE Cuenta ADD CONSTRAINT cuenta_d2 UNIQUE (username);

ALTER TABLE Cuenta ADD CONSTRAINT cuenta_d3
CHECK (nivel >= 1 AND nivel <= 100);

ALTER TABLE Cuenta ADD CONSTRAINT cuenta_d4
CHECK (equipo <> '');
ALTER TABLE Cuenta ALTER COLUMN equipo SET NOT NULL;

-- Entidad
ALTER TABLE Cuenta ADD CONSTRAINT cuenta_pkey
PRIMARY KEY (codigo);

-- Referencial
ALTER TABLE Cuenta ADD CONSTRAINT cuenta_fkey1
FOREIGN KEY (id_persona) REFERENCES Participante(id_persona)
ON DELETE CASCADE
ON UPDATE CASCADE;

-- COMENTARIOS Cuenta
COMMENT ON TABLE Cuenta IS 'Tabla que almacena las cuentas de los participantes';
COMMENT ON COLUMN Cuenta.codigo IS 'Código único de la cuenta';
COMMENT ON COLUMN Cuenta.id_persona IS 'Identificador de la persona dueña de la cuenta';
COMMENT ON COLUMN Cuenta.username IS 'Nombre de usuario de la cuenta';
COMMENT ON COLUMN Cuenta.nivel IS 'Nivel de la cuenta, entre 1 y 100';
COMMENT ON COLUMN Cuenta.equipo IS 'Nombre del equipo al que pertenece la cuenta';
COMMENT ON CONSTRAINT cuenta_pkey ON Cuenta IS 'Llave primaria de la tabla Cuenta';
COMMENT ON CONSTRAINT cuenta_d1 ON Cuenta IS 'Restricción para que username no sea vacío';
COMMENT ON CONSTRAINT cuenta_d2 ON Cuenta IS 'Restricción que asegura que el username sea único';
COMMENT ON CONSTRAINT cuenta_d3 ON Cuenta IS 'Restricción para que nivel esté entre 1 y 100';
COMMENT ON CONSTRAINT cuenta_fkey1 ON Cuenta IS 'Llave foránea que referencia a Participante';
COMMENT ON CONSTRAINT cuenta_d4 ON Cuenta IS 'Restricción para que equipo no sea vacío';

-- Tabla Organizador
CREATE TABLE Organizador (
    id_persona INTEGER,
    ciudad VARCHAR(100),
    colonia VARCHAR(100),
    calle VARCHAR(100),
    codigo_postal VARCHAR(10),
    num_exterior VARCHAR(10),
    num_interior VARCHAR(10),
    esRegistrador BOOLEAN,
    esCuidador BOOLEAN,
    esLimpiador BOOLEAN,
    esVendedor BOOLEAN
);

-- Restricciones Organizador
-- Dominio
ALTER TABLE Organizador ADD CONSTRAINT organizador_d1
CHECK (ciudad <> '');
ALTER TABLE Organizador ALTER COLUMN ciudad SET NOT NULL;

ALTER TABLE Organizador ADD CONSTRAINT organizador_d2
CHECK (colonia <> '');
ALTER TABLE Organizador ALTER COLUMN colonia SET NOT NULL;

ALTER TABLE Organizador ADD CONSTRAINT organizador_d3
CHECK (calle <> '');
ALTER TABLE Organizador ALTER COLUMN calle SET NOT NULL;

ALTER TABLE Organizador ADD CONSTRAINT organizador_d4
CHECK (codigo_postal <> '');
ALTER TABLE Organizador ALTER COLUMN codigo_postal SET NOT NULL;

ALTER TABLE Organizador ADD CONSTRAINT organizador_d5
CHECK (num_exterior <> '');
ALTER TABLE Organizador ALTER COLUMN num_exterior SET NOT NULL;

ALTER TABLE Organizador ALTER COLUMN num_interior SET NOT NULL; 

ALTER TABLE Organizador ALTER COLUMN esRegistrador SET NOT NULL;
ALTER TABLE Organizador ALTER COLUMN esCuidador SET NOT NULL;
ALTER TABLE Organizador ALTER COLUMN esLimpiador SET NOT NULL;
ALTER TABLE Organizador ALTER COLUMN esVendedor SET NOT NULL;

-- Entidad
ALTER TABLE Organizador ADD CONSTRAINT organizador_pkey
PRIMARY KEY (id_persona);

-- Referencial
ALTER TABLE Organizador ADD CONSTRAINT organizador_fkey1
FOREIGN KEY (id_persona) REFERENCES Personal(id_persona)
ON DELETE CASCADE
ON UPDATE CASCADE;

-- COMENTARIOS Organizador
COMMENT ON TABLE Organizador IS 'Tabla que representa a los organizadores del evento';

-- Comentarios de columnas
COMMENT ON COLUMN Organizador.id_persona IS 'Identificador único de la persona que es organizador (llave primaria y foránea)';
COMMENT ON COLUMN Organizador.ciudad IS 'Ciudad donde reside el organizador';
COMMENT ON COLUMN Organizador.colonia IS 'Colonia donde reside el organizador';
COMMENT ON COLUMN Organizador.calle IS 'Calle donde reside el organizador';
COMMENT ON COLUMN Organizador.codigo_postal IS 'Código postal del domicilio del organizador';
COMMENT ON COLUMN Organizador.num_exterior IS 'Número exterior del domicilio del organizador';
COMMENT ON COLUMN Organizador.num_interior IS 'Número interior del domicilio del organizador';
COMMENT ON COLUMN Organizador.esRegistrador IS 'Indica si el organizador también cumple funciones de registrador';
COMMENT ON COLUMN Organizador.esCuidador IS 'Indica si el organizador también cumple funciones de cuidador';
COMMENT ON COLUMN Organizador.esLimpiador IS 'Indica si el organizador también cumple funciones de limpiador';
COMMENT ON COLUMN Organizador.esVendedor IS 'Indica si el organizador también cumple funciones de vendedor';

-- Comentarios de constraints
COMMENT ON CONSTRAINT organizador_d1 ON Organizador IS 'Restricción de dominio que verifica que la ciudad no sea una cadena vacía';
COMMENT ON CONSTRAINT organizador_d2 ON Organizador IS 'Restricción de dominio que verifica que la colonia no sea una cadena vacía';
COMMENT ON CONSTRAINT organizador_d3 ON Organizador IS 'Restricción de dominio que verifica que la calle no sea una cadena vacía';
COMMENT ON CONSTRAINT organizador_d4 ON Organizador IS 'Restricción de dominio que verifica que el código postal no sea una cadena vacía';
COMMENT ON CONSTRAINT organizador_d5 ON Organizador IS 'Restricción de dominio que verifica que el número exterior no sea una cadena vacía';
COMMENT ON CONSTRAINT organizador_pkey ON Organizador IS 'Restricción de llave primaria para identificar únicamente a cada organizador';
COMMENT ON CONSTRAINT organizador_fkey1 ON Organizador IS 'Restricción referencial que verifica que el id_persona exista en la tabla Personal';

-- Tabla Registrador
CREATE TABLE Registrador (
    id_persona INTEGER,
    salario_base DECIMAL(10,2)
);

-- Restricciones Registrador
-- Dominio
ALTER TABLE Registrador ADD CONSTRAINT registrador_d1
CHECK (salario_base > 0);
ALTER TABLE Registrador ALTER COLUMN salario_base SET NOT NULL;

-- Entidad
ALTER TABLE Registrador ADD CONSTRAINT registrador_pkey
PRIMARY KEY (id_persona);

-- Referencial
ALTER TABLE Registrador ADD CONSTRAINT registrador_fkey1
FOREIGN KEY (id_persona) REFERENCES Organizador(id_persona)
ON DELETE CASCADE
ON UPDATE CASCADE;

-- COMENTARIOS Registrador
COMMENT ON TABLE Registrador IS 'Tabla que representa a los registradores del evento, quienes se encargan de registrar participantes';

-- Comentarios de columnas
COMMENT ON COLUMN Registrador.id_persona IS 'Identificador único de la persona que es registrador (llave primaria y foránea)';
COMMENT ON COLUMN Registrador.salario_base IS 'Salario base que recibe el registrador por sus servicios';

-- Comentarios de constraints
COMMENT ON CONSTRAINT registrador_d1 ON Registrador IS 'Restricción de dominio que verifica que el salario base sea mayor a 0';
COMMENT ON CONSTRAINT registrador_pkey ON Registrador IS 'Restricción de llave primaria para identificar únicamente a cada registrador';
COMMENT ON CONSTRAINT registrador_fkey1 ON Registrador IS 'Restricción referencial que verifica que el id_persona exista en la tabla Organizador';

-- Tabla Cuidador
CREATE TABLE Cuidador (
    id_persona INTEGER,
    locacion VARCHAR(100),
    horario VARCHAR(50),
    salario DECIMAL(10,2)
);

-- Restricciones Cuidador
-- Dominio
ALTER TABLE Cuidador ADD CONSTRAINT cuidador_d1
CHECK (locacion <> '');
ALTER TABLE Cuidador ALTER COLUMN locacion SET NOT NULL;

ALTER TABLE Cuidador ADD CONSTRAINT cuidador_d2
CHECK (horario <> '');
ALTER TABLE Cuidador ALTER COLUMN horario SET NOT NULL;

ALTER TABLE Cuidador ADD CONSTRAINT cuidador_d3
CHECK (salario > 0);
ALTER TABLE Cuidador ALTER COLUMN salario SET NOT NULL;

-- Entidad
ALTER TABLE Cuidador ADD CONSTRAINT cuidador_pkey
PRIMARY KEY (id_persona);

-- Referencial
ALTER TABLE Cuidador ADD CONSTRAINT cuidador_fkey1
FOREIGN KEY (id_persona) REFERENCES Organizador(id_persona)
ON DELETE CASCADE
ON UPDATE CASCADE;

-- COMENTARIOS Cuidador
COMMENT ON TABLE Cuidador IS 'Tabla que representa a los cuidadores del evento, responsables de vigilar áreas específicas';

-- Comentarios de columnas
COMMENT ON COLUMN Cuidador.id_persona IS 'Identificador único de la persona que es cuidador (llave primaria y foránea)';
COMMENT ON COLUMN Cuidador.locacion IS 'Ubicación o área específica que el cuidador debe vigilar';
COMMENT ON COLUMN Cuidador.horario IS 'Horario de trabajo asignado al cuidador';
COMMENT ON COLUMN Cuidador.salario IS 'Salario que recibe el cuidador por sus servicios';

-- Comentarios de constraints
COMMENT ON CONSTRAINT cuidador_d1 ON Cuidador IS 'Restricción de dominio que verifica que la locación no sea una cadena vacía';
COMMENT ON CONSTRAINT cuidador_d2 ON Cuidador IS 'Restricción de dominio que verifica que el horario no sea una cadena vacía';
COMMENT ON CONSTRAINT cuidador_d3 ON Cuidador IS 'Restricción de dominio que verifica que el salario sea mayor a 0';
COMMENT ON CONSTRAINT cuidador_pkey ON Cuidador IS 'Restricción de llave primaria para identificar únicamente a cada cuidador';
COMMENT ON CONSTRAINT cuidador_fkey1 ON Cuidador IS 'Restricción referencial que verifica que el id_persona exista en la tabla Organizador';


-- Tabla Limpiador
CREATE TABLE Limpiador (
    id_persona INTEGER,
    locacion VARCHAR(100),
    horario VARCHAR(50),
    salario DECIMAL(10,2)
);

-- Restricciones Limpiador
-- Dominio
ALTER TABLE Limpiador ADD CONSTRAINT limpiador_d1
CHECK (locacion <> '');
ALTER TABLE Limpiador ALTER COLUMN locacion SET NOT NULL;

ALTER TABLE Limpiador ADD CONSTRAINT limpiador_d2
CHECK (horario <> '');
ALTER TABLE Limpiador ALTER COLUMN horario SET NOT NULL;

ALTER TABLE Limpiador ADD CONSTRAINT limpiador_d3
CHECK (salario > 0);
ALTER TABLE Limpiador ALTER COLUMN salario SET NOT NULL;

-- Entidad
ALTER TABLE Limpiador ADD CONSTRAINT limpiador_pkey
PRIMARY KEY (id_persona);

-- Referencial
ALTER TABLE Limpiador ADD CONSTRAINT limpiador_fkey1
FOREIGN KEY (id_persona) REFERENCES Organizador(id_persona)
ON DELETE CASCADE
ON UPDATE CASCADE;

-- COMENTARIOS Limpiador
COMMENT ON TABLE Limpiador IS 'Tabla que representa a los limpiadores del evento, encargados de mantener limpias las instalaciones';

-- Comentarios de columnas
COMMENT ON COLUMN Limpiador.id_persona IS 'Identificador único de la persona que es limpiador (llave primaria y foránea)';
COMMENT ON COLUMN Limpiador.locacion IS 'Ubicación o área específica que el limpiador debe mantener limpia';
COMMENT ON COLUMN Limpiador.horario IS 'Horario de trabajo asignado al limpiador';
COMMENT ON COLUMN Limpiador.salario IS 'Salario que recibe el limpiador por sus servicios';

-- Comentarios de constraints
COMMENT ON CONSTRAINT limpiador_d1 ON Limpiador IS 'Restricción de dominio que verifica que la locación no sea una cadena vacía';
COMMENT ON CONSTRAINT limpiador_d2 ON Limpiador IS 'Restricción de dominio que verifica que el horario no sea una cadena vacía';
COMMENT ON CONSTRAINT limpiador_d3 ON Limpiador IS 'Restricción de dominio que verifica que el salario sea mayor a 0';
COMMENT ON CONSTRAINT limpiador_pkey ON Limpiador IS 'Restricción de llave primaria para identificar únicamente a cada limpiador';
COMMENT ON CONSTRAINT limpiador_fkey1 ON Limpiador IS 'Restricción referencial que verifica que el id_persona exista en la tabla Organizador';

-- Tabla Vendedor
CREATE TABLE Vendedor (
    id_persona INTEGER,
    ubicacion VARCHAR(100)
);

-- Restricciones Vendedor
-- Dominio
ALTER TABLE Vendedor ADD CONSTRAINT vendedor_d1
CHECK (ubicacion <> '');
ALTER TABLE Vendedor ALTER COLUMN ubicacion SET NOT NULL;

-- Entidad
ALTER TABLE Vendedor ADD CONSTRAINT vendedor_pkey
PRIMARY KEY (id_persona);

-- Referencial
ALTER TABLE Vendedor ADD CONSTRAINT vendedor_fkey1
FOREIGN KEY (id_persona) REFERENCES Organizador(id_persona)
ON DELETE CASCADE
ON UPDATE CASCADE;

-- COMENTARIOS Vendedor
COMMENT ON TABLE Vendedor IS 'Tabla que representa a los vendedores del evento, encargados de vender alimentos';

-- Comentarios de columnas
COMMENT ON COLUMN Vendedor.id_persona IS 'Identificador único de la persona que es vendedor (llave primaria y foránea)';
COMMENT ON COLUMN Vendedor.ubicacion IS 'Ubicación o puesto donde el vendedor ofrece sus productos';

-- Comentarios de constraints
COMMENT ON CONSTRAINT vendedor_d1 ON Vendedor IS 'Restricción de dominio que verifica que la ubicación no sea una cadena vacía';
COMMENT ON CONSTRAINT vendedor_pkey ON Vendedor IS 'Restricción de llave primaria para identificar únicamente a cada vendedor';
COMMENT ON CONSTRAINT vendedor_fkey1 ON Vendedor IS 'Restricción referencial que verifica que el id_persona exista en la tabla Organizador';


-- Tabla Torneo
CREATE TABLE Torneo (
    id_torneo SERIAL,
    edicion INTEGER,
    id_persona INTEGER,
    esMulti BOOLEAN,
    esPelea BOOLEAN,
    premio DECIMAL(10,2)
);

-- Restricciones Torneo
-- Dominio
ALTER TABLE Torneo ALTER COLUMN edicion SET NOT NULL;
ALTER TABLE Torneo ALTER COLUMN id_persona SET NOT NULL;
ALTER TABLE Torneo ALTER COLUMN esMulti SET NOT NULL;
ALTER TABLE Torneo ALTER COLUMN esPelea SET NOT NULL;

ALTER TABLE Torneo ADD CONSTRAINT torneo_d1
CHECK (premio >= 0);

ALTER TABLE Torneo ADD CONSTRAINT torneo_d2
CHECK (
    (esMulti = TRUE AND esPelea = FALSE) OR
    (esMulti = FALSE AND esPelea = TRUE)
);

-- Entidad
ALTER TABLE Torneo ADD CONSTRAINT torneo_pkey
PRIMARY KEY (id_torneo);

-- Referencial
ALTER TABLE Torneo ADD CONSTRAINT torneo_fkey1
FOREIGN KEY (edicion) REFERENCES Evento(edicion)
ON DELETE CASCADE
ON UPDATE CASCADE;

ALTER TABLE Torneo ADD CONSTRAINT torneo_fkey2
FOREIGN KEY (id_persona) REFERENCES Participante(id_persona)
ON DELETE CASCADE
ON UPDATE CASCADE;

-- COMENTARIOS Torneo
COMMENT ON TABLE Torneo IS 'Tabla en la que se guarda la información relacionada a los torneos';
COMMENT ON COLUMN Torneo.id_torneo IS 'Identificador del torneo';
COMMENT ON COLUMN Torneo.edicion IS 'Edición del evento al que pertenece el torneo (llave foránea)';
COMMENT ON COLUMN Torneo.id_persona IS 'Identificador del participante que organiza el torneo (llave foránea)';
COMMENT ON COLUMN Torneo.esMulti IS 'Indica si el torneo es de tipo multi';
COMMENT ON COLUMN Torneo.esPelea IS 'Indica si el torneo es de tipo pelea';
COMMENT ON COLUMN Torneo.premio IS 'Premio del torneo';
COMMENT ON CONSTRAINT torneo_d1 ON Torneo IS 'Restricción que asegura que el premio sea mayor o igual a 0';
COMMENT ON CONSTRAINT torneo_d2 ON Torneo IS 'Restricción que asegura que el torneo sea de un solo tipo (multi o pelea)';
COMMENT ON CONSTRAINT torneo_pkey ON Torneo IS 'Llave primaria de la tabla Torneo';
COMMENT ON CONSTRAINT torneo_fkey1 ON Torneo IS 'Llave foránea que referencia a la tabla Evento';
COMMENT ON CONSTRAINT torneo_fkey2 ON Torneo IS 'Llave foránea que referencia a la tabla Participante';

-- Tabla Multi
CREATE TABLE Multi (
    id_torneo INTEGER,
    esCaptura BOOLEAN,
    esDistanciaRecorrida BOOLEAN
);

-- Restricciones Multi
-- Dominio
ALTER TABLE Multi ALTER COLUMN esCaptura SET NOT NULL;
ALTER TABLE Multi ALTER COLUMN esDistanciaRecorrida SET NOT NULL;

-- Entidad
ALTER TABLE Multi ADD CONSTRAINT multi_pkey
PRIMARY KEY (id_torneo);

-- Referencial
ALTER TABLE Multi ADD CONSTRAINT multi_fkey1
FOREIGN KEY (id_torneo) REFERENCES Torneo(id_torneo)
ON DELETE CASCADE
ON UPDATE CASCADE;

ALTER TABLE Participante ADD CONSTRAINT participante_fkey2
FOREIGN KEY (id_torneo) REFERENCES Multi(id_torneo)
ON DELETE CASCADE
ON UPDATE CASCADE;

-- COMENTARIOS Multi
COMMENT ON TABLE Multi IS 'Tabla que representa los torneos de tipo multijugador, que pueden incluir diferentes modalidades de competencia';

-- Comentarios de columnas
COMMENT ON COLUMN Multi.id_torneo IS 'Identificador único del torneo multijugador (llave primaria y foránea)';
COMMENT ON COLUMN Multi.esCaptura IS 'Indica si el torneo multi incluye la modalidad de captura de Pokémon';
COMMENT ON COLUMN Multi.esDistanciaRecorrida IS 'Indica si el torneo multi incluye la modalidad de distancia recorrida';

-- Comentarios de constraints
COMMENT ON CONSTRAINT multi_pkey ON Multi IS 'Restricción de llave primaria para identificar únicamente cada torneo multijugador';
COMMENT ON CONSTRAINT multi_fkey1 ON Multi IS 'Restricción referencial que verifica que el id_torneo exista en la tabla Torneo';

-- Tabla Pelea
CREATE TABLE Pelea (
    id_torneo INTEGER
);

-- Entidad
ALTER TABLE Pelea ADD CONSTRAINT pelea_pkey
PRIMARY KEY (id_torneo);

-- Referencial
ALTER TABLE Pelea ADD CONSTRAINT pelea_fkey1
FOREIGN KEY (id_torneo) REFERENCES Torneo(id_torneo)
ON DELETE CASCADE
ON UPDATE CASCADE;

-- COMENTARIOS Pelea
COMMENT ON TABLE Pelea IS 'Tabla que representa los torneos de tipo pelea entre Pokémon';

-- Comentarios de columnas
COMMENT ON COLUMN Pelea.id_torneo IS 'Identificador único del torneo de pelea (llave primaria y foránea)';

-- Comentarios de constraints
COMMENT ON CONSTRAINT pelea_pkey ON Pelea IS 'Restricción de llave primaria para identificar únicamente cada torneo de pelea';
COMMENT ON CONSTRAINT pelea_fkey1 ON Pelea IS 'Restricción referencial que verifica que el id_torneo exista en la tabla Torneo';

CREATE TABLE Distancia (
    id_persona INTEGER,
    distancia DECIMAL(10,2)
);

-- Entidad
ALTER TABLE Distancia ADD CONSTRAINT distancia_pkey
PRIMARY KEY (id_persona, distancia);

-- Referencial
ALTER TABLE Distancia ADD CONSTRAINT distancia_fkey1
FOREIGN KEY (id_persona) REFERENCES Participante(id_persona)
ON DELETE CASCADE
ON UPDATE CASCADE;

-- COMENTARIOS Distancia
COMMENT ON TABLE Distancia IS 'Tabla que representa la modalidad de distancia recorrida en torneos de un punto a otro';
COMMENT ON COLUMN Distancia.id_persona IS 'Identificador único del participante asociado (llave foránea)';
COMMENT ON COLUMN Distancia.distancia IS 'Distancia en kilómetros que los participantes recorren de un punto a otro';
COMMENT ON CONSTRAINT distancia_pkey ON Distancia IS 'Restricción de llave primaria compuesta por id_torneo y distancia';
COMMENT ON CONSTRAINT distancia_fkey1 ON Distancia IS 'Llave foránea que referencia a Participante';


-- Tabla Alimento
CREATE TABLE Alimento (
    id_alimento SERIAL,
    id_persona INTEGER,
    tipo VARCHAR(50),
    nombre VARCHAR(100),
    precio DECIMAL(6,2),
    esPerecedero BOOLEAN,
    fecha_caducidad DATE
);

-- Restricciones Alimento
-- Dominio
ALTER TABLE Alimento ALTER COLUMN id_persona SET NOT NULL;

ALTER TABLE Alimento ADD CONSTRAINT alimento_d1
CHECK (tipo <> '');
ALTER TABLE Alimento ALTER COLUMN tipo SET NOT NULL;

ALTER TABLE Alimento ADD CONSTRAINT alimento_d2
CHECK (nombre <> '');
ALTER TABLE Alimento ALTER COLUMN nombre SET NOT NULL;

ALTER TABLE Alimento ADD CONSTRAINT alimento_d3
CHECK (precio > 0);
ALTER TABLE Alimento ALTER COLUMN precio SET NOT NULL;

ALTER TABLE Alimento ALTER COLUMN esPerecedero SET NOT NULL;

ALTER TABLE Alimento ALTER COLUMN fecha_caducidad SET NOT NULL;

-- Entidad
ALTER TABLE Alimento ADD CONSTRAINT alimento_pkey
PRIMARY KEY (id_alimento);

-- Referencial
ALTER TABLE Alimento ADD CONSTRAINT alimento_fkey1
FOREIGN KEY (id_persona) REFERENCES Vendedor(id_persona)
ON DELETE CASCADE
ON UPDATE CASCADE;

-- COMENTARIOS Alimento
COMMENT ON TABLE Alimento IS 'Tabla que representa los alimentos disponibles para venta en el evento';

-- Comentarios de columnas
COMMENT ON COLUMN Alimento.id_alimento IS 'Identificador único del alimento (llave primaria)';
COMMENT ON COLUMN Alimento.id_persona IS 'Identificador del vendedor que ofrece el alimento (llave foránea)';
COMMENT ON COLUMN Alimento.tipo IS 'Tipo o categoría del alimento (bebida, comida, snack, etc.)';
COMMENT ON COLUMN Alimento.nombre IS 'Nombre descriptivo del alimento';
COMMENT ON COLUMN Alimento.precio IS 'Precio de venta del alimento en pesos';
COMMENT ON COLUMN Alimento.esPerecedero IS 'Indica si el alimento es perecedero o no';
COMMENT ON COLUMN Alimento.fecha_caducidad IS 'Fecha de caducidad del alimento';

-- Comentarios de constraints
COMMENT ON CONSTRAINT alimento_d1 ON Alimento IS 'Restricción de dominio que verifica que el tipo no sea una cadena vacía';
COMMENT ON CONSTRAINT alimento_d2 ON Alimento IS 'Restricción de dominio que verifica que el nombre no sea una cadena vacía';
COMMENT ON CONSTRAINT alimento_d3 ON Alimento IS 'Restricción de dominio que verifica que el precio sea mayor a 0';
COMMENT ON CONSTRAINT alimento_pkey ON Alimento IS 'Restricción de llave primaria para identificar únicamente cada alimento';
COMMENT ON CONSTRAINT alimento_fkey1 ON Alimento IS 'Restricción referencial que verifica que el id_persona del vendedor exista en la tabla Vendedor';


-- Tabla Pokemon
CREATE TABLE Pokemon (
    id_pokemon SERIAL,
    codigo INTEGER,
    id_torneo INTEGER,
    apodo VARCHAR(50),
    especie VARCHAR(100),
    tipo VARCHAR(50),
    sexo CHAR(1),
    peso DECIMAL(6,2),
    puntos_combate INTEGER,
    fecha_captura DATE,
    esShiny BOOLEAN,
    hora_captura TIME
);

-- Restricciones Pokemon
-- Dominio
ALTER TABLE Pokemon ALTER COLUMN codigo SET NOT NULL;
ALTER TABLE Pokemon ALTER COLUMN id_torneo SET NOT NULL;
ALTER TABLE Pokemon ALTER COLUMN id_pokemon SET NOT NULL;

ALTER TABLE Pokemon ADD CONSTRAINT pokemon_d1
CHECK (especie <> '');
ALTER TABLE Pokemon ALTER COLUMN especie SET NOT NULL;

ALTER TABLE Pokemon ADD CONSTRAINT pokemon_d2
CHECK (tipo <> '');
ALTER TABLE Pokemon ALTER COLUMN tipo SET NOT NULL;

ALTER TABLE Pokemon ADD CONSTRAINT pokemon_d3
CHECK (sexo IN ('M', 'F', 'N'));

ALTER TABLE Pokemon ADD CONSTRAINT pokemon_d4
CHECK (peso > 0);

ALTER TABLE Pokemon ADD CONSTRAINT pokemon_d5
CHECK (puntos_combate >= 0);

ALTER TABLE Pokemon ADD CONSTRAINT pokemon_d6
CHECK(apodo <> '');
ALTER TABLE Pokemon ALTER COLUMN apodo SET NOT NULL;

ALTER TABLE Pokemon ALTER COLUMN fecha_captura SET NOT NULL;
ALTER TABLE Pokemon ALTER COLUMN esShiny SET NOT NULL;
ALTER TABLE Pokemon ALTER COLUMN hora_captura SET NOT NULL;

-- Entidad
ALTER TABLE Pokemon ADD CONSTRAINT pokemon_pkey
PRIMARY KEY (id_pokemon, codigo);

-- Referencial
ALTER TABLE Pokemon ADD CONSTRAINT pokemon_fkey1
FOREIGN KEY (codigo) REFERENCES Cuenta(codigo)
ON DELETE CASCADE
ON UPDATE CASCADE;

ALTER TABLE Pokemon ADD CONSTRAINT pokemon_fkey2
FOREIGN KEY (id_torneo) REFERENCES Torneo(id_torneo)
ON DELETE CASCADE
ON UPDATE CASCADE;

-- COMENTARIOS Pokemon
COMMENT ON TABLE Pokemon IS 'Tabla en la que se guarda la información relacionada a los pokemones';
COMMENT ON COLUMN Pokemon.id_pokemon IS 'Identificador del pokemon';
COMMENT ON COLUMN Pokemon.codigo IS 'Código de la cuenta a la que pertenece el pokemon (llave foránea)';
COMMENT ON COLUMN Pokemon.id_torneo IS 'Identificador del torneo en el que está inscrito el pokemon (llave foránea)';
COMMENT ON COLUMN Pokemon.apodo IS 'Apodo del pokemon';
COMMENT ON COLUMN Pokemon.especie IS 'Especie del pokemon';
COMMENT ON COLUMN Pokemon.tipo IS 'Tipo del pokemon';
COMMENT ON COLUMN Pokemon.sexo IS 'Sexo del pokemon';
COMMENT ON COLUMN Pokemon.peso IS 'Peso del pokemon';
COMMENT ON COLUMN Pokemon.puntos_combate IS 'Puntos de combate del pokemon';
COMMENT ON COLUMN Pokemon.fecha_captura IS 'Fecha de captura del pokemon';
COMMENT ON COLUMN Pokemon.esShiny IS 'Indica si el pokemon es shiny';
COMMENT ON COLUMN Pokemon.hora_captura IS 'Hora de captura del pokemon';
COMMENT ON CONSTRAINT pokemon_d1 ON Pokemon IS 'Restricción que asegura que la especie no esté vacía';
COMMENT ON CONSTRAINT pokemon_d2 ON Pokemon IS 'Restricción que asegura que el tipo no esté vacío';
COMMENT ON CONSTRAINT pokemon_d3 ON Pokemon IS 'Restricción que asegura que el sexo sea M, F o N';
COMMENT ON CONSTRAINT pokemon_d4 ON Pokemon IS 'Restricción que asegura que el peso sea mayor a 0';
COMMENT ON CONSTRAINT pokemon_d5 ON Pokemon IS 'Restricción que asegura que los puntos de combate sean mayores o iguales a 0';
COMMENT ON CONSTRAINT pokemon_d6 ON Pokemon IS 'Restricción que asegura que el apodo no esté vacío';
COMMENT ON CONSTRAINT pokemon_pkey ON Pokemon IS 'Llave primaria de la tabla Pokemon';
COMMENT ON CONSTRAINT pokemon_fkey1 ON Pokemon IS 'Llave foránea que referencia a la tabla Cuenta';
COMMENT ON CONSTRAINT pokemon_fkey2 ON Pokemon IS 'Llave foránea que referencia a la tabla Torneo';

-- ============================================
-- TABLAS CON LLAVES COMPUESTAS
-- ============================================

-- Tabla Combate
CREATE TABLE Combate (
    id_combate SERIAL,
    id_torneo INTEGER,
    fase VARCHAR(50)
);

-- Restricciones Combate
-- Dominio
ALTER TABLE Combate ALTER COLUMN id_torneo SET NOT NULL;
ALTER TABLE Combate ALTER COLUMN id_combate SET NOT NULL;

ALTER TABLE Combate ADD CONSTRAINT combate_d1
CHECK (fase <> '');
ALTER TABLE Combate ALTER COLUMN fase SET NOT NULL;

-- Entidad
ALTER TABLE Combate ADD CONSTRAINT combate_pkey
PRIMARY KEY (id_combate, id_torneo);

-- Referencial
ALTER TABLE Combate ADD CONSTRAINT combate_fkey1
FOREIGN KEY (id_torneo) REFERENCES Pelea(id_torneo)
ON DELETE CASCADE
ON UPDATE CASCADE;

-- COMENTARIOS Combate
COMMENT ON TABLE Combate IS 'Tabla en la que se guarda la información relacionada a los combates';
COMMENT ON COLUMN Combate.id_combate IS 'Identificador del combate';
COMMENT ON COLUMN Combate.id_torneo IS 'Identificador del torneo en el que se lleva a cabo el combate (llave foránea)';
COMMENT ON COLUMN Combate.fase IS 'Fase del combate';
COMMENT ON CONSTRAINT combate_d1 ON Combate IS 'Restricción que asegura que la fase no esté vacía';
COMMENT ON CONSTRAINT combate_pkey ON Combate IS 'Llave primaria de la tabla Combate';
COMMENT ON CONSTRAINT combate_fkey1 ON Combate IS 'Llave foránea que referencia a la tabla Pelea';

-- Tabla Telefonos
CREATE TABLE Telefonos (
    id_persona INTEGER,
    telefono VARCHAR(20)
);

-- Restricciones Telefonos
-- Dominio
ALTER TABLE Telefonos ADD CONSTRAINT telefonos_d1
CHECK (telefono <> '');
ALTER TABLE Telefonos ALTER COLUMN telefono SET NOT NULL;

-- Entidad
ALTER TABLE Telefonos ADD CONSTRAINT telefonos_pkey
PRIMARY KEY (id_persona, telefono);

-- Referencial
ALTER TABLE Telefonos ADD CONSTRAINT telefonos_fkey1
FOREIGN KEY (id_persona) REFERENCES Personal(id_persona)
ON DELETE CASCADE
ON UPDATE CASCADE;

-- COMENTARIOS Telefonos
COMMENT ON TABLE Telefonos IS 'Tabla que almacena los números telefónicos del personal del evento';

-- Comentarios de columnas
COMMENT ON COLUMN Telefonos.id_persona IS 'Identificador de la persona a quien pertenece el teléfono (llave foránea y parte de llave primaria)';
COMMENT ON COLUMN Telefonos.telefono IS 'Número telefónico de contacto (parte de llave primaria)';

-- Comentarios de constraints
COMMENT ON CONSTRAINT telefonos_d1 ON Telefonos IS 'Restricción de dominio que verifica que el teléfono sea válido usando una expresión regular';
COMMENT ON CONSTRAINT telefonos_pkey ON Telefonos IS 'Restricción de llave primaria compuesta por id_persona y telefono';
COMMENT ON CONSTRAINT telefonos_fkey1 ON Telefonos IS 'Restricción referencial que verifica que el id_persona exista en la tabla Personal';


-- Tabla Emails
CREATE TABLE Emails (
    id_persona INTEGER,
    email VARCHAR(255)
);

-- Restricciones Emails
-- Dominio
ALTER TABLE Emails ADD CONSTRAINT emails_d1
CHECK (email LIKE '%@%._%');
ALTER TABLE Emails ALTER COLUMN email SET NOT NULL;

-- Entidad
ALTER TABLE Emails ADD CONSTRAINT emails_pkey
PRIMARY KEY (id_persona, email);

ALTER TABLE Emails ADD CONSTRAINT emails_uk1
UNIQUE (email);

-- Referencial
ALTER TABLE Emails ADD CONSTRAINT emails_fkey1
FOREIGN KEY (id_persona) REFERENCES Personal(id_persona)
ON DELETE CASCADE
ON UPDATE CASCADE;

-- COMENTARIOS Emails
COMMENT ON TABLE Emails IS 'Tabla en la que se guardan los emails de las personas';
COMMENT ON COLUMN Emails.id_persona IS 'Identificador de la persona (llave foránea)';
COMMENT ON COLUMN Emails.email IS 'Email de la persona';
COMMENT ON CONSTRAINT emails_d1 ON Emails IS 'Restricción que asegura que el email tenga un formato válido';
COMMENT ON CONSTRAINT emails_pkey ON Emails IS 'Llave primaria de la tabla Emails';
COMMENT ON CONSTRAINT emails_uk1 ON Emails IS 'Restricción que asegura que el email sea único';
COMMENT ON CONSTRAINT emails_fkey1 ON Emails IS 'Llave foránea que referencia a la tabla Personal';

-- ============================================
-- TABLAS DE RELACIONES M:N
-- ============================================

-- Tabla Trabajar
CREATE TABLE Trabajar (
    id_organizador INTEGER,
    edicion INTEGER
);

-- Referencial
ALTER TABLE Trabajar ADD CONSTRAINT trabajar_fkey1
FOREIGN KEY (id_organizador) REFERENCES Organizador(id_persona)
ON DELETE CASCADE
ON UPDATE CASCADE;

ALTER TABLE Trabajar ADD CONSTRAINT trabajar_fkey2
FOREIGN KEY (edicion) REFERENCES Evento(edicion)
ON DELETE CASCADE
ON UPDATE CASCADE;

-- COMENTARIOS Trabajar
COMMENT ON TABLE Trabajar IS 'Tabla que relaciona a los organizadores con los eventos en los que trabajan';
COMMENT ON COLUMN Trabajar.id_organizador IS 'Identificador del organizador (llave foránea)';
COMMENT ON COLUMN Trabajar.edicion IS 'Edición del evento (llave foránea)'; 
COMMENT ON CONSTRAINT trabajar_fkey1 ON Trabajar IS 'Llave foránea que referencia a la tabla Organizador';
COMMENT ON CONSTRAINT trabajar_fkey2 ON Trabajar IS 'Llave foránea que referencia a la tabla Evento';

-- Tabla Participar
CREATE TABLE Participar (
    id_persona INTEGER,
    id_torneo INTEGER
);

-- Restricciones Participar
-- Dominio

-- Referencial
ALTER TABLE Participar ADD CONSTRAINT participar_fkey1
FOREIGN KEY (id_persona) REFERENCES Participante(id_persona)
ON DELETE CASCADE
ON UPDATE CASCADE;

ALTER TABLE Participar ADD CONSTRAINT participar_fkey2
FOREIGN KEY (id_torneo) REFERENCES Torneo(id_torneo)
ON DELETE CASCADE
ON UPDATE CASCADE;

-- COMENTARIOS Participar
COMMENT ON TABLE Participar IS 'Tabla que relaciona a los participantes con los torneos en los que participan';
COMMENT ON COLUMN Participar.id_persona IS 'Identificador del participante (llave foránea)';
COMMENT ON COLUMN Participar.id_torneo IS 'Identificador del torneo (llave foránea)';
COMMENT ON CONSTRAINT participar_fkey1 ON Participar IS 'Llave foránea que referencia a la tabla Participante';
COMMENT ON CONSTRAINT participar_fkey2 ON Participar IS 'Llave foránea que referencia a la tabla Torneo';

-- Tabla Comprar
CREATE TABLE Comprar (
    id_persona INTEGER,
    id_alimento INTEGER,
    metodo_pago VARCHAR(50),
    cantidad INTEGER
);

-- Restricciones Comprar
-- Dominio
ALTER TABLE Comprar ADD CONSTRAINT comprar_d1
CHECK (metodo_pago <> '');
ALTER TABLE Comprar ALTER COLUMN metodo_pago SET NOT NULL;

ALTER TABLE Comprar ADD CONSTRAINT comprar_d2
CHECK (cantidad > 0);
ALTER TABLE Comprar ALTER COLUMN cantidad SET NOT NULL;

-- Referencial
ALTER TABLE Comprar ADD CONSTRAINT comprar_fkey1
FOREIGN KEY (id_persona) REFERENCES Persona(id_persona)
ON DELETE CASCADE
ON UPDATE CASCADE;

ALTER TABLE Comprar ADD CONSTRAINT comprar_fkey2
FOREIGN KEY (id_alimento) REFERENCES Alimento(id_alimento)
ON DELETE CASCADE
ON UPDATE CASCADE;

-- COMENTARIOS Comprar
COMMENT ON TABLE Comprar IS 'Tabla que registra las compras realizadas por personas sobre alimentos disponibles en el evento';
COMMENT ON COLUMN Comprar.id_persona IS 'Identificador de la persona que realiza la compra (FK a Persona.id_persona)';
COMMENT ON COLUMN Comprar.id_alimento IS 'Identificador del alimento comprado (FK a Alimento.id_alimento)';
COMMENT ON COLUMN Comprar.metodo_pago IS 'Método de pago utilizado en la compra (efectivo, tarjeta, etc.)';
COMMENT ON COLUMN Comprar.cantidad IS 'Cantidad de unidades compradas (entera y > 0)';
COMMENT ON CONSTRAINT comprar_d1 ON Comprar IS 'Restricción de dominio que verifica que metodo_pago no sea una cadena vacía';
COMMENT ON CONSTRAINT comprar_d2 ON Comprar IS 'Restricción de dominio que verifica que la cantidad sea mayor a 0';
COMMENT ON CONSTRAINT comprar_fkey1 ON Comprar IS 'Restricción referencial que verifica que id_persona exista en la tabla Persona';
COMMENT ON CONSTRAINT comprar_fkey2 ON Comprar IS 'Restricción referencial que verifica que id_alimento exista en la tabla Alimento';

-- Tabla Registrar
CREATE TABLE Registrar (
    id_persona_p INTEGER,
    id_persona_r INTEGER
);

-- Referencial
ALTER TABLE Registrar ADD CONSTRAINT registrar_fkey1
FOREIGN KEY (id_persona_r) REFERENCES Registrador(id_persona)
ON DELETE CASCADE
ON UPDATE CASCADE;

ALTER TABLE Registrar ADD CONSTRAINT registrar_fkey2
FOREIGN KEY (id_persona_p) REFERENCES Participante(id_persona)
ON DELETE CASCADE
ON UPDATE CASCADE;

-- COMENTARIOS Registrar
COMMENT ON TABLE Registrar IS 'Tabla que relaciona registradores con los participantes que registraron';
COMMENT ON COLUMN Registrar.id_persona_r IS 'Identificador del registrador (FK a Registrador.id_persona)';
COMMENT ON COLUMN Registrar.id_persona_p IS 'Identificador del participante registrado (FK a Participante.id_persona)';
COMMENT ON CONSTRAINT registrar_fkey1 ON Registrar IS 'Restricción referencial que verifica que id_persona_r exista en la tabla Registrador';
COMMENT ON CONSTRAINT registrar_fkey2 ON Registrar IS 'Restricción referencial que verifica que id_persona_p exista en la tabla Participante';

-- Tabla Asistir
CREATE TABLE Asistir (
    edicion INTEGER,
    id_persona INTEGER,
    hora_ingreso TIME,
    hora_salida TIME
);

-- Restricciones Asistir
-- Dominio
ALTER TABLE Asistir ALTER COLUMN hora_ingreso SET NOT NULL;

ALTER TABLE Asistir ADD CONSTRAINT asistir_d1
CHECK (hora_salida > hora_ingreso OR hora_salida IS NULL);

-- Referencial
ALTER TABLE Asistir ADD CONSTRAINT asistir_fkey1
FOREIGN KEY (edicion) REFERENCES Evento(edicion)
ON DELETE CASCADE
ON UPDATE CASCADE;

ALTER TABLE Asistir ADD CONSTRAINT asistir_fkey2
FOREIGN KEY (id_persona) REFERENCES Espectador(id_persona)
ON DELETE CASCADE
ON UPDATE CASCADE;

-- COMENTARIOS Asistir
COMMENT ON TABLE Asistir IS 'Tabla que registra la asistencia de espectadores por edición, con horas de ingreso y salida';
COMMENT ON COLUMN Asistir.edicion IS 'Edición del evento a la que corresponde la asistencia (FK a Evento.edicion)';
COMMENT ON COLUMN Asistir.id_persona IS 'Identificador de la persona que asiste (FK a Espectador.id_persona)';
COMMENT ON COLUMN Asistir.hora_ingreso IS 'Hora de ingreso a la edición (no nula)';
COMMENT ON COLUMN Asistir.hora_salida IS 'Hora de salida de la edición (puede ser NULL si no se registró salida)';
COMMENT ON CONSTRAINT asistir_d1 ON Asistir IS 'Restricción que asegura que hora_salida sea mayor que hora_ingreso o que hora_salida sea NULL';
COMMENT ON CONSTRAINT asistir_fkey1 ON Asistir IS 'Restricción referencial que verifica que edicion exista en la tabla Evento';
COMMENT ON CONSTRAINT asistir_fkey2 ON Asistir IS 'Restricción referencial que verifica que id_persona exista en la tabla Espectador';

-- Tabla Combatir
CREATE TABLE Combatir (
    id_pokemon INTEGER,
    id_combate INTEGER,
    id_torneo INTEGER,
    codigo INTEGER
);

ALTER TABLE Combatir ALTER COLUMN id_torneo SET NOT NULL;
ALTER TABLE Combatir ALTER COLUMN codigo SET NOT NULL;
ALTER TABLE Combatir ALTER COLUMN id_pokemon SET NOT NULL;
ALTER TABLE Combatir ALTER COLUMN id_combate SET NOT NULL;
ALTER TABLE Combatir ADD CONSTRAINT combatir_uk1 UNIQUE (id_combate, id_pokemon, codigo);

-- Referencial
ALTER TABLE Combatir ADD CONSTRAINT combatir_fkey1
FOREIGN KEY (id_pokemon, codigo) REFERENCES Pokemon(id_pokemon, codigo)
ON DELETE CASCADE
ON UPDATE CASCADE;

ALTER TABLE Combatir ADD CONSTRAINT combatir_fkey2
FOREIGN KEY (id_combate, id_torneo) REFERENCES Combate(id_combate, id_torneo)
ON DELETE CASCADE
ON UPDATE CASCADE;

-- COMENTARIOS Combatir
COMMENT ON TABLE Combatir IS 'Tabla que relaciona pokémon con los combates en los que participan';
COMMENT ON COLUMN Combatir.id_pokemon IS 'Identificador del pokémon que participa en el combate (FK a Pokemon.id_pokemon)';
COMMENT ON COLUMN Combatir.id_combate IS 'Identificador del combate en el que participa el pokémon (FK a Combate.id_combate)';
COMMENT ON COLUMN Combatir.id_torneo IS 'Identificador del torneo al que pertenece el combate (FK a Torneo.id_torneo)';
COMMENT ON COLUMN Combatir.codigo IS 'Código de la cuenta a la que pertenece el pokémon (FK a Cuenta.codigo)';
COMMENT ON CONSTRAINT combatir_fkey1 ON Combatir IS 'Restricción referencial que verifica que id_pokemon exista en la tabla Pokemon y codigo en Cuenta';
COMMENT ON CONSTRAINT combatir_fkey2 ON Combatir IS 'Restricción referencial que verifica que id_combate exista en la tabla Combate y id_torneo en Torneo';
COMMENT ON CONSTRAINT combatir_uk1 ON Combatir IS 'Restricción de integridad que asegura que el id_combate, id_pokemon y el código sean únicos';

-- Tabla Ser
CREATE TABLE Ser (
    id_persona_r INTEGER,
    id_persona_p INTEGER
);

-- Referencial
ALTER TABLE Ser ADD CONSTRAINT ser_fkey1
FOREIGN KEY (id_persona_r) REFERENCES Registrador(id_persona)
ON DELETE CASCADE
ON UPDATE CASCADE;

ALTER TABLE Ser ADD CONSTRAINT ser_fkey2
FOREIGN KEY (id_persona_p) REFERENCES Participante(id_persona)
ON DELETE CASCADE
ON UPDATE CASCADE;

-- COMENTARIOS Ser
COMMENT ON TABLE Ser IS 'Tabla que relaciona registradores con participantes a los que sirven o registraron';
COMMENT ON COLUMN Ser.id_persona_r IS 'Identificador del registrador (FK a Registrador.id_persona)';
COMMENT ON COLUMN Ser.id_persona_p IS 'Identificador del participante relacionado (FK a Participante.id_persona)';
COMMENT ON CONSTRAINT ser_fkey1 ON Ser IS 'Restricción referencial que verifica que id_persona_r exista en la tabla Registrador';
COMMENT ON CONSTRAINT ser_fkey2 ON Ser IS 'Restricción referencial que verifica que id_persona_p exista en la tabla Participante';

-- Tabla Enfrentar
CREATE TABLE Enfrentar (
    id_combate INTEGER,
    id_persona INTEGER,
    id_torneo INTEGER,
    esGanador BOOLEAN
);

-- Restricciones Enfrentar
-- Dominio
ALTER TABLE Enfrentar ALTER COLUMN esGanador SET NOT NULL;
ALTER TABLE Enfrentar ALTER COLUMN id_torneo SET NOT NULL;
ALTER TABLE Enfrentar ALTER COLUMN id_combate SET NOT NULL;
ALTER TABLE Enfrentar ALTER COLUMN id_persona SET NOT NULL;

-- Referencial
ALTER TABLE Enfrentar ADD CONSTRAINT enfrentar_fkey1
FOREIGN KEY (id_combate, id_torneo) REFERENCES Combate(id_combate, id_torneo)
ON DELETE CASCADE
ON UPDATE CASCADE;

ALTER TABLE Enfrentar ADD CONSTRAINT enfrentar_fkey2
FOREIGN KEY (id_persona) REFERENCES Participante(id_persona)
ON DELETE CASCADE
ON UPDATE CASCADE;

-- COMENTARIOS Enfrentar
COMMENT ON TABLE Enfrentar IS 'Tabla que indica qué participantes se enfrentan en cada combate y quién resultó ganador';
COMMENT ON COLUMN Enfrentar.id_combate IS 'Identificador del combate (FK a Combate.id_combate)';
COMMENT ON COLUMN Enfrentar.id_persona IS 'Identificador del participante que enfrenta (FK a Participante.id_persona)';
COMMENT ON COLUMN Enfrentar.esGanador IS 'Indicador booleano que señala si el participante fue el ganador (NOT NULL)';
COMMENT ON COLUMN Enfrentar.id_torneo IS 'Identificador del torneo al que pertenece el combate (FK a Torneo.id_torneo)';
COMMENT ON CONSTRAINT enfrentar_fkey1 ON Enfrentar IS 'Restricción referencial que verifica que id_combate exista en la tabla Combate y id_torneo en Combate';
COMMENT ON CONSTRAINT enfrentar_fkey2 ON Enfrentar IS 'Restricción referencial que verifica que id_persona exista en la tabla Participante';

-- Reiniciar las secuencias SERIAL después de crear las tablas
ALTER SEQUENCE evento_edicion_seq RESTART WITH 1;
ALTER SEQUENCE persona_id_persona_seq RESTART WITH 1;
ALTER SEQUENCE cuenta_codigo_seq RESTART WITH 1;
ALTER SEQUENCE torneo_id_torneo_seq RESTART WITH 1;
ALTER SEQUENCE combate_id_combate_seq RESTART WITH 1;
ALTER SEQUENCE alimento_id_alimento_seq RESTART WITH 1;
ALTER SEQUENCE pokemon_id_pokemon_seq RESTART WITH 1;


SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
ORDER BY table_name;


