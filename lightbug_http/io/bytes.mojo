from python import PythonObject

alias Bytes = DynamicVector[Int8]


@value
@register_passable("trivial")
struct UnsafeString:
    var data: Pointer[Int8]
    var len: Int

    fn __init__(inout self, str: StringLiteral) -> UnsafeString:
        let l = str.__len__()
        let s = String(str)
        let p = Pointer[Int8].alloc(l)
        for i in range(l):
            p.store(i, s._buffer[i])
        return UnsafeString(p, l)

    fn __init__(str: String) -> UnsafeString:
        let l = str.__len__()
        let p = Pointer[Int8].alloc(l)
        for i in range(l):
            p.store(i, str._buffer[i])
        return UnsafeString(p, l)

    fn to_string(self) -> String:
        let s = String(self.data, self.len)
        return s


fn bytes_equal(a: Bytes, b: Bytes) -> Bool:
    return String(a) == String(b)
