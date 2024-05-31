from collections.optional import Optional
from ..builtins import Byte
from ..syscall.file import close
from ..syscall.types import (
    c_void,
    c_uint,
    c_char,
    c_int,
)
from ..syscall.net import (
    sockaddr,
    sockaddr_in,
    addrinfo,
    addrinfo_unix,
    socklen_t,
    socket,
    connect,
    recv,
    send,
    shutdown,
    inet_pton,
    inet_ntoa,
    inet_ntop,
    to_char_ptr,
    htons,
    ntohs,
    strlen,
    getaddrinfo,
    getaddrinfo_unix,
    gai_strerror,
    c_charptr_to_string,
    bind,
    listen,
    accept,
    setsockopt,
    getsockopt,
    getsockname,
    getpeername,
    AF_INET,
    SOCK_STREAM,
    SHUT_RDWR,
    AI_PASSIVE,
    SOL_SOCKET,
    SO_REUSEADDR,
    SO_RCVTIMEO,
)
from .fd import FileDescriptor, FileDescriptorBase
from .ip import (
    convert_binary_ip_to_string,
    build_sockaddr_pointer,
    convert_binary_port_to_int,
)
from .address import Addr, TCPAddr, HostPort

alias SocketClosedError = Error("Socket: Socket is already closed")


