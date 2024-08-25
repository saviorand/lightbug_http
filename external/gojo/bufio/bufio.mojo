from collections import InlineList
from utils import Span
import ..io
from ..builtins import copy, panic
from ..builtins.bytes import index_byte
from ..strings import StringBuilder

alias MIN_READ_BUFFER_SIZE = 16
alias MAX_CONSECUTIVE_EMPTY_READS = 100

alias ERR_INVALID_UNREAD_BYTE = "bufio: invalid use of unread_byte"
alias ERR_INVALID_UNREAD_RUNE = "bufio: invalid use of unread_rune"
alias ERR_BUFFER_FULL = "bufio: buffer full"
alias ERR_NEGATIVE_COUNT = "bufio: negative count"
alias ERR_NEGATIVE_READ = "bufio: reader returned negative count from Read"
alias ERR_NEGATIVE_WRITE = "bufio: writer returned negative count from write"


# buffered input
# TODO: Uncomment write_to and write_buf once the bug with the trait's Span argument is fixed.
struct Reader[R: io.Reader](Sized, io.Reader, io.ByteReader, io.ByteScanner):
    """Implements buffering for an io.Reader object."""

    var buf: List[UInt8]
    var reader: R  # reader provided by the client
    var read_pos: Int
    var write_pos: Int  # buf read and write positions
    var last_byte: Int  # last byte read for unread_byte; -1 means invalid
    var last_rune_size: Int  # size of last rune read for unread_rune; -1 means invalid
    var err: Error

    fn __init__(
        inout self,
        owned reader: R,
        capacity: Int = io.BUFFER_SIZE,
        read_pos: Int = 0,
        write_pos: Int = 0,
        last_byte: Int = -1,
        last_rune_size: Int = -1,
    ):
        self.buf = List[UInt8](capacity=capacity)
        self.reader = reader^
        self.read_pos = read_pos
        self.write_pos = write_pos
        self.last_byte = last_byte
        self.last_rune_size = last_rune_size
        self.err = Error()

    fn __moveinit__(inout self, owned existing: Self):
        self.buf = existing.buf^
        self.reader = existing.reader^
        self.read_pos = existing.read_pos
        self.write_pos = existing.write_pos
        self.last_byte = existing.last_byte
        self.last_rune_size = existing.last_rune_size
        self.err = existing.err^

    # size returns the size of the underlying buffer in bytes.
    fn __len__(self) -> Int:
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

    fn reset(inout self, owned reader: R):
        """Discards any buffered data, resets all state, and switches
        the buffered reader to read from r.
        Calling reset on the zero value of [Reader] initializes the internal buffer
        to the default size.
        Calling self.reset(b) (that is, resetting a [Reader] to itself) does nothing."""
        self = Reader[R](
            reader=reader^,
            last_byte=-1,
            last_rune_size=-1,
        )

    fn fill(inout self):
        """Reads a new chunk into the buffer."""
        # Slide existing data to beginning.
        if self.read_pos > 0:
            var data_to_slide = self.as_bytes_slice()[self.read_pos : self.write_pos]
            # TODO: Temp copying of elements until I figure out a better pattern or slice refs are added
            for i in range(len(data_to_slide)):
                self.buf[i] = data_to_slide[i]

            # self.buf.reserve(current_capacity)
            self.write_pos -= self.read_pos
            self.read_pos = 0

        # Compares to the length of the entire InlineList[UInt8, io.BUFFER_SIZE] object, including 0 initialized positions.
        # IE. var b = InlineList[UInt8, io.BUFFER_SIZE](capacity=4096), then trying to write at b[4096] and onwards will fail.
        if self.write_pos >= io.BUFFER_SIZE:
            panic("bufio.Reader: tried to fill full buffer")

        # Read new data: try a limited number of times.
        var i: Int = MAX_CONSECUTIVE_EMPTY_READS
        while i > 0:
            # var span = self.as_bytes_slice()
            var bytes_read: Int
            var err: Error
            bytes_read, err = self.reader.read(self.buf)
            if bytes_read < 0:
                panic(ERR_NEGATIVE_READ)

            self.write_pos += bytes_read

            if err:
                self.err = err
                return

            if bytes_read > 0:
                return

            i -= 1

        self.err = Error(str(io.ERR_NO_PROGRESS))

    fn read_error(inout self) -> Error:
        if not self.err:
            return Error()

        var err = self.err
        self.err = Error()
        return err

    fn peek(inout self, number_of_bytes: Int) -> (Span[UInt8, __lifetime_of(self)], Error):
        """Returns the next n bytes without advancing the reader. The bytes stop
        being valid at the next read call. If Peek returns fewer than n bytes, it
        also returns an error explaining why the read is short. The error is
        [ERR_BUFFER_FULL] if number_of_bytes is larger than b's buffer size.

        Calling Peek prevents a [Reader.unread_byte] or [Reader.unread_rune] call from succeeding
        until the next read operation.

        Args:
            number_of_bytes: The number of bytes to peek.
        """
        if number_of_bytes < 0:
            return self.as_bytes_slice()[0:0], Error(ERR_NEGATIVE_COUNT)

        self.last_byte = -1
        self.last_rune_size = -1

        while self.write_pos - self.read_pos < number_of_bytes and self.write_pos - self.read_pos < io.BUFFER_SIZE:
            self.fill()  # self.write_pos-self.read_pos < self.capacity => buffer is not full

        if number_of_bytes > io.BUFFER_SIZE:
            return self.as_bytes_slice()[self.read_pos : self.write_pos], Error(ERR_BUFFER_FULL)

        # 0 <= n <= io.BUFFER_SIZE
        var err = Error()
        var available_space = self.write_pos - self.read_pos
        if available_space < number_of_bytes:
            # not enough data in buffer
            err = self.read_error()
            if not err:
                err = Error(ERR_BUFFER_FULL)

        return self.as_bytes_slice()[self.read_pos : self.read_pos + number_of_bytes], err

    fn discard(inout self, number_of_bytes: Int) -> (Int, Error):
        """Discard skips the next n bytes, returning the number of bytes discarded.

        If Discard skips fewer than n bytes, it also returns an error.
        If 0 <= number_of_bytes <= self.buffered(), Discard is guaranteed to succeed without
        reading from the underlying io.Reader.
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

    fn _read(inout self, inout dest: Span[UInt8], capacity: Int) -> (Int, Error):
        """Reads data into dest.
        It returns the number of bytes read into dest.
        The bytes are taken from at most one Read on the underlying [Reader],
        hence n may be less than len(src).
        To read exactly len(src) bytes, use io.ReadFull(b, src).
        If the underlying [Reader] can return a non-zero count with io.EOF,
        then this Read method can do so as well; see the [io.Reader] docs."""
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
            var buf = self.as_bytes_slice()  # TODO: I'm hoping this reads into self.data directly lol
            var bytes_read: Int
            bytes_read, self.err = self.reader._read(buf, len(buf))

            if bytes_read < 0:
                panic(ERR_NEGATIVE_READ)

            if bytes_read == 0:
                return 0, self.read_error()

            self.write_pos += bytes_read

        # copy as much as we can
        var source = self.as_bytes_slice()[self.read_pos : self.write_pos]
        bytes_read = 0
        var start = len(dest)
        var target = dest.unsafe_ptr()
        for i in range(len(source)):
            target[i + start] = source[i]
            bytes_read += 1
        dest._len += bytes_read
        self.read_pos += bytes_read
        self.last_byte = int(self.buf[self.read_pos - 1])
        self.last_rune_size = -1
        return bytes_read, Error()

    fn read(inout self, inout dest: List[UInt8]) -> (Int, Error):
        """Reads data into dest.
        It returns the number of bytes read into dest.
        The bytes are taken from at most one Read on the underlying [Reader],
        hence n may be less than len(src).
        To read exactly len(src) bytes, use io.ReadFull(b, src).
        If the underlying [Reader] can return a non-zero count with io.EOF,
        then this Read method can do so as well; see the [io.Reader] docs."""

        var span = Span(dest)

        var bytes_read: Int
        var err: Error
        bytes_read, err = self._read(span, dest.capacity)
        dest.size += bytes_read

        return bytes_read, err

    fn read_byte(inout self) -> (UInt8, Error):
        """Reads and returns a single byte from the internal buffer. If no byte is available, returns an error."""
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

        unread_byte returns an error if the most recent method called on the
        [Reader] was not a read operation. Notably, [Reader.peek], [Reader.discard], and [Reader.write_to] are not
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
        """Reads until the first occurrence of delim in the input,
        returning a slice pointing at the bytes in the buffer. It includes the first occurrence of the delimiter.
        The bytes stop being valid at the next read.
        If read_slice encounters an error before finding a delimiter,
        it returns all the data in the buffer and the error itself (often io.EOF).
        read_slice fails with error [ERR_BUFFER_FULL] if the buffer fills without a delim.
        Because the data returned from read_slice will be overwritten
        by the next I/O operation, most clients should use
        [Reader.read_bytes] or read_string instead.
        read_slice returns err != nil if and only if line does not end in delim.

        Args:
            delim: The delimiter to search for.

        Returns:
            The Span[UInt8] from the internal buffer.
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
            if self.buffered() >= io.BUFFER_SIZE:
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

    fn read_line(inout self: Self) -> (List[UInt8], Bool):
        """Low-level line-reading primitive. Most callers should use
        [Reader.read_bytes]('\n') or [Reader.read_string]('\n') instead or use a [Scanner].

        read_line tries to return a single line, not including the end-of-line bytes.
        If the line was too long for the buffer then isPrefix is set and the
        beginning of the line is returned. The rest of the line will be returned
        from future calls. isPrefix will be false when returning the last fragment
        of the line. The returned buffer is only valid until the next call to
        read_line. read_line either returns a non-nil line or it returns an error,
        never both.

        The text returned from read_line does not include the line end ("\r\n" or "\n").
        No indication or error is given if the input ends without a final line end.
        Calling [Reader.unread_byte] after read_line will always unread the last byte read
        (possibly a character belonging to the line end) even if that byte is not
        part of the line returned by read_line.
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
            return List[UInt8](line), True

        if len(line) == 0:
            return List[UInt8](line), False

        if line[len(line) - 1] == ord("\n"):
            var drop = 1
            if len(line) > 1 and line[len(line) - 2] == ord("\r"):
                drop = 2

            line = line[: len(line) - drop]

        return List[UInt8](line), False

    fn collect_fragments(inout self, delim: UInt8) -> (List[List[UInt8]], Span[UInt8, __lifetime_of(self)], Int, Error):
        """Reads until the first occurrence of delim in the input. It
        returns (slice of full buffers, remaining bytes before delim, total number
        of bytes in the combined first two elements, error).

        Args:
            delim: The delimiter to search for.
        """
        # Use read_slice to look for delim, accumulating full buffers.
        var err = Error()
        var full_buffers = List[List[UInt8]]()
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
            var buf = List[UInt8](frag)
            full_buffers.append(buf)
            total_len += len(buf)

        total_len += len(frag)
        return full_buffers, frag, total_len, err

    fn read_bytes(inout self, delim: UInt8) -> (List[UInt8], Error):
        """Reads until the first occurrence of delim in the input,
        returning a slice containing the data up to and including the delimiter.
        If read_bytes encounters an error before finding a delimiter,
        it returns the data read before the error and the error itself (often io.EOF).
        read_bytes returns err != nil if and only if the returned data does not end in
        delim.
        For simple uses, a Scanner may be more convenient.

        Args:
            delim: The delimiter to search for.

        Returns:
            The List[UInt8] from the internal buffer.
        """
        var full: List[List[UInt8]]
        var frag: Span[UInt8, __lifetime_of(self)]
        var n: Int
        var err: Error
        full, frag, n, err = self.collect_fragments(delim)

        # Allocate new buffer to hold the full pieces and the fragment.
        var buf = List[UInt8](capacity=n)
        n = 0

        # copy full pieces and fragment in.
        for i in range(len(full)):
            var buffer = full[i]
            n += copy(buf, buffer, n)

        _ = copy(buf, frag, n)

        return buf, err

    fn read_string(inout self, delim: UInt8) -> (String, Error):
        """Reads until the first occurrence of delim in the input,
        returning a string containing the data up to and including the delimiter.
        If read_string encounters an error before finding a delimiter,
        it returns the data read before the error and the error itself (often io.EOF).
        read_string returns err != nil if and only if the returned data does not end in
        delim.
        For simple uses, a Scanner may be more convenient.

        Args:
            delim: The delimiter to search for.

        Returns:
            The String from the internal buffer.
        """
        var full: List[List[UInt8]]
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

    # fn write_to[W: io.Writer](inout self, inout writer: W) -> (Int, Error):
    #     """Writes the internal buffer to the writer. This may make multiple calls to the [Reader.Read] method of the underlying [Reader].
    #     If the underlying reader supports the [Reader.WriteTo] method,
    #     this calls the underlying [Reader.WriteTo] without buffering.
    #     write_to implements io.WriterTo.

    #     Args:
    #         writer: The writer to write to.

    #     Returns:
    #         The number of bytes written.
    #     """
    #     self.last_byte = -1
    #     self.last_rune_size = -1

    #     var bytes_written: Int
    #     var err: Error
    #     bytes_written, err = self.write_buf(writer)
    #     if err:
    #         return bytes_written, err

    #     # internal buffer not full, fill before writing to writer
    #     if (self.write_pos - self.read_pos) < io.BUFFER_SIZE:
    #         self.fill()

    #     while self.read_pos < self.write_pos:
    #         # self.read_pos < self.write_pos => buffer is not empty
    #         var bw: Int
    #         var err: Error
    #         bw, err = self.write_buf(writer)
    #         bytes_written += bw

    #         self.fill()  # buffer is empty

    #     return bytes_written, Error()

    # fn write_buf[W: io.Writer](inout self, inout writer: W) -> (Int, Error):
    #     """Writes the [Reader]'s buffer to the writer.

    #     Args:
    #         writer: The writer to write to.

    #     Returns:
    #         The number of bytes written.
    #     """
    #     # Nothing to write
    #     if self.read_pos == self.write_pos:
    #         return Int(0), Error()

    #     # Write the buffer to the writer, if we hit EOF it's fine. That's not a failure condition.
    #     var bytes_written: Int
    #     var err: Error
    #     var buf_to_write = self.as_bytes_slice()[self.read_pos : self.write_pos]
    #     bytes_written, err = writer.write(List[UInt8](buf_to_write))
    #     if err:
    #         return bytes_written, err

    #     if bytes_written < 0:
    #         panic(ERR_NEGATIVE_WRITE)

    #     self.read_pos += bytes_written
    #     return Int(bytes_written), Error()


