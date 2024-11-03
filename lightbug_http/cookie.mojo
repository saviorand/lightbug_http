from collections import Optional, List, Dict
from small_time import SmallTime, TimeZone
from lightbug_http.strings import to_string, lineBreak
from lightbug_http.header import HeaderKey

@value
struct Duration():
    var seconds: Int

    fn __init__(
        inout self,
        seconds: Int = 0,
        minutes: Int = 0,
        hours: Int = 0,
        days: Int = 0
    ):
        self.seconds = seconds
        self.seconds += minutes * 60
        self.seconds += hours * 60 * 60
        self.seconds += days * 24 * 60 * 60


@value
struct SameSite():
    var value : UInt8

    alias none = SameSite(0)
    alias lax = SameSite(1)
    alias strict = SameSite(2)

    fn __eq__(self, other: Self) -> Bool:
        return self.value == other.value

    fn __str__(self) -> String:
        if self.value == 0:
            return "none"
        elif self.value == 1:
            return "lax"
        else:
            return "strict"


@value
struct Expiration:
    var variant: UInt8
    var datetime: Optional[SmallTime]

    @staticmethod
    fn session() -> Self:
        return Self(variant=0, datetime=None)

    @staticmethod
    fn dateTime(time: SmallTime) -> Self:
        return Self(variant=1, datetime=time)

    @staticmethod
    fn invalidate() -> Self:
        return Self(variant=1, datetime=SmallTime(1970, 1, 1, 0, 0, 0, 0))

    fn is_session(self) -> Bool:
        return self.variant == 0

    fn is_datetime(self) -> Bool:
        return self.variant == 1

    fn http_date_timestamp(self) -> Optional[String]:
        if not self.datetime:
            return Optional[String](None)

        # TODO fix this it breaks time and space (replacing timezone might add or remove something sometimes)
        var dt = self.datetime.value()
        dt.tz = TimeZone(0, "GMT")
        return Optional[String](dt.format("ddd, DD MMM YYYY HH:mm:ss ZZZ"))

    fn __eq__(self, other: Self) -> Bool:
        if self.variant != other.variant:
            return False
        if self.variant == 1:
            return self.datetime == other.datetime
        return True


struct Cookie():
    alias EXPIRES = "Expires"
    alias MAX_AGE = "Max-Age"
    alias DOMAIN = "Domain"
    alias PATH = "Path"
    alias SECURE = "Secure"
    alias HTTP_ONLY = "HttpOnly"
    alias SAME_SITE = "SameSite"
    alias PARTITIONED = "Partitioned"

    var name: String
    var value: String
    var expires: Expiration
    var secure: Bool
    var http_only: Bool
    var partitioned: Bool
    var same_site: Optional[SameSite]
    var domain: Optional[String]
    var path: Optional[String]
    var max_age: Optional[Duration]

    fn __init__(
        inout self,
        name: String,
        value: String,
        expires: Expiration = Expiration.session(),
        max_age: Optional[Duration] = Optional[Duration](None),
        domain: Optional[String] = Optional[String](None),
        path: Optional[String] = Optional[String](None),
        same_site: Optional[SameSite] = Optional[SameSite](None),
        secure: Bool = False,
        http_only: Bool = False,
        partitioned: Bool = False,
    ):
        self.name = name
        self.value = value
        self.expires = expires
        self.max_age = max_age
        self.domain = domain
        self.path = path
        self.secure = secure
        self.http_only = http_only
        self.same_site = same_site
        self.partitioned = partitioned

    fn clear_cookie(inout self):
        self.max_age = Optional[Duration](None)
        self.expires = Expiration.invalidate()

    fn to_header(self) -> Header:
        return Header(HeaderKey.SET_COOKIE, self.build_header_value())

    fn build_header_value(self) -> String:
        alias seperator = "; "
        alias equal = "="
        var header_value = self.name + equal + self.value
        if self.expires.is_datetime():
            var v = self.expires.http_date_timestamp()
            if v:
                header_value += seperator + Cookie.EXPIRES + equal + v.value()
        if self.max_age:
            header_value += seperator + Cookie.MAX_AGE + equal + str(self.max_age.value().seconds)
        if self.domain:
            header_value += seperator + Cookie.DOMAIN + equal + self.domain.value()
        if self.path:
            header_value += seperator + Cookie.PATH + equal + self.path.value()
        if self.secure:
            header_value += seperator + Cookie.SECURE
        if self.http_only:
            header_value += seperator + Cookie.HTTP_ONLY
        if self.same_site:
            header_value += seperator + Cookie.SAME_SITE + equal + str(self.same_site.value())
        if self.partitioned:
            header_value += seperator + Cookie.PARTITIONED
        return header_value


@value
struct Cookies(Formattable, Stringable):
    var _inner: Dict[String, String]

    fn __init__(inout self):
        self._inner = Dict[String, String]()

    fn parse_cookies(inout self, headers: Headers) raises:
        var cookie_header = headers[HeaderKey.COOKIE]
        if not cookie_header:
            return None
        var cookie_strings = cookie_header.split("; ")

        for chunk in cookie_strings:
            var key = String("")
            var value = chunk[]
            if "=" in chunk[]:
                var key_value = chunk[].split("=")
                key = key_value[0]
                value = key_value[1]

            # TODO value must be "unquoted"
            self._inner[key] = value


    @always_inline
    fn empty(self) -> Bool:
        return len(self._inner) == 0

    @always_inline
    fn __contains__(self, key: String) -> Bool:
        return key.lower() in self._inner

    @always_inline
    fn __getitem__(self, key: String) -> Optional[String]:
        try:
            return self._inner[key.lower()]
        except:
            return None

    fn to_header(self) -> Optional[Header]:
        alias equal = "="
        if len(self._inner) == 0:
            return None

        var header_value = List[String]()
        for cookie in self._inner.items():
            header_value.append(cookie[].key + equal + cookie[].value)
        return Header(HeaderKey.COOKIE, "; ".join(header_value))


    fn write_cookie(self, inout writer: Formatter, key: String, value: String):
        writer.write(key + ": ", value, lineBreak)

    fn format_to(self, inout writer: Formatter):
        for cookie in self._inner.items():
            self.write_cookie(writer, cookie[].key, cookie[].value)

    fn __str__(self) -> String:
        return to_string(self)
