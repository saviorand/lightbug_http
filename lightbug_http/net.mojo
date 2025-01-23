from utils import StaticTuple
from time import sleep, perf_counter_ns
from memory import UnsafePointer, stack_allocation, Span
from sys.info import sizeof, os_is_macos
from sys.ffi import external_call, OpaquePointer
from lightbug_http.strings import NetworkType, to_string
from lightbug_http.io.bytes import Bytes, bytes
from lightbug_http.io.sync import Duration
from lightbug_http.libc import (
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
    SOCK_DGRAM,
    SOL_SOCKET,
    SO_REUSEADDR,
    SO_REUSEPORT,
    SHUT_RDWR,
    htons,
    ntohs,
    ntohl,
    inet_pton,
    inet_ntop,
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
    gai_strerror,
    INET_ADDRSTRLEN,
    INET6_ADDRSTRLEN,
)
from lightbug_http.utils import logger
from lightbug_http.socket import Socket


alias default_buffer_size = 4096
"""The default buffer size for reading and writing data."""
alias default_tcp_keep_alive = Duration(15 * 1000 * 1000 * 1000)  # 15 seconds
"""The default TCP keep-alive duration."""


trait Connection(Movable):
    fn read(self, mut buf: Bytes) raises -> Int:
        ...

    fn write(self, buf: Span[Byte]) raises -> Int:
        ...

    fn close(mut self) raises:
        ...

    fn shutdown(mut self) raises -> None:
        ...

    fn teardown(mut self) raises:
        ...

    fn local_addr(self) -> TCPAddr:
        ...

    fn remote_addr(self) -> TCPAddr:
        ...


trait Addr(Stringable, Representable, Writable, EqualityComparableCollectionElement):
    alias _type: StringLiteral

    fn __init__(out self):
        ...

    fn __init__(out self, ip: String, port: UInt16):
        ...

    fn network(self) -> String:
        ...


trait AnAddrInfo:
    fn get_ip_address(self, host: String) raises -> in_addr:
        """TODO: Once default functions can be implemented in traits, this function should use the functions currently
        implemented in the `addrinfo_macos` and `addrinfo_unix` structs.
        """
        ...


struct NoTLSListener:
    """A TCP listener that listens for incoming connections and can accept them."""

    var socket: Socket[TCPAddr]

    fn __init__(out self, owned socket: Socket[TCPAddr]):
        self.socket = socket^

    fn __init__(out self) raises:
        self.socket = Socket[TCPAddr]()

    fn __moveinit__(out self, owned existing: Self):
        self.socket = existing.socket^

    fn accept(self) raises -> TCPConnection:
        return TCPConnection(self.socket.accept())

    fn close(mut self) raises -> None:
        return self.socket.close()

    fn shutdown(mut self) raises -> None:
        return self.socket.shutdown()

    fn teardown(mut self) raises:
        self.socket.teardown()

    fn addr(self) -> TCPAddr:
        return self.socket.local_address()


struct ListenConfig:
    var _keep_alive: Duration

    fn __init__(out self, keep_alive: Duration = default_tcp_keep_alive):
        self._keep_alive = keep_alive

    fn listen[address_family: Int = AF_INET](mut self, address: String) raises -> NoTLSListener:
        constrained[address_family in [AF_INET, AF_INET6], "Address family must be either AF_INET or AF_INET6."]()
        var local = parse_address(address)
        var addr = TCPAddr(local[0], local[1])
        var socket: Socket[TCPAddr]
        try:
            socket = Socket[TCPAddr]()
        except e:
            logger.error(e)
            raise Error("ListenConfig.listen: Failed to create listener due to socket creation failure.")

        @parameter
        # TODO: do we want to reuse port on linux? currently doesn't work
        if os_is_macos():
            try:
                socket.set_socket_option(SO_REUSEADDR, 1)
            except e:
                logger.warn("ListenConfig.listen: Failed to set socket as reusable", e)

        var bind_success = False
        var bind_fail_logged = False
        while not bind_success:
            try:
                socket.bind(addr.ip, addr.port)
                bind_success = True
            except e:
                if not bind_fail_logged:
                    print("Bind attempt failed: ", e)
                    print("Retrying. Might take 10-15 seconds.")
                    bind_fail_logged = True
                print(".", end="", flush=True)

                try:
                    socket.shutdown()
                except e:
                    logger.error("ListenConfig.listen: Failed to shutdown socket:", e)
                    # TODO: Should shutdown failure be a hard failure? We can still ungracefully close the socket.
                sleep(UInt(1))

        try:
            socket.listen(128)
        except e:
            logger.error(e)
            raise Error("ListenConfig.listen: Listen failed on sockfd: " + str(socket.fd))

        var listener = NoTLSListener(socket^)
        var msg = String.write("\n🔥🐝 Lightbug is listening on ", "http://", addr.ip, ":", str(addr.port))
        print(msg)
        print("Ready to accept connections...")

        return listener^


