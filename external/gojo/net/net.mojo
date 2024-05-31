from memory.arc import Arc
import ..io
from ..builtins import Byte
from .socket import Socket
from .address import Addr, TCPAddr

alias DEFAULT_BUFFER_SIZE = 4096


trait Conn(io.Writer, io.Reader, io.Closer):
    fn __init__(inout self, owned socket: Socket):
        ...

    """Conn is a generic stream-oriented network connection."""

    fn local_address(self) -> TCPAddr:
        """Returns the local network address, if known."""
        ...

    fn remote_address(self) -> TCPAddr:
        """Returns the local network address, if known."""
        ...

    # fn set_deadline(self, t: time.Time) -> Error:
    #     """Sets the read and write deadlines associated
    #     with the connection. It is equivalent to calling both
    #     SetReadDeadline and SetWriteDeadline.

    #     A deadline is an absolute time after which I/O operations
    #     fail instead of blocking. The deadline applies to all future
    #     and pending I/O, not just the immediately following call to
    #     read or write. After a deadline has been exceeded, the
    #     connection can be refreshed by setting a deadline in the future.

    #     If the deadline is exceeded a call to read or write or to other
    #     I/O methods will return an error that wraps os.ErrDeadlineExceeded.
    #     This can be tested using errors.Is(err, os.ErrDeadlineExceeded).
    #     The error's Timeout method will return true, but note that there
    #     are other possible errors for which the Timeout method will
    #     return true even if the deadline has not been exceeded.

    #     An idle timeout can be implemented by repeatedly extending
    #     the deadline after successful read or write calls.

    #     A zero value for t means I/O operations will not time out."""
    #     ...

    # fn set_read_deadline(self, t: time.Time) -> Error:
    #     """Sets the deadline for future read calls
    #     and any currently-blocked read call.
    #     A zero value for t means read will not time out."""
    #     ...

    # fn set_write_deadline(self, t: time.Time) -> Error:
    #     """Sets the deadline for future write calls
    #     and any currently-blocked write call.
    #     Even if write times out, it may return n > 0, indicating that
    #     some of the data was successfully written.
    #     A zero value for t means write will not time out."""
    #     ...


@value
struct Connection(Conn):
    """Connection is a concrete generic stream-oriented network connection.
    It is used as the internal connection for structs like TCPConnection.

    Args:
        fd: The file descriptor of the connection.
    """

    var fd: Arc[Socket]

    fn __init__(inout self, owned socket: Socket):
        self.fd = Arc(socket^)

    fn read(inout self, inout dest: List[Byte]) -> (Int, Error):
        """Reads data from the underlying file descriptor.

        Args:
            dest: The buffer to read data into.

        Returns:
            The number of bytes read, or an error if one occurred.
        """
        var bytes_written: Int = 0
        var err = Error()
        bytes_written, err = self.fd[].read(dest)
        if err:
            if str(err) != io.EOF:
                return 0, err

        return bytes_written, err

    fn write(inout self, src: List[Byte]) -> (Int, Error):
        """Writes data to the underlying file descriptor.

        Args:
            src: The buffer to read data into.

        Returns:
            The number of bytes written, or an error if one occurred.
        """
        var bytes_read: Int = 0
        var err = Error()
        bytes_read, err = self.fd[].write(src)
        if err:
            return 0, err

        return bytes_read, err

    fn close(inout self) -> Error:
        """Closes the underlying file descriptor.

        Returns:
            An error if one occurred, or None if the file descriptor was closed successfully.
        """
        return self.fd[].close()

    fn local_address(self) -> TCPAddr:
        """Returns the local network address.
        The Addr returned is shared by all invocations of local_address, so do not modify it.
        """
        return self.fd[].local_address

    fn remote_address(self) -> TCPAddr:
        """Returns the remote network address.
        The Addr returned is shared by all invocations of remote_address, so do not modify it.
        """
        return self.fd[].remote_address
