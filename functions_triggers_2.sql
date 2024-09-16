----------------------------------------------------------------------------------------------------------------------------------------
-- 1.a ---------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------

BEGIN WORK;

SET search_path TO erp;

CREATE OR REPLACE FUNCTION fn_check_budget(_project_id erp.tb_projects.project_id%TYPE, import erp.tb_project_budget.total_amount%TYPE)
RETURNS boolean AS $$

DECLARE
comportamiento erp.tb_projects.budget_behaviour%TYPE;
budget erp.tb_projects.budget%TYPE;
total_amounts erp.tb_project_budget.total_amount%TYPE;

BEGIN
    SELECT tp.budget_behaviour INTO comportamiento FROM erp.tb_projects tp WHERE tp.project_id = _project_id;
	SELECT tp.budget INTO budget FROM erp.tb_projects tp WHERE tp.project_id = _project_id;
	
	IF _project_id IS NULL OR import IS NULL THEN
		RETURN false;
	ELSIF comportamiento = 'open' OR comportamiento = 'margin' THEN
		RETURN true;
	ELSIF comportamiento = 'closed' THEN
        SELECT SUM(tpb.total_amount) INTO total_amounts FROM erp.tb_project_budget tpb WHERE tpb.project_id = _project_id;
        IF budget >= (total_amounts + import) THEN
            RETURN true;
        ELSE 
            RETURN false;
        END IF;
	END IF;
END;
$$ LANGUAGE plpgsql;

COMMIT WORK;

-- SENTENCIAS DE PRUEBA DEL EJERCICIO 1.a:
BEGIN WORK; SELECT fn_check_budget(1001, 10000.00); COMMIT WORK; -- proyecto 1001 closed, sum(total_amount) sobrepasa budget, debe lanzar un false
BEGIN WORK; SELECT fn_check_budget(1001, 10.00); COMMIT WORK;	   -- proyecto 1001 closed, sum(total_amount) no sobrepasa budget, debe lanzar un true
BEGIN WORK; SELECT fn_check_budget(1002, 10000.00); COMMIT WORK; -- proyecto 1002 margin, debe retornar un true
BEGIN WORK; SELECT fn_check_budget(1003, 10000.00); COMMIT WORK; -- proyecto 1003 open, debe retornar un true

----------------------------------------------------------------------------------------------------------------------------------------
-- 1.b. --------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------

BEGIN WORK;

SET search_path TO erp;

CREATE OR REPLACE FUNCTION fn_aux_check_budget()
RETURNS trigger AS $$

DECLARE
_project_id 		erp.tb_projects.project_id%TYPE;
_old_project_id		erp.tb_projects.project_id%TYPE;
_project_budget_id 	erp.tb_project_budget.project_budget_id%TYPE;
_old_amount			erp.tb_project_budget.total_amount%TYPE;
import 				erp.tb_project_budget.total_amount%TYPE;

budget	 			erp.tb_projects.budget%TYPE;
total_amounts 		erp.tb_project_budget.total_amount%TYPE;

BEGIN
	
	_project_id := NEW.project_id;
	_old_project_id := OLD.project_id;
	import := NEW.total_amount;
	_project_budget_id := NEW.project_budget_id;
	_old_amount := OLD.total_amount;
	
	SELECT tp.budget INTO budget FROM erp.tb_projects tp WHERE tp.project_id = _project_id;
	SELECT SUM(tpb.total_amount) INTO total_amounts FROM erp.tb_project_budget tpb WHERE tpb.project_id = _project_id;
	
	IF NOT fn_check_budget(_project_id, import) AND (TG_OP <> 'DELETE') THEN -- si la función booleana devuelve true, if not true, o sea si false
		RAISE EXCEPTION 'El budget es closed y al añadir tu nuevo total_amount, la suma de total amounts sobrepasa el budget';  -- no retorna nada

	ELSIF (TG_OP = 'INSERT') THEN
		-- sentencia insert - proyecto open
		UPDATE erp.tb_projects tp SET budget = total_amounts + import WHERE tp.budget_behaviour = 'open' AND tp.project_id = _project_id;

        -- sentencia insert - proyecto margin
		UPDATE erp.tb_projects tp SET budget = tp.budget + import WHERE tp.budget_behaviour = 'margin' AND tp.project_id = _project_id;

        RETURN NEW;

    ELSIF (TG_OP = 'UPDATE') THEN
		-- sentencia update - proyecto open
		UPDATE erp.tb_projects tp SET budget = (total_amounts - _old_amount) + import WHERE tp.budget_behaviour = 'open' AND tp.project_id = _project_id;

		-- sentencia update - proyecto margin
		UPDATE erp.tb_projects tp SET budget = (tp.budget - _old_amount) + import WHERE tp.budget_behaviour = 'margin' AND tp.project_id = _project_id;

		RETURN NEW;

    ELSIF (TG_OP = 'DELETE') THEN
		-- sentencia delete - proyecto open
        UPDATE erp.tb_projects tp SET budget = tp.budget - _old_amount WHERE tp.budget_behaviour = 'open' AND tp.project_id = _old_project_id;

        -- sentencia delete - proyecto margin
		UPDATE erp.tb_projects tp SET budget = tp.budget - _old_amount WHERE tp.budget_behaviour = 'margin' AND tp.project_id = _old_project_id;
        
        RETURN OLD;
	END IF;

