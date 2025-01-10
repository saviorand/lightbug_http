from memory import Span
from lightbug_http.io.bytes import Bytes, bytes, Byte
from lightbug_http.header import Headers, HeaderKey, Header, write_header
from lightbug_http.cookie import RequestCookieJar
from lightbug_http.uri import URI
from lightbug_http.utils import ByteReader, ByteWriter, logger
from lightbug_http.io.sync import Duration
from lightbug_http.strings import (
    strHttp11,
    strHttp,
    strSlash,
    whitespace,
    rChar,
    nChar,
    lineBreak,
    to_string,
)


@value
struct HTTPRequest(Writable, Stringable):
    var headers: Headers
    var cookies: RequestCookieJar
    var uri: URI
    var body_raw: Bytes

    var method: String
    var protocol: String

    var server_is_tls: Bool
    var timeout: Duration

    @staticmethod
    fn from_bytes(addr: String, max_body_size: Int, b: Span[Byte]) raises -> HTTPRequest:
        var reader = ByteReader(b)
        var headers = Headers()
        var method: String
        var protocol: String
        var uri: String
        try:
            var rest = headers.parse_raw(reader)
            method, uri, protocol = rest[0], rest[1], rest[2]
        except e:
            raise Error("HTTPRequest.from_bytes: Failed to parse request headers: " + str(e))
        
        var cookies = RequestCookieJar()
        try:
            cookies.parse_cookies(headers)
        except e:
            raise Error("HTTPRequest.from_bytes: Failed to parse cookies: " + str(e))

        var content_length = headers.content_length()
        if content_length > 0 and max_body_size > 0 and content_length > max_body_size:
            raise Error("HTTPRequest.from_bytes: Request body too large.")

        var request = HTTPRequest(URI.parse(addr + uri), headers=headers, method=method, protocol=protocol, cookies=cookies)
        try:
            request.read_body(reader, content_length, max_body_size)
        except e:
            raise Error("HTTPRequest.from_bytes: Failed to read request body: " + str(e))

        return request

    fn __init__(
        mut self,
        uri: URI,
        headers: Headers = Headers(),
        cookies: RequestCookieJar = RequestCookieJar(),
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

    fn set_connection_close(mut self):
        self.headers[HeaderKey.CONNECTION] = "close"

    fn set_content_length(mut self, l: Int):
        self.headers[HeaderKey.CONTENT_LENGTH] = str(l)

    fn connection_close(self) -> Bool:
        var result = self.headers.get(HeaderKey.CONNECTION)
        if not result:
            return False
        return result.value() == "close"

    @always_inline
    fn read_body(mut self, mut r: ByteReader, content_length: Int, max_body_size: Int) raises -> None:
        if content_length > max_body_size:
            raise Error("Request body too large")

        self.body_raw = r.read_bytes(content_length)
        self.set_content_length(content_length)

    fn write_to[T: Writer, //](self, mut writer: T):
        path = self.uri.path if len(self.uri.path) > 1 else strSlash
        if len(self.uri.query_string) > 0:
            path.write("?", self.uri.query_string)

        writer.write(
            self.method,
            whitespace,
            path,
            whitespace,
            self.protocol,
            lineBreak,
            self.headers,
            self.cookies,
            lineBreak,
            to_string(self.body_raw)
        )

    fn encode(owned self) -> Bytes:
        """Encodes request as bytes.

        This method consumes the data in this request and it should
        no longer be considered valid.
        """
        var path = self.uri.path if len(self.uri.path) > 1 else strSlash
        if len(self.uri.query_string) > 0:
            path.write("?", self.uri.query_string)
        
        var writer = ByteWriter()
        writer.write(
            self.method,
            whitespace,
            path,
            whitespace,
            self.protocol,
            lineBreak,
            self.headers,
            self.cookies,
            lineBreak,
        )
        writer.consuming_write(self^.body_raw)
        return writer.consume()

    fn __str__(self) -> String:
        return String.write(self)
