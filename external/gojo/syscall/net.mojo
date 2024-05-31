from .types import c_char, c_int, c_ushort, c_uint, c_void, c_size_t, c_ssize_t, strlen
from .file import O_CLOEXEC, O_NONBLOCK
from utils.static_tuple import StaticTuple

alias IPPROTO_IPV6 = 41
alias IPV6_V6ONLY = 26
alias EPROTONOSUPPORT = 93

# Adapted from https://github.com/gabrieldemarmiesse/mojo-stdlib-extensions/ . Huge thanks to Gabriel!

alias FD_STDIN: c_int = 0
alias FD_STDOUT: c_int = 1
alias FD_STDERR: c_int = 2

alias SUCCESS = 0
alias GRND_NONBLOCK: UInt8 = 1

alias char_pointer = UnsafePointer[c_char]


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
    var ptr = Pointer[c_char]().alloc(len(s))
    for i in range(len(s)):
        ptr.store(i, ord(s[i]))
    return ptr


fn c_charptr_to_string(s: Pointer[c_char]) -> String:
    return String(s.bitcast[UInt8](), strlen(s))


fn cftob(val: c_int) -> Bool:
    """Convert C-like failure (-1) to Bool."""
    return rebind[Bool](val > 0)


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

# Protocol family constants
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
alias AI_V4MAPPED = 2048
alias AI_ALL = 256
alias AI_ADDRCONFIG = 1024
alias AI_IDN = 64

alias INET_ADDRSTRLEN = 16
alias INET6_ADDRSTRLEN = 46

alias SHUT_RD = 0
alias SHUT_WR = 1
alias SHUT_RDWR = 2

alias SOL_SOCKET = 65535

# Socket Options
alias SO_DEBUG = 1
alias SO_REUSEADDR = 4
alias SO_TYPE = 4104
alias SO_ERROR = 4103
alias SO_DONTROUTE = 16
alias SO_BROADCAST = 32
alias SO_SNDBUF = 4097
alias SO_RCVBUF = 4098
alias SO_KEEPALIVE = 8
alias SO_OOBINLINE = 256
alias SO_LINGER = 128
alias SO_REUSEPORT = 512
alias SO_RCVLOWAT = 4100
alias SO_SNDLOWAT = 4099
alias SO_RCVTIMEO = 4102
alias SO_SNDTIMEO = 4101
alias SO_RCVTIMEO_OLD = 4102
alias SO_SNDTIMEO_OLD = 4101
alias SO_ACCEPTCONN = 2

# unsure of these socket options, they weren't available via python
alias SO_NO_CHECK = 11
alias SO_PRIORITY = 12
alias SO_BSDCOMPAT = 14
alias SO_PASSCRED = 16
alias SO_PEERCRED = 17
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
    var s6_addr: StaticTuple[c_char, 16]


@value
@register_passable("trivial")
struct sockaddr:
    var sa_family: sa_family_t
    var sa_data: StaticTuple[c_char, 14]


@value
@register_passable("trivial")
struct sockaddr_in:
    var sin_family: sa_family_t
    var sin_port: in_port_t
    var sin_addr: in_addr
    var sin_zero: StaticTuple[c_char, 8]


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
    """Struct field ordering can vary based on platform.
    For MacOS, I had to swap the order of ai_canonname and ai_addr.
    https://stackoverflow.com/questions/53575101/calling-getaddrinfo-directly-from-python-ai-addr-is-null-pointer.
    """

    var ai_flags: c_int
    var ai_family: c_int
    var ai_socktype: c_int
    var ai_protocol: c_int
    var ai_addrlen: socklen_t
    var ai_canonname: Pointer[c_char]
    var ai_addr: Pointer[sockaddr]
    var ai_next: Pointer[addrinfo]

    fn __init__() -> Self:
        return Self(0, 0, 0, 0, 0, Pointer[c_char](), Pointer[sockaddr](), Pointer[addrinfo]())


@value
@register_passable("trivial")
struct addrinfo_unix:
    """Struct field ordering can vary based on platform.
    For MacOS, I had to swap the order of ai_canonname and ai_addr.
    https://stackoverflow.com/questions/53575101/calling-getaddrinfo-directly-from-python-ai-addr-is-null-pointer.
    """

    var ai_flags: c_int
    var ai_family: c_int
    var ai_socktype: c_int
    var ai_protocol: c_int
    var ai_addrlen: socklen_t
    var ai_addr: Pointer[sockaddr]
    var ai_canonname: Pointer[c_char]
    var ai_next: Pointer[addrinfo]

    fn __init__() -> Self:
        return Self(0, 0, 0, 0, 0, Pointer[sockaddr](), Pointer[c_char](), Pointer[addrinfo]())


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


fn inet_ntop(af: c_int, src: Pointer[c_void], dst: Pointer[c_char], size: socklen_t) -> Pointer[c_char]:
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
    return external_call["socket", c_int, c_int, c_int, c_int](domain, type, protocol)  # FnName, RetType  # Args


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

    Args:
        socket: A File Descriptor.
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


