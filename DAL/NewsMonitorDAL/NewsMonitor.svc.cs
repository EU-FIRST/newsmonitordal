 using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Net;
using System.Runtime.Serialization;
using System.ServiceModel;
using System.ServiceModel.Activation;
using System.ServiceModel.Channels;
using System.ServiceModel.Web;
using System.Text;
using System.Web;
using Latino;
using Latino.Model;
 using Latino.TextMining;
 using Latino.Visualization;
using System.Configuration;


namespace NewsMonitorDAL
{
    public enum Aggregate
    {
        Day,
        MA,
        Avg
    }
    public enum DataType
    {
        Sentiment,
        PumpDump
    }
    public enum TagCloudType
    {
        Titles, 
        Entities,
    };


    [ServiceContract]
    [AspNetCompatibilityRequirements(RequirementsMode = AspNetCompatibilityRequirementsMode.Allowed)]
    public class NewsMonitor
    { 

        [OperationContract]
        [WebGet(ResponseFormat = WebMessageFormat.Json)]
        public List<Entity> FindEntity(string query)
        {
            StringReplacer strRpl = StringReplacerGetDefaultBasic();
            StringReplacerCommentNamedRemove(strRpl, "uri");
            var sqlParams = new object[] { "", query };

            List<SqlRow.Entity> entities = DataProvider.GetDataWithReplace<SqlRow.Entity>("Entity.sql", strRpl, sqlParams);

            return entities
                .Select(ent => new Entity
                {
                    Id = ent.EntityUri,
                    Description = ent.EntityLabel,
                    Features = ent.Features
                })
                .ToList();
        }

        [OperationContract]
        [WebGet(ResponseFormat = WebMessageFormat.Json)]
        public List<EntityDetail> EntityDetail(string entity)
        { 
            if (string.IsNullOrWhiteSpace(entity)) return new List<EntityDetail>();

            StringReplacer strRpl = StringReplacerGetDefaultBasic();
            var sqlParams = new object[] { entity };

            List<SqlRow.Entity> volumeTimeSeries = DataProvider.GetDataWithReplace<SqlRow.Entity>("EntityDetail.sql", strRpl, sqlParams);

            return volumeTimeSeries.Select(d => new EntityDetail()
                {
                    Id = d.EntityUri,
                    Description = d.EntityLabel,
                    NumDocuments = d.NumDocuments,
                    NumOccurrences = d.NumOccurrences,
                    DataStartTimeDate = d.DataStartTime ?? DateTime.MinValue,
                    DataEndTimeDate = d.DataEndTime ?? DateTime.MinValue,
                    Features = d.Features
                }).ToList();

        }

        // ************ Common functions *******************

        private static TDayData[] FillMissingDates<TSqlRowType, TDayData>(DateTime from, int days, IEnumerable<TSqlRowType> volumeTimeSeries, Func<TSqlRowType, TDayData> createFromExisting, Func<TSqlRowType, DateTime> date)
            where TDayData : DayData, new()
        {
            // important: imput 0 values if they are absent for specific days !!!!!
            List<TSqlRowType> volumeTimeSeriesOrdered = volumeTimeSeries.OrderBy(date).ToList();

            int j = 0;
            TDayData[] returnArray = new TDayData[days];
            for (int i = 0; i < days; i++)
            {
                if (j < volumeTimeSeriesOrdered.Count && date(volumeTimeSeriesOrdered[j]) == from.AddDays(i).Date)
                {
                    returnArray[i] = createFromExisting(volumeTimeSeriesOrdered[j]);
                    j++;
                }
                else
                {
                    returnArray[i] = new TDayData() { DateDate = from.AddDays(i) };
                }
            }
            return returnArray;
        }

        // ************ Volume *******************

