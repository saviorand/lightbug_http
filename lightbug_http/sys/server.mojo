from lightbug_http.server import DefaultConcurrency
from lightbug_http.net import Listener
from lightbug_http.http import HTTPRequest, encode
from lightbug_http.uri import URI
from lightbug_http.header import RequestHeader
from lightbug_http.sys.net import SysListener, SysConnection, SysNet
from lightbug_http.service import HTTPService
from lightbug_http.io.sync import Duration
from lightbug_http.io.bytes import Bytes
from lightbug_http.error import ErrorHandler
from lightbug_http.strings import next_line, NetworkType


struct SysServer:
    var error_handler: ErrorHandler

    var name: String
    var max_concurrent_connections: Int
    var max_requests_per_connection: Int

    var max_request_body_size: Int
    var tcp_keep_alive: Bool

    var ln: SysListener

    fn __init__(inout self) raises:
        self.error_handler = ErrorHandler()
        self.name = "lightbug_http"
        self.max_concurrent_connections = 1000
        self.max_requests_per_connection = 0
        self.max_request_body_size = 0
        self.tcp_keep_alive = False
        self.ln = SysListener()

    fn __init__(inout self, error_handler: ErrorHandler) raises:
        self.error_handler = error_handler
        self.name = "lightbug_http"
        self.max_concurrent_connections = 1000
        self.max_requests_per_connection = 0
        self.max_request_body_size = 0
        self.tcp_keep_alive = False
        self.ln = SysListener()

    fn get_concurrency(self) -> Int:
        var concurrency = self.max_concurrent_connections
        if concurrency <= 0:
            concurrency = DefaultConcurrency
        return concurrency

    fn listen_and_serve[
        T: HTTPService
    ](inout self, address: String, handler: T) raises -> None:
        var __net = SysNet()
        var listener = __net.listen(NetworkType.tcp4.value, address)
        self.serve(listener, handler)

    fn serve[T: HTTPService](inout self, ln: SysListener, handler: T) raises -> None:
        # var max_worker_count = self.get_concurrency()
        # TODO: logic for non-blocking read and write here, see for example https://github.com/valyala/fasthttp/blob/9ba16466dfd5d83e2e6a005576ee0d8e127457e2/server.go#L1789

        self.ln = ln

        while True:
            try:
                var conn = self.ln.accept()
                var buf = Bytes()
                try:
                    var read_len = conn.read(buf)
                except:
                    conn.close()
                    raise Error("Failed to read request")
                var first_line_and_headers = next_line(buf)
                var request_line = first_line_and_headers.first_line
                var rest_of_headers = first_line_and_headers.rest

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

                var res = handler.func(
                    HTTPRequest(
                        uri,
                        buf,
                        header,
                    )
                )
                var res_encoded = encode(res)
                try:
                    _ = conn.write(res_encoded._vector)
                except:
                    conn.close()
                    raise Error("Failed to write response")
                conn.close()
            except:
                raise Error("Failed to serve request")
