/*
AUTOR: Roberto Carrancio
Web: www.soydba.es
Repositorio: https://github.com/SoyDBA/
*/

--==============================================================================
-- Filtrado de inicios de sesión por IP
--==============================================================================

-- Crear la base de datos ConfigSeguridad
CREATE DATABASE ConfigSeguridad;
GO

-- Usar la base de datos ConfigSeguridad
USE ConfigSeguridad;
GO

-- Crear tabla maestra para gestionar usuarios y sus IPs permitidas
CREATE TABLE LoginsPermitidos (
    NombreUsuario NVARCHAR(100) NOT NULL, -- Nombre del usuario
    IPPermitida NVARCHAR(48) NOT NULL -- Dirección IP permitida, 'TODAS' si no hay restricciones
);
GO

-- ANTES DE CONTINUAR CON LA CREACIÓN DEL TRIGGER
-- Asegurate de tener todos los registros de logins en la tabla LoginsPermitidos
-- EJEMPLO: 
/*
INSERT INTO LoginsPermitidos (NombreUsuario, IPPermitida) 
VALUES 
    ('sa', '192.168.101.225'),			-- Usuario 'sa' solo puede conectarse desde una IP específica
	('sa', '<local machine>'),		-- Usuario 'sa' solo puede conectarse desde la máquina local
    ('admin', 'TODAS'),				-- Usuario 'admin' puede conectarse desde cualquier IP
    ('usuario1', '192.168.104.134');	-- Otro usuario con una IP específica
GO
-- Puedes añadir o actualizar esta lista según tus necesidades
*/



-- Crear el trigger para validar conexiones basado en la tabla LoginsPermitidos
CREATE TRIGGER RestriccionLogins
ON ALL SERVER
WITH EXECUTE AS N'sa'
FOR LOGON
AS

/*
AUTOR: Roberto Carrancio
Web: www.soydba.es
Repositorio: https://github.com/SoyDBA/
*/

BEGIN
    DECLARE @IPCliente NVARCHAR(48);		-- Dirección IP del cliente
    DECLARE @NombreUsuario NVARCHAR(100);	-- Nombre del usuario que intenta conectarse

    -- Obtener la IP del cliente desde las conexiones actuales
    SELECT 
        @IPCliente = client_net_address
    FROM 
        sys.dm_exec_connections
    WHERE 
        session_id = @@SPID;

    -- Obtener el nombre del usuario que intenta conectarse
    SET @NombreUsuario = ORIGINAL_LOGIN();

    -- Verificar si el usuario y la IP están permitidos
    IF NOT EXISTS (
        SELECT 1
        FROM ConfigSeguridad.dbo.LoginsPermitidos
        WHERE NombreUsuario = @NombreUsuario
          AND (IPPermitida = @IPCliente OR IPPermitida = 'TODAS')
    )
    BEGIN
        -- Bloquear la conexión si no está permitida
        ROLLBACK;
        PRINT 'Acceso denegado: Usuario o IP no autorizados.';
    END
END;
GO

-- Notificación de finalización
PRINT 'Base de datos ConfigSeguridad configurada exitosamente. Trigger creado.';
GO


