/*REM*/ DECLARE @uri VARCHAR(max) = 'http://project-first.eu/ontology#pos_mint'
/*REM*/ DECLARE @labelLike VARCHAR(max) = 'slovenia'
--ADD DECLARE @uri VARCHAR(MAX) = {0}
--ADD DECLARE @labelLike VARCHAR(MAX) = {1}

SELECT id           AS Id,
       entity_uri   AS EntityUri,
	   entity_label AS EntityLabel,
	   flags        AS Flags,
	   class_id     AS ClassId
  FROM entity
 WHERE                    1=0
       /*REM uri*/       OR entity_uri = @uri 
       /*REM labelLike*/ OR entity_label LIKE '%' + @labelLike + '%'