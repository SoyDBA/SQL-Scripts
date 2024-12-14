/*
AUTOR: Roberto Carrancio
Web: www.soydba.es
Repositorio: https://github.com/SoyDBA/
*/

--==============================================================================
-- Acceso del login SA solo desde servidor local
--==============================================================================

USE [master]
GO


CREATE TRIGGER [RestrictSALogin]
ON ALL SERVER
FOR LOGON
AS
BEGIN
/*
AUTOR: Roberto Carrancio
Web: www.soydba.es
Repositorio: https://github.com/SoyDBA/
*/

    DECLARE @client_ip VARCHAR(48);
    SELECT @client_ip = client_net_address
    FROM sys.dm_exec_connections
    WHERE session_id = @@SPID;

    -- Lista de IPs autorizadas
    IF ORIGINAL_LOGIN() = 'sa' AND @client_ip NOT IN ('192.168.101.202','<local machine>') -- Cambiar la dirección IP por la del servidor
    BEGIN
        ROLLBACK;
        PRINT 'Acceso denegado para sa desde una máquina no autorizada.';
    END
END;
GO


