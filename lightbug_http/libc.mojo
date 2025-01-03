from utils import StaticTuple
from sys.ffi import external_call
from sys.info import sizeof, os_is_windows, os_is_macos, os_is_linux
from memory import memcpy, UnsafePointer, stack_allocation
from lightbug_http.io.bytes import Bytes

alias IPPROTO_IPV6 = 41
alias IPV6_V6ONLY = 26
alias EPROTONOSUPPORT = 93

# Adapted from https://github.com/gabrieldemarmiesse/mojo-stdlib-extensions/ . Huge thanks to Gabriel!

alias SUCCESS = 0
alias GRND_NONBLOCK: UInt8 = 1

alias char_UnsafePointer = UnsafePointer[c_char]

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
# TODO: These are probably platform specific, we should check the values on each linux and macos.
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
alias EINPROGRESS = 36
alias EALREADY = 37
alias ENOTSOCK = 38
alias EDESTADDRREQ = 39
alias EMSGSIZE = 40
alias ENOPROTOOPT = 42
alias EAFNOSUPPORT = 47
alias EADDRINUSE = 48
alias EADDRNOTAVAIL = 49
alias ENETUNREACH = 51
alias ECONNABORTED = 53
alias ECONNRESET = 54
alias ENOBUFS = 55
alias EISCONN = 56
alias ENOTCONN = 57
alias ETIMEDOUT = 60
alias ECONNREFUSED = 61
alias ELOOP = 62
alias ENAMETOOLONG = 63
alias EDQUOT = 69
alias EPROTO = 100
alias EOPNOTSUPP = 102

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
    var ai_flags: c_int
    var ai_family: c_int
    var ai_socktype: c_int
    var ai_protocol: c_int
    var ai_addrlen: socklen_t
    var ai_addr: UnsafePointer[sockaddr]
    var ai_canonname: UnsafePointer[c_char]
    var ai_next: UnsafePointer[c_void]

    fn __init__(out self):
        self.ai_flags = 0
        self.ai_family = 0
        self.ai_socktype = 0
        self.ai_protocol = 0
        self.ai_addrlen = 0
        self.ai_addr = UnsafePointer[sockaddr]()
        self.ai_canonname = UnsafePointer[c_char]()
        self.ai_next = UnsafePointer[c_void]()


# --- ( Network Related Syscalls & Structs )------------------------------------


fn htonl(hostlong: c_uint) -> c_uint:
    """Libc POSIX `htonl` function.

    Args:
        hostlong: A 32-bit integer in host byte order.

    Returns:
        The value provided in network byte order.

    #### C Function
    ```c
    uint32_t htonl(uint32_t hostlong)
    ```

    #### Notes:
    * Reference: https://man7.org/linux/man-pages/man3/htonl.3p.html.
    """
    return external_call["htonl", c_uint, c_uint](hostlong)


fn htons(hostshort: c_ushort) -> c_ushort:
    """Libc POSIX `htons` function.

    Args:
        hostshort: A 16-bit integer in host byte order.
    
    Returns:
        The value provided in network byte order.
    
    #### C Function
    ```c
    uint16_t htons(uint16_t hostshort)
    ```

    #### Notes:
    * Reference: https://man7.org/linux/man-pages/man3/htonl.3p.html.
    """
    return external_call["htons", c_ushort, c_ushort](hostshort)


fn ntohl(netlong: c_uint) -> c_uint:
    """Libc POSIX `ntohl` function.

    Args:
        netlong: A 32-bit integer in network byte order.

    Returns:
        The value provided in host byte order.
    
    #### C Function
    ```c
    uint32_t ntohl(uint32_t netlong)
    ```
    
    #### Notes:
    * Reference: https://man7.org/linux/man-pages/man3/htonl.3p.html
    """
    return external_call["ntohl", c_uint, c_uint](netlong)


fn ntohs(netshort: c_ushort) -> c_ushort:
    """Libc POSIX `ntohs` function.

    Args:
        netshort: A 16-bit integer in network byte order.

    Returns:
        The value provided in host byte order.
    
    #### C Function
    ```c
    uint16_t ntohs(uint16_t netshort)
    ```
    
    #### Notes:
    * Reference: https://man7.org/linux/man-pages/man3/htonl.3p.html
    """
    return external_call["ntohs", c_ushort, c_ushort](netshort)


fn _inet_ntop(
    af: c_int,
    src: UnsafePointer[c_void],
    dst: UnsafePointer[c_char],
    size: socklen_t,
) raises -> UnsafePointer[c_char]:
    """Libc POSIX `inet_ntop` function.

    Args:
        af: Address Family see AF_ aliases.
        src: A UnsafePointer to a binary address.
        dst: A UnsafePointer to a buffer to store the result.
        size: The size of the buffer.

    Returns:
        A UnsafePointer to the buffer containing the result.
    
    #### C Function
    ```c
    const char *inet_ntop(int af, const void *restrict src, char *restrict dst, socklen_t size)
    ```

    #### Notes:
    * Reference: https://man7.org/linux/man-pages/man3/inet_ntop.3p.html.
    """
    return external_call[
        "inet_ntop",
        UnsafePointer[c_char],  # FnName, RetType
        c_int,
        UnsafePointer[c_void],
        UnsafePointer[c_char],
        socklen_t,  # Args
    ](af, src, dst, size)


fn inet_ntop(
    af: c_int,
    src: UnsafePointer[c_void],
    dst: UnsafePointer[c_char],
    size: socklen_t,
) raises -> String:
    """Libc POSIX `inet_ntop` function.

    Args:
        af: Address Family see AF_ aliases.
        src: A UnsafePointer to a binary address.
        dst: A UnsafePointer to a buffer to store the result.
        size: The size of the buffer.

    Returns:
        A UnsafePointer to the buffer containing the result.
    
    Raises:
        Error: If an error occurs while converting the address.
        EAFNOSUPPORT: `*src` was not an `AF_INET` or `AF_INET6` family address.
        ENOSPC: The buffer size, `size`, was not large enough to store the presentation form of the address.
    
    #### C Function
    ```c
    const char *inet_ntop(int af, const void *restrict src, char *restrict dst, socklen_t size)
    ```

    #### Notes:
    * Reference: https://man7.org/linux/man-pages/man3/inet_ntop.3p.html.
    """
    var result = _inet_ntop(af, src, dst, size)

    # `inet_ntop` returns NULL on error.
    if not result:
        var errno = get_errno()
        if errno == EAFNOSUPPORT:
            raise Error("inet_ntop: `*src` was not an `AF_INET` or `AF_INET6` family address.")
        elif errno == ENOSPC:
            raise Error("inet_ntop: The buffer size, `size`, was not large enough to store the presentation form of the address.")
        else:
            raise Error("inet_ntop: An error occurred while converting the address. Error code: " + str(errno))
    
    # We want the string representation of the address, so it's ok to take ownership of the pointer here.
    return String(ptr=result, length=int(size))


