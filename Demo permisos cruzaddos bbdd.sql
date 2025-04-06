-- Demo permisos cruzaddos bbdd
-- Lenguaje T-SQL
-- 1. Crear una base de datos
CREATE DATABASE TestPermisos1
GO
-- 2. Crear una tabla
USE TestPermisos1
GO
CREATE TABLE TestPermisos (
  id INT NOT NULL,
  nombre VARCHAR(45) NOT NULL,
  PRIMARY KEY (id));
GO
-- 3. Insertar datos de demostración
INSERT INTO TestPermisos1.dbo.TestPermisos (id, nombre) 
VALUES (1, 'Juan'),
(2, 'Pedro'),
(3, 'Maria'),
(4, 'Ana'),
(5, 'Luis'),
(6, 'Carlos'),
(7, 'Laura'),
(8, 'Javier'),
(9, 'Sofia'),
(10, 'Diego');

-- 4. Crear una segunda base de datos
USE master
GO
CREATE DATABASE TestPermisos2
GO
-- 5. Crear vista de la tabla TestPermisos
USE TestPermisos2
GO
CREATE VIEW TestPermisosView AS
SELECT * FROM TestPermisos1.dbo.TestPermisos WHERE id < 5;
GO
-- 6. Crear un Login y usuario
USE master
GO
CREATE LOGIN TestUser WITH PASSWORD = 'TestUser123';
GO
USE TestPermisos2
GO
CREATE USER TestUser FOR LOGIN TestUser;
GO
-- 7. Asignar permisos al usuario
GRANT SELECT ON TestPermisosView TO TestUser;
-- 8. Probar permisos cruzados
-- Ambas consultas deberían fallar, ya que el usuario TestUser no existe en la base de datos TestPermisos1.
USE TestPermisos2
GO
EXECUTE AS LOGIN='TestUser'
SELECT * FROM TestPermisosView; 
SELECT * FROM TestPermisos1.dbo.TestPermisos;
REVERT

-- 9. Crear usuario en la base de datos TestPermisos1
USE TestPermisos1
GO
CREATE USER TestUser FOR LOGIN TestUser;
GO

-- 10. Probar permisos cruzados
-- Ambas consultas deberían fallar. Ahora con un error distinto, ya que el usuario TestUser no tiene permisos sobre la tabla.
USE TestPermisos2
GO
EXECUTE AS LOGIN='TestUser'
SELECT * FROM TestPermisosView; 
SELECT * FROM TestPermisos1.dbo.TestPermisos;
REVERT

-- 11. Solución
-- Dar permisos a la tabla no es una solución, ya que el usuario TestUser solo debería tener acceso a los datos como están filtrados por la vista.
-- habilitar permiso de acceso cruzado
ALTER DATABASE TestPermisos1 SET DB_CHAINING ON
ALTER DATABASE TestPermisos2 SET DB_CHAINING ON

-- 12. Probar permisos cruzados
-- El usuario TestUser no tiene permisos sobre la tabla pero ahora ya puede ejecutar la consulta sobre la vista.
-- Si quiere consultar la tabla dará error.
USE TestPermisos2
GO
EXECUTE AS LOGIN='TestUser'
SELECT * FROM TestPermisosView; 
SELECT * FROM TestPermisos1.dbo.TestPermisos;
REVERT