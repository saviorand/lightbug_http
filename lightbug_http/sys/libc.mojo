from benchmark import time_function

alias IPPROTO_IPV6 = 41
alias IPV6_V6ONLY = 26
alias EPROTONOSUPPORT = 93

# Adapted from https://github.com/gabrieldemarmiesse/mojo-stdlib-extensions/ . Huge thanks to Gabriel!

alias FD_STDIN: c_int = 0
alias FD_STDOUT: c_int = 1
alias FD_STDERR: c_int = 2

alias SUCCESS = 0
alias GRND_NONBLOCK: UInt8 = 1

alias char_pointer = AnyPointer[c_char]


@value
struct Str:
    var vector: DynamicVector[c_char]

    fn __init__(inout self, string: String):
        self.vector = DynamicVector[c_char](capacity=len(string) + 1)
        for i in range(len(string)):
            self.vector.push_back(ord(string[i]))
        self.vector.push_back(0)

    fn __init__(inout self, size: Int):
        self.vector = DynamicVector[c_char]()
        self.vector.resize(size + 1, 0)

    fn __len__(self) -> Int:
        for i in range(len(self.vector)):
            if self.vector[i] == 0:
                return i
        return -1

    fn to_string(self, size: Int) -> String:
        var result: String = ""
        for i in range(size):
            result += chr(self.vector[i].to_int())
        return result

    fn __enter__(owned self: Self) -> Self:
        return self ^


# Adapted from https://github.com/crisadamo/mojo-Libc . Huge thanks to Cristian!
# C types
alias c_void = UInt8
alias c_char = UInt8
alias c_schar = Int8
alias c_uchar = UInt8
alias c_short = Int16
alias c_ushort = UInt16
alias c_int = Int32
alias c_uint = UInt32
alias c_long = Int64
alias c_ulong = UInt64
alias c_float = Float32
alias c_double = Float64

# `Int` is known to be machine's width
alias c_size_t = Int
alias c_ssize_t = Int

alias ptrdiff_t = Int64
alias intptr_t = Int64
alias uintptr_t = UInt64


# --- ( error.h Constants )-----------------------------------------------------
alias EPERM = 1
alias ENOENT = 2
alias ESRCH = 3
alias EINTR = 4
alias EIO = 5
alias ENXIO = 6
alias E2BIG = 7
alias ENOEXEC = 8
alias EBADF = 9
alias ECHILD = 10
alias EAGAIN = 11
alias ENOMEM = 12
alias EACCES = 13
alias EFAULT = 14
alias ENOTBLK = 15
alias EBUSY = 16
alias EEXIST = 17
alias EXDEV = 18
alias ENODEV = 19
alias ENOTDIR = 20
alias EISDIR = 21
alias EINVAL = 22
alias ENFILE = 23
alias EMFILE = 24
alias ENOTTY = 25
alias ETXTBSY = 26
alias EFBIG = 27
alias ENOSPC = 28
alias ESPIPE = 29
alias EROFS = 30
alias EMLINK = 31
alias EPIPE = 32
alias EDOM = 33
alias ERANGE = 34
alias EWOULDBLOCK = EAGAIN


fn to_char_ptr(s: String) -> Pointer[c_char]:
    """Only ASCII-based strings."""
    let ptr = Pointer[c_char]().alloc(len(s))
    for i in range(len(s)):
        ptr.store(i, ord(s[i]))
    return ptr


fn c_charptr_to_string(s: Pointer[c_char]) -> String:
    return String(s.bitcast[Int8](), strlen(s))


fn cftob(val: c_int) -> Bool:
    """Convert C-like failure (-1) to Bool."""
    return rebind[Bool](val > 0)


# @always_inline("nodebug")
# fn external_call6[
#     callee: StringLiteral,
#     type: AnyType,
#     T0: AnyType,
#     T1: AnyType,
#     T2: AnyType,
#     T3: AnyType,
#     T4: AnyType,
#     T5: AnyType,
# ](arg0: T0, arg1: T1, arg2: T2, arg3: T3, arg4: T4, arg5: T5) -> type:
#     """Call an external function.

#     Parameters
#       callee: The name of the external function.
#       type: The return type.
#       T0: The first argument type.
#       T1: The second argument type.
#       T2: The third argument type.
#       T3: The fourth argument type.
#       T4: The fifth argument type.
#       T5: The fifth argument type.

#     Args:
#       arg0: The first argument.
#       arg1: The second argument.
#       arg2: The third argument.
#       arg3: The fourth argument.
#       arg4: The fifth argument.
#       arg5: The fifth argument.

#     Returns:
#       The external call result.
#     """

#     @parameter
#     if _mlirtype_is_eq[type, NoneType]():
#         __mlir_op.`pop.external_call`[func : callee.value, _type:None](
#             arg0, arg1, arg2, arg3, arg4, arg5
#         )
#         return rebind[type](None)
#     else:
#         return __mlir_op.`pop.external_call`[func : callee.value, _type:type](
#             arg0, arg1, arg2, arg3, arg4, arg5
#         )


# --- ( Network Related Constants )---------------------------------------------
alias sa_family_t = c_ushort
alias socklen_t = c_uint
alias in_addr_t = c_uint
alias in_port_t = c_ushort

# Address Family Constants
alias AF_UNSPEC = 0
alias AF_UNIX = 1
alias AF_LOCAL = AF_UNIX
alias AF_INET = 2
alias AF_AX25 = 3
alias AF_IPX = 4
alias AF_APPLETALK = 5
alias AF_NETROM = 6
alias AF_BRIDGE = 7
alias AF_ATMPVC = 8
alias AF_X25 = 9
alias AF_INET6 = 10
alias AF_ROSE = 11
alias AF_DECnet = 12
alias AF_NETBEUI = 13
alias AF_SECURITY = 14
alias AF_KEY = 15
alias AF_NETLINK = 16
alias AF_ROUTE = AF_NETLINK
alias AF_PACKET = 17
alias AF_ASH = 18
alias AF_ECONET = 19
alias AF_ATMSVC = 20
alias AF_RDS = 21
alias AF_SNA = 22
alias AF_IRDA = 23
alias AF_PPPOX = 24
alias AF_WANPIPE = 25
alias AF_LLC = 26
alias AF_CAN = 29
alias AF_TIPC = 30
alias AF_BLUETOOTH = 31
alias AF_IUCV = 32
alias AF_RXRPC = 33
alias AF_ISDN = 34
alias AF_PHONET = 35
alias AF_IEEE802154 = 36
alias AF_CAIF = 37
alias AF_ALG = 38
alias AF_NFC = 39
alias AF_VSOCK = 40
alias AF_KCM = 41
alias AF_QIPCRTR = 42
alias AF_MAX = 43

