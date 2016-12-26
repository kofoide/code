CREATE EVENT SESSION [Learn] ON SERVER 
ADD EVENT sqlserver.sql_batch_starting(
    ACTION(sqlserver.database_name,sqlserver.username)
    WHERE ([sqlserver].[not_equal_i_sql_unicode_string]([sqlserver].[session_nt_user],N'ekofoid') AND [sqlserver].[not_equal_i_sql_unicode_string]([sqlserver].[client_app_name],N'Report Server') AND [sqlserver].[database_name]<>N'master' AND [sqlserver].[database_name]<>N'msdb')) 
ADD TARGET package0.event_file(SET filename=N'S:\Logs\Learn.xel',max_file_size=(250))
WITH (MAX_MEMORY=4096 KB,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,MAX_DISPATCH_LATENCY=30 SECONDS,MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=NONE,TRACK_CAUSALITY=OFF,STARTUP_STATE=OFF)
GO


