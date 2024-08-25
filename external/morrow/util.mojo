from collections.vector import DynamicVector

from .constants import MAX_TIMESTAMP, MAX_TIMESTAMP_MS, MAX_TIMESTAMP_US
from .constants import _DAYS_IN_MONTH, _DAYS_BEFORE_MONTH


fn _is_leap(year: Int) -> Bool:
    "year -> 1 if leap year, else 0."
    return year % 4 == 0 and (year % 100 != 0 or year % 400 == 0)


def _days_before_year(year: Int) -> Int:
    "year -> number of days before January 1st of year."
    var y = year - 1
    return y * 365 + y // 4 - y // 100 + y // 400


def _days_in_month(year: Int, month: Int) -> Int:
    "year, month -> number of days in that month in that year."
    if month == 2 and _is_leap(year):
        return 29
    return _DAYS_IN_MONTH[month]


def _days_before_month(year: Int, month: Int) -> Int:
    "year, month -> number of days in year preceding first day of month."
    if month > 2 and _is_leap(year):
        return _DAYS_BEFORE_MONTH[month] + 1
    return _DAYS_BEFORE_MONTH[month]


@always_inline
def _ymd2ord(year: Int, month: Int, day: Int) -> Int:
    "year, month, day -> ordinal, considering 01-Jan-0001 as day 1."
    dim = _days_in_month(year, month)
    return _days_before_year(year) + _days_before_month(year, month) + day


def normalize_timestamp(timestamp: Float64) -> Float64:
    """Normalize millisecond and microsecond timestamps into normal timestamps."""
    if timestamp > MAX_TIMESTAMP:
        if timestamp < MAX_TIMESTAMP_MS:
            timestamp /= 1000
        elif timestamp < MAX_TIMESTAMP_US:
            timestamp /= 1_000_000
        else:
            raise Error(
                "The specified timestamp " + timestamp + "is too large."
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
    return rjust(string, width, fillchar)
