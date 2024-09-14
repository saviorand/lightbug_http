from utils.string_slice import StringSlice
from utils import Span
from gojo.strings.builder import StringBuilder
from gojo.bufio import Reader
from small_time.small_time import now
from lightbug_http.uri import URI
from lightbug_http.io.bytes import Bytes, bytes
from lightbug_http.header import RequestHeader, ResponseHeader
from lightbug_http.io.sync import Duration
from lightbug_http.net import Addr, TCPAddr
from lightbug_http.strings import strHttp11, strHttp, strSlash, whitespace, rChar, nChar


alias OK_MESSAGE = String("OK").as_bytes()
alias NOT_FOUND_MESSAGE = String("Not Found").as_bytes()
alias TEXT_PLAIN_CONTENT_TYPE = String("text/plain").as_bytes()
alias OCTET_STREAM_CONTENT_TYPE = String("application/octet-stream").as_bytes()

trait Request:
    fn __init__(inout self, uri: URI):
        ...

    fn __init__(
        inout self,
        header: RequestHeader,
        uri: URI,
        body: Bytes,
        parsed_uri: Bool,
        server_is_tls: Bool,
        timeout: Duration,
        disable_redirect_path_normalization: Bool,
    ):
        ...

    fn set_host(inout self, host: String) -> Self:
        ...

    fn set_host_bytes(inout self, host: Bytes) -> Self:
        ...

    fn host(self) -> String:
        ...

    fn set_request_uri(inout self, request_uri: String) -> Self:
        ...

    fn set_request_uri_bytes(inout self, request_uri: Bytes) -> Self:
        ...

    fn request_uri(inout self) -> String:
        ...

    fn set_connection_close(inout self) -> Self:
        ...

    fn connection_close(self) -> Bool:
        ...


trait Response:
    fn __init__(inout self, header: ResponseHeader, body: Bytes):
        ...

    fn set_status_code(inout self, status_code: Int) -> Self:
        ...

    fn status_code(self) -> Int:
        ...

    fn set_connection_close(inout self) -> Self:
        ...

    fn connection_close(self) -> Bool:
        ...


@value
struct HTTPRequest(Request):
    var header: RequestHeader
    var __uri: URI
    var body_raw: Bytes

    var parsed_uri: Bool
    var server_is_tls: Bool
    var timeout: Duration
    var disable_redirect_path_normalization: Bool

    fn __init__(inout self, uri: URI):
        self.header = RequestHeader("127.0.0.1")
        self.__uri = uri
        self.body_raw = Bytes()
        self.parsed_uri = False
        self.server_is_tls = False
        self.timeout = Duration()
        self.disable_redirect_path_normalization = False

    fn __init__(inout self, uri: URI, headers: RequestHeader):
        self.header = headers
        self.__uri = uri
        self.body_raw = Bytes()
        self.parsed_uri = False
        self.server_is_tls = False
        self.timeout = Duration()
        self.disable_redirect_path_normalization = False

    fn __init__(inout self, uri: URI, buf: Bytes, headers: RequestHeader):
        self.header = headers
        self.__uri = uri
        self.body_raw = buf
        self.parsed_uri = False
        self.server_is_tls = False
        self.timeout = Duration()
        self.disable_redirect_path_normalization = False

    fn __init__(
        inout self,
        header: RequestHeader,
        uri: URI,
        body: Bytes,
        parsed_uri: Bool,
        server_is_tls: Bool,
        timeout: Duration,
        disable_redirect_path_normalization: Bool,
    ):
        self.header = header
        self.__uri = uri
        self.body_raw = body
        self.parsed_uri = parsed_uri
        self.server_is_tls = server_is_tls
        self.timeout = timeout
        self.disable_redirect_path_normalization = disable_redirect_path_normalization

    fn get_body_bytes(self) -> Span[UInt8, __lifetime_of(self)]:
        return Span[UInt8, __lifetime_of(self)](self.body_raw)

    fn set_body_bytes(inout self, body: Bytes) -> Self:
        self.body_raw = body
        return self

    fn set_host(inout self, host: String) -> Self:
        _ = self.__uri.set_host(host)
        return self

    fn set_host_bytes(inout self, host: Bytes) -> Self:
        _ = self.__uri.set_host_bytes(host)
        return self

    fn host(self) -> String:
        return self.__uri.host_str()

    fn set_request_uri(inout self, request_uri: String) -> Self:
        _ = self.header.set_request_uri(request_uri.as_bytes())
        self.parsed_uri = False
        return self

    fn set_request_uri_bytes(inout self, request_uri: Bytes) -> Self:
        _ = self.header.set_request_uri_bytes(request_uri)
        return self

    fn request_uri(inout self) -> String:
        if self.parsed_uri:
            _ = self.set_request_uri_bytes(self.__uri.request_uri())
        return self.header.request_uri()

    fn uri(self) -> URI:
        return self.__uri

    fn set_connection_close(inout self) -> Self:
        _ = self.header.set_connection_close()
        return self

    fn connection_close(self) -> Bool:
        return self.header.connection_close()
    
    fn read_body(inout self, inout r: Reader, content_length: Int, header_len: Int, max_body_size: Int) raises -> None:
        if content_length > max_body_size:
            raise Error("Request body too large")

        _ = r.discard(header_len)

        var body_buf_result = r.peek(r.buffered())
        var body_buf = body_buf_result[0]
        
        _ = self.set_body_bytes(body_buf)

