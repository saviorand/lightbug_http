from ..builtins._bytes import Bytes, Byte

alias Rune = Int32

# Package io provides basic interfaces to I/O primitives.
# Its primary job is to wrap existing implementations of such primitives,
# such as those in package os, into shared public interfaces that
# abstract the fntionality, plus some other related primitives.
#
# Because these interfaces and primitives wrap lower-level operations with
# various implementations, unless otherwise informed clients should not
# assume they are safe for parallel execution.
# Seek whence values.
alias SEEK_START = 0  # seek relative to the origin of the file
alias SEEK_CURRENT = 1  # seek relative to the current offset
alias SEEK_END = 2  # seek relative to the end

# ERR_SHORT_WRITE means that a write accepted fewer bytes than requested
# but failed to return an explicit error.
alias ERR_SHORT_WRITE = "short write"

# ERR_INVALID_WRITE means that a write returned an impossible count.
alias ERR_INVALID_WRITE = "invalid write result"

# ERR_SHORT_BUFFER means that a read required a longer buffer than was provided.
alias ERR_SHORT_BUFFER = "short buffer"

# EOF is the error returned by Read when no more input is available.
# (Read must return EOF itself, not an error wrapping EOF,
# because callers will test for EOF using ==.)
# fntions should return EOF only to signal a graceful end of input.
# If the EOF occurs unexpectedly in a structured data stream,
# the appropriate error is either [ERR_UNEXPECTED_EOF] or some other error
# giving more detail.
alias EOF = "EOF"

# ERR_UNEXPECTED_EOF means that EOF was encountered in the
# middle of reading a fixed-size block or data structure.
alias ERR_UNEXPECTED_EOF = "unexpected EOF"

# ERR_NO_PROGRESS is returned by some clients of a [Reader] when
# many calls to Read have failed to return any data or error,
# usually the sign of a broken [Reader] implementation.
alias ERR_NO_PROGRESS = "multiple Read calls return no data or error"


trait Reader(Movable):
    """Reader is the trait that wraps the basic Read method.

    Read reads up to len(p) bytes into p. It returns the number of bytes
    read (0 <= n <= len(p)) and any error encountered. Even if Read
    returns n < len(p), it may use all of p as scratch space during the call.
    If some data is available but not len(p) bytes, Read conventionally
    returns what is available instead of waiting for more.

    When Read encounters an error or end-of-file condition after
    successfully reading n > 0 bytes, it returns the number of
    bytes read. It may return the (non-nil) error from the same call
    or return the error (and n == 0) from a subsequent call.
    An instance of this general case is that a Reader returning
    a non-zero number of bytes at the end of the input stream may
    return either err == EOF or err == nil. The next Read should
    return 0, EOF.

    Callers should always process the n > 0 bytes returned before
    considering the error err. Doing so correctly handles I/O errors
    that happen after reading some bytes and also both of the
    allowed EOF behaviors.

    If len(p) == 0, Read should always return n == 0. It may return a
    non-nil error if some error condition is known, such as EOF.

    Implementations of Read are discouraged from returning a
    zero byte count with a nil error, except when len(p) == 0.
    Callers should treat a return of 0 and nil as indicating that
    nothing happened; in particular it does not indicate EOF.

    Implementations must not retain p."""

    fn read(inout self, inout dest: Bytes) raises -> Int:
        ...


trait Writer(Movable):
    """Writer is the trait that wraps the basic Write method.

    Write writes len(p) bytes from p to the underlying data stream.
    It returns the number of bytes written from p (0 <= n <= len(p))
    and any error encountered that caused the write to stop early.
    Write must return a non-nil error if it returns n < len(p).
    Write must not modify the slice data, even temporarily.

    Implementations must not retain p.
    """

    fn write(inout self, src: Bytes) raises -> Int:
        ...


trait Closer(Movable):
    """
    Closer is the trait that wraps the basic Close method.

    The behavior of Close after the first call is undefined.
    Specific implementations may document their own behavior.
    """

    fn close(inout self) raises:
        ...


trait Seeker(Movable):
    """
    Seeker is the trait that wraps the basic Seek method.

    Seek sets the offset for the next Read or Write to offset,
    interpreted according to whence:
    [SEEK_START] means relative to the start of the file,
    [SEEK_CURRENT] means relative to the current offset, and
    [SEEK_END] means relative to the end
    (for example, offset = -2 specifies the penultimate byte of the file).
    Seek returns the new offset relative to the start of the
    file or an error, if any.

    Seeking to an offset before the start of the file is an error.
    Seeking to any positive offset may be allowed, but if the new offset exceeds
    the size of the underlying object the behavior of subsequent I/O operations
    is implementation-dependent.
    """

    fn seek(inout self, offset: Int64, whence: Int) raises -> Int64:
        ...


trait ReadWriter(Reader, Writer):
    ...


trait ReadCloser(Reader, Closer):
    ...


trait WriteCloser(Writer, Closer):
    ...


