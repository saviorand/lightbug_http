from lightbug_http.net import (
    Listener,
    ListenConfig,
    Connection,
    TCPAddr,
    Net,
    resolve_internet_addr,
    default_buffer_size,
    default_tcp_keep_alive,
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
    getsockopt,
    listen,
    accept,
    send,
    recv,
    bind,
    shutdown,
    close,
    free,
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
            raise Error("Failed to accept connection")
        # TODO: pass raddr to connection
        # free memory

        return SysConnection(self.__addr, TCPAddr("", 0), new_sockfd)

    fn close(self) raises:
        _ = shutdown(self.fd, SHUT_RDWR)
        var close_status = close(self.fd)
        if close_status == -1:
            raise Error("Failed to close new_sockfd")

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

        var ai = sockaddr_in(address_family, bin_port, raw_ip, StaticTuple[8, c_char]())
        var ai_ptr = Pointer[sockaddr_in].address_of(ai).bitcast[sockaddr]()

        var sockfd = socket(address_family, SOCK_STREAM, 0)
        if sockfd == -1:
            print("Socket creation error")

        var yes: Int = 1
        var setoptstatus = setsockopt(
            sockfd,
            SOL_SOCKET,
            SO_REUSEADDR,
            Pointer[Int].address_of(yes).bitcast[c_void](),
            sizeof[Int](),
        )
        # if setoptstatus == -1:
        #     var option_value: Int = 0
        #     var option_len: socklen_t = sizeof[Int]()
        #     var status = getsockopt(
        #         sockfd,
        #         SOL_SOCKET,
        #         SO_REUSEADDR,
        #         Pointer[Int].address_of(option_value).bitcast[c_void](),
        #         Pointer[socklen_t].address_of(option_len),
        #     )
        #     if status == -1:
        #         print("Failed to get socket option SO_REUSEADDR")
        #     else:
        #         print("SO_REUSEADDR is set to: ", option_value)
        #     raise Error("Setsockopt failed")

        if bind(sockfd, ai_ptr, sizeof[sockaddr_in]()) == -1:
            _ = shutdown(sockfd, SHUT_RDWR)
            var close_status = close(sockfd)
            if close_status == -1:
                raise Error("Failed to close new_sockfd")
            raise Error("Binding socket failed. Wait a few seconds and try again?")

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
            raise Error("Failed to receive message")
        var bytes_str = String(new_buf.bitcast[Int8](), bytes_recv)
        buf += bytes_str.as_bytes()
        return bytes_recv

    fn write(self, buf: Bytes) raises -> Int:
        var msg = buf.__str__()
        if send(self.fd, to_char_ptr(msg).bitcast[c_void](), len(msg), 0) == -1:
            raise Error("Failed to send response")
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
