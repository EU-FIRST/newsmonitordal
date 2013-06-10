using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.Serialization;
using System.Web;

namespace NewsMonitorDAL
{
    [DataContract]
    public class Entity
    {
        [DataMember(Order = 0)]
        public int Id { get; set; }
        [DataMember(Order = 1)]
        public string Label { get; set; }
        [DataMember(Order = 2)]
        public string Uri { get; set; }
        [DataMember(Order = 3)]
        public string EncodedUri { get; set; }
    }

    [DataContract]
    public class DaySentiment
    {
        public DateTime DateDate { get; set; }
        [DataMember(Order = 0)]
        public string Date
        {
            get { return DateDate.ToString("yyyy-MM-dd"); }
            set { DateDate = DateTime.Parse(value); }
        }
        [DataMember(Order = 1)]
        public double SentimentPolatiry { get; set; }

    }

    [DataContract]
    public class DayPumpDumpIndex
    {
        public DateTime DateDate { get; set; }
        [DataMember(Order = 0)]
        public string Date
        {
            get { return DateDate.ToString("yyyy-MM-dd"); }
            set { DateDate = DateTime.Parse(value); }
        }
        [DataMember(Order = 1)]
        public double PumpDumpIndex { get; set; }

    }
}