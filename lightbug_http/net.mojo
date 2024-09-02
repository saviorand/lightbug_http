from sys.info import sizeof
from lightbug_http.strings import NetworkType
from lightbug_http.io.bytes import Bytes
from lightbug_http.io.sync import Duration
from lightbug_http.sys.net import SysConnection
from .libc import (
    c_void,
    AF_INET,
    sockaddr,
    sockaddr_in,
    socklen_t,
    getsockname,
    getpeername,
    ntohs,
    inet_ntop
)

alias default_buffer_size = 4096
alias default_tcp_keep_alive = Duration(15 * 1000 * 1000 * 1000)  # 15 seconds


trait Net(DefaultConstructible):
    fn __init__(inout self) raises:
        ...

    fn __init__(inout self, keep_alive: Duration) raises:
        ...

    # A listen method should be implemented on structs that implement Net.
    # Signature is not enforced for now.
    # fn listen(inout self, network: String, addr: String) raises -> Listener:
    #    ...


trait ListenConfig:
    fn __init__(inout self, keep_alive: Duration) raises:
        ...

    # A listen method should be implemented on structs that implement ListenConfig.
    # Signature is not enforced for now.
    # fn listen(inout self, network: String, address: String) raises -> Listener:
    #    ...


trait Listener(Movable):
    fn __init__(inout self) raises:
        ...

    fn __init__(inout self, addr: TCPAddr) raises:
        ...

    fn accept(borrowed self) raises -> SysConnection:
        ...

    fn close(self) raises:
        ...

    fn addr(self) -> TCPAddr:
        ...


trait Connection(Movable):
    fn __init__(inout self, laddr: String, raddr: String) raises:
        ...

    fn __init__(inout self, laddr: TCPAddr, raddr: TCPAddr) raises:
        ...

    fn read(self, inout buf: Bytes) raises -> Int:
        ...

    fn write(self, buf: Bytes) raises -> Int:
        ...

    fn close(self) raises:
        ...

    fn local_addr(inout self) raises -> TCPAddr:
        ...

    fn remote_addr(self) raises -> TCPAddr:
        ...


trait Addr(CollectionElement):
    fn __init__(inout self):
        ...

    fn __init__(inout self, ip: String, port: Int):
        ...

    fn network(self) -> String:
        ...

    fn string(self) -> String:
        ...


alias TCPAddrList = List[TCPAddr]


@value
struct TCPAddr(Addr):
    var ip: String
    var port: Int
    var zone: String  # IPv6 addressing zone

    fn __init__(inout self):
        self.ip = String("127.0.0.1")
        self.port = 8000
        self.zone = ""

    fn __init__(inout self, ip: String, port: Int):
        self.ip = ip
        self.port = port
        self.zone = ""

    fn network(self) -> String:
        return NetworkType.tcp.value

    fn string(self) -> String:
        if self.zone != "":
            return join_host_port(self.ip + "%" + self.zone, self.port.__str__())
        return join_host_port(self.ip, self.port.__str__())


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
    elif (
        network == NetworkType.ip.value
        or network == NetworkType.ip4.value
        or network == NetworkType.ip6.value
    ):
        if address != "":
            host = address
    elif network == NetworkType.unix.value:
        raise Error("Unix addresses not supported yet")
    else:
        raise Error("unsupported network type: " + network)
    return TCPAddr(host, portnum)


fn join_host_port(host: String, port: String) -> String:
    if host.find(":") != -1:  # must be IPv6 literal
        return "[" + host + "]:" + port
    return host + ":" + port


alias missingPortError = Error("missing port in address")
alias tooManyColonsError = Error("too many colons in address")


struct HostPort:
    var host: String
    var port: String

    fn __init__(inout self, host: String, port: String):
        self.host = host
        self.port = port


