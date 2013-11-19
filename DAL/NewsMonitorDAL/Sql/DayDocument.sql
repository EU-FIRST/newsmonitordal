/*REM*/ DECLARE @entity VARCHAR(MAX) = 'http://project-first.eu/ontology#cou_US'
/*REM*/ DECLARE @from DATE = '2013-05-07'
/*REM*/ DECLARE @to DATE = '2013-05-08'
/*REM*/ DECLARE @normalize BIT = 0
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
					 COALESCE( 
        				SUM(BS.positives - BS.negatives)/
        					CAST(NULLIF(SUM(BS.positives + BS.negatives), 0) AS FLOAT)
        				,0
        			) AS [Index] -- if (BS.positives + BS.negatives == 0) returns 0
			  FROM document_sentiment BS
				   LEFT JOIN occurrence O
        				  ON BS.document_id = O.document_id
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
       D.time_get AS RetrieveTime,
	   D.domain_name AS DomainName,
	   D.response_url AS Url,
       D.document_guid AS DocumentId,
       COALESCE( 
            SUM(BS.positives - BS.negatives)/
                CAST(NULLIF(SUM(BS.positives + BS.negatives), 0) AS FLOAT)
				,0
        )/
        (@sentStDevMod*@sentStDev)
		AS [Index] -- if (BS.positives + BS.negatives == 0) returns 0
  FROM document_sentiment BS
       LEFT JOIN occurrence O
	          ON BS.document_id = O.document_id
       INNER JOIN entity E
              ON O.entity_id = E.id
       INNER JOIN document D
	          ON D.id = O.document_id
 WHERE     E.entity_uri = @entity
       AND O.[date] >= @from
       AND O.[date] <= @to
 GROUP BY O.[date], 
          D.document_guid, 
		  D.time_get,
	      D.domain_name,
	      D.response_url
 ORDER BY O.[date], D.time_get