alias PF_UNSPEC = AF_UNSPEC
alias PF_UNIX = AF_UNIX
alias PF_LOCAL = AF_LOCAL
alias PF_INET = AF_INET
alias PF_AX25 = AF_AX25
alias PF_IPX = AF_IPX
alias PF_APPLETALK = AF_APPLETALK
alias PF_NETROM = AF_NETROM
alias PF_BRIDGE = AF_BRIDGE
alias PF_ATMPVC = AF_ATMPVC
alias PF_X25 = AF_X25
alias PF_INET6 = AF_INET6
alias PF_ROSE = AF_ROSE
alias PF_DECnet = AF_DECnet
alias PF_NETBEUI = AF_NETBEUI
alias PF_SECURITY = AF_SECURITY
alias PF_KEY = AF_KEY
alias PF_NETLINK = AF_NETLINK
alias PF_ROUTE = AF_ROUTE
alias PF_PACKET = AF_PACKET
alias PF_ASH = AF_ASH
alias PF_ECONET = AF_ECONET
alias PF_ATMSVC = AF_ATMSVC
alias PF_RDS = AF_RDS
alias PF_SNA = AF_SNA
alias PF_IRDA = AF_IRDA
alias PF_PPPOX = AF_PPPOX
alias PF_WANPIPE = AF_WANPIPE
alias PF_LLC = AF_LLC
alias PF_CAN = AF_CAN
alias PF_TIPC = AF_TIPC
alias PF_BLUETOOTH = AF_BLUETOOTH
alias PF_IUCV = AF_IUCV
alias PF_RXRPC = AF_RXRPC
alias PF_ISDN = AF_ISDN
alias PF_PHONET = AF_PHONET
alias PF_IEEE802154 = AF_IEEE802154
alias PF_CAIF = AF_CAIF
alias PF_ALG = AF_ALG
alias PF_NFC = AF_NFC
alias PF_VSOCK = AF_VSOCK
alias PF_KCM = AF_KCM
alias PF_QIPCRTR = AF_QIPCRTR
alias PF_MAX = AF_MAX

# Socket Type constants
alias SOCK_STREAM = 1
alias SOCK_DGRAM = 2
alias SOCK_RAW = 3
alias SOCK_RDM = 4
alias SOCK_SEQPACKET = 5
alias SOCK_DCCP = 6
alias SOCK_PACKET = 10
alias SOCK_CLOEXEC = O_CLOEXEC
alias SOCK_NONBLOCK = O_NONBLOCK

# Address Information
alias AI_PASSIVE = 1
alias AI_CANONNAME = 2
alias AI_NUMERICHOST = 4
alias AI_V4MAPPED = 8
alias AI_ALL = 16
alias AI_ADDRCONFIG = 32
alias AI_IDN = 64

alias INET_ADDRSTRLEN = 16
alias INET6_ADDRSTRLEN = 46

alias SHUT_RD = 0
alias SHUT_WR = 1
alias SHUT_RDWR = 2

alias SOL_SOCKET = 1

alias SO_DEBUG = 1
alias SO_REUSEADDR = 2
alias SO_TYPE = 3
alias SO_ERROR = 4
alias SO_DONTROUTE = 5
alias SO_BROADCAST = 6
alias SO_SNDBUF = 7
alias SO_RCVBUF = 8
alias SO_KEEPALIVE = 9
alias SO_OOBINLINE = 10
alias SO_NO_CHECK = 11
alias SO_PRIORITY = 12
alias SO_LINGER = 13
alias SO_BSDCOMPAT = 14
alias SO_REUSEPORT = 15
alias SO_PASSCRED = 16
alias SO_PEERCRED = 17
alias SO_RCVLOWAT = 18
alias SO_SNDLOWAT = 19
alias SO_RCVTIMEO = 20
alias SO_SNDTIMEO = 21
alias SO_RCVTIMEO_OLD = 20
alias SO_SNDTIMEO_OLD = 21
alias SO_SECURITY_AUTHENTICATION = 22
alias SO_SECURITY_ENCRYPTION_TRANSPORT = 23
alias SO_SECURITY_ENCRYPTION_NETWORK = 24
alias SO_BINDTODEVICE = 25
alias SO_ATTACH_FILTER = 26
alias SO_DETACH_FILTER = 27
alias SO_GET_FILTER = SO_ATTACH_FILTER
alias SO_PEERNAME = 28
alias SO_TIMESTAMP = 29
alias SO_TIMESTAMP_OLD = 29
alias SO_ACCEPTCONN = 30
alias SO_PEERSEC = 31
alias SO_SNDBUFFORCE = 32
alias SO_RCVBUFFORCE = 33
alias SO_PASSSEC = 34
alias SO_TIMESTAMPNS = 35
alias SO_TIMESTAMPNS_OLD = 35
alias SO_MARK = 36
alias SO_TIMESTAMPING = 37
alias SO_TIMESTAMPING_OLD = 37
alias SO_PROTOCOL = 38
alias SO_DOMAIN = 39
alias SO_RXQ_OVFL = 40
alias SO_WIFI_STATUS = 41
alias SCM_WIFI_STATUS = SO_WIFI_STATUS
alias SO_PEEK_OFF = 42
alias SO_NOFCS = 43
alias SO_LOCK_FILTER = 44
alias SO_SELECT_ERR_QUEUE = 45
alias SO_BUSY_POLL = 46
alias SO_MAX_PACING_RATE = 47
alias SO_BPF_EXTENSIONS = 48
alias SO_INCOMING_CPU = 49
alias SO_ATTACH_BPF = 50
alias SO_DETACH_BPF = SO_DETACH_FILTER
alias SO_ATTACH_REUSEPORT_CBPF = 51
alias SO_ATTACH_REUSEPORT_EBPF = 52
alias SO_CNX_ADVICE = 53
alias SCM_TIMESTAMPING_OPT_STATS = 54
alias SO_MEMINFO = 55
alias SO_INCOMING_NAPI_ID = 56
alias SO_COOKIE = 57
alias SCM_TIMESTAMPING_PKTINFO = 58
alias SO_PEERGROUPS = 59
alias SO_ZEROCOPY = 60
alias SO_TXTIME = 61
alias SCM_TXTIME = SO_TXTIME
alias SO_BINDTOIFINDEX = 62
alias SO_TIMESTAMP_NEW = 63
alias SO_TIMESTAMPNS_NEW = 64
alias SO_TIMESTAMPING_NEW = 65
alias SO_RCVTIMEO_NEW = 66
alias SO_SNDTIMEO_NEW = 67
alias SO_DETACH_REUSEPORT_BPF = 68


# --- ( Network Related Structs )-----------------------------------------------
@value
@register_passable("trivial")
struct in_addr:
    var s_addr: in_addr_t


@value
@register_passable("trivial")
struct in6_addr:
    var s6_addr: StaticTuple[16, c_char]


@value
@register_passable("trivial")
struct sockaddr:
    var sa_family: sa_family_t
    var sa_data: StaticTuple[14, c_char]


@value
@register_passable("trivial")
struct sockaddr_in:
    var sin_family: sa_family_t
    var sin_port: in_port_t
    var sin_addr: in_addr
    var sin_zero: StaticTuple[8, c_char]


@value
@register_passable("trivial")
struct sockaddr_in6:
    var sin6_family: sa_family_t
    var sin6_port: in_port_t
    var sin6_flowinfo: c_uint
    var sin6_addr: in6_addr
    var sin6_scope_id: c_uint


@value
@register_passable("trivial")
struct addrinfo:
    var ai_flags: c_int
    var ai_family: c_int
    var ai_socktype: c_int
    var ai_protocol: c_int
    var ai_addrlen: socklen_t
    var ai_addr: Pointer[sockaddr]
    var ai_canonname: Pointer[c_char]
    # FIXME(cristian): This should be Pointer[addrinfo]
    var ai_next: Pointer[c_void]

    fn __init__() -> Self:
        return Self(
            0, 0, 0, 0, 0, Pointer[sockaddr](), Pointer[c_char](), Pointer[c_void]()
        )


