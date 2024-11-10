from collections import Optional, List, Dict
from small_time import SmallTime, TimeZone
from lightbug_http.strings import to_string, lineBreak
from lightbug_http.header import HeaderKey, write_header
from lightbug_http.utils import ByteReader, ByteWriter, is_newline, is_space

alias HTTP_DATE_FORMAT = "ddd, DD MMM YYYY HH:mm:ss ZZZ"
alias TZ_GMT = TimeZone(0, "GMT")

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

    @staticmethod
    fn from_string(str: String) -> Optional[Self]:
        try:
            return Self(seconds=int(str))
        except:
            return None



@value
struct SameSite():
    var value : UInt8

    alias none = SameSite(0)
    alias lax = SameSite(1)
    alias strict = SameSite(2)

    alias NONE = "none"
    alias LAX = "lax"
    alias STRICT = "strict"

    @staticmethod
    fn from_str(str: String) -> Optional[Self]:
        if str == SameSite.NONE:
            return SameSite.none
        elif str == SameSite.LAX:
            return SameSite.lax
        elif str == SameSite.STRICT:
            return SameSite.strict
        return None

    fn __eq__(self, other: Self) -> Bool:
        return self.value == other.value

    fn __str__(self) -> String:
        if self.value == 0:
            return SameSite.NONE
        elif self.value == 1:
            return SameSite.LAX
        else:
            return SameSite.STRICT


@value
struct Expiration:
    var variant: UInt8
    var datetime: Optional[SmallTime]

    @staticmethod
    fn session() -> Self:
        return Self(variant=0, datetime=None)

    @staticmethod
    fn from_datetime(time: SmallTime) -> Self:
        return Self(variant=1, datetime=time)

    @staticmethod
    fn from_string(str: String) -> Optional[Self]:
        try:
            return SmallTime.strptime(str, HTTP_DATE_FORMAT, TimeZone(0, "GMT"))
        except:
            return None

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
        dt.tz =  TimeZone(0, "GMT")
        return Optional[String](dt.format(HTTP_DATE_FORMAT))

    fn __eq__(self, other: Self) -> Bool:
        if self.variant != other.variant:
            return False
        if self.variant == 1:
            return self.datetime == other.datetime
        return True


