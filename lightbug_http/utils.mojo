from lightbug_http.io.bytes import Bytes, Byte
from lightbug_http.strings import BytesConstant
from lightbug_http.net import default_buffer_size
from memory import memcpy

@always_inline
fn is_newline(b: Byte) -> Bool:
    return b == BytesConstant.nChar or b == BytesConstant.rChar

@always_inline
fn is_space(b: Byte) -> Bool:
    return b == BytesConstant.whitespace

struct ByteWriter:

    var _inner: Bytes

    fn __init__(inout self):
        self._inner = Bytes(capacity=default_buffer_size)

    @always_inline
    fn write(inout self, owned b: Bytes):
        self._inner.extend(b^)

    @always_inline
    fn write(inout self, inout s: String):
        # kind of cursed but seems to work?
        _ = s._buffer.pop()
        self._inner.extend(s._buffer^)
        s._buffer = s._buffer_type()

    @always_inline
    fn write(inout self, s: StringLiteral):
        var str = String(s)
        self.write(str)

    @always_inline
    fn write(inout self, b: Byte):
        self._inner.append(b)
        
    fn consume(inout self) -> Bytes:
        var ret = self._inner^
        self._inner = Bytes()
        return ret^

struct ByteReader:
    var _inner: Bytes
    var read_pos: Int

    fn __init__(inout self, owned b: Bytes):
        self._inner = b^
        self.read_pos = 0

    fn peek(self) -> Byte:
        if self.read_pos >= len(self._inner):
            return 0
        return self._inner[self.read_pos]

    fn read_until(inout self, char: Byte) -> Bytes:
        var start = self.read_pos
        while self.peek() != char:
            self.increment()
        return self._inner[start:self.read_pos]

    @always_inline
    fn read_word(inout self) -> Bytes:
        return self.read_until(BytesConstant.whitespace)

    fn read_line(inout self) -> Bytes:
        var start = self.read_pos
        while not is_newline(self.peek()):
            self.increment()
        var ret = self._inner[start:self.read_pos]
        if self.peek() == BytesConstant.rChar:
            self.increment(2)
        else:
            self.increment()
        return ret

    @always_inline
    fn skip_whitespace(inout self):
        while is_space(self.peek()):
            self.increment()

    @always_inline
    fn increment(inout self, v: Int = 1):
        self.read_pos += v

    @always_inline
    fn consume(inout self, inout buffer: Bytes):
        var pos = self.read_pos
        self.read_pos = -1
        var read_len = len(self._inner) - pos
        buffer.resize(read_len, 0)
        memcpy(buffer.data, self._inner.data + pos, read_len)


    