fn _inet_pton(af: c_int, src: UnsafePointer[c_char], dst: UnsafePointer[c_void]) -> c_int:
    """Libc POSIX `inet_pton` function. Converts a presentation format address (that is, printable form as held in a character string)
    to network format (usually a struct in_addr or some other internal binary representation, in network byte order).
    It returns 1 if the address was valid for the specified address family, or 0 if the address was not parseable in the specified address family,
    or -1 if some system error occurred (in which case errno will have been set).

    Args:
        af: Address Family see AF_ aliases.
        src: A UnsafePointer to a string containing the address.
        dst: A UnsafePointer to a buffer to store the result.
    
    Returns:
        1 on success, 0 if the input is not a valid address, -1 on error.
    
    #### C Function
    ```c
    int inet_pton(int af, const char *restrict src, void *restrict dst)
    ```

    #### Notes:
    * Reference: https://man7.org/linux/man-pages/man3/inet_ntop.3p.html
    """
    return external_call[
        "inet_pton",
        c_int,
        c_int,
        UnsafePointer[c_char],
        UnsafePointer[c_void],
    ](af, src, dst)


fn inet_pton(af: c_int, src: UnsafePointer[c_char], dst: UnsafePointer[c_void]) raises:
    """Libc POSIX `inet_pton` function. Converts a presentation format address (that is, printable form as held in a character string)
    to network format (usually a struct in_addr or some other internal binary representation, in network byte order).

    Args:
        af: Address Family see AF_ aliases.
        src: A UnsafePointer to a string containing the address.
        dst: A UnsafePointer to a buffer to store the result.
    
    Raises:
        Error: If an error occurs while converting the address or the input is not a valid address.
        
    #### C Function
    ```c
    int inet_pton(int af, const char *restrict src, void *restrict dst)
    ```

    #### Notes:
    * Reference: https://man7.org/linux/man-pages/man3/inet_ntop.3p.html
    * This function is valid for `AF_INET` and `AF_INET6`.
    """
    var result = _inet_pton(af, src, dst)
    if result == 0:
        raise Error("inet_pton: The input is not a valid address.")
    elif result == -1:
        var errno = get_errno()
        raise Error("inet_pton: An error occurred while converting the address. Error code: " + str(errno))


fn _socket(domain: c_int, type: c_int, protocol: c_int) -> c_int:
    """Libc POSIX `socket` function.

    Args:
        domain: Address Family see AF_ aliases.
        type: Socket Type see SOCK_ aliases.
        protocol: The protocol to use.

    Returns:
        A File Descriptor or -1 in case of failure.

    #### C Function
    ```c
    int socket(int domain, int type, int protocol)
    ```

    #### Notes:
    * Reference: https://man7.org/linux/man-pages/man3/socket.3p.html
    """
    return external_call["socket", c_int, c_int, c_int, c_int](domain, type, protocol)


fn socket(domain: c_int, type: c_int, protocol: c_int) raises -> c_int:
    """Libc POSIX `socket` function.

    Args:
        domain: Address Family see AF_ aliases.
        type: Socket Type see SOCK_ aliases.
        protocol: The protocol to use.

    Returns: 
        A File Descriptor or -1 in case of failure.
    
    Raises:
        SocketError: If an error occurs while creating the socket.
        EACCES: Permission to create a socket of the specified type and/or protocol is denied.
        EAFNOSUPPORT: The implementation does not support the specified address family.
        EINVAL: Invalid flags in type, Unknown protocol, or protocol family not available.
        EMFILE: The per-process limit on the number of open file descriptors has been reached.
        ENFILE: The system-wide limit on the total number of open files has been reached.
        ENOBUFS or ENOMEM: Insufficient memory is available. The socket cannot be created until sufficient resources are freed.
        EPROTONOSUPPORT: The protocol type or the specified protocol is not supported within this domain.

    #### C Function
    ```c
    int socket(int domain, int type, int protocol)
    ```

    #### Notes:
    * Reference: https://man7.org/linux/man-pages/man3/socket.3p.html
    """
    var fd = _socket(domain, type, protocol)
    if fd == -1:
        var errno = get_errno()
        if errno == EACCES:
            raise Error("SocketError (EACCES): Permission to create a socket of the specified type and/or protocol is denied.")
        elif errno == EAFNOSUPPORT:
            raise Error("SocketError (EAFNOSUPPORT): The implementation does not support the specified address family.")
        elif errno == EINVAL:
            raise Error("SocketError (EINVAL): Invalid flags in type, Unknown protocol, or protocol family not available.")
        elif errno == EMFILE:
            raise Error("SocketError (EMFILE): The per-process limit on the number of open file descriptors has been reached.")
        elif errno == ENFILE:
            raise Error("SocketError (ENFILE): The system-wide limit on the total number of open files has been reached.")
        elif int(errno) in [ENOBUFS, ENOMEM]:
            raise Error("SocketError (ENOBUFS or ENOMEM): Insufficient memory is available. The socket cannot be created until sufficient resources are freed.")
        elif errno == EPROTONOSUPPORT:
            raise Error("SocketError (EPROTONOSUPPORT): The protocol type or the specified protocol is not supported within this domain.")
        else:
            raise Error("SocketError: An error occurred while creating the socket. Error code: " + str(errno))

    return fd


fn _setsockopt(
    socket: c_int,
    level: c_int,
    option_name: c_int,
    option_value: UnsafePointer[c_void],
    option_len: socklen_t,
) -> c_int:
    """Libc POSIX `setsockopt` function.

    Args:
        socket: A File Descriptor.
        level: The protocol level.
        option_name: The option to set.
        option_value: A UnsafePointer to the value to set.
        option_len: The size of the value.

    Returns:
        0 on success, -1 on error.

    #### C Function
    ```c
    int setsockopt(int socket, int level, int option_name, const void *option_value, socklen_t option_len)
    ```

    #### Notes:
    * Reference: https://man7.org/linux/man-pages/man3/setsockopt.3p.html
    """
    return external_call[
        "setsockopt",
        c_int,  # FnName, RetType
        c_int,
        c_int,
        c_int,
        UnsafePointer[c_void],
        socklen_t,  # Args
    ](socket, level, option_name, option_value, option_len)


