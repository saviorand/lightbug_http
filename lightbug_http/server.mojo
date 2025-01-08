from memory import Span
from lightbug_http.io.sync import Duration
from lightbug_http.io.bytes import Bytes, bytes
from lightbug_http.strings import NetworkType
from lightbug_http.utils import ByteReader, logger
from lightbug_http.net import NoTLSListener, default_buffer_size, TCPConnection, ListenConfig, TCPAddr
from lightbug_http.socket import Socket
from lightbug_http.http import HTTPRequest, encode
from lightbug_http.http.common_response import InternalError
from lightbug_http.uri import URI
from lightbug_http.header import Headers
from lightbug_http.service import HTTPService
from lightbug_http.error import ErrorHandler


alias DefaultConcurrency: Int = 256 * 1024
alias default_max_request_body_size = 4 * 1024 * 1024  # 4MB


struct Server(Movable):
    """A Mojo-based server that accept incoming requests and delivers HTTP services.
    """

    var error_handler: ErrorHandler

    var name: String
    var _address: String
    var max_concurrent_connections: Int
    var max_requests_per_connection: Int

    var _max_request_body_size: Int
    var tcp_keep_alive: Bool

    var ln: NoTLSListener

    fn __init__(
        out self,
        error_handler: ErrorHandler = ErrorHandler(),
        name: String = "lightbug_http",
        address: String = "127.0.0.1",
        max_concurrent_connections: Int = 1000,
        max_requests_per_connection: Int = 0,
        max_request_body_size: Int = default_max_request_body_size,
        tcp_keep_alive: Bool = False,
    ) raises:
        self.error_handler = error_handler
        self.name = name
        self._address = address
        self.max_concurrent_connections = max_concurrent_connections
        self.max_requests_per_connection = max_requests_per_connection
        self._max_request_body_size = default_max_request_body_size
        self.tcp_keep_alive = tcp_keep_alive
        self.ln = NoTLSListener(Socket[TCPAddr]())
    
    fn __moveinit__(mut self, owned other: Server) -> None:
        self.error_handler = other.error_handler
        self.name = other.name
        self._address = other._address
        self.max_concurrent_connections = other.max_concurrent_connections
        self.max_requests_per_connection = other.max_requests_per_connection
        self._max_request_body_size = other._max_request_body_size
        self.tcp_keep_alive = other.tcp_keep_alive
        self.ln = other.ln^

    fn address(self) -> String:
        return self._address

    fn set_address(mut self, own_address: String) -> None:
        self._address = own_address

    fn max_request_body_size(self) -> Int:
        return self._max_request_body_size

    fn set_max_request_body_size(mut self, size: Int) -> None:
        self._max_request_body_size = size

    fn get_concurrency(self) -> Int:
        """Retrieve the concurrency level which is either
        the configured `max_concurrent_connections` or the `DefaultConcurrency`.

        Returns:
            Concurrency level for the server.
        """
        var concurrency = self.max_concurrent_connections
        if concurrency <= 0:
            concurrency = DefaultConcurrency
        return concurrency

    fn listen_and_serve[T: HTTPService](mut self, address: String, mut handler: T) raises:
        """Listen for incoming connections and serve HTTP requests.

        Parameters:
            T: The type of HTTPService that handles incoming requests.

        Args:
            address: The address (host:port) to listen on.
            handler: An object that handles incoming HTTP requests.
        """
        var net = ListenConfig()
        var listener = net.listen(NetworkType.tcp4.value, address)
        self.set_address(address)
        self.serve(listener^, handler)

    fn serve[T: HTTPService](mut self, owned ln: NoTLSListener, mut handler: T) raises:
        """Serve HTTP requests.

        Parameters:
            T: The type of HTTPService that handles incoming requests.

        Args:
            ln: TCP server that listens for incoming connections.
            handler: An object that handles incoming HTTP requests.

        Raises:
            If there is an error while serving requests.
        """
        self.ln = ln^
        while True:
            var conn = self.ln.accept()
            self.serve_connection(conn, handler)

    fn serve_connection[T: HTTPService](mut self, mut conn: TCPConnection, mut handler: T) raises -> None:
        """Serve a single connection.

        Parameters:
            T: The type of HTTPService that handles incoming requests.

        Args:
            conn: A connection object that represents a client connection.
            handler: An object that handles incoming HTTP requests.

        Raises:
            If there is an error while serving the connection.
        """
        var max_request_body_size = self.max_request_body_size()
        if max_request_body_size <= 0:
            max_request_body_size = default_max_request_body_size

        var req_number = 0
        while True:
            req_number += 1

            # TODO: We should read until 0 bytes are received. 
            # If we completely fill the buffer haven't read the full request, we end up processing a partial request.
            var b = Bytes(capacity=default_buffer_size)
            var bytes_recv = conn.read(b)
            # TODO: Should the connection be closed here? The client should close it for 1.1 http.
            if bytes_recv == 0:
                conn.close()
                break

            var request: HTTPRequest
            try:
                request = HTTPRequest.from_bytes(self.address(), max_request_body_size, b)
            except e:
                logger.error(e)
                raise Error("Server.serve_connection: Failed to parse request")
            
            var res: HTTPResponse
            try:
                res = handler.func(request)
            except:
                if not conn.is_closed():
                    try:
                        _ = conn.write(encode(InternalError()))
                        conn.close()
                    except e:
                        logger.error(e)
                        raise Error("Failed to send InternalError response")
                return

            var close_connection = (not self.tcp_keep_alive) or request.connection_close()
            if close_connection:
                res.set_connection_close()

            try:
                _ = conn.write(encode(res^))
            except e:
                conn.close()
                break
            
            if close_connection:
                conn.close()
                break

