/*REM*/ DECLARE @entityId INT = 2085
/*REM*/ DECLARE @days INT = 14
/*REM*/ DECLARE @date DATE = '2013-06-07'
/*REM*/ DECLARE @normalize BIT = 1
--ADD DECLARE @entityId INT = {0}
--ADD DECLARE @days INT = {1}
--ADD DECLARE @date DATE = {2}
--ADD DECLARE @normalize BIT = {3}

DECLARE @sentStDevMod float = 6
DECLARE @sentStDev float = 1/@sentStDevMod

--Retrieveng normalization parameter - standard deviation of the first year of entity's data
IF (@normalize = 1) BEGIN
	DECLARE @dateNormalize DATE
	SELECT @dateNormalize = MIN(O.[date])
	  FROM occurrence O
	 WHERE O.entity_id = @entityId

	SELECT @sentStDev = COALESCE(STDEV(SentByDays.Sentiment), 1)
	  FROM (SELECT O.[date] AS [Date], 
					 COALESCE( 
        				SUM(BS.positives - BS.negatives)/
        					CAST(NULLIF(SUM(BS.positives + BS.negatives), 0) AS FLOAT)
        				,0
        			) AS Sentiment -- if (BS.positives + BS.negatives == 0) returns 0
			  FROM block_sentiment BS
				   LEFT JOIN occurrence O
        				  ON BS.document_id = O.document_id
			 WHERE     O.entity_id = @entityId 
				   AND O.[date] >= @dateNormalize
				   AND O.[date] < DATEADD (DAY, 365, @dateNormalize)
			 GROUP BY O.[date]
			) SentByDays

/*REM*/ PRINT '@dateNormalize = ' + CONVERT(VARCHAR(MAX), @dateNormalize)
/*REM*/ PRINT '@dateNormalize + year = ' + CONVERT(VARCHAR(MAX), DATEADD (DAY, 365, @dateNormalize))
/*REM*/ PRINT '@sentStDev = ' + CONVERT(VARCHAR(MAX), @sentStDev)
END

--The actual select returned
SELECT O.[date] AS [Date],
        COALESCE( 
            SUM(BS.positives - BS.negatives)/
                CAST(NULLIF(SUM(BS.positives + BS.negatives), 0) AS FLOAT)
				,0
        )/
        (@sentStDevMod*@sentStDev)
		AS Sentiment -- if (BS.positives + BS.negatives == 0) returns 0
  FROM block_sentiment BS
       LEFT JOIN occurrence O
	          ON BS.document_id = O.document_id
 WHERE     O.entity_id = @entityId 
       AND O.[date] > DATEADD (DAY, -@days , @date)
       AND O.[date] <= @date
 GROUP BY O.[date]
 ORDER BY O.[date]







