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
from lightbug_http.io.bytes import Bytes, to_string, to_bytes, b64decode
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
    O_NONBLOCK,
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
)
from external.b64 import encode as b64_encode

# from external.b64 import decode as b64_decode


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

    @always_inline
    fn accept[T: Connection](self) raises -> T:
        let their_addr_ptr = Pointer[sockaddr].alloc(1)
        var sin_size = socklen_t(sizeof[socklen_t]())
        let new_sockfd = accept(
            self.fd, their_addr_ptr, Pointer[socklen_t].address_of(sin_size)
        )
        if new_sockfd == -1:
            print("Failed to accept connection")
        # TODO: pass raddr to connection
        return SysConnection(self.__addr, TCPAddr("", 0), new_sockfd)

    fn close(self) raises:
        _ = shutdown(self.fd, SHUT_RDWR)
        let close_status = close(self.fd)
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
        let addr = resolve_internet_addr(network, address)
        let address_family = AF_INET
        var ip_buf_size = 4
        if address_family == AF_INET6:
            ip_buf_size = 16

        let ip_buf = Pointer[c_void].alloc(ip_buf_size)
        let conv_status = inet_pton(address_family, to_char_ptr(addr.ip), ip_buf)
        let raw_ip = ip_buf.bitcast[c_uint]().load()

        let bin_port = htons(UInt16(addr.port))

        var ai = sockaddr_in(address_family, bin_port, raw_ip, StaticTuple[8, c_char]())
        let ai_ptr = Pointer[sockaddr_in].address_of(ai).bitcast[sockaddr]()

        let sockfd = socket(address_family, SOCK_STREAM, 0)
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

        let listener = SysListener(addr, sockfd)

        print("🔥🐝 Lightbug is listening on " + addr.ip + ":" + addr.port.__str__())
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
        let new_buf = Pointer[UInt8]().alloc(default_buffer_size)
        let bytes_recv = recv(self.fd, new_buf, default_buffer_size, 0)
        if bytes_recv == -1:
            print("Failed to receive message")
        let bytes_str = String(new_buf.bitcast[Int8](), bytes_recv)
        buf = bytes_str._buffer
        return bytes_recv

    async fn read_async(self, inout buf: Bytes) raises -> Int:
        @parameter
        async fn task() -> Int:
            try:
                _ = self.read(buf)
                return buf[0].__int__()
            except e:
                print("Failed to read from connection: " + e.__str__())
                return -1

        let routine: Coroutine[Int] = task()
        return await routine

    fn write(self, buf: Bytes) raises -> Int:
        let msg = String(buf)
        if send(self.fd, to_char_ptr(msg).bitcast[c_void](), len(msg), 0) == -1:
            print("Failed to send response")
        return len(buf)

    async fn write_async(self, buf: Bytes) raises -> Int:
        print("write_async " + b64decode(buf))

        @parameter
        async fn task() -> Int:
            try:
                let write_len = self.write(buf)
                return write_len
            except e:
                print("Failed to write to connection: " + e.__str__())
                return -1

        let routine: Coroutine[Int] = task()
        return await routine

    fn close(self) raises:
        _ = shutdown(self.fd, SHUT_RDWR)
        let close_status = close(self.fd)
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