END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS tg_update_budget ON erp.tb_project_budget;
CREATE TRIGGER tg_update_budget
BEFORE INSERT OR UPDATE OR DELETE ON erp.tb_project_budget
FOR EACH ROW
EXECUTE FUNCTION fn_aux_check_budget();

COMMIT WORK;

-- SENTENCIAS DE PRUEBA DEL EJERCICIO 1.b:

BEGIN WORK;
-- el budget_id = 3 corresponde al proyecto 1001, que es closed.
-- El nuevo sum(total_amount) sobrepasa el budget, por lo tanto Raise Exception (no actualiza el total_amount ni el budget)
UPDATE erp.tb_project_budget SET units = 100, unit_price = 100, total_amount = 10000 WHERE tb_project_budget.project_budget_id = 3;
ROLLBACK WORK;

BEGIN WORK;
-- el budget_id = 3 corresponde al proyecto 1001, que es closed.
-- No obstante, esta vez el nuevo sum(total_amount) no sobrepasa el budget, por lo tanto actualiza el total_amount del budget_id = 3 pero no actualiza el budget.
UPDATE erp.tb_project_budget SET units = 1, unit_price = 10, total_amount = 10 WHERE tb_project_budget.project_budget_id = 3;
COMMIT WORK;

BEGIN WORK;
-- El budget_id = 16 corresponde al proyecto 1002, que es margin.
-- Por lo tanto, al updatearse el total_amount al alza, el budget deberá aumentar en la misma medida margen constante.
UPDATE erp.tb_project_budget SET units = 1, unit_price = 3000, total_amount = 3000 WHERE tb_project_budget.project_budget_id = 16;
COMMIT WORK;

BEGIN WORK;
-- El budget_id = 16 corresponde al proyecto 1002, que es margin.
-- Por lo tanto, al updatearse el total_amount a la baja, el budget deberá disminuir en la misma medida (margen constante).
UPDATE erp.tb_project_budget SET units = 1, unit_price = 20, total_amount = 20 WHERE tb_project_budget.project_budget_id = 16;
COMMIT WORK;

BEGIN WORK;
-- El budget_id = 5 corresponde al proyecto 1003, que es open.
-- Por lo tanto, al updatear el total_amount al alza, el budget deberá ser exactamente la suma de los nuevos total_amounts (el budget subirá)
UPDATE erp.tb_project_budget SET units = 10, unit_price = 58.4, total_amount = 584 WHERE tb_project_budget.project_budget_id = 5; 
COMMIT WORK;

BEGIN WORK;
-- El budget_id = 5 corresponde al proyecto 1003, que es open.
-- Por lo tanto, al updatear el total_amount a la baja, el budget deberá ser exactamente la suma de los nuevos total_amounts (el budget bajará)
UPDATE erp.tb_project_budget SET units = 1, unit_price = 58.4, total_amount = 58.4 WHERE tb_project_budget.project_budget_id = 5;
COMMIT WORK;

BEGIN WORK;
-- Project 1001 es closed.
-- Por lo tanto, al insertar un nuevo total_amount al alza sobrepasando el budget, no lo deberá aceptar.
INSERT INTO erp.tb_project_budget(project_budget_id, project_id, concept, units, unit_price, total_amount) VALUES (33, 1001, 'Other materials', 1, 10000, 10000);
ROLLBACK WORK;

BEGIN WORK;
-- Project 1001 es closed.
-- No obstante, al insertar un nuevo total_amount al alza no sobrepasando el budget, por lo tanto lo deberá aceptar.
INSERT INTO erp.tb_project_budget(project_budget_id, project_id, concept, units, unit_price, total_amount) VALUES (33, 1001, 'Other materials', 1, 10, 10);
COMMIT WORK;

BEGIN WORK;
-- Project 1002 es margin.
-- Por lo tanto, al insertar un nuevo total_amount al alza, el budget se debería actualizar al alza manteniendo el margen.
INSERT INTO erp.tb_project_budget(project_budget_id, project_id, concept, units, unit_price, total_amount) VALUES (34, 1002, 'Other materials', 1, 1000, 1000);
COMMIT WORK;

BEGIN WORK;
-- Project 1003 es open.
-- Por lo tanto, al insertar un nuevo total_amount al alza, el budget deberá reflejar ese añadido.
INSERT INTO erp.tb_project_budget(project_budget_id, project_id, concept, units, unit_price, total_amount) VALUES (35, 1003, 'Other materials', 1, 1000, 1000);
COMMIT WORK;

BEGIN WORK;
-- Project 1001 es closed.
-- Por lo tanto, al deletear el project_budget_id, el budget no cambia.
DELETE FROM erp.tb_project_budget WHERE tb_project_budget.project_budget_id = 33;
COMMIT WORK;

BEGIN WORK;
-- Project 1002 es margin.
-- Por lo tanto, al deletear el project_budget_id = 34, el budget se reducirá en la misma medida pero conservando el margen.
DELETE FROM erp.tb_project_budget WHERE tb_project_budget.project_budget_id = 34;
COMMIT WORK;

BEGIN WORK;
-- Project 1003 es open.
-- Por lo tanto, al deletear el project_budget_id = 35, el budget se reducirá en la misma medida igualando la nueva suma de total_amounts.
DELETE FROM erp.tb_project_budget WHERE tb_project_budget.project_budget_id = 35;
COMMIT WORK;
