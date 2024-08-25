from .util import rjust

alias SECONDS_OF_DAY = 24 * 3600


struct TimeDelta(Stringable):
    var days: Int
    var seconds: Int
    var microseconds: Int

    fn __init__(
        inout self,
        days: Int = 0,
        seconds: Int = 0,
        microseconds: Int = 0,
        milliseconds: Int = 0,
        minutes: Int = 0,
        hours: Int = 0,
        weeks: Int = 0,
    ):
        self.days = 0
        self.seconds = 0
        self.microseconds = 0

        var days_ = days
        var seconds_ = seconds
        var microseconds_ = microseconds

        # Normalize everything to days, seconds, microseconds.
        days_ += weeks * 7
        seconds_ += minutes * 60 + hours * 3600
        microseconds_ += milliseconds * 1000

        self.days = days_
        days_ = seconds_ // SECONDS_OF_DAY
        seconds_ = seconds_ % SECONDS_OF_DAY
        self.days += days_
        self.seconds += seconds_

        seconds_ = microseconds_ // 1000000
        microseconds_ = microseconds_ % 1000000
        days_ = seconds_ // SECONDS_OF_DAY
        seconds_ = seconds_ % SECONDS_OF_DAY
        self.days += days_
        self.seconds += seconds_

        seconds_ = microseconds_ // 1000000
        self.microseconds = microseconds_ % 1000000
        self.seconds += seconds_
        days_ = self.seconds // SECONDS_OF_DAY
        self.seconds = self.seconds % SECONDS_OF_DAY
        self.days += days_

    fn __copyinit__(inout self, other: Self):
        self.days = other.days
        self.seconds = other.seconds
        self.microseconds = other.microseconds

    fn __str__(self) -> String:
        var mm = self.seconds // 60
        var ss = self.seconds % 60
        var hh = mm // 60
        mm = mm % 60
        var s = String(hh) + ":" + rjust(mm, 2, "0") + ":" + rjust(ss, 2, "0")
        if self.days:
            if abs(self.days) != 1:
                s = String(self.days) + " days, " + s
            else:
                s = String(self.days) + " day, " + s
        if self.microseconds:
            s = s + rjust(self.microseconds, 6, "0")
        return s

    fn total_seconds(self) -> Float64:
        """Total seconds in the duration."""
        return (
            (self.days * 86400 + self.seconds) * 10**6 + self.microseconds
        ) / 10**6

    @always_inline
    fn __add__(self, other: Self) -> Self:
        return Self(
            self.days + other.days,
            self.seconds + other.seconds,
            self.microseconds + other.microseconds,
        )

    fn __radd__(self, other: Self) -> Self:
        return self.__add__(other)

    fn __sub__(self, other: Self) -> Self:
        return Self(
            self.days - other.days,
            self.seconds - other.seconds,
            self.microseconds - other.microseconds,
        )

    fn __rsub__(self, other: Self) -> Self:
        return Self(
            other.days - self.days,
            other.seconds - self.seconds,
            other.microseconds - self.microseconds,
        )

    fn __neg__(self) -> Self:
        return Self(-self.days, -self.seconds, -self.microseconds)

    fn __pos__(self) -> Self:
        return self

    def __abs__(self) -> Self:
        if self.days < 0:
            return -self
        else:
            return self

    @always_inline
    fn __mul__(self, other: Int) -> Self:
        return Self(
            self.days * other,
            self.seconds * other,
            self.microseconds * other,
        )

    fn __rmul__(self, other: Int) -> Self:
        return self.__mul__(other)

    fn _to_microseconds(self) -> Int:
        return (self.days * SECONDS_OF_DAY + self.seconds) * 1000000 + self.microseconds

    fn __mod__(self, other: Self) -> Self:
        var r = self._to_microseconds() % other._to_microseconds()
        return Self(0, 0, r)

    fn __eq__(self, other: Self) -> Bool:
        return (
            self.days == other.days
            and self.seconds == other.seconds
            and self.microseconds == other.microseconds
        )

    @always_inline
    fn __le__(self, other: Self) -> Bool:
        if self.days < other.days:
            return True
        elif self.days == other.days:
            if self.seconds < other.seconds:
                return True
            elif (
                self.seconds == other.seconds
                and self.microseconds <= other.microseconds
            ):
                return True
        return False

    @always_inline
    fn __lt__(self, other: Self) -> Bool:
        if self.days < other.days:
            return True
        elif self.days == other.days:
            if self.seconds < other.seconds:
                return True
            elif (
                self.seconds == other.seconds and self.microseconds < other.microseconds
            ):
                return True
        return False

    fn __ge__(self, other: Self) -> Bool:
        return not self.__lt__(other)

    fn __gt__(self, other: Self) -> Bool:
        return not self.__le__(other)

    fn __bool__(self) -> Bool:
        return self.days != 0 or self.seconds != 0 or self.microseconds != 0


alias Min = TimeDelta(-99999999)
alias Max = TimeDelta(days=99999999)
alias Resolution = TimeDelta(microseconds=1)
