from utils import StaticTuple
from time import sleep
from sys.info import sizeof, os_is_macos
from sys.ffi import external_call
from lightbug_http.strings import NetworkType
from lightbug_http.strings import NetworkType, to_string
from lightbug_http.io.bytes import Bytes, bytes
from lightbug_http.io.sync import Duration
from .libc import (
    c_void,
    c_int,
    c_uint,
    c_char,
    c_ssize_t,
    in_addr,
    sockaddr,
    sockaddr_in,
    socklen_t,
    AI_PASSIVE,
    AF_INET,
    AF_INET6,
    SOCK_STREAM,
    SOL_SOCKET,
    SO_REUSEADDR,
    SHUT_RDWR,
    htons,
    ntohs,
    inet_pton,
    inet_ntop,
    to_char_ptr,
    socket,
    connect,
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
)


alias default_buffer_size = 4096
alias default_tcp_keep_alive = Duration(15 * 1000 * 1000 * 1000)  # 15 seconds


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


trait AnAddrInfo:
    fn get_ip_address(self, host: String) raises -> in_addr:
        """
        TODO: Once default functions can be implemented in traits, this function should use the functions currently
        implemented in the `addrinfo_macos` and `addrinfo_unix` structs.
        """
        ...


@value
struct NoTLSListener:
    """
    A TCP listener that listens for incoming connections and can accept them.
    """

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
        var their_addr = sockaddr(0, StaticTuple[c_char, 14]())
        var their_addr_ptr = Reference[sockaddr](their_addr)
        var sin_size = socklen_t(sizeof[socklen_t]())
        var sin_size_ptr = Reference[socklen_t](sin_size)
        var new_sockfd = external_call["accept", c_int](self.fd, their_addr_ptr, sin_size_ptr)

        # var new_sockfd = accept(
        #     self.fd, their_addr_ptr, UnsafePointer[socklen_t].address_of(sin_size)
        # )
        if new_sockfd == -1:
            print("Failed to accept connection, system accept() returned an error.")
        var peer = get_peer_name(new_sockfd)

        return SysConnection(self.__addr, TCPAddr(peer.host, atol(peer.port)), new_sockfd)

    fn close(self) raises:
        _ = shutdown(self.fd, SHUT_RDWR)
        var close_status = close(self.fd)
        if close_status == -1:
            print("Failed to close listener")

    fn addr(self) -> TCPAddr:
        return self.__addr


struct ListenConfig:
    var __keep_alive: Duration

    fn __init__(inout self) raises:
        self.__keep_alive = default_tcp_keep_alive

    fn __init__(inout self, keep_alive: Duration) raises:
        self.__keep_alive = keep_alive

    fn listen(inout self, network: String, address: String) raises -> NoTLSListener:
        var addr = resolve_internet_addr(network, address)
        var address_family = AF_INET
        var ip_buf_size = 4
        if address_family == AF_INET6:
            ip_buf_size = 16

        var sockfd = socket(address_family, SOCK_STREAM, 0)
        if sockfd == -1:
            print("Socket creation error")

        var yes: Int = 1
        var setsockopt_result = setsockopt(
            sockfd,
            SOL_SOCKET,
            SO_REUSEADDR,
            UnsafePointer[Int].address_of(yes).bitcast[c_void](),
            sizeof[Int](),
        )

        var bind_success = False
        var bind_fail_logged = False

        var ip_buf = UnsafePointer[c_void].alloc(ip_buf_size)
        var conv_status = inet_pton(address_family, to_char_ptr(addr.ip), ip_buf)
        var raw_ip = ip_buf.bitcast[c_uint]()[]
        var bin_port = htons(UInt16(addr.port))

        var ai = sockaddr_in(address_family, bin_port, raw_ip, StaticTuple[c_char, 8]())
        var ai_ptr = Reference[sockaddr_in](ai)

        while not bind_success:
            # var bind = bind(sockfd, ai_ptr, sizeof[sockaddr_in]())
            var bind = external_call["bind", c_int](sockfd, ai_ptr, sizeof[sockaddr_in]())
            if bind == 0:
                bind_success = True
            else:
                if not bind_fail_logged:
                    print("Bind attempt failed. The address might be in use or the socket might not be available.")
                    print("Retrying. Might take 10-15 seconds.")
                    bind_fail_logged = True
                print(".", end="", flush=True)
                _ = shutdown(sockfd, SHUT_RDWR)
                sleep(1)

        if listen(sockfd, c_int(128)) == -1:
            print("Listen failed.\n on sockfd " + sockfd.__str__())

        var listener = NoTLSListener(addr, sockfd)

        print("\n🔥🐝 Lightbug is listening on " + "http://" + addr.ip + ":" + addr.port.__str__())
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
        var bytes_recv = recv(
            self.fd,
            buf.unsafe_ptr().offset(buf.size),
            buf.capacity - buf.size,
            0,
        )
        if bytes_recv == -1:
            return 0
        buf.size += bytes_recv
        if bytes_recv == 0:
            return 0
        if bytes_recv < buf.capacity:
            return bytes_recv
        return bytes_recv

    fn write(self, owned msg: String) raises -> Int:
        var bytes_sent = send(self.fd, msg.unsafe_ptr(), len(msg), 0)
        if bytes_sent == -1:
            print("Failed to send response")
        return bytes_sent

    fn write(self, buf: Bytes) raises -> Int:
        var content = to_string(buf)
        var bytes_sent = send(self.fd, content.unsafe_ptr(), len(content), 0)
        if bytes_sent == -1:
            print("Failed to send response")
        _ = content
        return bytes_sent

    fn close(self) raises:
        _ = shutdown(self.fd, SHUT_RDWR)
        var close_status = close(self.fd)
        if close_status == -1:
            print("Failed to close connection")

    fn local_addr(inout self) raises -> TCPAddr:
        return self.laddr

    fn remote_addr(self) raises -> TCPAddr:
        return self.raddr


