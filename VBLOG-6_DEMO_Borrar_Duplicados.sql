USE [master]
IF EXISTS (select 1 from sys.databases where name = 'DEMO')
DROP DATABASE DEMO
GO
CREATE DATABASE DEMO
GO

USE [DEMO]
GO
CREATE TABLE Personas
	(
	[ID] INT Identity(1,1) NOT NULL,
	[NOMBRE] VARCHAR(25) NOT NULL,
	[APELLIDO_1] VARCHAR(25)  NULL,
	[NACIONALIDAD] VARCHAR(25) NULL
	) ON [PRIMARY]
GO

INSERT INTO Personas (NOMBRE,APELLIDO_1,NACIONALIDAD) 
VALUES
	('Peter','Griffin','USA'),
	('Peter','Griffin','USA'),
	('Obelix', 'OaaS', 'Francia'),
	('Obelix', 'OaaS', 'Francia'),
	('Obelix', 'OaaS', 'Francia'),
	('Dandy', NULL, 'España')
GO




SELECT NOMBRE,
	APELLIDO_1,
	NACIONALIDAD, 
    COUNT(*) AS CNT
FROM Personas
GROUP BY NOMBRE,
	APELLIDO_1,
	NACIONALIDAD
HAVING COUNT(*) > 1;

--------------------------------------------------------------------


SELECT *
    FROM Personas
    WHERE ID NOT IN
    (
        SELECT MAX(ID)
        FROM Personas
        GROUP BY NOMBRE,
			APELLIDO_1,
			NACIONALIDAD
    );

DELETE
    FROM Personas
    WHERE ID NOT IN
    (
        SELECT MAX(ID)
        FROM Personas
        GROUP BY NOMBRE,
			APELLIDO_1,
			NACIONALIDAD
    );
--------------------------------------------------------------------

SELECT NOMBRE,
	APELLIDO_1,
	NACIONALIDAD,
    ROW_NUMBER() OVER(PARTITION BY NOMBRE,
		APELLIDO_1,
		NACIONALIDAD
       ORDER BY id) AS CNT
FROM Personas


;WITH CTE AS (
SELECT NOMBRE,
	APELLIDO_1,
	NACIONALIDAD,
    ROW_NUMBER() OVER(PARTITION BY NOMBRE,
		APELLIDO_1,
		NACIONALIDAD
       ORDER BY id) AS CNT
FROM Personas
)

DELETE FROM CTE WHERE CNT>1
--------------------------------------------------------------------

SELECT P.ID, 
    P.NOMBRE, 
    P.APELLIDO_1, 
    P.NACIONALIDAD, 
    R.rank
FROM Personas P
INNER JOIN
	(
	 SELECT *, 
	        RANK() OVER(PARTITION BY NOMBRE, 
	                                 APELLIDO_1, 
	                                 NACIONALIDAD
	        ORDER BY id) rank
	 FROM Personas
	) R ON P.ID = R.ID;

DELETE FROM P
FROM Personas P
INNER JOIN
	(
	 SELECT *, 
	        RANK() OVER(PARTITION BY NOMBRE, 
	                                 APELLIDO_1, 
	                                 NACIONALIDAD
	        ORDER BY id) rank
	 FROM Personas
	) R ON P.ID = R.ID
WHERE R.RANK>1

--------------------------------------------------------------------
--------------------------------------------------------------------
--------------------------------------------------------------------

	

USE [master]
IF EXISTS (select 1 from sys.databases where name = 'DEMO_NOID')
DROP DATABASE DEMO_NOID
GO
CREATE DATABASE DEMO_NOID
GO

USE [DEMO_NOID]
GO
CREATE TABLE Personas
	(
	[NOMBRE] VARCHAR(25) NOT NULL,
	[APELLIDO_1] VARCHAR(25)  NULL,
	[NACIONALIDAD] VARCHAR(25) NULL
	) ON [PRIMARY]
GO

INSERT INTO Personas (NOMBRE,APELLIDO_1,NACIONALIDAD) 
VALUES
	('Peter','Griffin','USA'),
	('Peter','Griffin','USA'),
	('Obelix', 'OaaS', 'Francia'),
	('Obelix', 'OaaS', 'Francia'),
	('Obelix', 'OaaS', 'Francia'),
	('Dandy', NULL, 'España')
GO



SELECT *, %%physloc%% FROM PERSONAS



SELECT NOMBRE,
	APELLIDO_1,
	NACIONALIDAD, 
    COUNT(*) AS CNT
FROM Personas
GROUP BY NOMBRE,
	APELLIDO_1,
	NACIONALIDAD
HAVING COUNT(*) > 1;

--------------------------------------------------------------------


SELECT *
    FROM Personas
    WHERE %%physloc%% NOT IN
    (
        SELECT MAX(%%physloc%%)
        FROM Personas
        GROUP BY NOMBRE,
			APELLIDO_1,
			NACIONALIDAD
    );

DELETE
    FROM Personas
    WHERE %%physloc%% NOT IN
    (
        SELECT MAX(%%physloc%%)
        FROM Personas
        GROUP BY NOMBRE,
			APELLIDO_1,
			NACIONALIDAD
    );
--------------------------------------------------------------------

SELECT NOMBRE,
	APELLIDO_1,
	NACIONALIDAD,
    ROW_NUMBER() OVER(PARTITION BY NOMBRE,
		APELLIDO_1,
		NACIONALIDAD
       ORDER BY %%physloc%%) AS CNT
FROM Personas

;WITH CTE AS (
SELECT NOMBRE,
	APELLIDO_1,
	NACIONALIDAD,
    ROW_NUMBER() OVER(PARTITION BY NOMBRE,
		APELLIDO_1,
		NACIONALIDAD
       ORDER BY %%physloc%%) AS CNT
FROM Personas
)

DELETE FROM CTE WHERE CNT>1
--------------------------------------------------------------------

SELECT P.%%physloc%%, 
    P.NOMBRE, 
    P.APELLIDO_1, 
    P.NACIONALIDAD, 
    R.rank
FROM Personas P
INNER JOIN
	(
	 SELECT *, %%physloc%% AS Loc,
	        RANK() OVER(PARTITION BY NOMBRE, 
	                                 APELLIDO_1, 
	                                 NACIONALIDAD
	        ORDER BY %%physloc%%) rank
	 FROM Personas
	) R ON P.%%physloc%% = R.Loc;

DELETE
FROM Personas P
INNER JOIN
	(
	 SELECT *, %%physloc%% AS Loc,
	        RANK() OVER(PARTITION BY NOMBRE, 
	                                 APELLIDO_1, 
	                                 NACIONALIDAD
	        ORDER BY %%physloc%%) rank
	 FROM Personas
	) R ON P.%%physloc%% = R.Loc
WHERE R.RANK>1