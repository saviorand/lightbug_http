from lightbug_http.net import (
    Listener,
    ListenConfig,
    Connection,
    TCPAddr,
    Net,
    resolve_internet_addr,
    default_buffer_size,
    default_tcp_keep_alive,
    HostPort
)
from lightbug_http.strings import NetworkType
from lightbug_http.io.bytes import Bytes
from lightbug_http.io.sync import Duration
from external.libc import (
    c_void,
    c_int,
    c_uint,
    c_char,
    sockaddr,
    sockaddr_in,
    socklen_t,
    AF_INET,
    AF_INET6,
    SOCK_STREAM,
    SOL_SOCKET,
    SO_REUSEADDR,
    SHUT_RDWR,
    htons,
    inet_pton,
    to_char_ptr,
    socket,
    setsockopt,
    listen,
    accept,
    send,
    recv,
    bind,
    shutdown,
    close,
    getsockname,
    getpeername,
    ntohs,
    inet_ntop
)


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
    var ip_buffer = Pointer[c_void].alloc(16)
    var ip_address_ptr = Pointer.address_of(ip_address).bitcast[c_void]()
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
    var local_address_ptr = Pointer[sockaddr].alloc(1)
    var local_address_ptr_size = socklen_t(sizeof[sockaddr]())
    var status = getsockname(
        fd,
        local_address_ptr,
        Pointer[socklen_t].address_of(local_address_ptr_size),
    )
    if status == -1:
        raise Error("get_sock_name: Failed to get address of local socket.")
    var addr_in = local_address_ptr.bitcast[sockaddr_in]().load()

    return HostPort(
        host=convert_binary_ip_to_string(addr_in.sin_addr.s_addr, AF_INET, 16),
        port=convert_binary_port_to_int(addr_in.sin_port),
    )


fn get_peer_name(fd: Int32) raises -> HostPort:
    """Return the address of the peer connected to the socket."""
    var remote_address_ptr = Pointer[sockaddr].alloc(1)
    var remote_address_ptr_size = socklen_t(sizeof[sockaddr]())
    var status = getpeername(
        fd,
        remote_address_ptr,
        Pointer[socklen_t].address_of(remote_address_ptr_size),
    )
    if status == -1:
        raise Error("get_peer_name: Failed to get address of remote socket.")

    # Cast sockaddr struct to sockaddr_in to convert binary IP to string.
    var addr_in = remote_address_ptr.bitcast[sockaddr_in]().load()

    return HostPort(
        host=convert_binary_ip_to_string(addr_in.sin_addr.s_addr, AF_INET, 16),
        port=convert_binary_port_to_int(addr_in.sin_port),
    )


@value
struct SysListener(Listener):
    var fd: c_int
    var __addr: TCPAddr

    fn __init__(inout self) raises:
        self.__addr = TCPAddr("localhost", 8080)
        self.fd = socket(AF_INET, SOCK_STREAM, 0)

    fn __init__(inout self, addr: TCPAddr) raises:
        self.__addr = addr
        self.fd = socket(AF_INET, SOCK_STREAM, 0)

    fn __init__(inout self, addr: TCPAddr, fd: c_int) raises:
        self.__addr = addr
        self.fd = fd

    fn accept(self) raises -> SysConnection:
        var their_addr_ptr = Pointer[sockaddr].alloc(1)
        var sin_size = socklen_t(sizeof[socklen_t]())
        var new_sockfd = accept(
            self.fd, their_addr_ptr, Pointer[socklen_t].address_of(sin_size)
        )
        if new_sockfd == -1:
            print("Failed to accept connection")
        var peer = get_peer_name(new_sockfd)

        return SysConnection(self.__addr, TCPAddr(peer.host, atol(peer.port)), new_sockfd)

    fn close(self) raises:
        _ = shutdown(self.fd, SHUT_RDWR)
        var close_status = close(self.fd)
        if close_status == -1:
            print("Failed to close new_sockfd")

    fn addr(self) -> TCPAddr:
        return self.__addr


