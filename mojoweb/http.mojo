from mojoweb.header import RequestHeader, ResponseHeader
from mojoweb.uri import URI
from mojoweb.args import Args
from mojoweb.stream import StreamReader
from mojoweb.body import Body, RequestBodyWriter, ResponseBodyWriter
from mojoweb.utils import Bytes, Duration, Addr


struct Request:
    var header: RequestHeader
    var uri: URI

    var post_args: Args

    var body_stream: StreamReader
    var w: RequestBodyWriter
    var body: Body
    var body_raw: Bytes

    # TODO: var multipart_form
    # TODO: var multipart_form_boundary

    # TODO: var parsed_uri: Bool
    # TODO: var parsed_post_args: Bool

    # TODO: var keep_body_buffer: Bool

    var server_is_tls: Bool

    var timeout: Duration

    # TODO: var use_host_header: Bool

    var disable_redirect_path_normalization: Bool

    fn __init__(inout self, header: RequestHeader, uri: URI) -> None:
        self.header = header
        self.uri = uri

    fn set_host(self, host: String) -> Self:
        return Self(self, self.uri.set_host(host))


struct Response:
    var header: ResponseHeader

    var stream_immediate_header_flush: Bool
    var stream_body: Bool

    var body_stream: StreamReader
    var w: ResponseBodyWriter
    var body: Body
    var body_raw: Bytes

    var skip_reading_writing_body: Bool

    # TODO: var keep_body_buffer: Bool

    var raddr: Addr
    var laddr: Addr
