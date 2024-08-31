from utils import Span
from collections import InlineList
from ..syscall import SocketOptions
from .address import NetworkType, split_host_port, join_host_port, BaseAddr, resolve_internet_addr, HostPort
from .socket import Socket


@value
struct TCPAddr(Addr):
    """Addr struct representing a TCP address.

    Args:
        ip: IP address.
        port: Port number.
        zone: IPv6 addressing zone.
    """

    var ip: String
    var port: Int
    var zone: String  # IPv6 addressing zone

    fn __init__(inout self, ip: String = "127.0.0.1", port: Int = 8000, zone: String = ""):
        self.ip = ip
        self.port = port
        self.zone = zone

    fn __init__(inout self, addr: BaseAddr):
        self.ip = addr.ip
        self.port = addr.port
        self.zone = addr.zone

    fn __str__(self) -> String:
        if self.zone != "":
            return join_host_port(str(self.ip) + "%" + self.zone, str(self.port))
        return join_host_port(self.ip, str(self.port))

    fn network(self) -> String:
        return NetworkType.tcp.value


struct TCPConnection(Movable):
    """TCPConn is an implementation of the Conn interface for TCP network connections.

    Args:
        connection: The underlying Connection.
    """

    var socket: Socket

    fn __init__(inout self, owned socket: Socket):
        self.socket = socket^

    fn __moveinit__(inout self, owned existing: Self):
        self.socket = existing.socket^

    fn _read(inout self, inout dest: UnsafePointer[UInt8], capacity: Int) -> (Int, Error):
        """Reads data from the underlying file descriptor.

        Args:
            dest: The buffer to read data into.
            capacity: The capacity of the destination buffer.

        Returns:
            The number of bytes read, or an error if one occurred.
        """
        var bytes_read: Int
        var err = Error()
        bytes_read, err = self.socket._read(dest, capacity)
        if err:
            if str(err) != str(io.EOF):
                return bytes_read, err

        return bytes_read, err

    fn read(inout self, inout dest: List[UInt8, True]) -> (Int, Error):
        """Reads data from the underlying file descriptor.

        Args:
            dest: The buffer to read data into.

        Returns:
            The number of bytes read, or an error if one occurred.
        """
        if dest.size == dest.capacity:
            return 0, Error("net.tcp.TCPConnection.read: no space left in destination buffer.")

        var dest_ptr = dest.unsafe_ptr().offset(dest.size)
        var bytes_read: Int
        var err: Error
        bytes_read, err = self._read(dest_ptr, dest.capacity - dest.size)
        dest.size += bytes_read

        return bytes_read, err

    fn write(inout self, src: Span[UInt8]) -> (Int, Error):
        """Writes data to the underlying file descriptor.

        Args:
            src: The buffer to read data into.

        Returns:
            The number of bytes written, or an error if one occurred.
        """
        return self.socket.write(src)

    fn close(inout self) -> Error:
        """Closes the underlying file descriptor.

        Returns:
            An error if one occurred, or None if the file descriptor was closed successfully.
        """
        return self.socket.close()

    fn local_address(self) -> TCPAddr:
        """Returns the local network address.
        The Addr returned is shared by all invocations of local_address, so do not modify it.

        Returns:
            The local network address.
        """
        return self.socket.local_address_as_tcp()

    fn remote_address(self) -> TCPAddr:
        """Returns the remote network address.
        The Addr returned is shared by all invocations of remote_address, so do not modify it.

        Returns:
            The remote network address.
        """
        return self.socket.remote_address_as_tcp()


fn listen_tcp(network: String, local_address: TCPAddr) raises -> TCPListener:
    """Creates a new TCP listener.

    Args:
        network: The network type.
        local_address: The local address to listen on.
    """
    var socket = Socket()
    socket.bind(local_address.ip, local_address.port)
    socket.set_socket_option(SocketOptions.SO_REUSEADDR, 1)
    socket.listen()
    # print(str("Listening on ") + str(socket.local_address_as_tcp()))
    return TCPListener(socket^, network, local_address)


fn listen_tcp(network: String, local_address: String) raises -> TCPListener:
    """Creates a new TCP listener.

    Args:
        network: The network type.
        local_address: The address to listen on. The format is "host:port".
    """
    var tcp_addr: TCPAddr
    var err: Error
    tcp_addr, err = resolve_internet_addr(network, local_address)
    if err:
        raise err
    return listen_tcp(network, tcp_addr)


fn listen_tcp(network: String, host: String, port: Int) raises -> TCPListener:
    """Creates a new TCP listener.

    Args:
        network: The network type.
        host: The address to listen on, in ipv4 format.
        port: The port to listen on.
    """
    return listen_tcp(network, TCPAddr(host, port))


struct TCPListener:
    var socket: Socket
    var network_type: String
    var address: TCPAddr

    fn __init__(
        inout self,
        owned socket: Socket,
        network_type: String,
        address: TCPAddr,
    ):
        self.socket = socket^
        self.network_type = network_type
        self.address = address

    fn __moveinit__(inout self, owned existing: Self):
        self.socket = existing.socket^
        self.network_type = existing.network_type^
        self.address = existing.address^

    fn accept(self) raises -> TCPConnection:
        return TCPConnection(self.socket.accept())

    fn close(inout self) -> Error:
        return self.socket.close()


alias TCP_NETWORK_TYPES = InlineList[String, 3]("tcp", "tcp4", "tcp6")


fn dial_tcp(network: String, remote_address: TCPAddr) raises -> TCPConnection:
    """Connects to the address on the named network.

    The network must be "tcp", "tcp4", or "tcp6".
    Args:
        network: The network type.
        remote_address: The remote address to connect to.

    Returns:
        The TCP connection.
    """
    # TODO: Add conversion of domain name to ip address
    if network not in TCP_NETWORK_TYPES:
        raise Error("unsupported network type: " + network)

    var socket = Socket()
    var err = socket.connect(remote_address.ip, remote_address.port)
    if err:
        raise err
    return TCPConnection(socket^)


fn dial_tcp(network: String, remote_address: String) raises -> TCPConnection:
    """Connects to the address on the named network.

    The network must be "tcp", "tcp4", or "tcp6".
    Args:
        network: The network type.
        remote_address: The remote address to connect to. (The format is "host:port").

    Returns:
        The TCP connection.
    """
    var remote: HostPort
    var err: Error
    remote, err = split_host_port(remote_address)
    if err:
        raise err
    return dial_tcp(network, TCPAddr(remote.host, remote.port))


fn dial_tcp(network: String, host: String, port: Int) raises -> TCPConnection:
    """Connects to the address on the named network.

    The network must be "tcp", "tcp4", or "tcp6".
    Args:
        network: The network type.
        host: The remote address to connect to in ipv4 format.
        port: The remote port.

    Returns:
        The TCP connection.
    """
    return dial_tcp(network, TCPAddr(host, port))
