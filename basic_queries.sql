---------------------------------------------------------------------------------------------------
-- SET PATH TO SCHEMA -----------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

SET search_path TO erp;

---------------------------------------------------------------------------------------------------
-- Apartado a -------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

SELECT tp.project_id, tp.project_name, tp.description, tp.start_date, (tp.end_date - tp.start_date) AS total_project_days
FROM erp.tb_projects tp		-- aquí no haría falta especificar "erp" pero lo he puesto para no tener que copiar el path de la linea 9 en en pgAdmin
WHERE priority = 'low' 
	AND start_date > '2024-01-01'
	AND tp.project_name LIKE 'Home%'
ORDER BY total_project_days DESC;

---------------------------------------------------------------------------------------------------
-- Apartado b -------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

SELECT tp.project_id, tp.project_name, tt.task_name, ttp.start_date, ttp.end_date
FROM erp.tb_projects tp 
	LEFT JOIN erp.tb_task_project ttp ON tp.project_id = ttp.project_id
	LEFT JOIN erp.tb_tasks tt ON tt.task_id = ttp.task_id
WHERE tp.project_name IN ('Stadium', 'City Hall')
ORDER BY ttp.start_date ASC;

---------------------------------------------------------------------------------------------------
-- Apartado c -------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

SELECT tp.project_id,
tp.project_name,
te.name,
tp.budget
FROM erp.tb_projects tp FULL OUTER JOIN erp.tb_employees te ON tp.sales_manager = te.employees_id
WHERE tp.start_date BETWEEN '2024-03-01' AND '2024-03-31'
ORDER BY tp.project_id;

---------------------------------------------------------------------------------------------------
-- Apartado d -------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

SELECT 	te.employees_id,
		te.name,
		COUNT(tta.task_assigment_id) AS more_than_three_tasks,
		MIN(ttp.start_date),
		MAX(ttp.end_date)
FROM tb_task_assigment tta
		INNER JOIN tb_task_project ttp USING (task_project_id)
		INNER JOIN tb_employees te USING (employees_id)
GROUP BY te.employees_id, te.name
HAVING COUNT (tta.task_assigment_id) > 3
ORDER BY more_than_three_tasks ASC, te.name DESC

---------------------------------------------------------------------------------------------------
-- Apartado e -------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

SELECT 	conceptos_seleccionados.project_id,
		tp.project_name,
		tp.budget AS budget,
		conceptos_seleccionados.concept,
		(conceptos_seleccionados.units * conceptos_seleccionados.unit_price) AS importe_del_registro
FROM (
		SELECT * FROM erp.tb_project_budget tpb
		WHERE tpb.concept != 'Solar panels'
		AND tpb.concept != 'Study and planning'
	 ) AS conceptos_seleccionados
		LEFT JOIN erp.tb_projects tp
		ON conceptos_seleccionados.project_id = tp.project_id
GROUP BY tp.project_id,
		conceptos_seleccionados.project_id,
		conceptos_seleccionados.concept,
		conceptos_seleccionados.units,
		conceptos_seleccionados.unit_price
HAVING budget > (SELECT AVG(budget) FROM erp.tb_projects)
ORDER BY tp.project_id ASC, conceptos_seleccionados.concept DESC;