CREATE EVENT SESSION [Errores] ON SERVER 
ADD EVENT sqlserver.error_reported(
    ACTION(sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_id,sqlserver.database_name,sqlserver.session_id,sqlserver.sql_text,sqlserver.username)
    WHERE ([severity]>=(16)))
ADD TARGET package0.event_file(SET filename=N'D:\xEvents\Errores.xel')
WITH (MAX_MEMORY=4096 KB,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,MAX_DISPATCH_LATENCY=30 SECONDS,MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=NONE,TRACK_CAUSALITY=OFF,STARTUP_STATE=OFF)
GO

CREATE EVENT SESSION [ConsumoCPU] ON SERVER 
ADD EVENT sqlserver.query_post_execution_showplan(
    ACTION(package0.process_id,sqlserver.database_name,sqlserver.nt_username,sqlserver.sql_text)
    WHERE ([duration]>=(10000000)))
ADD TARGET package0.event_file(SET filename=N'D:\xEvents\ConsumoCPU.xel')
WITH (MAX_MEMORY=4096 KB,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,MAX_DISPATCH_LATENCY=30 SECONDS,MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=NONE,TRACK_CAUSALITY=OFF,STARTUP_STATE=OFF)
GO

CREATE EVENT SESSION [Convert Warnings] ON SERVER 
ADD EVENT sqlserver.plan_affecting_convert(
    ACTION(sqlserver.database_name,sqlserver.is_system,sqlserver.sql_text,sqlserver.username)
    WHERE ([package0].[greater_than_uint64]([sqlserver].[session_id],(50)) AND [package0].[equal_uint64]([convert_issue],'Seek Plan') AND [sqlserver].[database_id]>(4)))
ADD TARGET package0.event_file(SET filename=N'D:\xEvents\Convert Warnings')
WITH (MAX_MEMORY=4096 KB,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,MAX_DISPATCH_LATENCY=30 SECONDS,MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=NONE,TRACK_CAUSALITY=OFF,STARTUP_STATE=OFF)
GO

CREATE EVENT SESSION [WARNINGS] ON SERVER 
ADD EVENT sqlserver.hash_warning(
    ACTION(sqlserver.sql_text,sqlserver.username)
    WHERE ([sqlserver].[session_id]>(50) AND [sqlserver].[database_id]>(4))),
ADD EVENT sqlserver.missing_column_statistics(
    ACTION(sqlserver.sql_text,sqlserver.username)
    WHERE ([sqlserver].[session_id]>(50) AND [sqlserver].[database_id]>(4))),
ADD EVENT sqlserver.missing_join_predicate(
    ACTION(sqlserver.sql_text,sqlserver.username)
    WHERE ([sqlserver].[session_id]>(50) AND [sqlserver].[database_id]>(4))),
ADD EVENT sqlserver.plan_affecting_convert(
    ACTION(sqlserver.sql_text,sqlserver.username)
    WHERE ([sqlserver].[session_id]>(50) AND [sqlserver].[database_id]>(4))),
ADD EVENT sqlserver.sort_warning(
    ACTION(sqlserver.sql_text,sqlserver.username)
    WHERE ([sqlserver].[session_id]>(50) AND [sqlserver].[database_id]>(4))),
ADD EVENT sqlserver.unmatched_filtered_indexes(
    ACTION(sqlserver.sql_text,sqlserver.username)
    WHERE ([sqlserver].[session_id]>(50) AND [sqlserver].[database_id]>(4)))
ADD TARGET package0.event_file(SET filename=N'D:\xEvents\WARNINGS')
WITH (MAX_MEMORY=4096 KB,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,MAX_DISPATCH_LATENCY=30 SECONDS,MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=NONE,TRACK_CAUSALITY=OFF,STARTUP_STATE=OFF)
GO

CREATE EVENT SESSION [query_antipattern] ON SERVER 
ADD EVENT sqlserver.query_antipattern(
    ACTION(sqlserver.client_app_name,sqlserver.plan_handle,sqlserver.query_hash,sqlserver.query_plan_hash,sqlserver.sql_text)
    WHERE ([sqlserver].[client_app_name]<>N'''Microsoft SQL Server Management Studio - Transact-SQL IntelliSense'''))
ADD TARGET package0.event_file(SET filename=N'D:\xEvents\Antipatrones.xel')
WITH (MAX_MEMORY=4096 KB,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,MAX_DISPATCH_LATENCY=30 SECONDS,MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=NONE,TRACK_CAUSALITY=OFF,STARTUP_STATE=OFF)
GO


CREATE EVENT SESSION [TempDB_error] ON SERVER 
ADD EVENT sqlserver.error_reported(
    ACTION(sqlserver.database_id,sqlserver.plan_handle,sqlserver.session_id,sqlserver.session_nt_username,sqlserver.sql_text,sqlserver.tsql_stack)
    WHERE ([database_id]=(2) AND [session_id]>(50) AND ([error_number]=(1101) OR [error_number]=(1105))))
ADD TARGET package0.event_file(SET filename=N'D:\xEvents\TempDB_error.xel')
WITH (MAX_MEMORY=4096 KB,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,MAX_DISPATCH_LATENCY=120 SECONDS,MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=NONE,TRACK_CAUSALITY=OFF,STARTUP_STATE=ON)
GO

CREATE EVENT SESSION [Deadlocks] ON SERVER 
ADD EVENT sqlserver.xml_deadlock_report
ADD TARGET package0.event_file(SET filename=N'D:\xEvents\deadlocks.xel',max_file_size=(2048))
WITH (MAX_MEMORY=4096 KB,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,MAX_DISPATCH_LATENCY=30 SECONDS,MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=NONE,TRACK_CAUSALITY=OFF,STARTUP_STATE=OFF)
GO

