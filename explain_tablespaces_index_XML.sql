-----------------------------------------------------------------------------------------------------
--Apartado A ----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------

EXPLAIN SELECT p.project_name, p.start_date, t.task_name
FROM erp.tb_task_project AS tp, 
    erp.tb_tasks AS t, 
    erp.tb_projects AS p
WHERE tp.task_id = t.task_id AND 
    tp.project_id = p.project_id AND
    t.task_id IN ('IE', 'SP', 'AS') AND 
    (p.budget_behaviour LIKE '%closed%' OR p.budget_behaviour LIKE '%margin%')
ORDER BY p.start_date DESC;

-----------------------------------------------------------------------------------------------------
--Apartado B ----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------

CREATE TABLESPACE tb_index_budgetbehaviour
LOCATION 'C:/Users/maite/Desktop/DATASCIENCE_1/Bases de datos';

ALTER TABLE erp.tb_projects SET TABLESPACE tb_index_budgetbehaviour;

CREATE INDEX indexOnBudgetBehaviour
ON erp.tb_projects USING btree (budget_behaviour)
TABLESPACE tb_index_budgetbehaviour;

ANALYZE erp.tb_projects;

EXPLAIN SELECT p.project_name, p.start_date, t.task_name
FROM erp.tb_task_project AS tp, 
    erp.tb_tasks AS t, 
    erp.tb_projects AS p
WHERE tp.task_id = t.task_id AND 
    tp.project_id = p.project_id AND
    t.task_id IN ('IE', 'SP', 'AS') AND 
    (p.budget_behaviour LIKE '%closed%' OR p.budget_behaviour LIKE '%margin%')
ORDER BY p.start_date DESC;

-----------------------------------------------------------------------------------------------------
--Apartado C ----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------

SELECT p.start_date, p.project_name, t.task_name
FROM erp.tb_task_project AS tp
	JOIN erp.tb_tasks t USING (task_id) 
	JOIN erp.tb_projects p USING (project_id)
WHERE t.task_id IN ('IE', 'SP', 'AS') AND 
    (p.budget_behaviour LIKE '%closed%' OR p.budget_behaviour LIKE '%margin%');

-----------------------------------------------------------------------------------------------------
--Apartado D ----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------

-- Consulta de SQL normal de lo que se busca:
SELECT p.description, p.project_name, e.phone, tp.task_id, tp.start_date, p.budget
FROM erp.tb_projects p 
	JOIN erp.tb_employees e ON p.sales_manager = e.employees_id
	JOIN erp.tb_task_project tp USING (project_id);

-- Consulta SQL que permite crear la estructura XML siguiente:
SELECT xmlelement(name "project", xmlattributes(p.description AS "description"),
		xmlelement(name "name", p.project_name),
		xmlelement(name "phone_contact", e.phone),
		xmlelement(name "active_task", tp.task_id),
		xmlelement(name "date_task", tp.start_date),
		xmlelement(name "cost_project", p.budget)) AS project_xml
FROM erp.tb_projects p 
	JOIN erp.tb_employees e ON p.sales_manager = e.employees_id
	JOIN erp.tb_task_project tp USING (project_id);
