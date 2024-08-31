from utils import StringSlice, Span
from memory import memcpy
import ..io
from ..builtins import copy, panic, index_byte


alias SMALL_BUFFER_SIZE: Int = 64
"""Initial allocation minimal capacity."""

alias ReadOp = Int8
"""The ReadOp constants describe the last action performed on
the buffer, so that unread_rune and unread_byte can check for
invalid usage. op_read_runeX constants are chosen such that
converted to Int they correspond to the rune size that was read."""

alias OP_READ: ReadOp = -1
"""Any other read operation."""
alias OP_INVALID: ReadOp = 0
"""Non-read operation."""
alias OP_READ_RUNE1: ReadOp = 1
"""Read rune of size 1."""
alias OP_READ_RUNE2: ReadOp = 2
"""Read rune of size 2."""
alias OP_READ_RUNE3: ReadOp = 3
"""Read rune of size 3."""
alias OP_READ_RUNE4: ReadOp = 4
"""Read rune of size 4."""

alias MAX_INT: Int = 2147483647
alias MIN_READ: Int = 512
"""MIN_READ is the minimum slice size passed to a read call by
[Buffer.read_from]. As long as the [Buffer] has at least MIN_READ bytes beyond
what is required to hold the contents of r, read_from will not grow the
underlying buffer."""

alias ERR_TOO_LARGE = "buffer.Buffer: too large"
"""ERR_TOO_LARGE is passed to panic if memory cannot be allocated to store data in a buffer."""
alias ERR_NEGATIVE_READ = "buffer.Buffer: reader returned negative count from read"
alias ERR_SHORT_WRITE = "short write"


