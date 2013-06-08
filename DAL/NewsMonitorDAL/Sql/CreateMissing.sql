USE TwitterMonitorStock
GO

CREATE TABLE Entity(
	Name varchar(255) NOT NULL,
	ResolutionMinutes int NOT NULL,
	WindowDays int NOT NULL,
	WindowCode varchar(1) NOT NULL,
	Granularity varchar(1) NOT NULL,
	TableId uniqueidentifier NOT NULL
)

CREATE NONCLUSTERED INDEX Entity_Name_WindowCode
    ON Entity (Name, WindowCode)
    INCLUDE (TableId)

CREATE NONCLUSTERED INDEX Clusters_TableId_WithData
    ON Clusters (TableId, Topic, StartTime, EndTime)
    INCLUDE (Id, NumDocs)
  
/*
-- not needed due to unique constraint  
CREATE NONCLUSTERED INDEX Terms_TableId_ClusterId
    ON Terms (TableId, ClusterId)

-- Suggested by query analizer to add data - ?not sure about that?
CREATE NONCLUSTERED INDEX Terms_ClusterId_WithData
    ON Terms (TableId, ClusterId)
    INCLUDE (StemHash, MostFrequentForm, TFIDF, [User], Hashtag, Stock, NGram)
*/





INSERT INTO Entity (Name, ResolutionMinutes, WindowDays, WindowCode, Granularity, TableId) VALUES
('MSFT', 30, 1, 'D', 'F', 'C4734EE4-03BD-8478-0B5D-B8C8189C3D23'),
('MSFT', 60, 1, 'D', 'F', 'A7BF5A9B-E1A7-2763-5AAE-25EF8C9220B9'),
('MSFT', 120, 1, 'D', 'F', '7DDABE99-152E-7F3B-85C3-71E8A4F2B04D'),
('MSFT', 240, 1, 'D', 'F', '33DD43C6-9906-983D-CEF9-CE686BFE5201'),
('MSFT', 30, 7, 'W', 'F', 'AB5F26CE-A07B-304E-531B-D3EC3D21F2E9'),
('MSFT', 60, 7, 'W', 'F', '9F1FE5B6-1025-676A-88E6-2796F14DDF8D'),
('MSFT', 120, 7, 'W', 'F', '8D5706B5-E253-5955-45EC-392552F3C163'),
('MSFT', 240, 7, 'W', 'F', '0EC98A49-8A6D-ECD7-D048-D3661E83604A'),
('MSFT', 30, 1, 'D', 'C', 'A8B13B03-ABBC-62C5-8E77-5D4388682B21'),
('MSFT', 60, 1, 'D', 'C', '291C8245-478E-C3B6-5F43-7BC3BC14CCE2'),
('MSFT', 120, 1, 'D', 'C', '9C260B70-7D2B-CF5B-5C58-A5BA63643ECD'),
('MSFT', 240, 1, 'D', 'C', '5FFFC1F6-EE03-E6D0-8664-E45A26C894AC'),
('MSFT', 30, 7, 'W', 'C', 'E2C1DDC2-6840-097F-5105-5E86C43B6A6C'),
('MSFT', 60, 7, 'W', 'C', '8FEABD5F-EA56-F3E6-EE93-6D808EB836F8'),
('MSFT', 120, 7, 'W', 'C', '1F5353A8-7921-E79A-8BC1-5804BA49DB1B'),
('MSFT', 240, 7, 'W', 'C', '05827A92-AC01-3A39-263C-1B31AE24B124'),
('JPM', 30, 1, 'D', 'F', 'DD7AB86D-3360-0EC7-C9EF-DFF505E63373'),
('JPM', 60, 1, 'D', 'F', '7A071AF9-222F-7EE2-CB10-3D9CE475D1F0'),
('JPM', 120, 1, 'D', 'F', 'E29EF7F0-0C89-086E-463A-B9CD92E16BE7'),
('JPM', 240, 1, 'D', 'F', 'BC4C3D1F-A630-26C2-10A1-15E87706678F'),
('JPM', 30, 7, 'W', 'F', '517EF0EC-BA12-F761-5835-94A17B1B8F6B'),
('JPM', 60, 7, 'W', 'F', '792795BE-3BC8-7388-F1DA-3A4884D18435'),
('JPM', 120, 7, 'W', 'F', '016649B6-9230-A56E-48DF-A89E12EC1294'),
('JPM', 240, 7, 'W', 'F', '08614C46-B99F-E2A1-9C01-7051CC9873A7'),
('JPM', 30, 1, 'D', 'C', '138A520E-0A1B-0073-83C3-10AD3747949F'),
('JPM', 60, 1, 'D', 'C', '4E2FEBEF-7FBE-66DB-F603-B9D64E7AA4C6'),
('JPM', 120, 1, 'D', 'C', '33AD9A8C-7CE7-CE78-B444-C3B091E57281'),
('JPM', 240, 1, 'D', 'C', '40A07F2A-30B4-5D19-48D7-19EFBDB28300'),
('JPM', 30, 7, 'W', 'C', 'A27F3124-24C2-474F-0D24-3A09747B2E10'),
('JPM', 60, 7, 'W', 'C', '0ECEAF2C-FA83-A883-23A7-86C2F1E57EA9'),
('JPM', 120, 7, 'W', 'C', 'EAC88931-9EB3-846E-DC27-1EB3E9FF25C0'),
('JPM', 240, 7, 'W', 'C', 'AB1E7753-1CF6-433B-D4A8-E168B3679D52'),
('BAC', 30, 1, 'D', 'F', '4557006B-11AD-4977-2D82-EDAA6E3D0FE8'),
('BAC', 60, 1, 'D', 'F', '4F5E50CA-219C-EE2C-5182-8C5EC1F3A6FB'),
('BAC', 120, 1, 'D', 'F', '3F828E55-6765-6E58-A38F-E9CE345798D0'),
('BAC', 240, 1, 'D', 'F', 'CF70C9BA-E46B-FB09-5BA2-7516BE9BFA49'),
('BAC', 30, 7, 'W', 'F', 'DEF8C500-70D3-46BE-6D73-590CE7B127AF'),
('BAC', 60, 7, 'W', 'F', 'D1387F9F-D9BF-B241-4B0E-48E517D74F8E'),
('BAC', 120, 7, 'W', 'F', 'E099C718-140F-2A79-ECA5-54E3622237C7'),
('BAC', 240, 7, 'W', 'F', '96166778-EBA6-C81A-8E2A-60094EDA47B9'),
('BAC', 30, 1, 'D', 'C', 'E2D628E0-CC34-A499-3736-8E208F26D93D'),
('BAC', 60, 1, 'D', 'C', '5664203C-5DD2-4988-26A5-72A8719AC198'),
('BAC', 120, 1, 'D', 'C', '2E7BFA99-8B42-8E51-81F9-BC0F5FE6A584'),
('BAC', 240, 1, 'D', 'C', '047C18A9-52D6-2737-A2D1-11B11513C51E'),
('BAC', 30, 7, 'W', 'C', '0F6DAF87-6836-DB72-57A0-9EA5556F1786'),
('BAC', 60, 7, 'W', 'C', '712452B3-5A50-9D65-0ECD-8CB18C9AFDA7'),
('BAC', 120, 7, 'W', 'C', 'A94B4669-C1D3-FC1D-7EF1-D0EE22BB36DB'),
('BAC', 240, 7, 'W', 'C', 'EDD6CFB0-FB65-3331-08FD-126A4022B641'),
('IBM', 30, 1, 'D', 'F', '9A135F9F-EF06-B9AD-BF47-4BBDCF833DE4'),
('IBM', 60, 1, 'D', 'F', '83432836-0C67-38F4-01B0-00B2BEFFE7C5'),
('IBM', 120, 1, 'D', 'F', 'F6E7818E-987D-3F01-830F-1C738D939419'),
('IBM', 240, 1, 'D', 'F', '8CE3CE65-C19B-6AAF-7D39-6B800C8675C0'),
('IBM', 30, 7, 'W', 'F', '3E76F85E-D890-461B-4502-E1A6E83690E8'),
('IBM', 60, 7, 'W', 'F', '1E55E2AC-E725-0051-D09B-9F33DB7D41C3'),
('IBM', 120, 7, 'W', 'F', '7331F3D4-77E1-6FEF-FA75-F779C4E2D14A'),
('IBM', 240, 7, 'W', 'F', '642F2CF4-E920-55DA-3981-780DBE6655BC'),
('IBM', 30, 1, 'D', 'C', '8A729B3F-D020-B5A1-07D9-0B8EE2A3FC8B'),
('IBM', 60, 1, 'D', 'C', 'AD7274F2-A458-1386-CFFD-962373216C49'),
('IBM', 120, 1, 'D', 'C', '834A3C97-4357-7835-788C-D6763D3CDBFB'),
('IBM', 240, 1, 'D', 'C', '53AD35F8-6660-7915-8C74-159F24DA7923'),
('IBM', 30, 7, 'W', 'C', 'F8739C87-4AB7-7377-0C7D-33D645358BA9'),
('IBM', 60, 7, 'W', 'C', '7A8D66CD-21D6-5DAA-A661-61D6DCE4B196'),
('IBM', 120, 7, 'W', 'C', '1705EA45-0BD4-8BA7-CB48-BDBB623B104A'),
('IBM', 240, 7, 'W', 'C', 'E61A50FF-885B-5B81-5DE4-940FB394CD7F'),
('INTC', 30, 1, 'D', 'F', '6B37705E-8728-3441-5406-01AB9760F00A'),
('INTC', 60, 1, 'D', 'F', 'CD1696D5-97C3-B9E2-F25C-CA0715402BEC'),
('INTC', 120, 1, 'D', 'F', 'A5B9717F-675B-7BA3-58E9-025887D8A6C4'),
('INTC', 240, 1, 'D', 'F', 'F5E49731-DC41-09DA-ADC8-0B6ED331F13E'),
('INTC', 30, 7, 'W', 'F', '9715A542-D584-F327-68C2-DD6A8FD5834B'),
('INTC', 60, 7, 'W', 'F', 'D0BDA40A-7711-9BEA-AB58-2C657CB430FD'),
('INTC', 120, 7, 'W', 'F', 'B1EA6D88-CF08-687D-1AB2-8C0F2EEDEC0D'),
('INTC', 240, 7, 'W', 'F', '89CAD5E3-7A97-A82F-740E-4F6FA9C2F592'),
('INTC', 30, 1, 'D', 'C', 'BDE51FBB-1710-7C17-FCEA-9AD15EB1DD27'),
('INTC', 60, 1, 'D', 'C', 'A2DC2488-1348-88CC-6CF4-4A802EEFA0F3'),
('INTC', 120, 1, 'D', 'C', '77B7AD33-9A87-221A-5ECA-56BEBDF9EE4B'),
('INTC', 240, 1, 'D', 'C', '1397F0A1-6C93-1D00-E21E-A427A606FFF3'),
('INTC', 30, 7, 'W', 'C', 'B80D5C4F-5356-1F71-F845-6D2C64C360B5'),
('INTC', 60, 7, 'W', 'C', '59C5F1BB-063B-0596-C95C-EE84B0EFECBC'),
('INTC', 120, 7, 'W', 'C', '08BE72C0-2081-6AB9-D45A-87C17598B3BF'),
('INTC', 240, 7, 'W', 'C', 'DDD04EA4-BFBB-6323-B02A-C0D262C79ED2'),
('HPQ', 30, 1, 'D', 'F', 'E5484A84-9A56-86E5-40C1-CE9CC0FC3597'),
('HPQ', 60, 1, 'D', 'F', 'BE09CCDA-2F97-4BAF-7AF6-11A8ED1AED69'),
('HPQ', 120, 1, 'D', 'F', '13BE3DF1-DA07-9836-2BFD-6F07BFD9FCB6'),
('HPQ', 240, 1, 'D', 'F', '2B82A15F-DD2C-D958-6BED-7546475724D7'),
('HPQ', 30, 7, 'W', 'F', 'E552A08B-FC12-AA3D-86F8-D4CA799AA0E2'),
('HPQ', 60, 7, 'W', 'F', '02FD2EA0-B63A-D43B-2323-BD7180632F03'),
('HPQ', 120, 7, 'W', 'F', '4AD77BE0-60E7-29D9-8BD1-2FB07F14137C'),
('HPQ', 240, 7, 'W', 'F', 'B106AD1F-0F0C-9389-1757-0611D562A40D'),
('HPQ', 30, 1, 'D', 'C', '24FD7693-01C6-E70B-5139-935D658012A8'),
('HPQ', 60, 1, 'D', 'C', '9A0CF1B8-01D2-C785-2972-7AE67631D82E'),
('HPQ', 120, 1, 'D', 'C', 'A07AF6E3-1263-4CDD-225F-55C163AD21C7'),
('HPQ', 240, 1, 'D', 'C', '17B0062E-3427-9122-2E15-2CE7F562BD98'),
('HPQ', 30, 7, 'W', 'C', '5A13A1AA-CE84-4EB5-2E9A-522E9A81B990'),
('HPQ', 60, 7, 'W', 'C', '4219B425-300D-9AAE-7E8A-CF1EA90B380D'),
('HPQ', 120, 7, 'W', 'C', '7C6800E0-3A42-FD4B-BC46-E87D92D9D561'),
('HPQ', 240, 7, 'W', 'C', 'FABDAC53-9AF3-C0D2-F540-C10B7827E154'),
('WMT', 30, 1, 'D', 'F', 'B1EC2F7D-9FD4-C9E4-05CB-AD63705B97F6'),
('WMT', 60, 1, 'D', 'F', '084162E9-0BE7-2783-C32C-3741D66B9278'),
('WMT', 120, 1, 'D', 'F', '58A1F7AA-778C-98D5-9A95-5154DD6F4BDF'),
('WMT', 240, 1, 'D', 'F', 'B6F6112A-0AD6-C896-380A-09A7407CA298'),
('WMT', 30, 7, 'W', 'F', '61B469F0-5A13-9A7D-DEDC-1F50F170F8BD'),
('WMT', 60, 7, 'W', 'F', '1EBAD121-8E60-44CC-537A-ED7835FBE9EB'),
('WMT', 120, 7, 'W', 'F', '6114D87C-0608-F2B9-993D-2495116195EF'),
('WMT', 240, 7, 'W', 'F', 'FF979BF0-48C1-A547-0CA4-92729DA05CE2'),
('WMT', 30, 1, 'D', 'C', '85B73C3D-4079-4698-B861-B833F9C45122'),
('WMT', 60, 1, 'D', 'C', '96CB458F-4C82-5DAD-CF59-D494A84D003A'),
('WMT', 120, 1, 'D', 'C', '81906D3D-29DF-24D7-041D-AB020CB04063'),
('WMT', 240, 1, 'D', 'C', '8282D816-630A-A028-8F3B-2A928F0FC942'),
('WMT', 30, 7, 'W', 'C', '23C2034D-AD4D-23F8-61F4-CC46C5B17420'),
('WMT', 60, 7, 'W', 'C', '9986C59A-AD63-2F04-E3B3-20E1FA2A0674'),
('WMT', 120, 7, 'W', 'C', 'E16683AB-B6CE-C6C8-1576-EBA5515149CE'),
('WMT', 240, 7, 'W', 'C', 'FE52CE0C-73AD-7562-A0E8-40A0DE6E2E1E'),
('BA', 30, 1, 'D', 'F', '06DF5D6A-8CDE-85AF-C6D0-6B301F4889AE'),
('BA', 60, 1, 'D', 'F', 'B5975EDF-6C4B-C659-2556-DD92C259EBED'),
('BA', 120, 1, 'D', 'F', '8DB70F65-AE25-9357-FD6F-4CEA8DAD49F6'),
('BA', 240, 1, 'D', 'F', '5E82C893-0DE3-FB21-F5AF-DAFA14F6CD88'),
('BA', 30, 7, 'W', 'F', 'B7B8DD79-2AF2-3F01-0EC7-BDE425F92C36'),
('BA', 60, 7, 'W', 'F', '6840D5F8-E9E3-790F-FCDD-C2B334C2D283'),
('BA', 120, 7, 'W', 'F', '94A1360E-7F69-57E9-BBB7-C6A54867F18A'),
('BA', 240, 7, 'W', 'F', '3B19A8FC-9B54-0181-F3B3-DDEE15FA84BC'),
('BA', 30, 1, 'D', 'C', 'B019BCFA-8034-7CED-CA14-1BECABD36CB0'),
('BA', 60, 1, 'D', 'C', '7A9F501E-1778-1878-61D9-DEA8B92F13F8'),
('BA', 120, 1, 'D', 'C', '7CF6E734-4CB7-7453-3378-8107218EAFEA'),
('BA', 240, 1, 'D', 'C', '8DA5DE0D-8375-4A74-56D6-E4E63716C1A8'),
('BA', 30, 7, 'W', 'C', '9C811913-7A78-431E-F23F-E1987CD8CE56'),
('BA', 60, 7, 'W', 'C', 'B61B1272-8F74-1CFC-5B0B-38D3B25C5961'),
('BA', 120, 7, 'W', 'C', 'E9D9A9FE-987F-F879-4575-46F1631ACC0C'),
('BA', 240, 7, 'W', 'C', 'F97A46E0-17A0-06B0-E6B8-0EBFD2A40F29'),
('CAT', 30, 1, 'D', 'F', 'C2AC9828-7D20-0C43-5F11-109AF7BF00F7'),
('CAT', 60, 1, 'D', 'F', '1228FC97-A60D-294A-7CAE-5B7DD4278DB2'),
('CAT', 120, 1, 'D', 'F', '80A40A53-9327-C312-D46D-EC3A182791AE'),
('CAT', 240, 1, 'D', 'F', 'D0BDEC68-F7F8-EC6A-A9C2-353F7BC07C3E'),
('CAT', 30, 7, 'W', 'F', '11DA8A7C-7F74-675B-CB93-66A05BD276C7'),
('CAT', 60, 7, 'W', 'F', 'FB20E9E1-A9E1-4475-1928-518530B5A390'),
('CAT', 120, 7, 'W', 'F', 'ED89416B-5A3D-6CD5-CACA-BF8075130FEA'),
('CAT', 240, 7, 'W', 'F', 'BCBED4F2-4D7C-A57A-ACA1-F2AED9D13A95'),
('CAT', 30, 1, 'D', 'C', '7663BF17-42F0-1AEE-EFD1-CE0E6A182B55'),
('CAT', 60, 1, 'D', 'C', '47C46721-6743-7BD4-6541-CDAC471BF919'),
('CAT', 120, 1, 'D', 'C', '2AB13651-68AE-335A-7EAF-1B3550FC3DB8'),
('CAT', 240, 1, 'D', 'C', 'CA83CAF3-36F4-BAE1-EB41-ACB495E87E70'),
('CAT', 30, 7, 'W', 'C', '20D5E164-A42D-99BD-C2BC-69E24DD0D5FC'),
('CAT', 60, 7, 'W', 'C', 'D13138A4-C2C5-1386-EE5D-8BCCACE93014'),
('CAT', 120, 7, 'W', 'C', '0AC67A95-D987-17FF-58F3-D66AC39C408A'),
('CAT', 240, 7, 'W', 'C', '618FD6E7-5B0F-101F-232F-DAC902477771'),
('CSCO', 30, 1, 'D', 'F', '14828228-4714-6FB9-BCD2-F2E46966DFBD'),
('CSCO', 60, 1, 'D', 'F', 'E64B2ED9-4608-3153-6248-176061E74574'),
('CSCO', 120, 1, 'D', 'F', 'E8315C8D-F796-2D4C-7FF3-02BA6A14C031'),
('CSCO', 240, 1, 'D', 'F', '91F11199-733D-1BC2-2154-353527552E29'),
('CSCO', 30, 7, 'W', 'F', 'A4059160-082E-03DE-FBD1-86D4720B80C2'),
('CSCO', 60, 7, 'W', 'F', 'D0D0A0B0-F5A6-0805-B3A3-62F00692D57A'),
('CSCO', 120, 7, 'W', 'F', 'B722AB36-09E9-A4E9-1440-22C59CF13526'),
('CSCO', 240, 7, 'W', 'F', 'BE954F0F-E749-27E0-591C-B44D8AAEB130'),
('CSCO', 30, 1, 'D', 'C', '60968B3F-5893-2FBF-6E90-0FA63563D7D6'),
('CSCO', 60, 1, 'D', 'C', '98AF7D69-5A56-9AB1-E572-3122C1BEC5E8'),
('CSCO', 120, 1, 'D', 'C', '31FD2BD8-54F1-F76A-7316-7E4C0C284CDA'),
('CSCO', 240, 1, 'D', 'C', 'F9CC21E3-FA45-6915-0A76-3DD933472287'),
('CSCO', 30, 7, 'W', 'C', '62589FC2-38D1-293E-B444-3DB84C4F5C76'),
('CSCO', 60, 7, 'W', 'C', 'EE2C5332-F71A-AAC4-81E1-328357792563'),
('CSCO', 120, 7, 'W', 'C', '29BAED78-828B-E27C-9B64-C3D8BD004DBE'),
('CSCO', 240, 7, 'W', 'C', 'D60A8EA3-3366-EA46-6232-8C05F9D6D1CE'),
('MCD', 30, 1, 'D', 'F', '156CAE8B-BE78-E7E3-B5A7-85858B50BE03'),
('MCD', 60, 1, 'D', 'F', 'E61B3091-3680-CE65-31FB-60D78703E8ED'),
('MCD', 120, 1, 'D', 'F', '03C26FAD-4D15-3435-1818-CC4AB16BC5F3'),
('MCD', 240, 1, 'D', 'F', '0AC2DC46-1EDE-8834-2F06-8EC2D72B9224'),
('MCD', 30, 7, 'W', 'F', '0C9183A1-1652-26A9-5AB1-AF4C8AFF0422'),
('MCD', 60, 7, 'W', 'F', 'EDBC08FB-A380-118B-4C95-24A10C0CB197'),
('MCD', 120, 7, 'W', 'F', 'DE2D372D-026D-93EF-90BE-6FF8E6C8F8A5'),
('MCD', 240, 7, 'W', 'F', '19A524F8-A691-1FAA-6AAB-7BF44C54AABD'),
('MCD', 30, 1, 'D', 'C', '64B7991F-4397-C3D3-F655-D3FDA92FABDB'),
('MCD', 60, 1, 'D', 'C', '433B0FFA-F4AC-E7BB-430E-D2101C512E85'),
('MCD', 120, 1, 'D', 'C', 'A109FB72-F930-8DD0-54EB-58D5F4AB710C'),
('MCD', 240, 1, 'D', 'C', 'F691D93E-E790-6AA8-2A38-868B64D040FB'),
('MCD', 30, 7, 'W', 'C', '4D4D6BB8-34AE-FC9D-5BF9-51FC6B7E086D'),
('MCD', 60, 7, 'W', 'C', '74077B37-7BF9-C941-6F4D-78FCE2650FDC'),
('MCD', 120, 7, 'W', 'C', 'FF89E2C2-C67A-34B5-F726-F32784813543'),
('MCD', 240, 7, 'W', 'C', 'C2E2BFDF-3F4A-49DE-F9FE-2662B2B818C6'),
('T', 30, 1, 'D', 'F', '05A69FBC-68FB-A0B3-6A74-BB16B63C3AF4'),
('T', 60, 1, 'D', 'F', '2726A510-1FC2-BB72-2A61-7C5E9D7777EB'),
('T', 120, 1, 'D', 'F', '706D92D1-841D-46C1-4AC6-C0049B85310C'),
('T', 240, 1, 'D', 'F', 'B8B9DB8E-6ED8-BA0B-A860-6DC81582E38B'),
('T', 30, 7, 'W', 'F', '4718D296-D387-4363-E9DB-BD868405445A'),
('T', 60, 7, 'W', 'F', 'DE017CB7-A42C-BB48-1614-9EB7508F903D'),
('T', 120, 7, 'W', 'F', '44B6EE86-924C-2D8E-9571-21CFFDF73AF5'),
('T', 240, 7, 'W', 'F', 'A5EC3225-ECEC-ADBA-E20A-D7C082192E29'),
('T', 30, 1, 'D', 'C', 'EF798444-68C4-05D5-63E4-DB4A39D5B7CB'),
('T', 60, 1, 'D', 'C', '209CB133-3254-68A7-8D6B-64293DCBA902'),
('T', 120, 1, 'D', 'C', 'BE67D522-F9DE-E6CB-4286-8926D8B5828A'),
('T', 240, 1, 'D', 'C', 'E04CD68C-9088-3C48-6A7D-99DEA95F457A'),
('T', 30, 7, 'W', 'C', 'F0090DD4-CCE2-EAB3-986B-DB0C9DBD21F9'),
('T', 60, 7, 'W', 'C', 'B5C77EDF-8479-47A8-6742-00423C4E9B61'),
('T', 120, 7, 'W', 'C', '152A9BC5-DD39-F91B-6AC4-04A647C44D9E'),
('T', 240, 7, 'W', 'C', '29352FEE-F340-BEF8-D243-62CDABC6DE1B'),
('JNJ', 30, 1, 'D', 'F', '6D11E166-1096-35AD-704B-00AB20180F5E'),
('JNJ', 60, 1, 'D', 'F', '0C183C36-72A6-4A9B-C042-8AE35660A728'),
('JNJ', 120, 1, 'D', 'F', 'E394CAF6-163E-59ED-4253-E67850E26CDD'),
('JNJ', 240, 1, 'D', 'F', 'A098AA2F-77F1-1A61-EF3A-971D0EC88B98'),
('JNJ', 30, 7, 'W', 'F', 'D9221B4C-5741-ECF1-5EEE-B7A9A63E839D'),
('JNJ', 60, 7, 'W', 'F', '366E3814-FB16-D647-6350-69CD159A1D1D'),
('JNJ', 120, 7, 'W', 'F', '584C8251-DEA2-C94A-8BE3-B6A837A260D8'),
('JNJ', 240, 7, 'W', 'F', '0C65FA66-16E5-DB1A-3CC4-6BB0A77FDC6F'),
('JNJ', 30, 1, 'D', 'C', '09A32744-B90B-31A0-105A-34CDB4C24425'),
('JNJ', 60, 1, 'D', 'C', 'AF11C4E3-2D12-9B61-6799-1409BFBB0083'),
('JNJ', 120, 1, 'D', 'C', '2D9789BC-58BE-8645-5E9E-1AA518542687'),
('JNJ', 240, 1, 'D', 'C', 'D1535F5E-E2AD-9931-277A-F3E7E406440F'),
('JNJ', 30, 7, 'W', 'C', 'E2BADD6F-B169-535D-7353-00721920ABA4'),
('JNJ', 60, 7, 'W', 'C', '63A00A5F-6520-D48F-8913-D886B94E0DCE'),
('JNJ', 120, 7, 'W', 'C', '2CB4D8C6-4DE3-7767-31CD-9F21545A1B34'),
('JNJ', 240, 7, 'W', 'C', 'F93E04B7-6D8F-8E91-AB16-044CB1E8C532'),
('XOM', 30, 1, 'D', 'F', '76B4622E-8A68-69BB-EEED-EBFE8DC31566'),
('XOM', 60, 1, 'D', 'F', 'F761C0C4-8F59-DB55-934D-4DE931331808'),
('XOM', 120, 1, 'D', 'F', '8B8C29DE-F2BF-5263-E0FF-AE56DAAB0CB2'),
('XOM', 240, 1, 'D', 'F', 'E0E2E403-F035-0F59-5E8D-A66480ABCB0B'),
('XOM', 30, 7, 'W', 'F', '2CE04B88-3152-D384-D87F-D51D8DD8B609'),
('XOM', 60, 7, 'W', 'F', '257CA00C-7173-A8D3-B449-43A72E8BDE71'),
('XOM', 120, 7, 'W', 'F', '5C9E5550-641A-3B7B-45B6-99300F79CBE6'),
('XOM', 240, 7, 'W', 'F', '4A7E1A73-76EE-3A1F-A544-6ABC7661C229'),
('XOM', 30, 1, 'D', 'C', '7B369C0E-48A7-D258-1E5C-01CEF6937CFD'),
('XOM', 60, 1, 'D', 'C', '284C66C9-DFCF-E9B2-DC50-79035ACB807E'),
('XOM', 120, 1, 'D', 'C', 'F668EE12-8068-7D32-F707-904BC04C9666'),
('XOM', 240, 1, 'D', 'C', 'FB5611ED-1232-6596-0345-D713E4561B48'),
('XOM', 30, 7, 'W', 'C', 'CDF5DFBD-78A2-FD47-23C5-923DC1CBD041'),
('XOM', 60, 7, 'W', 'C', '8E4B952D-9558-BC63-B8E1-DC77AEDBC5AE'),
('XOM', 120, 7, 'W', 'C', 'CE4338F1-83D0-4FD5-A25C-4F2BF81E4119'),
('XOM', 240, 7, 'W', 'C', '57D8CE95-C2B7-2D2D-D4E5-67CCFB09C54E'),
('DIS', 30, 1, 'D', 'F', '53AFB37C-C868-8411-0453-C5138FB6DA71'),
('DIS', 60, 1, 'D', 'F', '3EA74228-D471-F0DE-C3A4-C1B5AE196DCF'),
('DIS', 120, 1, 'D', 'F', 'E278C69F-559D-D499-C60A-36DF2A58D232'),
('DIS', 240, 1, 'D', 'F', '1DB80724-D583-7543-CA46-D25C9CA468FF'),
('DIS', 30, 7, 'W', 'F', '03EA97A6-FED2-9ED1-4D34-32A70E3B5657'),
('DIS', 60, 7, 'W', 'F', 'FF273C6E-FD32-6721-78BD-F4BCA88170C0'),
('DIS', 120, 7, 'W', 'F', '19B71F4D-26C4-0F15-C124-F434AF612C17'),
('DIS', 240, 7, 'W', 'F', 'CEE74EF9-08CA-4E1F-4321-E572EF92B862'),
('DIS', 30, 1, 'D', 'C', 'DA8F621B-99C2-4A44-0C93-8FB78C09FE9D'),
('DIS', 60, 1, 'D', 'C', '0DF93088-5DE2-93FC-4EF4-A4FD17DE4A0C'),
('DIS', 120, 1, 'D', 'C', 'F1D3E3FA-C54D-B0A7-C1FA-4356157BFC71'),
('DIS', 240, 1, 'D', 'C', '0E9307C4-A6AE-40CD-6539-83EDA0E9FC34'),
('DIS', 30, 7, 'W', 'C', '37AA8B89-59FE-6EE1-A786-DD89E7249FD5'),
('DIS', 60, 7, 'W', 'C', '8E6C62B5-A624-8D79-D9F3-5EE1B259EDBB'),
('DIS', 120, 7, 'W', 'C', 'C3F8AB46-EDB8-07A4-924E-11091DF6BFFB'),
('DIS', 240, 7, 'W', 'C', '8BD2DA37-DADF-A7AD-4FC0-8E479A33AED4'),
('GE', 30, 1, 'D', 'F', '9777CABF-CF27-89C9-3971-04E054388576'),
('GE', 60, 1, 'D', 'F', '1B98E160-1A10-EF3F-2000-4AE587BE6CB2'),
('GE', 120, 1, 'D', 'F', 'FC643B00-2965-1A74-1FDB-5C2069669715'),
('GE', 240, 1, 'D', 'F', 'B28F524B-EA00-1CAF-3807-D1F18D47CEF1'),
('GE', 30, 7, 'W', 'F', '125ACE2D-ED7E-F1C7-7E74-7BC722049AB7'),
('GE', 60, 7, 'W', 'F', 'AA29C815-A8E0-831C-7244-61705326598B'),
('GE', 120, 7, 'W', 'F', '9C4C86E8-5C95-5CAE-418E-EB1AC7FF65A2'),
('GE', 240, 7, 'W', 'F', 'F43F3C49-AEF7-A98C-3A70-CD5E85D0686C'),
('GE', 30, 1, 'D', 'C', '64F0ACD1-9034-F5C9-EE1E-8F8354825BA1'),
('GE', 60, 1, 'D', 'C', '8D25CF0A-454A-C30C-49E4-2E82E08D697A'),
('GE', 120, 1, 'D', 'C', '392E436F-4FB7-6329-FBAB-F4B1BAC14891'),
('GE', 240, 1, 'D', 'C', '337C0207-D5B4-F0AD-236F-C0BED06E9F94'),
('GE', 30, 7, 'W', 'C', '6E68E982-18F8-62FF-C4B4-3FE6C0A1EA8F'),
('GE', 60, 7, 'W', 'C', '9C77D0BE-8748-C599-16F2-FB3D23D4CA81'),
('GE', 120, 7, 'W', 'C', '2A8663E9-5DF1-497B-427A-78ADFAC627AE'),
('GE', 240, 7, 'W', 'C', 'A7E37F15-EC33-522A-D756-ACDDD2DE6BE1'),
('VZ', 30, 1, 'D', 'F', '91ADC93A-0AE8-403A-C123-DD6465660821'),
('VZ', 60, 1, 'D', 'F', '6255F488-0752-FFE9-C9EC-124FE3AC3100'),
('VZ', 120, 1, 'D', 'F', 'E9A94C1F-F63B-7722-4B77-168846E6FF5C'),
('VZ', 240, 1, 'D', 'F', '7721E88C-C27A-9026-47F2-A611D801401C'),
('VZ', 30, 7, 'W', 'F', '99D79530-FD28-16AB-F52A-93BEFA250956'),
('VZ', 60, 7, 'W', 'F', 'A3165BC1-97C3-8E83-BE20-2748DC187E57'),
('VZ', 120, 7, 'W', 'F', '8FB944A8-F312-7CE1-C07B-19750F51F1C0'),
('VZ', 240, 7, 'W', 'F', '9D66FAE6-9823-E91E-D8D0-625B0D9B5B00'),
('VZ', 30, 1, 'D', 'C', '85944312-2862-19BC-40B2-BE2AEBB78CA3'),
('VZ', 60, 1, 'D', 'C', '009194FD-396C-EECD-A87A-972600A07577'),
('VZ', 120, 1, 'D', 'C', 'E2141E1A-6222-453F-2886-F94A4EC13C25'),
('VZ', 240, 1, 'D', 'C', '449354D0-F3C9-C74A-08F8-02D60FDB1B65'),
('VZ', 30, 7, 'W', 'C', '2FB084B0-6D94-6D99-E026-54F0DFCD824C'),
('VZ', 60, 7, 'W', 'C', 'EE5B8BF4-9D44-DEEF-96BF-95A8366DDA53'),
('VZ', 120, 7, 'W', 'C', '8B9961CC-2703-D9CA-1A03-FC55D05126CB'),
('VZ', 240, 7, 'W', 'C', '935C3466-FC06-3EC7-C2B4-032F9C27F771'),
('PFE', 30, 1, 'D', 'F', 'B242E183-0565-CEAA-7863-8D1B1CA8AF87'),
('PFE', 60, 1, 'D', 'F', '2D7EABE9-FF2D-3B43-2FEA-36AE52EC5D0C'),
('PFE', 120, 1, 'D', 'F', '5CD25A05-7A04-C864-ADD9-A868093A3215'),
('PFE', 240, 1, 'D', 'F', 'D894E515-B758-31C9-3F31-638E234C1EF8'),
('PFE', 30, 7, 'W', 'F', '9F884B2E-8235-5FF0-07BD-5C659FA0806F'),
('PFE', 60, 7, 'W', 'F', '60CC8D8A-A23B-13ED-4CEB-A743B34243D7'),
('PFE', 120, 7, 'W', 'F', '007A9C8E-B60F-411C-605E-F42EA2F76A9E'),
('PFE', 240, 7, 'W', 'F', 'A5B3C664-A397-DAC5-1DF3-CB9DCE97F261'),
('PFE', 30, 1, 'D', 'C', 'BCB7FAED-4E1C-3D99-27E6-00DF62EA6657'),
('PFE', 60, 1, 'D', 'C', 'B141B4D6-118F-4921-36E8-06F29D4CE784'),
('PFE', 120, 1, 'D', 'C', '53F54DD8-94C9-BCF5-E133-ABE1186F039B'),
('PFE', 240, 1, 'D', 'C', '52AAB1EF-F716-E873-3701-5A2D432794CC'),
('PFE', 30, 7, 'W', 'C', '157EDB8F-F54D-110F-FD6B-FC5B7FD61C37'),
('PFE', 60, 7, 'W', 'C', '38269F83-FF25-8F63-27FB-C8D8B98F08D5'),
('PFE', 120, 7, 'W', 'C', '95815C7B-C07E-1607-F69B-2D96E0194117'),
('PFE', 240, 7, 'W', 'C', 'CE7FD83D-33C2-E375-3E38-9B0D8B5653DE'),
('KO', 30, 1, 'D', 'F', 'ECF4FB18-1A67-0ED8-6158-6DB4CF635725'),
('KO', 60, 1, 'D', 'F', '8660DB6F-2297-35F0-CA65-10A9DE22574E'),
('KO', 120, 1, 'D', 'F', '0102CD68-40C2-1459-2F27-D825975CD773'),
('KO', 240, 1, 'D', 'F', '58F897F7-E9C0-3651-2522-88B8BEF2B5BD'),
('KO', 30, 7, 'W', 'F', '2817CF4F-4BFE-FDD3-9AB8-6B57A258AD6F'),
('KO', 60, 7, 'W', 'F', '894C4F20-CEBB-09D7-1B16-BC3E630186E2'),
('KO', 120, 7, 'W', 'F', 'BA3A6FD0-BBCE-472E-5858-C8D759930F0F'),
('KO', 240, 7, 'W', 'F', 'ECDF14C3-FE6E-3E3A-5DC7-7EF501FC97A7'),
('KO', 30, 1, 'D', 'C', '44D5ED6E-B12B-1E24-E7AD-8C9D7193704A'),
('KO', 60, 1, 'D', 'C', 'BFD81CC1-6301-49A5-1530-3EBF097E4CA8'),
('KO', 120, 1, 'D', 'C', '2C4B32EE-B534-BB81-1A86-40581108025A'),
('KO', 240, 1, 'D', 'C', 'A7048066-7C8B-B9F9-7AD7-D4F1808BE6FA'),
('KO', 30, 7, 'W', 'C', 'A63D03B2-ED49-DB49-DE79-1E4F1CA69F17'),
('KO', 60, 7, 'W', 'C', '0C39220A-18BF-9EA7-7111-BC435001A2BF'),
('KO', 120, 7, 'W', 'C', 'BD9D2775-0FE8-C4A0-8F06-E7FAB2C9979D'),
('KO', 240, 7, 'W', 'C', '94B94E31-3721-3EF7-78FB-BAD270F929B1'),
('AA', 30, 1, 'D', 'F', 'F9E8B292-A3AD-B00E-D9FF-04D2A09DE00A'),
('AA', 60, 1, 'D', 'F', 'BD7A1727-3187-8993-1DE8-64C6EEC1841D'),
('AA', 120, 1, 'D', 'F', '0C14F328-CCAE-BEA1-C94A-613502F9CF1C'),
('AA', 240, 1, 'D', 'F', '9D416D06-A790-2362-9BB3-8F14CE8EAAFE'),
('AA', 30, 7, 'W', 'F', '06093494-4B13-422C-B431-661C4E7CD025'),
('AA', 60, 7, 'W', 'F', '8196DD67-CDFE-29E9-F5CD-10EFE35FD4D9'),
('AA', 120, 7, 'W', 'F', '580F775A-5A8A-2F79-4B9A-70C007E1C921'),
('AA', 240, 7, 'W', 'F', '534AC982-B8CF-3614-355E-FBE39B6491F3'),
('AA', 30, 1, 'D', 'C', 'D3DBE57E-4D41-C308-6B0A-313C37434C40'),
('AA', 60, 1, 'D', 'C', '457E3A2E-D61D-0755-730A-C99706B00BC8'),
('AA', 120, 1, 'D', 'C', 'B0C6AFB7-289F-FB90-779F-B394F1295A2D'),
('AA', 240, 1, 'D', 'C', '1142C778-8638-8454-C59A-39DE5C99316D'),
('AA', 30, 7, 'W', 'C', '7241B212-0E9F-926B-C18B-C4CA0F3C208C'),
('AA', 60, 7, 'W', 'C', '63CB2560-C70D-B788-78CF-430C0C6B2A00'),
('AA', 120, 7, 'W', 'C', '86446C10-0FD3-2D6A-F1F0-D54976FBF654'),
('AA', 240, 7, 'W', 'C', '7AE218EA-57A5-FADE-E0E8-B57F0C6995B0'),
('PG', 30, 1, 'D', 'F', '8F76E97D-0767-22D8-A593-35F15F043B97'),
('PG', 60, 1, 'D', 'F', 'C8DB8E27-2A01-8C14-8959-BE38FA07F827'),
('PG', 120, 1, 'D', 'F', 'CF6A6B49-654A-2023-8B48-F0C7B3302790'),
('PG', 240, 1, 'D', 'F', 'AA272FCA-9AB1-C87A-3ABC-562678EC1DC5'),
('PG', 30, 7, 'W', 'F', '93C8A6BC-DD23-1D5F-E1A9-C0A4226D2D68'),
('PG', 60, 7, 'W', 'F', '6FB699B3-791A-F76D-FB89-197B8C60DBF1'),
('PG', 120, 7, 'W', 'F', '96E5B35B-7102-1294-6717-326869207526'),
('PG', 240, 7, 'W', 'F', '5F77D001-021E-376D-802E-42ACEF9D082F'),
('PG', 30, 1, 'D', 'C', '6CF5864D-6F80-8A86-A959-458F21AC2163'),
('PG', 60, 1, 'D', 'C', 'AC58668C-5F9A-915D-A295-817748FEA7EC'),
('PG', 120, 1, 'D', 'C', 'F6D2F39C-A565-31AF-47F2-82FEA8ED124E'),
('PG', 240, 1, 'D', 'C', '27DB9883-6DAE-CCCA-767D-8DF252E5B57A'),
('PG', 30, 7, 'W', 'C', 'A4165965-671C-7B31-72E0-429B54168983'),
('PG', 60, 7, 'W', 'C', '28C9AE2B-3595-2C31-29CB-59FDD2C62104'),
('PG', 120, 7, 'W', 'C', '7263082D-DFFC-8D06-768C-16388596F61A'),
('PG', 240, 7, 'W', 'C', '529CFFAC-8286-A093-62CF-90AC42CE7642'),
('HD', 30, 1, 'D', 'F', 'A9064E4C-EF50-7A53-5605-83DDDF5EF66B'),
('HD', 60, 1, 'D', 'F', 'AEDDB65A-E6F7-4DA1-C0DA-A504FE4768CE'),
('HD', 120, 1, 'D', 'F', '3CBBB3E6-C3DD-DD47-FC5D-286426C6F7EE'),
('HD', 240, 1, 'D', 'F', 'DE9995D4-8570-67FB-21F5-22078EB29D34'),
('HD', 30, 7, 'W', 'F', 'AF7D3E4F-B199-FB3B-3C03-F9807D6183C3'),
('HD', 60, 7, 'W', 'F', '20E17D6D-197E-4F4B-1351-D0D3C2789BED'),
('HD', 120, 7, 'W', 'F', '02CF48AE-E92B-9FEB-F7C1-7F3BB0FE6F8D'),
('HD', 240, 7, 'W', 'F', 'FDF99E8A-1AE8-9857-6DDE-8149A944FBD2'),
('HD', 30, 1, 'D', 'C', 'D7579B58-F2DE-1750-0E18-597E7EA222D2'),
('HD', 60, 1, 'D', 'C', 'FD9D59E9-E014-2D75-C179-3D833522FD5B'),
('HD', 120, 1, 'D', 'C', 'BF60E549-7CB4-EB56-EBA6-FBA7E3893843'),
('HD', 240, 1, 'D', 'C', 'D32A4447-F2FE-423E-2F8A-FE8B96821E9C'),
('HD', 30, 7, 'W', 'C', 'CC27FC6D-80E6-9D27-FE31-5108518FA1D5'),
('HD', 60, 7, 'W', 'C', '10EF932B-B844-5934-8C4C-AC032B7E6B95'),
('HD', 120, 7, 'W', 'C', '6488B7DF-B3DD-A8AA-3366-01DBCE71FBF9'),
('HD', 240, 7, 'W', 'C', '6CBD1278-D948-8323-9465-36C1CE6C9EA1'),
('MRK', 30, 1, 'D', 'F', 'B00B8B08-B20F-F40D-29E7-725F1FBE3820'),
('MRK', 60, 1, 'D', 'F', '5BB38352-4F52-AD3B-3EE3-E09054DA8DEB'),
('MRK', 120, 1, 'D', 'F', 'FECA890A-85FC-441E-274E-AB915A9FF1C8'),
('MRK', 240, 1, 'D', 'F', '2486CFE0-07E1-E0AE-884B-492D76C99940'),
('MRK', 30, 7, 'W', 'F', '9A84891B-AC0F-5638-792E-7A1158B7C2A6'),
('MRK', 60, 7, 'W', 'F', '76EF7465-274E-08CA-CCB4-D07C6C0D4C5E'),
('MRK', 120, 7, 'W', 'F', 'CCDC5AFC-FAB6-3BD0-0DCB-052308FD64F2'),
('MRK', 240, 7, 'W', 'F', '8F4EC509-B9F6-7389-F6C5-2A835EC5A106'),
('MRK', 30, 1, 'D', 'C', '7AA79EB4-9F74-7DBD-C7C5-1033F2FCC71A'),
('MRK', 60, 1, 'D', 'C', 'C871FAFB-F2C8-471E-82BE-DDBE8D821440'),
('MRK', 120, 1, 'D', 'C', '910E6B27-CB20-9EC7-7653-F2CFF4726870'),
('MRK', 240, 1, 'D', 'C', 'C539B8B0-63E0-4AF1-890A-B93AB4F6D81B'),
('MRK', 30, 7, 'W', 'C', '22B9DED8-8F28-D9F1-4312-BA755B675FC3'),
('MRK', 60, 7, 'W', 'C', '72738608-F444-07C1-EC6C-5370049628B0'),
('MRK', 120, 7, 'W', 'C', '7F1E938C-D66A-DC99-D140-5BA45BACE97D'),
('MRK', 240, 7, 'W', 'C', 'C305A414-2901-C64E-67A5-589555A48FBD'),
('CVX', 30, 1, 'D', 'F', '954ECEA6-2F63-1FBF-F342-8DE197B1D730'),
('CVX', 60, 1, 'D', 'F', 'D5A64FB7-170E-D423-C415-EA6E972E4F38'),
('CVX', 120, 1, 'D', 'F', '1DEA9B8C-90A5-1C42-00A5-C4F12AF2F42B'),
('CVX', 240, 1, 'D', 'F', 'F53FFA9A-55D3-D881-D47F-386F743300E3'),
('CVX', 30, 7, 'W', 'F', 'B3880302-E7C5-750D-4332-12186D8E8F38'),
('CVX', 60, 7, 'W', 'F', '1CF98B68-FB63-CD6D-6175-CB89CAD9533B'),
('CVX', 120, 7, 'W', 'F', 'E08102CC-AD4F-0469-6FB9-A19E6A5CEE24'),
('CVX', 240, 7, 'W', 'F', '911F7BB6-DD4E-133B-BD5B-C79C501E792C'),
('CVX', 30, 1, 'D', 'C', '414F22E5-5D98-7B01-C0E7-F239E1E9DA00'),
('CVX', 60, 1, 'D', 'C', '12DD390E-F27F-1BAC-84B9-3E2C8422F130'),
('CVX', 120, 1, 'D', 'C', '9B50B48B-E94C-CC9A-6883-C0ADF886D37C'),
('CVX', 240, 1, 'D', 'C', 'F78575B8-81C1-0C6C-8A31-1F234CE7FCB5'),
('CVX', 30, 7, 'W', 'C', '8089C57F-962E-E3B7-36CF-051AFF717CD1'),
('CVX', 60, 7, 'W', 'C', '2EB96CD8-6275-D4C6-C241-B380FF434C34'),
('CVX', 120, 7, 'W', 'C', '6A45CB95-AECD-31C6-1BD8-91DD657A7377'),
('CVX', 240, 7, 'W', 'C', '4B59C746-68D2-35C1-9263-84A32D0506DD'),
('AXP', 30, 1, 'D', 'F', '14E2F104-36E5-65B1-170D-FE9E4AB38E37'),
('AXP', 60, 1, 'D', 'F', '84A966A5-C1BA-754E-656D-E80D6842B71D'),
('AXP', 120, 1, 'D', 'F', '0BF8F4BD-95CB-D9C0-C865-94242AA71978'),
('AXP', 240, 1, 'D', 'F', '4F26E5BD-05B1-CEC0-02C5-6E85749FA361'),
('AXP', 30, 7, 'W', 'F', 'A854D90A-C08A-0B86-4E55-A88D13A5B277'),
('AXP', 60, 7, 'W', 'F', '4809A365-9B7B-891C-5E7E-58FE8310E5DE'),
('AXP', 120, 7, 'W', 'F', '74B74FA7-9634-EBB8-C938-8514E4957110'),
('AXP', 240, 7, 'W', 'F', 'A3B86F1C-86CE-063E-4683-A3539F23A5FE'),
('AXP', 30, 1, 'D', 'C', '5AD143D1-5A7E-B5C2-FE77-FD7768CD46A7'),
('AXP', 60, 1, 'D', 'C', '7B140B8B-5AD2-CF74-6440-B84FE3C11A73'),
('AXP', 120, 1, 'D', 'C', 'F0CC1DE8-5143-1AB5-1A46-E1589EFF43E8'),
('AXP', 240, 1, 'D', 'C', '247B1321-456E-EE78-8490-4BE2A60E85FC'),
('AXP', 30, 7, 'W', 'C', '09BDBF75-7C45-74DE-F6CD-F39CB4C26B16'),
('AXP', 60, 7, 'W', 'C', 'E462CBAE-E73E-09B4-1E13-B216B7FCF792'),
('AXP', 120, 7, 'W', 'C', '486B1D07-B478-FEDF-6282-828B21A71D77'),
('AXP', 240, 7, 'W', 'C', 'BAB8C0A0-8742-984B-A81D-5D03550B649C'),
('MMM', 30, 1, 'D', 'F', '9294B54D-E94A-71A9-06C2-1D4406D758D5'),
('MMM', 60, 1, 'D', 'F', 'C2F87B3D-E880-2F33-96D1-D2BE33D8FB1B'),
('MMM', 120, 1, 'D', 'F', '6C784353-851D-3E1E-5C3A-20697A0B16FB'),
('MMM', 240, 1, 'D', 'F', '6449CC73-4339-A2C3-CD23-26521B44D474'),
('MMM', 30, 7, 'W', 'F', '8E7035DF-2B89-A706-82E3-4051575DAC4F'),
('MMM', 60, 7, 'W', 'F', 'C502A6EF-AA0F-2C09-CAFA-73B5C4272DF1'),
('MMM', 120, 7, 'W', 'F', 'EB555A59-FD57-7936-FEEF-B10DEFA6317A'),
('MMM', 240, 7, 'W', 'F', 'BC1CA750-A0CE-5816-B804-39EB3947AD45'),
('MMM', 30, 1, 'D', 'C', '7DD73C57-0454-668A-BD29-135365EC0A4E'),
('MMM', 60, 1, 'D', 'C', 'AD3154E7-7C85-B6A2-3DE1-B508D5E317AA'),
('MMM', 120, 1, 'D', 'C', '6B907F3F-9147-5713-36D3-B0E6775FA8CF'),
('MMM', 240, 1, 'D', 'C', '89A99A38-3BB6-6973-9BAB-2F06FF66027A'),
('MMM', 30, 7, 'W', 'C', '68013E34-9D81-E0B2-339A-789E9A40532D'),
('MMM', 60, 7, 'W', 'C', '61DD6299-A3E3-A768-55D2-01C8BA6CEA83'),
('MMM', 120, 7, 'W', 'C', '07744D77-A4BB-6BBD-139B-82BA0FEDD1C9'),
('MMM', 240, 7, 'W', 'C', '4E186925-E12B-CF52-5C96-1191BC528526'),
('DD', 30, 1, 'D', 'F', 'C448665A-6BE4-E9CB-9F6C-6024EB715B2A'),
('DD', 60, 1, 'D', 'F', '24D1C67A-4B9B-5164-6A6E-866EDC22BCCA'),
('DD', 120, 1, 'D', 'F', 'FE0B84D4-0657-E73D-DCAC-E8EE1A722B4B'),
('DD', 240, 1, 'D', 'F', '5BEE47AF-823D-12E9-6373-3093D154795E'),
('DD', 30, 7, 'W', 'F', '323EFB42-7C8F-D844-1A30-97343D84AAF1'),
('DD', 60, 7, 'W', 'F', '47C78949-D9BF-FBF8-71BC-DCAD70C55C1F'),
('DD', 120, 7, 'W', 'F', '88580EC8-E956-FFFA-587E-7BE63C86042D'),
('DD', 240, 7, 'W', 'F', 'B4AC78CE-FB23-CAB5-D1E6-4F02CCE4391B'),
('DD', 30, 1, 'D', 'C', '3681636C-7362-7450-247B-9C4DB4B94602'),
('DD', 60, 1, 'D', 'C', '8246D829-6A77-0240-42F7-AD2A3BFE2F56'),
('DD', 120, 1, 'D', 'C', 'D3D6F2CB-983E-1687-E5E1-DD52522956B0'),
('DD', 240, 1, 'D', 'C', 'A2465F3B-246D-1EC2-924F-A39F687ABFF8'),
('DD', 30, 7, 'W', 'C', '27F17879-BFBD-C02F-0DC6-434EBBED92B1'),
('DD', 60, 7, 'W', 'C', '39503414-71E9-23C7-91F7-A894113BEE9F'),
('DD', 120, 7, 'W', 'C', '6226234F-B66C-E2FA-F4A9-083E5BA8842C'),
('DD', 240, 7, 'W', 'C', '83AD0C98-2AC4-5089-668B-99F5A017CB8D'),
('UTX', 30, 1, 'D', 'F', '17E863F5-943E-58BD-5932-624E30B8AB91'),
('UTX', 60, 1, 'D', 'F', 'B653EEAF-5CE0-27B6-34C0-FAC3D26E3DE4'),
('UTX', 120, 1, 'D', 'F', 'CF90390F-6F6F-A7F1-8028-1EB61D03A6E8'),
('UTX', 240, 1, 'D', 'F', '266418C5-6692-F9EE-40AF-641B7E79203F'),
('UTX', 30, 7, 'W', 'F', 'E1918071-3707-74FF-AFEC-C81474CDF057'),
('UTX', 60, 7, 'W', 'F', '2EE4487F-B65F-943B-FEA0-FEB5E2DA24F1'),
('UTX', 120, 7, 'W', 'F', '0B352844-370C-CDB1-8A2C-F4D6E484DCEC'),
('UTX', 240, 7, 'W', 'F', 'A182CB86-B18F-7498-F98E-EE47F9266841'),
('UTX', 30, 1, 'D', 'C', '17D5B5D0-B10A-EE43-6DF5-EA4CF4F7AF22'),
('UTX', 60, 1, 'D', 'C', 'A91340CA-3767-5979-97C9-067A2CFFBBC5'),
('UTX', 120, 1, 'D', 'C', '9E01E7D2-D37F-F8C3-A411-693006FF9DBA'),
('UTX', 240, 1, 'D', 'C', 'D20C8EC4-4D75-FC5A-304C-7311AC10CCB2'),
('UTX', 30, 7, 'W', 'C', '2D9EE9B3-8B0A-59D9-0647-60FADEA7598A'),
('UTX', 60, 7, 'W', 'C', 'DCA31574-9895-CD42-0913-AFE9E7DF51C7'),
('UTX', 120, 7, 'W', 'C', '56F96341-4D4F-52B4-79D0-A392BB2019F8'),
('UTX', 240, 7, 'W', 'C', 'EFCBED95-4543-77E5-D5CC-1EBE51DFEE3D'),
('UNH', 30, 1, 'D', 'F', 'B77E5D1E-CB70-DAE8-3B27-085B9388F03C'),
('UNH', 60, 1, 'D', 'F', '13CDB0BB-7C9B-62CE-BCA1-C81FD17B6BFB'),
('UNH', 120, 1, 'D', 'F', '0D81D404-0DDD-6D49-CF7D-F0F1E7BD7881'),
('UNH', 240, 1, 'D', 'F', '5BF8483F-6A57-7320-06AD-9EC7901768EE'),
('UNH', 30, 7, 'W', 'F', '73F7DF46-AF39-310E-1C43-14E0072E0833'),
('UNH', 60, 7, 'W', 'F', '0BEE5371-9945-6099-57AC-64AA5F812FDC'),
('UNH', 120, 7, 'W', 'F', 'EA4F6F44-5A23-1941-F60C-3068910F8AE5'),
('UNH', 240, 7, 'W', 'F', '96A84575-6286-3032-B28F-2BF007DDB121'),
('UNH', 30, 1, 'D', 'C', 'D8499DC1-CC65-93D1-43A3-BBB6F2606A04'),
('UNH', 60, 1, 'D', 'C', '95D17F99-E6B0-09CD-9E08-3224271E12EA'),
('UNH', 120, 1, 'D', 'C', '1B2603AD-9FB2-DE86-5539-EBE56937BD64'),
('UNH', 240, 1, 'D', 'C', '9409D000-1A64-29A9-17F3-9237C1D2E869'),
('UNH', 30, 7, 'W', 'C', '0F91266A-B103-A2AA-E9E4-13F438425728'),
('UNH', 60, 7, 'W', 'C', 'E8180401-0B89-BDE8-D4E9-B05ECDABAB90'),
('UNH', 120, 7, 'W', 'C', '4C875BE2-D268-C1C1-E360-C6F54789C341'),
('UNH', 240, 7, 'W', 'C', '85C587EC-77A2-E430-5BEA-E4E3E5BE2797'),
('TRV', 30, 1, 'D', 'F', '79E7EF54-9249-B132-D9E4-CF55B622B6D7'),
('TRV', 60, 1, 'D', 'F', '4B00513C-DF89-DFFE-0C57-D2BB05584E08'),
('TRV', 120, 1, 'D', 'F', 'C400C270-EDB6-18D1-0572-FB82827707ED'),
('TRV', 240, 1, 'D', 'F', '01FDDAC3-5B9D-A6B9-6578-E8810AE42859'),
('TRV', 30, 7, 'W', 'F', '6C099D46-BDB8-C170-F2B1-971BC437C533'),
('TRV', 60, 7, 'W', 'F', '20C656F4-8A84-1421-48E8-5456316A6980'),
('TRV', 120, 7, 'W', 'F', '59AD366E-59A4-9A8A-C0E7-0E424543484F'),
('TRV', 240, 7, 'W', 'F', 'AC394906-B3FD-E8AD-E1C4-3D8B26B17A99'),
('TRV', 30, 1, 'D', 'C', 'A3864E07-8EA4-DFCF-9CF2-64BAE2B7C40E'),
('TRV', 60, 1, 'D', 'C', '084E92E6-6400-58F0-4AB9-1B5E27846BD4'),
('TRV', 120, 1, 'D', 'C', '5029416A-D0FB-B2D7-437E-4B5D2BBB69C9'),
('TRV', 240, 1, 'D', 'C', 'B8BB039C-C3BA-00FD-D87F-202AD95CC1A2'),
('TRV', 30, 7, 'W', 'C', 'A32C916F-133E-A8C3-612C-807106B15061'),
('TRV', 60, 7, 'W', 'C', 'F9912E30-A1A6-7211-E9CC-828FD821AB28'),
('TRV', 120, 7, 'W', 'C', '3CBB3161-3713-E93B-7CD5-458C4026E011'),
('TRV', 240, 7, 'W', 'C', '592F7A75-AA3A-7F30-2D25-4881E0B11EAB')