fn setsockopt(
    socket: c_int,
    level: c_int,
    option_name: c_int,
    option_value: UnsafePointer[c_void],
    option_len: socklen_t,
) raises:
    """Libc POSIX `setsockopt` function. Manipulate options for the socket referred to by the file descriptor, `socket`.

    Args:
        socket: A File Descriptor.
        level: The protocol level.
        option_name: The option to set.
        option_value: A UnsafePointer to the value to set.
        option_len: The size of the value.

    Raises:
        Error: If an error occurs while setting the socket option.
        EBADF: The argument `socket` is not a valid descriptor.
        EFAULT: The argument `option_value` points outside the process's allocated address space.
        EINVAL: The argument `option_len` is invalid. Can sometimes occur when `option_value` is invalid.
        ENOPROTOOPT: The option is unknown at the level indicated.
        ENOTSOCK: The argument `socket` is not a socket.

    #### C Function
    ```c
    int setsockopt(int socket, int level, int option_name, const void *option_value, socklen_t option_len)
    ```

    #### Notes:
    * Reference: https://man7.org/linux/man-pages/man3/setsockopt.3p.html
    """
    var result = _setsockopt(socket, level, option_name, option_value, option_len)
    if result == -1:
        var errno = get_errno()
        if errno == EBADF:
            raise Error("setsockopt: The argument `socket` is not a valid descriptor.")
        elif errno == EFAULT:
            raise Error("setsockopt: The argument `option_value` points outside the process's allocated address space.")
        elif errno == EINVAL:
            raise Error("setsockopt: The argument `option_len` is invalid. Can sometimes occur when `option_value` is invalid.")
        elif errno == ENOPROTOOPT:
            raise Error("setsockopt: The option is unknown at the level indicated.")
        elif errno == ENOTSOCK:
            raise Error("setsockopt: The argument `socket` is not a socket.")
        else:
            raise Error("setsockopt: An error occurred while setting the socket option. Error code: " + str(errno))


fn _getsockname(
    socket: c_int,
    address: UnsafePointer[sockaddr],
    address_len: UnsafePointer[socklen_t],
) -> c_int:
    """Libc POSIX `getsockname` function.

    Args:
        socket: A File Descriptor.
        address: A UnsafePointer to a buffer to store the address of the peer.
        address_len: A UnsafePointer to the size of the buffer.
    
    Returns:
        0 on success, -1 on error.

    #### C Function
    ```c
    int getsockname(int socket, struct sockaddr *restrict address, socklen_t *restrict address_len)
    ```

    #### Notes:
    * Reference: https://man7.org/linux/man-pages/man3/getsockname.3p.html
    """
    return external_call[
        "getsockname",
        c_int,  # FnName, RetType
        c_int,
        UnsafePointer[sockaddr],
        UnsafePointer[socklen_t],  # Args
    ](socket, address, address_len)


fn getsockname(
    socket: c_int,
    address: UnsafePointer[sockaddr],
    address_len: UnsafePointer[socklen_t],
) raises:
    """Libc POSIX `getsockname` function.

    Args:
        socket: A File Descriptor.
        address: A UnsafePointer to a buffer to store the address of the peer.
        address_len: A UnsafePointer to the size of the buffer.
    
    Raises:
        Error: If an error occurs while getting the socket name.
        EBADF: The argument `socket` is not a valid descriptor.
        EFAULT: The `address` argument points to memory not in a valid part of the process address space.
        EINVAL: `address_len` is invalid (e.g., is negative).
        ENOBUFS: Insufficient resources were available in the system to perform the operation.
        ENOTSOCK: The argument `socket` is not a socket, it is a file.

    #### C Function
    ```c
    int getsockname(int socket, struct sockaddr *restrict address, socklen_t *restrict address_len)
    ```

    #### Notes:
    * Reference: https://man7.org/linux/man-pages/man3/getsockname.3p.html
    """
    var result = _getsockname(socket, address, address_len)
    if result == -1:
        var errno = get_errno()
        if errno == EBADF:
            raise Error("getsockname: The argument `socket` is not a valid descriptor.")
        elif errno == EFAULT:
            raise Error("getsockname: The `address` argument points to memory not in a valid part of the process address space.")
        elif errno == EINVAL:
            raise Error("getsockname: `address_len` is invalid (e.g., is negative).")
        elif errno == ENOBUFS:
            raise Error("getsockname: Insufficient resources were available in the system to perform the operation.")
        elif errno == ENOTSOCK:
            raise Error("getsockname: The argument `socket` is not a socket, it is a file.")
        else:
            raise Error("getsockname: An error occurred while getting the socket name. Error code: " + str(errno))


fn _getpeername(
    sockfd: c_int,
    addr: UnsafePointer[sockaddr],
    address_len: UnsafePointer[socklen_t],
) -> c_int:
    """Libc POSIX `getpeername` function.

    Args:
        sockfd: A File Descriptor.
        addr: A UnsafePointer to a buffer to store the address of the peer.
        address_len: A UnsafePointer to the size of the buffer.

    Returns:
        0 on success, -1 on error.

    #### C Function
    ```c
    int getpeername(int socket, struct sockaddr *restrict addr, socklen_t *restrict address_len)
    ```

    #### Notes:
    * Reference: https://man7.org/linux/man-pages/man2/getpeername.2.html
    """
    return external_call[
        "getpeername",
        c_int,  # FnName, RetType
        c_int,
        UnsafePointer[sockaddr],
        UnsafePointer[socklen_t],  # Args
    ](sockfd, addr, address_len)


