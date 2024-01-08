from lightbug_http.server import DefaultConcurrency
from lightbug_http.net import Listener
from lightbug_http.http import HTTPRequest, HTTPResponse, encode
from lightbug_http.uri import URI
from lightbug_http.header import ResponseHeader, RequestHeader
from lightbug_http.sys.net import SysListener, SysListenConfig, SysConnection, SysNet
from lightbug_http.python import Modules
from lightbug_http.service import HTTPService
from lightbug_http.io.sync import Duration
from lightbug_http.io.bytes import Bytes
from lightbug_http.error import ErrorHandler
from lightbug_http.strings import next_line, NetworkType, strHttp, CharSet


struct SysServer:
    var error_handler: ErrorHandler

    var name: String
    var max_concurrent_connections: Int
    var read_buffer_size: Int
    var write_buffer_size: Int

    var read_timeout: Duration
    var write_timeout: Duration
    var idle_timeout: Duration

    var max_connections_per_ip: Int
    var max_requests_per_connection: Int
    var max_keep_alive_duration: Duration
    var max_idle_worker_duration: Duration
    var tcp_keep_alive_period: Duration

    var max_request_body_size: Int
    var disable_keep_alive: Bool
    var tcp_keep_alive: Bool
    var reduce_memory_usage: Bool

    var get_only: Bool
    var disable_pre_parse_multipart_form: Bool
    var disable_header_names_normalization: Bool
    var sleep_when_concurrency_limits_exceeded: Duration

    var no_default_server_header: Bool
    var no_default_date: Bool
    var no_default_content_type: Bool

    var close_on_shutdown: Bool
    var stream_request_body: Bool

    var ln: SysListener

    var open: Atomic[DType.int32]
    var stop: Atomic[DType.int32]

    fn __init__(inout self) raises:
        self.error_handler = ErrorHandler()

        self.name = "lightbug_http"
        self.max_concurrent_connections = 1000
        self.read_buffer_size = 4096
        self.write_buffer_size = 4096

        self.read_timeout = Duration(5)
        self.write_timeout = Duration(5)
        self.idle_timeout = Duration(60)

        self.max_connections_per_ip = 0
        self.max_requests_per_connection = 0
        self.max_keep_alive_duration = Duration(0)
        self.max_idle_worker_duration = Duration(0)
        self.tcp_keep_alive_period = Duration(0)

        self.max_request_body_size = 0
        self.disable_keep_alive = False
        self.tcp_keep_alive = False
        self.reduce_memory_usage = False

        self.get_only = False
        self.disable_pre_parse_multipart_form = False
        self.disable_header_names_normalization = False
        self.sleep_when_concurrency_limits_exceeded = Duration(0)

        self.no_default_server_header = False
        self.no_default_date = False
        self.no_default_content_type = False

        self.close_on_shutdown = False
        self.stream_request_body = False

        self.ln = SysListener()
        self.open = 0
        self.stop = 0

    fn __init__(inout self, error_handler: ErrorHandler) raises:
        self.error_handler = error_handler

        self.name = "lightbug_http"
        self.max_concurrent_connections = 1000
        self.read_buffer_size = 4096
        self.write_buffer_size = 4096

        self.read_timeout = Duration(5)
        self.write_timeout = Duration(5)
        self.idle_timeout = Duration(60)

        self.max_connections_per_ip = 0
        self.max_requests_per_connection = 0
        self.max_keep_alive_duration = Duration(0)
        self.max_idle_worker_duration = Duration(0)
        self.tcp_keep_alive_period = Duration(0)

        self.max_request_body_size = 0
        self.disable_keep_alive = False
        self.tcp_keep_alive = False
        self.reduce_memory_usage = False

        self.get_only = False
        self.disable_pre_parse_multipart_form = False
        self.disable_header_names_normalization = False
        self.sleep_when_concurrency_limits_exceeded = Duration(0)

        self.no_default_server_header = False
        self.no_default_date = False
        self.no_default_content_type = False

        self.close_on_shutdown = False
        self.stream_request_body = False

        self.ln = SysListener()
        self.open = 0
        self.stop = 0

    fn get_concurrency(self) -> Int:
        var concurrency = self.max_concurrent_connections
        if concurrency <= 0:
            concurrency = DefaultConcurrency
        return concurrency

    fn listen_and_serve[
        T: HTTPService
    ](inout self, address: String, handler: T) raises -> None:
        var __net = SysNet()
        let listener = __net.listen(NetworkType.tcp4.value, address)
        self.serve(listener, handler)

    fn serve[T: HTTPService](inout self, ln: SysListener, handler: T) raises -> None:
        # let max_worker_count = self.get_concurrency()
        # TODO: logic for non-blocking read and write here, see for example https://github.com/valyala/fasthttp/blob/9ba16466dfd5d83e2e6a005576ee0d8e127457e2/server.go#L1789

        self.ln = ln

        while True:
            let conn = self.ln.accept[SysConnection]()
            self.open.__iadd__(1)
            var buf = Bytes()
            let read_len = conn.read(buf)
            # Extract the first line (request line) and the rest of the headers
            let first_line_and_headers = next_line(buf)
            let request_line = first_line_and_headers.first_line
            let rest_of_headers = first_line_and_headers.rest

            var uri = URI(request_line)
            try:
                uri.parse()
            except:
                conn.close()
                raise Error("Failed to parse request line")

            var header = RequestHeader(buf)
            try:
                header.parse()
            except:
                conn.close()
                raise Error("Failed to parse request header")

            let res = handler.func(
                HTTPRequest(
                    uri,
                    buf,
                    header,
                )
            )
            let res_encoded = encode(res)
            _ = conn.write(res_encoded)
            conn.close()
