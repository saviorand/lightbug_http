from time import now
from external.morrow import Morrow
from external.gojo.strings.builder import NewStringBuilder
from lightbug_http.uri import URI
from lightbug_http.io.bytes import Bytes, bytes
from lightbug_http.header import RequestHeader, ResponseHeader
from lightbug_http.io.sync import Duration
from lightbug_http.net import Addr, TCPAddr
from lightbug_http.strings import next_line, strHttp11, strHttp

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

    fn set_connection_close(inout self, connection_close: Bool) -> Self:
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

    fn set_connection_close(inout self, connection_close: Bool) -> Self:
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
        self.header = RequestHeader(String("127.0.0.1"))
        self.__uri = uri
        self.body_raw = Bytes()
        self.parsed_uri = False
        self.server_is_tls = False
        self.timeout = Duration()
        self.disable_redirect_path_normalization = False

    fn __init__(inout self, uri: URI, headers: RequestHeader):
        self.header = RequestHeader()
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

    fn get_body(self) -> Bytes:
        return self.body_raw

    fn set_host(inout self, host: String) -> Self:
        _ = self.__uri.set_host(host)
        return self

    fn set_host_bytes(inout self, host: Bytes) -> Self:
        _ = self.__uri.set_host_bytes(host)
        return self

    fn host(self) -> String:
        return self.__uri.host()

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

    fn set_connection_close(inout self, connection_close: Bool) -> Self:
        _ = self.header.set_connection_close()
        return self

    fn connection_close(self) -> Bool:
        return self.header.connection_close()


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
            bytes("OK"),
            bytes("Content-Type: application/octet-stream\r\n"),
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

    fn get_body(self) -> Bytes:
        return self.body_raw

    fn set_status_code(inout self, status_code: Int) -> Self:
        _ = self.header.set_status_code(status_code)
        return self

    fn status_code(self) -> Int:
        return self.header.status_code()

    fn set_connection_close(inout self, connection_close: Bool) -> Self:
        _ = self.header.set_connection_close()
        return self

    fn connection_close(self) -> Bool:
        return self.header.connection_close()

fn OK(body: StringLiteral) -> HTTPResponse:
    return HTTPResponse(
        ResponseHeader(200, bytes("OK"), bytes("Content-Type: text/plain")), bytes(body),
    )

fn OK(body: StringLiteral, content_type: String) -> HTTPResponse:
    return HTTPResponse(
        ResponseHeader(200, bytes("OK"), bytes(content_type)), bytes(body),
    )

fn OK(body: String) -> HTTPResponse:
    return HTTPResponse(
        ResponseHeader(200, bytes("OK"), bytes("Content-Type: text/plain")), bytes(body),
    )

fn OK(body: String, content_type: String) -> HTTPResponse:
    return HTTPResponse(
        ResponseHeader(200, bytes("OK"), bytes(content_type)), bytes(body),
    )

fn OK(body: Bytes) -> HTTPResponse:
    return HTTPResponse(
        ResponseHeader(200, bytes("OK"), bytes("Content-Type: text/plain")), body,
    )

fn OK(body: Bytes, content_type: String) -> HTTPResponse:
    return HTTPResponse(
        ResponseHeader(200, bytes("OK"), bytes(content_type)), body,
    )

fn OK(body: Bytes, content_type: String, content_encoding: String) -> HTTPResponse:
    return HTTPResponse(
        ResponseHeader(200, bytes("OK"), bytes(content_type), bytes(content_encoding)), body,
    )

fn NotFound(path: String) -> HTTPResponse:
    return HTTPResponse(
        ResponseHeader(404, bytes("Not Found"), bytes("text/plain")), bytes("path " + path + " not found"),
    )

fn encode(req: HTTPRequest, uri: URI) raises -> Bytes:
    var protocol = strHttp11

    var builder = NewStringBuilder()

    _ = builder.write(req.header.method())
    _ = builder.write_string(String(req.header.method()))
    _ = builder.write_string(String(" "))
    if len(uri.request_uri()) > 1:
        _ = builder.write(uri.request_uri())
    else:
        _ = builder.write_string(String("/"))
    _ = builder.write_string(String(" "))
    _ = builder.write_string(protocol)
    _ = builder.write_string(String("\r\n"))

    _ = builder.write_string(String("Host: " + String(uri.host())))
    _ = builder.write_string(String("\r\n"))

    if len(req.body_raw) > 0:
        if len(req.header.content_type()) > 0:
            _ = builder.write_string(String("Content-Type: "))
            _ = builder.write(req.header.content_type())
            _ = builder.write_string(String("\r\n"))

        _ = builder.write_string(String("Content-Length: "))
        _ = builder.write_string(String(len(req.body_raw)))
        _ = builder.write_string(String("\r\n"))

    _ = builder.write_string(String("Connection: "))
    if req.connection_close():
        _ = builder.write_string(String("close"))
    else:
        _ = builder.write_string(String("keep-alive"))
    
    _ = builder.write_string(String("\r\n"))
    _ = builder.write_string(String("\r\n"))
    
    if len(req.body_raw) > 0:
        _ = builder.write(req.body_raw)
    
    print(builder.render())
    
    return builder.__str__()._buffer


fn encode(res: HTTPResponse) raises -> Bytes:
    var res_str = String()
    var protocol = strHttp11
    var current_time = String()
    try:
        current_time = Morrow.utcnow().__str__()
    except e:
        print("Error getting current time: " + str(e))
        current_time = str(now())

    var builder = StringBuilder()

    _ = builder.write(protocol)
    _ = builder.write_string(String(" "))
    _ = builder.write_string(String(res.header.status_code()))
    _ = builder.write_string(String(" "))
    _ = builder.write(res.header.status_message())
    _ = builder.write_string(String("\r\n"))

    _ = builder.write_string(String("Server: lightbug_http"))
    _ = builder.write_string(String("\r\n"))

    _ = builder.write_string(String("Content-Type: "))
    _ = builder.write(res.header.content_type())
    _ = builder.write_string(String("\r\n"))

    if len(res.header.content_encoding()) > 0:
        _ = builder.write_string(String("Content-Encoding: "))
        _ = builder.write(res.header.content_encoding())
        _ = builder.write_string(String("\r\n"))

    if len(res.body_raw) > 0:
        _ = builder.write_string(String("Content-Length: "))
        _ = builder.write_string(String(len(res.body_raw)))
        _ = builder.write_string(String("\r\n"))

    _ = builder.write_string(String("Connection: "))
    if res.connection_close():
        _ = builder.write_string(String("close"))
    else:
        _ = builder.write_string(String("keep-alive"))
    _ = builder.write_string(String("\r\n"))

    _ = builder.write_string(String("Date: "))
    _ = builder.write_string(String(current_time))

    if len(res.body_raw) > 0:
        _ = builder.write_string(String("\r\n"))
        _ = builder.write_string(String("\r\n"))
        _ = builder.write(res.body_raw)

    return builder.get_bytes()

fn split_http_string(buf: Bytes) raises -> (String, List[String], String):
    var request = String(buf)
    
    var request_first_line_headers_body = request.split("\r\n\r\n")
    var request_first_line_headers = request_first_line_headers_body[0]
    var request_body = request_first_line_headers_body[1]
    var request_first_line_headers_list = request_first_line_headers.split("\r\n")
    var request_first_line = request_first_line_headers_list[0]
    var request_headers = request_first_line_headers_list[1:]

    return (request_first_line, request_headers, request_body)