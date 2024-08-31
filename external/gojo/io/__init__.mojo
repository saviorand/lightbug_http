"""`io` provides basic interfaces to I/O primitives.
Its primary job is to wrap existing implementations of such primitives,
such as those in package os, into shared public interfaces that
abstract the fntionality, plus some other related primitives.

Because these interfaces and primitives wrap lower-level operations with
various implementations, unless otherwise informed clients should not
assume they are safe for parallel execution.
seek whence values.
"""
from utils import Span
from .io import write_string, read_at_least, read_full, read_all, BUFFER_SIZE
from .file import FileWrapper
from .std import STDWriter


alias Rune = Int32

alias SEEK_START = 0
"""seek relative to the origin of the file."""
alias SEEK_CURRENT = 1
"""seek relative to the current offset."""
alias SEEK_END = 2
"""seek relative to the end."""

alias ERR_SHORT_WRITE = Error("short write")
"""A write accepted fewer bytes than requested, but failed to return an explicit error."""

alias ERR_INVALID_WRITE = Error("invalid write result")
"""A write returned an impossible count."""

alias ERR_SHORT_BUFFER = Error("short buffer")
"""A read required a longer buffer than was provided."""

alias EOF = Error("EOF")
"""Returned by `read` when no more input is available.
(`read` must return `EOF` itself, not an error wrapping EOF,
because callers will test for EOF using `==`)

Functions should return `EOF` only to signal a graceful end of input.
If the `EOF` occurs unexpectedly in a structured data stream,
the appropriate error is either `ERR_UNEXPECTED_EOF` or some other error
giving more detail."""

alias ERR_UNEXPECTED_EOF = Error("unexpected EOF")
"""EOF was encountered in the middle of reading a fixed-size block or data structure."""

alias ERR_NO_PROGRESS = Error("multiple read calls return no data or error")
"""Returned by some clients of a `Reader` when
many calls to read have failed to return any data or error,
usually the sign of a broken `Reader` implementation."""


trait Reader(Movable):
    """Wraps the basic `read` method.

    `read` reads up to `len(dest)` bytes into p. It returns the number of bytes
    `read` `(0 <= n <= len(dest))` and any error encountered. Even if `read`
    returns n < `len(dest)`, it may use all of p as scratch space during the call.
    If some data is available but not `len(dest)` bytes, read conventionally
    returns what is available instead of waiting for more.

    When read encounters an error or end-of-file condition after
    successfully reading n > 0 bytes, it returns the number of
    bytes read. It may return an error from the same call
    or return the error (and n == 0) from a subsequent call.
    An instance of this general case is that a Reader returning
    a non-zero number of bytes at the end of the input stream may
    return either err == `EOF` or err == Error(). The next read should
    return 0, EOF.

    Callers should always process the n > 0 bytes returned before
    considering the error err. Doing so correctly handles I/O errors
    that happen after reading some bytes and also both of the
    allowed `EOF` behaviors.

    If `len(dest) == 0`, `read` should always return n == 0. It may return an
    error if some error condition is known, such as `EOF`.

    Implementations of `read` are discouraged from returning a
    zero byte count with an empty error, except when `len(dest) == 0`.
    Callers should treat a return of 0 and an empty error as indicating that
    nothing happened; in particular it does not indicate `EOF`.

    Implementations must not retain `dest`."""

    fn read(inout self, inout dest: List[UInt8, True]) -> (Int, Error):
        ...

    fn _read(inout self, inout dest: UnsafePointer[UInt8], capacity: Int) -> (Int, Error):
        ...


trait Writer(Movable):
    """Wraps the basic `write` method.

    `write` writes `len(dest)` bytes from `src` to the underlying data stream.
    It returns the number of bytes written from `src` (0 <= n <= `len(dest)`)
    and any error encountered that caused the `write` to stop early.
    `write` must return an error if it returns `n < len(dest)`.
    `write` must not modify the data `src`, even temporarily.

    Implementations must not retain `src`.
    """

    fn write(inout self, src: Span[UInt8, _]) -> (Int, Error):
        ...


trait Closer(Movable):
    """Wraps the basic `close` method.

    The behavior of `close` after the first call is undefined.
    Specific implementations may document their own behavior.
    """

    fn close(inout self) -> Error:
        ...


trait Seeker(Movable):
    """Wraps the basic `seek` method.

    `seek` sets the offset for the next read or write to offset,
    interpreted according to whence:
    `SEEK_START` means relative to the start of the file,
    `SEEK_CURRENT` means relative to the current offset, and
    `SEEK_END]` means relative to the end
    (for example, `offset = -2` specifies the penultimate byte of the file).
    `seek` returns the new offset relative to the start of the
    file or an error, if any.

    Seeking to an offset before the start of the file is an error.
    Seeking to any positive offset may be allowed, but if the new offset exceeds
    the size of the underlying object the behavior of subsequent I/O operations
    is implementation dependent.
    """

    fn seek(inout self, offset: Int, whence: Int) -> (Int, Error):
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
    """Wraps the `read_from` method.

    `read_from` reads data from `reader` until `EOF` or error.
    The return value n is the number of bytes read.
    Any error except `EOF` encountered during the read is also returned.
    """

    fn read_from[R: Reader](inout self, inout reader: R) -> (Int, Error):
        ...


