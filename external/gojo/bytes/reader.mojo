from utils import Span
from ..builtins import copy, panic
import ..io


# TODO: Maybe try a non owning reader, but I'm concerned about the lifetime of the buffer.
# Is making it unsafe a good idea? The source data would need to be ensured to outlive the reader by the user.
struct Reader(
    Sized,
    io.Reader,
    io.ReaderAt,
    io.WriterTo,
    io.Seeker,
    io.ByteReader,
    io.ByteScanner,
):
    """A Reader implements the io.Reader, io.ReaderAt, io.WriterTo, io.Seeker,
    io.ByteScanner, and io.RuneScanner Interfaces by reading from
    a bytes pointer. Unlike a `Buffer`, a `Reader` is read-only and supports seeking.

    Examples:
    ```mojo
    from gojo.bytes import reader

    var reader = reader.Reader(buffer=String("Hello, World!").as_bytes())
    var dest = List[UInt8, True](capacity=16)
    _ = reader.read(dest)
    dest.append(0)
    print(String(dest))  # Output: Hello, World!
    ```
    .
    """

    var _data: UnsafePointer[UInt8]
    """The contents of the bytes buffer. Active contents are from buf[off : len(buf)]."""
    var _size: Int
    """The number of bytes stored in the buffer."""
    var _capacity: Int
    """The maximum capacity of the buffer, eg the allocation of self._data."""
    var index: Int
    """Current reading index."""
    var prev_rune: Int
    """Index of previous rune; or < 0."""

    fn __init__(inout self, owned buffer: List[UInt8, True]):
        """Initializes a new `Reader` with the given List buffer.

        Args:
            buffer: The buffer to read from.
        """
        self._capacity = buffer.capacity
        self._size = buffer.size
        self._data = buffer.steal_data()
        self.index = 0
        self.prev_rune = -1

    fn __init__(inout self, text: String):
        """Initializes a new `Reader` with the given String.

        Args:
            text: The String to initialize the `Reader` with.
        """
        var bytes = text.as_bytes()
        self._capacity = bytes.capacity
        self._size = bytes.size
        self._data = bytes.steal_data()
        self.index = 0
        self.prev_rune = -1

    fn __moveinit__(inout self, owned other: Reader):
        self._capacity = other._capacity
        self._size = other._size
        self._data = other._data
        self.index = other.index
        self.prev_rune = other.prev_rune

        other._data = UnsafePointer[UInt8]()
        other._size = 0
        other._capacity = 0
        other.index = 0
        other.prev_rune = -1

    fn __len__(self) -> Int:
        """Returns the number of bytes of the unread portion of the slice."""
        return self._size - int(self.index)

    fn __del__(owned self) -> None:
        """Frees the internal buffer."""
        if self._data:
            self._data.free()

    fn as_bytes_slice(ref [_]self) -> Span[UInt8, __lifetime_of(self)]:
        """Returns the internal data as a Span[UInt8]."""
        return Span[UInt8, __lifetime_of(self)](unsafe_ptr=self._data, len=self._size)

    fn _read(inout self, inout dest: UnsafePointer[UInt8], capacity: Int) -> (Int, Error):
        """Reads from the internal buffer into the destination buffer.

        Args:
            dest: The destination buffer to read into.
            capacity: The capacity of the destination buffer.

        Returns:
            Int: The number of bytes read into dest.
        """
        if self.index >= self._size:
            return 0, io.EOF

        # Copy the data of the internal buffer from offset to len(buf) into the destination buffer at the given index.
        self.prev_rune = -1
        var bytes_to_write = self.as_bytes_slice()[self.index : self._size]
        var bytes_written = copy(dest, bytes_to_write.unsafe_ptr(), len(bytes_to_write))
        self.index += bytes_written

        return bytes_written, Error()

    fn read(inout self, inout dest: List[UInt8, True]) -> (Int, Error):
        """Reads from the internal buffer into the destination buffer.

        Args:
            dest: The destination buffer to read into.

        Returns:
            Int: The number of bytes read into dest.
        """
        var dest_ptr = dest.unsafe_ptr().offset(dest.size)
        var bytes_read: Int
        var err: Error
        bytes_read, err = self._read(dest_ptr, dest.capacity - dest.size)
        dest.size += bytes_read

        return bytes_read, err

    fn _read_at(self, inout dest: Span[UInt8], off: Int, capacity: Int) -> (Int, Error):
        """Reads `len(dest)` bytes into `dest` beginning at byte offset `off`.

        Args:
            dest: The destination buffer to read into.
            off: The offset to start reading from.
            capacity: The capacity of the destination buffer.

        Returns:
            The number of bytes read into dest.
        """
        # cannot modify state - see io.ReaderAt
        if off < 0:
            return 0, Error("bytes.Reader.read_at: negative offset")

        if off >= Int(self._size):
            return 0, io.EOF

        var unread_bytes = self.as_bytes_slice()[off : self._size]
        var bytes_written = copy(dest.unsafe_ptr(), unread_bytes.unsafe_ptr(), len(unread_bytes))
        if bytes_written < len(dest):
            return 0, io.EOF

        return bytes_written, Error()

    fn read_at(self, inout dest: List[UInt8, True], off: Int) -> (Int, Error):
        """Reads `len(dest)` bytes into `dest` beginning at byte offset `off`.

        Args:
            dest: The destination buffer to read into.
            off: The offset to start reading from.

        Returns:
            The number of bytes read into dest.
        """
        var span = Span(dest)
        var bytes_read: Int
        var err: Error
        bytes_read, err = self._read_at(span, off, dest.capacity)
        dest.size += bytes_read

        return bytes_read, err

    fn read_byte(inout self) -> (UInt8, Error):
        """Reads and returns a single byte from the internal buffer."""
        self.prev_rune = -1
        if self.index >= self._size:
            return UInt8(0), io.EOF

        var byte = self._data[self.index]
        self.index += 1
        return byte, Error()

    fn unread_byte(inout self) -> Error:
        """Unreads the last byte read by moving the read position back by one.

        Returns:
            An error if the read position is at the beginning of the buffer.
        """
        if self.index <= 0:
            return Error("bytes.Reader.unread_byte: at beginning of buffer.")
        self.prev_rune = -1
        self.index -= 1

        return Error()

    # # read_rune implements the [io.RuneReader] Interface.
    # fn read_rune(self) (ch rune, size Int, err error):
    #     if self.index >= Int(self._size):
    #         self.prev_rune = -1
    #         return 0, 0, io.EOF

    #     self.prev_rune = Int(self.index)
    #     if c := self.buffer[self.index]; c < utf8.RuneSelf:
    #         self.index+= 1
    #         return rune(c), 1, nil

    #     ch, size = utf8.DecodeRune(self.buffer[self.index:])
    #     self.index += Int(size)
    #     return

    # # unread_rune complements [Reader.read_rune] in implementing the [io.RuneScanner] Interface.
    # fn unread_rune(self) error:
    #     if self.index <= 0:
    #         return errors.New("bytes.Reader.unread_rune: at beginning of slice")

    #     if self.prev_rune < 0:
    #         return errors.New("bytes.Reader.unread_rune: previous operation was not read_rune")

    #     self.index = Int(self.prev_rune)
    #     self.prev_rune = -1
    #     return nil

    fn seek(inout self, offset: Int, whence: Int) -> (Int, Error):
        """Moves the read position to the specified `offset` from the specified `whence`.

        Args:
            offset: The offset to move to.
            whence: The reference point for offset.

        Returns:
            The new position in which the next read will start from.
        """
        self.prev_rune = -1
        var position: Int = 0

        if whence == io.SEEK_START:
            position = offset
        elif whence == io.SEEK_CURRENT:
            position = self.index + offset
        elif whence == io.SEEK_END:
            position = self._size + offset
        else:
            return Int(0), Error("bytes.Reader.seek: invalid whence")

        if position < 0:
            return Int(0), Error("bytes.Reader.seek: negative position")

        self.index = position
        return position, Error()

    fn write_to[W: io.Writer](inout self, inout writer: W) -> (Int, Error):
        """Writes data to `writer` until the buffer is drained or an error occurs.

        Args:
            writer: The writer to write to.

        Returns:
            The number of bytes written and an error if one occurred.
        """
        self.prev_rune = -1
        if self.index >= self._size:
            return 0, Error()

        var bytes = self.as_bytes_slice()[self.index : self._size]
        var write_count: Int
        var err: Error
        write_count, err = writer.write(bytes)
        if write_count > len(bytes):
            panic("bytes.Reader.write_to: invalid Write count")

        self.index += write_count
        if write_count != len(bytes):
            return write_count, io.ERR_SHORT_WRITE

        return write_count, Error()

    fn reset(inout self, owned buffer: List[UInt8, True]) -> None:
        """Resets the `Reader` to be reading from `buffer`.

        Args:
            buffer: The new buffer to read from.
        """
        self._capacity = buffer.capacity
        self._size = buffer.size
        self._data = buffer.steal_data()
        self.index = 0
        self.prev_rune = -1
