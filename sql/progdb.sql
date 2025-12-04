-- ============================================
-- DISPARADORES PARA VALIDAR ROLES E INMUTABILIDAD
-- ============================================

-- Disparador: validar roles en Persona y prohibir su modificación después de creada
CREATE OR REPLACE FUNCTION persona_rol()
RETURNS trigger AS $$
BEGIN
    -- Asegurar exactamente un rol verdadero
    IF ( (COALESCE(NEW.esPersonal, FALSE)::int + COALESCE(NEW.esEspectador, FALSE)::int) <> 1 ) THEN
        RAISE EXCEPTION 'Una persona solo puede tener un rol';
    END IF;

    IF (TG_OP = 'UPDATE') THEN
        IF (NEW.esPersonal IS DISTINCT FROM OLD.esPersonal OR NEW.esEspectador IS DISTINCT FROM OLD.esEspectador) THEN
            RAISE EXCEPTION 'Los roles de Persona no pueden ser modificados';
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER persona_roles
BEFORE INSERT OR UPDATE ON Persona
FOR EACH ROW EXECUTE FUNCTION persona_rol();


-- Disparador: validar roles en Personal y asegurar consistencia con Persona
CREATE OR REPLACE FUNCTION personal_rol()
RETURNS trigger AS $$
DECLARE
    padre_personal RECORD;
BEGIN
    -- Asegurar exactamente un rol verdadero en Personal
    IF ( (COALESCE(NEW.esParticipante, FALSE)::int + COALESCE(NEW.esOrganizador, FALSE)::int) <> 1 ) THEN
        RAISE EXCEPTION 'Personal solo puede tener un rol';
    END IF;

    SELECT * INTO padre_personal FROM Persona WHERE id_persona = NEW.id_persona;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'No existe Persona con id % referenciada por Personal', NEW.id_persona;
    END IF;
    IF COALESCE(padre_personal.esPersonal, FALSE) = FALSE THEN
        RAISE EXCEPTION 'La Persona % no tiene este rol', NEW.id_persona;
    END IF;

    IF (TG_OP = 'UPDATE') THEN
        IF (NEW.esParticipante IS DISTINCT FROM OLD.esParticipante OR NEW.esOrganizador IS DISTINCT FROM OLD.esOrganizador) THEN
            RAISE EXCEPTION 'Los roles de Personal no pueden ser modificados';
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER personal_roles
BEFORE INSERT OR UPDATE ON Personal
FOR EACH ROW EXECUTE FUNCTION personal_rol();


-- Disparador: validar roles en Organizador y asegurar consistencia con Personal
CREATE OR REPLACE FUNCTION organizador_rol()
RETURNS trigger AS $$
DECLARE
    padre_personal RECORD;
    roles_true_count int := 0;
BEGIN
    roles_true_count := COALESCE(NEW.esRegistrador, FALSE)::int
                      + COALESCE(NEW.esCuidador, FALSE)::int
                      + COALESCE(NEW.esLimpiador, FALSE)::int
                      + COALESCE(NEW.esVendedor, FALSE)::int;
    IF roles_true_count <> 1 THEN
        RAISE EXCEPTION 'Organizador solo puede tener un rol';
    END IF;

    SELECT * INTO padre_personal FROM Personal WHERE id_persona = NEW.id_persona;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'No existe Personal con id % referenciado por Organizador', NEW.id_persona;
    END IF;
    IF COALESCE(padre_personal.esOrganizador, FALSE) = FALSE THEN
        RAISE EXCEPTION 'La persona % no tiene este rol', NEW.id_persona;
    END IF;

    IF (TG_OP = 'UPDATE') THEN
        IF (NEW.esRegistrador IS DISTINCT FROM OLD.esRegistrador
            OR NEW.esCuidador IS DISTINCT FROM OLD.esCuidador
            OR NEW.esLimpiador IS DISTINCT FROM OLD.esLimpiador
            OR NEW.esVendedor IS DISTINCT FROM OLD.esVendedor) THEN
            RAISE EXCEPTION 'Los roles de Organizador no pueden ser modificados';
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


-- Disparador adicional en Espectador para asegurar coherencia con Persona
CREATE OR REPLACE FUNCTION espectador_integridad()
RETURNS trigger AS $$
DECLARE
    p RECORD;
BEGIN
    SELECT esEspectador INTO p FROM Persona WHERE id_persona = NEW.id_persona;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'No existe Persona con id % referenciada por Espectador', NEW.id_persona;
    END IF;
    IF COALESCE(p.esEspectador, FALSE) = FALSE THEN
        RAISE EXCEPTION 'La Persona % no es un Espectador', NEW.id_persona;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER espectador_integridad
BEFORE INSERT ON Espectador
FOR EACH ROW EXECUTE FUNCTION espectador_integridad();


-- Disparador: validar roles en Torneo y prohibir su modificación después de creada
CREATE OR REPLACE FUNCTION torneo_rol()
RETURNS trigger AS $$
BEGIN
    -- Asegurar exactamente un rol verdadero
    IF ( (COALESCE(NEW.esMulti, FALSE)::int + COALESCE(NEW.esPelea, FALSE)::int) <> 1 ) THEN
        RAISE EXCEPTION 'Torneo debe ser exactamente de un tipo';
    END IF;

    -- En actualizaciones, prohibir cambiar los atributos de rol
    IF (TG_OP = 'UPDATE') THEN
        IF (NEW.esMulti IS DISTINCT FROM OLD.esMulti OR NEW.esPelea IS DISTINCT FROM OLD.esPelea) THEN
            RAISE EXCEPTION 'El tipo de Torneo no puede ser modificado';
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER torneo_roles
BEFORE INSERT OR UPDATE ON Torneo
FOR EACH ROW EXECUTE FUNCTION torneo_rol();


