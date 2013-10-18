/*REM*/ DECLARE @entity VARCHAR(MAX) = 'http://project-first.eu/ontology#cou_SI'
/*REM*/ DECLARE @from DATE = '2012-08-23'
/*REM*/ DECLARE @to DATE = '2012-08-24'
/*REM*/ DECLARE @confidence INTEGER = 2
/*REM*/ DECLARE @maxNumTerms INTEGER = 100
/*REM*/ DECLARE @isFinancial INTEGER = 0
--ADD DECLARE @entity VARCHAR(MAX) = {0}
--ADD DECLARE @from DATE = {1}
--ADD DECLARE @to DATE = {2}
--ADD DECLARE @confidence INTEGER = {3}
--ADD DECLARE @maxNumTerms INTEGER = {4}
--ADD DECLARE @isFinancial INTEGER = {5}

--The actual select returned
SELECT TOP (@maxNumTerms) e2.entity_label Entity, 
                          sum(dec2.cnt)              Count
FROM   document_entity_count dec 
       JOIN document_entity_count dec2 
         ON dec2.document_id = dec.document_id 
	   JOIN document d on d.id  = dec.document_id	   
       JOIN entity e1
		 ON dec.entity_id = e1.id
	   JOIN entity e2 
         ON dec2.entity_id = e2.id 	          
WHERE  e1.entity_uri = @entity 
       AND dec.date >= @from
	   AND dec.date <= @to
       AND dec.cnt >= @confidence
       AND dec2.cnt >= @confidence 
	   AND (@isFinancial = 1 and d.is_financial = 1 or @isFinancial = 0)
GROUP  BY e2.entity_label       
ORDER  BY Count DESC 