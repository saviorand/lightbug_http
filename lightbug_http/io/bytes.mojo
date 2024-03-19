from python import PythonObject
from external.gojo.builtins._bytes import Bytes


@value
@register_passable("trivial")
struct UnsafeString:
    var data: Pointer[Int8]
    var len: Int

    fn __init__(str: StringLiteral) -> UnsafeString:
        var l = str.__len__()
        var s = String(str)
        var p = Pointer[Int8].alloc(l)
        for i in range(l):
            p.store(i, s.as_bytes()[i])
        return UnsafeString(p, l)

    fn __init__(str: String) -> UnsafeString:
        var l = str.__len__()
        var p = Pointer[Int8].alloc(l)
        for i in range(l):
            p.store(i, str.as_bytes()[i])
        return UnsafeString(p, l)

    fn to_string(self) -> String:
        var s = String(self.data, self.len)
        return s


fn bytes_equal(a: Bytes, b: Bytes) -> Bool:
    return a == b
