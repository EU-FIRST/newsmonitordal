using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace NewsMonitorDAL
{
    public class SqlRow
    {
        public class Entity
        {
            public int Id { get; set; }
            public string EntityUri { get; set; }
            public string EntityLabel { get; set; }
            public string Flags { get; set; }
            public int ClassId { get; set; }
            public int NumDocuments { get; set; }
            public int NumOccurrences { get; set; }
            public DateTime? DataStartTime { get; set; }
            public DateTime? DataEndTime { get; set; }
            public string Features { get; set; }
        }

        public class DayDocument
        {
            public DateTime Date { get; set; }
            public DateTime RetrieveTime { get; set; }
            public string DomainName { get; set; }
            public string Url { get; set; }
            public Guid DocumentId { get; set; }
            public double Index { get; set; }
        }

        public class DocumentFileName
        {
            public string FileName { get; set; }
        }

        public class DayVolume
        {
            public DateTime Date { get; set; }
            public int Volume { get; set; }
        }

        public class DayIndex
        {
            public DateTime Date { get; set; }
            public double Index { get; set; }
        }

        public class DayIndexClasses
        {
            public DateTime Date { get; set; }
            public int Positives { get; set; }
            public int PosNeutrals { get; set; }
            public int Neutrals { get; set; }
            public int NegNeutrals { get; set; }
            public int Negatives { get; set; }
            public int Volume { get; set; }
        }

    }
}