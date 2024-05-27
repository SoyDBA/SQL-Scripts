USE [DBA]
GO

/****** Object:  StoredProcedure [dbo].[MonitorTableUsage]    Script Date: 27/05/2024 18:29:26 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Roberto Carrancio (www.soydba.es)
-- Create date: 04/04/2024
-- Description:	Procedimiento para monitorizar a través del tiempo
-- el crecimiento de las tablas de las BBDD.
-- =============================================
CREATE PROCEDURE [dbo].[MonitorTableUsage]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
		
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name='TableUsage')
BEGIN
	CREATE TABLE TableUsage (
		[Fecha] DATE NOT NULL,
		[BaseDatos] VARCHAR(150) NOT NULL,
		[Esquema]  VARCHAR(150) NOT NULL,
		[Tabla]  VARCHAR(150) NOT NULL,
		[Filas] BIGINT,
		[TamañoTotalMb] FLOAT,
		[EspacioDatosMb] FLOAT,
		[EspacioIndicesMb] FLOAT,
		[EspacioLibreMb] FLOAT,
		CONSTRAINT PK_TableUsage PRIMARY KEY CLUSTERED (Fecha, BaseDatos, Esquema, Tabla)
	)
END

EXEC sp_MSforeachdb 'USE [?]
		IF EXISTS (SELECT 1 FROM sys.databases WHERE is_read_only = 0 and name=''?'')
		BEGIN
		INSERT INTO [DBA].dbo.[TableUsage] ([Fecha], [BaseDatos], [Esquema], [Tabla], [Filas], [TamañoTotalMb], [EspacioDatosMb], [EspacioIndicesMb], [EspacioLibreMb]	)
		SELECT
			GETDATE() Fecha
			,''?'' as BaseDatos
			,a3.name AS SchemaName,
		    a2.name AS TableName,
		    a1.rows as Row_Count,
		    (a1.reserved )* 8.0 / 1024 AS reserved_mb,
		    a1.data * 8.0 / 1024 AS data_mb,
		    (CASE WHEN (a1.used ) > a1.data THEN (a1.used ) - a1.data ELSE 0 END) * 8.0 / 1024 AS index_size_mb,
		    (CASE WHEN (a1.reserved ) > a1.used THEN (a1.reserved ) - a1.used ELSE 0 END) * 8.0 / 1024 AS unused_mb
		FROM    (   SELECT
		            ps.object_id,
		            SUM ( CASE WHEN (ps.index_id < 2) THEN row_count    ELSE 0 END ) AS [rows],
		            SUM (ps.reserved_page_count) AS reserved,
		            SUM (CASE   WHEN (ps.index_id < 2) THEN (ps.in_row_data_page_count + ps.lob_used_page_count + ps.row_overflow_used_page_count)
		                        ELSE (ps.lob_used_page_count + ps.row_overflow_used_page_count) END
		                ) AS data,
		            SUM (ps.used_page_count) AS used
		            FROM sys.dm_db_partition_stats ps
		            GROUP BY ps.object_id
		        ) AS a1
		INNER JOIN sys.all_objects a2  ON ( a1.object_id = a2.object_id )
		INNER JOIN sys.schemas a3 ON (a2.schema_id = a3.schema_id)
		WHERE a2.type <> N''S'' and a2.type <> N''IT''   
		option (recompile)
	END'
END
GO

/****** Object:  StoredProcedure [dbo].[Monitorizar_FileGroups]    Script Date: 27/05/2024 18:29:37 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		Roberto Carrancio (www.soydba.es)
-- Create date: 31/12/2018
-- Description:	Procedimiento para monitorizar a través del tiempo
-- el crecimiento de los ficheros de las BBDD.
-- =============================================
CREATE PROCEDURE [dbo].[Monitorizar_Ficheros]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
		
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name='CRECIMIENTO_FICHEROS')
BEGIN
	CREATE TABLE [dbo].[CRECIMIENTO_FICHEROS](
		[dbname] [nvarchar](128) NULL,
		[Type] [nvarchar](60) NULL,
		[FileName] [nvarchar](128) NULL,
		[FileGroup] [nvarchar](128) NULL,
		[Path] [nvarchar](260) NULL,
		[CurrentSizeMB] [numeric](17, 6) NULL,
		[UsedSpace] [numeric](17, 6) NULL,
		[Fecha] [datetime] NULL
) ON [PRIMARY]
END




EXEC sp_MSforeachdb 'USE [?]
		IF EXISTS (SELECT 1 FROM sys.databases WHERE is_read_only = 0 and name=''?'')
		BEGIN
		INSERT INTO [DBA].dbo.[CRECIMIENTO_FICHEROS]
		([dbname]
		,[Type]
		,[FileName]
		,[FileGroup]
		,[Path]
		,[CurrentSizeMB]
		,[UsedSpace]
		,[Fecha])
		select
		''?''
		,f.type_desc as [Type]
		,f.name as [FileName]
		,fg.name as [FileGroup]
		,f.physical_name as [Path]
		,f.size / 128.0 as [CurrentSizeMB]
		,convert(int,fileproperty(f.name,''SpaceUsed'')) / 
			128.0 [UsedSpace]
		,GETDATE() Fecha
	from 
		sys.database_files f left outer join 
			sys.filegroups fg on
				f.data_space_id = fg.data_space_id
	option (recompile)
	END'
END
GO


USE [msdb]
GO

/****** Object:  Job [MP_Monitor_Crecimiento_Ficheros]    Script Date: 27/05/2024 18:28:50 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 27/05/2024 18:28:51 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'MP_Monitor_Crecimiento_Ficheros', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Monitor FileGroups]    Script Date: 27/05/2024 18:28:51 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Monitor Ficheros', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'exec dbo.[Monitorizar_Ficheros]', 
		@database_name=N'DBA', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Monitor Tablas]    Script Date: 27/05/2024 18:28:51 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Monitor Tablas', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'exec dba.dbo.MonitorTableUsage', 
		@database_name=N'DBA', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Daily 23:30', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20231017, 
		@active_end_date=99991231, 
		@active_start_time=233000, 
		@active_end_time=235959, 
		@schedule_uid=N'15367ccc-1d50-4318-95aa-5c78663dd142'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO


