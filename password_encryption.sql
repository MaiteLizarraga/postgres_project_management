-----------------------------------------------------------------------------------------------------
--Apartado D ----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------

ALTER TABLE erp.tb_employees ADD COLUMN password CHARACTER VARYING(100);
-- ALTER TABLE erp.tb_employees DROP COLUMN password;

UPDATE erp.tb_employees SET password = crypt(CAST(employees_id AS text), gen_salt('md5'));

SELECT * FROM erp.tb_employees
ORDER BY employees_id ASC 


-- https://www.postgresql.org/docs/current/pgcrypto.html
-- https://www.fortinet.com/lat/resources/cyberglossary/pgp-encryption#:~:text=PGP%20es%20la%20abreviatura%20de,firmas%20digitales%20y%20cifrando%20archivos.
-- https://latam.kaspersky.com/blog/que-es-un-hash-y-como-funciona/2806/
-- https://man7.org/linux/man-pages/man3/crypt.3.html
