from mojoweb.io.bytes import Bytes

alias O_RDWR = 0o2


@value
struct FileDescriptor:
    var fd: Int

    fn __moveinit__(inout self, owned existing: Self):
        self.fd = existing.fd

    fn __init__(inout self, fd: Int):
        self.fd = fd

    fn __init__(inout self, path: String):
        let mode: Int = 0o644  # file permission

        # Call the open(2) syscall with appropriate flags and mode
        self.fd = external_call["open", Int, String, Int, Int](path, O_RDWR, mode)

    fn __del__(owned self):
        # Call the close(2) syscall
        external_call["close", Int, Int](self.fd)

    fn dup(self) -> Self:
        # Invoke the dup(2) system call
        let new_fd = external_call["dup", Int, Int](self.fd)
        return FileDescriptor(new_fd)

    fn read(self, buffer: Bytes, count: Int) -> Int:
        # Invoke the read(2) system call
        return external_call["read", Int, Int, Bytes, Int](self.fd, buffer, count)

    fn write(self, buffer: Bytes, count: Int) -> Int:
        # Invoke the write(2) system call
        return external_call["write", Int, Int, Bytes, Int](self.fd, buffer, count)


# # This is a simple wrapper around POSIX-style fcntl.h functions.
# struct FileDescriptor:
#     var fd: Int

#     # This is how we move our unique type.
#     fn __moveinit__(inout self, owned existing: Self):
#         self.fd = existing.fd

#     # This takes ownership of a POSIX file descriptor.
#     fn __init__(inout self, fd: Int):
#         self.fd = fd

#     fn __init__(inout self, path: String):
#         # Error handling omitted, call the open(2) syscall.
#         self = FileDescriptor(open(path, ...))

#     fn __del__(owned self):
#         close(self.fd)   # pseudo code, call close(2)

#     fn dup(self) -> Self:
#         # Invoke the dup(2) system call.
#         return Self(dup(self.fd))
#     fn read(...): ...
#     fn write(...): ...
