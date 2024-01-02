from lightbug_http.header import RequestHeader, ResponseHeader
from lightbug_http.uri import URI
from lightbug_http.args import Args
from lightbug_http.stream import StreamReader
from lightbug_http.body import Body, RequestBodyWriter, ResponseBodyWriter
from lightbug_http.io.bytes import Bytes
from lightbug_http.io.sync import Duration
from lightbug_http.net import Addr, TCPAddr
from lightbug_http.strings import TwoLines, next_line, strHttp11, strHttp10, strHttp


trait Request:
    fn __init__(inout self, uri: URI):
        ...

    fn __init__(
        inout self,
        header: RequestHeader,
        uri: URI,
        post_args: Args,
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
    var uri: URI

    var post_args: Args

    var body_stream: StreamReader
    var w: RequestBodyWriter
    var body: Body
    var body_raw: Bytes

    # TODO: var multipart_form
    # TODO: var multipart_form_boundary

    var parsed_uri: Bool
    # TODO: var parsed_post_args: Bool

    # TODO: var keep_body_buffer: Bool

    var server_is_tls: Bool

    var timeout: Duration

    # TODO: var use_host_header: Bool

    var disable_redirect_path_normalization: Bool

    fn __init__(inout self, uri: URI):
        self.header = RequestHeader()
        self.uri = uri
        self.post_args = Args()
        self.body_stream = StreamReader()
        self.w = RequestBodyWriter()
        self.body = Body()
        self.body_raw = Bytes()
        self.parsed_uri = False
        self.server_is_tls = False
        self.timeout = Duration()
        self.disable_redirect_path_normalization = False

    fn __init__(inout self, uri: URI, buf: Bytes, headers: RequestHeader):
        self.header = headers
        self.uri = uri
        self.post_args = Args()
        self.body_stream = StreamReader()
        self.w = RequestBodyWriter()
        self.body = Body()
        self.body_raw = buf
        self.parsed_uri = False
        self.server_is_tls = False
        self.timeout = Duration()
        self.disable_redirect_path_normalization = False

    fn __init__(
        inout self,
        header: RequestHeader,
        uri: URI,
        post_args: Args,
        body: Bytes,
        parsed_uri: Bool,
        server_is_tls: Bool,
        timeout: Duration,
        disable_redirect_path_normalization: Bool,
    ):
        self.header = header
        self.uri = uri
        self.post_args = post_args
        self.body_stream = StreamReader()
        self.w = RequestBodyWriter()
        self.body = Body()
        self.body_raw = body
        self.parsed_uri = parsed_uri
        self.server_is_tls = server_is_tls
        self.timeout = timeout
        self.disable_redirect_path_normalization = disable_redirect_path_normalization

    fn set_host(inout self, host: String) -> Self:
        _ = self.uri.set_host(host)
        return self

    fn set_host_bytes(inout self, host: Bytes) -> Self:
        _ = self.uri.set_host_bytes(host)
        return self

    fn host(self) -> String:
        return self.uri.host()

    fn set_request_uri(inout self, request_uri: String) -> Self:
        _ = self.header.set_request_uri(request_uri._buffer)
        self.parsed_uri = False
        return self

    fn set_request_uri_bytes(inout self, request_uri: Bytes) -> Self:
        _ = self.header.set_request_uri_bytes(request_uri)
        return self

    fn request_uri(inout self) -> String:
        if self.parsed_uri:
            _ = self.set_request_uri_bytes(self.uri.request_uri())
        return self.header.request_uri()

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

    var body_stream: StreamReader
    var w: ResponseBodyWriter
    var body: Body
    var body_raw: Bytes

    var skip_reading_writing_body: Bool

    # TODO: var keep_body_buffer: Bool

    var raddr: TCPAddr
    var laddr: TCPAddr

    fn __init__(inout self, body_bytes: Bytes):
        # TODO: infer content type from the body
        self.header = ResponseHeader(
            200,
            String("OK")._buffer,
            String("Content-Type: application/octet-stream\r\n")._buffer,
        )
        self.stream_immediate_header_flush = False
        self.stream_body = False
        self.body_stream = StreamReader()
        self.w = ResponseBodyWriter()
        self.body = Body()
        self.body_raw = body_bytes
        self.skip_reading_writing_body = False
        self.raddr = TCPAddr()
        self.laddr = TCPAddr()

    fn __init__(inout self, header: ResponseHeader, body_bytes: Bytes):
        self.header = header
        self.stream_immediate_header_flush = False
        self.stream_body = False
        self.body_stream = StreamReader()
        self.w = ResponseBodyWriter()
        self.body = Body()
        self.body_raw = body_bytes
        self.skip_reading_writing_body = False
        self.raddr = TCPAddr()
        self.laddr = TCPAddr()

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


fn OK(body: Bytes) -> HTTPResponse:
    return HTTPResponse(
        ResponseHeader(
            200, String("OK")._buffer, String("Content-Type: text/plain")._buffer
        ),
        body,
    )


fn encode(res: HTTPResponse) -> Bytes:
    var res_str = String()
    let protocol = strHttp11
    res_str += protocol
    res_str += String(" ")
    res_str += String(res.header.status_code())
    res_str += String(" ")
    res_str += String(res.header.status_message())
    res_str += String("\r\n")
    res_str += String("Server: M\r\n")
    res_str += String("Date: ")
    res_str += String("Content-Length: ")
    res_str += String(res.body_raw.__len__().__str__())
    res_str += String("\r\n")
    res_str += String("\r\n")
    res_str += res.body_raw
    return res_str._buffer
