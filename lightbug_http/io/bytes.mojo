from python import PythonObject
from lightbug_http.strings import nChar, rChar, to_string

alias Byte = UInt8
alias Bytes = List[Byte]


@always_inline
fn byte(s: String) -> Byte:
    return ord(s)


@always_inline
fn bytes(s: String) -> Bytes:
    return s.as_bytes()


fn bytes_equal(a: Bytes, b: Bytes) -> Bool:
    return to_string(a) == to_string(b)


fn compare_case_insensitive(a: Bytes, b: Bytes) -> Bool:
    if len(a) != len(b):
        return False
    for i in range(len(a) - 1):
        if (a[i] | 0x20) != (b[i] | 0x20):
            return False
    return True


@value
@register_passable("trivial")
struct UnsafeString:
    var data: UnsafePointer[UInt8]
    var len: Int

    fn __init__(inout self) -> None:
        self.data = UnsafePointer[UInt8]()
        self.len = 0

    fn __init__(inout self, str: StringLiteral) -> None:
        var l = str.__len__()
        var s = String(str)
        var p = UnsafePointer[UInt8].alloc(l)
        for i in range(l):
            p.store(i, s._buffer[i])
        self.data = p
        self.len = l

    fn __init__(inout self, str: String) -> None:
        var l = str.__len__()
        var p = UnsafePointer[UInt8].alloc(l)
        for i in range(l):
            p.store(i, str._buffer[i])
        self.data = p
        self.len = l

    fn to_string(self) -> String:
        var s = String(self.data, self.len)
        return s
