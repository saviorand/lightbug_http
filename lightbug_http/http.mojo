from utils.string_slice import StringSlice
from utils import Span
from small_time.small_time import now
from lightbug_http.uri import URI
from lightbug_http.utils import ByteReader, ByteWriter
from lightbug_http.io.bytes import Bytes, bytes, Byte
from lightbug_http.header import Headers, HeaderKey, Header, write_header
from lightbug_http.io.sync import Duration
from lightbug_http.net import Addr, TCPAddr
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


alias OK_MESSAGE = String("OK").as_bytes()
alias NOT_FOUND_MESSAGE = String("Not Found").as_bytes()
alias TEXT_PLAIN_CONTENT_TYPE = String("text/plain").as_bytes()
alias OCTET_STREAM_CONTENT_TYPE = String("application/octet-stream").as_bytes()


@always_inline
fn encode(owned req: HTTPRequest) -> Bytes:
    return req._encoded()


@always_inline
fn encode(owned res: HTTPResponse) -> Bytes:
    return res._encoded()

@value
struct HTTPRequest(Formattable, Stringable):
    var headers: Headers
    var uri: URI
    var body_raw: Bytes

    var method: String
    var protocol: String

    var server_is_tls: Bool
    var timeout: Duration

    @staticmethod
    fn from_bytes(
        addr: String, max_body_size: Int, owned b: Bytes
    ) raises -> HTTPRequest:
        var reader = ByteReader(b^)
        var headers = Headers()
        var method: String
        var protocol: String
        var uri_str: String
        try:
            method, uri_str, protocol = headers.parse_raw(reader)
        except e:
            raise Error("Failed to parse request headers: " + e.__str__())

        var uri = URI.parse_raises(addr + uri_str)

        var content_length = headers.content_length()

        if (
            content_length > 0
            and max_body_size > 0
            and content_length > max_body_size
        ):
            raise Error("Request body too large")

        var request = HTTPRequest(
            uri, headers=headers, method=method, protocol=protocol
        )

        try:
            request.read_body(reader, content_length, max_body_size)
        except e:
            raise Error("Failed to read request body: " + e.__str__())

        return request

    fn __init__(
        inout self,
        uri: URI,
        headers: Headers = Headers(),
        method: String = "GET",
        protocol: String = strHttp11,
        body: Bytes = Bytes(),
        server_is_tls: Bool = False,
        timeout: Duration = Duration(),
    ):
        self.headers = headers
        self.method = method
        self.protocol = protocol
        self.uri = uri
        self.body_raw = body
        self.server_is_tls = server_is_tls
        self.timeout = timeout
        self.set_content_length(len(body))
        if HeaderKey.CONNECTION not in self.headers:
            self.set_connection_close()

    fn set_connection_close(inout self):
        self.headers[HeaderKey.CONNECTION] = "close"

    fn set_content_length(inout self, l: Int):
        self.headers[HeaderKey.CONTENT_LENGTH] = str(l)

    fn connection_close(self) -> Bool:
        return self.headers[HeaderKey.CONNECTION] == "close"

    @always_inline
    fn read_body(
        inout self, inout r: ByteReader, content_length: Int, max_body_size: Int
    ) raises -> None:
        if content_length > max_body_size:
            raise Error("Request body too large")

        r.consume(self.body_raw)
        self.set_content_length(content_length)

    fn format_to(self, inout writer: Formatter):
        writer.write(
            self.method,
            whitespace,
            self.uri.path if len(self.uri.path) > 1 else strSlash,
            whitespace,
            self.protocol,
            lineBreak,
        )

        self.headers.format_to(writer)
        writer.write(lineBreak)
        writer.write(to_string(self.body_raw))

    fn _encoded(inout self) -> Bytes:
        """Encodes request as bytes.

        This method consumes the data in this request and it should
        no longer be considered valid.
        """
        var writer = ByteWriter()
        writer.write(self.method)
        writer.write(whitespace)
        var path = self.uri.path if len(self.uri.path) > 1 else strSlash
        writer.write(path)
        writer.write(whitespace)
        writer.write(self.protocol)
        writer.write(lineBreak)

        self.headers.encode_to(writer)
        writer.write(lineBreak)

        writer.write(self.body_raw)

        return writer.consume()

    fn __str__(self) -> String:
        return to_string(self)