@value
struct HTTPResponse(Response):
    var header: ResponseHeader
    var stream_immediate_header_flush: Bool
    var stream_body: Bool
    var body_raw: Bytes
    var skip_reading_writing_body: Bool
    var raddr: TCPAddr
    var laddr: TCPAddr

    fn __init__(inout self, body_bytes: Bytes):
        self.header = ResponseHeader(
            200,
            OK_MESSAGE,
            OCTET_STREAM_CONTENT_TYPE,
        )
        self.stream_immediate_header_flush = False
        self.stream_body = False
        self.body_raw = body_bytes
        self.skip_reading_writing_body = False
        self.raddr = TCPAddr()
        self.laddr = TCPAddr()

    fn __init__(inout self, header: ResponseHeader, body_bytes: Bytes):
        self.header = header
        self.stream_immediate_header_flush = False
        self.stream_body = False
        self.body_raw = body_bytes
        self.skip_reading_writing_body = False
        self.raddr = TCPAddr()
        self.laddr = TCPAddr()
    
    fn get_body_bytes(self) -> Span[UInt8, __lifetime_of(self)]:
        return Span[UInt8, __lifetime_of(self)](self.body_raw)

    fn get_body(self) -> Bytes:
        return self.body_raw

    fn set_body_bytes(inout self, body: Bytes) -> Self:
        self.body_raw = body
        return self
    
    fn set_status_code(inout self, status_code: Int) -> Self:
        _ = self.header.set_status_code(status_code)
        return self

    fn status_code(self) -> Int:
        return self.header.status_code()

    fn set_connection_close(inout self) -> Self:
        _ = self.header.set_connection_close()
        return self

    fn connection_close(self) -> Bool:
        return self.header.connection_close()
    
    fn read_body(inout self, inout r: Reader, header_len: Int) raises -> None:
        _ = r.discard(header_len)

        var body_buf_result = r.peek(r.buffered())
        
        _ = self.set_body_bytes(body_buf_result[0])

fn OK(body: StringLiteral) -> HTTPResponse:
    return HTTPResponse(
        ResponseHeader(200, OK_MESSAGE, TEXT_PLAIN_CONTENT_TYPE), body.as_bytes_slice(),
    )

fn OK(body: StringLiteral, content_type: String) -> HTTPResponse:
    return HTTPResponse(
        ResponseHeader(200, OK_MESSAGE, content_type.as_bytes()), body.as_bytes_slice(),
    )

fn OK(body: String) -> HTTPResponse:
    return HTTPResponse(
        ResponseHeader(200, OK_MESSAGE, TEXT_PLAIN_CONTENT_TYPE), body.as_bytes(),
    )

fn OK(body: String, content_type: String) -> HTTPResponse:
    return HTTPResponse(
        ResponseHeader(200, OK_MESSAGE, content_type.as_bytes()), body.as_bytes(),
    )

fn OK(body: Bytes) -> HTTPResponse:
    return HTTPResponse(
        ResponseHeader(200, OK_MESSAGE, TEXT_PLAIN_CONTENT_TYPE), body,
    )

fn OK(body: Bytes, content_type: String) -> HTTPResponse:
    return HTTPResponse(
        ResponseHeader(200, OK_MESSAGE, content_type.as_bytes()), body,
    )