struct Socket(FileDescriptorBase):
    """Represents a network file descriptor. Wraps around a file descriptor and provides network functions.

    Args:
        local_address: The local address of the socket (local address if bound).
        remote_address: The remote address of the socket (peer's address if connected).
        address_family: The address family of the socket.
        socket_type: The socket type.
        protocol: The protocol.
    """

    var sockfd: FileDescriptor
    var address_family: Int
    var socket_type: UInt8
    var protocol: UInt8
    var local_address: TCPAddr
    var remote_address: TCPAddr
    var _closed: Bool
    var _is_connected: Bool

    fn __init__(
        inout self,
        local_address: TCPAddr = TCPAddr(),
        remote_address: TCPAddr = TCPAddr(),
        address_family: Int = AF_INET,
        socket_type: UInt8 = SOCK_STREAM,
        protocol: UInt8 = 0,
    ) raises:
        """Create a new socket object.

        Args:
            local_address: The local address of the socket (local address if bound).
            remote_address: The remote address of the socket (peer's address if connected).
            address_family: The address family of the socket.
            socket_type: The socket type.
            protocol: The protocol.
        """
        self.address_family = address_family
        self.socket_type = socket_type
        self.protocol = protocol

        var fd = socket(address_family, SOCK_STREAM, 0)
        if fd == -1:
            raise Error("Socket creation error")
        self.sockfd = FileDescriptor(int(fd))
        self.local_address = local_address
        self.remote_address = remote_address
        self._closed = False
        self._is_connected = False

    fn __init__(
        inout self,
        fd: Int32,
        address_family: Int,
        socket_type: UInt8,
        protocol: UInt8,
        local_address: TCPAddr = TCPAddr(),
        remote_address: TCPAddr = TCPAddr(),
    ):
        """
        Create a new socket object when you already have a socket file descriptor. Typically through socket.accept().

        Args:
            fd: The file descriptor of the socket.
            address_family: The address family of the socket.
            socket_type: The socket type.
            protocol: The protocol.
            local_address: Local address of socket.
            remote_address: Remote address of port.
        """
        self.sockfd = FileDescriptor(int(fd))
        self.address_family = address_family
        self.socket_type = socket_type
        self.protocol = protocol
        self.local_address = local_address
        self.remote_address = remote_address
        self._closed = False
        self._is_connected = True

    fn __moveinit__(inout self, owned existing: Self):
        self.sockfd = existing.sockfd^
        self.address_family = existing.address_family
        self.socket_type = existing.socket_type
        self.protocol = existing.protocol
        self.local_address = existing.local_address^
        self.remote_address = existing.remote_address^
        self._closed = existing._closed
        self._is_connected = existing._is_connected

    # fn __enter__(self) -> Self:
    #     return self

    # fn __exit__(inout self) raises:
    #     if self._is_connected:
    #         self.shutdown()
    #     if not self._closed:
    #         self.close()

    fn __del__(owned self):
        if self._is_connected:
            self.shutdown()
        if not self._closed:
            var err = self.close()
            _ = self.sockfd.fd
            if err:
                print("Failed to close socket during deletion:", str(err))

    @always_inline
    fn accept(self) raises -> Self:
        """Accept a connection. The socket must be bound to an address and listening for connections.
        The return value is a connection where conn is a new socket object usable to send and receive data on the connection,
        and address is the address bound to the socket on the other end of the connection.
        """
        var their_addr_ptr = Pointer[sockaddr].alloc(1)
        var sin_size = socklen_t(sizeof[socklen_t]())
        var new_sockfd = accept(self.sockfd.fd, their_addr_ptr, Pointer[socklen_t].address_of(sin_size))
        if new_sockfd == -1:
            raise Error("Failed to accept connection")

        var remote = self.get_peer_name()
        return Self(
            new_sockfd,
            self.address_family,
            self.socket_type,
            self.protocol,
            self.local_address,
            TCPAddr(remote.host, remote.port),
        )

    fn listen(self, backlog: Int = 0) raises:
        """Enable a server to accept connections.

        Args:
            backlog: The maximum number of queued connections. Should be at least 0, and the maximum is system-dependent (usually 5).
        """
        var queued = backlog
        if backlog < 0:
            queued = 0
        if listen(self.sockfd.fd, queued) == -1:
            raise Error("Failed to listen for connections")

    @always_inline
    fn bind(inout self, address: String, port: Int) raises:
        """Bind the socket to address. The socket must not already be bound. (The format of address depends on the address family).

        When a socket is created with Socket(), it exists in a name
        space (address family) but has no address assigned to it.  bind()
        assigns the address specified by addr to the socket referred to
        by the file descriptor sockfd.  addrlen specifies the size, in
        bytes, of the address structure pointed to by addr.
        Traditionally, this operation is called 'assigning a name to a
        socket'.

        Args:
            address: String - The IP address to bind the socket to.
            port: The port number to bind the socket to.
        """
        var sockaddr_pointer = build_sockaddr_pointer(address, port, self.address_family)

        if bind(self.sockfd.fd, sockaddr_pointer, sizeof[sockaddr_in]()) == -1:
            _ = shutdown(self.sockfd.fd, SHUT_RDWR)
            raise Error("Binding socket failed. Wait a few seconds and try again?")

        var local = self.get_sock_name()
        self.local_address = TCPAddr(local.host, local.port)

    @always_inline
    fn file_no(self) -> Int32:
        """Return the file descriptor of the socket."""
        return self.sockfd.fd

    @always_inline
    fn get_sock_name(self) raises -> HostPort:
        """Return the address of the socket."""
        if self._closed:
            raise SocketClosedError

        # TODO: Add check to see if the socket is bound and error if not.

        var local_address_ptr = Pointer[sockaddr].alloc(1)
        var local_address_ptr_size = socklen_t(sizeof[sockaddr]())
        var status = getsockname(
            self.sockfd.fd,
            local_address_ptr,
            Pointer[socklen_t].address_of(local_address_ptr_size),
        )
        if status == -1:
            raise Error("Socket.get_sock_name: Failed to get address of local socket.")
        var addr_in = local_address_ptr.bitcast[sockaddr_in]().load()

        return HostPort(
            host=convert_binary_ip_to_string(addr_in.sin_addr.s_addr, AF_INET, 16),
            port=convert_binary_port_to_int(addr_in.sin_port),
        )

    fn get_peer_name(self) raises -> HostPort:
        """Return the address of the peer connected to the socket."""
        if self._closed:
            raise SocketClosedError

        # TODO: Add check to see if the socket is bound and error if not.
        var remote_address_ptr = Pointer[sockaddr].alloc(1)
        var remote_address_ptr_size = socklen_t(sizeof[sockaddr]())
        var status = getpeername(
            self.sockfd.fd,
            remote_address_ptr,
            Pointer[socklen_t].address_of(remote_address_ptr_size),
        )
        if status == -1:
            raise Error("Socket.get_peer_name: Failed to get address of remote socket.")

        # Cast sockaddr struct to sockaddr_in to convert binary IP to string.
        var addr_in = remote_address_ptr.bitcast[sockaddr_in]().load()

        return HostPort(
            host=convert_binary_ip_to_string(addr_in.sin_addr.s_addr, AF_INET, 16),
            port=convert_binary_port_to_int(addr_in.sin_port),
        )

    fn get_socket_option(self, option_name: Int) raises -> Int:
        """Return the value of the given socket option.

        Args:
            option_name: The socket option to get.
        """
        var option_value_pointer = Pointer[c_void].alloc(1)
        var option_len = socklen_t(sizeof[socklen_t]())
        var option_len_pointer = Pointer.address_of(option_len)
        var status = getsockopt(
            self.sockfd.fd,
            SOL_SOCKET,
            option_name,
            option_value_pointer,
            option_len_pointer,
        )
        if status == -1:
            raise Error("Socket.get_sock_opt failed with status: " + str(status))

        return option_value_pointer.bitcast[Int]().load()

    fn set_socket_option(self, option_name: Int, owned option_value: UInt8 = 1) raises:
        """Return the value of the given socket option.

        Args:
            option_name: The socket option to set.
            option_value: The value to set the socket option to.
        """
        var option_value_pointer = Pointer[c_void].address_of(option_value)
        var option_len = sizeof[socklen_t]()
        var status = setsockopt(self.sockfd.fd, SOL_SOCKET, option_name, option_value_pointer, option_len)
        if status == -1:
            raise Error("Socket.set_sock_opt failed with status: " + str(status))

    fn connect(inout self, address: String, port: Int) raises:
        """Connect to a remote socket at address.

        Args:
            address: String - The IP address to connect to.
            port: The port number to connect to.
        """
        var sockaddr_pointer = build_sockaddr_pointer(address, port, self.address_family)

        if connect(self.sockfd.fd, sockaddr_pointer, sizeof[sockaddr_in]()) == -1:
            self.shutdown()
            raise Error("Socket.connect: Failed to connect to the remote socket at: " + address + ":" + str(port))

        var remote = self.get_peer_name()
        self.remote_address = TCPAddr(remote.host, remote.port)

    fn write(inout self: Self, src: List[Byte]) -> (Int, Error):
        """Send data to the socket. The socket must be connected to a remote socket.

        Args:
            src: The data to send.

        Returns:
            The number of bytes sent.
        """
        var bytes_written: Int
        var err: Error
        bytes_written, err = self.sockfd.write(src)
        if err:
            return 0, err

        return bytes_written, Error()

    fn send_all(self, src: List[Byte], max_attempts: Int = 3) raises:
        """Send data to the socket. The socket must be connected to a remote socket.

        Args:
            src: The data to send.
            max_attempts: The maximum number of attempts to send the data.
        """
        var header_pointer = src.unsafe_ptr()
        var total_bytes_sent = 0
        var attempts = 0

        # Try to send all the data in the buffer. If it did not send all the data, keep trying but start from the offset of the last successful send.
        while total_bytes_sent < len(src):
            if attempts > max_attempts:
                raise Error("Failed to send message after " + String(max_attempts) + " attempts.")

            var bytes_sent = send(
                self.sockfd.fd,
                header_pointer.offset(total_bytes_sent),
                strlen(header_pointer.offset(total_bytes_sent)),
                0,
            )
            if bytes_sent == -1:
                raise Error("Failed to send message, wrote" + String(total_bytes_sent) + "bytes before failing.")
            total_bytes_sent += bytes_sent
            attempts += 1

    fn send_to(inout self, src: List[Byte], address: String, port: Int) raises -> Int:
        """Send data to the a remote address by connecting to the remote socket before sending.
        The socket must be not already be connected to a remote socket.

        Args:
            src: The data to send.
            address: The IP address to connect to.
            port: The port number to connect to.
        """
        var header_pointer = Pointer[Int8](src.data.address).bitcast[UInt8]()
        self.connect(address, port)
        var bytes_written: Int
        var err: Error
        bytes_written, err = self.write(src)
        if err:
            raise err
        return bytes_written

    fn read(inout self, inout dest: List[Byte]) -> (Int, Error):
        """Receive data from the socket."""
        # Not ideal since we can't use the pointer from the List[Byte] struct directly. So we use a temporary pointer to receive the data.
        # Then we copy all the data over.
        var bytes_written: Int
        var err: Error
        bytes_written, err = self.sockfd.read(dest)
        if err:
            if str(err) != "EOF":
                return 0, err

        return bytes_written, Error()

    fn shutdown(self):
        _ = shutdown(self.sockfd.fd, SHUT_RDWR)

    fn close(inout self) -> Error:
        """Mark the socket closed.
        Once that happens, all future operations on the socket object will fail.
        The remote end will receive no more data (after queued data is flushed).
        """
        self.shutdown()
        var err = self.sockfd.close()
        if err:
            return err

        self._closed = True
        return Error()

    # TODO: Trying to set timeout fails, but some other options don't?
    # fn get_timeout(self) raises -> Seconds:
    #     """Return the timeout value for the socket."""
    #     return self.get_socket_option(SO_RCVTIMEO)

    # fn set_timeout(self, owned duration: Seconds) raises:
    #     """Set the timeout value for the socket.

    #     Args:
    #         duration: Seconds - The timeout duration in seconds.
    #     """
    #     self.set_socket_option(SO_RCVTIMEO, duration)

    fn send_file(self, file: FileHandle, offset: Int = 0) raises:
        self.send_all(file.read_bytes())
