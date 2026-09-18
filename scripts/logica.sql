--Lógica y Automatización(PL/pgSQL)
--Motor: PostgreSQL


-- 1. Trigger: Validación de Horarios y Cálculo de Duración de Turno


CREATE OR REPLACE FUNCTION validar_y_calcular_turno()
RETURNS TRIGGER AS $$
DECLARE
    inicio_ts TIMESTAMP;
    fin_ts    TIMESTAMP;
    duracion  INTERVAL;
BEGIN
    -- Validar que la hora de inicio y fin no sean iguales
    IF NEW.Hora_Inicio = NEW.Hora_Fin THEN
        RAISE EXCEPTION 'La hora de fin (%) no puede ser igual a la hora de inicio (%).', 
            NEW.Hora_Fin, NEW.Hora_Inicio;
    END IF;

    -- Construir timestamps para cálculo preciso de intervalos
    inicio_ts := ('2000-01-01 ' || NEW.Hora_Inicio)::TIMESTAMP;
    fin_ts    := ('2000-01-01 ' || NEW.Hora_Fin)::TIMESTAMP;

    -- Manejo de turnos nocturnos que cruzan la medianoche
    IF fin_ts <= inicio_ts THEN
        fin_ts := fin_ts + INTERVAL '1 day';
    END IF;

    -- Asignación automática del intervalo calculado
    duracion := fin_ts - inicio_ts;
    NEW.Duracion := duracion;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Asociación del trigger a la tabla Turno
DROP TRIGGER IF EXISTS trg_validar_y_calcular_turno ON Turno;

CREATE TRIGGER trg_validar_y_calcular_turno
BEFORE INSERT OR UPDATE ON Turno
FOR EACH ROW
EXECUTE FUNCTION validar_y_calcular_turno();



-- 2. SP: Registro de Mantenimiento y Cambio de Estado de Equipo


CREATE OR REPLACE PROCEDURE RegistrarMantenimiento(
    p_id_tipo_mantenimiento INT,
    p_id_equipo INT,
    p_fecha DATE,
    p_duracion INTERVAL
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_nombre_equipo VARCHAR(100);
    v_tipo_mantenimiento VARCHAR(100);
BEGIN
    -- Validar existencia previa del equipo
    IF NOT EXISTS (SELECT 1 FROM Equipo WHERE ID_Equipo = p_id_equipo) THEN
        RAISE EXCEPTION 'El equipo con ID % no existe en la base de datos.', p_id_equipo;
    END IF;

    -- Validar existencia del tipo de mantenimiento
    IF NOT EXISTS (SELECT 1 FROM TipoMantenimiento WHERE ID_TipoMantenimiento = p_id_tipo_mantenimiento) THEN
        RAISE EXCEPTION 'El tipo de mantenimiento con ID % no existe.', p_id_tipo_mantenimiento;
    END IF;

    -- Insertar el registro de mantenimiento
    INSERT INTO Mantenimiento (ID_TipoMantenimiento, ID_Equipo, Fecha, Duracion)
    VALUES (p_id_tipo_mantenimiento, p_id_equipo, p_fecha, p_duracion);

    -- Actualizar el estado del equipo a "En mantenimiento"
    UPDATE Equipo
    SET Estado = 'En mantenimiento'
    WHERE ID_Equipo = p_id_equipo;

    -- Recuperar información 
    SELECT Nombre INTO v_nombre_equipo FROM Equipo WHERE ID_Equipo = p_id_equipo;
    SELECT Descripcion INTO v_tipo_mantenimiento FROM TipoMantenimiento WHERE ID_TipoMantenimiento = p_id_tipo_mantenimiento;

    RAISE NOTICE 'Mantenimiento del tipo "%" registrado exitosamente para el equipo "%". Estado actualizado.',
        v_tipo_mantenimiento, v_nombre_equipo;
END;
$$;
