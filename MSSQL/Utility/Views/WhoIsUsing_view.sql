CREATE VIEW WhoIsUsing
AS

WITH data (event_data_XML, pk)
AS
(
SELECT  + CAST('<root>' + event_data + '</root>' AS XML) AS 'event_data_XML', ROW_NUMBER() OVER(ORDER BY event_data)

FROM sys.fn_xe_file_target_read_file('S:\Logs\*.xel', NULL, NULL, NULL)
)
, values2 (times, xpart, datapart, PK, rn)
AS
(
SELECT items.item.value('@timestamp', 'varchar(100)'), item1s.item.value('local-name(..)', 'varchar(50)'), item1s.item.value('text()[1]', 'varchar(100)'), PK, ROW_NUMBER() OVER(PARTITION BY PK ORDER BY PK)
FROM
			data	D
CROSS APPLY event_data_XML.nodes('/root/event') AS items(item)
CROSS APPLY event_data_XML.nodes('/root/event/*/value') AS item1s(item)

)

SELECT CONVERT(DATETIME, times, 127) AS sql_date, [1] AS user_sql, [2] AS database_name, [3] AS user_name
FROM
	(SELECT rn, datapart, pk, times FROM values2) AS SourceTable
PIVOT
	(MAX(datapart) FOR rn IN ([1], [2], [3])) AS PivotTable


