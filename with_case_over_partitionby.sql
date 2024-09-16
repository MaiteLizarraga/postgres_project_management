-----------------------------------------------------------------------------------------------------
--Apartado A ----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------

WITH RECURSIVE nivel_organizativo_tareas AS (
	SELECT p.project_name, tp.start_date, t.task_name, tp.task_project_id, CAST (t.task_name AS TEXT) AS resultado
	FROM 	erp.tb_task_project tp 
			JOIN erp.tb_projects p USING (project_id)
			JOIN erp.tb_tasks t USING (task_id)
	WHERE tp.parent_id IS NULL
	UNION ALL
	SELECT p.project_name, tp.start_date, t.task_name, tp.task_project_id, CAST(nivot.resultado || ' <- ' || t.task_name AS TEXT) AS resultado
	FROM erp.tb_task_project tp 
		JOIN erp.tb_projects p USING (project_id)
		JOIN erp.tb_tasks t USING (task_id)
		INNER JOIN nivel_organizativo_tareas nivot ON (tp.parent_id = nivot.task_project_id)
)
SELECT project_name, task_name, start_date, resultado
FROM nivel_organizativo_tareas
ORDER BY project_name, start_date;

-----------------------------------------------------------------------------------------------------
--Apartado B ----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------

WITH project_task_counts AS (
    SELECT DISTINCT
        p.project_name, 
        p.priority, 
        COUNT(tp.task_project_id) AS task_count,
        MIN(tp.start_date) AS first_date,
        MAX(tp.end_date) AS last_date,
        (MAX(tp.end_date) - MIN(tp.start_date)) AS difference_days,
        SUM(tpb.total_amount) OVER (PARTITION BY project_id) AS total_amounts,
        CASE WHEN SUM(tpb.total_amount) = p.budget THEN TRUE ELSE FALSE END AS is_budget_correct
    FROM 
        erp.tb_projects p 
        JOIN erp.tb_task_project tp USING (project_id)
        JOIN erp.tb_project_budget tpb USING (project_id)
    GROUP BY
        p.project_name, 
        p.priority,
        p.budget,
		p.project_id,
		tpb.total_amount
)
SELECT
    project_name,
    priority,
    task_count,
    first_date,
    last_date,
    difference_days,
	RANK() OVER (PARTITION BY priority ORDER BY total_amounts) AS priority_ranking,
    is_budget_correct,
	total_amounts
FROM 
    project_task_counts
ORDER BY priority, priority_ranking;

