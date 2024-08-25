import ..io
from sys import external_call


@value
struct STDWriter[file_descriptor: Int](Copyable, io.Writer, io.StringWriter):
    """A writer for POSIX file descriptors."""

    fn __init__(inout self):
        constrained[
            file_descriptor == 1 or file_descriptor == 2,
            "The STDWriter Struct is meant to write to STDOUT and STDERR. file_descriptor must be 1 or 2.",
        ]()

    fn write(inout self, src: Span[UInt8]) -> (Int, Error):
        """Writes the given bytes to the file descriptor.

        Args:
            src: The bytes to write to the file descriptor.

        Returns:
            The number of bytes written to the file descriptor.
        """
        var write_count: Int = external_call["write", Int, Int32, UnsafePointer[UInt8], Int](
            file_descriptor, src.unsafe_ptr(), len(src)
        )

        if write_count == -1:
            return 0, Error("Failed to write to file descriptor " + str(file_descriptor))

        return write_count, Error()

    fn write_string(inout self, src: String) -> (Int, Error):
        """Writes the given string to the file descriptor.

        Args:
            src: The string to write to the file descriptor.

        Returns:
            The number of bytes written to the file descriptor.
        """
        return self.write(src.as_bytes_slice())

    fn read_from[R: io.Reader](inout self, inout reader: R) -> (Int, Error):
        """Reads from the given reader to a temporary buffer and writes to the file descriptor.

        Args:
            reader: The reader to read from.

        Returns:
            The number of bytes written to the file descriptor.
        """
        var buffer = List[UInt8](capacity=io.BUFFER_SIZE)
        _ = reader.read(buffer)
        return self.write(Span(buffer))