struct TCPConnection:
    var socket: Socket[TCPAddr]

    fn __init__(out self, owned socket: Socket[TCPAddr]):
        self.socket = socket^

    fn __moveinit__(out self, owned existing: Self):
        self.socket = existing.socket^

    fn read(self, mut buf: Bytes) raises -> Int:
        try:
            return self.socket.receive(buf)
        except e:
            if str(e) == "EOF":
                raise e
            else:
                logger.error(e)
                raise Error("TCPConnection.read: Failed to read data from connection.")

    fn write(self, buf: Span[Byte]) raises -> Int:
        if buf[-1] == 0:
            raise Error("TCPConnection.write: Buffer must not be null-terminated.")

        try:
            return self.socket.send(buf)
        except e:
            logger.error("TCPConnection.write: Failed to write data to connection.")
            raise e

    fn close(mut self) raises:
        self.socket.close()

    fn shutdown(mut self) raises:
        self.socket.shutdown()

    fn teardown(mut self) raises:
        self.socket.teardown()

    fn is_closed(self) -> Bool:
        return self.socket._closed

    # TODO: Switch to property or return ref when trait supports attributes.
    fn local_addr(self) -> TCPAddr:
        return self.socket.local_address()

    fn remote_addr(self) -> TCPAddr:
        return self.socket.remote_address()


struct UDPConnection:
    var socket: Socket[UDPAddr]

    fn __init__(out self, owned socket: Socket[UDPAddr]):
        self.socket = socket^

    fn __moveinit__(out self, owned existing: Self):
        self.socket = existing.socket^

    fn read_from(mut self, size: Int = default_buffer_size) raises -> (Bytes, String, UInt16):
        """Reads data from the underlying file descriptor.

        Args:
            size: The size of the buffer to read data into.

        Returns:
            The number of bytes read, or an error if one occurred.

        Raises:
            Error: If an error occurred while reading data.
        """
        return self.socket.receive_from(size)

    fn read_from(mut self, mut dest: Bytes) raises -> (UInt, String, UInt16):
        """Reads data from the underlying file descriptor.

        Args:
            dest: The buffer to read data into.

        Returns:
            The number of bytes read, or an error if one occurred.

        Raises:
            Error: If an error occurred while reading data.
        """
        return self.socket.receive_from(dest)

    fn write_to(mut self, src: Span[Byte], address: UDPAddr) raises -> Int:
        """Writes data to the underlying file descriptor.

        Args:
            src: The buffer to read data into.
            address: The remote peer address.

        Returns:
            The number of bytes written, or an error if one occurred.

        Raises:
            Error: If an error occurred while writing data.
        """
        return self.socket.send_to(src, address.ip, address.port)

    fn write_to(mut self, src: Span[Byte], host: String, port: UInt16) raises -> Int:
        """Writes data to the underlying file descriptor.

        Args:
            src: The buffer to read data into.
            host: The remote peer address in IPv4 format.
            port: The remote peer port.

        Returns:
            The number of bytes written, or an error if one occurred.

        Raises:
            Error: If an error occurred while writing data.
        """
        return self.socket.send_to(src, host, port)

    fn close(mut self) raises:
        self.socket.close()

    fn shutdown(mut self) raises:
        self.socket.shutdown()

    fn teardown(mut self) raises:
        self.socket.teardown()

    fn is_closed(self) -> Bool:
        return self.socket._closed

    fn local_addr(self) -> ref [self.socket._local_address] UDPAddr:
        return self.socket.local_address()

    fn remote_addr(self) -> ref [self.socket._remote_address] UDPAddr:
        return self.socket.remote_address()


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
    var ai_next: OpaquePointer

    fn __init__(
        out self,
        ai_flags: c_int = 0,
        ai_family: c_int = 0,
        ai_socktype: c_int = 0,
        ai_protocol: c_int = 0,
        ai_addrlen: socklen_t = 0,
    ):
        self.ai_flags = ai_flags
        self.ai_family = ai_family
        self.ai_socktype = ai_socktype
        self.ai_protocol = ai_protocol
        self.ai_addrlen = ai_addrlen
        self.ai_canonname = UnsafePointer[c_char]()
        self.ai_addr = UnsafePointer[sockaddr]()
        self.ai_next = OpaquePointer()

    fn get_ip_address(self, host: String) raises -> in_addr:
        """Returns an IP address based on the host.
        This is a MacOS-specific implementation.

        Args:
            host: String - The host to get the IP from.

        Returns:
            The IP address.
        """
        var result = UnsafePointer[Self]()
        var hints = Self(ai_flags=0, ai_family=AF_INET, ai_socktype=SOCK_STREAM, ai_protocol=0)
        try:
            getaddrinfo(host, String(), hints, result)
        except e:
            logger.error("Failed to get IP address.")
            raise e

        if not result[].ai_addr:
            freeaddrinfo(result)
            raise Error("Failed to get IP address because the response's `ai_addr` was null.")

        var ip = result[].ai_addr.bitcast[sockaddr_in]()[].sin_addr
        freeaddrinfo(result)
        return ip