fn getpeername(
    sockfd: c_int,
    addr: UnsafePointer[sockaddr],
    address_len: UnsafePointer[socklen_t],
) raises:
    """Libc POSIX `getpeername` function.

    Args:
        sockfd: A File Descriptor.
        addr: A UnsafePointer to a buffer to store the address of the peer.
        address_len: A UnsafePointer to the size of the buffer.

    Raises:
        Error: If an error occurs while getting the socket name.
        EBADF: The argument `socket` is not a valid descriptor.
        EFAULT: The `addr` argument points to memory not in a valid part of the process address space.
        EINVAL: `address_len` is invalid (e.g., is negative).
        ENOBUFS: Insufficient resources were available in the system to perform the operation.
        ENOTCONN: The socket is not connected.
        ENOTSOCK: The argument `socket` is not a socket, it is a file.

    #### C Function
    ```c
    int getpeername(int socket, struct sockaddr *restrict addr, socklen_t *restrict address_len)
    ```

    #### Notes:
    * Reference: https://man7.org/linux/man-pages/man2/getpeername.2.html
    """
    var result = _getpeername(sockfd, addr, address_len)
    if result == -1:
        var errno = get_errno()
        if errno == EBADF:
            raise Error("getpeername: The argument `socket` is not a valid descriptor.")
        elif errno == EFAULT:
            raise Error("getpeername: The `addr` argument points to memory not in a valid part of the process address space.")
        elif errno == EINVAL:
            raise Error("getpeername: `address_len` is invalid (e.g., is negative).")
        elif errno == ENOBUFS:
            raise Error("getpeername: Insufficient resources were available in the system to perform the operation.")
        elif errno == ENOTCONN:
            raise Error("getpeername: The socket is not connected.")
        elif errno == ENOTSOCK:
            raise Error("getpeername: The argument `socket` is not a socket, it is a file.")
        else:
            raise Error("getpeername: An error occurred while getting the socket name. Error code: " + str(errno))


fn _bind(socket: c_int, address: UnsafePointer[sockaddr], address_len: socklen_t) -> c_int:
    """Libc POSIX `bind` function.

    Args:
        socket: A File Descriptor.
        address: A UnsafePointer to the address to bind to.
        address_len: The size of the address.
    
    Returns:
        0 on success, -1 on error.

    #### C Function
    ```c
    int bind(int socket, const struct sockaddr *address, socklen_t address_len)
    ```

    #### Notes:
    * Reference: https://man7.org/linux/man-pages/man3/bind.3p.html
    """
    return external_call["bind", c_int, c_int, UnsafePointer[sockaddr], socklen_t](socket, address, address_len)


fn bind(socket: c_int, address: UnsafePointer[sockaddr], address_len: socklen_t) raises:
    """Libc POSIX `bind` function.

    Args:
        socket: A File Descriptor.
        address: A UnsafePointer to the address to bind to.
        address_len: The size of the address.
    
    Raises:
        Error: If an error occurs while binding the socket.
        EACCES: The address, `address`, is protected, and the user is not the superuser.
        EADDRINUSE: The given address is already in use.
        EBADF: `socket` is not a valid descriptor.
        EINVAL: The socket is already bound to an address.
        ENOTSOCK: `socket` is a descriptor for a file, not a socket.

        # The following errors are specific to UNIX domain (AF_UNIX) sockets
        EACCES: Search permission is denied on a component of the path prefix. (See also path_resolution(7).)
        EADDRNOTAVAIL: A nonexistent interface was requested or the requested address was not local.
        EFAULT: `address` points outside the user's accessible address space.
        EINVAL: The `address_len` is wrong, or the socket was not in the AF_UNIX family.
        ELOOP: Too many symbolic links were encountered in resolving addr.
        ENAMETOOLONG: `address` is too long.
        ENOENT: The file does not exist.
        ENOMEM: Insufficient kernel memory was available.
        ENOTDIR: A component of the path prefix is not a directory.
        EROFS: The socket inode would reside on a read-only file system.

    #### C Function
    ```c
    int bind(int socket, const struct sockaddr *address, socklen_t address_len)
    ```

    #### Notes:
    * Reference: https://man7.org/linux/man-pages/man3/bind.3p.html
    """
    var result = _bind(socket, address, address_len)
    if result == -1:
        var errno = get_errno()
        if errno == EACCES:
            raise Error("bind: The address, `address`, is protected, and the user is not the superuser.")
        elif errno == EADDRINUSE:
            raise Error("bind: The given address is already in use.")
        elif errno == EBADF:
            raise Error("bind: `socket` is not a valid descriptor.")
        elif errno == EINVAL:
            raise Error("bind: The socket is already bound to an address.")
        elif errno == ENOTSOCK:
            raise Error("bind: `socket` is a descriptor for a file, not a socket.")

        # The following errors are specific to UNIX domain (AF_UNIX) sockets. TODO: Pass address_family when unix sockets supported.
        # if address_family == AF_UNIX:
        #     if errno == EACCES:
        #         raise Error("bind: Search permission is denied on a component of the path prefix. (See also path_resolution(7).)")
        #     elif errno == EADDRNOTAVAIL:
        #         raise Error("bind: A nonexistent interface was requested or the requested address was not local.")
        #     elif errno == EFAULT:
        #         raise Error("bind: `address` points outside the user's accessible address space.")
        #     elif errno == EINVAL:
        #         raise Error("bind: The `address_len` is wrong, or the socket was not in the AF_UNIX family.")
        #     elif errno == ELOOP:
        #         raise Error("bind: Too many symbolic links were encountered in resolving addr.")
        #     elif errno == ENAMETOOLONG:
        #         raise Error("bind: `address` is too long.")
        #     elif errno == ENOENT:
        #         raise Error("bind: The file does not exist.")
        #     elif errno == ENOMEM:
        #         raise Error("bind: Insufficient kernel memory was available.")
        #     elif errno == ENOTDIR:
        #         raise Error("bind: A component of the path prefix is not a directory.")
        #     elif errno == EROFS:
        #         raise Error("bind: The socket inode would reside on a read-only file system.")
        
        raise Error("bind: An error occurred while binding the socket. Error code: " + str(errno))


fn _listen(socket: c_int, backlog: c_int) -> c_int:
    """Libc POSIX `listen` function.

    Args:
        socket: A File Descriptor.
        backlog: The maximum length of the queue of pending connections.

    Returns:
        0 on success, -1 on error.

    #### C Function
    ```c
    int listen(int socket, int backlog)
    ```

    #### Notes:
    * Reference: https://man7.org/linux/man-pages/man3/listen.3p.html
    """
    return external_call["listen", c_int, c_int, c_int](socket, backlog)


