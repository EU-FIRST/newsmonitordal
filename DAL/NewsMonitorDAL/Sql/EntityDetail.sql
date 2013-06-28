/*REM*/ DECLARE @entity VARCHAR(MAX) = 'http://project-first.eu/ontology#comp_otc_ABCFF'
--ADD DECLARE @entity VARCHAR(MAX) = {0}

SELECT E.id                 AS Id,
       E.entity_uri         AS EntityUri,
	   E.entity_label       AS EntityLabel,
	   E.flags              AS Flags,
	   E.class_id           AS ClassId,
       CASE WHEN O.entity_id IS NULL THEN 0 ELSE Count(1) END
                            AS NumOccurrences,
       Count(DISTINCT D.id) AS NumDocuments,
       Min(D.date)          AS DataStartTime,
       Max(D.date)          AS DataEndTime,
       '{ class:{ label:"' + C.class_label + '",'+
       ' uri:"' + C.class_uri + '"} }' AS Features
  FROM entity E
       INNER JOIN class C
               ON C.id = E.class_id
       LEFT OUTER JOIN occurrence O
              ON O.entity_id = E.id
       LEFT OUTER JOIN document D
              ON D.id = O.document_id 
 WHERE E.entity_uri = @entity
 GROUP BY E.id,
          O.entity_id,
          E.entity_uri,  
          E.entity_label,
          E.flags,
          E.class_id,
          C.id,
          C.class_label,
          C.class_uri