        [OperationContract]
        [WebGet(ResponseFormat = WebMessageFormat.Json)]
        public List<DayVolume> Volume(string entity, DateTime from, DateTime to, int days, string data, string aggregate, int maWindow)
        {
            if (string.IsNullOrWhiteSpace(entity)) return new List<DayVolume>();

            ParameterChecker.TimeSpan(ref from, ref to, ref days);
            DataType dataEnum = ParameterChecker.EnumParse(data, DataType.Sentiment);
            Aggregate aggEnum = ParameterChecker.EnumParse(aggregate, Aggregate.Day);
            maWindow = ParameterChecker.StrictlyPositiveNumber(maWindow, 0);
            if (aggEnum == Aggregate.MA)
            {
                to = to.AddDays(maWindow);
                days += maWindow;
            }

            List<DayVolume> returnArray = GetVolume(entity, from, to, days);
            switch (aggEnum)
            {
                case Aggregate.Day:
                    return returnArray;
                case Aggregate.MA:
                    return GetVolumeMovingAvg(returnArray, maWindow);
                case Aggregate.Avg:
                    return GetVolumeAvg(returnArray);
                default:
                    throw new ArgumentOutOfRangeException(); 
            }
           
        }

        private List<DayVolume> GetVolume(string entity, DateTime from, DateTime to, int days)
        {
            StringReplacer strRpl = StringReplacerGetDefaultBasic();
            var sqlParams = new object[] { entity, from, to, days };
            List<SqlRow.DayVolume> volumeTimeSeries = DataProvider.GetDataWithReplace<SqlRow.DayVolume>("DayVolume.sql", strRpl, sqlParams);

            var returnArray = FillMissingDates(from, days, volumeTimeSeries, dv=>new DayVolume(){DateDate = dv.Date, Volume = dv.Volume}, dv => dv.Date);
            return returnArray.ToList();
        }
        public List<DayVolume> GetVolumeMovingAvg(List<DayVolume> ds, int maWindow)
        {
            int period = ds.Count -maWindow - 1;  // number of days between dateEnd and dateStart 

            List<DayVolume> result = new List<DayVolume>();
            for (int i = maWindow - 1; i < period+1; i++)
            {
                double avg = 0;
                for (int j = 0; j < maWindow; j++)
                {
                    avg = avg + ds[i - j].Volume;
                }
                avg = avg / maWindow;

                DayVolume avgds = new DayVolume { DateDate = ds[i].DateDate, Volume = avg };
                result.Add(avgds);
            }

            return result;
        }
        public List<DayVolume> GetVolumeAvg(List<DayVolume> ds)
        {
            return new List<DayVolume>(new[]
                {
                    new DayVolume
                        {
                            DateDate = ds.Min(d => d.DateDate),
                            Volume = ds.Average(d => d.Volume)
                        }
                });
        }

        // ************ DrillDown *******************

        [OperationContract]
        [WebGet(ResponseFormat = WebMessageFormat.Json)]
        public DocumentDetail Document(Guid documentId)
        {

            StringReplacer strRpl = StringReplacerGetDefaultBasic();
            var sqlParams = new object[] { documentId };
            List<SqlRow.DocumentFileName> documentFilename = DataProvider.GetDataWithReplace<SqlRow.DocumentFileName>("DocumentFileName.sql", strRpl, sqlParams);

            if (documentFilename.Any())
            {
                string fileServer = ConfigurationManager.AppSettings["fileServer"];
                string fileNameWrong = documentFilename.First().FileName;
                string fileNameCorrect =
                    fileNameWrong.Substring(0, fileNameWrong.LastIndexOf('_') + 1) +
                    documentId.ToString().Replace("-", "") +
                    fileNameWrong.Substring(fileNameWrong.IndexOf('.'));
                string fileName = (fileServer + fileNameCorrect).Replace('\\', '/');

                WebClient wc = new WebClient();
                Stream webStream = wc.OpenRead(fileName);
                
                Latino.Workflows.TextMining.Document doc = new Latino.Workflows.TextMining.Document("","");
                doc.ReadXmlCompressed(webStream);
                webStream.Close();

                return new DocumentDetail()
                {
                    DocumentId = documentId,
                    Title = doc.Name,
                    Content = doc.Text
                };
            }

            throw new WebFaultException<string>(
                string.Format("No documents with id '{0}' found in the database.", documentId),
                HttpStatusCode.NotAcceptable);

        }

