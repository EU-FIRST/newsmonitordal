/*REM*/ DECLARE @entity VARCHAR(MAX) = 'http://project-first.eu/ontology#cou_US'
/*REM*/ DECLARE @from DATE = '2013-05-07'
/*REM*/ DECLARE @to DATE = '2013-06-07'
/*REM*/ DECLARE @normalize BIT = 1
--ADD DECLARE @entity VARCHAR(MAX) = {0}
--ADD DECLARE @from DATE = {1}
--ADD DECLARE @to DATE = {2}
--ADD DECLARE @normalize BIT = {3}

DECLARE @neutralZone FLOAT = 0.2

SELECT [Date]                                AS [Date],
       Positives                             AS Positives,
       PosNeutrals + Neutrals/2 + Neutrals%2 AS PosNeutrals, -- plus half+(1) of true neutrals
       NegNeutrals + Neutrals/2              AS NegNeutrals, -- plus half of true neutrals
       Negatives                             AS Negatives,
       Volume                                AS Volume
  FROM (SELECT Doc.[date]                                                                                       AS [Date],
               SUM(CASE WHEN                                   Doc.[Index] >= @neutralZone THEN 1 ELSE 0 END) AS Positives,
               SUM(CASE WHEN Doc.[Index] <   @neutralZone  AND Doc.[Index] >  0            THEN 1 ELSE 0 END) AS PosNeutrals,
               SUM(CASE WHEN Doc.[Index] =   0                                             THEN 1 ELSE 0 END) AS Neutrals, -- true neutrals
               SUM(CASE WHEN Doc.[Index] <   0             AND Doc.[Index] > -@neutralZone THEN 1 ELSE 0 END) AS NegNeutrals,
               SUM(CASE WHEN Doc.[Index] <= -@neutralZone                                  THEN 1 ELSE 0 END) AS Negatives,
               COUNT(1)                                                                                       AS Volume
          FROM (SELECT O.[date] AS [Date],
                       COALESCE( 
                            SUM(BS.positives - BS.negatives)/
                                CAST(NULLIF(SUM(BS.positives + BS.negatives), 0) AS FLOAT)
                            ,0
                       ) AS [Index]
                  FROM block_sentiment BS
                       LEFT JOIN occurrence O
                	          ON BS.document_id = O.document_id
                       INNER JOIN entity E
                              ON O.entity_id = E.id
			     WHERE     E.entity_uri = @entity
                       AND O.[date] >= @from
                       AND O.[date] <= @to
                 GROUP BY BS.document_id,
                          O.[date]
               ) Doc
         GROUP BY Doc.[date]
        ) AS DateAgg
  ORDER BY [date]