@value
@register_passable("trivial")
struct addrinfo_unix(AnAddrInfo):
    """Standard addrinfo struct for Unix systems.
    Overwrites the existing libc `getaddrinfo` function to adhere to the AnAddrInfo trait.
    """

    var ai_flags: c_int
    var ai_family: c_int
    var ai_socktype: c_int
    var ai_protocol: c_int
    var ai_addrlen: socklen_t
    var ai_addr: UnsafePointer[sockaddr]
    var ai_canonname: UnsafePointer[c_char]
    var ai_next: OpaquePointer

    fn __init__(
        out self,
        ai_flags: c_int = 0,
        ai_family: c_int = 0,
        ai_socktype: c_int = 0,
        ai_protocol: c_int = 0,
        ai_addrlen: socklen_t = 0,
    ):
        self.ai_flags = ai_flags
        self.ai_family = ai_family
        self.ai_socktype = ai_socktype
        self.ai_protocol = ai_protocol
        self.ai_addrlen = ai_addrlen
        self.ai_addr = UnsafePointer[sockaddr]()
        self.ai_canonname = UnsafePointer[c_char]()
        self.ai_next = OpaquePointer()

    fn get_ip_address(self, host: String) raises -> in_addr:
        """Returns an IP address based on the host.
        This is a Unix-specific implementation.

        Args:
            host: String - The host to get IP from.

        Returns:
            The IP address.
        """
        var result = UnsafePointer[Self]()
        var hints = Self(ai_flags=0, ai_family=AF_INET, ai_socktype=SOCK_STREAM, ai_protocol=0)
        try:
            getaddrinfo(host, String(), hints, result)
        except e:
            logger.error("Failed to get IP address.")
            raise e

        if not result[].ai_addr:
            freeaddrinfo(result)
            raise Error("Failed to get IP address because the response's `ai_addr` was null.")

        var ip = result[].ai_addr.bitcast[sockaddr_in]()[].sin_addr
        freeaddrinfo(result)
        return ip


fn create_connection(host: String, port: UInt16) raises -> TCPConnection:
    """Connect to a server using a socket.

    Args:
        host: The host to connect to.
        port: The port to connect on.

    Returns:
        The socket file descriptor.
    """
    var socket = Socket[TCPAddr]()
    try:
        socket.connect(host, port)
    except e:
        logger.error(e)
        try:
            socket.shutdown()
        except e:
            logger.error("Failed to shutdown socket: " + str(e))
        raise Error("Failed to establish a connection to the server.")

    return TCPConnection(socket^)