fn strlen(s: Pointer[c_char]) -> c_size_t:
    """Libc POSIX `strlen` function
    Reference: https://man7.org/linux/man-pages/man3/strlen.3p.html
    Fn signature: size_t strlen(const char *s).

    Args: s: A pointer to a C string.
    Returns: The length of the string.
    """
    return external_call["strlen", c_size_t, Pointer[c_char]](s)


# --- ( Network Related Syscalls & Structs )------------------------------------


fn htonl(hostlong: c_uint) -> c_uint:
    """Libc POSIX `htonl` function
    Reference: https://man7.org/linux/man-pages/man3/htonl.3p.html
    Fn signature: uint32_t htonl(uint32_t hostlong).

    Args: hostlong: A 32-bit integer in host byte order.
    Returns: The value provided in network byte order.
    """
    return external_call["htonl", c_uint, c_uint](hostlong)


fn htons(hostshort: c_ushort) -> c_ushort:
    """Libc POSIX `htons` function
    Reference: https://man7.org/linux/man-pages/man3/htonl.3p.html
    Fn signature: uint16_t htons(uint16_t hostshort).

    Args: hostshort: A 16-bit integer in host byte order.
    Returns: The value provided in network byte order.
    """
    return external_call["htons", c_ushort, c_ushort](hostshort)


fn ntohl(netlong: c_uint) -> c_uint:
    """Libc POSIX `ntohl` function
    Reference: https://man7.org/linux/man-pages/man3/htonl.3p.html
    Fn signature: uint32_t ntohl(uint32_t netlong).

    Args: netlong: A 32-bit integer in network byte order.
    Returns: The value provided in host byte order.
    """
    return external_call["ntohl", c_uint, c_uint](netlong)


fn ntohs(netshort: c_ushort) -> c_ushort:
    """Libc POSIX `ntohs` function
    Reference: https://man7.org/linux/man-pages/man3/htonl.3p.html
    Fn signature: uint16_t ntohs(uint16_t netshort).

    Args: netshort: A 16-bit integer in network byte order.
    Returns: The value provided in host byte order.
    """
    return external_call["ntohs", c_ushort, c_ushort](netshort)


fn inet_ntop(
    af: c_int, src: Pointer[c_void], dst: Pointer[c_char], size: socklen_t
) -> Pointer[c_char]:
    """Libc POSIX `inet_ntop` function
    Reference: https://man7.org/linux/man-pages/man3/inet_ntop.3p.html.
    Fn signature: const char *inet_ntop(int af, const void *restrict src, char *restrict dst, socklen_t size).

    Args:
        af: Address Family see AF_ aliases.
        src: A pointer to a binary address.
        dst: A pointer to a buffer to store the result.
        size: The size of the buffer.

    Returns:
        A pointer to the buffer containing the result.
    """
    return external_call[
        "inet_ntop",
        Pointer[c_char],  # FnName, RetType
        c_int,
        Pointer[c_void],
        Pointer[c_char],
        socklen_t,  # Args
    ](af, src, dst, size)


fn inet_pton(af: c_int, src: Pointer[c_char], dst: Pointer[c_void]) -> c_int:
    """Libc POSIX `inet_pton` function
    Reference: https://man7.org/linux/man-pages/man3/inet_ntop.3p.html
    Fn signature: int inet_pton(int af, const char *restrict src, void *restrict dst).

    Args: af: Address Family see AF_ aliases.
        src: A pointer to a string containing the address.
        dst: A pointer to a buffer to store the result.
    Returns: 1 on success, 0 if the input is not a valid address, -1 on error.
    """
    return external_call[
        "inet_pton",
        c_int,  # FnName, RetType
        c_int,
        Pointer[c_char],
        Pointer[c_void],  # Args
    ](af, src, dst)


fn inet_addr(cp: Pointer[c_char]) -> in_addr_t:
    """Libc POSIX `inet_addr` function
    Reference: https://man7.org/linux/man-pages/man3/inet_addr.3p.html
    Fn signature: in_addr_t inet_addr(const char *cp).

    Args: cp: A pointer to a string containing the address.
    Returns: The address in network byte order.
    """
    return external_call["inet_addr", in_addr_t, Pointer[c_char]](cp)


fn inet_ntoa(addr: in_addr) -> Pointer[c_char]:
    """Libc POSIX `inet_ntoa` function
    Reference: https://man7.org/linux/man-pages/man3/inet_addr.3p.html
    Fn signature: char *inet_ntoa(struct in_addr in).

    Args: in: A pointer to a string containing the address.
    Returns: The address in network byte order.
    """
    return external_call["inet_ntoa", Pointer[c_char], in_addr](addr)


fn socket(domain: c_int, type: c_int, protocol: c_int) -> c_int:
    """Libc POSIX `socket` function
    Reference: https://man7.org/linux/man-pages/man3/socket.3p.html
    Fn signature: int socket(int domain, int type, int protocol).

    Args: domain: Address Family see AF_ aliases.
        type: Socket Type see SOCK_ aliases.
        protocol: The protocol to use.
    Returns: A File Descriptor or -1 in case of failure.
    """
    return external_call[
        "socket", c_int, c_int, c_int, c_int  # FnName, RetType  # Args
    ](domain, type, protocol)


fn setsockopt(
    socket: c_int,
    level: c_int,
    option_name: c_int,
    option_value: Pointer[c_void],
    option_len: socklen_t,
) -> c_int:
    """Libc POSIX `setsockopt` function
    Reference: https://man7.org/linux/man-pages/man3/setsockopt.3p.html
    Fn signature: int setsockopt(int socket, int level, int option_name, const void *option_value, socklen_t option_len).

    Args: socket: A File Descriptor.
        level: The protocol level.
        option_name: The option to set.
        option_value: A pointer to the value to set.
        option_len: The size of the value.
    Returns: 0 on success, -1 on error.
    """
    return external_call[
        "setsockopt",
        c_int,  # FnName, RetType
        c_int,
        c_int,
        c_int,
        Pointer[c_void],
        socklen_t,  # Args
    ](socket, level, option_name, option_value, option_len)


fn bind(socket: c_int, address: Pointer[sockaddr], address_len: socklen_t) -> c_int:
    """Libc POSIX `bind` function
    Reference: https://man7.org/linux/man-pages/man3/bind.3p.html
    Fn signature: int bind(int socket, const struct sockaddr *address, socklen_t address_len).
    """
    return external_call[
        "bind", c_int, c_int, Pointer[sockaddr], socklen_t  # FnName, RetType  # Args
    ](socket, address, address_len)


fn listen(socket: c_int, backlog: c_int) -> c_int:
    """Libc POSIX `listen` function
    Reference: https://man7.org/linux/man-pages/man3/listen.3p.html
    Fn signature: int listen(int socket, int backlog).

    Args: socket: A File Descriptor.
        backlog: The maximum length of the queue of pending connections.
    Returns: 0 on success, -1 on error.
    """
    return external_call["listen", c_int, c_int, c_int](socket, backlog)


fn accept(
    socket: c_int, address: Pointer[sockaddr], address_len: Pointer[socklen_t]
) -> c_int:
    """Libc POSIX `accept` function
    Reference: https://man7.org/linux/man-pages/man3/accept.3p.html
    Fn signature: int accept(int socket, struct sockaddr *restrict address, socklen_t *restrict address_len).

    Args: socket: A File Descriptor.
        address: A pointer to a buffer to store the address of the peer.
        address_len: A pointer to the size of the buffer.
    Returns: A File Descriptor or -1 in case of failure.
    """
    return external_call[
        "accept",
        c_int,  # FnName, RetType
        c_int,
        Pointer[sockaddr],
        Pointer[socklen_t],  # Args
    ](socket, address, address_len)


