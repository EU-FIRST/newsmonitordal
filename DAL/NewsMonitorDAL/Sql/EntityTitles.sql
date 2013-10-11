/*REM*/ DECLARE @entity VARCHAR(MAX) = 'http://project-first.eu/ontology#cou_SI'
/*REM*/ DECLARE @from DATE = '2012-08-23'
/*REM*/ DECLARE @to DATE = '2012-08-24'
/*REM*/ DECLARE @confidence INTEGER = 2
/*REM*/ DECLARE @isFinancial INTEGER = 0
--ADD DECLARE @entity VARCHAR(MAX) = {0}
--ADD DECLARE @from DATE = {1}
--ADD DECLARE @to DATE = {2}
--ADD DECLARE @confidence INTEGER = {3}
--ADD DECLARE @isFinancial INTEGER = {4}

--The actual select returned
SELECT title 
FROM document_entity_count dec
JOIN document d on d.id  = dec.document_id
WHERE 
	entity_id = (
		SELECT id 
		FROM entity 
		WHERE entity_uri = @entity )
	AND dec.date >= @from
	AND dec.date <= @to
	AND cnt >= @confidence
	AND (@isFinancial = 1 and d.is_financial = 1 or @isFinancial = 0)
	;