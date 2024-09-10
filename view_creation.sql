---------------------------------------------------------------------------------------------------
-- Apartado d -------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

CREATE VIEW erp.tech_employees_projects_tasks  AS
    SELECT 	te.name, 
            ttp.start_date AS task_start_date,
            ttp.end_date AS task_end_date,
            tp.project_name,
            tt.task_name,
            tta.task_done 
    FROM erp.tb_employees te
        INNER JOIN erp.tb_task_assigment tta USING (employees_id)
        INNER JOIN erp.tb_task_project ttp USING (task_project_id)
        INNER JOIN erp.tb_tasks tt USING (task_id)
        INNER JOIN erp.tb_projects tp USING (project_id)
    WHERE tta.task_done = FALSE;

-- Comprobamos en pgAdmin4 que la vista existe y que sólo nos muestra las tareas no completadas
-- No hemos podido poner WITH CHECK OPTION ya que da error. Según el log del error, la causa es que
-- "Views that do not select from a single table or view are not automatically updatable.". Es decir,
-- las vistas que seleccionan datos de más de una tabla o vista no pueden ser actualizadas automáticamente. 