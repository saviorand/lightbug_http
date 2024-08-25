from memory import UnsafePointer
from sys.ffi import external_call

alias c_void = UInt8
alias c_char = UInt8
alias c_schar = Int8
alias c_uchar = UInt8
alias c_short = Int16
alias c_ushort = UInt16
alias c_int = Int32
alias c_uint = UInt32
alias c_long = Int64
alias c_ulong = UInt64
alias c_float = Float32
alias c_double = Float64


@value
@register_passable("trivial")
struct CTimeval:
    var tv_sec: Int  # Seconds
    var tv_usec: Int  # Microseconds

    fn __init__(inout self, tv_sec: Int = 0, tv_usec: Int = 0):
        self.tv_sec = tv_sec
        self.tv_usec = tv_usec


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

    fn __init__(inout self):
        self.tm_sec = 0
        self.tm_min = 0
        self.tm_hour = 0
        self.tm_mday =  0
        self.tm_mon = 0
        self.tm_year = 0
        self.tm_wday = 0
        self.tm_yday = 0
        self.tm_isdst = 0
        self.tm_gmtoff = 0


@always_inline
fn c_gettimeofday() -> CTimeval:
    var tv = CTimeval()
    var p_tv = UnsafePointer[CTimeval].address_of(tv)
    external_call["gettimeofday", NoneType, UnsafePointer[CTimeval], Int32](p_tv, 0)
    return tv


@always_inline
fn c_localtime(owned tv_sec: Int) -> CTm:
    var p_tv_sec = UnsafePointer[Int].address_of(tv_sec)
    var tm = external_call["localtime", UnsafePointer[CTm], UnsafePointer[Int]](p_tv_sec)
    return tm[0]


@always_inline
fn c_strptime(time_str: String, time_format: String) -> CTm:
    var tm = CTm()
    var p_tm = UnsafePointer[CTm].address_of(tm)
    external_call["strptime", NoneType, UnsafePointer[c_char], UnsafePointer[c_char], UnsafePointer[CTm]](
        to_char_ptr(time_str), to_char_ptr(time_format), p_tm
    )
    return tm


@always_inline
fn c_gmtime(owned tv_sec: Int) -> CTm:
    var p_tv_sec = UnsafePointer[Int].address_of(tv_sec)
    var tm = external_call["gmtime", UnsafePointer[CTm], UnsafePointer[Int]](p_tv_sec)
    return tm[0]


fn to_char_ptr(s: String) -> UnsafePointer[c_char]:
    """Only ASCII-based strings."""
    var ptr = UnsafePointer[c_char]().alloc(len(s))
    for i in range(len(s)):
        ptr.store(i, ord(s[i]))
    return ptr
