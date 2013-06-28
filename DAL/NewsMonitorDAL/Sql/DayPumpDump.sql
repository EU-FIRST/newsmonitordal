/*REM*/ DECLARE @entity VARCHAR(MAX) = 'http://project-first.eu/ontology#cou_US'
/*REM*/ DECLARE @from DATE = '2013-05-07'
/*REM*/ DECLARE @to DATE = '2013-06-07'
/*REM*/ DECLARE @normalize BIT = 1
--ADD DECLARE @entity VARCHAR(MAX) = {0}
--ADD DECLARE @from DATE = {1}
--ADD DECLARE @to DATE = {2}
--ADD DECLARE @normalize BIT = {3}

DECLARE @sentStDevMod float = 6
DECLARE @sentStDev float = 1/@sentStDevMod

--Retrieveng normalization parameter - standard deviation of the first year of entity's data
IF (@normalize = 1) BEGIN
	DECLARE @toNormalize DATE
	SELECT @toNormalize = MIN(O.[date])
	  FROM entity E
           INNER JOIN occurrence O
                   ON O.entity_id = E.id
	 WHERE E.entity_uri = @entity

	SELECT @sentStDev = COALESCE(STDEV(IndexByDays.[Index]), 1)
	  FROM (SELECT O.[date] AS [Date], 
				   AVG(D.pump_dump_index) AS [Index]
			  FROM document D
				   LEFT JOIN occurrence O
        				  ON D.id = O.document_id
                   INNER JOIN entity E
                           ON O.entity_id = E.id
			 WHERE     E.entity_uri = @entity
				   AND O.[date] >= @toNormalize
				   AND O.[date] < DATEADD (DAY, 365, @toNormalize)
			 GROUP BY O.[date]
			) IndexByDays

/*REM*/ PRINT '@toNormalize = ' + CONVERT(VARCHAR(MAX), @toNormalize)
/*REM*/ PRINT '@toNormalize + year = ' + CONVERT(VARCHAR(MAX), DATEADD (DAY, 365, @toNormalize))
/*REM*/ PRINT '@sentStDev = ' + CONVERT(VARCHAR(MAX), @sentStDev)
END

--The actual select returned
SELECT O.[date] AS [Date],
       AVG(D.pump_dump_index)/
        (@sentStDevMod*@sentStDev) AS [Index]
  FROM document D
       LEFT JOIN occurrence O
	          ON D.id = O.document_id
       INNER JOIN entity E
              ON O.entity_id = E.id
 WHERE     E.entity_uri = @entity
       AND O.[date] >= @from
       AND O.[date] <= @to
 GROUP BY O.[date]
 ORDER BY O.[date]















