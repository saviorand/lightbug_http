from gojo.bufio import Reader, Scanner, scan_words, scan_bytes
from gojo.bytes.buffer import Buffer
from lightbug_http.server import DefaultConcurrency
from lightbug_http.net import Listener, default_buffer_size
from lightbug_http.http import HTTPRequest, encode
from lightbug_http.uri import URI
from lightbug_http.header import RequestHeader
from lightbug_http.sys.net import SysListener, SysConnection, SysNet
from lightbug_http.service import HTTPService
from lightbug_http.io.sync import Duration
from lightbug_http.io.bytes import Bytes, bytes
from lightbug_http.error import ErrorHandler
from lightbug_http.strings import NetworkType

alias default_max_request_body_size = 4 * 1024 * 1024  # 4MB

@value
struct SysServer:
    """
    A Mojo-based server that accept incoming requests and delivers HTTP services.
    """

    var error_handler: ErrorHandler

    var name: String
    var __address: String
    var max_concurrent_connections: Int
    var max_requests_per_connection: Int

    var __max_request_body_size: Int
    var tcp_keep_alive: Bool

    var ln: SysListener

    fn __init__(inout self) raises:
        self.error_handler = ErrorHandler()
        self.name = "lightbug_http"
        self.__address = "127.0.0.1"
        self.max_concurrent_connections = 1000
        self.max_requests_per_connection = 0
        self.__max_request_body_size = default_max_request_body_size
        self.tcp_keep_alive = False
        self.ln = SysListener()
    
    fn __init__(inout self, tcp_keep_alive: Bool) raises:
        self.error_handler = ErrorHandler()
        self.name = "lightbug_http"
        self.__address = "127.0.0.1"
        self.max_concurrent_connections = 1000
        self.max_requests_per_connection = 0
        self.__max_request_body_size = default_max_request_body_size
        self.tcp_keep_alive = tcp_keep_alive
        self.ln = SysListener()
    
    fn __init__(inout self, own_address: String) raises:
        self.error_handler = ErrorHandler()
        self.name = "lightbug_http"
        self.__address = own_address
        self.max_concurrent_connections = 1000
        self.max_requests_per_connection = 0
        self.__max_request_body_size = default_max_request_body_size
        self.tcp_keep_alive = False
        self.ln = SysListener()

    fn __init__(inout self, error_handler: ErrorHandler) raises:
        self.error_handler = error_handler
        self.name = "lightbug_http"
        self.__address = "127.0.0.1"
        self.max_concurrent_connections = 1000
        self.max_requests_per_connection = 0
        self.__max_request_body_size = default_max_request_body_size
        self.tcp_keep_alive = False
        self.ln = SysListener()
    
    fn __init__(inout self, max_request_body_size: Int) raises:
        self.error_handler = ErrorHandler()
        self.name = "lightbug_http"
        self.__address = "127.0.0.1"
        self.max_concurrent_connections = 1000
        self.max_requests_per_connection = 0
        self.__max_request_body_size = max_request_body_size
        self.tcp_keep_alive = False
        self.ln = SysListener()
    
    fn __init__(inout self, max_request_body_size: Int, tcp_keep_alive: Bool) raises:
        self.error_handler = ErrorHandler()
        self.name = "lightbug_http"
        self.__address = "127.0.0.1"
        self.max_concurrent_connections = 1000
        self.max_requests_per_connection = 0
        self.__max_request_body_size = max_request_body_size
        self.tcp_keep_alive = tcp_keep_alive
        self.ln = SysListener()
    
    fn address(self) -> String:
        return self.__address
    
    fn set_address(inout self, own_address: String) -> Self:
        self.__address = own_address
        return self

    fn max_request_body_size(self) -> Int:
        return self.__max_request_body_size
    
    fn set_max_request_body_size(inout self, size: Int) -> Self:
        self.__max_request_body_size = size
        return self

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
        _ = self.set_address(address)
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
            self.serve_connection(conn, handler)
    
    fn serve_connection[T: HTTPService](inout self, conn: SysConnection, handler: T) raises -> None:
        """
        Serve a single connection.

        Args:
            conn : SysConnection - A connection object that represents a client connection.
            handler : HTTPService - An object that handles incoming HTTP requests.

        Raises:
        If there is an error while serving the connection.
        """
        var b = Bytes(capacity=default_buffer_size)
        var bytes_recv = conn.read(b) 
        if bytes_recv == 0:
            conn.close()
            return

        var buf = Buffer(b^)
        var reader = Reader(buf^)
        var error = Error()
        
        var max_request_body_size = self.max_request_body_size()
        if max_request_body_size <= 0:
            max_request_body_size = default_max_request_body_size
        
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

            var uri = URI(self.address() + header.request_uri_str())
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
            
            _ = conn.write(encode(res))

            if not self.tcp_keep_alive:
                conn.close()
                return
