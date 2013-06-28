/*REM*/ DECLARE @uri VARCHAR(max) = 'http://project-first.eu/ontology#cou_US'
/*REM*/ DECLARE @labelLike VARCHAR(max) = 'slovenia'
--ADD DECLARE @uri VARCHAR(MAX) = {0}
--ADD DECLARE @labelLike VARCHAR(MAX) = {1}

SELECT E.id           AS Id,
       E.entity_uri   AS EntityUri,
	   E.entity_label AS EntityLabel,
	   E.flags        AS Flags,
	   E.class_id     AS ClassId,
       '{ class:{ label:"' + C.class_label + '",'+
       ' uri:"' + C.class_uri + '"} }' AS Features
  FROM entity E
       INNER JOIN class C
               ON C.id = E.class_id
 WHERE                    1=0
       /*REM uri*/       OR entity_uri = @uri 
       /*REM labelLike*/ OR entity_label LIKE '%' + @labelLike + '%'
       /*REM labelLike*/ OR entity_uri LIKE '%' + @labelLike + '%'