struct Buffer(
    Stringable,
    Sized,
    io.Reader,
    io.Writer,
    io.StringWriter,
    io.ByteWriter,
    io.ByteReader,
):
    """A Buffer is a variable-sized buffer of bytes with Read and Write methods.

    Examples:
    ```mojo
    from gojo.bytes import buffer
    var buf = buffer.Buffer(capacity=16)
    _ = buf.write_string("Hello, World!")

    var dest = List[UInt8, True](capacity=16)
    _ = buf.read(dest)
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
    var offset: Int  #
    """The read/writer offset of the buffer. read at buf[off], write at buf[len(buf)]."""
    var last_read: ReadOp
    """Last read operation, so that unread* can work correctly."""

    fn __init__(inout self, *, capacity: Int = io.BUFFER_SIZE):
        """Creates a new buffer with the specified capacity.

        Args:
            capacity: The initial capacity of the buffer.
        """
        self._capacity = capacity
        self._size = 0
        self._data = UnsafePointer[UInt8]().alloc(capacity)
        self.offset = 0
        self.last_read = OP_INVALID

    fn __init__(inout self, owned buf: List[UInt8, True]):
        """Creates a new buffer with List buffer provided.

        Args:
            buf: The List buffer to initialize the buffer with.
        """
        self._capacity = buf.capacity
        self._size = buf.size
        self._data = buf.steal_data()
        self.offset = 0
        self.last_read = OP_INVALID

    fn __init__(inout self, buf: String):
        """Creates a new buffer with String provided.

        Args:
            buf: The String to initialize the buffer with.
        """
        var bytes = buf.as_bytes()
        self._capacity = bytes.capacity
        self._size = bytes.size
        self._data = bytes.steal_data()
        self.offset = 0
        self.last_read = OP_INVALID

    fn __init__(inout self, *, owned data: UnsafePointer[UInt8], capacity: Int, size: Int):
        """Creates a new buffer with UnsafePointer buffer provided.

        Args:
            data: The List buffer to initialize the buffer with.
            capacity: The initial capacity of the buffer.
            size: The number of bytes stored in the buffer.
        """
        self._capacity = capacity
        self._size = size
        self._data = data
        self.offset = 0
        self.last_read = OP_INVALID

    fn __moveinit__(inout self, owned other: Self):
        self._data = other._data
        self._size = other._size
        self._capacity = other._capacity
        self.offset = other.offset
        self.last_read = other.last_read
        other._data = UnsafePointer[UInt8]()
        other._size = 0
        other._capacity = 0
        other.offset = 0
        other.last_read = OP_INVALID

    fn __del__(owned self):
        if self._data:
            self._data.free()

    fn __len__(self) -> Int:
        """Returns the number of bytes of the unread portion of the buffer. `self._size - self.offset`."""
        return self._size - self.offset

    fn bytes_ptr(self) -> UnsafePointer[UInt8]:
        """Returns a pointer to the beginning of the unread portion of the buffer."""
        return self._data.offset(self.offset)

    fn bytes(self) -> List[UInt8, True]:
        """Returns a list of bytes holding a copy of the unread portion of the buffer."""
        var copy = UnsafePointer[UInt8]().alloc(self._size)
        memcpy(copy, self._data.offset(self.offset), self._size)
        return List[UInt8, True](unsafe_pointer=copy, size=self._size - self.offset, capacity=self._size - self.offset)

    fn as_bytes_slice(ref [_]self) -> Span[UInt8, __lifetime_of(self)]:
        """Returns the internal data as a Span[UInt8]."""
        return Span[UInt8, __lifetime_of(self)](unsafe_ptr=self._data, len=self._size)

    fn as_string_slice(self) -> StringSlice[__lifetime_of(self)]:
        """
        Return a StringSlice view of the data owned by the builder.

        Returns:
          The string representation of the bytes buffer. Returns an empty string if the bytes buffer is empty.
        """
        return StringSlice[__lifetime_of(self)](unsafe_from_utf8_ptr=self._data, len=self._size)

    fn _resize(inout self, capacity: Int) -> None:
        """
        Resizes the string builder buffer.

        Args:
          capacity: The new capacity of the string builder buffer.
        """
        var new_data = UnsafePointer[UInt8]().alloc(capacity)
        memcpy(new_data, self._data, self._size)
        self._data.free()
        self._data = new_data
        self._capacity = capacity

        return None

    fn _resize_if_needed(inout self, bytes_to_add: Int) -> None:
        """Resizes the buffer if the number of bytes to add exceeds the buffer's capacity.

        Args:
            bytes_to_add: The number of bytes to add to the buffer.
        """
        # TODO: Handle the case where new_capacity is greater than MAX_INT. It should panic.
        if bytes_to_add > self._capacity - self._size:
            var new_capacity = int(self._capacity * 2)
            if new_capacity < self._capacity + bytes_to_add:
                new_capacity = self._capacity + bytes_to_add
            self._resize(new_capacity)

    fn __str__(self) -> String:
        """
        Converts the string builder to a string.

        Returns:
          The string representation of the string builder. Returns an empty
          string if the string builder is empty.
        """
        return self.as_string_slice()

    @deprecated("Buffer.render() has been deprecated. Use Buffer.as_string_slice() or call str() instead.")
    fn render(self) -> StringSlice[__lifetime_of(self)]:
        """
        Return a StringSlice view of the data owned by the builder.

        Returns:
          The string representation of the string builder. Returns an empty string if the string builder is empty.
        """
        return self.as_string_slice()

    fn write(inout self, src: Span[UInt8]) -> (Int, Error):
        """
        Appends a byte Span to the buffer.

        Args:
            src: The byte array to append.

        Returns:
            The number of bytes written to the buffer.
        """
        self._resize_if_needed(len(src))

        memcpy(self._data.offset(self._size), src._data, len(src))
        self._size += len(src)

        return len(src), Error()

    fn write_string(inout self, src: String) -> (Int, Error):
        """
        Appends a string to the buffer.

        Args:
            src: The string to append.

        Returns:
            The number of bytes written to the buffer.
        """
        return self.write(src.as_bytes_slice())

    fn write_byte(inout self, byte: UInt8) -> (Int, Error):
        """Appends a byte to the buffer, growing the buffer as needed.
        The returned error is always empty, but is included to match [bufio.Writer]'s
        write_byte. If the buffer becomes too large, write_byte will panic with
        `ERR_TOO_LARGE`.

        Args:
            byte: The byte to write to the buffer.

        Returns:
            The number of bytes written to the buffer.
        """
        self.last_read = OP_INVALID
        self._resize_if_needed(1)
        self._data[self._size] = byte
        self._size += 1

        return 1, Error()

    fn empty(self) -> Bool:
        """Reports whether the unread portion of the buffer is empty."""
        return self._size <= self.offset

    fn reset(inout self) -> None:
        """Resets the buffer to be empty."""
        if self._data:
            self._data.free()
        self._data = UnsafePointer[UInt8]().alloc(self._capacity)
        self._size = 0
        self.offset = 0
        self.last_read = OP_INVALID

    fn _read(inout self, inout dest: UnsafePointer[UInt8], capacity: Int) -> (Int, Error):
        """Reads the next len(dest) bytes from the buffer or until the buffer
        is drained. The return value `bytes_read` is the number of bytes read.

        If the buffer has no data to return, err is `io.EOF` (unless `len(dest)` is zero);
        otherwise it is empty.

        Args:
            dest: The buffer to read into.
            capacity: The capacity of the destination buffer.

        Returns:
            The number of bytes read from the buffer.
        """
        self.last_read = OP_INVALID
        if self.empty():
            # Buffer is empty, reset to recover space.
            self.reset()
            if capacity == 0:
                return 0, Error()
            return 0, io.EOF

        # Copy the data of the internal buffer from offset to len(buf) into the destination buffer at the given index.
        var bytes_to_read = self.as_bytes_slice()[self.offset :]
        var count = min(capacity, len(bytes_to_read))
        var bytes_read = copy(dest, bytes_to_read.unsafe_ptr(), count)
        self.offset += bytes_read

        if bytes_read > 0:
            self.last_read = OP_READ

        return bytes_read, Error()

    fn read(inout self, inout dest: List[UInt8, True]) -> (Int, Error):
        """Reads the next len(dest) bytes from the buffer or until the buffer
        is drained. The return value `bytes_read` is the number of bytes read.

        If the buffer has no data to return, err is `io.EOF` (unless `len(dest)` is zero);
        otherwise it is empty.

        Args:
            dest: The buffer to read into.

        Returns:
            The number of bytes read from the buffer.
        """
        var dest_ptr = dest.unsafe_ptr().offset(dest.size)
        var bytes_read: Int
        var err: Error
        bytes_read, err = self._read(dest_ptr, dest.capacity - dest.size)
        dest.size += bytes_read

        return bytes_read, err

    fn read_byte(inout self) -> (UInt8, Error):
        """Reads and returns the next byte from the buffer. If no byte is available, it returns error `io.EOF`.

        Returns:
            The next byte from the buffer.
        """
        if self.empty():
            # Buffer is empty, reset to recover space.
            self.reset()
            return UInt8(0), io.EOF

        var byte = self._data[self.offset]
        self.offset += 1
        self.last_read = OP_READ

        return byte, Error()

    fn unread_byte(inout self) -> Error:
        """Unreads the last byte returned by the most recent successful read operation that read at least one byte.

        Returns:
            If a write has happened since the last read, the last read returned an error, or if the read read zero
            bytes, `unread_byte` returns an error.
        """
        if self.last_read == OP_INVALID:
            return Error("buffer.Buffer: unread_byte: previous operation was not a successful read")

        self.last_read = OP_INVALID
        if self.offset > 0:
            self.offset -= 1

        return Error()

    fn read_bytes(inout self, delim: UInt8) -> (List[UInt8, True], Error):
        """Reads until the first occurrence of `delim` in the input,
        returning a List copy containing the data up to and including the delimiter.

        If `read_bytes` encounters an error before finding a delimiter,
        it returns the data read before the error and the error itself (often `io.EOF`).
        `read_bytes` returns an error if and only if the returned data does not end in
        `delim`.

        Args:
            delim: The delimiter to read until.

        Returns:
            A list containing the data up to and including the delimiter.
        """
        var slice: Span[UInt8, __lifetime_of(self)]
        var err: Error
        slice, err = self.read_slice(delim)

        var bytes = List[UInt8, True](capacity=len(slice) + 1)
        for byte in slice:
            bytes.append(byte[])

        return bytes, err

    fn read_slice(inout self, delim: UInt8) -> (Span[UInt8, __lifetime_of(self)], Error):
        """Like `read_bytes` but returns a reference to internal buffer data.

        Args:
            delim: The delimiter to read until.

        Returns:
            A span containing the data up to and including the delimiter.
        """
        var i = index_byte(bytes=self.as_bytes_slice(), delim=delim)
        var end = self.offset + i + 1

        var err = Error()
        if i < 0:
            end = self._size
            err = Error(str(io.EOF))

        var line = self.as_bytes_slice()[self.offset : end]
        self.offset = end
        self.last_read = OP_READ

        return line, err

    fn read_string(inout self, delim: UInt8) -> (String, Error):
        """Reads until the first occurrence of `delim` in the input,
        returning a string containing the data up to and including the delimiter.

        If `read_string` encounters an error before finding a delimiter,
        it returns the data read before the error and the error itself (often `io.EOF`).
        `read_string` returns an error if and only if the returned data does not end
        in `delim`.

        Args:
            delim: The delimiter to read until.

        Returns:
            A string containing the data up to and including the delimiter.
        """
        var bytes: List[UInt8, True]
        var err: Error
        bytes, err = self.read_bytes(delim)
        bytes.append(0)

        return String(bytes^), err

    fn next(inout self, number_of_bytes: Int) -> Span[UInt8, __lifetime_of(self)]:
        """Returns a Span containing the next n bytes from the buffer,
        advancing the buffer as if the bytes had been returned by `Buffer.read`.

        If there are fewer than n bytes in the buffer, `next` returns the entire buffer.

        Args:
            number_of_bytes: The number of bytes to read from the buffer.

        Returns:
            A slice containing the next n bytes from the buffer.
        """
        self.last_read = OP_INVALID
        var bytes_remaining = len(self)
        var bytes_to_read = number_of_bytes
        if bytes_to_read > bytes_remaining:
            bytes_to_read = bytes_remaining

        var data = self.as_bytes_slice()[self.offset : self.offset + bytes_to_read]

        self.offset += bytes_to_read
        if bytes_to_read > 0:
            self.last_read = OP_READ

        return data

    fn write_to[W: io.Writer](inout self, inout writer: W) -> (Int, Error):
        """Writes data to `writer` until the buffer is drained or an error occurs.
        The return value `total_bytes_written` is the number of bytes written; Any error
        encountered during the write is also returned.

        Args:
            writer: The writer to write to.

        Returns:
            The number of bytes written to the writer.
        """
        self.last_read = OP_INVALID
        var bytes_to_write = len(self)
        var total_bytes_written: Int = 0

        if bytes_to_write > 0:
            var bytes_written: Int
            var err: Error
            bytes_written, err = writer.write(self.as_bytes_slice()[self.offset :])
            if bytes_written > bytes_to_write:
                panic("bytes.Buffer.write_to: invalid write count")

            self.offset += bytes_written
            total_bytes_written = bytes_written
            if err:
                return total_bytes_written, err

            # all bytes should have been written, by definition of write method in io.Writer
            if bytes_written != bytes_to_write:
                return total_bytes_written, Error(ERR_SHORT_WRITE)

        # Buffer is now empty; reset.
        self.reset()
        return total_bytes_written, Error()