        [OperationContract]
        [WebGet(ResponseFormat = WebMessageFormat.Json)]
        public List<DayDocument> DocumentList(string entity, DateTime from, DateTime to, int days, string data, bool normalize)
        {
            if (string.IsNullOrWhiteSpace(entity)) return new List<DayDocument>();

            ParameterChecker.TimeSpan(ref from, ref to, ref days);
            DataType dataType = ParameterChecker.EnumParse(data, DataType.Sentiment);

            if (dataType == DataType.PumpDump)
                throw new WebFaultException<string>(
                        string.Format("Data of type 'PumpDump' not supported yet in DocumentList service. If required please send a request for support to the service author."),
                        HttpStatusCode.NotAcceptable);

            StringReplacer strRpl = StringReplacerGetDefaultBasic();
            var sqlParams = new object[] { entity, from, to, normalize };
            List<SqlRow.DayDocument> documents = DataProvider.GetDataWithReplace<SqlRow.DayDocument>(dataType == DataType.Sentiment ? "DayDocument.sql" : "DayDocument.sql", strRpl, sqlParams);

            return documents.Select(doc => new DayDocument()
            {
                DateDate = doc.Date,
                RetrieveTimeDate = doc.RetrieveTime,
                DomainName = doc.DomainName,
                Url = doc.Url,
                DocumentId = doc.DocumentId,
                Index = doc.Index
            }).ToList();
        }

        // ************ Index *******************

        [OperationContract]
        [WebGet(ResponseFormat = WebMessageFormat.Json)]
        public List<DayIndex> Index(string entity, DateTime from, DateTime to, int days, string data, string aggregate, int maWindow, bool normalize)
        {
            if (string.IsNullOrWhiteSpace(entity)) return new List<DayIndex>();

            ParameterChecker.TimeSpan(ref from, ref to, ref days);
            DataType dataEnum = ParameterChecker.EnumParse(data, DataType.Sentiment);
            Aggregate aggEnum = ParameterChecker.EnumParse(aggregate, Aggregate.Day);
            maWindow = ParameterChecker.StrictlyPositiveNumber(maWindow, 0);
            if (aggEnum == Aggregate.MA)
            {
                to = to.AddDays(maWindow);
                days += maWindow;
            }

            List<DayIndex> returnArray = GetIndex(entity, from, to, days, dataEnum, normalize);
            switch (aggEnum)
            {
                case Aggregate.Day:
                    return returnArray;
                case Aggregate.MA:
                    return GetIndexMovingAvg(returnArray, maWindow);
                case Aggregate.Avg:
                    return GetIndexAvg(returnArray);
                default:
                    throw new ArgumentOutOfRangeException();
            }

        }

        private List<DayIndex> GetIndex(string entity, DateTime from, DateTime to, int days, DataType dataType, bool normalize)
        {
            StringReplacer strRpl = StringReplacerGetDefaultBasic();
            var sqlParams = new object[] { entity, from, to, normalize };
            List<SqlRow.DayIndex> indexTimeSeries = DataProvider.GetDataWithReplace<SqlRow.DayIndex>(dataType == DataType.Sentiment ? "DaySentiment.sql" : "DayPumpDump.sql", strRpl, sqlParams);

            var returnArray = FillMissingDates(from, days, indexTimeSeries, dv => new DayIndex() { DateDate = dv.Date, Index = dv.Index }, dv => dv.Date);
            return returnArray.ToList();
        }
        public List<DayIndex> GetIndexMovingAvg(List<DayIndex> ds, int maWindow)
        {
            int period = ds.Count - maWindow - 1;  // number of days between dateEnd and dateStart 

            List<DayIndex> result = new List<DayIndex>();
            for (int i = maWindow - 1; i < period+1; i++)
            {
                double avg = 0;
                for (int j = 0; j < maWindow; j++)
                {
                    avg = avg + ds[i - j].Index;
                }
                avg = avg / maWindow;

                DayIndex avgds = new DayIndex { DateDate = ds[i].DateDate, Index = avg };
                result.Add(avgds);
            }

            return result;
        }
        public List<DayIndex> GetIndexAvg(List<DayIndex> ds)
        {
            return new List<DayIndex>(new[]
                {
                    new DayIndex
                        {
                            DateDate = ds.Min(d => d.DateDate),
                            Index = ds.Average(d => d.Index)
                        }
                });
        }

        // ************ VolumeAndIndex *******************
        