fn connect(socket: c_int, address: Pointer[sockaddr], address_len: socklen_t) -> c_int:
    """Libc POSIX `connect` function
    Reference: https://man7.org/linux/man-pages/man3/connect.3p.html
    Fn signature: int connect(int socket, const struct sockaddr *address, socklen_t address_len).

    Args: socket: A File Descriptor.
        address: A pointer to the address to connect to.
        address_len: The size of the address.
    Returns: 0 on success, -1 on error.
    """
    return external_call[
        "connect", c_int, c_int, Pointer[sockaddr], socklen_t  # FnName, RetType  # Args
    ](socket, address, address_len)


fn recv(
    socket: c_int, buffer: Pointer[c_void], length: c_size_t, flags: c_int
) -> c_ssize_t:
    """Libc POSIX `recv` function
    Reference: https://man7.org/linux/man-pages/man3/recv.3p.html
    Fn signature: ssize_t recv(int socket, void *buffer, size_t length, int flags).
    """
    return external_call[
        "recv",
        c_ssize_t,  # FnName, RetType
        c_int,
        Pointer[c_void],
        c_size_t,
        c_int,  # Args
    ](socket, buffer, length, flags)


# fn recvfrom(
#     socket: c_int,
#     buffer: Pointer[c_void],
#     length: c_size_t,
#     flags: c_int,
#     address: Pointer[sockaddr],
#     address_len: Pointer[socklen_t],
# ) -> c_ssize_t:
#     """Libc POSIX `recvfrom` function
#     Reference: https://man7.org/linux/man-pages/man3/recvfrom.3p.html
#     Fn signature: ssize_t recvfrom(int socket, void *restrict buffer, size_t length, int flags, struct sockaddr *restrict address, socklen_t *restrict address_len).
#     """
#     return external_call6[
#         "recvfrom",
#         c_ssize_t,  # FnName, RetType
#         c_int,
#         Pointer[c_void],
#         c_size_t,
#         c_int,
#         Pointer[sockaddr],  # Args
#         Pointer[socklen_t],  # Args
#     ](socket, buffer, length, flags, address, address_len)


fn send(
    socket: c_int, buffer: Pointer[c_void], length: c_size_t, flags: c_int
) -> c_ssize_t:
    """Libc POSIX `send` function
    Reference: https://man7.org/linux/man-pages/man3/send.3p.html
    Fn signature: ssize_t send(int socket, const void *buffer, size_t length, int flags).

    Args: socket: A File Descriptor.
        buffer: A pointer to the buffer to send.
        length: The size of the buffer.
        flags: Flags to control the behaviour of the function.
    Returns: The number of bytes sent or -1 in case of failure.
    """
    return external_call[
        "send",
        c_ssize_t,  # FnName, RetType
        c_int,
        Pointer[c_void],
        c_size_t,
        c_int,  # Args
    ](socket, buffer, length, flags)


# fn sendto(
#     socket: c_int,
#     message: Pointer[c_void],
#     length: c_size_t,
#     flags: c_int,
#     dest_addr: Pointer[sockaddr],
#     dest_len: socklen_t,
# ) -> c_ssize_t:
#     """Libc POSIX `sendto` function
#     Reference: https://man7.org/linux/man-pages/man3/sendto.3p.html
#     Fn signature: ssize_t sendto(int socket, const void *message, size_t length, int flags, const struct sockaddr *dest_addr, socklen_t dest_len)

#     Args:
#     Returns:
#     """
#     return external_call6[
#         "sendto",
#         c_ssize_t,  # FnName, RetType
#         c_int,
#         Pointer[c_void],
#         c_size_t,
#         c_int,
#         Pointer[sockaddr],
#         socklen_t,  # Args
#     ](socket, message, length, flags, dest_addr, dest_len)


fn shutdown(socket: c_int, how: c_int) -> c_int:
    """Libc POSIX `shutdown` function
    Reference: https://man7.org/linux/man-pages/man3/shutdown.3p.html
    Fn signature: int shutdown(int socket, int how).

    Args: socket: A File Descriptor.
        how: How to shutdown the socket.
    Returns: 0 on success, -1 on error.
    """
    return external_call["shutdown", c_int, c_int, c_int](  # FnName, RetType  # Args
        socket, how
    )


fn getaddrinfo(
    nodename: Pointer[c_char],
    servname: Pointer[c_char],
    hints: Pointer[addrinfo],
    res: Pointer[Pointer[addrinfo]],
) -> c_int:
    """Libc POSIX `getaddrinfo` function
    Reference: https://man7.org/linux/man-pages/man3/getaddrinfo.3p.html
    Fn signature: int getaddrinfo(const char *restrict nodename, const char *restrict servname, const struct addrinfo *restrict hints, struct addrinfo **restrict res).
    """
    return external_call[
        "getaddrinfo",
        c_int,  # FnName, RetType
        Pointer[c_char],
        Pointer[c_char],
        Pointer[addrinfo],  # Args
        Pointer[Pointer[addrinfo]],  # Args
    ](nodename, servname, hints, res)


fn gai_strerror(ecode: c_int) -> Pointer[c_char]:
    """Libc POSIX `gai_strerror` function
    Reference: https://man7.org/linux/man-pages/man3/gai_strerror.3p.html
    Fn signature: const char *gai_strerror(int ecode).

    Args: ecode: The error code.
    Returns: A pointer to a string describing the error.
    """
    return external_call[
        "gai_strerror", Pointer[c_char], c_int  # FnName, RetType  # Args
    ](ecode)


# fn get_addr(ptr: Pointer[sockaddr]) -> sockaddr:
#     if ptr.load().sa_family == AF_INET:
#         ptr.bitcast[sockaddr_in]().load().sin_addr
#     return ptr.bitcast[sockaddr_in6]().load().sin6_addr


fn inet_pton(address_family: Int, address: String) -> Int:
    var ip_buf_size = 4
    if address_family == AF_INET6:
        ip_buf_size = 16

    let ip_buf = Pointer[c_void].alloc(ip_buf_size)
    let conv_status = inet_pton(
        rebind[c_int](address_family), to_char_ptr(address), ip_buf
    )
    return ip_buf.bitcast[c_uint]().load().to_int()


# --- ( File Related Syscalls & Structs )---------------------------------------
# alias off_t = Int64
# alias mode_t = UInt32

# alias FM_READ = "r"
# alias FM_WRITE = "w"
# alias FM_APPEND = "a"
# alias FM_BINARY = "b"
# alias FM_PLUS = "+"

# alias SEEK_SET = 0
# alias SEEK_CUR = 1
# alias SEEK_END = 2

# alias O_RDONLY = 0
# alias O_WRONLY = 1
# alias O_RDWR = 2
# alias O_APPEND = 8
# alias O_CREAT = 512
# alias O_TRUNC = 1024
# alias O_EXCL = 2048
# alias O_SYNC = 8192
alias O_NONBLOCK = 16384
alias O_ACCMODE = 3
alias O_CLOEXEC = 524288

