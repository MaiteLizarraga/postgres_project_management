---------------------------------------------------------------------------------------------------
-- DROP DATABASE ----------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

DROP DATABASE IF EXISTS dbdw_pec2;

---------------------------------------------------------------------------------------------------
-- CREATE DATABASE --------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

CREATE DATABASE dbdw_pec2;

---------------------------------------------------------------------------------------------------
-- SET PATH TO DATABASE ---------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

SET search_path TO dbdw_pec2;

---------------------------------------------------------------------------------------------------
-- DROP SCHEMA ------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

DROP SCHEMA IF EXISTS erp;

---------------------------------------------------------------------------------------------------
-- CREATE SCHEMA ----------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

CREATE SCHEMA erp;

---------------------------------------------------------------------------------------------------
-- DROP TABLES ------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS erp.tb_employees;
DROP TABLE IF EXISTS erp.tb_projects;
DROP TABLE IF EXISTS erp.tb_project_budget;
DROP TABLE IF EXISTS erp.tb_tasks;
DROP TABLE IF EXISTS erp.tb_task_project;
DROP TABLE IF EXISTS erp.tb_task_assigment;

---------------------------------------------------------------------------------------------------
-- CREATE TABLES ----------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

BEGIN WORK;

---------------------------------------------------------------------------------------------------
-- Create Table Employees -------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

CREATE TABLE erp.tb_employees (     -- te
    employees_id    INT,
    name   CHARACTER VARYING(20) NOT NULL,
    role   CHARACTER VARYING(30) NOT NULL,
    phone  CHARACTER(13) NOT NULL,
    CONSTRAINT pk_employees PRIMARY KEY (employees_id)
);

---------------------------------------------------------------------------------------------------
-- Create Table Projects --------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

CREATE TABLE erp.tb_projects (      -- tp
    project_id     INT,
    project_name   CHARACTER VARYING(30) NOT NULL,
    description    CHARACTER VARYING(40),
    start_date     DATE NOT NULL,
    end_date       DATE NOT NULL,
    priority       CHARACTER(6) NOT NULL,
    sales_manager  INT,
    budget         NUMERIC(8,2) NOT NULL,
    CONSTRAINT pk_projects PRIMARY KEY (project_id),
    CONSTRAINT fk_projects_employees FOREIGN KEY (sales_manager) REFERENCES erp.tb_employees(employees_id),
    CONSTRAINT u_project_name UNIQUE(project_name),
    CONSTRAINT ck_priority CHECK(priority in ('high','medium','low'))
);

---------------------------------------------------------------------------------------------------
-- Create Table Project Budget --------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

CREATE TABLE erp.tb_project_budget (    -- tpb
    project_budget_id   INT,
    project_id          INT NOT NULL,
    concept             CHARACTER VARYING(50) NOT NULL,
    units               INT NOT NULL,
    unit_price          NUMERIC(8,2) NOT NULL,
    CONSTRAINT pk_project_budget PRIMARY KEY (project_budget_id),
    CONSTRAINT fk_project_budget_projects FOREIGN KEY (project_id) REFERENCES erp.tb_projects(project_id)
);

---------------------------------------------------------------------------------------------------
-- Create Table Tasks -----------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

CREATE TABLE erp.tb_tasks (     -- tt
    task_id     CHARACTER(2),
    task_name   CHARACTER(50) NOT NULL,
    CONSTRAINT pk_tasks PRIMARY KEY (task_id)
);

---------------------------------------------------------------------------------------------------
-- Create Table Task Project ----------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

CREATE TABLE erp.tb_task_project (      -- ttp
    task_project_id INT,
    project_id      INT NOT NULL,
    task_id         CHARACTER(2),
    start_date      DATE NOT NULL,
    end_date        DATE NOT NULL,
    parent_id       INT DEFAULT NULL,
    CONSTRAINT pk_task_project PRIMARY KEY (task_project_id),
    CONSTRAINT fk_projects FOREIGN KEY (project_id) REFERENCES erp.tb_projects(project_id),
    CONSTRAINT fk_tasks FOREIGN KEY (task_id) REFERENCES erp.tb_tasks(task_id),
    CONSTRAINT fk_task_project FOREIGN KEY (parent_id) REFERENCES erp.tb_task_project(task_project_id),
    CONSTRAINT ck_task_project CHECK(parent_id IS NULL OR parent_id <= task_project_id)
);

---------------------------------------------------------------------------------------------------
-- Create Table Task Assignment -------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

CREATE TABLE erp.tb_task_assigment (    -- tta
    task_assigment_id   INT,
    employees_id        INT NOT NULL,
    task_project_id     INT NOT NULL,
    task_done           BOOLEAN NOT NULL DEFAULT FALSE,
    CONSTRAINT pk_task_assigment PRIMARY KEY (task_assigment_id),
    CONSTRAINT fk_employees FOREIGN KEY (employees_id) REFERENCES erp.tb_employees(employees_id),
    CONSTRAINT fk_task_project FOREIGN KEY (task_project_id) REFERENCES erp.tb_task_project(task_project_id)
);

---------------------------------------------------------------------------------------------------
-- COMMIT TABLES ----------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

COMMIT WORK;