        [OperationContract]
        [WebGet(ResponseFormat = WebMessageFormat.Json)]
        public List<DayVolumeIndex> VolumeAndIndex(string entity, DateTime from, DateTime to, int days, string data, string aggregate, int maWindow, bool normalize)
        {
            if (string.IsNullOrWhiteSpace(entity)) return new List<DayVolumeIndex>();

            ParameterChecker.TimeSpan(ref from, ref to, ref days);
            DataType dataEnum = ParameterChecker.EnumParse(data, DataType.Sentiment);
            Aggregate aggEnum = ParameterChecker.EnumParse(aggregate, Aggregate.Day);
            maWindow = ParameterChecker.StrictlyPositiveNumber(maWindow, 0);
            if (aggEnum == Aggregate.MA)
            {
                to = to.AddDays(maWindow);
                days += maWindow;
            }

            List<DayVolume> volumeData = GetVolume(entity, from, to, days);
            List<DayIndex> indexData = GetIndex(entity, from, to, days, dataEnum, normalize);
            switch (aggEnum)
            {
                case Aggregate.Day:
                    return MergeVolumeIndex(volumeData, indexData);
                case Aggregate.MA:
                    return MergeVolumeIndex(
                        GetVolumeMovingAvg(volumeData, maWindow), 
                        GetIndexMovingAvg(indexData, maWindow)
                        );
                case Aggregate.Avg:
                    return MergeVolumeIndex(
                        GetVolumeAvg(volumeData), 
                        GetIndexAvg(indexData)
                        );
                default:
                    throw new ArgumentOutOfRangeException();
            }

        }

        private List<DayVolumeIndex> MergeVolumeIndex(List<DayVolume> volume, List<DayIndex> index)
        {
            Dictionary<DateTime, DayVolumeIndex> dict = new Dictionary<DateTime, DayVolumeIndex>();
            foreach (var dv in volume)
            {
                if (dict.ContainsKey(dv.DateDate))
                    dict[dv.DateDate].Volume = dv.Volume;
                else
                    dict[dv.DateDate] = new DayVolumeIndex() {DateDate = dv.DateDate, Volume = dv.Volume};
            }
            foreach (var dv in index)
            {
                if (dict.ContainsKey(dv.DateDate))
                    dict[dv.DateDate].Index = dv.Index;
                else
                    dict[dv.DateDate] = new DayVolumeIndex() { DateDate = dv.DateDate, Index = dv.Index };
            }
            return dict.Values.OrderBy(dv => dv.DateDate).ToList();

        }

        // ************ IndexClasses *******************
        
        [OperationContract]
        [WebGet(ResponseFormat = WebMessageFormat.Json)]
        public List<DayIndexClasses> IndexClasses(string entity, DateTime from, DateTime to, int days, string data, string aggregate, int maWindow)
        {
            if (string.IsNullOrWhiteSpace(entity)) return new List<DayIndexClasses>();

            ParameterChecker.TimeSpan(ref from, ref to, ref days);
            DataType dataEnum = ParameterChecker.EnumParse(data, DataType.Sentiment);
            Aggregate aggEnum = ParameterChecker.EnumParse(aggregate, Aggregate.Day);
            maWindow = ParameterChecker.StrictlyPositiveNumber(maWindow, 0);
            if (aggEnum == Aggregate.MA)
            {
                to = to.AddDays(maWindow);
                days += maWindow;
            }

            List<DayIndexClasses> returnArray = GetIndexClasses(entity, from, to, days, dataEnum);
            switch (aggEnum)
            {
                case Aggregate.Day:
                    return returnArray;
                case Aggregate.MA:
                    return GetIndexClassesMovingAvg(returnArray, maWindow);
                case Aggregate.Avg:
                    return GetIndexClassesAvg(returnArray);
                default:
                    throw new ArgumentOutOfRangeException();
            }

        }

