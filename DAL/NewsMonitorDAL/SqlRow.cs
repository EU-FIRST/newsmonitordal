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
        }

        public class DaySentiment
        {
            public DateTime Date { get; set; }
            public double Sentiment { get; set; }
        }

    }
}