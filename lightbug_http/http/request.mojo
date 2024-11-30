from lightbug_http.io.bytes import Bytes, bytes, Byte
from lightbug_http.header import Headers, HeaderKey, Header, write_header
from lightbug_http.cookie import RequestCookieJar
from lightbug_http.uri import URI
from lightbug_http.utils import ByteReader, ByteWriter
from lightbug_http.io.sync import Duration
from lightbug_http.strings import (
    Encodable,
    Parsable,
    strHttp11,
    strHttp,
    strSlash,
    whitespace,
    lineBreak,
    to_string,
)

@value
struct HTTPRequest[HeaderType: Parsable, CookieType: Parsable](Formattable, Stringable, Encodable):
    var headers: HeaderType
    var cookies: CookieType
    var uri: URI
    var body_raw: Bytes

    var method: String
    var protocol: String

    var server_is_tls: Bool
    var timeout: Duration

    @staticmethod
    fn from_bytes(addr: String, max_body_size: Int, owned b: Bytes) raises -> HTTPRequest[HeaderType, CookieType]:
        var reader = ByteReader(b^)
        var headers = HeaderType()
        var cookies = CookieType()
        var method: String
        var protocol: String
        var uri_str: String

        try:
            var rest = headers.parse_raw(reader)
            method, uri_str, protocol = rest[0], rest[1], rest[2]
        except e:
            raise Error("Failed to parse request headers: " + e.__str__())

        try:
            cookies.parse(reader)
        except e:
            raise Error("Failed to parse cookies: " + e.__str__())

        var uri = URI.parse_raises(addr + uri_str)

        var content_length = headers.content_length()
        if content_length > 0 and max_body_size > 0 and content_length > max_body_size:
            raise Error("Request body too large")

        var request = HTTPRequest(
            uri,
            headers=headers,
            cookies=cookies,
            method=method,
            protocol=protocol,
        )

        try:
            request.read_body(reader, content_length, max_body_size)
        except e:
            raise Error("Failed to read request body: " + e.__str__())

        return request

    fn __init__(
        inout self,
        uri: URI,
        headers: HeaderType = HeaderType(),
        cookies: CookieType = CookieType(),
        method: String = "GET",
        protocol: String = strHttp11,
        body: Bytes = Bytes(),
        server_is_tls: Bool = False,
        timeout: Duration = Duration(),
    ):
        self.headers = headers
        self.cookies = cookies
        self.method = method
        self.protocol = protocol
        self.uri = uri
        self.body_raw = body
        self.server_is_tls = server_is_tls
        self.timeout = timeout
        self.set_content_length(len(body))

        if HeaderKey.CONNECTION not in self.headers:
            self.headers[HeaderKey.CONNECTION] = "keep-alive"
        if HeaderKey.HOST not in self.headers:
            self.headers[HeaderKey.HOST] = uri.host

    fn set_connection_close(inout self):
        self.headers[HeaderKey.CONNECTION] = "close"

    fn set_content_length(inout self, l: Int):
        self.headers[HeaderKey.CONTENT_LENGTH] = str(l)

    fn connection_close(self) -> Bool:
        return self.headers[HeaderKey.CONNECTION] == "close"

    @always_inline
    fn read_body(inout self, inout r: ByteReader, content_length: Int, max_body_size: Int) raises -> None:
        if content_length > max_body_size:
            raise Error("Request body too large")

        r.consume(self.body_raw, content_length)
        self.set_content_length(content_length)

    fn format_to(self, inout writer: Formatter):
        writer.write(self.method, whitespace)
        var path = self.uri.path if len(self.uri.path) > 1 else strSlash
        if len(self.uri.query_string) > 0:
            path += "?" + self.uri.query_string

        writer.write(path)
        writer.write(whitespace, self.protocol, lineBreak)

        self.headers.format_to(writer)
        self.cookies.format_to(writer)
        writer.write(lineBreak)
        writer.write(to_string(self.body_raw))

    fn encode(self) -> Bytes:
        var writer = ByteWriter()
        writer.write(self.method)
        writer.write(whitespace)
        var path = self.uri.path if len(self.uri.path) > 1 else strSlash
        if len(self.uri.query_string) > 0:
            path += "?" + self.uri.query_string
        writer.write(path)
        writer.write(whitespace)
        writer.write(self.protocol)
        writer.write(lineBreak)

        self.headers.encode_to(writer)
        self.cookies.encode_to(writer)
        writer.write(lineBreak)
        writer.write(self.body_raw)

        return writer.consume()

    fn __str__(self) -> String:
        return to_string(self)
