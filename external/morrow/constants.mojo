from utils import StaticTuple


# todo: hardcode for tmp
alias _MAX_TIMESTAMP: Int = 32503737600
alias MAX_TIMESTAMP = _MAX_TIMESTAMP
alias MAX_TIMESTAMP_MS = MAX_TIMESTAMP * 1000
alias MAX_TIMESTAMP_US = MAX_TIMESTAMP * 1_000_000

alias _DAYS_IN_MONTH = VariadicList[Int](
    -1, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31
)
alias _DAYS_BEFORE_MONTH = VariadicList[Int](
    -1, 0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334
)  # -1 is a placeholder for indexing purposes.


alias MONTH_NAMES = StaticTuple[StringLiteral, 13](
    "",
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December",
)

alias MONTH_ABBREVIATIONS = StaticTuple[StringLiteral, 13](
    "",
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "May",
    "Jun",
    "Jul",
    "Aug",
    "Sep",
    "Oct",
    "Nov",
    "Dec",
)

alias DAY_NAMES = StaticTuple[StringLiteral, 8](
    "",
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday",
)
alias DAY_ABBREVIATIONS = StaticTuple[StringLiteral, 8](
    "", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"
)
