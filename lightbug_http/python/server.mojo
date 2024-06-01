from lightbug_http.server import DefaultConcurrency
from lightbug_http.net import Listener
from lightbug_http.http import HTTPRequest, encode, split_http_string
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
from lightbug_http.strings import NetworkType


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
        self.ln = ln

        while True:
            var conn = self.ln.accept()
            var buf = Bytes()
            var read_len = conn.read(buf)
            if read_len == 0:
                conn.close()
                break
            
            var request_first_line: String
            var request_headers: String
            var request_body: String

            request_first_line, request_headers, request_body = split_http_string(buf)
            
            var uri = URI(request_first_line)
            try:
                uri.parse()
            except:
                conn.close()
                raise Error("Failed to parse request line")

            var header = RequestHeader(buf)
            try:
                header.parse(request_first_line)
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
