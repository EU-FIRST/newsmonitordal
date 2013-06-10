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
    [ServiceContract]
    [AspNetCompatibilityRequirements(RequirementsMode = AspNetCompatibilityRequirementsMode.Allowed)]
    [JavascriptCallbackBehavior(UrlParameterName = "jsonp")]
    public class NewsMonitor
    {
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
                    Id = ent.Id, 
                    Label = ent.EntityLabel,
                    Uri = ent.EntityUri,
                    EncodedUri = HttpUtility.UrlEncode(ent.EntityUri)
                })
                .ToList();
        }

        [OperationContract]
        [WebGet(ResponseFormat = WebMessageFormat.Json)]
        public double GetAvgSentiment(string entityUri, DateTime date, int days, bool normalize)
        {
            List<DaySentiment> ds = GetDaySentiment(entityUri, date, days, normalize);
            double d = ds.Average(daySentiment => daySentiment.SentimentPolatiry);
            return d;
        }

        [OperationContract]
        [WebGet(ResponseFormat = WebMessageFormat.Json)]
        public List<DaySentiment> GetMovingAvgSentiment(string entityUri, DateTime dateStart, DateTime dateEnd, int window, bool normalize)
        {
            int period = Convert.ToInt32(((dateEnd - dateStart).TotalDays));  // number of days between dateEnd and dateStart 
            List<DaySentiment> ds = GetDaySentiment(entityUri, dateEnd, period + window, normalize);

            List<DaySentiment> result = new List<DaySentiment>();
            for (int i = window - 1; i < period + window; i++)
            {
                double avg = 0;
                for (int j = 0; j < window; j++)
                {
                    avg = avg + ds[i - j].SentimentPolatiry;
                }
                avg = avg / window;

                DaySentiment avgds = new DaySentiment { Date = ds[i].Date, SentimentPolatiry = avg };
                result.Add(avgds);
            }

            return result;
        }

        [OperationContract]
        [WebGet(ResponseFormat = WebMessageFormat.Json)]
        public List<DaySentiment> GetDaySentiment(string entityUri, DateTime date, int days, bool normalize)
        {
            int entityId = UriToId(entityUri);

            StringReplacer strRpl = StringReplacerGetDefaultBasic();
            var sqlParams = new object[] { entityId, days, date, normalize };
            List<SqlRow.DaySentiment> sentimentTimeSeries = DataProvider.GetDataWithReplace<SqlRow.DaySentiment>("DaySentiment.sql", strRpl, sqlParams);

            // important: imput 0 values if they are absent for specific days !!!!!
            int j = 0;
            DaySentiment[] returnArray = new DaySentiment[days];
            for (int i = 0; i < days; i++)
            {
                if (j < sentimentTimeSeries.Count && sentimentTimeSeries[j].Date.Date == date.AddDays(-days + i + 1).Date)
                {
                    SqlRow.DaySentiment ds = sentimentTimeSeries[j];
                    returnArray[i] = new DaySentiment { DateDate = ds.Date, SentimentPolatiry = ds.Sentiment };
                    j++;
                } else
                {
                    returnArray[i] = new DaySentiment{ DateDate = date.AddDays(-days + i + 1), SentimentPolatiry = 0 };
                }
            }

            /*
            if (!normalize)
            {
                return returnArray.ToList();
            }
            // normalize
            double normPar = GetNormalizationParameter(entityUri);
            foreach (var daySentiment in returnArray)
            {
                daySentiment.SentimentPolatiry = daySentiment.SentimentPolatiry / normPar;
                if (daySentiment.SentimentPolatiry > 1)
                {
                    daySentiment.SentimentPolatiry = 1;
                } else if (daySentiment.SentimentPolatiry < -1)
                {
                    daySentiment.SentimentPolatiry = -1;
                }
            }*/

            return normalize
                ? returnArray.Select(daySent => new DaySentiment { DateDate = daySent.DateDate, SentimentPolatiry = Math.Min(daySent.SentimentPolatiry, 1) }).ToList()
                : returnArray.ToList();
        }

        [OperationContract]
        [WebGet(ResponseFormat = WebMessageFormat.Json)]
        public double GetAvgPumpDumpIndex(string entityUri, DateTime date, int days, bool normalize)
        {
            List<DayPumpDumpIndex> ds = GetDayPumpDumpIndex(entityUri, date, days, normalize);
            double d = ds.Average(DayPumpDumpIndex => DayPumpDumpIndex.PumpDumpIndex);
            return d;
        }

        [OperationContract]
        [WebGet(ResponseFormat = WebMessageFormat.Json)]
        public List<DayPumpDumpIndex> GetMovingAvgPumpDumpIndex(string entityUri, DateTime dateStart, DateTime dateEnd, int window, bool normalize)
        {
            int period = Convert.ToInt32(((dateEnd - dateStart).TotalDays));  // number of days between dateEnd and dateStart 
            List<DayPumpDumpIndex> ds = GetDayPumpDumpIndex(entityUri, dateEnd, period + window, normalize);

            List<DayPumpDumpIndex> result = new List<DayPumpDumpIndex>();
            for (int i = window - 1; i < period + window; i++)
            {
                double avg = 0;
                for (int j = 0; j < window; j++)
                {
                    avg = avg + ds[i - j].PumpDumpIndex;
                }
                avg = avg / window;

                DayPumpDumpIndex avgds = new DayPumpDumpIndex { Date = ds[i].Date, PumpDumpIndex = avg };
                result.Add(avgds);
            }

            return result;
        }

        [OperationContract]
        [WebGet(ResponseFormat = WebMessageFormat.Json)]
        public List<DayPumpDumpIndex> GetDayPumpDumpIndex(string entityUri, DateTime date, int days, bool normalize)
        {
            int entityId = UriToId(entityUri);

            StringReplacer strRpl = StringReplacerGetDefaultBasic();
            var sqlParams = new object[] { entityId, days, date, normalize };
            List<SqlRow.DayPumpDumpIndex> pumpDumpTimeSeries = DataProvider.GetDataWithReplace<SqlRow.DayPumpDumpIndex>("DayPumpDumpIndex.sql", strRpl, sqlParams);

            // important: imput 0 values if they are absent for specific days !!!!!
            int j = 0;
            DayPumpDumpIndex[] returnArray = new DayPumpDumpIndex[days];
            for (int i = 0; i < days; i++)
            {
                if (j < pumpDumpTimeSeries.Count && pumpDumpTimeSeries[j].Date.Date == date.AddDays(-days + i + 1).Date)
                {
                    SqlRow.DayPumpDumpIndex ds = pumpDumpTimeSeries[j];
                    returnArray[i] = new DayPumpDumpIndex { DateDate = ds.Date, PumpDumpIndex = ds.PumpDumpIndex };
                    j++;
                } else
                {
                    returnArray[i] = new DayPumpDumpIndex { DateDate = date.AddDays(-days + i + 1), PumpDumpIndex = 0 };
                }
            }

            return normalize
                ? returnArray.Select(daySent => new DayPumpDumpIndex { DateDate = daySent.DateDate, PumpDumpIndex = Math.Min(daySent.PumpDumpIndex, 1) }).ToList()
                : returnArray.ToList();
        }
        
        //Helper functions
        public StringReplacer StringReplacerGetDefaultBasic()
        {
            var strRpl = new StringReplacer();
            strRpl.AddReplacement("/*REM*/", "--");
            strRpl.AddReplacement("--ADD", "");

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
