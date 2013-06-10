/*REM*/ DECLARE @entityId INT = 2085
/*REM*/ DECLARE @days INT = 14
/*REM*/ DECLARE @date DATE = '2013-06-07'
/*REM*/ DECLARE @normalize BIT = 1
--ADD DECLARE @entityId INT = {0}
--ADD DECLARE @days INT = {1}
--ADD DECLARE @date DATE = {2}
--ADD DECLARE @normalize BIT = {3}

DECLARE @pdStDevMod float = 6
DECLARE @pdStDev float = 1/@pdStDevMod

--Retrieveng normalization parameter - standard deviation of the first year of entity's data
IF (@normalize = 1) BEGIN
	DECLARE @dateNormalize DATE
	SELECT @dateNormalize = MIN(O.[date])
	  FROM occurrence O
	 WHERE O.entity_id = @entityId

	SELECT @pdStDev = COALESCE(STDEV(PumpDumpByDays.PumpDumpIndex), 1)
	  FROM (SELECT O.[date] AS [Date],
                    AVG(D.pump_dump_index) AS PumpDumpIndex
               FROM document D
                    LEFT JOIN occurrence O
                         ON D.id = O.document_id
              WHERE     O.entity_id = @entityId 
                    AND O.[date] > DATEADD (DAY, -@days , @date)
                    AND O.[date] <= @date
              GROUP BY O.[date]
			) PumpDumpByDays

/*REM*/ PRINT '@dateNormalize = ' + CONVERT(VARCHAR(MAX), @dateNormalize)
/*REM*/ PRINT '@dateNormalize + year = ' + CONVERT(VARCHAR(MAX), DATEADD (DAY, 365, @dateNormalize))
/*REM*/ PRINT '@pdStDev = ' + CONVERT(VARCHAR(MAX), @pdStDev)
END

--The actual select returned
SELECT O.[date] AS [Date],
       AVG(D.pump_dump_index)/
       (@pdStDevMod*@pdStDev) AS PumpDumpIndex
  FROM document D
       LEFT JOIN occurrence O
	          ON D.id = O.document_id
 WHERE     O.entity_id = @entityId 
       AND O.[date] > DATEADD (DAY, -@days , @date)
       AND O.[date] <= @date
 GROUP BY O.[date]
 ORDER BY O.[date]