# # from fcntl.h
# alias O_EXEC = -1
# alias O_SEARCH = -1
# alias O_DIRECTORY = -1
# alias O_DSYNC = -1
# alias O_NOCTTY = -1
# alias O_NOFOLLOW = -1
# alias O_RSYNC = -1
# alias O_TTY_INIT = -1

# alias STDIN_FILENO = 0
# alias STDOUT_FILENO = 1
# alias STDERR_FILENO = 2

# alias F_DUPFD = 0
# alias F_GETFD = 1
# alias F_SETFD = 2
# alias F_GETFL = 3
# alias F_SETFL = 4
# alias F_GETOWN = 5
# alias F_SETOWN = 6
# alias F_GETLK = 7
# alias F_SETLK = 8
# alias F_SETLKW = 9
# alias F_RGETLK = 10
# alias F_RSETLK = 11
# alias F_CNVT = 12
# alias F_RSETLKW = 13
# alias F_DUPFD_CLOEXEC = 14

# # TODO(cristian)
# alias FD_CLOEXEC = -1
# alias F_RDLCK = -1
# alias F_UNLCK = -1
# alias F_WRLCK = -1

# alias AT_EACCESS = 512
# alias AT_FDCWD = -100
# alias AT_SYMLINK_NOFOLLOW = 256
# alias AT_REMOVEDIR = 512
# alias AT_SYMLINK_FOLLOW = 1024
# alias AT_NO_AUTOMOUNT = 2048
# alias AT_EMPTY_PATH = 4096
# alias AT_RECURSIVE = 32768


# @register_passable("trivial")
# struct FILE:
#     pass


# fn fcntl[*T: AnyType](fildes: c_int, cmd: c_int, *args: *T) -> c_int:
#     """Libc POSIX `fcntl` function
#     Reference: https://man7.org/linux/man-pages/man3/close.3p.html
#     Fn signature: int fcntl(int fildes, int cmd, ...)

#     Args:
#     Returns:
#     """
#     return external_call["fcntl", c_int, c_int, c_int](  # FnName, RetType  # Args
#         fildes, cmd, args
#     )


fn close(fildes: c_int) -> c_int:
    """Libc POSIX `close` function
    Reference: https://man7.org/linux/man-pages/man3/close.3p.html
    Fn signature: int close(int fildes).

    Args:
        fildes: A File Descriptor to close.

    Returns:
        Upon successful completion, 0 shall be returned; otherwise, -1
        shall be returned and errno set to indicate the error.
    """
    return external_call["close", c_int, c_int](fildes)


fn open[*T: AnyType](path: Pointer[c_char], oflag: c_int, *args: *T) -> c_int:
    """Libc POSIX `open` function
    Reference: https://man7.org/linux/man-pages/man3/open.3p.html
    Fn signature: int open(const char *path, int oflag, ...).

    Args:
        path: A pointer to a C string containing the path to open.
        oflag: The flags to open the file with.
        args: The optional arguments.
    Returns:
        A File Descriptor or -1 in case of failure
    """
    return external_call[
        "open", c_int, Pointer[c_char], c_int  # FnName, RetType  # Args
    ](path, oflag, args)


fn openat[
    *T: AnyType
](fd: c_int, path: Pointer[c_char], oflag: c_int, *args: *T) -> c_int:
    """Libc POSIX `open` function
    Reference: https://man7.org/linux/man-pages/man3/open.3p.html
    Fn signature: int openat(int fd, const char *path, int oflag, ...).

    Args:
        fd: A File Descriptor.
        path: A pointer to a C string containing the path to open.
        oflag: The flags to open the file with.
        args: The optional arguments.
    Returns:
        A File Descriptor or -1 in case of failure
    """
    return external_call[
        "openat", c_int, c_int, Pointer[c_char], c_int  # FnName, RetType  # Args
    ](fd, path, oflag, args)


# fn fopen(pathname: Pointer[c_char], mode: Pointer[c_char]) -> Pointer[FILE]:
#     """Libc POSIX `fopen` function
#     Reference: https://man7.org/linux/man-pages/man3/fopen.3p.html
#     Fn signature: FILE *fopen(const char *restrict pathname, const char *restrict mode)

#     Args:
#     Returns:
#     """
#     return external_call[
#         "fopen",
#         Pointer[FILE],  # FnName, RetType
#         Pointer[c_char],
#         Pointer[c_char],  # Args
#     ](pathname, mode)


# fn fdopen(fildes: c_int, mode: Pointer[c_char]) -> Pointer[FILE]:
#     """Libc POSIX `fdopen` function
#     Reference: https://man7.org/linux/man-pages/man3/fdopen.3p.html
#     Fn signature: FILE *fdopen(int fildes, const char *mode)

#     Args:
#     Returns:
#     """
#     return external_call[
#         "fdopen", Pointer[FILE], c_int, Pointer[c_char]  # FnName, RetType  # Args
#     ](fildes, mode)


# fn freopen(
#     pathname: Pointer[c_char], mode: Pointer[c_char], stream: Pointer[FILE]
# ) -> Pointer[FILE]:
#     """Libc POSIX `freopen` function
#     Reference: https://man7.org/linux/man-pages/man3/freopen.3p.html
#     Fn signature: FILE *freopen(const char *restrict pathname, const char *restrict mode, FILE *restrict stream)

#     Args:
#     Returns:
#     """
#     return external_call[
#         "freopen",
#         Pointer[FILE],  # FnName, RetType
#         Pointer[c_char],
#         Pointer[c_char],
#         Pointer[FILE],  # Args
#     ](pathname, mode, stream)


# fn fmemopen(
#     buf: Pointer[c_void], size: c_size_t, mode: Pointer[c_char]
# ) -> Pointer[FILE]:
#     """Libc POSIX `fmemopen` function
#     Reference: https://man7.org/linux/man-pages/man3/fmemopen.3p.html
#     Fn signature: FILE *fmemopen(void *restrict buf, size_t size, const char *restrict mode)

#     Args:
#     Returns:
#     """
#     return external_call[
#         "fmemopen",
#         Pointer[FILE],  # FnName, RetType
#         Pointer[c_void],
#         c_size_t,
#         Pointer[c_char],  # Args
#     ](buf, size, mode)


# fn creat(path: Pointer[c_char], mode: mode_t) -> c_int:
#     """Libc POSIX `creat` function
#     Reference: https://man7.org/linux/man-pages/man3/creat.3p.html
#     Fn signature: int creat(const char *path, mode_t mode)

#     Args:
#     Returns:
#     """
#     return external_call[
#         "creat", c_int, Pointer[c_char], mode_t  # FnName, RetType  # Args
#     ](path, mode)


# fn fseek(stream: Pointer[FILE], offset: c_long, whence: c_int) -> c_int:
#     """Libc POSIX `fseek` function
#     Reference: https://man7.org/linux/man-pages/man3/fseek.3p.html
#     Fn signature: int fseek(FILE *stream, long offset, int whence)

#     Args:
#     Returns:
#     """
#     return external_call[
#         "fseek", c_int, Pointer[FILE], c_long, c_int  # FnName, RetType  # Args
#     ](stream, offset, whence)


# fn fseeko(stream: Pointer[FILE], offset: off_t, whence: c_int) -> c_int:
#     """Libc POSIX `fseeko` function
#     Reference: https://man7.org/linux/man-pages/man3/fseek.3p.html
#     Fn signature: int fseeko(FILE *stream, off_t offset, int whence)