struct SysNet:
    var __lc: ListenConfig

    fn __init__(inout self) raises:
        self.__lc = ListenConfig(default_tcp_keep_alive)

    fn __init__(inout self, keep_alive: Duration) raises:
        self.__lc = ListenConfig(keep_alive)

    fn listen(inout self, network: String, addr: String) raises -> NoTLSListener:
        return self.__lc.listen(network, addr)


@value
@register_passable("trivial")
struct addrinfo_macos(AnAddrInfo):
    """
    For MacOS, I had to swap the order of ai_canonname and ai_addr.
    https://stackoverflow.com/questions/53575101/calling-getaddrinfo-directly-from-python-ai-addr-is-null-pointer.
    """

    var ai_flags: c_int
    var ai_family: c_int
    var ai_socktype: c_int
    var ai_protocol: c_int
    var ai_addrlen: socklen_t
    var ai_canonname: UnsafePointer[c_char]
    var ai_addr: UnsafePointer[sockaddr]
    var ai_next: UnsafePointer[c_void]

    fn __init__(inout self):
        self.ai_flags = 0
        self.ai_family = 0
        self.ai_socktype = 0
        self.ai_protocol = 0
        self.ai_addrlen = 0
        self.ai_canonname = UnsafePointer[c_char]()
        self.ai_addr = UnsafePointer[sockaddr]()
        self.ai_next = UnsafePointer[c_void]()

    fn get_ip_address(self, host: String) raises -> in_addr:
        """
        Returns an IP address based on the host.
        This is a MacOS-specific implementation.

        Args:
            host: String - The host to get the IP from.

        Returns:
            in_addr - The IP address.
        """
        var host_ptr = to_char_ptr(host)
        var servinfo = Reference(Self())
        var servname = UnsafePointer[Int8]()

        var hints = Self()
        hints.ai_family = AF_INET
        hints.ai_socktype = SOCK_STREAM
        hints.ai_flags = AI_PASSIVE

        var error = external_call[
            "getaddrinfo",
            Int32,
        ](host_ptr, servname, Reference(hints), Reference(servinfo))

        if error != 0:
            print("getaddrinfo failed with error code: " + error.__str__())
            raise Error("Failed to get IP address. getaddrinfo failed.")

        var addrinfo = servinfo[]

        var ai_addr = addrinfo.ai_addr
        if not ai_addr:
            print("ai_addr is null")
            raise Error("Failed to get IP address. getaddrinfo was called successfully, but ai_addr is null.")

        var addr_in = ai_addr.bitcast[sockaddr_in]()[]

        return addr_in.sin_addr


