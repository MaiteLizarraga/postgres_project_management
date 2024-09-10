---------------------------------------------------------------------------------------------------
-- SET PATH TO SCHEMA -----------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

SET search_path TO erp;

---------------------------------------------------------------------------------------------------
-- Apartado a -------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

ALTER TABLE erp.tb_project_budget 
ADD COLUMN total_amount NUMERIC (8,2) NOT NULL DEFAULT 0;

UPDATE erp.tb_project_budget
SET total_amount = units*unit_price;

-- Comprobamos que existe la nueva columna y que el valor mostrado coincide con el cálculo que queríamos realizar

---------------------------------------------------------------------------------------------------
-- Apartado b -------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

ALTER TABLE erp.tb_project_budget 
ADD CONSTRAINT check_cars_employee CHECK (units * unit_price = total_amount IS NOT NULL OR units*unit_price >= 0);

-- Repetimos con código las comprobaciones que ya hemos realizado visualmente en el apartado anterior

---------------------------------------------------------------------------------------------------
-- Apartado c -------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

INSERT INTO erp.tb_project_budget (project_budget_id, project_id, concept, units, unit_price, total_amount) 
VALUES ('33','1002','Rent an elevator',6,70,420);

-- Con el siguiente código, imprimimos la linea project_budget_id = 33 para cerciorarnos de que se
-- han insertado correctamente los valores:
-- SELECT * FROM erp.tb_project_budget WHERE project_budget_id = 33