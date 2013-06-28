/*REM*/ DECLARE @entity VARCHAR(max) = 'http://project-first.eu/ontology#cou_US'
/*REM*/ DECLARE @from DATE = '2013-05-01'
/*REM*/ DECLARE @to DATE = '2013-06-11'
--ADD DECLARE @entity VARCHAR(max) = {0}
--ADD DECLARE @from DATE = {1}
--ADD DECLARE @to DATE = {2}

--The actual select returned

SELECT O.[date] AS [Date],
       COUNT(DISTINCT O.document_id) AS Volume
  FROM entity E
       INNER JOIN occurrence O
               ON O.entity_id = E.id
 WHERE     E.entity_uri = @entity
       AND O.[date] >= @from
       AND O.[date] <= @to
 GROUP BY [date]
 ORDER BY [date]