trait WriterReadFrom(Writer, ReaderFrom):
    ...


trait WriterTo:
    """Wraps the `write_to` method.

    `write_to` writes data to `writer` until there's no more data to write or
    when an error occurs. The return value n is the number of bytes
    written. Any error encountered during the write is also returned.
    """

    fn write_to[W: Writer](inout self, inout writer: W) -> (Int, Error):
        ...


trait ReaderWriteTo(Reader, WriterTo):
    ...


trait ReaderAt:
    """Wraps the basic `read_at` method.

    `read_at` reads `len(dest)` bytes into `dest` starting at offset `off` in the
    underlying input source. It returns the number of bytes
    read (`0 <= n <= len(dest)`) and any error encountered.

    When `read_at` returns `n < len(dest)`, it returns an error
    explaining why more bytes were not returned. In this respect,
    `read_at` is stricter than `read`.

    Even if `read_at` returns `n < len(dest)`, it may use all of `dest` as scratch
    space during the call. If some data is available but not `len(dest)` bytes,
    `read_at` blocks until either all the data is available or an error occurs.
    In this respect `read_at` is different from `read`.

    If the `n = len(dest)` bytes returned by `read_at` are at the end of the
    input source, `read_at` may return either err == `EOF` or an empty error.

    If `read_at` is reading from an input source with a seek offset,
    `read_at` should not affect nor be affected by the underlying
    seek offset.

    Clients of `read_at` can execute parallel `read_at` calls on the
    same input source.

    Implementations must not retain `dest`."""

    fn read_at(self, inout dest: List[UInt8, True], off: Int) -> (Int, Error):
        ...

    fn _read_at(self, inout dest: Span[UInt8], off: Int, capacity: Int) -> (Int, Error):
        ...


trait WriterAt:
    """Wraps the basic `write_at` method.

    `write_at` writes `len(dest)` bytes from p to the underlying data stream
    at offset `off`. It returns the number of bytes written from p (`0 <= n <= len(dest)`)
    and any error encountered that caused the write to stop early.
    `write_at` must return an error if it returns `n < len(dest)`.

    If `write_at` is writing to a destination with a seek offset,
    `write_at` should not affect nor be affected by the underlying
    seek offset.

    Clients of `write_at` can execute parallel `write_at` calls on the same
    destination if the ranges do not overlap.

    Implementations must not retain `src`."""

    fn _write_at(self, src: Span[UInt8], off: Int) -> (Int, Error):
        ...

    fn write_at(self, src: List[UInt8, True], off: Int) -> (Int, Error):
        ...


trait ByteReader:
    """Wraps the `read_byte` method.

    `read_byte` reads and returns the next byte from the input or
    any error encountered. If `read_byte` returns an error, no input
    byte was consumed, and the returned byte value is undefined.

    `read_byte` provides an efficient trait for byte-at-time
    processing. A `Reader` that does not implement `ByteReader`
    can be wrapped using `bufio.Reader` to add this method."""

    fn read_byte(inout self) -> (UInt8, Error):
        ...


trait ByteScanner(ByteReader):
    """Adds the `unread_byte` method to the basic `read_byte` method.

    `unread_byte` causes the next call to `read_byte` to return the last byte read.
    If the last operation was not a successful call to `read_byte`, `unread_byte` may
    return an error, unread the last byte read (or the byte prior to the
    last-unread byte), or (in implementations that support the `Seeker` trait)
    seek to one byte before the current offset."""

    fn unread_byte(inout self) -> Error:
        ...


trait ByteWriter:
    """Wraps the `write_byte` method."""

    fn write_byte(inout self, byte: UInt8) -> (Int, Error):
        ...


trait RuneReader:
    """Wraps the `read_rune` method.

    `read_rune` reads a single encoded Unicode character
    and returns the rune and its size in bytes. If no character is
    available, err will be set."""

    fn read_rune(inout self) -> (Rune, Int):
        ...


trait RuneScanner(RuneReader):
    """Adds the `unread_rune` method to the basic `read_rune` method.

    `unread_rune` causes the next call to `read_rune` to return the last rune read.
    If the last operation was not a successful call to `read_rune`, `unread_rune` may
    return an error, unread the last rune read (or the rune prior to the
    last-unread rune), or (in implementations that support the `Seeker` trait)
    seek to the start of the rune before the current offset."""

    fn unread_rune(inout self) -> Rune:
        ...


trait StringWriter:
    """Wraps the `write_string` method."""

    fn write_string(inout self, src: String) -> (Int, Error):
        ...
