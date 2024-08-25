from collections import InlineArray, InlineList
from utils import Span
from ..syscall import SocketOptions, SocketType
from .address import NetworkType, split_host_port, join_host_port, BaseAddr, resolve_internet_addr
from .socket import Socket


# TODO: Change ip to list of bytes
@value
struct UDPAddr(Addr):
    """Represents the address of a UDP end point.

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
        return NetworkType.udp.value


struct UDPConnection(Movable):
    """Implementation of the Conn interface for TCP network connections."""

    var socket: Socket

    fn __init__(inout self, owned socket: Socket):
        self.socket = socket^

    fn __moveinit__(inout self, owned existing: Self):
        self.socket = existing.socket^

    fn read_from(inout self, inout dest: List[UInt8]) -> (Int, HostPort, Error):
        """Reads data from the underlying file descriptor.

        Args:
            dest: The buffer to read data into.

        Returns:
            The number of bytes read, or an error if one occurred.
        """
        var bytes_read: Int
        var remote: HostPort
        var err = Error()
        bytes_read, remote, err = self.socket.receive_from_into(dest)
        if err:
            if str(err) != str(io.EOF):
                return bytes_read, remote, err

        return bytes_read, remote, err

    fn write_to(inout self, src: Span[UInt8], address: UDPAddr) -> (Int, Error):
        """Writes data to the underlying file descriptor.

        Args:
            src: The buffer to read data into.
            address: The remote peer address.

        Returns:
            The number of bytes written, or an error if one occurred.
        """
        return self.socket.send_to(src, address.ip, address.port)

    fn write_to(inout self, src: Span[UInt8], host: String, port: Int) -> (Int, Error):
        """Writes data to the underlying file descriptor.

        Args:
            src: The buffer to read data into.
            host: The remote peer address in IPv4 format.
            port: The remote peer port.

        Returns:
            The number of bytes written, or an error if one occurred.
        """
        return self.socket.send_to(src, host, port)

    fn close(inout self) -> Error:
        """Closes the underlying file descriptor.

        Returns:
            An error if one occurred, or None if the file descriptor was closed successfully.
        """
        return self.socket.close()

    fn local_address(self) -> UDPAddr:
        """Returns the local network address.
        The Addr returned is shared by all invocations of local_address, so do not modify it.

        Returns:
            The local network address.
        """
        return self.socket.local_address_as_udp()

    fn remote_address(self) -> UDPAddr:
        """Returns the remote network address.
        The Addr returned is shared by all invocations of remote_address, so do not modify it.

        Returns:
            The remote network address.
        """
        return self.socket.remote_address_as_udp()


fn listen_udp(network: String, local_address: UDPAddr) raises -> UDPConnection:
    """Creates a new UDP listener.

    Args:
        network: The network type.
        local_address: The local address to listen on.
    """
    var socket = Socket(socket_type=SocketType.SOCK_DGRAM)
    socket.bind(local_address.ip, local_address.port)
    # print(str("Listening on ") + str(socket.local_address_as_udp()))
    return UDPConnection(socket^)


fn listen_udp(network: String, local_address: String) raises -> UDPConnection:
    """Creates a new UDP listener.

    Args:
        network: The network type.
        local_address: The address to listen on. The format is "host:port".
    """
    var result = split_host_port(local_address)
    return listen_udp(network, UDPAddr(result[0].host, result[0].port))


fn listen_udp(network: String, host: String, port: Int) raises -> UDPConnection:
    """Creates a new UDP listener.

    Args:
        network: The network type.
        host: The address to listen on in ipv4 format.
        port: The port number.
    """
    return listen_udp(network, UDPAddr(host, port))


alias UDP_NETWORK_TYPES = InlineList[String, 3]("udp", "udp4", "udp6")


fn dial_udp(network: String, local_address: UDPAddr) raises -> UDPConnection:
    """Connects to the address on the named network.

    The network must be "udp", "udp4", or "udp6".
    Args:
        network: The network type.
        local_address: The local address.

    Returns:
        The TCP connection.
    """
    # TODO: Add conversion of domain name to ip address
    if network not in UDP_NETWORK_TYPES:
        raise Error("unsupported network type: " + network)

    var socket = Socket(local_address=BaseAddr(local_address), socket_type=SocketType.SOCK_DGRAM)
    return UDPConnection(socket^)


fn dial_udp(network: String, local_address: String) raises -> UDPConnection:
    """Connects to the address on the named network.

    The network must be "udp", "udp4", or "udp6".
    Args:
        network: The network type.
        local_address: The local address to connect to. (The format is "host:port").

    Returns:
        The TCP connection.
    """
    var result = split_host_port(local_address)
    if result[1]:
        raise result[1]

    return dial_udp(network, UDPAddr(result[0].host, result[0].port))


fn dial_udp(network: String, host: String, port: Int) raises -> UDPConnection:
    """Connects to the address on the named network.

    The network must be "udp", "udp4", or "udp6".
    Args:
        network: The network type.
        host: The remote host in ipv4 format.
        port: The remote port.

    Returns:
        The TCP connection.
    """
    return dial_udp(network, UDPAddr(host, port))
