/*REM*/ DECLARE @guid UNIQUEIDENTIFIER = '0FDA596E-7431-1F35-AA55-0C94DAC3BDBD'
--ADD DECLARE @guid UNIQUEIDENTIFIER = {0}

SELECT '\' +             CAST(DATEPART(YEAR,   time_get) AS VARCHAR(MAX)) +             
       '\' + RIGHT('0' + CAST(DATEPART(MONTH,  time_get) AS VARCHAR(MAX)), 2) +            
       '\' + RIGHT('0' + CAST(DATEPART(DAY,    time_get) AS VARCHAR(MAX)), 2) +              
       '\' + RIGHT('0' + CAST(DATEPART(HOUR,   time_get) AS VARCHAR(MAX)), 2) +             
       '_' + RIGHT('0' + CAST(DATEPART(MINUTE, time_get) AS VARCHAR(MAX)), 2) +           
       '_' + RIGHT('0' + CAST(DATEPART(SECOND, time_get) AS VARCHAR(MAX)), 2) +           
       '_' + LOWER(REPLACE(CAST(document_guid AS VARCHAR(MAX)),'-','')) + 
       '.xml.gz' AS FileName                                              
FROM document                                                             
WHERE document_guid = @guid                                               