fn listen(socket: c_int, backlog: c_int) raises:
    """Libc POSIX `listen` function.

    Args:
        socket: A File Descriptor.
        backlog: The maximum length of the queue of pending connections.

    Raises:
        Error: If an error occurs while listening on the socket.
        EADDRINUSE: Another socket is already listening on the same port.
        EBADF: `socket` is not a valid descriptor.
        ENOTSOCK: `socket` is a descriptor for a file, not a socket.
        EOPNOTSUPP: The socket is not of a type that supports the `listen()` operation.

    #### C Function
    ```c
    int listen(int socket, int backlog)
    ```

    #### Notes:
    * Reference: https://man7.org/linux/man-pages/man3/listen.3p.html
    """
    var result = _listen(socket, backlog)
    if result == -1:
        var errno = get_errno()
        if errno == EADDRINUSE:
            raise Error("listen: Another socket is already listening on the same port.")
        elif errno == EBADF:
            raise Error("listen: `socket` is not a valid descriptor.")
        elif errno == ENOTSOCK:
            raise Error("listen: `socket` is a descriptor for a file, not a socket.")
        elif errno == EOPNOTSUPP:
            raise Error("listen: The socket is not of a type that supports the `listen()` operation.")
        else:
            raise Error("listen: An error occurred while listening on the socket. Error code: " + str(errno))


fn _accept(
    socket: c_int,
    address: UnsafePointer[sockaddr],
    address_len: UnsafePointer[socklen_t],
) -> c_int:
    """Libc POSIX `accept` function.

    Args:
        socket: A File Descriptor.
        address: A UnsafePointer to a buffer to store the address of the peer.
        address_len: A UnsafePointer to the size of the buffer.

    Returns:
        A File Descriptor or -1 in case of failure.

    #### C Function
    ```c
    int accept(int socket, struct sockaddr *restrict address, socklen_t *restrict address_len)
    ```

    #### Notes:
    * Reference: https://man7.org/linux/man-pages/man3/accept.3p.html
    """
    return external_call[
        "accept",
        c_int,  # FnName, RetType
        c_int,
        UnsafePointer[sockaddr],
        UnsafePointer[socklen_t],  # Args
    ](socket, address, address_len)


fn accept(
    socket: c_int,
    address: UnsafePointer[sockaddr],
    address_len: UnsafePointer[socklen_t],
) raises:
    """Libc POSIX `accept` function.

    Args:
        socket: A File Descriptor.
        address: A UnsafePointer to a buffer to store the address of the peer.
        address_len: A UnsafePointer to the size of the buffer.

    Raises:
        Error: If an error occurs while listening on the socket.
        EAGAIN or EWOULDBLOCK: The socket is marked nonblocking and no connections are present to be accepted. POSIX.1-2001 allows either error to be returned for this case, and does not require these constants to have the same value, so a portable application should check for both possibilities.
        EBADF: `socket` is not a valid descriptor.
        ECONNABORTED: `socket` is not a valid descriptor.
        EFAULT: The `address` argument is not in a writable part of the user address space.
        EINTR: The system call was interrupted by a signal that was caught before a valid connection arrived; see `signal(7)`.
        EINVAL: Socket is not listening for connections, or `addr_length` is invalid (e.g., is negative).
        EMFILE: The per-process limit of open file descriptors has been reached.
        ENFILE: The system limit on the total number of open files has been reached.
        ENOBUFS or ENOMEM: Not enough free memory. This often means that the memory allocation is limited by the socket buffer limits, not by the system memory.
        ENOTSOCK: `socket` is a descriptor for a file, not a socket.
        EOPNOTSUPP: The referenced socket is not of type `SOCK_STREAM`.
        EPROTO: Protocol error.

        # Linux specific errors
        EPERM: Firewall rules forbid connection.

    #### C Function
    ```c
    int accept(int socket, struct sockaddr *restrict address, socklen_t *restrict address_len)
    ```

    #### Notes:
    * Reference: https://man7.org/linux/man-pages/man3/accept.3p.html
    """
    var result = _accept(socket, address, address_len)
    if result == -1:
        var errno = get_errno()
        if int(errno) in [EAGAIN, EWOULDBLOCK]:
            raise Error("accept: The socket is marked nonblocking and no connections are present to be accepted. POSIX.1-2001 allows either error to be returned for this case, and does not require these constants to have the same value, so a portable application should check for both possibilities..")
        elif errno == EBADF:
            raise Error("accept: `socket` is not a valid descriptor.")
        elif errno == ECONNABORTED:
            raise Error("accept: `socket` is not a valid descriptor.")
        elif errno == EFAULT:
            raise Error("accept: The `address` argument is not in a writable part of the user address space.")
        elif errno == EINTR:
            raise Error("accept: The system call was interrupted by a signal that was caught before a valid connection arrived; see `signal(7)`.")
        elif errno == EINVAL:
            raise Error("accept: Socket is not listening for connections, or `addr_length` is invalid (e.g., is negative).")
        elif errno == EMFILE:
            raise Error("accept: The per-process limit of open file descriptors has been reached.")
        elif errno == ENFILE:
            raise Error("accept: The system limit on the total number of open files has been reached.")
        elif int(errno) in [ENOBUFS, ENOMEM]:
            raise Error("accept: Not enough free memory. This often means that the memory allocation is limited by the socket buffer limits, not by the system memory.")
        elif errno == ENOTSOCK:
            raise Error("accept: `socket` is a descriptor for a file, not a socket.")
        elif errno == EOPNOTSUPP:
            raise Error("accept: The referenced socket is not of type `SOCK_STREAM`.")
        elif errno == EPROTO:
            raise Error("accept: Protocol error.")
        
        @parameter
        if os_is_linux():
            if errno == EPERM:
                raise Error("accept: Firewall rules forbid connection.")
        raise Error("accept: An error occurred while listening on the socket. Error code: " + str(errno))


fn _connect(socket: c_int, address: Pointer[sockaddr], address_len: socklen_t) -> c_int:
    """Libc POSIX `connect` function.

    Args: socket: A File Descriptor.
        address: A UnsafePointer to the address to connect to.
        address_len: The size of the address.
    Returns: 0 on success, -1 on error.

    #### C Function
    ```c
    int connect(int socket, const struct sockaddr *address, socklen_t address_len)
    ```

    #### Notes:
    * Reference: https://man7.org/linux/man-pages/man3/connect.3p.html
    """
    return external_call["connect", c_int](socket, address, address_len)


