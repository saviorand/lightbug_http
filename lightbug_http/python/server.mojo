from lightbug_http.server import DefaultConcurrency
from lightbug_http.net import Listener
from lightbug_http.http import HTTPRequest, encode
from lightbug_http.uri import URI
from lightbug_http.header import RequestHeader
from lightbug_http.python.net import (
    PythonTCPListener,
    PythonNet,
    PythonConnection,
)
from lightbug_http.python import Modules
from lightbug_http.service import HTTPService
from lightbug_http.io.sync import Duration
from lightbug_http.io.bytes import Bytes
from lightbug_http.error import ErrorHandler
from lightbug_http.strings import next_line, NetworkType


struct PythonServer:
    var pymodules: Modules
    var error_handler: ErrorHandler

    var name: String
    var max_concurrent_connections: Int

    var tcp_keep_alive: Bool

    var ln: PythonTCPListener

    fn __init__(inout self) raises:
        self.pymodules = Modules()
        self.error_handler = ErrorHandler()
        self.name = "lightbug_http"
        self.max_concurrent_connections = 1000
        self.tcp_keep_alive = False
        self.ln = PythonTCPListener()

    fn __init__(inout self, error_handler: ErrorHandler) raises:
        self.pymodules = Modules()
        self.error_handler = error_handler

        self.name = "lightbug_http"
        self.max_concurrent_connections = 1000
        self.tcp_keep_alive = False

        self.ln = PythonTCPListener()

    fn get_concurrency(self) -> Int:
        var concurrency = self.max_concurrent_connections
        if concurrency <= 0:
            concurrency = DefaultConcurrency
        return concurrency

    fn listen_and_serve[
        T: HTTPService
    ](inout self, address: String, handler: T) raises -> None:
        var __net = PythonNet()
        var listener = __net.listen(NetworkType.tcp4.value, address)
        self.serve(listener, handler)

    fn serve[
        T: HTTPService
    ](inout self, ln: PythonTCPListener, handler: T) raises -> None:
        # var max_worker_count = self.get_concurrency()
        # TODO: logic for non-blocking read and write here, see for example https://github.com/valyala/fasthttp/blob/9ba16466dfd5d83e2e6a005576ee0d8e127457e2/server.go#L1789

        self.ln = ln

        while True:
            var conn = self.ln.accept[PythonConnection]()
            var buf = Bytes()
            var read_len = conn.read(buf)
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
            _ = conn.write(res_encoded)
            conn.close()
