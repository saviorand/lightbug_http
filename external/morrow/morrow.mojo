from ._py import py_dt_datetime
from .util import normalize_timestamp, rjust, _ymd2ord, _days_before_year
from ._libc import c_gettimeofday, c_localtime, c_gmtime, c_strptime
from ._libc import CTimeval, CTm
from .timezone import TimeZone
from .timedelta import TimeDelta
from .formatter import formatter
from .constants import _DAYS_BEFORE_MONTH, _DAYS_IN_MONTH
from python.object import PythonObject
from python import Python


alias _DI400Y = 146097  # number of days in 400 years
alias _DI100Y = 36524  #    "    "   "   " 100   "
alias _DI4Y = 1461  #    "    "   "   "   4   "


@value
struct Morrow(StringableRaising):
    var year: Int
    var month: Int
    var day: Int
    var hour: Int
    var minute: Int
    var second: Int
    var microsecond: Int
    var tz: TimeZone

    fn __init__(
        inout self,
        year: Int,
        month: Int,
        day: Int,
        hour: Int = 0,
        minute: Int = 0,
        second: Int = 0,
        microsecond: Int = 0,
        tz: TimeZone = TimeZone.none(),
    ) raises:
        self.year = year
        self.month = month
        self.day = day
        self.hour = hour
        self.minute = minute
        self.second = second
        self.microsecond = microsecond
        self.tz = tz

    @staticmethod
    fn now() raises -> Self:
        var t = c_gettimeofday()
        return Self._fromtimestamp(t, False)

    @staticmethod
    fn utcnow() raises -> Self:
        var t = c_gettimeofday()
        return Self._fromtimestamp(t, True)

    @staticmethod
    fn _fromtimestamp(t: CTimeval, utc: Bool) raises -> Self:
        var tm: CTm
        var tz: TimeZone
        if utc:
            tm = c_gmtime(t.tv_sec)
            tz = TimeZone(0, "UTC")
        else:
            tm = c_localtime(t.tv_sec)
            tz = TimeZone(int(tm.tm_gmtoff), "local")

        var result = Self(
            int(tm.tm_year) + 1900,
            int(tm.tm_mon) + 1,
            int(tm.tm_mday),
            int(tm.tm_hour),
            int(tm.tm_min),
            int(tm.tm_sec),
            t.tv_usec,
            tz,
        )
        return result

    @staticmethod
    fn fromtimestamp(timestamp: Float64) raises -> Self:
        var timestamp_ = normalize_timestamp(timestamp)
        var t = CTimeval(int(timestamp_))
        return Self._fromtimestamp(t, False)

    @staticmethod
    fn utcfromtimestamp(timestamp: Float64) raises -> Self:
        var timestamp_ = normalize_timestamp(timestamp)
        var t = CTimeval(int(timestamp_))
        return Self._fromtimestamp(t, True)

    @staticmethod
    fn strptime(
        date_str: String, fmt: String, tzinfo: TimeZone = TimeZone.none()
    ) raises -> Self:
        """
        Create a Morrow instance from a date string and format,
        in the style of ``datetime.strptime``.  Optionally replaces the parsed TimeZone.

        Usage::

        >>> Morrow.strptime('20-01-2019 15:49:10', '%d-%m-%Y %H:%M:%S')
            <Morrow [2019-01-20T15:49:10+00:00]>
        """
        var tm = c_strptime(date_str, fmt)
        var tz = TimeZone(int(tm.tm_gmtoff)) if tzinfo.is_none() else tzinfo
        return Self(
            int(tm.tm_year) + 1900,
            int(tm.tm_mon) + 1,
            int(tm.tm_mday),
            int(tm.tm_hour),
            int(tm.tm_min),
            int(tm.tm_sec),
            0,
            tz,
        )

    @staticmethod
    fn strptime(date_str: String, fmt: String, tz_str: String) raises -> Self:
        """
        Create a Morrow instance by time_zone_string with utc format.

        Usage::

        >>> Morrow.strptime('20-01-2019 15:49:10', '%d-%m-%Y %H:%M:%S', '+08:00')
            <Morrow [2019-01-20T15:49:10+08:00]>
        """
        var tzinfo = TimeZone.from_utc(tz_str)
        return Self.strptime(date_str, fmt, tzinfo)

    fn format(self, fmt: String = "YYYY-MM-DD HH:mm:ss ZZ") raises -> String:
        """Returns a string representation of the `Morrow`
        formatted according to the provided format string.

        :param fmt: the format string.

        Usage::
            >>> var m = Morrow.now()
            >>> m.format('YYYY-MM-DD HH:mm:ss ZZ')
            '2013-05-09 03:56:47 -00:00'

            >>> m.format('MMMM DD, YYYY')
            'May 09, 2013'

            >>> m.format()
            '2013-05-09 03:56:47 -00:00'

        """
        return formatter.format(self, fmt)

    fn isoformat(
        self, sep: String = "T", timespec: StringLiteral = "auto"
    ) raises -> String:
        """Return the time formatted according to ISO.

        The full format looks like 'YYYY-MM-DD HH:MM:SS.mmmmmm'.

        If self.tzinfo is not None, the UTC offset is also attached, giving
        giving a full format of 'YYYY-MM-DD HH:MM:SS.mmmmmm+HH:MM'.

        Optional argument sep specifies the separator between date and
        time, default 'T'.

        The optional argument timespec specifies the number of additional
        terms of the time to include. Valid options are 'auto', 'hours',
        'minutes', 'seconds', 'milliseconds' and 'microseconds'.
        """
        var date_str = (
            rjust(self.year, 4, "0")
            + "-"
            + rjust(self.month, 2, "0")
            + "-"
            + rjust(self.day, 2, "0")
        )
        var time_str = String("")
        if timespec == "auto" or timespec == "microseconds":
            time_str = (
                rjust(self.hour, 2, "0")
                + ":"
                + rjust(self.minute, 2, "0")
                + ":"
                + rjust(self.second, 2, "0")
                + "."
                + rjust(self.microsecond, 6, "0")
            )
        elif timespec == "milliseconds":
            time_str = (
                rjust(self.hour, 2, "0")
                + ":"
                + rjust(self.minute, 2, "0")
                + ":"
                + rjust(self.second, 2, "0")
                + "."
                + rjust(self.microsecond // 1000, 3, "0")
            )
        elif timespec == "seconds":
            time_str = (
                rjust(self.hour, 2, "0")
                + ":"
                + rjust(self.minute, 2, "0")
                + ":"
                + rjust(self.second, 2, "0")
            )
        elif timespec == "minutes":
            time_str = rjust(self.hour, 2, "0") + ":" + rjust(self.minute, 2, "0")
        elif timespec == "hours":
            time_str = rjust(self.hour, 2, "0")
        else:
            raise Error()
        if self.tz.is_none():
            return sep.join(date_str, time_str)
        else:
            return sep.join(date_str, time_str) + self.tz.format()

    fn toordinal(self) raises -> Int:
        """Return proleptic Gregorian ordinal for the year, month and day.

        January 1 of year 1 is day 1.  Only the year, month and day values
        contribute to the result.
        """
        return _ymd2ord(self.year, self.month, self.day)

    @staticmethod
    fn fromordinal(ordinal: Int) raises -> Self:
        """Construct a Morrow from a proleptic Gregorian ordinal.

        January 1 of year 1 is day 1.  Only the year, month and day are
        non-zero in the result.
        """
        # n is a 1-based index, starting at 1-Jan-1.  The pattern of leap years
        # repeats exactly every 400 years.  The basic strategy is to find the
        # closest 400-year boundary at or before n, then work with the offset
        # from that boundary to n.  Life is much clearer if we subtract 1 from
        # n first -- then the values of n at 400-year boundaries are exactly
        # those divisible by _DI400Y:
        #
        #     D  M   Y            n              n-1
        #     -- --- ----        ----------     ----------------
        #     31 Dec -400        -_DI400Y       -_DI400Y -1
        #      1 Jan -399         -_DI400Y +1   -_DI400Y      400-year boundary
        #     ...
        #     30 Dec  000        -1             -2
        #     31 Dec  000         0             -1
        #      1 Jan  001         1              0            400-year boundary
        #      2 Jan  001         2              1
        #      3 Jan  001         3              2
        #     ...
        #     31 Dec  400         _DI400Y        _DI400Y -1
        #      1 Jan  401         _DI400Y +1     _DI400Y      400-year boundary
        var n = ordinal
        n -= 1
        var n400 = n // _DI400Y
        n = n % _DI400Y
        var year = n400 * 400 + 1  # ..., -399, 1, 401, ...

        # Now n is the (non-negative) offset, in days, from January 1 of year, to
        # the desired date.  Now compute how many 100-year cycles precede n.
        # Note that it's possible for n100 to equal 4!  In that case 4 full
        # 100-year cycles precede the desired day, which implies the desired
        # day is December 31 at the end of a 400-year cycle.
        var n100 = n // _DI100Y
        n = n % _DI100Y

        # Now compute how many 4-year cycles precede it.
        var n4 = n // _DI4Y
        n = n % _DI4Y

        # And now how many single years.  Again n1 can be 4, and again meaning
        # that the desired day is December 31 at the end of the 4-year cycle.
        var n1 = n // 365
        n = n % 365

        year += n100 * 100 + n4 * 4 + n1
        if n1 == 4 or n100 == 4:
            return Self(year - 1, 12, 31)

        # Now the year is correct, and n is the offset from January 1.  We find
        # the month via an estimate that's either exact or one too large.
        var leapyear = n1 == 3 and (n4 != 24 or n100 == 3)
        var month = (n + 50) >> 5
        var preceding: Int
        if month > 2 and leapyear:
            preceding = _DAYS_BEFORE_MONTH[month] + 1
        else:
            preceding = _DAYS_BEFORE_MONTH[month]
        if preceding > n:  # estimate is too large
            month -= 1
            if month == 2 and leapyear:
                preceding -= _DAYS_BEFORE_MONTH[month] + 1
            else:
                preceding -= _DAYS_BEFORE_MONTH[month]
        n -= preceding

        # Now the year and month are correct, and n is the offset from the
        # start of that month:  we're done!
        return Self(year, month, n + 1)

    fn isoweekday(self) raises -> Int:
        # "Return day of the week, where Monday == 1 ... Sunday == 7."
        # 1-Jan-0001 is a Monday
        return self.toordinal() % 7 or 7

    fn __str__(self) raises -> String:
        return self.isoformat()

    fn __sub__(self, other: Self) raises -> TimeDelta:
        var days1 = self.toordinal()
        var days2 = other.toordinal()
        var secs1 = self.second + self.minute * 60 + self.hour * 3600
        var secs2 = other.second + other.minute * 60 + other.hour * 3600
        var base = TimeDelta(
            days1 - days2, secs1 - secs2, self.microsecond - other.microsecond
        )
        return base

    fn to_py(self) raises -> PythonObject:
        # todo: add tz later
        var dateimte = Python.import_module("datetime")
        return dateimte.datetime(
            self.year,
            self.month,
            self.day,
            self.hour,
            self.minute,
            self.second,
            self.microsecond,
        )

    @staticmethod
    fn from_py(py_datetime: PythonObject) raises -> Morrow:
        # Python.is_type not working, use __class__.__name__ instead
        if py_datetime.__class__.__name__ == "datetime":
            return Morrow(
                int(py_datetime.year),
                int(py_datetime.month),
                int(py_datetime.day),
                int(py_datetime.hour),
                int(py_datetime.minute),
                int(py_datetime.second),
                int(py_datetime.second),
            )
        elif py_datetime.__class__.__name__ == "date":
            return Morrow(
                int(py_datetime.year),
                int(py_datetime.month),
                int(py_datetime.day),
            )
        else:
            raise Error(
                "invalid python object, only support py builtin datetime or date"
            )