fn connect(socket: c_int, address: Pointer[sockaddr], address_len: socklen_t) raises:
    """Libc POSIX `connect` function.

    Args: socket: A File Descriptor.
        address: A UnsafePointer to the address to connect to.
        address_len: The size of the address.
    Returns: 0 on success, -1 on error.

    #### C Function
    ```c
    int connect(int socket, const struct sockaddr *address, socklen_t address_len)
    ```

    #### Notes:
    * Reference: https://man7.org/linux/man-pages/man3/connect.3p.html
    """
    var result = _connect(socket, address, address_len)
    if result == -1:
        var errno = get_errno()
        if errno == EACCES:
            raise Error("connect: For UNIX domain sockets, which are identified by pathname: Write permission is denied on the socket file, or search permission is denied for one of the directories in the path prefix. (See also path_resolution(7)).")
        elif errno == EADDRINUSE:
            raise Error("connect: Local address is already in use.")
        elif errno == EAGAIN:
            raise Error("connect: No more free local ports or insufficient entries in the routing cache.")
        elif errno == EALREADY:
            raise Error("connect: The socket is nonblocking and a previous connection attempt has not yet been completed.")
        elif errno == EBADF:
            raise Error("connect: The file descriptor is not a valid index in the descriptor table.")
        elif errno == ECONNREFUSED:
            raise Error("connect: No-one listening on the remote address.")
        elif errno == EFAULT:
            raise Error("connect: The socket structure address is outside the user's address space.")
        elif errno == EINPROGRESS:
            raise Error("connect: The socket is nonblocking and the connection cannot be completed immediately. It is possible to select(2) or poll(2) for completion by selecting the socket for writing. After select(2) indicates writability, use getsockopt(2) to read the SO_ERROR option at level SOL_SOCKET to determine whether connect() completed successfully (SO_ERROR is zero) or unsuccessfully (SO_ERROR is one of the usual error codes listed here, explaining the reason for the failure).")
        elif errno == EINTR:
            raise Error("connect: The system call was interrupted by a signal that was caught.")
        elif errno == EISCONN:
            raise Error("connect: The socket is already connected.")
        elif errno == ENETUNREACH:
            raise Error("connect: Network is unreachable.")
        elif errno == ENOTSOCK:
            raise Error("connect: The file descriptor is not associated with a socket.")
        elif errno == EAFNOSUPPORT:
            raise Error("connect: The passed address didn't have the correct address family in its `sa_family` field.")
        elif errno == ETIMEDOUT:
            raise Error("connect: Timeout while attempting connection. The server may be too busy to accept new connections.")
        else:
            raise Error("connect: An error occurred while connecting to the socket. Error code: " + str(errno))


fn _recv(
    socket: c_int,
    buffer: UnsafePointer[UInt8],
    length: c_size_t,
    flags: c_int,
) -> c_ssize_t:
    """Libc POSIX `recv` function.

    Args:
        socket: A File Descriptor.
        buffer: A UnsafePointer to the buffer to store the received data.
        length: The size of the buffer.
        flags: Flags to control the behaviour of the function.
    
    Returns:
        The number of bytes received or -1 in case of failure.

    #### C Function
    ```c
    ssize_t recv(int socket, void *buffer, size_t length, int flags)
    ```

    #### Notes:
    * Reference: https://man7.org/linux/man-pages/man3/recv.3p.html
    """
    return external_call[
        "recv",
        c_ssize_t,  # FnName, RetType
        c_int,
        UnsafePointer[UInt8],
        c_size_t,
        c_int,  # Args
    ](socket, buffer, length, flags)


fn recv(
    socket: c_int,
    buffer: UnsafePointer[UInt8],
    length: c_size_t,
    flags: c_int,
) raises -> c_ssize_t:
    """Libc POSIX `recv` function.

    Args:
        socket: A File Descriptor.
        buffer: A UnsafePointer to the buffer to store the received data.
        length: The size of the buffer.
        flags: Flags to control the behaviour of the function.
    
    Returns:
        The number of bytes received or -1 in case of failure.

    #### C Function
    ```c
    ssize_t recv(int socket, void *buffer, size_t length, int flags)
    ```

    #### Notes:
    * Reference: https://man7.org/linux/man-pages/man3/recv.3p.html
    """
    var result = _recv(socket, buffer, length, flags)
    if result == -1:
        var errno = get_errno()
        if int(errno) in [EAGAIN, EWOULDBLOCK]:
            raise Error("recv: The socket is marked nonblocking and the receive operation would block, or a receive timeout had been set and the timeout expired before data was received.")
        elif errno == EBADF:
            raise Error("recv: The argument `socket` is an invalid descriptor.")
        elif errno == ECONNREFUSED:
            raise Error("recv: The remote host refused to allow the network connection (typically because it is not running the requested service).")
        elif errno == EFAULT:
            raise Error("recv: `buffer` points outside the process's address space.")
        elif errno == EINTR:
            raise Error("recv: The receive was interrupted by delivery of a signal before any data were available.")
        elif errno == ENOTCONN:
            raise Error("recv: The socket is not connected.")
        elif errno == ENOTSOCK:
            raise Error("recv: The file descriptor is not associated with a socket.")
        else:
            raise Error("recv: An error occurred while attempting to receive data from the socket. Error code: " + str(errno))
    
    return result


fn _send(socket: c_int, buffer: UnsafePointer[c_void], length: c_size_t, flags: c_int) -> c_ssize_t:
    """Libc POSIX `send` function.

    Args:
        socket: A File Descriptor.
        buffer: A UnsafePointer to the buffer to send.
        length: The size of the buffer.
        flags: Flags to control the behaviour of the function.

    Returns:
        The number of bytes sent or -1 in case of failure.

    #### C Function
    ```c
    ssize_t send(int socket, const void *buffer, size_t length, int flags)
    ```

    #### Notes:
    * Reference: https://man7.org/linux/man-pages/man3/send.3p.html
    """
    return external_call["send", c_ssize_t](socket, buffer, length, flags)


