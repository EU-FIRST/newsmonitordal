﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.ServiceModel.Web;
using System.Web;

namespace NewsMonitorDAL
{
    public class ParameterChecker
    {

        public enum WindowSizeParam
        {
            D,
            W,
            M
        }

        public static string Stock(string stock)
        {
            if (string.IsNullOrWhiteSpace(stock))
                throw new WebFaultException<string>(
                    string.Format("The stock parameter (stock symbol prefixed with $) is required to run this service"),
                    HttpStatusCode.NotAcceptable
                );

            if (!stock.StartsWith("$"))
                throw new WebFaultException<string>(
                    string.Format("The specified stock ({0}) specifier is not valid as it is not prefixed with '$' as required by specification.", stock),
                    HttpStatusCode.NotAcceptable
                );
            return stock.Substring(1);
        }

        public static string WindowSize(string windowSize)
        {
            WindowSizeParam ws;
            if (Enum.TryParse(windowSize, true, out ws))
                return ws.ToString();

            return WindowSizeParam.W.ToString();
        }

        public static EnumTypeT EnumParse<EnumTypeT>(string enumValue, EnumTypeT defaultValue) where EnumTypeT : struct, IConvertible
        {
            if (string.IsNullOrWhiteSpace(enumValue))
                return defaultValue;

            EnumTypeT parsedValue;
            if (Enum.TryParse(enumValue, true, out parsedValue))
                return parsedValue;

            throw new WebFaultException<string>(
                    string.Format("{0} parameter with value '{1}' could not be parsed! Please consult documentation.", typeof(EnumTypeT).Name, enumValue),
                    HttpStatusCode.NotAcceptable);
        }

        public static int PositiveNumber(int maxNumTopics, int defaultValue)
        {
            if (maxNumTopics < 0)
                return defaultValue;
            
            return maxNumTopics;
        }

        public static int StrictlyPositiveNumber(int num, int defaultValue)
        {
            if (num <= 0)
                return defaultValue;
            
            return num;
        }

        public static int ZeroOrOne(int num, int defaultValue)
        {
            if (num < 0 || num >1)
                return defaultValue;

            return num;
        }

        public static TimeSpan StepTimeSpan(TimeSpan stepTimeSpan)
        {
            return new TimeSpan((int) Math.Max(Math.Round(stepTimeSpan.TotalHours), 1), 0, 0);
        }

        public static DateTime DateRoundToHour(DateTime dateTime)
        {
            if (dateTime == DateTime.MinValue) 
                dateTime = DateTime.Now;
            return DateTime.MinValue + new TimeSpan((int)(Math.Round((dateTime - DateTime.MinValue).TotalHours)), 0, 0);
        }
        public static DateTime DateRoundToDayLeaveMin(DateTime dateTime)
        {
            if (dateTime == DateTime.MinValue)
                return dateTime;
            return DateTime.MinValue + new TimeSpan((int)(Math.Round((dateTime - DateTime.MinValue).TotalDays)*24), 0, 0);
        }

        public static bool Boolean(bool groupedZeroPadding)
        {
            return groupedZeroPadding;
        }

        public static void CheckTimeSlotNum(DateTime dateTimeStart, DateTime dateTimeEnd, TimeSpan stepTimeSpan, int maxNumTopics)
        {
            int pointNum = (int)(maxNumTopics * (dateTimeEnd - dateTimeStart).TotalHours / stepTimeSpan.TotalHours);
            int maxPoints = 100000;
            if (pointNum > maxPoints)
                throw new WebFaultException<string>(
                    string.Format("Maximum number of data points is more than allowed ({0}). " +
                                  "The number of data points is calculated by maxNumTopics * (number of stepTimeSpan between dateTimeStart and dateTimeEnd). " +
                                  "Please set these parameters so that they do not exceed the limits. " +
                                  "Current values are: " +
                                  "maxNumTopics={1}, " +
                                  "stepTimeSpan={2}, " +
                                  "dateTimeStart={3}, " +
                                  "dateTimeEnd={4}." +
                                  "Which totals to {5} time points.",
                                  maxPoints, maxNumTopics, stepTimeSpan, dateTimeStart, dateTimeEnd, pointNum),
                    HttpStatusCode.NotAcceptable);
        }

        public static void TimeSpan(ref DateTime from, ref DateTime to, ref int days)
        {
            from = ParameterChecker.DateRoundToDayLeaveMin(from); //inclusive from
            to = ParameterChecker.DateRoundToDayLeaveMin(to); //inclusive to
            days = ParameterChecker.StrictlyPositiveNumber(days, 1);

            // (from & to)
            if (from != DateTime.MinValue && to != DateTime.MinValue)
            {
                if (to < from) to = from;
                days = (int)Math.Round((to - from).TotalDays + 1);
            }
            // (from & !to)
            else if (from != DateTime.MinValue)
            {
                to = from + new TimeSpan(days - 1, 0, 0, 0);
            }
            // (!from & to)
            else if (to != DateTime.MinValue)
            {
                from = to - new TimeSpan(days - 1, 0, 0, 0);
            }
            // (!from & !to)
            else
            {
                to = ParameterChecker.DateRoundToDayLeaveMin(DateTime.Now);
                from = to - new TimeSpan(days - 1, 0, 0, 0);
            }
            //throw new WebFaultException<string>(
            //    string.Format("One of the following sets of parameters must be set: (stock, from, to) or (stock, date) or (stock, days)!"),
            //    HttpStatusCode.NotAcceptable
            //    );
        }


    }
}