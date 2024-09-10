---------------------------------------------------------------------------------------------------
-- Apartado e -------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

CREATE USER technical_user WITH LOGIN PASSWORD '1234';                  -- Se crea el usuario y se le asigna una contraseña por defecto
GRANT USAGE ON SCHEMA "erp" TO technical_user;                          -- Se asocia el usuario al esquema que va a utilizar
GRANT SELECT ON erp.tb_task_assigment TO technical_user;                -- Se le dan permisos de sólo lectura y consulta a este usuario para una sola tabla, la de tb_task_assigment
GRANT UPDATE (task_done) ON erp.tb_task_assigment TO technical_user;    -- Se le da a este usuario permiso de modificación a la columna task_done de la única tabla para la que
                                                                        -- le hemos dado permiso de lectura, la de tb_task_assigment

-- Esta parte está muy desarrollada en el word, donde realizo pruebas creando un nuevo servidor, asociándolo
-- a la base de datos de la Pec y comprobando que efectivamente, con este usuario, sólo puedo visualizar la tabla
--  de tb_task_assignment y que sólo puedo modificar el atributo task_done.

-- Fuentes consultadas para realizar el ejercicio 3:
--     • PECs de semestres anteriores
--     • https://stackoverflow.com/questions/20036547/mysql-how-to-grant-read-only-permissions-to-a-user 
--     • https://www.postgresql.org/docs/9.1/sql-grant.html
--     • https://www.postgresql.org/docs/current/sql-grant.html
--     • https://stackoverflow.com/questions/14462353/grant-alter-on-only-one-column-in-table
--     • https://www.postgresqltutorial.com/postgresql-administration/postgresql-grant
--     • https://www.postgresql.org/docs/9.4/sql-droprole.html
--     • https://www.postgresql.org/docs/current/sql-revoke.html

-- Aquí debajo el código que he utilizado para eliminar los users creados mientras probaba distintas opciones:
    -- REVOKE GRANT OPTION FOR ALL PRIVILEGES ON SCHEMA erp FROM technical_user;
    -- REVOKE ALL PRIVILEGES ON SCHEMA erp FROM technical_user;
    -- REVOKE GRANT OPTION FOR ALL PRIVILEGES ON TABLE erp.tb_task_assigment FROM technical_user;
    -- REVOKE ALL PRIVILEGES ON TABLE erp.tb_task_assigment FROM technical_user;
    -- DROP ROLE technical_user;
