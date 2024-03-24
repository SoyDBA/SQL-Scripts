USE [msdb]
GO
DECLARE @Sev17 Varchar(200), 
@Sev18 Varchar(200), 
@Sev19 Varchar(200), 
@Sev20 Varchar(200), 
@Sev21 Varchar(200), 
@Sev22 Varchar(200),
@Sev23 Varchar(200), 
@Sev24 Varchar(200),  
@Sev25 Varchar(200),
@Error823 Varchar(200), 
@Error824 Varchar(200), 
@Error825 Varchar(200),
@Error1480 Varchar(200),
@DBMailOperator Varchar(100)
SET @DBMailOperator = 'DBA Team' /* DEFINE AQUI EL NOMBRE DE TU OPERADOR DE MAIL EN EL AGENTE DE SQL */
SET @Sev17 = 'Severity 17'
SET @Sev18 = 'Severity 18'
SET @Sev19 = 'Severity 19'
SET @Sev20 = 'Severity 20'
SET @Sev21 = 'Severity 21'
SET @Sev22 = 'Severity 22'
SET @Sev23 = 'Severity 23'
SET @Sev24 = 'Severity 24'
SET @Sev25 = 'Severity 25'
SET @Error823 = 'Error 823'
SET @Error824 = 'Error 824'
SET @Error825 = 'Error 825'
SET @Error1480 = 'Error 1480'

 
EXEC msdb.dbo.sp_add_alert @Name=@sev17,
@message_id=0,
@severity=17,
@enabled=1,
@delay_between_responses=60,
@include_event_description_in=1,
@job_id=N'00000000-0000-0000-0000-000000000000';
EXEC msdb.dbo.sp_add_notification @alert_name=@sev17, @operator_name=@DBMailOperator, @notification_method = 7;

EXEC msdb.dbo.sp_add_alert @Name=@Sev18,
@message_id=0,
@severity=18,
@enabled=1,
@delay_between_responses=60,
@include_event_description_in=1,
@job_id=N'00000000-0000-0000-0000-000000000000';
EXEC msdb.dbo.sp_add_notification @alert_name=@sev18, @operator_name=@DBMailOperator, @notification_method = 7;

EXEC msdb.dbo.sp_add_alert @Name=@sev19,
@message_id=0,
@severity=19,
@enabled=1,
@delay_between_responses=60,
@include_event_description_in=1,
@job_id=N'00000000-0000-0000-0000-000000000000';
EXEC msdb.dbo.sp_add_notification @alert_name=@sev19, @operator_name=@DBMailOperator, @notification_method = 7;

EXEC msdb.dbo.sp_add_alert @Name=@Sev20,
@message_id=0,
@severity=20,
@enabled=1,
@delay_between_responses=60,
@include_event_description_in=1,
@job_id=N'00000000-0000-0000-0000-000000000000';
EXEC msdb.dbo.sp_add_notification @alert_name=@Sev20, @operator_name=@DBMailOperator, @notification_method = 7;

EXEC msdb.dbo.sp_add_alert @Name=@Sev21,
@message_id=0,
@severity=21,
@enabled=1,
@delay_between_responses=60,
@include_event_description_in=1,
@job_id=N'00000000-0000-0000-0000-000000000000';
EXEC msdb.dbo.sp_add_notification @alert_name=@Sev21, @operator_name=@DBMailOperator, @notification_method = 7;

EXEC msdb.dbo.sp_add_alert @Name=@Sev22,
@message_id=0,
@severity=22,
@enabled=1,
@delay_between_responses=60,
@include_event_description_in=1,
@job_id=N'00000000-0000-0000-0000-000000000000';
EXEC msdb.dbo.sp_add_notification @alert_name=@Sev22, @operator_name=@DBMailOperator, @notification_method = 7;

EXEC msdb.dbo.sp_add_alert @Name=@Sev23,
@message_id=0,
@severity=23,
@enabled=1,
@delay_between_responses=60,
@include_event_description_in=1,
@job_id=N'00000000-0000-0000-0000-000000000000';
EXEC msdb.dbo.sp_add_notification @alert_name=@Sev23, @operator_name=@DBMailOperator, @notification_method = 7;

EXEC msdb.dbo.sp_add_alert @Name=@Sev24,
@message_id=0,
@severity=24,
@enabled=1,
@delay_between_responses=60,
@include_event_description_in=1,
@job_id=N'00000000-0000-0000-0000-000000000000';
EXEC msdb.dbo.sp_add_notification @alert_name=@Sev24, @operator_name=@DBMailOperator, @notification_method = 7;

EXEC msdb.dbo.sp_add_alert @Name=@Sev25,
@message_id=0,
@severity=25,
@enabled=1,
@delay_between_responses=60,
@include_event_description_in=1,
@job_id=N'00000000-0000-0000-0000-000000000000';
EXEC msdb.dbo.sp_add_notification @alert_name=@Sev25, @operator_name=@DBMailOperator, @notification_method = 7;

EXEC msdb.dbo.sp_add_alert @name=@Error823,
@message_id=823,
@severity=0,
@enabled=1,
@delay_between_responses=60,
@include_event_description_in=1,
@job_id=N'00000000-0000-0000-0000-000000000000'
EXEC msdb.dbo.sp_add_notification @alert_name=@Error823, @operator_name=@DBMailOperator, @notification_method = 7;

EXEC msdb.dbo.sp_add_alert @name=@Error824,
@message_id=824,
@severity=0,
@enabled=1,
@delay_between_responses=60,
@include_event_description_in=1,
@job_id=N'00000000-0000-0000-0000-000000000000'
EXEC msdb.dbo.sp_add_notification @alert_name=@Error824, @operator_name=@DBMailOperator, @notification_method = 7;

EXEC msdb.dbo.sp_add_alert @name=@Error825,
@message_id=825,
@severity=0,
@enabled=1,
@delay_between_responses=60,
@include_event_description_in=1,
@job_id=N'00000000-0000-0000-0000-000000000000'
EXEC msdb.dbo.sp_add_notification @alert_name=@Error825, @operator_name=@DBMailOperator, @notification_method = 7;

EXEC msdb.dbo.sp_add_alert @name=@Error1480,
@message_id=1480,
@severity=0,
@enabled=1,
@delay_between_responses=60,
@include_event_description_in=1,
@job_id=N'00000000-0000-0000-0000-000000000000'
EXEC msdb.dbo.sp_add_notification @alert_name=@Error1480, @operator_name=@DBMailOperator, @notification_method = 7;
