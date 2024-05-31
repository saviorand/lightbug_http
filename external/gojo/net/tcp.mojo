from ..builtins import Byte
from ..syscall.net import SO_REUSEADDR
from .net import Connection, Conn
from .address import TCPAddr, NetworkType, split_host_port
from .socket import Socket


# Time in nanoseconds
alias Duration = Int
alias DEFAULT_BUFFER_SIZE = 4096
alias DEFAULT_TCP_KEEP_ALIVE = Duration(15 * 1000 * 1000 * 1000)  # 15 seconds


fn resolve_internet_addr(network: String, address: String) raises -> TCPAddr:
    var host: String = ""
    var port: String = ""
    var portnum: Int = 0
    if (
        network == NetworkType.tcp.value
        or network == NetworkType.tcp4.value
        or network == NetworkType.tcp6.value
        or network == NetworkType.udp.value
        or network == NetworkType.udp4.value
        or network == NetworkType.udp6.value
    ):
        if address != "":
            var host_port = split_host_port(address)
            host = host_port.host
            port = host_port.port
            portnum = atol(port.__str__())
    elif network == NetworkType.ip.value or network == NetworkType.ip4.value or network == NetworkType.ip6.value:
        if address != "":
            host = address
    elif network == NetworkType.unix.value:
        raise Error("Unix addresses not supported yet")
    else:
        raise Error("unsupported network type: " + network)
    return TCPAddr(host, portnum)


# TODO: For now listener is paired with TCP until we need to support
# more than one type of Connection or Listener
@value
struct ListenConfig(CollectionElement):
    var keep_alive: Duration

    fn listen(self, network: String, address: String) raises -> TCPListener:
        var tcp_addr = resolve_internet_addr(network, address)
        var socket = Socket(local_address=tcp_addr)
        socket.bind(tcp_addr.ip, tcp_addr.port)
        socket.set_socket_option(SO_REUSEADDR, 1)
        socket.listen()
        print(String("Listening on ") + socket.local_address)
        return TCPListener(socket^, self, network, address)


trait Listener(Movable):
    # Raising here because a Result[Optional[Connection], Error] is funky.
    fn accept(self) raises -> Connection:
        ...

    fn close(inout self) -> Error:
        ...

    fn addr(self) raises -> TCPAddr:
        ...


@value
struct TCPConnection(Conn):
    """TCPConn is an implementation of the Conn interface for TCP network connections.

    Args:
        connection: The underlying Connection.
    """

    var _connection: Connection

    fn __init__(inout self, connection: Connection):
        self._connection = connection

    fn __init__(inout self, owned socket: Socket):
        self._connection = Connection(socket^)

    fn __moveinit__(inout self, owned existing: Self):
        self._connection = existing._connection^

    fn read(inout self, inout dest: List[Byte]) -> (Int, Error):
        """Reads data from the underlying file descriptor.

        Args:
            dest: The buffer to read data into.

        Returns:
            The number of bytes read, or an error if one occurred.
        """
        var bytes_written: Int
        var err: Error
        bytes_written, err = self._connection.read(dest)
        if err:
            if str(err) != io.EOF:
                return 0, err

        return bytes_written, Error()

    fn write(inout self, src: List[Byte]) -> (Int, Error):
        """Writes data to the underlying file descriptor.

        Args:
            src: The buffer to read data into.

        Returns:
            The number of bytes written, or an error if one occurred.
        """
        var bytes_written: Int
        var err: Error
        bytes_written, err = self._connection.write(src)
        if err:
            return 0, err

        return bytes_written, Error()

    fn close(inout self) -> Error:
        """Closes the underlying file descriptor.

        Returns:
            An error if one occurred, or None if the file descriptor was closed successfully.
        """
        return self._connection.close()

    fn local_address(self) -> TCPAddr:
        """Returns the local network address.
        The Addr returned is shared by all invocations of local_address, so do not modify it.

        Returns:
            The local network address.
        """
        return self._connection.local_address()

    fn remote_address(self) -> TCPAddr:
        """Returns the remote network address.
        The Addr returned is shared by all invocations of remote_address, so do not modify it.

        Returns:
            The remote network address.
        """
        return self._connection.remote_address()


fn listen_tcp(network: String, local_address: TCPAddr) raises -> TCPListener:
    """Creates a new TCP listener.

    Args:
        network: The network type.
        local_address: The local address to listen on.
    """
    return ListenConfig(DEFAULT_TCP_KEEP_ALIVE).listen(network, local_address.ip + ":" + str(local_address.port))


fn listen_tcp(network: String, local_address: String) raises -> TCPListener:
    """Creates a new TCP listener.

    Args:
        network: The network type.
        local_address: The address to listen on. The format is "host:port".
    """
    return ListenConfig(DEFAULT_TCP_KEEP_ALIVE).listen(network, local_address)


struct TCPListener(Listener):
    var _file_descriptor: Socket
    var listen_config: ListenConfig
    var network_type: String
    var address: String

    fn __init__(
        inout self,
        owned file_descriptor: Socket,
        listen_config: ListenConfig,
        network_type: String,
        address: String,
    ):
        self._file_descriptor = file_descriptor^
        self.listen_config = listen_config
        self.network_type = network_type
        self.address = address

    fn __moveinit__(inout self, owned existing: Self):
        self._file_descriptor = existing._file_descriptor^
        self.listen_config = existing.listen_config^
        self.network_type = existing.network_type
        self.address = existing.address

    fn listen(self) raises -> Self:
        return self.listen_config.listen(self.network_type, self.address)

    fn accept(self) raises -> Connection:
        return Connection(self._file_descriptor.accept())

    fn accept_tcp(self) raises -> TCPConnection:
        return TCPConnection(self._file_descriptor.accept())

    fn close(inout self) -> Error:
        return self._file_descriptor.close()

    fn addr(self) raises -> TCPAddr:
        return resolve_internet_addr(self.network_type, self.address)
