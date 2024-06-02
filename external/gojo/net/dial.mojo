from .tcp import TCPAddr, TCPConnection, resolve_internet_addr
from .socket import Socket
from .address import split_host_port


@value
struct Dialer:
    var local_address: TCPAddr

    fn dial(self, network: String, address: String) raises -> TCPConnection:
        var tcp_addr = resolve_internet_addr(network, address)
        var socket = Socket(local_address=self.local_address)
        socket.connect(tcp_addr.ip, tcp_addr.port)
        return TCPConnection(socket^)


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
    return Dialer(remote_address).dial(network, remote_address.ip + ":" + str(remote_address.port))


fn dial_tcp(network: String, remote_address: String) raises -> TCPConnection:
    """Connects to the address on the named network.

    The network must be "tcp", "tcp4", or "tcp6".
    Args:
        network: The network type.
        remote_address: The remote address to connect to.

    Returns:
        The TCP connection.
    """
    var address = split_host_port(remote_address)
    return Dialer(TCPAddr(address.host, address.port)).dial(network, remote_address)