fn getsockopt(
    socket: c_int,
    level: c_int,
    option_name: c_int,
    option_value: Pointer[c_void],
    option_len: Pointer[socklen_t],
) -> c_int:
    """Libc POSIX `getsockopt` function
    Reference: https://man7.org/linux/man-pages/man3/getsockopt.3p.html
    Fn signature: int getsockopt(int socket, int level, int option_name, void *restrict option_value, socklen_t *restrict option_len).

    Args: socket: A File Descriptor.
        level: The protocol level.
        option_name: The option to get.
        option_value: A pointer to the value to get.
        option_len: Pointer to the size of the value.
    Returns: 0 on success, -1 on error.
    """
    return external_call[
        "getsockopt",
        c_int,  # FnName, RetType
        c_int,
        c_int,
        c_int,
        Pointer[c_void],
        Pointer[socklen_t],  # Args
    ](socket, level, option_name, option_value, option_len)


fn getsockname(socket: c_int, address: Pointer[sockaddr], address_len: Pointer[socklen_t]) -> c_int:
    """Libc POSIX `getsockname` function
    Reference: https://man7.org/linux/man-pages/man3/getsockname.3p.html
    Fn signature: int getsockname(int socket, struct sockaddr *restrict address, socklen_t *restrict address_len).

    Args: socket: A File Descriptor.
        address: A pointer to a buffer to store the address of the peer.
        address_len: A pointer to the size of the buffer.
    Returns: 0 on success, -1 on error.
    """
    return external_call[
        "getsockname",
        c_int,  # FnName, RetType
        c_int,
        Pointer[sockaddr],
        Pointer[socklen_t],  # Args
    ](socket, address, address_len)


fn getpeername(sockfd: c_int, addr: Pointer[sockaddr], address_len: Pointer[socklen_t]) -> c_int:
    """Libc POSIX `getpeername` function
    Reference: https://man7.org/linux/man-pages/man2/getpeername.2.html
    Fn signature:   int getpeername(int socket, struct sockaddr *restrict addr, socklen_t *restrict address_len).

    Args: sockfd: A File Descriptor.
        addr: A pointer to a buffer to store the address of the peer.
        address_len: A pointer to the size of the buffer.
    Returns: 0 on success, -1 on error.
    """
    return external_call[
        "getpeername",
        c_int,  # FnName, RetType
        c_int,
        Pointer[sockaddr],
        Pointer[socklen_t],  # Args
    ](sockfd, addr, address_len)


fn bind(socket: c_int, address: Pointer[sockaddr], address_len: socklen_t) -> c_int:
    """Libc POSIX `bind` function
    Reference: https://man7.org/linux/man-pages/man3/bind.3p.html
    Fn signature: int bind(int socket, const struct sockaddr *address, socklen_t address_len).
    """
    return external_call["bind", c_int, c_int, Pointer[sockaddr], socklen_t](  # FnName, RetType  # Args
        socket, address, address_len
    )


fn listen(socket: c_int, backlog: c_int) -> c_int:
    """Libc POSIX `listen` function
    Reference: https://man7.org/linux/man-pages/man3/listen.3p.html
    Fn signature: int listen(int socket, int backlog).

    Args: socket: A File Descriptor.
        backlog: The maximum length of the queue of pending connections.
    Returns: 0 on success, -1 on error.
    """
    return external_call["listen", c_int, c_int, c_int](socket, backlog)


fn accept(socket: c_int, address: Pointer[sockaddr], address_len: Pointer[socklen_t]) -> c_int:
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
    return external_call["connect", c_int, c_int, Pointer[sockaddr], socklen_t](  # FnName, RetType  # Args
        socket, address, address_len
    )


fn recv(socket: c_int, buffer: Pointer[c_void], length: c_size_t, flags: c_int) -> c_ssize_t:
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


fn send(socket: c_int, buffer: Pointer[c_void], length: c_size_t, flags: c_int) -> c_ssize_t:
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


fn shutdown(socket: c_int, how: c_int) -> c_int:
    """Libc POSIX `shutdown` function
    Reference: https://man7.org/linux/man-pages/man3/shutdown.3p.html
    Fn signature: int shutdown(int socket, int how).

    Args: socket: A File Descriptor.
        how: How to shutdown the socket.
    Returns: 0 on success, -1 on error.
    """
    return external_call["shutdown", c_int, c_int, c_int](socket, how)  # FnName, RetType  # Args


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


fn getaddrinfo_unix(
    nodename: Pointer[c_char],
    servname: Pointer[c_char],
    hints: Pointer[addrinfo_unix],
    res: Pointer[Pointer[addrinfo_unix]],
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
        Pointer[addrinfo_unix],  # Args
        Pointer[Pointer[addrinfo_unix]],  # Args
    ](nodename, servname, hints, res)


fn gai_strerror(ecode: c_int) -> Pointer[c_char]:
    """Libc POSIX `gai_strerror` function
    Reference: https://man7.org/linux/man-pages/man3/gai_strerror.3p.html
    Fn signature: const char *gai_strerror(int ecode).

    Args: ecode: The error code.
    Returns: A pointer to a string describing the error.
    """
    return external_call["gai_strerror", Pointer[c_char], c_int](ecode)  # FnName, RetType  # Args


fn inet_pton(address_family: Int, address: String) -> Int:
    var ip_buf_size = 4
    if address_family == AF_INET6:
        ip_buf_size = 16

    var ip_buf = Pointer[c_void].alloc(ip_buf_size)
    var conv_status = inet_pton(rebind[c_int](address_family), to_char_ptr(address), ip_buf)
    return int(ip_buf.bitcast[c_uint]().load())
