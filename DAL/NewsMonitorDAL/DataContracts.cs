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
        public string Id { get; set; }
        [DataMember(Order = 1)]
        public string Description { get; set; }
        [DataMember(Order = 2)]
        public string Features { get; set; }
    }

    [DataContract]
    public class EntityDetail
    {
        [DataMember(Order = 0)]
        public string Id { get; set; }
        [DataMember(Order = 1)]
        public string Description { get; set; }
        [DataMember(Order = 2)]
        public int NumDocuments { get; set; }
        [DataMember(Order = 3)]
        public int NumOccurrences { get; set; }
        
        public DateTime DataStartTimeDate { get; set; }
        [DataMember(Order = 4)]
        public string DataStartTime
        {
            get { return DataStartTimeDate == DateTime.MinValue ? "" : DataStartTimeDate.ToString("yyyy-MM-dd"); }
            set { }
        }
        
        public DateTime DataEndTimeDate { get; set; }
        [DataMember(Order = 5)]
        public string DataEndTime
        {
            get { return DataEndTimeDate == DateTime.MinValue ? "" : DataEndTimeDate.ToString("yyyy-MM-dd"); }
            set { }
        }
        [DataMember(Order = 6)]
        public string Features { get; set; }
    }

    [DataContract]
    public class DayDocument : DayData
    {
        public DateTime RetrieveTimeDate { get; set; }
        [DataMember(Order = 1)]
        public string RetrieveTime
        {
            get { return RetrieveTimeDate.ToString("s", System.Globalization.CultureInfo.InvariantCulture); }
            set { }
        }
        [DataMember(Order = 2)]
        public string DomainName { get; set; }
        [DataMember(Order = 3)]
        public string Url { get; set; }
        [DataMember(Order = 4)]
        public Guid DocumentId { get; set; }
        [DataMember(Order = 5)]
        public double Index { get; set; }
    }

    [DataContract]
    public class DocumentDetail
    {
        [DataMember(Order = 0)]
        public Guid DocumentId { get; set; }
        [DataMember(Order = 1)]
        public string Title { get; set; }
        [DataMember(Order = 2)]
        public string Content { get; set; }
    }


    [DataContract]
    public class DayData
    {
        public DateTime DateDate { get; set; }
        [DataMember(Order = 0)]
        public string Date
        {
            get { return DateDate.ToString("yyyy-MM-dd"); }
            set { }
        }
    }

    [DataContract]
    public class DayVolume : DayData
    {
        [DataMember(Order = 1)]
        public double Volume { get; set; }
    }

    [DataContract]
    public class DayIndex : DayData
    {
        [DataMember(Order = 1)]
        public double Index { get; set; }
    }

    [DataContract]
    public class DayVolumeIndex : DayData
    {
        [DataMember(Order = 1)]
        public double Volume { get; set; }
        [DataMember(Order = 2)]
        public double Index { get; set; }
    }
    
    [DataContract]
    public class DayIndexClasses : DayData
    {
        [DataMember(Order = 1)]
        public double Positives { get; set; }
        [DataMember(Order = 2)]
        public double PosNeutrals { get; set; }
        [DataMember(Order = 3)]
        public double NegNeutrals { get; set; }
        [DataMember(Order = 4)]
        public double Negatives { get; set; }
    }

}