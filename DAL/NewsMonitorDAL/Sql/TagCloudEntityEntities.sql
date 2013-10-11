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
                          Count(e2.entity_label)              Count, 
                          ( Isnull(c1.class_label, '') + ' ' 
                            + Isnull(c2.[class_label], '') + ' ' 
                            + Isnull(c3.[class_label], '') + ' ' 
                            + Isnull(c4.[class_label], '') + ' ' 
                            + Isnull(c5.[class_label], '') ) ClassPath 
FROM   document_entity_count dec 
       JOIN document_entity_count dec2 
         ON dec2.document_id = dec.document_id 
	   JOIN document d on d.id  = dec.document_id	   
       JOIN entity e1
		 ON dec.entity_id = e1.id
	   JOIN entity e2 
         ON dec2.entity_id = e2.id 	   
       JOIN class c1 
         ON c1.id = e2.class_id 
       LEFT JOIN class c2 
              ON c1.parent_class_id = c2.id 
       LEFT JOIN class c3 
              ON c2.parent_class_id = c3.id 
       LEFT JOIN class c4 
              ON c3.parent_class_id = c4.id 
       LEFT JOIN class c5 
              ON c4.parent_class_id = c5.id 
WHERE  e1.entity_uri = @entity 
       AND dec.date >= @from
	   AND dec.date <= @to
       AND dec.cnt >= @confidence
       AND dec2.cnt >= @confidence 
	   AND (@isFinancial = 1 and d.is_financial = 1 or @isFinancial = 0)
GROUP  BY e2.entity_label, 
          c1.class_label, 
          c2.class_label, 
          c3.class_label, 
          c4.class_label, 
          c5.class_label 
ORDER  BY Count DESC 