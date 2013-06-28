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
using Latino.Visualization;


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
            DataType dataEnum = ParameterChecker.DataType(data, DataType.Sentiment);
            Aggregate aggEnum = ParameterChecker.Aggregate(aggregate, Aggregate.Day);
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

        // ************ Index *******************

        [OperationContract]
        [WebGet(ResponseFormat = WebMessageFormat.Json)]
        public List<DayIndex> Index(string entity, DateTime from, DateTime to, int days, string data, string aggregate, int maWindow)
        {
            if (string.IsNullOrWhiteSpace(entity)) return new List<DayIndex>();

            ParameterChecker.TimeSpan(ref from, ref to, ref days);
            DataType dataEnum = ParameterChecker.DataType(data, DataType.Sentiment);
            Aggregate aggEnum = ParameterChecker.Aggregate(aggregate, Aggregate.Day);
            maWindow = ParameterChecker.StrictlyPositiveNumber(maWindow, 0);
            if (aggEnum == Aggregate.MA)
            {
                to = to.AddDays(maWindow);
                days += maWindow;
            }

            List<DayIndex> returnArray = GetIndex(entity, from, to, days, dataEnum);
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

        private List<DayIndex> GetIndex(string entity, DateTime from, DateTime to, int days, DataType dataType)
        {
            StringReplacer strRpl = StringReplacerGetDefaultBasic();
            var sqlParams = new object[] { entity, from, to, days };
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
        public List<DayVolumeIndex> VolumeAndIndex(string entity, DateTime from, DateTime to, int days, string data, string aggregate, int maWindow)
        {
            if (string.IsNullOrWhiteSpace(entity)) return new List<DayVolumeIndex>();

            ParameterChecker.TimeSpan(ref from, ref to, ref days);
            DataType dataEnum = ParameterChecker.DataType(data, DataType.Sentiment);
            Aggregate aggEnum = ParameterChecker.Aggregate(aggregate, Aggregate.Day);
            maWindow = ParameterChecker.StrictlyPositiveNumber(maWindow, 0);
            if (aggEnum == Aggregate.MA)
            {
                to = to.AddDays(maWindow);
                days += maWindow;
            }

            List<DayVolume> volumeData = GetVolume(entity, from, to, days);
            List<DayIndex> indexData = GetIndex(entity, from, to, days, dataEnum);
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
            DataType dataEnum = ParameterChecker.DataType(data, DataType.Sentiment);
            Aggregate aggEnum = ParameterChecker.Aggregate(aggregate, Aggregate.Day);
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