@value
@register_passable("trivial")
struct addrinfo_unix(AnAddrInfo):
    """
    Standard addrinfo struct for Unix systems. Overwrites the existing libc `getaddrinfo` function to adhere to the AnAddrInfo trait.
    """

    var ai_flags: c_int
    var ai_family: c_int
    var ai_socktype: c_int
    var ai_protocol: c_int
    var ai_addrlen: socklen_t
    var ai_addr: UnsafePointer[sockaddr]
    var ai_canonname: UnsafePointer[c_char]
    var ai_next: UnsafePointer[c_void]

    fn __init__(inout self):
        self.ai_flags = 0
        self.ai_family = 0
        self.ai_socktype = 0
        self.ai_protocol = 0
        self.ai_addrlen = 0
        self.ai_addr = UnsafePointer[sockaddr]()
        self.ai_canonname = UnsafePointer[c_char]()
        self.ai_next = UnsafePointer[c_void]()

    fn get_ip_address(self, host: String) raises -> in_addr:
        """
        Returns an IP address based on the host.
        This is a Unix-specific implementation.

        Args:
            host: String - The host to get IP from.

        Returns:
            UInt32 - The IP address.
        """
        var host_ptr = to_char_ptr(host)
        var servinfo = UnsafePointer[Self]().alloc(1)
        servinfo.init_pointee_move(Self())

        var hints = Self()
        hints.ai_family = AF_INET
        hints.ai_socktype = SOCK_STREAM
        hints.ai_flags = AI_PASSIVE

        var error = getaddrinfo[Self](
            host_ptr,
            UnsafePointer[UInt8](),
            UnsafePointer.address_of(hints),
            UnsafePointer.address_of(servinfo),
        )
        if error != 0:
            print("getaddrinfo failed")
            raise Error("Failed to get IP address. getaddrinfo failed.")

        var addrinfo = servinfo[]

        var ai_addr = addrinfo.ai_addr
        if not ai_addr:
            print("ai_addr is null")
            raise Error("Failed to get IP address. getaddrinfo was called successfully, but ai_addr is null.")

        var addr_in = ai_addr.bitcast[sockaddr_in]()[]

        return addr_in.sin_addr


fn create_connection(sock: c_int, host: String, port: UInt16) raises -> SysConnection:
    """
    Connect to a server using a socket.

    Args:
        sock: Int32 - The socket file descriptor.
        host: String - The host to connect to.
        port: UInt16 - The port to connect to.

    Returns:
        Int32 - The socket file descriptor.
    """
    var ip: in_addr
    if os_is_macos():
        ip = addrinfo_macos().get_ip_address(host)
    else:
        ip = addrinfo_unix().get_ip_address(host)

    # Convert ip address to network byte order.
    var addr: sockaddr_in = sockaddr_in(AF_INET, htons(port), ip, StaticTuple[c_char, 8](0, 0, 0, 0, 0, 0, 0, 0))
    var addr_ptr = Reference[sockaddr_in](addr)

    if external_call["connect", c_int](sock, addr_ptr, sizeof[sockaddr_in]()) == -1:
        _ = shutdown(sock, SHUT_RDWR)
        raise Error("Failed to connect to server")

    var laddr = TCPAddr()
    var raddr = TCPAddr(host, int(port))
    var conn = SysConnection(sock, laddr, raddr)

    return conn


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
    elif network == NetworkType.ip.value or network == NetworkType.ip4.value or network == NetworkType.ip6.value:
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


fn convert_binary_ip_to_string(owned ip_address: UInt32, address_family: Int32, address_length: UInt32) -> String:
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


fn getaddrinfo[
    T: AnAddrInfo
](
    nodename: UnsafePointer[c_char],
    servname: UnsafePointer[c_char],
    hints: UnsafePointer[T],
    res: UnsafePointer[UnsafePointer[T]],
) -> c_int:
    """
    Overwrites the existing libc `getaddrinfo` function to use the AnAddrInfo trait.

    Libc POSIX `getaddrinfo` function
    Reference: https://man7.org/linux/man-pages/man3/getaddrinfo.3p.html
    Fn signature: int getaddrinfo(const char *restrict nodename, const char *restrict servname, const struct addrinfo *restrict hints, struct addrinfo **restrict res).
    """
    return external_call[
        "getaddrinfo",
        c_int,  # FnName, RetType
        UnsafePointer[c_char],
        UnsafePointer[c_char],
        UnsafePointer[T],  # Args
        UnsafePointer[UnsafePointer[T]],  # Args
    ](nodename, servname, hints, res)