fn OK(body: Bytes, content_type: String, content_encoding: String) -> HTTPResponse:
    return HTTPResponse(
        ResponseHeader(200, OK_MESSAGE, content_type.as_bytes(), content_encoding.as_bytes()), body,
    )

fn NotFound(path: String) -> HTTPResponse:
    return HTTPResponse(
        ResponseHeader(404, NOT_FOUND_MESSAGE, TEXT_PLAIN_CONTENT_TYPE), ("path " + path + " not found").as_bytes(),
    )

fn encode(req: HTTPRequest) -> Bytes:
    var builder = StringBuilder()

    _ = builder.write(req.header.method())
    _ = builder.write_string(whitespace)
    if len(req.uri().path_bytes()) > 1:
        _ = builder.write_string(req.uri().path())
    else:
        _ = builder.write_string(strSlash)
    _ = builder.write_string(whitespace)
    
    _ = builder.write(req.header.protocol())

    _ = builder.write_string(rChar)
    _ = builder.write_string(nChar)

    if len(req.header.host()) > 0:
        _ = builder.write_string("Host: ")
        _ = builder.write(req.header.host())
        _ = builder.write_string(rChar)
        _ = builder.write_string(nChar)

    if len(req.body_raw) > 0:
        if len(req.header.content_type()) > 0:
            _ = builder.write_string("Content-Type: ")
            _ = builder.write(req.header.content_type())
            _ = builder.write_string(rChar)
            _ = builder.write_string(nChar)

        _ = builder.write_string("Content-Length: ")
        _ = builder.write_string(len(req.body_raw).__str__())
        _ = builder.write_string(rChar)
        _ = builder.write_string(nChar)

    _ = builder.write_string("Connection: ")
    if req.connection_close():
        _ = builder.write_string("close")
    else:
        _ = builder.write_string("keep-alive")
    
    _ = builder.write_string(rChar)
    _ = builder.write_string(nChar)
    _ = builder.write_string(rChar)
    _ = builder.write_string(nChar)
    
    if len(req.body_raw) > 0:
        _ = builder.write(req.get_body_bytes())
    
    # TODO: Might want to avoid creating a string then copying the bytes
    return str(builder).as_bytes()


fn encode(res: HTTPResponse) -> Bytes:
    var current_time = String()
    try:
        current_time = now(utc=True).__str__()
    except e:
        print("Error getting current time: " + str(e))

    var builder = StringBuilder()

    _ = builder.write(res.header.protocol())
    _ = builder.write_string(whitespace)
    _ = builder.write_string(res.header.status_code().__str__())
    _ = builder.write_string(whitespace)
    _ = builder.write(res.header.status_message())

    _ = builder.write_string(rChar)
    _ = builder.write_string(nChar)

    _ = builder.write_string("Server: lightbug_http")

    _ = builder.write_string(rChar)
    _ = builder.write_string(nChar)

    _ = builder.write_string("Content-Type: ")
    _ = builder.write(res.header.content_type())

    _ = builder.write_string(rChar)
    _ = builder.write_string(nChar)

    if len(res.header.content_encoding()) > 0:
        _ = builder.write_string("Content-Encoding: ")
        _ = builder.write(res.header.content_encoding())
        _ = builder.write_string(rChar)
        _ = builder.write_string(nChar)

    if len(res.body_raw) > 0:
        _ = builder.write_string("Content-Length: ")
        _ = builder.write_string(str(len(res.body_raw)))
        _ = builder.write_string(rChar)
        _ = builder.write_string(nChar)
    else:
        _ = builder.write_string("Content-Length: 0")
        _ = builder.write_string(rChar)
        _ = builder.write_string(nChar)

    _ = builder.write_string("Connection: ")
    if res.connection_close():
        _ = builder.write_string("close")
    else:
        _ = builder.write_string("keep-alive")
    _ = builder.write_string(rChar)
    _ = builder.write_string(nChar)

    _ = builder.write_string("Date: ")
    _ = builder.write_string(current_time)

    _ = builder.write_string(rChar)
    _ = builder.write_string(nChar)
    _ = builder.write_string(rChar)
    _ = builder.write_string(nChar)
 
    if len(res.body_raw) > 0:
        _ = builder.write(res.get_body_bytes())

    # TODO: Might want to avoid creating a string then copying the bytes
    return str(builder).as_bytes()
