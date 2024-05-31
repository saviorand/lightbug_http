from .types import c_int, c_char, c_void, c_size_t, c_ssize_t


# --- ( File Related Syscalls & Structs )---------------------------------------
alias O_NONBLOCK = 16384
alias O_ACCMODE = 3
alias O_CLOEXEC = 524288


fn close(fildes: c_int) -> c_int:
    """Libc POSIX `close` function
    Reference: https://man7.org/linux/man-pages/man3/close.3p.html
    Fn signature: int close(int fildes).

    Args:
        fildes: A File Descriptor to close.

    Returns:
        Upon successful completion, 0 shall be returned; otherwise, -1
        shall be returned and errno set to indicate the error.
    """
    return external_call["close", c_int, c_int](fildes)


fn open[*T: AnyType](path: Pointer[c_char], oflag: c_int, *args: *T) -> c_int:
    """Libc POSIX `open` function
    Reference: https://man7.org/linux/man-pages/man3/open.3p.html
    Fn signature: int open(const char *path, int oflag, ...).

    Args:
        path: A pointer to a C string containing the path to open.
        oflag: The flags to open the file with.
        args: The optional arguments.
    Returns:
        A File Descriptor or -1 in case of failure
    """
    return external_call["open", c_int, Pointer[c_char], c_int](path, oflag, args)  # FnName, RetType  # Args


fn openat[*T: AnyType](fd: c_int, path: Pointer[c_char], oflag: c_int, *args: *T) -> c_int:
    """Libc POSIX `open` function
    Reference: https://man7.org/linux/man-pages/man3/open.3p.html
    Fn signature: int openat(int fd, const char *path, int oflag, ...).

    Args:
        fd: A File Descriptor.
        path: A pointer to a C string containing the path to open.
        oflag: The flags to open the file with.
        args: The optional arguments.
    Returns:
        A File Descriptor or -1 in case of failure
    """
    return external_call["openat", c_int, c_int, Pointer[c_char], c_int](  # FnName, RetType  # Args
        fd, path, oflag, args
    )


fn printf[*T: AnyType](format: Pointer[c_char], *args: *T) -> c_int:
    """Libc POSIX `printf` function
    Reference: https://man7.org/linux/man-pages/man3/fprintf.3p.html
    Fn signature: int printf(const char *restrict format, ...).

    Args: format: A pointer to a C string containing the format.
        args: The optional arguments.
    Returns: The number of bytes written or -1 in case of failure.
    """
    return external_call[
        "printf",
        c_int,  # FnName, RetType
        Pointer[c_char],  # Args
    ](format, args)


fn sprintf[*T: AnyType](s: Pointer[c_char], format: Pointer[c_char], *args: *T) -> c_int:
    """Libc POSIX `sprintf` function
    Reference: https://man7.org/linux/man-pages/man3/fprintf.3p.html
    Fn signature: int sprintf(char *restrict s, const char *restrict format, ...).

    Args: s: A pointer to a buffer to store the result.
        format: A pointer to a C string containing the format.
        args: The optional arguments.
    Returns: The number of bytes written or -1 in case of failure.
    """
    return external_call["sprintf", c_int, Pointer[c_char], Pointer[c_char]](s, format, args)  # FnName, RetType  # Args


fn read(fildes: c_int, buf: Pointer[c_void], nbyte: c_size_t) -> c_int:
    """Libc POSIX `read` function
    Reference: https://man7.org/linux/man-pages/man3/read.3p.html
    Fn signature: sssize_t read(int fildes, void *buf, size_t nbyte).

    Args: fildes: A File Descriptor.
        buf: A pointer to a buffer to store the read data.
        nbyte: The number of bytes to read.
    Returns: The number of bytes read or -1 in case of failure.
    """
    return external_call["read", c_ssize_t, c_int, Pointer[c_void], c_size_t](fildes, buf, nbyte)


fn write(fildes: c_int, buf: Pointer[c_void], nbyte: c_size_t) -> c_int:
    """Libc POSIX `write` function
    Reference: https://man7.org/linux/man-pages/man3/write.3p.html
    Fn signature: ssize_t write(int fildes, const void *buf, size_t nbyte).

    Args: fildes: A File Descriptor.
        buf: A pointer to a buffer to write.
        nbyte: The number of bytes to write.
    Returns: The number of bytes written or -1 in case of failure.
    """
    return external_call["write", c_ssize_t, c_int, Pointer[c_void], c_size_t](fildes, buf, nbyte)
