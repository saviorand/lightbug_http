from lightbug_http.io.sync import Duration
from lightbug_http.io.bytes import Bytes, bytes
from lightbug_http.strings import NetworkType
from lightbug_http.utils import ByteReader
from lightbug_http.net import NoTLSListener, default_buffer_size, NoTLSListener, SysConnection, SysNet
from lightbug_http.http import HTTPRequest, encode
from lightbug_http.http.common_response import InternalError
from lightbug_http.uri import URI
from lightbug_http.header import Headers
from lightbug_http.service import HTTPService
from lightbug_http.error import ErrorHandler


alias DefaultConcurrency: Int = 256 * 1024
alias default_max_request_body_size = 4 * 1024 * 1024  # 4MB


@value
struct Server:
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

    var ln: NoTLSListener

    fn __init__(inout self) raises:
        self.error_handler = ErrorHandler()
        self.name = "lightbug_http"
        self.__address = "127.0.0.1"
        self.max_concurrent_connections = 1000
        self.max_requests_per_connection = 0
        self.__max_request_body_size = default_max_request_body_size
        self.tcp_keep_alive = False
        self.ln = NoTLSListener()

    fn __init__(inout self, tcp_keep_alive: Bool) raises:
        self.error_handler = ErrorHandler()
        self.name = "lightbug_http"
        self.__address = "127.0.0.1"
        self.max_concurrent_connections = 1000
        self.max_requests_per_connection = 0
        self.__max_request_body_size = default_max_request_body_size
        self.tcp_keep_alive = tcp_keep_alive
        self.ln = NoTLSListener()

    fn __init__(inout self, own_address: String) raises:
        self.error_handler = ErrorHandler()
        self.name = "lightbug_http"
        self.__address = own_address
        self.max_concurrent_connections = 1000
        self.max_requests_per_connection = 0
        self.__max_request_body_size = default_max_request_body_size
        self.tcp_keep_alive = False
        self.ln = NoTLSListener()

    fn __init__(inout self, error_handler: ErrorHandler) raises:
        self.error_handler = error_handler
        self.name = "lightbug_http"
        self.__address = "127.0.0.1"
        self.max_concurrent_connections = 1000
        self.max_requests_per_connection = 0
        self.__max_request_body_size = default_max_request_body_size
        self.tcp_keep_alive = False
        self.ln = NoTLSListener()

    fn __init__(inout self, max_request_body_size: Int) raises:
        self.error_handler = ErrorHandler()
        self.name = "lightbug_http"
        self.__address = "127.0.0.1"
        self.max_concurrent_connections = 1000
        self.max_requests_per_connection = 0
        self.__max_request_body_size = max_request_body_size
        self.tcp_keep_alive = False
        self.ln = NoTLSListener()

    fn __init__(inout self, max_request_body_size: Int, tcp_keep_alive: Bool) raises:
        self.error_handler = ErrorHandler()
        self.name = "lightbug_http"
        self.__address = "127.0.0.1"
        self.max_concurrent_connections = 1000
        self.max_requests_per_connection = 0
        self.__max_request_body_size = max_request_body_size
        self.tcp_keep_alive = tcp_keep_alive
        self.ln = NoTLSListener()

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

    fn listen_and_serve[T: HTTPService](inout self, address: String, inout handler: T) raises:
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

    fn serve[T: HTTPService](inout self, ln: NoTLSListener, inout handler: T) raises:
        """
        Serve HTTP requests.

        Args:
            ln : NoTLSListener - TCP server that listens for incoming connections.
            handler : HTTPService - An object that handles incoming HTTP requests.

        Raises:
            If there is an error while serving requests.
        """
        self.ln = ln

        while True:
            var conn = self.ln.accept()
            self.serve_connection(conn, handler)

    fn serve_connection[T: HTTPService](inout self, conn: SysConnection, inout handler: T) raises -> None:
        """
        Serve a single connection.

        Args:
            conn : SysConnection - A connection object that represents a client connection.
            handler : HTTPService - An object that handles incoming HTTP requests.

        Raises:
            If there is an error while serving the connection.
        """
        var max_request_body_size = self.max_request_body_size()
        if max_request_body_size <= 0:
            max_request_body_size = default_max_request_body_size

        var req_number = 0
        var is_closed = False

        while True:
            req_number += 1

            b = Bytes(capacity=default_buffer_size)
            bytes_recv = conn.read(b)
            if bytes_recv == 0:
                if not is_closed:
                    conn.close()
                    is_closed = True
                break

            var request = HTTPRequest.from_bytes(self.address(), max_request_body_size, b^)

            var res: HTTPResponse
            try:
                res = handler.func(request)
            except:
                if not is_closed:
                    _ = conn.write(encode(InternalError()))
                    conn.close()
                    is_closed = True
                return

            var close_connection = (not self.tcp_keep_alive) or request.connection_close()

            if close_connection:
                res.set_connection_close()

            var written = conn.write(encode(res^))

            if close_connection or written == -1:
                if not is_closed:
                    conn.close()
                    is_closed = True
                break

