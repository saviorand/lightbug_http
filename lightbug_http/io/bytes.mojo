from python import PythonObject
from lightbug_http.strings import nChar, rChar, nChar_byte, rChar_byte, to_string

alias Byte = UInt8
alias Bytes = List[Byte, True]

fn bytes(s: StringLiteral, pop: Bool = True) -> Bytes:
    var buf = String(s)._buffer
    if pop:
        _ = buf.pop()
    return buf

fn bytes(s: String, pop: Bool = True) -> Bytes:
    var buf = s._buffer
    if pop:
        _ = buf.pop()
    return buf

fn bytes_equal(a: Bytes, b: Bytes) -> Bool:
    return to_string(a) == to_string(b)

fn index_byte(buf: Bytes, c: Byte) -> Int:
    for i in range(len(buf)):
        if buf[i] == c:
            return i
    return -1

fn last_index_byte(buf: Bytes, c: Byte) -> Int:
    for i in range(len(buf)-1, -1, -1):
        if buf[i] == c:
            return i
    return -1

fn compare_case_insensitive(a: Bytes, b: Bytes) -> Bool:
    if len(a) != len(b):
        return False
    for i in range(len(a) - 1):
        if (a[i] | 0x20) != (b[i] | 0x20):
            return False
    return True

fn next_line(b: Bytes) raises -> (Bytes, Bytes):
    var n_next = index_byte(b, nChar_byte)
    if n_next < 0:
        raise Error("next_line: newline not found")
    var n = n_next
    if n > 0 and (b[n-1] == rChar_byte):
        n -= 1
    return (b[:n+1], b[n_next+1:])

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

