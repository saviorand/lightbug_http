from collections.vector import InlinedFixedVector
from lightbug_http.net import (
    Listener,
    ListenConfig,
    Connection,
    TCPAddr,
    Net,
    resolve_internet_addr,
    default_tcp_keep_alive,
)
from lightbug_http.strings import NetworkType
from lightbug_http.io.fd import FileDescriptor
from lightbug_http.io.bytes import Bytes
from lightbug_http.io.sync import Duration
from lightbug_http.sys.libc import (
    c_void,
    c_int,
    c_uint,
    c_char,
    sockaddr,
    sockaddr_in,
    socklen_t,
    EPROTONOSUPPORT,
    EINVAL,
    AF_INET,
    AF_INET6,
    AF_UNIX,
    IPPROTO_IPV6,
    IPV6_V6ONLY,
    SOCK_CLOEXEC,
    SOCK_STREAM,
    SOL_SOCKET,
    SO_BROADCAST,
    SO_REUSEADDR,
    SOCK_NONBLOCK,
    SOCK_DGRAM,
    SOCK_RAW,
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


alias __sock_len = UInt32


fn internet_socket(
    network: String,
    family: Int,
    laddr: String,
    raddr: String,
    sotype: Int,
    proto: Int,
    mode: String,
) raises -> NetFileDescriptor:
    let ipv6only = False
    let s = sys_socket(family, sotype, proto)
    set_default_socket_options(s, family, sotype, ipv6only)
    try:
        # let fd = new_net_fd(s, family, sotype, network)
        # TODO: stream and datagram listening logic goes here
        # call bind
        return new_net_fd(s, family, sotype, network)

    except e:
        let close_status = close(s)
        if close_status != 0:
            print("Could not close socket")
        raise Error("Could not create socket, got this error: " + e.__str__())


fn set_default_socket_options(s: Int, family: Int, sotype: Int, ipv6only: Bool):
    if family == AF_INET6 and sotype != SOCK_RAW:
        var ipv6bool = 0
        if ipv6only:
            ipv6bool = 1
        _ = external_call["setsockopt", Int, Int, Int, Int](
            s, IPPROTO_IPV6, IPV6_V6ONLY, ipv6bool
        )
    # TODO: handle errors
    if sotype == SOCK_DGRAM or sotype == SOCK_RAW and family != AF_UNIX:
        _ = external_call["setsockopt", Int, Int, Int, Int](
            s, SOL_SOCKET, SO_BROADCAST, 1
        )


fn sys_socket(family: Int, sotype: Int, proto: Int) raises -> Int:
    let type: Int
    if sotype:
        type = sotype
    else:
        type = SOCK_NONBLOCK
    let s = external_call["socket", Int, Int, Int, Int](family, type, proto)
    if s == -1 or s == EPROTONOSUPPORT or s == EINVAL:
        raise Error(
            "Could not create socket, got this output from syscall: " + String(s)
        )
    return s


fn new_net_fd(
    fd: FileDescriptor, family: Int, sotype: Int, network: String
) raises -> NetFileDescriptor:
    let is_sock_stream = sotype == SOCK_STREAM
    let zero_read_is_eof = sotype != SOCK_DGRAM and sotype != SOCK_RAW
    let pfd = PollFileDescriptor(fd, is_sock_stream, zero_read_is_eof)
    return NetFileDescriptor(pfd, family, sotype, network)


struct SockAddrOutput:
    var ptr: AnyPointer[RawInet4SockAddr]
    var len: __sock_len
    var c_err: Int

    fn __init__(
        inout self, ptr: AnyPointer[RawInet4SockAddr], len: __sock_len, c_err: Int
    ) raises:
        self.ptr = ptr
        self.len = len
        self.c_err = c_err


trait SockAddr:
    fn __init__(inout self, addr: String, port: Int):
        ...

    fn sock_addr(self) raises -> SockAddrOutput:
        ...


@value
struct RawInet4SockAddr(Movable):
    var family: UInt16
    var port: UInt16
    var addr: InlinedFixedVector[UInt8, 4]
    var zero: UInt8

    fn __moveinit__(inout self, owned existing: RawInet4SockAddr):
        self.family = existing.family
        self.port = existing.port
        self.addr = existing.addr
        self.zero = existing.zero

    fn __init__(inout self):
        self.family = AF_INET
        self.port = 0
        self.addr = InlinedFixedVector[UInt8, 4](0)
        self.zero = 0

    fn __init__(inout self, addr: String, port: Int):
        self.family = AF_INET
        self.port = port
        self.addr = InlinedFixedVector[UInt8, 4](0)
        self.zero = 0


struct Inet4SockAddr(SockAddr):
    var port: Int
    var addr: Bytes
    var raw: RawInet4SockAddr

    fn __init__(inout self, addr: String, port: Int):
        self.port = port
        self.addr = addr._buffer
        self.raw = RawInet4SockAddr(addr, port)

    fn sock_addr(self) raises -> SockAddrOutput:
        if self.port < 0 or self.port > 65535:
            return SockAddrOutput(AnyPointer[RawInet4SockAddr](), __sock_len(0), EINVAL)

        let casted_ptr = AnyPointer[RawInet4SockAddr]()
        casted_ptr.emplace_value(self.raw)

        return SockAddrOutput(casted_ptr, __sock_len(16), 0)
        # return SockAddrOutput(AnyPointer[RawInet4SockAddr](self.raw), __sock_len(16), 0)
        # return SockAddrOutput(ptr, len)


@value
struct PollFileDescriptor:
    var fd: FileDescriptor
    var is_stream: Bool
    var zero_read_is_eof: Bool

    fn __init__(
        inout self, fd: FileDescriptor, is_stream: Bool, zero_read_is_eof: Bool
    ) raises:
        self.fd = fd
        self.is_stream = is_stream
        self.zero_read_is_eof = zero_read_is_eof


struct RawConn:
    var fd: AnyPointer[NetFileDescriptor]

    fn __init__(inout self):
        self.fd = AnyPointer[NetFileDescriptor]()


struct NetFileDescriptor(Movable):
    var pfd: PollFileDescriptor
    var family: Int
    var sotype: Int
    var is_connected: Bool
    var network: String
    var raddr: TCPAddr
    var laddr: TCPAddr

    fn __moveinit__(inout self, owned existing: NetFileDescriptor):
        self.pfd = existing.pfd
        self.family = existing.family
        self.sotype = existing.sotype
        self.is_connected = existing.is_connected
        self.network = existing.network
        self.raddr = existing.raddr
        self.laddr = existing.laddr

    fn __init__(
        inout self, pfd: PollFileDescriptor, family: Int, sotype: Int, network: String
    ) raises:
        self.pfd = pfd
        self.family = family
        self.sotype = sotype
        self.is_connected = False
        self.network = network
        self.raddr = TCPAddr("", 0)
        self.laddr = TCPAddr("", 0)

    fn connect(self, la: SockAddrOutput, ra: SockAddrOutput) raises -> SockAddrOutput:
        # TODO: implement connect logic
        return SockAddrOutput(AnyPointer[RawInet4SockAddr](), __sock_len(0), EINVAL)

    fn dial[T: SockAddr](inout self, laddr: T, raddr: T) raises:
        let c = RawConn()
        let lsa: SockAddrOutput
        let rsa: SockAddrOutput
        let crsa: SockAddrOutput
        try:
            lsa = laddr.sock_addr()
            _ = external_call["bind", Int, Int, AnyPointer[RawInet4SockAddr]](
                self.pfd.fd.fd, lsa.ptr
            )
        except e:
            raise Error("Could not get local socket address, got error: " + e.__str__())
        try:
            rsa = raddr.sock_addr()
            crsa = self.connect(lsa, rsa)
            self.is_connected = True
        except e:
            raise Error(
                "Could not get remote socket address and connect, got error: "
                + e.__str__()
            )
        # lsa, _ = syscall.Getsockname(fd.pfd.Sysfd)
        # if crsa != nil {
        #     fd.setAddr(fd.addrFunc()(lsa), fd.addrFunc()(crsa))
        # } else if rsa, _ = syscall.Getpeername(fd.pfd.Sysfd); rsa != nil {
        #     fd.setAddr(fd.addrFunc()(lsa), fd.addrFunc()(rsa))
        # } else {
        #     fd.setAddr(fd.addrFunc()(lsa), raddr)
        # }
        # return nil


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

        print("inet_pton: " + raw_ip.__str__() + " :: status: " + conv_status.__str__())

        let bin_port = htons(UInt16(addr.port))
        print("htons: " + "\n" + bin_port.__str__())

        var ai = sockaddr_in(address_family, bin_port, raw_ip, StaticTuple[8, c_char]())
        let ai_ptr = Pointer[sockaddr_in].address_of(ai).bitcast[sockaddr]()

        let sockfd = socket(address_family, SOCK_STREAM, 0)
        if sockfd == -1:
            print("Socket creation error")
        print("sockfd: " + "\n" + sockfd.__str__())

        var yes: Int = 1
        if (
            setsockopt(
                sockfd,
                SOL_SOCKET,
                SO_REUSEADDR,
                Pointer[Int].address_of(yes).bitcast[c_void](),
                sizeof[Int](),
            )
            == -1
        ):
            print("set socket options failed")

        if bind(sockfd, ai_ptr, sizeof[sockaddr_in]()) == -1:
            # close(sockfd)
            _ = shutdown(sockfd, SHUT_RDWR)
            print("Binding socket failed")

        if listen(sockfd, c_int(128)) == -1:
            print("Listen failed.\n on sockfd " + sockfd.__str__())

        let listener = SysListener(addr, sockfd)

        print(
            "Listening on "
            + addr.ip
            + ":"
            + addr.port.__str__()
            + " on sockfd "
            + sockfd.__str__()
            + "Waiting for connections..."
        )

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
        # TODO: make this compliant with read signature
        let buf_size = 1024
        var buf_ptr = Pointer[UInt8]().alloc(buf_size)
        let bytes_recv = recv(self.fd, buf_ptr, buf_size, 0)
        return bytes_recv

    fn write(self, buf: Bytes) raises -> Int:
        let msg = String(buf)
        if send(self.fd, to_char_ptr(msg).bitcast[c_void](), len(msg), 0) == -1:
            print("Failed to send response")
        return len(buf)

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
