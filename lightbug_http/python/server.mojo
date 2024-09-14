from gojo.bufio import Reader, Scanner
from gojo.bytes.buffer import Buffer
from lightbug_http.server import DefaultConcurrency
from lightbug_http.net import Listener, default_buffer_size
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
from lightbug_http.strings import NetworkType

alias default_max_request_body_size = 4 * 1024 * 1024  # 4MB

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
        var conn = self.ln.accept()
        
        var b = Bytes(capacity=default_buffer_size)
        var bytes_recv = conn.read(b) 
        print("Bytes received: ", bytes_recv)
        if bytes_recv == 0:
            conn.close()
            return

        print("Buffer time")
        var buf = Buffer(b^)
        var reader = Reader(buf^)
        print("Reader time")
        var error = Error()
        
        var max_request_body_size = default_max_request_body_size
        
        var req_number = 0
        
        while True:
            req_number += 1

            if req_number > 1:
                var b = Bytes(capacity=default_buffer_size)
                var bytes_recv = conn.read(b)
                if bytes_recv == 0:
                    conn.close()
                    break
                buf = Buffer(b^)
                reader = Reader(buf^)

            var header = RequestHeader()
            var first_line_and_headers_len = 0
            try:
                first_line_and_headers_len = header.parse_raw(reader)
            except e:
                error = Error("Failed to parse request headers: " + e.__str__())

            var uri = URI(String(header.request_uri()))
            try:
                uri.parse()
            except e:
                error = Error("Failed to parse request line:" + e.__str__())
            
            if header.content_length() > 0:
                if max_request_body_size > 0 and header.content_length() > max_request_body_size:
                    error = Error("Request body too large")
            
            var request = HTTPRequest(
                    uri,
                    Bytes(),
                    header,
                )
            
            try:
                request.read_body(reader, header.content_length(), first_line_and_headers_len, max_request_body_size)
            except e:
                error = Error("Failed to read request body: " + e.__str__())
            
            var res = handler.func(request)
            
            if not self.tcp_keep_alive:
                _ = res.set_connection_close()
            
            var res_encoded = encode(res)

            _ = conn.write(res_encoded)

            if not self.tcp_keep_alive:
                conn.close()
                return
