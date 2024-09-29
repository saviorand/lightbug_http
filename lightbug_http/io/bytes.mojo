from python import PythonObject
from lightbug_http.strings import nChar, rChar, to_string

alias Byte = UInt8
alias Bytes = List[Byte, True]


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

