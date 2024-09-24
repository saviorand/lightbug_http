from lightbug_http.server import DefaultConcurrency
from lightbug_http.net import Listener, default_buffer_size
from lightbug_http.http import HTTPRequest, encode
from lightbug_http.uri import URI
from lightbug_http.header import Headers
from lightbug_http.sys.net import SysListener, SysConnection, SysNet
from lightbug_http.service import HTTPService, UpgradeLoop, NoUpgrade
from lightbug_http.io.sync import Duration
from lightbug_http.io.bytes import Bytes, bytes
from lightbug_http.error import ErrorHandler
from lightbug_http.strings import NetworkType
from lightbug_http.utils import ByteReader
from lightbug_http.libc import fd_set, timeval, select

alias default_max_request_body_size = 4 * 1024 * 1024  # 4MB


@value
struct SysServer[T: UpgradeLoop = NoUpgrade]: # TODO: conditional conformance on main struct , then a default for upgrade e.g. NoUpgrade
    """
    A Mojo-based server that accept incoming requests and delivers HTTP services.
    """
    var error_handler: ErrorHandler
    var upgrade_loop: T

    var name: String
    var __address: String
    var max_concurrent_connections: Int
    var max_requests_per_connection: Int

    var __max_request_body_size: Int
    var tcp_keep_alive: Bool

    var ln: SysListener

    var connections: List[SysConnection]
    var read_fds: fd_set
    var write_fds: fd_set

    fn __init__(inout self, upgrade: T) raises:
        self.error_handler = ErrorHandler()
        self.upgrade_loop = upgrade
        self.name = "lightbug_http"
        self.__address = "127.0.0.1"
        self.max_concurrent_connections = 1000
        self.max_requests_per_connection = 0
        self.__max_request_body_size = default_max_request_body_size
        self.tcp_keep_alive = False
        self.ln = SysListener()
        self.connections = List[SysConnection]()
        self.read_fds = fd_set()
        self.write_fds = fd_set()

    fn __init__(inout self, tcp_keep_alive: Bool, upgrade: T) raises:
        self.error_handler = ErrorHandler()
        self.upgrade_loop = upgrade
        self.name = "lightbug_http"
        self.__address = "127.0.0.1"
        self.max_concurrent_connections = 1000
        self.max_requests_per_connection = 0
        self.__max_request_body_size = default_max_request_body_size
        self.tcp_keep_alive = tcp_keep_alive
        self.ln = SysListener()
        self.connections = List[SysConnection]()
        self.read_fds = fd_set()
        self.write_fds = fd_set()

    fn __init__(inout self, own_address: String, upgrade: T) raises:
        self.error_handler = ErrorHandler()
        self.upgrade_loop = upgrade
        self.name = "lightbug_http"
        self.__address = own_address
        self.max_concurrent_connections = 1000
        self.max_requests_per_connection = 0
        self.__max_request_body_size = default_max_request_body_size
        self.tcp_keep_alive = False
        self.ln = SysListener()
        self.connections = List[SysConnection]()
        self.read_fds = fd_set()
        self.write_fds = fd_set()

    fn __init__(inout self, error_handler: ErrorHandler, upgrade: T) raises:
        self.error_handler = error_handler
        self.upgrade_loop = upgrade
        self.name = "lightbug_http"
        self.__address = "127.0.0.1"
        self.max_concurrent_connections = 1000
        self.max_requests_per_connection = 0
        self.__max_request_body_size = default_max_request_body_size
        self.tcp_keep_alive = False
        self.ln = SysListener()
        self.connections = List[SysConnection]()
        self.read_fds = fd_set()
        self.write_fds = fd_set()

    fn __init__(inout self, max_request_body_size: Int, upgrade: T) raises:
        self.error_handler = ErrorHandler()
        self.upgrade_loop = upgrade
        self.name = "lightbug_http"
        self.__address = "127.0.0.1"
        self.max_concurrent_connections = 1000
        self.max_requests_per_connection = 0
        self.__max_request_body_size = max_request_body_size
        self.tcp_keep_alive = False
        self.ln = SysListener()
        self.connections = List[SysConnection]()
        self.read_fds = fd_set()
        self.write_fds = fd_set()

    fn __init__(
        inout self, max_request_body_size: Int, tcp_keep_alive: Bool, upgrade: T
    ) raises:
        self.error_handler = ErrorHandler()
        self.upgrade_loop = upgrade
        self.name = "lightbug_http"
        self.__address = "127.0.0.1"
        self.max_concurrent_connections = 1000
        self.max_requests_per_connection = 0
        self.__max_request_body_size = max_request_body_size
        self.tcp_keep_alive = tcp_keep_alive
        self.ln = SysListener()
        self.connections = List[SysConnection]()
        self.read_fds = fd_set()
        self.write_fds = fd_set()
    
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
    ](inout self, address: String, handler: T) raises -> None: # TODO: conditional conformance on main struct , then a default for handler e.g. WebsocketHandshake
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

    fn serve[
        T: HTTPService
    ](inout self, ln: SysListener, handler: T) raises -> None:
        """
        Serve HTTP requests.

        Args:
            ln : SysListener - TCP server that listens for incoming connections.
            handler : HTTPService - An object that handles incoming HTTP requests.

        Raises:
        If there is an error while serving requests.
        """
        self.ln = ln
        self.connections = List[SysConnection]()

        while True:
            _ = self.read_fds.clear_all()
            _ = self.write_fds.clear_all()

            self.read_fds.set(int(self.ln.fd))

            var max_fd = self.ln.fd
            for i in range(len(self.connections)):
                var conn = self.connections[i]
                print("Setting fd in read_fds and write_fds: ", conn.fd)
                self.read_fds.set(int(conn.fd))
                self.write_fds.set(int(conn.fd))
                print("Is fd set in read_fds: ", self.read_fds.is_set(int(conn.fd)))
                if conn.fd > max_fd:
                    max_fd = conn.fd
                
            var timeout = timeval(0, 10000)

            var select_result = select(
                max_fd + 1,
                UnsafePointer.address_of(self.read_fds),
                UnsafePointer.address_of(self.write_fds),
                UnsafePointer[fd_set](),
                UnsafePointer.address_of(timeout)
            )
            if select_result == -1:
                print("Select error")
                return
            print("Select result: ", select_result)
            print("Number of connections: ", len(self.connections))
            print("Listener fd: ", self.ln.fd)
            print("Max fd: ", max_fd)
            print("Is read_fds set: ", self.read_fds.is_set(int(self.ln.fd)))
            if self.read_fds.is_set(int(self.ln.fd)):
                print("New connection incoming")
                var conn = self.ln.accept()
                print("New connection accepted")
                try: 
                    _ = conn.set_non_blocking(True)
                except e:
                    print("Error setting non-blocking: ", e)
                    conn.close()
                    continue
                self.connections.append(conn)
                if conn.fd > max_fd:
                    max_fd = conn.fd
                    print("Max fd updated: ", max_fd)
                    self.read_fds.set(int(conn.fd))
            
            var i = 0
            while i < len(self.connections):
                var conn = self.connections[i]
                print("Checking connection ", i, "fd: ", conn.fd)
                if self.read_fds.is_set(int(conn.fd)):
                    print("Reading from connection ", i)
                    _ = self.handle_read(conn, handler)
                if self.write_fds.is_set(int(conn.fd)):
                    print("Writing to connection ", i)
                    _ = self.handle_write(conn)
                
                if conn.is_closed():
                    _ = self.connections.pop(i)
                else:
                    i += 1

    fn handle_read[T: HTTPService](inout self, inout conn: SysConnection, handler: T) raises -> None:
        var max_request_body_size = self.max_request_body_size()
        if max_request_body_size <= 0:
            max_request_body_size = default_max_request_body_size

        var b = Bytes(capacity=default_buffer_size)
        print("Trying to read")
        var bytes_recv = conn.read(b)
        print("Read bytes: ", bytes_recv)
        
        if bytes_recv == 0:
            conn.close()
            return

        var request = HTTPRequest.from_bytes(self.address(), max_request_body_size, b^)
        var res = handler.func(request)

        var can_upgrade = self.upgrade_loop.can_upgrade()
        
        if not self.tcp_keep_alive and not can_upgrade:
            _ = res.set_connection_close()

        conn.set_write_buffer(encode(res^))
        
        if can_upgrade:
            self.upgrade_loop.process_data(conn, False, Bytes()) # TODO: is_binary is now hardcoded to = False, need to get it from the frame

        # if not self.tcp_keep_alive:
        #     conn.close()

    fn handle_write(inout self, inout conn: SysConnection) raises -> None:
        var write_buffer = conn.write_buffer()
        if write_buffer:
            var bytes_sent = conn.write(write_buffer)
            if bytes_sent < len(write_buffer):
                conn.set_write_buffer(write_buffer[bytes_sent:])
            else:
                conn.set_write_buffer(Bytes())