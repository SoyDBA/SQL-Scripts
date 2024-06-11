USE [tempdb]
GO
select 'ALTER DATABASE TEMPDB MODIFY FILE (NAME=' + name + ', FILENAME=''' + physical_name + ''',SIZE=262144KB,FILEGROWTH=65536KB)'
FROM sys.database_files order by type_desc
GO
CHECKPOINT; 
GO
DECLARE @sqlCmd VARCHAR(MAX)
SET @sqlcmd=''
SELECT @sqlCmd = @sqlCmd + 'DBCC SHRINKFILE (' + name + ' ,0, TRUNCATEONLY);'
FROM sys.database_files
--PRINT @sqlCmd
EXEC (@sqlCmd)
