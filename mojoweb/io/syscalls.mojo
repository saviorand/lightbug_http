from collections.vector import DynamicVector

# Types aliases
alias void = UInt8
alias char = UInt8
alias schar = Int8
alias uchar = UInt8
alias short = Int16
alias ushort = UInt16
alias int = Int32
alias uint = UInt32
alias long = Int64
alias ulong = UInt64
alias float = Float32
alias double = Float64
alias time_t = Int64

alias size_t = UInt64
alias ssize_t = Int

alias ptrdiff_t = Int64
alias intptr_t = Int64
alias uintptr_t = UInt64

# standard io
alias FD_STDIN: int = 0
alias FD_STDOUT: int = 1
alias FD_STDERR: int = 2

# --- ( error.h Constants )-----------------------------------------------------
alias SUCCESS = 0
alias EPERM = 1
alias ENOENT = 2
alias ESRCH = 3
alias EINTR = 4
alias EIO = 5
alias ENXIO = 6
alias E2BIG = 7
alias ENOEXEC = 8
alias EBADF = 9
alias ECHILD = 10
alias EAGAIN = 11
alias ENOMEM = 12
alias EACCES = 13
alias EFAULT = 14
alias ENOTBLK = 15
alias EBUSY = 16
alias EEXIST = 17
alias EXDEV = 18
alias ENODEV = 19
alias ENOTDIR = 20
alias EISDIR = 21
alias EINVAL = 22
alias ENFILE = 23
alias EMFILE = 24
alias ENOTTY = 25
alias ETXTBSY = 26
alias EFBIG = 27
alias ENOSPC = 28
alias ESPIPE = 29
alias EROFS = 30
alias EMLINK = 31
alias EPIPE = 32
alias EDOM = 33
alias ERANGE = 34
alias EWOULDBLOCK = EAGAIN

# random consts
alias GRND_NONBLOCK: UInt8 = 1

alias char_pointer = AnyPointer[char]


@value
struct Str:
    var vector: DynamicVector[char]

    fn __init__(inout self, string: String):
        self.vector = DynamicVector[char](capacity=len(string) + 1)
        for i in range(len(string)):
            self.vector.push_back(ord(string[i]))
        self.vector.push_back(0)

    fn __init__(inout self, size: Int):
        self.vector = DynamicVector[char]()
        self.vector.resize(size + 1, 0)

    fn __len__(self) -> Int:
        for i in range(len(self.vector)):
            if self.vector[i] == 0:
                return i
        return -1

    fn to_string(self, size: Int) -> String:
        var result: String = ""
        for i in range(size):
            result += chr(self.vector[i].to_int())
        return result

    fn __enter__(owned self: Self) -> Self:
        return self ^