        private List<DayIndexClasses> GetIndexClasses(string entity, DateTime from, DateTime to, int days, DataType dataType)
        {
            StringReplacer strRpl = StringReplacerGetDefaultBasic();
            var sqlParams = new object[] { entity, from, to, days }; 
            List<SqlRow.DayIndexClasses> indexClassesTimeSeries = DataProvider.GetDataWithReplace<SqlRow.DayIndexClasses>(dataType == DataType.Sentiment ? "DaySentimentClasses.sql" : "DayPumpDumpClasses.sql", strRpl, sqlParams);

            var returnArray = FillMissingDates(from, days, indexClassesTimeSeries, 
                dv => new DayIndexClasses()
                    {
                        DateDate = dv.Date, 
                        Positives = dv.Positives,
                        PosNeutrals = dv.PosNeutrals,
                        NegNeutrals = dv.NegNeutrals,
                        Negatives = dv.Negatives
                    }, 
                dv => dv.Date);
            return returnArray.ToList();
        }
        public List<DayIndexClasses> GetIndexClassesMovingAvg(List<DayIndexClasses> ds, int maWindow)
        {
            int period = ds.Count - maWindow - 1;  // number of days between dateEnd and dateStart 

            List<DayIndexClasses> result = new List<DayIndexClasses>();
            for (int i = maWindow - 1; i < period + 1; i++)
            {
                DayIndexClasses avg = new DayIndexClasses();
                for (int j = 0; j < maWindow; j++)
                {
                    avg.Positives += ds[i - j].Positives;
                    avg.PosNeutrals += ds[i - j].PosNeutrals;
                    avg.NegNeutrals += ds[i - j].NegNeutrals;
                    avg.Negatives += ds[i - j].Negatives;
                }

                DayIndexClasses avgds = new DayIndexClasses
                {
                    DateDate = ds[i].DateDate,
                    Positives = avg.Positives / maWindow,
                    PosNeutrals = avg.PosNeutrals / maWindow,
                    NegNeutrals = avg.NegNeutrals / maWindow,
                    Negatives = avg.Negatives / maWindow
                };
                result.Add(avgds);
            }

            return result;
        }
        public List<DayIndexClasses> GetIndexClassesAvg(List<DayIndexClasses> ds)
        {
            return new List<DayIndexClasses>(new[]
                {
                    new DayIndexClasses
                        {
                            DateDate = ds.Min(d => d.DateDate),
                            Positives = ds.Average(d => d.Positives),
                            PosNeutrals = ds.Average(d => d.PosNeutrals),
                            NegNeutrals = ds.Average(d => d.NegNeutrals),
                            Negatives = ds.Average(d => d.Negatives)
                        }
                });
        }
        
        // ************ Sentiment Polarity *******************

        private int UriToId(string uri)
        {
            StringReplacer strRpl = StringReplacerGetDefaultBasic();
            StringReplacerCommentNamedRemove(strRpl, "labelLike");
            var sqlParams = new object[] { uri, "" };

            List<SqlRow.Entity> dataDescription = DataProvider.GetDataWithReplace<SqlRow.Entity>("Entity.sql", strRpl, sqlParams);

            if (dataDescription.Any())
                return dataDescription.First().Id;
            else
                return -1;
        }

        [OperationContract]
        [WebGet(ResponseFormat = WebMessageFormat.Json)]
        private List<Entity> GetEntityId(string label)
        {
            StringReplacer strRpl = StringReplacerGetDefaultBasic();
            StringReplacerCommentNamedRemove(strRpl, "uri");
            var sqlParams = new object[] { "", label };

            List<SqlRow.Entity> entities = DataProvider.GetDataWithReplace<SqlRow.Entity>("Entity.sql", strRpl, sqlParams);

            return entities
                .Select(ent => new Entity
                {
                    Id = ent.EntityUri,
                    Description = ent.EntityLabel,
                })
                .ToList();
        }

        [OperationContract]
        [WebGet(ResponseFormat = WebMessageFormat.Json)]
        public double GetAvgSentiment(string entityUri, DateTime date, int days, bool normalize)
        {
            List<DayIndex> ds = GetDaySentiment(entityUri, date, days, normalize);
            double d = ds.Average(daySentiment => daySentiment.Index);
            return d;
        }

        [OperationContract]
        [WebGet(ResponseFormat = WebMessageFormat.Json)]
        public List<DayIndex> GetMovingAvgSentiment(string entityUri, DateTime dateStart, DateTime dateEnd, int window, bool normalize)
        {
            int period = Convert.ToInt32(((dateEnd - dateStart).TotalDays));  // number of days between dateEnd and dateStart 
            List<DayIndex> ds = GetDaySentiment(entityUri, dateEnd, period + window, normalize);

            List<DayIndex> result = new List<DayIndex>();
            for (int i = window - 1; i < period + window; i++)
            {
                double avg = 0;
                for (int j = 0; j < window; j++)
                {
                    avg = avg + ds[i - j].Index;
                }
                avg = avg / window;

                DayIndex avgds = new DayIndex { DateDate = ds[i].DateDate, Index = avg };
                result.Add(avgds);
            }

            return result;
        }

