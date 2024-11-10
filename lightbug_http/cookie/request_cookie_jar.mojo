from collections import Optional, List, Dict
from small_time import SmallTime, TimeZone
from small_time.small_time import strptime
from lightbug_http.strings import to_string, lineBreak
from lightbug_http.header import HeaderKey, write_header
from lightbug_http.utils import ByteReader, ByteWriter, is_newline, is_space

@value
struct RequestCookieJar(Formattable, Stringable):
    # TODO Key must be a cookie key (containing all attributes except, epxires and max age)
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