fn send(socket: c_int, buffer: UnsafePointer[c_void], length: c_size_t, flags: c_int) raises -> c_ssize_t:
    """Libc POSIX `send` function.

    Args:
        socket: A File Descriptor.
        buffer: A UnsafePointer to the buffer to send.
        length: The size of the buffer.
        flags: Flags to control the behaviour of the function.

    Returns:
        The number of bytes sent or -1 in case of failure.
    
    Raises:
        Error: If an error occurs while attempting to receive data from the socket.
        EAGAIN or EWOULDBLOCK: The socket is marked nonblocking and the receive operation would block, or a receive timeout had been set and the timeout expired before data was received.
        EBADF: The argument `socket` is an invalid descriptor.
        ECONNRESET: Connection reset by peer.
        EDESTADDRREQ: The socket is not connection-mode, and no peer address is set.
        ECONNREFUSED: The remote host refused to allow the network connection (typically because it is not running the requested service).
        EFAULT: `buffer` points outside the process's address space.
        EINTR: The receive was interrupted by delivery of a signal before any data were available.
        EINVAL: Invalid argument passed.
        EISCONN: The connection-mode socket was connected already but a recipient was specified.
        EMSGSIZE: The socket type requires that message be sent atomically, and the size of the message to be sent made this impossible.
        ENOBUFS: The output queue for a network interface was full. This generally indicates that the interface has stopped sending, but may be caused by transient congestion.
        ENOMEM: No memory available.
        ENOTCONN: The socket is not connected.
        ENOTSOCK: The file descriptor is not associated with a socket.
        EOPNOTSUPP: Some bit in the flags argument is inappropriate for the socket type.
        EPIPE: The local end has been shut down on a connection oriented socket. In this case the process will also receive a SIGPIPE unless MSG_NOSIGNAL is set.

    #### C Function
    ```c
    ssize_t send(int socket, const void *buffer, size_t length, int flags)
    ```

    #### Notes:
    * Reference: https://man7.org/linux/man-pages/man3/send.3p.html
    """
    var result = _send(socket, buffer, length, flags)
    if result == -1:
        var errno = get_errno()
        if int(errno) in [EAGAIN, EWOULDBLOCK]:
            raise Error("send: The socket is marked nonblocking and the receive operation would block, or a receive timeout had been set and the timeout expired before data was received.")
        elif errno == EBADF:
            raise Error("send: The argument `socket` is an invalid descriptor.")
        elif errno == EAGAIN:
            raise Error("send: No more free local ports or insufficient entries in the routing cache.")
        elif errno == ECONNRESET:
            raise Error("send: Connection reset by peer.")
        elif errno == EDESTADDRREQ:
            raise Error("send: The socket is not connection-mode, and no peer address is set.")
        elif errno == ECONNREFUSED:
            raise Error("send: The remote host refused to allow the network connection (typically because it is not running the requested service).")
        elif errno == EFAULT:
            raise Error("send: `buffer` points outside the process's address space.")
        elif errno == EINTR:
            raise Error("send: The receive was interrupted by delivery of a signal before any data were available.")
        elif errno == EINVAL:
            raise Error("send: Invalid argument passed.")
        elif errno == EISCONN:
            raise Error("send: The connection-mode socket was connected already but a recipient was specified.")
        elif errno == EMSGSIZE:
            raise Error("send: The socket type requires that message be sent atomically, and the size of the message to be sent made this impossible..")
        elif errno == ENOBUFS:
            raise Error("send: The output queue for a network interface was full. This generally indicates that the interface has stopped sending, but may be caused by transient congestion.")
        elif errno == ENOMEM:
            raise Error("send: No memory available.")
        elif errno == ENOTCONN:
            raise Error("send: The socket is not connected.")
        elif errno == ENOTSOCK:
            raise Error("send: The file descriptor is not associated with a socket.")
        elif errno == EOPNOTSUPP:
            raise Error("send: Some bit in the flags argument is inappropriate for the socket type.")
        elif errno == EPIPE:
            raise Error("send: The local end has been shut down on a connection oriented socket. In this case the process will also receive a SIGPIPE unless MSG_NOSIGNAL is set.")
        else:
            raise Error("send: An error occurred while attempting to receive data from the socket. Error code: " + str(errno))
    
    return result


fn _shutdown(socket: c_int, how: c_int) -> c_int:
    """Libc POSIX `shutdown` function.

    Args:
        socket: A File Descriptor.
        how: How to shutdown the socket.
    
    Returns:
        0 on success, -1 on error.

    #### C Function
    ```c
    int shutdown(int socket, int how)
    ```

    #### Notes:
    * Reference: https://man7.org/linux/man-pages/man3/shutdown.3p.html
    """
    return external_call["shutdown", c_int, c_int, c_int](socket, how)


fn shutdown(socket: c_int, how: c_int) raises:
    """Libc POSIX `shutdown` function.

    Args:
        socket: A File Descriptor.
        how: How to shutdown the socket.
    
    Raises:
        Error: If an error occurs while attempting to receive data from the socket.
        EBADF: The argument `socket` is an invalid descriptor.
        EINVAL: Invalid argument passed.
        ENOTCONN: The socket is not connected.
        ENOTSOCK: The file descriptor is not associated with a socket.

    #### C Function
    ```c
    int shutdown(int socket, int how)
    ```

    #### Notes:
    * Reference: https://man7.org/linux/man-pages/man3/shutdown.3p.html
    """
    var result = _shutdown(socket, how)
    if result == -1:
        var errno = get_errno()
        if errno == EBADF:
            raise Error("shutdown: The argument `socket` is an invalid descriptor.")
        elif errno == EINVAL:
            raise Error("shutdown: Invalid argument passed.")
        elif errno == ENOTCONN:
            raise Error("shutdown: The socket is not connected.")
        elif errno == ENOTSOCK:
            raise Error("shutdown: The file descriptor is not associated with a socket.")
        else:
            raise Error("shutdown: An error occurred while attempting to receive data from the socket. Error code: " + str(errno))


fn _getaddrinfo(
    nodename: UnsafePointer[c_char],
    servname: UnsafePointer[c_char],
    hints: UnsafePointer[addrinfo],
    res: UnsafePointer[UnsafePointer[addrinfo]],
) -> c_int:
    """Libc POSIX `getaddrinfo` function.

    Args:
        nodename: The node name.
        servname: The service name.
        hints: A UnsafePointer to the hints.
        res: A UnsafePointer to the result.
    
    Returns:
        0 on success, an error code on failure.

    #### C Function
    ```c
    int getaddrinfo(const char *restrict nodename, const char *restrict servname, const struct addrinfo *restrict hints, struct addrinfo **restrict res)
    ```

    #### Notes:
    * Reference: https://man7.org/linux/man-pages/man3/getaddrinfo.3p.html
    """
    return external_call[
        "getaddrinfo",
        c_int,  # FnName, RetType
        UnsafePointer[c_char],
        UnsafePointer[c_char],
        UnsafePointer[addrinfo],  # Args
        UnsafePointer[UnsafePointer[addrinfo]],  # Args
    ](nodename, servname, hints, res)


