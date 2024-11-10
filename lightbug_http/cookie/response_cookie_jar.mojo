from collections import Optional, List, Dict
from small_time import SmallTime, TimeZone
from small_time.small_time import strptime
from lightbug_http.strings import to_string, lineBreak
from lightbug_http.header import HeaderKey, write_header
from lightbug_http.utils import ByteReader, ByteWriter, is_newline, is_space

@value
struct ResponseCookieJar(Formattable, Stringable):
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

    fn __getitem__(self, key: String) raises -> Cookie:
        return self._inner[key]

    fn get(self, key: String) -> Optional[Cookie]:
        try:
            return self[key]
        except:
            return None

    @always_inline
    fn __contains__(self, key: String) -> Bool:
        return key in self._inner

    fn __str__(self) -> String:
        return to_string(self)

    fn __len__(self) -> Int:
       return len(self._inner)

    @always_inline
    fn set_cookie(inout self, cookie: Cookie):
        self[cookie.name] = cookie

    @always_inline
    fn empty(self) -> Bool:
        return len(self) == 0


    fn from_headers(inout self, headers: List[String]) raises:
        for header in headers:
            try:
                self.set_cookie(Cookie.from_set_header(header[]))
            except:
                raise Error("Failed to parse cookie header string " + header[])

    fn encode_to(inout self, inout writer: ByteWriter):
        for cookie in self._inner.values():
            var v = cookie[].build_header_value()
            write_header(writer, HeaderKey.SET_COOKIE , v)


    fn format_to(self, inout writer: Formatter):
        for cookie in self._inner.values():
            var v = cookie[].build_header_value()
            write_header(writer, HeaderKey.SET_COOKIE , v)
