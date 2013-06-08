/*REM*/ DECLARE @entityId int = 2085
/*REM*/ DECLARE @days int = 10
/*REM*/ DECLARE @date DATE = '2013-06-07'
--ADD DECLARE @entityId int = {0}
--ADD DECLARE @days int = {1}
--ADD DECLARE @date DATE = {2}

SELECT O.[date] AS [Date], 
       SUM(BS.positives - BS.negatives)/CAST(SUM(BS.positives + BS.negatives) AS FLOAT) AS Sentiment
  FROM block_sentiment BS
       LEFT JOIN occurrence O
	          ON BS.document_id = O.document_id
 WHERE     O.entity_id = @entityId 
       AND O.[date] > DATEADD (DAY, -@days , @date)
       AND O.[date] <= @date
 GROUP BY O.[date]
 ORDER BY O.[date]