        [OperationContract]
        [WebGet(ResponseFormat = WebMessageFormat.Json)]
        public List<DayIndex> GetDaySentiment(string entityUri, DateTime date, int days, bool normalize)
        {
            //int entityId = UriToId(entityUri);

            StringReplacer strRpl = StringReplacerGetDefaultBasic();
            var sqlParams = new object[] { entityUri, date.AddDays(-days), date, normalize };
            List<SqlRow.DayIndex> sentimentTimeSeries = DataProvider.GetDataWithReplace<SqlRow.DayIndex>("DaySentiment.sql", strRpl, sqlParams);

            // important: imput 0 values if they are absent for specific days !!!!!
            int j = 0;
            DayIndex[] returnArray = new DayIndex[days];
            for (int i = 0; i < days; i++)
            {
                if (j < sentimentTimeSeries.Count && sentimentTimeSeries[j].Date.Date == date.AddDays(-days + i + 1).Date)
                {
                    SqlRow.DayIndex ds = sentimentTimeSeries[j];
                    returnArray[i] = new DayIndex { DateDate = ds.Date, Index = ds.Index };
                    j++;
                } else
                {
                    returnArray[i] = new DayIndex{ DateDate = date.AddDays(-days + i + 1), Index = 0 };
                }
            }

            /*
            if (!normalize)
            {
                return returnArray.ToList();
            }
            // normalize
            double normPar = GetNormalizationParameter(entity);
            foreach (var daySentiment in returnArray)
            {
                daySentiment.Index = daySentiment.Index / normPar;
                if (daySentiment.Index > 1)
                {
                    daySentiment.Index = 1;
                } else if (daySentiment.Index < -1)
                {
                    daySentiment.Index = -1;
                }
            }*/

            return normalize
                ? returnArray.Select(daySent => new DayIndex { DateDate = daySent.DateDate, Index = Math.Min(daySent.Index, 1) }).ToList()
                : returnArray.ToList();
        }

        // ************ Tag cloud news *******************
        //invoke example: http://localhost:11111/NewsMonitor.svc/rest/TagCloud?entity=http%3A%2F%2Fproject-first.eu%2Fontology%23cou_SI&from=2012-08-23&to=2012-08-24&days=2&confidence=2&tagCloudType=Titles&maxNumTerms=100&FinancialOnly=0

        [OperationContract]
        [WebGet(ResponseFormat = WebMessageFormat.Json)]
        public List<TermWeight> TagCloud(string entity, DateTime from, DateTime to, int days, int confidence, string tagCloudType, int maxNumTerms, int financialOnly)
        {
            ParameterChecker.TimeSpan(ref from, ref to, ref days);                                            // check parameters
            confidence = ParameterChecker.StrictlyPositiveNumber(confidence, 2);
            TagCloudType tagCloudTypePrm = ParameterChecker.EnumParse(tagCloudType, TagCloudType.Titles);
            maxNumTerms = ParameterChecker.StrictlyPositiveNumber(maxNumTerms, 100);
            financialOnly = ParameterChecker.ZeroOrOne(financialOnly, 0);

            return (tagCloudTypePrm == TagCloudType.Titles)
                       ? TagCloudTitles(entity, from, to, confidence, maxNumTerms, financialOnly)
                       : (tagCloudTypePrm == TagCloudType.Entities)
                             ? TagCloudEntities(entity, @from, to, confidence, maxNumTerms, financialOnly)
                             : new List<TermWeight>();
            
        }