@value
struct TCPAddr(Addr):
    alias _type = "TCPAddr"
    var ip: String
    var port: UInt16
    var zone: String  # IPv6 addressing zone

    fn __init__(out self):
        self.ip = "127.0.0.1"
        self.port = 8000
        self.zone = ""

    fn __init__(out self, ip: String = "127.0.0.1", port: UInt16 = 8000):
        self.ip = ip
        self.port = port
        self.zone = ""

    fn network(self) -> String:
        return NetworkType.tcp.value

    fn __eq__(self, other: Self) -> Bool:
        return self.ip == other.ip and self.port == other.port and self.zone == other.zone

    fn __ne__(self, other: Self) -> Bool:
        return not self == other

    fn __str__(self) -> String:
        if self.zone != "":
            return join_host_port(self.ip + "%" + self.zone, str(self.port))
        return join_host_port(self.ip, str(self.port))

    fn __repr__(self) -> String:
        return String.write(self)

    fn write_to[W: Writer, //](self, mut writer: W):
        writer.write("TCPAddr(", "ip=", repr(self.ip), ", port=", str(self.port), ", zone=", repr(self.zone), ")")


@value
struct UDPAddr(Addr):
    alias _type = "UDPAddr"
    var ip: String
    var port: UInt16
    var zone: String  # IPv6 addressing zone

    fn __init__(out self):
        self.ip = "127.0.0.1"
        self.port = 8000
        self.zone = ""

    fn __init__(out self, ip: String = "127.0.0.1", port: UInt16 = 8000):
        self.ip = ip
        self.port = port
        self.zone = ""

    fn network(self) -> String:
        return NetworkType.udp.value

    fn __eq__(self, other: Self) -> Bool:
        return self.ip == other.ip and self.port == other.port and self.zone == other.zone

    fn __ne__(self, other: Self) -> Bool:
        return not self == other

    fn __str__(self) -> String:
        if self.zone != "":
            return join_host_port(self.ip + "%" + self.zone, str(self.port))
        return join_host_port(self.ip, str(self.port))

    fn __repr__(self) -> String:
        return String.write(self)

    fn write_to[W: Writer, //](self, mut writer: W):
        writer.write("UDPAddr(", "ip=", repr(self.ip), ", port=", str(self.port), ", zone=", repr(self.zone), ")")


fn listen_udp(local_address: UDPAddr) raises -> UDPConnection:
    """Creates a new UDP listener.

    Args:
        local_address: The local address to listen on.

    Returns:
        A UDP connection.

    Raises:
        Error: If the address is invalid or failed to bind the socket.
    """
    socket = Socket[UDPAddr](socket_type=SOCK_DGRAM)
    socket.bind(local_address.ip, local_address.port)
    return UDPConnection(socket^)


fn listen_udp(local_address: String) raises -> UDPConnection:
    """Creates a new UDP listener.

    Args:
        local_address: The address to listen on. The format is "host:port".

    Returns:
        A UDP connection.

    Raises:
        Error: If the address is invalid or failed to bind the socket.
    """
    var address = parse_address(local_address)
    return listen_udp(UDPAddr(address[0], address[1]))


fn listen_udp(host: String, port: UInt16) raises -> UDPConnection:
    """Creates a new UDP listener.

    Args:
        host: The address to listen on in ipv4 format.
        port: The port number.

    Returns:
        A UDP connection.

    Raises:
        Error: If the address is invalid or failed to bind the socket.
    """
    return listen_udp(UDPAddr(host, port))


fn dial_udp(local_address: UDPAddr) raises -> UDPConnection:
    """Connects to the address on the named network. The network must be "udp", "udp4", or "udp6".

    Args:
        local_address: The local address.

    Returns:
        The UDP connection.

    Raises:
        Error: If the network type is not supported or failed to connect to the address.
    """
    return UDPConnection(Socket(local_address=local_address, socket_type=SOCK_DGRAM))


fn dial_udp(local_address: String) raises -> UDPConnection:
    """Connects to the address on the named network. The network must be "udp", "udp4", or "udp6".

    Args:
        local_address: The local address.

    Returns:
        The UDP connection.

    Raises:
        Error: If the network type is not supported or failed to connect to the address.
    """
    var address = parse_address(local_address)
    return dial_udp(UDPAddr(address[0], address[1]))


fn dial_udp(host: String, port: UInt16) raises -> UDPConnection:
    """Connects to the address on the named network. The network must be "udp", "udp4", or "udp6".

    Args:
        host: The host to connect to.
        port: The port to connect on.

    Returns:
        The UDP connection.

    Raises:
        Error: If the network type is not supported or failed to connect to the address.
    """
    return dial_udp(UDPAddr(host, port))


# TODO: Support IPv6 long form.
fn join_host_port(host: String, port: String) -> String:
    if host.find(":") != -1:  # must be IPv6 literal
        return "[" + host + "]:" + port
    return host + ":" + port


alias MissingPortError = Error("missing port in address")
alias TooManyColonsError = Error("too many colons in address")


fn parse_address(address: String) raises -> (String, UInt16):
    """Parse an address string into a host and port.

    Args:
        address: The address string.

    Returns:
        A tuple containing the host and port.
    """
    var colon_index = address.rfind(":")
    if colon_index == -1:
        raise MissingPortError

    var host: String = ""
    var port: String = ""
    var j: Int = 0
    var k: Int = 0

    if address[0] == "[":
        var end_bracket_index = address.find("]")
        if end_bracket_index == -1:
            raise Error("missing ']' in address")

        if end_bracket_index + 1 == len(address):
            raise MissingPortError
        elif end_bracket_index + 1 == colon_index:
            host = address[1:end_bracket_index]
            j = 1
            k = end_bracket_index + 1
        else:
            if address[end_bracket_index + 1] == ":":
                raise TooManyColonsError
            else:
                raise MissingPortError
    else:
        host = address[:colon_index]
        if host.find(":") != -1:
            raise TooManyColonsError

    if address[j:].find("[") != -1:
        raise Error("unexpected '[' in address")
    if address[k:].find("]") != -1:
        raise Error("unexpected ']' in address")

    port = address[colon_index + 1 :]
    if port == "":
        raise MissingPortError
    if host == "":
        raise Error("missing host")
    return host, UInt16(int(port))


fn binary_port_to_int(port: UInt16) -> Int:
    """Convert a binary port to an integer.

    Args:
        port: The binary port.

    Returns:
        The port as an integer.
    """
    return int(ntohs(port))


fn binary_ip_to_string[address_family: Int32](owned ip_address: UInt32) raises -> String:
    """Convert a binary IP address to a string by calling `inet_ntop`.

    Parameters:
        address_family: The address family of the IP address.

    Args:
        ip_address: The binary IP address.

    Returns:
        The IP address as a string.
    """
    constrained[int(address_family) in [AF_INET, AF_INET6], "Address family must be either AF_INET or AF_INET6."]()
    var ip: String

    @parameter
    if address_family == AF_INET:
        ip = inet_ntop[address_family, INET_ADDRSTRLEN](ip_address)
    else:
        ip = inet_ntop[address_family, INET6_ADDRSTRLEN](ip_address)

    return ip


fn _getaddrinfo[
    T: AnAddrInfo, hints_origin: MutableOrigin, result_origin: MutableOrigin, //
](
    nodename: UnsafePointer[c_char],
    servname: UnsafePointer[c_char],
    hints: Pointer[T, hints_origin],
    res: Pointer[UnsafePointer[T], result_origin],
) -> c_int:
    """Libc POSIX `getaddrinfo` function.

    Args:
        nodename: The node name.
        servname: The service name.
        hints: A Pointer to the hints.
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
        Pointer[T, hints_origin],  # Args
        Pointer[UnsafePointer[T], result_origin],  # Args
    ](nodename, servname, hints, res)


fn getaddrinfo[
    T: AnAddrInfo, //
](node: String, service: String, mut hints: T, mut res: UnsafePointer[T],) raises:
    """Libc POSIX `getaddrinfo` function.

    Args:
        node: The node name.
        service: The service name.
        hints: A Pointer to the hints.
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
    var result = _getaddrinfo(
        node.unsafe_ptr(), service.unsafe_ptr(), Pointer.address_of(hints), Pointer.address_of(res)
    )
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


fn freeaddrinfo[T: AnAddrInfo, //](ptr: UnsafePointer[T]):
    """Free the memory allocated by `getaddrinfo`."""
    external_call["freeaddrinfo", NoneType, UnsafePointer[T]](ptr)
