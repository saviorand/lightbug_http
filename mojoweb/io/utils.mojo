alias Bytes = DynamicVector[Int8]

# Time in nanoseconds
alias Duration = Int


fn bytes_equal(a: Bytes, b: Bytes) -> Bool:
    return String(a) == String(b)


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
