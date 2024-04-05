import ..io
from collections.optional import Optional
from ..builtins import Byte, copy, Result, panic, WrappedError


@value
struct Reader(
    Sized, io.Reader, io.ReaderAt, io.ByteReader, io.ByteScanner, io.Seeker, io.WriterTo
):
    """A Reader that implements the [io.Reader], [io.ReaderAt], [io.ByteReader], [io.ByteScanner], [io.Seeker], and [io.WriterTo] traits
    by reading from a string. The zero value for Reader operates like a Reader of an empty string.
    """

    var string: String
    var read_pos: Int64  # current reading index
    var prev_rune: Int  # index of previous rune; or < 0

    fn __init__(inout self, string: String = ""):
        self.string = string
        self.read_pos = 0
        self.prev_rune = -1

    fn __len__(self) -> Int:
        """Returns the number of bytes of the unread portion of the string.

        Returns:
            int: the number of bytes of the unread portion of the string.
        """
        if self.read_pos >= Int64(len(self.string)):
            return 0

        return int(Int64(len(self.string)) - self.read_pos)

    fn size(self) -> Int64:
        """Returns the original length of the underlying string.
        size is the number of bytes available for reading via [Reader.read_at].
        The returned value is always the same and is not affected by calls
        to any other method.

        Returns:
            The original length of the underlying string.
        """
        return Int64(len(self.string))

    fn read(inout self, inout dest: List[Byte]) -> Result[Int]:
        """Reads from the underlying string into the provided List[Byte] object.
        Implements the [io.Reader] trait.

        Args:
            dest: The destination List[Byte] object to read into.

        Returns:
            The number of bytes read into dest.
        """
        if self.read_pos >= Int64(len(self.string)):
            return Result(0, WrappedError(io.EOF))

        self.prev_rune = -1
        var bytes_written = copy(dest, self.string[int(self.read_pos) :].as_bytes())
        self.read_pos += Int64(bytes_written)
        return bytes_written

    fn read_at(self, inout dest: List[Byte], off: Int64) -> Result[Int]:
        """Reads from the Reader into the dest List[Byte] starting at the offset off.
        It returns the number of bytes read into dest and an error if any.
        Implements the [io.ReaderAt] trait.

        Args:
            dest: The destination List[Byte] object to read into.
            off: The byte offset to start reading from.

        Returns:
            The number of bytes read into dest.
        """
        # cannot modify state - see io.ReaderAt
        if off < 0:
            return Result(0, WrappedError("strings.Reader.read_at: negative offset"))

        if off >= Int64(len(self.string)):
            return Result(0, WrappedError(io.EOF))

        var error: Optional[WrappedError] = None
        var copied_elements_count = copy(dest, self.string[int(off) :].as_bytes())
        if copied_elements_count < len(dest):
            error = WrappedError(io.EOF)

        return copied_elements_count

    fn read_byte(inout self) -> Result[Byte]:
        """Reads the next byte from the underlying string.
        Implements the [io.ByteReader] trait.

        Returns:
            The next byte from the underlying string.
        """
        self.prev_rune = -1
        if self.read_pos >= Int64(len(self.string)):
            return Result(Byte(0), WrappedError(io.EOF))

        var b = self.string[int(self.read_pos)]
        self.read_pos += 1
        return Result(Byte(ord(b)), None)

    fn unread_byte(inout self) -> Optional[WrappedError]:
        """Unreads the last byte read. Only the most recent byte read can be unread.
        Implements the [io.ByteScanner] trait.
        """
        if self.read_pos <= 0:
            return WrappedError("strings.Reader.unread_byte: at beginning of string")

        self.prev_rune = -1
        self.read_pos -= 1

        return None

    # # read_rune implements the [io.RuneReader] trait.
    # fn read_rune() (ch rune, size int, err error):
    #     if self.read_pos >= Int64(len(self.string)):
    #         self.prev_rune = -1
    #         return 0, 0, io.EOF

    #     self.prev_rune = int(self.read_pos)
    #     if c = self.string[self.read_pos]; c < utf8.RuneSelf:
    #         self.read_pos += 1
    #         return rune(c), 1, nil

    #     ch, size = utf8.DecodeRuneInString(self.string[self.read_pos:])
    #     self.read_pos += Int64(size)
    #     return

    # # unread_rune implements the [io.RuneScanner] trait.
    # fn unread_rune() error:
    #     if self.read_pos <= 0:
    #         return errors.New("strings.Reader.unread_rune: at beginning of string")

    #     if self.prev_rune < 0:
    #         return errors.New("strings.Reader.unread_rune: previous operation was not read_rune")

    #     self.read_pos = Int64(self.prev_rune)
    #     self.prev_rune = -1
    #     return nil

    fn seek(inout self, offset: Int64, whence: Int) -> Result[Int64]:
        """Seeks to a new position in the underlying string. The next read will start from that position.
        Implements the [io.Seeker] trait.

        Args:
            offset: The offset to seek to.
            whence: The seek mode. It can be one of [io.SEEK_START], [io.SEEK_CURRENT], or [io.SEEK_END].

        Returns:
            The new position in the string.
        """
        self.prev_rune = -1
        var position: Int64 = 0

        if whence == io.SEEK_START:
            position = offset
        elif whence == io.SEEK_CURRENT:
            position = self.read_pos + offset
        elif whence == io.SEEK_END:
            position = Int64(len(self.string)) + offset
        else:
            return Result(Int64(0), WrappedError("strings.Reader.seek: invalid whence"))

        if position < 0:
            return Result(
                Int64(0), WrappedError("strings.Reader.seek: negative position")
            )

        self.read_pos = position
        return position

    fn write_to[W: io.Writer](inout self, inout writer: W) -> Result[Int64]:
        """Writes the remaining portion of the underlying string to the provided writer.
        Implements the [io.WriterTo] trait.

        Args:
            writer: The writer to write the remaining portion of the string to.

        Returns:
            The number of bytes written to the writer.
        """
        self.prev_rune = -1
        if self.read_pos >= Int64(len(self.string)):
            return Result(Int64(0), None)

        var chunk_to_write = self.string[int(self.read_pos) :]
        var result = io.write_string(writer, chunk_to_write)
        var bytes_written = result.value
        if bytes_written > len(chunk_to_write):
            panic("strings.Reader.write_to: invalid write_string count")

        var error: Optional[WrappedError] = None
        self.read_pos += Int64(bytes_written)
        if bytes_written != len(chunk_to_write) and result.has_error():
            error = WrappedError(io.ERR_SHORT_WRITE)

        return Result(Int64(bytes_written), error)

    # TODO: How can I differentiate between the two write_to methods when the writer implements both traits?
    # fn write_to[W: io.StringWriter](inout self, inout writer: W) raises -> Int64:
    #     """Writes the remaining portion of the underlying string to the provided writer.
    #     Implements the [io.WriterTo] trait.

    #     Args:
    #         writer: The writer to write the remaining portion of the string to.

    #     Returns:
    #         The number of bytes written to the writer.
    #     """
    #     self.prev_rune = -1
    #     if self.read_pos >= Int64(len(self.string)):
    #         return 0

    #     var chunk_to_write = self.string[self.read_pos:]
    #     var bytes_written = io.write_string(writer, chunk_to_write)
    #     if bytes_written > len(chunk_to_write):
    #         raise Error("strings.Reader.write_to: invalid write_string count")

    #     self.read_pos += Int64(bytes_written)
    #     if bytes_written != len(chunk_to_write):
    #         raise Error(io.ERR_SHORT_WRITE)

    #     return Int64(bytes_written)

    fn reset(inout self, string: String):
        """Resets the [Reader] to be reading from the beginning of the provided string.

        Args:
            string: The string to read from.
        """
        self.string = string
        self.read_pos = 0
        self.prev_rune = -1


fn new_reader(string: String = "") -> Reader:
    """Returns a new [Reader] reading from the provided string.
    It is similar to [bytes.new_buffer] but more efficient and non-writable.

    Args:
        string: The string to read from.
    """
    return Reader(string)