fn gai_strerror(ecode: c_int) -> UnsafePointer[c_char]:
    """Libc POSIX `gai_strerror` function.

    Args:
        ecode: The error code.

    Returns:
        A UnsafePointer to a string describing the error.

    #### C Function
    ```c
    const char *gai_strerror(int ecode)
    ```

    #### Notes:
    * Reference: https://man7.org/linux/man-pages/man3/gai_strerror.3p.html
    """
    return external_call["gai_strerror", UnsafePointer[c_char], c_int](ecode)


fn getaddrinfo(
    nodename: UnsafePointer[c_char],
    servname: UnsafePointer[c_char],
    hints: UnsafePointer[addrinfo],
    res: UnsafePointer[UnsafePointer[addrinfo]],
) raises:
    """Libc POSIX `getaddrinfo` function.

    Args:
        nodename: The node name.
        servname: The service name.
        hints: A UnsafePointer to the hints.
        res: A UnsafePointer to the result.
    
    Raises:
        Error: If an error occurs while attempting to receive data from the socket.
        EAI_AGAIN: The name could not be resolved at this time. Future attempts may succeed.
        EAI_BADFLAGS: The `ai_flags` value was invalid.
        EAI_FAIL: A non-recoverable error occurred when attempting to resolve the name.
        EAI_FAMILY: The `ai_family` member of the `hints` argument is not supported.
        EAI_MEMORY: Out of memory.
        EAI_NONAME: The name does not resolve for the supplied parameters.
        EAI_SERVICE: The `servname` is not supported for `ai_socktype`.
        EAI_SOCKTYPE: The `ai_socktype` is not supported.
        EAI_SYSTEM: A system error occurred. `errno` is set in this case.

    #### C Function
    ```c
    int getaddrinfo(const char *restrict nodename, const char *restrict servname, const struct addrinfo *restrict hints, struct addrinfo **restrict res)
    ```

    #### Notes:
    * Reference: https://man7.org/linux/man-pages/man3/getaddrinfo.3p.html
    """
    var result = _getaddrinfo(nodename, servname, hints, res)
    if result != 0:
        # gai_strerror returns a char buffer that we don't know the length of.
        # TODO: Perhaps switch to writing bytes once the Writer trait allows writing individual bytes.
        var err = gai_strerror(result)
        var msg = List[Byte, True]()
        var i = 0
        while err[i] != 0:
            msg.append(err[i])
            i += 1
        msg.append(0)
        raise Error("getaddrinfo: " + String(msg^))


fn inet_pton(address_family: Int, address: String) raises -> Int:
    """Converts an IP address from text to binary form.

    Args:
        address_family: The address family (AF_INET or AF_INET6).
        address: The IP address in text form.
    
    Returns:
        The IP address in binary form.
    """
    var ip_buf_size = 4
    if address_family == AF_INET6:
        ip_buf_size = 16

    var ip_buf = UnsafePointer[c_void].alloc(ip_buf_size)
    inet_pton(rebind[c_int](address_family), address.unsafe_ptr(), ip_buf)
    return int(ip_buf.bitcast[c_uint]())


# --- ( File Related Syscalls & Structs )---------------------------------------
alias O_NONBLOCK = 16384
alias O_ACCMODE = 3
alias O_CLOEXEC = 524288


fn _close(fildes: c_int) -> c_int:
    """Libc POSIX `close` function.

    Args:
        fildes: A File Descriptor to close.

    Returns:
        Upon successful completion, 0 shall be returned; otherwise, -1
        shall be returned and errno set to indicate the error.
    
    #### C Function
    ```c
    int close(int fildes).
    ```

    #### Notes:
    * Reference: https://man7.org/linux/man-pages/man3/close.3p.html
    """
    return external_call["close", c_int, c_int](fildes)


fn close(fildes: c_int) raises:
    """Libc POSIX `close` function.

    Args:
        fildes: A File Descriptor to close.
    
    Raises:
        SocketError: If an error occurs while creating the socket.
        EACCES: Permission to create a socket of the specified type and/or protocol is denied.
        EAFNOSUPPORT: The implementation does not support the specified address family.
        EINVAL: Invalid flags in type, Unknown protocol, or protocol family not available.
        EMFILE: The per-process limit on the number of open file descriptors has been reached.
        ENFILE: The system-wide limit on the total number of open files has been reached.
        ENOBUFS or ENOMEM: Insufficient memory is available. The socket cannot be created until sufficient resources are freed.
        EPROTONOSUPPORT: The protocol type or the specified protocol is not supported within this domain.
    
    #### C Function
    ```c
    int close(int fildes)
    ```

    #### Notes:
    * Reference: https://man7.org/linux/man-pages/man3/close.3p.html
    """
    if _close(fildes) == -1:
        var errno = get_errno()
        if errno == EBADF:
            raise Error("CloseError (EBADF): The fildes argument is not a valid open file descriptor.")
        elif errno == EINTR:
            raise Error("CloseError (EINTR): The close() function was interrupted by a signal.")
        elif errno == EIO:
            raise Error("CloseError (EIO): An I/O error occurred while reading from or writing to the file system.")
        elif int(errno) in [ENOSPC, EDQUOT]:
            raise Error("CloseError (ENOSPC or EDQUOT): On NFS, these errors are not normally reported against the first write which exceeds the available storage space, but instead against a subsequent write(2), fsync(2), or close().")
        else:
            raise Error("SocketError: An error occurred while creating the socket. Error code: " + str(errno))


fn get_errno() -> c_int:
    """Get a copy of the current value of the `errno` global variable for
    the current thread.

    Returns:
        A copy of the current value of `errno` for the current thread.
    """

    @parameter
    if os_is_windows():
        var errno = stack_allocation[1, c_int]()
        _ = external_call["_get_errno", c_void](errno)
        return errno[]
    else:
        alias loc = "__error" if os_is_macos() else "__errno_location"
        return external_call[loc, UnsafePointer[c_int]]()[]
