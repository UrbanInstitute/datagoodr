## data-raw/datatypes/datetime.R
## Positive examples for the DATE / TIME family. Seeded from the AutoType
## benchmark's ~25 date files, grouped by representation (multiple AutoType
## files feed one detector). Gregorian + Hijri here; the non-ASCII locale
## calendars (Chinese, German, Spanish) are a separate sub-wave.

## ISO 8601 date (date3)
iso_date <- c(
  "2016-03-15", "2016-03-13", "2016-03-12", "2016-03-11", "2020-01-01",
  "1999-12-31", "2024-02-29", "2000-06-15", "1987-02-06", "2010-11-30"
)

## ISO 8601 datetime, optional fraction/zone (date-s, date6, date7, date-o)
iso_datetime <- c(
  "1987-02-06T06:00:37", "1988-01-12T06:34:58", "1930-07-06T02:08:45",
  "2009-06-15T13:45:30", "2010-06-15T13:45:30", "2009-06-15T13:45:30+02:00",
  "2011-06-15T13:45:30+02:00", "1987-02-06T06:00:37.0000000",
  "2011-06-15T13:45:30Z", "1971-07-15T06:43:21"
)

## US numeric date M/D/YY[YY] (date1)
us_date <- c(
  "3/3/16", "1/27/16", "12/31/99", "7/4/2016", "2/29/2020", "11/9/1989",
  "6/15/2000", "10/1/85", "4/4/04", "9/30/2023"
)

## US numeric datetime with AM/PM (date-g uses /, date9 uses -)
us_datetime <- c(
  "2/6/1987 6:00:37 AM", "1/12/1988 6:34:58 AM", "7/6/1930 2:08:45 AM",
  "7/15/1971 6:43:21 AM", "05-13-2009 12:35 PM", "04-04-2009 12:15 AM",
  "02-02-2010 11:43 PM", "01-30-2009 11:18 AM", "3/15/2016 10:53:29 PM",
  "12-25-2000 08:00 AM"
)

## day-Mon-year with abbreviated month (date2, date10)
abbr_month_date <- c(
  "1-Jul-14", "2-Jul-14", "3-Jul-14", "4-Jul-14", "21/Nov/2012",
  "03/Apr/2013", "02/Feb/2013", "08/May/2013", "15-Aug-99", "31/Dec/2000"
)

## RFC 2822 / HTTP datetime (date-R)
rfc2822_datetime <- c(
  "Fri, 06 Feb 1987 06:00:37 GMT", "Tue, 12 Jan 1988 06:34:58 GMT",
  "Sun, 06 Jul 1930 02:08:45 GMT", "Thu, 15 Jul 1971 06:43:21 GMT",
  "Mon, 01 Jan 2001 00:00:00 GMT", "Wed, 31 Dec 1969 23:59:59 GMT",
  "Sat, 14 Mar 2020 09:15:00 UTC", "Fri, 06 Feb 1987 06:00:37 +0000"
)

## verbose English date (date-d, date-f, date-u, date-mixed, date5, date8, date4)
long_date <- c(
  "Friday, June 16, 1967", "Thursday, June 9, 1955",
  "Wednesday, May 17, 1967", "Friday, June 16, 1967 8:46:44 AM",
  "Friday, February 6, 1987 2:00:37 PM", "Saturday, February 6, 2010",
  "Sunday, January 18, 1976", "Mar 15 2016 10:53:29", "Sun, Mar 8, 2:00 AM",
  "Mon, Aug 11, 3114 BCE", "Thu, Nov 13, 2720 BCE"
)

## Month Year (date-y, date11)
month_year <- c(
  "February 1987", "January 1988", "July 1930", "July 1971",
  "August, 2005", "April, 2001", "June, 2013", "September, 2017",
  "December 2020", "March, 1999"
)

## Compact YYYYMM year-month (e.g. a fiscal reporting period)
yyyymm <- c(
  "201912", "201301", "200006", "199901", "202012",
  "201706", "198802", "203011", "195005", "209912"
)

## Month Day, no year (date-m)
month_day <- c(
  "February 6", "January 12", "July 6", "July 15", "March 1",
  "October 31", "December 25", "May 9", "November 11", "August 20"
)

## clock time (date-t)
clock_time <- c(
  "6:00:37 AM", "6:34:58 AM", "2:08:45 AM", "6:43:21 AM", "11:59 PM",
  "12:00 AM", "23:45", "08:30:15", "1:05 PM", "9:15:00 AM"
)

## date range (daterange1, daterange2)
date_range <- c(
  "07/21/16 to 08/19/16", "08/20/16 to 09/20/16", "09/21/16 to 10/20/16",
  "1972-01-01 - 1972-07-01", "1972-07-01 - 1973-01-01", "1973-01-01 - 1974-01-01",
  "2020-01-01 - 2020-12-31", "01/01/20 to 12/31/20"
)

## Hijri (Islamic-calendar) date (date-hijri)
hijri_date <- c(
  "11 Shawwal 1430", "5 Muharram 1300", "19 Rajab 1460", "6 Muharram 1300",
  "1 Ramadan 1445", "27 Rajab 1440", "10 Muharram 1444", "15 Shaban 1443"
)