#     Args:
#     Returns:
#     """
#     return external_call[
#         "fseeko", c_int, Pointer[FILE], off_t, c_int  # FnName, RetType  # Args
#     ](stream, offset, whence)


# fn lseek(fildes: c_int, offset: off_t, whence: c_int) -> off_t:
#     """Libc POSIX `lseek` function
#     Reference: https://man7.org/linux/man-pages/man3/lseek.3p.html
#     Fn signature: off_t lseek(int fildes, off_t offset, int whence)

#     Args:
#     Returns:
#     """
#     return external_call[
#         "lseek", off_t, c_int, off_t, c_int  # FnName, RetType  # Args
#     ](fildes, offset, whence)


# fn fputc(c: c_int, stream: Pointer[FILE]) -> c_int:
#     """Libc POSIX `fputc` function
#     Reference: https://man7.org/linux/man-pages/man3/fputc.3p.html
#     Fn signature: int fputc(int c, FILE *stream)

#     Args:
#     Returns:
#     """
#     return external_call[
#         "fputc", c_int, c_int, Pointer[FILE]  # FnName, RetType  # Args
#     ](c, stream)


# fn fputs(s: Pointer[c_char], stream: Pointer[FILE]) -> c_int:
#     """Libc POSIX `fputs` function
#     Reference: https://man7.org/linux/man-pages/man3/fputs.3p.html
#     Fn signature: int fputs(const char *restrict s, FILE *restrict stream)

#     Args:
#     Returns:
#     """
#     return external_call[
#         "fputs", c_int, Pointer[c_char], Pointer[FILE]  # FnName, RetType  # Args
#     ](s, stream)


# fn fgetc(stream: Pointer[FILE]) -> c_int:
#     """Libc POSIX `fgetc` function
#     Reference: https://man7.org/linux/man-pages/man3/fgetc.3p.html
#     Fn signature: int fgetc(FILE *stream)

#     Args:
#     Returns:
#     """
#     return external_call["fgets", c_int, Pointer[FILE]](  # FnName, RetType  # Args
#         stream
#     )


# fn fgets(s: Pointer[c_char], n: c_int, stream: Pointer[FILE]) -> Pointer[c_char]:
#     """Libc POSIX `fgets` function
#     Reference: https://man7.org/linux/man-pages/man3/fgets.3p.html
#     Fn signature: char *fgets(char *restrict s, int n, FILE *restrict stream)

#     Args:
#     Returns:
#     """
#     return external_call[
#         "fgets",
#         Pointer[c_char],  # FnName, RetType
#         Pointer[c_char],
#         c_int,
#         Pointer[FILE],  # Args
#     ](s, n, stream)


# fn dprintf[*T: AnyType](fildes: c_int, format: Pointer[c_char], *args: *T) -> c_int:
#     """Libc POSIX `dprintf` function
#     Reference: https://man7.org/linux/man-pages/man3/fprintf.3p.html
#     Fn signature: int dprintf(int fildes, const char *restrict format, ...)

#     Args:
#     Returns:
#     """
#     return external_call[
#         "dprintf", c_int, c_int, Pointer[c_char]  # FnName, RetType  # Args
#     ](fildes, format, args)


# fn fprintf[
#     *T: AnyType
# ](stream: Pointer[FILE], format: Pointer[c_char], *args: *T) -> c_int:
#     """Libc POSIX `fprintf` function
#     Reference: https://man7.org/linux/man-pages/man3/fprintf.3p.html
#     Fn signature: int fprintf(FILE *restrict stream, const char *restrict format, ...)

#     Args:
#     Returns:
#     """
#     return external_call[
#         "fprintf", c_int, Pointer[FILE], Pointer[c_char]  # FnName, RetType  # Args
#     ](stream, format, args)


fn printf[*T: AnyType](format: Pointer[c_char], *args: *T) -> c_int:
    """Libc POSIX `printf` function
    Reference: https://man7.org/linux/man-pages/man3/fprintf.3p.html
    Fn signature: int printf(const char *restrict format, ...).

    Args: format: A pointer to a C string containing the format.
        args: The optional arguments.
    Returns: The number of bytes written or -1 in case of failure.
    """
    return external_call[
        "printf",
        c_int,  # FnName, RetType
        Pointer[c_char],  # Args
    ](format, args)


# fn snprintf[
#     *T: AnyType
# ](s: Pointer[c_char], n: c_size_t, format: Pointer[c_char], *args: *T) -> c_int:
#     """Libc POSIX `snprintf` function
#     Reference: https://man7.org/linux/man-pages/man3/fprintf.3p.html
#     Fn signature: int snprintf(char *restrict s, size_t n, const char *restrict format, ...)

#     Args:
#     Returns:
#     """
#     return external_call[
#         "snprintf",
#         c_int,  # FnName, RetType
#         Pointer[c_char],
#         c_size_t,
#         Pointer[c_char],  # Args
#     ](s, n, format, args)


fn sprintf[
    *T: AnyType
](s: Pointer[c_char], format: Pointer[c_char], *args: *T) -> c_int:
    """Libc POSIX `sprintf` function
    Reference: https://man7.org/linux/man-pages/man3/fprintf.3p.html
    Fn signature: int sprintf(char *restrict s, const char *restrict format, ...).

    Args: s: A pointer to a buffer to store the result.
        format: A pointer to a C string containing the format.
        args: The optional arguments.
    Returns: The number of bytes written or -1 in case of failure.
    """
    return external_call[
        "sprintf", c_int, Pointer[c_char], Pointer[c_char]  # FnName, RetType  # Args
    ](s, format, args)


# fn fscanf[
#     *T: AnyType
# ](stream: Pointer[FILE], format: Pointer[c_char], *args: *T) -> c_int:
#     """Libc POSIX `fscanf` function
#     Reference: https://man7.org/linux/man-pages/man3/fscanf.3p.html
#     Fn signature: int fscanf(FILE *restrict stream, const char *restrict format, ...)

#     Args:
#     Returns:
#     """
#     return external_call[
#         "fscanf", c_int, Pointer[FILE], Pointer[c_char]  # FnName, RetType  # Args
#     ](stream, format, args)


# fn scanf[*T: AnyType](format: Pointer[c_char], *args: *T) -> c_int:
#     """Libc POSIX `scanf` function
#     Reference: https://man7.org/linux/man-pages/man3/fscanf.3p.html
#     Fn signature: int scanf(const char *restrict format, ...)

#     Args:
#     Returns:
#     """
#     return external_call["scanf", c_int, Pointer[c_char]](  # FnName, RetType  # Args
#         format, args
#     )


# fn sscanf[*T: AnyType](s: Pointer[c_char], format: Pointer[c_char], *args: *T) -> c_int:
#     """Libc POSIX `sscanf` function
#     Reference: https://man7.org/linux/man-pages/man3/fscanf.3p.html
#     Fn signature: int sscanf(const char *restrict s, const char *restrict format, ...)

#     Args:
#     Returns:
#     """
#     return external_call[
#         "sscanf", c_int, Pointer[c_char], Pointer[c_char]  # FnName, RetType  # Args
#     ](s, format, args)


# fn fread(
#     ptr: Pointer[c_void], size: c_size_t, nitems: c_size_t, stream: Pointer[FILE]
# ) -> c_int:
#     """Libc POSIX `fread` function
#     Reference: https://man7.org/linux/man-pages/man3/fread.3p.html
#     Fn signature: size_t fread(void *restrict ptr, size_t size, size_t nitems, FILE *restrict stream)