# buffered output
struct Writer[W: io.Writer](Sized, io.Writer, io.ByteWriter, io.StringWriter, io.ReaderFrom):
    """Implements buffering for an [io.Writer] object.
    # If an error occurs writing to a [Writer], no more data will be
    # accepted and all subsequent writes, and [Writer.flush], will return the error.
    # After all data has been written, the client should call the
    # [Writer.flush] method to guarantee all data has been forwarded to
    # the underlying [io.Writer]."""

    var buf: List[UInt8]
    var bytes_written: Int
    var writer: W
    var err: Error

    fn __init__(
        inout self,
        owned writer: W,
        capacity: Int = io.BUFFER_SIZE,
        bytes_written: Int = 0,
    ):
        self.buf = List[UInt8](capacity=capacity)
        self.bytes_written = bytes_written
        self.writer = writer^
        self.err = Error()

    fn __moveinit__(inout self, owned existing: Self):
        self.buf = existing.buf^
        self.bytes_written = existing.bytes_written
        self.writer = existing.writer^
        self.err = existing.err^

    fn __len__(self) -> Int:
        """Returns the size of the underlying buffer in bytes."""
        return len(self.buf)

    fn as_bytes_slice(ref [_]self) -> Span[UInt8, __lifetime_of(self)]:
        """Returns the internal data as a Span[UInt8]."""
        return Span[UInt8, __lifetime_of(self)](self.buf)

    fn reset(inout self, owned writer: W):
        """Discards any unflushed buffered data, clears any error, and
        resets b to write its output to w.
        Calling reset on the zero value of [Writer] initializes the internal buffer
        to the default size.
        Calling w.reset(w) (that is, resetting a [Writer] to itself) does nothing.

        Args:
            writer: The writer to write to.
        """
        self.err = Error()
        self.bytes_written = 0
        self.writer = writer^

    fn flush(inout self) -> Error:
        """Writes any buffered data to the underlying [io.Writer]."""
        # Prior to attempting to flush, check if there's a pre-existing error or if there's nothing to flush.
        var err = Error()
        if self.err:
            return self.err
        if self.bytes_written == 0:
            return err

        var bytes_written: Int = 0
        bytes_written, err = self.writer.write(self.as_bytes_slice()[0 : self.bytes_written])

        # If the write was short, set a short write error and try to shift up the remaining bytes.
        if bytes_written < self.bytes_written and not err:
            err = Error(str(io.ERR_SHORT_WRITE))

        if err:
            if bytes_written > 0 and bytes_written < self.bytes_written:
                # TODO: Temp copying of elements until I figure out a better pattern or slice refs are added
                var temp = self.as_bytes_slice()[bytes_written : self.bytes_written]
                for i in range(len(temp)):
                    self.buf[i] = temp[i]
                    # if i > len(temp):
                    #     self.buf[i] = temp[i]
                    # else:
                    #     self.buf.append(temp[i])

            self.bytes_written -= bytes_written
            self.err = err
            return err

        # Reset the buffer
        self.buf = List[UInt8](capacity=io.BUFFER_SIZE)
        self.bytes_written = 0
        return err

    fn available(self) -> Int:
        """Returns how many bytes are unused in the buffer."""
        return self.buf.capacity - len(self.buf)

    fn buffered(self) -> Int:
        """Returns the number of bytes that have been written into the current buffer.

        Returns:
            The number of bytes that have been written into the current buffer.
        """
        return self.bytes_written

    fn write(inout self, src: Span[UInt8]) -> (Int, Error):
        """Writes the contents of src into the buffer.
        It returns the number of bytes written.
        If nn < len(src), it also returns an error explaining
        why the write is short.

        Args:
            src: The bytes to write.

        Returns:
            The number of bytes written.
        """
        var total_bytes_written: Int = 0
        var src_copy = src  # TODO: Make a copy, maybe try a non owning Span
        var err = Error()
        while len(src_copy) > self.available() and not self.err:
            var bytes_written: Int = 0
            if self.buffered() == 0:
                # Large write, empty buffer.
                # write directly from p to avoid copy.
                bytes_written, err = self.writer.write(src_copy)
                self.err = err
            else:
                # TODO: Temp copying of elements until I figure out a better pattern or slice refs are added
                for i in range(len(src_copy)):
                    if i + self.bytes_written > len(src_copy):
                        self.buf[i + self.bytes_written] = src_copy[i]
                    else:
                        self.buf.append(src_copy[i])
                    bytes_written += 1

                self.bytes_written += bytes_written
                _ = self.flush()

            total_bytes_written += bytes_written
            src_copy = src_copy[bytes_written : len(src_copy)]

        if self.err:
            return total_bytes_written, self.err

        # TODO: Temp copying of elements until I figure out a better pattern or slice refs are added
        var n = 0
        for i in range(len(src_copy)):
            if i + self.bytes_written > len(src_copy):
                self.buf[i + self.bytes_written] = src_copy[i]
            else:
                self.buf.append(src_copy[i])
            n += 1
        self.bytes_written += n
        total_bytes_written += n
        return total_bytes_written, err

    fn write_byte(inout self, src: UInt8) -> (Int, Error):
        """Writes a single byte to the internal buffer.

        Args:
            src: The byte to write.
        """
        if self.err:
            return 0, self.err
        # If buffer is full, flush to the underlying writer.
        var err = self.flush()
        if self.available() <= 0 and err:
            return 0, self.err

        self.buf.append(src)
        self.bytes_written += 1

        return 1, Error()

    # # WriteRune writes a single Unicode code point, returning
    # # the number of bytes written and any error.
    # fn WriteRune(r rune) (size int, err error):
    #     # Compare as uint32 to correctly handle negative runes.
    #     if uint32(r) < utf8.RuneSelf:
    #         err = self.write_posriteByte(byte(r))
    #         if err != nil:
    #             return 0, err

    #         return 1, nil

    #     if self.err != nil:
    #         return 0, self.err

    #     n := self.available()
    #     if n < utf8.UTFMax:
    #         if self.flush(); self.err != nil:
    #             return 0, self.err

    #         n = self.available()
    #         if n < utf8.UTFMax:
    #             # Can only happen if buffer is silly small.
    #             return self.write_posriteString(string(r))

    #     size = utf8.EncodeRune(self.as_bytes_slice()[self.bytes_written:], r)
    #     self.bytes_written += size
    #     return size, nil

    fn write_string(inout self, src: String) -> (Int, Error):
        """Writes a string to the internal buffer.
        It returns the number of bytes written.
        If the count is less than len(s), it also returns an error explaining
        why the write is short.

        Args:
            src: The string to write.

        Returns:
            The number of bytes written.
        """
        return self.write(src.as_bytes_slice())

    fn read_from[R: io.Reader](inout self, inout reader: R) -> (Int, Error):
        """Implements [io.ReaderFrom]. If the underlying writer
        supports the read_from method, this calls the underlying read_from.
        If there is buffered data and an underlying read_from, this fills
        the buffer and writes it before calling read_from.

        Args:
            reader: The reader to read from.

        Returns:
            The number of bytes read.
        """
        if self.err:
            return 0, self.err

        var bytes_read: Int = 0
        var total_bytes_written: Int = 0
        var err = Error()
        while True:
            if self.available() == 0:
                var err = self.flush()
                if err:
                    return total_bytes_written, err

            var nr = 0
            while nr < MAX_CONSECUTIVE_EMPTY_READS:
                # Read into remaining unused space in the buffer.
                var buf = self.as_bytes_slice()[self.bytes_written : len(self.buf)]
                bytes_read, err = reader._read(buf, self.bytes_written - len(self.buf))

                if bytes_read != 0 or err:
                    break
                nr += 1

            if nr == MAX_CONSECUTIVE_EMPTY_READS:
                return bytes_read, io.ERR_NO_PROGRESS

            self.bytes_written += bytes_read
            total_bytes_written += bytes_read
            if err:
                break

        if err and str(err) == str(io.EOF):
            # If we filled the buffer exactly, flush preemptively.
            if self.available() == 0:
                err = self.flush()
            else:
                err = Error()

        return total_bytes_written, Error()


# buffered input and output
struct ReadWriter[R: io.Reader, W: io.Writer]():
    """ReadWriter stores pointers to a [Reader] and a [Writer].
    It implements [io.ReadWriter]."""

    var reader: R
    var writer: W

    fn __init__(inout self, owned reader: R, owned writer: W):
        self.reader = reader^
        self.writer = writer^
