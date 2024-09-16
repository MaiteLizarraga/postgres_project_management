-------------------------------------------------------------------------------------------------
-- # 3.a ----------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------

-- Explicación en formato texto en el documento pdf.

-------------------------------------------------------------------------------------------------
-- # 3.b ----------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------

-- Interlación genérica de nivel de base de datos

CREATE COLLATION IF NOT EXISTS erp.alphabetical_collation(
	provider = ICU,
	locale = 'es-ES',
	deterministic = false,
	rules = 'H <<< A'
)

select name from testCollation
order by name COLLATE erp.alphabetical_collation ASC;

-- Misma intercalación pero específica para la columna name de la tabla testcollation

ALTER TABLE testCollation ALTER COLUMN name SET DATA TYPE varchar(15) COLLATE erp.alphabetical_collation;

select name from testCollation
order by name ASC;


-- FUENTES CONSULTADAS:
-- https://www.postgresql.org/docs/current/collation.html
-- https://stackoverflow.com/questions/57924382/how-to-change-column-collation-postgresql
-- https://dba.stackexchange.com/questions/94887/what-is-the-impact-of-lc-ctype-on-a-postgresql-database
-- https://www.cybertec-postgresql.com/en/icu-collations-against-postgresql-data-corruption/
-- https://newsmatic.com.ar/gestion-de-datos/manejo-acentos-mayusculas-sql-server#:~:text=La%20colaci%C3%B3n%20se%20refiere%20a,nivel%20de%20base%20de%20datos.
-- https://www.postgresql.org/docs/current/sql-createcollation.html
-- https://www.postgresql.org/docs/16/catalog-pg-collation.html
-- https://es.stackoverflow.com/questions/455269/como-cuando-y-la-funcionalidad-de-collate
-- https://support.microsoft.com/es-es/topic/cuando-intento-abrir-el-administrador-de-dispositivos-o-la-ventana-administraci%C3%B3n-de-equipos-aparece-un-mensaje-de-error-mmc-no-puede-abrir-el-archivo-c-windows-system32-devmgmt-msc-6b229ef2-74f8-a174-7f7f-6a78b251a9aa#:~:text=Haga%20clic%20en%20Inicio%20y,carpeta%20donde%20instal%C3%B3%20Microsoft%20Windows.
-- https://www.autodesk.es/support/technical/article/caas/sfdcarticles/sfdcarticles/ESP/How-to-determine-the-installation-language-of-an-Operating-System-before-installing-Vault-Server.html
-- https://www.postgresql.org/docs/16/collation.html#COLLATION-MANAGING-CREATE-LIBC
-- https://stackoverflow.com/questions/57924382/how-to-change-column-collation-postgresql