#     Args:
#     Returns:
#     """
#     return external_call[
#         "fread",
#         c_size_t,  # FnName, RetType
#         Pointer[c_void],
#         c_size_t,
#         c_size_t,
#         Pointer[FILE],  # Args
#     ](ptr, size, nitems, stream)


# fn rewind(stream: Pointer[FILE]) -> c_void:
#     """Libc POSIX `rewind` function
#     Reference: https://man7.org/linux/man-pages/man3/rewind.3p.html
#     Fn signature: void rewind(FILE *stream)

#     Args:
#     Returns:
#     """
#     return external_call["rewind", c_void, Pointer[FILE]](stream)


# fn getline(
#     lineptr: Pointer[Pointer[FILE]], n: Pointer[c_size_t], stream: Pointer[FILE]
# ) -> c_ssize_t:
#     """Libc POSIX `getline` function
#     Reference: https://man7.org/linux/man-pages/man3/getline.3p.html
#     Fn signature: ssize_t getline(char **restrict lineptr, size_t *restrict n, FILE *restrict stream);


#     Args:
#     Returns:
#     """
#     return external_call[
#         "getline",
#         c_ssize_t,  # FnName, RetType
#         Pointer[Pointer[FILE]],
#         Pointer[c_size_t],
#         Pointer[FILE],  # Args
#     ](lineptr, n, stream)


# fn pread(fildes: c_int, buf: Pointer[c_void], nbyte: c_size_t, offset: off_t) -> c_int:
#     """Libc POSIX `pread` function
#     Reference: https://man7.org/linux/man-pages/man3/read.3p.html
#     Fn signature: ssize_t pread(int fildes, void *buf, size_t nbyte, off_t offset)

#     Args:
#     Returns:
#     """
#     return external_call["pread", c_ssize_t, c_int, Pointer[c_void], c_size_t, off_t](
#         fildes, buf, nbyte, offset
#     )


fn read(fildes: c_int, buf: Pointer[c_void], nbyte: c_size_t) -> c_int:
    """Libc POSIX `read` function
    Reference: https://man7.org/linux/man-pages/man3/read.3p.html
    Fn signature: sssize_t read(int fildes, void *buf, size_t nbyte).

    Args: fildes: A File Descriptor.
        buf: A pointer to a buffer to store the read data.
        nbyte: The number of bytes to read.
    Returns: The number of bytes read or -1 in case of failure.
    """
    return external_call["read", c_ssize_t, c_int, Pointer[c_void], c_size_t](
        fildes, buf, nbyte
    )


# fn pwrite(fildes: c_int, buf: Pointer[c_void], nbyte: c_size_t, offset: off_t) -> c_int:
#     """Libc POSIX `pwrite` function
#     Reference: https://man7.org/linux/man-pages/man3/write.3p.html
#     Fn signature: ssize_t pwrite(int fildes, const void *buf, size_t nbyte, off_t offset)

#     Args:
#     Returns:
#     """
#     return external_call["pwrite", c_ssize_t, c_int, Pointer[c_void], c_size_t, off_t](
#         fildes, buf, nbyte, offset
#     )


fn write(fildes: c_int, buf: Pointer[c_void], nbyte: c_size_t) -> c_int:
    """Libc POSIX `write` function
    Reference: https://man7.org/linux/man-pages/man3/write.3p.html
    Fn signature: ssize_t write(int fildes, const void *buf, size_t nbyte).

    Args: fildes: A File Descriptor.
        buf: A pointer to a buffer to write.
        nbyte: The number of bytes to write.
    Returns: The number of bytes written or -1 in case of failure.
    """
    return external_call["write", c_ssize_t, c_int, Pointer[c_void], c_size_t](
        fildes, buf, nbyte
    )


# fn fclose(stream: Pointer[FILE]) -> c_int:
#     """Libc POSIX `fclose` function
#     Reference: https://man7.org/linux/man-pages/man3/fclose.3p.html
#     Fn signature: int fclose(FILE *stream)

#     Args:
#         stream:
#     Returns:
#     """
#     return external_call["fclose", c_int, Pointer[FILE]](stream)


# fn ftell(stream: Pointer[FILE]) -> c_long:
#     """Libc POSIX `ftell` function
#     Reference: https://man7.org/linux/man-pages/man3/ftell.3p.html
#     Fn signature: long ftell(FILE *stream)

#     Args:
#     Returns:
#     """
#     return external_call["ftell", c_long, Pointer[FILE]](stream)


# fn ftello(stream: Pointer[FILE]) -> off_t:
#     """Libc POSIX `ftello` function
#     Reference: https://man7.org/linux/man-pages/man3/ftell.3p.html
#     Fn signature: off_t ftello(FILE *stream)

#     Args:
#     Returns:
#     """
#     return external_call["ftello", off_t, Pointer[FILE]](stream)


# fn fflush(stream: Pointer[FILE]) -> c_int:
#     """Libc POSIX `fflush` function
#     Reference: https://man7.org/linux/man-pages/man3/fflush.3p.html
#     Fn signature: int fflush(FILE *stream)

#     Args:
#         stream

#     Returns:
#     """
#     return external_call["fflush", c_int, Pointer[FILE]](stream)


# fn clearerr(stream: Pointer[FILE]) -> c_void:
#     """Libc POSIX `feof` function
#     Reference: https://man7.org/linux/man-pages/man3/clearerr.3p.html
#     Fn signature: void clearerr(FILE *stream)

#     Args:
#     Returns:
#     """
#     return external_call["clearerr", c_void, Pointer[FILE]](stream)


# fn feof(stream: Pointer[FILE]) -> c_int:
#     """Libc POSIX `feof` function
#     Reference: https://man7.org/linux/man-pages/man3/feof.3p.html
#     Fn signature: int feof(FILE *stream)

#     Args:
#     Returns:
#     """
#     return external_call["feof", c_int, Pointer[FILE]](stream)


# fn ferror(stream: Pointer[FILE]) -> c_int:
#     """Libc POSIX `ferror` function
#     Reference: https://man7.org/linux/man-pages/man3/ferror.3p.html
#     Fn signature: int ferror(FILE *stream)

#     Args:
#     Returns:
#     """
#     return external_call["ferror", c_int, Pointer[FILE]](stream)


# fn ioctl[*T: AnyType](fildes: c_int, request: c_int, *args: *T) -> c_int:
#     """Libc POSIX `ioctl` function
#     Reference: https://man7.org/linux/man-pages/man3/ioctl.3p.html
#     Fn signature: int ioctl(int fildes, int request, ... /* arg */)

#     TODO(cristian): add ioctl Options
#     Args:
#     Returns:
#     """
#     return external_call["ioctl", c_int, c_int, c_int](  # FnName, RetType  # Args
#         fildes, request, args
#     )