        private List<TermWeight> TagCloudTitles(string entity, DateTime from, DateTime to, int confidence, int maxNumTerms, int financialOnly)
        {
            StringReplacer strRpl = StringReplacerGetDefaultBasic();
            var sqlParams = new object[] { entity, from, to, confidence, financialOnly };
            List<SqlRow.DocumentTitle> titles =
                DataProvider.GetDataWithReplace<SqlRow.DocumentTitle>("EntityTitles.sql", strRpl, sqlParams);
            var bowSpc = CreateBowSpace();
            bowSpc.Initialize(titles.Select(dt => dt.Title)); //count terms
            return
                bowSpc.Words.Select(w => new TermWeight() { Term = w.Stem, Weight = w.Freq})
                      .OrderByDescending(wc => wc.Weight)
                      .ThenBy(wc => wc.Term)
                      .Take(maxNumTerms)
                      .ToList();
        }

        private List<TermWeight> TagCloudEntities(string entity, DateTime from, DateTime to, int confidence, int maxNumTerms, int financialOnly)
        {
            StringReplacer strRpl = StringReplacerGetDefaultBasic();
            var sqlParams = new object[] { entity, from, to, confidence, maxNumTerms, financialOnly };
            List<SqlRow.EntityCountClasspath> entityCount =
                DataProvider.GetDataWithReplace<SqlRow.EntityCountClasspath>("TagCloudEntityEntities.sql", strRpl, sqlParams);
            return
                entityCount.Select(
                    wordCount =>
                    new TermWeight()
                        {
                            Term = wordCount.Entity,
                            Weight = wordCount.Count                            
                        }).ToList();
        }

        public static BowSpace CreateBowSpace()
        {
            // Get the stop words and stemmer for English.
            IStemmer stemmer = new Lemmatizer(Language.English);
            Set<string>.ReadOnly stopWords = StopWords.EnglishStopWords;

            // Create a tokenizer.
            UnicodeTokenizer tokenizer = new UnicodeTokenizer();
            tokenizer.MinTokenLen = 4; // Each token must be at least X characters long.
            tokenizer.Filter = TokenizerFilter.AlphanumLoose; // Tokens  can consist of alphabetic characters only.

            // Create a bag-of-words space.
            var bowSpc = new BowSpace();
            bowSpc.Tokenizer = tokenizer; // Assign the tokenizer.
            bowSpc.StopWords = stopWords; // Assign the stop words.
            bowSpc.Stemmer = stemmer;     // Assign the stemmer.
            bowSpc.MinWordFreq = 3;       // A term must appear at least X times in the corpus for it to be part of the vocabulary.
            bowSpc.MaxNGramLen = 1;       // Terms consisting of at most X consecutive words will be considered.
            bowSpc.WordWeightType = WordWeightType.TfIdf;
            // Set the weighting scheme for the bag-of-words vectors to TF-IDF.
            bowSpc.NormalizeVectors = true; // The TF-IDF vectors will be normalized?
            bowSpc.CutLowWeightsPerc = 0.05; 
            // The terms with the lowest weights, summing up to X% of the overall weight sum, will be removed from each TF-IDF vector.
            return bowSpc;
        }

        // ************ Helper functions *******************

        public StringReplacer StringReplacerGetDefaultBasic()
        {
            var strRpl = new StringReplacer();
            strRpl.AddReplacement("/*REM*/", "--");
            strRpl.AddReplacement("--ADD", "");

            int maxParameters = 20;
            for (int i = 0; i < maxParameters; i++)
                strRpl.AddReplacement("{" + i + "}", "#$#ENC$" + i + "#$#ENC$");
            strRpl.AddReplacement("{", "{{");
            strRpl.AddReplacement("}", "}}");
            for (int i = 0; i < maxParameters; i++)
                strRpl.AddReplacement("#$#ENC$" + i + "#$#ENC$", "{" + i + "}");

            return strRpl;
        }
        public StringReplacer StringReplacerGetDefault(string entity, string windowSize)
        {
            var strRpl = StringReplacerGetDefaultBasic();
            strRpl.AddReplacement("[AAPL_D_Terms]", string.Format("[Terms_{0}_{1}_1500]", entity, windowSize));
            strRpl.AddReplacement("[AAPL_D_Clusters]", string.Format("[Clusters_{0}_{1}_1500]", entity, windowSize));

            return strRpl;
        }
        public StringReplacer StringReplacerCommentNamedRemove(StringReplacer strRpl, string name)
        {
            strRpl.AddReplacement(string.Format("/*REM {0}*/", name), "--");
            return strRpl;
        }


    }

}
