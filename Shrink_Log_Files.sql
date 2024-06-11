IF OBJECT_ID('tempdb..#DBsizes') IS NOT NULL
    DROP TABLE #DBsizes

CREATE TABLE #DBsizes
(
	ServerName nvarchar(max),
	DBname nvarchar(max),
	Filename nvarchar(max),
	CurrentSize INT,
	SpaceUsed	INT,
	CurrentAvailableSpace	INT,
	Growth INT,
	Physical nvarchar(max),
	status INT,
)

EXEC sp_MSforeachdb'
USE [?]
INSERT INTO #DBsizes
SELECT
		@@SERVERNAME,
		db_name(),
		ms.name, 
		-- Current Size		
		sf.size/128,
		-- Used space
		fileproperty(sf.name,''SpaceUsed'')/128,
		-- Current Available space
		(sf.size-fileproperty(sf.name,''SpaceUsed''))/128,
		CASE
			WHEN sf.growth < 0 THEN -1
			WHEN sf.growth = 0 THEN 0
			ELSE (sf.growth)/128
		END,
		ms.filename,
		sf.status
FROM	master.dbo.sysaltfiles ms, dbo.sysfiles sf
WHERE	dbid = DB_ID()
		AND ms.fileid = sf.FILEID
		AND sf.groupid = 0
		AND dbid <> 2
';

WITH Cte
AS
(
SELECT
	DBname,
	Filename,
	SUBSTRING(Physical,1,1) as [Drive],
	CurrentSize,
	SpaceUsed,
	Growth,
	CASE
		WHEN Growth <= 0 THEN (SpaceUsed*1)+1
		ELSE ((SpaceUsed/Growth) + 1) * Growth
	END as TargetSize,
	'USE ' + QUOTENAME(DBname) + '; CHECKPOINT; DBCC SHRINKFILE(N'''+Filename+''' , 0, TRUNCATEONLY);' as 'TruncateOnly',
	CASE
		WHEN Growth <= 0 THEN 'USE ' + QUOTENAME(DBname) + '; CHECKPOINT; DBCC SHRINKFILE(N'''+Filename+''' , '+CAST(CAST((SpaceUsed*1) + 1 AS FLOAT) as NVARCHAR(MAX))+' );'
		ELSE 'USE ' + QUOTENAME(DBname) + '; CHECKPOINT; DBCC SHRINKFILE(N'''+Filename+''' , '+ CAST(CAST((((SpaceUsed/Growth) + 1) * Growth) AS FLOAT) as NVARCHAR(MAX)) +');'
	END as 'ShrinkFile'
FROM #DBsizes
)
SELECT 
	DBname,
	Filename,
	Drive,
	CurrentSize,
	SpaceUsed,
	CAST(SpaceUsed as FLOAT)*100.0/(CurrentSize+1) as 'SpaceUsed_Pct',
	TargetSize,
	CurrentSize - TargetSize as [PotentialGain],
	CAST(CurrentSize - TargetSize as FLOAT)*100.0/(CurrentSize+1) as 'PotentialGain_Pct',
	TruncateOnly,
	ShrinkFile
FROM cte
ORDER BY Drive ASC, PotentialGain DESC

IF OBJECT_ID('tempdb..#DBsizes') IS NOT NULL

    DROP TABLE #DBsizes
