from utils import Span
import ..io
from ..builtins import copy, panic
from ..builtins.bytes import index_byte
from ..strings import StringBuilder


# buffered input
struct Reader[R: io.Reader](Sized, io.Reader, io.ByteReader, io.ByteScanner, io.WriterTo):
    """Implements buffering for an io.Reader object.

    Examples:
    ```mojo
    import gojo.bytes
    import gojo.bufio
    var buf = bytes.Buffer(capacity=16)
    _ = buf.write_string("Hello, World!")
    var reader = bufio.Reader(buf^)

    var dest = List[UInt8, True](capacity=16)
    _ = reader.read(dest)
    dest.append(0)
    print(String(dest))  # Output: Hello, World!
    ```
    """

    var buf: List[UInt8, True]
    """Internal buffer."""
    var reader: R
    """Reader provided by the client."""
    var read_pos: Int
    """Buffer read position."""
    var write_pos: Int
    """Buffer write position."""
    var last_byte: Int
    """Last byte read for unread_byte; -1 means invalid."""
    var last_rune_size: Int
    """Size of last rune read for unread_rune; -1 means invalid."""
    var err: Error
    """Error encountered during reading."""
    var initial_capacity: Int
    """Initial internal buffer capacity, used when resetting to it's initial state."""

    fn __init__(
        inout self,
        owned reader: R,
        *,
        capacity: Int = io.BUFFER_SIZE,
        read_pos: Int = 0,
        write_pos: Int = 0,
        last_byte: Int = -1,
        last_rune_size: Int = -1,
    ):
        """Initializes a new buffered reader with the provided reader and buffer capacity.

        Args:
            reader: The reader to buffer.
            capacity: The initial buffer capacity.
            read_pos: The buffer read position.
            write_pos: The buffer write position.
            last_byte: The last byte read for unread_byte; -1 means invalid.
            last_rune_size: The size of the last rune read for unread_rune; -1 means invalid.
        """
        self.initial_capacity = capacity
        self.buf = List[UInt8, True](capacity=capacity)
        self.reader = reader^
        self.read_pos = read_pos
        self.write_pos = write_pos
        self.last_byte = last_byte
        self.last_rune_size = last_rune_size
        self.err = Error()

    fn __moveinit__(inout self, owned existing: Self):
        self.initial_capacity = existing.initial_capacity
        self.buf = existing.buf^
        self.reader = existing.reader^
        self.read_pos = existing.read_pos
        self.write_pos = existing.write_pos
        self.last_byte = existing.last_byte
        self.last_rune_size = existing.last_rune_size
        self.err = existing.err^

    fn __len__(self) -> Int:
        """Returns the size of the underlying buffer in bytes."""
        return len(self.buf)

    # reset discards any buffered data, resets all state, and switches
    # the buffered reader to read from r.
    # Calling reset on the zero value of [Reader] initializes the internal buffer
    # to the default size.
    # Calling self.reset(b) (that is, resetting a [Reader] to itself) does nothing.
    # fn reset[R: io.Reader](self, reader: R):
    #     # If a Reader r is passed to NewReader, NewReader will return r.
    #     # Different layers of code may do that, and then later pass r
    #     # to reset. Avoid infinite recursion in that case.
    #     if self == reader:
    #         return

    #     # if self.buf == nil:
    #     #     self.buf = make(InlineList[UInt8, io.BUFFER_SIZE], io.BUFFER_SIZE)

    #     self.reset(self.buf, r)

    fn as_bytes_slice(ref [_]self) -> Span[UInt8, __lifetime_of(self)]:
        """Returns the internal data as a Span[UInt8]."""
        return Span[UInt8, __lifetime_of(self)](self.buf)

    fn reset(inout self, owned reader: R) -> None:
        """Discards any buffered data, resets all state, and switches
        the buffered reader to read from `reader`. Calling reset on the `Reader` returns the internal buffer to the default size.

        Args:
            reader: The reader to buffer.
        """
        self = Reader[R](
            reader=reader^,
            last_byte=-1,
            last_rune_size=-1,
        )

    fn fill(inout self) -> None:
        """Reads a new chunk into the internal buffer from the reader."""
        # Slide existing data to beginning.
        if self.read_pos > 0:
            var data_to_slide = self.as_bytes_slice()[self.read_pos : self.write_pos]
            for i in range(len(data_to_slide)):
                self.buf[i] = data_to_slide[i]

            self.write_pos -= self.read_pos
            self.read_pos = 0

        # Compares to the capacity of the internal buffer.
        # IE. var b = List[UInt8, True](capacity=4096), then trying to write at b[4096] and onwards will fail.
        if self.write_pos >= self.buf.capacity:
            panic("bufio.Reader: tried to fill full buffer")

        # Read new data: try a limited number of times.
        var i: Int = MAX_CONSECUTIVE_EMPTY_READS
        while i > 0:
            var dest_ptr = self.buf.unsafe_ptr().offset(self.buf.size)
            var bytes_read: Int
            var err: Error
            bytes_read, err = self.reader._read(dest_ptr, self.buf.capacity - self.buf.size)
            if bytes_read < 0:
                panic(ERR_NEGATIVE_READ)

            self.buf.size += bytes_read
            self.write_pos += bytes_read

            if err:
                self.err = err
                return

            if bytes_read > 0:
                return

            i -= 1

        self.err = Error(str(io.ERR_NO_PROGRESS))

    fn read_error(inout self) -> Error:
        """Returns the error encountered during reading."""
        if not self.err:
            return Error()

        var err = self.err
        self.err = Error()
        return err

    fn peek(inout self, number_of_bytes: Int) -> (Span[UInt8, __lifetime_of(self)], Error):
        """Returns the next `number_of_bytes` bytes without advancing the reader. The bytes stop
        being valid at the next read call. If `peek` returns fewer than `number_of_bytes` bytes, it
        also returns an error explaining why the read is short. The error is
        `ERR_BUFFER_FULL` if `number_of_bytes` is larger than the internal buffer's capacity.

        Calling `peek` prevents a `Reader.unread_byte` or `Reader.unread_rune` call from succeeding
        until the next read operation.

        Args:
            number_of_bytes: The number of bytes to peek.

        Returns:
            A reference to the bytes in the internal buffer, and an error if one occurred.
        """
        if number_of_bytes < 0:
            return self.as_bytes_slice()[0:0], Error(ERR_NEGATIVE_COUNT)

        self.last_byte = -1
        self.last_rune_size = -1

        while self.write_pos - self.read_pos < number_of_bytes and self.write_pos - self.read_pos < self.buf.capacity:
            self.fill()  # self.write_pos-self.read_pos < self.capacity => buffer is not full

        if number_of_bytes > self.buf.size:
            return self.as_bytes_slice()[self.read_pos : self.write_pos], Error(ERR_BUFFER_FULL)

        # 0 <= n <= self.buf.size
        var err = Error()
        var available_space = self.write_pos - self.read_pos
        if available_space < number_of_bytes:
            # not enough data in buffer
            err = self.read_error()
            if not err:
                err = Error(ERR_BUFFER_FULL)

        return self.as_bytes_slice()[self.read_pos : self.read_pos + number_of_bytes], err

    fn discard(inout self, number_of_bytes: Int) -> (Int, Error):
        """Skips the next `number_of_bytes` bytes.

        If fewer than `number_of_bytes` bytes are skipped, `discard` returns an error.
        If 0 <= `number_of_bytes` <= `self.buffered()`, `discard` is guaranteed to succeed without
        reading from the underlying `io.Reader`.

        Args:
            number_of_bytes: The number of bytes to skip.

        Returns:
            The number of bytes skipped, and an error if one occurred.
        """
        if number_of_bytes < 0:
            return 0, Error(ERR_NEGATIVE_COUNT)

        if number_of_bytes == 0:
            return 0, Error()

        self.last_byte = -1
        self.last_rune_size = -1

        var remain = number_of_bytes
        while True:
            var skip = self.buffered()
            if skip == 0:
                self.fill()
                skip = self.buffered()

            if skip > remain:
                skip = remain

            self.read_pos += skip
            remain -= skip
            if remain == 0:
                return number_of_bytes, Error()

    fn _read(inout self, inout dest: UnsafePointer[UInt8], capacity: Int) -> (Int, Error):
        """Reads data into `dest`.

        The bytes are taken from at most one `read` on the underlying `io.Reader`,
        hence n may be less than `len(src`).

        To read exactly `len(src)` bytes, use `io.read_full(b, src)`.
        If the underlying `io.Reader` can return a non-zero count with `io.EOF`,
        then this `read` method can do so as well; see the `io.Reader` docs.

        Args:
            dest: The buffer to read data into.
            capacity: The capacity of the destination buffer.

        Returns:
            The number of bytes read into dest.
        """
        if capacity == 0:
            if self.buffered() > 0:
                return 0, Error()
            return 0, self.read_error()

        var bytes_read: Int = 0
        if self.read_pos == self.write_pos:
            if capacity >= len(self.buf):
                # Large read, empty buffer.
                # Read directly into dest to avoid copy.
                var bytes_read: Int
                bytes_read, self.err = self.reader._read(dest, capacity)

                if bytes_read < 0:
                    panic(ERR_NEGATIVE_READ)

                if bytes_read > 0:
                    self.last_byte = int(dest[bytes_read - 1])
                    self.last_rune_size = -1

                return bytes_read, self.read_error()

            # One read.
            # Do not use self.fill, which will loop.
            self.read_pos = 0
            self.write_pos = 0
            var buf = self.buf.unsafe_ptr().offset(self.buf.size)
            var bytes_read: Int
            bytes_read, self.err = self.reader._read(buf, self.buf.capacity - self.buf.size)

            if bytes_read < 0:
                panic(ERR_NEGATIVE_READ)

            if bytes_read == 0:
                return 0, self.read_error()

            self.write_pos += bytes_read

        # copy as much as we can
        var source = self.as_bytes_slice()[self.read_pos : self.write_pos]
        bytes_read = copy(dest, source.unsafe_ptr(), capacity)
        self.read_pos += bytes_read
        self.last_byte = int(self.buf[self.read_pos - 1])
        self.last_rune_size = -1
        return bytes_read, Error()

    fn read(inout self, inout dest: List[UInt8, True]) -> (Int, Error):
        """Reads data into `dest`.

        The bytes are taken from at most one `read` on the underlying `io.Reader`,
        hence n may be less than `len(src`).

        To read exactly `len(src)` bytes, use `io.read_full(b, src)`.
        If the underlying `io.Reader` can return a non-zero count with `io.EOF`,
        then this `read` method can do so as well; see the `io.Reader` docs.

        Args:
            dest: The buffer to read data into.

        Returns:
            The number of bytes read into dest.
        """
        var dest_ptr = dest.unsafe_ptr().offset(dest.size)
        var bytes_read: Int
        var err: Error
        bytes_read, err = self._read(dest_ptr, dest.capacity - dest.size)
        dest.size += bytes_read

        return bytes_read, err

    fn read_byte(inout self) -> (UInt8, Error):
        """Reads and returns a single byte from the internal buffer.

        Returns:
            The byte read from the internal buffer. If no byte is available, returns an error.
        """
        self.last_rune_size = -1
        while self.read_pos == self.write_pos:
            if self.err:
                return UInt8(0), self.read_error()
            self.fill()  # buffer is empty

        var c = self.as_bytes_slice()[self.read_pos]
        self.read_pos += 1
        self.last_byte = int(c)
        return c, Error()

    fn unread_byte(inout self) -> Error:
        """Unreads the last byte. Only the most recently read byte can be unread.

        Returns:
            `unread_byte` returns an error if the most recent method called on the
            `Reader` was not a read operation. Notably, `Reader.peek`, `Reader.discard`, and `Reader.write_to` are not
            considered read operations.
        """
        if self.last_byte < 0 or self.read_pos == 0 and self.write_pos > 0:
            return Error(ERR_INVALID_UNREAD_BYTE)

        # self.read_pos > 0 or self.write_pos == 0
        if self.read_pos > 0:
            self.read_pos -= 1
        else:
            # self.read_pos == 0 and self.write_pos == 0
            self.write_pos = 1

        self.as_bytes_slice()[self.read_pos] = self.last_byte
        self.last_byte = -1
        self.last_rune_size = -1
        return Error()

    # # read_rune reads a single UTF-8 encoded Unicode character and returns the
    # # rune and its size in bytes. If the encoded rune is invalid, it consumes one byte
    # # and returns unicode.ReplacementChar (U+FFFD) with a size of 1.
    # fn read_rune(inout self) (r rune, size int, err error):
    #     for self.read_pos+utf8.UTFMax > self.write_pos and !utf8.FullRune(self.as_bytes_slice()[self.read_pos:self.write_pos]) and self.err == nil and self.write_pos-self.read_pos < self.buf.capacity:
    #         self.fill() # self.write_pos-self.read_pos < len(buf) => buffer is not full

    #     self.last_rune_size = -1
    #     if self.read_pos == self.write_pos:
    #         return 0, 0, self.read_poseadErr()

    #     r, size = rune(self.as_bytes_slice()[self.read_pos]), 1
    #     if r >= utf8.RuneSelf:
    #         r, size = utf8.DecodeRune(self.as_bytes_slice()[self.read_pos:self.write_pos])

    #     self.read_pos += size
    #     self.last_byte = int(self.as_bytes_slice()[self.read_pos-1])
    #     self.last_rune_size = size
    #     return r, size, nil

    # # unread_rune unreads the last rune. If the most recent method called on
    # # the [Reader] was not a [Reader.read_rune], [Reader.unread_rune] returns an error. (In this
    # # regard it is stricter than [Reader.unread_byte], which will unread the last byte
    # # from any read operation.)
    # fn unread_rune() error:
    #     if self.last_rune_size < 0 or self.read_pos < self.last_rune_size:
    #         return ERR_INVALID_UNREAD_RUNE

    #     self.read_pos -= self.last_rune_size
    #     self.last_byte = -1
    #     self.last_rune_size = -1
    #     return nil

    fn buffered(self) -> Int:
        """Returns the number of bytes that can be read from the current buffer.

        Returns:
            The number of bytes that can be read from the current buffer.
        """
        return self.write_pos - self.read_pos

    fn read_slice(inout self, delim: UInt8) -> (Span[UInt8, __lifetime_of(self)], Error):
        """Reads until the first occurrence of `delim` in the input, returning a slice pointing at the bytes in the buffer.
        It includes the first occurrence of the delimiter. The bytes stop being valid at the next read.

        If `read_slice` encounters an error before finding a delimiter, it returns all the data in the buffer and the error itself (often `io.EOF`).
        `read_slice` fails with error `ERR_BUFFER_FULL` if the buffer fills without a `delim`.
        Because the data returned from `read_slice` will be overwritten by the next I/O operation,
        most clients should use `Reader.read_bytes` or `Reader.read_string` instead.
        `read_slice` returns an error if and only if line does not end in delim.

        Args:
            delim: The delimiter to search for.

        Returns:
            A reference to a Span of bytes from the internal buffer.
        """
        var err = Error()
        var s = 0  # search start index
        var line: Span[UInt8, __lifetime_of(self)]
        while True:
            # Search buffer.
            var i = index_byte(self.as_bytes_slice()[self.read_pos + s : self.write_pos], delim)
            if i >= 0:
                i += s
                line = self.as_bytes_slice()[self.read_pos : self.read_pos + i + 1]
                self.read_pos += i + 1
                break

            # Pending error?
            if self.err:
                line = self.as_bytes_slice()[self.read_pos : self.write_pos]
                self.read_pos = self.write_pos
                err = self.read_error()
                break

            # Buffer full?
            if self.buffered() >= self.buf.capacity:
                self.read_pos = self.write_pos
                line = self.as_bytes_slice()
                err = Error(ERR_BUFFER_FULL)
                break

            s = self.write_pos - self.read_pos  # do not rescan area we scanned before
            self.fill()  # buffer is not full

        # Handle last byte, if any.
        var i = len(line) - 1
        if i >= 0:
            self.last_byte = int(line[i])
            self.last_rune_size = -1

        return line, err

    fn read_line(inout self) -> (List[UInt8, True], Bool):
        """Low-level line-reading primitive. Most callers should use
        `Reader.read_bytes('\\n')` or `Reader.read_string]('\\n')` instead or use a `Scanner`.

        `read_line` tries to return a single line, not including the end-of-line bytes.

        The text returned from `read_line` does not include the line end ("\\r\\n" or "\\n").
        No indication or error is given if the input ends without a final line end.
        Calling `Reader.unread_byte` after `read_line` will always unread the last byte read
        (possibly a character belonging to the line end) even if that byte is not
        part of the line returned by `read_line`.
        """
        var line: Span[UInt8, __lifetime_of(self)]
        var err: Error
        line, err = self.read_slice(ord("\n"))

        if err and str(err) == ERR_BUFFER_FULL:
            # Handle the case where "\r\n" straddles the buffer.
            if len(line) > 0 and line[len(line) - 1] == ord("\r"):
                # Put the '\r' back on buf and drop it from line.
                # Let the next call to read_line check for "\r\n".
                if self.read_pos == 0:
                    # should be unreachable
                    panic("bufio: tried to rewind past start of buffer")

                self.read_pos -= 1
                line = line[: len(line) - 1]
            return List[UInt8, True](line), True

        if len(line) == 0:
            return List[UInt8, True](line), False

        if line[len(line) - 1] == ord("\n"):
            var drop = 1
            if len(line) > 1 and line[len(line) - 2] == ord("\r"):
                drop = 2

            line = line[: len(line) - drop]

        return List[UInt8, True](line), False

    fn collect_fragments(
        inout self, delim: UInt8
    ) -> (List[List[UInt8, True]], Span[UInt8, __lifetime_of(self)], Int, Error):
        """Reads until the first occurrence of `delim` in the input. It
        returns (list of full buffers, remaining bytes before `delim`, total number
        of bytes in the combined first two elements, error).

        Args:
            delim: The delimiter to search for.

        Returns:
            List of full buffers, the remaining bytes before `delim`, the total number of bytes in the combined first two elements, and an error if one occurred.
        """
        # Use read_slice to look for delim, accumulating full buffers.
        var err = Error()
        var full_buffers = List[List[UInt8, True]]()
        var total_len = 0
        var frag: Span[UInt8, __lifetime_of(self)]
        while True:
            frag, err = self.read_slice(delim)
            if not err:
                break

            var read_slice_error = err
            if str(read_slice_error) != ERR_BUFFER_FULL:
                err = read_slice_error
                break

            # Make a copy of the buffer Span.
            var buf = List[UInt8, True](frag)
            full_buffers.append(buf)
            total_len += len(buf)

        total_len += len(frag)
        return full_buffers, frag, total_len, err

    fn read_bytes(inout self, delim: UInt8) -> (List[UInt8, True], Error):
        """Reads until the first occurrence of `delim` in the input,
        returning a List containing the data up to and including the delimiter.

        If `read_bytes` encounters an error before finding a delimiter,
        it returns the data read before the error and the error itself (often `io.EOF`).
        `read_bytes` returns an error if and only if the returned data does not end in
        `delim`. For simple uses, a `Scanner` may be more convenient.

        Args:
            delim: The delimiter to search for.

        Returns:
            The a copy of the bytes from the internal buffer as a list.
        """
        var full: List[List[UInt8, True]]
        var frag: Span[UInt8, __lifetime_of(self)]
        var n: Int
        var err: Error
        full, frag, n, err = self.collect_fragments(delim)

        # Allocate new buffer to hold the full pieces and the fragment.
        var buf = List[UInt8, True](capacity=n)
        n = 0

        # copy full pieces and fragment in.
        for i in range(len(full)):
            var buffer = full[i]
            n += copy(buf, buffer, n)

        _ = copy(buf, frag, n)

        return buf, err

    fn read_string(inout self, delim: UInt8) -> (String, Error):
        """Reads until the first occurrence of `delim` in the input,
        returning a string containing the data up to and including the delimiter.

        If `read_string` encounters an error before finding a delimiter,
        it returns the data read before the error and the error itself (often `io.EOF`).
        read_string returns an error if and only if the returned data does not end in
        `delim`. For simple uses, a `Scanner` may be more convenient.

        Args:
            delim: The delimiter to search for.

        Returns:
            A copy of the data from the internal buffer as a String.
        """
        var full: List[List[UInt8, True]]
        var frag: Span[UInt8, __lifetime_of(self)]
        var n: Int
        var err: Error
        full, frag, n, err = self.collect_fragments(delim)

        # Allocate new buffer to hold the full pieces and the fragment.
        var buf = StringBuilder(capacity=n)

        # copy full pieces and fragment in.
        for i in range(len(full)):
            var buffer = full[i]
            _ = buf.write(Span(buffer))

        _ = buf.write(frag)
        return str(buf), err

    fn write_to[W: io.Writer](inout self, inout writer: W) -> (Int, Error):
        """Writes the internal buffer to the writer.
        This may make multiple calls to the `Reader.read` method of the underlying `Reader`.

        Args:
            writer: The writer to write to.

        Returns:
            The number of bytes written.
        """
        self.last_byte = -1
        self.last_rune_size = -1

        var bytes_written: Int
        var err: Error
        bytes_written, err = self.write_buf(writer)
        if err:
            return bytes_written, err

        # internal buffer not full, fill before writing to writer
        if (self.write_pos - self.read_pos) < self.buf.capacity:
            self.fill()

        while self.read_pos < self.write_pos:
            # self.read_pos < self.write_pos => buffer is not empty
            var bw: Int
            var err: Error
            bw, err = self.write_buf(writer)
            bytes_written += bw

            self.fill()  # buffer is empty

        return bytes_written, Error()

    fn write_buf[W: io.Writer](inout self, inout writer: W) -> (Int, Error):
        """Writes the `Reader`'s buffer to the `writer`.

        Args:
            writer: The writer to write to.

        Returns:
            The number of bytes written.
        """
        # Nothing to write
        if self.read_pos == self.write_pos:
            return Int(0), Error()

        # Write the buffer to the writer, if we hit EOF it's fine. That's not a failure condition.
        var bytes_written: Int
        var err: Error
        var buf_to_write = self.as_bytes_slice()[self.read_pos : self.write_pos]
        bytes_written, err = writer.write(List[UInt8, True](buf_to_write))
        if err:
            return bytes_written, err

        if bytes_written < 0:
            panic(ERR_NEGATIVE_WRITE)

        self.read_pos += bytes_written
        return Int(bytes_written), Error()
