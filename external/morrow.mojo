# From Morrow package https://github.com/mojoto/morrow.mojo/tree/cc6625e16829acc55bcea060dd2ea5d6a4b6c676
# Including like this until better package management is available

alias _MAX_TIMESTAMP: Int = 32503737600
alias MAX_TIMESTAMP = _MAX_TIMESTAMP
alias MAX_TIMESTAMP_MS = MAX_TIMESTAMP * 1000
alias MAX_TIMESTAMP_US = MAX_TIMESTAMP * 1_000_000


@always_inline
fn c_gettimeofday() -> CTimeval:
    var tv = CTimeval()
    var p_tv = Pointer[CTimeval].address_of(tv)
    external_call["gettimeofday", NoneType, Pointer[CTimeval], Int32](p_tv, 0)
    return tv


@always_inline
fn c_gmtime(owned tv_sec: Int) -> CTm:
    var p_tv_sec = Pointer[Int].address_of(tv_sec)
    var tm = external_call["gmtime", Pointer[CTm], Pointer[Int]](p_tv_sec).load()
    return tm


@always_inline
fn c_localtime(owned tv_sec: Int) -> CTm:
    var p_tv_sec = Pointer[Int].address_of(tv_sec)
    var tm = external_call["localtime", Pointer[CTm], Pointer[Int]](p_tv_sec).load()
    return tm


@value
struct TimeZone:
    var offset: Int
    var name: String

    fn __init__(inout self, offset: Int, name: String = ""):
        self.offset = offset
        self.name = name

    fn __str__(self) -> String:
        return self.name

    fn is_none(self) -> Bool:
        return self.name == "None"

    @staticmethod
    fn none() -> TimeZone:
        return TimeZone(0, "None")

    @staticmethod
    fn local() -> TimeZone:
        var local_t = c_localtime(0)
        return TimeZone(int(local_t.tm_gmtoff), "local")

    @staticmethod
    fn from_utc(utc_str: String) raises -> TimeZone:
        if len(utc_str) == 0:
            raise Error("utc_str is empty")
        if utc_str == "utc" or utc_str == "UTC" or utc_str == "Z":
            return TimeZone(0, "utc")
        var p = 3 if len(utc_str) > 3 and utc_str[0:3] == "UTC" else 0

        var sign = -1 if utc_str[p] == "-" else 1
        if utc_str[p] == "+" or utc_str[p] == "-":
            p += 1

        if (
            len(utc_str) < p + 2
            or not isdigit(ord(utc_str[p]))
            or not isdigit(ord(utc_str[p + 1]))
        ):
            raise Error("utc_str format is invalid")
        var hours: Int = atol(utc_str[p : p + 2])
        p += 2

        var minutes: Int
        if len(utc_str) <= p:
            minutes = 0
        elif len(utc_str) == p + 3 and utc_str[p] == ":":
            minutes = atol(utc_str[p + 1 : p + 3])
        elif len(utc_str) == p + 2 and isdigit(ord(utc_str[p])):
            minutes = atol(utc_str[p : p + 2])
        else:
            minutes = 0
            raise Error("utc_str format is invalid")
        var offset: Int = sign * (hours * 3600 + minutes * 60)
        return TimeZone(offset)

    fn format(self) -> String:
        var sign: String
        var offset_abs: Int
        if self.offset < 0:
            sign = "-"
            offset_abs = -self.offset
        else:
            sign = "+"
            offset_abs = self.offset
        var hh = offset_abs // 3600
        var mm = offset_abs % 3600
        return sign + rjust(hh, 2, "0") + ":" + rjust(mm, 2, "0")


@value
@register_passable("trivial")
struct CTm:
    var tm_sec: Int32  # Seconds
    var tm_min: Int32  # Minutes
    var tm_hour: Int32  # Hour
    var tm_mday: Int32  # Day of the month
    var tm_mon: Int32  # Month
    var tm_year: Int32  # Year minus 1900
    var tm_wday: Int32  # Day of the week
    var tm_yday: Int32  # Day of the year
    var tm_isdst: Int32  # Daylight savings flag
    var tm_gmtoff: Int64  # localtime zone offset seconds

    fn __init__() -> Self:
        return Self {
            tm_sec: 0,
            tm_min: 0,
            tm_hour: 0,
            tm_mday: 0,
            tm_mon: 0,
            tm_year: 0,
            tm_wday: 0,
            tm_yday: 0,
            tm_isdst: 0,
            tm_gmtoff: 0,
        }


@value
struct Morrow:
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

    fn __str__(self) raises -> String:
        return self.isoformat()

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


@value
@register_passable("trivial")
struct CTimeval:
    var tv_sec: Int  # Seconds
    var tv_usec: Int  # Microseconds

    fn __init__(tv_sec: Int = 0, tv_usec: Int = 0) -> Self:
        return Self {tv_sec: tv_sec, tv_usec: tv_usec}


def normalize_timestamp(timestamp: Float64) -> Float64:
    """Normalize millisecond and microsecond timestamps into normal timestamps."""
    if timestamp > MAX_TIMESTAMP:
        if timestamp < MAX_TIMESTAMP_MS:
            timestamp /= 1000
        elif timestamp < MAX_TIMESTAMP_US:
            timestamp /= 1_000_000
        else:
            raise Error(
                "The specified timestamp " + String(timestamp) + "is too large."
            )
    return timestamp


fn _repeat_string(string: String, n: Int) -> String:
    var result: String = ""
    for _ in range(n):
        result += string
    return result


fn rjust(string: String, width: Int, fillchar: String = " ") -> String:
    var extra = width - len(string)
    return _repeat_string(fillchar, extra) + string


fn rjust(string: Int, width: Int, fillchar: String = " ") -> String:
    return rjust(String(string), width, fillchar)