-- Disparador: validar roles en Multi y asegurar coherencia con Torneo
CREATE OR REPLACE FUNCTION multi_rol()
RETURNS trigger AS $$
DECLARE
    padre_torneo RECORD;
    modos_true int := 0;
BEGIN
    modos_true := COALESCE(NEW.esCaptura, FALSE)::int + COALESCE(NEW.esDistanciaRecorrida, FALSE)::int;
    IF modos_true <> 1 THEN
        RAISE EXCEPTION 'Multi solo debe ser de un tipo';
    END IF;

    SELECT esMulti INTO padre_torneo FROM Torneo WHERE id_torneo = NEW.id_torneo;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'No existe Torneo con id % referenciado por Multi', NEW.id_torneo;
    END IF;
    IF COALESCE(padre_torneo.esMulti, FALSE) = FALSE THEN
        RAISE EXCEPTION 'El Torneo % no es de tipo multi', NEW.id_torneo;
    END IF;

    -- En actualizaciones, prohibir cambiar las modalidades
    IF (TG_OP = 'UPDATE') THEN
        IF (NEW.esCaptura IS DISTINCT FROM OLD.esCaptura OR NEW.esDistanciaRecorrida IS DISTINCT FROM OLD.esDistanciaRecorrida) THEN
            RAISE EXCEPTION 'El tipo de Multi no puede ser modificado';
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER multi_roles
BEFORE INSERT OR UPDATE ON Multi
FOR EACH ROW EXECUTE FUNCTION multi_rol();

-- Disparador: validar consistencia de Pelea con Torneo (solo insertar si Torneo.esPelea = TRUE)
CREATE OR REPLACE FUNCTION pelea_integridad()
RETURNS trigger AS $$
DECLARE
    t RECORD;
BEGIN
    SELECT esPelea INTO t FROM Torneo WHERE id_torneo = NEW.id_torneo;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'No existe Torneo con id % referenciado por Pelea', NEW.id_torneo;
    END IF;
    IF COALESCE(t.esPelea, FALSE) = FALSE THEN
        RAISE EXCEPTION 'El Torneo % no es de tipo pelea', NEW.id_torneo;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER pelea_integridad_trg
BEFORE INSERT ON Pelea
FOR EACH ROW EXECUTE FUNCTION pelea_integridad();

-- ============================================
-- FUNCIONES PARA ATRIBUTOS CALCULADOS
-- ============================================

--- Función: Contar el número de regitsors que realizó un registrador
--- Entrada: id_registrador
CREATE OR REPLACE FUNCTION contar_registros_registrador(p_registrador INTEGER)
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM Registrar
    WHERE id_persona_r = p_registrador;

    RETURN COALESCE(v_count, 0);
END;
$$;

--- Función: Calcular el sueldo de un registrador (sueldo base + 50*canntidad de registros realizados)
--- Entrada: id_registrador
CREATE OR REPLACE FUNCTION calcular_salario_registrador(p_registrador INTEGER)
RETURNS NUMERIC(12,2)
LANGUAGE plpgsql
AS $$
DECLARE
    v_base NUMERIC(12,2);
    v_cnt  INTEGER;
BEGIN
    SELECT salario_base INTO v_base
    FROM Registrador
    WHERE id_persona = p_registrador;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'No existe registrador con id %', p_registrador;
    END IF;

    SELECT COUNT(*) INTO v_cnt
    FROM Registrar
    WHERE id_persona_r = p_registrador;

    RETURN ROUND(v_base + (v_cnt * 50)::NUMERIC, 2);
END;
$$;

--- Función para calcular el precio final de un alimento
--- Entrada: id_alimento
CREATE OR REPLACE FUNCTION precio_final_alimento(p_id_alimento INTEGER)
RETURNS TABLE(
    id_alimento INTEGER,
    precio_base NUMERIC(10,2),
    iva NUMERIC(10,2),
    precio_final NUMERIC(10,2)
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_precio NUMERIC(10,2);
BEGIN
    SELECT precio INTO v_precio
    FROM Alimento
    WHERE id_alimento = p_id_alimento;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'No existe alimento con id %', p_id_alimento;
    END IF;

    RETURN QUERY
    SELECT p_id_alimento,
           v_precio,
           ROUND(v_precio * 0.16, 2) AS iva,
           ROUND(v_precio * 1.16, 2) AS precio_final;
END;
$$;

--- Función para calcular la distancia total de un participante en un solo torneo de distancia recorrida
--- id_persona (Del participante)
CREATE OR REPLACE FUNCTION distancia_total_por_edicion(p_edicion INTEGER)
RETURNS TABLE(
    id_participante INTEGER,
    nombre_participante TEXT,
    distancia_total NUMERIC(14,2)
)
LANGUAGE sql
AS $$
SELECT d.id_persona,
       COALESCE(per.nombres,'') || ' ' || COALESCE(per.apellido_paterno,'') || ' ' || COALESCE(per.apellido_materno,'') AS nombre_participante,
       SUM(d.distancia)::NUMERIC(14,2) AS distancia_total
FROM Distancia d
JOIN Participante par ON par.id_persona = d.id_persona
JOIN Torneo t ON par.id_torneo = t.id_torneo
JOIN Multi m ON t.id_torneo = m.id_torneo
LEFT JOIN Persona per ON per.id_persona = d.id_persona
WHERE t.edicion = $1
  AND m.esDistanciaRecorrida = TRUE
GROUP BY d.id_persona, per.nombres, per.apellido_paterno, per.apellido_materno
ORDER BY distancia_total DESC;
$$;