@value
struct HTTPResponse(Formattable, Stringable):
    var headers: Headers
    var body_raw: Bytes
    var skip_reading_writing_body: Bool
    var raddr: TCPAddr
    var laddr: TCPAddr
    var __is_upgrade: Bool

    var status_code: Int
    var status_text: String
    var protocol: String

    @staticmethod
    fn from_bytes(owned b: Bytes) raises -> HTTPResponse:
        var reader = ByteReader(b^)

        var headers = Headers()
        var protocol: String
        var status_code: String
        var status_text: String

        try:
            protocol, status_code, status_text = headers.parse_raw(reader)
        except e:
            raise Error("Failed to parse response headers: " + e.__str__())

        var response = HTTPResponse(
            Bytes(),
            headers=headers,
            protocol=protocol,
            status_code=int(status_code),
            status_text=status_text,
        )

        try:
            response.read_body(reader)
            return response
        except e:
            raise Error("Failed to read request body: " + e.__str__())

    fn __init__(
        inout self,
        body_bytes: Bytes,
        headers: Headers = Headers(),
        status_code: Int = 200,
        status_text: String = "OK",
        protocol: String = strHttp11,
    ):
        self.headers = headers
        if HeaderKey.CONTENT_TYPE not in self.headers:
            self.headers[HeaderKey.CONTENT_TYPE] = "application/octet-stream"
        self.status_code = status_code
        self.status_text = status_text
        self.protocol = protocol
        self.body_raw = body_bytes
        self.skip_reading_writing_body = False
        self.__is_upgrade = False
        self.raddr = TCPAddr()
        self.laddr = TCPAddr()
        self.set_connection_keep_alive()
        self.set_content_length(len(body_bytes))

    fn get_body_bytes(self) -> Bytes:
        return self.body_raw

    @always_inline
    fn set_connection_close(inout self):
        self.headers[HeaderKey.CONNECTION] = "close"

    @always_inline
    fn set_connection_keep_alive(inout self):
        self.headers[HeaderKey.CONNECTION] = "keep-alive"

    fn connection_close(self) -> Bool:
        return self.headers[HeaderKey.CONNECTION] == "close"

    @always_inline
    fn set_content_length(inout self, l: Int):
        self.headers[HeaderKey.CONTENT_LENGTH] = str(l)

    @always_inline
    fn read_body(inout self, inout r: ByteReader) raises -> None:
        r.consume(self.body_raw)

    fn format_to(self, inout writer: Formatter):
        writer.write(
            self.protocol,
            whitespace,
            self.status_code,
            whitespace,
            self.status_text,
            lineBreak,
            "server: lightbug_http",
            lineBreak,
        )

        if HeaderKey.DATE not in self.headers:
            try:
                var current_time = now(utc=True).__str__()
                write_header(writer, HeaderKey.DATE, current_time)
            except:
                pass

        self.headers.format_to(writer)

        writer.write(lineBreak)
        writer.write(to_string(self.body_raw))

    fn _encoded(inout self) -> Bytes:
        """Encodes response as bytes.

        This method consumes the data in this request and it should
        no longer be considered valid.
        """
        var writer = ByteWriter()
        writer.write(self.protocol)
        writer.write(whitespace)
        writer.write(bytes(str(self.status_code)))
        writer.write(whitespace)
        writer.write(self.status_text)
        writer.write(lineBreak)
        writer.write("server: lightbug_http")
        writer.write(lineBreak)

        if HeaderKey.DATE not in self.headers:
            try:
                var current_time = now(utc=True).__str__()
                write_header(writer, HeaderKey.DATE, current_time)
            except:
                pass

        self.headers.encode_to(writer)

        writer.write(lineBreak)
        writer.write(self.body_raw)

        return writer.consume()

    fn __str__(self) -> String:
        return to_string(self)


fn OK(body: String) -> HTTPResponse:
    return HTTPResponse(
        headers=Headers(Header(HeaderKey.CONTENT_TYPE, "text/plain")),
        body_bytes=bytes(body),
    )


fn OK(body: String, content_type: String) -> HTTPResponse:
    return HTTPResponse(
        headers=Headers(Header(HeaderKey.CONTENT_TYPE, content_type)),
        body_bytes=bytes(body),
    )


fn OK(body: Bytes) -> HTTPResponse:
    return HTTPResponse(
        headers=Headers(Header(HeaderKey.CONTENT_TYPE, "text/plain")),
        body_bytes=body,
    )


fn OK(body: Bytes, content_type: String) -> HTTPResponse:
    return HTTPResponse(
        headers=Headers(Header(HeaderKey.CONTENT_TYPE, content_type)),
        body_bytes=body,
    )


fn OK(
    body: Bytes, content_type: String, content_encoding: String
) -> HTTPResponse:
    return HTTPResponse(
        headers=Headers(
            Header(HeaderKey.CONTENT_TYPE, content_type),
            Header(HeaderKey.CONTENT_ENCODING, content_encoding),
        ),
        body_bytes=body,
    )


fn NotFound(path: String) -> HTTPResponse:
    return HTTPResponse(
        status_code=404,
        status_text="Not Found",
        headers=Headers(Header(HeaderKey.CONTENT_TYPE, "text/plain")),
        body_bytes=bytes("path " + path + " not found"),
    )
