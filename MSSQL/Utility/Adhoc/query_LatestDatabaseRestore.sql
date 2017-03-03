WITH AllRestores AS
(
SELECT
    D.name AS DatabaseName
,   D.create_date AS DatabaseCreateDate
,   D.compatibility_level AS DatabaseCompatibilityLevel
,   D.collation_name AS DatabaseCollation
,   R.restore_date AS RestoreCompleteDate
,   R.restore_type AS RestoreType
,   RowNum = ROW_NUMBER() OVER (PARTITION BY D.name ORDER BY R.restore_date DESC)
FROM
            [master].sys.databases  D
LEFT JOIN   msdb.dbo.restorehistory R   ON   D.Name = R.destination_database_name
)
SELECT
    DatabaseName
,   RestoreCompleteDate
FROM AllRestores
WHERE
    RowNum = 1
AND DatabaseName IN ('ASM-AH', 'DynamicsWarehouse', 'NHACRM', 'NHACRMReporting', 'NHADATAMART', 'NHAAnalytics', 'NHACertPortal')