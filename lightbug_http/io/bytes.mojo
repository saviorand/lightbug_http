from python import PythonObject
from base64 import b64encode
from memory.unsafe import bitcast

alias ByteDType = DType.int8
alias Bytes = DynamicVector[Int8]
alias Byte = Int8


fn to_bytes(string: String) -> Bytes:
    return b64encode(string)._buffer


fn to_bytes[type: DType, nelts: Int = 1](simd: SIMD[type, nelts]) -> Bytes:
    let simd_bytes = bitcast[ByteDType, nelts * sizeof[type](), type, nelts](simd)

    var bytes = Bytes(nelts * sizeof[type]())

    @unroll
    for i in range(nelts * sizeof[type]()):
        bytes.append(simd_bytes[i])

    return bytes


fn to_string(bytes: Bytes) -> String:
    return b64decode(bytes)


fn rstrip_unsafe(content: String, chars: String = " ") -> String:
    var strip_pos: Int = len(content)
    for i in range(len(content)):
        let c = content[len(content) - i - 1 : len(content) - i]
        if chars.find(c) == -1:
            strip_pos = len(content) - i
            break

    return content[:strip_pos]


# Temporary until stdlib base64 decode is implemented
fn b64decode(s: String) -> String:
    alias base64: String = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

    let padding = s.count("=")

    let s_strip = rstrip_unsafe(s, "=")

    # base64 decode
    var binary_string: String = ""
    for i in range(len(s_strip)):
        let index: Byte = base64.find(s_strip[i : i + 1])
        binary_string += byte_to_binary_string(index)

    if padding:
        binary_string = binary_string[: -padding * 2]

    var decoded_string: String = ""
    for i in range(0, len(binary_string), 8):
        let byte = binary_string[i : i + 8]
        decoded_string += chr(binary_string_to_byte(byte).to_int())

    return decoded_string


fn byte_to_binary_string(byte: Byte) -> String:
    var binary_string: String = ""
    for i in range(8):
        let bit = (byte >> i) & 1
        binary_string += String(bit)

    # find significant bits
    var significant_binary_string: String = ""
    var found_significant_bit: Bool = False
    for i in range(len(binary_string)):
        let bit = binary_string[len(binary_string) - i - 1 : len(binary_string) - i]
        if bit == "1":
            found_significant_bit = True
        if found_significant_bit:
            significant_binary_string += bit

    # left pad to 6 bits if less than 6 bits
    if len(significant_binary_string) < 6:
        let padding = 6 - len(significant_binary_string)
        for i in range(padding):
            significant_binary_string = "0" + significant_binary_string

    return significant_binary_string


fn binary_string_to_byte(binary_string: String) -> Byte:
    var total = 0
    let length = len(binary_string)
    for i in range(length):
        # Get the value at the current position (0 or 1)
        let bit = binary_string[length - 1 - i]

        let bit_value: Int
        if bit == "1":
            bit_value = 1
        else:
            bit_value = 0

        # Add to the total, considering its position (2^i)
        total += bit_value * (2**i)

    return total


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
