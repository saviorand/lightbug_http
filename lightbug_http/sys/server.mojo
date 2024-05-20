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
    """
    A Mojo-based server that accept incoming requests and delivers HTTP services.
    """

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
        """
        Retrieve the concurrency level which is either
        the configured max_concurrent_connections or the DefaultConcurrency.

        Returns:
            Int: concurrency level for the server.
        """
        var concurrency = self.max_concurrent_connections
        if concurrency <= 0:
            concurrency = DefaultConcurrency
        return concurrency

    fn listen_and_serve[
        T: HTTPService
    ](inout self, address: String, handler: T) raises -> None:
        """
        Listen for incoming connections and serve HTTP requests.

        Args:
            address : String - The address (host:port) to listen on.
            handler : HTTPService - An object that handles incoming HTTP requests.
        """
        var __net = SysNet()
        var listener = __net.listen(NetworkType.tcp4.value, address)
        self.serve(listener, handler)

    fn serve[T: HTTPService](inout self, ln: SysListener, handler: T) raises -> None:
        """
        Serve HTTP requests.

        Args:
            ln : SysListener - TCP server that listens for incoming connections.
            handler : HTTPService - An object that handles incoming HTTP requests.

        Raises:
        If there is an error while serving requests.
        """
        self.ln = ln

        while True:
            var conn = self.ln.accept()
            var buf = Bytes()
            
            while True:
                var read_len = conn.read(buf)
                if read_len == 0:
                    conn.close()
                    break
                var request = next_line(buf)
                var headers_and_body = next_line(request.rest, "\n\n")
                var request_headers = headers_and_body.first_line
                var request_body = headers_and_body.rest
                var uri = URI(request.first_line)
                try:
                    uri.parse()
                except e:
                    conn.close()
                    raise Error("Failed to parse request line:" + e.__str__())

                var header = RequestHeader(request_headers._buffer)
                try:
                    header.parse(request.first_line)
                except e:
                    conn.close()
                    raise Error("Failed to parse request header: " + e.__str__())
                
                if header.content_length() != 0 and header.content_length() != (len(request_body) + 1):
                    var remaining_body = Bytes()
                    var remaining_len = header.content_length() - len(request_body + 1)
                    while remaining_len > 0:
                        var read_len = conn.read(remaining_body)
                        buf.extend(remaining_body)
                        remaining_len -= read_len

                var res = handler.func(
                    HTTPRequest(
                        uri,
                        buf,
                        header,
                    )
                )
                var res_encoded = encode(res)
                _ = conn.write(res_encoded)
                
                if header.connection_close():
                    conn.close()
                    break
