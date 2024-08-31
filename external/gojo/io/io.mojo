from ..builtins import copy, panic

alias BUFFER_SIZE = 4096
"""The default buffer size for reading and writing operations."""


fn write_string[W: Writer](inout writer: W, string: String) -> (Int, Error):
    """Writes the contents of the `string` to `writer`, which accepts a Span of bytes.
    If `writer` implements `StringWriter`, `StringWriter.write_string` is invoked directly.
    Otherwise, `Writer.write` is called exactly once.

    Args:
        writer: The writer to write to.
        string: The string to write.

    Returns:
        The number of bytes written and an error, if any.
    """
    return writer.write(string.as_bytes_slice())


fn write_string[W: StringWriter](inout writer: W, string: String) -> (Int, Error):
    """Writes the contents of the `string` to `writer`, which accepts a Span of bytes.
    If `writer` implements `StringWriter`, `StringWriter.write_string` is invoked directly.
    Otherwise, `Writer.write` is called exactly once.

    Args:
        writer: The writer to write to.
        string: The string to write.

    Returns:
        The number of bytes written and an error, if any.
    """
    return writer.write_string(string)


fn read_at_least[R: Reader](inout reader: R, inout dest: List[UInt8, True], min: Int) -> (Int, Error):
    """Reads from `reader` into `dest` until it has read at least `min` bytes.
    It returns the number of bytes copied and an error if fewer bytes were read.
    The error is `EOF` only if no bytes were read.
    If an `EOF` happens after reading fewer than min bytes,
    `read_at_least` returns `ERR_UNEXPECTED_EOF`.
    If min is greater than the length of `dest`, `read_at_least` returns `ERR_SHORT_BUFFER`.
    On return, `n >= min` if and only if err is empty.
    If `reader` returns an error having read at least min bytes, the error is dropped.

    Args:
        reader: The reader to read from.
        dest: The buffer to read into.
        min: The minimum number of bytes to read.

    Returns:
        The number of bytes read.
    """
    var error = Error()
    if len(dest) < min:
        return 0, io.ERR_SHORT_BUFFER

    var total_bytes_read: Int = 0
    while total_bytes_read < min and not error:
        var bytes_read: Int
        bytes_read, error = reader.read(dest)
        total_bytes_read += bytes_read

    if total_bytes_read >= min:
        error = Error()

    elif total_bytes_read > 0 and str(error):
        error = ERR_UNEXPECTED_EOF

    return total_bytes_read, error


fn read_full[R: Reader](inout reader: R, inout dest: List[UInt8, True]) -> (Int, Error):
    """Reads exactly `len(dest)` bytes from `reader` into `dest`.
    It returns the number of bytes copied and an error if fewer bytes were read.
    The error is `EOF` only if no bytes were read.
    If an `EOF` happens after reading some but not all the bytes,
    `read_full` returns `ERR_UNEXPECTED_EOF`.
    On return, `n == len(buf)` if and only if err is empty.
    If `reader` returns an error having read at least `len(buf)` bytes, the error is dropped.
    """
    return read_at_least(reader, dest, len(dest))


# TODO: read directly into dest
fn read_all[R: Reader](inout reader: R) -> (List[UInt8, True], Error):
    """Reads from `reader` until an error or `EOF` and returns the data it read.
    A successful call returns an empty err, and not err == `EOF`. Because `read_all` is
    defined to read from `src` until `EOF`, it does not treat an `EOF` from `read`
    as an error to be reported.

    Args:
        reader: The reader to read from.

    Returns:
        The data read.
    """
    var dest = List[UInt8, True](capacity=BUFFER_SIZE)
    var at_eof: Bool = False

    while True:
        var temp = List[UInt8, True](capacity=BUFFER_SIZE)
        var bytes_read: Int
        var err: Error
        bytes_read, err = reader.read(temp)
        if str(err) != "":
            if str(err) != str(EOF):
                return dest, err

            at_eof = True

        # If new bytes will overflow the result, resize it.
        # if some bytes were written, how do I append before returning result on the last one?
        if len(dest) + len(temp) > dest.capacity:
            dest.reserve(dest.capacity * 2)
        dest.extend(temp)

        if at_eof:
            return dest, err