fn split_host_port(hostport: String) raises -> HostPort:
    var host: String = ""
    var port: String = ""
    var colon_index = hostport.rfind(":")
    var j: Int = 0
    var k: Int = 0

    if colon_index == -1:
        raise missingPortError
    if hostport[0] == "[":
        var end_bracket_index = hostport.find("]")
        if end_bracket_index == -1:
            raise Error("missing ']' in address")
        if end_bracket_index + 1 == len(hostport):
            raise missingPortError
        elif end_bracket_index + 1 == colon_index:
            host = hostport[1:end_bracket_index]
            j = 1
            k = end_bracket_index + 1
        else:
            if hostport[end_bracket_index + 1] == ":":
                raise tooManyColonsError
            else:
                raise missingPortError
    else:
        host = hostport[:colon_index]
        if host.find(":") != -1:
            raise tooManyColonsError
    if hostport[j:].find("[") != -1:
        raise Error("unexpected '[' in address")
    if hostport[k:].find("]") != -1:
        raise Error("unexpected ']' in address")
    port = hostport[colon_index + 1 :]

    if port == "":
        raise missingPortError
    if host == "":
        raise Error("missing host")
    return HostPort(host, port)


fn convert_binary_port_to_int(port: UInt16) -> Int:
    return int(ntohs(port))


fn convert_binary_ip_to_string(
    owned ip_address: UInt32, address_family: Int32, address_length: UInt32
) -> String:
    """Convert a binary IP address to a string by calling inet_ntop.

    Args:
        ip_address: The binary IP address.
        address_family: The address family of the IP address.
        address_length: The length of the address.

    Returns:
        The IP address as a string.
    """
    # It seems like the len of the buffer depends on the length of the string IP.
    # Allocating 10 works for localhost (127.0.0.1) which I suspect is 9 bytes + 1 null terminator byte. So max should be 16 (15 + 1).
    var ip_buffer = UnsafePointer[c_void].alloc(16)
    var ip_address_ptr = UnsafePointer.address_of(ip_address).bitcast[c_void]()
    _ = inet_ntop(address_family, ip_address_ptr, ip_buffer, 16)

    var string_buf = ip_buffer.bitcast[Int8]()
    var index = 0
    while True:
        if string_buf[index] == 0:
            break
        index += 1

    return StringRef(string_buf, index)


fn get_sock_name(fd: Int32) raises -> HostPort:
    """Return the address of the socket."""
    var local_address_ptr = UnsafePointer[sockaddr].alloc(1)
    var local_address_ptr_size = socklen_t(sizeof[sockaddr]())
    var status = getsockname(
        fd,
        local_address_ptr,
        UnsafePointer[socklen_t].address_of(local_address_ptr_size),
    )
    if status == -1:
        raise Error("get_sock_name: Failed to get address of local socket.")
    var addr_in = local_address_ptr.bitcast[sockaddr_in]()[]

    return HostPort(
        host=convert_binary_ip_to_string(addr_in.sin_addr.s_addr, AF_INET, 16),
        port=convert_binary_port_to_int(addr_in.sin_port).__str__(),
    )


fn get_peer_name(fd: Int32) raises -> HostPort:
    """Return the address of the peer connected to the socket."""
    var remote_address_ptr = UnsafePointer[sockaddr].alloc(1)
    var remote_address_ptr_size = socklen_t(sizeof[sockaddr]())

    var status = getpeername(
        fd,
        remote_address_ptr,
        UnsafePointer[socklen_t].address_of(remote_address_ptr_size),
    )
    if status == -1:
        raise Error("get_peer_name: Failed to get address of remote socket.")

    # Cast sockaddr struct to sockaddr_in to convert binary IP to string.
    var addr_in = remote_address_ptr.bitcast[sockaddr_in]()[]

    return HostPort(
        host=convert_binary_ip_to_string(addr_in.sin_addr.s_addr, AF_INET, 16),
        port=convert_binary_port_to_int(addr_in.sin_port).__str__(),
    )