# --- ( Logging Syscalls ) -----------------------------------------------------
# alias LOG_PID = -1
# alias LOG_CONS = -1
# alias LOG_NDELAY = -1
# alias LOG_ODELAY = -1
# alias LOG_NOWAIT = -1
# alias LOG_KERN = -1
# alias LOG_USER = -1
# alias LOG_MAIL = -1
# alias LOG_NEWS = -1
# alias LOG_UUCP = -1
# alias LOG_DAEMON = -1
# alias LOG_AUTH = -1
# alias LOG_CRON = -1
# alias LOG_LPR = -1
# alias LOG_LOCAL0 = -1
# alias LOG_LOCAL1 = -1
# alias LOG_LOCAL2 = -1
# alias LOG_LOCAL3 = -1
# alias LOG_LOCAL4 = -1
# alias LOG_LOCAL5 = -1
# alias LOG_LOCAL6 = -1
# alias LOG_LOCAL7 = -1
# alias LOG_MASK = -1  # (pri)
# alias LOG_EMERG = -1
# alias LOG_ALERT = -1
# alias LOG_CRIT = -1
# alias LOG_ERR = -1
# alias LOG_WARNING = -1
# alias LOG_NOTICE = -1
# alias LOG_INFO = -1
# alias LOG_DEBUG = -1


# fn openlog(ident: Pointer[c_char], logopt: c_int, facility: c_int) -> c_void:
#     """Libc POSIX `openlog` function
#     Reference: https://man7.org/linux/man-pages/man3/closelog.3p.html
#     Fn signature: void openlog(const char *ident, int logopt, int facility)

#     Args:
#     Returns:
#     """
#     return external_call[
#         "openlog", c_void, Pointer[c_char], c_int, c_int  # FnName, RetType  # Args
#     ](ident, logopt, facility)


# fn syslog[*T: AnyType](priority: c_int, message: Pointer[c_char], *args: *T) -> c_void:
#     """Libc POSIX `syslog` function
#     Reference: https://man7.org/linux/man-pages/man3/closelog.3p.html
#     Fn signature: void syslog(int priority, const char *message, ... /* arguments */)

#     Args:
#     Returns:
#     """
#     return external_call[
#         "syslog", c_void, c_int, Pointer[c_char]  # FnName, RetType  # Args
#     ](priority, message, args)


# fn setlogmask(maskpri: c_int) -> c_int:
#     """Libc POSIX `setlogmask` function
#     Reference: https://man7.org/linux/man-pages/man3/closelog.3p.html
#     Fn signature:  int setlogmask(int maskpri)

#     Args:
#     Returns:
#     """
#     return external_call["setlogmask", c_int, c_int](maskpri)  # FnName, RetType  # Args


# fn closelog():
#     """Libc POSIX `closelog` function
#     Reference: https://man7.org/linux/man-pages/man3/closelog.3p.html
#     Fn signature: void closelog(void)

#     Args:
#     Returns:
#     """
#     _ = external_call["closelog", c_void]()


# --- ( Testing Functions ) ----------------------------------------------------


fn __test_getaddrinfo__():
    let ip_addr = "127.0.0.1"
    let port = 8083

    var servinfo = Pointer[addrinfo]().alloc(1)
    servinfo.store(addrinfo())

    var hints = addrinfo()
    hints.ai_family = AF_INET
    hints.ai_socktype = SOCK_STREAM
    hints.ai_flags = AI_PASSIVE
    # let hints_ptr =

    let status = getaddrinfo(
        to_char_ptr(ip_addr),
        Pointer[UInt8](),
        Pointer.address_of(hints),
        Pointer.address_of(servinfo),
    )
    let msg_ptr = gai_strerror(c_int(status))
    _ = external_call["printf", c_int, Pointer[c_char], Pointer[c_char]](
        to_char_ptr("gai_strerror: %s"), msg_ptr
    )
    let msg = c_charptr_to_string(msg_ptr)
    print("getaddrinfo satus: " + msg)
    # getaddrinfo()


fn __test_socket_client__():
    let ip_addr = "127.0.0.1"  # The server's hostname or IP address
    let port = 8080  # The port used by the server
    let address_family = AF_INET

    let ip_buf = Pointer[c_void].alloc(4)
    let conv_status = inet_pton(address_family, to_char_ptr(ip_addr), ip_buf)
    let raw_ip = ip_buf.bitcast[c_uint]().load()

    print("inet_pton: " + raw_ip.__str__() + " :: status: " + conv_status.__str__())

    let bin_port = htons(UInt16(port))
    print("htons: " + "\n" + bin_port.__str__())

    var ai = sockaddr_in(address_family, bin_port, raw_ip, StaticTuple[8, c_char]())
    let ai_ptr = Pointer[sockaddr_in].address_of(ai).bitcast[sockaddr]()

    let sockfd = socket(address_family, SOCK_STREAM, 0)
    if sockfd == -1:
        print("Socket creation error")
    print("sockfd: " + "\n" + sockfd.__str__())

    if connect(sockfd, ai_ptr, sizeof[sockaddr_in]()) == -1:
        _ = shutdown(sockfd, SHUT_RDWR)

    let msg = to_char_ptr("Hello, world Server")
    let bytes_sent = send(sockfd, msg, strlen(msg), 0)
    if bytes_sent == -1:
        _ = shutdown(sockfd, SHUT_RDWR)
        print("failed to send message\n")

    let buf_size = 1024
    var buf = Pointer[UInt8]().alloc(buf_size)
    let bytes_recv = recv(sockfd, buf, buf_size, 0)
    if bytes_recv == -1:
        _ = shutdown(sockfd, SHUT_RDWR)
        print("failed to receive message\n")
    print("Recived Message: ")
    print(String(buf.bitcast[Int8](), bytes_recv))


fn __test_socket_server__() raises:
    let ip_addr = "127.0.0.1"
    let port = 8083

    let address_family = AF_INET
    var ip_buf_size = 4
    if address_family == AF_INET6:
        ip_buf_size = 16

    let ip_buf = Pointer[c_void].alloc(ip_buf_size)
    let conv_status = inet_pton(address_family, to_char_ptr(ip_addr), ip_buf)
    let raw_ip = ip_buf.bitcast[c_uint]().load()

    print("inet_pton: " + raw_ip.__str__() + " :: status: " + conv_status.__str__())

    let bin_port = htons(UInt16(port))
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

    print(
        "server: started at "
        + ip_addr
        + ":"
        + port.__str__()
        + " on sockfd "
        + sockfd.__str__()
        + "Waiting for connections..."
    )

    let their_addr_ptr = Pointer[sockaddr].alloc(1)
    var sin_size = socklen_t(sizeof[socklen_t]())
    let new_sockfd = accept(
        sockfd, their_addr_ptr, Pointer[socklen_t].address_of(sin_size)
    )
    if new_sockfd == -1:
        print("Accept failed")
        # close(sockfd)
        _ = shutdown(sockfd, SHUT_RDWR)

    # inet_ntop(their_addr.ss_family, get_in_addr((struct sockaddr *)&their_addr), s, sizeof s);
    # printf("server: got connection from %s\n", s);

    let msg = "Hello, Mojo!"
    if send(new_sockfd, to_char_ptr(msg).bitcast[c_void](), len(msg), 0) == -1:
        print("Failed to send response")
    print("Message sent succesfully")
    # let close_status = close(new_sockfd)
    # if close_status == -1:
    # print("Failed to close new_sockfd")
    _ = shutdown(sockfd, SHUT_RDWR)


# fn __test_file__():
#     let fp = fopen(to_char_ptr("test.mojo"), to_char_ptr("r"))

#     let buf_size = 1024
#     var buf = Pointer[UInt8]().alloc(buf_size)
#     let status = fread(buf.bitcast[c_void](), buf_size, 1, fp)

#     print(String(buf.bitcast[Int8](), buf_size))

#     _ = fclose(fp)