trait ReadWriteCloser(Reader, Writer, Closer):
    ...


trait ReadSeeker(Reader, Seeker):
    ...


trait ReadSeekCloser(Reader, Seeker, Closer):
    ...


trait WriteSeeker(Writer, Seeker):
    ...


trait ReadWriteSeeker(Reader, Writer, Seeker):
    ...


trait ReaderFrom:
    """ReaderFrom is the trait that wraps the ReadFrom method.

    ReadFrom reads data from r until EOF or error.
    The return value n is the number of bytes read.
    Any error except EOF encountered during the read is also returned.

    The [copy] function uses [ReaderFrom] if available."""

    fn read_from[R: Reader](inout self, inout reader: R) raises -> Int64:
        ...


trait WriterReadFrom(Writer, ReaderFrom):
    ...


trait WriterTo:
    """WriterTo is the trait that wraps the WriteTo method.

    WriteTo writes data to w until there's no more data to write or
    when an error occurs. The return value n is the number of bytes
    written. Any error encountered during the write is also returned.

    The copy function uses WriterTo if available."""

    fn write_to[W: Writer](inout self, inout writer: W) raises -> Int64:
        ...


trait ReaderWriteTo(Reader, WriterTo):
    ...


trait ReaderAt:
    """ReaderAt is the trait that wraps the basic ReadAt method.

    ReadAt reads len(p) bytes into p starting at offset off in the
    underlying input source. It returns the number of bytes
    read (0 <= n <= len(p)) and any error encountered.

    When ReadAt returns n < len(p), it returns a non-nil error
    explaining why more bytes were not returned. In this respect,
    ReadAt is stricter than Read.

    Even if ReadAt returns n < len(p), it may use all of p as scratch
    space during the call. If some data is available but not len(p) bytes,
    ReadAt blocks until either all the data is available or an error occurs.
    In this respect ReadAt is different from Read.

    If the n = len(p) bytes returned by ReadAt are at the end of the
    input source, ReadAt may return either err == EOF or err == nil.

    If ReadAt is reading from an input source with a seek offset,
    ReadAt should not affect nor be affected by the underlying
    seek offset.

    Clients of ReadAt can execute parallel ReadAt calls on the
    same input source.

    Implementations must not retain p."""

    fn read_at(self, inout dest: Bytes, off: Int64) raises -> Int:
        ...


trait WriterAt:
    """WriterAt is the trait that wraps the basic WriteAt method.

    WriteAt writes len(p) bytes from p to the underlying data stream
    at offset off. It returns the number of bytes written from p (0 <= n <= len(p))
    and any error encountered that caused the write to stop early.
    WriteAt must return a non-nil error if it returns n < len(p).

    If WriteAt is writing to a destination with a seek offset,
    WriteAt should not affect nor be affected by the underlying
    seek offset.

    Clients of WriteAt can execute parallel WriteAt calls on the same
    destination if the ranges do not overlap.

    Implementations must not retain p."""

    fn write_at(self, src: Bytes, off: Int64) raises -> Int:
        ...


trait ByteReader:
    """ByteReader is the trait that wraps the read_byte method.

    read_byte reads and returns the next byte from the input or
    any error encountered. If read_byte returns an error, no input
    byte was consumed, and the returned byte value is undefined.

    read_byte provides an efficient trait for byte-at-time
    processing. A [Reader] that does not implement ByteReader
    can be wrapped using bufio.NewReader to add this method."""

    fn read_byte(inout self) raises -> Byte:
        ...


trait ByteScanner:
    """ByteScanner is the trait that adds the unread_byte method to the
    basic read_byte method.

    unread_byte causes the next call to read_byte to return the last byte read.
    If the last operation was not a successful call to read_byte, unread_byte may
    return an error, unread the last byte read (or the byte prior to the
    last-unread byte), or (in implementations that support the [Seeker] trait)
    seek to one byte before the current offset."""

    fn unread_byte(inout self) raises:
        ...


trait ByteWriter:
    """ByteWriter is the trait that wraps the write_byte method."""

    fn write_byte(inout self, byte: Byte) raises -> Int:
        ...


trait RuneReader:
    """RuneReader is the trait that wraps the read_rune method.

    read_rune reads a single encoded Unicode character
    and returns the rune and its size in bytes. If no character is
    available, err will be set."""

    fn read_rune(inout self) -> (Rune, Int):
        ...


trait RuneScanner(RuneReader):
    """RuneScanner is the trait that adds the unread_rune method to the
    basic read_rune method.

    unread_rune causes the next call to read_rune to return the last rune read.
    If the last operation was not a successful call to read_rune, unread_rune may
    return an error, unread the last rune read (or the rune prior to the
    last-unread rune), or (in implementations that support the [Seeker] trait)
    seek to the start of the rune before the current offset."""

    fn unread_rune(inout self) -> Rune:
        ...


trait StringWriter:
    """StringWriter is the trait that wraps the WriteString method."""

    fn write_string(inout self, src: String) raises -> Int:
        ...