struct Cookie(CollectionElement):
    alias EXPIRES = "Expires"
    alias MAX_AGE = "Max-Age"
    alias DOMAIN = "Domain"
    alias PATH = "Path"
    alias SECURE = "Secure"
    alias HTTP_ONLY = "HttpOnly"
    alias SAME_SITE = "SameSite"
    alias PARTITIONED = "Partitioned"

    alias SEPERATOR = "; "
    alias EQUAL = "="

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


    @staticmethod
    fn from_set_header(header_str: String) -> Self raises:
        var parts = header_str.split(Cookie.SEPERATOR)
        if len(parts) < 1:
            raise Error("invalid Cookie")

        if Cookie.EQUAL in parts[0]:
            var name_value = parts[0].split(Cookie.EQUAL)
            var cookie = Cookie(name_value[0], name_value[1])
        else:
            var cookie = Cookie("", part[0])

        for i in range(1, len(parts)):
            var part = parts[i]
            if part == Cookie.PARTITIONED:
                cookie.paritioned = True
            elif part == Cookie.SECURE:
                cookie.secure = True
            elif part == Cookie.HTTP_ONLY:
                cookie.http_only = True
            elif part.startswith(Cookie.SAME_SITE):
                cookie.same_site = SameSite.from_string(part.removesuffix(Cookie.SAME_SITE + Cookie.EQUAL))
            elif part.startswith(Cookie.DOMAIN):
                cookie.domain = part.removesuffix(Cookie.DOMAIN + Cookie.equal)
            elif part.startswith(Cookie.PATH):
                cookie.path = part.removesuffix(Cookie.PATH + Cookie.equal)
            elif part.startswith(Cookie.MAX_AGE):
                cookie.max_age = Duration.from_string(part.removesuffix(Cookie.MAX_AGE + Cookie.EQUAL))
            elif part.startswith(Cookie.EXPIRES):
                var expires =  Expiration.from_string(part.removesuffix(Cookie.EXPIRES + Cookie.EQUAL))
                if expires:
                    cookie.expires = expires.value()
        return cookie

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

    fn __copyinit__(inout self: Cookie, existing: Cookie):
        self.name = existing.name
        self.value = existing.value
        self.max_age = existing.max_age
        self.expires = existing.expires
        self.domain = existing.domain
        self.path = existing.path
        self.secure = existing.secure
        self.http_only = existing.http_only
        self.same_site = existing.same_site
        self.partitioned = existing.partitioned

    fn __moveinit__(inout self: Cookie, owned existing: Cookie):
        self.name = existing.name
        self.value = existing.value
        self.max_age = existing.max_age
        self.expires = existing.expires
        self.domain = existing.domain
        self.path = existing.path
        self.secure = existing.secure
        self.http_only = existing.http_only
        self.same_site = existing.same_site
        self.partitioned = existing.partitioned

    fn clear_cookie(inout self):
        self.max_age = Optional[Duration](None)
        self.expires = Expiration.invalidate()

    fn to_header(self) -> Header:
        return Header(HeaderKey.SET_COOKIE, self.build_header_value())

    fn build_header_value(self) -> String:

        var header_value = self.name + Cookie.EQUAL + self.value
        if self.expires.is_datetime():
            var v = self.expires.http_date_timestamp()
            if v:
                header_value += Cookie.SEPERATOR + Cookie.EXPIRES + Cookie.EQUAL + v.value()
        if self.max_age:
            header_value += Cookie.SEPERATOR + Cookie.MAX_AGE + Cookie.EQUAL + str(self.max_age.value().seconds)
        if self.domain:
            header_value += Cookie.SEPERATOR + Cookie.DOMAIN + Cookie.EQUAL + self.domain.value()
        if self.path:
            header_value += Cookie.SEPERATOR + Cookie.PATH + Cookie.EQUAL + self.path.value()
        if self.secure:
            header_value += Cookie.SEPERATOR + Cookie.SECURE
        if self.http_only:
            header_value += Cookie.SEPERATOR + Cookie.HTTP_ONLY
        if self.same_site:
            header_value += Cookie.SEPERATOR + Cookie.SAME_SITE + Cookie.EQUAL + str(self.same_site.value())
        if self.partitioned:
            header_value += Cookie.SEPERATOR + Cookie.PARTITIONED
        return header_value


@value
struct SetCookies(Formattable, Stringable):
    var _inner: Dict[String, Cookie]

    fn __init__(inout self):
        self._inner = Dict[String, Cookie]()

    fn __init__(inout self, *cookies: Cookie):
        self._inner = Dict[String, Cookie]()
        for cookie in cookies:
            self.set_cookie(cookie[])

    @always_inline
    fn __setitem__(inout self, key: String, value: Cookie):
        self._inner[key] = value

    @always_inline
    fn set_cookie(inout self, cookie: Cookie):
        self[cookie.name] = cookie

    @always_inline
    fn empty(self) -> Bool:
        return len(self._inner) == 0

    @always_inline
    fn __contains__(self, key: Cookie) -> Bool:
        return cookie.name in self._inner

    fn from_header(inout self, headers: List[String]) raises:
        for header in headers:
            try:
                self.set_cookie(Cookie.from_set_header(header[]))
            except:
                raise Error("Failed to parse cookie header string " + header[])

    fn encode_to(inout self, inout writer: ByteWriter):
        for cookie in self._inner.values():
            var v = cookie[].build_header_value()
            write_header(writer, HeaderKey.SET_COOKIE , v)

    fn __str__(self) -> String:
        return to_string(self)

    fn format_to(self, inout writer: Formatter):
        for cookie in self._inner.items():
            writer.write(cookie[].key)


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