struct SysListenConfig(ListenConfig):
    var __keep_alive: Duration

    fn __init__(inout self) raises:
        self.__keep_alive = Duration(default_tcp_keep_alive)

    fn __init__(inout self, keep_alive: Duration) raises:
        self.__keep_alive = Duration(keep_alive)

    fn listen(inout self, network: String, address: String) raises -> SysListener:
        var addr = resolve_internet_addr(network, address)
        var address_family = AF_INET
        var ip_buf_size = 4
        if address_family == AF_INET6:
            ip_buf_size = 16

        var ip_buf = Pointer[c_void].alloc(ip_buf_size)
        var conv_status = inet_pton(address_family, to_char_ptr(addr.ip), ip_buf)
        var raw_ip = ip_buf.bitcast[c_uint]().load()

        var bin_port = htons(UInt16(addr.port))

        var ai = sockaddr_in(address_family, bin_port, raw_ip, StaticTuple[c_char, 8]())
        var ai_ptr = Pointer[sockaddr_in].address_of(ai).bitcast[sockaddr]()

        var sockfd = socket(address_family, SOCK_STREAM, 0)
        if sockfd == -1:
            print("Socket creation error")

        var yes: Int = 1
        _ = setsockopt(
            sockfd,
            SOL_SOCKET,
            SO_REUSEADDR,
            Pointer[Int].address_of(yes).bitcast[c_void](),
            sizeof[Int](),
        )

        if bind(sockfd, ai_ptr, sizeof[sockaddr_in]()) == -1:
            _ = shutdown(sockfd, SHUT_RDWR)
            print("Binding socket failed. Wait a few seconds and try again?")

        if listen(sockfd, c_int(128)) == -1:
            print("Listen failed.\n on sockfd " + sockfd.__str__())

        var listener = SysListener(addr, sockfd)

        print(
            "🔥🐝 Lightbug is listening on "
            + "http://"
            + addr.ip
            + ":"
            + addr.port.__str__()
        )
        print("Ready to accept connections...")

        return listener


@value
struct SysConnection(Connection):
    var fd: c_int
    var raddr: TCPAddr
    var laddr: TCPAddr

    fn __init__(inout self, laddr: String, raddr: String) raises:
        self.raddr = resolve_internet_addr(NetworkType.tcp4.value, raddr)
        self.laddr = resolve_internet_addr(NetworkType.tcp4.value, laddr)
        self.fd = socket(AF_INET, SOCK_STREAM, 0)

    fn __init__(inout self, laddr: TCPAddr, raddr: TCPAddr) raises:
        self.raddr = raddr
        self.laddr = laddr
        self.fd = socket(AF_INET, SOCK_STREAM, 0)

    fn __init__(inout self, laddr: TCPAddr, raddr: TCPAddr, fd: c_int) raises:
        self.raddr = raddr
        self.laddr = laddr
        self.fd = fd

    fn read(self, inout buf: Bytes) raises -> Int:
        var new_buf = Pointer[UInt8]().alloc(default_buffer_size)
        var bytes_recv = recv(self.fd, new_buf, default_buffer_size, 0)
        if bytes_recv == -1:
            print("Failed to receive message")
        var bytes_str = String(new_buf.bitcast[Int8](), bytes_recv)
        buf = bytes_str._buffer
        return bytes_recv

    fn write(self, buf: Bytes) raises -> Int:
        var msg = String(buf)
        if send(self.fd, to_char_ptr(msg).bitcast[c_void](), len(msg), 0) == -1:
            print("Failed to send response")
        return len(buf)

    fn close(self) raises:
        _ = shutdown(self.fd, SHUT_RDWR)
        var close_status = close(self.fd)
        if close_status == -1:
            print("Failed to close new_sockfd")

    fn local_addr(inout self) raises -> TCPAddr:
        return self.laddr

    fn remote_addr(self) raises -> TCPAddr:
        return self.raddr


struct SysNet(Net):
    var __lc: SysListenConfig

    fn __init__(inout self):
        try:
            self.__lc = SysListenConfig(default_tcp_keep_alive)
        except e:
            print("Could not initialize SysListenConfig: " + e.__str__())

    fn __init__(inout self, keep_alive: Duration) raises:
        self.__lc = SysListenConfig(keep_alive)

    fn listen(inout self, network: String, addr: String) raises -> SysListener:
        return self.__lc.listen(network, addr)
